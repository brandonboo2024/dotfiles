;; -*- lexical-binding: t; -*-

;; Modal editing via meow, vanilla Qwerty layout.
;;
;; meow layers states on top of the existing global map rather than replacing
;; it, so everything bound elsewhere in this config keeps working unchanged:
;; C-x, C-s (consult-line), C-. (embark), M-o, C-v/M-v, C-x g (magit).
;;
;; The SPC leader dispatches to C-c, so every prefix set up elsewhere comes
;; along for free:
;;   SPC o ...  -> C-c o ...  (org)
;;   SPC p ...  -> C-c p ...  (project)
;;   SPC l ...  -> C-c l ...  (eglot)
;;   SPC t ...  -> C-c t ...  (tabs / workspaces)
;; SPC ? shows the cheatsheet, SPC / describes what a keypad chord resolved to.
;;
;; NOTE: this file is meow-config.el, not meow.el - a modules/meow.el would
;; shadow the package's own meow.el on `load-path'.

(defun my/meow-keypad-title (def)
  "Render a `my/foo-map' prefix keymap as `+foo' in the keypad popup.
Uninterned on purpose: an interned `org' may be a command, which prints
differently."
  (let ((name (and (symbolp def) (symbol-name def))))
    (if (and name (string-match "\\`my/\\(.+\\)-map\\'" name))
        (make-symbol (match-string 1 name))
      (meow-keypad-get-title def))))

(defun my/meow-redo ()
  "Cancel current selection then redo.
Mirror of `meow-undo' - meow's Qwerty layout has no redo of its own,
so U (normally `meow-undo-in-selection') is given over to it below.

`undo-fu-only-redo' does call `deactivate-mark' itself, but that is not
enough here: `meow--cancel-selection' additionally clears
`meow--selection' and `meow--selection-history', without which `z'
\(`meow-pop-selection') can pop to a selection the undo has invalidated."
  (interactive)
  (when (region-active-p)
    (meow--cancel-selection))
  (undo-fu-only-redo))

;; Verbatim from upstream KEYBINDING_QWERTY.org, except U (see my/meow-redo)
(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . my/meow-redo)         ;; was meow-undo-in-selection
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :demand t
  :custom
  ;; A string keeps `meow--keypad-base-keymap' nil so lookups go through
  ;; `key-binding'; with nil, minor-mode C-c maps (eglot's C-c l) are invisible.
  (meow-keypad-leader-dispatch "C-c")
  ;; Frees SPC m / SPC g for C-c m / C-c g; default m/g are eaten as M- and C-M-.
  (meow-keypad-meta-prefix ?M)
  (meow-keypad-ctrl-meta-prefix ?G)
  :config
  (setq meow-keypad-get-title-function #'my/meow-keypad-title)
  (meow-setup)
  ;; Terminals must accept raw keys - normal state would eat every keystroke.
  ;; magit/dired/ibuffer and most special-mode derivatives are already covered
  ;; by meow's defaults (check with C-h v meow-mode-state-list); these are the
  ;; gaps for packages meow doesn't ship knowledge of.
  (dolist (entry '((eat-mode . insert)
                   (agent-shell-mode . insert)))
    (add-to-list 'meow-mode-state-list entry))
  (meow-global-mode 1))

(provide 'meow-config)
