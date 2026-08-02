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

(defun my/open-project-agent-session ()
  "Open or attach this project's native agent tmux session in Foot."
  (interactive)
  (let* ((project (project-current t))
         (root (project-root project))
         (config-home (or (getenv "XDG_CONFIG_HOME")
                          (expand-file-name "~/.config")))
         (launcher (expand-file-name "scripts/agent-session" config-home)))
    (when (file-remote-p root)
      (user-error "Agent sessions require a local project"))
    (unless (file-executable-p launcher)
      (user-error "Agent session launcher is not executable: %s" launcher))
    (let ((process (start-process "agent-session" nil launcher root)))
      (set-process-query-on-exit-flag process nil))))

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
;; match-paren is bound in meow-config.el, not here. meow builds its normal
;; state keymap with (suppress-keymap map t), which rebinds every
;; self-inserting character to `undefined' -- so a global binding on "%" is
;; shadowed the moment meow-global-mode is on. Modified keys such as the C-v
;; and M-v above are unaffected.

(define-prefix-command 'my/git-prefix-map)
(global-set-key (kbd "C-c g") 'my/git-prefix-map)
(define-key my/git-prefix-map (kbd "o") #'my/open-project-forge)

(provide 'keybinds)
