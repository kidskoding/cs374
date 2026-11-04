// CS 374 A, Homework 9, Problem 1
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let Short = $italic("Short")$
#let Long = $italic("Long")$
#let Relic = $italic("Relic")$
#let Damage = $italic("Damage")$
#let MR = $italic("MR")$
#let True = smallcaps[True]
#let False = smallcaps[False]

#show: homework.with(
  title: "CS 374: Section A - Homework 9, Problem 1",
  date: "November 3, 2026",
)

Throughout this problem, $G = (V, E)$ is a DAG with exactly one source $s$ and exactly one
sink $b$, and the *length* of a path is its number of edges.

*There is at least one path from $s$ to $b$*: Start at $b$ and repeatedly step
backward along any edge into the current vertex. Since $G$ is a DAG, no vertex
repeats, so this stops after at most $|V|$ steps, at a vertex with in-degree
$0$. The only such vertex is $s$. Reversing the steps gives a path from $s$ to
$b$.

*Every walk in a DAG is a path*: A walk that repeats a vertex contains a
directed cycle, and a DAG has none. So below, "path" and "walk" mean the same
thing.

= (a) Do all $(s, b)$-paths have the same length?

All paths from $s$ to $b$ have the same length exactly when the shortest one and
the longest one have the same length. So we compute both with dynamic
programming over the DAG.

== Recursive functions

For every vertex $v in V$, define:

#boxed[
  $Short(v)$ = the minimum length of a path from $s$ to $v$ \
  $Long(v)$ = the maximum length of a path from $s$ to $v$
]

We set $Short(v) = infinity$ and $Long(v) = -infinity$ if there is no path from
$s$ to $v$. The algorithm returns #True if $Short(b) = Long(b)$, and #False
otherwise.

== Recurrence

$
Short(v) = cases(
  0 & "if" v = s,
  1 + min_((u, v) in E) Short(u) & "otherwise",
)
quad quad
Long(v) = cases(
  0 & "if" v = s,
  1 + max_((u, v) in E) Long(u) & "otherwise",
)
$

with $min emptyset = infinity$ and $max emptyset = -infinity$.

*Base case*: $s$ has in-degree $0$, so the only path from $s$ to $s$ is the
path $chevron.l s chevron.r$ with no edges. Both values are $0$.

*Recursive case ($v != s$)*: A path from $s$ to $v$ has at least one edge. Its
last edge is some edge $(u, v) in E$, and the rest of it is a path from $s$ to
$u$. Conversely, for every edge $(u, v) in E$, a path from $s$ to $u$ followed by
the edge $(u, v)$ is a walk from $s$ to $v$, and so a path, of length one more.
So the path lengths from $s$ to $v$ are exactly the numbers $1 + ell$, where
$(u, v) in E$ and $ell$ is the length of a path from $s$ to $u$. Taking the
minimum and the maximum gives the two recurrences. If no path reaches any
predecessor $u$, both sides are $infinity$ (or $-infinity$), as they should be.

*Answer*: There is at least one path from $s$ to $b$, so both $Short(b)$ and
$Long(b)$ are finite and are the lengths of actual paths. Every path from $s$ to
$b$ has length between $Short(b)$ and $Long(b)$. If $Short(b) = Long(b)$, every
path has that one length. If $Short(b) < Long(b)$, the shortest and the longest
path have different lengths. So returning whether $Short(b) = Long(b)$ is
correct.

== Memoization and evaluation order

We store the values in two arrays $Short[v]$ and $Long[v]$, indexed by the
vertices. $Short(v)$ and $Long(v)$ depend only on the values at the predecessors
$u$ of $v$, and every predecessor comes before $v$ in a topological order of
$G$. So we evaluate the vertices in topological order.

Instead of scanning the in-edges of $v$, the algorithm below pushes each value
forward along the out-edges of $u$. When the loop reaches $v$, every
predecessor $u$ has already been processed, so $Short[v]$ and $Long[v]$ already
hold the minimum and maximum in the recurrence.

