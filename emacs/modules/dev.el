;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(require 'project)
(require 'seq)

(add-hook 'emacs-lisp-mode-hook #'flymake-mode)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package zig-mode
  :mode "\\.zig\\'")

(use-package markdown-mode
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-math t)
  (markdown-hide-urls nil))

(use-package geiser
  :demand t
  :custom
  (geiser-default-implementation 'guile))

(use-package geiser-guile
  :demand t)

(require 'ansi-color)

(setq compilation-scroll-output 'first-error
      ;; Save modified buffers silently rather than prompting per file on
      ;; every build.
      compilation-ask-about-save nil
      ;; recompile means recompile; do not ask whether to kill the running one.
      compilation-always-kill t)

;; Build tools emit colour when they detect a terminal, and direnv-provided
;; toolchains frequently do. Without this the escape sequences render as
;; literal garbage in the compilation buffer.
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(define-prefix-command 'my/build-prefix-map)
(global-set-key (kbd "C-c b") 'my/build-prefix-map)
(define-key my/build-prefix-map (kbd "b") #'project-compile)
(define-key my/build-prefix-map (kbd "c") #'compile)
(define-key my/build-prefix-map (kbd "r") #'recompile)
(define-key my/build-prefix-map (kbd "k") #'kill-compilation)

(defconst my/clangd-build-directories
  '("" "build")
  "Directories under the project root that may hold a compilation database.")

(defun my/clangd-database-directory (project)
  "Return the directory holding PROJECT's compile_commands.json, or nil.
clangd only searches upward from the source file, so an out-of-tree
build directory is never found on its own."
  (or (locate-dominating-file default-directory "compile_commands.json")
      (when-let* ((root (project-root project)))
        (seq-find
         (lambda (dir)
           (file-readable-p (expand-file-name "compile_commands.json" dir)))
         (mapcar (lambda (dir) (expand-file-name dir root))
                 my/clangd-build-directories)))))

(defvar my/clangd-query-driver
  (string-join
   '(;; Debian/Ubuntu system toolchains, including cross compilers
     "/usr/bin/*gcc*" "/usr/bin/*g++*" "/usr/bin/*clang*"
     "/usr/bin/c++" "/usr/bin/cc"
     "/usr/local/bin/*gcc*" "/usr/local/bin/*g++*"
     ;; Nix profiles
     "/etc/profiles/per-user/*/bin/*" "/run/current-system/sw/bin/*"
     "/nix/store/*/bin/*")
   ",")
  "Globs of compiler drivers clangd may interrogate for system include paths.
Without this clangd guesses the libstdc++ location and gets it wrong whenever
its guess doesn't match the installed GCC, producing spurious
\"vector file not found\" errors on an otherwise valid translation unit.
Non-matching globs are simply ignored, so one list covers every machine.")

(defun my/eglot-clangd-contact (_interactive project)
  "Build the clangd command for PROJECT."
  (let ((database-directory
         (my/clangd-database-directory project)))
    (if database-directory
        (message "clangd: using %scompile_commands.json"
                 (file-name-as-directory database-directory))
      (message "clangd: no compilation database found under project root"))
    (append
     (list "clangd"
           "--background-index"
           "--clang-tidy"
           "--completion-style=detailed"
           "--enable-config"
           "--header-insertion=never"
           (concat "--query-driver=" my/clangd-query-driver)
           (format "-j=%d" (max 1 (/ (num-processors) 2))))
     (when database-directory
       (list (concat "--compile-commands-dir=" database-directory))))))

(setq-default eglot-workspace-configuration
              '(:nixd (:formatting (:command ["nixfmt"]))))

(use-package eglot
  :straight nil
  :hook
  ((c-mode
    c++-mode
    python-mode
    zig-mode
    nix-mode) . eglot-ensure)
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
  (eglot-confirm-server-edits nil)
  (eglot-extend-to-xref t)
  :config
  (if (boundp 'eglot-events-buffer-config)
      (setq eglot-events-buffer-config '(:size 0 :format full))
    (set (intern "eglot-events-buffer-size") 0))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . my/eglot-clangd-contact))
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements eglot-mode-map
      "C-c l" "lsp")))

(use-package magit
  :bind (("C-x g" . magit-status)
         :map project-prefix-map
         ("v" . magit-project-status))
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (add-to-list 'project-switch-commands '(magit-project-status "Magit") t))

(use-package diff-hl
  :custom
  (diff-hl-side 'right)
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

;; Per-project direnv environment for Eglot, compilers and subprocesses.
;; Kept last so envrc's major-mode hook runs before the hooks added above.
(use-package envrc
  :if (executable-find "direnv")
  :hook (after-init . envrc-global-mode))

(provide 'dev)
