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

(toggle-frame-fullscreen)
(setq frame-inhibit-implied-resize t)
(setq pixel-scroll-precision-mode t)


;;; Packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;; Custom Variables

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-fill-mode-hook '(yas--auto-fill-wrapper))
 '(comment-auto-fill-only-comments t)
 '(context-menu-mode t)
 '(elfeed-feeds
   '("https://news.ycombinator.com"))
 '(evil-symbol-word-search t)
 '(imenu-auto-rescan t)
 '(imenu-max-items 999)
 '(imenu-sort-function 'imenu--sort-by-name)
 '(org-edit-src-content-indentation 8)
 '(org-image-actual-width 500)
 '(org-indent-indentation-per-level 8)
 '(org-list-demote-modify-bullet '(("-" . "+") ("+" . "-")))
 '(org-list-indent-offset 6)
 '(org-startup-with-inline-images t)
 '(package-selected-packages
   '(dtrt-indent elfeed yasnippet-classic-snippets evil-surround diminish outline-toc imenu-list org-modern dashboard evil evil-leader smartparens wrap-region multiple-cursors volatile-highlights expand-region browse-kill-ring company avy nyan-mode all-the-icons beacon git-gutter magit which-key marginalia ivy orderless swiper counsel projectile yasnippet ivy-yasnippet yasnippet-snippets fzf hydra browse-at-remote posframe file-info restart-emacs format-all crux web-mode persistent-scratch markdown-mode outline-minor-faces backline dired-narrow smex elpy eros speedrect octave eshell imenu imenu-anywhere shell-maker chatgpt-shell breadcrumb multifiles pdf-tools google-this)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; Defaults

