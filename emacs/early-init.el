;; To prevent straight.el and package.el to conflict  -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)
;; Backups/Lockfiles
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; Defer GC during startup; gcmh takes over once init finishes (see modules/qol.el)
(setq gc-cons-threshold most-positive-fixnum)


