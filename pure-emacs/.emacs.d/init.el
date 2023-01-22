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
(add-hook 'prog-mode-hook (lambda () (define-key prog-mode-map (kbd "ESC ESC c") 'comment-line)))
(setq-default tab-width 4)
(setq tab-width 4)
;; make indent commands use space only (never tab character)
(setq-default indent-tabs-mode nil)
;; emacs 23.1 to 26, default to t
;; if indent-tabs-mode is t, it means it may use tab, resulting mixed space and tab
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
(setq cursor-type 'bar)

(setq-default truncate-lines +1)
(setq display-line-numbers 'visual)
(setq display-line-numbers-type 'visual)
(global-prettify-symbols-mode +1)
(defun copy-whole-buffer ()
  "This function will copy the whole buffer..."
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (kill-ring-save nil nil t))
  )

(defun my-indent-whole-buffer-and-save ()
  (interactive)
  (indent-region (point-min) (point-max))
  (save-buffer)  )
;;; Company and completions
;;; Hippie expand
;; https://www.masteringemacs.org/article/text-expansion-hippie-expand
(global-set-key [remap dabbrev-expand] 'hippie-expand)
;;; Outline minor mode
;;; Multiple cursors
;;; Minibuffer completions
;; Dired
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

;; https://github.com/Alexander-Miller/treemacs
(setq speedbar-show-unknown-files t)
(setq compilation-auto-jump-to-first-error nil)
(setq compilation-scroll-output t)

;;; Outline minor mode
(setq outline-minor-mode-cycle t)
;;; Others
(global-set-key (kbd "C-c =") 'my-indent-whole-buffer)


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

(defun my-open-init-file ()
  (interactive)
  (find-file user-init-file))

;; (if (file-exists-p (concat my-emacs-root-path "/" "other-packages/aide/aide.el")))
;; (straight-use-package)

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

(global-set-key (kbd "ESC ESC =") 'my-indent-whole-buffer)
(global-set-key (kbd "ESC ESC K") 'nuke-all-buffers)
(global-set-key (kbd "ESC ESC b k") 'kill-buffer)
(global-set-key (kbd "ESC ESC e x") 'eval-last-sexp)
(global-set-key (kbd "ESC ESC e r") 'eval-region)
(global-set-key (kbd "ESC ESC f") 'ffap)
(global-set-key (kbd "ESC ESC h") 'help)
(global-set-key (kbd "ESC ESC i") 'my-open-init-file)
(global-set-key (kbd "ESC ESC w o") 'delete-other-windows)
(global-set-key (kbd "ESC ESC w c") 'delete-window)
(global-set-key (kbd "ESC ESC w f") 'toggle-frame-maximized)
(global-set-key (kbd "ESC ESC q") 'save-buffers-kill-terminal)
(global-set-key (kbd "ESC ESC e m") 'menu-bar-open)
(global-set-key (kbd "ESC ESC w s") 'split-window-below)
(global-set-key (kbd "ESC ESC t") 'toggle-truncate-lines)
(global-set-key (kbd "ESC ESC w v") 'split-window-right)
(global-set-key (kbd "ESC ESC x d") 'dired)

;;; Autosave files every 1 second if visited and changed
(setq auto-save-visited-interval 1)
(auto-save-visited-mode +1)
(setq auto-revert-interval 1)
(add-hook 'compilation-filter-hook 'comint-truncate-buffer)
(setq comint-buffer-maximum-size 10000)
(global-display-line-numbers-mode +1)
(global-set-key (kbd "ESC ESC l") 'list-packages)

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
(global-set-key (kbd "ESC ESC o a a") 'org-agenda)
(global-set-key (kbd "ESC ESC o a t") 'org-todo-list)
(setq org-export-backends '(ascii html icalendar latex md odt org))
(setq org-todo-keywords '((sequence "TODO" "KILL" "SKIP" "DONE")))
;;; Enable tabs in buffers
(global-tab-line-mode t)
;;; Save sessions in emacs
(setq desktop-save t)
(desktop-save-mode 1)
;;; Set desktop save path
;; (setq desktop-path "c:/Users/ravee/")
;; (desktop-read "c:/Users/ravee")
(unless (file-directory-p "~/.emacs.d/desktop")
(eshell-command "mkdir ~/.emacs.d/desktop"))
(setq desktop-path "~/.emacs.d/desktop")
(desktop-read "~/.emacs.d/desktop")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(completion-cdabbrev-prompt-flag t)
 '(completion-on-separator-character t)
 '(delimit-columns-after "")
 '(dynamic-completion-mode t)
 '(fido-mode t)
 '(global-whitespace-mode t)
 '(icomplete-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
