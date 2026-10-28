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

Today: one more reduction to reachability, with a technique called *graph layering*.
Then what happens when the bag in whatever-first search matters, and a closer look at
*depth-first search*.

== Graph Layering
=== The problem
*Input:* a directed graph $G = (V, E)$ and two vertices $s$ and $t$. *Question:* is
there a *walk* from $s$ to $t$ whose length is divisible by 3?

A *walk* follows the edge directions, and may repeat vertices and edges. (A path may
not.)

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

- $G_1$: the shortest path $s -> w -> t$ has length 2. But the walk
  $s -> w -> y -> x -> s -> w -> t$ has length 6. Every walk from $s$ to $t$ has length
  $2 + 4k$, and $k = 1$ works.
- $G_2$: there are infinitely many walks from $s$ to $t$, such as $s -> z -> t$ and
  $s -> z -> w -> s -> z -> t$. But every one has length $2 + 3k$, which is never
  divisible by 3.

=== Don't modify the search, build a new graph
It's tempting to change the code of whatever-first search so it also tracks lengths
mod 3. That can work, but it's *dangerous*. It's easy to get wrong, and you would have
to prove that your modified search still finds every walk. Instead, *reduce to plain
reachability* in a new graph $G'$, and run the search unchanged.

Imagine an ant walking on $G$. To answer the question, it only needs to know two
things: *where it is*, and *how many steps it has taken, mod 3*. Make each pair a
vertex.

*1. Build a graph:* $G' = (V', E')$ with
$ V' &= V times {0, 1, 2} \
  E' &= {(u, i) -> (v, (i + 1) mod 3) mid(|) u -> v in E, #h(0.3em) i in {0, 1, 2}} $

Each edge of $G$ becomes 3 edges of $G'$, one *from each layer to the next*. Following
an edge always adds one step. The arrow notation keeps this readable: an edge between
pairs written with nested pairs gets ugly fast.

*2. Graph problem, and why it helps:*
$ G "has a walk from" s "to" t "of length divisible by 3" <==> (s, 0) "can reach" (t, 0) "in" G' $

*3. Algorithm:* Run whatever-first search in $G'$ from $(s, 0)$. Answer yes if and
only if it marks $(t, 0)$.

*4. Running time:* $|V'| = 3|V|$ and $|E'| = 3|E|$, so building $G'$ and searching it
takes $O(|V'| + |E'|) = #box(stroke: black, inset: 3pt, [$O(|V| + |E|)$])$. That's as
fast as possible.

*$G_2$, layered:* Layer $i$ holds the vertices $v_i$ (meaning "at $v$, after $i$
steps mod 3"). The search from $s_0$ marks the yellow vertices and follows the bold
edges. It never marks $t_0$, so the answer is no:

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
#align(center, text(size: 0.85em)[Layers 0, 1, 2 from top to bottom. Every edge goes
down one layer, except edges out of layer 2, which wrap around to layer 0.])

For $G_1$, the walk of length 6 becomes the path
$s_0 -> w_1 -> y_2 -> x_0 -> s_1 -> w_2 -> t_0$ in $G'$.

#keyidea[*Graph layering:* when a graph problem (reachability, shortest paths) needs
to remember *extra information*, make one copy of the graph per value of that
information, and wire the copies together so the layer you're in *is* the
information. Same idea as the product construction for DFAs: new states = old states
$times$ extra bits. Erickson has a separate note on graph layering, linked from the
course schedule.]

