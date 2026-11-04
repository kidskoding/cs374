#import "setup.typ": *

#let body = [
= Lecture 19 (Oct 29) - Negative Weights, DAG SSSP, Dynamic Programming on DAGs, Layered Bellman-Ford

Tuesday handled shortest paths with *positive* weights. Today the weights can be
*negative*. First we make cycles a non-issue by working on DAGs, where a topological
order gives shortest paths in linear time. Then we use graph layering to turn any graph
without negative cycles into a DAG. That gives an $O(|V| |E|)$ algorithm that can also
detect negative cycles.

== Recap: Ford's Framework and Dijkstra
Every vertex stores two values:
- $v.text("dist")$: the length of *some* walk from $s$ to $v$ (or $infinity$). It
  overestimates $text("dist")(s, v)$ until the algorithm is done.
- $v.text("pred")$: the vertex before $v$ on that walk.

An edge $u -> v$ is *tense* if $u.text("dist") + w(u -> v) < v.text("dist")$: the
walk to $u$ plus one more edge beats the best known walk to $v$. *Relaxing* it sets
$v.text("dist") <- u.text("dist") + w(u -> v)$ and $v.text("pred") <- u$.
FordSSSP initializes ($s.text("dist") = 0$, everything else $infinity$), then relaxes
tense edges until none are left.

*Dijkstra* is one way to run FordSSSP:
- An edge $u -> v$ can only become tense when $u.text("dist")$ drops. Lowering
  $v.text("dist")$ only helps $v$. So when $u.text("dist")$ drops, put $u$ in a data
  structure to recheck its outgoing edges later.
- That data structure is a priority queue keyed by dist: Insert $v$ with key
  $v.text("dist")$, or DecreaseKey if $v$ is already there.
- With positive weights, vertices come out in increasing order of dist, so none is
  ever reinserted. Total: $O(|E| log |V|)$.

== Unit Weights: Breadth-First Search
If every edge has weight $1$, use *BFS*. It is whatever-first search with a plain
queue. Written in Ford's style, it is Dijkstra with the $+1$ hard-coded and Push/Pull
instead of Insert/ExtractMin:

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

The queue is always sorted by dist, and a newly pushed vertex really does belong at the
back. So BFS looks at vertices in the same order Dijkstra would, without a priority
queue: $O(|V| + |E|)$. (A detailed proof is on the course website and in Erickson's
book.)

== Negative Weights: Walks vs. Paths
Nothing about the shortest-path problem requires positive weights. But with negative
weights, FordSSSP is really looking for *shortest walks*, which may repeat vertices.

- *Shortest simple paths with negative weights are NP-hard.* There is probably no
  polynomial-time algorithm. So we look for shortest walks and hope they are paths.
- *Positive weights: shortest walks are paths.* If a walk visits a vertex twice, cut
  out the cycle between the two visits. That cycle has positive weight, so the walk
  gets strictly shorter.
- *Negative cycle: no shortest walk.* If $s$ can reach a cycle of negative total
  weight, walk to it and go around again and again. Every lap is shorter, so there is
  no shortest walk to any vertex on (or after) the cycle.
- *No negative cycle: shortest walks can be paths.* Cutting a cycle out of a walk
  makes it no longer. So a shortest walk exists, and some shortest walk is a simple
  path. If every cycle is positive, *every* shortest walk is a path.

#keyidea[*Amended claim:* If $G$ has *no negative cycle* (reachable from $s$),
FordSSSP terminates, and then every $v.text("dist") = text("dist")(s, v)$ and the pred
edges form a shortest-path tree. This says *nothing* about running time: it may relax
the same edge exponentially many times. "Positive weights" (Tuesday's version) was a
special case.]

=== Dijkstra with negative edges
Dijkstra, *as written on Tuesday*, is still an implementation of FordSSSP even with
negative edges. It rechecks every edge that could have become tense, because it may put
a vertex back into the priority queue. So:
- *No negative cycle:* Dijkstra is still *correct*. Only the running-time analysis
  used positive weights. With many negative edges it can be very slow.
- *Few negative edges:* still a good choice. Yesterday's lab had a graph with exactly
  one negative edge $u -> v$. Most solutions ran shortest paths from $s$ and from $v$
  and combined them. Plain Dijkstra also works: each vertex re-enters the queue at
  most about once, so it is still $O(|E| log |V|)$.

#trap[*The textbook Dijkstra is different.* Many presentations load *every* vertex
into the priority queue up front and never reinsert. That version always runs in
$O(|E| log |V|)$, but it can be *wrong with even one negative edge*. You must allow
reinsertion for Dijkstra to stay correct with negative weights.]

