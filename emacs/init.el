;; ===UI modifications===

;; Window Graphics
(setq inhibit-startup-message t)
(scroll-bar-mode -1) 
(tool-bar-mode -1)
(tooltip-mode 1)
(set-fringe-mode 10)
(menu-bar-mode 1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(menu-bar--display-line-numbers-mode-relative)
(blink-cursor-mode -1)
(set-face-attribute 'default nil :font "Berkeley Mono" :height 145)
(load-theme 'modus-vivendi)

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

;; ======= Copre =======

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
  (consult-fd-args "fd --no-ignore --full-path --color=never")
  (consult-ripgrep-args
   (concat "rg --null --line-buffered --color=never "
           "--max-columns=1000 --path-separator / "
           "--smart-case --no-heading --with-filename --line-number "
           "--search-zip"))
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
  ("C-c r" . consult-ripgrep)
  ("C-x C-f" . consult-fd)
  ("C-c e" . consult-bookmark)) ;; C-x r to see register info, bookmarks are stored in registers

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
    nix-ts-mode) . eglot-ensure)
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

;; TODO:
;; - project.el/projectile.el -> org-mode -> magit -> embark -> eshell -> latex -> terminal-emacs
