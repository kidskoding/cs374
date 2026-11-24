#import "setup.typ": *

#let body = [
= Lecture 18 (Oct 27) - Cycle Detection, Topological Sort, Shortest Paths, Dijkstra's Algorithm

This lecture first completes our study of depth-first search. We use it to detect
cycles, and we obtain a topological sort almost for free. We then begin the last major
problem in the algorithms part of the course, the computation of shortest paths.

== Recap: DFS with a Clock
Recall from Lecture 17 that DFSAll unmarks every vertex and then calls
$text("DFS")(v)$ on each vertex that is still unmarked. $text("DFS")(v)$ marks $v$,
records its start time $v.text("pre")$, recursively explores every unmarked
out-neighbor, and records its finish time $v.text("post")$. We use two facts in this
lecture:
- If there is a path from $v$ to $w$ through vertices that are unmarked when
  $text("DFS")(v)$ starts, then $text("DFS")(v)$ calls $text("DFS")(w)$, possibly
  indirectly. The call need not follow that exact path.
- Sorting the vertices by $v.text("post")$ gives a *postorder*. Different loop orders
  give different postorders.

An edge $u -> v$ is a *back edge* if $text("DFS")(v)$ calls $text("DFS")(u)$, directly
or indirectly. In that case there is a path $v ~> u$, which together with the edge
$u -> v$ forms a cycle.

== Cycle Detection
#theorem[$G$ has a directed cycle if and only if DFSAll on $G$ finds a back edge.]

For the ($<==$) direction, a back edge closes a cycle, as we saw in Lecture 17.

For the ($==>$) direction, let $C$ be a cycle. DFSAll calls DFS on every vertex, so we
can let $v$ be the first vertex of $C$ on which DFS is called. Let $u$ be the vertex
just before $v$ on $C$, so that $u -> v$ is an edge. When $text("DFS")(v)$ starts, the
rest of $C$ is still unmarked, so the path around $C$ from $v$ to $u$ uses only
unmarked vertices. Therefore $text("DFS")(v)$ calls $text("DFS")(u)$, and the edge
$u -> v$ is a back edge.

Thus every cycle has at least one edge that DFSAll finds as a back edge. Which edge it
finds depends on the loop orders in DFSAll and DFS.

=== Spotting back edges with finish times
If $u -> v$ is a back edge, then $text("DFS")(u)$ runs inside $text("DFS")(v)$, so

$ v.text("pre") < u.text("pre") < u.text("post") < v.text("post") $

It suffices to compare finish times, because two other orderings are impossible for
any edge $u -> v$:
- Active intervals never partially overlap, because DFS uses a call stack.
- The order $u.text("post") < v.text("pre")$ cannot occur, because $text("DFS")(u)$
  examines the edge $u -> v$ and therefore marks $v$ before it finishes.

Consequently, for every edge $u -> v$,
$ u -> v "is a back edge" <==> u.text("post") < v.text("post") $

```
IsAcyclic(G):
  DFSAll(G)                       ⟨⟨with the clock⟩⟩
  for each edge u → v
    if u.post < v.post
      return False                ⟨⟨back edge: cycle⟩⟩
  return True
```

DFSAll marks each vertex once and examines each edge once, and the final loop spends
$O(1)$ time per edge, so the running time of IsAcyclic is
$#box(stroke: black, inset: 3pt, [$O(|V| + |E|)$])$.

Erickson's book takes a different approach. It stores a status on each vertex (new,
active, or finished) and reports a back edge when it finds an edge into an active
vertex.

== Topological Sort
A recursive algorithm can work only if its dependency graph has no cycle. Even when
the graph is acyclic, we still need an order in which to solve the subproblems, with
every subproblem solved before anything that points to it.

A *topological order* of a directed graph is an ordering of its vertices such that for
every edge $u -> v$, $u$ comes before $v$. A dependency graph needs the reverse order,
with callees first, which is slightly inconvenient.

- A graph with a cycle has no topological order, because going around the cycle, some
  edge has to point backward.
- In a graph with no cycle, a reversed postorder is a topological order. Without a
  cycle, DFSAll finds no back edge, so every edge $u -> v$ has
  $v.text("post") < u.text("post")$; that is, the head finishes first. Listing the
  vertices by decreasing finish time therefore makes every edge point forward.

#keyidea[A topological order is a reversed postorder. Run DFSAll, then list the
vertices from last finished to first finished. This takes $O(|V| + |E|)$ time, and the
same run also checks for a cycle.]

