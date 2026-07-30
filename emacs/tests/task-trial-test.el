;;; task-trial-test.el --- Tests for Batch I Org trial -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'org-agenda)
(require 'task-trial)

(defmacro my/org-trial-test-with-fixture (&rest body)
  "Run BODY with isolated Org files and an enabled trial overlay."
  (declare (indent 0) (debug t))
  `(let* ((test-root (make-temp-file "org-trial-test-" t))
          (org-directory (file-name-as-directory test-root))
          (org-default-notes-file
           (expand-file-name "inbox.org" org-directory))
          (projects-file (expand-file-name "projects.org" org-directory))
          (my/org-trial-calendar-file
           (expand-file-name "calendar.org" org-directory))
          (my/org-trial-log-file
           (expand-file-name "batch-i-log.org" org-directory))
          (my/org-trial-protocol-file
           (expand-file-name "protocol.org" test-root))
          (my/org-trial-clock-persist-file
           (expand-file-name "org-clock-save.el" test-root))
          (org-agenda-files (list org-default-notes-file projects-file))
          (org-capture-templates
           `(("t" "Old scheduled task" entry
              (file ,org-default-notes-file)
              "* TODO %?\nSCHEDULED: %^t\n")))
          (org-agenda-custom-commands
           '(("d" "Existing day" agenda "")))
          (org-agenda-prefix-format
           '((agenda . " %i %-12:c%?-12t% s")
             (todo . " %i %-12:c")
             (tags . " %i %-12:c")
             (search . " %i %-12:c")))
          (org-agenda-hide-tags-regexp nil)
          (org-todo-keywords
           '((sequence "TODO(t)" "|" "DONE(d)" "CANCELLED(c@)")))
          (org-tag-alist '(("existing" . ?e)))
          (org-clock-persist nil)
          (org-clock-out-when-done nil)
          (org-clock-idle-time nil)
          (org-priority-highest ?A)
          (org-priority-lowest ?C)
          (org-priority-default ?B)
          (my/org-trial--enabled nil)
          (my/org-trial--saved-state nil)
          (original-todo-keywords (copy-tree org-todo-keywords))
          (original-priorities
           (list org-priority-highest
                 org-priority-lowest
                 org-priority-default)))
     (unwind-protect
         (progn
           (with-temp-file org-default-notes-file
             (insert "* Inbox\n"))
           (with-temp-file projects-file
             (insert
              "* Focused project :focus:\n"
              ":PROPERTIES:\n"
              ":OBJECTIVE: Learn by building a small example\n"
              ":END:\n"
              "** TODO First task\n"
              ":PROPERTIES:\n"
              ":FOOTHOLD: Open the relevant source file\n"
              ":END:\n"
              "** TODO Second task\n"
              "** TODO Third task\n"
              "** TODO Fourth task\n"
              "** TODO Fifth task\n"
              "** TODO Sixth task\n"))
           (with-temp-file my/org-trial-calendar-file
             (insert "* Appointments\n"))
           (with-temp-file my/org-trial-log-file
             (insert "* Daily records\n"))
           (with-temp-file my/org-trial-protocol-file
             (insert "* Protocol\n"))
           (org-set-regexps-and-options)
           (my/org-trial-enable)
           ,@body)
       (when my/org-trial--enabled
         (my/org-trial-disable))
       (dolist (file
                (list org-default-notes-file
                      projects-file
                      my/org-trial-calendar-file
                      my/org-trial-log-file
                      my/org-trial-protocol-file))
         (when-let* ((buffer (find-buffer-visiting file)))
           (kill-buffer buffer)))
       (when (get-buffer org-agenda-buffer-name)
         (kill-buffer org-agenda-buffer-name))
       (delete-directory test-root t))))

