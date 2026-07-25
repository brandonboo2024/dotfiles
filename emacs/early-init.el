;; To prevent straight.el and package.el to conflict  -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)

;; Keep generated package and state data out of the Git-controlled config.
(defconst my/emacs-data-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_DATA_HOME")
       (expand-file-name ".local/share/" "~"))))
(defconst my/emacs-state-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_STATE_HOME")
       (expand-file-name ".local/state/" "~"))))

(make-directory my/emacs-data-directory t)
(make-directory my/emacs-state-directory t)

(setq straight-base-dir my/emacs-data-directory
      custom-file (expand-file-name "custom.el" my/emacs-state-directory))

;; Backups/Lockfiles
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

