#import "setup.typ": *

#let body = [
= Lecture 19 (Oct 29) - Negative Weights, DAG SSSP, Dynamic Programming on DAGs, Layered Bellman-Ford

Lecture 18 handled shortest paths with positive weights. In this lecture the weights may
be negative. We first make cycles a non-issue by working on DAGs, where a topological
order gives shortest paths in linear time. We then use graph layering to turn any graph
without negative cycles into a DAG. The result is an $O(|V| |E|)$ algorithm that can
also detect negative cycles.

== Recap: Ford's Framework and Dijkstra
Every vertex stores two values:
- $v.text("dist")$ is the length of some walk from $s$ to $v$ (or $infinity$). It
  overestimates $text("dist")(s, v)$ until the algorithm is done.
- $v.text("pred")$ is the vertex before $v$ on that walk.

An edge $u -> v$ is *tense* if $u.text("dist") + w(u -> v) < v.text("dist")$, that is,
if the walk to $u$ followed by one more edge beats the best known walk to $v$.
*Relaxing* the edge sets $v.text("dist") <- u.text("dist") + w(u -> v)$ and
$v.text("pred") <- u$. FordSSSP initializes the values ($s.text("dist") = 0$,
everything else $infinity$) and then relaxes tense edges until none are left.

Dijkstra's algorithm is one way to run FordSSSP:
- An edge $u -> v$ can become tense only when $u.text("dist")$ drops, since lowering
  $v.text("dist")$ only helps $v$. So when $u.text("dist")$ drops, the algorithm puts
  $u$ in a data structure in order to recheck its outgoing edges later.
- That data structure is a priority queue keyed by dist. The algorithm inserts $v$
  with key $v.text("dist")$, or calls DecreaseKey if $v$ is already in the queue.
- With positive weights, vertices come out in increasing order of dist, so no vertex
  is ever reinserted. The total running time is $O(|E| log |V|)$.

== Unit Weights: Breadth-First Search
If every edge has weight $1$, we can use BFS, which is whatever-first search with an
ordinary queue. Written in Ford's style, BFS is Dijkstra's algorithm with the $+1$
hard-coded and with Push/Pull in place of Insert/ExtractMin:

```
BFS(s):
  InitSSSP(s)
  Push(s)
  while the queue is not empty
    u ← Pull()
    for each edge u → v
      if v.dist > u.dist + 1       ⟨⟨u → v is tense⟩⟩
        v.dist ← u.dist + 1
        v.pred ← u
        Push(v)
```

The queue is always sorted by dist, and a newly pushed vertex does belong at the back.
So BFS examines the vertices in the same order as Dijkstra's algorithm, without a
priority queue, in $O(|V| + |E|)$ time. A detailed proof appears on the course website
and in Erickson's book.

== Negative Weights: Walks vs. Paths
The shortest-path problem itself does not require positive weights. With negative
weights, however, FordSSSP is really looking for shortest walks, which may repeat
vertices.

- Finding shortest simple paths with negative weights is NP-hard, so there is probably
  no polynomial-time algorithm. We therefore look for shortest walks and hope that they
  are paths.
- With positive weights, shortest walks are paths. If a walk visits a vertex twice, we
  can cut out the cycle between the two visits. That cycle has positive weight, so the
  walk gets strictly shorter.
- A negative cycle rules out shortest walks. If $s$ can reach a cycle of negative total
  weight, a walk can go to the cycle and around it again and again. Every lap makes the
  walk shorter, so there is no shortest walk to any vertex on (or after) the cycle.
- Without negative cycles, shortest walks can be paths. Cutting a cycle out of a walk
  does not make it longer, so a shortest walk exists, and some shortest walk is a
  simple path. If every cycle is positive, every shortest walk is a path.

#keyidea[Amended claim: if $G$ has no negative cycle reachable from $s$, then FordSSSP
terminates, and at that point $v.text("dist") = text("dist")(s, v)$ for every vertex
$v$ and the pred edges form a shortest-path tree. The claim says nothing about running
time, since the algorithm may relax the same edge exponentially many times. The
positive-weight version from Lecture 18 is a special case.]