#algo(
  [#fn[SameLength]$(G, s, b)$:],
  (1, [compute a topological order of $G$]),
  (1, [for every vertex $v$: $Short[v] <- infinity$, $Long[v] <- -infinity$]),
  (1, [$Short[s] <- 0$, $Long[s] <- 0$]),
  (1, [for each vertex $u$ in topological order]),
  (2, [for each edge $(u, v) in E$]),
  (3, [$Short[v] <- min{Short[v], Short[u] + 1}$]),
  (3, [$Long[v] <- max{Long[v], Long[u] + 1}$]),
  (1, [if $Short[b] = Long[b]$: return #True]),
  (1, [else: return #False]),
)

== Running time

A topological order takes $O(|V| + |E|)$ time to compute with depth-first
search. Initialising the arrays takes $O(|V|)$ time. The main loop looks at
each vertex once and each edge once, doing $O(1)$ work per edge. The algorithm
runs in #boxed[$O(|V| + |E|)$ time]

#disclosures(sources: [None], llm: llm-note)

#pagebreak()

= (b) Most relics on a path the PC survives

Let $r(v) = 1$ if $Relic(v) =$ #True and $r(v) = 0$ otherwise.

The PC dies as soon as its health is $0$ or less. So, if the PC is at vertex $v$
with health $h >= 1$ and moves along an edge $(v, w)$, it survives entering $w$
exactly when $h - Damage(w) >= 1$, that is, when $Damage(w) < h$, and its
health becomes $h - Damage(w)$. Damage is never negative, so the health never
goes up. Since the PC starts with health $k$, its health is always an integer
between $1$ and $k$ while it is alive.

== Recursive function

For every vertex $v in V$ and every integer $1 <= h <= k$, define:

#boxed[
  $MR(v, h)$ = the maximum number of relics the PC acquires *after* leaving $v$ \
  on a path from $v$ to $b$ that the PC survives when it starts at $v$ with health $h$ \
  ($-infinity$ if there is no such path)
]

"Acquires after leaving $v$" means we count $r(w)$ for every vertex $w$ of the
path except $v$ itself. We need $MR(s, k)$: the PC starts at $s$ with health
$k$, and $Relic(s) =$ #False and $Damage(s) = 0$, so the start space adds
nothing.

== Recurrence

$
MR(v, h) = cases(
  0 & "if" v = b,
  max {r(w) + MR(w, h - Damage(w)) mid(|) (v, w) in E "and" Damage(w) < h} & "otherwise",
)
$

with $max emptyset = -infinity$ and $1 + (-infinity) = 0 + (-infinity) = -infinity$.

*Base case*: $b$ is the only sink, so the only path from $b$ to $b$ is
$chevron.l b chevron.r$. The PC is already at $b$ with health $h >= 1$, so it
has survived, and it acquires no more relics. So $MR(b, h) = 0$.

*Recursive case ($v != b$)*: Take any path $v -> w -> dots.c -> b$ that the PC
survives from $v$ with health $h$. Its first edge is some $(v, w) in E$. The PC
survives entering $w$, so $Damage(w) < h$. It gets $r(w)$ relics at $w$, and it
then stands at $w$ with health $h - Damage(w)$, which is between $1$ and $k$. The rest
of the path is a path from $w$ to $b$ that the PC survives from there, so it
yields at most $MR(w, h - Damage(w))$ more relics. So the left side is at most
the right side.

Conversely, take any edge $(v, w) in E$ with $Damage(w) < h$ for which
$MR(w, h - Damage(w))$ is finite, and a path from $w$ to $b$ that achieves it.
The edge $(v, w)$ followed by that path is a walk from $v$ to $b$, and so a
path. The PC survives entering $w$, and then survives the rest. It gets
$r(w) + MR(w, h - Damage(w))$ relics after leaving $v$. So the left side is at
least the right side.

If no edge $(v, w)$ allows a surviving path, both sides are $-infinity$. The
recurrence is well founded: every call $MR(w, dot)$ is at a successor $w$ of $v$,
which comes after $v$ in topological order, even when $Damage(w) = 0$ and the
health does not change.

The answer $MR(s, k)$ is the maximum number of relics over all surviving paths
from $s$ to $b$, or $-infinity$ if there is none, as required.

== Memoization and evaluation order

We store $MR$ in a two-dimensional array $MR[v, h]$, indexed by a vertex
$v in V$ and an integer $1 <= h <= k$. Every index $h - Damage(w)$ used by the
recurrence is between $1$ and $k$, because the recurrence only uses it when
$Damage(w) < h$.

Each entry $MR[v, dot]$ depends only on entries $MR[w, dot]$ at successors $w$ of
$v$, which come after $v$ in a topological order. So we fill the rows for the
vertices in *reverse* topological order. Within a row, the order of $h$ does
not matter.

#algo(
  [#fn[MaxRelics]$(G, s, b, k)$:],
  (1, [compute a topological order of $G$]),
  (1, [for each vertex $v$ in reverse topological order]),
  (2, [for $h <- 1$ to $k$]),
  (3, [if $v = b$]),
  (4, [$MR[v, h] <- 0$]),
  (3, [else]),
  (4, [$MR[v, h] <- -infinity$]),
  (4, [for each edge $(v, w) in E$]),
  (5, [if $Damage(w) < h$]),
  (6, [$MR[v, h] <- max{MR[v, h], r(w) + MR[w, h - Damage(w)]}$]),
  (1, [return $MR[s, k]$]),
)

== Running time

The topological order takes $O(|V| + |E|)$ time. The array has $|V| k$ entries.
The entry $MR[v, h]$ takes $O(1 + "outdeg"(v))$ time, so all $k$ entries of
row $v$ take $O(k (1 + "outdeg"(v)))$ time. Summing over all vertices,
$sum_v k (1 + "outdeg"(v)) = k (|V| + |E|)$. The algorithm runs in
#boxed[$O(k (|V| + |E|))$ time]

#disclosures(sources: [None], llm: llm-note)
