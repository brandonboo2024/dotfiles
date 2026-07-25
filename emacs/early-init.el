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

;; native-comp writes to user-emacs-directory/eln-cache unless told otherwise,
;; and user-emacs-directory is this Git repository. straight-base-dir and
;; no-littering do not cover it, so it quietly grew to 283M inside the
;; worktree. Must be done here: the cache path is fixed before init.el runs.
(startup-redirect-eln-cache
 (expand-file-name "eln-cache/" my/emacs-data-directory))

;; Backups/Lockfiles
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