=== Dijkstra with negative edges
Dijkstra's algorithm, as written in Lecture 18, is still an implementation of FordSSSP
even with negative edges. It rechecks every edge that could have become tense, because
it may put a vertex back into the priority queue. Two consequences follow:
- If there is no negative cycle, Dijkstra's algorithm is still correct, because only
  the running-time analysis used positive weights. With many negative edges, however,
  it can be very slow.
- With few negative edges, it is still a good choice. Lab 10A had a graph with exactly
  one negative edge $u -> v$. Most solutions ran shortest paths from $s$ and from $v$
  and combined them. Plain Dijkstra also works, because each vertex re-enters the queue
  at most about once, so the running time is still $O(|E| log |V|)$.

#trap[The textbook version of Dijkstra's algorithm is different. Many presentations
load every vertex into the priority queue at the start and never reinsert. That
version always runs in $O(|E| log |V|)$ time, but it can be wrong with even one
negative edge. Dijkstra's algorithm stays correct with negative weights only if it
allows reinsertion.]

*Example (not from lecture):* Consider the edges $s -> a$ ($2$), $s -> b$ ($3$),
$b -> a$ ($-2$), and $a -> t$ ($1$). The true distance is
$text("dist")(s, t) = 3 - 2 + 1 = 2$.
- Without reinsertion, the algorithm extracts $s$ ($a = 2$, $b = 3$), then extracts
  $a$ ($t = 3$), then extracts $b$, which lowers $a$ to $1$ after $a$ is already done.
  So $t$ stays at $3$, which is wrong.
- With reinsertion, when $b$ lowers $a$ to $1$, $a$ goes back into the queue. Pulling
  $a$ again relaxes $a -> t$, so $t = 2$, which is correct.

== Shortest Paths in a DAG
To get rid of negative cycles completely, we first assume that the graph has no cycles
at all. Then shortest walks exist and are paths, and a topological order tells us what
to compute first.

Recall from Lectures 17 and 18 that a recursive algorithm finishes if and only if its
dependency graph is a DAG, and that in this case a topological order (in which every
edge $u -> v$ has $u$ before $v$) can be found in $O(|V| + |E|)$ time.

=== The recurrence
Let $text("distance")(v)$ be the true distance from $s$ to $v$; we reserve the word
"dist" for Ford's variables. A shortest path from $s$ to $v != s$ has some last edge
$u -> v$, and the part before it is a shortest path to $u$. We do not know which edge
is last, so we try them all:

$ text("distance")(v) = cases(
  0 & "if" v = s,
  display(min_(u -> v)) (text("distance")(u) + w(u -> v)) & "otherwise",
) $

A minimum over no edges is $infinity$, which means that $v$ is unreachable.

Computing $text("distance")(v)$ requires $text("distance")(u)$ for every edge
$u -> v$, so the dependency graph has an edge $v -> u$. The dependency graph is
therefore the reversal of $G$, and it is a DAG whenever $G$ is. For the evaluation
order, we must solve $text("distance")(u)$ before $text("distance")(v)$ for every edge
$u -> v$, which is exactly a topological order of $G$.

```
DagSSSP(s):
  for each vertex v in topological order
    if v = s
      distance(v) ← 0
    else
      distance(v) ← ∞
      for each edge u → v
        if distance(v) > distance(u) + w(u → v)
          distance(v) ← distance(u) + w(u → v)
```

On homework it is acceptable to write "for each vertex $v$ in topological order"; the
reader understands that the order is computed first, in linear time.

Here is the same algorithm in Ford's framework, which also sets the pred pointers:

```
DagSSSP(s):
  InitSSSP(s)
  for each vertex v in topological order
    for each edge u → v
      if u → v is tense
        Relax(u → v)
```

=== Running time
- Computing the topological order takes $O(|V| + |E|)$ time.
- There are $|V|$ subproblems, but their costs differ: the subproblem for $v$ costs
  $O(1 + text("indeg")(v))$. Each edge $u -> v$ appears in exactly one subproblem,
  namely that of $v$, so the total is $O(|V| + |E|)$.

