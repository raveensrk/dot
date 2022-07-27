(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compilation-ask-about-save nil nil nil "Save all buffers before compilation")
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output t)
 '(cursor-type 'bar)
 '(custom-enabled-themes '(wombat))
 '(custom-file "~/.emacs.d/custom.el")
 '(custom-safe-themes
   '("ee92ce1c1161c93411629213e2e51ff0199aedc479c4588f3bdf8747e3dc1ae6" default))
 '(dired-hide-details-hide-information-lines t)
 '(dired-hide-details-hide-symlink-targets t)
 '(display-line-numbers 'visual)
 '(display-line-numbers-type 'visual)
 '(dynamic-fonts-preferred-monospace-point-size 20)
 '(dynamic-fonts-preferred-proportional-point-size 20)
 '(evil-symbol-word-search t)
 '(git-gutter:always-show-separator t)
 '(global-git-gutter-mode t)
 '(ledger-default-date-format "%Y-%m-%d")
 '(ledger-report-auto-refresh nil)
 '(ledger-reports
   '(("A" "%(binary) -f %(ledger-file) -V bal -B --flat ")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(org-agenda-files '("~/.agenda_files"))
 '(org-agenda-start-with-log-mode 'clockcheck)
 '(org-babel-load-languages '((awk . t) (C . t) (shell . t) (php . t)))
 '(org-export-backends '(ascii html icalendar latex md odt))
 '(org-habit-show-all-today t)
 '(org-habit-show-done-always-green nil)
 '(org-link-descriptive nil)
 '(org-link-file-path-type 'relative)
 '(org-log-done 'time)
 '(org-log-into-drawer t)
 '(org-log-refile 'time)
 '(org-modules
   '(ol-bbdb ol-bibtex ol-docview ol-doi ol-eww ol-gnus org-habit ol-info ol-irc ol-mhe org-mouse ol-rmail ol-w3m))
 '(org-outline-path-complete-in-steps nil)
 '(org-priority-default 70)
 '(org-priority-faces
   '((65 . "red")
     (66 . "yellow")
     (67 . "orange")
     (68 . "fuchsia")
     (69 . "sandybrown")))
 '(org-priority-highest 65)
 '(org-priority-lowest 70)
 '(org-refile-allow-creating-parent-nodes 'confirm)
 '(org-refile-use-outline-path 'file)
 '(org-startup-indented t)
 '(org-startup-truncated nil)
 '(org-todo-keywords
   '((sequence "BACKLOG" "BLOG" "TODO" "IN-PROGRESS|CURRENT" "CURR" "|" "DONE" "SKIP" "SKIPPED")))
 '(outline-minor-mode-cycle t)
 '(outline-minor-mode-cycle-filter nil)
 '(outline-minor-mode-highlight 'append)
 '(package-selected-packages
   '(orderless flymake-shellcheck flex-autopair smartparens xml-quotes projectile-ripgrep xhair indent-guide htmlize markdown-mode all-the-icons-completion all-the-icons-ivy-rich ivy counsel ox-pandoc evil-surround php-mode simple-httpd projectile dynamic-fonts use-package runner avy rainbow-delimiters swiper helm-etags-plus beacon company embark evil evil-goggles evil-leader evil-mc evil-numbers evil-snipe evil-vimish-fold expand-region flycheck flyspell-correct folding git-gutter helm ledger-mode load-dir magit marginalia minimal-session-saver noccur olivetti restart-emacs search-web vterm which-key writegood-mode yasnippet yasnippet-snippets))
 '(php-mode-coding-style 'php)
 '(show-paren-mode t)
 '(speedbar-show-unknown-files t)
 '(tab-width 4)
 '(warning-suppress-log-types '((magit)))
 '(warning-suppress-types '((magit)))
 '(word-wrap t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; TODO: Do not set org-agenda-files 
;; TODO: Convert all these custom set variables to init.el file
