---
id: "n5mxvfg2cq"
title: "Fix native-compiler unknown-function warnings in straight builds"
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

Native-compiler warnings for missing functions, all from straight builds: smartparens-pkg.el:1:2 define-package; smartparens-config.el org-element-property, org-element-at-point, org-in-src-block-p; file-info.el dired-get-filename; browse-at-remote.el log-view-current-entry, dired-current-directory; pyvenv.el widget-types-convert-widget, widget-copy. Cause: packages compile before org, dired, log-view and widget are loaded. Fix: require them from config, or accept and filter these from the startup report. Verify: rebuild straight and confirm the warnings are gone.
