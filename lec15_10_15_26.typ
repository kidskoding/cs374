#import "setup.typ": *

// Small tree drawn from explicit node positions. `nodes` maps an id to
// (x: column, y: depth, label: content, fill: optional color); `edges` lists
// (parent id, child id) pairs.
#let tree-pic(nodes, edges, unit: 40pt, row: 40pt, nw: 30pt, nh: 18pt) = {
  let vs = nodes.values()
  let width = unit * (calc.max(..vs.map(v => v.x)) + 1)
  let depth = calc.max(..vs.map(v => v.y))
  let px(x) = unit * (x + 0.5)
  let py(y) = row * y + nh / 2
  box(width: width, height: row * depth + nh, {
    for (a, b) in edges {
      let p = nodes.at(a)
      let c = nodes.at(b)
      place(line(start: (px(p.x), py(p.y) + nh / 2), end: (px(c.x), py(c.y) - nh / 2), stroke: 0.5pt + luma(130)))
    }
    for v in vs {
      place(dx: px(v.x) - nw / 2, dy: py(v.y) - nh / 2, box(
        width: nw,
        height: nh,
        radius: 2pt,
        fill: v.at("fill", default: accent-light),
        stroke: 0.5pt + accent,
        align(center + horizon, text(size: 0.75em, v.label)),
      ))
    }
  })
}

// Plank drawn to scale: one box per final piece, with the mark positions underneath.
#let plank(lens, unit: 24pt) = {
  let total = lens.sum()
  let starts = range(lens.len()).map(i => lens.slice(0, i).sum(default: 0))
  align(center, box(width: total * unit, height: 32pt, {
    for (i, l) in lens.enumerate() {
      place(dx: starts.at(i) * unit, box(
        width: l * unit,
        height: 18pt,
        fill: rgb("#e8d3a9"),
        stroke: 0.6pt + rgb("#8b6b3d"),
        align(center + horizon, text(size: 0.8em)[#l]),
      ))
    }
    for p in starts + (total,) {
      place(dx: p * unit - 6pt, dy: 21pt, box(width: 12pt, align(center, text(size: 0.7em, fill: luma(90))[#p])))
    }
  }))
}

// Upper-triangular table indexed by row i and column k. `val(i, k)` gives the cell
// content, `hl(i, k)` its highlight color (or none).
#let tri-table(n, val: (i, k) => [], hl: (i, k) => none, size: 1.9em) = align(center, block(breakable: false, grid(
  columns: (size,) * (n + 1),
  rows: 1.6em,
  align: center + horizon,
  stroke: (x, y) => if x == 0 or y == 0 { none } else { 0.5pt },
  fill: (x, y) => if x == 0 or y == 0 { none } else if y > x { luma(225) } else {
    let c = hl(y, x)
    if c == none { white } else { c }
  },
  ..range(n + 1).map(y => range(n + 1).map(x => {
    if x == 0 and y == 0 { text(size: 0.7em)[$i backslash k$] }
    else if y == 0 { text(size: 0.75em, fill: accent)[#x] }
    else if x == 0 { text(size: 0.75em, fill: accent)[#y] }
    else if y > x { [] }
    else { text(size: 0.85em, val(y, x)) }
  })).flatten(),
)))

#let body = [
= Lecture 15 (Oct 15) - Dynamic Programming on Trees: Woodcutting, Maximum Independent Set

So far, dynamic programming has read one or two arrays from one end to the other.
Today the recursion has a different shape: it builds a *tree*. This is the last
lecture on dynamic programming for its own sake.

#keyidea[*Make one decision, and the rest splits into independent pieces:* Solve each
piece recursively and add up the costs. Woodcutting splits a plank into two
subplanks. Independent set splits a tree into its subtrees.]

== Woodcutting
=== The problem
A plank of wood has $n - 1$ marks on it. It must be cut at every mark, and only at
the marks, into $n$ final pieces. Only one company owns a saw big enough. It does
*one cut at a time* and charges the *length of the plank it is cutting*. Each cut
gives two smaller planks, which you hand back for more cuts.

*Input:* an array $text("Len")[1 .. n]$ of the final piece lengths, in order from left
to right. *Output:* the minimum total cost to make all the cuts.

*Example:* A plank of length 10 with marks at 2, 3 and 6, so $n = 4$ and
$text("Len") = [2, 1, 3, 4]$:

#plank((2, 1, 3, 4))

The first cut always costs \$10, whichever mark it uses. After that, the order
matters:

#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: (left, left, right),
  table.header([*Strategy*], [*Cuts, in order (plank length paid)*], [*Total*]),
  [Left to right], [at 2 (10), at 3 (8), at 6 (7)], [\$25],
  [Middle first], [at 3 (10), then at 2 (3) and at 6 (7)], [\$20],
  [Right to left], [at 6 (10), at 3 (6), at 2 (3)], [*\$19*],
))

#trap[*The most balanced cut is not always best:* Right to left wins here: the long
piece of length 4 is cut off first, so you stop paying for it early.]

=== Part 1: Formulate recursively
*Decision:* where to make the first cut. It costs the length of the whole plank. It
leaves a left subplank and a right subplank, and these are *independent* problems:
how you cut one does not change the cost of the other.

The cuts form a *binary tree*. The root is the whole plank, and its two children are
the two subplanks. Choosing the first cut means choosing the root. The optimal
strategy for the example:

#align(center, tree-pic(
  (
    a: (x: 2.125, y: 0, label: [$[1 .. 4]$ \$10]),
    b: (x: 1.25, y: 1, label: [$[1 .. 3]$ \$6]),
    c: (x: 3, y: 1, label: [4], fill: white),
    d: (x: 0.5, y: 2, label: [$[1 .. 2]$ \$3]),
    e: (x: 2, y: 2, label: [3], fill: white),
    f: (x: 0, y: 3, label: [2], fill: white),
    g: (x: 1, y: 3, label: [1], fill: white),
  ),
  (("a", "b"), ("a", "c"), ("b", "d"), ("b", "e"), ("d", "f"), ("d", "g")),
  unit: 60pt, row: 34pt, nw: 52pt,
))
#align(center, text(size: 0.85em)[Internal nodes: the pieces on that plank and the
cost of its cut. Leaves: final piece lengths.])

