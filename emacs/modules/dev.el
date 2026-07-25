;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package zig-mode
  :mode "\\.zig\\'")

(use-package eglot
  :hook
  ((c-mode
    c++-mode
    rust-mode
    python-mode
    nix-mode) . eglot-ensure)
  ;; Under C-c l, not C-c r / C-c f. eglot-mode-map is a minor-mode map and
  ;; therefore wins over the global bindings, so the old keys silently took
  ;; over global ripgrep and fd in every buffer with a language server -- which
  ;; is to say, in every buffer where code is actually written.
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc))
  :custom
  (eglot-autoshutdown t))

;; (use-package treesit
;;   :straight nil
;;   :custom
;;   (treesit-font-lock-level 2)
;;   :config
;;   ;; Auto-enable treesitter major modes when grammar is available
;;   (setq major-mode-remap-alist
;;         '((c-mode . c-ts-mode)
;;           (c++-mode . c-ts-mode)
;;           (rust-mode . rust-ts-mode)
;;           (python-mode . python-ts-mode)
;;           (bash-mode . bash-ts-mode)
;;           (json-mode . json-ts-mode)
;;           (yaml-mode . yaml-ts-mode)
;;           (dockerfile-mode . dockerfile-ts-mode))))

(use-package magit
  :bind
  ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :hook
  (git-commit-setup . git-commit-turn-on-flyspell))

(provide 'dev)
