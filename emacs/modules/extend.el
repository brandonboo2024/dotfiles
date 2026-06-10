;; -*- lexical-binding: t; -*-

;; Contains extensions/functionalities to further extend emacs
;; Are all useful/cannot be replaced, but I would not consider them important enough to be part of core.el in a major cleanse

(use-package vterm
  :custom
  (display-line-numbers-mode 0)
  :config
  (defun vterm-send-Ctrl-c ()
    (interactive) (vterm-send-key "c" nil nil t))
  (defun vterm-send-Ctrl-d ()
    (interactive) (vterm-send-key "d" nil nil t))
  :bind(:map vterm-mode-map
             ("C-c ESC" . vterm-send-escape)
             ("C-c C-c" . vterm-send-Ctrl-c)
             ("C-c C-d" . vterm-send-Ctrl-d)))

(use-package pdf-tools
  :straight nil
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-loader-install))

(use-package no-littering
  ;; Available via straight/elpa. Straight will install it.
  :custom
  (no-littering-etc-directory (expand-file-name "etc/" user-emacs-directory))
  (no-littering-var-directory (expand-file-name "var/" user-emacs-directory)))

(provide 'extend)
