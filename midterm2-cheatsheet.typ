#set page(paper: "us-letter", margin: 0.35in, columns: 2)
#set columns(gutter: 0.18in)
#set text(size: 7.3pt, font: "New Computer Modern")
#set par(leading: 0.42em, spacing: 0.55em)
#set list(spacing: 0.35em, indent: 0.4em)
#set enum(spacing: 0.35em, indent: 0.4em)
#show heading: it => block(above: 0.7em, below: 0.35em, fill: luma(225), inset: (x: 3pt, y: 2pt), width: 100%, text(size: 8.2pt, weight: "bold", it.body))
#let t(..xs) = table(columns: xs.pos().len(), inset: (x: 2.5pt, y: 1.8pt), stroke: 0.4pt, ..xs.named().at("rows", default: ()))
#let tbl(cols, ..cells) = table(columns: cols, inset: (x: 2.5pt, y: 1.8pt), stroke: 0.4pt, ..cells)

= EXAM TACTICS
- Read all 5 first. *Graphs first* (strongest), then Q1, DP, D&C.
- *Target 20/50:* Q1 recurrences ~4 · graph Q full 6 lines ~7 · each DP: subproblem + base = *4* · D&C: returns + base + recurrence ~5.
- *Never blank.* No IDK credit, but the English description alone = 3/10.
- *Always a running time.* Plain English beats confusing symbols.
- Stuck on a trick 3 min → write the *correct slow* answer (−1 only).

= GRAPH ANSWER — 6 LINES (10 pts)
+ *Vertices* (1): one per \_\_\_; meaning; *count*.
+ *Edges* (1): "*directed* edge $x -> y$ whenever \_\_\_"; *count*; DAG?
+ *Values* (1): weights $w(e)$ / "none" (counting moves → none).
+ *Problem* (3): "*shortest path / reachability / longest path / topo order* in $G$ *from* \_\_ *to* \_\_, since every valid \_\_ is a path in $G$ and vice versa." Name *vertices*, not the question.
+ *Algorithm* (2): "Run \_\_\_ from \_\_\_ (because \_\_\_); return \_\_\_, or 'none' if unreached." Black box — never explain it (−1).
+ *Time* (2): $V =$ \_, $E =$ \_ in *input terms* (n, m, ...).
*3 questions:* situation now = *vertex* · one step = *edge* · step costs? = *weight*.

= WHICH ALGORITHM
#tbl((1.5fr, 1.1fr, auto),
  [*Problem says*], [*Use*], [*Time*],
  [can I reach / which reachable], [WFS], [$O(V+E)$],
  [fewest moves/steps, no weights], [BFS], [$O(V+E)$],
  [order / prerequisites / "before"], [topo sort (DFS); cycle → none], [$O(V+E)$],
  [cycle?], [DFS], [$O(V+E)$],
  [longest / most / count paths, *DAG*], [DP in topo order], [$O(V+E)$],
  [shortest path in DAG (neg ok)], [DP in topo order], [$O(V+E)$],
  [weights $>= 0$], [Dijkstra], [$O(E log V)$],
  [negative weights / neg cycle?], [Bellman-Ford], [$O(V E)$],
  [all pairs], [Floyd-Warshall], [$O(V^3)$],
)
Longest path is only easy in a *DAG* — find why no cycles (time/D increases).

