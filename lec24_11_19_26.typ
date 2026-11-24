#import "setup.typ": *

// Vertex names for gadget pictures: "uv-in" is drawn as uv over "in", "c1" as c_1.
#let gv(n) = if n.starts-with("c") {
  eval("c_" + n.last(), mode: "math")
} else {
  let (p, s) = n.split("-")
  stack(spacing: 1.5pt, eval(p.clusters().join(" "), mode: "math"), text(size: 0.85em, s))
}
// Draw the bold edges last so that the thin reverse edge of a bidirected pair does not cover them.
#let bold-last(all, b) = all.filter(e => e not in b) + b

#let body = [
= Lecture 24 (Nov 19) - NP-Hardness Proofs: Vertex Cover to Directed Hamiltonian Cycle, Vertex Cover to Subset Sum, Choosing a Problem to Reduce From

This lecture gives two more NP-hardness reductions, both from vertex cover. The first
reduces vertex cover to directed Hamiltonian cycle, using the most elaborate gadgets in
the course. The second reduces vertex cover to subset sum. It is much simpler, and it
shows that a problem about adding integers can be NP-hard. The lecture ends with advice on choosing
the problem to reduce from in a new NP-hardness proof.

Recall that to prove a problem NP-complete, we show that it is in NP and that it is
NP-hard. To prove NP-hardness by a reduction from a known NP-hard problem, we
- describe an algorithm that turns any instance of the known problem into an instance
  of the new problem,
- show that the algorithm runs in polynomial time, and
- show that the original instance is a yes instance if and only if the new instance
  is a yes instance, proving each direction separately.

The *vertex cover* problem takes an undirected graph $G = (V, E)$ and an integer $k$
and asks whether $G$ has a vertex cover of size at most $k$, that is, a set of at most
$k$ vertices such that every edge of $G$ has at least one endpoint in the set.

== Vertex Cover to Directed Hamiltonian Cycle
A *Hamiltonian cycle* in a graph is a cycle that contains every vertex exactly once. In
other words, it is a closed walk that visits every vertex and returns to its start
without entering any vertex twice, except the starting vertex at the end. The
*directed Hamiltonian cycle* problem takes a directed graph as its only input and asks
whether it contains a Hamiltonian cycle.

The problem is in NP. A certificate for a yes instance is the cycle itself, written as
a permutation of the vertices. A verifier checks in polynomial time that every vertex
appears exactly once and that each vertex in the sequence has an edge to the next one,
including an edge from the last back to the first.

Erickson's textbook gives two proofs that the problem is NP-hard, one of them by a
reduction from 3SAT. Here we reduce from vertex cover. Given an undirected graph $G$
and an integer $k$, we build a new directed graph $H$ that has a Hamiltonian cycle if
and only if $G$ has a vertex cover of size $k$. As in the 3-coloring reduction, $H$ is
assembled from *gadgets*, small pieces of the new instance that each capture one aspect
of the original instance. A vertex cover has to cover edges, so there is one gadget per
edge of $G$. There is also one gadget per vertex and one more piece that enforces the
size bound $k$.

We may assume that $k$ is smaller than the number of vertices of $G$ with at least one
neighbor. Otherwise those vertices already form a vertex cover of size at most $k$, and
the reduction can output any fixed graph that has a Hamiltonian cycle. Under this
assumption, a vertex cover of size at most $k$ can be padded with further vertices of
positive degree until it has exactly $k$ vertices, so we look for covers of size
exactly $k$.

=== Edge gadgets
For each edge $u v$ of $G$, the graph $H$ has four vertices
$ (u, v, "in"), quad (u, v, "out"), quad (v, u, "in"), quad (v, u, "out") $
and six edges:
- $(u, v, "in") -> (u, v, "out")$ and $(v, u, "in") -> (v, u, "out")$,
- edges in both directions between $(u, v, "in")$ and $(v, u, "in")$,
- edges in both directions between $(u, v, "out")$ and $(v, u, "out")$.

The vertices whose first component is $u$ form the *$u$ side* of the gadget, and the
other two form the $v$ side. The rest of $H$ is wired so that a cycle can enter the
gadget only at one of the two in-vertices and can leave only from one of the two
out-vertices. Under that restriction, a Hamiltonian cycle can pass through the gadget
in exactly three ways:
+ It enters at $(u, v, "in")$, crosses to the $v$ side, goes up the $v$ side, crosses
  back, and leaves from $(u, v, "out")$. This represents $u$ being in the cover and $v$
  not.
