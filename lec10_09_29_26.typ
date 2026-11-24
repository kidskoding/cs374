#import "setup.typ": *

#let body = [
= Lecture 10 (Sep 29) - Recursion: Tower of Hanoi and Mergesort

#keyidea[Recursion follows the pattern shrink, trust, combine. We turn a big problem
into smaller copies of the same problem, trust that the copies are solved, and
combine their answers.]

At this point the course moves from _models of computation_ (DFAs, grammars, and Turing
machines) to _algorithms_, that is, to the question of how to solve problems correctly and fast.

== The RealRAM Model
We use the same cost model as CS 225, in which anything a C-like language does cheaply
takes $O(1)$ time.

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Operation*], [*Cost*]),
  [Arithmetic on a number], [$O(1)$],
  [Read or write `A[i]`], [$O(1)$],
  [Follow a pointer / reference], [$O(1)$],
  [Call a function (overhead)], [$O(1)$],
))

== Describing Algorithms
On homework and exams, an answer to a "describe an algorithm" question should contain
the following:

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Give* #sym.checkmark], [*Don't give* #sym.times]),
  [Clear English or pseudocode], [Real code (C++, Rust, Perl, ...)],
  [What each function *returns*], [A correctness proof (if you follow a class pattern)],
  [Running time: recurrence + solution], [A loose bound "just to be safe"],
))

#trap[Greedy algorithms need a formal proof. They often look right and are wrong,
so without a proof, graders assume that a greedy algorithm is incorrect.]

Answers are graded as shown below. Target running times are not given.

#align(center, table(
  columns: 3,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Correct?*], [*Speed*], [*Credit*]),
  [Yes], [Faster than expected], [Extra credit],
  [Yes], [Slower than expected], [Big partial credit],
  [No], [Fast], [Very little],
))

#keyidea[Correctness comes first, then speed.]

== Reductions and Recursion
A *reduction* solves a problem $A$ by using a solver for another problem $B$ as a
*black box*, one whose inside we never look at:

#flow([instance of $A$], [black box solves $B$], [answer for $A$])

*Recursion* is a reduction in which $B$ is a smaller copy of $A$ itself:

#flow([instance of $A$ \ size $n$], [smaller instance(s) \ of $A$], [recursion fairy \ solves them], [combine \ into answer])

If the instance is too small to shrink, we answer it directly; this is the *base case*.

=== Example: sum of an array

```
Sum(A[1..n]):
  if n = 0
    return 0                       ⟨⟨base case⟩⟩
  return Sum(A[1..n − 1]) + A[n]   ⟨⟨trust the smaller call⟩⟩
```

#align(center, grid(
  columns: 8,
  column-gutter: 3pt,
  align: center + horizon,
  `Sum(`, cells(3, 1, 4, hl: (2,)), `)`, h(6pt) + $=$ + h(6pt),
  `Sum(`, cells(3, 1, fill: accent-light), `)`, h(4pt) + $+ 4 = 4 + 4 = 8$,
))

#align(center, text(size: 0.85em)[Blue part: handed to the recursion fairy, who returns $4$. Yellow part: our own work.])

=== The recursion fairy
#keyidea[Never trace what happens inside a recursive call; assume that it returns the
right answer. Tracing the calls made by those calls quickly becomes more than anyone can
keep track of.]

This trust is justified by induction (Lecture 01). We assume that the algorithm is
correct on every smaller input, which is the inductive hypothesis, and then show that it
is correct on inputs of size $n$.

We therefore have three jobs:
+ Every recursive call must be on a strictly smaller instance of the same problem.
+ Every base case must be answered correctly.
+ The combine step must be correct, assuming that the recursive calls were correct.

== Tower of Hanoi
The Tower of Hanoi is a puzzle by Édouard Lucas (1883). The goal is to move the whole
stack from `src` to `dst`.

#grid(
  columns: (1fr, 1fr),
  align: center,
  hanoi(((4, 3, 2, 1), (), ()), caption: [Start]),
  hanoi(((), (), (4, 3, 2, 1)), caption: [Goal]),
)

The puzzle has two rules:
- We may move only one disk at a time, from the top of a pile to the top of another peg.
- We may never put a bigger disk on a smaller one.

=== The recursive idea
At some point the biggest disk (drawn dark) must move to `dst`. To move it, every
smaller disk must be out of the way, stacked on `tmp`.

