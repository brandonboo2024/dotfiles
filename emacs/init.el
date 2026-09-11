;; ===UI modifications===  -*- lexical-binding: t; -*-

;; Bootstrap code for straight.elp
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default 1) ;; use-package integration by default

(dolist (pkg '(seq eldoc xref flymake external-completion project org))
  (add-to-list 'straight-built-in-pseudo-packages pkg))

(setq no-littering-etc-directory
      (expand-file-name "etc/" my/emacs-data-directory)
      no-littering-var-directory
      (expand-file-name "var/" my/emacs-state-directory))

(use-package no-littering
  :demand t)

(use-package compile-angel
  :demand t
  :config
  ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
  ;; (When set to nil, compile-angel won't show which file is being compiled.)
  (setq compile-angel-verbose nil)

  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-path-suffixes'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; the `use-package' macro, you'll need to explicitly add:
  ;; (eval-when-compile (require 'use-package))
  ;; at the top of your init file.
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)

  ;; Keep Straight's use-package setup interpreted in configuration modules.
  (compile-angel-exclude-directory
   (expand-file-name "modules/" user-emacs-directory))

  ;; Uncomment the line below to compile automatically when an Elisp file is saved
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files when they are loaded
  ;; using `load' or `require'.
  (compile-angel-on-load-mode 1))

;; Window Graphics
(setq default-frame-alist
      '((undecorated . t)
        (internal-border-width . 24)
        (font . "Berkeley Mono-22")))
(setq inhibit-startup-message t)
(setq use-dialog-box nil)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(column-number-mode 1)
(setq multiple-terminals-merge-keyboards 1)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
;; Emacs initializes this option after init.el, so disable it afterward.
(add-hook 'after-init-hook (lambda () (blink-cursor-mode -1)))
(setq visible-cursor t
      cursor-in-non-selected-windows nil)
(pixel-scroll-precision-mode 1)
(setq custom-safe-themes t)
(electric-pair-mode -1)

;; Keep convenience behavior explicit instead of loading a broad preset.
(setq frame-resize-pixelwise t
      window-resize-pixelwise t
      frame-inhibit-implied-resize t
      save-interprogram-paste-before-kill t
      imenu-auto-rescan t
      shell-command-prompt-show-cwd t
      vc-find-revision-no-save t)
(delete-selection-mode 1)
(context-menu-mode 1)
(global-xref-mouse-mode 1)
(global-completion-preview-mode 1)

(custom-set-faces
 '(default ((t (:family "Berkeley Mono" :height 230))))
 '(fixed-pitch ((t (:family "Berkeley Mono"))))
 '(variable-pitch ((t (:family "IBM Plex Sans" :height 260)))))

;; Theme
(use-package lambda-themes
  :straight (:type git :host github :repo "lambda-emacs/lambda-themes")
  :custom
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t)
  (lambda-themes-set-variable-pitch t)
  (lambda-themes-set-vibrant t)
  :config
  (load-theme 'lambda-light))

;; Buffer Settings
(setq initial-major-mode 'org-mode
      initial-scratch-message ""
      initial-buffer-choice t)
(auto-save-visited-mode 1)
(global-auto-revert-mode 1)
(repeat-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-save-visited-interval 60)
(setq auto-revert-avoid-polling t) ;; revert based on events, rather than time
(use-package savehist
  :straight nil
  :custom
  (history-length 1000)
  (savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
  :hook (after-init . savehist-mode))

(use-package recentf
  :straight nil
  :hook (after-init . recentf-mode))

;; Line Settings
(setq-default tab-width 4)
(setq-default fill-column 80)
(setq sentence-end-double-space nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-always-indent 'complete)
(dolist (mode '(term-mode-hook
                eshell-mode-hook
                ghostel-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
(setq scroll-margin 20)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

;; Sound
(setq ring-bell-function 'ignore)

;; Symlink
(setq vc-follow-symlinks t) ;; Disable prompt to follow symlink

;; GUI and terminal frames can coexist under the daemon. Choose the clipboard
;; backend when the operation happens, not while init.el is loading.
(defun my/interprogram-cut (text)
  "Put TEXT on the clipboard for the selected frame."
  (if (display-graphic-p (selected-frame))
      (gui-select-text text)
    (with-temp-buffer
      (insert text)
      (call-process-region
       (point-min) (point-max) "wl-copy" nil nil nil "--type" "text/plain"))))

(defun my/interprogram-paste ()
  "Read the clipboard using the backend for the selected frame."
  (if (display-graphic-p (selected-frame))
      (gui-selection-value)
    (with-temp-buffer
      (when (zerop (call-process "wl-paste" nil t nil "--no-newline"))
        (buffer-string)))))

(setq interprogram-cut-function #'my/interprogram-cut
      interprogram-paste-function #'my/interprogram-paste
      select-enable-primary t
      select-enable-clipboard t)

(use-package kkp
  :config
  ;; The global mode installs terminal-specific hooks and ignores GUI frames.
  (global-kkp-mode +1))

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(require 'keybinds)
(require 'core)
(require 'qol)
(require 'extend)
(require 'notes)
(require 'dev)
(require 'meow-config)

(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))
