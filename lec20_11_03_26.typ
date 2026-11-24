#import "setup.typ": *

#let body = [
= Lecture 20 (Nov 3) - Bellman-Ford via Dynamic Programming, All-Pairs Shortest Paths, Floyd-Warshall

Lecture 19 solved single-source shortest paths with negative weights by layering the
graph and running DagSSSP on the result. That algorithm runs in $O(|V| |E|)$ time, and
until a few years ago no faster algorithm was known for negative weights. It also needs
a layered graph with $|V|^2$ vertices, which is far more space than the input. In this
lecture we derive the standard Bellman-Ford algorithm directly from a dynamic
programming recurrence and then simplify it until it uses only $O(|V|)$ space. The same
sequence of steps then gives several algorithms for computing the distance between
every pair of vertices, ending with the $O(|V|^3)$ Floyd-Warshall algorithm.

== Why the DAG Recurrence Fails
Let $G = (V, E)$ be a directed graph with real edge weights $w$, which may be positive,
negative, or zero, and let $s$ be a source vertex. Recall the recurrence from
Lecture 19, where $text("distance")(v)$ is the distance from $s$ to $v$:

$ text("distance")(v) = cases(
  0 & "if" v = s,
  display(min_(u -> v)) (text("distance")(u) + w(u -> v)) & "otherwise",
) $

The recurrence is correct for every graph without negative cycles, but in a DAG it is
also an algorithm, because its dependency graph is the reversal of $G$. If $v$ lies on
a directed cycle, then computing $text("distance")(v)$ requires the distance to the
previous vertex on the cycle, which requires the distance to the vertex before that,
and eventually requires $text("distance")(v)$ itself. The dependency graph contains the
reversal of every cycle of $G$, so the recursion never bottoms out.

For recursion (or induction) to work, some parameter must move toward a base case at
every recursive call. Following the idea of Lecture 19, we add a parameter that counts
the edges of a walk.

== Bellman's Recurrence
Let $text("dist")_(<= i)(v)$ be the length of the shortest walk from $s$ to $v$ that
uses at most $i$ edges. Lecture 19 counted walks with exactly $i$ edges. Allowing at
most $i$ edges makes the algorithms below simpler.

If $G$ has no negative cycle, some shortest walk from $s$ to $v$ is a simple path, and a
simple path has at most $|V| - 1$ edges. A walk with more edges repeats a vertex, and
removing the cycle between the two visits does not make the walk longer. Therefore

$ text("dist")(s, v) = text("dist")_(<= |V| - 1)(v). $

Now consider a shortest walk from $s$ to $v$ with at most $i$ edges, where $i >= 1$.
There are two possibilities.
- The walk uses at most $i - 1$ edges. Then its length is
  $text("dist")_(<= i - 1)(v)$.
- The walk uses exactly $i$ edges. Then it has a last edge $u -> v$, and the part before
  that edge is a walk from $s$ to $u$ with at most $i - 1$ edges. We do not know which
  edge is last, so we try every edge into $v$.

When $i = 0$, the only walk with no edges is the empty walk from $s$ to itself, of
length $0$. Any other vertex gets the default value $infinity$, meaning that no such
walk exists. Combining the cases gives

$ text("dist")_(<= i)(v) = cases(
  0 & "if" i = 0 "and" v = s,
  infinity & "if" i = 0 "and" v != s,
  min(text("dist")_(<= i - 1)(v), space display(min_(u -> v)) (text("dist")_(<= i - 1)(u) + w(u -> v))) & "otherwise",
) $

The recurrence holds even if $G$ has negative cycles, for every $i$, including values
such as $i = |V|^2$. Only the equation
$text("dist")(s, v) = text("dist")_(<= |V| - 1)(v)$ needs the assumption that there is
no negative cycle.

Lecture 19's layered graph could have been built to match this recurrence more closely.
Adding a zero-weight edge $(v, i - 1) -> (v, i)$ from each vertex to its own copy in the
next layer turns "exactly $i$ edges" into "at most $i$ edges."

