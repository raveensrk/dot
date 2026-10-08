---
id: "m1gwbs6p98"
title: "Silence straight.el loaded after package.el warning"
state: "done"
due: ""
priority: ""
tag: ["emacs", "bug"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-03"
closed: "2026-10-03T17:40"
---

Startup: "Warning (straight): straight.el was loaded when package.el was already loaded. You may wish to delete ~/.emacs.d/elpa or add (setq package-enable-at-startup nil) to ~/.emacs.d/early-init.el to avoid multiple versions of the same packages being loaded." ~/.emacs.d/elpa currently holds markdown-mode only; config/emacs/init.el already dropped package-initialize, so package.el still runs from site-start. Fix: set package-enable-at-startup nil (early-init in config/emacs, since ~/.emacs.d stays untracked) and delete ~/.emacs.d/elpa. Verify: warning gone on a fresh start through the emacs alias.
Done 2026-10-03. straight's guard is (featurep 'package) AND package-enable-at-startup AND a non-empty elpa; measured with a probe copy of init.el, all three were true at straight load (flag=t, package=t, elpa=(markdown-mode-2.8 ...)). Fix: (setq package-enable-at-startup nil) in config/emacs/init.el right after (require 'package), before the straight bootstrap - an early-init file is not an option because the emacs alias runs 'emacs -q -l $DOT/config/emacs/init.el' and -q never reads one. Cleanup: the unused package.el install (~/.emacs.d/elpa, 1.3 MB: markdown-mode 2.8 + .signed + archives + gnupg) moved to ~/.Trash/elpa-2026-10-03; no config file in config/emacs mentions markdown and straight carries its own markdown-mode build. Verified through the real entry point: at straight load the flag is nil now (was t); forcing straight.el's SOURCE to load after the config - the exact path that printed the warning before - stays silent (displayed=nil); a full alias start after the removal prints no warning and reports straight=t, 76 built packages, elpa=nil. The compiled straight.elc path never printed the warning in this session and that part is unexplained; the fix removes the condition for every build.
