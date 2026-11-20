;; -*- lexical-binding: t; -*-

;; Modal editing. Key tables and the package declaration live together so
;; `meow-setup' is always defined before `use-package meow' calls it.
;;
;; Not named meow.el: it would shadow straight's meow.el on `load-path'.

;;; Org things
;;
;; Meow's `,' `.' `[' `]' act on a "thing" picked by the next key. h and t are
;; unused by default, so they select Org headings and subtrees.

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

  ;; SPC is the keypad, which dispatches to C-c (see below), so every C-c
  ;; prefix is SPC <key>: SPC o org, SPC l eglot, SPC p project, SPC b build.
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
   ;; Upstream binds both Q and X to meow-goto-line; X keeps it, Q starts a
   ;; macro (meow already remaps the end/call side).
   '("Q" . kmacro-start-macro-or-insert-counter)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   ;; Redo, in place of meow-undo-in-selection.
   '("U" . undo-fu-only-redo)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   ;; Must be bound here: normal state suppresses self-inserting keys.
   '("%" . match-paren)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :custom
  (meow-keypad-leader-dispatch "C-c")
  ;; The keypad reserves g for C-M-, which hid the C-c g git prefix. Move it
  ;; to G. m (M-) and SPC (literal) stay reserved: never bind C-c m or C-c SPC.
  (meow-keypad-ctrl-meta-prefix ?G)
  :config
  (setq meow-cursor-type-insert 'box
        meow-cursor-type-keypad 'box
        meow-cursor-type-region-cursor 'box)
  (meow-setup)
  (meow-global-mode 1)

  ;; Meow hooks its which-key integration onto which-key-mode-hook, which has
  ;; already run (core.el loads first), so enable it by hand.
  (when (bound-and-true-p which-key-mode)
    (meow--which-key-describe-keymap))

  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements global-map
      "C-c p"   "project"
      "C-c e"   "external"
      "C-c g"   "git"
      "C-c b"   "build"
      "C-c t"   "tabs"
      "C-c o"   "org"
      "C-c n"   "notes"
      "C-c a"   "ai"))

  ;; Start terminals in insert state.
  (add-to-list 'meow-mode-state-list '(ghostel-mode . insert)))

;; Notmuch has its own single-key bindings, so meow is turned off there.
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

;; Not a mode hook: meow-global-mode re-enables meow on
;; `after-change-major-mode-hook', which runs after mode hooks. Depth 90 runs
;; this after meow's own function.
(add-hook 'after-change-major-mode-hook #'my/meow-disable-in-viewer-modes 90)

(provide 'meow-config)
