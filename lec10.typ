#import "setup.typ": *

#let body = [
= Lecture 10 - Recursion: Tower of Hanoi and Mergesort

#keyidea[*Shrink, trust, combine.* Turn a big problem into smaller copies of
the same problem. Trust that the copies get solved. Combine the answers.]

The course now moves from _models of computation_ (DFAs, grammars, Turing machines) to
_algorithms_: how to solve problems *correctly* and *fast*.

== The RealRAM Model
Same cost model as CS 225: anything a C-like language does cheaply is $O(1)$.

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
What a "describe an algorithm" answer needs on homework and exams:

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Give* #sym.checkmark], [*Don't give* #sym.times]),
  [Clear English or pseudocode], [Real code (C++, Rust, Perl, ...)],
  [What each function *returns*], [A correctness proof (if you follow a class pattern)],
  [Running time: recurrence + solution], [A loose bound "just to be safe"],
))

#trap[*Greedy algorithms need a formal proof.* They often look right and are wrong.
Without a proof, graders assume a greedy algorithm is incorrect.]

How answers are graded (target runtimes are not given):

#align(center, table(
  columns: 3,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Correct?*], [*Speed*], [*Credit*]),
  [Yes], [Faster than expected], [Extra credit],
  [Yes], [Slower than expected], [Big partial credit],
  [No], [Fast], [Very little],
))

#keyidea[*Correctness first, then speed.*]

== Reductions and Recursion
A *reduction* solves problem $A$ by using a solver for problem $B$ as a *black box*
(you never look inside it):

#flow([instance of $A$], [black box solves $B$], [answer for $A$])

*Recursion* is a reduction where $B$ is *a smaller copy of $A$ itself*:

#flow([instance of $A$ \ size $n$], [smaller instance(s) \ of $A$], [recursion fairy \ solves them], [combine \ into answer])

If the instance is too small to shrink, answer it directly. That is the *base case*.

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
#keyidea[Never trace what happens *inside* a recursive call. Assume it returns the
right answer. Tracing the calls of the calls overflows your brain.]

Why trusting is allowed: *induction* (Lecture 01). Assume the algorithm is correct on
every smaller input (inductive hypothesis). Then show it is correct on size $n$.

Your three jobs:
+ Every recursive call is on a *strictly smaller* instance of the *same* problem
+ Every *base case* is answered correctly
+ The *combine step* is correct, assuming the recursive calls were correct

== Tower of Hanoi
Puzzle by Édouard Lucas (1883). Move the whole stack from `src` to `dst`.

#grid(
  columns: (1fr, 1fr),
  align: center,
  hanoi(((4, 3, 2, 1), (), ()), caption: [Start]),
  hanoi(((), (), (4, 3, 2, 1)), caption: [Goal]),
)

*Rules:*
- Move *one* disk at a time, from the top of a pile to the top of another peg
- *Never* put a bigger disk on a smaller one

=== The recursive idea
The biggest disk (dark) must move to `dst` at some point. To move it, every
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

#keyidea[The big disk never gets in the way: any disk may sit on it. So moving the
$n - 1$ small disks is *the same puzzle*, just smaller, with a different target peg.]

=== Algorithm
State what the call does, so a reader can check it:

```
Hanoi(n, src, dst, tmp):   ⟨⟨move disks 1..n from src to dst⟩⟩
  if n > 0
    Hanoi(n − 1, src, tmp, dst)     ⟨⟨step 1⟩⟩
    move disk n from src to dst     ⟨⟨step 2⟩⟩
    Hanoi(n − 1, tmp, dst, src)     ⟨⟨step 3⟩⟩
```

Base case: $n = 0$, nothing to move.

=== Counting moves
Let $T(n)$ be the number of moves for $n$ disks. Two recursive calls, plus one move:

$ T(n) = cases(0 & " if " n = 0, 2 T(n - 1) + 1 & " if " n > 0) $

This is a *recurrence*: the cost is written in terms of the cost of smaller inputs.
Compute small values and spot the pattern:

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
Guess-and-verify: check the guess with induction. Assume $T(k) = 2^k - 1$ for all $k < n$.

- $n = 0$: $T(0) = 0 = 2^0 - 1$ #sym.checkmark
- $n > 0$:
  $ T(n) & = 2 T(n - 1) + 1 && quad "definition of " T\
   & = 2 (2^(n - 1) - 1) + 1 && quad "inductive hypothesis"\
   & = 2^n - 1 && quad "arithmetic" $

== Mergesort
Sort $A[1 .. n]$ into increasing order. By von Neumann (1945).

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

Base case: $n <= 1$. Already sorted, nothing to do.

=== Merging
Both halves are sorted, so the smallest remaining element is always at the *front*
of one half. Repeatedly compare the two fronts and take the smaller one:

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

Each comparison places one element, so `Merge` takes *$O(n)$* time. One way to write it:

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
Two half-size recursive calls, plus $O(n)$ for the merge:

$ T(n) = 2 T(n / 2) + O(n) $

#keyidea[Floors and ceilings ($floor(n/2)$ vs $ceil(n/2)$) don't matter when the
problem shrinks by a constant fraction. Just write $n / 2$.]

== Recursion Trees
A picture of every recursive call, used to *solve* recurrences.

- One *node* per recursive call. The *root* is the first call.
- A node's *children* are the recursive calls it makes.
- A node's *value* is the work done in that call, *not counting* its children.

#keyidea[*Total time = sum of all node values.* Add up each level (row) first, then
add up the levels.]

=== Mergesort
The root does $n$ work (the merge). Each child has half the elements, so it does
$n / 2$ work. Each grandchild does $n / 4$. And so on, down to size $1$.

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

- *Every level sums to $n$.*
- *How many levels?* Each level halves the size: $n -> n/2 -> n/4 -> dots -> 1$. You
  can halve $n$ only $log_2 n$ times before reaching $1$.

$ T(n) = underbrace(n, "per level") times underbrace(log_2 n, "levels") = #box(stroke: black, inset: 3pt, [$ O(n log n) $]) $

The log base doesn't matter inside big-$O$ (changing base is a constant factor).

=== The three common shapes
Look at how the level sums change from top to bottom:

#grid(
  columns: (1fr, 1fr, 1fr),
  align: center,
  level-bars([All equal], (1, 1, 1, 1, 1), caption: [total = level sum × levels \ e.g. mergesort: $O(n log n)$]),
  level-bars([Shrinking], (1, 0.66, 0.44, 0.3, 0.2), color: rgb("#27ae60"), caption: [*root* dominates \ total = $O("root")$]),
  level-bars([Growing], (0.2, 0.3, 0.44, 0.66, 1), color: warn-color, caption: [*leaves* dominate \ total = $O(\# "leaves")$]),
)

#v(0.6em)
Shrinking and growing are *geometric series*: each level is the one above times a
fixed ratio $!= 1$ (for example $n, n/3, n/9, dots$). A geometric series is
proportional to its *biggest term*, however many terms it has. Lecture 11 has
examples of both.

#trap[Don't memorize a formula theorem instead. It only fits recurrences with
equal-size pieces. Lecture 11's recurrences don't fit it, but recursion trees still work.]
]

#show: notes
#set heading(numbering: "1.1")
#body