The new graph is an ordinary graph, so you can hand it to *any* black-box graph
algorithm (whatever-first search, Dijkstra's algorithm, ...). The algorithm doesn't
care where the vertices came from.

== Whatever-First Search, Revisited
=== Parent pointers
Put *pairs* into the bag instead of single vertices. A pair $(p, v)$ means "found $v$,
and the last step to it came from $p$":

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
$v.text("parent") -> v$, and its parent was marked earlier. So the parent edges form
a *tree rooted at $s$*: it holds one path from $s$ to every vertex $s$ can reach. In an
undirected graph, this is a *spanning tree* of $s$'s component: a tree containing every
vertex of it.

=== The bag matters now
A different bag removes vertices in a different order. That gives a *different tree*,
and a different running time $O(|V| + |E| dot T)$, where $T$ is the time per bag
operation:

#align(center, table(
  columns: (8.5em, 1fr, auto, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  align: left + horizon,
  table.header([*Bag*], [*Search, and the tree it builds*], [*$T$*], [*Total time*]),
  [Queue], [*Breadth-first search*. Finds every vertex 1 step from $s$, then 2 steps, and so on. Builds a *shortest-path tree*, counting edges (no weights).], [$O(1)$], [$O(|V| + |E|)$],
  [Priority queue: priority of $(u, v)$ is $text("dist")(u) + w(u -> v)$; weights $>= 0$], [*Best-first search* = *Dijkstra's algorithm*. Shortest paths with edge weights (proof next week).], [$O(log |E|)$], [$O(|V| + |E| log |V|)$],
  [Priority queue: priority of $u v$ is $w(u v)$; undirected], [*Prim's algorithm*. Builds a *minimum spanning tree* (not covered this semester).], [$O(log |E|)$], [$O(|V| + |E| log |V|)$],
  [Stack], [*Depth-first search*. Long, skinny trees. Uses: below.], [$O(1)$], [$O(|V| + |E|)$],
))

Here $text("dist")(u)$ is the total weight of the tree path from $s$ to $u$. The
priority queue is a binary heap, with $O(log |E|)$ insert and extract-min. A simple
graph has $|E| <= |V|^2$, so $log |E| <= 2 log |V|$, and $O(log |E|) = O(log |V|)$.

#keyidea[*BFS, DFS, Dijkstra and Prim are all whatever-first search:* They differ only
in the bag that decides where to go next.]

On homework 8 you may use Dijkstra's algorithm as a black box.

== Depth-First Search
For BFS, Dijkstra and Prim there is an obvious problem to solve. For depth-first
search there isn't a one-sentence reason to care. So this time, start with the
algorithm and then look for problems it solves.

=== The recursive version
Whatever-first search with a stack is a depth-first search, but DFS is usually written
*recursively*: for each edge $v -> w$, immediately explore everything out of $w$. One
more change: check whether $w$ is marked *before* the recursive call, instead of
pushing it and checking later.

```
DFS(v):                      ⟨⟨v is unmarked⟩⟩
  mark v
  for each edge v → w
    if w is unmarked
      w.parent ← v
      DFS(w)
```

Like any search, $text("DFS")(s)$ marks everything reachable from $s$ (if nothing was
marked before). What that is depends heavily on $s$. On a path, starting at the first
vertex marks everything, and starting at the last vertex marks only that vertex.

The uses of DFS are about the structure of the *whole* graph, so call it until every
vertex is marked:

```
DFSAll(G):
  for all vertices v
    unmark v
  for all vertices v
    if v is unmarked
      DFS(v)
```

Every vertex is marked once and its edges are explored once: $O(|V| + |E|)$ time.

=== Three facts about DFSAll
+ *Every vertex gets marked*: $text("DFS")(v)$ is called exactly once for every $v$.
  The loop in DFSAll guarantees it.
+ *Before $text("DFS")(v)$ finishes, it marks every vertex reachable from $v$ through
  unmarked vertices.* It keeps diving deeper. It stops only at vertices that someone
  else already marked.
+ *If $text("DFS")(v)$ calls $text("DFS")(w)$, directly or indirectly, there is a path
  from $v$ to $w$.*

=== Clock: start and finish times
The applications depend on the *order* in which DFS starts and finishes each vertex.
To reason about it, add a clock. Each event gets the next clock value:

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

The *active interval* of $v$ is $[v.text("pre"), v.text("post")]$: from when
$text("DFS")(v)$ goes onto the call stack until it comes off.

#keyidea[*Active intervals are either disjoint or nested:* That is how a call stack
works: if $text("DFS")(u)$ starts while $text("DFS")(v)$ is running, $text("DFS")(u)$
finishes first.]

*Example:* DFSAll on this graph, taking vertices and edges in alphabetical order. Bold
edges are tree (parent) edges:

#let dfs-pos = (a: (0, 0), b: (1.4, 0), c: (1.4, 1.2), d: (0, 1.2), e: (0, 2.4), f: (1.4, 2.4))
#let dfs-edges = (("a", "b"), ("a", "d"), ("b", "c"), ("c", "a"), ("d", "c"), ("e", "d"), ("e", "f"))
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  align: horizon,
  graph-pic(dfs-pos, dfs-edges, directed: true, bold: (("a", "b"), ("b", "c"), ("a", "d"), ("e", "f")), unit: 48pt),
  intervals((("a", 1, 8), ("b", 2, 5), ("c", 3, 4), ("d", 6, 7), ("e", 9, 12), ("f", 10, 11)), 12),
))

$text("DFS")(a)$ finds $b$, then $c$ (whose edge to $a$ goes to a marked vertex), then
backs up to $a$ and finds $d$ ($d -> c$: already marked). Nothing marked so far
reaches $e$, so DFSAll calls $text("DFS")(e)$ later, which finds $f$.

#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Order*], [*Sort by*]),
  [Preorder: $a, b, c, d, e, f$], [start time $v.text("pre")$. Rarely useful in this class.],
  [*Postorder*: $c, b, d, a, f, e$], [finish time $v.text("post")$. Very useful.],
))

== Finding a Cycle
A *dependency graph* has the subproblems of a recursive algorithm as vertices, and an
edge $u -> v$ when $u$ calls $v$ directly (Fibonacci: $F_8 -> F_7$ and $F_8 -> F_6$).
A recursive algorithm *terminates only if its dependency graph has no cycle*. On a
cycle through $u$, solving $u$ needs the answer to $u$, which you're still computing.

*Problem:* given a directed graph $G$, does it have a cycle? A directed graph with no
cycle is a *directed acyclic graph* (DAG).

Run DFSAll. Suppose that during $text("DFS")(v)$ there is a call to $text("DFS")(u)$,
and it finds an edge $u -> v$ back to the still-active $v$. That edge is a *back edge*.
By fact 3 there is a path $v ~> u$, and with the edge $u -> v$ that makes a *cycle*. In
the example, $c -> a$ is a back edge: cycle $a -> b -> c -> a$.

#keyidea[*One back edge proves a cycle:* Which edges are back edges depends on the
order DFSAll takes vertices and edges. But if DFSAll finds even one, the graph is not
acyclic.]

Is the converse true (a cycle $=>$ DFS always finds a back edge)? Next lecture.
]

#show: notes
#set heading(numbering: "1.1")
#body