Every subplank holds a *contiguous* run of final pieces, so a pair of indices names
it.

*Subproblem:* For $1 <= i <= k <= n$:

$ text("Cutting")(i, k) = "minimum cost to cut the plank made of pieces" text("Len")[i .. k] "into those pieces" $

*Recurrence:* Guess the index $r$ of the first piece in the right subplank. The right
subplank must not be empty, and neither may the left one, so $i < r <= k$:

$ text("Cutting")(i, k) = cases(
  0 & "if" i = k,
  limits(sum)_(j = i)^k text("Len")[j] + limits(min)_(i < r <= k) (text("Cutting")(i, r - 1) + text("Cutting")(r, k)) & "otherwise"
) $

The sum is the cost of the first cut (the length of the whole subplank). The $min$
tries every place for that cut. A single piece ($i = k$) needs no cuts.

*Original problem:* $text("Cutting")(1, n)$.

#keyidea[*Try every root. Don't try to be clever:* You don't know which cut goes
first, so try all of them, and let the recursion handle each side.]

=== Part 2: Build solutions bottom-up
*Subproblems:* $text("Cutting")(i, k)$ for all $1 <= i <= k <= n$.

*Data structure:* a 2D array $text("Cutting")[1 .. n, 1 .. n]$. Only the entries with
$i <= k$ are used.

*Dependencies:* Entry $(i, k)$ reads $text("Cutting")(i, r - 1)$ for
$i <= r - 1 < k$: the *same row, to the left*. It also reads
$text("Cutting")(r, k)$ for $i < r <= k$: the *same column, below*. For $n = 6$ and
entry $(2, 5)$:

#tri-table(6, hl: (i, k) => if (i, k) == (2, 5) { mark-color } else if (i == 2 and k < 5) or (k == 5 and i > 2) { accent-light } else { none })

#align(center, text(size: 0.85em)[Rows are $i$, columns are $k$. Yellow: the entry
being filled. Blue: the entries it reads. Gray: unused ($i > k$).])

*Evaluation order:* Any order that fills the row to the left and the column below
first. Three choices work:

#align(center, table(
  columns: (auto, auto, auto),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Order*], [*Loops*], [*Verdict*]),
  [Row by row], [$i$ from $n$ *down* to $1$; inside, $k$ from $i$ *up* to $n$], [Good],
  [Column by column], [$k$ from $1$ *up* to $n$; inside, $i$ from $k$ *down* to $1$], [Good],
  [Diagonal by diagonal], [Short subplanks first ($k - i = 0, 1, 2, dots$)], [Correct, but the indices are easy to get wrong],
))