(add-to-list 'load-path "~/.emacs.d/packages") 
(require 'better-defaults)
(add-to-list 'auto-mode-alist '("\\.txt\\'" . org-mode))

;;; Backups

(make-directory "~/.emacs_backups/" t)
(make-directory "~/.emacs_autosave/" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs_autosave/" t)))
(setq backup-directory-alist '(("." . "~/.emacs_backups/")))
;; (setq backup-by-copying t)

;;; Appearence

;; (setq-default show-trailing-whitespace t)
;; (global-whitespace-newline-mode t)
(setq-default cursor-type '(bar . 2))
(setq-default cursor-in-non-selected-windows 'hollow)
(set-face-attribute 'default nil :height 200)

(use-package beacon
  :config
  (beacon-mode 1))

(use-package git-gutter
  :diminish
  :config
  (global-git-gutter-mode)
  (setq git-gutter:always-show-separator t)
  (diminish 'global-git-gutter-mode)
  )

(setq visible-bell t)
(setq display-line-numbers t)
(setq display-line-numbers-type t)
(global-display-line-numbers-mode +1)
(global-visual-line-mode t)
;; (setq-default visual-line-fringe-indicators t)
(setq-default truncate-lines +1)
(global-prettify-symbols-mode +1)
(setq ring-bell-function 'ignore)
(setq show-paren-mode t)
(tab-bar-mode t)

;;;; Outline mode extend headings backline

(use-package outline-minor-faces
  :diminish
  :hook outline-minor-mode
  )

(use-package backline
  :diminish
  :after outline
  :config (advice-add 'outline-flag-region :after 'backline-update)
  (outline-minor-faces-mode +1))

;;; Editing

(setq kill-whole-line t)
(setq sentence-end-double-space nil)
(setq-default abbrev-mode 1)
(global-auto-revert-mode t)
(put 'narrow-to-region 'disabled nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq dtrt-indent-global-mode t)

(use-package format-all
  :diminish
  ;; https://github.com/lassik/emacs-format-all-the-code/tree/c156ffe5f3c979ab89fd941658e840801078d091
  :hook
  (add-hook 'prog-mode-hook 'format-all-mode)
  )

(use-package smartparens
  :diminish
  :config (smartparens-global-mode +1))

(use-package wrap-region
  :diminish
  :config
  (wrap-region-global-mode)
  (wrap-region-add-wrapper "*" "*"))

(use-package multiple-cursors
  :config
  (multiple-cursors-mode 1))

(use-package volatile-highlights
  :diminish
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
  :diminish
  :config
  (global-company-mode 1)
  )

(use-package yasnippet
  :diminish
  :config
  (yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.
  (setq yas-snippet-dirs '("~/.emacs.d/snippets/")))

(use-package ivy-yasnippet
  :after yasnippet)

(use-package yasnippet-snippets
  :after yasnippet
  :diminish)

;;; Evil Mode

(evil-mode t)
(global-evil-leader-mode t)
(evil-leader/set-leader "<SPC>")
(global-evil-surround-mode t)

;;; Navigation

(use-package breadcrumb)

(use-package imenu
  :config
  (defun try-to-add-imenu ()
    "Function to enable imenu in any mode, if that mode has imenu available."
    (condition-case nil (imenu-add-to-menubar "imenu-index") (error nil)))
  (add-hook 'font-lock-mode-hook 'try-to-add-imenu)

  ;; Add use-package to imenu list
  (add-to-list 'imenu-generic-expression
               '("Used Packages"
                 "\\(^\\s-*(use-package +\\)\\(\\_<.+\\_>\\)" 2))

  ;; Sort Imenu by name
  (setq imenu-sort-function 'imenu--sort-by-name)
  (setq imenu-auto-rescan t))

(use-package imenu-anywhere)

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
  :defer t
  :diminish
  ;; https://github.com/bling/fzf.el
  :bind
  ;; Don't forget to set keybinds!
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

(use-package projectile
  :diminish
  :config
  (projectile-mode +1)
  (defun my-projectile-add-to-known-projects (args)
    "Add a project to projectile interactively"
    (interactive "D")
    (projectile-add-known-project args))
  (setq projectile-generic-command "fd -L . -0 --type f --color=never --strip-cwd-prefix")
  (setq projectile-project-search-path nil)
  (setq projectile-auto-discover nil))

(use-package marginalia
  :config (marginalia-mode 1))

(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-height 20)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-count-format "(%d/%d) ")
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-re-builders-alist '((t . orderless-ivy-re-builder)))
  (add-to-list 'ivy-highlight-functions-alist '(orderless-ivy-re-builder . orderless-ivy-highlight)))

(use-package orderless
  :after ivy
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package swiper
  :config
  (defun my-word-at-point ()
    (interactive)
    (swiper (word-at-point))))

(use-package counsel
  :config
  (defun my-counsel-M-x ()
    "Counsel M-x with ^ removed"
    (interactive)
    (counsel-M-x "")))

(use-package which-key
  :config (which-key-mode 1))

(use-package dashboard
  ;; https://github.com/emacs-dashboard/emacs-dashboard
  :diminish
  :config
  (dashboard-setup-startup-hook)

  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)

  ;; To disable shortcut "jump" indicators for each section, set
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 10)
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

(use-package org-modern                                  
  :config                                                
  (with-eval-after-load 'org (global-org-modern-mode)))

(use-package imenu-list
  :config
  (imenu-list-start-timer)
  (setq org-imenu-depth 99))

(setq org-agenda-custom-commands
      '(("c" . "My Custom Agendas")
        ("cu" "Unscheduled TODO"
         ((todo ""
                ((org-agenda-overriding-header "\nUnscheduled TODO")
                 (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp)))))
         nil
         nil)))

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

(setq require-final-newline t)
(setq-default indicate-empty-lines t)
(eros-mode 1)
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
(add-hook 'sh-mode-hook (lambda () (setq-local outline-regexp "# {{{*")))
(defalias 'perl-mode 'cperl-mode)
(setq cperl-invalid-face nil) 
(setq cperl-electric-keywords t) ;; expands for keywords such as foreach, while, etc...
(setq cperl-hairy t) ;; Turns on most of the CPerlMode options
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(elpy-enable)
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

(diminish 'eldoc-mode)
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

(defadvice server-visit-files (before parse-numbers-in-lines (files proc &optional nowait) activate)
  "Open file with emacsclient with cursors positioned on requested line.
        Most of console-based utilities prints filename in format
        'filename:linenumber'.  So you may wish to open filename in that format.
        Just call:
          emacsclient filename:linenumber
        and file 'filename' will be opened and cursor set on line 'linenumber'"
  (ad-set-arg 0
              (mapcar (lambda (fn)
                        (let ((name (car fn)))
                          (if (string-match "^\\(.*?\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?$" name)
                              (cons
                               (match-string 1 name)
                               (cons (string-to-number (match-string 2 name))
                                     (string-to-number (or (match-string 3 name) ""))))
                            fn))) files)))

(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))

;;; Keybindings

(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "C-c +") 'my-increment-number-decimal)))
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "C-c c") 'comment-line)))
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(evil-leader/set-key "/" 'swiper)
(evil-leader/set-key "<left>" 'previous-buffer)
(evil-leader/set-key "<right>" 'next-buffer)
(evil-leader/set-key "O" 'crux-kill-other-buffers)
(evil-leader/set-key "b" 'switch-to-buffer)
(evil-leader/set-key "e" 'find-file)
(evil-leader/set-key "i" 'crux-find-user-init-file)
(evil-leader/set-key "k" 'kill-buffer)
(evil-leader/set-key "o" 'counsel-outline)
(evil-leader/set-key "q" 'save-buffers-kill-emacs)
(evil-leader/set-key "r" 'restart-emacs)
(evil-leader/set-key "w" 'save-buffers)
(evil-leader/set-key "x" 'eval-buffer)
(evil-leader/set-key "a" 'mark-whole-buffer)
(global-set-key (kbd "C-M-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C-c '") 'counsel-mark-ring)
(global-set-key (kbd "C-c 0") 'insert-date)
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)
(global-set-key (kbd "C-c D") 'crux-smart-kill-line)
(global-set-key (kbd "C-c K") 'nuke-all-buffers)
(global-set-key (kbd "C-c SPC") 'open-org-agenda-day-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)
(global-set-key (kbd "C-c b") 'counsel-bookmark)
(global-set-key (kbd "C-c d") 'crux-duplicate-current-line-or-region)
(global-set-key (kbd "C-c e x") 'my-extract-region-to-variable)
(global-set-key (kbd "C-c f .") 'company-files)
(global-set-key (kbd "C-c f a") 'append-to-file)
(global-set-key (kbd "C-c f f") 'ffap)
(global-set-key (kbd "C-c f i") 'file-info-show)
(global-set-key (kbd "C-c f r") 'counsel-recentf)
(global-set-key (kbd "C-c g") 'counsel-rg)
(global-set-key (kbd "C-c h d") 'dictionary-search)
(global-set-key (kbd "C-c h k") 'counsel-descbinds)
(global-set-key (kbd "C-c i") 'crux-find-user-init-file)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c m") 'menu-bar-open)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c o c") 'org-capture)
(global-set-key (kbd "C-c o t") 'org-toggle-item)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c w f") 'toggle-frame-fullscreen)
(global-set-key (kbd "C-c x") 'counsel-compile)
(global-set-key (kbd "C-c y i") 'ivy-yasnippet)
(global-set-key (kbd "C-c y n") 'yas-new-snippet)
(global-set-key (kbd "C-c z") 'counsel-fzf)
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "M-o") 'counsel-outline)
(global-set-key (kbd "M-x") 'my-counsel-M-x)
(global-set-key (kbd "C-c e u") 'upcase-initials-region)
(global-set-key (kbd "C-S-k") 'crux-kill-whole-line)

(global-set-key [remap dabbrev-expand] 'hippie-expand)

;;; Testing





;;; Ideas

