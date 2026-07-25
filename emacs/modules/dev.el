;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(require 'project)
(require 'seq)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package zig-mode
  :mode "\\.zig\\'")

(defconst my/clangd-compilation-database-candidates
  '("compile_commands.json"
    "build/compile_commands.json"
    "build-debug/compile_commands.json"
    "build-release/compile_commands.json"
    "cmake-build-debug/compile_commands.json"
    "cmake-build-release/compile_commands.json")
  "Compilation database paths to check at each source ancestor.")

(defconst my/make-project-files
  '("Makefile" "makefile" "GNUmakefile")
  "Make project markers recognized for C and C++ buffers.")

(defun my/project-try-makefile (directory)
  "Return the nearest Make-based C or C++ project above DIRECTORY."
  (when (derived-mode-p 'c-mode 'c++-mode)
    (when-let* ((root
                 (locate-dominating-file
                  directory
                  (lambda (candidate)
                    (seq-some
                     (lambda (marker)
                       (file-exists-p
                        (expand-file-name marker candidate)))
                     my/make-project-files)))))
      (cons 'transient root))))

(add-hook 'project-find-functions #'my/project-try-makefile)

(defun my/clangd-compilation-database-directory (project)
  "Return the nearest compilation database directory in PROJECT."
  (let ((directory
         (file-name-as-directory
          (expand-file-name
           (or (and buffer-file-name (file-name-directory buffer-file-name))
               default-directory))))
        (root
         (file-name-as-directory
          (expand-file-name (project-root project))))
        found)
    (while (and directory (not found))
      (dolist (relative my/clangd-compilation-database-candidates)
        (let ((candidate (expand-file-name relative directory)))
          (when (and (not found) (file-readable-p candidate))
            (setq found (file-name-directory candidate)))))
      (setq directory
            (cond
             (found nil)
             ((file-equal-p directory root) nil)
             (t
              (let ((parent
                     (file-name-directory
                      (directory-file-name directory))))
                (and (file-in-directory-p parent root) parent))))))
    found))

(defun my/eglot-clangd-contact (_interactive project)
  "Build the clangd command for PROJECT."
  (let ((database-directory
         (my/clangd-compilation-database-directory project)))
    (if database-directory
        (message "clangd: using %scompile_commands.json"
                 database-directory)
      (message "clangd: no compilation database found under project root"))
    (append
     '("clangd"
       "--background-index"
       "--clang-tidy"
       "--completion-style=detailed"
       "--enable-config"
       "--header-insertion=never")
     (when database-directory
       (list (concat "--compile-commands-dir=" database-directory))))))

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
  (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . my/eglot-clangd-contact)))

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
