;;; org_agenda.el --- Discover repository task files -*- lexical-binding: t; -*-

(require 'org-agenda)

(defvar dot-org-roots '("~/dot" "~/repos")
  "Directories searched recursively for Org agenda files.
Discovery includes gitignored files and hidden directories, except Git
metadata.  Directory symlinks are not followed, avoiding cycles.")

(defun dot-org-refresh (&rest _args)
  "Refresh `org-agenda-files' before generating or rebuilding an agenda.
Keep archives out of the normal agenda; Org's archive mode includes them
on request.  Resolve file symlinks and overlapping roots to a single file."
  (interactive)
  (let (files)
    (dolist (root dot-org-roots)
      (setq root (expand-file-name root))
      (if (not (file-directory-p root))
          (display-warning 'dot-org (format "Missing agenda root: %s" root))
        (dolist (path (directory-files-recursively
                      root "\\.org\\'" nil
                      (lambda (dir)
                        (not (equal (file-name-nondirectory
                                     (directory-file-name dir)) ".git")))))
          (when (file-regular-p path)
            (push (file-truename path) files)))))
    (setq org-agenda-files (sort (delete-dups files) #'string-lessp))))

;; This entry point also runs for direct agenda commands and agenda redo.
;; Do not walk the repositories during startup or on each file lookup.
(advice-add 'org-agenda-prepare :before #'dot-org-refresh)

(require 'org-capture)

(defun dot-org-inbox ()
  "Return the originating buffer's repository-root inbox.
Recognize .git directories and worktree/submodule .git files.  Refuse to
choose a destination when capture starts outside a repository."
  (with-current-buffer (or (org-capture-get :original-buffer) (current-buffer))
    (let ((root (locate-dominating-file default-directory ".git")))
      (unless root
        (user-error "Capture requires a repository buffer; open one first"))
      (expand-file-name "inbox.org" root))))

;; Raw inbox entries are headings, not tasks, until triaged.
(setq org-capture-templates
      '(("c" "capture" entry (file dot-org-inbox) "* %?\n" :prepend t)))
(setq org-id-locations-file (expand-file-name "org-id-locations" user-emacs-directory))

(provide 'dot-org-agenda)
;;; org_agenda.el ends here
