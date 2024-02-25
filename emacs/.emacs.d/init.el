;;; Introduction

;; (setq debug-on-error t)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
(set-face-attribute 'default nil :weight 'semi-bold :height '200 :family "Fira Code")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(setq pixel-scroll-precision-mode t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

(straight-use-package 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;;; Defaults

(add-to-list 'load-path "~/.emacs.d/packages")
(require 'better-defaults)

(make-directory "~/.emacs_backups/" t)
(make-directory "~/.emacs_autosave/" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs_autosave/" t)))
(setq backup-directory-alist '(("." . "~/.emacs_backups/")))

(use-package beacon
  :config
  (beacon-mode 1))

(setq visible-bell t)
(setq display-line-numbers t)
(setq display-line-numbers-type t)
(global-display-line-numbers-mode +1)

(setq ring-bell-function 'ignore)
(setq show-paren-mode t)

(setq kill-whole-line t)
(setq sentence-end-double-space nil)
(setq-default abbrev-mode 1)
(put 'narrow-to-region 'disabled nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(use-package smartparens
  :config (smartparens-global-mode +1))

(use-package wrap-region
  :config
  (wrap-region-global-mode)
  (wrap-region-add-wrapper "*" "*"))

(use-package browse-kill-ring
  :config
  (setq browse-kill-ring-highlight-inserted-item t
        browse-kill-ring-highlight-current-entry nil
        browse-kill-ring-show-preview t))

(use-package company
  :config
  (global-company-mode 1))

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets/")))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package hydra)

(use-package browse-at-remote)

(use-package posframe)

(use-package file-info)

(use-package fzf
  :ensure t
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        fzf/position-bottom t
        fzf/window-height 15))

(use-package which-key
  :config (which-key-mode 1))

(defalias 'yes-or-no-p 'y-or-n-p)
(mouse-avoidance-mode 'cat-and-mouse)
(recentf-mode 1)
(save-place-mode +1)
(savehist-mode 1)
(setq inhibit-startup-screen t)
(setq mouse-drag-and-drop-region t)
(setq mouse-drag-and-drop-region-cut-when-buffers-differ t)
(setq mouse-wheel-flip-direction t)
(setq mouse-wheel-tilt-scroll t)
(setq recentf-max-menu-items 200)
(setq recentf-max-saved-items 200)
(winner-mode 1)

;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

(setf dired-kill-when-opening-new-dired-buffer t)
(setq-default dired-listing-switches "-alh")
(setq dired-recursive-copies 'always)
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-dwim-target t)
(setq dired-hide-details-hide-information-lines t)
(setq dired-hide-details-hide-symlink-targets t)
(add-hook 'dired-mode-hook (lambda () (define-key dired-mode-map (kbd "C-c +") 'dired-create-empty-file)))

(defun dired-dotfiles-toggle ()
  "Show/hide dot-files"
  (interactive)
  (when (equal major-mode 'dired-mode)
    (if (or (not (boundp 'dired-dotfiles-show-p)) dired-dotfiles-show-p) ; if currently showing
        (progn
          (set (make-local-variable 'dired-dotfiles-show-p) nil)
          (message "h")
          (dired-mark-files-regexp "^\\\.")
          (dired-do-kill-lines))
      (progn (revert-buffer) ; otherwise just revert to re-show
             (set (make-local-variable 'dired-dotfiles-show-p) t)))))

(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))

(use-package dired-narrow
  :config
  (define-key dired-mode-map (kbd "/") 'dired-narrow-fuzzy))

(defun remove-extra-spaces (start end)
  "Remove extra spaces from region START to END, or current line if no region is given,
    and replace them with single spaces."
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-end-position))))
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (re-search-forward "\\s-+" nil t)
        (replace-match " ")))))

(defun switch-to-dashboard-buffer ()
  (interactive)
  (switch-to-buffer "*dashboard*"))

(defun read-lines-from-file-as-list (file-path)
  "Return a quoted list of lines of a file at FILE-PATH."
  (with-temp-buffer
    (insert-file-contents file-path)
    (mapcar (lambda (line) (format "%s" line)) (split-string (buffer-string) "\n" t))))

(defun copy-whole-buffer ()
  "This function will copy the whole buffer..."
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (kill-ring-save nil nil t))
  )

(defun my-expand-lines ()
  (interactive)
  (let ((hippie-expand-try-functions-list
         '(try-expand-line)))
    (call-interactively 'hippie-expand)))

(defun my-indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun my-indent-whole-buffer-and-save ()
  (interactive)
  (indent-region (point-min) (point-max))
  (save-buffer)  )

(defun insert-date ()
  "This will insert todays date in YYYY-MM-DD format"
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun return-date ()
  "This will return todays date in YYYY-MM-DD format"
  (interactive)
  (format-time-string "%Y-%m-%d"))

(defalias 'today 'return-date)

(use-package google-this)

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default))

(use-package crux)

(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(setq speedbar-show-unknown-files t)
(setq compilation-auto-jump-to-first-error t)
(setq compilation-scroll-output t)
(setq vc-follow-symlinks nil)

(defun my-extract-region-to-variable (variable)
  "Cut and extract selected text region and replace it with a variable name."
  (interactive "sEnter variable name: ")
  (save-excursion
    (let ((selection (buffer-substring (region-beginning) (region-end))))
      (delete-region (region-beginning) (region-end))
      (insert (format "$%s" variable))
      (beginning-of-line)
      (open-line 1)
      (insert (format "%s=\"%s\"" variable selection))
      (move-beginning-of-line nil))))

(use-package magit)
(setq require-final-newline t)
(setq-default indicate-empty-lines t)

(use-package eros
  :config
  (eros-mode 1))
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
(defalias 'perl-mode 'cperl-mode)
(setq cperl-invalid-face nil)
(setq cperl-electric-keywords t) ;; expands for keywords such as foreach, while, etc...
(setq cperl-hairy t) ;; Turns on most of the CPerlMode options
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(use-package elpy
  :config
  (elpy-enable))
(put 'upcase-region 'disabled nil)

(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 500)

(use-package gptel)

(if (file-exists-p "~/.config/openai-api-key.el")
    (load-file "~/.config/openai-api-key.el"))

(setq gc-cons-threshold 20000000)
(setq large-file-warning-threshold 200000000)
(fset 'yes-or-no-p 'y-or-n-p)
(display-time-mode t)
(setq save-place-file "~/.emacs.d/saveplace")

(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs))

(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))

(use-package restart-emacs)

(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)
(pixel-scroll-mode t)
(global-set-key (kbd "C-c w") 'tab-list)
(global-set-key (kbd "C-c y") 'duplicate-dwim)
(global-set-key (kbd "C-c c") 'comment-line)
(global-set-key (kbd "C-c K") 'nuke-all-buffers)
(global-set-key (kbd "C-c X") 'crux-kill-other-buffers)
(global-set-key (kbd "C-c f f") 'ffap)
(global-set-key (kbd "C-c f i") 'file-info-show)
(global-set-key (kbd "C-c i") 'crux-find-user-init-file)
(global-set-key (kbd "C-c r") 'restart-emacs)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key [remap dabbrev-expand] 'hippie-expand)

(set-face-attribute 'line-number-current-line nil :background "dark gray")
(set-face-attribute 'line-number-current-line nil :foreground "black")
(tool-bar-mode t)
(menu-bar-mode t)
(ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-use-filename-at-point 'guess)
(setq ido-use-url-at-point nil)
(setq ido-ignore-extensions t)
(use-package smex
  :config
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command))
(if (file-exists-p "~/tags/TAGS")
    (visit-tags-table "~/tags/TAGS"))

(use-package rainbow-delimiters
  :config
  (rainbow-delimiters-mode t))

(use-package occur-x
  :config
  (add-hook 'occur-mode-hook 'turn-on-occur-x-mode))

(require 'hydra-examples "~/.emacs.d/straight/repos/hydra/hydra-examples.el")
(global-set-key (kbd "C-x SPC") 'hydra-rectangle/body)

(defun archive-code ()
  "Move selected code to end of the file and comment it..."
  (interactive)
  (save-excursion
    (kill-region (region-beginning) (region-end))
    (end-of-buffer)
    (open-line 2)
    (end-of-buffer)
    (yank)
    (comment-region (region-beginning) (region-end))
    ))

(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode-enable)

(use-package iedit)

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)))

(use-package verilog-ext
  :hook ((verilog-mode . verilog-ext-mode))
  :init
  ;; Can also be set through `M-x RET customize-group RET verilog-ext':
  ;; Comment out/remove the ones you do not need
  (setq verilog-ext-feature-list
        '(font-lock
          xref
          capf
          hierarchy
          eglot
          lsp
          flycheck
          beautify
          navigation
          template
          formatter
          compilation
          imenu
          which-func
          hideshow
          typedefs
          time-stamp
          block-end-comments
          ports))
  :config
  (verilog-ext-mode-setup))

(progn
  (defhydra hydra-of-hydras (:columns 4 :color amaranth)
    "Hydra of hydras"
    ("u" undo "undo")
    ("(" beginning-of-defun "beginning of defun")
    (")" end-of-defun "end of defun")
    ("+" text-scale-increase "in")
    ("," xref-go-back "xref go back")
    ("'" pop-global-mark "pop global mark")
    ("-" text-scale-decrease "out")
    ("." xref-find-definitions "xref find def")
    ("<" beginning-of-buffer "beginning of buffer")
    (">" end-of-buffer "end of buffer")
    ("D" dired "dired")
    ("d" kill-whole-line "kill whole line")
    ("c" comment-line "comment line")
    ("a" avy-goto-char "avy")
    ("b" bmkp-cycle "Cycle bookmarks")
    ("e" next-line "next line")
    ("h" gptel "gptel" :exit t :color blue)
    ("i" previous-line "previous line")
    ("k" kill-buffer "kill buffer")
    ("m" imenu "imenu")
    ("n" backward-char "backward character")
    ("o" forward-char "forward character")
    ("p" yank "forward character")
    ("q" nil "quit" :exit t :color blue)
    ("C-." emabark-act)
    ("r" recentf-open "Recent files")
    ("/" hydra-tools/body "tools" :color teal)
    ("t" treemacs "treemacs")
    ("w" ace-window "ace window")
    ("x" eval-last-sexp "evaluate last sexp")
    ("X" eval-buffer "evaluate whole buffer")
    )
  (global-set-key (kbd "s-a") 'hydra-of-hydras/body))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region))

(use-package swiper)
(use-package counsel)
(use-package ivy
  :config
  (ivy-mode t)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  (define-key ivy-mode-map (kbd "C-,") 'ivy-immediate-done)
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
  )

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package helpful
  :config
  ;; Note that the built-in `describe-function' includes both functions
  ;; and macros. `helpful-function' is functions only, so we provide
  ;; `helpful-callable' as a drop-in replacement.
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command)
  ;; Lookup the current symbol at point. C-c C-d is a common keybinding
  ;; for this in lisp modes.
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)

  ;; Look up *F*unctions (excludes macros).
  ;;
  ;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
  ;; already links to the manual, if a function is referenced there.
  (global-set-key (kbd "C-h F") #'helpful-function)
  (setq counsel-describe-function-function #'helpful-callable)
  (setq counsel-describe-variable-function #'helpful-variable)
  )

(use-package telephone-line
  :config
  (telephone-line-mode 1)
  (setq telephone-line-primary-left-separator 'telephone-line-gradient
        telephone-line-secondary-left-separator 'telephone-line-nil
        telephone-line-primary-right-separator 'telephone-line-gradient
        telephone-line-secondary-right-separator 'telephone-line-nil)
  (setq telephone-line-height 24
        telephone-line-evil-use-short-tag t)
  )

(use-package dimmer
  :config
  (require 'dimmer)
  (dimmer-configure-which-key)
  (dimmer-configure-helm)
  (dimmer-mode t))

(use-package rainbow-mode
  :config
  (rainbow-mode t))

(use-package telephone-line
  :config
  (telephone-line-mode 1)
  (setq telephone-line-primary-left-separator 'telephone-line-gradient
        telephone-line-secondary-left-separator 'telephone-line-nil
        telephone-line-primary-right-separator 'telephone-line-gradient
        telephone-line-secondary-right-separator 'telephone-line-nil)
  (setq telephone-line-height 24
        telephone-line-evil-use-short-tag t)
  )
(use-package all-the-icons
  :if (display-graphic-p))

(use-package multiple-cursors)

(use-package ialign)
(use-package literate-calc-mode
  :config
  (literate-calc-minor-mode t))

(use-package tldr)

(use-package fancy-compilation
  :commands (fancy-compilation-mode))

(with-eval-after-load 'compile
  (fancy-compilation-mode))

(use-package  dirvish
  :config
  (dirvish-override-dired-mode t))

(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

(use-package ws-butler
  :config
  (ws-butler-global-mode t))

(defun remove-double-newlines ()
  "An function to remove double new lines everywhere after point."
  (interactive)
  (dotimes (i 10)
    (replace-regexp-in-region "\n\s*\n\s*\n" "\n\n" (point-min) (point-max))))

(add-hook 'before-save-hook 'remove-double-newlines)

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package aggressive-indent
  :config
  (global-aggressive-indent-mode 1))

(use-package tiny)

(use-package dumb-jump)

(use-package buffer-expose)

(use-package wgrep)

(use-package on-screen
  :config
  (on-screen-global-mode +1)
  )

(use-package num3-mode
  :config
  (global-num3-mode t))

(use-package cyberpunk-theme
  :config
  (load-theme 'cyberpunk))

(global-set-key (kbd "C-c b") 'bookmark-bmenu-list)

(use-package breadcrumb
  :config
  (breadcrumb-mode t))

(global-set-key (kbd "s-x") 'counsel-M-x)
(global-set-key (kbd "s-b") 'counsel-bookmark)

(with-eval-after-load 'package
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(use-package ivy-hydra
  :config
  (global-set-key (kbd "C-c .") 'hydra-ivy/body))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)
  (setq dashboard-icon-type 'all-the-icons)  ; use `all-the-icons' package
  (setq dashboard-set-navigator t)
  (setq dashboard-set-init-info t)
  )
;; (setq debug-on-error nil)

(use-package syntax-subword
  :config
  (global-syntax-subword-mode t))

(error "DONE")

(setq-default use-package-always-pin nil)
(setq straight-use-package-by-default nil)
(use-package org
  :config
  (setq
   org-M-RET-may-split-line nil
   org-agenda-files '("~/org")
   org-agenda-inhibit-startup nil
   org-agenda-restore-windows-after-quit t
   org-agenda-sticky t
   org-capture-templates
   '(("c" "capture" entry
      (file "~/org/capture.org")
      "" :prepend t))
   org-cycle-hide-block-startup t
   org-default-notes-file "~/iCloud/org/capture.org"
   org-directory "~/iCloud/org"
   + '(org-extend-today-until 4)
   + '(org-fontify-todo-headline t)
   + '(org-fontify-whole-heading-line t)
   + '(org-hide-emphasis-markers t)
   '(org-hide-leading-stars t)
   - '(org-indent-indentation-per-level 4)
   + '(org-id-link-to-org-use-id t)
   + '(org-id-locations-file "~/iCloud/org/.org-id-locations")
   + '(org-id-locations-file-relative t)
   + '(org-indent-indentation-per-level 8)
   + '(org-insert-heading-respect-content t)
   + '(org-insert-mode-line-in-empty-file t)
   '(org-journal-dir "~/iCloud/notes")
   '(org-journal-enable-agenda-integration t)
   '(org-journal-file-type 'weekly)
   + '(org-modules
       +   '(ol-bbdb ol-bibtex org-ctags ol-docview ol-doi ol-eww ol-gnus org-habit org-id ol-info ol-irc ol-mhe org-mouse org-protocol ol-rmail org-tempo ol-w3m ol-eshell org-annotate-file ol-bookmark org-checklist org-choose org-collector ol-elisp-symbol org-eval-light org-eval org-expiry org-learn org-notify org-panel org-screen org-screenshot org-toc org-velocity))
   + '(org-pretty-entities t)
   + '(org-startup-align-all-tables nil)
   + '(org-startup-folded t)
   + '(org-startup-indented t)
   + '(org-startup-numerated nil)
   + '(org-use-effective-time t)
   + '(org-use-last-clock-out-time-as-effective-time nil)
   '("Makefile" "index.org" ".dir-locals.el" "README" "readme.org" "README.org" "readme"))
  + '(todo-directory "~/iCloud/org/todo")
  '(org-default ((t (:inherit default :height 250 :family "Chalkboard"))))
  -(global-set-key (kbd "C-c o a") 'org-agenda)
  (global-set-key (kbd "C-c o c") 'org-capture)
  (with-eval-after-load 'org (global-org-modern-mode t)))
  +;; (org-habit-toggle-display-in-agenda t)
  +(add-to-list 'org-modules 'org-habit t)
  +(unless (package-installed-p 'org-contrib) (package-install 'org-contrib))
  -                   (global-set-key (kbd "C-c a") 'org-agenda)
  +(global-set-key (kbd "C-c a") 'org-agenda-list)

  )

(straight-remove-unused-repos t)

