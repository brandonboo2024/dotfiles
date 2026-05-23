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

;; Sound
(setq ring-bell-function 'ignore)

;; Symlink
(setq vc-follow-symlinks t) ;; Disable prompt to follow symlink

;; ==============================================


;; ======= Basic Utilities ======

;; Sync clipboard with emacs kill ring
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

;; ======= Package Installation and Configuration

;; Install packages
(straight-use-package 'use-package)
(straight-use-package 'vertico)
(straight-use-package 'consult)
(straight-use-package 'marginalia)
(straight-use-package 'orderless)

;; Whichkey
(use-package which-key
  :diminish which-key-mode ;; Hides minor mode from status bar
  :init
  (which-key-mode)
  (which-key-setup-minibuffer)
  :config
  (setq which-key-prefix-prefix "◉ "))

;; Minibuffer Utilities
(use-package orderless ;; No more prefix-only matching
  :config
  (setq completion-styles '(orderless basic)))

(use-package vertico ;; Displays minibuffers in a nicer window
  :init
  (vertico-mode))

(use-package marginalia ;; Gives rich info on files selected in minibuffer
  :init
  (marginalia-mode))

(use-package consult ;; Better commands for minibuffers
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
  ("C-c r" . consult-ripgrep)
  ("C-c f" . consult-find)
  ("C-c e" . consult-bookmark)) ;; C-x r to see register info, bookmarks are stored in registers

(use-package paren ;; Supposed to help with paren highlights
  :config
  (setq show-paren-delay 0.1
		show-paren-highlight-openparen t
		show-paren-when-point-inside-paren t
		show-paren-when-point-in-periphery t)
  :init
  (show-paren-mode 1))

;; ====== Keybinds ======

(defun match-paren(arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s(") (forward-list 1) (backward-char 1))
		((looking-at "\\s)") (forward-char 1) (backward-list 1))
		(t (self-insert-command (or arg 1)))))

(global-set-key "%" 'match-paren)
