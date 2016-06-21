
;; Org needs to be loaded at this stage!
(add-to-list 'load-path "~/.emacs.d/plugins/org-mode/lisp")
(add-to-list 'load-path "~/.emacs.d/plugins/org-mode/contrib/lisp" t)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(org-babel-load-file "~/.emacs.d/configuration.org")
;;(load-file "~/.emacs.d/configuration.el")
