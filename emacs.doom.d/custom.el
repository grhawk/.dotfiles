(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(warning-suppress-log-types
   '((doom-first-buffer-hook)
     (doom-first-buffer-hook)
     (defvaralias)))
 '(warning-suppress-types '((doom-first-buffer-hook) (defvaralias))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.

 (defvar server-socket-dir
  (and (featurep 'make-network-process '(:family local))
   (format "%s/emacs-server"  "/tmp"))
  "The directory in which to place the server socket.
  If local sockets are not supported, this is nil.")

;; (defvar server-socket-dir
;;   (and (featurep 'make-network-process '(:family local))
;;    (format "%s/emacs-server%d" (or (getenv "TMPDIR") "/tmp") (user-uid)))
;;   "The directory in which to place the server socket.
;;   If local sockets are not supported, this is nil.")


 )
