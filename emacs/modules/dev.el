;; -*- lexical-binding: t; -*-

;; Programming: languages, compilation, Eglot, Git and direnv.

(require 'project)
(require 'seq)

(add-hook 'emacs-lisp-mode-hook #'flymake-mode)
(when (executable-find "shellcheck")
  (add-hook 'sh-mode-hook #'flymake-mode)
  (add-hook 'sh-mode-hook #'sh-shellcheck-flymake))

;; by default ediff creates a new frame
(setq ediff-window-setup-function #'ediff-setup-windows-plain
      ediff-split-window-function #'split-window-horizontally)

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
      compilation-ask-about-save nil ;; save buffers without asking
      compilation-always-kill t)     ;; restart a running build without asking

;; Render ANSI colour codes from build tools.
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
  "Globs of compiler drivers clangd may query for system include paths.
Otherwise clangd guesses the libstdc++ location and reports spurious
\"file not found\" errors.  Non-matching globs are ignored, so one list
covers every machine.")

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
  ;; Disable the events log, which slows Eglot down.
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . my/eglot-clangd-contact))
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements eglot-mode-map
      "C-c l" "lsp")))

(defun my/project-agent-session ()
  "Open or switch to this project's tmux agent session."
  (interactive)
  (unless (executable-find "agent-session")
    (user-error "agent-session not found on PATH"))
  (let ((root (expand-file-name (project-root (project-current t)))))
    (start-process "agent-session" nil "agent-session" root)))

(define-key project-prefix-map (kbd "a") #'my/project-agent-session)
(add-to-list 'project-switch-commands '(my/project-agent-session "Agent") t)

(use-package magit
  :bind (("C-x g" . magit-status)
         :map my/git-prefix-map
         ("f" . magit-file-dispatch)
         ("b" . magit-blame-addition)
         :map project-prefix-map
         ("v" . magit-project-status))
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (add-to-list 'project-switch-commands '(magit-project-status "Magit") t))

(use-package diff-hl
  :hook (dired-mode . diff-hl-dired-mode)
  :bind (:map my/git-prefix-map
              ("n" . diff-hl-next-hunk)
              ("p" . diff-hl-previous-hunk)
              ("h" . diff-hl-show-hunk)
              ("r" . diff-hl-revert-hunk)
              ("s" . diff-hl-stage-current-hunk))
  :custom
  (diff-hl-side 'left)
  :config
  (defvar-keymap my/diff-hl-repeat-map
    :repeat t
    "n" #'diff-hl-next-hunk
    "p" #'diff-hl-previous-hunk
    "h" #'diff-hl-show-hunk
    "r" #'diff-hl-revert-hunk
    "s" #'diff-hl-stage-current-hunk)
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

;; Per-project direnv environment. Kept last so its hook runs before the
;; mode hooks above (eglot-ensure needs the environment).
(use-package envrc
  :if (executable-find "direnv")
  :hook (after-init . envrc-global-mode))

(provide 'dev)
