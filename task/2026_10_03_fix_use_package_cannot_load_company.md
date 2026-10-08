---
id: "tb9m90x9st"
title: "Fix use-package cannot load company"
state: "todo"
due: ""
priority: ""
tag: ["emacs", "bug"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-03"
closed: ""
---

Startup: "Error (use-package): Cannot load company". Find the use-package form that pulls company (elpy depends on company-mode) and whether the :ensure name or the straight recipe is wrong, or drop elpy in favour of eglot. Verify: no error at startup and company-mode activates in a python buffer.
