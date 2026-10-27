---
id: "hdde6bfsd9"
title: "Try Bitmagnet securely and privately"
state: "todo"
due: ""
priority: ""
tag: ["search", "privacy"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-26"
closed: ""
---


Bitmagnet (https://bitmagnet.io) is a self-hosted BitTorrent DHT crawler and search engine.
Try it without exposing my home IP or this Mac.

## Concerns

- The DHT crawler talks to thousands of peers over UDP, so my IP shows up in the DHT. ISPs can see the traffic.
- It indexes whatever is in the DHT, including content that may be illegal to download where I live. Indexing metadata is not downloading, but keep the two apart.
- The web UI and GraphQL API have no authentication.

## Plan

- Run it in Docker (Colima) next to SearXNG, with Postgres; config in `~/dot_local/config/bitmagnet/`.
- Route all DHT traffic through a VPN container (gluetun) with a kill switch, so nothing leaks if the VPN drops. Check the VPN provider allows P2P.
- Bind the web UI to `127.0.0.1` only. Publish no DHT port on the host.
- Drop container capabilities, set no-new-privileges, pin image tags.
- Optional: add Bitmagnet's Torznab endpoint as a SearXNG engine.

## Acceptance

- The IP seen from inside the bitmagnet container is the VPN's, not mine; stopping the VPN stops all crawler traffic.
- http://localhost:3333 works from this Mac; nothing listens on the LAN.
