# 0002 — First graph reduction written (lab 9a problem 1)

Date: 2026-11-08, the night before Midterm 2.

## What happened
Wrote the full 6-line graph-reduction answer for the number maze (lab 9a P1) in `labs/lab09a.typ`, with scaffolding: vertices (i, j), directed edges to the 4 cells M[i, j] away, no values, shortest path (1,1) to (n,n), BFS, O(n^2). Graded about 8.5/10 on the standard graph-reduction rubric.

## Insights
- Got the concept parts fast: vertices = cells, BFS for fewest moves.
- Stuck on notation, not ideas: what i/j are, M[i, j] = the number in the cell (not the cell), why "directed", one move changes row OR column.
- Lost points by merging the problem line with the algorithm, and by leaving out the "unreachable means no solution" case.
- Confidence jumped once the answer was seen to be just 6 short lines: "I can pass decently."

## Next
Lab 9a P3 (vertex (i, j, r), r = moves mod 5), then P2, then lab 9b. Zone of proximal development: state-augmented vertices.

## Update, 2026-11-09 ~00:40
- Did lab 9a P3 (i, j, r mod 5) and P2 (i, j, H/V) with less help; both ~8.5-9/10.
- Recurring mistakes: (1) restating the question instead of "shortest path in G from <vertex> to <vertex>"; (2) BFS start/end written as 2-part vertices in a 3-part graph; (3) first instinct was to "modify BFS / filter results" instead of changing the vertex. Fixed via the "stack of floors" picture.
- Grasped the 3-question recipe (situation = vertex, one step = edge, cost = weight) and the algorithm-choice line (BFS/Dijkstra/Bellman-Ford/topo+DP/DFS) at the interface level only.
- Next: lab 9b P1 (DAG/topo), lab 10a P1 (Dijkstra), then DP labs, practice exam 1 timed at noon.
