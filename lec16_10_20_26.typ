#import "setup.typ": *

#let body = [
= Lecture 16 (Oct 20) - Graphs: Definitions, Representations, Search, Reductions

The next two to two and a half weeks of the course cover fundamental graph
algorithms. Homework problems rarely ask us to design a new graph algorithm. Instead,
we reduce problems to these algorithms: we build a graph, run a known algorithm on it,
and read off the answer. The lectures explain how the algorithms work, and the
homework uses them.

== What Is a Graph?
A drawing of dots and curves is only a picture of a graph, and two very different
drawings can show the same graph. The formal definition is more abstract.

A *graph* is an ordered pair $G = (V, E)$ of two sets.
- $V$ is any non-empty finite set, whose elements are the *vertices* (or nodes). This
  is the same idea as an alphabet.
- $E$ is the set of *edges* (or arcs). What counts as an edge depends on the kind of
  graph:

#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Kind*], [*An edge is*], [*Written*]),
  [Directed], [an ordered pair $(u, v)$ with $u, v in V$], [$u -> v$],
  [Undirected], [an unordered pair ${u, v}$, that is, a set of exactly two vertices], [$u v$],
))

The short notation keeps descriptions of edge sets readable without nested brackets.

=== Vertices can be anything
Because $V$ can be any finite set, we can take the objects of a problem as the
vertices of a graph. Reductions depend on this freedom.

#align(center, table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Graph*], [*Vertices*], [*Edges*]),
  [Intersection graph], [Geometric objects (segments, disks)], [Pairs of objects that intersect],
  [Dependency graph], [Distinct subproblems of a recursive algorithm], [$u -> v$ if $u$ calls $v$ directly. Fibonacci: $F_6 -> F_5$ and $F_6 -> F_4$],
  [Configuration graph], [States of a game, puzzle or machine (for example, every legal placement of 4 Tower of Hanoi disks)], [Pairs of states one move apart; directed if a move cannot be undone],
  [NFA state graph], [States], [Possible transitions on one symbol],
))

The question "Can this puzzle get from configuration $A$ to configuration $B$?" is
exactly the question "Is there a path from $A$ to $B$ in the configuration graph?",
and the path is the sequence of moves. Dependency graphs return later as another way
to view dynamic programming.

== Representing a Graph
We assume that $G$ is *simple*, meaning that it has no parallel edges: there are never
two edges from $u$ to $v$, or two edges with endpoints $u$ and $v$. Consider the
following undirected example.

#let ex-pos = (a: (0, 0), b: (2, 0), c: (1, 1.3), d: (3, 1.3), e: (3, 0))
#let ex-edges = (("a", "b"), ("a", "c"), ("b", "c"), ("c", "d"), ("b", "e"))
#let ex-names = ("a", "b", "c", "d", "e")
#let adj(u, v) = ex-edges.any(((x, y)) => (x, y) == (u, v) or (x, y) == (v, u))