=== Bellman's algorithm
Every recursive call decreases $i$, and $i$ cannot go below $0$, so the recurrence can
be evaluated directly. We store the values in an array $text("dist")[i, v]$ indexed by
$0 <= i <= |V| - 1$ and by the vertices themselves. Because every entry for $i$ depends
only on entries for $i - 1$, the outer loop goes from small $i$ to large $i$, and the
vertices within one value of $i$ can be handled in any order. The base cases are written
outside the main loop. This dynamic programming algorithm is due to Bellman.

```
BellmanSSSP(s):
  dist[0, s] ← 0
  for every vertex v ≠ s
    dist[0, v] ← ∞
  for i ← 1 to |V| − 1
    for every vertex v
      dist[i, v] ← dist[i − 1, v]
      for every edge u → v
        if dist[i, v] > dist[i − 1, u] + w(u → v)
          dist[i, v] ← dist[i − 1, u] + w(u → v)
  for every vertex v
    v.dist ← dist[|V| − 1, v]
```

The last loop stores the final distances in the usual $v.text("dist")$ variables.

There are $|V| - 1$ values of $i$. For one value of $i$, the algorithm visits every
vertex and every edge into that vertex, so it examines each edge of $G$ once, in
$O(|E|)$ time if every vertex is reachable from $s$. The total time is $O(|V| |E|)$, the
same as layered Bellman-Ford. The array holds $|V|^2$ entries, so the space is
$O(|V|^2)$, which is better than the $O(|V| |E|)$ edges of the layered graph but still
more than necessary.

== From Bellman's Algorithm to Bellman-Ford
Three small changes turn BellmanSSSP into the algorithm usually presented as
Bellman-Ford. None of them changes the asymptotic running time, but together they
reduce the space to $O(|V|)$.

=== Change 1: pull the edge loop out
For a fixed $i$, every edge $u -> v$ is examined exactly once. As long as all the
assignments $text("dist")[i, v] <- text("dist")[i - 1, v]$ happen before any edge is
examined, the edges can be processed in any order. So we move the edge loop out by one
level:

```
  for i ← 1 to |V| − 1
    for every vertex v
      dist[i, v] ← dist[i − 1, v]
    for every edge u → v
      if dist[i, v] > dist[i − 1, u] + w(u → v)
        dist[i, v] ← dist[i − 1, u] + w(u → v)
```

=== Change 2: use the current row
In the edge loop we replace $text("dist")[i - 1, u]$ by $text("dist")[i, u]$:

```
    for every edge u → v
      if dist[i, v] > dist[i, u] + w(u → v)
        dist[i, v] ← dist[i, u] + w(u → v)
```

When the edge loop runs, $text("dist")[i, u]$ has already been set to
$text("dist")[i - 1, u]$ and can only have decreased since. So each sum is no larger
than before, and the algorithm can only find smaller values. Each value is still the
length of an actual walk from $s$ (or $infinity$), because it is always some stored
value plus the weight of one more edge. After this change, $text("dist")[i, v]$ is no
longer exactly $text("dist")_(<= i)(v)$. The algorithm maintains two inequalities:

$ text("dist")(s, v) <= text("dist")[i, v] <= text("dist")_(<= i)(v). $

The left inequality holds because every stored value is the length of some walk, and
with no negative cycles no walk is shorter than the distance. The right inequality
follows by induction on $i$, because every option in the recurrence for
$text("dist")_(<= i)(v)$ is still considered, now with values that are at most as
large. At $i = |V| - 1$ both ends equal $text("dist")(s, v)$, so the output is correct.

=== Change 3: drop the row index
The loop over vertices now only copies the previous row into the new row without
modifying it. We drop the first index entirely and write directly over the previous
row. The variables become $v.text("dist")$, the edge test asks whether $u -> v$ is
tense, and the update is a relaxation. The index $i$ is no longer used, so the outer
loop becomes "repeat $|V| - 1$ times." Adding the negative-cycle check from Lecture 19
gives the final algorithm:

```
BellmanFord(s):
  InitSSSP(s)
  repeat |V| − 1 times
    for every edge u → v
      if u → v is tense
        Relax(u → v)
  for every edge u → v
    if u → v is tense
      return "Negative cycle!"
```