+ The mirror image: it enters at $(v, u, "in")$, zigzags through the $u$ side, and
  leaves from $(v, u, "out")$. This represents $v$ being in the cover and $u$ not.
+ It enters at $(u, v, "in")$ and goes straight to $(u, v, "out")$, and at another time
  it enters at $(v, u, "in")$ and goes straight to $(v, u, "out")$. This represents
  both endpoints being in the cover.

#let gd-pos = ("uv-in": (0, 1.7), "uv-out": (0, 0), "vu-in": (1.7, 1.7), "vu-out": (1.7, 0))
#let gd-edges = (
  ("uv-in", "uv-out"), ("vu-in", "vu-out"),
  ("uv-in", "vu-in"), ("vu-in", "uv-in"),
  ("uv-out", "vu-out"), ("vu-out", "uv-out"),
)
#let gd(b, cap) = stack(spacing: 6pt,
  graph-pic(gd-pos, bold-last(gd-edges, b), directed: true, bold: b, label: gv,
    unit: 36pt, r: 13pt, size: 0.65em),
  text(size: 0.85em, cap))
#align(center, grid(
  columns: 4,
  column-gutter: 2.2em,
  align: bottom,
  gd((), [The gadget for $u v$]),
  gd((("uv-in", "vu-in"), ("vu-in", "vu-out"), ("vu-out", "uv-out")), [(1) only $u$]),
  gd((("vu-in", "uv-in"), ("uv-in", "uv-out"), ("uv-out", "vu-out")), [(2) only $v$]),
  gd((("uv-in", "uv-out"), ("vu-in", "vu-out")), [(3) both, in two passes]),
))

To see that no other pattern is possible, suppose that the cycle enters at
$(u, v, "in")$. If it next goes to $(v, u, "in")$, then it must continue to
$(v, u, "out")$, because the only other edge out of $(v, u, "in")$ leads back to a
vertex already used. If the cycle then left the gadget, the vertex $(u, v, "out")$
could never be visited, since both of its incoming edges come from vertices already
used. So the cycle goes on to $(u, v, "out")$ and leaves; this is pattern (1). If
instead the cycle goes from $(u, v, "in")$ straight to $(u, v, "out")$, it cannot
continue to $(v, u, "out")$: then $(v, u, "in")$ would have no unused vertex to move
to, since both of its outgoing edges lead to vertices already used. So the cycle leaves
from $(u, v, "out")$, and the $v$ side must be covered by a separate pass from
$(v, u, "in")$ to $(v, u, "out")$; this is pattern (3). Entering at $(v, u, "in")$ is
symmetric. In every pattern, a cycle that enters at $(u, v, "in")$ leaves from
$(u, v, "out")$.

=== Vertex chains
For each vertex $u$ of $G$, the edge gadgets on the $u$ sides are linked into a *vertex
chain*. Let $v_1, v_2, dots, v_d$ be the neighbors of $u$, in any order. We add the
$d - 1$ edges
$ (u, v_i, "out") -> (u, v_(i + 1), "in") quad "for" 1 <= i <= d - 1. $
The chain begins at $(u, v_1, "in")$ and ends at $(u, v_d, "out")$. Suppose that a
Hamiltonian cycle enters the chain at its first vertex. In every pattern it leaves the
gadget from the out-vertex on the same side, and from there the only edge inside the
chain leads to the next gadget's in-vertex on the $u$ side. So the cycle passes through
all of $u$'s edge gadgets in order and leaves the chain at $(u, v_d, "out")$. Along the
way it may take detours through the other sides of gadgets, as in pattern (1). Entering
$u$'s chain means committing to $u$ as a member of the cover for every edge at $u$.

=== Cover vertices
Finally, we add $k$ *cover vertices* $c_1, dots, c_k$. (The lecture called them
$x_1, dots, x_k$; we rename them because the example below has a vertex $x$.) For every
$j$ and every vertex $u$ of $G$ with at least one neighbor, we add an edge from $c_j$
to the first vertex $(u, v_1, "in")$ of $u$'s chain, and an edge from the last vertex
$(u, v_d, "out")$ of $u$'s chain to $c_j$. A cycle can therefore enter a chain only at
its beginning, from a cover vertex, and can leave a chain only at its end, to a cover
vertex. The number of cover vertices enforces the size bound $k$.

