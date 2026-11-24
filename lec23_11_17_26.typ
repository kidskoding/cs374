#import "setup.typ": *

#let body = [
= Lecture 23 (Nov 17) - NP-Hardness Proofs: 3SAT to Independent Set, 3SAT to 3Color

Lectures 21 and 22 introduced the classes P and NP, defined NP-hardness, and named the
first NP-complete problem, SAT. This lecture applies those definitions. We prove that
Independent Set is NP-hard by a reduction from 3SAT, which also settles Clique and
Vertex Cover through the reductions of Lectures 21 and 22. We then prove that 3Color is
NP-hard, again by a reduction from 3SAT, this time built out of small pieces called
gadgets. Both proofs are written in the full format expected on homework and exams.

== Recap: P, NP, and NP-Hardness
All problems in this part of the course are *decision problems*, whose answer is yes or
no.
- *P* is the class of decision problems that can be solved in polynomial time.
- *NP* is the class of decision problems whose yes answers can be verified in
  polynomial time. If the answer to an instance is yes, there is a *certificate* that
  we can hand to a polynomial-time *verifier*. The verifier reads the instance and the
  certificate and confirms that the answer is yes. The verifier cannot be tricked: on a
  no instance, it rejects every certificate.
- Every problem in P is in NP, because the verifier can ignore the certificate and
  solve the instance from scratch. Most computer scientists believe that
  $P != N P$, so that many problems in NP have no polynomial-time algorithm.
- A problem is *NP-hard* if every problem in NP reduces to it in polynomial time. A
  polynomial-time algorithm for an NP-hard problem would therefore give one for every
  problem in NP. If $P != N P$, no NP-hard problem has a polynomial-time algorithm.
- A problem is *NP-complete* if it is NP-hard and also in NP. These are the hardest
  problems in NP: if $P != N P$ they have no polynomial-time algorithm, and if $P = N P$
  they do. Membership in NP is also convenient in the proofs below, because the
  certificates give us something concrete to reason about.

The first NP-complete problem is SAT. Its input is a Boolean formula in *conjunctive
normal form* (CNF): an AND of *clauses*, where each clause is an OR of *literals*, and
each literal is a variable or its negation. The question is whether some assignment of
true and false to the variables makes the formula true. SAT is in NP, because a
satisfying assignment is a certificate that can be checked in polynomial time. The
*Cook-Levin theorem* states that SAT is NP-hard. Its proof has many technical details
and is beyond the scope of this course. SAT is the first NP-complete problem that feels
natural: it is a problem people actually want to solve, and SAT solvers are used
throughout computing and beyond.

=== The strategy for proving NP-hardness
Once one NP-hard problem is known, we no longer need to reduce every problem in NP
directly to a new problem. To prove that a problem $B$ is NP-hard, we reduce a known
NP-hard problem $A$ to $B$, using a polynomial-time *many-one reduction*, also called a
*Karp reduction*. Such a reduction is a polynomial-time algorithm that turns any
instance of $A$ into an instance of $B$ with the same answer. Every problem in NP
reduces to $A$ in polynomial time, and $A$ reduces to $B$ in polynomial time, so
composing the two reductions reduces every problem in NP to $B$.

This is the only strategy needed for NP-hardness proofs on homework and on the final
exam. Lecture 22 used it to show that *3SAT* is NP-complete. 3SAT is SAT restricted to
formulas in which every clause has exactly three literals.

=== What a proof must contain
An NP-hardness proof by reduction from $A$ to $B$ has three parts.
+ Describe the reduction: given an arbitrary instance of $A$, describe the instance of
  $B$ that it builds.
+ Argue that the reduction runs in polynomial time.
+ Prove that the reduction is correct: the instance of $A$ is a yes instance if and
  only if the constructed instance of $B$ is a yes instance. Both directions need a
  proof.

When both problems are in NP, a yes instance of either one has a certificate. The
forward direction can then start from a hypothetical certificate for $A$ and build a
certificate for $B$, and the backward direction can go the other way.

=== Problems that are NP-hard but not in NP
Some NP-hard problems are not in NP. Later lectures introduce *undecidable* problems,
which have no algorithm that always finishes, and many of them are NP-hard in the sense
defined above. One example is the halting problem. Every decidable problem, and in
particular every problem in NP, can be reduced to the halting problem in polynomial
time, so the halting problem is NP-hard. It is not NP-complete, because every problem in
NP has an algorithm: a finite-time algorithm can try every certificate, since
certificates have bounded length.

