#import "setup.typ": notes, appendix

#import "lec01.typ": body as lecture-01
#import "lec10.typ": body as lecture-10
#import "lec11.typ": body as lecture-11

#import "labs/lab01a.typ": body as lab-01a 
#import "labs/lab01b.typ": body as lab-01b 

#import "problem-sets/probset01.typ": body as prob-set-01

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
#lecture-10
#lecture-11

// Appendices follow all lectures as back matter.
#pagebreak()
#show: appendix
= Labs
#lab-01a
#lab-01b
#pagebreak()
= Problem Sets
#prob-set-01
