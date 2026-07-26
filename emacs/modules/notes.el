;; -*- lexical-binding: t; -*-

;; org-roam is the notes system. The Obsidian vault is frozen: it stays
;; readable as an archive, but nothing new goes into it, and notes are not
;; being migrated across. Look there for anything older than the switch.

(defvar my/org-directory (file-truename "~/org/"))
(defvar my/org-roam-directory (expand-file-name "roam/" my/org-directory))

(defun my/org-confirm-babel-evaluate (_lang _body)
  "Return nil (no prompt) only for Org files under `my/org-directory'."
  (not (and buffer-file-name
            (string-prefix-p (file-name-as-directory my/org-directory)
                             (file-truename buffer-file-name)))))

(defun my/org-file(path)
  (expand-file-name path my/org-directory))

(use-package org
  :straight nil
  :custom
  (org-directory my/org-directory)
  (org-default-notes-file (my/org-file "inbox.org"))
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-src-content-indentation 0)
  (org-log-into-drawer t)
  (org-preview-latex-default-process 'dvisvgm)
  (org-agenda-files
   (list (my/org-file "inbox.org")
         (my/org-file "projects.org")))
  (org-log-done 'time)
  (org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)" "CANCELLED(c@)")))
  ;; Refile is what gives inbox.org an exit. Without it capture is just
  ;; appending to a text file and the inbox becomes a junk drawer.
  ;; Both variables are needed: -in-steps nil alone (as this file had it) does
  ;; nothing unless -use-outline-path is also set.
  (org-refile-targets `((,(my/org-file "projects.org") :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-id-link-to-org-use-id 'create-if-interactive)
  (org-confirm-babel-evaluate #'my/org-confirm-babel-evaluate)
  (org-archive-location (concat
                         (file-name-as-directory (my/org-file "archive"))
                         "%s_archive::"))
  (org-tag-alist
   '(("dsa")
     ("computer-networks")
     ("c++")
     ("zig")
     ("FOSS")))
  (org-babel-C-compiler "clang")
  
  :config
  (plist-put org-format-latex-options :scale 1.5)
  (require 'org-tempo)
  
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (C . t)
     (shell . t)
     (scheme . t)))
  
  ;; Capture is the bottleneck, not the agenda. One dateless template meant
  ;; every task arrived undated, so the agenda had nothing to show and the
  ;; inbox stayed a flat list. These add the two shapes that actually produce
  ;; agenda entries -- scheduled and deadlined -- at one keystroke each.
  ;; Everything still lands in inbox.org; org-refile (C-c C-w) moves it into
  ;; projects.org afterwards. Capturing straight into a project heading was
  ;; considered and rejected: it hardcodes an outline path that changes.
  (setq org-capture-templates
        `(("i" "Inbox task" entry
           (file ,(my/org-file "inbox.org"))
           "* TODO %?\n%U\n")

          ("t" "Scheduled task" entry
           (file ,(my/org-file "inbox.org"))
           "* TODO %?\nSCHEDULED: %^t\n%U\n")

          ("d" "Task with deadline" entry
           (file ,(my/org-file "inbox.org"))
           "* TODO %?\nDEADLINE: %^t\n%U\n")

          ("n" "Note" entry
           (file ,(my/org-file "inbox.org"))
           "* %?\n%U\n")))

  ;; One view, not a suite. Today's dated items on top, everything still open
  ;; below, so a single key answers both "what is due" and "what exists".
  (setq org-agenda-custom-commands
        '(("d" "Day and open tasks"
           ((agenda "" ((org-agenda-span 'day)))
            (todo "TODO"
                  ((org-agenda-overriding-header "All open tasks")))))))

  :bind
  (("C-c o c" . org-capture)
  ("C-c o a" . org-agenda)
  ("C-c o w" . org-refile)
  ("C-c o x" . org-archive-subtree)))
  
(use-package org-roam
  :after org
  :custom
  (org-roam-directory my/org-roam-directory)
  (org-roam-completion-everywhere t)

  (org-roam-node-display-template
   (concat "${title:*} ${tags}"))
  
  (org-roam-capture-templates
     '(("a" "atomic note" plain
        "%?"
        :if-new
        (file+head
         "${slug}.org"
         "#+title: ${title}\n#+filetags: \n\n") 
        :unnarrowed t)

       ("l" "literate note" plain
        "%?"
        :if-new
        (file+head
         "literate/${slug}.org"
         "#+title: ${title}\n#+filetags: :literate:\n\n")
        :unnarrowed t)))

    (org-roam-dailies-directory "dailies/")

    (org-roam-dailies-capture-templates
     '(("d" "daily" entry
        "* %?"
        :target
        (file+head
         "%<%d-%m-%Y>.org"
         "#+title: %<%d-%m-%Y>\n#+filetags: :daily:\n\n"))))
  :config
  (org-roam-db-autosync-mode)
  :bind
  (("C-c o f" . org-roam-node-find)
   ("C-c o i" . org-roam-node-insert)
   ("C-c o n" . org-roam-capture)
   ("C-c o b" . org-roam-buffer-toggle)
   ("C-c o d" . org-roam-dailies-capture-today)
   ("C-c o g" . org-roam-dailies-goto-today)
   ("C-c o t a" . org-roam-tag-add)
   ("C-c o t r" . org-roam-tag-remove)))

(provide 'notes)
