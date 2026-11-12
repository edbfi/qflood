<p align="center">
  <img src="assets/qflood.svg" alt="qflood logo" width="160" height="160">
</p>
<h1 align="center">qflood</h1>
<p align="center"><strong>qBittorrent with Flood in a VPN-ready container.</strong></p>
<p align="center">
  <a href="https://github.com/edbfi/qflood/blob/release/LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-blue?style=flat" alt="License: GPL-3.0"></a>
  <a href="https://github.com/moby/moby" title="Docker Engine source (Moby)"><img src="https://img.shields.io/badge/Docker-2496ED?style=flat&amp;logo=docker&amp;logoColor=white" alt="Docker"></a>
  <a href="https://github.com/qbittorrent/qBittorrent"><img src="https://img.shields.io/badge/qBittorrent-2F67BA?style=flat&amp;logo=qbittorrent&amp;logoColor=white" alt="qBittorrent"></a>
  <a href="https://github.com/jesec/flood"><img src="https://img.shields.io/badge/Flood-4A90E2?style=flat" alt="Flood"></a>
</p>

Based on [hotio/rflood](https://github.com/hotio/rflood), replacing rTorrent with qBittorrent and retaining Flood. Uses libtorrent v2 by default; `LIBTORRENT=v1` selects the alternative binary.

[Documentation and examples](https://web.edb.fi/containers/qflood/).

The nightly image follows the latest Flood `master` build.

Set `FLOOD_AUTH=true` for Flood account setup. Configure its qBittorrent connection using the Web UI credentials. The optional no-auth mode expects qBittorrent to permit localhost access; enabling it is an explicit user configuration choice.