== Independent Set
An *independent set* in an undirected graph $G$ is a subset $S$ of vertices such that
no two vertices of $S$ share an edge. The empty set is always independent, so the
interesting question is how large an independent set can be.

#align(center, block(stroke: 0.5pt, inset: 8pt)[
  *IndependentSet:* Given an undirected graph $G$ and an integer $k$, does $G$ contain
  an independent set of size $k$?
])

We focus on decision problems here and in the course notes. Erickson's book discusses
the same problems as optimization problems. For Independent Set the decision version
loses nothing: if $G$ has an independent set larger than $k$, any $k$ of its vertices
also form an independent set.

#theorem[IndependentSet is NP-complete.]

IndependentSet is in NP. It was the first example of a member of NP when the class was
defined. The certificate is the independent set itself. In polynomial time, the
verifier checks that the set has $k$ vertices and that no two of them share an edge.

To prove that IndependentSet is NP-hard, we need a known NP-hard problem to reduce
from, and so far the only ones are SAT and 3SAT. We reduce from 3SAT, because a
reduction is cleaner when every clause has exactly three literals.

=== The reduction
Let $phi$ be a 3CNF formula with $n$ variables and $k$ clauses. We build an undirected
graph $G$ and an integer $k'$ such that $G$ has an independent set of size $k'$ if and
only if $phi$ is satisfiable.

- $G$ has one vertex for each literal occurrence in $phi$. Since each clause has
  exactly three literals, $G$ has exactly $3k$ vertices, and we identify each vertex
  with its literal.
- For any two literals $u$ and $v$ in the same clause, $G$ has a *clause edge* $u v$.
  Each clause becomes a triangle.
- For any two literals $u$ and $v$ that are a variable and its negation, such as $a$
  and $overline(a)$, $G$ has a *literal edge* $u v$, even when $u$ and $v$ lie in
  different clauses.
- Finally, $k' = k$.

The intent is that the independent set picks the literals that are true in a
satisfying assignment. The literal edges prevent the set from containing both a literal
and its negation, so every variable is either true or false and never both. The clause
edges limit the set to one literal per clause, which makes the count come out to
exactly $k$.

*Example:* The formula
$ phi = (a or b or c) and (b or overline(c) or overline(d)) and (overline(a) or c or d) and (a or overline(b) or overline(d)) $
has $n = 4$ variables and $k = 4$ clauses. The reduction produces the graph below, with
$12$ vertices and $k' = 4$. Thin edges are clause edges and thick edges are literal
edges.

#let is-pos = (
  c1: (0, 1.8), b1: (0.75, 0.5), a1: (1.5, 1.8),
  nc2: (2.6, 0), b2: (3.35, 1.3), nd2: (4.1, 0),
  na3: (5.2, 1.8), d3: (5.95, 0.5), c3: (6.7, 1.8),
  nd4: (7.8, 0), nb4: (8.55, 1.3), a4: (9.3, 0),
)
#let is-lab = (
  a1: $a$, b1: $b$, c1: $c$,
  b2: $b$, nc2: $overline(c)$, nd2: $overline(d)$,
  na3: $overline(a)$, c3: $c$, d3: $d$,
  a4: $a$, nb4: $overline(b)$, nd4: $overline(d)$,
)
#let is-clause = (
  ("a1", "b1"), ("b1", "c1"), ("a1", "c1"),
  ("b2", "nc2"), ("nc2", "nd2"), ("b2", "nd2"),
  ("na3", "c3"), ("c3", "d3"), ("na3", "d3"),
  ("a4", "nb4"), ("nb4", "nd4"), ("a4", "nd4"),
)
#let is-literal = (
  ("c1", "nc2"), ("nc2", "c3"), ("a1", "na3"), ("na3", "a4"),
  ("b1", "nb4"), ("b2", "nb4"), ("nd2", "d3"), ("d3", "nd4"),
)
#align(center, graph-pic(
  is-pos,
  is-clause + is-literal,
  bold: is-literal,
  marked: ("a1", "nd2", "c3", "a4"),
  label: n => is-lab.at(n),
  unit: 40pt,
))
#align(center, text(size: 0.85em)[One triangle per clause, in order from left to right.
The shaded vertices form the independent set built from the assignment
$a = b = c = "true"$, $d = "false"$.])

