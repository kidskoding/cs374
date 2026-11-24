#import "setup.typ": *

#let ans(body) = block(
  width: 100%,
  stroke: 0.5pt + luma(150),
  inset: (x: 12pt, y: 10pt),
  radius: 3pt,
  above: 1.2em,
  below: 1.2em,
  body,
)
#let blank = box(width: 4em, stroke: (bottom: 0.5pt), height: 0.9em)

#let body = [
= Midterm 2 Crash Course

Lectures 10–19 in one sitting. Read it in order. Cover each model answer, write
your own, then compare. The full tables live in the Final Review appendix.

== The Game Plan
Exams here are graded with rubrics. Most of the points come from *writing the
right structure*, not from a perfect final answer.

+ *First pass, 10 minutes:* for every problem, decide its type (table below) and
  write that type's template skeleton. Don't solve anything yet.
+ *Second pass:* fill in the skeleton you understand best first.
+ *Never leave a part blank.* The rubric gives no credit for "I don't know", but the
  English description alone is worth 3 of 10 points.
+ *Always give a running time.* It is easy points, and a missing one loses them.

#align(center, table(
  columns: (1.3fr, 1fr, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  align: left + horizon,
  table.header([*If the problem...*], [*It is...*], [*Template*]),
  [gives a recurrence, or asks "how fast is this recursion?"], [a recurrence], [@cc-rec],
  [asks for the $k$th smallest, a median, or huge-number arithmetic], [divide and conquer], [@cc-dc],
  [asks for the best / number of ways / is it possible, over choices], [dynamic programming], [@cc-dp],
  [asks "can I get from here to there?" or for a shortest path], [a graph problem], [@cc-graph],
))

== Recurrences <cc-rec>
#keyidea[Draw a *recursion tree*. Add up each level. Look at how the level sums change.]

#align(center, table(
  columns: (auto, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Level sums...*], [*Total*]),
  [stay the same], [(one level) $times$ (number of levels, usually $log n$)],
  [shrink (geometric)], [the root],
  [grow (geometric)], [the leaves: $("calls per node")^("depth")$],
))

*Drill.* Cover the right column.
#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  table.header([*Recurrence*], [*Level sums*], [*Answer*]),
  [$T(n) = 2T(n\/2) + n$], [$n, n, n, dots$ (same)], [$O(n log n)$],
  [$T(n) = T(n\/2) + n$], [$n, n\/2, n\/4, dots$ (shrink)], [$O(n)$],
  [$T(n) = 3T(n\/2) + n$], [$n, 3n\/2, 9n\/4, dots$ (grow)], [$O(3^(log_2 n)) = O(n^(log_2 3))$],
  [$T(n) = 2T(n\/2) + 1$], [$1, 2, 4, dots$ (grow)], [$O(2^(log_2 n)) = O(n)$],
  [$T(n) = 4T(n\/2) + n^2$], [$n^2, n^2, n^2, dots$ (same)], [$O(n^2 log n)$],
))

== Divide and Conquer <cc-dc>
- *Use black boxes from class.* Sorting is $O(n log n)$. Selection (the $k$th
  smallest, or the median) is $O(n)$ with median of medians. You don't re-derive them.
- *Template:* split the input, trust the recursion fairy on the pieces, combine. Say
  what each call *returns*. Give the recurrence *and* its solution.
- Running times are *worst case*: quicksort and quickselect are $O(n^2)$.

== Dynamic Programming <cc-dp>
#keyidea[*One question writes every recurrence:* make one decision, try every option,
and for each option ask "after this choice, where am I allowed to continue?" That
position goes inside the recursive call.]

=== Which kind of subproblem?
#align(center, table(
  columns: (auto, auto, 1fr),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  align: left + horizon,
  table.header([*Input*], [*Subproblem*], [*The one decision*]),
  [one array or string], [$F(i)$ for suffix $A[i .. n]$], [take $A[i]$ or skip it; or which piece starts at $i$ (Lec 12, 13)],
  [a sequence you split in two], [$F(i, k)$ for $A[i .. k]$], [where to split, try every point (Lec 15)],
  [a rooted tree], [$F(v)$ for the subtree at $v$], [is $v$ in or out? (Lec 15)],
  [a DAG], [$F(v)$ for vertex $v$], [which edge leaves (or enters) $v$ (Lec 19)],
))

