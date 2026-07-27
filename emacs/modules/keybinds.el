;; -*- lexical-binding: t; -*-

(defvar consult-fd-args)
(defvar consult-async-min-input)

;; Named prefix keymaps under C-c (= meow's SPC leader). Symbols, not the
;; anonymous maps `define-key' implies, so meow's keypad popup can label them.
(define-prefix-command 'my/org-map)
(define-prefix-command 'my/project-map)
(define-prefix-command 'my/tabs-map)
(define-key mode-specific-map "o" 'my/org-map)
(define-key mode-specific-map "p" 'my/project-map)
(define-key mode-specific-map "t" 'my/tabs-map)

(defun match-paren(arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun my/list-unsaved-buffers ()
  "List files/buffers with unsaved changes."
  (interactive)
  (let ((unsaved
         (seq-filter
          (lambda (buf)
          (with-current-buffer buf
            (and buffer-file-name
                 (buffer-modified-p))))
         (buffer-list))))
  (if unsaved
      (message "Unsaved %s"
               (mapconcat #'buffer-name unsaved ", "))
    (message "No unsaved file buffers."))))

(defun my/global-fd ()
  "Find ALL files, including ignored ones"
  (interactive)
  (let ((consult-fd-args '("fd" "--no-ignore" "--full-path" "--color=never")))
    (call-interactively #'consult-fd)))

(defun my/project-fd ()
  "Find Files in Project, with no min-input"
  (interactive)
  (let ((consult-async-min-input -1))
    (consult-fd (project-root (project-current t)))))

(defun simple-scroll-down ()
  "Move half a screen below."
  (interactive)
  (forward-line (floor (window-height) 2))
  (setq this-command 'scroll-up-command))

(defun simple-scroll-up ()
  "Move half a screen above."
  (interactive)
  (forward-line (- (floor (window-height) 2)))
  (setq this-command 'scroll-down-command))

(global-set-key (kbd "C-v") #'simple-scroll-down)
(global-set-key (kbd "M-v") #'simple-scroll-up)

;; Built-in linear redo. It already lives on C-? and C-M-_, both awkward over a
;; TTY; M-_ is unbound and mnemonic. (vundo on C-x u covers the tree case.)
(global-set-key (kbd "M-_") #'undo-redo)

(global-set-key (kbd "C-c u") #'my/list-unsaved-buffers)
(global-set-key "%" 'match-paren)

(global-set-key (kbd "M-o") #'other-window)

(provide 'keybinds)
