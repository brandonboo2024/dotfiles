;; -*- lexical-binding: t; -*-

;; Contains many QOL and aesthetic improvements, except theme
;; Most are nice to have, but not necessary. They should be the first
;; to be removed should there be performance/cleanups
;; Theme remains in init.el

;; Vanilla behaviour tweaks
(setq use-short-answers t)
(setq enable-recursive-minibuffers t)
(setq read-extended-command-predicate
      #'command-completion-default-include-p)

(use-package saveplace
  :straight nil
  :hook (after-init . save-place-mode))

(use-package nerd-icons
  :config
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package ibuffer
  :straight nil
  :bind
  ([remap list-buffers] . ibuffer))

(use-package ibuffer-project
  :after ibuffer
  :hook
  (ibuffer . (lambda ()
               (setq ibuffer-filter-groups
                     (ibuffer-project-generate-filter-groups))
               (unless (eq ibuffer-sorting-mode 'project-file-relative)
                 (ibuffer-do-sort-by-project-file-relative)))))

(use-package paren
  :custom
  (show-paren-delay 0.1)
  (show-paren-highlight-openparen t)
  (show-paren-when-point-in-periphery t)
  (show-paren-when-point-inside-paren t)
  :config
  (show-paren-mode 1))

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package mood-line
  :custom
  (mood-line-segment-modal-meow-state-alist
   '((normal . (" NORMAL " . (:inherit mood-line-status-neutral
                            :inverse-video t :weight bold)))
     (insert . (" INSERT " . (:inherit mood-line-status-success
                            :inverse-video t :weight bold)))
     (keypad . (" KEYPAD " . (:inherit mood-line-status-warning
                            :inverse-video t :weight bold)))
     (beacon . (" BEACON " . (:inherit mood-line-status-error
                            :inverse-video t :weight bold)))
     (motion . (" MOTION " . (:inherit mood-line-status-info
                            :inverse-video t :weight bold)))))
  :config
  (setq mood-line-glyph-alist mood-line-glyphs-unicode)
  (mood-line-mode))


(defun my/tab-bar-select-digit ()
  "Select the tab-bar tab named by the digit invoking this command."
  (interactive)
  (tab-bar-select-tab (- last-command-event ?0)))

(use-package tab-bar
  :straight nil
  :custom
  (tab-bar-show 1)
  (tab-bar-close-button-show nil)
  (tab-bar-new-tab-choice "*scratch*")
  :bind (:map my/tabs-map
              ("c" . tab-new)
              ("n" . tab-next)
              ("p" . tab-previous)
              ("l" . tab-recent)
              ("k" . tab-close)
              ("K" . tab-close-other)
              ("," . tab-rename)
              ("w" . tab-switch)
              ("u" . tab-undo))
  :config
  (dotimes (i 9)
    (define-key my/tabs-map
                (number-to-string (1+ i))
                #'my/tab-bar-select-digit))
  (tab-bar-mode 1))

;; Nicer dired
(use-package dirvish
  :demand t
  :custom
  ;; Upstream ships (file-size) alone, so icons are an explicit opt-in. This
  ;; line is what replaces nerd-icons-dired.
  (dirvish-attributes '(nerd-icons file-size collapse subtree-state vc-state))
  (dirvish-quick-access-entries
   '(("h" "~/"          "home")
     ("n" "~/nixos/"    "nixos")
     ("o" "~/org/"      "org")))
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
  :straight nil
  :bind
  ("C-c p B" . project-list-buffers)
  ("C-c p p" . project-switch-project)
  ("C-c p k" . project-kill-buffers))

(provide 'qol)
