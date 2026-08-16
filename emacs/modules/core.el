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


(use-package vertico ;; Displays minibuffers in a nicer window
  :demand t
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :config
  (vertico-mode)
  (require 'vertico-directory))

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
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

(use-package which-key
  :diminish which-key-mode ;; Hides minor mode from status bar
  :custom
  (which-key-prefix-prefix "◉ ")
  (which-key-idle-delay 0.3)
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

(use-package consult
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :custom
  (consult-ripgrep-args
   (concat "rg --null --line-buffered --color=never "
           "--max-columns=1000 --path-separator / "
           "--smart-case --no-heading --with-filename --line-number "
           "--search-zip"))
  ;; Upstream defaults are 0.2 / 0.5 / 0.2.
  (consult-async-input-debounce 0.1)
  (consult-async-input-throttle 0.3)
  (consult-async-refresh-delay 0.1)
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
  ("M-y" . consult-yank-pop)
  ("M-g f" . consult-flymake)
  ("M-g i" . consult-imenu)
  ;; C-c <key> searches globally, C-c p <key> searches the project.
  ;; Both pairs are defined in keybinds.el.
  ("C-c r" . my/global-rg)
  ("C-c p r" . my/project-rg)
  ("C-c f" . my/global-fd)
  ("C-c p f" . my/project-fd)
  ("C-c p b" . consult-project-buffer)) ;; C-x r to see register info, bookmarks are stored in registers

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
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))))

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