#trap[*The two loops go in opposite directions*: one counts up, one counts down. Read
each direction off the dependency drawing. Don't assume both go the same way.]

*Running time:* Each entry adds up to $n$ lengths and tries up to $n$ values of $r$,
so $O(n)$ time per entry. (Erickson precomputes the sums, but it doesn't change the
answer here.) There are $O(n^2)$ entries:

$ O(n^2) "subproblems" times O(n) "each" = #box(stroke: black, inset: 3pt, [$ O(n^3) $]) $

On homework, you can stop here. The pseudocode is just nested loops, and it is no
easier to read than the steps above. For reference (Erickson's book names the array
`MinCost`):

```
Woodcut(Len[1..n]):
  for i ← n down to 1
    Cutting[i, i] ← 0
    for k ← i + 1 to n
      total ← Len[i] + Len[i + 1] + ... + Len[k]
      best ← ∞
      for r ← i + 1 to k
        best ← min(best, Cutting[i, r − 1] + Cutting[r, k])
      Cutting[i, k] ← total + best
  return Cutting[1, n]
```

*The example, filled in:* $text("Len") = [2, 1, 3, 4]$, row by row from the bottom:

#let wood = ((0, 3, 9, 19), (none, 0, 4, 12), (none, none, 0, 7), (none, none, none, 0))
#tri-table(4, val: (i, k) => [#wood.at(i - 1).at(k - 1)], hl: (i, k) => if (i, k) == (1, 4) { mark-color } else { none })

For example, $text("Cutting")(1, 4) = 10 + min(0 + 12, 3 + 7, 9 + 0) = 19$. The best
first cut is $r = 4$: cut off the last piece, as in the right-to-left strategy.

== Maximum Independent Set in Trees
=== The problem
Let $G = (V, E)$ be a graph. An *independent set* is a subset $S subset.eq V$ such
that *no edge has both endpoints in $S$*. The goal: find the largest one.

In a general graph this is *NP-hard* (later in the semester). There is probably no
polynomial-time algorithm, not even an $O(n^(100))$ one. So restrict the input to a
*rooted tree* $T$ with $n$ nodes and root $r$. Nodes may have any number of children:
it is not necessarily a binary tree. Rooted trees are recursive: a root, plus a
rooted subtree for each child.

=== Part 1: Formulate recursively
*Decision:* is the root in the set or not?
- *Root not in the set:* Its children are all allowed. There are no edges between
  different subtrees, so take the best independent set of each child's subtree and
  combine them.
- *Root in the set:* Every child shares an edge with the root, so no child is
  allowed. The children's subtrees below them are free: take the best set in each
  *grandchild's* subtree, plus the root.

The recursive calls are always on subtrees. Name a subtree by its root, as with
binary search trees in CS 225.

*Subproblem:* For each node $v$:

$ text("MIS")(v) = "the size of the largest independent set in the subtree rooted at" v $

*Notation:* $w arrow.b v$ means "$w$ is a child of $v$".

*Recurrence:*

$ text("MIS")(v) = max {
  limits(sum)_(w arrow.b v) text("MIS")(w),
  #h(1em) 1 + limits(sum)_(w arrow.b v) limits(sum)_(x arrow.b w) text("MIS")(x)
} $

No separate base case is needed. At a leaf both sums are empty, so
$text("MIS")("leaf") = max{0, 1} = 1$.

*Original problem:* $text("MIS")(r)$.

=== Part 2: Build solutions bottom-up
*Subproblems:* one per node $v$.

*Data structure:* The subproblems are named by nodes, not integers, so an array no
longer fits. Store each answer in a *field on the node*: $v.text("MIS")$. (Same idea as
a distance field on each vertex in Dijkstra's algorithm.)

*Dependencies:* $v$ reads its children and grandchildren: nodes *below* $v$.

*Evaluation order:* *postorder*. It visits all of a node's descendants before the
node.

#keyidea[*"Evaluate in postorder" is a complete answer:* Computing a postorder is a
black-box algorithm you may use. Compute it, then loop over the nodes in that order.
The same answer works for directed acyclic graphs next week.]

*Running time:* The usual (number of subproblems) $times$ (time per subproblem) gives
a bound that is far too big. The time per node varies a lot: one node may have
$n slash 2$ children while most have none. Max time $times$ count gives $O(n^2)$.

