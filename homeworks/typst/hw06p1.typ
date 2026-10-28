// CS 374 A, Homework 6, Problem 1
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let MaxJoy = $italic("MaxJoy")$
#let nxt = $italic("next")$

#show: homework.with(
  title: "CS 374: Section A - Homework 6, Problem 1",
  date: "October 13, 2026",
)

Throughout, a set $S$ of days off is *valid for $(ell, k)$* if every $k$
consecutive workdays contain at most $ell$ days of $S$. Joy values $J[i]$ may be
negative, so an optimal plan may take no days off, with total joy $0$.

= (a) At most 2 days off in any 28 consecutive workdays

== Recursive function

For $1 <= i <= n + 1$ and $0 <= g <= 27$, let $P(i, g) = {i - g}$ if $g >= 1$,
and $P(i, 0) = emptyset$. Define

#boxed[
  $MaxJoy(i, g)$ = the maximum of $sum_(s in S) J[s]$ over all sets
  $S subset.eq {i, i + 1, ..., n}$ \ such that $S union P(i, g)$ is valid for
  $(2, 28)$.
]

In words: $MaxJoy(i, g)$ is the most joy we can collect from days $i$ through
$n$, if day $i - g$ is already taken off (or no earlier day matters, when
$g = 0$). The set $S = emptyset$ is always allowed, so $MaxJoy(i, g) >= 0$. We
need $MaxJoy(1, 0)$.

*Why this is the right subproblem.* Let $H$ be the days off already chosen
before day $i$, and assume $H$ contains at most one day in
$[i - 27, i - 1]$, namely day $i - g$ (or no day, if $g = 0$). Any 28
consecutive days that contain a day $>= i$ start at day $i - 27$ or later, so
they meet $H$ only in $P(i, g)$. Hence, if $H$ is valid, $H union S$ is valid
exactly when $S union P(i, g)$ is valid. Every recursive call below keeps this
property.

== Recurrence

Let $nxt(g) = g + 1$ if $1 <= g <= 26$, and $nxt(g) = 0$ if $g in {0, 27}$.
For all $i > n$ we set $MaxJoy(i, g) = 0$. For $1 <= i <= n$:

$
MaxJoy(i, 0) = max cases(
  MaxJoy(i + 1, 0) & "(work day" i")",
  J[i] + MaxJoy(i + 1, 1) & "(take off day" i")",
)
$

and for $1 <= g <= 27$:

$
MaxJoy(i, g) = max cases(
  MaxJoy(i + 1, nxt(g)) & "(work day" i")",
  J[i] + MaxJoy(i + 28 - g, 28 - g) & "(take off day" i")",
)
$

*Explanation.* Every valid $S$ either contains day $i$ or does not, so we take
the better of the two options.
- *Work day $i$.* The next subproblem starts at day $i + 1$, whose window of the
  27 previous days is $[i - 26, i]$. Day $i - g$ stays in that window, now at
  offset $g + 1$, exactly when $1 <= g <= 26$; if $g = 27$ it leaves the window,
  and if $g = 0$ there is still no day off in the window. This is $nxt(g)$.
- *Take off day $i$ when $g = 0$.* No earlier day off lies in
  $[i - 27, i - 1]$, so day $i$ is the only day off so far in any 28
  consecutive days that contain it. Day $i$ is also the only day off in the
  window $[i - 26, i]$ of day $i + 1$, at offset $1$.
- *Take off day $i$ when $g >= 1$.* Days $i - g$ and $i$ are both off. The 28
  consecutive days $[i - g, i - g + 27]$ already contain two days off, so none
  of the days $i + 1, ..., i - g + 27$ may be taken off. The first day we may
  take off next is $i' = i - g + 28 >= i + 1$. Among the days
  $[i' - 27, i' - 1] = [i - g + 1, i - g + 27]$ the only day off is day $i$, at
  offset $i' - i = 28 - g$, which lies in $[1, 27]$. Taking off day $i$ itself is
  allowed, because the 28 days ending at day $i$ contain only days $i - g$ and
  $i$ from the plan.

== Memoization and evaluation order

We store $MaxJoy$ in a two-dimensional array $MaxJoy[1 .. n + 28][0 .. 27]$. All
rows $i > n$ are $0$; the largest row the recurrence reads is
$i + 28 - g <= n + 27$. Each entry $MaxJoy[i, g]$ depends only on entries in rows
larger than $i$, so we fill rows $i = n, n - 1, ..., 1$ in decreasing order, and
within a row the columns $g = 0, 1, ..., 27$ in any order.

#algo(
  [#fn[MaxJoyA]$(J[1 .. n])$:],
  (1, [for $i <- n + 1$ to $n + 27$ and $g <- 0$ to $27$: $MaxJoy[i, g] <- 0$]),
  (1, [for $i <- n$ down to $1$]),
  (2, [$MaxJoy[i, 0] <- max{MaxJoy[i + 1, 0], J[i] + MaxJoy[i + 1, 1]}$]),
  (2, [for $g <- 1$ to $27$]),
  (3, [$t <- 28 - g$], [offset of day $i$ seen from day $i + t$]),
  (3, [$MaxJoy[i, g] <- max{MaxJoy[i + 1, nxt(g)], J[i] + MaxJoy[i + t, t]}$]),
  (1, [return $MaxJoy[1, 0]$]),
)