If there is no negative cycle, the values are the true distances when the repeat loop
ends, and no edge is tense. If a negative cycle is reachable from $s$, some edge is
tense, by the argument in Lecture 19. Each round examines every edge once, so the
running time is $O(|V| |E|)$, and the algorithm stores only $O(|V|)$ values.

#keyidea[Bellman-Ford is Bellman's dynamic programming algorithm with the edge loop
pulled out, the current row used in place of the previous one, and the row index
dropped. Seen without this derivation, it is hard to tell why $|V| - 1$ rounds of
relaxing every edge give the correct distances.]

*Example (not from lecture):* Take the path $s -> a -> b -> c$ with weights $2$, $-1$,
and $3$, and suppose the edge loop examines the edges in that order. In BellmanSSSP,
row $1$ finds only $text("dist")[1, a] = 2$, and $c$ is not reached until row $3$. In
BellmanFord, the first round relaxes $s -> a$, then $a -> b$ using the new value of $a$,
then $b -> c$, so after one round $a = 2$, $b = 1$, and $c = 4$. The remaining rounds
change nothing. So after the first round $c.text("dist") = 4$ while
$text("dist")_(<= 1)(c) = infinity$, a strict case of the inequality above.

== All-Pairs Shortest Paths
In the *all-pairs shortest path* problem we are given a directed graph $G$ with edge
weights and must compute $text("dist")(u, v)$, the distance from $u$ to $v$, for every
pair of vertices $u$ and $v$. A table of distances between major cities on a paper road
map is the output of this problem.

One solution runs a single-source algorithm once from every vertex. Call a graph
*dense* if $|E| = Theta(|V|^2)$.
- With positive weights, running Dijkstra's algorithm from each vertex takes
  $O(|V| dot |E| log |V|)$ time, which is $O(|V|^3 log |V|)$ for a dense graph.
- With negative weights but no negative cycle, running Bellman-Ford from each vertex
  takes $O(|V| dot |V| |E|) = O(|V|^2 |E|)$ time, which is $O(|V|^4)$ for a dense graph.

Erickson's textbook describes Johnson's algorithm, which runs Bellman-Ford once and
uses the result to reweight the edges so that every weight becomes nonnegative while
shortest paths stay the same. It then runs Dijkstra's algorithm from every vertex. We
do not cover it here. Instead we design all-pairs algorithms by dynamic programming.

The single-source recurrence carries over with the source as a variable:
$text("dist")(u, u) = 0$, and otherwise $text("dist")(u, v)$ is the minimum of
$text("dist")(u, x) + w(x -> v)$ over all edges $x -> v$. It fails on general graphs for
the same reason as before, since cycles in $G$ give cycles in the dependency graph. As
before, we add a parameter that counts edges.

== Shimbel's Algorithm
Let $text("dist")(u, v, ell)$ be the length of the shortest walk from $u$ to $v$ with
at most $ell$ edges. The reasoning is the same as for Bellman's recurrence, with the
source $u$ now allowed to vary. The shortest such walk either has at most $ell - 1$
edges, or it has a last edge $x -> v$ preceded by a walk from $u$ to $x$ with at most
$ell - 1$ edges:

$ text("dist")(u, v, ell) = cases(
  0 & "if" ell = 0 "and" v = u,
  infinity & "if" ell = 0 "and" v != u,
  min(text("dist")(u, v, ell - 1), space display(min_(x -> v)) (text("dist")(u, x, ell - 1) + w(x -> v))) & "otherwise",
) $

The parameter $ell$ always decreases, so the outer loop goes over $ell$ in increasing
order, and the pairs $u, v$ can be handled in any order. This algorithm was proposed by
Shimbel in 1954.

```
ShimbelAPSP(V, E, w):
  for all vertices u
    for all vertices v
      if u = v
        dist[u, v, 0] ← 0
      else
        dist[u, v, 0] ← ∞
  for ℓ ← 1 to |V| − 1
    for all vertices u
      for all vertices v
        dist[u, v, ℓ] ← dist[u, v, ℓ − 1]
        for every edge x → v
          if dist[u, v, ℓ] > dist[u, x, ℓ − 1] + w(x → v)
            dist[u, v, ℓ] ← dist[u, x, ℓ − 1] + w(x → v)
```

