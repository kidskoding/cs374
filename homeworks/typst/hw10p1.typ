// CS 374 A, Homework 10, Problem 1
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let PM = smallcaps[PerfectMatching]
#let Sat = smallcaps[Sat]
#let True = smallcaps[True]
#let False = smallcaps[False]

#show: homework.with(
  title: "CS 374: Section A - Homework 10, Problem 1",
  date: "November 17, 2026",
)

Throughout this problem, $G = (V, E)$ is a simple undirected graph (no loops
and no parallel edges). For a vertex $v$, let $E(v)$ be the set of edges
incident to $v$, and let $deg(v) = |E(v)|$.

*Exactly one per vertex*: A set $M subset.eq E$ is a perfect matching if and
only if every vertex $v in V$ is incident to exactly one edge of $M$. If every
vertex is in exactly one edge of $M$, no two edges of $M$ share a vertex, and
counting edge endpoints gives $2|M| = sum_v |M inter E(v)| = |V|$. Conversely,
in a matching every vertex is in at most one edge of $M$, and $2|M| = |V|$
means the $2|M|$ endpoints cover all $|V|$ vertices, so every vertex is in
exactly one. We use this form below.

= (a) #PM $in$ NP

*Certificate*: a set $M$ of edges, listed as pairs of vertices. A perfect
matching has $|M| = |V| slash 2 <= |E|$ edges, so the certificate has size
polynomial in the size of $G$.

*Verifier*: Given $G$ and $M$:

+ Check that every pair in $M$ is an edge of $E$.
+ Set a counter $c(v) <- 0$ for every vertex $v$. For every edge ${u, v}$ in
  $M$, add $1$ to $c(u)$ and to $c(v)$.
+ Accept if and only if $c(v) = 1$ for every vertex $v$.

By the fact above, the verifier accepts exactly when $M$ is a perfect matching
of $G$. (A pair listed twice adds $2$ to its endpoints' counters, so it is
rejected.) Step 1 takes $O(|M| dot |E|) = O(|E|^2)$ time by scanning $E$ for
each pair, and steps 2 and 3 take $O(|V| + |M|)$ time. So the verifier runs in
polynomial time.

$G$ has a perfect matching if and only if some certificate makes the verifier
accept, so #PM $in$ NP.

#disclosures(sources: [None], llm: llm-note)

#pagebreak()

= (b) Reduction from #PM to #Sat

== Reduction

Given $G = (V, E)$, build a CNF formula $Phi$ as follows.

*Special cases*: If $V = emptyset$, output $Phi = (y)$, which is satisfiable;
the empty matching is perfect. If some vertex has degree $0$, output
$Phi = (y) and (not y)$, which is not satisfiable; that vertex can never be
matched, so $G$ has no perfect matching.

*Main case*: Every vertex has degree at least $1$.

- *Variables*: one variable $x_e$ for every edge $e in E$. The intended meaning
  is "$x_e =$ #True if and only if $e in M$".
- *At least one*: For every vertex $v$, the clause
  $
  A_v = or.big_(e in E(v)) x_e
  $
  It has $deg(v) >= 1$ literals.
- *At most one*: For every vertex $v$ and every pair of distinct edges
  $e, f in E(v)$, the clause
  $
  B_(v, e, f) = (not x_e or not x_f)
  $

#boxed[
  $Phi = and.big_(v in V) A_v and and.big_(v in V) and.big_(e != f in E(v)) B_(v, e, f)$
]

For a fixed $v$, the clauses $A_v$ and all $B_(v, e, f)$ together are true if
and only if exactly one of the variables $x_e$ with $e in E(v)$ is #True.

== Correctness

#boxed[$G$ has a perfect matching #h(1em) $<==>$ #h(1em) $Phi$ is satisfiable]

The special cases were handled above, so assume every vertex has degree at
least $1$.

$==>$ Suppose $G$ has a perfect matching $M$. Set $x_e =$ #True if $e in M$
and $x_e =$ #False otherwise. Every vertex $v$ is in exactly one edge of $M$, so
exactly one of the variables $x_e$ with $e in E(v)$ is #True. So $A_v$ is true,
and every $B_(v, e, f)$ is true. This holds for every $v$, so $Phi$ is true.

$<==$ Suppose $Phi$ has a satisfying assignment. Let
$M = {e in E : x_e = #True}$. For every vertex $v$, the clause $A_v$ is true,
so at least one edge of $E(v)$ is in $M$. Every clause $B_(v, e, f)$ is true,
so no two different edges of $E(v)$ are both in $M$. So every vertex is in
exactly one edge of $M$, and by the fact at the top, $M$ is a perfect matching
of $G$.

== Running time

Computing the degrees and checking the special cases takes $O(|V| + |E|)$ time.
$Phi$ has $|E|$ variables. The clauses $A_v$ have $sum_v deg(v) = 2|E|$
literals in all. The number of clauses $B_(v, e, f)$ is
$
sum_(v in V) binom(deg(v), 2) <= sum_(v in V) (deg(v) (|V| - 1)) / 2 = |E| (|V| - 1)
$
and each has $2$ literals. So $Phi$ has size $O(|V| + |V| |E|)$, and we can
write it down in that much time by looping over each vertex and each pair of
its edges. The reduction runs in #boxed[$O(|V| + |V| |E|)$ time]
which is polynomial in the size of $G$. #h(1fr) $square$

#disclosures(sources: [None], llm: llm-note)

#pagebreak()

= (c) Why this does not imply P $=$ NP

Part (b) shows #PM $<=_P$ #Sat, so a fast algorithm for #Sat would give a fast
algorithm for #PM. That tells us #Sat is at least as hard as #PM. It tells us
nothing about how hard #Sat is compared to #PM in the other direction, so the
polynomial time algorithm for #PM says nothing new about #Sat.

To conclude P $=$ NP, we would need a polynomial time algorithm for an NP-hard
problem such as #Sat, or a polynomial time reduction *from* #Sat *to* #PM.
Combined with the fast #PM algorithm, that second reduction would solve #Sat in
polynomial time. We have neither. Part (b) reduces the easy problem to the hard
one.

By the Cook-Levin theorem, every problem in NP, including every problem in P,
reduces to #Sat anyway, so part (b) could not have told us anything about
P versus NP.

#disclosures(sources: [None], llm: llm-note)
