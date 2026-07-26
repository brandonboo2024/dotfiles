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

;; Modeline. The reason for a package here is meow: modal state is the single
;; most-consulted piece of state in this config, and the default modeline
;; renders it as unstyled text in a bar there is otherwise no reason to read.
;;
;; Left stock on purpose. Segment trimming (`mood-line-defformat') and any face
;; work against doric belong in a later pass, once there is something to react
;; to rather than a guess.
(use-package mood-line
  :config
  ;; Unicode rather than the nerd-font glyph set. This daemon serves pgtk GUI
  ;; frames and real tty frames from one process, and these render the same in
  ;; both. `mood-line-glyphs-ascii' is the fallback if anything boxes in foot.
  ;;
  ;; setq in :config, not :custom: the value is a variable defined by the
  ;; package, so it cannot be read before the package loads.
  (setq mood-line-glyph-alist mood-line-glyphs-unicode)
  (mood-line-mode))

;; Better buffer but more detailed, built-in
(use-package ibuffer
  :ensure nil
  :bind
  ([remap list-buffers] . ibuffer))

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

;; Nicer way to navigate dired
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<backtab>" . dired-subtree-cycle)))

(use-package project
  :bind
  ("C-c p B" . project-list-buffers)
  ("C-c p k" . project-kill-buffers))

(provide 'qol)
