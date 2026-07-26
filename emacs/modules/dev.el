;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(require 'project)
(require 'seq)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package zig-mode
  :mode "\\.zig\\'")

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package markdown-mode
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-math t)
  (markdown-hide-urls nil))

(setq compilation-scroll-output 'first-error)

(define-prefix-command 'my/build-prefix-map)
(global-set-key (kbd "C-c b") 'my/build-prefix-map)
(define-key my/build-prefix-map (kbd "b") #'project-compile)
(define-key my/build-prefix-map (kbd "r") #'recompile)
(define-key my/build-prefix-map (kbd "k") #'kill-compilation)

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
  :straight nil
  :hook
  ((c-mode
    c++-mode
    rust-mode
    python-mode
    zig-mode
    nix-mode) . eglot-ensure)
  ;; ((typescript-mode tsx-mode js-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format)
              ("C-c l d" . eldoc)
              ("C-c l n" . flymake-goto-next-error)
              ("C-c l p" . flymake-goto-prev-error)
              ("C-c l l" . flymake-show-buffer-diagnostics))
  :custom
  (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . my/eglot-clangd-contact))
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements eglot-mode-map
      "C-c l" "lsp")))

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
