// CS 374 A, Homework 8, Problem 2
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#show: homework.with(
  title: "CS 374: Section A - Homework 8, Problem 2",
  date: "October 27, 2026",
)

The label of the first vertex $v_0$ of a walk is not part of $sigma(W)$. So
when a walk moves along an edge $u -> v$, it reads exactly one character, the
label $ell(v)$ of the vertex it arrives at.

The idea in both parts is the same: run a DFA alongside the walk. A vertex of
the new graph records the current station in $G$ and the current state of the
DFA, and each edge moves in $G$ and feeds the new label to the DFA.

= (a) Walks whose string contains #lit("374")

== DFA

The DFA $M_(374)$ has states $0, 1, 2, 3$. State $j$ means "the longest suffix
of the string read so far that is a prefix of #lit("374") has length $j$," and
state $3$ means #lit("374") has already appeared. It starts in state $0$, and
state $3$ is the only accepting state. Its transitions $delta(j, d)$ are:

#align(center, table(
  columns: 5,
  align: center,
  stroke: 0.5pt,
  inset: (x: 10pt, y: 5pt),
  [state], [#lit("3")], [#lit("7")], [#lit("4")], [other digits],
  [$0$], [$1$], [$0$], [$0$], [$0$],
  [$1$], [$1$], [$2$], [$0$], [$0$],
  [$2$], [$1$], [$0$], [$3$], [$0$],
  [$3$], [$3$], [$3$], [$3$], [$3$],
))

For example, from state $2$ (the string ends in #lit("37")) the digit #lit("3")
goes to state $1$, because the string now ends in #lit("373"), whose longest
suffix that is a prefix of #lit("374") is #lit("3"). The DFA ends in state $3$
exactly when its input contains #lit("374").

== Graph

Build a directed graph $H = (V_H, E_H)$:

- *Vertices:* $V_H = V times {0, 1, 2, 3}$. Vertex $(v, j)$ means "the walk is at
  vertex $v$, and $M_(374)$ is in state $j$ after reading the string of the walk
  so far." So $|V_H| = 4 |V|$.
- *Edges:* For every edge $u -> v$ in $E$ and every state $j$, $H$ has an edge
  $(u, j) -> (v, delta(j, ell(v)))$. So $|E_H| = 4 |E|$.

== Algorithm

#boxed[
  Run whatever-first search (for example, BFS) in $H$ from $(s, 0)$. \ Return
  #smallcaps[True] if $(t, 3)$ is reached, and #smallcaps[False] otherwise.
]

== Correctness

*Claim:* The vertex $(v, j)$ is reachable from $(s, 0)$ in $H$ if and only if
$G$ has a walk $W$ from $s$ to $v$ such that $M_(374)$ ends in state $j$ after
reading $sigma(W)$.