*Example:* Remove the edge $c -> a$ from the graph of Lecture 17, so that it becomes a
DAG. Running DFSAll in alphabetical order gives the postorder $c, b, d, a, f, e$.
Reversing it gives the order shown below.

#let dag-pos = (e: (0, 0), f: (1, 0.9), a: (2, 0), d: (3, 0.9), b: (4, 0), c: (5, 0.9))
#align(center, graph-pic(
  dag-pos,
  (("a", "b"), ("a", "d"), ("b", "c"), ("d", "c"), ("e", "d"), ("e", "f")),
  directed: true,
  unit: 50pt,
))
#align(center, text(size: 0.85em)[The topological order $e, f, a, d, b, c$, from left
to right. Every edge points to the right.])

#trap[This algorithm differs from the other topological sort algorithm, which
repeatedly removes a vertex with no incoming edges. Both are correct. The DFS-based
algorithm fits naturally with cycle detection and with dynamic programming on
dependency graphs (Lecture 19).]

== Single-Source Shortest Paths
The input is a directed graph $G = (V, E)$, a weight function $w: E -> RR$, and a
source vertex $s$. Weights may be positive, zero, or even negative. A useful model is a
road network in which $w(u -> v)$ is the travel time along one stretch of road.

The *distance* $text("dist")(s, t)$ is the minimum total weight of any path from $s$
to $t$. Every known algorithm that computes one distance computes the distances from
$s$ to every vertex anyway, because the shortest route to $t$ requires the shortest
route to the vertex before $t$, and so on. We therefore study the *single-source
shortest paths* problem (SSSP).

Negative weights still make sense. They might model a scenic road we would like to
take, and they appear in Lab 10A and the homework of the same week. In this lecture all weights are
positive; Lecture 19 treats negative weights.

=== The shortest-path tree
Every subpath of a shortest path is itself a shortest path. If the portion from $a$ to
$d$ were not a shortest path from $a$ to $d$, replacing it with a shorter one would
shorten the whole path.

Consequently, if two shortest paths split apart at $a$ and meet again at $d$, both
detours from $a$ to $d$ are shortest paths, and we may keep one of them for both
paths. We call this "uncrossing" the paths. Repeating this step leaves a
*shortest-path tree rooted at $s$*.

Our goal is to compute $text("dist")(s, v)$ for every vertex $v$, together with a
shortest-path tree rooted at $s$.

== Ford's Generic Algorithm
Just as whatever-first search unifies the algorithms for reachability, one general
framework covers all the shortest-path algorithms. Each specific algorithm chooses an
order that suits the structure and weights of the graph. The framework is due to
Lester Ford (1956). Each vertex stores two values:
- $v.text("dist")$ is the length of some path from $s$ to $v$, or $infinity$. It may
  be too large until the algorithm finishes.
- $v.text("pred")$ is the vertex before $v$ on that path, or Null.

Following $v, v.text("pred"), v.text("pred").text("pred"), dots$ back to $s$ yields a
path, but that path need not have length $v.text("dist")$, because pred values set
earlier can change later. What is guaranteed is that some path ending in
$v.text("pred") -> v$ has length $v.text("dist")$.

An edge $u -> v$ is *tense* if
$ u.text("dist") + w(u -> v) < v.text("dist") $
A tense edge proves that the algorithm is not finished, because going to $u$ and then
along $u -> v$ beats the best known path to $v$. We fix a tense edge by *relaxing* it.

```
InitSSSP(s):
  s.dist ← 0
  s.pred ← Null
  for every vertex v ≠ s
    v.dist ← ∞
    v.pred ← Null

Relax(u → v):
  v.dist ← u.dist + w(u → v)
  v.pred ← u

FordSSSP(s):
  InitSSSP(s)
  while there is at least one tense edge
    Relax any tense edge
```

*Claim (positive weights).* FordSSSP terminates. When it does,
$v.text("dist") = text("dist")(s, v)$ for every vertex $v$, and every $v.text("pred")$
is the vertex before $v$ on a shortest path, so the pred edges form a shortest-path
tree. The proof rests on two observations:
- While some $v.text("dist")$ is too large, some edge is tense, so the algorithm
  cannot stop early.
- Each $v.text("dist")$ is always the length of an actual path, and it only decreases.
  Since there are only finitely many paths, it cannot decrease forever.

Erickson's chapter on shortest paths gives more detail.

#trap[A solution should not simply say "run Ford's algorithm." With a bad order of
tense edges, the algorithm can take exponential time, since a single $v.text("dist")$
might drop about $2^(|V|)$ times, and graders assume the worst order. Instead, examine
the structure of the graph (does it have cycles, or is it a DAG?) and its weights (are
they all positive, all 1, or partly negative?), and choose the specific algorithm that
fits.]

