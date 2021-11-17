(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode t)
 '(custom-enabled-themes '(wombat))
 '(package-selected-packages
   '(multiple-cursors mark-multiple elfeed-org elfeed evil expand-region org-superstar magit))
 '(show-paren-mode t)
 '(tab-width 4))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq visible-bell 1)
(recentf-mode)
(setq dired-kill-when-opening-new-dired-buffer t)

;; Better copy and cut
(defadvice kill-ring-save (before slick-copy activate compile) "When called
  interactively with no active region, copy a single line instead."
           (interactive (if mark-active (list (region-beginning) (region-end)) (message
	                                "Copied line") (list (line-beginning-position) (line-beginning-position
		                                2)))))
(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;; Org mode
(setq org-src-tab-acts-natively t)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(org-babel-do-load-languages 'org-babel-load-languages 
                             '(
                               (shell . t)
                               )
                             )
(global-set-key (kbd "C-c e") 'org-babel-execute-src-block)
(setq org-confirm-babel-evaluate nil)
;; (org-num-mode)

;; Interface
(global-set-key (kbd "ESC m") #'menu-bar-open)
(put 'narrow-to-region 'disabled nil)
(recentf-mode 1)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(when (require 'beacon nil 'noerror)
  (beacon-mode 1))

(add-hook 'find-file-hook
          (lambda ()
            (when (string= (file-name-extension buffer-file-name) "org")
              (org-indent-mode +1))))

;; Magit
(when (require 'magit nil 'noerror)
  (global-set-key (kbd "C-x g") 'magit-status))

(set-face-attribute 'default nil :height 100)

;; IDO Mode
(ido-mode 1)

;; (org-superstar-mode 1)

(when (require 'expand-region nil 'noerror)
  (global-set-key (kbd "C-=") 'er/expand-region))

;; (require 'evil)
;; (evil-mode 1)
;; (global-evil-surround-mode 1)
;; 
;; ;; this macro was copied from here: https://stackoverflow.com/a/22418983/4921402
;; (defmacro define-and-bind-quoted-text-object (name key start-regex end-regex)
;;   (let ((inner-name (make-symbol (concat "evil-inner-" name)))
;;         (outer-name (make-symbol (concat "evil-a-" name))))
;;     `(progn
;;        (evil-define-text-object ,inner-name (count &optional beg end type)
;;          (evil-select-paren ,start-regex ,end-regex beg end type count nil))
;;        (evil-define-text-object ,outer-name (count &optional beg end type)
;;          (evil-select-paren ,start-regex ,end-regex beg end type count t))
;;        (define-key evil-inner-text-objects-map ,key #',inner-name)
;;        (define-key evil-outer-text-objects-map ,key #',outer-name))))
;; 
;; 
;; (define-and-bind-quoted-text-object "tilde" "~" "~" "~")

;; Also, hiding leading stars with ~(setq org-superstar-special-todo-items 'hide)~ looks great but breaks after switching org-mode buffers once.

(tab-bar-mode 1)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)

;; This will set first buffer shown as scratch
;; (setq initial-buffer-choice t)

;; https://stackoverflow.com/questions/1817257/how-to-determine-operating-system-in-elisp
(defmacro with-system (type &rest body)
  "Evaluate BODY if `system-type' equals TYPE."
  (declare (indent defun))
  `(when (eq system-type ',type)
     ,@body))

(with-system gnu/linux
  ;; This will add this file to buffer list when opening emacs
  (find-file "~/repos/raveenkumar.xyz/src/index.org")
  (find-file "/home/raveensrk/repos/jorunal-personal/src/index.org")
  (find-file "/home/raveensrk/repos/.emacs/emacs/.emacs")
  )

(with-system windows-nt
  (find-file "c:/Github/raveenkumar.xyz/src/index.org")
  (find-file "c:/Github/journal-work/src/index.org")
  (find-file "c:/Github/.emacs/emacs/.emacs")
  )


;; https://stackoverflow.com/questions/6515009/how-to-configure-emacs-to-have-it-complete-the-path-automatically-like-vim#6556788

(when (require 'multiple-cursors nil 'noerror)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))


;; set default tab char's display width to 4 spaces
(setq-default tab-width 4) ; emacs 23.1 to 26 default to 8

;; set current buffer's tab char's display width to 4 spaces
(setq tab-width 4)


(progn
  ;; make indent commands use space only (never tab character)
  (setq-default indent-tabs-mode nil)
  ;; emacs 23.1 to 26, default to t
  ;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
  )
