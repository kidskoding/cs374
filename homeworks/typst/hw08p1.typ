// CS 374 A, Homework 8, Problem 1
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let cost = $\$$
#let sys = $italic("system")$
#let dist = $italic("dist")$

#show: homework.with(
  title: "CS 374: Section A - Homework 8, Problem 1",
  date: "October 27, 2026",
)

At any moment the card is in one of three *modes*: $A$ (both stickers on), $B$
(top sticker removed) or $C$ (both stickers removed). The mode only moves
forward, $A -> B -> C$, and a sticker may be removed at any station. While the
card is in mode $X$, an edge $e$ costs

$
w_X (e) = cases(
  cost(e) slash 2 & "if" sys(e) = X,
  cost(e) & "otherwise.",
)
$

A *plan* is a walk from $s$ to $t$ in $G$ together with the stations where the
stickers come off. Its cost is the sum of $w_X (e)$ over the edges $e$ of the
walk, where $X$ is the mode while that edge is used.

= Graph

We build a directed graph $G' = (V', E')$ with three copies of $G$, one for
each mode:

- *Vertices:* $V' = V times {A, B, C}$. Vertex $(v, X)$ means "we are at station
  $v$ and the card is in mode $X$." So $|V'| = 3 |V|$.
- *Travel edges:* For every edge $e = u -> v$ in $E$ and every mode
  $X in {A, B, C}$, $G'$ has an edge $(u, X) -> (v, X)$ with weight $w_X (e)$.
  This is riding connection $e$ without touching the stickers.
- *Sticker edges:* For every station $v in V$, $G'$ has an edge
  $(v, A) -> (v, B)$ and an edge $(v, B) -> (v, C)$, both with weight $0$. These
  are removing the top sticker and the bottom sticker at station $v$. There are
  no edges back to an earlier mode, because a sticker cannot be put back on.

So $|E'| = 3 |E| + 2 |V|$. Every weight is $cost(e)$, $cost(e) slash 2$ or $0$,
so all weights are non-negative.

= Algorithm

#boxed[
  Run Dijkstra's algorithm on $G'$ from $(s, A)$ and return \
  $min{dist(t, A), dist(t, B), dist(t, C)}$.
]

We start at $(s, A)$ because both stickers are on when we leave the friend's
house. We may arrive at the Transit Authority in any mode, so we take the best
of the three copies of $t$. If none of them is reachable, all three distances
are $infinity$ and there is no way to reach $t$.

= Correctness

*Every plan gives a path in $G'$ with the same cost:* Follow the plan step by
step, starting at $(s, A)$. When the plan rides an edge $e = u -> v$ in mode $X$,
take the travel edge $(u, X) -> (v, X)$, which has weight $w_X (e)$, the price
of that ride. When the plan removes a sticker at station $v$, take the sticker
edge $(v, A) -> (v, B)$ or $(v, B) -> (v, C)$, which has weight $0$. The plan
ends at $t$ in some mode $X$, so this is a path from $(s, A)$ to $(t, X)$ whose
weight equals the cost of the plan.

*Every path in $G'$ gives a plan with the same cost:* Take a path from $(s, A)$
to $(t, X)$. Each travel edge $(u, Y) -> (v, Y)$ comes from an edge
$e = u -> v$ of $G$, and riding $e$ in mode $Y$ costs $w_Y (e)$. Each sticker
edge stays at the same station and moves the mode one step forward, so it is a
legal sticker removal that costs nothing. The modes along the path only go
forward, $A$ then $B$ then $C$, so the stickers come off in the allowed order.
Reading the stations in order gives a walk from $s$ to $t$ in $G$, and the cost
of this plan equals the weight of the path.

Therefore the cheapest plan costs exactly the smallest distance from $(s, A)$
to one of $(t, A)$, $(t, B)$, $(t, C)$, which is what the algorithm returns.
Dijkstra's algorithm is correct here because every weight in $G'$ is
non-negative.

*Example:* In the handout's graph, the plan given there is the path

$
(s, A) ->^1 (b, A) ->^(4.5) (e, A) ->^0 (e, B) ->^5 (d, B) ->^3 (c, B) ->^4 (f, B) ->^0 (f, C) ->^4 (t, C),
$

with total weight $1 + 4.5 + 5 + 3 + 4 + 4 = 21.5$, the value in the handout.

= Running time

Building $G'$ takes $O(|V'| + |E'|) = O(|V| + |E|)$ time: each edge of $G$
gives three travel edges and each station gives two sticker edges, each with a
weight found in $O(1)$ time. Dijkstra's algorithm on $G'$ takes
$O(|E'| log |V'|) = O((|E| + |V|) log |V|)$ time, since
$log |V'| = log 3 + log |V|$. Taking the minimum of three distances is $O(1)$.
The algorithm runs in #boxed[$O((|V| + |E|) log |V|)$ time.]

#disclosures(llm: llm-note)