== Dijkstra's Algorithm
Dijkstra's algorithm assumes only that all weights are positive. It rests on two
observations about FordSSSP:
+ An edge becomes tense only when the dist value of its tail drops. Dist values only
  decrease. If $u -> v$ is not tense, lowering $v.text("dist")$ cannot make it tense;
  only lowering $u.text("dist")$ can. So, as in whatever-first search, we revisit the
  outgoing edges of $u$ after $u.text("dist")$ drops, and not before.
+ We should relax the edges out of the vertex with the smallest dist value. With
  positive weights, relaxing $u -> v$ gives $v.text("dist") > u.text("dist")$, so the
  smallest dist value can never decrease again.

Combining these observations, we keep the vertices whose dist values have dropped in a
priority queue, keyed by dist.

```
Dijkstra(s):
  InitSSSP(s)
  Insert(s, 0)
  while the priority queue is not empty
    u ← ExtractMin()
    for each edge u → v
      if u → v is tense
        Relax(u → v)
        if v is in the priority queue
          DecreaseKey(v, v.dist)
        else
          Insert(v, v.dist)
```

The priority queue initially contains only $s$, rather than every vertex, and a vertex
is inserted when its dist value first drops. As written, the algorithm could even
insert a vertex again after extracting it, although with positive weights this never
happens, as we show below. Lecture 19 explains why the algorithm is written this way.

*Example:* In the graph below, edge weights are shown in red. The bold edges are the
final pred edges, which form the shortest-path tree.

#let dj-pos = (s: (0, 0.8), a: (1.6, 0), b: (1.6, 1.6), c: (3.2, 1.1), t: (4.8, 0.4))
#let dj-w = (("s", "a", 4), ("s", "b", 1), ("b", "a", 2), ("a", "c", 1), ("b", "c", 5), ("c", "t", 3), ("a", "t", 6))
#let dj-get(e) = [#dj-w.find(((u, v, _)) => (u, v) == e).at(2)]
#align(center, graph-pic(
  dj-pos,
  dj-w.map(((u, v, _)) => (u, v)),
  directed: true,
  bold: (("s", "b"), ("b", "a"), ("a", "c"), ("c", "t")),
  weight: dj-get,
  unit: 52pt,
))

#align(center, table(
  columns: 6,
  inset: (x: 9pt, y: 4pt),
  stroke: 0.5pt,
  align: center,
  table.header([*After*], [$s$], [$a$], [$b$], [$c$], [$t$]),
  [InitSSSP], [$0$], [$infinity$], [$infinity$], [$infinity$], [$infinity$],
  [extract $s$], [*0*], [$4$], [$1$], [$infinity$], [$infinity$],
  [extract $b$], [], [$3$ (via $b$)], [*1*], [$6$], [$infinity$],
  [extract $a$], [], [*3*], [], [$4$ (via $a$)], [$9$],
  [extract $c$], [], [], [], [*4*], [$7$ (via $c$)],
  [extract $t$], [], [], [], [], [*7*],
))
#align(center, text(size: 0.85em)[A bold entry means that the vertex has been
extracted and its dist value is final. The extracted dist values appear in increasing
order: $0, 1, 3, 4, 7$.])

=== Running time
Let $d_i$ be the dist value of the $i$th vertex extracted. Every dist value created
after that extraction is $d_i$ plus a positive weight, so it is larger than $d_i$.
Since $d_i$ was the smallest value in the queue, the extracted values strictly
increase: $d_1 < d_2 < dots$

The dist value of a vertex never increases. So if $v$ were extracted twice, its second
value would be no larger than its first, contradicting the increasing order. Therefore
each vertex is extracted at most once, which gives the following bounds:
- There are at most $|V|$ Insert and $|V|$ ExtractMin operations.
- Each edge is examined at most once (when its tail is extracted), so there are at
  most $|E|$ DecreaseKey operations.

With a binary heap, each operation takes $O(log |V|)$ time, so the total running time
is

$ O((|V| + |E|) log |V|) = #box(stroke: black, inset: 3pt, [$O(|E| log |V|)$]) $

The last step assumes that every vertex is reachable from $s$, so that
$|E| >= |V| - 1$. A simple graph has $|E| <= |V|^2$, so $log |E| <= 2 log |V|$; hence
$log |E|$ and $log |V|$ are interchangeable in big-$O$ notation.
]

#show: notes
#set heading(numbering: "1.1")
#body
