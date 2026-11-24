#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  - *Vertices* (what does each one mean?): #todo
  - *Edges* (directed? a dag?): #todo
  - *Values on vertices or edges* (or "none"): #todo
  - *Problem in the graph* (shortest path / reachability, from where to where, and why it answers the question): #todo
  - *Algorithm* (which one, started where, how you read the answer): #todo
  - *Running time* (in terms of $n$, not $|V|$ and $|E|$): #todo
]

#let body = [
== Lab 9A: Applying Graph Traversals (October 21)

For each of the problems below, transform the input into a graph and apply a standard
graph algorithm that you've seen in class. Whenever you use a standard graph
algorithm, you must provide the following information. (I recommend actually using a
bulleted list.)

- What are the vertices? What does each vertex represent?
- What are the edges? Are they directed or undirected? If it matters to your
  algorithm, is the graph a dag?
- If the vertices or edges have any associated values, what are they?
- What is the precise relationship between your graph and the stated problem?
- What standard graph algorithm are you using to solve the problem? Exactly how are
  you invoking that algorithm, and exactly how are you using the results?
- What is the running time of your entire algorithm, including the time to build the
  graph, as a function of the original input parameters?

Finally, remember that even when you are explicitly given a graph as part of the
input, that may not be the graph you want to use as input to the standard algorithm!

#hrule

A *number maze* is an $n times n$ grid of positive integers, represented as an array
$M[1 .. n, 1 .. n]$. A token starts in the upper left corner; your goal is to move
the token to the lower-right corner. On each turn, you can move the token in any
direction (up, down, left, or right) by a distance equal to the number on its current
square. For example, if the token is on a square labeled 3, then you can move it three
steps up, three steps down, three steps left, or three steps right on your next turn.
However, moving the token off the edge of the board is forbidden.

#figure(
  table(
    columns: (2em,) * 5,
    rows: 2em,
    align: center + horizon,
    stroke: 0.5pt,
    fill: (x, y) => if x == 0 and y == 0 { accent-light } else if x == 4 and y == 4 { mark-color },
    [3], [5], [7], [4], [6],
    [5], [3], [1], [5], [3],
    [2], [8], [3], [1], [4],
    [4], [5], [7], [2], [3],
    [3], [1], [3], [2], [★],
  ),
  caption: [A $5 times 5$ number maze that can be solved in eight moves. Start is
    shaded blue; the goal ★ is the lower-right corner. (The handout also shows the
    eight-move solution path.)],
)

+ Describe and analyze an efficient algorithm that either returns the minimum number
  of moves required to solve a given number maze, or correctly reports that the maze
  has no solution.

  For example, given the number maze shown above, your algorithm should return the
  integer 8, which is the length of the sequence of moves shown in the handout. (This
  is actually the unique shortest solution.)

  Build a directed graph $G$:
  - where a *vertex* can be defined as $(i, j)$ for each cell, resulting in $n^2$ vertices
  - where an *edge* can be defined as a directed edge from $(i, j)$ to each of
    the four cells in each adjacent direction: $(i - M[i, j], j)$ (up), $(i + M[i, j], j)$ (down),
    $(i, j - M[i, j])$ (left), and $(i, j + M[i, j])$ (right), whenever that cell is on the board, resulting in at most $4 n^2$ edges
  - where there are *no values* on any vertices or edges
  - where the minimum number of moves equals the length of the shortest path in
    $G$ from $(1, 1)$ to $(n, n)$
  - run a *breadth first search (BFS)* algorithm from $(1, 1)$ because $G$ is unweighted, which allows BFS to find paths with the fewest edges, where we can return the distance to $(n, n)$ or "no solution" if BFS never reaches it
  - running this algorithm will result in a time complexity of $O(n^2 + 4n^2)
    = O(n^2)$

#hrule
The remaining problems consider variants of problem 1, where a sequence of moves must
satisfy some additional constraint to be considered a valid solution. The example
solution shown above is not a valid solution for any of these variants. For each
problem, your goal is to describe an algorithm that either returns the minimum number
of moves in a valid solution to a given number maze, or reports correctly that no
valid solution exists.

