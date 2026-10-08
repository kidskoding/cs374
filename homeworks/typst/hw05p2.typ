// CS 374 A, Homework 5, Problem 2
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) to draft this algorithm and explain its structure to
  me. I traced it by hand on several small weighted sets against the answer from
  sorting, and typeset the submission myself.
]

#show: homework.with(
  title: "CS 374: Section A - Homework 5, Problem 2",
  date: "October 6, 2026",
)

The $i$th element has value $S[i]$ and weight $W[i]$, values and weights are
positive and distinct, and $w(R)$ is the total weight of a set $R$. The weighted
median of $S$ is the element $x$ with

$
w(S_(<x)) <= w(S) / 2 #h(1.5em) "and" #h(1.5em) w(S_(>x)) < w(S) / 2.
$

The algorithm only compares values and adds or subtracts weights; it uses no
hashing and no radix sort. We use the linear-time selection algorithm from class
(#fn[MomSelect], median of medians) as a black box, and the #fn[Partition] subroutine from
quicksort, modified to move each weight $W[i]$ along with its value $S[i]$.

= A more general problem

Since $w(S_(>x)) = w(S) - w(S_(<x)) - w(x)$, the second condition is the same as
$w(S) / 2 < w(S_(<x)) + w(x)$. So the weighted median is the unique $x$ with

$
w(S_(<x)) <= w(S) / 2 < w(S_(<x)) + w(x).
$

In words: lay the elements end to end in order of value on the number line, each
covering an interval as long as its weight; the weighted median is the element
whose interval contains the point $w(S) / 2$. We solve the same problem for an
arbitrary point $t$.

*Weighted selection:* #fn[WSelect]$(S[1 .. n], W[1 .. n], t)$, given a non-empty
weighted set and a number $t$ with $0 <= t < w(S)$, returns the value of the
unique element $x$ with $w(S_(<x)) <= t < w(S_(<x)) + w(x)$.

This $x$ exists and is unique: the intervals
$[w(S_(<x)), w(S_(<x)) + w(x))$, taken in order of value, are disjoint, have
positive length, and together cover $[0, w(S))$ exactly.

#algo(
  [#fn[WSelect]$(S[1 .. n], W[1 .. n], t)$:],
  (1, [if $n = 1$]),
  (2, [return $S[1]$]),
  (1, [$v <-$ #fn[MomSelect]$(S[1 .. n], ceil(n slash 2))$], [median value]),
  (1, [find the index $p$ with $S[p] = v$]),
  (1, [$r <-$ #fn[Partition]$(S[1 .. n], W[1 .. n], p)$], [pivot $v$ now at $S[r]$]),
  (1, [$w_L <- W[1] + W[2] + dots.c + W[r - 1]$], [weight of smaller values]),
  (1, [if $t < w_L$]),
  (2, [return #fn[WSelect]$(S[1 .. r - 1], W[1 .. r - 1], t)$]),
  (1, [else if $t < w_L + W[r]$]),
  (2, [return $S[r]$]),
  (1, [else]),
  (2, [return #fn[WSelect]$(S[r + 1 .. n], W[r + 1 .. n], t - w_L - W[r])$]),
)

*Weighted median:* #fn[WeightedMedian]$(S[1 .. n], W[1 .. n])$ returns the value of
the weighted median of the given weighted set.

#algo(
  [#fn[WeightedMedian]$(S[1 .. n], W[1 .. n])$:],
  (1, [$italic("total") <- 0$]),
  (1, [for $i <- 1$ to $n$]),
  (2, [$italic("total") <- italic("total") + W[i]$]),
  (1, [return #fn[WSelect]$(S[1 .. n], W[1 .. n], italic("total") slash 2)$]),
)

The call satisfies the precondition of #fn[WSelect], because $0 <= w(S) / 2 < w(S)$
when all weights are positive. By the reformulation above, the element #fn[WSelect]
returns for $t = w(S) / 2$ is exactly the weighted median.

= Why #fn[WSelect] is correct

We argue by induction on $n$. When $n = 1$ the only element $x$ has
$w(S_(<x)) = 0 <= t < w(x) = w(S)$, so returning it is correct.

For $n >= 2$, after partitioning let $L = S[1 .. r - 1]$ hold the values smaller
than the pivot $S[r]$ and $G = S[r + 1 .. n]$ hold the larger ones, so that
$w_L = w(L)$ and $w(S) = w_L + W[r] + w(G)$.

- *If $t < w_L$.* Then $L$ is non-empty and $0 <= t < w(L)$, so the recursive
  call satisfies the precondition. For every $x in L$ the elements of $S$ smaller
  than $x$ all lie in $L$, so $S_(<x) = L_(<x)$, and the element that $L$ assigns
  to $t$ is the element that $S$ assigns to $t$.

- *If $w_L <= t < w_L + W[r]$.* The pivot $x = S[r]$ has $S_(<x) = L$, so
  $w(S_(<x)) <= t < w(S_(<x)) + w(x)$ and the pivot is the answer.

- *If $t >= w_L + W[r]$.* Let $t' = t - w_L - W[r]$. Then $t' >= 0$, and
  $t' < w(S) - w_L - W[r] = w(G)$, so $G$ is non-empty and the recursive call
  satisfies the precondition. For every $x in G$ we have
  $S_(<x) = L union {S[r]} union G_(<x)$, so
  $w(S_(<x)) = w_L + W[r] + w(G_(<x))$. Subtracting $w_L + W[r]$ from every part of
  the condition $w(S_(<x)) <= t < w(S_(<x)) + w(x)$ turns it into
  $w(G_(<x)) <= t' < w(G_(<x)) + w(x)$, so the element that $G$ assigns to $t'$
  is the element that $S$ assigns to $t$.

In every case #fn[WSelect] returns the correct element, assuming by induction that the
recursive call on the smaller set $L$ or $G$ is correct.

= Running time

#fn[MomSelect] runs in $O(n)$ time, and finding $p$, #fn[Partition], and the sum $w_L$
each take one pass over the array, so one call of #fn[WSelect] does $O(n)$ work
besides its recursive call. Because the pivot is the median, $L$ and $G$ each
hold at most $n / 2$ elements, and #fn[WSelect] makes at most one recursive call. So,
ignoring floors and ceilings,

$
T(n) <= T(n / 2) + O(n),
$

which solves to $T(n) = O(n)$, since the work per level shrinks geometrically:
$O(n + n / 2 + n / 4 + dots.c) = O(n)$. #fn[WeightedMedian] adds one $O(n)$ pass to
compute the total weight, so the whole algorithm runs in
#boxed[$O(n)$ time.]

This beats the $O(n log n)$ algorithm that sorts by value and scans the prefix
sums of the weights.

#disclosures(llm: llm-note)
