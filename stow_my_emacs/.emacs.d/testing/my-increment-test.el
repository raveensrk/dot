;; TODO: This function will look at the word under point
;; if its a number Shift-<right> will increment
;; if not it will be shift select

;; https://endlessparentheses.com/define-context-aware-keys-in-emacs.html

(defun look-at-me ()
  "This will look for a number at point."
  (interactive)
  (if (looking-at "[0-9]+")
      (message "looking")
    (message "not looking")))



(defun check-word-under-point ()
  (interactive)
  (if (looking-at "[0-9]+")
      (progn
        (message "looking")
        (my-increment-number-decimal))))


(define-key global-map (kbd "S-<right>")
  (lambda () (if (looking-at "[0-9]+")
      (progn
        (message "looking")
        (my-increment-number-decimal)))))


(define-key global-map (kbd "S-<left>") 'check-word-under-point-2)


(defun my-increment-number-decimal (&optional arg)
  "Increment the number forward from point by 'arg'."
  (interactive "p*")
  (save-excursion
    (save-match-data
      (let (inc-by field-width answer)
        (setq inc-by (if arg arg 1))
        (skip-chars-backward "0123456789")
        (when (re-search-forward "[0-9]+" nil t)
          (setq field-width (- (match-end 0) (match-beginning 0)))
          (setq answer (+ (string-to-number (match-string 0) 10) inc-by))
          (when (< answer 0)
            (setq answer (+ (expt 10 field-width) answer)))
          (replace-match (format (concat "%0" (int-to-string field-width) "d")
                                 answer)))))))

(defun check-word-under-point-2 ()
  (interactive)
  (save-excursion
    (if (looking-at "[0-9]+")
        (progn
          (message "looking")
          (my-increment-number-decimal -1))
      (left-char))))
(advice-add 'left-char :before-while 'check-word-under-point-2)
___9956_




(defmacro endless/define-conditional-key (keymap key def
                                                 &rest body)
  "In KEYMAP, define key sequence KEY as DEF conditionally.
This is like `define-key', except the definition
\"disappears\" whenever BODY evaluates to nil."
  (declare (indent 3)
           (debug (form form form &rest sexp)))
  `(define-key ,keymap ,key 
     '(menu-item
       ,(format "maybe-%s" (or (car (cdr-safe def)) def))
       nil
       :filter (lambda (&optional _)
                 (when ,(macroexp-progn body)
                   ,def)))))
