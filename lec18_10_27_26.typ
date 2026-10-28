#import "setup.typ": *

#let body = [
= Lecture 18 (Oct 27) - Cycle Detection, Topological Sort, Shortest Paths, Dijkstra's Algorithm

First, finish depth-first search: detect cycles, and get a topological sort almost
for free. Then start the last big problem of the algorithms part of the course:
*shortest paths*.

== Recap: DFS with a Clock
From Lecture 17: DFSAll unmarks every vertex, then calls $text("DFS")(v)$ on each
vertex that is still unmarked. $text("DFS")(v)$ marks $v$, records its start time
$v.text("pre")$, recursively explores every unmarked out-neighbor, and records its
finish time $v.text("post")$. Two facts used today:
- If there is a path from $v$ to $w$ through vertices that are unmarked when
  $text("DFS")(v)$ starts, then $text("DFS")(v)$ calls $text("DFS")(w)$ (maybe
  indirectly). It may not follow that exact path.
- Sorting vertices by $v.text("post")$ gives *a postorder*. Different loop orders give
  different postorders.

An edge $u -> v$ is a *back edge* if $text("DFS")(v)$ (directly or indirectly) calls
$text("DFS")(u)$. Then there is a path $v ~> u$, and with $u -> v$ it is a cycle.

== Cycle Detection
#theorem[$G$ has a directed cycle if and only if DFSAll on $G$ finds a back edge.]

*($<==$)*: a back edge closes a cycle (Lecture 17).

*($==>$)*: let $C$ be a cycle. DFSAll calls DFS on every vertex, so let $v$ be the
*first* vertex of $C$ that DFS is called on. Let $u$ be the vertex just before $v$ on
$C$, so $u -> v$ is an edge. When $text("DFS")(v)$ starts, the rest of $C$ is still
unmarked, so the path around $C$ from $v$ to $u$ uses only unmarked vertices. So
$text("DFS")(v)$ calls $text("DFS")(u)$, and the edge $u -> v$ is a back edge.

Every cycle has *at least one* edge found as a back edge. Which one depends on the
loop orders in DFSAll and DFS.

=== Spotting back edges with finish times
If $u -> v$ is a back edge, $text("DFS")(u)$ runs inside $text("DFS")(v)$:

$ v.text("pre") < u.text("pre") < u.text("post") < v.text("post") $

You only need to compare finish times. For *any* edge $u -> v$, two other orders are
impossible:
- Active intervals never partially overlap, because DFS uses a call stack.
- $u.text("post") < v.text("pre")$ can't happen: $text("DFS")(u)$ sees the edge
  $u -> v$, so it marks $v$ before it finishes.

So for an edge $u -> v$:
$ u -> v "is a back edge" <==> u.text("post") < v.text("post") $

```
IsAcyclic(G):
  DFSAll(G)                       ⟨⟨with the clock⟩⟩
  for each edge u → v
    if u.post < v.post
      return False                ⟨⟨back edge: cycle⟩⟩
  return True
```

*Running time:* DFSAll marks each vertex once and looks at each edge once, and the
loop is $O(1)$ per edge: $#box(stroke: black, inset: 3pt, [$O(|V| + |E|)$])$.

Erickson's book does it another way: store a status on each vertex (new, active,
finished), and report a back edge when you find an edge into an *active* vertex.

== Topological Sort
A recursive algorithm can only work if its dependency graph has no cycle. If it has
none, you still need an order to solve the subproblems in: every subproblem before
anything that points to it.

A *topological order* of a directed graph is an ordering of its vertices such that for
every edge $u -> v$, *$u$ comes before $v$*. A dependency graph needs the reverse
(callees first), which is a little annoying.

- *A cycle means no topological order:* Going around the cycle, some edge has to point
  backward.
- *No cycle: reverse a postorder:* With no cycle, DFSAll finds no back edge. So every
  edge $u -> v$ has $v.text("post") < u.text("post")$: the head finishes first. List
  the vertices by *decreasing* finish time, and every edge points forward.

#keyidea[*Topological order = reversed postorder:* Run DFSAll, then list the vertices
from last finished to first finished. $O(|V| + |E|)$. The same run also checks for a
cycle.]

*Example:* The Lecture 17 graph without the edge $c -> a$, so it is a DAG. DFSAll in
alphabetical order gives postorder $c, b, d, a, f, e$. Reversed:

#let dag-pos = (e: (0, 0), f: (1, 0.9), a: (2, 0), d: (3, 0.9), b: (4, 0), c: (5, 0.9))
#align(center, graph-pic(
  dag-pos,
  (("a", "b"), ("a", "d"), ("b", "c"), ("d", "c"), ("e", "d"), ("e", "f")),
  directed: true,
  unit: 50pt,
))
#align(center, text(size: 0.85em)[Topological order $e, f, a, d, b, c$, left to right.
Every edge points right.])

#trap[*This is not the other topological sort algorithm* (repeatedly remove a vertex
with no incoming edges). Both are correct. The DFS one goes with cycle detection and
with dynamic programming on dependency graphs (Thursday).]

== Single-Source Shortest Paths
*Input:* a directed graph $G = (V, E)$, a weight function $w: E -> RR$, and a source
vertex $s$. Weights may be positive, zero or even negative. Think of a road network
where $w(u -> v)$ is the travel time on a stretch of road.

