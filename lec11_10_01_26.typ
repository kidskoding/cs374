#import "setup.typ": *

// Median-of-medians grid: 5 rows, odd number of columns. Columns are sorted top to
// bottom, then ordered by their medians (middle row). Top-left cells are <= mom.
#let mom-grid(cols: 9) = {
  let mid = calc.quo(cols, 2)
  grid(
    columns: (14pt,) * cols,
    rows: 14pt,
    stroke: 0.5pt,
    fill: (x, y) => if x == mid and y == 2 { rgb("#5dade2") }
      else if y == 2 { rgb("#f7dc6f") }
      else if x <= mid and y <= 2 { luma(215) }
      else { white },
    ..range(5 * cols).map(_ => []),
  )
}

#let body = [
= Lecture 11 (Oct 1) - Divide and Conquer: Quicksort and Linear Time Selection

== Divide and Conquer
Mergesort is an example of a *divide and conquer* algorithm. There are no hard rules
for what counts as divide and conquer, but such algorithms generally follow three
steps:

+ Divide the problem into smaller instances of the same problem.
+ Delegate the smaller instances to the recursion fairy.
+ Combine the solutions of the subproblems into a solution for the original
  instance. This step usually requires some extra work.

In mergesort, we divide the array into two halves of size about $n / 2$, sort both
halves recursively, and then combine them with `Merge`. Combining two sorted arrays
is much easier than sorting from scratch.

To analyze a divide and conquer algorithm, we write a *recurrence* for its running
time in terms of the running times on the smaller instances, and then solve the
recurrence, usually with a recursion tree.

== Quicksort
Quicksort was introduced by Tony Hoare in 1961. It works as follows.

+ Choose a *pivot* element. The choice is arbitrary; any element is allowed.
+ *Partition* the array in linear time, moving every element smaller than the pivot
  to its left and every element bigger than the pivot to its right.
+ The pivot is now in its final position, although the two sides are not yet sorted.
  Neither side contains the pivot, so both sides are strictly smaller. Recursively
  sort the left side, and then recursively sort the right side.

```
QuickSort(A[1..n]):
  if n > 1
    choose a pivot element A[p]
    r ← Partition(A, p)
    QuickSort(A[1..r − 1])
    QuickSort(A[r + 1..n])
```

=== Rank
`Partition` returns $r$, the new index of the pivot. This index is the *rank* of the
pivot:

- $text("rank")(x) = 1 + (text("number of elements smaller than ") x)$
- Equivalently, the rank is the position of $x$ in sorted order, counting from 1.

After partitioning, the elements smaller than the pivot are in $A[1 .. r - 1]$ and the
elements larger are in $A[r + 1 .. n]$. Duplicate elements cause no problem if we take
the rank to mean the pivot's final position.

=== Partition
We include the partition algorithm only for completeness. Its correctness argument
is subtle; see the lecture notes and Erickson's book for details. The algorithm first
moves the pivot to the end of the array, out of the way. It then walks through the
array, and whenever it finds an element smaller than the pivot, it swaps that element
into the left part. Finally, it swaps the pivot into place.

```
Partition(A[1..n], p):
  swap A[p] ↔ A[n]
  ℓ ← 0                          ⟨⟨#items < pivot⟩⟩
  for i ← 1 to n − 1
    if A[i] < A[n]
      ℓ ← ℓ + 1
      swap A[ℓ] ↔ A[i]
  swap A[n] ↔ A[ℓ + 1]
  return ℓ + 1
```

Partitioning takes $O(n)$ time.

=== Worst case
The recursive calls need not be on halves of the array. If the pivot has rank $r$,
the running time satisfies

$ T(n) = T(r - 1) + T(n - r) + O(n) $

If the pivot is the smallest or largest element, one recursive call is empty and the
other has $n - 1$ elements, so

$ T(n) = T(n - 1) + O(n) $

In this case the recursion tree is a single long path:

#recursion-tree(
  ([0], ($n$,), $n$),
  ([1], ($n - 1$,), $n - 1$),
  ([2], ($n - 2$,), $n - 2$),
  ([$dots.v$], ($dots.h$,), $dots.v$),
  ([$n - 1$], ($1$,), $1$),
)

The level sums form an arithmetic series. Unlike the sum of a geometric series, its
sum is proportional to (largest term) $times$ (number of terms):

$ T(n) = sum_(i = 1)^n i = #box(stroke: black, inset: 3pt, [$ O(n^2) $]) $

Every simple deterministic pivot rule has bad inputs that force this behavior. This
includes choosing the first element, the last element, or even the median of the
first, middle, and last elements.

