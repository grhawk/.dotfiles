(defun terminal-init-rxvt ()
  "Something"
  (screen-register-default-colors)
  (tty-set-up-initial-frame-faces))

;; Compile everything in the emacs.d directory
;(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)

;; Org needs to be loaded at this stage!
(add-to-list 'load-path "~/.emacs.d/plugins/org-mode/lisp")
(add-to-list 'load-path "~/.emacs.d/plugins/org-mode/contrib/lisp" t)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(org-babel-load-file "~/.emacs.d/configuration.org")
;; (load-file "~/.emacs.d/configuration.el")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (paredit yasnippet yaml-mode wgrep smex smart-mode-line request-deferred rainbow-delimiters persp-projectile magit julia-shell irony-eldoc ido-vertical-mode ido-ubiquitous flycheck-rtags flycheck-pos-tip flycheck-irony flycheck-color-mode-line flx-ido dired+ diminish diff-hl company-rtags company-quickhelp company-jedi company-irony-c-headers company-irony cmake-ide bookmark+ alert))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
