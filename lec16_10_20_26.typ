#import "setup.typ": *

#let body = [
= Lecture 16 (Oct 20) - Graphs: Definitions, Representations, Search, Reductions

For the next two or two and a half weeks: fundamental *graph algorithms*. You will
rarely design a new graph algorithm on homework. Instead you will *reduce* problems
to these algorithms: build a graph, run a known algorithm on it, and read off the
answer. Lecture explains how the algorithms work; homework uses them.

== What Is a Graph?
A drawing of dots and curves is only a picture. Two very different drawings can show
the same graph. The definition is more abstract:

A *graph* is an ordered pair $G = (V, E)$ of two sets.
- $V$ is any non-empty, finite set: the *vertices* (or nodes). Same idea as an
  alphabet.
- $E$ is the set of *edges* (or arcs). What an edge is depends on the kind of graph:

#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Kind*], [*An edge is*], [*Written*]),
  [Directed], [an ordered pair $(u, v)$ with $u, v in V$], [$u -> v$],
  [Undirected], [an unordered pair ${u, v}$: a set of exactly two vertices], [$u v$],
))

The short notation keeps descriptions of edge sets readable without nested brackets.

=== Vertices can be anything
$V$ is any finite set, so you can make the *objects of a problem* into vertices. This
is the key to reductions.

#align(center, table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Graph*], [*Vertices*], [*Edges*]),
  [Intersection graph], [Geometric objects (segments, disks)], [Pairs of objects that intersect],
  [Dependency graph], [Distinct subproblems of a recursive algorithm], [$u -> v$ if $u$ calls $v$ directly. Fibonacci: $F_6 -> F_5$ and $F_6 -> F_4$],
  [Configuration graph], [States of a game, puzzle or machine (for example, every legal placement of 4 Tower of Hanoi disks)], [Pairs one move apart. Directed if a move can't be undone],
  [NFA state graph], [States], [Possible transitions on one symbol],
))

*"Can this puzzle get from configuration $A$ to configuration $B$?"* is exactly
*"is there a path from $A$ to $B$ in the configuration graph?"* The path is the
sequence of moves. Dependency graphs come back soon, as another way to see dynamic
programming.

== Representing a Graph
Assume $G$ is *simple*: no parallel edges (never two edges from $u$ to $v$, or two
edges with endpoints $u$ and $v$). Example, undirected:

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
A $|V| times |V|$ array, indexed by vertices. Entry $(u, v)$ is $1$ if $u -> v in E$
(directed) or $u v in E$ (undirected), and $0$ otherwise. An undirected edge gives
*two* $1$s, at $(u, v)$ and $(v, u)$.

=== Adjacency list
A 1D array indexed by vertices. Entry $u$ is a list of its *neighbors*: every $v$ with
$u -> v in E$ (directed) or $u v in E$ (undirected). A linked list is fine; nothing
fancier is ever needed.

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

*From now on, assume adjacency lists* and give running times in terms of $|V|$ and
$|E|$. Graph algorithms almost always ask "what are $u$'s neighbors?" and almost never
ask "is $u v$ an edge?", so the slow edge test doesn't matter.

An intersection graph behaves like an *implicit* adjacency matrix: you can test
whether two objects intersect in $O(1)$, but you can't list an object's neighbors
without checking every other object.

== Reachability and Whatever-First Search
*Reachability:* Given a graph $G = (V, E)$ (directed or undirected) and a vertex $s$,
find every vertex $v$ that $s$ can *reach*: there is a path from $s$ to $v$.
- *Directed:* the path must start at $s$ and end at $v$. $v$ might not be able to get
  back to $s$.
- *Undirected:* paths go both ways, so this finds the *connected component* of $s$:
  the largest set of vertices with a path between every pair.

The adjacency list only tells you about *single edges*. A path can use many edges, so
finding them takes work.

=== The idea
Depth-first search (DFS) and breadth-first search (BFS) both solve reachability. They
do the *same important things*, and differ only in an implementation detail. So
describe one general algorithm, *whatever-first search*:
+ $s$ can reach itself (a path with no edges).
+ If $s$ can reach $u$ and $u -> v$ is an edge, then $s$ can reach $v$. So every time
  you find a reachable vertex, remember to search out of it later.
+ A cycle could send the search around forever. So *mark* a vertex when you explore
  its edges, and never explore it again.

A *bag* is any data structure that supports *insert a vertex* and *remove some vertex*
that was inserted. Which vertex comes out depends on the bag.

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

*Example:* A directed graph. Searching from $s$ marks the yellow vertices. Nothing
leads from them to $d$ or $e$ ($d -> a$ points the wrong way):

