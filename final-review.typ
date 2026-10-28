#import "setup.typ": *

// Living review sheet for the final. Update it with every new lecture: add rows to
// the recognition and algorithm tables, and any new recipe, connection or trap.

#let ref-table(columns, header, breakable: false, ..rows) = {
  let t = table(
    columns: columns,
    inset: (x: 8pt, y: 5pt),
    stroke: 0.5pt,
    align: left + horizon,
    table.header(..header.map(h => [*#h*])),
    ..rows,
  )
  align(center, if breakable [#t <breakable>] else { t })
}

#let body = [
= Final Review: Patterns and Connections

One place to review for the final. The lecture numbers point back to the full notes.

== Which Technique?
The most important exam skill: look at a new problem and recognize what it needs.

#ref-table(
  (1.3fr, 1.3fr, auto),
  ([If the problem...], [Try...], [See]),
  breakable: true,
  [Asks to prove a fact about strings or another recursively defined object],
  [Strong induction on the structure: $w = eps$ or $w = a x$], [Lec 01, Lab 1A],
  [Asks to describe a language by a pattern], [Regular expression], [Lab 1B],
  [Contains smaller copies of itself], [Recursion: shrink, trust, combine], [Lec 10],
  [Is easy to finish once both halves are solved], [Divide and conquer (mergesort)], [Lec 10],
  [Asks for the $k$th smallest element or the median],
  [Selection: quickselect, or median of medians for $O(n)$ worst case], [Lec 11],
  [Does arithmetic on huge $n$-digit numbers],
  [Split the digits into halves, and make as few recursive calls as possible], [Lec 12],
  [Needs a sequence of decisions (list all / find best / is it possible?)],
  [Backtracking: one decision, try every option, recurse], [Lec 12],
  [Has a sequence or string input, and you choose the next piece],
  [Backtracking with the subproblem "the suffix starting at index $i$"], [Lec 12, 13],
  [Has a backtracking recurrence whose calls repeat], [Dynamic programming], [Lec 13],
  [Splits a sequence into two independent parts, and you choose where],
  [Interval DP: subproblem = subarray $A[i .. k]$; try every split point], [Lec 15],
  [Has a rooted tree as input],
  [Tree DP: one subproblem per subtree, named by its root; evaluate in postorder], [Lec 15],
  [Is NP-hard on general graphs (such as max independent set), but the input is a tree],
  [Tree DP: decide the root (in or out), recurse on subtrees], [Lec 15],
  [Asks "can I get from here to there?" (states, configurations, moves)],
  [Build a graph whose vertices are the objects; reachability with whatever-first search], [Lec 16],
  [Is reachability or shortest paths, but you must remember extra information (steps mod $k$, a parity, a flag)],
  [Graph layering: vertices $V times {"extra info"}$; search or Dijkstra on the new graph], [Lec 17],
  [Asks for shortest paths counted in edges], [Breadth-first search (whatever-first search with a queue)], [Lec 17],
  [Asks for shortest paths with weights $>= 0$], [Dijkstra's algorithm, as a black box], [Lec 17, 18],
  [Asks whether a directed graph has a cycle (or whether a recursion terminates)],
  [DFSAll; a back edge means a cycle. Check every edge for $u.text("post") < v.text("post")$], [Lec 17, 18],
  [Asks for an order where every task comes after the tasks it needs (a DAG)],
  [Topological sort: DFSAll, then reverse the postorder], [Lec 18],
  [Asks for distances or shortest paths from one vertex],
  [Single-source shortest paths: pick the algorithm that fits the structure and the weights], [Lec 18],
)

#keyidea[*If something from class works as a black box, use it:* Sorting and then
picking the middle element is a correct $O(n log n)$ median algorithm.]

== Algorithms at a Glance
#let rt(rec, time) = [#rec \ #h(1em) $=>$ #time]
#ref-table(
  (auto, 1fr, auto),
  ([Algorithm], [Idea], [Recurrence $=>$ worst-case time]),
  breakable: true,
  [Tower of Hanoi], [Move $n - 1$ disks off, move the big disk, move $n - 1$ back],
  rt($T(n) = 2 T(n - 1) + 1$, [$2^n - 1$ moves]),
  [Mergesort], [Sort both halves, then merge], rt($T(n) = 2 T(n\/2) + O(n)$, $O(n log n)$),
  [Quicksort], [Partition around a pivot, sort both sides],
  rt($T(n) = T(n - 1) + O(n)$, $O(n^2)$),
  [Quickselect], [One-armed quicksort: recurse only on the side holding rank $k$],
  rt($T(n) = T(n - 1) + O(n)$, $O(n^2)$),
  [Median of medians], [Pivot = median of the block-of-5 medians, found recursively],
  rt($T(n) <= T(n\/5) + T(7n\/10) + O(n)$, $O(n)$),
  [Split multiply], [Split digits in half; 4 products $a c, a d, b c, b d$],
  rt($T(n) = 4 T(n\/2) + O(n)$, $O(n^2)$),
  [Karatsuba], [3 products: $a d + b c = a c + b d - (a - b)(c - d)$],
  rt($T(n) = 3 T(n\/2) + O(n)$, $O(n^(log_2 3)) approx O(n^(1.585))$),
  [RecFibo], [Straight from the definition; $phi approx 1.618$],
  rt($T(n) = T(n - 1) + T(n - 2) + 1$, $Theta(phi^n)$),
  [IterFibo], [Fill $F[0 .. n]$ left to right], rt([one loop], $O(n)$),
  [Text segmentation], [Try every first word, recurse on the suffix], rt([backtracking], [$O(2^n)$ IsWord calls]),
  [FastSplittable], [Fill $text("SplitTable")[1 .. n + 1]$ right to left], rt([two nested loops], [$O(n^2)$ IsWord calls]),
  [Woodcutting], [Try every first cut $r$; fill $text("Cutting")[i, k]$ with $i$ down, $k$ up],
  rt([$O(n^2)$ entries $times$ $O(n)$], $O(n^3)$),
  [Tree MIS], [Root in (skip children) or out (children free); postorder],
  rt([charge reads to nodes], $O(n)$),
  [Whatever-first search], [Bag of vertices; mark on removal; push all out-neighbors],
  rt([$O(|V| + |E| dot T)$], [$O(|V| + |E|)$ with a stack or queue]),
  [Useless DFA states], [Graph on states, edge per transition; unmarked by search from $s$],
  rt([$|V| = n, |E| <= 2n$], $O(n)$),
  [Breadth-first search], [Whatever-first search with a queue; shortest-path tree (edge count)],
  rt([$T = O(1)$], $O(|V| + |E|)$),
  [Dijkstra], [Extract the min-dist vertex, relax its tense out-edges; weights $> 0$],
  rt([each vertex extracted once, binary heap], $O(|E| log |V|)$),
  [DFS / DFSAll], [Recursive; check marks before calling; pre/post clock times],
  rt([each vertex and edge once], $O(|V| + |E|)$),
  [IsAcyclic], [DFSAll; a cycle exists iff some edge has $u.text("post") < v.text("post")$],
  rt([DFSAll + one pass over edges], $O(|V| + |E|)$),
  [Topological sort], [DFSAll; list vertices by decreasing $v.text("post")$],
  rt([DFSAll], $O(|V| + |E|)$),
  [FordSSSP], [Relax any tense edge until none is left (generic)],
  rt([bad order], [exponential]),
  [Walk of length $equiv 0 space (mod 3)$], [Layered graph $V times {0, 1, 2}$; can $(s, 0)$ reach $(t, 0)$?],
  rt([$|V'| = 3|V|$, $|E'| = 3|E|$], $O(|V| + |E|)$),
)

== Solving Recurrences: Recursion Trees
+ Draw one node per call. A node's value is the work in that call, *not* counting
  its children.
+ Sum each level, then look at how the level sums change from top to bottom.

#ref-table(
  (auto, auto, auto),
  ([Level sums], [Total], [Example]),
  [All equal], [level sum $times$ number of levels], [Mergesort: $n dot log_2 n$],
  [Decreasing geometric], [$O("root")$], [Median of medians: $O(n)$],
  [Increasing geometric], [$O(\# "leaves")$], [Karatsuba: $O(n^(log_2 3))$],
  [Arithmetic (not geometric)], [largest term $times$ number of terms], [Quicksort worst: $O(n^2)$],
)

Useful facts:
- Number of leaves $= (\# "calls per node")^("depth")$.
- Size multiplied by $r < 1$ each level $=>$ depth $= log_(1 slash r) n = O(log n)$.
- $a^(log_b c) = c^(log_b a)$, for example $4^(log_2 n) = n^(log_2 4) = n^2$.
- The log base, floors and ceilings don't change the big-$O$ answer.
- Unbalanced splits are fine: a tree with missing nodes still gives an upper bound.

#trap[Don't rely on a formula theorem. It only fits equal-size pieces, and median of
medians doesn't fit. Recursion trees always work.]

== Recipes
=== Induction proof (Lec 01)
+ State a *strong* inductive hypothesis explicitly ("for all $k < n$").
+ Handle *every case* of the object (for strings: $w = eps$ and $w = a x$).
+ Use the hypothesis where it helps.
+ End by noting that all cases are handled.

=== Describing an algorithm (Lec 10)
- English or pseudocode, never real code.
- Say what every function *returns*.
- Running time: give the recurrence *and* its solution.

=== Backtracking (Lec 12)
+ See the problem as a *sequence of decisions*.
+ Find the *recursive subproblem*: what the recursion fairy needs to know to finish.
+ Try *every option* for one decision, and recurse on each.
+ Pick a *base case* where no decisions are left.
+ Write it as a *recurrence* on indices, and say which call solves the problem.

=== Dynamic programming (Lec 13)
#ref-table(
  (auto, 1fr),
  ([Step], [Write down]),
  [1a. Subproblem], [English definition of what the function returns. Not how to compute it, not how it gets used.],
  [1b. Recurrence], [Including base cases.],
  [1c. Original problem], [Which call answers it, for example $text("Splittable")(1)$.],
  [2a. All subproblems], [The range of every parameter, for example $1 <= i <= n + 1$.],
  [2b. Data structure], [Usually an array, named after the function.],
  [2c. Dependencies], [Which entries each entry reads. Draw them.],
  [2d. Evaluation order], [An order where every dependency is filled first.],
  [2e. Algorithm], [Loops around the recurrence (optional on exams).],
  [2f. Running time], [(Number of subproblems) $times$ (time per subproblem).],
)

=== DP on a tree (Lec 15)
Same recipe, with these changes:
- *Subproblems* are named by nodes: "the subtree rooted at $v$".
- *Data structure:* a field on each node ($v.text("MIS")$), not an array.
- *Evaluation order:* postorder. Saying "postorder" is a complete answer.
- *Running time:* add the work over all nodes and charge each read to the child (or
  edge) being read. Don't multiply the maximum time per node by $n$.

=== Graph reduction (Lec 16)
#ref-table(
  (auto, 1fr),
  ([Step], [Write down]),
  [1. Graph], [Vertices and edges (and what they mean, if not obvious).],
  [2. Problem], [Which graph problem, and why its answer solves yours ($q$ useless $<==>$ $s$ can't reach $q$).],
  [3. Algorithm], [Which algorithm, and how to use its output ("whatever-first search from $s$; the unmarked vertices").],
  [4. Running time], [In terms of the *original input* ($n$), not $|V|$ and $|E|$.],
)

=== Graph layering (Lec 17)
+ Ask what the "ant" walking on $G$ must remember besides where it is (steps mod 3,
  a parity, whether it used something). Call that set $S$.
+ $V' = V times S$. For each edge $u -> v$ and each $i in S$, add the edge
  $(u, i) -> (v, i')$, where $i'$ is the new extra information after that step.
+ Ask a plain graph question: can $(s, "start")$ reach $(t, "goal")$? Shortest path?
+ Running time: the new graph has $|S|$ times as many vertices and edges. Give it in
  terms of the original input.

=== Shortest paths (Lec 18)
- Each vertex keeps $v.text("dist")$ (length of *some* path, or $infinity$) and
  $v.text("pred")$.
- *Tense:* $u.text("dist") + w(u -> v) < v.text("dist")$. *Relax:* set
  $v.text("dist") <- u.text("dist") + w(u -> v)$ and $v.text("pred") <- u$.
- Every algorithm is Ford's: relax tense edges until none are left. They differ in the
  order. Pick the order from the graph's structure and weights.

=== Graph representations (Lec 16)
#ref-table(
  (auto, auto, auto),
  ([Operation], [Adjacency matrix], [Adjacency list (default)]),
  [Is $u v$ an edge?], [$O(1)$], [$O(deg(u))$],
  [Neighbors of $u$], [$O(|V|)$], [$O(1)$ each],
  [Space], [$O(|V|^2)$], [$O(|V| + |E|)$],
)

== Connections
- *Recursion fairy = inductive hypothesis:* Trusting a recursive call on a smaller
  input is the same move as using the hypothesis in a strong induction proof.
- *Generalize the problem to recurse on it:* Median $->$ selection of rank $k$ (Lec
  11). Segment the string $->$ segment the suffix $A[i .. n]$ (Lec 12). Same idea as
  strengthening a hypothesis in induction.
- *Quicksort and quickselect* share `Partition`. Quickselect recurses on one side
  only, so its good-pivot tree shrinks instead of staying flat.
- *The number of recursive calls matters:* Karatsuba's 3 calls instead of 4: $n^2 ->
  n^(1.585)$. Median of medians with blocks of 5 instead of 3: $n log n -> n$.
- *Subproblems can be unexpected:* Median of medians recurses on a sample just to find
  a pivot.
- *DP = backtracking + memoization, then iteration:* Memoized Fibonacci fills its
  array left to right; IterFibo makes that order explicit. Same for FastSplittable,
  right to left.
- *A decision that splits the input into independent pieces* means you add their costs:
  left and right subplank (woodcutting), subtrees of the root (tree MIS), left and
  right halves (mergesort).
- *Woodcutting builds a binary tree:* Choosing the first cut = choosing the root. Try
  every root; don't try to be clever.
- *Split one subproblem into two to simplify the recurrence:* $text("MISyes")$ and
  $text("MISno")$ remove the grandchildren sums. Same move as generalizing a problem to
  recurse on it.
- *Evaluation order = dependencies first:* Right to left (FastSplittable), row by row
  with $i$ down and $k$ up (woodcutting), postorder (trees). Dependency graphs (Lec 16)
  make these orders explicit.
- *Vertices can be anything:* Configuration graphs (Tower of Hanoi), dependency graphs
  (Fibonacci calls), NFA/DFA state graphs. Reachability in them answers "can this
  happen?".
- *BFS, DFS, Dijkstra and Prim are the same algorithm*, whatever-first search, with a
  different bag: queue, stack, priority queue.
- *Graph layering = product construction:* New vertices = old vertices $times$ extra
  information, just like DFA states $times$ extra bits.
- *Postorder again:* Tree DP evaluates in postorder (Lec 15); DFS finish times give a
  postorder of any graph (Lec 17).
- *A recursion terminates only if its dependency graph is acyclic:* DFS finds cycles
  through back edges.
- *DFS active intervals nest or are disjoint*, because DFS uses a call stack. That is
  why a back edge is exactly an edge with $u.text("post") < v.text("post")$.
- *Topological order is the reverse of a DP evaluation order:* A dependency graph
  needs callees first: postorder. Tree DP's postorder (Lec 15) is the special case.
- *A subpath of a shortest path is a shortest path:* Same "optimal substructure" that
  makes dynamic programming work, and why shortest paths form a tree.
- *Dijkstra = whatever-first search with a priority queue*, plus relaxing.
- *Ford's framework is to shortest paths what whatever-first search is to
  reachability:* one general algorithm, many orders.
- *Same recurrence, different meaning:* RecFibo's running time satisfies the Fibonacci
  recurrence itself, so it grows like $phi^n$.

== Common Ways to Lose Points
- A loose bound "just to be safe" (such as $O(n!)$) is marked wrong. Give the bound
  your analysis produces.
- All running times are *worst case*. Quicksort is $O(n^2)$, not $O(n log n)$.
- A greedy algorithm without a proof is assumed wrong.
- Tracing inside a recursive call instead of trusting it.
- DP: missing the English subproblem definition, or a definition that says how to
  compute it.
- DP: arrays named `DP`, `OPT`, `ans` or `table`.
- DP: memoizing in a hash table instead of an array.
- Skipping steps of the DP recipe on homework and exams.
- Interval DP: both loops going the same direction. Read each direction off the
  dependency drawing ($i$ down, $k$ up for woodcutting).
- Tree DP: running time as (max time per node) $times n$. Charge reads to nodes.
- Graph reductions: saying "DFS" or "BFS" when you mean "whatever-first search".
- Graph reductions: giving the running time as $O(|V| + |E|)$ instead of in terms of
  the original input.
- Modifying the code of a search to track extra information. Build a layered graph and
  run the search unchanged.
- Dijkstra with negative edge weights.
- Saying "run Ford's algorithm" without an order: graded as exponential time.
- Back-edge test backwards: a cycle needs an edge with $u.text("post") < v.text("post")$
  (the tail finishes first).
- Topological order vs. postorder: topological order is the *reverse* of postorder.
]

#show: notes
#set heading(numbering: "1.1")
#body
