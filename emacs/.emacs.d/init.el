;;; Introduction

;; Emacs versions supported: 28.2+. This init file will follow the
;; following structure where the configs are organized under the
;; respective headings.

;;; Inspirations

;; https://github.com/munen/emacs.d/
;; https://emacsredux.com/blog/2016/01/31/use-tab-to-indent-or-complete/
;; https://emacsredux.com/blog/2022/06/03/enable-mouse-support-in-terminal-emacs/
;; https://idiomdrottning.org/bad-emacs-defaults
;; https://news.ycombinator.com/item?id=37843908
;; https://irreal.org/emacs-reminders.html

;;; Startup

; (toggle-frame-fullscreen)
(setq frame-inhibit-implied-resize t)
(setq pixel-scroll-precision-mode t)


;;; Packages

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

;;; Backups

(make-directory "~/.emacs_backups/" t)
(make-directory "~/.emacs_autosave/" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs_autosave/" t)))
(setq backup-directory-alist '(("." . "~/.emacs_backups/")))
;; (setq backup-by-copying t)

;;; Appearence

;; (setq-default show-trailing-whitespace t)
;; (global-whitespace-newline-mode t)
(setq-default cursor-type '(box . 1))
(setq-default cursor-in-non-selected-windows 'hollow)
(set-face-attribute 'default nil :height 120)

(use-package beacon
  :config
  (beacon-mode 1))

(use-package git-gutter
  :config
  (global-git-gutter-mode)
  (setq git-gutter:always-show-separator t)
  )

(setq visible-bell t)
(setq display-line-numbers t)
(setq display-line-numbers-type t)
(global-display-line-numbers-mode +1)
;; (global-visual-line-mode t)
;; (setq-default visual-line-fringe-indicators t)
(setq-default truncate-lines +1)
(global-prettify-symbols-mode +1)
(setq ring-bell-function 'ignore)
(setq show-paren-mode t)
(tab-bar-mode t)

;;; Editing

(setq kill-whole-line t)
(setq sentence-end-double-space nil)
(setq-default abbrev-mode 1)
(global-auto-revert-mode t)
(put 'narrow-to-region 'disabled nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq dtrt-indent-global-mode t)

(use-package smartparens
  :config (smartparens-global-mode +1))

(use-package wrap-region
  :config
  (wrap-region-global-mode)
  (wrap-region-add-wrapper "*" "*"))

(use-package multiple-cursors
  :config
  (multiple-cursors-mode 1))

(use-package volatile-highlights
  :config
  (volatile-highlights-mode t))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region))

(use-package browse-kill-ring
  :config
  (setq browse-kill-ring-highlight-inserted-item t
        browse-kill-ring-highlight-current-entry nil
        browse-kill-ring-show-preview t))

(use-package company
  :config
  (global-company-mode 1)
  )

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets/")))

;; (use-package ivy-yasnippet
;;   :after yasnippet)

(use-package yasnippet-snippets
  :after yasnippet
)
(use-package hydra)

(use-package browse-at-remote)

(use-package posframe)

(use-package file-info
  :config
  (setq hydra-hint-display-type 'posframe)
  (setq hydra-posframe-show-params `(:poshandler posframe-poshandler-frame-center
                                                 :internal-border-width 2
                                                 :internal-border-color "#61AFEF"
                                                 :left-fringe 16
                                                 :right-fringe 16)))

(use-package fzf
  ;; https://github.com/bling/fzf.el
  ;; Don't forget to set keybinds!
  :ensure t
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 15))

;; (use-package projectile
;;   :config
;;   (projectile-mode +1)
;;   (defun my-projectile-add-to-known-projects (args)
;;     "Add a project to projectile interactively"
;;     (interactive "D")
;;     (projectile-add-known-project args))
;;   (setq projectile-generic-command "fd -L . -0 --type f --color=never --strip-cwd-prefix")
;;   (setq projectile-project-search-path nil)
;;   (setq projectile-auto-discover nil))

;; (use-package marginalia
;;   :config (marginalia-mode 1))

;; (use-package ivy
;;   :config
;;   (ivy-mode nil)
;;   (setq ivy-height 10)
;;   (setq ivy-use-virtual-buffers t)
;;   (setq enable-recursive-minibuffers nil)
;;   (setq ivy-count-format "(%d/%d) ")
;;   ;; enable this if you want `swiper' to use it
;;   ;; (setq search-default-mode #'char-fold-to-regexp)
;;   ;; (setq ivy-re-builders-alist '((t . orderless-ivy-re-builder)))
;; ;;  (add-to-list 'ivy-highlight-functions-alist '(orderless-ivy-re-builder . orderless-ivy-highlight))
;;   )

;; (use-package swiper
;;   :config
;;   (defun my-word-at-point ()
;;     (interactive)
;;     (swiper (word-at-point))))

;; (use-package counsel
;;   :config
;;   (defun my-counsel-M-x ()
;;     "Counsel M-x with ^ removed"
;;     (interactive)
;;     (counsel-M-x "")))

(use-package which-key
  :config (which-key-mode 1))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)

  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)

  ;; To disable shortcut "jump" indicators for each section, set
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 20)
                          (projects . 5))))

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
(setq vc-follow-symlinks t)
(winner-mode 1)

;;;; Mouse Support In Terminal

;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;;; Dired

(setf dired-kill-when-opening-new-dired-buffer t)
(setq-default dired-listing-switches "-alh")
(setq dired-recursive-copies 'always)
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-dwim-target t)
(setq dired-hide-details-hide-information-lines t)
(setq dired-hide-details-hide-symlink-targets t)
(setq dired-kill-when-opening-new-dired-buffer nil)
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

;;; My functions

(defun bash-macos ()
  "This will open Bash terminal in macos"
  (interactive)
  (term "/opt/homebrew/bin/bash"))

(defun bash-local ()
  "This will open Bash terminal from ~/.local/bin/bash"
  (interactive)
  (term "~/.local/bin/bash"))

(defun read-file-as-string (file-path)
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)))

