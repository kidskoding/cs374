;;; Directory Local Variables. -*- no-byte-compile: t -*-

;; Layout of this course, read by `+org-live-pdf-mode' from cs374.org.
;; (DIR PDF-DIR IN-BOOK), each dir relative to cs374.org.
;;   PDF-DIR nil -> no standalone PDF, it only appears in cs374.pdf
;;   IN-BOOK nil -> never in cs374.pdf, standalone only
((org-mode
  . ((+org-live-pdf-children
      . (("."             "lectures"       t)
         ("problem-sets"  nil              t)
         ("labs"          nil              t)
         ("homeworks/org" "homeworks/pdfs" nil))))))
