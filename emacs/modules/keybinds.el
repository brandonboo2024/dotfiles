;; -*- lexical-binding: t; -*-

;; These three are defcustoms in consult, which is loaded lazily. Declaring
;; them special HERE, before anything below binds them, is what makes the
;; `let's in the search commands dynamic rather than lexical.

;; Keep these at the top of the file, above every use.
(defvar consult-fd-args)
(defvar consult-ripgrep-args)
(defvar consult-async-min-input)

(define-prefix-command 'my/tabs-map)
(define-key mode-specific-map "t" 'my/tabs-map)

;; Shell/terminal prefix. Declared here rather than in extend.el because both
;; extend.el (eat) and qol.el (popper) bind into it, and this file loads first.
(define-prefix-command 'my/shell-map)
(define-key mode-specific-map "s" 'my/shell-map)

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
  ;; Default 3 means the minibuffer opens empty and nothing previews until
  ;; three characters are typed. A project is small and already
  ;; ignore-filtered, so list it all immediately. Not done for my/global-fd
  ;; (fd --no-ignore --hidden from ~/) or either ripgrep command, where an
  ;; empty pattern matches every line of every file.
  (let ((consult-async-min-input 0))
    (consult-fd nil)))

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

(defun my/eat-project (&optional arg)
  "Open this project's eat terminal, or a plain one outside a project.
`eat-project' calls (project-current t), which signals rather than falling
back, so a terminal could not be opened from a non-project buffer at all.
ARG is passed through: non-numeric creates a new session, numeric selects
the session with that number."
  (interactive "P")
  (require 'eat)
  (if (project-current)
      (eat-project arg)
    (eat nil arg)))

(defun my/shell-command-root ()
  "Return the current project's root, or `default-directory' outside one."
  (if-let* ((project (project-current)))
      (project-root project)
    default-directory))

(defun my/async-shell-command (command &optional output-buffer)
  "Run COMMAND asynchronously from the project root.
OUTPUT-BUFFER is passed through from the prefix argument, as in
`async-shell-command'.

The output buffer is named after COMMAND. Vanilla reuses one name and
`async-shell-command-buffer' is set to `new-buffer', so three background
jobs would otherwise be *Async Shell Command*, <2> and <3> -- unreadable
in the popper cycle. Two runs of the same command still get a <2> suffix."
  (interactive (list (read-shell-command "Async shell command: ")
                     current-prefix-arg))
  (let* ((default-directory (my/shell-command-root))
         (shell-command-buffer-name-async
          (format "*async: %s*"
                  (truncate-string-to-width command 40 nil nil t))))
    (async-shell-command command output-buffer)))

(defun my/shell-command ()
  "Run `shell-command' synchronously from the project root.
Output lands in *Shell Command Output*, which popper treats as a popup."
  (interactive)
  (let ((default-directory (my/shell-command-root)))
    (call-interactively #'shell-command)))

(defun my/forge-url-from-remote (remote)
  "Return the web URL for a supported Git REMOTE."
  (let (host path)
    (cond
     ((string-match
       "\\`\\(?:https?\\|ssh\\)://\\(?:[^/@]+@\\)?\\([^/]+\\)/\\(.+\\)\\'"
       remote)
      (setq host (match-string 1 remote)
            path (match-string 2 remote)))
     ((string-match
       "\\`\\(?:[^@/:]+@\\)?\\([^/:]+\\):\\(.+\\)\\'"
       remote)
      (setq host (match-string 1 remote)
            path (match-string 2 remote)))
     (t
      (user-error "Unsupported origin URL: %s" remote)))
    (unless (member host '("github.com" "codeberg.org" "git.sr.ht"))
      (user-error "Unsupported forge host: %s" host))
    (setq path (string-remove-suffix
                ".git"
                (string-remove-suffix "/" path)))
    (when (string-empty-p path)
      (user-error "Malformed origin URL: %s" remote))
    (format "https://%s/%s" host path)))

(defun my/open-project-forge ()
  "Open the current Git repository's forge page in the default browser."
  (interactive)
  (require 'browse-url)
  (require 'vc-git)
  (let ((root (vc-git-root default-directory)))
    (unless root
      (user-error "Current directory is not in a Git repository"))
    (let ((remote
           (condition-case nil
               (vc-git-repository-url root "origin")
             (error nil))))
      (unless remote
        (user-error "Git repository has no origin remote"))
      (browse-url
       (my/forge-url-from-remote (string-trim remote))))))

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

(define-key my/shell-map (kbd "a") #'my/async-shell-command)
(define-key my/shell-map (kbd "!") #'my/shell-command)

(define-prefix-command 'my/git-prefix-map)
(global-set-key (kbd "C-c g") 'my/git-prefix-map)
(define-key my/git-prefix-map (kbd "o") #'my/open-project-forge)

(provide 'keybinds)
