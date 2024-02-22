(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor-in-non-selected-windows 'box)
 '(dashboard-navigator-buttons nil)
 '(dashboard-page-separator "\12\12")
 '(dashboard-projects-backend 'project-el)
 '(dashboard-vertically-center-content t)
 '(default-input-method "rfc1345")
 '(ffap-file-name-with-spaces t)
 '(grep-find-command
   '("find -L . -type f -exec grep --color=auto -nH --null -e  \\{\\} +" . 54))
 '(grep-find-ignored-files
   '(".#*" "*.o" "*~" "*.bin" "*.lbin" "*.so" "*.a" "*.ln" "*.blg" "*.bbl" "*.elc" "*.lof" "*.glo" "*.idx" "*.lot" "*.fmt" "*.tfm" "*.class" "*.fas" "*.lib" "*.mem" "*.x86f" "*.sparcf" "*.dfsl" "*.pfsl" "*.d64fsl" "*.p64fsl" "*.lx64fsl" "*.lx32fsl" "*.dx64fsl" "*.dx32fsl" "*.fx64fsl" "*.fx32fsl" "*.sx64fsl" "*.sx32fsl" "*.wx64fsl" "*.wx32fsl" "*.fasl" "*.ufsl" "*.fsl" "*.dxl" "*.lo" "*.la" "*.gmo" "*.mo" "*.toc" "*.aux" "*.cp" "*.fn" "*.ky" "*.pg" "*.tp" "*.vr" "*.cps" "*.fns" "*.kys" "*.pgs" "*.tps" "*.vrs" "*.pyc" "*.pyo" "TAGS" "tags"))
 '(grep-find-template
   "find -H -L <D> <X> -type f <F> -exec grep <C> -nH --null -e <R> \\{\\} +")
 '(grep-find-use-xargs 'exec-plus)
 '(ido-ignore-directories '("\\`CVS/" "\\`\\.\\./" "\\`\\./"))
 '(ido-show-dot-for-dired t)
 '(ido-use-filename-at-point 'guess)
 '(org-agenda-files '("~/iCloud/My projects" "~/my_repos" "~/org"))
 '(project-vc-extra-root-markers
   '("Makefile" "index.org" ".dir-locals.el" "README" "readme.org" "README.org" "readme"))
 '(project-vc-ignores '("TAGS" "tags"))
 '(projectile-auto-discover nil)
 '(projectile-generic-command "find -L . -type f | cut -c3- | tr '\\n' '\\0'")
 '(straight-use-package-by-default t)
 '(treemacs-indent-guide-mode t)
 '(treemacs-indentation 0)
 '(treemacs-indentation-string " ┃ "))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#2e3436" :foreground "#eeeeec" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 175 :width normal :foundry "nil" :family "Menlo")))))