$ #box(stroke: black, inset: 3pt, [$O(|V| + |E|)$]) "for any weights, negative included" $

#trap[Why is the bound not $O(|V| dot |E|)$? Multiplying the time per subproblem by
the number of subproblems gives a valid but loose bound here. One subproblem can have
up to $|V|$ incoming edges, but the incoming edges of all vertices add up to $|E|$.
This is the same argument we used for DFS examining outgoing edges.]

*Example:* The edges point from left to right, so $s, a, b, c, t$ is a topological
order. Note the negative edge $c -> t$.

#let dag-pos = (s: (0, 0.6), a: (1.4, 0), b: (2.8, 1.2), c: (4.2, 0), t: (5.6, 0.6))
#let dag-w = (("s", "a", $3$), ("s", "b", $10$), ("a", "b", $5$), ("a", "c", $12$), ("b", "c", $5$), ("b", "t", $9$), ("c", "t", $-4$))
#let dag-get(e) = dag-w.find(((u, v, _)) => (u, v) == e).at(2)
#align(center, graph-pic(
  dag-pos,
  dag-w.map(((u, v, _)) => (u, v)),
  directed: true,
  bold: (("s", "a"), ("a", "b"), ("b", "c"), ("c", "t")),
  weight: dag-get,
  unit: 48pt,
))

#align(center, table(
  columns: 3,
  inset: (x: 9pt, y: 4pt),
  stroke: 0.5pt,
  align: (center, left, center),
  table.header([*Vertex*], [*Incoming edges tried*], [*distance*]),
  [$s$], [source], [$0$],
  [$a$], [$s$: $0 + 3$], [$3$],
  [$b$], [$s$: $0 + 10$; $a$: $3 + 5 = 8$], [$8$],
  [$c$], [$a$: $3 + 12 = 15$; $b$: $8 + 5 = 13$], [$13$],
  [$t$], [$b$: $8 + 9 = 17$; $c$: $13 - 4 = 9$], [$9$],
))
#align(center, text(size: 0.85em)[Each row reads only the rows above it. The bold
edges form the shortest-path tree.])

== Dynamic Programming on DAGs: Which Order?
DagSSSP is dynamic programming in which the subproblems are the vertices of a DAG and
each one depends on its incoming edges. In other problems, each subproblem depends on
its outgoing edges instead.

*Example:* longest paths to a target $t$ in a DAG. Longest paths are NP-hard in
general graphs but easy in a DAG, and Lab 9B allowed this computation as a subroutine.
Let $text("longest")(u)$ be the length of the longest path from $u$ to $t$. In a DAG, a
path that leaves $t$ can never come back, so

$ text("longest")(u) = cases(
  0 & "if" u = t,
  display(max_(u -> v)) (w(u -> v) + text("longest")(v)) & "otherwise",
) $

A maximum over no edges is $-infinity$, which means that $t$ is unreachable from $u$.
Now $u$ depends on its outgoing edges, so for every edge $u -> v$ we must solve $v$
before $u$. Any reversed topological order works. Since a topological order is a
reversed postorder, reversing it again gives simply a postorder:

```
DagLongest(t):
  for each vertex u in postorder
    if u = t
      longest(u) ← 0
    else
      longest(u) ← −∞
      for each edge u → v
        if longest(u) < w(u → v) + longest(v)
          longest(u) ← w(u → v) + longest(v)
```

Writing "for each vertex in postorder" is likewise acceptable; the reader understands
that DFSAll runs first. Each vertex and each edge is still examined once, so the
running time is $O(|V| + |E|)$.

#keyidea[For dynamic programming over the vertices of a DAG:
- If each subproblem depends on its incoming edges, as in DagSSSP, solve the
  subproblems in topological order.
- If each subproblem depends on its outgoing edges, as in DagLongest, solve them in
  postorder.]

