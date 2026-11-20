;; -*- lexical-binding: t; -*-

;; Skip GC pauses during startup, then restore a reasonable runtime threshold.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; straight.el manages packages, so keep package.el from activating its own.
(setq package-enable-at-startup nil)

;; Prefer a newer .el over a stale .elc.
(setq load-prefer-newer t)

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

(startup-redirect-eln-cache
 (expand-file-name "eln-cache/" my/emacs-data-directory))

(setq native-comp-async-report-warnings-errors 'silent)

;; LSP servers send large JSON; read it in 1 MB chunks instead of 64 KB.
(setq read-process-output-max (* 1024 1024))

;; Backups/Lockfiles
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

(setq auto-save-list-file-prefix
      (expand-file-name "auto-save-list/.saves-" my/emacs-state-directory))
