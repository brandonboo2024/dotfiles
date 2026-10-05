;; -*- lexical-binding: t; -*-

;; Config for note taking

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
  (dolist (face '(org-block
                  org-block-begin-line
                  org-block-end-line
                  org-checkbox
                  org-code
                  org-date
                  org-document-info-keyword
                  org-done
                  org-drawer
                  org-formula
                  org-meta-line
                  org-priority
                  org-property-value
                  org-special-keyword
                  org-table
                  org-tag
                  org-todo
                  org-verbatim))
    (face-remap-add-relative face 'fixed-pitch))
  (face-remap-add-relative 'org-table '(:height 0.9))
  (face-remap-add-relative
   'org-document-title '(:inherit variable-pitch :height 386))
  (face-remap-add-relative
   'org-level-1 '(:inherit variable-pitch :height 347))
  (face-remap-add-relative
   'org-level-2 '(:inherit variable-pitch :height 309))
  (face-remap-add-relative
   'org-level-3 '(:inherit variable-pitch :height 289)))

; for html exports
(use-package htmlize
  :defer t)

;; Nix supplies the native zmq dependency; Straight manages the frontend.
(use-package jupyter
  :defer t)

(with-eval-after-load 'jupyter-org-client
  ;; Restarted kernels cannot finish requests belonging to the old process.
  (defun my/jupyter-clear-restarted-org-requests (client)
    "Clear stale Org execution markers after CLIENT successfully restarts."
    (when (object-of-class-p client 'jupyter-org-client)
      (let (requests)
        (dolist (buffer (buffer-list))
          (with-current-buffer buffer
            (when (derived-mode-p 'org-mode)
              (save-restriction
                (widen)
                (let ((pos (point-min)))
                  (while (< pos (point-max))
                    (let ((req (get-text-property pos 'jupyter-request)))
                      (when (and (jupyter-org-request-p req)
                                 (eq (jupyter-request-client req) client)
                                 (not (jupyter-request-idle-p req)))
                        (cl-pushnew req requests)))
                    (setq pos (next-single-property-change
                               pos 'jupyter-request nil (point-max)))))))))
        (dolist (req requests)
          (jupyter-org-abort req)))))

  (advice-add 'jupyter-restart-kernel :after
              #'my/jupyter-clear-restarted-org-requests)

  ;; Compatibility workaround: emacs-jupyter/jupyter#607.
  (defun my/jupyter-org-results-drawer-pre-blank (element)
    "Supply the drawer spacing required by current Org interpreters."
    (when (and (eq (org-element-type element) 'drawer)
               (null (org-element-property :pre-blank element)))
      (org-element-put-property element :pre-blank 0))
    element)

  (advice-add 'jupyter-org-results-drawer :filter-return
              #'my/jupyter-org-results-drawer-pre-blank))

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
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-agenda-tags-column 0)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-list-allow-alphabetical t)
  (org-pretty-entities-include-sub-superscripts nil)
  (org-preview-latex-default-process 'dvisvgm)
  (org-todo-keywords
   '((type "TODO(t)" "EVENT(e)" "REMINDER(r)" "ADMIN(a)" "|" "DONE(d)")))
  :hook (org-mode . my/org-variable-pitch)
  :config
  (require 'org-tempo)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (C . t)
     (shell . t)
     (python . t)
     (jupyter . t)))
  (with-eval-after-load 'ox-latex
    (setq org-latex-src-block-backend 'minted)
    (add-to-list 'org-latex-packages-alist '("" "minted")))
  (setq jupyter-org-auto-connect nil)

  ; we remove hook to load on org-mode, and shift it to envrc
  (remove-hook 'org-mode-hook #'org-babel-jupyter-make-local-aliases)

  (with-eval-after-load 'envrc
    (add-hook 'envrc-mode-hook
              (lambda ()
                (when (and envrc-mode
                           (derived-mode-p 'org-mode)
                           (executable-find jupyter-executable))
                  (org-babel-jupyter-make-local-aliases)))))

  ;; when we restart the jupyter-kernel or export into other buffers, get envrc to carry over the environment to other buffers created
    (with-eval-after-load 'envrc
    (dolist (command '(jupyter-run-repl jupyter-repl-restart-kernel
                       org-export-as))
      (advice-add command :around #'envrc-propagate-environment)))
  (setf (alist-get 'file org-link-frame-setup) #'find-file)
  (setq org-agenda-files
        (cons org-default-notes-file (my/org-project-files))
        org-capture-templates
        '(("t" "Task" entry (file "") "* %^{Type|TODO|EVENT|REMINDER|ADMIN} %?")
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

* Index

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
                         "#+title: ${title}
* ${title}
")
      :unnarrowed t)))
  :config
  (org-roam-db-autosync-mode)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n l" . org-roam-buffer-toggle)))

(use-package tex
  :straight nil
  :demand t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :hook ((LaTeX-mode . turn-on-reftex)
         (LaTeX-mode . TeX-source-correlate-mode)
         (LaTeX-mode . visual-line-mode))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t)
  (TeX-source-correlate-method 'synctex)
  (TeX-source-correlate-start-server t)
  (TeX-view-program-selection '((output-pdf "Sioyek")))
  (reftex-plug-into-AUCTeX t))

(use-package auctex-latexmk
  :straight nil
  :after tex
  :custom
  (auctex-latexmk-inherit-TeX-PDF-mode t)
  :config
  (auctex-latexmk-setup)
  :hook
  (LaTeX-mode . (lambda () (setq-local TeX-command-default "LatexMk"))))

(provide 'notes)
