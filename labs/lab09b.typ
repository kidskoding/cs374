#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  Build a directed graph $G$:
  - *Vertices* (what does each one mean? how many?): #todo
  - *Edges* (when is there an edge? how many? is $G$ a dag?): #todo
  - *Values on vertices or edges* (or "none"): #todo
  - *Problem in the graph* (which problem, in $G$, from where to where, and why it answers the question): #todo
  - *Algorithm* (which one, run how, and how you read the answer): #todo
  - *Running time* (in terms of $n$ and $m$): #todo
]

#let body = [
== Lab 9B: Applying DAGs (October 23)

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

+ Suppose you decide to organize a Snakes and Ladders competition with $n$
  participants. In this competition, each game of Snakes and Ladders involves three
  players. After the game is finished, they are ranked first, second, and third. Each
  player may be involved in any (non-negative) number of games, and the number need
  not be equal among players.

  At the end of the competition, $m$ games have been played. You realize that you
  forgot to implement a proper rating system, and therefore decide to produce the
  overall ranking of all $n$ players as you see fit. However, to avoid being too
  suspicious, if player $A$ ranked better than player $B$ in at least one game, then
  $A$ must rank better than $B$ in the overall ranking.

  You are given the list of players and their rankings in each of the $m$ games.
  Describe and analyze an algorithm that produces an overall ranking of the $n$
  players that is consistent with the individual game rankings, or correctly reports
  that no such ranking exists.

  Build a directed graph $G$:
  - where a *vertex* can be defined as each individual player, resulting in a total of $n$ vertices for $G$ 
  - and an *edge* is a directed edge that can be defined as $A -> B$, where player $A$ ranked better than player $B$ in at least one game. Each game ($1^"st", 2^"nd", 3^"rd"$) will then result in 3 edges, where $1^"st" -> 2^"nd"$, $1^"st" -> 3^"rd"$, $2^"nd" -> 3^"rd"$, resulting in at most $3m$ edges
  - in this problem, there are no values on either the vertices or edges
  - Every valid overall ranking is a *topological order of $G$*, and vice versa. Therefore, a valid ranking exists if and only if $G$ is a DAG
  - Therefore, we can run a *topological ordering* on $G$ using a *depth-first search (DFS)*. If DFS finds a directed cycle, then we can report that no valid ranking exists; otherwise, we return the topological order as the overall ranking
  - A topological ordering of any graph results in a time complexity of $O(V + E)$, so on $G$, this would result in $O(n + 3m) = O(n + m)$ 

+ There are $n$ galaxies connected by $m$ intergalactic teleport-ways. Each
  teleport-way joins two galaxies and can be traversed in both directions. However, the
  company that runs the teleport-ways has established an extremely lucrative cost
  structure: Anyone can teleport _further_ from their home galaxy at no cost
  whatsoever, but teleporting _toward_ their home galaxy is prohibitively expensive.

  Judy has decided to take a sabbatical tour of the universe by visiting as many
  galaxies as possible, starting at her home galaxy. To save on travel expenses, she
  wants to teleport away from her home galaxy at every step, except for the very last
  teleport home.

  Describe and analyze an algorithm to compute the maximum number of galaxies that
  Judy can visit. Your input consists of an undirected graph $G$ with $n$ vertices and
  $m$ edges describing the teleport-way network, an integer $1 <= s <= n$ identifying
  Judy's home galaxy, and an array $D[1 .. n]$ containing the distances of each galaxy
  from $s$.

  _[Hint: There is a linear time algorithm to compute longest paths in a directed
  acyclic graph. See Section 6.4 of Jeff's notes.]_

  Build a directed graph $G$:
  - where a *vertex* can be defined as each individual galaxy, resulting in a total of $n + 1$ vertices for $G$, where 1 represents an extra copy of Judy returning home again at the end (aka a second copy of home, used only as the finish line)
  - and an *edge* is a directed edge that can be defined as $u -> v$, where $u$ and $v$ represent two distinct galaxies, wherever there is a teleport way between $u$ and $v$ and $D[v] > D[u]$, plus an edge $u -> t$ whenever there is a teleport-way between $u$ and $s$ (the final teleport home). This gives at most $2m$ edges. $G$ is a DAG because $D$ strictly increases along every edge except those into $t$ and $t$ has no outgoing edges
  - in this problem, there are no values on either of the vertices or edges
  - Every path in $G$ from $s$ to $t$ with $ell$ edges is a valid tour that visits $ell - 1$ galaxies (not counting the travel back home) and vice versa
  - So the answer is the length of the longest path in $G$ from $s$ to $t - 1$
  - Since $G$ is a DAG, we compute the longest path from $s$ to $t$ using dynamic programming in topological order
  - This runs in $O(V + E) = O(n + 1 + 2m) = O(n + m)$ time

#hrule
*Harder problems to think about later:*

3. Just before embarking on her universal tour, Judy wins the space lottery, giving her
  just enough money to afford _two_ teleports toward her home galaxy. Describe and
  analyze a new algorithm to compute the maximum number of galaxies Judy can visit; if
  she visits the same galaxy twice, that counts as two visits. After all, argues the
  travel agent, who can see an entire galaxy in just one visit?

  #skeleton

4. #h(-2.2em)$star$#h(1.4em)Judy replies angrily to the travel agent that she _can_ see
  an entire galaxy in just one visit, because 99% of every galaxy is exactly the same
  glowing balls of plasma and lifeless chunks of rock and McDonalds and Starbucks and
  prefab "Irish" pubs and overpriced souvenir shops and boba tea shops as every other
  galaxy.

  Describe and analyze an algorithm to compute the maximum number of _distinct_
  galaxies Judy can visit. She is still allowed to visit the same galaxy more than
  once, but only the first visit counts toward her total.

  #skeleton
]

#show: notes
#body
