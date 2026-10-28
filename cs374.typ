#import "setup.typ": notes, appendix

#import "lec01_08_25_26.typ": body as lecture-01
#import "lec10_09_29_26.typ": body as lecture-10
#import "lec11_10_01_26.typ": body as lecture-11
#import "lec12_10_06_26.typ": body as lecture-12

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

// Every lecture starts on a new page.
#show heading.where(level: 1): it => pagebreak(weak: true) + it

#lecture-01
#lecture-10
#lecture-11
#lecture-12

// Appendices follow all lectures as back matter.
#pagebreak()
#show: appendix
= Labs
// Each lab starts on a new page; Lab 1A shares the page with the appendix title.
#lab-01a
#pagebreak()
#lab-01b
#pagebreak()
= Problem Sets
#prob-set-01