=== The general picture: memoization is postorder
For any recursive algorithm, an edge $u -> v$ in the dependency graph means "solve $v$
first." So a correct memoization order is a *postorder of the dependency graph*. Every
dynamic programming algorithm in the preceding lectures has used such an order:
- For edit distance, nested for loops happen to give a convenient postorder of the
  dependency graph, so no DFS is needed.
- Memoized Fibonacci is literally a DFS of the dependency graph that returns results
  in postorder.

When designing a dynamic programming algorithm, it can help to picture the dependency
graph, going down into it and bringing the answers back up.

== Summary So Far
#align(center, table(
  columns: 3,
  inset: (x: 9pt, y: 5pt),
  stroke: 0.5pt,
  align: (left, left, center),
  table.header([*Graph and weights*], [*Algorithm*], [*Time*]),
  [All weights $1$], [BFS], [$O(|V| + |E|)$],
  [All weights positive], [Dijkstra], [$O(|E| log |V|)$],
  [DAG, any weights], [DagSSSP], [$O(|V| + |E|)$],
  [Cycles and negative weights, no negative cycle], [Layered Bellman-Ford (below)], [$O(|V| |E|)$],
))

== Layered Bellman-Ford
We now consider a directed graph with negative weights and cycles, but no negative
cycle. The standard algorithm appears in Lecture 20. Here we build an algorithm from
tools we already have: graph layering (Lecture 17) and a reduction to DagSSSP.

Our goal is a new graph $G'$ with weights $w'$ that has no cycles. Without negative
cycles, some shortest walk is a simple path, and a simple path has at most $|V| - 1$
edges. We therefore build a graph that tracks how many edges a walk has used, for every
count from $0$ to $|V| - 1$.

=== The layered graph
$ V' = {(v, i) : v in V, space 0 <= i <= |V| - 1} $
$ E' = {(u, i - 1) -> (v, i) : u -> v in E, space 1 <= i <= |V| - 1} $
$ w'((u, i - 1) -> (v, i)) = w(u -> v) $

We can think of $G'$ as $|V|$ copies of the vertices, forming layers $0$ through
$|V| - 1$. Every edge moves a walk up one layer, so the layer number counts the edges
the walk has used.

- $G'$ is a DAG, because every edge increases the second component by $1$, and a cycle
  would have to come back down, which is impossible.
- Walks from $(s, 0)$ to $(v, i)$ in $G'$ correspond to walks from $s$ to $v$ in $G$
  with exactly $i$ edges, with the same weight. So
  $text("dist")_(G')((s, 0), (v, i))$ is the length of the shortest walk from $s$ to
  $v$ that uses exactly $i$ edges.
- To recover distances in $G$, note that a shortest path from $s$ to $v$ has some
  number of edges $i <= |V| - 1$, so we try them all:

$ text("dist")_G (s, v) = min_(0 <= i <= |V| - 1) text("dist")_(G')((s, 0), (v, i)) $

If no walk with exactly $i$ edges exists, DagSSSP gives $infinity$ for that layer, and
the minimum handles this case. If $v$ is unreachable, every layer is $infinity$.

```
LayeredBellmanFord(G, s):
  build G′ (layers 0 … |V| − 1)
  DagSSSP(G′, (s, 0))
  for each vertex v
    v.dist ← min over i of dist′((v, i))
```

*Example (not from lecture):* The graph $G$ below has a cycle $a -> b -> a$ of weight $-1 + 2 = 1$, which
is not negative. Here $|V| = 3$, so the layers are $0, 1, 2$.

#let lw = (("s", "a", $4$), ("s", "b", $1$), ("b", "a", $2$), ("a", "b", $-1$))
#let lw-get(u, v) = lw.find(((x, y, _)) => x == u and y == v).at(2)
#let g-pos = (s: (0, 0.6), a: (1.6, 0), b: (1.6, 1.2))
#let gl-pos = (
  s0: (0, 0), a0: (1.7, 0), b0: (3.4, 0),
  s1: (0, 1.4), a1: (1.7, 1.4), b1: (3.4, 1.4),
  s2: (0, 2.8), a2: (1.7, 2.8), b2: (3.4, 2.8),
)
// Layer i−1 → layer i copy of every edge; vertex keys are name + layer.
#let gl-edges = range(1, 3).map(i => lw.map(((u, v, _)) => (u + str(i - 1), v + str(i)))).flatten().chunks(2)
#let gl-w(e) = lw-get(e.at(0).first(), e.at(1).first())
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  align: horizon,
  stack(spacing: 6pt,
    graph-pic(g-pos, lw.map(((u, v, _)) => (u, v)), directed: true,
      weight: e => lw-get(..e), unit: 46pt),
    text(size: 0.85em)[$G$]),
  stack(spacing: 6pt,
    graph-pic(gl-pos, gl-edges, directed: true, weight: gl-w, unit: 40pt, r: 11pt,
      label: n => [$#n.first(), #n.last()$], size: 0.7em, marked: ("s0",)),
    text(size: 0.85em)[$G'$: layer $i$ is row $i$, top to bottom]),
))

#align(center, table(
  columns: 5,
  inset: (x: 9pt, y: 4pt),
  stroke: 0.5pt,
  align: center,
  table.header([*Vertex*], [*Layer 0*], [*Layer 1*], [*Layer 2*], [*$text("dist")_G (s, v)$ = min*]),
  [$s$], [$0$], [$infinity$], [$infinity$], [$0$],
  [$a$], [$infinity$], [$4$ ($s -> a$)], [$3$ ($s -> b -> a$)], [$3$],
  [$b$], [$infinity$], [$1$ ($s -> b$)], [$3$ ($s -> a -> b$)], [$1$],
))
#align(center, text(size: 0.85em)[Layer $i$ holds the shortest walk with exactly $i$
edges. The best layer differs from vertex to vertex.])

