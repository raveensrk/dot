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
;; (package-initialize)
;; ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; ;; and `package-pinned-packages`. Most users will not need or want to do this.
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(advice-add 'list-packages :before 'package-refresh-contents)
;; (setq use-package-always-ensure t) ; This only works with package.el ;; https://github.com/radian-software/straight.el#integration-with-use-package:~:text=Specifying%20%3Astraight%20t%20is%20unnecessary%20if%20you%20set%20straight%2Duse%2Dpackage%2Dby%2Ddefault%20to%20a%20non%2Dnil%20value.%20(Note%20that%20the%20variable%20use%2Dpackage%2Dalways%2Densure%20is%20associated%20with%20package.el%2C%20and%20you%20should%20not%20use%20it%20with%20straight.el.)
;;; Use package
(defalias 'up 'use-package)

(up benchmark-init :straight t :ensure t :config (add-hook 'after-init-hook 'benchmark-init/deactivate))
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

;; (tab-bar-mode nil)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)
;; This will set first buffer shown as scratch
;; (setq initial-buffer-choice t)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key (kbd "C-c n") 'tmm-menubar)
(global-set-key (kbd "C-c m") 'menu-bar-open)
(toggle-frame-maximized)
(put 'narrow-to-region 'disabled nil)
(use-package dashboard
  :straight t
  :diminish
  ;; https://github.com/emacs-dashboard/emacs-dashboard
  :ensure t
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
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "C-c +") 'my-increment-number-decimal)))
(setq-default tab-width 4)
(setq tab-width 4)
;; make indent commands use space only (never tab character)
(setq-default indent-tabs-mode nil)
;; emacs 23.1 to 26, default to t
;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
(up smartparens
  :straight t
  :diminish
  :config (smartparens-global-mode +1))
(up drag-stuff
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
(save-place-mode 1)
;;; Mouse Support in Terminal
;; https://emacsredux.com/blog/2022/06/03/enable-mouse-support-in-terminal-emacs/
;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))
;;; Appearence
(setq cursor-type 'bar)

(setq-default truncate-lines +1)
(up git-gutter
  :straight t
  :config
  (global-git-gutter-mode)
  (setq git-gutter:always-show-separator t)
  )
(setq display-line-numbers 'visual)
(setq display-line-numbers-type 'visual)
(use-package unicode-fonts
  :straight t
  :defer 10
  :ensure t
  :config
  (unicode-fonts-setup))
(global-prettify-symbols-mode +1)
(use-package emojify
  :straight t
  :defer 10
  :hook (after-init . global-emojify-mode))
(use-package centaur-tabs
  :straight t
  ;; https://github.com/ema2159/centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :config
  (centaur-tabs-headline-match)
  (setq centaur-tabs-style "bar")
  (setq centaur-tabs-height 32)
  (setq centaur-tabs-set-icons nil)
  (setq centaur-tabs-set-bar 'over)
  (setq centaur-tabs-close-button "X")
  (setq centaur-tabs-set-modified-marker t)
  (setq centaur-tabs-modified-marker "*")
  (centaur-tabs-change-fonts "arial" 160)
  (centaur-tabs-enable-buffer-reordering)
  (setq centaur-tabs-adjust-buffer-order t)
  (setq centaur-tabs-adjust-buffer-order 'right)
  (setq centaur-tabs-show-new-tab-button t)
  (setq centaur-tabs-show-count t)
  (setq centaur-tabs-set-icons nil)
  (setq centaur-tabs-show-navigation-buttons nil)

  )



;; Reference

;; http://xahlee.info/emacs/emacs/elisp_menu.html#:~:text=Adding%20Your%20Own%20Menu&text=(emacs%20call%20these%20IDs%20%E2%80%9Cfake,%3E%20.

;; Creating a new menu pane in the menu bar to the right of “Tools” menu
(up nyan-mode
  :straight t
  ;; Nyan mode
  ;; https://github.com/TeMPOraL/nyan-mode
  :config
  (nyan-mode)
  )
(up zoom
  :straight t
  :diminish
  ;; https://github.com/cyrus-and/zoom
  :config (zoom-mode t))
;; https://github.com/emacs-tw/awesome-emacs
(use-package all-the-icons
  :straight t
  :if (display-graphic-p))
;; TODO make sure you do this on windows https://www.reddit.com/r/emacs/comments/gznezn/alltheicons/
(up focus
  :straight t
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
(up indent-guide
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
(use-package magit :ensure t :bind ("C-x g" . magit-status))
(unless (package-installed-p 'compat)
  (package-install 'compat))
;; 57834ac3f93aa3c6af02e4484241c59bcbc676d0

(use-package beacon
  :config
  (beacon-mode 1))
;;; Expand region
(use-package expand-region
  :straight t
  :ensure t
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

(use-package which-key :straight t :config (which-key-mode 1))
(use-package rainbow-delimiters :straight t :config (rainbow-delimiters-mode 1))
(use-package avy
  :straight t
  :bind ("C-c a" . avy-goto-char))
;;; Minibuffer completions
(use-package marginalia :straight t :config (marginalia-mode 1))
(up ivy
  :straight t
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-count-format "(%d/%d) ")
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  :bind
  ("C-x b"   . 'ivy-switch-buffer)
  ("C-c v"   . 'ivy-push-view)
  ("C-c V"   . 'ivy-pop-view))
(up swiper
  :straight t
  :bind ("C-s" . swiper))
(up counsel
  :straight t
  :bind (
	     ;; ("C-c i L" . counsel-git-log)
	     ("C-c b"   . counsel-bookmark)
	     ( "ESC ESC C"   . compile)
	     ;; ( "ESC ESC C"   . counsel-compile)
	     ("C-c d"   . counsel-descbinds)
	     ;; ("C-c g"   . counsel-git)
	     ;; ("C-c j"   . counsel-git-grep)
	     ;; ("C-c k"   . counsel-rg)
	     ("C-c m"   . counsel-linux-app)
	     ("C-c o"   . counsel-outline)
	     ;;( "C-c t"   . counsel-load-theme)
	     ("C-c w"   . counsel-wmctrl)
	     ("C-c z"   . counsel-fzf)
	     ("C-x C-f" . counsel-find-file)
	     ("C-x l"   . counsel-locate)
	     ("M-x"     . counsel-M-x)
	     ("C-c fr"  . counsel-recentf)
	     ("C-c g" . counsel-rg)
	     ;;( "C-c er" . restart-emacs)
	     :map minibuffer-local-map
	     ("C-r" . counsel-minibuffer-history)
	     ))
;;; Dired
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
(use-package treemacs
  :straight t
  :defer 10
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))
;;; Projectile
(up projectile
  :straight t
  :diminish
  :config (projectile-mode +1)
  :bind (:map projectile-mode-map ("C-c p" . projectile-command-map)))
(setq projectile-project-search-path nil)
(setq projectile-auto-discover nil)
;;; Evil
(setq evil-want-keybinding nil)
(up evil-numbers
  :after evil
  :straight t
  :config
  (evil-define-key '(normal visual) 'global (kbd "C-a") 'evil-numbers/inc-at-pt)
  (evil-define-key '(normal visual) 'global (kbd "C-x") 'evil-numbers/dec-at-pt)
  (evil-define-key '(normal visual) 'global (kbd "g C-a") 'evil-numbers/inc-at-pt-incremental)
  (evil-define-key '(normal visual) 'global (kbd "g C-x") 'evil-numbers/dec-at-pt-incremental))
(up evil-snipe
  :after evil
  :straight t
  :config
  (evil-snipe-mode 1)
  (evil-snipe-override-mode 1))
(up evil-mc :straight t :config (evil-mc-mode 1))
(add-hook 'xref--xref-buffer-mode-hook 'turn-off-evil-mode)
(add-hook 'Custom-mode-hook 'turn-off-evil-mode)

;;;; UNDO
;; Vim style undo not needed for emacs 28
(use-package undo-fu
  :disabled t
  :straight t)
;;;; Vim Bindings
(use-package evil
  :disabled t
  :straight t
  :demand t
  :bind (("<escape>" . keyboard-escape-quit))
  :init
  ;; allows for using cgn
  ;; (setq evil-search-module 'evil-search)
  (setq evil-want-keybinding nil)
  ;; no vim insert bindings
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))
;;;; Vim Bindings Everywhere else
(use-package evil-collection
  :after evil
  :straight t
  :config
  (setq evil-want-integration t)
  (evil-collection-init))
;;;; Evil leader
(up evil-leader
  :straight t
  :after evil
  :config
  (global-evil-leader-mode 1)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "y" 'copy-whole-buffer
    "=" 'my-indent-whole-buffer
    "b" 'switch-to-buffer
    "fr" 'counsel-recentf
    "ff" 'counsel-find-file
    "r" 'restart-emacs
    "pl" 'package-list-packages
    "pi" 'my-package-refresh-and-install-selected-packages
    "h" 'help
    "d" 'dired
    "w" 'my-indent-whole-buffer-and-save
    "q" 'save-buffers-kill-terminal
    "i" 'my-find-init-file
    "+" 'text-scale-increase
    "-" 'text-scale-decrease
    "x" 'execute-extended-command
    "." 'embark-act
    ";" 'embark-dwim
    "B" 'embark-bindings
    "s" 'swiper
    "lr" 'ledger-report
    "a" 'mark-whole-buffer
    "pp" 'evil-paste-after-newline
    "c" 'comment-region
    "y" 'copy-whole-buffer
    )
  )
(defun evil-paste-after-newline ()
  (interactive)
  (progn
    (evil-insert-newline-below)
    (evil-paste-after 1)
    ))
;;; Maximize frame after starting emacsclient
(add-hook 'server-after-make-frame-hook 'toggle-frame-maximized)
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
(up yasnippet
  :straight t
  :defer 10
  :diminish
  :config
  (yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.
  (setq yas-snippet-dirs
        '("~/.emacs.d/snippets/"                 ;; personal snippets
          "c:/my_repos/dotfiles-main/stow/.emacs.d/snippets"           ;; foo-mode and bar-mode snippet collection
          ))
  (up yasnippet-snippets
    :straight t
    :diminish))
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
(up restart-emacs
  :straight t
  :bind ("C-c r" . restart-emacs))
(up format-all
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
(setq outline-minor-mode-cycle t)
;;; Others
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)


(defun switch-to-dashboard-buffer ()
  (interactive)
  (switch-to-buffer "*dashboard*"))

(strokes-mode +1)
(global-set-key (kbd "<down-mouse-3>") 'strokes-do-stroke) ; Draw strokes with RMB
(setq strokes-use-strokes-buffer t)
(global-set-key (kbd "C-c s s") 'strokes-global-set-stroke)


(if (string-equal system-type "windows-nt")
    (setq my-emacs-root-path "c:/github/dotfiles-main/stow_my_emacs/.emacs.d")
  (setq my-emacs-root-path "~/.emacs.d"))

(defun read-lines-from-file-as-list (file-path)
  "Return a quoted list of lines of a file at FILE-PATH."
  (with-temp-buffer
    (insert-file-contents file-path)
    (mapcar (lambda (line) (format "%s" line)) (split-string (buffer-string) "\n" t))))

(up elfeed
  :straight t
  :defer 10
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
  (find-file user-init-file))

(global-set-key (kbd "C-c i") 'my-open-init-file)
(global-set-key (kbd "C-c f f") 'find-file-at-point)

;; (if (file-exists-p (concat my-emacs-root-path "/" "other-packages/aide/aide.el")))
;; (straight-use-package)

(straight-use-package
 '(aide :type git :host github :repo "junjizhi/aide.el"))
(up request :straight t)
(up aide
  :config
  ;; TODO get this from an environment variable (setq openai-api-key "my-api-key")
  (setq aide-max-tokens 200))

(up persistent-scratch
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

(global-set-key (kbd "ESC ESC h") 'help)
(global-set-key (kbd "ESC ESC c") 'comment-line)
(global-set-key (kbd "ESC ESC e x") 'eval-last-sexp)
(global-set-key (kbd "ESC ESC r") 'restart-emacs)
(global-set-key (kbd "ESC ESC e f") 'elfeed)
(global-set-key (kbd "ESC ESC e e") 'elfeed-edit-my-rss-feed-list)
(up crux
  :straight t)
(global-set-key (kbd "ESC ESC d") 'crux-duplicate-current-line-or-region)
(global-set-key (kbd "ESC ESC D") 'crux-smart-kill-line)
(global-set-key (kbd "ESC ESC a") 'avy-goto-char)
(global-set-key (kbd "ESC ESC i") 'my-open-init-file)
(global-set-key (kbd "ESC ESC f") 'ffap)
(global-set-key (kbd "ESC ESC /") 'swiper)
(global-set-key (kbd "ESC ESC b b") 'counsel-buffer-or-recentf)
(global-set-key (kbd "ESC ESC q") 'save-buffers-kill-terminal)
(global-set-key (kbd "ESC ESC p") 'projectile-switch-project)
(global-set-key (kbd "ESC ESC b k") 'kill-buffer)

(defun nuke-all-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list))
  (delete-other-windows))

(global-set-key (kbd "ESC ESC K") 'nuke-all-buffers)

