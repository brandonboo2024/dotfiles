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

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package visual-fill-column
  :commands (visual-fill-column-mode)
  :custom
  (visual-fill-column-center-text t))

(use-package adaptive-wrap
  :commands (adaptive-wrap-prefix-mode))

(defun my/prose-wrap-setup ()
  "Soft-wrap at `fill-column', centered, wrapping on word boundaries."
  (visual-line-mode 1)
  (visual-fill-column-mode 1))

(defun my/markdown-wrap-setup ()
  "As `my/prose-wrap-setup', plus the continuation indent that org gets from
`org-indent-mode' - adaptive-wrap would clobber org's own `wrap-prefix', which
is heading-aware as well as list-aware, so it is markdown-only."
  (my/prose-wrap-setup)
  (adaptive-wrap-prefix-mode 1))

;; gfm-mode derives from markdown-mode, so README.md is covered too.
(add-hook 'markdown-mode-hook #'my/markdown-wrap-setup)
(add-hook 'org-mode-hook #'my/prose-wrap-setup)

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
  (mood-line-segment-modal-meow-state-alist
   '((normal . (" NORMAL " . (:inherit mood-line-status-neutral :inverse-video t :weight bold)))
     (insert . (" INSERT " . (:inherit mood-line-status-success :inverse-video t :weight bold)))
     (keypad . (" KEYPAD " . (:inherit mood-line-status-warning :inverse-video t :weight bold)))
     (beacon . (" BEACON " . (:inherit mood-line-status-error   :inverse-video t :weight bold)))
     (motion . (" MOTION " . (:inherit mood-line-status-info    :inverse-video t :weight bold)))))
  :config
  (mood-line-mode))

;; centaur-tabs = buffers of the current project, on C-<tab>.
;; tab-bar = workspaces, on the C-c t (SPC t) prefix, tmux-style.

(defun my/centaur-tabs-buffer-groups ()
  "Group tabs by project.el project; centaur-tabs' default wants projectile."
  (list (if-let* ((proj (project-current)))
            (project-name proj)
          "Common")))

(defvar my/centaur-tabs-extra-modes '(eat-mode dired-mode)
  "Non-file-visiting modes that still earn a tab (dirvish derives from dired).")

(defun my/centaur-tabs-eligible-p (buffer)
  "Non-nil if BUFFER earns a tab.
A whitelist: packages name working buffers whatever they like (dirvish's
`*dirvish-batch*<random>'), so blacklisting names never ends."
  (and (not (string-prefix-p " " (buffer-name buffer)))
       (or (buffer-file-name buffer)
           (with-current-buffer buffer
             (apply #'derived-mode-p my/centaur-tabs-extra-modes)))))

(defun my/centaur-tabs-buffer-list ()
  "Buffers eligible for a tab.
This, not `centaur-tabs-hide-tab-function', decides membership - that one
is consulted only for the current buffer, to draw the row or not."
  (seq-filter #'my/centaur-tabs-eligible-p (buffer-list)))

(defun my/centaur-tabs-hide-tab (buffer)
  "Non-nil if the tab row should be suppressed in BUFFER's window.
Membership predicate plus dedicated windows - `dirvish-side' is too narrow."
  (or (not (my/centaur-tabs-eligible-p buffer))
      (when-let* ((win (get-buffer-window buffer)))
        (window-dedicated-p win))))

(defun my/centaur-tabs-refresh-bar (&optional frame)
  "Rebuild the active-tab bar and the separators for FRAME.
centaur-tabs bakes both at load time behind `display-graphic-p', so under
`emacs --daemon' they are nil/unthemed forever.  `centaur-tabs-set-bar' is
assigned only here, so it can never be `left' while the image is missing."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (setq centaur-tabs-active-bar
            (centaur-tabs--make-xpm 'centaur-tabs-active-bar-face
                                    2 centaur-tabs-bar-height)
            centaur-tabs-set-bar (and centaur-tabs-active-bar 'left))
      ;; centaur-tabs' only cache invalidator; also picks up `centaur-tabs-style'.
      (centaur-tabs--after-load-theme))))

(use-package centaur-tabs
  :demand t
  :custom
  (centaur-tabs-style "bar")
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-modified-marker "●")
  (centaur-tabs-cycle-scope 'tabs) ;; C-<tab> stays inside the current group
  (centaur-tabs-show-navigation-buttons nil)
  (centaur-tabs-show-new-tab-button nil)
  :bind (("C-<tab>" . centaur-tabs-forward)
         ;; One chord, three spellings: GUI sends <iso-lefttab>, kkp <backtab>.
         ("C-S-<tab>" . centaur-tabs-backward)
         ("C-S-<iso-lefttab>" . centaur-tabs-backward)
         ("C-<backtab>" . centaur-tabs-backward)
         :map my/tabs-map
         ("g" . centaur-tabs-switch-group)
         ("[" . centaur-tabs-backward-group)
         ("]" . centaur-tabs-forward-group)
         ("<" . centaur-tabs-move-current-tab-to-left)
         (">" . centaur-tabs-move-current-tab-to-right)
         ("o" . centaur-tabs-kill-other-buffers-in-current-group))
  :config
  (setq centaur-tabs-buffer-groups-function #'my/centaur-tabs-buffer-groups
        centaur-tabs-buffer-list-function #'my/centaur-tabs-buffer-list
        centaur-tabs-hide-tab-function #'my/centaur-tabs-hide-tab)
  (centaur-tabs-mode 1)
  (add-hook 'server-after-make-frame-hook #'my/centaur-tabs-refresh-bar)
  (add-hook 'after-make-frame-functions #'my/centaur-tabs-refresh-bar)
  (my/centaur-tabs-refresh-bar))

(defun my/tab-bar-select-digit ()
  "Select the tab-bar tab named by the digit that invoked this command."
  (interactive)
  (tab-bar-select-tab (- last-command-event ?0)))

;; Must load after centaur-tabs: tab-bar grabs C-<tab> only if nothing else has.
(use-package tab-bar
  :straight nil
  :custom
  (tab-bar-show 1)              ;; the row appears only once there are 2+ tabs
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
  ;; C-c t 1..9 jump to a workspace; one named command beats nine lambdas, which
  ;; meow's keypad popup would list as nine "?closure" entries.
  (dotimes (i 9)
    (define-key my/tabs-map (number-to-string (1+ i)) #'my/tab-bar-select-digit))
  (tab-bar-mode 1))

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