(defun eshell-new-buffer (args)
  "Create a new eshell buffer."
  (interactive "P")
  (eshell "new"))

(defun my-increment-number-decimal (&optional arg)
  "Increment the number forward from point by 'arg'."
  (interactive "p*")
  (save-excursion
    (save-match-data
      (let (inc-by field-width answer)
        (setq inc-by (if arg arg 1))
        (skip-chars-backward "0123456789")
        (when (re-search-forward "[0-9]+" nil t)
          (setq field-width (- (match-end 0) (match-beginning 0)))
          (setq answer (+ (string-to-number (match-string 0) 10) inc-by))
          (when (< answer 0)
            (setq answer (+ (expt 10 field-width) answer)))
          (replace-match (format (concat "%0" (int-to-string field-width) "d")
                                 answer)))))))

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

(defun my-list-packages ()
  "If already refresehed dont refresh. List only."
  (interactive)
  (if (bound-and-true-p my-package-refreshed-once)
      (list-packages)
    (package-refresh-contents t)
    (setq my-package-refreshed-once t)
    (list-packages)))

(defun switch-to-dashboard-buffer ()
  (interactive)
  (switch-to-buffer "*dashboard*"))

(defun read-lines-from-file-as-list (file-path)
  "Return a quoted list of lines of a file at FILE-PATH."
  (with-temp-buffer
    (insert-file-contents file-path)
    (mapcar (lambda (line) (format "%s" line)) (split-string (buffer-string) "\n" t))))

(defun copy-file-path-to-clipboard ()
  "Copy the current file path to the kill ring and clipboard."
  (interactive)
  (let ((file-path (buffer-file-name)))
    (when file-path
      (kill-new file-path)
      (message "Copied file path: %s" file-path)
      (when (region-active-p)
        (deactivate-mark))
      (x-select-text file-path))))

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

;;; Org mode