=== Skeleton (copy this onto the exam)
#ans[
  *Subproblem.* $F(#blank) =$ #blank (what it *returns*, in English) \
  *Recurrence.* $F(#blank) = cases(#blank & "base case", #blank & "otherwise")$ \
  *Answer.* Call $F(#blank)$. \
  *Memoize.* Array $F[#blank]$. Each entry reads #blank, so fill #blank. \
  *Time.* (number of entries) $times$ (time per entry) $=$ #blank.
]

=== Model answer
*Problem.* Given $A[1 .. n]$, choose numbers with no two adjacent, maximizing their sum.

#ans[
  *Subproblem.* $text("MaxSum")(i)$ = the largest sum of non-adjacent elements of
  $A[i .. n]$. \
  *Recurrence.*
  $ text("MaxSum")(i) = cases(
    0 & "if" i > n,
    max{text("MaxSum")(i + 1), A[i] + text("MaxSum")(i + 2)} & "otherwise"
  ) $
  Skipping $A[i]$ continues at $i + 1$. Taking it bans $i + 1$, so it continues at $i + 2$. \
  *Answer.* $text("MaxSum")(1)$. \
  *Memoize.* Array $text("MaxSum")[1 .. n + 2]$. Entry $i$ reads entries $i + 1$ and
  $i + 2$, so fill $i$ from $n + 2$ down to $1$. \
  *Time.* $O(n)$ entries $times$ $O(1)$ each $= O(n)$.
]

#trap[Name the array after the function, never `DP` or `OPT`. Use an array, not a
hash table. Tree DP: evaluate in postorder, and charge each read to the child it reads,
not (max time per node) $times n$.]

== Graphs <cc-graph>
#keyidea[Don't invent a new algorithm. *Build a graph, then run one from class
unchanged.* If the walker must remember something extra (steps mod $k$, a flag),
make the vertices pairs $(v, "extra")$.]

=== Which algorithm?
#align(center, table(
  columns: (1.4fr, auto, auto),
  inset: (x: 8pt, y: 5pt),
  stroke: 0.5pt,
  align: left + horizon,
  table.header([*The question*], [*Algorithm*], [*Time*]),
  [Can $s$ reach $t$?], [whatever-first search], [$O(|V| + |E|)$],
  [Fewest edges from $s$], [BFS], [$O(|V| + |E|)$],
  [Shortest path, weights $>= 0$], [Dijkstra], [$O(|E| log |V|)$],
  [Shortest path in a DAG, any weights], [DagSSSP (topological order)], [$O(|V| + |E|)$],
  [Negative weights, no negative cycle], [Bellman-Ford], [$O(|V| |E|)$],
  [Is there a cycle?], [DFS: an edge with $u.text("post") < v.text("post")$], [$O(|V| + |E|)$],
  [Order tasks so each comes after what it needs], [topological sort: reverse postorder], [$O(|V| + |E|)$],
))

=== Skeleton (copy this onto the exam)
#ans[
  *Vertices.* One per #blank. \
  *Edges.* $u -> v$ whenever #blank (weight #blank). \
  *Problem.* The answer is yes / the length of #blank in this graph, because #blank. \
  *Algorithm.* Run #blank from #blank; return #blank. \
  *Time.* $|V| =$ #blank, $|E| =$ #blank, so #blank in terms of the *original* input.
]

=== Model answer
*Problem.* Given a directed graph $G$ and vertices $s, t$, decide whether there is a
walk from $s$ to $t$ whose number of edges is a multiple of 3.

#ans[
  *Vertices.* $(v, r)$ for every vertex $v$ and $r in {0, 1, 2}$: "at $v$, having taken
  $r$ edges mod 3". \
  *Edges.* For every edge $u -> v$ of $G$ and every $r$: $(u, r) -> (v, (r + 1) mod 3)$. \
  *Problem.* The walk exists if and only if $(s, 0)$ can reach $(t, 0)$. \
  *Algorithm.* Whatever-first search from $(s, 0)$; return whether $(t, 0)$ is marked. \
  *Time.* $3|V|$ vertices and $3|E|$ edges, so $O(|V| + |E|)$.
]

#trap[Dijkstra breaks with negative edges. Topological order is the *reverse* of
postorder. Give running times in terms of the original input, not the new graph.]

== Last Ten Minutes Before the Exam
- Recursion tree: add level by level; same, shrink, or grow.
- DP: subproblem in English, recurrence + base case, answer call, array + fill order, time.
- Graph: vertices, edges, which algorithm, time in terms of the input.
- Extra memory while walking a graph: pair it with the vertex.
- Never blank. Always a running time.
]

#show: notes
#set heading(numbering: "1.1")
#body