The three changes from Bellman-Ford apply here too. Pulling the edge loop out, using
current values, and dropping $ell$ gives

```
ShimbelAPSP(V, E, w):
  for all vertices u
    for all vertices v
      dist[u, v] ← 0 if u = v, ∞ otherwise
  repeat |V| − 1 times
    for every vertex u
      for every edge x → v
        if dist[u, v] > dist[u, x] + w(x → v)
          dist[u, v] ← dist[u, x] + w(x → v)
```

There are $|V| - 1$ rounds, each examining $|V|$ sources and $|E|$ edges, so the running
time is $O(|V|^2 |E|)$, or $O(|V|^4)$ for a dense graph. This is no improvement over
running Bellman-Ford from every vertex, and that is expected: the algorithm is
Bellman-Ford from every vertex, with the loops interleaved. It computes shortest paths
out of each source separately and never uses the fact that it knows shortest walks out
of every vertex at once.

== Fischer and Meyer: Guessing the Middle Vertex
To use the other sources' answers, we guess a vertex $x$ in the middle of the walk
instead of its last edge. The walk then splits into a walk from $u$ to $x$ and a walk
from $x$ to $v$, each with about half as many edges, and both are subproblems we are
solving anyway.

From here on we assume that $w(u -> v) = infinity$ whenever $u -> v$ is not an edge, so
that we can loop over all pairs of vertices. An adjacency matrix with $infinity$ in the
missing entries stores exactly this function.

If $ell = 1$, a walk from $u$ to $v != u$ must be the edge $u -> v$ itself. Otherwise a
walk with at most $ell$ edges splits at its middle vertex $x$ into two walks with at
most $ell \/ 2$ edges each, so

$ text("dist")(u, v, ell) = cases(
  0 & "if" v = u,
  w(u -> v) & "if" ell = 1 "and" v != u,
  display(min_x) (text("dist")(u, x, ell \/ 2) + text("dist")(x, v, ell \/ 2)) & "otherwise",
) $

where the minimum is over all vertices $x$.

The parameter $ell$ is halved at every call. To simplify, assume that $|V| - 1$ is a
power of $2$. Starting from $ell = |V| - 1$, the recursion asks for
$ell = (|V| - 1) \/ 2$, then $(|V| - 1) \/ 4$, then $(|V| - 1) \/ 8$, and so on. So only
$O(log |V|)$ values of $ell$ ever appear, all of them powers of $2$. In general we
round up and use $ell = 2^i$ for $0 <= i <= ceil(lg |V|)$, since $2^(ceil(lg |V|))$ is
at least $|V| - 1$ and extra allowed edges do not change a distance when there is no
negative cycle. We index the table by $i$, so that $ell \/ 2$ becomes $i - 1$, and we
solve the subproblems in increasing order of $i$. Erickson calls the result
FischerMeyerAPSP.

```
FischerMeyerAPSP(V, E, w):
  for all vertices u
    for all vertices v
      dist[u, v, 0] ← w(u → v)        ⟨⟨ℓ = 1, with w(v → v) = 0⟩⟩
  for i ← 1 to ⌈lg |V|⌉               ⟨⟨ℓ = 2^i⟩⟩
    for all vertices u
      for all vertices v
        dist[u, v, i] ← ∞
        for all vertices x
          if dist[u, v, i] > dist[u, x, i − 1] + dist[x, v, i − 1]
            dist[u, v, i] ← dist[u, x, i − 1] + dist[x, v, i − 1]
```

This algorithm mixes divide and conquer with dynamic programming: the recurrence halves
the problem, but the subproblems are shared and stored in a table. As before, we can
drop the index $i$ and update a single $|V| times |V|$ table in place:

