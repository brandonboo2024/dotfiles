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

;; Where candidates are displayed is vertico's concern, not consult's --
;; consult only supplies the candidates, and shows previews through ordinary
;; `display-buffer'. multiform lets the display be chosen per command, so the
;; commands worth a window get one and the rest stay in the fast bottom
;; minibuffer.
;;
;; :straight nil because MELPA's vertico recipe ships extensions/ alongside
;; vertico itself. These are already built; nothing new is cloned.
(use-package vertico-multiform
  :straight nil
  :after vertico
  :custom
  ;; Candidates in a narrow window on the left, preview on the right in the
  ;; window that was already selected. Both constants are single values on
  ;; purpose -- they are meant to be revised after looking at them on the
  ;; panel, not predicted.
  (vertico-buffer-display-action
   '(display-buffer-in-direction
     (direction . left)
     (window-width . 0.3)))
  (vertico-multiform-commands
   ;; Only the four search wrappers from keybinds.el. M-x, consult-buffer and
   ;; the rest keep the bottom minibuffer, where a two-keystroke command
   ;; should not be rearranging windows.
   ;;
   ;; consult-line is deliberately absent: it previews by scrolling the
   ;; current buffer, so giving it a window would displace the very thing it
   ;; is previewing.
   '((my/project-fd buffer)
     (my/global-fd buffer)
     (my/project-rg buffer)
     (my/global-rg buffer)))
  :config
  (vertico-multiform-mode))

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
  ;; my/project-fd now opens with the full file list already live, so these
  ;; govern how the list feels while typing rather than how long it takes to
  ;; appear at all. Upstream defaults are 0.2 / 0.5 / 0.2.
  (consult-async-input-debounce 0.1)
  (consult-async-input-throttle 0.3)
  (consult-async-refresh-delay 0.1)
  :bind
  ("C-x b" . consult-buffer)
  ("C-s" . consult-line)
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
