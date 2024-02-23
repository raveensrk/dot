;;; Introduction

;; (setq debug-on-error t)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;;; Startup

;; (toggle-frame-fullscreen)
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
  (global-company-mode 1)
  )

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets/")))

(use-package yasnippet-snippets
  :after yasnippet
  )
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

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
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


;;; Programming

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


;;;; Compilation 

(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 500)

;;; Openai And Chatgpt Related

(use-package gptel
  :config
  (load-file "~/.config/openai-api-key.el"))

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


(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))

(use-package restart-emacs)

;;; Keybindings

;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)
;; (global-set-key (kbd "C-c g") 'magit)
(global-set-key (kbd "C-c f g") 'find-grep)
(pixel-scroll-mode t)
(global-set-key (kbd "C-c w") 'tab-list)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c y") 'duplicate-dwim)
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

(setq tags-table-files '("$HOME/tags/tags"))

(tool-bar-mode t)
(menu-bar-mode t)
(ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-use-filename-at-point 'guess)
(setq ido-use-url-at-point nil)

(setq ido-file-extensions-order '(".bash" ".org" ".txt" ".sv" ".v" ".py" ".emacs" ".xml" ".el" ".ini" ".cfg" ".cnf"))
(setq ido-ignore-extensions t)


;; (add-hook 'occur-mode-hook (lambda () (next-error-follow-minor-mode)))



(use-package smex
  :config
  (smex-initialize)

  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command))

(use-package ranger
  :config
  (setq ranger-show-hidden t)
  (setq ranger-width-parents 10)
  (setq ranger-preview-file t))

(load-theme 'tango-dark)

(visit-tags-table "~/tags/TAGS")



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

(defun my-elisp-mode-faces ()
  "Buffer-local face remapping for `emacs-lisp-mode-hook'."
  (face-remap-add-relative 'default
                           :background "dark slate gray"
                           :foreground "white"))

(add-hook 'emacs-lisp-mode-hook #'my-elisp-mode-faces)

(defun my-org-mode-faces ()
  "Buffer-local face remapping for `org-mode-hook'."
  (face-remap-add-relative 'default
                           :background "DarkOrange4"
                           :foreground "white"))

(add-hook 'org-mode-hook #'my-org-mode-faces)


(defun my-verilog-mode-faces ()
  "Buffer-local face remapping for `verilog-mode-hook'."
  (face-remap-add-relative 'default
                           :background "#5f2f2f"
                           :foreground "white"))

(add-hook 'verilog-mode-hook #'my-verilog-mode-faces)





(progn
  (defhydra hydra-search ()
    "Search hydra"
    ("o" isearch-occur "isearch occur" :color pink)
    ("r" isearch-repeat-backward "isearch backward")
    ("s" isearch-repeat-forward "isearch forward")
    ("." isearch-forward-symbol-at-point "isearch symbol" :color pink)
    ("q" hydra-edit/body "quit" :exit t))
  
  (defhydra hydra-of-hydras (:columns 4)
    "Hydra of hydras"
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
    ("q" nil "quit" :exit t :color blue)
    ("s" hydra-search/body "search" :color teal)
    ("r" recentf-open "Recent files")
    ("/" hydra-tools/body "tools" :color teal)
    ("t" treemacs "treemacs")
    ("w" ace-window "ace window")
    ;; ("w d" delete-window "delete window")
    ;; ("w o" delete-other-windows "delete other window")
    ;; ("w s" split-window-below "split below")
    ;; ("w v" split-window-right "split right")
    ("x" eval-last-sexp "evaluate last sexp")
    ("X" eval-buffer "evaluate whole buffer")
    )
  (global-set-key (kbd "s-a") 'hydra-of-hydras/body))

(progn
  (require 'org)
  (defhydra hydra-tools 
    (:color amaranth)
    "Edit hydra"
    ("a" org-agenda "Agenda")
    ("g" magit "magit")
    ("!" shell-command "shell command")
    ("q" nil "quit" :exit t :color blue)))


(use-package expand-region
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region))


(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-is-never-other-window           t
          treemacs-show-cursor                     t
          treemacs-show-hidden-files               t
          treemacs-space-between-root-nodes        nil
          treemacs-width                           30
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))




;; (cond
;;  ((string= (message "%s" major-mode) (message "emacs-lisp-mode"))
;;   t)
;;  (t "default")


;;   )
;;  )
;; (print major-mode)

;; (add-hook 'emacs-lisp-mode-hook (lambda () (set-background-color "dark green")))

(use-package quelpa)
(use-package quelpa-use-package)

(use-package bookmark+
  :quelpa (bookmark+ :fetcher wiki
                     :files
                     ("bookmark+.el"
                      "bookmark+-mac.el"
                      "bookmark+-bmu.el"
                      "bookmark+-1.el"
                      "bookmark+-key.el"
                      "bookmark+-lit.el"
                      "bookmark+-doc.el"
                      "bookmark+-chg.el"))
  :defer 2)

(load-library "~/.emacs.d/quelpa/build/bookmark+/bookmark+.el")

