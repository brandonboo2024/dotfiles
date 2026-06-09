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

;; ======= Basic Utilities ======

;; Sync clipboard with emacs kill ring
(unless (display-graphic-p)
  (setq interprogram-cut-function
        (lambda (text)
          (start-process "wl-copy" nil "wl-copy" text)))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "wl-paste --no-newline"))))
(setq select-enable-clipboard t)

;; ======= Core =======
;; (setq custom-safe-themes t)
;; (use-package doom-themes
;;   :custom
;;   (doom-themes-enable-bold t)
;;   (doom-themes-enable-italic t)
;;   :config
;;   (load-theme 'doom-gruvbox)
;;   (doom-themes-org-config))

(use-package kkp
  :if (not (display-graphic-p))
  :config
  (global-kkp-mode +1))

;; Whichkey
(use-package which-key
  :diminish which-key-mode ;; Hides minor mode from status bar
  :custom
  (which-key-prefix-prefix "◉ ")
  (which-key-idle-delay 0.3)
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

;; Minibuffer Utilities
(use-package orderless ;; No more prefix-only matching
  :custom
  (completion-styles '(orderless basic)))

(use-package vertico ;; Displays minibuffers in a nicer window
  :config
  (vertico-mode))

(use-package marginalia ;; Gives rich info on files selected in minibuffer
  :config
  (marginalia-mode))

(use-package consult ;; Better commands for minibuffers
  :custom
  (consult-fd-args '("fd" "--no-ignore" "--full-path" "--color=never"))
  (consult-ripgrep-args
   (concat "rg --null --line-buffered --color=never "
           "--max-columns=1000 --path-separator / "
           "--smart-case --no-heading --with-filename --line-number "
           "--search-zip"))
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
  ("C-c r" . consult-ripgrep)
  ("C-c f" . consult-fd)
  ("C-c e" . consult-bookmark)) ;; C-x r to see register info, bookmarks are stored in registers

(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<backtab>" . dired-subtree-cycle)))

(use-package paren ;; Supposed to help with paren highlights
  :custom
  (show-paren-delay 0.1)
  (show-paren-highlight-openparen t)
  (show-paren-when-point-in-periphery t)
  (show-paren-when-point-inside-paren t)
  :config
  (show-paren-mode 1))

;; ====== Keybinds ======

(defun match-paren(arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(global-set-key "%" 'match-paren)

;; Programming Languages
(use-package nix-mode
  :mode "\\.nix\\'")

;; Terminal
(use-package vterm
  :custom
  (display-line-numbers-mode 0)
  :config
  (defun vterm-send-Ctrl-c ()
    (interactive) (vterm-send-key "c" nil nil t))
  (defun vterm-send-Ctrl-d ()
    (interactive) (vterm-send-key "d" nil nil t))
  :bind(:map vterm-mode-map
             ("C-c ESC" . vterm-send-escape)
             ("C-c C-c" . vterm-send-Ctrl-c)
             ("C-c C-d" . vterm-send-Ctrl-d)))
;; QOL
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)) ;; prog-mode is the base mode for all modes

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol]. helpful-symbol))

(use-package nerd-icons
  :custom
  (nerd-icons-scale-factor 1.0)
  (nerd-icons-default-adjust 0.0)
  :config
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :custom
  (nerd-icons-dired-lazy t)
  (nerd-icons-cache-icons t)
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package ibuffer
  :ensure nil
  :bind
  ([remap list-buffers] . ibuffer))

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Autocomplete
(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 3)
  (corfu-auto-delay 0.3)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (corfu-popupinfo-mode +1)
  (global-corfu-mode))

(use-package cape
  :defer 10 ;; Loads function lazily
  :init
  (add-to-list 'completion-at-point-functions #'cape-file) 
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; ====== LSP (Eglot) ======

(use-package eglot
  :hook
  ((c-ts-mode
    c++-ts-mode
    rust-ts-mode
    python-ts-mode
    nix-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c a" . eglot-code-actions)
              ("C-c r" . eglot-rename)
              ("C-c f" . eglot-format)
              ("C-c d" . eldoc))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))

;; ====== Tree-sitter ======

(use-package treesit
  :straight nil
  :custom
  (treesit-font-lock-level 2)
  :config
  ;; Auto-enable treesitter major modes when grammar is available
  (setq major-mode-remap-alist
        '((c-mode . c-ts-mode)
          (c++-mode . c-ts-mode)
          (rust-mode . rust-ts-mode)
          (python-mode . python-ts-mode)
          (bash-mode . bash-ts-mode)
          (json-mode . json-ts-mode)
          (yaml-mode . yaml-ts-mode)
          (dockerfile-mode . dockerfile-ts-mode))))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :custom
  (prefix-help-command #'embark-prefix-help-command)
  (embark-indicators '(embark-minimal-indicator
                       embark-highlight-indicator
                       embark-isearch-highlight-indicator)))

(use-package embark-consult
  :after  (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package magit
  :bind
  ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :hook
  (git-commit-setup . git-commit-turn-on-flyspell))

(use-package org
  :straight nil
  :custom
  (org-directory "~/org"))

(use-package pdf-tools
  :straight nil
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-loader-install))

(use-package gruvbox-theme)

;; TODO:
;; org-mode -> pdf integration -> latex -> terminal-emacs
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("871b064b53235facde040f6bdfa28d03d9f4b966d8ce28fb1725313731a2bcc8"
     "7b8f5bbdc7c316ee62f271acf6bcd0e0b8a272fdffe908f8c920b0ba34871d98" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
