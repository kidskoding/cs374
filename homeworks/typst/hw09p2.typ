// CS 374 A, Homework 9, Problem 2
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let dist = $italic("dist")$
#let True = smallcaps[True]
#let False = smallcaps[False]

#show: homework.with(
  title: "CS 374: Section A - Homework 9, Problem 2",
  date: "November 3, 2026",
)

A *closed walk* is a walk $v_0 -> v_1 -> dots.c -> v_m$ with $m >= 1$ edges
and $v_m = v_0$. It is a *cycle* (a simple cycle) if $v_0, v_1, ..., v_(m - 1)$
are all different. For a walk $W$, let $r(W)$ and $b(W)$ be its numbers of red
and blue edges, counted with repetition, and let $w(W)$ be the sum of the
weights of its edges. So $W$ is energetic if and only if $b(W) - 2 r(W) > 0$.

= (a) Is there an energetic cycle?

== Graph

Give every edge $e$ of $G$ a new weight

$
c(e) = cases(
  2 & "if" e "is red",
  -1 & "if" e "is blue.",
)
$

A cycle $C$ then has total new weight $c(C) = 2 r(C) - b(C)$, so

$
C "is energetic" quad <==> quad 2 r(C) < b(C) quad <==> quad c(C) < 0.
$

So $G$ has an energetic cycle if and only if $G$ has a negative cycle with
respect to $c$.

Add one new vertex $z$ to get the graph $G_z$, with an edge $z -> v$ of weight
$0$ for every vertex $v in V$. So $G_z$ has $|V| + 1$ vertices and
$|E| + |V|$ edges.

== Algorithm

#boxed[
  Run Bellman-Ford on $G_z$ with weights $c$, from the source $z$. \
  Return #True if it reports a negative cycle (an edge is still tense at the end), \
  and #False otherwise.
]

== Correctness

No edge enters $z$, so no cycle of $G_z$ goes through $z$. So the cycles of
$G_z$ are exactly the cycles of $G$, with the same weights. Every vertex of $G$
is reachable from $z$ by a single edge, so every cycle of $G$ is reachable from
$z$. Bellman-Ford reports a negative cycle if and only if a negative cycle is
reachable from the source. So the algorithm returns #True if and only if $G$
has a cycle $C$ with $c(C) < 0$, that is, an energetic cycle.

(If "negative cycle" is read as "closed walk of negative weight", nothing
changes: as in part (b), a closed walk that repeats a vertex splits into two
shorter closed walks whose weights add up to its weight, so one of them is also
negative. Repeating this, every negative closed walk contains a negative
simple cycle.)

== Running time

Building $G_z$ and the weights $c$ takes $O(|V| + |E|)$ time. Bellman-Ford on a
graph with $|V| + 1$ vertices and $|E| + |V|$ edges takes
$O((|V| + 1)(|E| + |V|))$ time. The algorithm runs in
#boxed[$O(|V| (|V| + |E|))$ time,] which is $O(|V| |E|)$ when every vertex has
an edge.

#disclosures(sources: [None], llm: llm-note)

#pagebreak()

= (b) The shortest energetic closed walk is a simple cycle

#boxed[
  *Claim.* If $G$ has an energetic closed walk, then a shortest energetic closed
  walk exists, and every shortest energetic closed walk is a simple cycle.
]

== Proof

*A shortest one exists.* There are infinitely many closed walks, so we first
check that the minimum is attained. Let $W_0$ be an energetic closed walk, and
let $w_min > 0$ be the smallest edge weight. A closed walk with weight at most
$w(W_0)$ has at most $w(W_0) slash w_min$ edges, and there are only finitely
many walks with that many edges. So the set of energetic closed walks with
weight at most $w(W_0)$ is finite, and it is not empty because it contains
$W_0$. Let $W$ be a walk of smallest weight in this set. Every other energetic
closed walk either is in the set, or has weight more than $w(W_0) >= w(W)$. So
$W$ is a shortest energetic closed walk.

*It is a simple cycle.* Let $W = v_0 -> v_1 -> dots.c -> v_m$ be any shortest
energetic closed walk, with $v_m = v_0$. Suppose, for contradiction, that $W$ is
not a simple cycle. Then $v_i = v_j$ for some indices $0 <= i < j <= m - 1$.
Split $W$ at these two visits into two closed walks:

- $W_1 = v_i -> v_(i + 1) -> dots.c -> v_j$, which uses edges $i + 1$ through
  $j$ of $W$. It has $j - i >= 1$ edges, and it is closed because $v_i = v_j$.
- $W_2 = v_j -> dots.c -> v_m = v_0 -> dots.c -> v_i$, which uses edges $j + 1$
  through $m$ and then edges $1$ through $i$ of $W$. It has
  $m - (j - i) >= 1$ edges, because $j - i <= m - 1$, and it is closed because
  $v_i = v_j$.

Every edge of $W$ is used by exactly one of $W_1$ and $W_2$. So
$r(W) = r(W_1) + r(W_2)$, $b(W) = b(W_1) + b(W_2)$ and
$w(W) = w(W_1) + w(W_2)$. Since $W$ is energetic,

$
(b(W_1) - 2 r(W_1)) + (b(W_2) - 2 r(W_2)) = b(W) - 2 r(W) > 0,
$

so at least one of the two terms is positive. Say $b(W_1) - 2 r(W_1) > 0$ (the
other case is the same with $W_1$ and $W_2$ swapped). Then $W_1$ is an energetic
closed walk. And $W_2$ has at least one edge, and every edge weight is
positive, so $w(W_2) > 0$ and

