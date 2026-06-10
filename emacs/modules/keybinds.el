;; -*- lexical-binding: t; -*-

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

(global-set-key (kbd "C-c u") #'my/list-unsaved-buffers)
(global-set-key "%" 'match-paren)

(provide 'keybinds)