#let reach-pos = (s: (0, 0), a: (1.5, 0), b: (0.75, 1.2), c: (3, 0), d: (2.25, 1.2), e: (3.75, 1.2))
#align(center, graph-pic(
  reach-pos,
  (("s", "a"), ("a", "b"), ("b", "s"), ("a", "c"), ("d", "a"), ("d", "e")),
  directed: true,
  marked: ("s", "a", "b", "c"),
  unit: 52pt,
))

*Claim:* Whatever-first search from $s$ marks *exactly* the vertices $s$ can reach.
The full proof is in Erickson's book. You won't be asked for proofs like this. Both
halves use induction:
- *Marked $=>$ reachable:* Induction on the order of marking. Either $v = s$, or $v$
  went into the bag through an edge $u -> v$ from a vertex $u$ marked earlier. By
  induction $u$ is reachable, so $v$ is too: add one edge.
- *Reachable $=>$ marked:* Induction on the distance from $s$ to $v$. If $v = s$, it
  goes into the bag first and comes out marked. Otherwise a shortest path ends with an
  edge $u -> v$, where $u$ is closer to $s$. By induction $u$ gets marked. Then $v$
  goes into the bag, and it gets marked later.

=== Running time
Let $T$ be the time for one bag insertion or removal. Count each line:

#align(center, table(
  columns: (auto, auto, 1fr),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Step*], [*Times*], [*Why*]),
  [`mark u`], [$<= |V|$], [Only unmarked vertices get marked, and marks never go away],
  [`for each edge u → v`], [$<= |E|$ total], [Only right after marking $u$, which happens once],
  [`put v into the bag`], [$<= |E| + 1$], [Once for $s$, then once per edge seen],
  [`take u from the bag`], [$<= |E| + 1$], [Can't remove more than was inserted],
))

$ "Total:" O(|V| + |E| dot T) $

For reachability, use the simplest bag: a *stack* or a *queue*, with $T = O(1)$:

$ #box(stroke: black, inset: 3pt, [$ O(|V| + |E|) $]) $

That is as fast as possible: the time it takes just to read the graph.

#align(center, table(
  columns: (auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Bag*], [*Search*]),
  [Stack], [Depth-first search (roughly)],
  [Queue], [Breadth-first search: also finds shortest paths, counted in edges],
  [Priority queue], [Other algorithms, with a slower $T$ (later)],
))

Different bags find the vertices in different orders and build different *spanning
trees*. More on Thursday.

== Reductions
*Reducing problem $A$ to problem $B$:* solve an instance of $A$ by building one or more
instances of $B$ and running an algorithm for $B$. From now on: build a graph, then
run a known graph algorithm.

=== Example: useless DFA states
*Input:* a DFA $M = (Q, {0, 1}, delta, s, A)$ with $n$ states. A state $q$ is
*useless* if no input string reaches it: there is no $x$ with $delta^*(s, x) = q$.
*Goal:* find every useless state, so you can delete them. (The subset construction
for NFA $->$ DFA often makes many of them.)

Moving from state to state along transitions is like walking from vertex to vertex.
So:

*1. Build a graph:* $G = (V, E)$ with
$ V = Q, #h(2em) E = {p -> q mid(|) delta(p, 0) = q "or" delta(p, 1) = q} $

*2. Say what graph problem to solve, and why it helps:*
$ q "is useless" <==> s "cannot reach" q "in" G $

*3. Say which algorithm to run, and how to use its output:* Run whatever-first search
from $s$. The useless states are the vertices it *doesn't* mark.

*4. Running time, in terms of the original input:* $G$ has $|V| = n$ vertices and
$|E| <= 2n$ edges (two transitions per state). Whatever-first search takes
$O(|V| + |E|)$, so the algorithm takes
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
#align(center, text(size: 0.85em)[A small DFA and its graph (self-loops not drawn).
Search from $s$ marks $s$ and $p$, so $u$ is useless.])

#keyidea[*That is the whole answer:* For a reduction, write down: the graph (its
vertices and edges, and what they mean if it isn't obvious), the graph problem and
why its answer helps, the algorithm and how to use its output, and the running time.
This is exactly the detail a full-credit exam solution needs. No induction proof is
needed at this point in the course.]

#trap[*Say "whatever-first search", not "DFS" or "BFS":* Unless you say otherwise, it
means the stack or queue version. Naming a specific search is more detail than
needed, and suggests you aren't thinking about the actual problem (reachability, not
shortest paths). It can lose a few points.]

#trap[*Report the running time in the input's own terms:* $|V|$ and $|E|$ belong to a
graph you made up. The person asking about useless states has never heard of it, so
give $O(n)$, not $O(|V| + |E|)$. Building the graph is assumed to take
$O(|V| + |E|)$ time. If building it is complicated, count that too.]

Next time: more about the bag and spanning trees, and a reduction that builds a *new*
graph out of a given graph (it's in the lecture notes on the website already, useful
for the lab).
]

#show: notes
#set heading(numbering: "1.1")
#body
