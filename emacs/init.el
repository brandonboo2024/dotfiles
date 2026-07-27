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

;; Track per-package load time; inspect with M-x use-package-report
(setq use-package-compute-statistics t)

;; no-littering works by rewriting path variables, so it MUST load before any
;; package or built-in mode that reads one of those paths. Keep it here, right
;; after the straight bootstrap and before everything else.
(use-package no-littering
  ;; Available via straight/elpa. Straight will install it.
  :custom
  (no-littering-etc-directory (expand-file-name "etc/" user-emacs-directory))
  (no-littering-var-directory (expand-file-name "var/" user-emacs-directory)))

;; Keep Custom's writes out of this file
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(load custom-file 'noerror 'nomessage)

;; Window Graphics
(setq inhibit-startup-message t)
(setq use-dialog-box nil)
(scroll-bar-mode -1) 
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(menu-bar--display-line-numbers-mode-relative)
(blink-cursor-mode -1)          ;; graphical frames
(setq visible-cursor nil)       ;; terminal frames: don't ask for the blinking "very visible" cursor
(pixel-scroll-precision-mode 1)
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-13"))
(setq custom-safe-themes t)
(use-package doric-themes)
(use-package kanagawa-themes)
(load-theme 'kanagawa-wave t)

;; Buffer Settings
(setq initial-major-mode 'org-mode
      initial-scratch-message ""
      initial-buffer-choice t)
(auto-save-visited-mode 1)
(global-auto-revert-mode 1)
(repeat-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-save-visited-interval 60)
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
                eat-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
(setq scroll-margin 30)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

;; Sound
(setq ring-bell-function 'ignore)

;; Symlink
(setq vc-follow-symlinks t) ;; Disable prompt to follow symlink

;; Sync clipboard with emacs kill ring. Only TTY frames need a helper; GUI
;; frames use the built-ins, checked per call since a daemon has no frame yet.
(defvar my/clipboard-copy-command
  (cond ((executable-find "wl-copy") '("wl-copy"))
        ((executable-find "xclip")   '("xclip" "-selection" "clipboard" "-in"))
        ((executable-find "xsel")    '("xsel" "--clipboard" "--input")))
  "Command setting the system clipboard from stdin, or nil.
Stdin rather than argv, so a leading dash or a huge kill can't be misread.")

(defvar my/clipboard-paste-command
  (cond ((executable-find "wl-paste") '("wl-paste" "--no-newline"))
        ((executable-find "xclip")    '("xclip" "-selection" "clipboard" "-out"))
        ((executable-find "xsel")     '("xsel" "--clipboard" "--output")))
  "Command printing the system clipboard to stdout, or nil.")

(defun my/clipboard-cut (text)
  "Put TEXT on the system clipboard."
  (if (display-graphic-p)
      (gui-select-text text)
    (when my/clipboard-copy-command
      (let* ((process-connection-type nil)
             (proc (apply #'start-process "clipboard-copy" nil
                          my/clipboard-copy-command)))
        (process-send-string proc text)
        (process-send-eof proc)))))

(defun my/clipboard-paste ()
  "Return the system clipboard, or nil if unchanged or unavailable.
Nil for unchanged is what stops yanks duplicating `kill-ring' entries."
  (if (display-graphic-p)
      (gui-selection-value)
    (when my/clipboard-paste-command
      (let ((text (with-temp-buffer
                    (apply #'call-process (car my/clipboard-paste-command)
                           nil t nil (cdr my/clipboard-paste-command))
                    (buffer-string))))
        (unless (or (string-empty-p text)
                    (string-equal text (car kill-ring)))
          text)))))

(setq interprogram-cut-function #'my/clipboard-cut)
(setq interprogram-paste-function #'my/clipboard-paste)
(setq select-enable-primary t)
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
(require 'notes)
(require 'dev)
;; Last, so meow's states sit on top of the final global map
(require 'meow-config)

;; TODO:

;; org-mode -> pdf integration -> latex -> terminal-emacs