$
w(W_1) = w(W) - w(W_2) < w(W).
$

This contradicts the choice of $W$ as a shortest energetic closed walk. So
$v_0, ..., v_(m - 1)$ are all different, and $W$ is a simple cycle. #h(1fr) $square$

*Consequence used in part (c).* Every simple cycle is a closed walk, and the
shortest energetic closed walk is a simple cycle. So if $G$ has an energetic
closed walk, the shortest energetic closed walk and the shortest energetic
cycle have the same weight. If $G$ has no energetic closed walk, it has no
energetic cycle either.

#disclosures(sources: [None], llm: llm-note)

#pagebreak()

= (c) Length of the shortest energetic cycle

Here the *length* of a cycle is its total weight $w$. We follow a walk and keep
track of its *balance* $d = b - 2 r$, where $b$ and $r$ are the numbers of blue
and red edges used so far. A blue edge adds $1$ to the balance and a red edge
subtracts $2$. A closed walk is energetic exactly when its final balance is at
least $1$.

*How many layers we need.* By part (b), it is enough to look at simple cycles.
A simple cycle has at most $|V|$ edges, so every prefix of it, started at any of
its vertices, has $0 <= b, r <= |V|$, and its balance $d = b - 2 r$ satisfies
$-2|V| <= d <= |V|$. So we only need the $3 |V| + 1$ balances in this range.

== Graph

Let $D = {-2|V|, ..., |V|}$. Build a directed graph $H = (V_H, E_H)$:

- *Vertices:* $V_H = V times D$. Vertex $(v, d)$ means "the walk is at vertex
  $v$, and its balance so far is $d$." So $|V_H| = (3|V| + 1) |V|$.
- *Edges:* For every blue edge $e = u -> v$ of $G$ and every $d in D$ with
  $d + 1 in D$, $H$ has an edge $(u, d) -> (v, d + 1)$ of weight $w(e)$. For
  every red edge $e = u -> v$ and every $d in D$ with $d - 2 in D$, $H$ has an
  edge $(u, d) -> (v, d - 2)$ of weight $w(e)$. So
  $|E_H| <= (3|V| + 1) |E|$.

Every weight in $H$ is the weight of an edge of $G$, so it is positive.

== Algorithm

#algo(
  [#fn[ShortestEnergeticCycle]$(G)$:],
  (1, [build $H$]),
  (1, [$"best" <- infinity$]),
  (1, [for each vertex $s in V$]),
  (2, [run Dijkstra's algorithm in $H$ from $(s, 0)$]),
  (2, [for $d <- 1$ to $|V|$]),
  (3, [$"best" <- min{"best", dist((s, 0), (s, d))}$]),
  (1, [return $"best"$], [$infinity$ means there is no energetic cycle]),
)

== Correctness

*Paths in $H$ are walks in $G$.* By construction, each edge
$(u, d) -> (v, d')$ of $H$ comes from an edge $u -> v$ of $G$ with the same
weight, and $d' - d$ is $+1$ for a blue edge and $-2$ for a red edge. So, by
induction on the number of edges, a path in $H$ from $(s, 0)$ to $(v, d)$ is
the same as a walk in $G$ from $s$ to $v$ with the same weight, whose final
balance is $d$ and all of whose prefix balances lie in $D$.

*The algorithm returns at most the answer.* Suppose $G$ has an energetic cycle,
and let $C$ be a shortest one, with weight $w^*$. Pick any vertex $s$ on $C$ and
read $C$ as a closed walk from $s$ back to $s$. As shown above, every prefix
balance of $C$ lies in $D$. Its final balance $d = b(C) - 2 r(C)$ satisfies
$1 <= d <= |V|$, because $C$ is energetic and has at most $|V|$ edges. So $H$
has a path from $(s, 0)$ to $(s, d)$ of weight $w^*$, and when the loop reaches
$s$, it sets $"best" <= w^*$.

*The algorithm returns at least the answer.* Whenever the algorithm uses a
finite value $dist((s, 0), (s, d))$ with $d >= 1$, there is a path in $H$ from
$(s, 0)$ to $(s, d)$ with that weight. It is a closed walk in $G$ from $s$ to
$s$ with balance $d >= 1$. It has at least one edge, since its balance is not
$0$, so it is an energetic closed walk. By part (b), its weight is at least the
weight of the shortest energetic closed walk, which equals $w^*$. So
$"best" >= w^*$.

Together, the algorithm returns exactly $w^*$. If $G$ has no energetic cycle,
then by part (b) it has no energetic closed walk either, so no path in $H$ goes
from any $(s, 0)$ to any $(s, d)$ with $d >= 1$, and the algorithm correctly
returns $infinity$. Dijkstra's algorithm is correct on $H$ because all its
weights are positive.

== Running time

$H$ has $|V_H| = O(|V|^2)$ vertices and $|E_H| = O(|V| |E|)$ edges, and it can
be built in $O(|V_H| + |E_H|) = O(|V| (|V| + |E|))$ time. One run of Dijkstra's
algorithm takes
$O((|V_H| + |E_H|) log |V_H|) = O(|V| (|V| + |E|) log |V|)$ time, since
$log |V_H| = O(log |V|)$. Reading the $|V|$ distances afterwards takes $O(|V|)$
time. We run Dijkstra once per vertex $s$, $|V|$ times in all. The algorithm
runs in #boxed[$O(|V|^2 (|V| + |E|) log |V|)$ time.]

#disclosures(sources: [None], llm: llm-note)