*Walks give paths:* We use induction on the number of edges of $W$. A walk with
no edges has $v = s$ and $sigma(W) = epsilon$, so $j = 0$, and $(s, 0)$ is
reachable from itself. Otherwise $W$ is a walk $W'$ from $s$ to some $u$,
followed by the edge $u -> v$, and $sigma(W) = sigma(W') ell(v)$. If $M_(374)$
ends in state $i$ on $sigma(W')$, then $(u, i)$ is reachable by induction, and
$M_(374)$ ends in state $j = delta(i, ell(v))$ on $sigma(W)$. The edge
$(u, i) -> (v, j)$ is in $H$, so $(v, j)$ is reachable.

*Paths give walks:* We use induction on the number of edges of a path from
$(s, 0)$. The empty path ends at $(s, 0)$, which matches the walk
$chevron.l s chevron.r$. Otherwise the last edge is $(u, i) -> (v, j)$, coming
from an edge $u -> v$ of $G$ with $j = delta(i, ell(v))$. By induction, there is
a walk $W'$ from $s$ to $u$ on whose string $M_(374)$ ends in state $i$. Adding
the edge $u -> v$ gives a walk from $s$ to $v$ on whose string $M_(374)$ ends in
state $j$.

By the claim with $v = t$ and $j = 3$, the search reaches $(t, 3)$ if and only
if some walk $W$ from $s$ to $t$ drives $M_(374)$ to state $3$, that is, if and
only if $sigma(W)$ contains #lit("374").

== Running time

Building $H$ takes $O(|V_H| + |E_H|) = O(|V| + |E|)$ time, since each
transition is a table lookup. The search also takes $O(|V_H| + |E_H|)$ time.
The algorithm runs in #boxed[$O(|V| + |E|)$ time.]

#disclosures(llm: llm-note)

#pagebreak()

= (b) Walks whose string is accepted by a DFA $M$

Let $M = (Q, delta, s', A)$, and let $delta^*(q, x)$ be the state $M$ reaches
from state $q$ after reading the string $x$.

== Graph

Build a directed graph $H = (V_H, E_H)$, the product of $G$ and $M$:

- *Vertices:* $V_H = V times Q$. Vertex $(v, q)$ means "the walk is at vertex
  $v$, and $M$ is in state $q$ after reading the string of the walk so far." So
  $|V_H| = |V| |Q|$.
- *Edges:* For every edge $u -> v$ in $E$ and every state $q in Q$, $H$ has an
  edge $(u, q) -> (v, delta(q, ell(v)))$. So $|E_H| = |E| |Q|$.

== Algorithm

#boxed[
  Run whatever-first search (for example, BFS) in $H$ from $(s, s')$. \ Return
  #smallcaps[True] if some vertex $(t, q)$ with $q in A$ is reached, and
  #smallcaps[False] otherwise.
]

After the search, we check the $|Q|$ vertices $(t, q)$ one by one.

== Correctness

*Claim:* For every vertex $v in V$ and state $q in Q$, the vertex $(v, q)$ is
reachable from $(s, s')$ in $H$ if and only if $G$ has a walk $W$ from $s$ to
$v$ with $delta^*(s', sigma(W)) = q$.

*Walks give paths:* We use induction on the number of edges of $W$. If $W$ has
no edges, then $v = s$, $sigma(W) = epsilon$ and $q = s'$, and $(s, s')$ is
reachable from itself. Otherwise $W$ is a walk $W'$ from $s$ to some vertex $u$,
followed by the edge $u -> v$, and $sigma(W) = sigma(W') ell(v)$. Let
$p = delta^*(s', sigma(W'))$. By induction, $(u, p)$ is reachable. Then
$delta^*(s', sigma(W)) = delta(p, ell(v)) = q$, so the edge
$(u, p) -> (v, q)$ is in $H$, and $(v, q)$ is reachable.

*Paths give walks:* We use induction on the number of edges of a path from
$(s, s')$ to $(v, q)$. A path with no edges ends at $(s, s')$, and the walk
$chevron.l s chevron.r$ has $sigma = epsilon$ and $delta^*(s', epsilon) = s'$.
Otherwise the last edge of the path is $(u, p) -> (v, q)$ for some edge
$u -> v$ in $E$ with $q = delta(p, ell(v))$. By induction, $G$ has a walk $W'$
from $s$ to $u$ with $delta^*(s', sigma(W')) = p$. Then $W'$ followed by the
edge $u -> v$ is a walk $W$ from $s$ to $v$ with
$delta^*(s', sigma(W)) = delta(p, ell(v)) = q$.

*Conclusion:* By the claim, the search reaches some $(t, q)$ with $q in A$ if
and only if $G$ has a walk $W$ from $s$ to $t$ with $delta^*(s', sigma(W)) in A$,
that is, with $sigma(W) in L(M)$. Whatever-first search reaches exactly the
vertices reachable from its start, so the algorithm is correct. This also covers
the walk with no edges: if $s = t$ and $s' in A$, the answer is
#smallcaps[True] because $epsilon in L(M)$.

== Running time

Building $H$ takes $O(|V_H| + |E_H|) = O((|V| + |E|) |Q|)$ time, since each
transition $delta(q, ell(v))$ takes $O(1)$ time. The search takes
$O(|V_H| + |E_H|)$ time, and checking the vertices $(t, q)$ takes $O(|Q|)$
time. The algorithm runs in #boxed[$O((|V| + |E|) |Q|)$ time.]

With $|Q| = 4$ this is $O(|V| + |E|)$, matching part (a).

#disclosures(llm: llm-note)
