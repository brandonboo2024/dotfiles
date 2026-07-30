;;; task-trial.el --- Reversible Batch I Org trial -*- lexical-binding: t; -*-

;; This module is deliberately inert when merely loaded.  During the seven-day
;; baseline it may be installed and tested without changing Org.  Call
;; `my/org-trial-enable' after `notes.el' to begin Phase A, and call
;; `my/org-trial-disable' before removing the activation lines.

(require 'org)
(require 'org-agenda)
(require 'org-capture)
(require 'org-clock)
(require 'seq)
(require 'subr-x)

(defgroup my/org-trial nil
  "Temporary task-operation trial for the textual computing system."
  :group 'org)

(defcustom my/org-trial-calendar-file
  (expand-file-name "calendar.org" org-directory)
  "Org file containing appointments and externally sourced events."
  :type 'file
  :group 'my/org-trial)

(defcustom my/org-trial-log-file
  (expand-file-name
   "research/personal-textual-computing/batch-i-log.org"
   org-directory)
  "Private Org file containing compact Batch I observations."
  :type 'file
  :group 'my/org-trial)

(defcustom my/org-trial-protocol-file
  (expand-file-name
   "100_projects/personal-textual-computing-system/experiments/batch-i/protocol.org"
   "~")
  "Versioned Batch I protocol and evidence contract."
  :type 'file
  :group 'my/org-trial)

(defcustom my/org-trial-clock-persist-file
  (expand-file-name
   "org-clock-save.el"
   (if (boundp 'my/emacs-state-directory)
       my/emacs-state-directory
     (expand-file-name
      "emacs/"
      (or (getenv "XDG_STATE_HOME")
          (expand-file-name ".local/state/" "~")))))
  "Generated Org clock state used during the trial."
  :type 'file
  :group 'my/org-trial)

(defvar my/org-trial--enabled nil
  "Non-nil while the Batch I overlay is active.")

(defvar my/org-trial--saved-state nil
  "State saved by `my/org-trial-enable' for in-session rollback.")

(defconst my/org-trial--command-bindings
  '(("v" . my/org-trial-orient)
    ("F" . my/org-trial-fixed)
    ("j" . my/org-trial-candidates)
    ("r" . my/org-trial-review)
    ("u" . my/org-trial-open-inbox)
    ("s" . my/org-trial-select-today)
    ("z" . my/org-trial-start-task)
    ("h" . my/org-trial-set-foothold)
    ("e" . my/org-trial-dispose)
    ("l" . my/org-trial-log-day)
    ("P" . my/org-trial-open-protocol))
  "Keys below `C-c o' provided by the trial.")

(defconst my/org-trial--agenda-prefix-format
  '((agenda . " %i %-12:c%?-12t%(my/org-trial-agenda-context) ")
    (todo . " %i %-12:c %(my/org-trial-agenda-context) ")
    (tags . " %i %-12:c %(my/org-trial-agenda-context) ")
    (search . " %i %-12:c %(my/org-trial-agenda-context) "))
  "Agenda prefixes that expose trial intent without priority mutation.")

