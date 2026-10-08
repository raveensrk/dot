---
id: "ca9xxgb0es"
title: "Check upstream powerline wrap issue 244 and pi issue 9628"
state: "todo"
due: "2026-10-21"
priority: "B"
tag: []
repeat: ""
effort: ""
postpone: 0
created: "2026-10-08"
closed: ""
---

Two-week check on upstream items from 2026-10-07.

1. https://github.com/nicobailon/pi-powerline-footer/issues/244 - asked upstream to wrap secondary-row overflow into extra rows instead of dropping the tail (zoomed-in terminal loses the last powerline items). Offered a PR. If it shipped: opt in via the new powerline setting and stop dropping the tail.

2. https://github.com/earendil-works/pi/issues/9628 - "bash tool: show elapsed time in minutes once it passes 60s". CLOSED as of 2026-10-07; closed is not shipped. If a pi release carries it, retire the local bundle patch: ~/dot/script/install_pi_timeout_label.py, ~/dot/config/pi/patches/timeout_label.patch, and the timeout-label-patch.ts guard.
