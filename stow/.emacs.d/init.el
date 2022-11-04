;;; Raveen's Emacs init

;; (toggle-debug-on-error)

;; (setq default-directory "C:/")

(if (string-equal system-type "windows-nt")
    (progn
      (setq custom-file "c:/github/dotfiles-main/stow/.emacs.d/custom.el")
      (add-to-list 'load-path "c:/github/dotfiles-main/stow/.emacs.d/site-lisp"))
  (progn
    (setq custom-file "~/.emacs.d/custom.el")
    (add-to-list 'load-path "~/.emacs.d/site-lisp")))

(load custom-file)

;;; Source after loading


;;; Appearence

;; (toggle-truncate-lines 1)

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

;;; Package Specific
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") the)
(defun my-package-refresh-and-install-selected-packages ()
  (interactive)
  (package-refresh-contents)
  (package-install-selected-packages t)
  (package-autoremove)
  )

;;; Dynamic Fonts
;; (require 'dynamic-fonts)
;; (dynamic-fonts-setup)     ; finds "best" fonts and sets faces:
;;                                         ; default, fixed-pitch, variable-pitch


;;;; Sr Speedbar
(require 'sr-speedbar)

;;;; Magit
(when (require 'magit nil 'noerror)
  (global-set-key (kbd "C-x g") 'magit-status))

;;;; Expand Region
(when (require 'expand-region nil 'noerror)
  (global-set-key (kbd "C-=") 'er/expand-region))

(defun my-indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun my-find-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun my-org-daily-notes-file ()
  (interactive)
  (format "%d-%02d-%d.org" (calendar-extract-year (calendar-current-date))
          (calendar-extract-month (calendar-current-date))
          (calendar-extract-day (calendar-current-date))))
(defun my-open-org-daily-notes-file ()
  (interactive)
  (find-file (format "./%s" (my-org-daily-notes-file))))

;; TODO: create heaing automatically after i enter todays org file
;; (format "* %s" (org-date-from-calendar))


;;;; Enabling packages
(when (require 'beacon nil 'noerror)
  (beacon-mode 1))

(global-company-mode 1)  
(require 'minimal-session-saver)
(minimal-session-saver-install-aliases)
(when (require 'multiple-cursors nil 'noerror)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))
(marginalia-mode 1)
(which-key-mode 1)
(when (package-installed-p 'rainbow-delimiters)
  (require 'rainbow-delimiters)
  (rainbow-delimiters-mode 1))
(when (package-installed-p 'avy)
  (require 'avy)
  (global-set-key (kbd "C-:") 'avy-goto-char))

;;;; Embark
(global-set-key (kbd "C-.") 'embark-act)
(global-set-key (kbd "C-;") 'embark-dwim)
(global-set-key (kbd "C-h B") 'embark-bindings)
;; Optionally replace the key help with a completing-read interface
(setq prefix-help-command #'embark-prefix-help-command)

;; Hide the mode line of the Embark live/completions buffers
(add-to-list 'display-buffer-alist
             '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
               nil
               (window-parameters (mode-line-format . none))))


;;;; IVY 
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(setq ivy-count-format "(%d/%d) ")
;; enable this if you want `swiper' to use it
;; (setq search-default-mode #'char-fold-to-regexp)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c F") 'counsel-org-file)
(global-set-key (kbd "C-c J") 'counsel-file-jump)
(global-set-key (kbd "C-c L") 'counsel-git-log)
(global-set-key (kbd "C-c V") 'ivy-pop-view)
(global-set-key (kbd "C-c b") 'counsel-bookmark)
(global-set-key (kbd "C-c c") 'counsel-compile)
(global-set-key (kbd "C-c d") 'counsel-descbinds)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-rg)
(global-set-key (kbd "C-c m") 'counsel-linux-app)
(global-set-key (kbd "C-c o") 'counsel-outline)
(global-set-key (kbd "C-c t") 'counsel-load-theme)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c w") 'counsel-wmctrl)
(global-set-key (kbd "C-c z") 'counsel-fzf)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "M-x") 'counsel-M-x)

;;;; Helm
;; (helm-mode 1)

;;; Startup and behaviour
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq visible-bell 1)
(tab-bar-mode 1)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)
;; This will set first buffer shown as scratch
;; (setq initial-buffer-choice t)

;;;; Mouse Support in Terminal
;; https://emacsredux.com/blog/2022/06/03/enable-mouse-support-in-terminal-emacs/
;; For linux use (gpm-mouse-mode 1)
(unless (display-graphic-p)
  (xterm-mouse-mode 1))


;;; Editing
(setq-default tab-width 4)
(setq tab-width 4)
(progn
  ;; make indent commands use space only (never tab character)
  (setq-default indent-tabs-mode nil)
  ;; emacs 23.1 to 26, default to t
  ;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
  )



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
;; (setq org-startup-folded t)
;; (add-hook 'org-mode-hook (lambda () (visual-line-mode 1)))
;; (add-hook 'org-mode-hook (lambda () (olivetti-mode)))


;; (add-hook 'org-mode-hook (lambda () (org-update-all-dblocks)))
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c e") 'org-babel-execute-src-block)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "ESC m") #'menu-bar-open)
(add-hook 'org-mode-hook
          (lambda ()
            (define-key org-mode-map (kbd "C-c n") 'org-toggle-narrow-to-subtree)
            (define-key org-mode-map (kbd "<tab>") 'org-cycle)
            ))
(put 'narrow-to-region 'disabled nil)


;;; Templates and Macros https://stackoverflow.com/questions/1817257/how-to-determine-operating-system-in-elisp
(defmacro with-system (type &rest body)
  "Evaluate BODY if `system-type' equals TYPE."
  (declare (indent defun))
  `(when (eq system-type ',type)
     ,@body))

(setq org-agenda-archives-mode t)
(setq org-confirm-babel-evaluate nil)
(setq org-src-tab-acts-natively t)
;; (org-num-mode)
;;;; PHP org babel
(require 'ob-php)

;; TODO: IMENU hook not working properly
;; (dolist (hook '(org-mode-hook))
;;   (add-hook hook (lambda () (imenu 1)))
;;   (add-hook hook (lambda () (imenu-add-menubar-index 1)))
;;   (add-hook hook (lambda () (setq imenu-auto-rescan 1)))
;;   )

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

;;; Modes
(add-to-list 'auto-mode-alist '("\\.bash_aliases$" . shell-script-mode))
(setq-default abbrev-mode 1)
(winner-mode 1)
(recentf-mode 1)
(setq recentf-max-menu-items 200)
(setq recentf-max-saved-items 200)
(save-place-mode 1)

;;; Hippie expand

;; https://www.masteringemacs.org/article/text-expansion-hippie-expand

(global-set-key [remap dabbrev-expand] 'hippie-expand)

;;; Outline minor mode

(setq outline-blank-line +1)
;; (global-set-key (kbd "<tab>") 'outline-toggle-children)

;; This is very interesting you can enable outline minor mode and it
;; can recogonize heading level. Based on the comments documentation.
;; ;; This is a left indented comment
;; ;;; This is a heading
;; ;;;; This is also a heading nested

;;;; Heading 1
;;;;; Heading 2
;; something
;;;;;; Heading 3
;; something

;;; General
(setq vc-follow-symlinks t)
(global-set-key (kbd "C-c m") 'menu-bar-open)

;;; Elisp
;; (dolist (hook '(emacs-lisp-mode-hook))
;;  (add-hook hook (lambda () (outline-minor-mode 1))))

;;; Shell-script-mode
(add-hook 'shell-script-mode-hook (lambda () (outline-minor-mode 1)))





;;; Notes

;;;; While Loop

;; (setq animals '(gazelle giraffe lion tiger))
;; 
;; (defun print-elements-of-list (list)
;;   "Print each element of LIST on a line of its own."
;;   (while list
;;     (print (car list))
;;     (setq list (cdr list))))
;; 
;; (print-elements-of-list animals)


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; (toggle-frame-fullscreen)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)



;;; Open file in external application

(defun xah-open-in-external-app (&optional @fname)
  "Open the current file or dired marked files in external app.
When called in emacs lisp, if @fname is given, open that.
URL `http://xahlee.info/emacs/emacs/emacs_dired_open_file_in_ext_apps.html'
Version 2019-11-04 2021-02-16"
  (interactive)
  (let* (
         ($file-list
          (if @fname
              (progn (list @fname))
            (if (string-equal major-mode "dired-mode")
                (dired-get-marked-files)
              (list (buffer-file-name)))))
         ($do-it-p (if (<= (length $file-list) 5)
                       t
                     (y-or-n-p "Open more than 5 files? "))))
    (when $do-it-p
      (cond
       ((string-equal system-type "windows-nt")
        (mapc
         (lambda ($fpath)
           (shell-command (concat "PowerShell -Command \"Invoke-Item -LiteralPath\" " "'" (shell-quote-argument (expand-file-name $fpath )) "'")))
         $file-list))
       ((string-equal system-type "darwin")
        (mapc
         (lambda ($fpath)
           (shell-command
            (concat "open " (shell-quote-argument $fpath))))  $file-list))
       ((string-equal system-type "gnu/linux")
        (mapc
         (lambda ($fpath) (let ((process-connection-type nil))
                            (start-process "" nil "xdg-open" $fpath))) $file-list))))))


;; (setq left-margin-width 20)
;; (setq left-fringe-width 20)


;;; Indent Guide
(indent-guide-global-mode 1)

;; (smartparens-global-mode +1)
;; (show-smartparens-global-mode +1)

(require 'flex-autopair)
(flex-autopair-mode 1)

;; #TODO (highlight-phrase #TODO dired-broken-symlink)

;;; Shellcheck
(add-hook 'sh-mode-hook 'flymake-shellcheck-load)
;;; set up babel support
(require 'org)
(require 'ob-tcl)
;; add additional languages with (require 'ob-language)
;; (global-set-key [wheel-right] 'scroll-left)
;; (global-set-key [wheel-left] 'scroll-right)
;; (put 'scroll-left 'disabled nil)

;;; Org Agenda files


(if (string-equal system-type "windows-nt")
    (progn (message "Windows")
           (setq org-agenda-files
                 (directory-files-recursively "c:/github" ".*agenda.*\.org$\\|.*agenda.*\.org_archive$")))
  (progn (message "Unix")
         (setq org-agenda-files '("~/.agenda_files"))
         (when (file-exists-p "~/my_repos")
           (setq org-agenda-text-search-extra-files
                 (directory-files-recursively "~/my_repos" ".*\.org$\\|.*\.org_archive$")))))

(org-id-update-id-locations)



;;; Eshell 
(add-hook 'sh-mode-hook 'flycheck-mode)
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



(defun org-drill-entry-empty-p () nil)

(global-set-key (kbd "C-c t") 'toggle-truncate-lines)
(global-set-key (kbd "C-c n") 'tmm-menubar)
(toggle-frame-maximized)

;;; Maximize frame after starting emacsclient
(add-hook 'server-after-make-frame-hook 'toggle-frame-maximized)


(defun my-expand-lines ()
  (interactive)
  (let ((hippie-expand-try-functions-list
         '(try-expand-line)))
    (call-interactively 'hippie-expand)))

;;; Evil mode stuff

;; (define-key evil-insert-state-map (kbd "C-x C-l") 'my-expand-lines)
;; (when (package-installed-p 'evil)
;;   (require 'evil)
;;   (evil-mode 1)
;;   ;; (evil-goggles-mode 1)
;;   ;; (evil-vimish-fold-mode 1)
;;   (global-evil-leader-mode 1)
;;   (evil-leader/set-leader "<SPC>")
;;   )
;; 
;; (add-hook 'eshell-mode-hook (lambda () (turn-off-evil-mode)))
;; 
;; ;; (require 'evil)
;; ;; (evil-mode 1)
;; ;; (global-evil-surround-mode 1)
;; ;; 
;; ;; ;; this macro was copied from here: https://stackoverflow.com/a/22418983/4921402
;; ;; (defmacro define-and-bind-quoted-text-object (name key start-regex end-regex)
;; ;;   (let ((inner-name (make-symbol (concat "evil-inner-" name)))
;; ;;         (outer-name (make-symbol (concat "evil-a-" name))))
;; ;;     `(progn
;; ;;        (evil-define-text-object ,inner-name (count &optional beg end type)
;; ;;          (evil-select-paren ,start-regex ,end-regex beg end type count nil))
;; ;;        (evil-define-text-object ,outer-name (count &optional beg end type)
;; ;;          (evil-select-paren ,start-regex ,end-regex beg end type count t))
;; ;;        (define-key evil-inner-text-objects-map ,key #',inner-name)
;; ;;        (define-key evil-outer-text-objects-map ,key #',outer-name))))
;; ;; 
;; ;; 
;; ;; (define-and-bind-quoted-text-object "tilde" "~" "~" "~")
;; 
;; ;; Also, hiding leading stars with ~(setq org-superstar-special-todo-items 'hide)~ looks great but breaks after switching org-mode buffers once.
;; (defun evil-paste-after-newline ()
;;   (interactive)
;;   (progn
;;     (evil-insert-newline-below)
;;     (evil-paste-after 1)
;;     ))
;; 
;; (global-set-key (kbd "C-c <C-left>") 'evil-window-left)
;; (global-set-key (kbd "C-c <C-right>") 'evil-window-right)
;; (global-set-key (kbd "C-c <C-up>") 'evil-window-up)
;; (global-set-key (kbd "C-c <C-down>") 'evil-window-down)
;; 
;; (evil-leader/set-key
;;   "=" 'my-indent-whole-buffer
;;   "b" 'switch-to-buffer
;;   "fr" 'counsel-recentf
;;   "ff" 'counsel-find-file
;;   "e" 'eval-buffer
;;   "\t" 'org-cycle
;;   "r" 'restart-emacs
;;   "pl" 'package-list-packages
;;   "pi" 'my-package-refresh-and-install-selected-packages
;;   "h" 'help
;;   "d" 'dired
;;   "w" 'save-buffer
;;   "q" 'save-buffers-kill-terminal
;;   "i" 'my-find-init-file
;;   "+" 'text-scale-increase
;;   "-" 'text-scale-decrease
;;   "x" 'execute-extended-command
;;   "." 'embark-act
;;   ";" 'embark-dwim
;;   "B" 'embark-bindings
;;   "s" 'swiper
;;   "lr" 'ledger-report
;;   "a" 'mark-whole-buffer
;;   "pp" 'evil-paste-after-newline
;;   "c" 'recompile
;;   )
;; (evil-define-key '(normal visual) 'global (kbd "C-a")
;;   'evil-numbers/inc-at-pt)
;; (evil-define-key '(normal visual) 'global (kbd "C-x")
;;   'evil-numbers/dec-at-pt)
;; (evil-define-key '(normal visual) 'global (kbd "g C-a")
;;   'evil-numbers/inc-at-pt-incremental)
;; (evil-define-key '(normal visual) 'global (kbd "g C-x")
;;   'evil-numbers/dec-at-pt-incremental)
;; (evil-snipe-mode 1)
;; (evil-snipe-override-mode 1)
;; (evil-mc-mode 1)


(global-set-key (kbd "C-c C-l") 'my-expand-lines)
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)
(global-set-key (kbd "C-c fr") 'counsel-recentf)
(global-set-key (kbd "C-c i") 'my-find-init-file)
(global-set-key (kbd "C-c .") 'embark-act)
(global-set-key (kbd "C-c ;") 'embark-dwim)


;;; Load all elisp files under ~/.emacs.d/site-lisp

(if (string-equal system-type "windows-nt")
    (setq my-lisp-files (directory-files-recursively "c:/github/dotfiles-main/stow/.emacs.d/site-lisp/" ""))
  (setq my-lisp-files (directory-files-recursively "~/.emacs.d/site-lisp/" "")))

(defun my-load-elisp-files (list)
  "Print each element of LIST on a line of its own."
  (while list
    (print (car list))
    (load-file (print (car list)))
    (setq list (cdr list))))

(my-load-elisp-files my-lisp-files)



(setq yas-snippet-dirs
      '("~/.emacs.d/snippets/"                 ;; personal snippets
        "c:/github/dotfiles-main/stow/.emacs.d/snippets"           ;; foo-mode and bar-mode snippet collection
        ))

(yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.


