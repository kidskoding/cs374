#import "setup.typ": *

#let body = [
= Lecture 12 (Oct 6) - Divide and Conquer: Multiplication; Backtracking: Text Segmentation

== Fast Multiplication
Grade-school (lattice) multiplication of two $n$-digit numbers multiplies each digit
of one number by the whole other number, and then adds the results. Each digit costs
$O(n)$ and there are $n$ digits, so the total is $O(n^2)$. Can divide and conquer do
better?

=== Cost model
Normally we use the RealRAM model, in which arithmetic on any number costs $O(1)$.
That model defeats the purpose here, so instead we count *single-digit operations*:
adding, subtracting, or multiplying one pair of digits.

In this model, several operations on $n$-digit numbers are cheap:

- Adding or subtracting two $n$-digit numbers: $O(n)$ (school method)
- Multiplying by a power of $10$ (padding with zeros): $O(n)$
- Splitting a number into its top and bottom digits: $O(n)$

Multiplication is the only hard operation.

=== Split into halves
Let $m = ceil(n / 2)$. We split each input into its $m$ most significant digits and
its $m$ least significant digits:

$ x = a dot 10^m + b #h(3em) y = c dot 10^m + d $

Each of $a, b, c, d$ has at most $m$ digits. Multiplying out (FOIL) gives

$ x y = a c dot 10^(2m) + (a d + b c) dot 10^m + b d $

This identity reduces one $n$-digit product to four $m$-digit products. The procedure
below computes $x y$ for non-negative integers $x$ and $y$ with at most $n$ digits
each.

```
SplitMultiply(x, y, n):
  if n = 1
    return x · y                    ⟨⟨times table⟩⟩
  else
    m ← ⌈n/2⌉
    a ← ⌊x / 10^m⌋;  b ← x mod 10^m
    c ← ⌊y / 10^m⌋;  d ← y mod 10^m
    e ← SplitMultiply(a, c, m)
    f ← SplitMultiply(b, d, m)
    g ← SplitMultiply(b, c, m)
    h ← SplitMultiply(a, d, m)
    return 10^(2m)·e + 10^m·(g + h) + f
```

The `mod` and `/` operations by $10^m$ only chop the digit string, and the final line
consists of padding and addition. All of this work takes $O(n)$ time.

=== Analysis
Let $T(n)$ be the number of single-digit operations. The algorithm makes four
recursive calls of size $n / 2$ and does $O(n)$ extra work, so

$ T(n) = 4 T(n / 2) + O(n) $

#tree-diagram(
  (
    ($n$,),
    ($n\/2$,) * 4,
    ($n\/4$,) * 16,
    ($dots.v$,),
  ),
  labels: ([0], [1], [2], [$dots.v$]),
  sums: ($n$, $4 dot n\/2 = 2n$, $16 dot n\/4 = 4n$, $dots.v$),
  cut: (3,),
  plain: (3,),
  width: 320pt,
  node-w: 17pt,
)

The level sums $n, 2n, 4n, dots$ form an increasing geometric series with ratio $2$.
A geometric series with ratio $!= 1$ is proportional to its largest term, which here
is the bottom level.

#keyidea[When the level sums increase, count the leaves. Every leaf is a base case
and does $O(1)$ work, so the bottom level sum is $O(\# "leaves")$.]

- Each level has $4$ times as many nodes as the one above.
- The subproblem size halves at each level, so there are $log_2 n$ levels.

$ \# "leaves" = 4^(log_2 n) $

To simplify this expression, we use the following log identity, which lets us swap
the base and the argument of the log:

$ a^(log_b c) = c^(log_b a) $

$ T(n) = O(4^(log_2 n)) = O(n^(log_2 4)) = #box(stroke: black, inset: 3pt, [$ O(n^2) $]) $

This is no improvement over the grade-school method. Until 1960, people believed that
$O(n^2)$ was the best possible.

== Karatsuba's Algorithm
In 1960, Karatsuba noticed that the middle term needs only one new product. Adding and
subtracting $a c$ and $b d$ gives

$ a d + b c = a c + b d - (a - b)(c - d) $

To check this identity, note that $(a - b)(c - d) = a c - a d - b c + b d$, so
$a c + b d - (a - b)(c - d) = a d + b c$.

The products $a c$ and $b d$ are needed anyway, so three recursive calls suffice:
$a c$, $b d$, and $(a - b)(c - d)$.

```
FastMultiply(x, y, n):
  if n = 1
    return x · y
  else
    m ← ⌈n/2⌉
    a ← ⌊x / 10^m⌋;  b ← x mod 10^m
    c ← ⌊y / 10^m⌋;  d ← y mod 10^m
    e ← FastMultiply(a, c, m)
    f ← FastMultiply(b, d, m)
    g ← FastMultiply(a − b, c − d, m)
    return 10^(2m)·e + 10^m·(e + f − g) + f
```

#trap[The differences $a - b$ and $c - d$ can be negative, although both still have
at most $m$ digits. Multiply their absolute values recursively, and then fix the
sign.]

