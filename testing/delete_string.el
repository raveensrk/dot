(defun replace-text-in-file (in_file out_file)
  (progn
    (create-file-buffer out_file)
    (switch-to-buffer out_file)
    (insert-file-contents in_file)
    (replace-regexp-in-region "Water" "Water2" (point-min) (point-max))
    (write-file out_file t)))

(replace-text-in-file "./example_text.txt" "./example_replaced_text.txt")