*Example:* The undirected graph $G$ below has four vertices and five edges. We ask
whether it has a vertex cover of size $2$. The edge labels in red are the edge numbers
used later in the subset sum reduction. The vertices $u$ and $x$, marked in yellow,
form a vertex cover.

#let ex-pos = (u: (0, 0), v: (2.2, 0), w: (0, 1.6), x: (2.2, 1.6))
#let ex-num = (("u", "v", $0$), ("u", "w", $1$), ("u", "x", $2$), ("v", "x", $3$), ("w", "x", $4$))
#align(center, graph-pic(
  ex-pos,
  ex-num.map(((a, b, _)) => (a, b)),
  marked: ("u", "x"),
  weight: e => ex-num.find(((a, b, _)) => (a, b) == e).at(2),
  unit: 44pt,
))

For this instance, $H$ has $4 dot 5 = 20$ gadget vertices and $2$ cover vertices. The
figure below shows only $u$'s vertex chain, with $u$'s neighbors taken in the order
$w, x, v$. The bottom row is the $u$ side of each gadget and the top row is the other
side. The bold edges show how the Hamiltonian cycle for the cover ${u, x}$ (described
below) passes through the chain. It detours through the $w$ and $v$ sides because $w$
and $v$ are not in the cover. It goes straight through the gadget for $u x$, because
$x$ is in the cover and $x$'s own chain visits the $x$ side later.

#let ch-pos = (
  "c1": (0, 1.5),
  "uw-in": (1.1, 1.5), "uw-out": (2.1, 1.5), "wu-in": (1.1, 0), "wu-out": (2.1, 0),
  "ux-in": (3.2, 1.5), "ux-out": (4.2, 1.5), "xu-in": (3.2, 0), "xu-out": (4.2, 0),
  "uv-in": (5.3, 1.5), "uv-out": (6.3, 1.5), "vu-in": (5.3, 0), "vu-out": (6.3, 0),
  "c2": (7.4, 1.5),
)
#let ch-gadget(a, b) = (
  (a + "-in", a + "-out"), (b + "-in", b + "-out"),
  (a + "-in", b + "-in"), (b + "-in", a + "-in"),
  (a + "-out", b + "-out"), (b + "-out", a + "-out"),
)
#let ch-all = ch-gadget("uw", "wu") + ch-gadget("ux", "xu") + ch-gadget("uv", "vu") + (
  ("uw-out", "ux-in"), ("ux-out", "uv-in"), ("c1", "uw-in"), ("uv-out", "c2"),
)
#let ch-bold = (
  ("c1", "uw-in"), ("uw-in", "wu-in"), ("wu-in", "wu-out"), ("wu-out", "uw-out"),
  ("uw-out", "ux-in"), ("ux-in", "ux-out"), ("ux-out", "uv-in"),
  ("uv-in", "vu-in"), ("vu-in", "vu-out"), ("vu-out", "uv-out"), ("uv-out", "c2"),
)
#align(center, graph-pic(ch-pos, bold-last(ch-all, ch-bold), directed: true,
  bold: ch-bold, marked: ("c1", "c2"), label: gv, unit: 42pt, r: 13pt, size: 0.65em))
#align(center, text(size: 0.85em)[The vertex chain for $u$. Edges to and from the
chains of $v$, $w$, and $x$ are not drawn.])

=== Running time
Every edge gadget has $4$ vertices and $6$ edges, and the chains add fewer than $2|E|$
edges in total. The cover vertices add $2k$ edges for each vertex of $G$. Since we
assumed that $k < |V|$, the graph $H$ has $4|E| + k$ vertices and
$O(|E| + |V|^2)$ edges. Each gadget has constant size and is built directly from the
input, so $H$ can be constructed in polynomial time, even though the drawing of $H$
looks much larger than $G$.

=== A vertex cover gives a Hamiltonian cycle
Suppose that $G$ has a vertex cover ${u_1, dots, u_k}$ of size $k$. We build a
Hamiltonian cycle in $H$ as follows.
+ Start at the cover vertex $c_1$ and go to the first vertex of $u_1$'s chain.
+ Walk through $u_1$'s chain. At the gadget for an edge $u_1 v$:
  - if $v$ is also in the cover, go straight from $(u_1, v, "in")$ to
    $(u_1, v, "out")$, leaving the $v$ side for $v$'s chain;
  - if $v$ is not in the cover, take the detour of pattern (1) through the $v$ side.
