---
id: "a8b2zhpend"
title: "Follow up PR 247: unlimited powerline wrap with a wrap_compact setting"
state: "done"
due: "2026-10-12"
priority: "A"
tag: ["pi"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-11"
closed: "2026-10-11T21:10"
---

Follow-up to https://github.com/nicobailon/pi-powerline-footer/pull/247
("feat(layout): wrap secondary-row overflow onto extra rows (#244)",
merged 2026-10-10). Issue #244 is mostly fixed, but not fully. Related task:
ca9x (check upstream powerline wrap issue 244).

## Asks

1. No row limit. Wrap still drops items once it hits a limit. Make it
   unlimited: never lose information.
2. Keep the `>` separator between items.
3. Do not guess where to break. Breaking only at separators leaves empty
   space on the right side of each row. Fill each row to the right edge and
   break where the width runs out.
4. Proposal: a new `secondaryOverflow` setting value, `wrap_compact`, so the
   current wrap stays as it is for anyone who likes it. 1,2,3 will go into a new option.

## Acceptance

- With `secondaryOverflow: "wrap_compact"` and a zoomed-in terminal, every
  secondary-row item shows, however many rows that takes.
- Each row but the last reaches the right edge; no ragged gap.
- `>` still separates items.

## References

1. `~/Desktop/Screen Recording 2026-10-11 at 8.55.16 PM.mov` (35 s) - current
   `wrap` in pi: the secondary row breaks before `opencode`, leaving a gap on
   the right of the first row, and the `>` at the break is gone.
2. `~/Desktop/Screen Recording 2026-10-11 at 9.04.00 PM.mov` (15 s) - mock in
   vim of the wanted `wrap_compact`: the row fills to the right edge, `>`
   stays before `opencode`, and the break falls mid-text (`rese|ts`).
