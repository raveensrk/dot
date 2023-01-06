;;; Package Specific
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)


;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(setq custom-file "~/.emacs.d/custom.el")
(add-to-list 'load-path "~/.emacs.d/site-lisp")
(load custom-file)
(defun my-package-refresh-and-install-selected-packages ()
  (interactive)
  (package-refresh-contents)
  (package-install-selected-packages t)
  (package-autoremove)
  )

;;; https://gist.github.com/Gavinok/38975384c4a46c291103e7b220dc25e9
;;; BOOTSTRAP USE-PACKAGE
;; (package-initialize)
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

(use-package benchmark-init :hook (after-init-hook benchmark-init/deactivate))

;;; Raveen's Emacs init

;; (toggle-debug-on-error)

;; If you are using windows set the home environment variable to a where your .emacs.d is present

;;; Startup and behaviour
(setq inhibit-startup-screen t)
(setq vc-follow-symlinks t)
(setq ring-bell-function 'ignore)
(setq visible-bell 1)
(tab-bar-mode 1)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)
;; This will set first buffer shown as scratch
;; (setq initial-buffer-choice t)
(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key (kbd "C-c n") 'tmm-menubar)
(toggle-frame-maximized)

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

(use-package dynamic-fonts :init (dynamic-fonts-setup))     ; finds "best" fonts and sets faces: default, fixed-pitch, variable-pitch
(use-package magit :bind ("C-x g" . magit-status))
(use-package expand-region :bind ("C-=" . er/expand-region))
;;; My functions

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
(defun my-find-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; (use-package org
;;   :hook
;;   (org-mode-hook (imenu 1))
;;   (org-mode-hook (imenu-add-menubar-index 1))
;;   (org-mode-hook (setq imenu-auto-rescan 1)))

;; Not working TODO
(use-package org
  :disabled t
  :hook
  (add-hook 'org-mode-hook #'imenu)
  (add-hook 'org-mode-hook #'(imenu-add-menubar-index 1))
  :bind (:map org-mode-map
			  ("C-c n" . org-toggle-narrow-to-subtree)
			  ("<tab>" . org-cycle)))
(use-package beacon :config (beacon-mode 1))
(use-package company
  :diminish
  :config (global-company-mode 1))
(use-package multiple-cursors
  :config
  (multiple-cursors-mode 1)
  :bind
  ("C-c e |"	.	mc/edit-lines)
  ("C-c e n"	.	mc/mark-next-like-this)
  ("C-c e p"	.	mc/mark-previous-like-this)
  ("C-c e a"	.	mc/mark-all-like-this))
(use-package marginalia :config (marginalia-mode 1))
(use-package which-key :config (which-key-mode 1))
(use-package rainbow-delimiters :config (rainbow-delimiters-mode 1))
(use-package avy :bind ("C-c y" . avy-goto-char))
(use-package embark
  :bind
  ("C-c ." . embark-act)
  ("C-c ;" . embark-dwim)
  ("C-h B" . embark-bindings)
  :config
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
				 nil
				 (window-parameters (mode-line-format . none))))
  )
(defalias 'up 'use-package)
(defalias '📦 'use-package)
(up ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-count-format "(%d/%d) ")
  ;; enable this if you want `swiper' to use it
  ;; (setq search-default-mode #'char-fold-to-regexp)
  (📦 swiper :bind ("C-s" . swiper))
  (📦 counsel :bind
	(:map minibuffer-local-map ("C-r" . counsel-minibuffer-history))
	("C-c i L" . counsel-git-log)
	("C-c b"   . counsel-bookmark)
	("C-c c"   . counsel-compile)
	("C-c d"   . counsel-descbinds)
	("C-c g"   . counsel-git)
	("C-c j"   . counsel-git-grep)
	("C-c k"   . counsel-rg)
	("C-c m"   . counsel-linux-app)
	("C-c o"   . counsel-outline)
	("C-c t"   . counsel-load-theme)
	("C-c w"   . counsel-wmctrl)
	("C-c z"   . counsel-fzf)
	("C-x C-f" . counsel-find-file)
	("C-x l"   . counsel-locate)
	("M-x"     . counsel-M-x)
    ("C-c fr"  . counsel-recentf)
    )
  :bind
  ("C-x b"   . 'ivy-switch-buffer)
  ("C-c v"   . 'ivy-push-view)
  ("C-c V"   . 'ivy-pop-view))

;;; Editing
(setq-default tab-width 4)
(setq tab-width 4)
;; make indent commands use space only (never tab character)
(setq-default indent-tabs-mode nil)
;; emacs 23.1 to 26, default to t
;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
;;; Backups
(setq backup-directory-alist
      '(("." . "~/.emacs.d/file-backups")))
;;; Dired
(setq dired-kill-when-opening-new-dired-buffer nil)
(global-set-key (kbd "C-c +") 'dired-create-empty-file)
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
;;; Org mode
(setq org-agenda-archives-mode t)
(setq org-confirm-babel-evaluate nil)
(setq org-src-tab-acts-natively t)
;; (setq org-startup-folded t)
;; (add-hook 'org-mode-hook (lambda () (visual-line-mode 1)))
(📦 org-auto-tangle :hook org-mode)
(📦 olivetti
  :diminish
  :hook org-mode)
;; (add-hook 'org-mode-hook (lambda () (org-update-all-dblocks)))
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
;; (global-set-key (kbd "C-c e") 'org-babel-execute-src-block)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "ESC m") #'menu-bar-open)
(put 'narrow-to-region 'disabled nil)
;;; Org Agenda files

(if (string-equal system-type "windows-nt")
    (progn (message "Windows")
           (setq org-agenda-files
                 (directory-files-recursively "c:/my_repos" ".*agenda.*\.org$\\|.*agenda.*\.org_archive$")))
  (progn (message "Unix")
         (setq org-agenda-files '("~/.agenda_files"))
         (when (file-exists-p "~/my_repos")
           (setq org-agenda-text-search-extra-files
                 (directory-files-recursively "~/my_repos" ".*\.org$\\|.*\.org_archive$")))))
;; (org-id-update-id-locations)
;;; Org super agenda
(setq spacemacs-theme-org-agenda-height nil
      org-agenda-time-grid '((daily today require-timed) "----------------------" nil)
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-include-diary t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-with-log-mode t)
(setq org-agenda-custom-commands
      '(("z" "Super zaen view"
         ((agenda "" ((org-agenda-span 'day)
                      (org-super-agenda-groups
                       '((:name "Today"
                                :time-grid t
                                :date today
                                :todo "TODAY"
                                :scheduled today
                                :order 1)))))
          (alltodo "" ((org-agenda-overriding-header "")
                       (org-super-agenda-groups
                        '((:name "Next to do"
                                 :todo "NEXT"
                                 :order 1)
                          (:name "Important"
                                 :tag "Important"
                                 :priority "A"
                                 :order 6)
                          (:name "Due Today"
                                 :deadline today
                                 :order 2)
                          (:name "Due Soon"
                                 :deadline future
                                 :order 8)
                          (:name "Overdue"
                                 :deadline past
                                 :order 7)
                          (:name "Assignments"
                                 :tag "Assignment"
                                 :order 10)
                          (:name "Issues"
                                 :tag "Issue"
                                 :order 12)
                          (:name "Projects"
                                 :tag "Project"
                                 :order 14)
                          (:name "Emacs"
                                 :tag "Emacs"
                                 :order 13)
                          (:name "Research"
                                 :tag "Research"
                                 :order 15)
                          (:name "To read"
                                 :tag "Read"
                                 :order 30)
                          (:name "Waiting"
                                 :todo "WAITING"
                                 :order 20)
                          (:name "trivial"
                                 :priority<= "C"
                                 :tag ("Trivial" "Unimportant")
                                 :todo ("SOMEDAY" )
                                 :order 90)
                          (:discard (:tag ("Chore" "Routine" "Daily")))))))))))
(defun insert-date ()
  (interactive)
  (insert
   (replace-regexp-in-string " \\w\\w\\w" ""
                             (string-replace ">" ""
                                             (string-replace "<" ""
                                                             (org-time-stamp nil nil)
                                                             )
                                             )
                             )
   )
  )

(defun create-a-blog-entry ()
  (interactive)
  (print "Starting file creation...")
  (find-file (read-file-name "Enter file Name:" "~/my_repos/raveenkumar.xyz/Blog/blog"))

  (save-excursion
    (insert
     "#+include: ../css/html-options-level-2.org
#+title: REPLACE_TITLE
#+filetags: REPLACE_TAG
"))

  (save-excursion
    (while (re-search-forward "REPLACE_TITLE" nil t)
      (replace-match (read-string "Enter title: "))))

  (save-excursion
    (while (re-search-forward "REPLACE_TAG" nil t)
      (replace-match (read-string "Enter title: "))))

  )

(defun org-drill-entry-empty-p () nil) ;; TODO why is this here?

;;; Spellchecker
;; https://www.tenderisthebyte.com/blog/2019/06/09/spell-checking-emacs/
(cond
 ((string-equal system-type "windows-nt")
  (progn
    (message "Microsoft Windows")))

 ((string-equal system-type "darwin") ;  macOS
  (progn
    (message "Mac OS X")
    (dolist (hook '(text-mode-hook))
      (add-hook hook (lambda () (flyspell-mode 1))))
    (eval-after-load "flyspell"
      '(progn
         (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
         (define-key flyspell-mouse-map [mouse-3] #'undefined)))))

 ((string-equal system-type "gnu/linux")
  (progn
    (message "Linux")
    (dolist (hook '(text-mode-hook))
      (add-hook hook (lambda () (flyspell-mode 1))))
    (eval-after-load "flyspell"
      '(progn
         (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
         (define-key flyspell-mouse-map [mouse-3] #'undefined)))

    )))
;;; Hippie expand
;; https://www.masteringemacs.org/article/text-expansion-hippie-expand
(global-set-key [remap dabbrev-expand] 'hippie-expand)
;;; Outline minor mode
(setq outline-blank-line +1)
(global-set-key (kbd "C-c m") 'menu-bar-open)

;; (📦 sh-script :hook (outline-minor-mode)) ; TODO
(📦 projectile
  :diminish
  :config (projectile-mode +1)
  :bind (:map projectile-mode-map ("C-c p" . projectile-command-map)))
(📦 indent-guide
  :diminish
  :config (indent-guide-global-mode 1))
(📦 smartparens
  :diminish
  :config (smartparens-global-mode +1))
;; (📦 flex-autopair :config (flex-autopair-mode 1))
(📦 flycheck
  :diminish
  :hook sh-mode)
(📦 flymake-shellcheck
  :diminish
  :hook sh-mode)
;; (📦 evil
;;   :bind
;;   (:map evil-insert-state-map ("C-x C-l" . my-expand-lines))
;;   (("<escape>" . keyboard-escape-quit))
;;   :hook
;;   (eshell-mode . turn-off-evil-mode)
;;   :config
;;   (evil-mode 1)
;;   ;; (global-evil-surround-mode 1)
;;   ;; (evil-goggles-mode 1)
;;   ;; (evil-vimish-fold-mode 1)
;;   (global-evil-leader-mode 1)
;;   (global-set-key (kbd "C-c <C-left>") 'evil-window-left)
;;   (global-set-key (kbd "C-c <C-right>") 'evil-window-right)
;;   (global-set-key (kbd "C-c <C-up>") 'evil-window-up)
;;   (global-set-key (kbd "C-c <C-down>") 'evil-window-down)
;;   (📦 evil-leader
;;     :config
;; 	(evil-leader/set-leader "<SPC>")
;; 	(evil-leader/set-key
;; 	 "y" 'copy-whole-buffer
;; 	 "=" 'my-indent-whole-buffer
;; 	 "b" 'switch-to-buffer
;; 	 "fr" 'counsel-recentf
;; 	 "ff" 'counsel-find-file
;; 	 "\t" 'org-cycle
;; 	 "r" 'restart-emacs
;; 	 "pl" 'package-list-packages
;; 	 "pi" 'my-package-refresh-and-install-selected-packages
;; 	 "h" 'help
;; 	 "d" 'dired
;; 	 "w" 'my-indent-whole-buffer-and-save
;; 	 "q" 'save-buffers-kill-terminal
;; 	 "i" 'my-find-init-file
;; 	 "+" 'text-scale-increase
;; 	 "-" 'text-scale-decrease
;; 	 "x" 'execute-extended-command
;; 	 "." 'embark-act
;; 	 ";" 'embark-dwim
;; 	 "B" 'embark-bindings
;; 	 "s" 'swiper
;; 	 "lr" 'ledger-report
;; 	 "a" 'mark-whole-buffer
;; 	 "pp" 'evil-paste-after-newline
;; 	 "c" 'recompile
;; 	 "y" 'copy-whole-buffer
;; 	 ))
;;   (📦 evil-numbers
;;     :config
;;   (evil-define-key '(normal visual) 'global (kbd "C-a") 'evil-numbers/inc-at-pt)
;;   (evil-define-key '(normal visual) 'global (kbd "C-x") 'evil-numbers/dec-at-pt)
;;   (evil-define-key '(normal visual) 'global (kbd "g C-a") 'evil-numbers/inc-at-pt-incremental)
;;   (evil-define-key '(normal visual) 'global (kbd "g C-x") 'evil-numbers/dec-at-pt-incremental))
;;   (📦 evil-snipe
;;     :config
;;     (evil-snipe-mode 1)
;;     (evil-snipe-override-mode 1))
;;   (📦 evil-mc :config (evil-mc-mode 1))
;;   (add-hook 'xref--xref-buffer-mode-hook 'turn-off-evil-mode)
;;   (📦 evil-escape
;;   :config
;;   (evil-escape-mode t)
;;   (setq-default evil-escape-key-sequence "eee"))
;;   )


;;; UNDO
;; Vim style undo not needed for emacs 28
(use-package undo-fu)

;;; Vim Bindings
(use-package evil
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


;;; Vim Bindings Everywhere else
(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))


;;; Maximize frame after starting emacsclient
(add-hook 'server-after-make-frame-hook 'toggle-frame-maximized)
(defun evil-paste-after-newline ()
  (interactive)
  (progn
    (evil-insert-newline-below)
    (evil-paste-after 1)
    ))

(defun copy-whole-buffer ()
  "This function will copy the whole buffer..."
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (kill-ring-save nil nil t))
  )

(global-set-key (kbd "C-c C-l") 'my-expand-lines)
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)



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
(📦 yasnippet
  :diminish
  :config
  (yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.
  (setq yas-snippet-dirs
        '("~/.emacs.d/snippets/"                 ;; personal snippets
          "c:/my_repos/dotfiles-main/stow/.emacs.d/snippets"           ;; foo-mode and bar-mode snippet collection
          ))
  (📦 yasnippet-snippets
    :diminish))

;; (add-hook 'emacs-lisp-mode-hook (outline-minor-mode 1))
;; (add-hook 'outline-minor-mode-hook
;;           (lambda ()
;;            (define-key (kbd "TAB") 'outline-toggle-children)))


;;; https://github.com/tarsius/bicycle
(use-package bicycle
  :diminish
  :disabled t
  :after outline
  :bind (:map outline-minor-mode-map
		      ([C-tab] . bicycle-cycle)
		      ([S-tab] . bicycle-cycle-global)))

;; (use-package prog
;;   :config
;;   (add-hook 'prog-mode-hook 'outline-minor-mode)
;;   (add-hook 'prog-mode-hook 'hs-minor-mode))

;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Foldout.html

(with-eval-after-load "outline"
  (require 'foldout))






;;; Testing
;;; Disabled
;; (toggle-truncate-lines 1)
;; Sr Speedbar
;; (require 'sr-speedbar)
;; (defun my-org-daily-notes-file ()
;;   (interactive)
;;   (format "%d-%02d-%d.org" (calendar-extract-year (calendar-current-date))
;;           (calendar-extract-month (calendar-current-date))
;;           (calendar-extract-day (calendar-current-date))))
;; (defun my-open-org-daily-notes-file ()
;;   (interactive)
;;   (find-file (format "./%s" (my-org-daily-notes-file))))
;; (require 'minimal-session-saver)
;; (minimal-session-saver-install-aliases)
;; Helm
;; (helm-mode 1)
;; (toggle-frame-fullscreen)
;; (setq left-margin-width 20)
;; (setq left-fringe-width 20)
;; #TODO (highlight-phrase #TODO dired-broken-symlink)
;; (require 'ob-tcl)
;; (global-set-key [wheel-right] 'scroll-left)
;; (global-set-key [wheel-left] 'scroll-right)
;; (put 'scroll-left 'disabled nil)



;; TODO make neotree open on startup
(up neotree
  :diminish
  :bind ("C-c d" . neotree-toggle)
  )

(global-auto-revert-mode t)
(defalias 'yes-or-no-p 'y-or-n-p)

(use-package dashboard
  :diminish
  ;; https://github.com/emacs-dashboard/emacs-dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  ;; (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  ;; Set the title
  ;; (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  ;; Set the banner
  ;; (setq dashboard-startup-banner nil)
  ;; Value can be
  ;; - nil to display no banner
  ;; - 'official which displays the official emacs logo
  ;; - 'logo which displays an alternative emacs logo
  ;; - 1, 2 or 3 which displays one of the text banners
  ;; - "path/to/your/image.gif", "path/to/your/image.png" or "path/to/your/text.txt" which displays whatever gif/image/text you would prefer
  ;; - a cons of '("path/to/your/image.png" . "path/to/your/text.txt")

  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)

  ;; To disable shortcut "jump" indicators for each section, set
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5)
                          (registers . 5)))


  ;; https://github.com/emacs-dashboard/emacs-dashboard/issues/184
  ;; TODO This solution did not work
  ;; (if (display-graphic-p)
  ;;     (define-key dashboard-mode-map [down-mouse-1] 'widget-button-click)
  ;;   (define-key dashboard-mode-map [down-mouse-1] nil))
  ;; (define-key dashboard-mode-map [mouse-1] 'widget-button-click)
  ;; (define-key dashboard-mode-map [down-mouse-1] 'widget-button-press)

  )

(up hyperbole
  :diminish
  :config (hyperbole-mode 1))
(up zoom
  :diminish
  ;; https://github.com/cyrus-and/zoom
  :config (zoom-mode t))
(up solaire-mode
  :diminish
  ;; https://github.com/hlissner/emacs-solaire-mode
  :config
  (solaire-global-mode +1)
  )

(use-package doom-themes
  :diminish
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-gruvbox t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))


;; https://github.com/emacs-tw/awesome-emacs

;; (up multifiles)
(use-package all-the-icons
  :if (display-graphic-p))
(up focus
  :diminish
  :hook emacs-lisp-mode
  )

(up drag-stuff
  :diminish
  ;; https://github.com/rejeep/drag-stuff.el
  :config
  (drag-stuff-global-mode +1)
  (drag-stuff-define-keys)
  )


(use-package fzf
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

(use-package spu
  :disabled t
  ;; https://github.com/mola-T/SPU
  ;; Silent Package updater
  :defer 5 ;; defer package loading for 5 second
  :config (spu-package-upgrade-daily))


(use-package esup
  :disabled t
  ;; Emacs startup profiler
  ;; https://github.com/jschaf/esup
  :ensure t
  ;; To use MELPA Stable use ":pin melpa-stable",
  :pin melpa-stable)

(up nyan-mode
  ;; Nyan mode
  ;; https://github.com/TeMPOraL/nyan-mode
  :config
  (nyan-mode)
  )

(up sr-speedbar)

(up selectric-mode
  :disabled t
  ;; https://github.com/rbanffy/selectric-mode
  :config
  (selectric-mode +1)
  )

;; TODO https://github.com/jtmoulia/elisp-koans

(up keycast
  :disabled t
  ;; https://github.com/tarsius/keycast
  :config
  (keycast-mode)
  ;; The code below is not working
  ;;  (keycast-mode-line-mode +1)
  )

(up restart-emacs)
(up diminish)
(up format-all
  :diminish
  ;; https://github.com/lassik/emacs-format-all-the-code/tree/c156ffe5f3c979ab89fd941658e840801078d091
  :hook
  (add-hook 'prog-mode-hook 'format-all-mode)
  )
(up apheleia
  :disabled t
  ;; https://github.com/radian-software/apheleia
  :config
  (apheleia-global-mode +1)
  )