#block(breakable: false, grid(
  columns: (1fr, 1fr),
  row-gutter: 14pt,
  align: center,
  hanoi(((4, 3, 2, 1), (), ()), caption: [Start]),
  hanoi(((4,), (3, 2, 1), ()), caption: [*Step 1:* recursively move $n - 1$ disks to `tmp`]),
  hanoi(((), (3, 2, 1), (4,)), caption: [*Step 2:* move the biggest disk to `dst`]),
  hanoi(((), (), (4, 3, 2, 1)), caption: [*Step 3:* recursively move $n - 1$ disks onto it]),
))

#keyidea[The big disk never gets in the way, because any disk may sit on it. Moving the
$n - 1$ small disks is therefore the same puzzle on fewer disks, with a different target peg.]

=== Algorithm
We state what the call does, so that a reader can check it:

```
Hanoi(n, src, dst, tmp):   ⟨⟨move disks 1..n from src to dst⟩⟩
  if n > 0
    Hanoi(n − 1, src, tmp, dst)     ⟨⟨step 1⟩⟩
    move disk n from src to dst     ⟨⟨step 2⟩⟩
    Hanoi(n − 1, tmp, dst, src)     ⟨⟨step 3⟩⟩
```

The base case is $n = 0$, where there is nothing to move.

=== Counting moves
Let $T(n)$ be the number of moves the algorithm makes for $n$ disks. Each call makes two
recursive calls plus one move, so

$ T(n) = cases(0 & " if " n = 0, 2 T(n - 1) + 1 & " if " n > 0) $

This is a *recurrence*, which writes the cost in terms of the cost of smaller inputs.
We compute small values and look for a pattern:

#align(center, table(
  columns: 7,
  inset: (x: 9pt, y: 5pt),
  stroke: 0.5pt,
  [$n$], [0], [1], [2], [3], [4], [5],
  [$T(n)$], [0], [1], [3], [7], [15], [31],
  [$2^n - 1$], [0], [1], [3], [7], [15], [31],
))

$ #box(stroke: black, inset: 3pt, [$ T(n) = 2^n - 1 $]) $

=== Proof by induction
This method is called guess-and-verify: we check the guess by induction. Assume that
$T(k) = 2^k - 1$ for all $k < n$.

- $n = 0$: $T(0) = 0 = 2^0 - 1$ #sym.checkmark
- $n > 0$:
  $ T(n) & = 2 T(n - 1) + 1 && quad "definition of " T\
   & = 2 (2^(n - 1) - 1) + 1 && quad "inductive hypothesis"\
   & = 2^n - 1 && quad "arithmetic" $

== Mergesort
Mergesort sorts $A[1 .. n]$ into increasing order. It is due to von Neumann (1945).

#align(center, block(breakable: false, grid(
  columns: 1,
  row-gutter: 7pt,
  align: center,
  cells(5, 2, 8, 1, 9, 3, 7, 4),
  text(size: 0.85em, fill: accent)[$arrow.b$ *divide* into two halves],
  [#cells(5, 2, 8, 1) #h(2em) #cells(9, 3, 7, 4)],
  text(size: 0.85em, fill: accent)[$arrow.b$ *recursion fairy* sorts each half],
  [#cells(1, 2, 5, 8, fill: accent-light) #h(2em) #cells(3, 4, 7, 9, fill: accent-light)],
  text(size: 0.85em, fill: accent)[$arrow.b$ *merge* the sorted halves],
  cells(1, 2, 3, 4, 5, 7, 8, 9, fill: mark-color),
)))

```
MergeSort(A[1..n]):
  if n > 1
    m ← ⌊n/2⌋
    MergeSort(A[1..m])
    MergeSort(A[m+1..n])
    Merge(A[1..n], m)
```

The base case is $n <= 1$, where the array is already sorted and there is nothing to do.

=== Merging
Because both halves are sorted, the smallest remaining element is always at the front
of one half. We repeatedly compare the two fronts and take the smaller one:

