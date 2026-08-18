;; -*- lexical-binding: t; -*-

;; Contains extensions/functionalities to further extend emacs
;; Are all useful/cannot be replaced, but I would not consider them important enough to be part of core.el in a major cleanse

(use-package ghostel
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("C-k"  . my/ghostel-send-C-k-and-kill)
         ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :config
  (defun my/ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-compile
  :straight ghostel
  :hook (after-init . ghostel-compile-global-mode))

(setq send-mail-function 'mailclient-send-it)

(use-package notmuch
  :straight nil
  :commands (notmuch-hello)
  :custom
  (notmuch-database-path "~/mail")
  (sendmail-program "msmtp")
  :config
  (setq user-full-name "Brandon Boo")
  (setq user-mail-address "jwboo@posteo.com")
  (setq message-sendmail-extra-arguments '("-a" "posteo"))
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  (setq notmuch-saved-searches
        '((:name "inbox"  :query "tag:inbox"  :key "i")
          (:name "unread" :query "tag:unread" :key "u")
          (:name "emacs"  :query "tag:emacs"  :key "e")
          (:name "linux"  :query "tag:linux"  :key "l")
          (:name "nix"    :query "tag:nix"    :key "n")
          (:name "sent"   :query "tag:sent"   :key "s")))
  :bind
  ("C-c e g" . notmuch)
  ("C-c e c" . notmuch-mua-mail))

(use-package elfeed
  :config
  (setq elfeed-feeds
    '(;; zig
      ("https://ziglang.org/news/index.xml"    zig)
      ("https://ziglang.org/devlog/index.xml"  zig dev)

      ;; c / c++
      ("https://isocpp.org/blog/rss/rss.xml"   cpp)
      ("https://herbsutter.com/feed/"           cpp)

      ;; systems / low-level
      ("https://nullprogram.com/feed/"          systems c emacs)
      ("https://drewdevault.com/blog/index.xml" systems)

      ;; linux
      ("https://lwn.net/headlines/rss"          linux)

      ;; emacs
      ("https://planet.emacslife.com/atom.xml"  emacs)))

  (setq elfeed-search-filter "@2-weeks-ago +unread")
  :bind
  ("C-c e f" . elfeed))

(use-package undo-fu
  :bind
  ([remap undo] . undo-fu-only-undo)
  ([remap undo-redo] . undo-fu-only-redo))

(use-package jinx
  :straight nil
  :hook (text-mode . jinx-mode)
  :bind ("M-$" . jinx-correct)
  :custom
  (jinx-languages "en_US")
  (text-mode-ispell-word-completion nil))

;; uses ~/.authinfo
(use-package gptel
  :config
  (setq gptel-model 'openai/gpt-oss-20b:free
        gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key #'gptel-api-key
          :models '(openai/gpt-oss-20b:free))))

;; meow lives in meow-config.el, which owns both its key tables and the
;; package declaration.

(provide 'extend)
