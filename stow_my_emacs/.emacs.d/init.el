;; Emacs versions supported: 28.2+

;;; IDEAS
;; https://github.com/abo-abo/auto-yasnippet

;;; Straight
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
(setq package-enable-at-startup nil)
;; (setq straight-use-package-by-default t)

(setq use-package-compute-stastics t)

(straight-use-package 'use-package)

;; (require 'package)
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; ;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; ;; and `package-pinned-packages`. Most users will not need or want to do this.
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (advice-add 'list-packages :before 'package-refresh-contents)
;; (setq use-package-always-ensure t) ; This only works with package.el ;; https://github.com/radian-software/straight.el#integration-with-use-package:~:text=Specifying%20%3Astraight%20t%20is%20unnecessary%20if%20you%20set%20straight%2Duse%2Dpackage%2Dby%2Ddefault%20to%20a%20non%2Dnil%20value.%20(Note%20that%20the%20variable%20use%2Dpackage%2Dalways%2Densure%20is%20associated%20with%20package.el%2C%20and%20you%20should%20not%20use%20it%20with%20straight.el.)

;;; Use package
(defalias 'up 'use-package)
(use-package diminish
  :straight t)
(use-package benchmark-init
  :straight t
  :config (add-hook 'after-init-hook 'benchmark-init/deactivate))
;;; Startup, behaviour, basics
(setq tab-width 4)
(setq mouse-wheel-flip-direction t)
(setq mouse-wheel-tilt-scroll t)
(setq save-place-mode t)
(setq show-paren-mode t)
(global-auto-revert-mode t)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-screen t)
(setq vc-follow-symlinks t)
(setq ring-bell-function 'ignore)
(setq visible-bell 1)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)
;; This will set first buffer shown as scratch
;; (setq initial-buffer-choice t)
;; (toggle-frame-maximized)
(put 'narrow-to-region 'disabled nil)

(use-package dashboard
  :straight t
  :diminish
  ;; https://github.com/emacs-dashboard/emacs-dashboard
  :straight t
  :config
  (dashboard-setup-startup-hook)

  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)

  ;; To disable shortcut "jump" indicators for each section, set
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 10)
                          (projects . 5))))
;;;; Editing
(use-package wrap-region
  :straight t
  :diminish
  :config
  (wrap-region-global-mode)
  (wrap-region-add-wrapper "*" "*")
  )
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "C-c c") 'comment-line)))

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
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "ESC ESC +") 'my-increment-number-decimal)))
(setq-default tab-width 4)
(setq tab-width 4)
;; make indent commands use space only (never tab character)
(setq-default indent-tabs-mode nil)
;; emacs 23.1 to 26, default to t
;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
(use-package smartparens
  :straight t
  :diminish
  :config (smartparens-global-mode +1))
(use-package drag-stuff
  :disabled t
  :straight t
  :defer 5
  :diminish
  ;; https://github.com/rejeep/drag-stuff.el
  :config
  (drag-stuff-global-mode +1)
  (drag-stuff-define-keys)
  )

(setq mouse-drag-and-drop-region t)
(setq mouse-drag-and-drop-region-cut-when-buffers-differ t)
;;; Backups
(setq backup-directory-alist
      '(("." . "~/.emacs.d/file-backups")))
;;; Modes
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(setq-default abbrev-mode 1)
(winner-mode 1)
(recentf-mode 1)
(setq recentf-max-menu-items 200)
(setq recentf-max-saved-items 200)
(save-place-mode +1)
;;; Mouse Support in Terminal
;; https://emacsredux.com/blog/2022/06/03/enable-mouse-support-in-terminal-emacs/
;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))
;;; Appearence
(diminish 'eldoc-mode)
(use-package dimmer
  :straight t
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-hydra)
  (dimmer-configure-magit)
  (dimmer-configure-posframe)
  (dimmer-mode t)
  )
