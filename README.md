# qFlood container

Based on [hotio/rflood](https://github.com/hotio/rflood), replacing rTorrent with qBittorrent and retaining Flood. Uses libtorrent v2 by default; `LIBTORRENT=v1` selects the alternative binary. Both application binaries are bundled on the edbfi Alpine base.

[Documentation and examples](https://web.edb.fi/containers/qflood/).

Native amd64/arm64 CI validates both libtorrent modes, Flood HTTP and its connection to qBittorrent. Publication is manual after review. Base images and application downloads are SHA-256 pinned; update checksums with versions. Nightly snapshots are reviewed and pinned, not automatically published on upstream events.

Set `FLOOD_AUTH=true` for Flood account setup. Configure its qBittorrent connection using the Web UI credentials. The optional no-auth mode expects qBittorrent to permit localhost access; enabling it is an explicit user configuration choice. Existing authentication defaults are preserved.

Upstream GPL-3.0 image license and application licenses remain applicable. VPN connectivity and real torrent transfers require separate integration validation.

Shared CI and Renovate presets use automation `v3.0.0`. The custom checked merger
is retired. Renovate automerge is explicitly disabled pending verified required
CI enforcement and a native Renovate canary. The read-only PR policy check
preserves sign-offs, Conventional Commit titles, review and hold requirements.
Native architecture builds and every existing container smoke assertion remain
mandatory; image publication remains an explicit manual operation after CI.