Instead, *add up the work and charge it to the node being read*. Node $v$ costs
$O(1 + \#"children" + \#"grandchildren")$. Each node is
- a child of at most one node, so it is read as a child at most once in total;
- a grandchild of at most one node, so it is read as a grandchild at most once in
  total.

So all the reads add up to $O(n)$, and the total is

$ O(n) "for the nodes" + O(n) "child reads" + O(n) "grandchild reads" = #box(stroke: black, inset: 3pt, [$ O(n) $]) $

This is only an analysis trick: the algorithm does nothing extra. (Another view: there
is one child read per edge, and a tree has $n - 1$ edges.)

#trap[*For tree and graph DP, don't multiply the maximum time per subproblem by the
number of subproblems.* Add the work over all nodes, and charge each read to the node
(or edge) it touches.]

=== A cleaner version: two subproblems
Split the subproblem in two, by whether $v$ is in the set:

$ text("MISyes")(v) &= "largest independent set in" v"'s subtree that" "must contain" v \
  text("MISno")(v) &= "largest independent set in" v"'s subtree that" "must not contain" v $

If $v$ is in, no child is: there is no decision. If $v$ is out, each child is free:
take the better of in and out.

$ text("MISyes")(v) &= 1 + sum_(w arrow.b v) text("MISno")(w) \
  text("MISno")(v) &= sum_(w arrow.b v) max { text("MISyes")(w), text("MISno")(w) } $

The two recurrences call each other, but there are no grandchildren sums. The answer
is $max{text("MISyes")(r), text("MISno")(r)}$. Store two fields on each node. Each
node still depends only on its children, so evaluate in postorder: $O(n)$ time.

```
TreeMIS(T):
  for each node v in postorder
    v.yes ← 1
    v.no ← 0
    for each child w of v
      v.yes ← v.yes + w.no
      v.no ← v.no + max(w.yes, w.no)
  return max(r.yes, r.no)
```

*Example:* Each node shows $text("MISyes") slash text("MISno")$. Yellow nodes form a
maximum independent set of size $max{5, 6} = 6$:

#let mis-node(name, yes, no) = [$#name$ \ #text(size: 0.85em)[#yes / #no]]
#align(center, tree-pic(
  (
    r: (x: 2, y: 0, label: mis-node("r", 5, 6), fill: white),
    a: (x: 0.5, y: 1, label: mis-node("a", 1, 2), fill: white),
    b: (x: 2, y: 1, label: mis-node("b", 1, 0), fill: mark-color),
    c: (x: 3.5, y: 1, label: mis-node("c", 3, 2), fill: mark-color),
    d: (x: 0, y: 2, label: mis-node("d", 1, 0), fill: mark-color),
    e: (x: 1, y: 2, label: mis-node("e", 1, 0), fill: mark-color),
    f: (x: 3.5, y: 2, label: mis-node("f", 1, 2), fill: white),
    g: (x: 3, y: 3, label: mis-node("g", 1, 0), fill: mark-color),
    h: (x: 4, y: 3, label: mis-node("h", 1, 0), fill: mark-color),
  ),
  (("r", "a"), ("r", "b"), ("r", "c"), ("a", "d"), ("a", "e"), ("c", "f"), ("f", "g"), ("f", "h")),
  unit: 46pt, row: 40pt, nw: 30pt, nh: 26pt,
))

For example, $text("MISyes")(c) = 1 + text("MISno")(f) = 3$, and
$text("MISno")(r) = 2 + 1 + 3 = 6$ (the better value of $a$, $b$ and $c$). The set:
leave out $r$, $a$ and $f$; take $b$, $c$, $d$, $e$, $g$, $h$.

== Summary
#align(center, table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Step*], [*Woodcutting*], [*Tree MIS*]),
  [Decision], [Where the first cut goes], [Is the root in the set?],
  [Subproblem], [$text("Cutting")(i, k)$: pieces $i .. k$], [$text("MIS")(v)$: subtree at $v$],
  [Original problem], [$text("Cutting")(1, n)$], [$text("MIS")(r)$],
  [Data structure], [2D array $text("Cutting")[1 .. n, 1 .. n]$], [Field $v.text("MIS")$ on each node],
  [Dependencies], [Same row to the left, same column below], [Children and grandchildren],
  [Evaluation order], [$i$ down from $n$; $k$ up from $i$], [Postorder],
  [Running time], [$O(n^2) times O(n) = O(n^3)$], [$O(n)$, by charging reads to nodes],
))
]

#show: notes
#set heading(numbering: "1.1")
#body