(setq-default truncate-lines +1)
(use-package git-gutter
  :diminish
  :straight t
  :config
  (global-git-gutter-mode)
  (setq git-gutter:always-show-separator t)
  (diminish 'global-git-gutter-mode)
  )
(setq display-line-numbers 'visual)
(setq display-line-numbers-type 'visual)
;; (use-package unicode-fonts
;;   :straight t
;;   :defer 10
;;   :config
;;   (unicode-fonts-setup))
(global-prettify-symbols-mode +1)
;; (use-package emojify
;;   :straight t
;;   :defer 10
;;   :hook (after-init . global-emojify-mode))


;; Reference

;; http://xahlee.info/emacs/emacs/elisp_menu.html#:~:text=Adding%20Your%20Own%20Menu&text=(emacs%20call%20these%20IDs%20%E2%80%9Cfake,%3E%20.

;; Creating a new menu pane in the menu bar to the right of “Tools” menu
(use-package nyan-mode
  :straight t
  ;; Nyan mode
  ;; https://github.com/TeMPOraL/nyan-mode
  :config
  (nyan-mode +1)
  )
(use-package zoom
  :straight t
  :diminish
  ;; https://github.com/cyrus-and/zoom
  :config (zoom-mode t))
;; https://github.com/emacs-tw/awesome-emacs
(use-package all-the-icons
  :straight t
  :if (display-graphic-p))
;; TODO make sure you do this on windows https://www.reddit.com/r/emacs/comments/gznezn/alltheicons/
(use-package focus
  :straight t
  :disabled t
  :diminish
  :hook emacs-lisp-mode
  )
;;;; Theme
(straight-use-package 'modus-themes)
(require 'modus-themes) ; OR for the built-in themes: (require-theme 'modus-themes)

;; Add all your customizations prior to loading the themes
(setq modus-themes-italic-constructs t)
(setq modus-themes-bold-constructs t)

;; Maybe define some palette overrides, such as by using our presets
(setq modus-themes-common-palette-overrides modus-themes-preset-overrides-intense)

;; Load the theme of your choice
(load-theme 'modus-vivendi :no-confim)
(use-package indent-guide
  :straight t
  :diminish
  :config (indent-guide-global-mode 1))
;;;; Fonts

;; https://emacsredux.com/blog/2021/12/22/check-if-a-font-is-available-with-emacs-lisp/
(cond
 ((find-font (font-spec :name "Cascadia Code"))
  (set-frame-font "Cascadia Code-12"))
 ((find-font (font-spec :name "Menlo"))
  (set-frame-font "Menlo-12"))
 ((find-font (font-spec :name "DejaVu Sans Mono"))
  (set-frame-font "DejaVu Sans Mono-12"))
 ((find-font (font-spec :name "Inconsolata"))
  (set-frame-font "Inconsolata-12")))

;; (use-package dynamic-fonts :init (dynamic-fonts-setup))     ; finds "best" fonts and sets faces: default, fixed-pitch, variable-pitch


;; ;; Check if a font exists
;; (defun font-exists-p (font)
;;   "Check if FONT exists on the system."
;;   (member font (x-list-fonts "*")))

;; ;; Set the default font to Fira Code with size 14
;; (if (font-exists-p "Fira Code")
;;     (progn
;;       (set-face-attribute 'default nil :font "Fira Code-14")

;;       ;; Define the prettified symbol list
;;       (defvar my-fira-code-prettify-symbols-alist
;;         '(("lambda" . ?λ)
;;           ("->" . ?→)
;;           ("=>" . ?⇒)
;;           ("!=" . ?≠)
;;           (">=" . ?≥)
;;           ("<=" . ?≤)
;;           ))

;;       ;; Enable Fira Code ligatures in programming and text modes
;;       (add-hook 'prog-mode-hook
;;                 (lambda ()
;;                   (setq prettify-symbols-alist my-fira-code-prettify-symbols-alist)
;;                   (prettify-symbols-mode)))
;;       (add-hook 'text-mode-hook
;;                 (lambda ()
;;                   (setq prettify-symbols-alist my-fira-code-prettify-symbols-alist)
;;                   (prettify-symbols-mode)))
;;       ))

(use-package magit
  :straight t
  :bind ("C-x g" . magit-status))
;; (unless (package-installed-p 'compat)
;;   (package-install 'compat))
;; 57834ac3f93aa3c6af02e4484241c59bcbc676d0

(use-package beacon
  :straight t
  :config
  (beacon-mode 1))
;;; Expand region
(use-package expand-region
  :straight t
  :straight t
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region)
  )
;;; My functions
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
(define-key global-map (kbd "C-c =") 'my-indent-whole-buffer)

;;; Company and completions
(global-set-key (kbd "C-c C-l") 'my-expand-lines)
(use-package company
  :straight t
  :diminish
  :config (global-company-mode 1))
;;; Hippie expand
;; https://www.masteringemacs.org/article/text-expansion-hippie-expand
(global-set-key [remap dabbrev-expand] 'hippie-expand)
;;; Outline minor mode
;;; Multiple cursors
(use-package multiple-cursors
  :straight t
  :config
  (multiple-cursors-mode 1)
  :bind
  ("C-M-<mouse-1>" . mc/add-cursor-on-click))

(use-package which-key
  :straight t
  :config (which-key-mode 1))
(use-package rainbow-delimiters
  :straight t
  :config
  (rainbow-delimiters-mode 1)
  :hook emacs-lisp-mode
  )
(use-package avy
  :straight t
  :bind ("C-c a" . avy-goto-char))
;;; Minibuffer completions
(use-package marginalia
  :straight t
  :config (marginalia-mode 1))
(use-package ivy
  :straight t
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
  (add-to-list 'ivy-highlight-functions-alist '(orderless-ivy-re-builder . orderless-ivy-highlight))
  :bind
  ("C-x b"   . 'ivy-switch-buffer)
  ("C-c v"   . 'ivy-push-view)
  ("C-c V"   . 'ivy-pop-view))

(use-package orderless
  :straight t
  :after ivy
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package swiper
  :straight t
  :config
  (defun my-word-at-point ()
    (interactive)
    (swiper (word-at-point)))
  :bind
  ("C-s" . swiper)
  ("C-c s" . my-word-at-point)
  )

(use-package counsel
  :straight t
  :config
  (defun my-counsel-M-x ()
    "Counsel M-x with ^ removed"
    (interactive)
    (counsel-M-x "")
    )
  :bind (
	     ("C-c g l" . counsel-git-log)
	     ("C-c b"   . counsel-bookmark)
	     ("C-c x"   . counsel-compile)
	     ("C-c d"   . counsel-descbinds)
	     ("C-c g g"   . counsel-git)
	     ("C-c j"   . counsel-git-grep)
	     ("C-c k"   . counsel-rg)
	     ("C-c m"   . counsel-linux-app)
	     ("C-c o o"   . counsel-outline)
	     ( "C-c t"   . counsel-load-theme)
	     ("C-c w"   . counsel-wmctrl)
	     ("C-c z"   . counsel-fzf)
	     ("C-x C-f" . counsel-find-file)
	     ("C-x l"   . counsel-locate)
	     ("M-x"     . my-counsel-M-x)
	     ("C-c f r"  . counsel-recentf)
	     :map minibuffer-local-map
	     ("C-r" . counsel-minibuffer-history)
	     ))

;;; Dired
;; Guess emacs dired destination
;; Lets say that you want to copy files from one dired split to the other
;; split, emacs can automatically guess the destination directory to make
;; this simpler.
(setq dired-dwim-target t)
;; https://emacs.stackexchange.com/questions/5603/how-to-quickly-copy-move-file-in-emacs-dired>

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


;;; Projectile
(use-package projectile
  :straight t
  :diminish
  :config
  (projectile-mode +1)
  (defun my-projectile-add-to-known-projects (args)
    "Add a project to projectile interactively"
    (interactive "D")
    (projectile-add-known-project args)
    )
  (setq projectile-generic-command "fd -L . -0 --type f --color=never --strip-cwd-prefix")
  :bind
  (:map projectile-mode-map ("C-c p" . projectile-command-map))
  ("C-c p a" . my-projectile-add-to-known-projects)
  )

(setq projectile-project-search-path nil)
(setq projectile-auto-discover nil)
;;  ;;; Evil
;;  (setq evil-want-keybinding nil)
;;  (use-package evil-numbers
;;    :after evil
;;    :straight t
;;    :config
;;    (evil-define-key '(normal visual) 'global (kbd "C-a") 'evil-numbers/inc-at-pt)
;;    (evil-define-key '(normal visual) 'global (kbd "C-x") 'evil-numbers/dec-at-pt)
;;    (evil-define-key '(normal visual) 'global (kbd "g C-a") 'evil-numbers/inc-at-pt-incremental)
;;    (evil-define-key '(normal visual) 'global (kbd "g C-x") 'evil-numbers/dec-at-pt-incremental))
;;  (use-package evil-snipe
;;    :after evil
;;    :straight t
;;    :config
;;    (evil-snipe-mode 1)
;;    (evil-snipe-override-mode 1))
;;  (use-package evil-mc :straight t :config (evil-mc-mode 1))
;;  (add-hook 'xref--xref-buffer-mode-hook 'turn-off-evil-mode)
;;  (add-hook 'Custom-mode-hook 'turn-off-evil-mode)

;; ;;;; UNDO
;; ;; Vim style undo not needed for emacs 28
;; (use-package undo-fu
;;   :disabled t
;;   :straight t)
 ;;;; Vim Bindings
;;  (use-package evil
;;    :straight t
;;    :demand t
;;    :bind (("<escape>" . keyboard-escape-quit))
;;    :init
;;    ;; allows for using cgn
;;    ;; (setq evil-search-module 'evil-search)
;;    (setq evil-want-keybinding nil)
;;    ;; no vim insert bindings
;;    (setq evil-undo-system 'undo-fu)
;;    :config
;;    (evil-mode 1))
;;  ;;;; Vim Bindings Everywhere else
;;  (use-package evil-collection
;;    :after evil
;;    :straight t
;;    :config
;;    (setq evil-want-integration t)
;;    (evil-collection-init))
;; ;;;; Evil leader
;; (use-package evil-leader
;;   :straight t
;;   :after evil
;;   :config
;;   (global-evil-leader-mode 1)
;;   (evil-leader/set-leader "<SPC>")
;;   (evil-leader/set-key
;;     "y" 'copy-whole-buffer
;;     "=" 'my-indent-whole-buffer
;;     "b" 'switch-to-buffer
;;     "fr" 'counsel-recentf
;;     "ff" 'counsel-find-file
;;     "r" 'restart-emacs
;;     "pl" 'package-list-packages
;;     "pi" 'my-package-refresh-and-install-selected-packages
;;     "h" 'help
;;     "d" 'dired
;;     "w" 'my-indent-whole-buffer-and-save
;;     "q" 'save-buffers-kill-terminal
;;     "i" 'my-find-init-file
;;     "+" 'text-scale-increase
;;     "-" 'text-scale-decrease
;;     "x" 'execute-extended-command
;;     "." 'embark-act
;;     ";" 'embark-dwim
;;     "B" 'embark-bindings
;;     "s" 'swiper
;;     "lr" 'ledger-report
;;     "a" 'mark-whole-buffer
;;     "pp" 'evil-paste-after-newline
;;     "c" 'comment-region
;;     "y" 'copy-whole-buffer
;;     )
;;   )
;; (defun evil-paste-after-newline ()
;;   (interactive)
;;   (progn
;;     (evil-insert-newline-below)
;;     (evil-paste-after 1)
;;     ))
;;; Maximize frame after starting emacsclient
;; (add-hook 'server-after-make-frame-hook 'toggle-frame-maximized)
;;; Load all elisp files under ~/.emacs.d/site-lisp
;; (setq my-lisp-files (directory-files-recursively "~/.emacs.d/site-lisp/" ""))

;; (defun my-load-elisp-files (list)
;;   "Print each element of LIST on a line of its own."
;;   (while list
;;     (print (car list))
;;     (load-file (print (car list)))
;;     (setq list (cdr list))))
;;
;; (my-load-elisp-files my-lisp-files)
;;; Yas snippets
(use-package yasnippet
  :straight t
  :diminish
  :bind
  ("C-c y n" . 'yas-new-snippet)
  :config
  (yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.
  (setq yas-snippet-dirs-windows "c:/github/dotfiles-main/stow_my_emacs/.emacs.d/snippets")
  (if (file-exists-p yas-snippet-dirs-windows)
      (add-to-list 'yas-snippet-dirs yas-snippet-dirs-windows)
    (setq yas-snippet-dirs        '("~/.emacs.d/snippets/")))
  )
(use-package ivy-yasnippet
  :straight t
  :after yasnippet
  :bind
  ("C-c y i" . ivy-yasnippet))

(use-package yasnippet-snippets
  :after yasnippet
  :straight t
  :diminish)

;;; fzf
(use-package fzf
  :straight t
  :defer 5
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
;;; Convenience
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



;; File-info
(use-package hydra
  :straight t)
(use-package browse-at-remote
  :straight t)
(use-package posframe
  :straight t)
(use-package file-info
  :straight (:host github :repo "artawower/file-info.el")
  :bind (("C-c f i" . 'file-info-show))
  :config
  (setq hydra-hint-display-type 'posframe)
  (setq hydra-posframe-show-params `(:poshandler posframe-poshandler-frame-center
                                                 :internal-border-width 2
                                                 :internal-border-color "#61AFEF"
                                                 :left-fringe 16
                                                 :right-fringe 16)))


(use-package restart-emacs
  :straight t
  :bind ("C-c r" . restart-emacs))
(use-package format-all
  :straight t
  :diminish
  ;; https://github.com/lassik/emacs-format-all-the-code/tree/c156ffe5f3c979ab89fd941658e840801078d091
  :hook
  (add-hook 'prog-mode-hook 'format-all-mode)
  )

;; https://github.com/Alexander-Miller/treemacs
(setq speedbar-show-unknown-files t)
(setq compilation-auto-jump-to-first-error nil)
(setq compilation-scroll-output t)

;;;; My Menu
(define-key-after
  global-map
  [menu-bar mymenu]
  (cons "My Menu" (make-sparse-keymap "hoot hoot"))
  'tools )
;; creating another menu item
(define-key
  global-map
  [menu-bar mymenu treemacs]
  '("toggle treemacs" . treemacs))
;;; Outline minor mode
;; (setq outline-minor-mode-cycle t)

(defun switch-to-dashboard-buffer ()
  (interactive)
  (switch-to-buffer "*dashboard*"))

;; TODO (strokes-mode +1)
;; (global-set-key (kbd "<down-mouse-3>") 'strokes-do-stroke) ; Draw strokes with RMB
;; (setq strokes-use-strokes-buffer t)
;; (global-set-key (kbd "ESC ESC e s") 'strokes-global-set-stroke)

(if (string-equal system-type "windows-nt")
    (setq my-emacs-root-path "c:/github/dotfiles-main/stow_my_emacs/.emacs.d")
  (setq my-emacs-root-path "~/.emacs.d"))

(defun read-lines-from-file-as-list (file-path)
  "Return a quoted list of lines of a file at FILE-PATH."
  (with-temp-buffer
    (insert-file-contents file-path)
    (mapcar (lambda (line) (format "%s" line)) (split-string (buffer-string) "\n" t))))

(use-package elfeed
  :straight t
  :defer 10
  :if (file-exists-p "~/.emacs.d/my-packages/rss-feeds.el")
  :config
  (setq my-rss-feed-list "~/.emacs.d/my-packages/rss-feeds.el")
  (load-file my-rss-feed-list)
  (defun elfeed-edit-my-rss-feed-list ()
    (interactive)
    (find-file my-rss-feed-list))
  (defun elfeed-db-delete ()
    (interactive)
    (delete-directory "~/.elfeed" t))
  (advice-add 'elfeed :before 'elfeed-update)
  :bind
  ("C-c e f f" . elfeed)
  ("C-c e f e" . elfeed-edit-my-rss-feed-list)
  ("C-c e f d" . elfeed-db-delete)
  )

(defun my-open-init-file ()
  (interactive)
  (find-file-other-window user-init-file))

;; (if (file-exists-p (concat my-emacs-root-path "/" "other-packages/aide/aide.el")))
;; (straight-use-package)


(use-package persistent-scratch
  :straight t
  :config
  (persistent-scratch-setup-default))

(defun er-copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))


;; https://emacsredux.com/blog/2016/01/31/use-tab-to-indent-or-complete/
;; (setq tab-always-indent 'complete)

(use-package crux
  :straight t
  :config
  (global-set-key (kbd "C-c D") 'crux-smart-kill-line)
  (global-set-key (kbd "C-c d") 'crux-duplicate-current-line-or-region))
(use-package web-mode
  :straight t)
(global-set-key (kbd "C-c i") 'my-open-init-file)
(global-set-key (kbd "C-c f f") 'ffap)
(global-set-key (kbd "C-c f a") 'append-to-file)
(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))
(global-set-key (kbd "C-c K") 'nuke-all-buffers)

(use-package magit-section
  :straight t)

(global-set-key (kbd "C-c m") 'menu-bar-open)

(defun my-magit-list-repositories ()
  "This will load magit-status libraries then open magit-list-repositories. Otherwise i get errors... This will make sure all libraries are loaded"
  (interactive)
  (load-library "magit-status")
  (magit-list-repositories)
  )

(global-set-key (kbd "C-c t") 'toggle-truncate-lines)


;;; Autosave files every 1 second if visited and changed
(setq auto-save-visited-interval 1)
(auto-save-visited-mode +1)
(setq auto-revert-interval 1)
;; (if (version< emacs-version "28.1")
;;     (message "Emacs version is older than 28.1")
;;   (progn
;;     (message "Emacs version is 28.1 or newer")
;;     (context-menu-mode +1)))
(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 10000)
(global-display-line-numbers-mode +1)

(use-package markdown-mode
  :straight t)


(defun my-list-packages ()
  "If already refresehed dont refresh. List only."
  (interactive)
  (if (bound-and-true-p my-package-refreshed-once)
      (list-packages)
    (package-refresh-contents t)
    (setq my-package-refreshed-once t)
    (list-packages)))


;;; Outline mode extend headings backline
(use-package outline-minor-faces
  :straight t
  :diminish
  )
(use-package backline
  :diminish
  :straight t
  :after outline
  :config (advice-add 'outline-flag-region :after 'backline-update)
  (outline-minor-faces-mode +1))

;; (use-package magit-section
;;   :straight t)

(use-package smex
  :straight t)

(use-package back-button
  :straight t
  :disabled t
  :diminish
  :config
  (back-button-mode +1))



;; https://ruzkuku.com/texts/emacs-mouse.html

;; (defun highlight-symbol-at-mouse (e)
;;   "Highlight symbol at mouse click E."
;;   (interactive "e")
;;   (save-excursion
;;     (mouse-set-point e)
;;     (highlight-symbol-at-point)))

;; (defun context-menu-highlight-symbol (menu click)
;;   "Populate MENU with command to search online."
;;   (save-excursion
;;     (mouse-set-point click)
;;     (when (symbol-at-point)
;;       (define-key-after menu [highlight-search-separator] menu-bar-separator)
;;       (define-key-after menu [highlight-search-mouse]
;;         '(menu-item "Highlight Symbol" highlight-symbol-at-mouse
;;                     :help "Highlight symbol at point"))))
;;   menu)

;; (add-hook 'context-menu-functions #'context-menu-highlight-symbol)

;; (defun duplicate-tab (e)
;;   "Highlight symbol at mouse click E."
;;   (interactive "e")
;;   (save-excursion
;;     (mouse-set-point e)
;;     (tab-bar-new-tab)))

;; (defun my-context-menu-duplicate-tab (menu click)
;;   (save-excursion
;;     (mouse-set-point click)
;;     (define-key-after menu [tab-separator] menu-bar-separator)
;;     (define-key-after menu [tab-seperator-mouse]
;;       '(menu-item "Duplicate Tab" duplicate-tab
;;                   :help "Create a duplicate tab")))
;;   menu)

;; (add-hook 'context-menu-functions #'my-context-menu-duplicate-tab)






(if (string-equal system-type "windows-nt")
    (progn
      (setq my-emacs-root-path "c:/github/dotfiles-main/stow_my_emacs/.emacs.d")
      (prefer-coding-system 'utf-8)))


;; Load all files in my-pacakges directory if it exists
(if (file-directory-p "~/.emacs.d/my-packages")
    (mapc 'load-file (directory-files-recursively "~/.emacs.d/my-packages" ".*\.el")))

(defun start-pomodoro ()
  (interactive)
  (org-timer-set-timer "0:20:02"))

(defun start-break ()
  (interactive)
  (org-timer-set-timer "0:10:02"))

(global-set-key (kbd "C-c 1 1") 'start-pomodoro)
(global-set-key (kbd "C-c 1 2") 'start-break)

;; from https://github.com/munen/emacs.d/

(setq gc-cons-threshold 20000000)
(setq make-backup-files nil)
(setq large-file-warning-threshold 200000000)
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(put 'dired-find-alternate-file 'disabled nil)
(setq-default dired-listing-switches "-alh")
(setq dired-recursive-copies 'always)
(use-package dired-narrow
  :straight t
  :config
  (define-key dired-mode-map (kbd "/") 'dired-narrow-fuzzy)
  )

(fset 'yes-or-no-p 'y-or-n-p)

(display-time-mode t)
(tab-bar-mode -1)

(setq save-place-file "~/.emacs.d/saveplace")

(setq visible-bell t)


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


;; https://www.reddit.com/r/emacs/comments/idz35e/emacs_27_can_take_svg_screenshots_of_itself/
(defun screenshot-svg ()
  "Save a screenshot of the current frame as an SVG image.
Saves to a temp file and puts the filename in the kill ring."
  (interactive)
  (let* ((filename (make-temp-file "Emacs" nil ".svg"))
         (data (x-export-frames nil 'svg)))
    (with-temp-file filename
      (insert data))
    (kill-new filename)
    (message filename)))


(use-package browse-kill-ring
  :straight t
  :config
  (setq browse-kill-ring-highlight-inserted-item t
        browse-kill-ring-highlight-current-entry nil
        browse-kill-ring-show-preview t)
  (define-key browse-kill-ring-mode-map (kbd "j") 'browse-kill-ring-forward)
  (define-key browse-kill-ring-mode-map (kbd "k") 'browse-kill-ring-previous))

;; TODO https://github.com/Malabarba/spinner.el
;; https://github.com/ferfebles/redtick
(setq magit-repository-directories '(("~/my_repos" . 1)))

(global-set-key (kbd "C-c o a a") 'org-agenda)
(global-set-key (kbd "C-c o a t") 'org-todo-list)


;; TODO For some reason this function is not present in my magit repo
;; https://github.com/magit/magit/commit/801cbfd83797600f4a38479c6ae4f8d474860aad#diff-d6a81474395687b058c1941f4e9fb8a3b21731e84a4f26b7fd5fdf2e9a800de5
;; (defun magit-repolist-column-dirty (_id)
;;   "Insert a letter if there are uncommitted changes.
;; Show N if there is at least one untracked file.
;; Show U if there is at least one unstaged file.
;; Show S if there is at least one staged file.
;; Only one letter is shown, the first that applies."
;;   (cond ((magit-untracked-files) "N")
;;         ((magit-unstaged-files)  "U")
;;         ((magit-staged-files     "S"))))

(setq magit-repolist-columns
      '(("Name"    25 magit-repolist-column-ident ())
        ("Version" 25 magit-repolist-column-version ())
        ("D"        1 magit-repolist-column-flag ())
        ("⇣"      3 magit-repolist-column-unpulled-from-upstream
         ((:right-align t)
          (:help-echo "Upstream changes not in branch")))
        ("⇡"      3 magit-repolist-column-unpushed-to-upstream
         ((:right-align t)
          (:help-echo "Local changes not in upstream")))
        ("Path"    99 magit-repolist-column-path ())))

(defun my-magit-repolist-pull-repos (repos)
  "This will get all repos name in repolist"
  (interactive (list (magit-repolist--get-repos ?*)))
  (run-hooks 'magit-credential-hook)
  (dolist (repo (magit-list-repos))
    (message repo))
  (magit-repolist--mapc
   (apply-partially #'magit-run-git "pull")
   repos "Pulling in %s..."))

(defun my-magit-repolist-push-repos (repos)
  "This will get all repos name in repolist and push them on by one"
  (interactive (list (magit-repolist--get-repos ?*)))
  (run-hooks 'magit-credential-hook)
  (dolist (repo (magit-list-repos))
    (message repo))
  (magit-repolist--mapc
   (apply-partially #'magit-run-git "push")
   repos "Pushing in %s...")
  )

;; (advice-add 'my-magit-repolist-pull-repos :before 'my-magit-list-repositories)




(setq org-todo-keywords '((sequence "TODO" "KILL" "SKIP" "DONE")))


;;; Better emacs narrowing, narrow ring 🛣️
(use-package zones
  :straight t
  :disabled t
  )

;;; Edit multiple files at the same time 🤹

(straight-use-package
 '(multifile :type git :host github :repo "magnars/multifiles.el"))
(use-package multifiles
  :load-path "~/.emacs.d/straight/build/multifile")
(global-set-key (kbd "C-c 3") 'mf/mirror-region-in-multifile)


(setq org-archive-location "%s::* Archived Tasks")
(setq vc-follow-symlinks nil)
(setq auto-save-visited-mode t
      calendar-date-style 'iso
      cursor-in-non-selected-windows 'hollow
      cursor-type '(bar . 2)
      dired-listing-switches "-alh"
      evil-cross-lines t
      evil-want-minibuffer t
      global-company-mode t
      global-visual-line-mode t
      inhibit-startup-screen t
      modus-themes-bold-constructs t
      modus-themes-fringes 'intense
      modus-themes-scale-headings t
      modus-themes-subtle-line-numbers nil
      modus-themes-tabs-accented t
      modus-themes-variable-pitch-headings t
      modus-themes-variable-pitch-ui t
      org-archive-location "::* Archived Tasks"
      org-export-backends
      '(ascii beamer html icalendar latex man md odt org confluence)
      org-export-use-babel nil
      org-export-with-broken-links 'mark
      org-html-allow-name-attribute-in-anchors t
      org-html-checkbox-type 'unicode
      org-html-html5-fancy t
      org-html-self-link-headlines t
      org-support-shift-select t
      org-todo-keywords '((sequence "TODO" "DOING" "SKIP" "KILL" "DONE"))
      recentf-mode t
      visible-bell t
      winner-mode t)

(setq-default cursor-type '(bar . 2))

(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))


(use-package ranger
  :straight t
  :config
  (setq ranger-show-hidden t))

(global-set-key (kbd "C-x d") 'ranger)

(defun insert-date ()
  "This will insert todays date in YYYY-MM-DD format"
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun return-date ()
  "This will return todays date in YYYY-MM-DD format"
  (interactive)
  (format-time-string "%Y-%m-%d"))

(defalias 'today 'return-date)

(global-set-key (kbd "C-c 0") 'insert-date)

(add-hook 'markdown-mode-hook (lambda () (text-scale-set 3)))



;; (add-hook 'prog-mode-hook 'turn-on-evil-mode)

;;; OpenAI

;; Enter the keys in the following variables in base64 format in the below file
;; (setq openai-api-key (base64-decode-string "key"))
;; (setq openai-key (base64-decode-string "key"))

(setq my-openai-api-key-file "~/.emacs.d/openai-api-key.el")

(if (file-exists-p my-openai-api-key-file)
    (load-file my-openai-api-key-file))

(use-package openai
  :straight (openai :type git :host github :repo "emacs-openai/openai")
  :bind
  ("C-c , r" . openai-completion-select-insert)
  ("C-c , b" . openai-completion-buffer-insert)
  )

(straight-use-package
 '(aide :type git :host github :repo "junjizhi/aide.el"))
(use-package request :straight t)
(use-package aide
  :config
  (setq aide-max-tokens 200))



;;; Eshell
(use-package eshell
  :config
  (defun eshell-new-buffer (args)
    "Create a new eshell buffer."
    (interactive "P")
    (eshell "new")
    )
  (global-set-key (kbd "C-c e e") 'eshell)
  (global-set-key (kbd "C-c e n") 'eshell-new-buffer))


;;; Imenu

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
  (setq imenu-auto-rescan t)
  :bind
  ("C-c o i" . counsel-imenu)
  )

(use-package imenu-anywhere
  :straight t)

;;; Fun

(use-package zone-sl
  :straight t)
(use-package zone-select
  :straight t)
(use-package zone
  :config
  (zone-when-idle 120)
  (zone-select-add-program 'zone-pgm-sl)
  )
(use-package zone-rainbow
  :straight t
  :after zone
  :config
  (setq zone-programs (vconcat [zone-rainbow] zone-programs)))


;;; Python
(use-package elpy
  :straight t
  :init
  (elpy-enable))


;;; Verilog
(add-hook 'verilog-mode-hook 'hs-minor-mode)
(put 'upcase-region 'disabled nil)

;;; Perl
;; cperl-mode is preferred to perl-mode                                        
;; "Brevity is the soul of wit" <foo at acm.org>                               
(defalias 'perl-mode 'cperl-mode)

(setq cperl-invalid-face nil) 

(setq cperl-electric-keywords t) ;; expands for keywords such as
;; foreach, while, etc...
(setq cperl-hairy t) ;; Turns on most of the CPerlMode options


(use-package speedrect
  :straight (speedrect :type git :host github :repo "jdtsmith/speedrect")
  )

;;; Lisp
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
(use-package eros
  ;; Emacs Lisp evaluation results as inline overlays.
  :straight t
  :init
  (eros-mode 1)
  :bind
  ("C-x x" . 'eval-defun)
  )


;;; Remove extra space from a region or current line
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

(global-set-key (kbd "C-c <SPC>") 'remove-extra-spaces)

(use-package octave
  :straight t
  :bind
  ("C-c x" . 'octave-eval-print-last-sexp))


(setq tags-add-tables nil)
(global-set-key (kbd "C-c '") 'helm-all-mark-rings)

		
(use-package lsp-grammarly
  :straight t
  :hook (text-mode . (lambda ()
                       (require 'lsp-grammarly)
                       (lsp))))