#align(center, grid(
  columns: 3,
  column-gutter: 2.2em,
  align: horizon,
  graph-pic(ex-pos, ex-edges),
  grid(
    columns: (1.6em,) * 6,
    rows: 1.4em,
    align: center + horizon,
    stroke: (x, y) => if x == 0 or y == 0 { none } else { 0.5pt },
    fill: (x, y) => if x > 0 and y > 0 and adj(ex-names.at(y - 1), ex-names.at(x - 1)) { accent-light } else { none },
    [], ..ex-names.map(n => text(size: 0.8em, fill: accent, n)),
    ..ex-names.map(u => (text(size: 0.8em, fill: accent, u), ..ex-names.map(v => text(size: 0.8em)[#if adj(u, v) [1] else [0]]))).flatten(),
  ),
  grid(
    columns: 2,
    column-gutter: 0.6em,
    row-gutter: 0.45em,
    align: left + horizon,
    ..ex-names.map(u => (
      box(stroke: 0.5pt, inset: (x: 5pt, y: 3pt), text(size: 0.8em, u)),
      text(size: 0.8em, ex-names.filter(v => adj(u, v)).join([ #sym.arrow.r ])),
    )).flatten(),
  ),
))
#align(center, text(size: 0.85em)[The graph, its adjacency matrix, and its adjacency
list.])

=== Adjacency matrix
An adjacency matrix is a $|V| times |V|$ array indexed by vertices. Entry $(u, v)$ is
$1$ if $u -> v in E$ (directed) or $u v in E$ (undirected), and $0$ otherwise. An
undirected edge therefore produces two $1$s, one at $(u, v)$ and one at $(v, u)$.

=== Adjacency list
An adjacency list is a one-dimensional array indexed by vertices. Entry $u$ holds a
list of the *neighbors* of $u$: every vertex $v$ with $u -> v in E$ (directed) or
$u v in E$ (undirected). A linked list suffices; nothing fancier is ever needed.

#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Operation*], [*Adjacency matrix*], [*Adjacency list*]),
  [Is $u -> v$ an edge?], [$O(1)$], [$O(deg(u))$: walk $u$'s list],
  [List the neighbors of $u$], [$O(|V|)$: walk the whole row], [$O(1)$ per neighbor],
  [Space], [$O(|V|^2)$, even with no edges], [$O(|V| + |E|)$],
))

From now on, we assume that graphs are stored as adjacency lists, and we give running
times in terms of $|V|$ and $|E|$. Graph algorithms almost always ask "What are the
neighbors of $u$?" and almost never ask "Is $u v$ an edge?", so the slow edge test
does not matter.

An intersection graph behaves like an implicit adjacency matrix. We can test whether
two objects intersect in $O(1)$ time, but we cannot list an object's neighbors without
checking every other object.

== Reachability and Whatever-First Search
The *reachability* problem is the following: given a graph $G = (V, E)$, directed or
undirected, and a vertex $s$, find every vertex $v$ that $s$ can *reach*, meaning that
there is a path from $s$ to $v$.
- In a directed graph, the path must start at $s$ and end at $v$, and $v$ might not be
  able to get back to $s$.
- In an undirected graph, paths go both ways, so reachability finds the *connected
  component* of $s$: the largest set of vertices with a path between every pair.

The adjacency list describes only single edges. A path can use many edges, so finding
paths takes some work.

=== The idea
Depth-first search (DFS) and breadth-first search (BFS) both solve reachability. They
do the same essential work and differ only in one implementation detail, so we
describe a single general algorithm, called *whatever-first search*. It rests on three
observations.
+ $s$ can reach itself, by a path with no edges.
+ If $s$ can reach $u$ and $u -> v$ is an edge, then $s$ can reach $v$. So whenever we
  find a reachable vertex, we must remember to search out of it later.
+ A cycle could send the search around forever. So we *mark* a vertex when we explore
  its edges, and we never explore it again.

A *bag* is any data structure that supports two operations: inserting a vertex, and
removing some vertex that was inserted earlier. Which vertex comes out depends on the
bag.

```
WhateverFirstSearch(s):
  put s into the bag
  while the bag is not empty
    take u from the bag
    if u is unmarked
      mark u
      for each edge u → v
        put v into the bag
```

*Example:* In the directed graph below, a search from $s$ marks the yellow vertices.
Nothing leads from them to $d$ or $e$, because the edge $d -> a$ points the wrong way.

#let reach-pos = (s: (0, 0), a: (1.5, 0), b: (0.75, 1.2), c: (3, 0), d: (2.25, 1.2), e: (3.75, 1.2))
#align(center, graph-pic(
  reach-pos,
  (("s", "a"), ("a", "b"), ("b", "s"), ("a", "c"), ("d", "a"), ("d", "e")),
  directed: true,
  marked: ("s", "a", "b", "c"),
  unit: 52pt,
))

*Claim:* Whatever-first search from $s$ marks exactly the vertices that $s$ can reach.

The full proof appears in Erickson's book; proofs of this kind will not be required in
this course. Both halves of the proof use induction.
- _Marked $=>$ reachable._ We induct on the order of marking. Either $v = s$, or $v$
  entered the bag through an edge $u -> v$ from a vertex $u$ that was marked earlier.
  By induction $u$ is reachable, so adding one edge shows that $v$ is reachable too.
- _Reachable $=>$ marked._ We induct on the distance from $s$ to $v$. If $v = s$, then
  $v$ goes into the bag first and comes out marked. Otherwise, a shortest path to $v$
  ends with an edge $u -> v$, where $u$ is closer to $s$. By induction $u$ is marked,
  so $v$ goes into the bag and is marked later.

=== Running time
Let $T$ be the time for one insertion into or removal from the bag. We count how often
each line executes:

