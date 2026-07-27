;; -*- lexical-binding: t; -*-

;; Contains any useful programming utilities

(use-package nix-mode
  :mode "\\.nix\\'")

(defun my/clangd-compile-commands-dir ()
  "Find the directory holding compile_commands.json for the
current buffer. clangd only searches upward from the source file
itself, so an out-of-tree build dir (e.g. build/) that isn't an
ancestor of the sources never gets found on its own; check upward
from the buffer, then the project root and common build dir names."
  (let* ((root (or (and (project-current) (project-root (project-current)))
                   default-directory))
         (has-db (lambda (dir)
                   (and dir
                        (or (file-exists-p (expand-file-name "compile_commands.json" dir))
                            ;; a .clangd may point at the database itself
                            (file-exists-p (expand-file-name ".clangd" dir))))))
         ;; Upward from the file first - catches a database sitting in an
         ;; intermediate directory rather than at the project root.
         (upward (locate-dominating-file default-directory "compile_commands.json")))
    (or (and upward (expand-file-name upward))
        (seq-find has-db
                  (append (list root)
                          (mapcar (lambda (d) (expand-file-name d root))
                                  '("build" "out"
                                    "build/Debug" "build/Release"
                                    "cmake-build-debug" "cmake-build-release"))
                          ;; build-<preset>/ and similar
                          (seq-filter #'file-directory-p
                                      (file-expand-wildcards
                                       (expand-file-name "build*/" root))))))))

(defvar my/clangd-query-driver
  (string-join
   '(;; Debian/Ubuntu system toolchains, incl. cross compilers
     "/usr/bin/*gcc*" "/usr/bin/*g++*" "/usr/bin/*clang*"
     "/usr/bin/c++" "/usr/bin/cc"
     "/usr/local/bin/*gcc*" "/usr/local/bin/*g++*"
     ;; Nix profiles (desktop)
     "/etc/profiles/per-user/*/bin/*" "/run/current-system/sw/bin/*"
     "/nix/store/*/bin/*")
   ",")
  "Globs of compiler drivers clangd may interrogate for system include paths.
Without this clangd guesses the libstdc++ location and gets it wrong whenever
its guess doesn't match the installed GCC - producing spurious
\"'vector' file not found\" errors on an otherwise valid translation unit.
Non-matching globs are simply ignored, so one list covers every machine.")

(defun my/clangd-contact (&rest _)
  "Eglot contact for clangd, pointed at the discovered compilation
database so per-project .dir-locals.el hacks aren't needed. Flags
are kept in sync with nvim/plugin/lsp.lua so C++ behaves the same
in both editors."
  (let ((dir (my/clangd-compile-commands-dir)))
    (append (list "clangd"
                  "--background-index"
                  "--clang-tidy"
                  "--header-insertion=never"
                  "--completion-style=detailed"
                  "--enable-config"
                  (concat "--query-driver=" my/clangd-query-driver)
                  (format "-j=%d" (max 1 (/ (num-processors) 2))))
            (when dir (list (concat "--compile-commands-dir=" dir)))
            '(:initializationOptions (:fallbackFlags ["-Wall"])))))

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
  ;; Follow xrefs into system headers outside the project (constant in C++)
  (eglot-extend-to-xref t)
  :config
  ;; The event log is a real allocation cost with a server as chatty as clangd.
  ;; eglot >= 1.17 (straight) uses the plist form; the 29.x built-in uses the
  ;; older integer variable.
  (if (boundp 'eglot-events-buffer-config)
      (setq eglot-events-buffer-config '(:size 0 :format full))
    (setq eglot-events-buffer-size 0))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode objc-mode) . my/clangd-contact)))

;; Linear, vim-like undo: undo never redoes and redo never undoes, so you can't
;; fall into Emacs's undo-the-undo cycle. Remapping (rather than rebinding) means
;; every existing route - C-/, M-_, and meow's `u' which dispatches through
;; `meow--kbd-undo' = "C-/" - lands on undo-fu without further wiring.
(use-package undo-fu
  :bind (([remap undo] . undo-fu-only-undo)
         ([remap undo-redo] . undo-fu-only-redo)))

(use-package vundo
  ;; Complements undo-fu rather than duplicating it: undo-fu gives a linear
  ;; u/U, vundo shows the actual tree for when you've undone into a branch that
  ;; linear redo can't reach.
  :bind ("C-x u" . vundo))

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