#align(center, table(
  columns: 4,
  inset: (x: 9pt, y: 4pt),
  stroke: 0.5pt,
  align: center + horizon,
  table.header([*Left half*], [*Right half*], [*Take*], [*Output so far*]),
  [#cells(1, 2, 5, 8, hl: (0,))], [#cells(3, 4, 7, 9, hl: (0,))], [1], [1],
  [#cells(2, 5, 8, hl: (0,))], [#cells(3, 4, 7, 9, hl: (0,))], [2], [1 2],
  [#cells(5, 8, hl: (0,))], [#cells(3, 4, 7, 9, hl: (0,))], [3], [1 2 3],
  [#cells(5, 8, hl: (0,))], [#cells(4, 7, 9, hl: (0,))], [4], [1 2 3 4],
  [#cells(5, 8, hl: (0,))], [#cells(7, 9, hl: (0,))], [5], [1 2 3 4 5],
  [$dots.v$], [$dots.v$], [$dots.v$], [$dots.v$],
))

Each comparison places one element, so `Merge` takes $O(n)$ time. Here is one way to write it:

```
Merge(A[1..n], m):
  i ← 1;  j ← m + 1          ⟨⟨fronts of the two halves⟩⟩
  for k ← 1 to n
    if j > n                 ⟨⟨right half used up⟩⟩
      B[k] ← A[i];  i ← i + 1
    else if i > m            ⟨⟨left half used up⟩⟩
      B[k] ← A[j];  j ← j + 1
    else if A[i] < A[j]
      B[k] ← A[i];  i ← i + 1
    else
      B[k] ← A[j];  j ← j + 1
  for k ← 1 to n
    A[k] ← B[k]
```

=== Recurrence
Mergesort makes two half-size recursive calls, plus $O(n)$ work for the merge, so

$ T(n) = 2 T(n / 2) + O(n) $

#keyidea[Floors and ceilings ($floor(n/2)$ versus $ceil(n/2)$) do not matter when the
problem shrinks by a constant fraction, so we simply write $n / 2$.]

== Recursion Trees
A *recursion tree* is a picture of every recursive call, which we use to solve recurrences.

- The tree has one *node* for each recursive call, and the *root* is the first call.
- A node's *children* are the recursive calls it makes.
- A node's *value* is the work done in that call, not counting its children.

#keyidea[The total time is the sum of all node values. We add up each level (row)
first, and then add up the levels.]

=== Mergesort
The root does $n$ work for the merge. Each child has half the elements, so it does
$n / 2$ work; each grandchild does $n / 4$; and so on, down to size $1$.

#tree-diagram(
  (
    ($n$,),
    ($n\/2$,) * 2,
    ($n\/4$,) * 4,
    ($n\/8$,) * 8,
    ($dots.v$,),
    ($1$,) * 8,
  ),
  labels: ([0], [1], [2], [3], [$dots.v$], [$log_2 n$]),
  sums: ($n$, $2 dot n\/2 = n$, $4 dot n\/4 = n$, $8 dot n\/8 = n$, $dots.v$, $n$),
  cut: (4, 5),
  plain: (4,),
)

- Every level sums to $n$.
- Each level halves the size: $n -> n/2 -> n/4 -> dots -> 1$. We can halve $n$ only
  $log_2 n$ times before reaching $1$, so there are $log_2 n$ levels.

$ T(n) = underbrace(n, "per level") times underbrace(log_2 n, "levels") = #box(stroke: black, inset: 3pt, [$ O(n log n) $]) $

The base of the logarithm does not matter inside big-$O$, because changing the base
changes the value by only a constant factor.

=== The three common shapes
We classify a recursion tree by how its level sums change from top to bottom:

#grid(
  columns: (1fr, 1fr, 1fr),
  align: center,
  level-bars([All equal], (1, 1, 1, 1, 1), caption: [total = level sum × levels \ e.g. mergesort: $O(n log n)$]),
  level-bars([Shrinking], (1, 0.66, 0.44, 0.3, 0.2), color: rgb("#27ae60"), caption: [*root* dominates \ total = $O("root")$]),
  level-bars([Growing], (0.2, 0.3, 0.44, 0.66, 1), color: warn-color, caption: [*leaves* dominate \ total = $O(\# "leaves")$]),
)

#v(0.6em)
In the shrinking and growing cases, the level sums form a *geometric series*, in which
each level is the one above times a fixed ratio $!= 1$ (for example $n, n/3, n/9, dots$).
A geometric series is proportional to its biggest term, however many terms it has.
Lecture 11 has examples of both.

#trap[Do not memorize a formula theorem in place of recursion trees. Such a theorem
fits only recurrences with equal-size pieces. The recurrences in Lecture 11 do not fit
it, but recursion trees still work for them.]
]

#show: notes
#set heading(numbering: "1.1")
#body
