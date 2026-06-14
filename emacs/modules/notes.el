;; -*- lexical-binding: t; -*-

(defvar my/org-directory (file-truename "~/org/"))
(defvar my/org-roam-directory (expand-file-name "roam/" my/org-directory))

(defun my/org-file(path)
  (expand-file-name path my/org-directory))

(use-package org
  :custom
  (org-directory my/org-directory)
  (org-default-notes-file (my/org-file "inbox.org"))
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-src-content-indentation 0)
  (org-preview-latex-default-process 'dvisvgm)
  (org-agenda-files
   (list (my/org-file "inbox.org")
         (my/org-file "projects.org")
         (my/org-file "roam/dailies/")))
  (org-log-done 'time)
  (org-outline-path-complete-in-steps nil)
  (org-id-link-to-org-use-id 'create-if-interactive)
  (org-confirm-babel-evaluate nil)
  (org-archive-location (concat
                         (file-name-as-directory (my/org-file "archive"))
                         "%s_archive::"))
  (org-tag-alist
   '(("dsa")
     ("computer-networks")
     ("c++")
     ("zig")))
  
  :config
  (plist-put org-format-latex-options :scale 1.5)
  (require 'org-tempo)
  
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (C . t)
     (shell . t)))
  
  (setq org-capture-templates `(("i" "Inbox"
                                 entry
                                 (file ,org-default-notes-file)
                                 "* TODO %?\n%U\n")))
  
  :bind
  (("C-c o c" . org-capture)
  ("C-c o a" . org-agenda)
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