= WHAT THE VERTEX REMEMBERS (TRICKS)
#tbl((1.2fr, 1fr),
  [*Rule in the problem*], [*Vertex / trick*],
  [alternate, no 2 in a row, no U-turn, colors], [$(v, "last dir/color")$],
  [count multiple of $k$, even/odd], [$(v, "count" mod k)$],
  [at most $k$ coupons/skips], [$(v, "# used")$, $0..k$],
  [modes that only go forward], [$(v, "mode")$],
  [walk spells a pattern], [$(v, "DFA state")$],
  [must end back at start], [fake copy $t$ of start],
  [many starts / many goals], [super-source / super-target],
  [undirected input, one-way rule], [keep allowed direction only],
  ["distance *to* $v$ from nearest X"], [reverse all edges],
  [exactly one special/negative edge], [cases: uses it or not; 2 runs],
  [products of rates (arbitrage)], [weight $-log R$; neg cycle → BF],
)
*Count:* $|V| = (\#"cells") times (\#"values of extra")$; $|E| <= |V| times (\#"moves")$.
*Two start states?* run BFS from each, take the min.

= DRAW BY HAND (Q1)
- *BFS tree:* layers 0,1,2...; parent = who found it first.
- *DFS tree:* go deep along unvisited edges, back up at dead end.
- *Topo order:* repeatedly remove a vertex with *no incoming edges*; stuck → *NONE* (cycle).
- *Shortest-path tree:* each vertex hangs off its cheapest route.

= MODEL: NUMBER MAZE, MOVES MULTIPLE OF 5
Vertices $(i, j, r)$, $r = "moves" mod 5$: $5n^2$. Edges $(i,j,r) -> (i',j',(r+1) mod 5)$ if $(i',j')$ is exactly $M[i,j]$ away in a straight line, on board: $<= 20 n^2$. No weights. Answer = shortest path $(1,1,0) -> (n,n,0)$. BFS from $(1,1,0)$. $O(n^2)$.

#colbreak()

= DP ANSWER — SKELETON (10 pts)
+ *Subproblem* (3): "$"NAME"(i)$ = the [max/min/\# of] [thing asked] that *starts at $A[i]$* / for *$A[i..n]$*." Name it after the thing — never one letter, OPT, DP (−1). Say what it *returns*, not how. *Prefer ONE variable* (works when what's left is a suffix).
+ *Answer:* which call, e.g. $F(1)$.
+ *Recurrence* (4): base (1) + recursive case (3): at the front, *try every choice*; after each choice *where do I continue?*
+ *Memo* (1): array $F[1..n+1]$ (never a hash table).
+ *Order* (1): fill so every entry it reads is done first.
+ *Time* (1): (\# entries) × (work per entry).
Memo/order/time count *only if* the recurrence is right → stuck? write (1) + base case = *4 pts*.

= SUBPROBLEM SHAPES
#tbl((1fr, 1.25fr),
  [*Input*], [*Subproblem*],
  [one array/string], [$F(i)$ on suffix $A[i..n]$],
  [plus "last taken" (increasing, decreasing)], [$F(i, j)$: suffix $A[j..n]$, all vs. $A[i]$],
  [two strings], [$F(i, j)$ on suffixes $A[i..], B[j..]$],
  [take from either end / split], [$F(i, j)$ on interval $A[i..j]$],
  [rooted tree], [$F(v)$ on subtree of $v$ (postorder)],
  [DAG], [$F(v)$ = best path from $v$],
)

= FILL ORDER RULES
- $F(i)$ reads $i+1, i+2$ → $i$ from $n$ *down to* 1.
- $F(i,j)$ reads column $j+1$ → $j$ down (outer), $i$ any.
- Interval $F(i,j)$ reads shorter intervals → by length, or $i$ down & $j$ up.
- Tree → postorder. DAG → reverse topological order.
- Q1 "meaningless recurrence": find which args each call *reads*, fill those first; time = entries × (\# terms in max/sum).

= MODEL: LONGEST DECREASING SUBSEQUENCE (1 variable)
$"LDS"(i)$ = length of the longest decreasing subsequence of $A[i..n]$ that *starts with $A[i]$*. \
$"LDS"(i) = 1 + max{"LDS"(j) : j > i, A[j] < A[i]}$; $= 1$ if no such $j$. \
Answer $max_(1<=i<=n) "LDS"(i)$ (can start anywhere). Array $"LDS"[1..n]$; reads only $j > i$ → fill $i$ from $n$ down to 1. $n$ entries × $O(n)$ = $O(n^2)$. \
*Template:* $F(i) = 1 + max{F(j) : j > i "and" [\_\_ "rule for next pick"]}$. \
*Graph version (full credit too):* vertices = indices + $s$; $i -> j$ if $i < j$, $A[i] > A[j]$; DAG; longest path from $s$; $O(n^2)$. \
*Model jumps (Quadhopper):* $"Hops"(i) = 0$ if $i > n$, else $1 + max_(1<=k<=4) "Hops"(i + D[i,k])$. Answer $"Hops"(1)$; array $[1..n]$, $i$ from $n$ down; $O(n)$. \
*Model take/skip:* $F(i) = max{F(i+1), A[i] + F(i+2)}$, $F(i) = 0$ if $i > n$.

= GREEDY FAILS (part a) — skeleton
*Input:* [tiny, 3–5 items]. *Greedy:* picks \_\_ (smallest/largest), then \_\_ → total \_\_. *Better:* picks \_\_, then \_\_ → total \_\_. Since \_\_ > \_\_, greedy is not optimal.
*Build:* greedy's tempting step lands on a *trap* (dead end / exposes a big card).
Quadhopper: $[1,2,10,10]$, $[10 times 4]$, $[1,10,10,10]$, $[1,10,10,10]$: greedy 2 moves, take 2 first → 3.
Elmo: $[5,10,1,4,6]$: Elmo 6; greedy you 5 → lose 9–17; you take 4 → win 14–12.

= RECURRENCES (recursion tree)
Top cost $f(n)$ vs next level ($a$ calls × $f(n/b)$): *shrink* → $O(f(n))$ · *same* → $O(f(n) log n)$ · *grow* → $O(n^(log_b a))$.
For $a T(n/b) + n^c$: compare $a$ vs $b^c$: $<$ → $n^c$; $=$ → $n^c log n$; $>$ → $n^(log_b a)$.
*Uneven splits* $T(alpha n) + T(beta n) + n$: add fractions: $< 1$ → $n$; $= 1$ → $n log n$.
#tbl((1.3fr, 1fr),
  [$2T(n/2)+n$], [$n log n$],
  [$T(n/2)+n$], [$n$],
  [$2T(n/2)+1$], [$n$],
  [$T(n/2)+1$ (binary search)], [$log n$],
  [$3T(n/2)+n$], [$n^(log_2 3) approx n^1.59$],
  [$4T(n/2)+n^2$], [$n^2 log n$],
  [$8T(n/2)+n^2$], [$n^3$],
  [$7T(n/2)+n^2$], [$n^(log_2 7) approx n^2.81$],
  [$T(n/2)+T(n/3)+T(n/6)+n$ (sizes sum to $n$)], [$n log n$],
  [$T(n/5)+T(7n/10)+n$ (sum $< n$)], [$n$],
  [$T(5n/11) + sqrt(n)$], [$sqrt(n)$],
)

= D&C / BINARY SEARCH (10 pts)
*Skeleton:* (3) "$"NAME"(A[1..n])$ returns \_\_." (1) "If $n <= 1$, return \_\_." (2) "Split at $m = floor(n/2)$; recurse on $A[1..m]$ and $A[m+1..n]$." (2) "Combine: \_\_ (use the black box)." (2) "$T(n) = 2T(n/2) + O(\_\_)$, so $O(\_\_)$."
- *Split in half*, recurse both, combine with the given black box → $2T(n/2) + "combine"$.
- *Binary search:* check the middle, decide which half *must* contain the answer, recurse on it → $T(n/2) + O(1) = O(log n)$.
- *Black boxes:* sort $O(n log n)$; select/median (MomSelect) $O(n)$. Never re-derive.
- Merge $k$ sorted arrays: merge halves recursively → $O(n k log k)$.

#pagebreak()
= NEVER BLANK — FIRST 25 MINUTES: WRITE THIS ON EVERY PROBLEM
*Spot the type from words in the question:* graph / roads / walk / grid / moves / reach → *GRAPH*. max / min / longest / \# of ways over an array or string → *DP*. "black box subroutine", sorted arrays, "efficient", find an index → *D&C*.
Copy the *question's own words* into the blanks. These lines need no insight.

*GRAPH (≈4–6 pts with zero insight)*
- Build a *directed* graph $G$. Vertices: one per \_\_\_ [thing that moves / where you are] (+ extra info if a rule needs memory). $|V| = $ \_\_\_.
- Edges: $u -> v$ whenever one legal \_\_\_ [move/step] goes from $u$ to $v$. $|E| <= $ \_\_\_.
- Weights: "none" if counting steps; else the given cost/length.
- The answer is the *shortest path / reachability* in $G$ from \_\_\_ [start] to \_\_\_ [goal], since every valid \_\_\_ is a path in $G$.
- Run *BFS* (no weights) / *Dijkstra* (weights ≥ 0) from \_\_\_. Return the distance, or "none" if unreached.
- Time $O(V + E)$ = $O($\_\_\_$)$ in the input's letters.

*DP (≈4 pts with zero insight)*
- Let $"NAME"(i)$ = the [*copy the question's quantity*] for the suffix $A[i..n]$ / starting at $A[i]$.
- $"NAME"(i) = 0$ if $i > n$. Otherwise try every choice at $i$: $max_("choice")[$value$ + "NAME"($where I continue$)]$.
- Answer $"NAME"(1)$. Array $"NAME"[1..n+1]$, fill $i$ from $n$ down to 1. Time = entries × choices.

*D&C (≈4–6 pts with zero insight)*
- $"NAME"(A[1..n])$ returns [*copy the question's quantity*]. If $n <= 1$, return \_\_\_.
- Split at $m = floor(n/2)$; recurse on both halves; combine with the given subroutine.
- $T(n) = 2T(n/2) + O(n) = O(n log n)$. (Binary search: $T(n/2) + O(1) = O(log n)$.)

*Timing:* 5 min per problem for this pass (25 min). Then go back and improve the one you understand best. At 15 min stuck on one → move on.

= FILLED-IN: PRACTICE EXAM PROBLEMS (match the closest one, copy its shape)
*GRAPH — rules need memory (Rainbow walk, P2 Q2):* vertices $(v, c)$, $c$ = color of last edge used, plus $(s, "none")$: $3V + 1$. Edge $u -> v$ colored $c'$ gives $(u, c) -> (v, c')$ for every $c != c'$: $<= 3E$. No weights. $v$ reachable by a rainbow walk iff some $(v, \_)$ is reachable from $(s, "none")$. WFS from $(s, "none")$. $O(V + E)$.

*GRAPH — walk with a length budget (P1 Q3: max height, length $<= L$):* Dijkstra from $s$ and from $t$ (undirected, lengths $> 0$). Answer $max{h(v) : d_s (v) + d_t (v) <= L}$. $O(E log V)$.

*GRAPH — nearest of a color (P3 Q3 remoteness):* add super-source $r$ with edges to all red vertices; BFS from $r$; $"dist"_"red" (v) = d(v) - 1$. Same for blue, green. Remoteness $= max$ of the three. $O(V + E)$.

*DAG — prerequisites, fewest terms (P2 Q5):* $"Term"(v) = 1 + max{"Term"(u) : u -> v}$, $= 1$ if no prerequisites. Take $v$ in term $"Term"(v)$; answer $max_v "Term"(v)$ (longest path). Fill in topological order. $O(V + E)$.

*DP — pick pieces of a string (P1 Q4 verbal subsequence):* $"Words"(i)$ = max number of non-overlapping words in $T[i..n]$. $"Words"(i) = 0$ if $i > n$; else $max{"Words"(i+1), max_(j >= i, "IsWord"(T[i..j])) 1 + "Words"(j+1)}$. Answer $"Words"(1)$. Array $[1..n+1]$, $i$ down. $n$ entries × $n$ choices × $O(n)$ IsWord $= O(n^3)$.

*DP — delete from either end (P2 Q3 square-depth):* $"SD"(i, k)$ = max perfect squares seen starting from $X[i..k]$. $"SD"(i,k) = 0$ if $i > k$; else $["IsSquare"(X[i..k])] + max{"SD"(i+1, k), "SD"(i, k-1)}$. Answer $"SD"(1, n)$. Fill by increasing length. $n^2$ entries × $O(n^2)$ IsSquare $= O(n^4)$.

*DP — game vs greedy Elmo (P3 Q2b):* $"Mine"(i,k)$ = most points I get from cards $C[i..k]$ when it is my turn. $"Elmo"(a,b) = 0$ if $a > b$; $= "Mine"(a+1, b)$ if $C[a] > C[b]$; else $"Mine"(a, b-1)$. $"Mine"(i,k) = 0$ if $i > k$; else $max{C[i] + "Elmo"(i+1, k), C[k] + "Elmo"(i, k-1)}$. Answer $"Elmo"(1, n)$ (Elmo moves first). By length; $O(n^2)$.

*D&C — merge $k$ sorted arrays (P2 Q4):* [3] "MergeAll($A_1..A_k$) returns one sorted array of all $k n$ elements." [1] $k = 1$: return $A_1$. [2] $L = "MergeAll"(A_1..A_(k/2))$, $R = "MergeAll"(A_(k/2+1)..A_k)$. [2] merge $L, R$ linearly, $O(n k)$. [2] $T(k) = 2T(k/2) + O(n k) = O(n k log k)$.

*D&C — closest pair with a black box (P1 Q5):* [3] "Closest($P[1..n]$) returns the smallest distance between two points." [1] $n <= 3$: try all pairs. [2] $m = floor(n/2)$; $d_L = "Closest"(P[1..m])$, $d_R = "Closest"(P[m+1..n])$. [2] $(i,j) = "IWalkTheLine"(P, P[m].x)$; return $min{d_L, d_R, "Distance"(P[i],P[j])}$ (every pair is left, right, or crosses). [2] $2T(n/2) + O(n) = O(n log n)$.

*BINARY SEARCH — the one index with $A[i] + A[i+1]$ even (P3 Q4):* before the break, $A[j]$ has *expected parity* $= "par"(A[1]) + (j-1) mod 2$; after it, flipped. [3] "Find($l o, h i$) returns the $i in [l o, h i)$ with $A[i] + A[i+1]$ even." [1] $h i = l o + 1$: return $l o$. [2] $m = floor((l o + h i)/2)$: $A[m]$ expected → Find($m, h i$), else Find($l o, m$). [2] Find(1, n); $T(n/2) + O(1) = O(log n)$.

#colbreak()
= MORE DP SKELETONS (copy the one that matches)
*Two directions / two modes (alternating, last taken up/down):* add the mode as a 2nd input. $"LAS"(i, "down")$ = longest alternating subseq. starting at $A[i]$, next pick smaller. $"LAS"(i,"down") = 1 + max{"LAS"(j, "up") : j > i, A[j] < A[i]}$ (or 1); $"LAS"(i,"up") = 1 + max{"LAS"(j,"down") : j > i, A[j] > A[i]}$. Answer $max_i "LAS"(i,"down")$. Array $[1..n] times {"up","down"}$, $i$ down. $O(n^2)$.

*Two strings $A[1..m]$, $B[1..n]$:* $F(i,j)$ = best for suffixes $A[i..m], B[j..n]$. Choices: match $A[i]$ with $B[j]$ (if allowed) → $F(i+1,j+1)$; skip $A[i]$ → $F(i+1,j)$; skip $B[j]$ → $F(i,j+1)$. Base: $i > m$ or $j > n$ → 0. Array $[1..m+1, 1..n+1]$; $i$ down outer, $j$ down inner. $O(m n)$.

*Interval $A[i..k]$ (split / either end / palindrome):* $F(i,k)$ = best for $A[i..k]$. Base $i > k$ (or $i = k$). Either end → $F(i+1,k)$, $F(i,k-1)$. Split → $max_(i <= j < k) F(i,j) + F(j+1,k)$. Fill by *increasing length* $k - i$ (or $i$ down outer, $k$ up inner). Time = $n^2$ × (choices).

*Tree (rooted, children):* $"In"(v)$ = best for subtree of $v$ if $v$ is chosen; $"Out"(v)$ = if not. $"In"(v) = w(v) + sum_("child" c) "Out"(c)$; $"Out"(v) = sum_c max{"In"(c), "Out"(c)}$. Leaf: $"In" = w(v)$, $"Out" = 0$. Answer $max{"In"("root"), "Out"("root")}$. Store at each node; *postorder*. $O(n)$.

*DAG (longest/shortest/count paths):* $F(v)$ = best path *from* $v$ to $t$. $F(t) = 0$; $F(v) = max_(v -> w) ("len"(v w) + F(w))$; dead end $= -infinity$. Store at vertices; *reverse topological order*. $O(V + E)$.

*Backtracking (recursive, try all):* "$F(i, "state")$ returns [true/best] for items $i..n$ given state." Base $i > n$. Try each option for item $i$, recurse on $i+1$. Time $O("options"^n)$ — then memoize if args are small → DP.

= Q1 "MEANINGLESS RECURRENCE" — SKELETON
"Array $F[$range of arg 1$, $range of arg 2$]$. $F(x,y)$ reads $F(\_\_, \_\_)$, so fill $x$ from \_\_ to \_\_ (outer), $y$ from \_\_ to \_\_ (inner). Time = (\# entries) × (\# terms per entry) = \_\_."
Rule: arg gets *bigger* in calls → fill it *downward*; *smaller* → *upward*; interval $(i,k)$ calls shorter ones → *by length*.
- P1 Foo$(i,k)$ reads $(i,j), (j,k)$, $i<j<k$: array $[1..n,1..n]$, by increasing $k - i$; $n^2 times O(n) = O(n^3)$.
- P1 Bar$(i,s)$ reads $(i, 2s), (i - s, s)$: array $[0..n, 1..n]$; $i$ from 0 *up* (outer), $s$ from $n$ *down* (inner); $O(n^2)$.
- P3 Huh$(i,k)$ reads $(i+1, k-2), (i+2, k-1)$: array $[1..n+2, 0..n]$; $i$ from $n$ *down* (outer), $k$ from 0 up; $O(n^2)$.

= Q1 "DRAW A GRAPH WITH..." — READY ANSWERS
- *DAG, one source, one sink, > 1 topo order:* $s -> a$, $s -> b$, $a -> t$, $b -> t$ ($s,a,b,t$ and $s,b,a,t$).
- *Distinct positive weights, 2 shortest paths $s -> t$:* $s -> a$ (1), $a -> t$ (4), $s -> b$ (2), $b -> t$ (3): both total 5.
- *DFS / BFS / shortest-path tree / topo order on a given graph:* follow side 1 "DRAW BY HAND"; write *NONE* if a cycle blocks topo order.

= GRAPH: ORDER / CYCLE SKELETON
"Vertices = tasks; edge $u -> v$ if $u$ must come before $v$. A valid order exists iff $G$ is a DAG; run DFS, output vertices in *reverse postorder*; if DFS finds an edge to an active vertex, report a cycle. $O(V + E)$."

= MORE FILLED-IN (rest of practice exams + labs)
*Zigzag walk (P3 Q5):* vertices $(v, d)$, $d in {"fwd","back"}$ = direction of the *next* edge. For each edge $u -> v$ (weight $w$): $(u,"fwd") -> (v,"back")$ and $(v,"back") -> (u,"fwd")$, both weight $w$. Shortest path from $(s,"fwd")$ to $(t, \_)$ by Dijkstra. $O(E log V)$. \
*75% of classes (P2 Q5b):* compute $"Term"(v)$ (part a); answer = smallest $T$ with $|{v : "Term"(v) <= T}| >= 0.75 |V|$. $O(V + E)$. \
*Ranking consistent with games (Lab 9b):* edge $i -> j$ if $i$ beat $j$ in some game ($3m$ edges). Ranking = topological order; exists iff DAG. DFS. $O(n + m)$. \
*Always move farther from home (Lab 9b):* edge $u -> v$ if $D[v] > D[u]$ → DAG ($D$ increases). Add $t$; longest path $s -> t$ by DP in topo order. $O(n + m)$. \
*Exactly one negative edge $u -> v$ (Lab 10a):* delete it → $G'$. Dijkstra from $s$ and from $v$. $min{d'(s,t), d'(s,u) + w(u v) + d'(v,t)}$. $O(E log V)$. \
*Meet a friend ASAP (Lab 10a):* Dijkstra from $p$ and from $q$; pick $t$ minimizing $max{d_p (t), d_q (t)}$. $O(E log V)$. \
*Fix one edge in all-pairs table (Lab 10b):* $"dist"'[x,y] = min{"dist"[x,y], "dist"[x,u] + w'(u v) + "dist"[v,y]}$. $O(V^2)$. \
*Jumps with landing spot (Lab 8a ramps):* $"MaxAir"(i) = max{"MaxAir"(i+1), "Length"[i] + "MaxAir"("Next"(i))}$, $"Next"$ by binary search. $O(n log n)$. *At most $k$ jumps:* add $ell$: $"MaxAir"(i, ell)$, $ell - 1$ when jumping; $O(n log n + n k)$. \
*Build $n$ from 1s (Lab 8b):* $"Min1s"(1) = 1$; $"Min1s"(n) = min$ over $m$ of $"Min1s"(m) + "Min1s"(n - m)$ and, if $m | n$, $"Min1s"(m) + "Min1s"(n/m)$. Fill increasing. $O(n^2)$.