+ From the end of $u_1$'s chain, go to $c_2$, then through $u_2$'s chain in the same
  way, then to $c_3$, and so on.
+ From the end of $u_k$'s chain, return to $c_1$, closing the cycle.

Each cover vertex is visited once. The chain of each vertex in the cover is walked once, and no
other chain is entered from a cover vertex. Consider the gadget for an edge $u v$.
Because the set is a vertex cover, at least one of $u$ and $v$ is in it. If only $u$ is,
the walk through $u$'s chain visits all four gadget vertices in its detour. If both
are, each chain visits its own side. In either case every vertex of the gadget is
visited exactly once, so the cycle is Hamiltonian.

For the example, the cover ${u, x}$ gives a cycle that goes from $c_1$ through $u$'s
chain as in the figure, then to $c_2$, then through $x$'s chain, which goes straight
through the gadget for $u x$ and detours through the $v$ and $w$ sides of the gadgets
for $v x$ and $w x$, and finally back to $c_1$.

=== A Hamiltonian cycle gives a vertex cover
Conversely, suppose that $H$ has a Hamiltonian cycle. Every edge out of a cover vertex
leads to the first vertex of some chain. As shown above, once the cycle enters a chain
at its first vertex, it passes through every gadget of that chain and leaves at the
chain's last vertex, whose only edges out of the chain lead to cover vertices. So the
cycle alternates between cover vertices and walks through whole chains, possibly with
detours. Because there are exactly $k$ cover vertices, the cycle walks through exactly
$k$ chains. Let $C$ be the set of the $k$ vertices of $G$ whose chains are walked.

The cycle visits all four vertices of each edge gadget, and every vertex of $H$ other
than the cover vertices lies on one of the $k$ chain walks. The only edges into the
gadget for $u v$ come from $u$'s chain and $v$'s chain, so the gadget is visited by a
walk of $u$'s chain or of $v$'s chain, and $u$ or $v$ is in $C$. Every edge of $G$
therefore has an endpoint in $C$, and $C$ is a vertex cover of size $k$.

#keyidea[In a gadget reduction, the gadgets restrict how a solution of the new
instance can look. Here each edge gadget can be traversed in only three ways and each
vertex chain must be walked completely or not entered from a cover vertex at all, so
any Hamiltonian cycle of $H$ can be read back as a choice of $k$ vertices covering
every edge.]

#trap[The vertex cover lives in the undirected graph $G$, and the Hamiltonian cycle
lives in the new directed graph $H$. We never look for a vertex cover inside $H$; it
is a separate graph built to answer the question about $G$. When both endpoints of an
edge $u v$ are in the cover, neither chain takes a detour through that edge's gadget.
The walk through $u$'s chain goes straight up the $u$ side, and the walk through $v$'s
chain later goes straight up the $v$ side.]

A reduction this elaborate is not expected on homework or exams. The full written
proof in the lecture notes shows the style expected for an NP-hardness proof: the
construction, its running time, and both directions of the equivalence.

=== Related problems
- Vertex cover and directed Hamiltonian cycle are both NP-complete, so directed
  Hamiltonian cycle also reduces to vertex cover. The lecture gave no clean direct
  reduction in that direction, but one can be obtained by going through SAT.
- Directed Hamiltonian cycle reduces directly to *undirected Hamiltonian cycle*, which
  asks whether an undirected graph has a cycle through every vertex exactly once. The
  details are in the notes for Lecture 23.
- The *directed* and *undirected Hamiltonian path* problems ask whether a graph has a
  path that contains every vertex exactly once. The input does not specify where the
  path starts or ends. Both problems are NP-complete, and the Hamiltonian cycle
  problems reduce to them. A direct reduction from vertex cover to directed
  Hamiltonian path is also possible by changing the construction above so that the
  path is forced to start and end at cover vertices, for example by splitting one
  cover vertex into a copy that keeps only its outgoing edges and a copy that keeps
  only its incoming edges.

== Vertex Cover to Subset Sum
The *subset sum* problem takes a set $X$ of positive integers and a non-negative
integer $T$, the *target*, and asks whether some subset of $X$ sums to exactly $T$.
Each integer of $X$ is either taken once or not taken.

Subset sum is in NP. The certificate for a yes instance is a subset $S subset.eq X$
with sum $T$, and a verifier can add up $S$ and compare it with $T$ in polynomial
time. The subset $S$ is not part of the input; the question is whether such a subset
exists.

