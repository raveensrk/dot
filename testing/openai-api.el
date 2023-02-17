;;; openai-api.el --- With the selected region use openai transformer -*- lexical-binding: t -*-

;; Author: Raveen Kumar
;; Maintainer: Raveen Kumar
;; Version: 0.1
;; Package-Requires: (dependencies)
;; Homepage: homepage
;; Keywords: ai


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; commentary

;;; Code:

(setenv "OPENAI_API_KEY" "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")



(defun openai-api ()
  "Send the selected region of text to OpenAI API and replace it with the API response."
  (interactive)
  (if (region-active-p)
      (let ((api-key (or (getenv "OPENAI_API_KEY")
                         (read-string "Enter your OpenAI API key: ")))
            (text (buffer-substring (region-beginning) (region-end))))
        (let ((text-encoded (url-hexify-string text))
              (url-request-method "POST")
              (url-request-extra-headers `(("Content-Type" . "application/json")
                                           ("Authorization" . ,(concat "Bearer " api-key))))
              (url-request-data (concat "{\"prompt\": \"" text-encoded "\", \"temperature\": 0.7, \"max_tokens\": 60, \"top_p\": 1}"))
              (url (url-generic-parse-url "https://api.openai.com/v1/completions")))
          (with-current-buffer (url-retrieve-synchronously url)
            (goto-char (point-min))
            (re-search-forward "^$")
            (delete-region (point) (point-min))
            (let ((response (buffer-substring (point) (point-max))))
              (when (not (string-empty-p text-encoded))
                (delete-region (region-beginning) (region-end))
                (insert (cdr (assoc 'text (json-read-from-string response)))))))))
    (message "No region selected.")))



(defun get-region-text ()
  "Return the text between the beginning and end of the region."
  (interactive)
  (message "%s" 
  (let ((start (region-beginning))
        (end (region-end)))
    (buffer-substring start end))))
(provide 'openai-api)

;;; openai-api.el ends here
