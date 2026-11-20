;; -*- lexical-binding: t; -*-

;; Pin package versions in a lockfile tracked by this repository, so updates
;; can be rolled back and every host builds the same commits.
(setq straight-profiles
      `((nil . ,(expand-file-name "straight-lock.el" user-emacs-directory))))

;; Bootstrap straight.el (installs itself into `straight-base-dir').
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

(setq straight-use-package-by-default 1)

;; Built into Emacs (or provided by Nix for zmq): never fetch these.
(dolist (pkg '(seq eldoc xref flymake external-completion project org zmq which-key))
  (add-to-list 'straight-built-in-pseudo-packages pkg))

;; Keep package data and state under XDG, out of this repository.
(setq no-littering-etc-directory
      (expand-file-name "etc/" my/emacs-data-directory)
      no-littering-var-directory
      (expand-file-name "var/" my/emacs-state-directory))

(use-package no-littering
  :demand t)

;; Byte- and native-compile packages as they load. The config itself stays
;; interpreted, since its use-package forms expect to run at load time.
(use-package compile-angel
  :demand t
  :config
  (setq compile-angel-verbose nil)
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)
  (compile-angel-exclude-directory
   (expand-file-name "modules/" user-emacs-directory))
  ;; State files (custom.el, recentf, ...) are data, not code to compile.
  (compile-angel-exclude-directory my/emacs-state-directory)
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)
  (compile-angel-on-load-mode 1))

;; Fonts: one base height (1/10 pt); every other size is a ratio of it.
;; Set through faces, not a frame `font' parameter, which would override them.
(defconst my/font-height 230
  "Base font height for code, in 1/10 pt.")

(defun my/font-scaled (ratio)
  "Return `my/font-height' scaled by RATIO, as an absolute face height."
  (round (* my/font-height ratio)))

;; Window Graphics
(setq default-frame-alist
      '((undecorated . t)
        (internal-border-width . 24)))
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
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
;; blink-cursor-mode is enabled after init.el runs, so turn it off later.
(add-hook 'after-init-hook (lambda () (blink-cursor-mode -1)))
(setq visible-cursor t
      cursor-in-non-selected-windows nil)
(pixel-scroll-precision-mode 1)
(setq custom-safe-themes t)
(electric-pair-mode -1)

;; Assorted defaults, set individually rather than via a preset package.
(setq frame-resize-pixelwise t
      window-resize-pixelwise t
      frame-inhibit-implied-resize t
      save-interprogram-paste-before-kill t
      imenu-auto-rescan t
      shell-command-prompt-show-cwd t
      vc-find-revision-no-save t
      epg-pinentry-mode 'loopback)
(delete-selection-mode 1)
(context-menu-mode 1)
(global-xref-mouse-mode 1)
;; Ghost-text completion for prose; code buffers use the Corfu popup.
(add-hook 'text-mode-hook #'completion-preview-mode)

;; custom-set-faces, not set-face-attribute: these specs survive `load-theme'.
(custom-set-faces
 `(default ((t (:family "Berkeley Mono" :height ,my/font-height))))
 '(fixed-pitch ((t (:family "Berkeley Mono"))))
 `(variable-pitch ((t (:family "IBM Plex Sans"
                       :height ,(my/font-scaled 1.13))))))

;; Theme
(use-package lambda-themes
  :straight (:type git :host github :repo "lambda-emacs/lambda-themes")
  :custom
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t)
  (lambda-themes-set-variable-pitch t)
  (lambda-themes-set-vibrant t)
  :config (load-theme 'lambda-light))

(use-package vscode-dark-plus-theme)

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
(setq scroll-margin 20)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

;; Sound
(setq ring-bell-function 'ignore)

;; Symlink
(setq vc-follow-symlinks t) ;; follow symlinks into Git without asking

;; The daemon serves GUI and terminal frames at once, so pick the clipboard
;; backend per call: the GUI selection, or wl-copy/wl-paste in a terminal.
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
  ;; Kitty keyboard protocol for terminal frames; GUI frames are unaffected.
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
