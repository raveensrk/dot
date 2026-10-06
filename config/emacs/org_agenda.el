;;; org_agenda.el --- Agenda discovery and capture for the todo skill schema -*- lexical-binding: t; -*-

;; Mirrors the todo skill (~/repos/agent1/skills/todo/SKILL.md).  Boards are
;; org files, states are TODO/IN_PROGRESS/OPTIONAL/LATER/DONE/OBSOLETE, and
;; capture appends a plain heading.
;;
;; Discovery duplicates the skill config (~/dot_local/config/todo_skill.toml):
;; default_dirs and ignore.  Change both when the config changes.

(require 'cl-lib)
(require 'org-agenda)
(require 'org-capture)

;;; Discovery

(defvar dot-org-roots
  '("~/dot"
    "~/repos"
    ;; beorg's iCloud container (the iOS org inbox). A sibling of ~/icloud,
    ;; not inside it, so it needs the container path.
    "~/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/org")
  "Directories searched recursively for Org agenda files.
The same list as default_dirs in todo_skill.toml.")

(defvar dot-org-ignore '("node_modules" "docs/corpus")
  "Paths excluded from agenda discovery.
The same list as ignore in todo_skill.toml.  A bare name matches a path
component, an entry with a slash matches that run of components, a glob is
a glob, and an absolute or ~/ entry matches that exact path and below.")

(defun dot-org-ignored-p (path)
  "Non-nil when PATH matches an entry in `dot-org-ignore'."
  (let ((text (expand-file-name path)))
    (cl-some
     (lambda (pattern)
       (cond
        ((string-prefix-p "~" pattern)
         (let ((base (expand-file-name pattern)))
           (or (equal text base) (string-prefix-p (concat base "/") text))))
        ((string-prefix-p "/" pattern)
         (or (equal text pattern) (string-prefix-p (concat pattern "/") text)))
        ((string-match-p "[*?[]" pattern)
         (or (string-match-p (wildcard-to-regexp pattern) text)
             (string-match-p (wildcard-to-regexp pattern)
                             (file-name-nondirectory path))))
        ((string-match-p "/" pattern)
         (or (equal text pattern)
             (string-suffix-p (concat "/" pattern) text)
             (string-match-p (concat "/" (regexp-quote pattern) "/") text)))
        (t (member pattern (split-string text "/")))))
     dot-org-ignore)))

(defun dot-org-refresh (&rest _args)
  "Rebuild `org-agenda-files' from `dot-org-roots'.
Skips hidden directories and `dot-org-ignore', and resolves file symlinks
to one entry per file.  Runs before every agenda build."
  (interactive)
  (let (files)
    (dolist (root dot-org-roots)
      (setq root (expand-file-name root))
      (if (not (file-directory-p root))
          (display-warning 'dot-org (format "Missing agenda root: %s" root))
        (dolist (path (directory-files-recursively
                       root "\\.org\\'" nil
                       (lambda (dir)
                         (and (not (string-prefix-p "." (file-name-nondirectory dir)))
                              (not (dot-org-ignored-p dir))))))
          (when (file-regular-p path)
            (push (file-truename path) files)))))
    (setq org-agenda-files (sort (delete-dups files) #'string-lessp))))

;; This entry point also runs for direct agenda commands and agenda redo.
;; Do not walk the repositories during startup or on each file lookup.
(advice-add 'org-agenda-prepare :before #'dot-org-refresh)

;;; Todo states

;; The same states as scripts/todo.el.  A file with a #+TODO: line overrides
;; this; headerless boards fall back to it.
(setq org-todo-keywords '((sequence "TODO" "IN_PROGRESS" "OPTIONAL" "LATER"
                                    "|" "DONE" "OBSOLETE"))
      org-log-done 'time)

;;; Display

;; The agenda owns the frame: delete other windows on open, restore on quit.
(setq org-agenda-window-setup 'only-window
      org-agenda-restore-windows-after-quit t)

(defun dot-org-agenda-tags ()
  "Tags of the entry as a fixed 28-wide column, for the agenda prefix."
  (let ((tags (ignore-errors (org-get-tags))))
    (format "%-28.28s" (if tags (concat ":" (string-join tags ":") ":") ""))))

;; Fixed-width columns: category (21: longest file name, 20, plus one), tags (28), time (5),
;; leader (10), then the heading.  Tags sit on the left, so the trailing
;; copy is removed.  Leader is blank on the deadline's own day,
;; "Overdue 3d" only when past due, all within the column; the grid's dot/dash fillers are dropped.
(setq org-agenda-prefix-format
      '((agenda . " %-21.21c %(dot-org-agenda-tags) %5t  %-10s ")
        (todo . " %-21.21c %(dot-org-agenda-tags) ")
        (tags . " %-21.21c %(dot-org-agenda-tags) ")
        (search . " %-21.21c %(dot-org-agenda-tags) "))
      org-agenda-remove-tags t
      org-agenda-deadline-leaders '("" "In %d d." "Overdue %dd")
      org-agenda-time-grid '((daily today require-timed)
                             (800 1000 1200 1400 1600 1800 2000) "" "")
      org-agenda-tags-column -100)

;; Red only when overdue against TODAY.  Org picks the deadline face from
;; the day column being drawn, so repeat occurrences after the deadline
;; date (future columns) came out red.  Every deadline gets the neutral
;; face here; the finalize hook below reds the ones whose date < today.
(setq org-agenda-deadline-faces '((-1.0e10 . org-upcoming-deadline)))

(defun dot-org-agenda-red-overdue ()
  "Give `org-imminent-deadline' to undone deadlines dated before today."
  (let ((today (org-today))
        (inhibit-read-only t))
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let ((date (get-text-property (point) 'ts-date))
              (type (get-text-property (point) 'type))
              (end (line-end-position)))
          (cond
           ;; Overdue: whole line red, TODO keyword and priority included.
           ((and date (< date today)
                 (member type '("deadline" "upcoming-deadline")))
            (put-text-property (point) end 'face 'org-imminent-deadline))
           ;; Any other task line: plain text, no faces at all.
           ((get-text-property (point) 'org-marker)
            (put-text-property (point) end 'face nil))))
        (forward-line 1)))))
(add-hook 'org-agenda-finalize-hook #'dot-org-agenda-red-overdue)

(defun dot-org-agenda-plain-keywords ()
  "Draw TODO keywords and [#X] priorities as plain text in the agenda.
Buffer-local remap, so org files keep their colours."
  (face-remap-add-relative 'org-todo 'default)
  (face-remap-add-relative 'org-priority 'default))
(add-hook 'org-agenda-mode-hook #'dot-org-agenda-plain-keywords)
;; [#B] colour comes from overlays, not the face above.
(setq org-agenda-fontify-priorities nil)

;;; Capture

(defun dot-org-capture-file ()
  "Ask which file to capture into.
Default to todo.org at the repository root when the buffer is inside a
repository (a .git directory or worktree file); no default otherwise."
  (let* ((root (locate-dominating-file default-directory ".git"))
         (file (read-file-name "Capture file: " nil
                               (and root (expand-file-name "todo.org" root)))))
    ;; org-capture fails on a missing parent directory; create it up front.
    (make-directory (file-name-directory file) t)
    file))

;; Plain heading, no state: the skill triages it later.  No :prepend, so the
;; entry lands at the end of the file, same as `scripts/todo capture'.
(setq org-capture-templates
      '(("c" "capture" entry (file dot-org-capture-file) "* %?\n")))
(setq org-id-locations-file (expand-file-name "org-id-locations" user-emacs-directory))

;; Doing lives with the skill. Missing repo leaves the rest of this file working.
(let ((todo-emacs (expand-file-name "~/repos/agent1/skills/todo/emacs.el")))
  (when (file-exists-p todo-emacs)
    (load todo-emacs nil 'nomessage)
    (global-set-key (kbd "C-c o d") 'agenda2)))


(provide 'dot-org-agenda)
;;; org_agenda.el ends here
