(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode t)
 '(custom-enabled-themes '(wombat))
 '(package-selected-packages
   '(folding multiple-cursors mark-multiple elfeed-org elfeed evil expand-region org-superstar magit))
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

(setq org-src-tab-acts-natively t)
;; (fset 'transform-to-src-block
;;      (kmacro-lambda-form [?\C-x ?\C-x ?\C-o ?# ?+ ?B ?E ?G ?I ?N ?_ ?S ?R ?C ?  ?b ?a ?s ?h ?\C-x ?\C-x return ?# ?+ ?E ?N ?D ?_ ?S ?R ?C] 0 "%d"))

;; (fset 'transform-md-code-block-to-org-src-block
;;       (kmacro-lambda-form [?\C-s ?` ?` ?` return home ?\C-k ?# ?! backspace ?+ ?B ?E ?G ?I ?N ?_ ?S ?R ?C ?  ?b ?a ?s ?h home ?\C-s ?` ?` ?` return home ?\C-k ?# ?+ ?E ?N ?D ?_ ?S ?R ?C home down] 0 "%d"))

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(global-set-key (kbd "ESC m") #'menu-bar-open)




(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; (and
;;  (require 'centered-cursor-mode)
;;  (global-centered-cursor-mode +1))

(require 'beacon)
(beacon-mode 1)

(add-hook 'find-file-hook
          (lambda ()
            (when (string= (file-name-extension buffer-file-name) "org")
              (org-indent-mode +1))))

(setq org-src-tab-acts-natively t)
(put 'narrow-to-region 'disabled nil)
(recentf-mode 1)

(org-babel-do-load-languages 'org-babel-load-languages
                             '(
                               (shell . t)
                               )
                             )

(setq org-confirm-babel-evaluate nil)
;; (org-num-mode)

(fset 'macro-org-rename-filename-to-links
      (kmacro-lambda-form [home ?\M-x up return M-left C-right C-left ?\[ ?\[ ?f ?i ?l ?e ?: end ?\C-r ?. ?\C-  ?\C-r ?: right ?\M-w end ?\] ?\[ ?\C-y ?\] ?\] home down] 0 "%d"))

;; check

(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

(global-set-key (kbd "C-c e") 'org-babel-execute-src-block)

(set-face-attribute 'default nil :height 200)
;; IDO Mode
;; (ido-mode 1)
(org-superstar-mode 1)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

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


(defun my/get-links-to-current-heading ()
  (interactive)
  (let ((title (nth 4 (org-heading-components))))
    (occur (concat "\\[\\[" title "\\]\\["))))

(global-set-key (kbd "C-x w") 'elfeed)

;; Load elfeed-org
;; (require 'elfeed-org)

;; Initialize elfeed-org
;; This hooks up elfeed-org to read the configuration when elfeed
;; is started with =M-x elfeed=
;; (elfeed-org 1)

;; Optionally specify a number of files containing elfeed
;; configuration. If not set then the location below is used.
;; Note: The customize interface is also supported.
;; (setq rmh-elfeed-org-files (list "~/repos/personal/src/elfeed.org"))
(tab-bar-mode 1)
(savehist-mode 1)
(mouse-avoidance-mode 'cat-and-mouse)

;; This will set first buffer shown as scratch
(setq initial-buffer-choice t)

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
  (find-file "~/.emacs")
  )

(with-system windows-nt
  (find-file "c:/Github/raveenkumar.xyz/src/index.org")
  (find-file "c:/Github/journal-work/src/index.org")
  (find-file "c:/Github/.emacs/emacs/.emacs")
  )


;; https://stackoverflow.com/questions/6515009/how-to-configure-emacs-to-have-it-complete-the-path-automatically-like-vim#6556788

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)


;; (add-to-list 'load-path "~/.emacs.d/vendor")
;; (require 'guru-mode)

(if (require 'folding nil 'noerror)
    (folding-mode-add-find-file-hook)
  (message "Library `folding' not found"))

(folding-add-to-marks-list 'shell-script-mode "# {{{" "# }}}" nil t)
(setq backup-directory-alist       `((".*" . , "~/.dotfiles/.config/emacs/auto-backups")))
