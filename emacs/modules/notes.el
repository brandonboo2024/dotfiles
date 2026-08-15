;; -*- lexical-binding: t; -*-

;; Keep Org deliberately bare while the organisation system is rebuilt from
;; actual use.  Files, captures, agendas, task states and advanced note tooling
;; can be added later without carrying assumptions from the previous setup.
(use-package org
  :straight nil
  :custom
  (org-directory (file-truename "~/org/")))

(provide 'notes)
