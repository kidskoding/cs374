#import "setup.typ": notes, appendix
#import "lec01.typ": body as lecture-01
#import "problem-sets/probset01.typ": body as problem-set-01
#import "labs/lab01a.typ": body as lab-01

#set document(
  title: "UIUC CS 374: Introduction to Algorithms and Models of Computation",
  author: "Anirudh Konidala",
)
#show: notes
#set heading(numbering: "1.1")

#align(center + horizon)[
  #text(size: 24pt, weight: "bold")[UIUC CS 374]

  #text(size: 18pt)[Introduction to Algorithms and Models of Computation]

  #v(2em)
  Anirudh Konidala

  August 2026 – December 2026 (Fall 2026)
]
#pagebreak()
#outline(title: [Contents])
#pagebreak()

#lecture-01

// Appendices follow all lectures as back matter.
#pagebreak()
#show: appendix
= Labs
#lab-01
#pagebreak()
= Problem Sets
#problem-set-01
