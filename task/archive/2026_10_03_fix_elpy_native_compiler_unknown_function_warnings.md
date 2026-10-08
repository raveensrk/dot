---
id: "g6prhbeszt"
title: "Fix elpy native-compiler unknown-function warnings"
state: "obsolete"
due: ""
priority: ""
tag: ["emacs", "bug"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-03"
closed: "2026-10-08T23:45"
---

Native-compiler warnings from ~/.emacs.d/straight/build/elpy (elpy.el, elpy-rpc.el, elpy-shell.el, elpy-refactor.el, elpy-django.el, snippets/python-mode/.yas-setup.el) and from occur-x/occur-x.el: unknown functions elpy-rpc-get-*, elpy-nav-*, eval-sexp-fu-flash, projectile-*, company-*, flymake-*, yas-minor-mode, linum-mode. elpy is unmaintained on Emacs 30. Decide: drop elpy for eglot or vendored python setup, or keep with the warnings filtered. Same check applies to occur-x and linum-mode. Verify: python buffer keeps completion, flymake and yasnippet, and the warnings are gone.

## Log

- obsolete 2026-10-08 23:45: Emacs removed 2026-10-08; Waypoint replaces it