=== Running time
- $|V'| = |V| dot |V| = |V|^2$.
- $|E'| = |E| dot (|V| - 1) = O(|V| |E|)$, because each edge is copied once per layer
  step.
- DagSSSP runs in time linear in the size of $G'$, which is $O(|V|^2 + |V| |E|)$.
  Taking the minima costs another $O(|V|^2)$.

If $G$ is connected, meaning that every vertex is reachable from $s$, then
$|E| >= |V| - 1$, and the running time simplifies to

$ #box(stroke: black, inset: 3pt, [$O(|V| |E|)$]) $

=== Detecting negative cycles
Even with negative cycles, the layered values are exact. Layering counts edges
carefully, so $text("dist")_(G')((s, 0), (v, i))$ is the shortest walk with exactly
$i$ edges even if $G$ has negative cycles. Only the last step breaks, because the
shortest walk may need more than $|V| - 1$ edges, or may not exist at all.

So, after running the algorithm, we store the minima in the $v.text("dist")$ variables
and check every edge for tension:
- If no edge is tense, then no negative cycle is reachable from $s$, and the values are
  the true distances.
- If some edge is tense, then there is a negative cycle reachable from $s$.

To see why, first suppose that no negative cycle is reachable. Then the values are the
true distances, and true distances leave no edge tense, since otherwise relaxing that
edge would beat a shortest path. Now suppose that a negative cycle $C$ is reachable.
Every vertex on $C$ has a finite value. If no edge of $C$ were tense, then
$v.text("dist") <= u.text("dist") + w(u -> v)$ for every edge $u -> v$ of $C$. Adding
these inequalities around $C$, every vertex's dist appears once on each side, so the
dist terms cancel, leaving $0 <= w(C)$. That contradicts $w(C) < 0$, so some edge on
$C$ is tense.

The check is one extra loop over the edges, costing $O(|E|)$ time, so the total stays
$O(|V| |E|)$.

#keyidea[On homework and labs, this algorithm may be called "Bellman-Ford." It
computes shortest paths when there is no negative cycle, and it detects a reachable
negative cycle, in $O(|V| |E|)$ time. The standard presentation of Bellman-Ford comes
in Lecture 20, because it fits the next topic.]
]

#show: notes
#set heading(numbering: "1.1")
#body
