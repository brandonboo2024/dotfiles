;; -*- lexical-binding: t; -*-

;; Contains many QOL and aesthetic improvements, except theme
;; Most are nice to have, but not necessary. They should be the first
;; to be removed should there be performance/cleanups
;; Theme remains in init.el

;; Vanilla behaviour tweaks, no packages involved
(setq use-short-answers t)              ;; y/n instead of typing out yes/no
(setq enable-recursive-minibuffers t)   ;; M-x from inside a consult prompt
(setq read-extended-command-predicate   ;; hide commands irrelevant to the mode
      #'command-completion-default-include-p)
(electric-pair-mode 1)

;; Third leg alongside savehist and recentf: reopen a file where you left it
(use-package saveplace
  :straight nil
  :hook (after-init . save-place-mode))

(use-package nerd-icons
  :config
  (setq nerd-icons-font-family "JetBrainsMono Nerd Font"))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Corfu's popup is a child frame and does not render in a terminal frame at
;; all. Since emacs runs as a daemon and is used over a TTY, without this the
;; completion UI (including corfu-popupinfo) is silently missing there.
;; Deliberately NOT gated on (display-graphic-p): a daemon has no frame at init,
;; and one daemon serves both GUI and TTY clients. corfu-terminal-disable-on-gui
;; (default t) already falls back to corfu's child frame per-frame.
(use-package corfu-terminal
  :straight (:host codeberg :repo "akib/emacs-corfu-terminal")
  :after corfu
  :config
  (corfu-terminal-mode +1))

;; Better buffer but more detailed, built-in
(use-package ibuffer
  :ensure nil
  :bind
  ([remap list-buffers] . ibuffer))

;; Groups ibuffer's list by project instead of one flat list
(use-package ibuffer-project
  :after ibuffer
  :hook
  (ibuffer . (lambda ()
               (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
               (unless (eq ibuffer-sorting-mode 'project-file-relative)
                 (ibuffer-do-sort-by-project-file-relative)))))

(use-package paren ;; Supposed to help with paren highlights
  :custom
  (show-paren-delay 0.1)
  (show-paren-highlight-openparen t)
  (show-paren-when-point-in-periphery t)
  (show-paren-when-point-inside-paren t)
  :config
  (show-paren-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)) ;; prog-mode is the base mode for all modes

;; Smooths out GC pauses; pairs with the startup threshold bump in early-init.el
(use-package gcmh
  :init
  (setq gcmh-idle-delay 'auto
        gcmh-high-cons-threshold (* 64 1024 1024))
  :hook (after-init . gcmh-mode))

;; Auto-kills stale buffers (unvisited for a few days) so buffer lists
;; don't grow unbounded across a long-lived daemon session
(use-package midnight
  :straight nil
  :hook (after-init . midnight-mode))

(use-package mood-line
  :custom
  (mood-line-glyph-alist mood-line-glyphs-fira-code)
  :config
  (mood-line-mode))

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons file-size collapse subtree-state vc-state))
  (dirvish-quick-access-entries
   '(("h" "~/" "home")
     ("n" "~/nixos/" "nixos")
     ("o" "~/org/" "org")
     ("r" "~/org/roam/" "roam")))
  :bind
  (("C-c p d" . dirvish-side)
  :map dirvish-mode-map
  ("<tab>" . dirvish-subtree-toggle)
  ("<backtab>" . dirvish-layout-toggle))
  :config
  (dirvish-override-dired-mode))

(provide 'qol)
