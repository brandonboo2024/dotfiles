;; (setq inhibit-startup-message t)

;; disable different bars
(scroll-bar-mode -1) 
(tool-bar-mode 1)
(tooltip-mode 1)
(set-fringe-mode 10)
(menu-bar-mode 1)

;; ui preferences
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(blink-cursor-mode -1)

;; set text
(set-face-attribute 'default nil :font "Berkeley Mono" :height 140)

;; theme
(load-theme 'modus-vivendi)

;; initialise package
(require 'package)

(setq package-archives '(("melpa", "https://melpa.org/packages/")
			 ("org", "https://orgmode.org/elpa/")
			 ("elpa", "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; use-package on non linux
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


