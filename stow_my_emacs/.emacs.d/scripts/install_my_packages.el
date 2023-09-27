(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; (message 
;;  (concat (mapcar 'string package-selected-packages))
;;  )


 ;; '(package-selected-packages
 ;;   '(benchmark-init aggressive-indent all-the-icons-completion all-the-icons-ivy-rich avy beacon company counsel dynamic-fonts embark evil evil-escape evil-goggles evil-leader evil-mc evil-numbers evil-snipe evil-surround evil-vimish-fold expand-region flex-autopair flycheck flymake-shellcheck flyspell-correct folding format-all git-gutter gruvbox-theme helm helm-etags-plus htmlize indent-guide ivy key-chord ledger-mode load-dir magit marginalia markdown-mode minimal-session-saver noccur olivetti orderless org-auto-tangle org-download org-drill org-super-agenda ox-pandoc php-mode projectile projectile-ripgrep rainbow-delimiters restart-emacs runner search-web simple-httpd smartparens swiper use-package vterm which-key writegood-mode xhair xml-quotes yasnippet yasnippet-snippets))




(package-refresh-contents)
(package-install-selected-packages)
(package-autoremove)

(provide 'install_my_packages)

