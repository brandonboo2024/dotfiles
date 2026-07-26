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

;; No nerd-icons-dired here: dirvish draws dired's icons itself via its
;; `nerd-icons' attribute, and running both double-renders every line.

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package mood-line
  :config
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

(use-package dirvish
  :demand t
  :custom
  ;; Upstream ships (file-size) alone, so icons are an explicit opt-in. This
  ;; line is what replaces nerd-icons-dired.
  (dirvish-attributes '(nerd-icons file-size collapse subtree-state vc-state))
  (dirvish-quick-access-entries
   '(("h" "~/"          "home")
     ("n" "~/nixos/"    "nixos")
     ("o" "~/org/"      "org")
     ("r" "~/org/roam/" "roam")))
  :bind
  (;; `d' is the only free letter left under the C-c p project prefix, and a
   ;; project file tree belongs there. which-key already labels C-c p.
   ("C-c p d" . dirvish-side)
   :map dirvish-mode-map
   ("<tab>" . dirvish-subtree-toggle)
   ;; dirvish-override-dired-mode only gives dired the attributes above. The
   ;; parent column and preview pane live in the full-frame layout, which
   ;; nothing enters on its own -- without this, C-x d never previews.
   ("<backtab>" . dirvish-layout-toggle))
  :config
  (dirvish-override-dired-mode))

(use-package project
  :bind
  ("C-c p B" . project-list-buffers)
  ("C-c p k" . project-kill-buffers))

(provide 'qol)
