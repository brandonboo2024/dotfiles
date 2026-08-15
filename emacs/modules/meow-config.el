;; -*- lexical-binding: t; -*-

;; Modal editing. This module owns both the key tables and the package
;; declaration, because `meow-setup' must exist before `use-package meow' runs
;; its :config. Splitting them (the tables were in keybinds.el, the package in
;; extend.el) made that ordering depend on the require sequence in init.el,
;; which happened to be correct and would have broken silently if reordered.
;;
;; Deliberately NOT named meow.el. `modules/' goes on `load-path' next to
;; straight's build directories, both via add-to-list, which prepends. A
;; modules/meow.el would race straight/build/meow/meow.el and whichever lost
;; would simply never load.

;;; Org things
;;
;; meow's `,' `.' `[' `]' operate on a "thing" chosen by the next key.
;; `meow-char-thing-table' ships r/s/c/g/e/w/b/p/l/v/d/. -- h and t are free,
;; so headings and subtrees go there. Org is the mode most of this config's
;; text editing happens in, so this is the single customization that pays.

(defun my/meow-bounds-of-org-subtree ()
  "Return the bounds of the Org subtree at point, heading line included."
  (when (derived-mode-p 'org-mode)
    (ignore-errors
      (save-excursion
        (org-back-to-heading t)
        (cons (point)
              (save-excursion (org-end-of-subtree t t) (point)))))))

(defun my/meow-inner-of-org-subtree ()
  "Return the body of the Org subtree at point, heading line excluded."
  (when (derived-mode-p 'org-mode)
    (ignore-errors
      (save-excursion
        (org-back-to-heading t)
        (let ((beginning (progn (forward-line 1) (point)))
              (end (progn (org-end-of-subtree t t) (point))))
          (cons (min beginning end) end))))))

(defun meow-setup ()
  "Define meow's key tables and register the Org things."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)

  (meow-thing-register 'heading
                       '(regexp "^\\*+ +" "$")
                       '(regexp "^\\*+ +" "$"))
  (meow-thing-register 'subtree
                       #'my/meow-inner-of-org-subtree
                       #'my/meow-bounds-of-org-subtree)
  (add-to-list 'meow-char-thing-table '(?h . heading))
  (add-to-list 'meow-char-thing-table '(?t . subtree))

  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))

  ;; SPC is meow-keypad, not a leader map of its own. With
  ;; `meow-keypad-leader-dispatch' set to "C-c" below, every key here that is
  ;; not a keypad start key (c/h/x) dispatches into the C-c map, so the
  ;; prefixes the rest of this config already defines -- C-c o for org, C-c l
  ;; for eglot, C-c p for project, C-c b for build -- are reachable as SPC o,
  ;; SPC l, SPC p, SPC b. Nothing needs to be redefined here to keep them.
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
   ;; Upstream's QWERTY table binds both Q and X to meow-goto-line
   ;; (KEYBINDING_QWERTY.org lines 74 and 85). X keeps it -- it pairs with x
   ;; for line -- and Q takes the macro start. meow already installs remaps
   ;; for meow-end-or-call-kmacro, so only the start side was missing.
   '("Q" . kmacro-start-macro-or-insert-counter)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   ;; undo-fu's redo. Displaces meow-undo-in-selection, which is a narrower
   ;; command than having any redo at all in normal state.
   '("U" . undo-fu-only-redo)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   ;; Normal state suppresses self-inserting keys, so this cannot live in a
   ;; global-set-key the way it used to.
   '("%" . match-paren)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :custom
  (meow-keypad-leader-dispatch "C-c")
  ;; Keypad reserves three characters as modifier prefixes, and upstream puts
  ;; C-M- on lowercase g. That silently ate C-c g: the git prefix vanished
  ;; from the SPC popup entirely and SPC g o produced C-M-o instead of
  ;; my/open-project-forge. Uppercase G keeps C-M- reachable as SPC G x while
  ;; freeing the letter.
  ;;
  ;; The other two reservations still stand, so do NOT create a C-c m or a
  ;; C-c SPC binding: m is meow-keypad-meta-prefix (SPC m x = M-x) and SPC is
  ;; meow-keypad-literal-prefix. Everything else in C-c is fair game.
  (meow-keypad-ctrl-meta-prefix ?G)
  :config
  (setq meow-cursor-type-insert 'box
        meow-cursor-type-keypad 'box
        meow-cursor-type-region-cursor 'box)
  (meow-setup)
  (meow-global-mode 1)

  ;; meow ships a which-key integration, but installs it by adding to
  ;; which-key-mode-hook -- which has already run, because core.el turns
  ;; which-key on and loads before this file. So the hook never fires and
  ;; meow falls back to its own popup, which labels every prefix "+prefix"
  ;; with no way to name them. Running it once here activates the real thing.
  (when (bound-and-true-p which-key-mode)
    (meow--which-key-describe-keymap))

  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements global-map
      "C-c p"   "project"
      "C-c e"   "external"
      "C-c g"   "git"
      "C-c b"   "build"
      "C-c t"   "tabs"))

  ;; Terminal input should work immediately without entering Meow insert state
  ;; by hand.
  (add-to-list 'meow-mode-state-list '(eat-mode . insert)))

;; Disable meow for notmuch
(defvar my/meow-disabled-modes
  '(notmuch-hello-mode
    notmuch-search-mode
    notmuch-show-mode
    notmuch-tree-mode)
  "Major modes where `meow-mode' is switched off completely.")

(defun my/meow-disable-in-viewer-modes ()
  "Turn `meow-mode' off in `my/meow-disabled-modes' buffers."
  (when (and meow-mode (apply #'derived-mode-p my/meow-disabled-modes))
    (meow-mode -1)))

;; Depth 90 rather than a mode hook. `meow-global-mode' installs its own
;; enable function on `after-change-major-mode-hook', which runs *after* every
;; major-mode hook -- a `(meow-mode -1)' in notmuch-search-mode-hook would be
;; undone a moment later. Appending to the same hook puts this after it.
(add-hook 'after-change-major-mode-hook #'my/meow-disable-in-viewer-modes 90)

(provide 'meow-config)
