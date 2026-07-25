;; -*- lexical-binding: t; -*-

;; These two are defcustoms in consult, which is loaded lazily. Declaring them
;; special HERE, before anything below binds them, is what makes the `let's in
;; the search commands dynamic rather than lexical.
;;
;; Both failure modes this avoids are quiet ones. Without a declaration, `let'
;; creates a lexical binding that consult never reads, so the extra arguments
;; are silently ignored. And if consult happens to load after a lexical
;; binding has already been established for the symbol, its defcustom errors
;; with "Defining as dynamic an already lexical var" -- which is why such a
;; command can appear to start working only after some other consult command
;; has been run first.
;;
;; Keep these at the top of the file, above every use.
(defvar consult-fd-args)
(defvar consult-ripgrep-args)

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

;;; Searching: project vs global
;;
;; Project commands search the current project and respect ignore files --
;; that is consult's own default behaviour, so they add nothing.
;; Global commands search under `my/global-search-root' and additionally look
;; inside ignored and hidden files.

(defvar my/global-search-root "~/"
  "Directory the global search commands start from.")

(defvar my/global-search-args '("--no-ignore" "--hidden")
  "Extra arguments the global search commands add to fd and ripgrep.")

(defun my/append-args (args extra)
  "Append EXTRA, a list of strings, to ARGS.
`consult-fd-args' is a list while `consult-ripgrep-args' is a string, and
either may be customised into the other form, so handle both."
  (if (stringp args)
      (concat args " " (string-join extra " "))
    (append args extra)))

(defun my/project-fd ()
  "Find files in the current project."
  (interactive)
  (require 'consult)
  (consult-fd nil))

(defun my/global-fd ()
  "Find files under `my/global-search-root', including ignored ones."
  (interactive)
  (require 'consult)
  (let ((consult-fd-args (my/append-args consult-fd-args my/global-search-args)))
    (consult-fd my/global-search-root)))

(defun my/project-rg ()
  "Search the current project with ripgrep."
  (interactive)
  (require 'consult)
  (consult-ripgrep nil))

(defun my/global-rg ()
  "Search under `my/global-search-root' with ripgrep, including ignored files."
  (interactive)
  (require 'consult)
  (let ((consult-ripgrep-args
         (my/append-args consult-ripgrep-args my/global-search-args)))
    (consult-ripgrep my/global-search-root)))

(defun my/open-project-forge ()
  "Open the current project's forge page in the default browser."
  (interactive)
  (require 'project)
  (let* ((project (project-current))
         (directory
          (if project
              (project-root project)
            default-directory))
         (output (generate-new-buffer " *open-project-forge*"))
         status)
    (unwind-protect
        (progn
          (setq status
                (call-process "open-github" nil output nil directory))
          (if (and (integerp status) (zerop status))
              (message "Opened forge page for %s" directory)
            (user-error
             "%s"
             (string-trim
              (with-current-buffer output (buffer-string))))))
      (kill-buffer output))))

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
(global-set-key (kbd "M-o") #'other-window)

(global-set-key (kbd "C-c u") #'my/list-unsaved-buffers)
(global-set-key "%" 'match-paren)

(define-prefix-command 'my/git-prefix-map)
(global-set-key (kbd "C-c g") 'my/git-prefix-map)
(define-key my/git-prefix-map (kbd "o") #'my/open-project-forge)

(provide 'keybinds)