(defun my/org-trial--capture-templates ()
  "Return the trial's deliberately small capture vocabulary."
  `(("i" "Inbox (neutral)" entry
     (file ,org-default-notes-file)
     "* %?\n%U\n")
    ("a" "Appointment" entry
     (file+headline ,my/org-trial-calendar-file "Appointments")
     "* %?\n%^T\n%U\n")
    ("d" "True deadline" entry
     (file ,org-default-notes-file)
     "* TODO %?\nDEADLINE: %^t\n%U\n")
    ("n" "Note" entry
     (file ,org-default-notes-file)
     "* %?\n%U\n")))

(defun my/org-trial--agenda-commands ()
  "Return the Batch I custom agenda commands."
  '(("V" "Batch I: daily orientation"
     ((agenda ""
              ((org-agenda-start-day "-1d")
               (org-agenda-span 2)
               (org-agenda-start-on-weekday nil)
               (org-agenda-entry-types '(:deadline :timestamp))
               (org-deadline-warning-days 0)
               (org-agenda-overriding-header
                "Fixed commitments: yesterday and today")))
      (tags-todo "+today"
                 ((org-agenda-overriding-header
                   "Accepted work: yesterday and today")
                  (org-agenda-skip-function
                   #'my/org-trial-skip-not-recent-selection)))
      (tags-todo "+focus-dormant"
                 ((org-agenda-overriding-header
                   "Focused-project candidates (at most five; not promises)")
                  (org-agenda-skip-function
                   #'my/org-trial-skip-current-selection)
                  (org-agenda-max-entries 5)
                  (org-agenda-sorting-strategy '(category-keep))))))

    ("F" "Batch I: fixed commitments"
     ((agenda ""
              ((org-agenda-start-day "0d")
               (org-agenda-span 7)
               (org-agenda-start-on-weekday nil)
               (org-agenda-entry-types '(:deadline :timestamp))
               (org-deadline-warning-days 0)
               (org-agenda-overriding-header
                "Appointments and deadlines: next seven days")))))

    ("J" "Batch I: just-in-time candidates"
     ((tags-todo "+focus-dormant"
                 ((org-agenda-overriding-header
                   "Actionable work in focused projects")
                  (org-agenda-skip-function
                   #'my/org-trial-skip-current-selection)
                  (org-agenda-max-entries 5)
                  (org-agenda-sorting-strategy '(category-keep))))))

    ("R" "Batch I: lightweight review"
     ((agenda ""
              ((org-agenda-start-day "0d")
               (org-agenda-span 14)
               (org-agenda-start-on-weekday nil)
               (org-agenda-entry-types '(:deadline :timestamp))
               (org-deadline-warning-days 0)
               (org-agenda-overriding-header
                "Fixed commitments: next fourteen days")))
      (todo "TODO"
            ((org-agenda-overriding-header "Accepted commitments")))
      (tags "+dormant"
            ((org-agenda-overriding-header
              "Dormant projects to reconsider (at most three)")
             (org-agenda-max-entries 3))))))
  )

(defun my/org-trial--replace-keyed-entry (entry entries)
  "Put ENTRY first in ENTRIES, replacing an item with the same key."
  (cons entry
        (seq-remove
         (lambda (candidate)
           (equal (car-safe candidate) (car entry)))
         entries)))

(defun my/org-trial--day (&optional offset)
  "Return an ISO date OFFSET days from today."
  (format-time-string
   "%Y-%m-%d"
   (time-add (current-time) (days-to-time (or offset 0)))))

(defun my/org-trial--truncate (value width)
  "Return VALUE normalized to one line and truncated to WIDTH."
  (when-let* ((value (and value (string-trim value)))
              ((not (string-empty-p value))))
    (truncate-string-to-width
     (replace-regexp-in-string "[\n\r\t ]+" " " value)
     width nil nil "…")))

(defun my/org-trial-agenda-context ()
  "Return compact class, objective, and foothold context at point."
  (let* ((class (org-entry-get nil "TRIAL_CLASS"))
         (class-label
          (pcase class
            ("must" "[M]")
            ("should" "[S]")
            ("jit" "[J]")
            (_ nil)))
         (objective
          (my/org-trial--truncate
           (org-entry-get nil "OBJECTIVE" 'inherit)
           42))
         (foothold
          (my/org-trial--truncate
           (org-entry-get nil "FOOTHOLD")
           36))
         (parts
          (delq nil
                (list class-label
                      (and objective (format "Obj: %s" objective))
                      (and foothold (format "Start: %s" foothold))))))
    (if parts
        (concat (string-join parts " | ") " |")
      "")))

(defun my/org-trial-skip-not-recent-selection ()
  "Skip entries that were not selected today or yesterday."
  (let ((selected (org-entry-get nil "TRIAL_SELECTED")))
    (unless (member selected
                    (list (my/org-trial--day)
                          (my/org-trial--day -1)))
      (save-excursion
        (org-end-of-subtree t)))))

(defun my/org-trial-skip-current-selection ()
  "Skip an entry already selected today."
  (when (equal (org-entry-get nil "TRIAL_SELECTED")
               (my/org-trial--day))
    (save-excursion
      (org-end-of-subtree t))))

(defun my/org-trial--entry-marker ()
  "Return a marker for the Org entry at point or on the agenda line."
  (cond
   ((derived-mode-p 'org-agenda-mode)
    (or (org-get-at-bol 'org-marker)
        (org-get-at-bol 'org-hd-marker)
        (user-error "This agenda line does not refer to an Org heading")))
   ((derived-mode-p 'org-mode)
    (save-excursion
      (org-back-to-heading t)
      (point-marker)))
   (t
    (user-error "Run this from an Org heading or Org agenda line"))))

(defun my/org-trial--call-at-entry (function)
  "Call FUNCTION at the source entry represented by point."
  (let ((from-agenda (derived-mode-p 'org-agenda-mode))
        (marker (my/org-trial--entry-marker)))
    (unwind-protect
        (with-current-buffer (marker-buffer marker)
          (goto-char marker)
          (org-back-to-heading t)
          (funcall function))
      (set-marker marker nil))
    (when from-agenda
      (org-agenda-redo))))

(defun my/org-trial--require-open-task ()
  "Signal an error unless point is on an open TODO entry."
  (unless (equal (org-get-todo-state) "TODO")
    (user-error "Accept this item as TODO before selecting or clocking it")))

(defun my/org-trial--count-selected (class)
  "Count today's unfinished selections whose TRIAL_CLASS is CLASS."
  (let ((count 0)
        (today (my/org-trial--day)))
    (org-map-entries
     (lambda ()
       (when (and (equal (org-entry-get nil "TRIAL_SELECTED") today)
                  (equal (org-entry-get nil "TRIAL_CLASS") class)
                  (not (org-entry-is-done-p)))
         (setq count (1+ count))))
     nil 'agenda)
    count))

(defun my/org-trial--set-selection (class)
  "Mark the current heading as today's selection of CLASS."
  (org-toggle-tag "today" 'on)
  (org-toggle-tag "dormant" 'off)
  (org-entry-put nil "TRIAL_SELECTED" (my/org-trial--day))
  (org-entry-put nil "TRIAL_CLASS" class)
  (org-entry-delete nil "TRIAL_DISPOSITION")
  (org-entry-delete nil "TRIAL_DISPOSITION_AT"))

(defun my/org-trial-select-today ()
  "Select the task at point as today's must-do or should-do.

The trial enforces at most one must and two should items.  It records selection
with properties and does not mutate Org priorities."
  (interactive)
  (let ((class
         (completing-read "Daily class: " '("must" "should") nil t)))
    (my/org-trial--call-at-entry
     (lambda ()
       (my/org-trial--require-open-task)
       (let ((already-same
              (and (equal (org-entry-get nil "TRIAL_SELECTED")
                          (my/org-trial--day))
                   (equal (org-entry-get nil "TRIAL_CLASS") class))))
         (unless already-same
           (pcase class
             ("must"
              (when (>= (my/org-trial--count-selected "must") 1)
                (user-error "The trial permits at most one must-do")))
             ("should"
              (when (>= (my/org-trial--count-selected "should") 2)
                (user-error "The trial permits at most two should-dos")))))
         (my/org-trial--set-selection class))))))

(defun my/org-trial-start-task ()
  "Clock into the task, selecting it just in time when necessary."
  (interactive)
  (my/org-trial--call-at-entry
   (lambda ()
     (my/org-trial--require-open-task)
     (unless (equal (org-entry-get nil "TRIAL_SELECTED")
                    (my/org-trial--day))
       (my/org-trial--set-selection "jit"))
     (org-clock-in))))

(defun my/org-trial-set-foothold ()
  "Record one small, observable starting action on the task at point."
  (interactive)
  (let ((foothold (read-string "Starting foothold: ")))
    (when (string-empty-p foothold)
      (user-error "A foothold cannot be empty"))
    (my/org-trial--call-at-entry
     (lambda ()
       (org-entry-put nil "FOOTHOLD" foothold)))))

(defun my/org-trial--record-disposition (value)
  "Record disposition VALUE and its time at the current heading."
  (org-entry-put nil "TRIAL_DISPOSITION" value)
  (org-entry-put nil "TRIAL_DISPOSITION_AT"
                 (format-time-string "[%Y-%m-%d %a %H:%M]")))

(defun my/org-trial--clear-selection ()
  "Remove active daily-selection metadata from the current heading."
  (org-toggle-tag "today" 'off)
  (org-entry-delete nil "TRIAL_SELECTED")
  (org-entry-delete nil "TRIAL_CLASS"))

(defun my/org-trial-dispose ()
  "Deliberately dispose of the selected task at point."
  (interactive)
  (let ((choice
         (completing-read
          "Disposition: "
          '("done"
            "continue tomorrow"
            "reduce to foothold"
            "return to project"
            "make dormant"
            "cancel")
          nil t)))
    (my/org-trial--call-at-entry
     (lambda ()
       (pcase choice
         ("done"
          (my/org-trial--record-disposition "done")
          (org-todo "DONE"))
         ("continue tomorrow"
          (org-toggle-tag "today" 'on)
          (org-entry-put nil "TRIAL_SELECTED" (my/org-trial--day 1))
          (my/org-trial--record-disposition "continue tomorrow"))
         ("reduce to foothold"
          (let ((foothold (read-string "Smaller starting foothold: ")))
            (when (string-empty-p foothold)
              (user-error "A foothold cannot be empty"))
            (org-entry-put nil "FOOTHOLD" foothold)
            (my/org-trial--record-disposition "reduce to foothold")
            (my/org-trial--clear-selection)))
         ("return to project"
          (my/org-trial--record-disposition "return to project")
          (my/org-trial--clear-selection))
         ("make dormant"
          (my/org-trial--record-disposition "make dormant")
          (my/org-trial--clear-selection)
          (org-toggle-tag "dormant" 'on))
         ("cancel"
          (my/org-trial--record-disposition "cancel")
          (org-todo "CANCELLED")))))))

(defun my/org-trial--agenda (key)
  "Open the custom agenda command KEY."
  (unless my/org-trial--enabled
    (user-error "Enable the Batch I overlay first"))
  (org-agenda nil key))

(defun my/org-trial-orient ()
  "Open the yesterday-plus-today orientation view."
  (interactive)
  (my/org-trial--agenda "V"))

(defun my/org-trial-fixed ()
  "Open the seven-day appointments-and-deadlines view."
  (interactive)
  (my/org-trial--agenda "F"))

(defun my/org-trial-candidates ()
  "Open up to five focused-project actions for JIT selection."
  (interactive)
  (my/org-trial--agenda "J"))

(defun my/org-trial-review ()
  "Open the lightweight review view."
  (interactive)
  (my/org-trial--agenda "R"))

(defun my/org-trial-open-inbox ()
  "Open the neutral capture inbox."
  (interactive)
  (find-file org-default-notes-file))

(defun my/org-trial-open-protocol ()
  "Open the versioned Batch I protocol."
  (interactive)
  (find-file my/org-trial-protocol-file))

(defun my/org-trial-log-day ()
  "Visit or create today's compact observation record."
  (interactive)
  (let* ((date (format-time-string "%Y-%m-%d %a"))
         (heading (format "** %s" date))
         (buffer (find-file-noselect my/org-trial-log-file)))
    (pop-to-buffer buffer)
    (widen)
    (goto-char (point-min))
    (unless (re-search-forward "^\\* Daily records[ \t]*$" nil t)
      (goto-char (point-max))
      (unless (bolp)
        (insert "\n"))
      (insert "* Daily records\n"))
    (org-back-to-heading t)
    (let* ((records-start (point))
           (record-level (1+ (org-current-level)))
           (records-end
            (save-excursion
              (org-end-of-subtree t t)))
           (record-position
            (save-excursion
              (goto-char records-start)
              (catch 'record
                (while (re-search-forward
                        (concat "^" (regexp-quote heading) "[ \t]*$")
                        records-end t)
                  (when (= (org-current-level) record-level)
                    (throw 'record (line-beginning-position))))))))
      (if record-position
          (progn
            (goto-char record-position)
            (org-show-entry))
        (goto-char records-end)
        (unless (bolp)
          (insert "\n"))
        (insert
         heading "\n"
         "- O:[Y/N] | P:[# planned] | S:[# started] | "
         "U:[brief dispositions] | H:[# missed hard commitments] | "
         "V:[# false-overdue debt items] | C:[# clock corrections] | "
         "Q:[1-5 trust/orientation] | F:[one friction]\n")
        (forward-line -1)
        (search-forward "O:[")))))

(defun my/org-trial--remember-state ()
  "Capture the Org and key state changed by the overlay."
  (setq
   my/org-trial--saved-state
   `((org-agenda-files . ,(copy-tree org-agenda-files))
     (org-capture-templates . ,(copy-tree org-capture-templates))
     (org-agenda-custom-commands
      . ,(copy-tree org-agenda-custom-commands))
     (org-agenda-prefix-format . ,(copy-tree org-agenda-prefix-format))
     (org-agenda-hide-tags-regexp . ,org-agenda-hide-tags-regexp)
     (org-clock-persist . ,org-clock-persist)
     (org-clock-persist-file . ,org-clock-persist-file)
     (org-clock-out-when-done . ,org-clock-out-when-done)
     (org-clock-idle-time . ,org-clock-idle-time)
     (org-tag-alist . ,(copy-tree org-tag-alist))
     (keys
      . ,(mapcar
          (lambda (binding)
            (let ((key (kbd (concat "C-c o " (car binding)))))
              (cons key (lookup-key global-map key))))
          my/org-trial--command-bindings)))))