The *distance* $text("dist")(s, t)$ is the minimum total weight of any path from $s$
to $t$. Every known algorithm that finds one distance finds the distances from $s$ to
*every* vertex anyway: the shortest route to $t$ needs the shortest route to the
vertex before $t$, and so on. So the problem is *single-source shortest paths*
(SSSP).

Negative weights still make sense (a scenic road you'd like to take, or the lab and
homework this week). Today all weights are *positive*. Negative weights are on
Thursday.

=== The shortest-path tree
*A subpath of a shortest path is a shortest path:* If the part from $a$ to $d$ weren't
the shortest from $a$ to $d$, replacing it with a shorter one would shorten the whole
path.

So if two shortest paths split apart at $a$ and meet again at $d$, both detours from
$a$ to $d$ are shortest. Keep one of them for both paths ("uncross" them). Doing this
again and again leaves a *shortest-path tree rooted at $s$*.

*Goal:* compute $text("dist")(s, v)$ for every $v$, and a shortest-path tree rooted
at $s$.

== Ford's Generic Algorithm
Like whatever-first search for reachability, one general framework covers all the
shortest-path algorithms. Each specific algorithm chooses an order that suits the
graph's structure and weights. The framework is Lester Ford's (1956). Each vertex
stores:
- $v.text("dist")$: the length of *some* path from $s$ to $v$, or $infinity$. It can
  be too big until the algorithm finishes.
- $v.text("pred")$: the vertex before $v$ on that path, or Null.

Following $v, v.text("pred"), v.text("pred").text("pred"), dots$ back to $s$ gives a
path. But it may not have length $v.text("dist")$, because earlier pred values can
change later. What's guaranteed: *some* path ending in $v.text("pred") -> v$ has
length $v.text("dist")$.

*Tense edge:* $u -> v$ is *tense* if
$ u.text("dist") + w(u -> v) < v.text("dist") $
That is proof you're not done: going to $u$ and then along $u -> v$ beats the best
known path to $v$. Fix it by *relaxing* the edge.

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

*Claim (positive weights):* FordSSSP terminates. When it does, every
$v.text("dist") = text("dist")(s, v)$, and every $v.text("pred")$ is the vertex before
$v$ on a shortest path, so the pred edges form a shortest-path tree. Proof idea:
- While some $v.text("dist")$ is too big, some edge is tense, so it can't stop early.
- Each $v.text("dist")$ is always the length of a real path, and it only goes down.
  There are only finitely many paths, so it can't go down forever.

See Erickson's shortest-paths chapter for more detail.

#trap[*Don't just say "run Ford's algorithm":* With a bad order of tense edges it can
take *exponential* time: one $v.text("dist")$ might drop about $2^(|V|)$ times. Graders
assume the worst order. Look at the graph's structure (cycles? a DAG?) and its weights
(all positive? all 1? some negative?), and pick the specific algorithm that fits.]

== Dijkstra's Algorithm
For *positive* weights, nothing else assumed. Two observations about FordSSSP:
+ *An edge becomes tense only when its tail's dist drops:* Dist values only decrease.
  If $u -> v$ isn't tense, lowering $v.text("dist")$ can't make it tense. Only lowering
  $u.text("dist")$ can. So, like whatever-first search, revisit $u$'s outgoing edges
  after $u.text("dist")$ drops, and not before.
+ *Relax out of the vertex with the smallest dist:* With positive weights, relaxing
  $u -> v$ gives $v.text("dist") > u.text("dist")$. So the smallest dist value can
  never go down again.

Together: keep the vertices whose dist dropped in a *priority queue*, keyed by dist.

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

The priority queue starts with only $s$, not every vertex. A vertex is inserted when
its dist first drops. As written, a vertex could even be inserted *again* after it was
extracted. With positive weights it never is (see below). Why it is written this way:
Thursday.

*Example:* Edge weights in red. Bold edges: the final pred edges, which form the
shortest-path tree:

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
#align(center, text(size: 0.85em)[Bold: the vertex is extracted and its dist is final.
The extracted dist values come out in increasing order: $0, 1, 3, 4, 7$.])

=== Running time
Let $d_i$ be the dist of the $i$th vertex extracted. Every new dist value created
after that is $d_i$ plus a *positive* weight, so it is bigger than $d_i$. Since $d_i$
was the smallest in the queue, the extracted values *strictly increase*:
$d_1 < d_2 < dots$

A vertex's dist never goes up. So if $v$ were extracted twice, its second value would
be no bigger than its first, contradicting the increasing order. *Each vertex is
extracted at most once.* So:
- at most $|V|$ Insert and $|V|$ ExtractMin operations;
- each edge is examined at most once (when its tail is extracted), so at most $|E|$
  DecreaseKey operations.

With a binary heap, each operation takes $O(log |V|)$:

$ O((|V| + |E|) log |V|) = #box(stroke: black, inset: 3pt, [$O(|E| log |V|)$]) $

The last step assumes every vertex is reachable from $s$, so $|E| >= |V| - 1$. A
simple graph has $|E| <= |V|^2$, so $log |E| <= 2 log |V|$: $log |E|$ and $log |V|$
are the same in big-$O$.
]

#show: notes
#set heading(numbering: "1.1")
#body
