;; -*- lexical-binding: t; -*-

;; Completion and self-documentation: the minimum to keep after an Emacs
;; bankruptcy.
;;   Vertico      minibuffer UI          Orderless   matching
;;   Corfu, Cape  in-buffer completion   Marginalia  annotations
;;   Consult      search and navigation  Embark      actions on candidates
;;   which-key, Helpful                  self-documentation

(use-package vertico
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
  ;; Code only; text-mode buffers get completion-preview ghost text instead.
  (global-corfu-modes '(prog-mode))
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 3)
  (corfu-auto-delay 0.3)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (corfu-popupinfo-mode +1)
  (global-corfu-mode))

;; Extra completion sources (file names, dabbrev) for Corfu.
(use-package cape
  :defer 10
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

(use-package which-key
  :straight nil
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
  ("M-g I" . consult-imenu-multi)
  ("M-g o" . consult-outline)
  ("M-g g" . consult-goto-line)
  ("M-g M-g" . consult-goto-line)
  ("M-g m" . consult-mark)
  ("M-g k" . consult-global-mark)
  ("M-g e" . consult-compile-error)
  ;; C-c <key> searches globally, C-c p <key> searches the project.
  ;; Both pairs are defined in keybinds.el.
  ("C-c r" . my/global-rg)
  ("C-c p r" . my/project-rg)
  ("C-c f" . my/global-fd)
  ("C-c p f" . my/project-fd)
  ("C-c p b" . consult-project-buffer))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :custom
  (prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after  (embark consult))

(use-package wgrep
  :defer t)

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))))

(use-package marginalia
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