(defun my/org-trial--restore-variable (variable)
  "Restore VARIABLE from `my/org-trial--saved-state'."
  (set variable (copy-tree (alist-get variable my/org-trial--saved-state))))

(defun my/org-trial--validate-files ()
  "Check that required live and research files exist."
  (dolist (file
           (list org-default-notes-file
                 (expand-file-name "projects.org" org-directory)
                 my/org-trial-calendar-file
                 my/org-trial-log-file
                 my/org-trial-protocol-file))
    (unless (file-exists-p file)
      (user-error "Batch I required file does not exist: %s" file))))

(defun my/org-trial--todo-state-present-p (state)
  "Return non-nil when STATE appears in `org-todo-keywords'."
  (seq-some
   (lambda (sequence)
     (seq-some
      (lambda (keyword)
        (and (stringp keyword)
             (equal
              state
              (replace-regexp-in-string
               "(.*)\\'" "" keyword))))
      (cdr sequence)))
   org-todo-keywords))

(defun my/org-trial-enable ()
  "Enable the reversible Batch I Org overlay."
  (interactive)
  (unless my/org-trial--enabled
    (my/org-trial--validate-files)
    (unless (and (my/org-trial--todo-state-present-p "TODO")
                 (my/org-trial--todo-state-present-p "DONE")
                 (my/org-trial--todo-state-present-p "CANCELLED"))
      (user-error "Batch I requires TODO, DONE, and CANCELLED states"))
    (my/org-trial--remember-state)
    (setq org-agenda-files
          (list org-default-notes-file
                (expand-file-name "projects.org" org-directory)
                my/org-trial-calendar-file)
          org-capture-templates (my/org-trial--capture-templates)
          org-agenda-prefix-format
          (copy-tree my/org-trial--agenda-prefix-format)
          org-agenda-hide-tags-regexp "focus\\|today\\|dormant"
          org-clock-persist 'history
          org-clock-persist-file my/org-trial-clock-persist-file
          org-clock-out-when-done t
          org-clock-idle-time 30)
    (dolist (tag '(("focus" . ?f)
                   ("today" . ?t)
                   ("dormant" . ?d)))
      (add-to-list 'org-tag-alist tag t))
    (dolist (command (my/org-trial--agenda-commands))
      (setq org-agenda-custom-commands
            (my/org-trial--replace-keyed-entry
             command org-agenda-custom-commands)))
    (dolist (binding my/org-trial--command-bindings)
      (global-set-key
       (kbd (concat "C-c o " (car binding)))
       (cdr binding)))
    (org-clock-persistence-insinuate)
    (setq my/org-trial--enabled t)
    (message "Batch I overlay enabled")))

(defun my/org-trial-disable ()
  "Restore the state saved when the Batch I overlay was enabled.

Restart Emacs after removing the activation lines for the cleanest rollback;
Org clock persistence hooks installed by Org may remain in the current
session."
  (interactive)
  (when my/org-trial--enabled
    (dolist (variable
             '(org-agenda-files
               org-capture-templates
               org-agenda-custom-commands
               org-agenda-prefix-format
               org-agenda-hide-tags-regexp
               org-clock-persist
               org-clock-persist-file
               org-clock-out-when-done
               org-clock-idle-time
               org-tag-alist))
      (my/org-trial--restore-variable variable))
    (dolist (saved (alist-get 'keys my/org-trial--saved-state))
      (if (or (null (cdr saved))
              (numberp (cdr saved)))
          (global-unset-key (car saved))
        (global-set-key (car saved) (cdr saved))))
    (setq my/org-trial--saved-state nil
          my/org-trial--enabled nil)
    (message "Batch I overlay disabled; restart Emacs after removing activation")))

(provide 'task-trial)

;;; task-trial.el ends here