*Example (not from lecture):* Edges $s -> a$ ($2$), $s -> b$ ($3$), $b -> a$ ($-2$),
$a -> t$ ($1$). The true $text("dist")(s, t) = 3 - 2 + 1 = 2$.
- *No reinsertion:* extract $s$ ($a = 2$, $b = 3$), extract $a$ ($t = 3$), extract
  $b$ (lowers $a$ to $1$, but $a$ is done). $t$ stays at $3$. Wrong.
- *With reinsertion:* when $b$ lowers $a$ to $1$, $a$ goes back in the queue. Pulling
  $a$ again relaxes $a -> t$, so $t = 2$. Correct.

== Shortest Paths in a DAG
To get rid of negative cycles completely, first assume the graph has *no cycles at
all*. Then shortest walks exist and are paths, and a topological order tells us what
to compute first.

Recall (Lectures 17–18): a recursive algorithm finishes if and only if its dependency
graph is a DAG, and then a topological order (every edge $u -> v$ has $u$ before $v$)
can be found in $O(|V| + |E|)$ time.

=== The recurrence
Let $text("distance")(v)$ be the true distance from $s$ to $v$. (The word "dist" is
saved for Ford's variables.) A shortest path from $s$ to $v != s$ has some *last edge*
$u -> v$, and the part before it is a shortest path to $u$. We don't know which edge is
last, so try them all:

$ text("distance")(v) = cases(
  0 & "if" v = s,
  display(min_(u -> v)) (text("distance")(u) + w(u -> v)) & "otherwise",
) $

A minimum over no edges is $infinity$: $v$ is unreachable.

*Dependency graph:* $text("distance")(v)$ needs $text("distance")(u)$ for every edge
$u -> v$, so the dependency graph has an edge $v -> u$. It is the *reversal of $G$*,
so it is a DAG whenever $G$ is. *Evaluation order:* solve $text("distance")(u)$ before
$text("distance")(v)$ for every edge $u -> v$. That is exactly a *topological order*
of $G$.

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

Writing "for each vertex $v$ in topological order" is fine on homework. It is
understood that you compute the order first, in linear time.

The same algorithm in Ford's framework, which also sets the pred pointers:

```
DagSSSP(s):
  InitSSSP(s)
  for each vertex v in topological order
    for each edge u → v
      if u → v is tense
        Relax(u → v)
```

=== Running time
- Topological order: $O(|V| + |E|)$.
- $|V|$ subproblems, but they cost different amounts: $v$'s costs
  $O(1 + text("indeg")(v))$. Each edge $u -> v$ appears in exactly one subproblem
  ($v$'s), so the total is $O(|V| + |E|)$.

$ #box(stroke: black, inset: 3pt, [$O(|V| + |E|)$]) "for any weights, negative included" $

#trap[*Why not $O(|V| dot |E|)$?* "Time per subproblem times number of subproblems"
gives a valid but loose bound here: one subproblem can have up to $|V|$ incoming
edges, but the incoming edges of *all* vertices add up to $|E|$. Same argument as for
DFS looking at outgoing edges.]

*Example:* The edges point left to right, so $s, a, b, c, t$ is a topological order.
Note the negative edge $c -> t$:

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
#align(center, text(size: 0.85em)[Each row only reads rows above it. Bold edges: the
shortest-path tree.])

== Dynamic Programming on DAGs: Which Order?
DagSSSP is dynamic programming where the subproblems are the vertices of a DAG and
each one depends on its *incoming* edges. Other problems depend on *outgoing* edges
instead.

*Example: longest paths to a target $t$ in a DAG.* (Longest paths are NP-hard in
general graphs, but easy in a DAG. Last Friday's lab allowed this as a subroutine.)
Let $text("longest")(u)$ be the length of the longest path from $u$ to $t$. In a DAG,
once you leave $t$ you can't come back, so:

$ text("longest")(u) = cases(
  0 & "if" u = t,
  display(max_(u -> v)) (w(u -> v) + text("longest")(v)) & "otherwise",
) $

(A maximum over no edges is $-infinity$: $t$ is unreachable from $u$.) Now $u$
depends on its *outgoing* edges, so for every edge $u -> v$ we must solve $v$ *before*
$u$. Any reversed topological order works. A topological order is a reversed
postorder, so reversing it again gives just a *postorder*:

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

"For each vertex in postorder" is fine to write: it is understood that you run DFSAll
first. Each vertex and each edge is still looked at once: $O(|V| + |E|)$.

#keyidea[*Dynamic programming over the vertices of a DAG:*
- Depends on *incoming* edges (like DagSSSP) → solve in *topological order*.
- Depends on *outgoing* edges (like DagLongest) → solve in *postorder*.]

=== The general picture: memoization is postorder
For *any* recursive algorithm, an edge $u -> v$ in the dependency graph means "solve
$v$ first". So a correct memoization order is a *postorder of the dependency graph*.
That's what we've been doing for two weeks:
- *Edit distance:* nested for loops happen to give a nice postorder of its dependency
  graph, so no DFS is needed.
