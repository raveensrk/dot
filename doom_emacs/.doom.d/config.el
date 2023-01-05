;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Raveen Kumar"
      user-mail-address "raveen@raveenkumar.xyz")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(if (version<= "27.1" emacs-version)
    (global-so-long-mode 1))

(menu-bar-mode +1)
(beacon-mode +1)
(tab-bar-mode +1)
(mouse-avoidance-mode 'cat-and-mouse)
(rainbow-mode +1)
;; (doom/increase-font-size 4)

(load-theme 'doom-gruvbox t)

(setq mouse-wheel-flip-direction t)
(setq mouse-wheel-tilt-scroll t)
(global-set-key (kbd "M-o") 'ace-window)
(dumb-jump-mode +1)
(setq dumb-jump-selector 'ivy)

(setq search-default-mode #'char-fold-to-regexp)

(setq projectile-project-search-path '("~/my_repos/" "~/work/" ("~/github" . 1)))

(add-hook 'dired-mode-hook 'dired-hide-details-mode)
(setq dired-dwim-target t)

;; (require 'org-download)

;; Drag-and-drop to `dired`
;; (add-hook 'dired-mode-hook 'org-download-enable)

;;; Org mode

(setq org-structure-template-alist
      '(("a" . "export ascii")
        ("c" . "center")
        ("C" . "comment")
        ("e" . "example")
        ("E" . "export")
        ("h" . "export html")
        ("l" . "export latex")
        ("q" . "quote")
        ("s" . "src")
        ("v" . "verse")
        ("b" . "src bash")))

(setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)
(setq org-id-locations-file-relative t)
(setq org-link-descriptive t)
(setq org-link-file-path-type 'relative)
(setq org-agenda-archives-mode t)
(setq org-startup-folded 'overview)
(setq org-attach-id-dir "data/")
(require 'org-auto-tangle)
(add-hook 'org-mode-hook 'org-auto-tangle-mode)

;;;; Org mode agenda
(if (string-equal system-type "windows-nt")
    (progn (message "Windows")
           (setq org-agenda-files
                 (directory-files-recursively "c:/my_repos" ".*agenda.*\.org$\\|.*agenda.*\.org_archive$")))
  (progn (message "Unix")
         (setq org-agenda-files '("~/.agenda_files"))
         (when (file-exists-p "~/my_repos")
           (setq org-agenda-text-search-extra-files
                 (directory-files-recursively "~/my_repos" ".*\.org$\\|.*\.org_archive$")))))

(org-id-update-id-locations)

;;; Org roam
(setq org-roam-directory (file-truename "~/my_repos"))
(setq find-file-visit-truename t)
(require 'org-roam-export)
(org-roam-db-autosync-mode)

(map! :leader :desc "Edit org mode src blocks" :n "z e" #'org-edit-src-code)

;;; enable abbreviations globally
(setq-default abbrev-mode t)

;;; Hotkeys
(map! :leader :desc "Winner undo" :n "<left>" #'winner-undo)
(map! :leader :desc "Toggle truncate lines" :n "z z t" #'toggle-truncate-lines)

;;; My functions
(defun my-indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(map! :leader
      :desc "Indent whole buffer"
      "z =" #'my-indent-whole-buffer)

(defun copy-whole-buffer ()
  "This function will copy the whole buffer..."
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (kill-ring-save nil nil t))
  )

(map! :leader
      :desc "Copy whole buffer"
      "z y" #'copy-whole-buffer)

(map! :leader
      :desc "Org roam find node"
      "z f" #'org-roam-node-find)

(map! :leader
      :desc "Org roam node insert"
      "z i" #'org-roam-node-insert)

;; (map! :leader
;;       :desc "Org roam buffer toggle"
;;       "z t" #'org-roam-buffer-toggle)

(map! :leader
      :desc "Org roam buffer toggle"
      "z s" #'org-roam-db-sync)

(map! :leader
      :desc "Open current org-mode url in OpenWith.exe external application..."
      "z o" #'my-wsl2-open-external-org-https-urls)


(defun my-org-convert-line-to-list ()
  "This function will make current line into a list"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (insert "- ")))

(map! :leader
      :desc "Convert current line to list item"
      "z l" #'my-org-convert-line-to-list)

(map! :leader
      :desc "Org toggle narrow to subtree"
      "z t" #'org-toggle-narrow-to-subtree)

(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-<up>") 'move-line-up)

(mapcar 'load-file (directory-files-recursively "~/.doom.d/my_elisp" ".*.el"))

;;(setq tags-table-list nil)
(setq find-file-visit-truename nil)
