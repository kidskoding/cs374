#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  Build a directed graph $G$:
  - *Vertices* (what does each one mean? how many?): #todo
  - *Edges* (when is there an edge? how many? is $G$ a dag?): #todo
  - *Values on vertices or edges* (or "none"): #todo
  - *Problem in the graph* (which problem, in $G$, from where to where, and why it answers the question): #todo
  - *Algorithm* (which one, run how, and how you read the answer): #todo
  - *Running time* (in terms of the input size): #todo
]

// Looped tree from the handout: tree edges drawn by graph-pic, leaf-to-root edges
// overlaid as polylines in the same coordinates.
#let lt-unit = 36pt
#let lt-r = 7pt
#let lt-pos = (
  r: (3, 0.6), a: (2.4, 1.5), b: (3.6, 1.5),
  c: (1.9, 2.4), d: (2.9, 2.4), f: (4.1, 2.4),
  e: (1.5, 3.3), g: (3.6, 3.3), h: (4.6, 3.3),
)
#let lt-edges = (("r", "a"), ("r", "b"), ("a", "c"), ("a", "d"), ("c", "e"), ("b", "f"), ("f", "g"), ("f", "h"))
#let lt-w = (ra: [5], rb: [8], ac: [17], ad: [0], ce: [23], bf: [1], fg: [9], fh: [14])
#let lt-at(p) = (p.at(0) * lt-unit + lt-r, p.at(1) * lt-unit + lt-r)
// Polyline through `pts` (in units), arrowhead at the last point, weight `w` at `wp`.
#let lt-loop(pts, w, wp) = {
  let ps = pts.map(lt-at)
  for i in range(ps.len() - 1) {
    place(line(start: ps.at(i), end: ps.at(i + 1), stroke: 0.6pt + luma(90)))
  }
  let (x1, y1) = ps.at(-2)
  let (x2, y2) = ps.at(-1)
  let dx = (x2 - x1) / 1pt
  let dy = (y2 - y1) / 1pt
  let d = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / d, dy / d)
  let (bx, by) = (x2 - ux * 6pt, y2 - uy * 6pt)
  place(polygon(fill: luma(90), stroke: none, (x2, y2), (bx - uy * 3pt, by + ux * 3pt), (bx + uy * 3pt, by - ux * 3pt)))
  let (wx, wy) = lt-at(wp)
  place(dx: wx - 8pt, dy: wy - 6pt, box(width: 16pt, height: 12pt, align(center + horizon, text(size: 0.75em, fill: warn-color, w))))
}
#let looped-tree = box(width: 6 * lt-unit + 2 * lt-r, height: 4 * lt-unit + 2 * lt-r, {
  // root sits at (3, 0.6); arrowheads stop just outside its circle (radius ~0.2 units)
  lt-loop(((1.5, 3.3), (0.6, 3.3), (0.6, 0.6), (2.8, 0.6)), [4], (0.85, 1.9))
  lt-loop(((2.9, 2.4), (2.9, 3.9), (0, 3.9), (0, 0.1), (2.85, 0.1), (2.88, 0.45)), [16], (-0.3, 1.9))
  lt-loop(((3.6, 3.3), (3.9, 3.9), (6, 3.9), (6, 0.1), (3.15, 0.1), (3.12, 0.45)), [7], (6.3, 1.9))
  lt-loop(((4.6, 3.3), (5.4, 3.3), (5.4, 0.6), (3.2, 0.6)), [42], (5.1, 1.9))
  place(graph-pic(
    lt-pos,
    lt-edges,
    directed: true,
    unit: lt-unit,
    r: lt-r,
    label: n => [],
    weight: e => lt-w.at(e.at(0) + e.at(1)),
  ))
})

#let body = [
== Lab 10A (October 28)

+ Describe and analyze an algorithm to compute the shortest path from vertex $s$ to
  vertex $t$ in a directed graph with weighted edges, where exactly _one_ edge
  $u -> v$ has negative weight. Assume the graph has no negative cycles. _[Hint: Modify
  the input graph and run Dijkstra's algorithm. Alternatively, *don't* modify the input
  graph, but run Dijkstra's algorithm anyway.]_

  Let $G^'$ be the input graph with the negative edge $u -> v$ removed:
    - where its *vertices* are the same vertices as the input graph, $V$
    - and its *edges* are every input edge except $u -> v$. All remaining weights are $>= 0$, resulting in a total number of edges equal to $E - 1$ for $G^'$
    - let $w(e)$ be a function that computes the weight of any arbitrary edge $e$. each edge will keep its weight $w(e)$ and all are $>= 0$ after removing $u -> v$
    - where we need to find the shortest path from vertex $s$ to vertex $t$ in the input graph that either avoids $u -> v$, with length $"dist"'(s, t)$, or uses $u -> v$, with length $"dist"'(s, u) + w(u -> v) + "dist"'(v, t)$. The answer is the smaller one
    - since all weights in $G^'$ are $>= 0$, we run Dijkstra's algorithm in $G^'$ from $s$ (giving $"dist"'(s, t)$ and $"dist"'(s, u)$) and from $v$ (giving $"dist"'(v, t)$), and return the minimum of the two cases
    - these two runs of Dijkstra take $O((E - 1) log V) = O(E log V)$ time

+ You just discovered your best friend from elementary school on Blueyarns (formerly
  known as Face$bb(X)$ formerly known as Twitbook). You both want to meet as soon as possible,
  but you live in two different cities that are far apart. To minimize travel time, you
  agree to meet at an intermediate city, and then you simultaneously hop in your cars
  and start driving toward each other. But where _exactly_ should you meet?

  You are given a weighted graph $G = (V, E)$, where the vertices $V$ represent cities
  and the edges $E$ represent roads that directly connect cities. Each edge $e$ has a
  weight $w(e)$ equal to the time required to travel between the two cities. You are
  also given a vertex $p$, representing your starting location, and a vertex $q$,
  representing your friend's starting location.

  Describe and analyze an algorithm to find the target vertex $t$ that allows you and
  your friend to meet as soon as possible, assuming both of you leave home _right now_.

  #skeleton

#hrule
*Think about later:*

3. A _looped tree_ is a weighted, directed graph built from a binary tree by adding an
  edge from every leaf back to the root. Every edge has a non-negative weight.

  #figure(looped-tree, caption: [A looped tree.])

  #set enum(numbering: "(a)")
  + How much time would Dijkstra's algorithm require to compute the shortest path
    between two vertices $u$ and $v$ in a looped tree with $n$ nodes?

    #todo

  + Describe and analyze a faster algorithm.

    #skeleton
]

#show: notes
#body
