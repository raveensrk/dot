;;; emacs_org_test.el --- Isolated agenda tests -*- lexical-binding: t; -*-

(require 'ert)

(defun dot-test-write (root name text)
  "Write TEXT to NAME below ROOT and return its path."
  (let ((path (expand-file-name name root)))
    (make-directory (file-name-directory path) t)
    (with-temp-file path (insert text))
    path))

(ert-deftest dot-org-capture-routing ()
  (let* ((root (make-temp-file "org-capture-" t))
         (repo (expand-file-name "repo" root))
         (worktree (expand-file-name "worktree" root)))
    (unwind-protect
        (progn
          (make-directory (expand-file-name ".git" repo) t)
          (dot-test-write worktree ".git" "gitdir: ../repo/.git/worktrees/test\n")
          (dot-test-write repo "inbox.org" "#+title: Inbox\n\n* Existing idea\n")
          (dolist (dir (list repo worktree))
            (make-directory (expand-file-name "nested" dir))
            (with-temp-buffer
              (setq default-directory (file-name-as-directory
                                       (expand-file-name "nested" dir)))
              (org-capture nil "c")
              (insert "Captured idea")
              (org-capture-finalize))
            (with-temp-buffer
              (insert-file-contents (expand-file-name "inbox.org" dir))
              (should (string-match-p "^\\* Captured idea$" (buffer-string)))))
          (with-temp-buffer
            (insert-file-contents (expand-file-name "inbox.org" repo))
            (should (search-forward "* Existing idea" nil t)))
          (with-temp-buffer
            (setq default-directory (file-name-as-directory root))
            (let ((org-capture-plist nil))
              (should-error (dot-org-inbox) :type 'user-error)))
          (should-not (file-exists-p (expand-file-name "inbox.org" root))))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (and buffer-file-name (file-in-directory-p buffer-file-name root))
            (set-buffer-modified-p nil)
            (kill-buffer buffer))))
      (delete-directory root t))))

(ert-deftest dot-org-discovery ()
  (let* ((root (make-temp-file "org-discovery-" t))
         (dot-org-roots (list root (expand-file-name "nested" root)))
         (org-agenda-files nil))
    (unwind-protect
        (let* ((board (dot-test-write root "todo.org" "* TODO board\n"))
               (nested (dot-test-write root "nested/a space.org" "* TODO nested\n"))
               (hidden (dot-test-write root ".notes/capture.org" "* TODO hidden\n")))
          (dot-test-write root ".git/example.org" "* TODO metadata\n")
          (dot-test-write root "todo.org_archive" "* DONE history\n")
          (dot-test-write root "todo.md" "- TODO: legacy\n")
          (make-directory (expand-file-name "directory.org" root))
          (make-symbolic-link root (expand-file-name "loop" root))
          (make-symbolic-link board (expand-file-name "alias.org" root))
          (dot-org-refresh)
          (should (equal org-agenda-files
                         (sort (mapcar #'file-truename (list board nested hidden))
                               #'string-lessp)))
          (delete-file nested)
          (dot-org-refresh)
          (should (= 2 (length org-agenda-files))))
      (delete-directory root t))))

(ert-deftest dot-org-missing-root ()
  (let* ((root (make-temp-file "org-missing-" t))
         (dot-org-roots (list (expand-file-name "missing" root)))
         (org-agenda-files '("stale.org"))
         messages)
    (unwind-protect
        (cl-letf (((symbol-function 'display-warning)
                   (lambda (&rest args) (push args messages))))
          (dot-org-refresh)
          (should-not org-agenda-files)
          (should messages))
      (delete-directory root t))))

(ert-deftest dot-org-agenda-rediscovers-files ()
  (let* ((root (make-temp-file "org-agenda-" t))
         (dot-org-roots (list root))
         (org-agenda-files nil)
         (org-agenda-sticky nil)
         (org-agenda-window-setup 'current-window))
    (unwind-protect
        (progn
          (dot-test-write root "todo.org" "* TODO Original task\n")
          (org-todo-list)
          (should (string-match-p "Original task" (buffer-string)))
          (dot-test-write root "nested/new.org" "* TODO Newly created task\n")
          (org-agenda-redo)
          (should (string-match-p "Newly created task" (buffer-string))))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (or (derived-mode-p 'org-agenda-mode)
                    (and buffer-file-name (file-in-directory-p buffer-file-name root)))
            (set-buffer-modified-p nil)
            (kill-buffer buffer))))
      (delete-directory root t))))