== Running time

The array has $28 (n + 27) = O(n)$ entries, each computed in $O(1)$ time, so
the algorithm runs in #boxed[$O(n)$ time.]

#disclosures(llm: llm-note)

#pagebreak()

= (b) At most $ell$ days off in any $k$ consecutive workdays

We assume $ell >= 1$; if $ell = 0$, no day may be taken off and the answer is
$0$.

== Recursive function

The state now records up to $ell - 1$ recent days off. For $1 <= i <= n + 1$,
let $D$ be any set of at most $ell - 1$ days in the range
$[max{1, i - k + 1}, i - 1]$. Define

#boxed[
  $MaxJoy(i, D)$ = the maximum of $sum_(s in S) J[s]$ over all sets
  $S subset.eq {i, i + 1, ..., n}$ \ such that $S union D$ is valid for
  $(ell, k)$.
]

In words: $MaxJoy(i, D)$ is the most joy we can collect from days $i$ through
$n$, if the days off among the $k - 1$ days before day $i$ are exactly the days
in $D$. Again $S = emptyset$ is allowed, so $MaxJoy(i, D) >= 0$. We need
$MaxJoy(1, emptyset)$.

*Why this is the right subproblem.* As in part (a), let $H$ be a valid set of
days off before day $i$ with $H inter [i - k + 1, i - 1] = D$. Any $k$
consecutive days that contain a day $>= i$ start at day $i - k + 1$ or later, so
they meet $H$ only in $D$. Hence $H union S$ is valid exactly when $S union D$ is
valid. Part (a) is the special case $ell = 2$, $k = 28$, $D = P(i, g)$.

== Recurrence

For all $i > n$ we set $MaxJoy(i, D) = 0$. For $1 <= i <= n$, let
$H = D union {i}$ and define the next day we may take off after day $i$:

$
i' = cases(
  i + 1 & "if" |H| < ell,
  max{i + 1, min(H) + k} & "if" |H| = ell,
)
$

Let $D' = H inter [i' - k + 1, i' - 1]$. Then

$
MaxJoy(i, D) = max cases(
  MaxJoy(i + 1, D without {i - k + 1}) & "(work day" i")",
  J[i] + MaxJoy(i', D') & "(take off day" i")",
)
$

*Explanation.*
- *Work day $i$.* The window of the $k - 1$ days before day $i + 1$ is
  $[i - k + 2, i]$, so day $i - k + 1$ leaves the state if it was in $D$, and
  nothing is added.
- *Take off day $i$.* This is always allowed: any $k$ consecutive days that
  contain day $i$ meet the earlier plan only inside $[i - k + 1, i - 1]$, that
  is, inside $D$, so they contain at most $|D| + 1 <= ell$ days off up to day
  $i$. If $|H| < ell$, the next free choice is day $i + 1$. If $|H| = ell$, the
  $k$ consecutive days starting at day $min(H)$ already contain the $ell$ days
  of $H$, so no day before $min(H) + k$ (and after $i$) may be taken off; the
  next possible day is $i'$. The new state $D'$ keeps the days of $H$ inside the
  $k - 1$ days before $i'$.
- *$D'$ is a legal state.* If $|H| < ell$ then $|D'| <= ell - 1$. If $|H| = ell$
  then $min(H) <= i' - k$, so $min(H) in.not D'$ and again $|D'| <= ell - 1$.

Every valid $S$ either contains day $i$ or does not, and in each case the days of
$S$ before $i'$ are forced, so the maximum of the two options is correct.

== Memoization and evaluation order

Because $ell$ is a constant, we encode $D$ by its offsets $i - d$ for $d in D$.
Each offset lies in $[1, k - 1]$. We sort the offsets in increasing order and
pad them with zeros to a tuple $(o_1, ..., o_(ell - 1)) in {0, ..., k - 1}^(ell - 1)$.
We store $MaxJoy$ in an $ell$-dimensional array
$MaxJoy[1 .. n + k][0 .. k - 1] dots.c [0 .. k - 1]$, with one index for the
day $i$ and $ell - 1$ indices for the offset tuple. All rows $i > n$ are $0$;
the largest day the recurrence reads is $min(H) + k <= n + k - 1$.

Every entry for day $i$ depends only on entries for larger days ($i + 1$ or
$i' > i$). So the outer loop runs over $i = n, n - 1, ..., 1$ in decreasing
order, and the inner loop runs over every sorted, zero-padded offset tuple in
lexicographic order (any order works inside one day). The answer is the entry
for $i = 1$ and the all-zero tuple, which encodes $D = emptyset$.

== Running time

For each day $i$ there are at most $k^(ell - 1)$ offset tuples, so the array has
$O((n + k) k^(ell - 1)) = O(n k^(ell - 1))$ entries, using $k <= n$. Each entry
is computed in $O(ell)$ time: we form $H$, find $min(H)$, compute $i'$, and
re-encode $D'$ and $D without {i - k + 1}$ as offset tuples, all on sets of at
most $ell$ elements. Since $ell$ is a constant, the algorithm runs in
#boxed[$O(n k^(ell - 1))$ time.]

For $ell = 2$ and $k = 28$ this is $O(n)$, matching part (a).

#disclosures(llm: llm-note)
