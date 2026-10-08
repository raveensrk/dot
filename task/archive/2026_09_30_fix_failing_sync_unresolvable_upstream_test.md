---
id: "t1y8cz6d0s"
title: "Fix failing sync unresolvable-upstream test"
state: "done"
due: ""
priority: ""
tag: ["sync"]
repeat: ""
effort: ""
postpone: 0
created: "2026-09-30"
closed: "2026-10-03T17:24"
---

  tests/test_sync.py::AutomaticModeTest.test_unresolvable_upstream_after_fetch_is_a_failure
  fails: commit 02aa6293 ("treat missing upstream-tracking ref as ok instead of
  failure") returns status "ok" / "Upstream branch does not exist on remote"
  when rev-parse @{upstream} fails, but the test still expects "failed" /
  "Could not resolve upstream branch". Decide which behaviour is right, then
  align script/,sync.py and the test (stash@{0} and stash@{1} touch the same
  area).
Decided 2026-10-03: the code is right, the test was stale. A configured upstream whose remote-tracking ref is gone after a successful fetch (empty remote, deleted tracked branch) is the same situation as no upstream at all - nothing to sync against - and 02aa6293 made both report ok/attention, matching the header contract 'no upstream configured -> OK if clean; needs attention if dirty'. A hard failure would fire on every repo whose merged branch was deleted. Change: the test now covers both trees, and the sync.py header names the case. Verified through the real entry point on a scratch clone whose remote branch was deleted: clean -> '[ OK ] Upstream branch does not exist on remote', 0 failed; with one edited file -> '[WARN] ... uncommitted changes (1 file(s))', 1 need attention. tests/test_sync.py 38 passed + 7 subtests; whole dot suite 149 passed + 10 subtests in 12.9s. No stashes touched.