#align(center, table(
  columns: (auto, auto, 1fr),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Step*], [*Times*], [*Why*]),
  [`mark u`], [$<= |V|$], [Only unmarked vertices get marked, and marks never go away],
  [`for each edge u → v`], [$<= |E|$ total], [Only right after marking $u$, which happens once],
  [`put v into the bag`], [$<= |E| + 1$], [Once for $s$, then once per edge seen],
  [`take u from the bag`], [$<= |E| + 1$], [We cannot remove more than was inserted],
))

$ "Total:" O(|V| + |E| dot T) $

For reachability we use the simplest kind of bag, a stack or a queue, so $T = O(1)$
and the running time is

$ #box(stroke: black, inset: 3pt, [$ O(|V| + |E|) $]) $

This is as fast as possible, since merely reading the graph takes this long.

#align(center, table(
  columns: (auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Bag*], [*Search*]),
  [Stack], [Depth-first search (roughly)],
  [Queue], [Breadth-first search, which also finds shortest paths counted in edges],
  [Priority queue], [Other algorithms, with a slower $T$ (covered later)],
))

Different bags find the vertices in different orders and build different spanning
trees. Lecture 17 returns to this point.

== Reductions
*Reducing* problem $A$ to problem $B$ means solving an instance of $A$ by building one
or more instances of $B$ and running an algorithm for $B$ on them. From now on, our
reductions build a graph and then run a known graph algorithm on it.

=== Example: useless DFA states
We are given a DFA $M = (Q, {0, 1}, delta, s, A)$ with $n$ states. A state $q$ is
*useless* if no input string reaches it, that is, if there is no string $x$ with
$delta^*(s, x) = q$. The goal is to find every useless state, so that we can delete
them. (The subset construction for NFA $->$ DFA often produces many useless states.)

Moving from state to state along transitions is like walking from vertex to vertex
along edges, which suggests the following reduction.

*1. Build a graph:* Let $G = (V, E)$, where
$ V = Q, #h(2em) E = {p -> q mid(|) delta(p, 0) = q "or" delta(p, 1) = q} $

*2. Say what graph problem to solve, and why it helps:*
$ q "is useless" <==> s "cannot reach" q "in" G $

*3. Say which algorithm to run, and how to use its output:* We run whatever-first
search from $s$. The useless states are the vertices that the search does not mark.

*4. Running time, in terms of the original input:* The graph $G$ has $|V| = n$
vertices and $|E| <= 2n$ edges, since each state has two transitions. Whatever-first
search runs in $O(|V| + |E|)$ time, so the algorithm runs in
$ #box(stroke: black, inset: 3pt, [$ O(n) $]) $

#let dfa-pos = (s: (0, 0), p: (2, 0), u: (1, 1.2))
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  align: horizon,
  table(
    columns: 3,
    inset: (x: 8pt, y: 4pt),
    stroke: 0.5pt,
    align: center,
    table.header([$q$], [$delta(q, 0)$], [$delta(q, 1)$]),
    [$s$], [$p$], [$s$],
    [$p$], [$s$], [$p$],
    [$u$], [$s$], [$p$],
  ),
  graph-pic(dfa-pos, (("s", "p"), ("p", "s"), ("u", "s"), ("u", "p")), directed: true, marked: ("s", "p"), unit: 50pt),
))
#align(center, text(size: 0.85em)[A small DFA and its graph (self-loops are not
drawn). A search from $s$ marks $s$ and $p$, so $u$ is useless.])

#keyidea[*What a reduction must state:* A solution by reduction describes the graph
(its vertices and edges, and what they mean if that is not obvious), the graph problem
and why its answer helps, the algorithm and how to use its output, and the running
time. This is exactly the level of detail that a full-credit exam solution needs. No
induction proof is required at this point in the course.]

#trap[*Say "whatever-first search", not "DFS" or "BFS":* Unless otherwise specified,
whatever-first search means the stack or queue version. Naming a specific search gives
more detail than the solution needs, and it suggests that the writer is not thinking
about the actual problem, which is reachability rather than shortest paths. It can
cost a few points.]

#trap[*Report the running time in the input's own terms:* $|V|$ and $|E|$ describe a
graph that we constructed ourselves. Someone asking about useless states has never
heard of that graph, so the answer should be $O(n)$, not $O(|V| + |E|)$. Building the
graph is assumed to take $O(|V| + |E|)$ time; if the construction is complicated, its
cost must be counted as well.]

Lecture 17 says more about the bag and spanning trees, and it presents a reduction
that builds a new graph out of a given graph. That reduction already appears in the
lecture notes on the course website and is useful for the lab.
]

#show: notes
#set heading(numbering: "1.1")
#body
