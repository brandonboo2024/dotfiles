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

;; Window Graphics
(setq inhibit-startup-message t)
(scroll-bar-mode -1) 
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(menu-bar--display-line-numbers-mode-relative)
(blink-cursor-mode -1)
(pixel-scroll-precision-mode 1)
(set-face-attribute 'default nil :font "Berkeley Mono" :height 150)
(load-theme 'modus-vivendi-tinted)

;; Buffer Settings
(setq initial-major-mode 'org-mode
      initial-scratch-message ""
      initial-buffer-choice t)
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 60)
(use-package savehist
  :straight nil
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
                vterm-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
(setq scroll-margin 20)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

;; Sound
(setq ring-bell-function 'ignore)

;; Symlink
(setq vc-follow-symlinks t) ;; Disable prompt to follow symlink

;; Sync clipboard with emacs kill ring
(unless (display-graphic-p)
  (setq interprogram-cut-function
        (lambda (text)
          (start-process "wl-copy" nil "wl-copy" text)))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "wl-paste --no-newline"))))
(setq select-enable-clipboard t)

(use-package kkp
  :if (not (display-graphic-p))
  :config
  (global-kkp-mode +1))

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(require 'keybinds)
(require 'core)
(require 'qol)
(require 'extend)
(require 'dev)

;; TODO:
;; org-mode -> pdf integration -> latex -> terminal-emacs
