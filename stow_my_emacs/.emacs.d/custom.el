(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(centaur-tabs-show-navigation-buttons t)
 '(compilation-ask-about-save nil nil nil "Save all buffers before compilation")
 '(compilation-auto-jump-to-first-error nil)
 '(compilation-scroll-output t)
 '(cursor-type 'bar)
 '(custom-enabled-themes '(gruvbox-dark-hard wombat))
 '(custom-safe-themes
   '("e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "d80952c58cf1b06d936b1392c38230b74ae1a2a6729594770762dc0779ac66b7" "ee92ce1c1161c93411629213e2e51ff0199aedc479c4588f3bdf8747e3dc1ae6" default))
 '(dired-dwim-target t)
 '(dired-hide-details-hide-information-lines t)
 '(dired-hide-details-hide-symlink-targets t)
 '(display-line-numbers 'visual)
 '(display-line-numbers-type 'visual)
 '(dynamic-fonts-preferred-monospace-point-size 12)
 '(dynamic-fonts-preferred-proportional-point-size 12)
 '(evil-symbol-word-search t)
 '(git-gutter:always-show-separator t)
 '(global-git-gutter-mode t)
 '(initial-frame-alist '((fullscreen . maximized)))
 '(ispell-dictionary "british")
 '(ledger-default-date-format "%Y-%m-%d")
 '(ledger-report-auto-refresh nil)
 '(ledger-reports
   '(("A" "%(binary) -f %(ledger-file) -V bal -B --flat ")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(mouse-wheel-flip-direction t)
 '(mouse-wheel-tilt-scroll t)
 '(neo-window-width 40)
 '(org-agenda-custom-commands
   '(("i" "Command to view ideas todo" tags-todo "ideas"
      ((org-agenda-overriding-header "IDEAS")))
     ("z" "Super zaen view"
      ((agenda ""
               ((org-agenda-span 'day)
                (org-super-agenda-groups
                 '((:name "Today" :time-grid t :date today :todo "TODAY" :scheduled today :order 1)))))
       (alltodo ""
                ((org-agenda-overriding-header "")
                 (org-super-agenda-groups
                  '((:name "Next to do" :todo "NEXT" :order 1)
                    (:name "Important" :tag "Important" :priority "A" :order 6)
                    (:name "Due Today" :deadline today :order 2)
                    (:name "Due Soon" :deadline future :order 8)
                    (:name "Overdue" :deadline past :order 7)
                    (:name "Assignments" :tag "Assignment" :order 10)
                    (:name "Issues" :tag "Issue" :order 12)
                    (:name "Projects" :tag "Project" :order 14)
                    (:name "Emacs" :tag "Emacs" :order 13)
                    (:name "Research" :tag "Research" :order 15)
                    (:name "To read" :tag "Read" :order 30)
                    (:name "Waiting" :todo "WAITING" :order 20)
                    (:name "trivial" :priority<= "C" :tag
                           ("Trivial" "Unimportant")
                           :todo
                           ("SOMEDAY")
                           :order 90)
                    (:discard
                     (:tag
                      ("Chore" "Routine" "Daily"))))))))
      nil)))
 '(org-agenda-prefix-format
   '((agenda . " %i %-12:c%?-12t% s")
     (todo . " %i %-25:c")
     (tags . " %i %-12:c")
     (search . " %i %-12:c")))
 '(org-agenda-start-with-log-mode 'clockcheck)
 '(org-babel-load-languages '((awk . t) (C . t) (shell . t)))
 '(org-clock-report-include-clocking-task t)
 '(org-export-backends '(ascii html icalendar latex md odt))
 '(org-habit-show-all-today t)
 '(org-habit-show-done-always-green nil)
 '(org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)
 '(org-id-locations-file-relative t)
 '(org-image-actual-width '(250))
 '(org-link-descriptive t)
 '(org-link-file-path-type 'relative)
 '(org-link-frame-setup
   '((vm . vm-visit-folder-other-frame)
     (vm-imap . vm-visit-imap-folder-other-frame)
     (gnus . org-gnus-no-new-news)
     (file . find-file)
     (wl . wl-other-frame)))
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
 '(org-src-preserve-indentation t)
 '(org-startup-folded nil)
 '(org-startup-indented t)
 '(org-startup-truncated nil)
 '(org-structure-template-alist
   '(("a" . "export ascii")
     ("c" . "center")
     ("C" . "comment")
     ("e" . "example")
     ("E" . "export")
     ("h" . "export html")
     ("l" . "export latex")
     ("q" . "quote")
     ("s" . "src")
     ("v" . "verse")
     ("b" . "src bash")))
 '(org-todo-keywords
   '((sequence "BLOG" "TODO" "CURR" "WAIT" "|" "DONE" "SKIP" "ARCH")))
 '(outline-minor-mode-cycle t)
 '(outline-minor-mode-cycle-filter nil)
 '(outline-minor-mode-highlight 'append)
 '(package-selected-packages
   '(org-bullets centaur-tabs emojify treemacs-tab-bar treemacs-persp treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil treemacs doom-themes solaire-mode apheleia diminish sr-speedbar nyan-mode nyan esup spu fzf drag-stuff focus all-the-icons multifiles solaire zoom hyperbole dashboard neotree prog-mode bicycle undo-fu evil-collection sh-script shell-script multiple-cursors org use-package benchmark-init aggressive-indent all-the-icons-completion all-the-icons-ivy-rich avy beacon company counsel dynamic-fonts embark evil evil-escape evil-goggles evil-leader evil-mc evil-numbers evil-snipe evil-surround evil-vimish-fold expand-region flex-autopair flycheck flymake-shellcheck flyspell-correct folding format-all git-gutter gruvbox-theme helm helm-etags-plus htmlize indent-guide ivy key-chord ledger-mode load-dir magit marginalia markdown-mode minimal-session-saver noccur olivetti orderless org-auto-tangle org-download org-drill org-super-agenda ox-pandoc php-mode projectile projectile-ripgrep rainbow-delimiters restart-emacs runner search-web simple-httpd smartparens swiper use-package vterm which-key writegood-mode xhair xml-quotes yasnippet yasnippet-snippets))
 '(php-mode-coding-style 'php)
 '(projectile-auto-discover nil)
 '(projectile-project-search-path nil)
 '(save-place-mode t)
 '(show-paren-mode t)
 '(speedbar-show-unknown-files t)
 '(tab-width 4)
 '(truncate-lines nil)
 '(warning-suppress-log-types '((magit)))
 '(warning-suppress-types '((emacs) (comp) (magit)))
 '(word-wrap t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; TODO: Do not set org-agenda-files 
;; TODO: Convert all these custom set variables to init.el file