=== Running time
The reduction builds one triangle per clause, which takes constant time per clause.
There is at most one literal edge per pair of vertices, so there are $O(k^2)$ literal
edges, and the whole graph can be built in $O(k^2)$ time. This is polynomial in the
size of $phi$.

=== Correctness
We prove that $phi$ is satisfiable if and only if $G$ has an independent set of size
$k$.

($arrow.r.double$) Suppose that $phi$ has a satisfying assignment. Every clause then
contains at least one true literal. Choose one true literal from each clause,
arbitrarily if a clause has several, and let $S$ be the set of the corresponding
vertices. Since $S$ has one vertex per clause, $|S| = k$. We check that no edge of $G$
has both endpoints in $S$.
- A clause edge joins two literals of the same clause, and $S$ contains only one
  literal from each clause.
- A literal edge joins a literal and its negation. Under the assignment exactly one of
  the two is true, and $S$ contains only true literals.

So $S$ is an independent set of size $k$. In the example, the assignment
$a = b = c = "true"$, $d = "false"$ satisfies $phi$, and one choice of true literals is
$a$, $overline(d)$, $c$, $a$, the shaded vertices in the figure.

($arrow.l.double$) Suppose that $G$ has an independent set $S$ of size $k$.
- Two vertices of the same triangle share a clause edge, so $S$ contains at most one
  vertex from each triangle. There are exactly $k$ triangles and $|S| = k$, so $S$
  contains exactly one vertex from each triangle.
- Because of the literal edges, $S$ never contains both a literal and its negation.

For each vertex of $S$, set its variable so that the literal is true. This assignment is
consistent, because no variable is asked to be both true and false. Variables with no
literal in $S$ can be set arbitrarily. Each clause has a literal in $S$, which is true,
so every clause is satisfied, and $phi$ is satisfiable.

The reduction is correct and runs in polynomial time, and 3SAT is NP-hard, so
IndependentSet is NP-hard. It is also in NP, so it is NP-complete.

#trap[Without the literal edges, the forward direction would still hold, but the
backward direction would fail: an independent set could contain a literal and its
negation, and it would not describe any assignment. Many constructions look like
reductions because "yes for $A$" implies "yes for $B$", even though the converse is
false. An NP-hardness proof must state and prove both directions of the "if and only
if".]

== Consequences: Clique and Vertex Cover
Lectures 21 and 22 gave Karp reductions from IndependentSet to Clique and from
IndependentSet to VertexCover. Now that IndependentSet is known to be NP-hard, those
reductions show that Clique and VertexCover are NP-hard, with no further work. Both
problems are also in NP: the certificate for Clique is the clique, and the certificate
for VertexCover is the vertex cover. So both are NP-complete.

All NP-complete problems reduce to one another in polynomial time, since each is in NP
and each is NP-hard. In this sense they are equally difficult, up to polynomial
overhead.

#trap[The direction of the reduction matters. To prove that a new problem is NP-hard,
we reduce the known NP-hard problem to the new problem. Thinking of the new problem as
a black box, the reduction shows how to use it to solve the known hard problem.
Reducing the new problem to a known hard problem proves nothing about hardness. For
example, every decidable problem has a Karp reduction to the halting problem, and that
fact says nothing about how hard those problems are.]

=== Problems between P and NP-hard
If $P != N P$, there are problems in NP that are neither in P nor NP-hard. The known
examples are artificial problems constructed for this argument. Some natural problems
are believed to lie in this intermediate range, such as deciding whether a large
integer has a small factor, or whether two graphs are isomorphic, but no proof is known
that they do.

== 3-Coloring
A *$k$-coloring* of an undirected graph $G = (V, E)$ is an assignment of $k$ colors to
the vertices, that is, a function $c: V -> {1, 2, dots, k}$. The coloring is *proper*
if every edge $u v$ has $c(u) != c(v)$. Colorings appear in other settings as well:
- The four-color theorem states that every planar graph (or map) has a proper
  4-coloring.
- In a compiler, register allocation is a coloring problem. The vertices are the
  variables of a function, and two variables that must be stored at the same time are
  adjacent, so they need different registers.

Computing the minimum number of colors, or the decision version "can $G$ be properly
colored with at most $k$ colors?", is NP-hard. More surprisingly, the problem stays
NP-hard when the number of colors is fixed at three.

