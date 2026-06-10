;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package eglot
  :hook
  ((c-ts-mode
    c++-ts-mode
    rust-ts-mode
    python-ts-mode
    nix-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c a" . eglot-code-actions)
              ("C-c r" . eglot-rename)
              ("C-c f" . eglot-format)
              ("C-c d" . eldoc))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))

(use-package treesit
  :straight nil
  :custom
  (treesit-font-lock-level 2)
  :config
  ;; Auto-enable treesitter major modes when grammar is available
  (setq major-mode-remap-alist
        '((c-mode . c-ts-mode)
          (c++-mode . c-ts-mode)
          (rust-mode . rust-ts-mode)
          (python-mode . python-ts-mode)
          (bash-mode . bash-ts-mode)
          (json-mode . json-ts-mode)
          (yaml-mode . yaml-ts-mode)
          (dockerfile-mode . dockerfile-ts-mode))))

(use-package magit
  :bind
  ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :hook
  (git-commit-setup . git-commit-turn-on-flyspell))

(provide 'dev)
