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
(electric-pair-mode 1)

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
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

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

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

(use-package visual-fill-column
  :commands (visual-fill-column-mode))

(use-package adaptive-wrap
  :commands (adaptive-wrap-prefix-mode))

(defun my/prose-wrap-setup ()
  "Soft-wrap at `fill-column', flush left, wrapping on word boundaries."
  (visual-line-mode 1)
  (visual-fill-column-mode 1))

(defun my/markdown-wrap-setup ()
  "Enable prose wrapping plus continuation indentation for Markdown.
Adaptive-wrap is not used for Org because it would replace Org's
heading-aware and list-aware `wrap-prefix'."
  (my/prose-wrap-setup)
  (adaptive-wrap-prefix-mode 1))

(defun my/prose-wrap-toggle ()
  "Toggle soft-wrapped prose against truncated lines, for wide tables.
Disable `visual-fill-column-mode' as well so truncated lines use the full
window width. In Org, prefer C-c TAB (`org-table-toggle-column-width') when
only a table needs to be narrowed."
  (interactive)
  (if visual-line-mode
      (progn
        (visual-fill-column-mode -1)
        (when (bound-and-true-p adaptive-wrap-prefix-mode)
          (adaptive-wrap-prefix-mode -1))
        (visual-line-mode -1)
        (setq truncate-lines t))
    (setq truncate-lines nil)
    (if (derived-mode-p 'markdown-mode)
        (my/markdown-wrap-setup)
      (my/prose-wrap-setup))))

(define-key mode-specific-map "w" #'my/prose-wrap-toggle)

(add-hook 'markdown-mode-hook #'my/markdown-wrap-setup)
(add-hook 'org-mode-hook #'my/prose-wrap-setup)

(use-package gcmh
  :init
  (setq gcmh-idle-delay 'auto
        gcmh-high-cons-threshold (* 64 1024 1024))
  :hook (after-init . gcmh-mode))

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

;; centaur-tabs groups project buffers; tab-bar provides workspaces; popper
;; owns transient buffers. Three separate axes, no overlap.

(defun my/centaur-tabs-buffer-groups ()
  "Group tabs by the current project.el project."
  (list (if-let* ((project (project-current)))
            (project-name project)
          "Common")))

;; eat-mode used to be here. Terminals are popper popups now, so a tab for one
;; would be a second, contradictory way to reach the same buffer.
(defvar my/centaur-tabs-extra-modes '(dired-mode)
  "Non-file-visiting modes that still earn a tab.")

(defun my/centaur-tabs-eligible-p (buffer)
  "Return non-nil when BUFFER should appear as a tab."
  (and (not (string-prefix-p " " (buffer-name buffer)))
       (or (buffer-file-name buffer)
           (with-current-buffer buffer
             (apply #'derived-mode-p my/centaur-tabs-extra-modes)))))

(defun my/centaur-tabs-buffer-list ()
  "Return buffers eligible to appear as tabs."
  (seq-filter #'my/centaur-tabs-eligible-p (buffer-list)))

(defun my/centaur-tabs-hide-tab (buffer)
  "Return non-nil when the tab row should be hidden for BUFFER."
  (or (not (my/centaur-tabs-eligible-p buffer))
      (when-let* ((window (get-buffer-window buffer)))
        (window-dedicated-p window))))

(defun my/centaur-tabs-refresh-bar (&optional frame)
  "Rebuild the active-tab bar and separators for FRAME.
centaur-tabs builds graphical assets when it loads, which leaves daemon
sessions without them until a graphical frame exists."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (setq centaur-tabs-active-bar
            (centaur-tabs--make-xpm 'centaur-tabs-active-bar-face
                                    2 centaur-tabs-bar-height)
            centaur-tabs-set-bar (and centaur-tabs-active-bar 'left))
      (centaur-tabs--after-load-theme))))

(use-package centaur-tabs
  :demand t
  :custom
  (centaur-tabs-style "bar")
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'nerd-icons)
  (centaur-tabs-set-modified-marker t)
  (centaur-tabs-modified-marker "●")
  (centaur-tabs-cycle-scope 'tabs)
  (centaur-tabs-show-navigation-buttons nil)
  (centaur-tabs-show-new-tab-button nil)
  :bind (("C-<tab>" . centaur-tabs-forward)
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
  "Select the tab-bar tab named by the digit invoking this command."
  (interactive)
  (tab-bar-select-tab (- last-command-event ?0)))

;; Load after centaur-tabs so tab-bar does not claim C-<tab>.
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

(defun my/popper-gptel-p (&optional buffer)
  "Return non-nil when BUFFER is a gptel chat buffer.
gptel-mode is a minor mode, so it cannot go in `popper-reference-buffers'
as a mode symbol -- popper only matches those against `major-mode'. The
optional argument is deliberate: popper has called predicates both with the
buffer and with it merely current, and this shape survives either."
  (with-current-buffer (or buffer (current-buffer))
    (bound-and-true-p gptel-mode)))

(defun my/popper-cleanup ()
  "Kill every popup buffer whose process has finished.
A day of builds and one-off commands leaves a long cycle of dead
*compilation* and *async: ...* buffers. This reaps them in one go.

Anything still running -- a live terminal, a build in progress, a long
command -- is kept, so this is safe to run at any moment. File-visiting
buffers are skipped outright: `popper-toggle-type' can promote one to a
popup, and killing it could discard real work."
  (interactive)
  (let ((killed 0))
    (dolist (buffer (buffer-list))
      (when (and (popper-popup-p buffer)
                 (not (buffer-file-name buffer))
                 (let ((process (get-buffer-process buffer)))
                   (or (null process)
                       (not (memq (process-status process) '(run stop))))))
        (kill-buffer buffer)
        (setq killed (1+ killed))))
    (popper--update-popups)
    (message "Killed %d finished popup%s" killed (if (= killed 1) "" "s"))))

(use-package popper
  :demand t
  :init
  ;; `popper-group-by-project' signals a user-error unless `project-root' is
  ;; already fboundp, and popper calls it while enabling popper-mode; without
  ;; this the :config block aborts and popper-echo-mode is silently never on.
  ;; Loading a built-in here is safe only because init.el pseudo-packages it.
  (require 'project)
  :custom
  (popper-reference-buffers
   '(eat-mode
     compilation-mode
     my/popper-gptel-p
     ;; "\\*async: " is my/async-shell-command; the other two are what vanilla
     ;; M-& and M-! produce.
     "^\\*async: "
     "\\*Async Shell Command\\*"
     "\\*Shell Command Output\\*"
     "\\*Backtrace\\*"
     "\\*Warnings\\*"
     ;; A `hide' entry is classified as a popup but never raised. These two are
     ;; pure build noise -- straight rebuilds a package and the log window lands
     ;; on top of whatever is being read. They stay reachable via C-x b, and
     ;; C-c s c cycles to them.
     ("\\*Native-compile-Log\\*" . hide)
     ("\\*Async-native-compile-log\\*" . hide)
     ("\\*Compile-Log\\*" . hide)
     ("\\*straight-process\\*" . hide)))
  ;; popper-window-height is deliberately left at its default,
  ;; `popper--fit-window-height', which scales to the buffer and caps at a
  ;; third of the frame. It wants chars or a function, not a fraction.
  ;;
  ;; Terminals are named per project by `eat-project', so grouping keeps
  ;; C-c s c cycling inside the current project instead of across all of them.
  (popper-group-function #'popper-group-by-project)
  :bind (;; Bound twice on purpose: C-` is the muscle-memory key but does not
         ;; reliably reach Emacs through a terminal, and C-c s s always does.
         ("C-`" . popper-toggle)
         :map my/shell-map
         ("s" . popper-toggle)
         ("c" . popper-cycle)
         ("C" . popper-cycle-backwards)
         ("p" . popper-toggle-type)
         ;; k kills the one in front of you, K reaps every finished one.
         ;; C-u C-u C-c s s buries them all without killing anything.
         ("k" . popper-kill-latest-popup)
         ("K" . my/popper-cleanup))
  :config
  (popper-mode 1)
  (popper-echo-mode 1))

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
  :straight nil
  :bind
  ("C-c p B" . project-list-buffers)
  ("C-c p p" . project-switch-project)
   ("C-c p k" . project-kill-buffers))

(provide 'qol)
