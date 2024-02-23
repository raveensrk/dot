(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ace-window-display-mode t)
 '(aw-dispatch-always nil)
 '(aw-dispatch-when-more-than 1)
 '(aw-keys '(49 50 51 52 53 54 55 56 57))
 '(beacon-blink-delay 0.7)
 '(beacon-blink-duration 1)
 '(beacon-blink-when-point-moves-horizontally 1)
 '(beacon-blink-when-point-moves-vertically 1)
 '(beacon-color "sienna1")
 '(beacon-dont-blink-commands nil)
 '(blink-cursor-delay 0.2)
 '(blink-cursor-interval 0.2)
 '(blink-cursor-mode nil)
 '(bookmark-use-annotations t)
 '(company-async-redisplay-delay 1)
 '(company-idle-delay 2)
 '(company-keywords-ignore-case t)
 '(company-tooltip-idle-delay 1.5)
 '(confirm-kill-emacs 'y-or-n-p)
 '(cursor-in-non-selected-windows 'box)
 '(cursor-type 'box)
 '(cycle-spacing-actions
   '(just-one-space delete-all-space restore delete-space-after delete-space-before))
 '(dashboard-navigator-buttons nil)
 '(dashboard-page-separator "\12\12")
 '(dashboard-projects-backend 'project-el)
 '(dashboard-vertically-center-content t)
 '(default-input-method "rfc1345")
 '(delete-selection-mode t)
 '(duplicate-line-final-position 1)
 '(dynamic-completion-mode t)
 '(ffap-file-name-with-spaces t)
 '(global-so-long-mode t)
 '(global-tab-line-mode nil)
 '(grep-find-command
   '("find -L . -type f -exec grep --color=auto -nH --null -e  \\{\\} +" . 54))
 '(grep-find-ignored-files
   '(".#*" "*.o" "*~" "*.bin" "*.lbin" "*.so" "*.a" "*.ln" "*.blg" "*.bbl" "*.elc" "*.lof" "*.glo" "*.idx" "*.lot" "*.fmt" "*.tfm" "*.class" "*.fas" "*.lib" "*.mem" "*.x86f" "*.sparcf" "*.dfsl" "*.pfsl" "*.d64fsl" "*.p64fsl" "*.lx64fsl" "*.lx32fsl" "*.dx64fsl" "*.dx32fsl" "*.fx64fsl" "*.fx32fsl" "*.sx64fsl" "*.sx32fsl" "*.wx64fsl" "*.wx32fsl" "*.fasl" "*.ufsl" "*.fsl" "*.dxl" "*.lo" "*.la" "*.gmo" "*.mo" "*.toc" "*.aux" "*.cp" "*.fn" "*.ky" "*.pg" "*.tp" "*.vr" "*.cps" "*.fns" "*.kys" "*.pgs" "*.tps" "*.vrs" "*.pyc" "*.pyo" "TAGS" "tags"))
 '(grep-find-template
   "find -H -L <D> <X> -type f <F> -exec grep <C> -nH --null -e <R> \\{\\} +")
 '(grep-find-use-xargs 'exec-plus)
 '(ibuffer-default-shrink-to-minimum-size t)
 '(ibuffer-default-sorting-mode 'major-mode)
 '(ibuffer-use-other-window t)
 '(ido-ignore-directories '("\\`CVS/" "\\`\\.\\./" "\\`\\./"))
 '(ido-separator nil)
 '(ido-show-dot-for-dired t)
 '(ido-use-filename-at-point 'guess)
 '(imenu-auto-rescan t)
 '(isearch-lazy-count t)
 '(line-spacing 0.1)
 '(next-line-add-newlines t)
 '(org-agenda-files
   '("~/iCloud/My projects/emacs.org" "~/iCloud/My projects/index.org"))
 '(org-capture-templates
   '(("p" "Plain text capture" entry
      (file "~/org/notes.org")
      "" :prepend t :empty-lines-after 1)))
 '(project-vc-extra-root-markers
   '("Makefile" "index.org" ".dir-locals.el" "README" "readme.org" "README.org" "readme"))
 '(project-vc-ignores '("TAGS" "tags"))
 '(projectile-auto-discover nil)
 '(projectile-generic-command "find -L . -type f | cut -c3- | tr '\\n' '\\0'")
 '(repeat-mode t)
 '(set-mark-command-repeat-pop t)
 '(show-trailing-whitespace t)
 '(straight-use-package-by-default t)
 '(tab-bar-close-button-show 'selected)
 '(tab-bar-history-mode t)
 '(tab-bar-new-button-show t)
 '(tab-bar-position nil)
 '(tab-bar-select-tab-modifiers nil)
 '(tab-bar-tab-hints t)
 '(tags-add-tables 'ask-user)
 '(treemacs-indent-guide-mode t)
 '(treemacs-indentation 0)
 '(treemacs-indentation-string " ┃ ")
 '(windmove-create-window nil)
 '(windmove-default-keybindings '([ignore] shift)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#2e3436" :foreground "#eeeeec" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 175 :width normal :foundry "nil" :family "Menlo"))))
 '(aw-leading-char-face ((t (:foreground "red" :height 1.0 :width extra-expanded))))
 '(cursor ((t (:background "light green"))))
 '(region ((t (:extend t :background "SeaGreen1" :foreground "black"))))
 '(tab-bar ((t (:inherit variable-pitch :background "LightSalmon2" :foreground "black"))))
 '(tab-bar-tab-group-current ((t (:inherit tab-bar-tab :weight bold))))
 '(tab-bar-tab-inactive ((t (:background "gray13" :foreground "gray100")))))




 ;; ;; '(electric-pair-mode t)
 ;; ;; '(electric-pair-pairs
 ;; ;;   '((34 . 34)
 ;; ;;     (8216 . 8217)
 ;; ;;     (8220 . 8221)
 ;; ;;     (40 . 41)
 ;; ;;     (123 . 125)
 ;; ;;     (93 . 93)))
 ;; ;; '(electric-pair-skip-whitespace-chars '(32 9 10))

;; ;; '(follow-auto t)


;; ;; '(goal-column 80)


 ;; '(show-smartparens-global-mode t)
