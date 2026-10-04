# qFlood container

Based on [hotio/rflood](https://github.com/hotio/rflood), replacing rTorrent with qBittorrent and retaining Flood. Uses libtorrent v2 by default; `LIBTORRENT=v1` selects the alternative binary. Both application binaries are bundled on the edbfi Alpine base.

[Documentation and examples](https://web.edb.fi/containers/qflood/).

CI builds the amd64 and arm64 images and checks that Flood answers before publishing them. Base image tags and application versions in `meta.json` are updated hourly through their `__command` entries. The nightly image follows the latest Flood `master` build, and every update is built and published.

Set `FLOOD_AUTH=true` for Flood account setup. Configure its qBittorrent connection using the Web UI credentials. The optional no-auth mode expects qBittorrent to permit localhost access; enabling it is an explicit user configuration choice. Existing authentication defaults are preserved.

Upstream GPL-3.0 image license and application licenses remain applicable. VPN connectivity and real torrent transfers require separate integration validation.
