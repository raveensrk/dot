;; KAIZEN
;; Emacs versions supported: 28.2+

;;; IDEAS
;; https://github.com/abo-abo/auto-yasnippet

;;; STRAIGHT
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

;; (setq use-package-compute-stastics t)

(straight-use-package 'use-package)

;;; USE PACKAGE
(use-package diminish
  :straight t)
(use-package benchmark-init
  :straight t
  :config (add-hook 'after-init-hook 'benchmark-init/deactivate))

;;; STARTUP, BEHAVIOUR, BASICS
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

(use-package multiple-cursors
  :straight t
  :config
  (multiple-cursors-mode 1)
  :bind
  ("C-M-<mouse-1>" . mc/add-cursor-on-click))

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
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "C-c +") 'my-increment-number-decimal)))
(setq-default tab-width 4)
(setq tab-width 4)
;; make indent commands use space only (never tab character)
;; emacs 23.1 to 26, default to t, if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
(setq-default indent-tabs-mode nil)

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

;;;; Remove extra space from a region or current line
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
;;; MOUSE SUPPORT IN TERMINAL
;; https://emacsredux.com/blog/2022/06/03/enable-mouse-support-in-terminal-emacs/
;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;;; BACKUPS
(setq backup-directory-alist
      '(("." . "~/.emacs.d/file-backups")))

;;; MODES
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(setq-default abbrev-mode 1)
(winner-mode 1)
(recentf-mode 1)
(setq recentf-max-menu-items 200)
(setq recentf-max-saved-items 200)
(save-place-mode +1)
;;; APPEARENCE

;; (add-hook 'server-after-make-frame-hook 'toggle-frame-maximized) ;; Maximize frame after starting emacsclient

;; (use-package rainbow-delimiters
;;   :straight t
;;   :config
;;   (rainbow-delimiters-mode 1)
;;   :hook emacs-lisp-mode
;;   )

(use-package volatile-highlights :straight t)
(volatile-highlights-mode t)

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

(use-package git-gutter
  :diminish
  :straight t
  :config
  (global-git-gutter-mode)
  (setq git-gutter:always-show-separator t)
  (diminish 'global-git-gutter-mode)
  )

(setq display-line-numbers t)
(setq display-line-numbers-type t)
(global-display-line-numbers-mode +1)
(global-visual-line-mode t)
(setq-default visual-line-fringe-indicators t)
;; (setq-default truncate-lines +1)

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

(use-package nyan-mode
  :straight t
  ;; Nyan mode
  ;; https://github.com/TeMPOraL/nyan-mode
  :config
  (nyan-mode +1)
  )

;; (use-package zoom
;;   :straight t
;;   :disabled t
;;   :diminish
;;   ;; https://github.com/cyrus-and/zoom
;;   :config (zoom-mode t))

;; https://github.com/emacs-tw/awesome-emacs
(use-package all-the-icons
  :straight t
  :if (display-graphic-p))
;; TODO make sure you do this on windows https://www.reddit.com/r/emacs/comments/gznezn/alltheicons/

;; (use-package focus
;;   :straight t
;;   :diminish
;;   :hook emacs-lisp-mode
;;   )

;;;; THEME
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

;;;; FONTS

;; https://emacsredux.com/blog/2021/12/22/check-if-a-font-is-available-with-emacs-lisp/

(cond
 ((find-font (font-spec :name "Fira Code"))
  (add-to-list 'default-frame-alist
               '(font . "Fira Code-24"))) 
 ((find-font (font-spec :name "Cascadia Code"))
  (set-frame-font "Cascadia Code-24"))
 ((find-font (font-spec :name "Menlo"))
  (set-frame-font "Menlo-24"))
 ((find-font (font-spec :name "DejaVu Sans Mono"))
  (set-frame-font "DejaVu Sans Mono-24"))
 ((find-font (font-spec :name "Inconsolata"))
  (set-frame-font "Inconsolata-24")))

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


(use-package beacon
  :straight t
  :config
  (beacon-mode 1))

;;; MY FUNCTIONS

(defun my-list-packages ()
  "If already refresehed dont refresh. List only."
  (interactive)
  (if (bound-and-true-p my-package-refreshed-once)
      (list-packages)
    (package-refresh-contents t)
    (setq my-package-refreshed-once t)
    (list-packages)))

(defun er-copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))


(defun my-open-init-file ()
  (interactive)
  (find-file-other-window user-init-file))

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
(define-key global-map (kbd "C-c =") 'my-indent-whole-buffer)

;;; DIRED
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


;;; PACKAGES
;;;; BROWSE KILL RING
(use-package browse-kill-ring
  :straight t
  :config
  (setq browse-kill-ring-highlight-inserted-item t
        browse-kill-ring-highlight-current-entry nil
        browse-kill-ring-show-preview t)
  (define-key browse-kill-ring-mode-map (kbd "j") 'browse-kill-ring-forward)
  (define-key browse-kill-ring-mode-map (kbd "k") 'browse-kill-ring-previous))


;;;; EXPAND REGION
(use-package expand-region
  :straight t
  :straight t
  :bind
  ("C-=" . er/expand-region)
  ("C--" . er/contract-region)
  )

;;;; MAGIT / GIT related

(use-package magit
  :straight t
  :bind ("C-x g" . magit-status))

(use-package magit-section
  :straight t)

(defun my-magit-list-repositories ()
  "This will load magit-status libraries then open magit-list-repositories. Otherwise i get errors... This will make sure all libraries are loaded"
  (interactive)
  (load-library "magit-status")
  (magit-list-repositories)
  )

(setq magit-repository-directories '(("~/my_repos" . 1)))


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


;;;; COMPANY AND COMPLETIONS

(global-set-key (kbd "C-c C-l") 'my-expand-lines)


(use-package company
  :straight t
  :diminish
  :config
  (global-company-mode 1)
  (global-set-key (kbd "C-c f .") 'company-files)
  )

;;;; Hippie expand
;; https://www.masteringemacs.org/article/text-expansion-hippie-expand

(global-set-key [remap dabbrev-expand] 'hippie-expand)


;;;; MULTIPLE CURSORS


(use-package which-key
  :straight t
  :config (which-key-mode 1))

(use-package avy
  :straight t
  :bind ("C-c a" . avy-goto-char))
;;;; MINIBUFFER COMPLETIONS

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

;;;; PROJECTILE

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


;;;; IMENU LIST

(use-package imenu-list
  :straight t
  )

;; TODO https://github.com/bmag/imenu-list

;;;; YASNIPPET

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

;;;; FZF

;; Check if an executable in present in elisp

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

;;;; OUTLI AND OUTLINES
(use-package outli
  :straight (:host github :repo "jdtsmith/outli")
  :after lispy ; only if you use lispy; it also sets speed keys on headers!
  :bind (:map outli-mode-map ; convenience key to get back to containing heading
	      ("C-c C-p" . (lambda () (interactive) (outline-back-to-heading))))
  :hook ((prog-mode text-mode) . outli-mode)
  (emacs-lisp-mode)) ; or whichever modes you prefer

(global-set-key (kbd "M-o") 'counsel-outline)




;;;; File-info
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

;;;; RESTART EMACS

(use-package restart-emacs
  :straight t
  :bind ("C-c r" . restart-emacs))

;;;; FORMAT ALL

(use-package format-all
  :straight t
  :diminish
  ;; https://github.com/lassik/emacs-format-all-the-code/tree/c156ffe5f3c979ab89fd941658e840801078d091
  :hook
  (add-hook 'prog-mode-hook 'format-all-mode)
  )

;;;; CRUX
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

;;;; PERSISTENT SCRATCH
(use-package persistent-scratch
  :straight t
  :config
  (persistent-scratch-setup-default))
;;;; MARKDOWN
(use-package markdown-mode
  :straight t)
;;;; Outline mode extend headings backline
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
;;;; DIRED NARROW
(use-package dired-narrow
  :straight t
  :config
  (define-key dired-mode-map (kbd "/") 'dired-narrow-fuzzy)
  )
;;;; RANGER
(use-package ranger
  :straight t
  :config
  (setq ranger-show-hidden t))

(global-set-key (kbd "C-x d") 'ranger)

;;;; MISC
(use-package smex
  :straight t)


;;;; Fun

(use-package zone-sl
  :straight t)
(use-package zone-select
  :straight t)
(use-package zone
  :config
  (zone-when-idle (* 420 69))
  (zone-select-add-program 'zone-pgm-sl)
  )
(use-package zone-rainbow
  :straight t
  :after zone
  :config
  (setq zone-programs (vconcat [zone-rainbow] zone-programs)))

;;;; Python
(use-package elpy
  :straight t
  :init
  (elpy-enable))


;;;; EROS
(use-package eros
  ;; Emacs Lisp evaluation results as inline overlays.
  :straight t
  :init
  (eros-mode 1)
  :bind
  ("C-x x" . 'eval-defun)
  )

;;;; SPEEDRECT
(use-package speedrect
  :straight (speedrect :type git :host github :repo "jdtsmith/speedrect")
  )

;;;; OCTAVE
(use-package octave
  :straight t
  :bind
  ("C-c x" . 'octave-eval-print-last-sexp))

;;;; lsp-grammarly		
(use-package lsp-grammarly
  :straight t
  :hook (text-mode . (lambda ()
                       (require 'lsp-grammarly)
                       (lsp))))
;;;; TREEMACS
;;;;; TESTING: EMACS BUG
;; https://emacs.stackexchange.com/questions/74289/emacs-28-2-error-in-macos-ventura-image-type-invalid-image-type-svg
;; Emacs bug
(add-to-list 'image-types 'svg)
;;;;; PLUGIN
(use-package treemacs
  :straight t
  :defer t
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

;; (use-package treemacs-evil
;;   :after (treemacs evil)
;;   :straight t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :straight t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :straight t)

(use-package treemacs-magit
  :after (treemacs magit)
  :straight t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :straight t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :straight t
  :config (treemacs-set-scope-type 'Tabs))

;;; CONVENIENCE 
(setq speedbar-show-unknown-files t)
(setq compilation-auto-jump-to-first-error nil)
(setq compilation-scroll-output t)
(global-set-key (kbd "C-c m") 'menu-bar-open)
;; https://emacsredux.com/blog/2016/01/31/use-tab-to-indent-or-complete/
;; (setq tab-always-indent 'complete)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(setq vc-follow-symlinks nil)


(global-set-key (kbd "C-c '") 'counsel-mark-ring)
(global-set-key (kbd "C-,") 'pop-global-mark)

(setq tags-add-tables nil)

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
    (move-beginning-of-line nil))
  ))

(global-set-key (kbd "C-c e x") 'my-extract-region-to-variable)

;;;; AUTOSAVE
;; autosave files every 1 second if visited and changed
(setq auto-save-visited-interval 1)
(auto-save-visited-mode +1)
(setq auto-revert-interval 1)
;; (if (version< emacs-version "28.1")
;;     (message "Emacs version is older than 28.1")
;;   (progn
;;     (message "Emacs version is 28.1 or newer")
;;     (context-menu-mode +1)))
;;;; COMPILATION 
(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 10000)



;;; MISC
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

(fset 'yes-or-no-p 'y-or-n-p)

(display-time-mode t)
(tab-bar-mode t)

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


;;; ORG MODE
(global-set-key (kbd "C-c o a a") 'org-agenda)
(global-set-key (kbd "C-c o a t") 'org-todo-list)
(global-set-key (kbd "C-c l") 'org-store-link)
(setq org-todo-keywords '((sequence "TODO" "KILL" "SKIP" "DONE")))
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

(global-set-key (kbd "C-c 0") 'insert-date)


;;; ESHELL
(use-package eshell
  :config
  (defun eshell-new-buffer (args)
    "Create a new eshell buffer."
    (interactive "P")
    (eshell "new")
    )
  (global-set-key (kbd "C-c e e") 'eshell)
  (global-set-key (kbd "C-c e n") 'eshell-new-buffer))


;;; IMENU

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

;;; VERILOG
(add-hook 'verilog-mode-hook 'hs-minor-mode)
(put 'upcase-region 'disabled nil)
(add-hook 'verilog-mode-hook (lambda () (setq-local outline-regexp ".*{{{*")))

;;; PERL
;; cperl-mode is preferred to perl-mode                                        
;; "Brevity is the soul of wit" <foo at acm.org>                               
(defalias 'perl-mode 'cperl-mode)

(setq cperl-invalid-face nil) 

(setq cperl-electric-keywords t) ;; expands for keywords such as
;; foreach, while, etc...
(setq cperl-hairy t) ;; Turns on most of the CPerlMode options


;;; LISP
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
;;; SH-MODE
(add-hook 'sh-mode-hook (lambda () (setq-local outline-regexp "# {{{*")))
;;; OPENAI AND CHATGPT RELATED

(setq my-openai-api-key-file "~/.emacs.d/openai-api-key.el")

(if (file-exists-p my-openai-api-key-file)
    (load-file my-openai-api-key-file))

(use-package shell-maker
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("shell-maker.el")))

(use-package chatgpt-shell
  :requires shell-maker
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("chatgpt-shell.el")))

;;; TESTING: BREADCRUMB

(use-package breadcrumb :straight (:host github :repo "joaotavora/breadcrumb"))

;;; TESTING: MENU
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
;;; TESTING: LOAD ALL ELISP FILES UNDER ~/.emacs.d/site-lisp
;; (setq my-lisp-files (directory-files-recursively "~/.emacs.d/site-lisp/" ""))

;; (defun my-load-elisp-files (list)
;;   "Print each element of LIST on a line of its own."
;;   (while list
;;     (print (car list))
;;     (load-file (print (car list)))
;;     (setq list (cdr list))))
;;
;; (my-load-elisp-files my-lisp-files)

;;; TESTING: WINDOWS

(if (string-equal system-type "windows-nt")
    (setq my-emacs-root-path "c:/github/dotfiles-main/stow_my_emacs/.emacs.d")
  (setq my-emacs-root-path "~/.emacs.d"))
;;; TESTING: EMACS MOUSE HIGHLIGHT SYMBOL
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

;;;; Load all files in my-pacakges directory if it exists
(if (file-directory-p "~/.emacs.d/my-packages")
    (mapc 'load-file (directory-files-recursively "~/.emacs.d/my-packages" ".*\.el")))


;;; TESTING: BETTER EMACS NARROWING, NARROW RING 🛣️
;; (use-package zones
;;   :straight t
;;   :disabled t
;;   )
;;; TESTING: EDIT MULTIPLE FILES AT THE SAME TIME 🤹

(straight-use-package
 '(multifile :type git :host github :repo "magnars/multifiles.el"))
(use-package multifiles
  :load-path "~/.emacs.d/straight/build/multifile")
(global-set-key (kbd "C-c 3") 'mf/mirror-region-in-multifile)


;;; TESTING: PDF TOOLS

(use-package pdf-tools :straight t)
(use-package google-this
  :straight t
  :bind ("C-c h" . google-this))

;;; End of init

(straight-remove-unused-repos t)

;;; Init

(switch-to-dashboard-buffer)
(delete-other-windows)
;;; CUSTOM SET VARIABLES
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(outli-heading-config
   '((sh-mode "# " 123 t nil)
     (emacs-lisp-mode ";;" 59 t nil)
     (tex-mode "%%" 37 t nil)
     (org-mode)
     (t
      (let*
          ((c
            (or comment-start "#"))
           (space
            (unless
                (eq
                 (aref c
                       (1-
                        (length c)))
                 32)
              " ")))
        (concat c space))
      42 nil nil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package sticky-windows :load-path "~/.emacs.d/lisp/sticky-windows.el")