```
FischerMeyerAPSP(V, E, w):
  for all vertices u
    for all vertices v
      dist[u, v] ← w(u → v)
  repeat ⌈lg |V|⌉ times
    for all vertices u
      for all vertices v
        for all vertices x
          if dist[u, v] > dist[u, x] + dist[x, v]
            dist[u, v] ← dist[u, x] + dist[x, v]
```

Each round takes $O(|V|^3)$ time, and there are only $ceil(lg |V|)$ rounds, so the
total time is $O(|V|^3 log |V|)$. For dense graphs this matches running Dijkstra's
algorithm from every vertex, and it works with negative edges.

== Floyd-Warshall
We can do better without any new tools by changing what the extra parameter restricts.
The earlier algorithms limit the number of edges in a walk; here we limit which
vertices may appear in the middle of a path.

Number the vertices $1, 2, dots, |V|$. A path *passes through* a vertex $x$ if it enters
$x$ and then leaves $x$, so that $x$ is neither its first nor its last vertex. Define
$text("dist")(u, v, r)$ to be the length of the shortest path from $u$ to $v$ that
passes through only vertices numbered at most $r$.

Consider such a shortest path from $u$ to $v$. The two cases now depend on whether the
path passes through vertex $r$.
- If it does not, it passes through only vertices numbered $1$ through $r - 1$, and its
  length is $text("dist")(u, v, r - 1)$.
- If it does, it visits $r$ once. The part from $u$ to $r$ and the part from $r$ to $v$
  pass through only vertices numbered $1$ through $r - 1$, since vertex $r$ itself is an
  endpoint of both parts.

There is nothing to guess beyond which of the two cases holds. When $r = 0$, no vertex
is numbered between $1$ and $0$, so the path cannot pass through anything and must be
the direct edge $u -> v$. With $w(v -> v) = 0$ for the empty path, the recurrence is

$ text("dist")(u, v, r) = cases(
  w(u -> v) & "if" r = 0,
  min(text("dist")(u, v, r - 1), space text("dist")(u, r, r - 1) + text("dist")(r, v, r - 1)) & "otherwise".
) $

Every path may pass through every vertex when $r = |V|$, so
$text("dist")(u, v) = text("dist")(u, v, |V|)$. The third parameter decreases at every
call, so we evaluate in increasing order of $r$, and the pairs $u, v$ may go in any
order. The result is a triply nested loop over the vertices with constant work inside,
which takes $O(|V|^3)$ time.

This structure is due to Kleene, who used it in 1951 to convert NFAs into regular
expressions. The last step of the proof of Kleene's theorem, from an NFA to a regular
expression, runs this same dynamic program and builds more and more complicated regular
expressions between pairs of states of the NFA.

Dropping the third parameter as before gives the algorithm commonly called
*Floyd-Warshall*:

```
FloydWarshall(V, E, w):
  for all vertices u
    for all vertices v
      dist[u, v] ← w(u → v)
  for all vertices r
    for all vertices u
      for all vertices v
        if dist[u, v] > dist[u, r] + dist[r, v]
          dist[u, v] ← dist[u, r] + dist[r, v]
```

For each $r$, every pair checks whether the path through $r$ is shorter and updates its
distance if it is. Updating in place is safe for the same reason as in Bellman-Ford:
values only decrease and are always lengths of real walks. Moreover, during round $r$
the entries $text("dist")[u, r]$ and $text("dist")[r, v]$ do not change, because
$text("dist")[r, r] = 0$ when there is no negative cycle. The table uses $O(|V|^2)$
space.

#trap[The loop over $r$ must be the outermost loop, because $r$ is the parameter that
decreases in the recurrence. The loops over $u$ and $v$ may be swapped. With $r$ innermost,
the loops perform a single round of the in-place FischerMeyerAPSP, which is not enough
in general.]

*Example (not from lecture):* Run FloydWarshall on the graph below. Its cycles,
$1 -> 2 -> 3 -> 4 -> 1$ (weight $4$) and $1 -> 3 -> 4 -> 1$ (weight $9$), are positive.