#align(center, block(stroke: 0.5pt, inset: 8pt)[
  *3Color:* Given an undirected graph $G$, does $G$ have a proper 3-coloring?
])

3Color is a special case of the general coloring problem, so it can only be easier.
Even so, deciding whether three colors suffice is NP-complete. Deciding whether four
colors suffice, or five, is also NP-hard; those reductions are simpler than the one
below.

#theorem[3Color is NP-complete.]

3Color is in NP: the certificate is a coloring. The verifier checks that it uses only
three colors and that no edge has two endpoints of the same color.

To prove that 3Color is NP-hard, the easiest reduction again starts from 3SAT, even
though IndependentSet, Clique, and VertexCover are now available. Erickson's book
suggests that the reduction is natural because the number three appears on both sides. A better
explanation is that $3 = 1 + 2$: two colors stand for the two values of a Boolean
variable, and one extra color makes the construction work.

=== The reduction
Given a 3CNF formula $phi$, we build an undirected graph $G$ that is 3-colorable if
and only if $phi$ is satisfiable. The graph is assembled from *gadgets*, small
subgraphs that each capture one aspect of the original problem. "Gadget" is the
standard term in research papers.

The *truth gadget* is a triangle in $G$ with vertices named $T$, $F$, and $X$. In any
proper 3-coloring, the three vertices of a triangle get three different colors, so all
three colors appear on this triangle. We name each color after its vertex: the color of
$T$ is *true*, the color of $F$ is *false*, and the color of $X$ is *other*. The other
color is needed only to make the construction work; it does not correspond to a truth
value.

For each variable $a$ of $phi$, the *variable gadget* is a triangle with two new
vertices $a$ and $overline(a)$ and the vertex $X$ from the truth gadget. In a proper
3-coloring, $X$ has the other color, so $a$ and $overline(a)$ receive the true and
false colors, one each. Thus exactly one of the two literals is colored true.

#let tv-pos = (
  a: (0, 0), na: (1, 0), b: (1.8, 0), nb: (2.8, 0),
  c: (3.6, 0), nc: (4.6, 0), d: (5.4, 0), nd: (6.4, 0),
  X: (3.2, 1.6), T: (2.6, 2.9), F: (3.8, 2.9),
)
#let tv-lab = (
  a: $a$, na: $overline(a)$, b: $b$, nb: $overline(b)$,
  c: $c$, nc: $overline(c)$, d: $d$, nd: $overline(d)$,
  X: $X$, T: $T$, F: $F$,
)
#let tv-truth = (("T", "F"), ("F", "X"), ("T", "X"))
#align(center, graph-pic(
  tv-pos,
  tv-truth + ("a", "b", "c", "d").map(v => ((v, "n" + v), (v, "X"), ("n" + v, "X"))).flatten().chunks(2),
  bold: tv-truth,
  label: n => tv-lab.at(n),
  unit: 40pt,
))
#align(center, text(size: 0.85em)[The truth gadget (thick) and the variable gadgets for
$a, b, c, d$. Every variable triangle shares the vertex $X$.])

For each clause, $G$ contains a *clause gadget* that joins the clause's three literal
vertices to the vertex $T$, using five new vertices and ten edges. The
literal vertices are the ones from the variable gadgets and $T$ is the vertex from the
truth gadget, but every clause gets its own five new vertices. All clause gadgets have
the same shape. For the clause $(x or y or z)$, with new vertices $p, q, r, s, u$, the
edges are
$ x p, quad y q, quad p q, quad p r, quad q r, quad r s, quad z u, quad s u, quad s T, quad u T. $
The figure shows the gadget for the clause $(a or b or overline(c))$.

#let cg-pos = (
  a: (0, 0), b: (0, 1.6), nc: (0, 3.2),
  p: (1.2, 0), q: (1.2, 1.6), r: (2.2, 0.8),
  s: (3.3, 0.8), u: (3.3, 3.2), T: (4.4, 2),
)
#let cg-lab = (
  a: $a$, b: $b$, nc: $overline(c)$, p: $p$, q: $q$, r: $r$, s: $s$, u: $u$, T: $T$,
)
#align(center, graph-pic(
  cg-pos,
  (("a", "p"), ("b", "q"), ("p", "q"), ("p", "r"), ("q", "r"),
   ("r", "s"), ("nc", "u"), ("s", "u"), ("s", "T"), ("u", "T")),
  marked: ("p", "q", "r", "s", "u"),
  label: n => cg-lab.at(n),
  unit: 40pt,
))
#align(center, text(size: 0.85em)[The clause gadget for $(a or b or overline(c))$. The
shaded vertices are new to this gadget; $a$, $b$, $overline(c)$, and $T$ are shared
with the rest of $G$.])

