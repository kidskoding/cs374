#import "setup.typ": *

// Layered copy of a directed graph: vertex (v, i) for each layer i < k, and an edge
// (u, i) -> (v, i + 1 mod k) for each edge u -> v. Keys are v + str(i).
#let layered(xs, edges, k: 3, gap: 1.15, shift: 0.35) = {
  let pos = (:)
  for (v, x) in xs {
    for i in range(k) { pos.insert(v + str(i), (x + i * shift, i * gap)) }
  }
  let es = edges.map(((u, v)) => range(k).map(i => (u + str(i), v + str(calc.rem(i + 1, k))))).sum()
  (pos, es)
}
#let layer-label(n) = $#n.at(0)_#n.at(1)$

// DFS active intervals on a timeline. Each row is (name, pre, post).
#let intervals(rows, n, unit: 24pt, row: 15pt) = {
  let lab = 18pt
  let height = row * (rows.len() + 1)
  align(center, box(width: lab + unit * (n + 1), height: height, {
    for (j, (name, pre, post)) in rows.enumerate() {
      let y = row * j
      place(dy: y, box(width: lab, height: row, align(horizon, $#name$)))
      place(dx: lab + pre * unit, dy: y + 3pt, rect(
        width: (post - pre) * unit,
        height: row - 6pt,
        radius: 2pt,
        fill: accent-light,
        stroke: 0.6pt + accent,
      ))
    }
    for t in range(1, n + 1) {
      place(dx: lab + t * unit - 5pt, dy: height - row + 2pt, box(width: 10pt, align(center, text(size: 0.7em, fill: luma(90))[#t])))
    }
  }))
}

#let body = [
= Lecture 17 (Oct 22) - Graph Layering, Whatever-First Search Variants, Depth-First Search

This lecture presents one more reduction to reachability, using a technique called
graph layering. We then consider what happens when the choice of bag in whatever-first
search matters, and we take a closer look at depth-first search.

== Graph Layering
=== The problem
We are given a directed graph $G = (V, E)$ and two vertices $s$ and $t$, and we want
to know whether there is a walk from $s$ to $t$ whose length is divisible by 3.

A *walk* follows the edge directions and may repeat vertices and edges, which a path
may not do.

#let g1 = (s: (0, 1), w: (1.3, 1), t: (2.6, 1), y: (2, 0), x: (0.6, 0))
#let g1-edges = (("s", "w"), ("w", "t"), ("w", "y"), ("y", "x"), ("x", "s"))
#let g2 = (s: (0, 1), z: (1.3, 1), t: (2.6, 1), w: (0.65, 0))
#let g2-edges = (("s", "z"), ("z", "t"), ("z", "w"), ("w", "s"))
#align(center, grid(
  columns: 2,
  column-gutter: 4em,
  align: center + bottom,
  graph-pic(g1, g1-edges, directed: true, unit: 44pt),
  graph-pic(g2, g2-edges, directed: true, unit: 44pt),
  [$G_1$: *yes*], [$G_2$: *no*],
))

- In $G_1$, the shortest path $s -> w -> t$ has length 2, but the walk
  $s -> w -> y -> x -> s -> w -> t$ has length 6. Every walk from $s$ to $t$ has length
  $2 + 4k$, and taking $k = 1$ works.
- In $G_2$, there are infinitely many walks from $s$ to $t$, such as $s -> z -> t$ and
  $s -> z -> w -> s -> z -> t$, but every one of them has length $2 + 3k$, which is
  never divisible by 3.

=== Don't modify the search, build a new graph
One could change the code of whatever-first search so that it also tracks lengths
mod 3. That approach can work, but it is risky: the modified code is easy to get wrong,
and we would have to prove that the modified search still finds every walk. Instead,
we reduce to plain reachability in a new graph $G'$ and run the search unchanged.

Imagine an ant walking on $G$. To answer the question, the ant needs to know only two
things: where it is, and how many steps it has taken, mod 3. We make each such pair a
vertex.

*1. Build a graph:* $G' = (V', E')$ with
$ V' &= V times {0, 1, 2} \
  E' &= {(u, i) -> (v, (i + 1) mod 3) mid(|) u -> v in E, #h(0.3em) i in {0, 1, 2}} $

Each edge of $G$ becomes three edges of $G'$, one from each layer to the next, and
following an edge always adds one step. The arrow notation keeps this definition
readable; an edge between pairs, written as a pair of nested pairs, quickly becomes
hard to read.

*2. Graph problem, and why it helps:*
$ G "has a walk from" s "to" t "of length divisible by 3" <==> (s, 0) "can reach" (t, 0) "in" G' $

*3. Algorithm:* We run whatever-first search in $G'$ from $(s, 0)$ and answer yes if
and only if the search marks $(t, 0)$.

*4. Running time:* Since $|V'| = 3|V|$ and $|E'| = 3|E|$, building $G'$ and searching
it takes $O(|V'| + |E'|) = #box(stroke: black, inset: 3pt, [$O(|V| + |E|)$])$ time,
which is as fast as possible.

*$G_2$, layered:* Layer $i$ holds the vertices $v_i$ (meaning "at $v$, after $i$
steps mod 3"). The search from $s_0$ marks the yellow vertices and follows the bold
edges. It never marks $t_0$, so the answer is no.

#let (g2-pos, g2-layered) = layered((s: 0, z: 1.2, w: 2.4, t: 3.6), g2-edges)
#align(center, graph-pic(
  g2-pos,
  g2-layered,
  directed: true,
  marked: ("s0", "z1", "t2", "w2"),
  bold: (("s0", "z1"), ("z1", "t2"), ("z1", "w2"), ("w2", "s0")),
  label: layer-label,
  unit: 46pt,
  r: 10pt,
  size: 0.85em,
))
#align(center, text(size: 0.85em)[Layers 0, 1, 2 appear from top to bottom. Every edge
goes down one layer, except edges out of layer 2, which wrap around to layer 0.])

For $G_1$, the walk of length 6 becomes the path
$s_0 -> w_1 -> y_2 -> x_0 -> s_1 -> w_2 -> t_0$ in $G'$.

#keyidea[*Graph layering:* When a graph problem (reachability, shortest paths) needs
to remember extra information, we make one copy of the graph for each value of that
information and wire the copies together so that the current layer records the
information. This is the same idea as the product construction for DFAs, in which the
new states are the old states $times$ the extra bits. Erickson has a separate note on
graph layering, linked from the course schedule.]

The new graph is an ordinary graph, so we can hand it to any black-box graph algorithm
(whatever-first search, Dijkstra's algorithm, ...), and the algorithm does not care
where the vertices came from.

== Whatever-First Search, Revisited
=== Parent pointers
We now put pairs into the bag instead of single vertices. A pair $(p, v)$ means that
we found $v$ and that the last step to $v$ came from $p$.

```
WhateverFirstSearch(s):
  put (∅, s) into the bag
  while the bag is not empty
    take (p, v) from the bag
    if v is unmarked
      mark v
      v.parent ← p
      for each edge v → w
        put (v, w) into the bag
```

Every marked vertex except $s$ gets exactly one *parent edge*
$v.text("parent") -> v$, and its parent was marked earlier. The parent edges therefore
form a tree rooted at $s$, which holds one path from $s$ to every vertex that $s$ can
reach. In an undirected graph, this tree is a *spanning tree* of the component of $s$:
a tree containing every vertex of that component.

=== The bag matters now
A different bag removes vertices in a different order, which yields a different tree
and a different running time $O(|V| + |E| dot T)$, where $T$ is the time per bag
operation.

#align(center, table(
  columns: (8.5em, 1fr, auto, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  align: left + horizon,
  table.header([*Bag*], [*Search, and the tree it builds*], [*$T$*], [*Total time*]),
  [Queue], [Breadth-first search. Finds every vertex 1 step from $s$, then 2 steps, and so on, and builds a *shortest-path tree*, counting edges (no weights).], [$O(1)$], [$O(|V| + |E|)$],
  [Priority queue: priority of $(u, v)$ is $text("dist")(u) + w(u -> v)$; weights $>= 0$], [*Best-first search*, which is Dijkstra's algorithm. Finds shortest paths with edge weights (proved in a later lecture).], [$O(log |E|)$], [$O(|V| + |E| log |V|)$],
  [Priority queue: priority of $u v$ is $w(u v)$; undirected], [Prim's algorithm. Builds a minimum spanning tree (not covered in this course).], [$O(log |E|)$], [$O(|V| + |E| log |V|)$],
  [Stack], [Depth-first search. Builds long, skinny trees; its uses appear below.], [$O(1)$], [$O(|V| + |E|)$],
))

Here $text("dist")(u)$ is the total weight of the tree path from $s$ to $u$. The
priority queue is a binary heap, which supports insert and extract-min in
$O(log |E|)$ time. A simple
graph has $|E| <= |V|^2$, so $log |E| <= 2 log |V|$, and $O(log |E|) = O(log |V|)$.

#keyidea[*BFS, DFS, Dijkstra and Prim are all whatever-first search:* They differ only
in the bag, which decides where the search goes next.]

Homework 8 allows Dijkstra's algorithm to be used as a black box.

== Depth-First Search
Breadth-first search, Dijkstra's algorithm and Prim's algorithm each solve an obvious
problem. Depth-first search has no comparable one-sentence motivation, so we start
with the algorithm and then look for problems it solves.

=== The recursive version
Whatever-first search with a stack is a depth-first search, but DFS is usually written
recursively: for each edge $v -> w$, the algorithm immediately explores everything out
of $w$. The recursive version makes one more change. It checks whether $w$ is marked
before the recursive call, instead of pushing $w$ and checking later.

```
DFS(v):                      ⟨⟨v is unmarked⟩⟩
  mark v
  for each edge v → w
    if w is unmarked
      w.parent ← v
      DFS(w)
```

Like any search, $text("DFS")(s)$ marks everything reachable from $s$, provided
nothing was marked beforehand. Which vertices those are depends heavily on $s$. On a
path, starting at the first vertex marks every vertex, while starting at the last
vertex marks only that vertex.

The uses of DFS concern the structure of the whole graph, so we call it repeatedly
until every vertex is marked:

```
DFSAll(G):
  for all vertices v
    unmark v
  for all vertices v
    if v is unmarked
      DFS(v)
```

Each vertex is marked once and its edges are explored once, so DFSAll runs in
$O(|V| + |E|)$ time.

=== Three facts about DFSAll
+ Every vertex gets marked: $text("DFS")(v)$ is called exactly once for every $v$, as
  the loop in DFSAll guarantees.
+ Before $text("DFS")(v)$ finishes, it marks every vertex reachable from $v$ through
  unmarked vertices. The search keeps going deeper and stops only at vertices that
  another call has already marked.
+ If $text("DFS")(v)$ calls $text("DFS")(w)$, directly or indirectly, there is a path
  from $v$ to $w$.

=== Clock: start and finish times
The applications depend on the order in which DFS starts and finishes each vertex.
To reason about this order, we add a clock, and each event gets the next clock value:

```
DFSAll(G):
  clock ← 0
  for all vertices v
    unmark v
  for all vertices v
    if v is unmarked
      clock ← DFS(v, clock)

DFS(v, clock):
  mark v
  clock ← clock + 1
  v.pre ← clock                ⟨⟨start time⟩⟩
  for each edge v → w
    if w is unmarked
      w.parent ← v
      clock ← DFS(w, clock)
  clock ← clock + 1
  v.post ← clock               ⟨⟨finish time⟩⟩
  return clock
```

The *active interval* of $v$ is $[v.text("pre"), v.text("post")]$, which lasts from
when $text("DFS")(v)$ goes onto the call stack until it comes off.

#keyidea[*Active intervals are either disjoint or nested:* This follows from how a
call stack works. If $text("DFS")(u)$ starts while $text("DFS")(v)$ is running, then
$text("DFS")(u)$ finishes first.]

*Example:* We run DFSAll on the following graph, taking vertices and edges in
alphabetical order. Bold edges are tree (parent) edges.

#let dfs-pos = (a: (0, 0), b: (1.4, 0), c: (1.4, 1.2), d: (0, 1.2), e: (0, 2.4), f: (1.4, 2.4))
#let dfs-edges = (("a", "b"), ("a", "d"), ("b", "c"), ("c", "a"), ("d", "c"), ("e", "d"), ("e", "f"))
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  align: horizon,
  graph-pic(dfs-pos, dfs-edges, directed: true, bold: (("a", "b"), ("b", "c"), ("a", "d"), ("e", "f")), unit: 48pt),
  intervals((("a", 1, 8), ("b", 2, 5), ("c", 3, 4), ("d", 6, 7), ("e", 9, 12), ("f", 10, 11)), 12),
))

