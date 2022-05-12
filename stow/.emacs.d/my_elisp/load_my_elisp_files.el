;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(dolist (lambda () (directory-files
    (replace-regexp-in-string " " " "
                               (expand-file-name "~/.emacs.d/my_elisp/")))) message)

(dolist (lambda () (get-load-suffixes)) message)

