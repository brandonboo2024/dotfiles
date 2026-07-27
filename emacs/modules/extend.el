;; -*- lexical-binding: t; -*-

;; Contains extensions/functionalities to further extend emacs
;; Are all useful/cannot be replaced, but I would not consider them important enough to be part of core.el in a major cleanse

;; Comes from the system (nixpkgs on the desktop), not straight. Guarded so the
;; config is a no-op where epdfinfo isn't installed instead of erroring on the
;; first PDF opened.
(use-package pdf-tools
  :straight nil
  :if (locate-library "pdf-tools")
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-loader-install))

;; no-littering lives in init.el - it has to load before anything reads a path.

(use-package eat
  :custom
  (eat-term-name "xterm-256color"))

(provide 'extend)