=== Worst-case analysis
This course uses *worst-case analysis*: a stated running time must hold for every
input. Thus the only bound we can promise for quicksort is $O(n^2)$.

A loose bound such as $O(n!)$ is technically correct but useless, and it is marked
wrong. State the bound that falls naturally out of your analysis technique.

=== Good pivots
In practice quicksort is fast. Unless someone deliberately gives it bad inputs, the
pivot rank is usually near $n / 2$. With probability about $1 / 3$, the pivot lies in
the middle third, so both recursive calls have at most $2n \/ 3$ elements. In the
most unbalanced such case, the running time satisfies

$ T(n) <= T(n / 3) + T((2 n) / 3) + O(n) $

#recursion-tree(
  ([0], ($n$,), $n$),
  ([1], ($n/3$, $(2n)/3$), $n$),
  ([2], ($n/9$, $(2n)/9$, $(2n)/9$, $(4n)/9$), $n$),
  ([$dots.v$], ($dots.h$,), $<= n$),
)

The tree is unbalanced, but every level sums to at most $n$. Some branches reach
their base cases early, so lower levels may be missing nodes; this does not affect
the upper bound.

The longest path follows the larger calls, and the subproblem size is multiplied by
$2 / 3$ at each level. The number of times we can multiply $n$ by $2 / 3$ before
reaching $1$ equals the number of times we can divide $n$ by $3 / 2$:

$ text("levels") <= log_(3 slash 2) n = O(log n) $

Changing the base of the logarithm to any other constant changes the result only by
a constant factor, so

$ T(n) = n dot log_(3 slash 2) n = #box(stroke: black, inset: 3pt, [$ O(n log n) $]) $

== Selection
In the *median* problem, we are given an array $A[1 .. n]$ and must find the element
of rank $ceil(n / 2)$.

=== Sort first
One solution is to mergesort the array and return $A[ceil(n / 2)]$. This takes
$O(n log n)$ time and is a perfectly valid answer on a homework or exam; in general,
if you can use something from class as a black box, you should. However, we only want
one element, so we should try to do better.

=== Recursive idea
Suppose we pick a pivot, partition the array, and compare the pivot's rank $r$ with
$ceil(n / 2)$. There are three cases.

- If $r < ceil(n / 2)$, everything to the left of the pivot is even smaller than the
  median, so the median lies to the right of the pivot, and we recurse on the right
  side.
- If $r > ceil(n / 2)$, the median lies to the left, and we recurse on the left side.
- If $r = ceil(n / 2)$, the pivot is the median.

We should not pick another pivot inside the right side ourselves. That is the
recursion fairy's job, and doing it for them makes them grumpy. We simply recurse.

There is a technical issue. Inside the right subarray, the median no longer has rank
$ceil(n / 2)$; its rank relative to the subarray is smaller. Thus the original problem
is not general enough to recurse on. Sometimes we need to solve a more general
problem that we can call recursively.

=== The selection problem
Given an array $A[1 .. n]$ and an integer $k$ with $1 <= k <= n$, we want to find the
element of rank $k$.

== Quickselect
Tony Hoare described quickselect on the same page of the paper as quicksort. We can
think of it as a one-armed quicksort.

```
QuickSelect(A[1..n], k):
  if n = 1
    return A[1]
  else
    choose a pivot element A[p]
    r ← Partition(A[1..n], p)
    if k < r
      return QuickSelect(A[1..r − 1], k)
    else if k > r
      return QuickSelect(A[r + 1..n], k − r)
    else
      return A[r]
```

- If $k < r$, everything to the right of the pivot is too big, so we search the left
  side, still for rank $k$.
- If $k > r$, the target is bigger than the pivot, so we search the right side. The
  right side is missing the $r$ smallest elements, so we look there for rank $k - r$.
- If $k = r$, the pivot is the answer.

=== Running time
In the worst case, the pivot is always the smallest or largest element. The recursion
tree is the same path as for quicksort, so the running time is $O(n^2)$.

If the pivot lies in the middle third, there is only one recursive call, on at most
$2n \/ 3$ elements:

$ T(n) <= T((2 n) / 3) + O(n) $

#recursion-tree(
  ([0], ($n$,), $n$),
  ([1], ($(2n)/3$,), $(2n)/3$),
  ([2], ($(4n)/9$,), $(4n)/9$),
  ([$i$], ($(2/3)^i n$,), $(2/3)^i n$),
)

The level sums form a decreasing geometric series. A geometric series whose ratio is
not $1$ is proportional to its largest term, which here is the root. Thus
$T(n) = O(n)$, provided we can always find a pivot near the middle.

