;; To prevent straight.el and package.el to conflict  -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)
;; Backups/Lockfiles
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

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

(global-set-key (kbd "C-c u") #'my/list-unsaved-buffers)
