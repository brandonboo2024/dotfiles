;; -*- lexical-binding: t; -*-

;; Contains many QOL and aesthetic improvements, except theme
;; Most are nice to have, but not necessary. They should be the first
;; to be removed should there be performance/cleanups
;; Theme remains in init.el

(use-package nerd-icons
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

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Better buffer but more detailed, built-in
(use-package ibuffer
  :ensure nil
  :bind
  ([remap list-buffers] . ibuffer))

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

;; Nicer way to navigate dired
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<backtab>" . dired-subtree-cycle)))

;;; Buffer hygiene
(use-package midnight
  :custom
  (clean-buffer-list-delay-general 1) ; days
  :config
  (midnight-mode 1))

;; Project-scoped equivalents of the buffer list and of killing buffers.
;; project-list-buffers is the ibuffer view restricted to one project;
;; project-kill-buffers closes a whole project in one go, which is what stops
;; the accumulation at source. Both are built in and already on C-x p C-b and
;; C-x p k; these bindings just put them next to the other C-c p commands.
;;
;; uniquify needs no configuration here: post-forward-angle-brackets has been
;; the default since well before this Emacs, so same-named files across
;; projects are already distinguishable.
(use-package project
  :bind
  ("C-c p B" . project-list-buffers)
  ("C-c p k" . project-kill-buffers))

(provide 'qol)