To prove NP-hardness, we reduce from a problem that also asks for a subset, so that
the subset chosen in the original problem can correspond to the subset chosen in subset
sum. Among the NP-hard problems seen so far, independent set, clique, and vertex cover
ask for subsets. We use vertex cover again and give a Karp reduction from vertex cover
to subset sum. The gadgets are now integers, and they are much simpler than in the
Hamiltonian cycle reduction.

=== The construction
Let $(G, k)$ be an instance of vertex cover. As before, we may assume $k <= |V|$, since
otherwise the answer is yes; then any cover of size at most $k$ can be padded to one of
size exactly $k$. Number the edges of $G$ from $0$ to $|E| - 1$. We build $X$ and $T$
as follows.
- For each edge $i$, add the integer $b_i = 4^i$.
- For each vertex $v$, add the integer
  $ a_v = 4^(|E|) + sum_(i in delta(v)) 4^i, $
  where $delta(v)$ is the set of numbers of the edges incident to $v$.
- Set the target to
  $ T = k dot 4^(|E|) + sum_(i = 0)^(|E| - 1) 2 dot 4^i. $

It helps to write every number in base $4$, with $|E| + 1$ digits, numbered $0$
through $|E|$ from the right. Digit $i < |E|$ belongs to edge $i$, and digit $|E|$
counts vertices. Every $a_v$ has a $1$ in digit $|E|$ and a $1$ in the digit of each
edge at $v$. The target has $k$ in digit $|E|$ and $2$ in every other digit.

For an edge $i = u v$, exactly three integers in $X$ have a nonzero digit $i$, namely
$a_u$, $a_v$, and $b_i$. A sum that reaches $2$ in digit $i$ must use at least one of
$a_u$ and $a_v$, so it must cover edge $i$. If it uses only one of them, $b_i$ supplies
the missing $1$.

*Example:* For the graph of the previous section, with the edges numbered as in the
figure ($u v = 0$, $u w = 1$, $u x = 2$, $v x = 3$, $w x = 4$) and $k = 2$, the instance
is shown below in base $4$. The last column gives the subset for the vertex cover
${u, x}$, which is constructed in the proof below.

#align(center, table(
  columns: 8,
  inset: (x: 8pt, y: 4pt),
  stroke: 0.5pt,
  align: center,
  table.header([*Integer*], [*digit 5*], [*4*], [*3*], [*2*], [*1*], [*0*], [*In $S$?*]),
  [$b_0$ ($u v$)], [0], [0], [0], [0], [0], [1], [yes],
  [$b_1$ ($u w$)], [0], [0], [0], [0], [1], [0], [yes],
  [$b_2$ ($u x$)], [0], [0], [0], [1], [0], [0], [no],
  [$b_3$ ($v x$)], [0], [0], [1], [0], [0], [0], [yes],
  [$b_4$ ($w x$)], [0], [1], [0], [0], [0], [0], [yes],
  [$a_u$], [1], [0], [0], [1], [1], [1], [yes],
  [$a_v$], [1], [0], [1], [0], [0], [1], [no],
  [$a_w$], [1], [1], [0], [0], [1], [0], [no],
  [$a_x$], [1], [1], [1], [1], [0], [0], [yes],
  [$T$], [2], [2], [2], [2], [2], [2], [],
))

The chosen integers sum to $T$ digit by digit. For example, digit $2$ (edge $u x$)
gets its $2$ from $a_u$ and $a_x$, so $b_2$ is left out, while digit $0$ (edge $u v$)
gets one $1$ from $a_u$ and the other from $b_0$.

=== Running time
The set $X$ has $|V| + |E|$ integers, and each one has $|E| + 1$ base-$4$ digits, that
is, $O(|E|)$ bits. The target also has $O(|E| + log k) = O(|E| + log |V|)$ bits.
Writing all of them down takes $O((|V| + |E|) dot |E|)$ time, which is polynomial. The
integers themselves are exponentially large, but the time to write them is
proportional to their number of digits.

=== A vertex cover gives a subset
Suppose that $G$ has a vertex cover $C$ of size $k$. Let $S$ contain $a_v$ for every
$v in C$, and $b_i$ for every edge $i$ that has exactly one endpoint in $C$. For each
edge $i = u v$, at least one endpoint is in $C$, since $C$ is a vertex cover. Either
both $a_u$ and $a_v$ are in $S$ and $b_i$ is not, or exactly one of them is in $S$
together with $b_i$. In both cases the integers of $S$ contribute exactly $2$ to digit
$i$. Exactly $k$ integers of $S$ have a $1$ in digit $|E|$, so that digit is $k$. No
digit below $|E|$ exceeds $3$, so there are no carries, and the sum of $S$ is $T$.

