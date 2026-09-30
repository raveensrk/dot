;;; emacs_org_test.el --- Isolated agenda tests -*- lexical-binding: t; -*-

(require 'ert)

(defun dot-test-write (root name text)
  "Write TEXT to NAME below ROOT and return its path."
  (let ((path (expand-file-name name root)))
    (make-directory (file-name-directory path) t)
    (with-temp-file path (insert text))
    path))

(defun dot-test-stub-read-file-name (target &optional seen)
  "Return a stub for `read-file-name' that records the default in SEEN.
The stub returns TARGET, or the default when TARGET is nil."
  (lambda (_prompt &optional _dir default &rest _)
    (when seen (setcar seen default))
    (or target default (expand-file-name "chosen.org" default-directory))))

(ert-deftest dot-org-capture-file-defaults ()
  (let* ((root (make-temp-file "org-capture-" t))
         (repo (expand-file-name "repo" root))
         (worktree (expand-file-name "worktree" root))
         (outside (expand-file-name "outside" root))
         (seen (list 'unset)))
    (unwind-protect
        (progn
          (make-directory (expand-file-name ".git" repo) t)
          (dot-test-write worktree ".git" "gitdir: ../repo/.git/worktrees/test\n")
          (make-directory outside t)
          (dolist (case (list (cons repo (expand-file-name "todo.org" repo))
                              (cons worktree (expand-file-name "todo.org" worktree))
                              (cons outside nil)))
            (setcar seen 'unset)
            (cl-letf (((symbol-function 'read-file-name)
                       (dot-test-stub-read-file-name nil seen)))
              (with-temp-buffer
                (setq default-directory (file-name-as-directory (car case)))
                (let ((org-capture-plist nil))
                  (should (equal (dot-org-capture-file)
                                 (or (cdr case)
                                     (expand-file-name "chosen.org" default-directory))))))
              (should (equal (car seen) (cdr case)))))
      (delete-directory root t)))))

(ert-deftest dot-org-capture-appends-plain-heading ()
  (let* ((root (make-temp-file "org-capture-" t))
         (board (expand-file-name "todo.org" root))
         (fresh (expand-file-name "fresh/todo.org" root)))
    (unwind-protect
        (progn
          (dot-test-write root "todo.org" "* Tasks\n** TODO Existing\n\n\n\n")
          (cl-letf (((symbol-function 'read-file-name)
                     (dot-test-stub-read-file-name board)))
            (with-temp-buffer
              (setq default-directory (file-name-as-directory root))
              (org-capture nil "c")
              (insert "Captured idea")
              (org-capture-finalize)))
          (with-temp-buffer
            (insert-file-contents board)
            (should (string-match-p "^\\* Captured idea$" (buffer-string)))
            (should (string-match-p "^\\* Tasks" (buffer-string)))
            (should (string-match-p "^\\*\\* TODO Existing$" (buffer-string))))
          (cl-letf (((symbol-function 'read-file-name)
                     (dot-test-stub-read-file-name fresh)))
            (with-temp-buffer
              (setq default-directory (file-name-as-directory root))
              (org-capture nil "c")
              (insert "New board entry")
              (org-capture-finalize)))
          (with-temp-buffer
            (insert-file-contents fresh)
            (should (equal "* New board entry\n" (buffer-string)))))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (and buffer-file-name (file-in-directory-p buffer-file-name root))
            (set-buffer-modified-p nil)
            (kill-buffer buffer))))
      (delete-directory root t))))

(ert-deftest dot-org-discovery ()
  (let* ((root (make-temp-file "org-discovery-" t))
         (dot-org-roots (list root (expand-file-name "nested" root)))
         (dot-org-ignore '("node_modules" "docs/corpus"))
         (org-agenda-files nil))
    (unwind-protect
        (let* ((board (dot-test-write root "todo.org" "* TODO board\n"))
               (nested (dot-test-write root "nested/a space.org" "* TODO nested\n")))
          (dot-test-write root ".notes/capture.org" "* TODO hidden\n")
          (dot-test-write root ".git/example.org" "* TODO metadata\n")
          (dot-test-write root "node_modules/pkg/x.org" "* TODO vendored\n")
          (dot-test-write root "docs/corpus/fixture.org" "* TODO fixture\n")
          (dot-test-write root "todo.org_archive" "* DONE history\n")
          (dot-test-write root "todo.md" "- TODO: legacy\n")
          (make-directory (expand-file-name "directory.org" root))
          (make-symbolic-link root (expand-file-name "loop" root))
          (make-symbolic-link board (expand-file-name "alias.org" root))
          (dot-org-refresh)
          (should (equal org-agenda-files
                         (sort (mapcar #'file-truename (list board nested))
                               #'string-lessp)))
          (delete-file nested)
          (dot-org-refresh)
          (should (= 1 (length org-agenda-files))))
      (delete-directory root t))))

(ert-deftest dot-org-todo-states ()
  (should (equal '((sequence "TODO" "IN_PROGRESS" "OPTIONAL" "LATER"
                             "|" "DONE" "OBSOLETE"))
                 org-todo-keywords))
  (should (eq 'time org-log-done)))

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
