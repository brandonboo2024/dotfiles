;; -*- lexical-binding: t; -*-

;; Contains extensions/functionalities to further extend emacs
;; Are all useful/cannot be replaced, but I would not consider them important enough to be part of core.el in a major cleanse

;; Zoom keys in pdf-view-mode: + / = enlarge, - shrink, 0 reset to
;; `pdf-view-display-size', W fit width, H fit height, P fit page. `s b' crops
;; to the text bounding box, which is the real fix for a scanned page with
;; wide margins; `s r' undoes it.
(use-package pdf-tools
  :straight nil
  :magic ("%PDF" . pdf-view-mode)
  :custom
  (pdf-view-display-size 'fit-page)
  ;; Default 1.25 is a coarse step at this DPI.
  (pdf-view-resize-factor 1.1)
  :config
  (pdf-loader-install))

(use-package eat
  :custom
  (eat-term-name "xterm-256color"))

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

(use-package gptel
  :config
  (setq gptel-model 'cohere/north-mini-code:free
        gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key #'gptel-api-key
          :models '(cohere/north-mini-code:free
                    openrouter/owl-alpha
                    poolside/laguna-m.1:free))))

;; meow lives in meow-config.el, which owns both its key tables and the
;; package declaration.

(provide 'extend)
