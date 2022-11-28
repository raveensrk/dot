;;; natural-language-date-time-parser.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Raveen Kumar
;;
;; Author: Raveen Kumar <raveen@raveenkumar.xyz>
;; Maintainer: Raveen Kumar <raveen@raveenkumar.xyz>
;; Created: November 28, 2022
;; Modified: November 28, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/raveenkumar/natural-language-date-time-parser
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(defun get-selection ()
  (interactive)
  (message (buffer-substring (mark) (point))))


;; test


(provide 'natural-language-date-time-parser)
;;; natural-language-date-time-parser.el ends here