=== A subset gives a vertex cover
Suppose that some $S subset.eq X$ sums to $T$. This direction is where base $4$ is
needed. For each $i < |E|$, only three integers of $X$ have a nonzero digit $i$, and each of them
has a $1$ there. So even if $S$ contained all three, digit $i$ of the sum would be at
most $3 < 4$, and adding the integers of $S$ never produces a carry out of digit $i$.
In base $2$, three $1$s would produce a carry and the digits would no longer be
counts. Because there are no carries, every digit of the sum of $S$ counts exactly the
integers of $S$ that have a $1$ in that digit, and we can compare the sum with $T$
digit by digit.
- Digit $i$ of $T$ is $2$, for each edge $i = u v$. Only $a_u$, $a_v$, and $b_i$
  contribute to that digit, so $S$ contains at least one of $a_u$ and $a_v$.
- Digit $|E|$ of $T$ is $k$, and every $a_v$ contributes $1$ there, so $S$ contains
  exactly $k$ of the vertex integers.

Let $C = {v : a_v in S}$. Then $|C| = k$ and every edge has an endpoint in $C$, so $C$
is a vertex cover of size $k$.

=== Weak and strong NP-hardness
Subset sum has an algorithm that runs in $O(n T)$ time, where $n = |X|$, as described
in the notes on backtracking and dynamic programming and in Erickson's textbook. This
does not show that P = NP. The input writes $T$ with only $O(log T)$ bits, so a running
time of $O(n T)$ is exponential in the size of the input. The reduction above produces
a target $T$ larger than $4^(|E|)$, so running the $O(n T)$ algorithm on its output
takes time exponential in the size of the original vertex cover instance.

An algorithm is *pseudo-polynomial* if its running time is polynomial in the number of
objects in the input and in the magnitudes of the numbers in the input. The $O(n T)$
algorithm for subset sum is pseudo-polynomial. A problem is *weakly NP-hard* if its
NP-hardness proofs need exponentially large numbers, as the reduction above does. A
weakly NP-hard problem can have a pseudo-polynomial algorithm without any consequence
for P versus NP. A problem is *strongly NP-hard* if it remains NP-hard even when the
numbers in the input are not exponentially large, that is, if an NP-hardness proof
exists that does not rely on exponentially large numbers.

#trap[A running time such as $O(n T)$ looks polynomial, but input size is measured in
bits. An integer $T$ occupies about $log_2 T$ bits, so $T$ itself can be exponential in
the input size.]

== Choosing a Problem to Reduce From
An NP-hardness proof starts with the choice of a known NP-hard problem to reduce from.
Choosing a problem for which a reduction can reasonably be found already earns credit
under the course rubric, because choosing well takes practice.
The lecture notes on the course website contain a long list of NP-hard problems, some
of them proved hard in lecture and some not. A list of known NP-hard problems is also
provided with the homework and with the final exam, and any problem on it may be used
as the starting point of a reduction.

Certain features of the target problem suggest a starting problem.

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*If the new problem involves*], [*Try reducing from*]),
  [making many yes/no decisions], [3SAT, which sets each variable to true or false],
  [finding a large subset of objects], [independent set or clique],
  [finding a small subset of objects], [vertex cover (set cover also fits, but vertex cover is simpler)],
  [partitioning objects into a few groups], [3-coloring, which assigns one of three colors to each vertex],
))

The reduction must handle every instance of the problem we reduce from, however
unusual. The instance it produces, on the other hand, can be as special as we like,
because we choose how to build it. This asymmetry gives two pieces of advice.
- Reduce from the simplest problem that works, so that an arbitrary instance has as
  little going on as possible. For example, 3SAT is always a better choice than
  general SAT, because every clause has exactly three literals.
- Feel free to make the constructed instance highly structured. The graph $H$ in the
  Hamiltonian cycle reduction is complicated, but it has a rigid structure, and we
  never had to reason about arbitrary directed graphs.

#keyidea[A reduction from problem $A$ to problem $B$ transforms an arbitrary instance
of $A$ into a special instance of $B$. Choose $A$ as simple and as similar to $B$ as
possible, and then design the instance of $B$ freely.]
]

#show: notes
#set heading(numbering: "1.1")
#body