(setq  calendar-date-style 'iso)
(setq  org-export-backends '(html md odt ascii))
(setq  org-export-use-babel nil)
(setq  org-export-with-broken-links 'mark)
(setq  org-html-allow-name-attribute-in-anchors t)
(setq  org-html-checkbox-type 'unicode)
(setq  org-html-html5-fancy t)
(setq  org-html-self-link-headlines t)
(setq  org-support-shift-select t)

(add-hook 'org-mode-hook 'org-indent-mode)

(setq org-agenda-files '("~/org"))
(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/capture.org"))

(defun open-org-agenda-day-view ()
  "Opens org agenda day view"
  (interactive)
  (require 'org)
  (org-agenda-list 1 "d")
  (delete-other-windows))

(setq org-archive-location "%s::* Archived Tasks")

(defun insert-date ()
  "This will insert todays date in YYYY-MM-DD format"
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun return-date ()
  "This will return todays date in YYYY-MM-DD format"
  (interactive)
  (format-time-string "%Y-%m-%d"))

(defalias 'today 'return-date)

;;; Convenience

(use-package pdf-tools )
(use-package google-this)
(use-package web-mode)
(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default))

(use-package crux)

(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(setq speedbar-show-unknown-files t)
(setq compilation-auto-jump-to-first-error nil)
(setq compilation-scroll-output t)
;; (setq tab-always-indent 'complete)
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

;;;; Autosave

;; autosave files every 1 second if visited and changed
(setq auto-save-visited-interval 1)
(auto-save-visited-mode +1)
(setq auto-revert-interval 1)

;;; Programming

(use-package magit)
(setq require-final-newline t)
(setq-default indicate-empty-lines t)
(use-package eros
  :config
  (eros-mode 1))
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
(add-hook 'sh-mode-hook (lambda () (setq-local outline-regexp "# {{{*")))
(defalias 'perl-mode 'cperl-mode)
(setq cperl-invalid-face nil) 
(setq cperl-electric-keywords t) ;; expands for keywords such as foreach, while, etc...
(setq cperl-hairy t) ;; Turns on most of the CPerlMode options
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(use-package elpy
  :config
  (elpy-enable))
(add-hook 'verilog-mode-hook 'hs-minor-mode)
(put 'upcase-region 'disabled nil)
(add-hook 'verilog-mode-hook (lambda () (setq-local outline-regexp ".*/// *")))

;;;; Tags

(setq tags-add-tables nil)

;;;; Compilation 

(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 10000)

;;; Openai And Chatgpt Related

(setq my-openai-api-key-file "~/.emacs.d/openai-api-key.el")
(if (file-exists-p my-openai-api-key-file)
    (load-file my-openai-api-key-file))
(use-package shell-maker)
(use-package chatgpt-shell
  :requires shell-maker)
(setq chatgpt-shell-openai-key (read-file-as-string "~/.config/openai.token"))

;;; Misc

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

(defmacro measure-time (&rest body)
  "Measure the time it takes to evaluate BODY."
  `(let ((time (current-time)))
     ,@body
     (message "%.06f" (float-time (time-since time)))))


(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))

(use-package restart-emacs)

;;; Keybindings

;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)
(global-set-key (kbd "C-c f g") 'find-grep)
(pixel-scroll-mode t)
(global-set-key (kbd "C-c w") 'tab-list)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c y") 'crux-duplicate-current-line-or-region)
(global-set-key (kbd "C-c o c") 'org-capture)
(global-set-key (kbd "C-c c") 'comment-line)
(global-set-key (kbd "C-c K") 'nuke-all-buffers)
(global-set-key (kbd "C-c X") 'crux-kill-other-buffers)
(global-set-key (kbd "C-c f f") 'ffap)
(global-set-key (kbd "C-c f i") 'file-info-show)
(global-set-key (kbd "C-c i") 'crux-find-user-init-file)
(global-set-key (kbd "C-c r") 'restart-emacs)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key (kbd "C-c d") 'ranger)
(global-set-key [remap dabbrev-expand] 'hippie-expand)

;;; Testing

(set-face-attribute 'line-number-current-line nil :background "#3B4252")
(set-face-attribute 'line-number-current-line nil :foreground "#81A1C1")

;;; Ideas

(setq tags-table-files '("$HOME/tags/tags"))

(tool-bar-mode t)
(menu-bar-mode t)
(ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(use-package smex
  :config
  (smex-initialize))

  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(use-package ranger
  :config
  (setq ranger-show-hidden t)
  )

(load-theme 'tango-dark)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(global-set-key (kbd "C-c m") 'imenu)

(visit-tags-table "~/tags/TAGS")

