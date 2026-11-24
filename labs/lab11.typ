#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let dp-skeleton = [
  - *Subproblem* (in English: what $F(...)$ returns, for which part of the input): #todo
  - *Answer* (which call): #todo
  - *Recurrence* (base case(s) and recursive case): #todo
  - *Memoization* (array and size): #todo
  - *Evaluation order*: #todo
  - *Running time*: #todo
]

#let graph-skeleton = [
  Build a directed graph $G$:
  - *Vertices* (what does each one mean? how many?): #todo
  - *Edges* (when is there an edge? how many? is $G$ a dag?): #todo
  - *Values on vertices or edges* (or "none"): #todo
  - *Problem in the graph* (which problem, in $G$, from where to where, and why it answers the question): #todo
  - *Algorithm* (which one, run how, and how you read the answer): #todo
  - *Running time* (in terms of the input size): #todo
]

// Example array from problem 1; true marks an icky number.
#let icky-array = (
  (3, true), (1, true), (4, false), (1, true), (5, true), (9, false), (2, true),
  (6, false), (5, false), (3, true), (5, false), (9, false), (7, false), (9, true),
  (3, false), (2, false), (3, false), (8, true), (4, false), (6, true), (2, false),
  (6, true),
)

// Palindrome dag from problem 2. Keys are unique; labels drop the trailing digit.
#let pal-pos = (
  S: (0, 2), H1: (1, 1), A1: (2, 0), N1: (4, 0), E: (3, 1), O2: (5, 1), N2: (2, 2),
  T1: (4, 2), T2: (6, 2), O1: (1, 3), N3: (3, 3), H2: (5, 3), D: (2, 4), A2: (4, 4),
)
#let pal-edges = (
  ("S", "H1"), ("S", "O1"), ("S", "E"), ("H1", "A1"), ("O1", "H1"), ("O1", "N2"),
  ("O1", "D"), ("A1", "N1"), ("A1", "E"), ("A1", "N2"), ("N1", "T1"), ("N1", "O2"),
  ("E", "T1"), ("E", "N3"), ("N2", "T1"), ("N2", "N3"), ("D", "N2"), ("D", "N3"),
  ("D", "A2"), ("N3", "A2"), ("N3", "T2"), ("A2", "T1"), ("A2", "H2"), ("T1", "O2"),
  ("T1", "H2"), ("O2", "T2"), ("H2", "T2"),
)
#let pal-path = (("H1", "A1"), ("A1", "N2"), ("N2", "N3"), ("N3", "A2"), ("A2", "H2"))

#let body = [
== Lab 11 (November 4)

+ Suppose you are given an array of numbers, some of which are marked as _icky_, and
  you want to compute the length of the longest increasing subsequence of $A$ that
  includes at most $k$ icky numbers. Your input consists of the integer $k$, the number
  array $A[1 .. n]$, and another boolean array $italic("Icky")[1 .. n]$.

  For example, suppose your input consists of the integer $k = 2$ and the following
  array (with icky numbers are indicated by stars):

  #align(center, table(
    columns: icky-array.len(),
    inset: (x: 3.5pt, y: 4pt),
    stroke: (x, y) => (
      top: 0.6pt,
      bottom: 0.6pt,
      left: if x == 0 { 0.6pt } else { (paint: luma(120), thickness: 0.5pt, dash: "dotted") },
      right: if x == icky-array.len() - 1 { 0.6pt },
    ),
    ..icky-array.map(((v, icky)) => if icky { $#v^*$ } else { $#v$ }),
  ))

  Then your algorithm should return the integer 5, which is the length of the
  increasing subsequence $4, 5^*, 6, 7, 9^*$.

  #set enum(numbering: "(a)")
  + Describe an algorithm for this problem using dynamic programming.

    #dp-skeleton

  + Describe an algorithm for this problem by reducing it to a standard graph problem.

    #graph-skeleton

#hrule
*Think about later:*

2. Let $G$ be a directed acyclic graph whose vertices have labels from some fixed
  alphabet. Any directed path in $G$ has a label, which is a string obtained by
  concatenating the labels of its vertices. Recall that a _palindrome_ is a string that
  is equal to its reversal.

  Describe and analyze an algorithm to find the length of the longest palindrome that
  is the label of a path in $G$. For example, given the dag below, your algorithm
  should return the integer 6, which is the length of the palindrome #lit("HANNAH").

  #align(center, graph-pic(
    pal-pos,
    pal-edges,
    directed: true,
    marked: ("H1", "A1", "N2", "N3", "A2", "H2"),
    bold: pal-path,
    unit: 42pt,
    label: n => n.at(0),
  ))

  #set enum(numbering: "(a)")
  + Describe an algorithm for this problem using dynamic programming.

    #dp-skeleton

  + Describe an algorithm for this problem by reducing it to a standard graph problem.

    #graph-skeleton
]

#show: notes
#body