(ert-deftest my/org-trial-enable-installs-scoped-interface ()
  (my/org-trial-test-with-fixture
    (should
     (equal org-agenda-files
            (list org-default-notes-file
                  (expand-file-name "projects.org" org-directory)
                  my/org-trial-calendar-file)))
    (should (equal (mapcar #'car org-capture-templates)
                   '("i" "a" "d" "n")))
    (should-not (assoc "t" org-capture-templates))
    (should (eq (key-binding (kbd "C-c o v"))
                #'my/org-trial-orient))
    (should (eq (key-binding (kbd "C-c o P"))
                #'my/org-trial-open-protocol))
    (should (equal org-todo-keywords original-todo-keywords))
    (should (equal
             (list org-priority-highest
                   org-priority-lowest
                   org-priority-default)
             original-priorities))
    (should (equal org-clock-persist 'history))
    (should (equal org-agenda-hide-tags-regexp
                   "focus\\|today\\|dormant"))
    (should (equal org-clock-persist-file
                   my/org-trial-clock-persist-file))
    (should org-clock-out-when-done)
    (should (= org-clock-idle-time 30))))

(ert-deftest my/org-trial-captures-preserve-date-semantics ()
  (my/org-trial-test-with-fixture
    (let ((neutral (assoc "i" org-capture-templates))
          (appointment (assoc "a" org-capture-templates))
          (deadline (assoc "d" org-capture-templates)))
      (should-not (string-match-p "TODO\\|SCHEDULED\\|DEADLINE"
                                  (nth 4 neutral)))
      (should (string-match-p "%\\^T" (nth 4 appointment)))
      (should-not (string-match-p "SCHEDULED\\|DEADLINE"
                                  (nth 4 appointment)))
      (should (string-match-p "DEADLINE: %\\^t" (nth 4 deadline)))
      (should-not (string-match-p "SCHEDULED" (nth 4 deadline))))))

(ert-deftest my/org-trial-selection-does-not-mutate-priority ()
  (my/org-trial-test-with-fixture
    (let ((buffer
           (find-file-noselect
            (expand-file-name "projects.org" org-directory))))
      (with-current-buffer buffer
        (goto-char (point-min))
        (re-search-forward "^\\*\\* TODO First task$")
        (org-back-to-heading t)
        (should-not
         (org-element-property :priority (org-element-at-point)))
        (cl-letf (((symbol-function 'completing-read)
                   (lambda (&rest _) "must")))
          (my/org-trial-select-today))
        (should (equal (org-entry-get nil "TRIAL_CLASS") "must"))
        (should (equal (org-entry-get nil "TRIAL_SELECTED")
                       (my/org-trial--day)))
        (should (member "today" (org-get-tags nil t)))
        (should-not
         (org-element-property :priority (org-element-at-point)))
        (save-buffer)))))

(ert-deftest my/org-trial-enforces-one-must ()
  (my/org-trial-test-with-fixture
    (let ((buffer
           (find-file-noselect
            (expand-file-name "projects.org" org-directory))))
      (with-current-buffer buffer
        (goto-char (point-min))
        (re-search-forward "^\\*\\* TODO First task$")
        (cl-letf (((symbol-function 'completing-read)
                   (lambda (&rest _) "must")))
          (my/org-trial-select-today))
        (save-buffer)
        (goto-char (point-min))
        (re-search-forward "^\\*\\* TODO Second task$")
        (cl-letf (((symbol-function 'completing-read)
                   (lambda (&rest _) "must")))
          (should-error (my/org-trial-select-today)
                        :type 'user-error))))))

(ert-deftest my/org-trial-jit-start-records-class-and-clocks ()
  (my/org-trial-test-with-fixture
    (let ((clocked nil)
          (buffer
           (find-file-noselect
            (expand-file-name "projects.org" org-directory))))
      (with-current-buffer buffer
        (goto-char (point-min))
        (re-search-forward "^\\*\\* TODO Second task$")
        (cl-letf (((symbol-function 'org-clock-in)
                   (lambda (&rest _) (setq clocked t))))
          (my/org-trial-start-task))
        (should clocked)
        (should (equal (org-entry-get nil "TRIAL_CLASS") "jit"))
        (should-not
         (org-element-property :priority (org-element-at-point)))))))

(ert-deftest my/org-trial-agenda-exposes-objective-and-foothold ()
  (my/org-trial-test-with-fixture
    (let ((buffer
           (find-file-noselect
            (expand-file-name "projects.org" org-directory))))
      (with-current-buffer buffer
        (goto-char (point-min))
        (re-search-forward "^\\*\\* TODO First task$")
        (cl-letf (((symbol-function 'completing-read)
                   (lambda (&rest _) "must")))
          (my/org-trial-select-today))
        (save-buffer))
      (save-window-excursion
        (org-agenda nil "V")
        (with-current-buffer org-agenda-buffer-name
          (let ((agenda (buffer-string)))
            (should (string-match-p "\\[M\\]" agenda))
            (should
             (string-match-p "Learn by building a small example" agenda))
            (should
             (string-match-p "Open the relevant source file" agenda))))))))

(ert-deftest my/org-trial-candidate-view-is-limited ()
  (my/org-trial-test-with-fixture
    (save-window-excursion
      (org-agenda nil "J")
      (with-current-buffer org-agenda-buffer-name
        (goto-char (point-min))
        (let ((count 0))
          (while (re-search-forward "TODO .* task" nil t)
            (setq count (1+ count)))
          (should (= count 5)))))))

(ert-deftest my/org-trial-log-is-compact-and-idempotent ()
  (my/org-trial-test-with-fixture
    (save-window-excursion
      (my/org-trial-log-day)
      (my/org-trial-log-day))
    (with-current-buffer (find-file-noselect my/org-trial-log-file)
      (save-buffer)
      (goto-char (point-min))
      (let ((heading
             (concat "^\\*\\* "
                     (regexp-quote (format-time-string "%Y-%m-%d %a"))
                     "$"))
            (count 0))
        (while (re-search-forward heading nil t)
          (setq count (1+ count)))
        (should (= count 1))
        (should (re-search-forward "V:\\[# false-overdue" nil t))))))

(ert-deftest my/org-trial-disable-restores-state ()
  (my/org-trial-test-with-fixture
    (my/org-trial-disable)
    (should-not my/org-trial--enabled)
    (should (equal (mapcar #'car org-capture-templates) '("t")))
    (should (equal org-agenda-files
                   (list org-default-notes-file
                         (expand-file-name "projects.org" org-directory))))
    (should-not (eq (key-binding (kbd "C-c o v"))
                    #'my/org-trial-orient))))

(provide 'task-trial-test)

;;; task-trial-test.el ends here