The gadget behaves like a chain of two logic gates. In a proper 3-coloring every
literal vertex is colored true or false, so consider the left part, the triangle
$p q r$ attached to the inputs $x$ and $y$.
- If $x$ and $y$ are both true, then $p$ and $q$ avoid the true color and differ from
  each other, so they use false and other, and $r$ must be true.
- If $x$ and $y$ are both false, the same argument with the roles of true and false
  exchanged forces $r$ to be false.
- If exactly one of $x, y$ is true, then $r$ can be given any of the three colors.

The left triangle therefore acts like a majority gate on two inputs: $r$ is forced to
be false exactly when both inputs are false, and otherwise $r$ can be colored true. The
right part is the triangle $s u T$, where $s$ is attached to $r$ and $u$ to $z$. If $r$
and $z$ were both false, then $s$ and $u$ could use neither the false color nor the true
color of their neighbor $T$, so both would be other, which is impossible because $s$
and $u$ are adjacent. Hence:

#keyidea[A clause gadget has a proper 3-coloring, consistent with the colors of its
literal vertices and of $T$, if and only if at least one of its three literal vertices
is colored true.]

=== Running time
$G$ has $3 + 2n + 5k$ vertices and $3 + 3n + 10k$ edges, where $n$ is the number of
variables and $k$ the number of clauses. Each gadget has constant size, so $G$ can be
built in $O(n + k)$ time. For the four-clause formula of the Independent Set example,
the graph has $3 + 8 + 20 = 31$ vertices. The full drawing looks complicated, but its
size is linear in the size of $phi$.

=== Correctness
We prove that $phi$ is satisfiable if and only if $G$ has a proper 3-coloring.

($arrow.r.double$) Suppose that $phi$ has a satisfying assignment. Give $T$, $F$, and
$X$ the colors true, false, and other. Each variable is true or false, so each literal
is true or false; color the true literals with the true color and the false literals
with the false color. Each variable triangle then has one literal of each truth value
together with $X$, so it is properly colored. Each clause has at least one true literal,
so the colors extend through its clause gadget:
- If $x$ or $y$ is true, the left triangle can be colored so that $r$ is true. Color
  $s$ false and $u$ other. The neighbors of $s$ are $r$ and $T$, which are true, and
  $u$, which is other. The neighbors of $u$ are $T$, $s$, and $z$, colored true, false,
  and either true or false, none of which is other.
- If $x$ and $y$ are both false, then $z$ is true and $r$ is forced to be false. Color
  $s$ other, since it is adjacent to $r$ and $T$, and color $u$ false. The neighbors of
  $u$ are $T$, $s$, and $z$, colored true, other, and true.

So $G$ has a proper 3-coloring. In the example formula with $a = b = c = "true"$ and
$d = "false"$, the second clause $(b or overline(c) or overline(d))$ has the true
literals $b$ and $overline(d)$. Here $x = b$ is true, so its gadget is colored as in
the first case.

($arrow.l.double$) Suppose that $G$ has a proper 3-coloring. The triangle $T F X$
uses all three colors; call them true, false, and other according to their vertices.
By the variable gadgets, every literal vertex is colored true or false, and each
literal and its negation get opposite colors. Assign each variable the value that makes
its true-colored literal true. For example, if $a$ is colored true we set $a$ true, and
if $overline(d)$ is colored true we set $d$ false. This is a consistent assignment
because exactly one of $a, overline(a)$ is colored true. By the analysis of the clause
gadget, the coloring of each gadget is consistent with the true color on $T$ only if at
least one of its three literal vertices is colored true. So every clause contains a true
literal, and $phi$ is satisfied.

The reduction is correct and runs in polynomial time, so 3Color is NP-hard, and since
it is in NP, it is NP-complete.

Designing a reduction as involved as this one is beyond what homework and exams
require. The idea of a gadget, a small subgraph that enforces one constraint of the
original problem, is useful in simpler reductions as well. Lecture 24 presents two more
NP-hardness proofs and discusses how to choose which known problem to reduce from.
]

#show: notes
#set heading(numbering: "1.1")
#body
