#!/usr/bin/env bash
set -euo pipefail
image="$1"
evidence="$2"
bash tools/base-smoke.sh "$image" "$evidence"
expected="v$(jq -r '.version | split("--")[0]' meta.json)"
for lib in 1 2; do
  docker run --rm --entrypoint "/app/qbittorrent-nox-lib$lib" "$image" --version > "$evidence/version-lib$lib.txt"
  grep -Fx "qBittorrent $expected" "$evidence/version-lib$lib.txt"
done
name="qflood-smoke-${GITHUB_RUN_ID:-local}-${RANDOM}"
config=$(mktemp -d)
host_uid=$(id -u)
host_gid=$(id -g)
cleanup() {
  docker logs "$name" 2>&1 | sed -E 's/(temporary password[^:]*:).*/\1 [REDACTED]/' > "$evidence/qbittorrent.log" || true
  docker rm -f "$name" >/dev/null 2>&1 || true
  # The image owns this disposable test directory as UID 1000.
  docker run --rm --entrypoint sh -v "$config:/test-config" "$image" -c 'rm -rf /test-config/*; chown "$1:$2" /test-config' sh "$host_uid" "$host_gid" >/dev/null 2>&1 || true
  rmdir "$config" || true
}
trap cleanup EXIT
# Permit loopback API access only in this disposable test configuration.
# Disable peer discovery; no torrents are added by this test.
mkdir -p "$config/config"
cat > "$config/config/qBittorrent.conf" <<'CONFIG'
[Preferences]
WebUI\LocalHostAuth=false
[BitTorrent]
Session\DHTEnabled=false
Session\LSDEnabled=false
Session\PeXEnabled=false
CONFIG
# The base intentionally takes ownership of only /config itself.
# Pre-existing fixture files must belong to the application user too.
docker run --rm --entrypoint sh -v "$config:/test-config" "$image" -c 'chown -R 1000:1000 /test-config'
for mode in default v1; do
  opts=()
  if [[ "$mode" == v1 ]]; then opts+=(-e LIBTORRENT=v1); fi
  docker run --detach --name "$name" -v "$config:/config" -e VPN_ENABLED=false "${opts[@]}" "$image"
  ready=false
  for _ in {1..60}; do
    if docker exec "$name" curl -fsS http://127.0.0.1:8080/api/v2/app/version > "$evidence/api-version-$mode.txt"; then ready=true; break; fi
    sleep 1
  done
  test "$ready" = true
  test "$(cat "$evidence/api-version-$mode.txt")" = "$expected"
  docker exec "$name" curl -fsS http://127.0.0.1:8080/api/v2/app/buildInfo > "$evidence/build-info-$mode.json"
  if [[ "$mode" == default ]]; then lib_version='2.0.14'; else lib_version='1.2.20'; fi
  jq -e --arg v "$lib_version" '.libtorrent | startswith($v)' "$evidence/build-info-$mode.json"
  docker exec "$name" curl -fsS http://127.0.0.1:8080/ > "$evidence/http-$mode.html"
  grep -qi qbittorrent "$evidence/http-$mode.html"
  docker exec "$name" sh -ec 'test "$(stat -c %u /config/config/qBittorrent.conf)" = 1000; test -d /config/flood'
  ready=false
  for _ in {1..60}; do
    if docker exec "$name" curl -fsS -c /tmp/flood-cookies http://127.0.0.1:3000/api/auth/verify > "$evidence/flood-session-$mode.json"; then ready=true; break; fi
    sleep 1
  done
  test "$ready" = true
  jq -e '.configs.authMethod == "none"' "$evidence/flood-session-$mode.json"
  ready=false
  for _ in {1..60}; do
    if docker exec "$name" curl -fsS -b /tmp/flood-cookies http://127.0.0.1:3000/api/client/connection-test > "$evidence/flood-connection-$mode.json"; then ready=true; break; fi
    sleep 1
  done
  test "$ready" = true
  jq -e '.isConnected == true' "$evidence/flood-connection-$mode.json"
  docker exec "$name" curl -fsS http://127.0.0.1:3000/ > "$evidence/flood-$mode.html"
  grep -qi flood "$evidence/flood-$mode.html"
  docker logs "$name" 2>&1 | sed -E 's/(temporary password[^:]*:).*/\1 [REDACTED]/' > "$evidence/qbittorrent-$mode.log"
  docker rm -f "$name" >/dev/null
 done
docker run --rm --entrypoint /app/flood "$image" --version > "$evidence/flood-version.txt"
expected_flood=$(jq -r '.flood_binary_version // .version_flood' meta.json)
grep -Fx "$expected_flood" "$evidence/flood-version.txt"
docker run --detach --name "$name" -v "$config:/config" -e VPN_ENABLED=false -e FLOOD_AUTH=true "$image"
ready=false
for _ in {1..60}; do
  if docker exec "$name" curl -fsS http://127.0.0.1:3000/api/auth/verify > "$evidence/flood-auth.json"; then ready=true; break; fi
  sleep 1
done
test "$ready" = true
jq -e '.initialUser == true and .configs.authMethod == "default"' "$evidence/flood-auth.json"
code=$(docker exec "$name" curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/api/client/connection-test)
test "$code" = 401
printf 'Both libtorrent modes, version/build APIs, Flood connection/HTTP/auth setup and configuration ownership passed.\n' >> "$evidence/result.txt"
