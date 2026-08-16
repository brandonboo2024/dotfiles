;; -*- lexical-binding: t; -*-

(defun my/org-project-files ()
  "Return Org files below the projects directory."
  (directory-files-recursively
   (expand-file-name "projects/" org-directory)
   org-agenda-file-regexp))

(defun my/org-agenda ()
  "Refresh project files and open the Org agenda dispatcher."
  (interactive)
  (setq org-agenda-files
        (cons org-default-notes-file (my/org-project-files)))
  (call-interactively #'org-agenda))

(defun my/org-open-index ()
  "Open the Org index."
  (interactive)
  (find-file (expand-file-name "index.org" org-directory)))

(defun my/org-open-inbox ()
  "Open the Org inbox."
  (interactive)
  (find-file org-default-notes-file))

(defun my/org-variable-pitch ()
  "Use variable-pitch prose and fixed-pitch structured text."
  (variable-pitch-mode 1)
  (dolist (face '(org-block org-code org-formula org-table org-verbatim))
    (face-remap-add-relative face 'fixed-pitch)))

(use-package org
  :straight nil
  :custom
  (org-directory (expand-file-name "~/org/"))
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (org-refile-targets '((my/org-project-files :maxlevel . 2)))
  (org-refile-use-outline-path 'file)
  :hook (org-mode . my/org-variable-pitch)
  :config
  (setq org-agenda-files
        (cons org-default-notes-file (my/org-project-files))
        org-capture-templates
        '(("t" "Task" entry (file "") "* TODO %?")
          ("n" "Thought" entry (file "") "* %?")))
  :bind
  (("C-c o c" . org-capture)
   ("C-c o a" . my/org-agenda)
   ("C-c o h" . my/org-open-index)
   ("C-c o i" . my/org-open-inbox)
   ("C-c o r" . org-refile)))

(use-package org-roam
  :demand t
  :custom
  (org-roam-directory (expand-file-name "roam/" org-directory))
  :config
  (org-roam-db-autosync-mode)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)))

(provide 'notes)