=== Analysis
Karatsuba's algorithm makes three recursive calls, still on size $n / 2$, and still
does $O(n)$ extra work:

$ T(n) = 3 T(n / 2) + O(n) $

#tree-diagram(
  (
    ($n$,),
    ($n\/2$,) * 3,
    ($n\/4$,) * 9,
    ($dots.v$,),
  ),
  labels: ([0], [1], [2], [$dots.v$]),
  sums: ($n$, $3 dot n\/2 = 3n\/2$, $9 dot n\/4 = 9n\/4$, $dots.v$),
  cut: (3,),
  plain: (3,),
  width: 320pt,
  node-w: 22pt,
)

The level sums still increase geometrically, now with ratio $3 / 2$, so we count the
leaves. The depth is still $log_2 n$, but each level now has $3$ times as many nodes:

$ T(n) = O(3^(log_2 n)) = O(n^(log_2 3)) = #box(stroke: black, inset: 3pt, [$ O(n^(1.585)) $]) $

#grid(
  columns: (1fr, 1fr),
  align: center,
  level-bars([4 calls (ratio 2)], (0.25, 0.5, 1, 2), color: warn-color, caption: [$O(n^2)$]),
  level-bars([3 calls (ratio 3/2)], (0.25, 0.375, 0.5625, 0.84), caption: [$O(n^(1.585))$]),
)

#keyidea[We should keep the number of recursive calls small. The subproblem sizes
shrink the same way in both algorithms, yet one call fewer turns $n^2$ into
$n^(1.585)$, because the leaf count is $(\# "calls")^("depth")$.]

=== Later history
By chopping the numbers into more pieces and combining the products more cleverly,
later algorithms reduce the running time further:

- 1971 (Schönhage and Strassen): $O(n log n log log n)$
- 2019 (Harvey and van der Hoeven): $O(n log n)$

The 2019 algorithm is purely theoretical; it beats the 1971 algorithm only on numbers
with more digits than there are particles in the universe.

=== Recursion tree shapes, all three seen
#align(center, table(
  columns: 3,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Level sums*], [*Total*], [*Example*]),
  [Equal], [level sum $times$ \# levels], [Mergesort: $O(n log n)$],
  [Decreasing geometric], [$O("root")$], [Mom select: $O(n)$],
  [Increasing geometric], [$O(\# "leaves")$], [Karatsuba: $O(n^(log_2 3))$],
))

== Backtracking
Lectures 12 through 15 cover a second recursive strategy. This lecture is concerned
only with correctness; Lecture 13 shows how to make these algorithms fast.

Many problems require a sequence of decisions. We may want to:

- List every way to do a task
- Find the best way to do a task
- Decide whether the task is possible at all

#keyidea[Make one decision, try every option for it, and recurse on the consequences
of each option. The recursion fairy makes all the other decisions.]

How we use the recursive results depends on the goal:

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Goal*], [*Combine the recursive results by*]),
  [List all solutions], [Collect the results of every call],
  [Find the best solution], [Keep the best result],
  [Is it possible?], [Return true if *any* call returns true (OR)],
))

== Text Segmentation
The input is a string $A[1 .. n]$ with the spaces removed, together with a black-box
function $text("IsWord")$ that says whether a string is a word. The output is true if
$A$ can be partitioned into substrings that are all words, and false otherwise.

