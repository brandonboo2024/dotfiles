;; -*- lexical-binding: t; -*-

;; This is the bare minimum needed for future emacs bankruptcy
;; Vertico: Minibuffer utility
;; Corfu: Autocomplete
;; Whichkey + Helpful: Self-documentation
;; Consult: Better commands
;; Embark: Context aware actions
;; Orderless: Better matching
;; Marginalia: Pretty Info
;; Helpful: Nicer info
;; Org mode


(use-package vertico ;; Displays minibuffers in a nicer window
  :config
  (vertico-mode))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 3)
  (corfu-auto-delay 0.3)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (corfu-popupinfo-mode +1)
  (global-corfu-mode))

;; Complements corfu by adding additional completion extensions
(use-package cape
  :defer 10 ;; Loads function lazily
  :init
  (add-to-list 'completion-at-point-functions #'cape-file) 
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package which-key
  :diminish which-key-mode ;; Hides minor mode from status bar
  :custom
  (which-key-prefix-prefix "◉ ")
  (which-key-idle-delay 0.3)
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

(use-package consult
  :custom
  (consult-ripgrep-args
   (concat "rg --null --line-buffered --color=never "
           "--max-columns=1000 --path-separator / "
           "--smart-case --no-heading --with-filename --line-number "
           "--search-zip"))
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
  ("C-c r" . consult-ripgrep)
  ("C-c f" . my/global-fd)
  ("C-c e" . consult-bookmark)
  ("C-c p b" . consult-project-buffer)
  ("C-c p f" . consult-fd)) ;; C-x r to see register info, bookmarks are stored in registers

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :custom
  (prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after  (embark consult))

(use-package orderless ;; No more prefix-only matching
  :custom
  (completion-styles '(orderless basic)))

(use-package marginalia ;; Gives rich info on files selected in minibuffer
  :config
  (marginalia-mode))

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol]. helpful-symbol))

(provide 'core)