2. Suppose a sequence of moves is considered valid if and only if the moves alternate
  between horizontal and vertical. That is, a valid move sequence never has two
  horizontal moves in a row or two vertical moves in a row.

  Describe and analyze an algorithm that either returns the minimum number of moves in
  a valid solution to a given number maze, or reports correctly that no valid solution
  exists.

  Build a directed graph $G$
  - where a *vertex* can be defined as:
    - $(i, j, H)$: at $(i, j)$, where the *next* move must be horizontal (left or right)
    - $(i, j, V)$: at $(i, j)$, where the *next* move must be vertical (up or down)
    - this results in a total of $n^2$ cells that can each go either horizontally or vertically, so $2 times n^2 = 2n^2$
  - and an *edge* can be defined as:
    - $(i, j, H) -> (i, j^', V)$, where $j^'$ represents movement either left or right by $M[i, j]$ from vertex $(i, j, H)$
    - $(i, j, V) -> (i^', j, H)$, where $i^'$ represents movement either up or down by $M[i, j]$ from vertex $(i, j, V)$
    - this results in a total of $n^2$ possible edge directions for $2$ directions, so $2n^2 times 2 = 4n^2$ 
  - where there are *no values* on any vertices or edges
  - where the minimum number of moves represents the length of the shortest path in $G$ from $(1, 1, H)$ or $(1, 1, V)$ (because the first move can go either way) and end at either $(n, n, H)$ or $(n, n, V)$ (since either one means you've arrived at the final square in the grid)
  - run a *breadth first search (BFS)* algorithm from $(1, 1, H)$ or $(1, 1, V)$ because $G$ is unweighted, which allows BFS to find paths with the fewest edges, where we can return the distance to $(n, n, H)$ or $(n, n, V)$
  - this algorithm will result in a time complexity of $O(V + E) = O(2n^2 + 4n^2) = O(n^2)$

3. Suppose a sequence of moves is considered valid if and only if its length (the
  number of moves) is a multiple of 5.

  Describe and analyze an algorithm that either returns the minimum number of moves in
  a valid solution to a given number maze, or reports correctly that no valid solution
  exists.

  Build a directed graph $G$:
  - where a *vertex* is defined as $(i, j, r)$ for each cell, where $(i, j)$ represents a cell and $r$ is the number of moves done so far, $mod 5$, meaning that $r in {0, 1, 2, 3, 4}$, meaning that $G$ has a total of $5n^2$ vertices
  - where an *edge* is defined as a directed edge between $(i, j, r) -> (i^', j^', (r + 1) mod 5)$, whenever $(i^', j^')$ is one legal move from $(i, j)$, which constitutes exactly as $M[i, j]$ squares up, down, left, or right, on the board (by definition of the problem), resulting in a total of at most
$20n^2$ edges
  - where there are *no values* on any vertices or edges
  - where the minimum number of moves equals the length of the shortest path in $G$ from $(1, 1, 0)$ to $(n, n, 0)$, since a walk ends on layer $0$ exactly, when its number of moves is a multiple of 5
  - with this in mind, we can leverage a *Breadth First Search (BFS)* from $(1, 1, 0)$ because $G$ is unweighted, allowing BFS to find paths with the fewest edges, where we can then return the distance to $(n, n, 0)$ or "no solution" if BFS never reaches it
  - running this algorithm will result in a time complexity of $O(5n^2 + 20n^2) = O(n^2)$

#hrule
*Harder problems to think about later:*

4. Now suppose a sequence of moves is considered valid if and only if it does not
  contain two adjacent moves in opposite directions. In other words, a sequence of
  moves is valid if and only if it contains no U-turns.

  Describe and analyze an algorithm that either returns the minimum number of moves in
  a valid solution to a given number maze, or reports correctly that no valid solution
  exists.

  #skeleton

5. Now suppose a sequence of moves is considered valid if and only if each move in the
  sequence is longer than the previous move (if any). In other words, a sequence of
  moves is valid if and only if the sequence of move lengths is increasing.

  Describe and analyze an algorithm that either returns the minimum number of moves in
  a valid solution to a given number maze, or reports correctly that no valid solution
  exists.

  #skeleton

6. Finally, suppose a sequence of moves is considered valid if and only if the
  sequence of move lengths is a palindrome. (A palindrome is any sequence that is
  equal to its reversal.)

  Describe and analyze an algorithm that either returns the minimum number of moves in
  a valid solution to a given number maze, or reports correctly that no valid solution
  exists.

  #skeleton
]

#show: notes
#body