Ancient Latin was often written without spaces, so this is a real problem. Deciding
what counts as a "word" is the job of $text("IsWord")$, so we need not worry about it.

=== Decisions
We choose the words one at a time, from left to right. Each decision is what the next
word should be.

For example, consider the string `BLUESTEMUNITROBOTHEARTHANDSATURNSPIN`, and suppose
the first four words are `BLUE STEM UNIT ROBOT`. The next word could be any of the
following:

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Next word*], [*Left to segment*]),
  [`HE`], [`ARTHANDSATURNSPIN`],
  [`HEAR`], [`THANDSATURNSPIN`],
  [`HEART`], [`HANDSATURNSPIN`],
  [`HEARTH`], [`ANDSATURNSPIN`],
))

We do not know which choice is right, so we try all four. For each choice, we
recursively ask whether the rest of the string can be segmented. If any one of these
calls succeeds, the whole string can be segmented.

=== The recursive subproblem
What does the recursion fairy need to know? The words chosen so far are irrelevant;
only the characters that remain matter. Many different earlier choices can lead to
the same remaining suffix, and the answer for that suffix is the same each time.

#keyidea[Finding the right recursive subproblem is the main goal. Here the subproblem
is "can this suffix be segmented?", and the algorithm follows almost automatically.]

For the base case, the empty string can always be segmented, into zero words, so the
algorithm returns true.

```
Splittable(A[1..n]):
  if n = 0
    return True
  for i ← 1 to n
    if IsWord(A[1..i])
      if Splittable(A[i + 1..n])
        return True
  return False
```

The algorithm tries every possible first word $A[1 .. i]$. If it is a word and the
rest $A[i + 1 .. n]$ can be segmented, the algorithm succeeds. If no first word works,
it fails.

#trap[This algorithm is not greedy. A greedy algorithm commits to one choice, for
example "always take the shortest first word", and such a rule is probably wrong for
some inputs. Backtracking tries every choice, so it is always correct.]

=== Running time
The algorithm is correct but slow: it can make $O(2^n)$ calls to $text("IsWord")$.
Lecture 13 shows how to make it fast.

=== Pass indices, not arrays
Copying the suffix into every recursive call is wasteful. Instead, we make
$A[1 .. n]$ a global array. Every subproblem is a suffix, so a single index identifies
it: $text("Splittable")(i)$ asks whether $A[i .. n]$ can be segmented.

```
Splittable(i):                      ⟨⟨A[1..n] is global⟩⟩
  if i > n
    return True
  for j ← i to n
    if IsWord(i, j)
      if Splittable(j + 1)
        return True
  return False
```

=== As a recurrence
The input is one integer and the output is a boolean, so $text("Splittable")$ is a
mathematical function, and we can define it with a recurrence instead of pseudocode.
We define:

- $text("IsWord")(i, j)$: true if and only if the substring $A[i .. j]$ is a word
- $text("Splittable")(i)$: true if and only if the suffix $A[i .. n]$ can be segmented

$ text("Splittable")(i) = cases(
  "True" & "if" i > n,
  limits(or.big)_(j = i)^n (text("IsWord")(i, j) and text("Splittable")(j + 1)) & "otherwise"
) $

The big $or$ tries every possible end $j$ of the first word. The answer to the
original problem is $text("Splittable")(1)$.

This recurrence describes the same algorithm as the pseudocode. Lecture 13 turns this
form into a fast algorithm almost mechanically.

== Summary: the Backtracking Recipe
+ Think of the problem as a sequence of decisions (here, the next word).
+ Find the recursive subproblem: what the recursion fairy must know to finish (here,
  the remaining suffix, represented by one index $i$).
+ Try every option for one decision, and recurse on each.
+ Pick a base case where no decision is left (here, the empty suffix, whose answer is
  true).
+ Write the algorithm as a recurrence on indices, and say which call answers the
  original problem.

#trap[Do not skip steps 1 and 2, even after Lecture 13. The speedup works only once we
have a correct recurrence to apply it to.]

More backtracking examples appear in the course notes and in Chapter 2 of Erickson's
book.
]

#show: notes
#set heading(numbering: "1.1")
#body
