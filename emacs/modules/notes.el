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

(defun my/org-read-course-directory ()
  "Prompt for an existing course directory."
  (file-name-as-directory
   (read-directory-name
    "Course: "
    (expand-file-name "projects/" org-directory)
    nil t)))

(defun my/org-ensure-new-file (file)
  "Return FILE unless it already exists."
  (if (file-exists-p file)
      (user-error "Org file already exists: %s" file)
    file))

(defun my/org-capture-course-index-file ()
  "Return a new index file in a selected course directory."
  (my/org-ensure-new-file
   (expand-file-name "index.org" (my/org-read-course-directory))))

(defun my/org-capture-course-unit-file ()
  "Prompt for a new unit file in a selected course directory."
  (let ((directory (my/org-read-course-directory)))
    (my/org-ensure-new-file
     (read-file-name "New unit file: " directory))))

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
  (org-refile-use-outline-path 'title)
  (org-outline-path-complete-in-steps nil)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-ellipsis "…")
  :hook (org-mode . my/org-variable-pitch)
  :config
  (setq org-agenda-files
        (cons org-default-notes-file (my/org-project-files))
        org-capture-templates
        '(("t" "Task" entry (file "") "* TODO %?")
          ("a" "Thought" entry (file "") "* %?")
          ("c" "Course index" plain
           (file my/org-capture-course-index-file)
           "#+title: %^{Course title}
#+category: %^{Category}

* Overview
** Schedule
%?
** Assessments

** Resources

* Units

* Suggested Readings

* Key concepts to cover

* Tasks
"
           :jump-to-captured t)
          ("n" "Course Note" plain
           (file my/org-capture-course-unit-file)
           "#+title: %^{Unit title}
#+category: %^{Category}

* Agenda

* Class Part

* Notes
%?
* Further Reading
"
           :jump-to-captured t)))
  :bind
  (("C-c o c" . org-capture)
   ("C-c o a" . my/org-agenda)
   ("C-c o g" . my/org-open-index)
   ("C-c o i" . my/org-open-inbox)
   ("C-c o r" . org-refile)))

(use-package org-habit
  :straight nil
  :after org
  :demand t
  :custom
  (org-habit-graph-column 70))

(use-package org-roam
  :demand t
  :custom
  (org-roam-directory (expand-file-name "roam/" org-directory))
  (org-roam-capture-templates
   '(("d" "Distilled note" plain "%?"
      :target (file+head "${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t)))
  :config
  (org-roam-db-autosync-mode)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)))

(provide 'notes)