#let fw-w = (("1", "2", $3$), ("1", "3", $6$), ("2", "3", $-2$), ("3", "4", $2$), ("4", "1", $1$))
#let fw-get(e) = fw-w.find(((u, v, _)) => (u, v) == e).at(2)
#align(center, graph-pic(
  ("1": (0, 0), "2": (2.2, 0), "3": (2.2, 1.6), "4": (0, 1.6)),
  fw-w.map(((u, v, _)) => (u, v)),
  directed: true,
  weight: fw-get,
  unit: 50pt,
))

#let fw-mat(rows) = table(
  columns: 5,
  inset: (x: 8pt, y: 4pt),
  stroke: 0.5pt,
  align: center,
  table.header([], [$1$], [$2$], [$3$], [$4$]),
  ..rows.enumerate().map(((i, row)) => ([$#(i + 1)$], ..row)).flatten(),
)
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  stack(spacing: 6pt, fw-mat((
    ([$0$], [$3$], [$6$], [$infinity$]),
    ([$infinity$], [$0$], [$-2$], [$infinity$]),
    ([$infinity$], [$infinity$], [$0$], [$2$]),
    ([$1$], [$infinity$], [$infinity$], [$0$]),
  )), text(size: 0.85em)[Before round $1$ ($r = 0$)]),
  stack(spacing: 6pt, fw-mat((
    ([$0$], [$3$], [$1$], [$3$]),
    ([$1$], [$0$], [$-2$], [$0$]),
    ([$3$], [$6$], [$0$], [$2$]),
    ([$1$], [$4$], [$2$], [$0$]),
  )), text(size: 0.85em)[After round $4$: all distances]),
))
#align(center, text(size: 0.85em)[Row $u$, column $v$ holds $text("dist")[u, v]$.])

#align(center, table(
  columns: 2,
  inset: (x: 9pt, y: 4pt),
  stroke: 0.5pt,
  align: (center, left),
  table.header([*Round*], [*Entries that change (via $r$)*]),
  [$r = 1$], [$[4, 2]$: $infinity -> 1 + 3 = 4$; $[4, 3]$: $infinity -> 1 + 6 = 7$],
  [$r = 2$], [$[1, 3]$: $6 -> 3 - 2 = 1$; $[4, 3]$: $7 -> 4 - 2 = 2$],
  [$r = 3$], [$[1, 4]$: $infinity -> 1 + 2 = 3$; $[2, 4]$: $infinity -> -2 + 2 = 0$],
  [$r = 4$], [$[2, 1]$: $infinity -> 0 + 1 = 1$; $[3, 1]$: $infinity -> 2 + 1 = 3$; $[3, 2]$: $infinity -> 3 + 3 = 6$],
))

For instance, the final entry $[3, 2] = 6$ is the path $3 -> 4 -> 1 -> 2$, which passes
through vertices $4$ and $1$, so it appears only once $r = 4$.

== Summary
#align(center, table(
  columns: 3,
  inset: (x: 9pt, y: 5pt),
  stroke: 0.5pt,
  align: (left, left, center),
  table.header([*Algorithm*], [*Weights*], [*Time (dense graph)*]),
  [Dijkstra from every vertex], [positive], [$O(|V| |E| log |V|)$ ($O(|V|^3 log |V|)$)],
  [Bellman-Ford from every vertex], [no negative cycle], [$O(|V|^2 |E|)$ ($O(|V|^4)$)],
  [Shimbel], [no negative cycle], [$O(|V|^2 |E|)$ ($O(|V|^4)$)],
  [Fischer-Meyer], [no negative cycle], [$O(|V|^3 log |V|)$],
  [Floyd-Warshall], [no negative cycle], [$O(|V|^3)$],
))

As with single-source shortest paths, use the fastest algorithm that fits the weights
and structure of the graph at hand. On exams, the algorithms of this lecture appear as
black boxes inside reductions, as in the homework. Their internals are not needed, but
it can be useful to know that all-pairs shortest paths can be computed in $O(|V|^3)$
time even with negative edges. Both single-source and all-pairs shortest paths have
seen faster algorithms in recent research, which this course does not cover.
]

#show: notes
#set heading(numbering: "1.1")
#body