The call $text("DFS")(a)$ finds $b$ and then $c$, whose edge to $a$ goes to a marked
vertex. It then backs up to $a$ and finds $d$, whose edge $d -> c$ also goes to a
marked vertex. Nothing marked so far reaches $e$, so DFSAll later calls
$text("DFS")(e)$, which finds $f$.

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Order*], [*Sort by*]),
  [Preorder: $a, b, c, d, e, f$], [start time $v.text("pre")$; rarely useful in this course],
  [Postorder: $c, b, d, a, f, e$], [finish time $v.text("post")$; very useful],
))

== Finding a Cycle
A *dependency graph* has the subproblems of a recursive algorithm as vertices, and an
edge $u -> v$ when $u$ calls $v$ directly (Fibonacci: $F_8 -> F_7$ and $F_8 -> F_6$).
A recursive algorithm terminates only if its dependency graph has no cycle: on a
cycle through $u$, solving $u$ needs the answer to $u$, which is still being computed.

The problem is to decide, given a directed graph $G$, whether $G$ has a cycle. A
directed graph with no cycle is a *directed acyclic graph* (DAG).

We run DFSAll. Suppose that during $text("DFS")(v)$ there is a call to
$text("DFS")(u)$, and that this call finds an edge $u -> v$ back to the still-active
vertex $v$. Such an edge is a *back edge*. By fact 3 there is a path $v ~> u$, and
together with the edge $u -> v$ it forms a cycle. In the example, $c -> a$ is a back
edge, which closes the cycle $a -> b -> c -> a$.

#keyidea[*One back edge proves a cycle:* Which edges are back edges depends on the
order in which DFSAll takes vertices and edges, but if DFSAll finds even one back
edge, the graph is not acyclic.]

Is the converse true (a cycle $=>$ DFS always finds a back edge)? Lecture 18 takes up
this question.
]

#show: notes
#set heading(numbering: "1.1")
#body
