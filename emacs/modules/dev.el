;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(use-package nix-mode
  :mode "\\.nix\\'")

(defun my/clangd-compile-commands-dir ()
  "Find the directory holding compile_commands.json for the
current buffer. clangd only searches upward from the source file
itself, so an out-of-tree build dir (e.g. build/) that isn't an
ancestor of the sources never gets found on its own; check the
project root and the common build dir names too."
  (let ((root (or (and (project-current) (project-root (project-current)))
                  default-directory)))
    (seq-find (lambda (dir) (file-exists-p (expand-file-name "compile_commands.json" dir)))
              (list root
                    (expand-file-name "build" root)
                    (expand-file-name "out" root)
                    (expand-file-name "cmake-build-debug" root)
                    (expand-file-name "cmake-build-release" root)))))

(defun my/clangd-contact (&rest _)
  "Eglot contact for clangd, pointed at the discovered compilation
database so per-project .dir-locals.el hacks aren't needed."
  (let ((dir (my/clangd-compile-commands-dir)))
    (append '("clangd" "--background-index" "--clang-tidy")
            (when dir (list (concat "--compile-commands-dir=" dir))))))

(use-package eglot
  :hook
  ((c-mode
    c++-mode
    rust-mode
    python-mode
    nix-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-edits nil)
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . my/clangd-contact)))

(use-package magit
  :bind
  ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :hook
  (git-commit-setup . git-commit-turn-on-flyspell))

(use-package agent-shell
  :bind (:map agent-shell-mode-map
         ("C-c c" . agent-shell-cycle-session-mode)
         ("C-<tab>" . nil)))

(provide 'dev)
