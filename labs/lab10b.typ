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

#let body = [
== Lab 10B (October 30)

+ Suppose that you have just finished computing the array
  $italic("dist")[1 .. |V|, 1 .. |V|]$ of shortest-path distances between *_all_* pairs of
  vertices in an edge-weighted directed graph $G = (V, E)$. Unfortunately, you discover
  that you incorrectly entered the weight of a single edge $u -> v$, so all that precious
  CPU time was wasted. Or was it? Maybe your distances are correct after all!

  In each of the following problems, let $w(u -> v)$ denote the weight that you used in
  your distance computation, and let $w'(u -> v)$ denote the correct weight of $u -> v$.
  You may assume there are no negative weight cycles in $G$ with either weight
  $w(u -> v)$ or $w'(u -> v)$.

  #set enum(numbering: "(a)")
  + Suppose $w(u -> v) > w'(u -> v)$; that is, the weight you used for $u -> v$ was
    _larger_ than its true weight. Describe an algorithm that repairs the distance array
    in *_$O(|V|^2)$ time_* under this assumption. _[Hint: For every pair of vertices $x$
    and $y$, either $u -> v$ is on the shortest path from $x$ to $y$ or it isn't.]_

    #skeleton

  + Maybe even that was too much work. Describe an algorithm that determines whether
    your original distance array is actually correct in *_$O(1)$ time_*, again assuming
    that $w(u -> v) > w'(u -> v)$. _[Hint: Either $u -> v$ is the shortest path from $u$
    to $v$ or it isn't.]_

    #skeleton

  + *To think about later:* Describe an algorithm that determines in *_$O(abs(E) abs(V))$
    time_* whether your distance array is actually correct, even if
    $w(u -> v) < w'(u -> v)$.

    #skeleton

  + *To think about later:* Argue that when $w(u -> v) < w'(u -> v)$, repairing the
    distance array _requires_ recomputing shortest paths from scratch, at least in the
    worst case.

    #todo

+ You---yes, _you_---can cause a major economic collapse with the power of
  algorithms!#footnote[No, you can't.] The _arbitrage_ business is a money-making scheme
  that takes advantage of differences in currency exchange. In particular, suppose that
  1 US dollar buys 120 Japanese yen; 1 yen buys 0.01 euros; and 1 euro buys 1.2 US
  dollars. Then, a trader starting with \$1 can convert their money from dollars to yen,
  then from yen to euros, and finally from euros back to dollars, ending with \$1.44!.
  The cycles of currencies \$ $->$ ¥ $->$ € $->$ \$ is called an *_arbitrage cycle_*. Of
  course, finding an exploiting arbitrage cycles before the prices are corrected
  requires extremely fast algorithms.

  Suppose $n$ different currencies are traded in your currency market. You are given a
  two-dimensional array $R[1 .. n, 1 .. n]$ containing exchange rates between every pair
  of currencies; for each $i$ and $j$, one unit of currency $i$ can be traded for
  $R[i, j]$ units of currency $j$. (Do _not_ assume that $R[i, j] dot R[j, i] = 1$.)

  #set enum(numbering: "(a)")
  + Describe an algorithm that returns an array $italic("MaxCurrency")[1 .. n]$ where
    $italic("MaxCurrency")[1 .. n]$ is the maximum amount of currency $i$ that you can
    obtain by trading starting with one unit of currency 1 assuming there are no
    arbitrage cycles.

    #skeleton

  + Describe an algorithm to determine whether the given matrix of currency exchange
    rates creates an arbitrage cycle.

    #skeleton

  + *To think about later:* Modify your algorithm from part (b) to actually return an
    arbitrage cycle if such a cycle exists.

    #skeleton
]

#show: notes
#body