- *Memoized Fibonacci:* literally a DFS of the dependency graph that returns results
  in postorder.

When designing a dynamic programming algorithm, it can help to picture the
dependency graph: go down into it, and bring the answers back up.

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
Now: a directed graph with negative weights *and* cycles, but no negative cycle. The
standard algorithm comes next Tuesday. Today we build one from tools we already have:
*graph layering* (last week) plus a *reduction to DagSSSP*.

The goal is a new graph $G'$ with weights $w'$ that has *no cycles*. The key fact:
with no negative cycle, some shortest walk is a simple path, and a simple path has *at
most $|V| - 1$ edges*. So build a graph that tracks how many edges a walk has used,
for every count from $0$ to $|V| - 1$.

=== The layered graph
$ V' = {(v, i) : v in V, space 0 <= i <= |V| - 1} $
$ E' = {(u, i - 1) -> (v, i) : u -> v in E, space 1 <= i <= |V| - 1} $
$ w'((u, i - 1) -> (v, i)) = w(u -> v) $

Think of $|V|$ copies of the vertices, layers $0$ through $|V| - 1$. Every edge you
take moves you *up one layer*, so the layer number counts the edges you have used.

- *$G'$ is a DAG:* every edge increases the second component by $1$. A cycle would
  have to come back down, which is impossible.
- *Walks with exactly $i$ edges:* walks from $(s, 0)$ to $(v, i)$ in $G'$ match walks
  from $s$ to $v$ in $G$ with *exactly $i$ edges*, with the same weight. So
  $text("dist")_(G')((s, 0), (v, i))$ is the length of the shortest walk from $s$ to
  $v$ that uses exactly $i$ edges.
- *Distances in $G$:* a shortest path from $s$ to $v$ has some number of edges
  $i <= |V| - 1$, so try them all:

$ text("dist")_G (s, v) = min_(0 <= i <= |V| - 1) text("dist")_(G')((s, 0), (v, i)) $

If no walk with exactly $i$ edges exists, DagSSSP gives $infinity$ for that layer, and
the minimum handles it. If $v$ is unreachable, every layer is $infinity$.

```
LayeredBellmanFord(G, s):
  build G′ (layers 0 … |V| − 1)
  DagSSSP(G′, (s, 0))
  for each vertex v
    v.dist ← min over i of dist′((v, i))
```

*Example:* $G$ has a cycle $a -> b -> a$ of weight $-1 + 2 = 1$, which isn't
negative. Here $|V| = 3$, so the layers are $0, 1, 2$:

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
edges. The best layer differs by vertex.])

=== Running time
- $|V'| = |V| dot |V| = |V|^2$.
- $|E'| = |E| dot (|V| - 1) = O(|V| |E|)$: each edge is copied once per layer step.
- DagSSSP is linear in the size of $G'$: $O(|V|^2 + |V| |E|)$. Taking the minima
  costs $O(|V|^2)$ more.

If $G$ is connected (every vertex reachable from $s$), then $|E| >= |V| - 1$, and
this simplifies to

$ #box(stroke: black, inset: 3pt, [$O(|V| |E|)$]) $

=== Detecting negative cycles
*With negative cycles, the layered values are still exact.* Layering counts edges
carefully, so $text("dist")_(G')((s, 0), (v, i))$ is the shortest walk with exactly
$i$ edges *even if $G$ has negative cycles*. Only the last step breaks: the shortest
walk may need more than $|V| - 1$ edges, or may not exist at all.

So, after running it, store the minima in the $v.text("dist")$ variables and *check
every edge for tension*:
- *No edge tense:* no negative cycle is reachable from $s$, and the values are the
  true distances.
- *Some edge tense:* there is a negative cycle reachable from $s$.

*Why:* If no negative cycle is reachable, the values are the true distances, and true
distances leave no edge tense (else relaxing it would beat a shortest path). If a
negative cycle $C$ is reachable, every vertex on it has a finite value. Suppose no
edge of $C$ is tense: then $v.text("dist") <= u.text("dist") + w(u -> v)$ for every
edge $u -> v$ of $C$. Add these up around $C$. Every vertex's dist appears once on
each side, so they cancel, leaving $0 <= w(C)$. That contradicts $w(C) < 0$. So some
edge on $C$ is tense.

The check is one extra loop over the edges, $O(|E|)$, so the total stays
$O(|V| |E|)$.

#keyidea[*For homework and labs, call this "Bellman-Ford"*: it computes shortest paths
when there is no negative cycle, and detects a reachable negative cycle, in
$O(|V| |E|)$ time. The standard way to present Bellman-Ford comes next Tuesday,
because it fits the next topic.]
]

#show: notes
#set heading(numbering: "1.1")
#body
