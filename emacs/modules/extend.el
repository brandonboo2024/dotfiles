;; -*- lexical-binding: t; -*-

;; Contains extensions/functionalities to further extend emacs
;; Are all useful/cannot be replaced, but I would not consider them important enough to be part of core.el in a major cleanse

;; (use-package vterm
;;   :custom
;;   (display-line-numbers-mode 0)
;;   :config
;;   (defun vterm-send-Ctrl-c ()
;;     (interactive) (vterm-send-key "c" nil nil t))
;;   (defun vterm-send-Ctrl-d ()
;;     (interactive) (vterm-send-key "d" nil nil t))
;;   :bind(:map vterm-mode-map
;;              ("C-c ESC" . vterm-send-escape)
;;              ("C-c C-c" . vterm-send-Ctrl-c)
;;              ("C-c C-d" . vterm-send-Ctrl-d)))

(use-package pdf-tools
  :straight nil
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-loader-install))

(use-package no-littering
  ;; Available via straight/elpa. Straight will install it.
  :custom
  (no-littering-etc-directory (expand-file-name "etc/" user-emacs-directory))
  (no-littering-var-directory (expand-file-name "var/" user-emacs-directory)))

(use-package eat
  :custom
  (eat-term-name "xterm-256color"))

(use-package notmuch
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

      ;; systems / low-level — these are essential for you
      ("https://nullprogram.com/feed/"          systems c emacs)
      ("https://drewdevault.com/blog/index.xml" systems)

      ;; linux
      ("https://lwn.net/headlines/rss"          linux)

      ;; emacs
      ("https://planet.emacslife.com/atom.xml"  emacs)))

  (setq elfeed-search-filter "@2-weeks-ago +unread")
  :bind
  ("C-c e f" . elfeed))

(provide 'extend)