== Median of Medians Selection
This algorithm is due to Blum, Floyd, Pratt, Rivest, and Tarjan, published in 1973 (the lecture gave 1970). The idea is to
take a representative *sample* of the array, find the sample's median recursively,
and use it as the pivot. The sample's median should be close to the real median.

```
MomSelect(A[1..n], k):
  if n ≤ 25
    use brute force
  else
    m ← ⌈n/5⌉
    for i ← 1 to m
      M[i] ← MedianOfFive(A[5i − 4..5i])
    mom ← MomSelect(M[1..m], ⌊m/2⌋)
    r ← Partition(A[1..n], mom)
    if k < r
      return MomSelect(A[1..r − 1], k)
    else if k > r
      return MomSelect(A[r + 1..n], k − r)
    else
      return mom
```

+ If $n <= 25$, sort the array and pick the answer directly. This big base case takes
  constant time.
+ Split the array into blocks of $5$, find the median of each block, and put the
  medians in an array $M$ of size about $n / 5$.
+ Recursively find the median of $M$, called the *median of medians*
  ($text("mom")$). The recursive call is allowed because $n / 5 < n$.
+ Run quickselect with $text("mom")$ as the pivot.

We can think of step 3 as an approximate median fairy, which is secretly the
recursion fairy in disguise.

=== Analysis
First consider the work outside the recursive calls. There are $n / 5$ medians of
five, each computed in constant time, and partitioning takes $O(n)$ time, so this
work is $O(n)$ in total.

The remaining question is whether $text("mom")$ is a good pivot; we must show that
neither recursive call is too big. For the analysis only (the algorithm does not do
this), we arrange $A$ into a $5 times n / 5$ grid:

+ Each column is one block of 5.
+ Sort each column with the smallest element on top, so the block medians land in
  the middle row.
+ Sort the columns by their medians, which places $text("mom")$ in the center.

#align(center, block(breakable: false)[
  #mom-grid(cols: 9)
  #v(0.4em)
  #text(size: 0.9em)[
    #box(fill: rgb("#f7dc6f"), stroke: 0.5pt, width: 8pt, height: 8pt) block medians
    #h(1em)
    #box(fill: rgb("#5dade2"), stroke: 0.5pt, width: 8pt, height: 8pt) $text("mom")$
    #h(1em)
    #box(fill: luma(215), stroke: 0.5pt, width: 8pt, height: 8pt) $<= text("mom")$
  ]
])

- Each median to the left of $text("mom")$ is smaller than $text("mom")$.
- Each column is sorted, so the elements above those medians are smaller still.
- There are $n / 5$ columns, so about $n / 10$ columns lie to the left of
  $text("mom")$, and each of them has $3$ elements (the median and the two above it)
  smaller than $text("mom")$.

Thus at least $3n \/ 10$ elements are smaller than $text("mom")$, so at most
$7n \/ 10$ elements are larger. Symmetrically, at most $7n \/ 10$ elements are
smaller. The other cells could go either way, but the argument does not need them.
Each recursive call therefore has at most $7n \/ 10$ elements:

$ T(n) <= O(n) + T(n / 5) + T((7 n) / 10) $

#recursion-tree(
  ([0], ($n$,), $n$),
  ([1], ($n/5$, $(7n)/10$), $(9n)/10$),
  ([2], ($n/25$, $(7n)/50$, $(7n)/50$, $(49n)/100$), $(81n)/100$),
  ([$i$], ($dots.h$,), $(9/10)^i n$),
)

Because $1 / 5 + 7 / 10 = 9 / 10 < 1$, the level sums form a decreasing geometric
series. The number of levels does not matter, since the sum is proportional to the
root:

$ T(n) = #box(stroke: black, inset: 3pt, [$ O(n) $]) $

This bound is optimal, because any algorithm must look at every element.

=== Why blocks of 5?
The block size $5$ is the smallest odd size for which the analysis works, although
$7$ also works. With blocks of $3$, the same argument gives

$ T(n) <= O(n) + T(n / 3) + T((2 n) / 3) $

This is the recurrence for quicksort with good pivots: every level sums to $n$, so
the running time is $O(n log n)$, which is no better than sorting.

=== Takeaways
- Divide and conquer algorithms can use unexpected subproblems, such as a recursive
  call on a sample whose only purpose is to find a pivot.
- Subproblems can be unbalanced. We analyze such algorithms with recursion trees.

== Preview: Fast Multiplication
Lecture 12 shows how to multiply two $n$-digit numbers with
$O(n^(log_2 3)) approx O(n^(1.59))$ single-digit multiplications. This is another
divide and conquer algorithm; it splits the digits of each number into two halves.
]

#show: notes
#set heading(numbering: "1.1")
#body
