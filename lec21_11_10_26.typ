#import "setup.typ": *

#let body = [
= Lecture 21 (Nov 10) - Karp Reductions: Decision Problems, Independent Set, Clique, Vertex Cover

This lecture begins the part of the course that asks which problems we probably cannot
solve quickly. We restrict attention to decision problems, which are the same thing as
languages, and we define polynomial-time many-one reductions, also called Karp
reductions. Reductions have been our main tool for designing algorithms. Here we use
them in the opposite direction, to transfer hardness from one problem to another. As a
first example we introduce three graph problems (independent set, clique, and vertex
cover) and prove that independent set and clique are equivalent up to polynomial time.

== Where the Course Goes Next
The course falls into three parts.
- The first month studied models of computation. We asked what a computer can do at
  all, usually in terms of strings: which properties of a string a DFA can check,
  which strings a context-free grammar can generate, and finally Turing machines,
  which can answer essentially any question about strings that we can hope to answer.
- The second part assumed a general model of computation close to real computers and
  asked what we can do quickly. We designed algorithms that beat trying every possible
  solution.
- The third part turns both questions around and takes them in reverse order. The next two weeks ask
  which problems probably have no fast algorithm, and how we can argue that. The final
  week asks which problems cannot be solved correctly by any algorithm at all.

This lecture sets up both questions. Lecture 22 addresses directly why we believe some
problems cannot be solved quickly.

== Optimization and Decision Problems
Most problems in the algorithms part of the course were *optimization problems*. The
input admits many *feasible solutions*, each with a value, and the goal is to find the
best one.

*Example:* Shortest paths (unweighted). Given a directed graph $G$ and two vertices $s$
and $t$, find a shortest path from $s$ to $t$. Breadth-first search solves this
problem.

To talk precisely about which problems are hard, it is easier to restrict the kind of
problem we consider. A *decision problem* gives an input and asks a yes-or-no
question about it, without asking for a best solution. Optimization problems usually
have decision versions.

*Example:* Shortest paths, decision version. Given a directed graph $G$, two vertices
$s$ and $t$, and an integer $k$, is $text("dist")(s, t) <= k$? The number $k$ is part
of the input, along with the graph and the two vertices.

The two versions are rarely far apart, since each can usually be solved with an
algorithm for the other.
- From optimization to decision: solve the optimization problem, look at the length of
  the shortest path, and compare it with $k$.
- From decision to optimization: call the decision algorithm as a black box for every
  $k$ from $0$ to $|V|$, and report the smallest $k$ for which the answer is yes.

Decision problems give a cleaner interface, because there are only two possible
answers. They make it easier to state theorems about difficulty, and the results we
prove for them carry over to optimization problems with little effort. From now on we
work with decision problems.

=== Decision problems are languages
There is a second reason to focus on decision problems: they tie directly to the first
part of the course. On a real computer every input is a string of $0$s and $1$s, so we
may treat the input to any decision problem $A$ as a string that describes it, for
example a string that encodes a graph, two vertices and an integer. The inputs whose
answer is yes then form a set of strings, that is, a language:

$ L_A = {x : x "is a yes instance of" A} $

Conversely, every language $L$ defines a decision problem: given a string $x$, is
$x in L$? Decision problems and languages are therefore essentially the same concept,
and we use the two words interchangeably. The next few lectures mostly say "problem";
the final week of the course, which returns to Turing machines, mostly says
"language."

== Showing That a Problem Is Hard
Suppose we have a decision problem $A$ and want to know whether some algorithm decides,
for every instance of $A$, whether it is a yes or a no instance, in polynomial time.
If the answer is yes, we have practiced what to do: design the algorithm. If the
answer is no, we need a way to argue it, and very few tools prove outright that a
problem cannot be solved quickly.
- In special models we can prove lower bounds. Sorting by comparisons between pairs of
  objects requires $Omega(n log n)$ time.
- For most problems no such proof is known. For example, nobody can prove that
  shortest paths with negative edge lengths require more than linear time.

The best available method is comparison. We relate a new problem to a problem that we
already believe is hard, and argue that the new problem is at least as hard. The
comparison is a reduction: if a fast algorithm for $B$ would give a fast algorithm for
$A$, and we do not believe that $A$ has a fast algorithm, then $B$ probably has none
either.

In earlier lectures a reduction treated another problem as a black box. To find the
useless states of a DFA we reduced to reachability, trusting that some reachability
algorithm exists without needing to know how it works. Recursion is also a reduction:
we solve a large instance by trusting an algorithm for smaller instances of the same
problem. For hardness arguments we use a more restricted kind of reduction.

== Many-One and Karp Reductions
A *many-one reduction* from a decision problem $A$ to a decision problem $B$ is a
function $f$ that maps instances of $A$ to instances of $B$ such that, for every
instance $x$ of $A$,

$ x "is a yes instance of" A quad <==> quad f(x) "is a yes instance of" B $

In the language of strings, $x in L_A$ if and only if $f(x) in L_B$. The function must
be computable: some algorithm must take $x$ and eventually produce $f(x)$. For a
general many-one reduction, the time this algorithm takes does not matter.

The condition is an "if and only if," so it says two things:
- every yes instance of $A$ maps to a yes instance of $B$, and
- every no instance of $A$ maps to a no instance of $B$. Equivalently, if $f(x)$ is a
  yes instance of $B$, then $x$ was a yes instance of $A$.

The name comes from the fact that $f$ need not be one-to-one. Many different instances
of $A$ may collapse to the same instance of $B$. Nor does $f$ need to be onto, since
some instances of $B$ may never be produced. The requirement is only that $f$ is a
function, defined on every instance of $A$.

A *polynomial-time many-one reduction*, or *Karp reduction*, is a many-one reduction
$f$ that can be computed in time polynomial in $|x|$, the size of the input. If a Karp
reduction from $A$ to $B$ exists, we write

$ A scripts(<=)_P B quad "or, equivalently," quad L_A scripts(<=)_P L_B $

The $P$ stands for polynomial. The notation suggests that $A$ is no more difficult
than $B$, up to the polynomial overhead of the reduction.

#trap[The symbol is a less-than-or-equal sign, not a subset sign. The strings $f(x)$
can look very different from the strings $x$, and $L_A$ need not be a subset of $L_B$.
The symbol compares the difficulty of two problems.]

=== Fast algorithms transfer backward along reductions
Suppose $A scripts(<=)_P B$ through a reduction $f$ that runs in $O(|x|^c)$ time, and suppose
an algorithm decides $B$ in $O(|y|^d)$ time on an input $y$. To decide an instance $x$
of $A$, we compute $f(x)$, run the algorithm for $B$ on it, and return its answer. The
answer is correct because $x$ and $f(x)$ have the same answer.

Polynomials compose. The reduction may make the input larger, but not by more than a
polynomial: writing $f(x)$ takes at least $|f(x)|$ steps, so $|f(x)| = O(|x|^c)$. The
algorithm for $B$ then takes $O((|x|^c)^d) = O(|x|^(c d))$ time, and the whole
procedure takes

$ O(|x|^c + |x|^(c d)) $

time, which is again a polynomial in $|x|$.

So if $A scripts(<=)_P B$ and $B$ has a polynomial-time algorithm, then $A$ has a
polynomial-time algorithm too. This matches how we have used reductions so far: to
solve $A$, reduce it to a problem $B$ that we already know how to solve. For the next
week and a half we use the contrapositive instead.

#keyidea[If $A scripts(<=)_P B$ and $A$ has no polynomial-time algorithm, then $B$ has no
polynomial-time algorithm. Otherwise the reduction followed by the algorithm for $B$
would solve $A$ in polynomial time, a contradiction.]

#trap[The direction is the reverse of what we are used to. When designing algorithms,
we reduce the new problem to a problem we already know how to solve. When proving
hardness, we reduce a problem we already believe is hard to the new problem.]

== Three Graph Problems
The next three problems take the same input: an undirected graph $G = (V, E)$ and an
integer $k >= 0$.

- An *independent set* in $G$ is a subset $S subset.eq V$ such that no two vertices of
  $S$ share an edge. The *independent set problem* (IndSet) asks whether $G$ has an
  independent set of size $k$. Independent sets in trees appeared in Lecture 15.
- A *clique* in $G$ is a subset $S subset.eq V$ such that every pair of vertices of $S$
  shares an edge. The *clique problem* (Clique) asks whether $G$ has a clique of size
  $k$.
- A *vertex cover* in $G$ is a subset $S subset.eq V$ that covers every edge: every
  edge has at least one endpoint in $S$. An edge may have both endpoints in $S$. The
  *vertex cover problem* (VertexCover) asks whether $G$ has a vertex cover of size $k$.

An independent set may include endpoints of many edges of $G$. The only requirement is
that no edge has both endpoints in $S$.

For the first two problems, a larger $k$ is the harder request: can we find as many as
$k$ vertices that are pairwise non-adjacent, or pairwise adjacent? Vertex cover goes the
other way. Large covers are easy (all of $V$ is a cover), and the question is whether
as few as $k$ vertices suffice to cover every edge.

*Example (not from lecture):* The graph below is a 6-cycle
$a, b, c, d, e, f$ with one extra edge $a c$. The yellow vertices show an independent
set ${b, d, f}$, a clique ${a, b, c}$ (bold edges), and a vertex cover ${a, c, e}$,
each of size $3$.

#let hex-pos = (a: (0.6, 0), b: (1.8, 0), c: (2.4, 1.04), d: (1.8, 2.08), e: (0.6, 2.08), f: (0, 1.04))
#let hex-edges = (("a", "b"), ("b", "c"), ("c", "d"), ("d", "e"), ("e", "f"), ("f", "a"), ("a", "c"))
#align(center, grid(
  columns: 3,
  column-gutter: 2.5em,
  align: center,
  stack(spacing: 6pt,
    graph-pic(hex-pos, hex-edges, marked: ("b", "d", "f"), unit: 36pt),
    text(size: 0.85em)[Independent set]),
  stack(spacing: 6pt,
    graph-pic(hex-pos, hex-edges, marked: ("a", "b", "c"),
      bold: (("a", "b"), ("b", "c"), ("a", "c")), unit: 36pt),
    text(size: 0.85em)[Clique]),
  stack(spacing: 6pt,
    graph-pic(hex-pos, hex-edges, marked: ("a", "c", "e"), unit: 36pt),
    text(size: 0.85em)[Vertex cover]),
))

No polynomial-time algorithm is known for any of these three problems. We can show,
however, that if any one of them has a polynomial-time algorithm, then all three do,
and by the contrapositive, if any one of them has none, then none of them do. The
proof consists of Karp reductions between the problems. This lecture proves
$text("IndSet") scripts(<=)_P text("Clique")$ and $text("Clique") scripts(<=)_P text("IndSet")$;
Lecture 22 proves the equivalence with vertex cover and explains why we believe that
none of the three can be solved quickly.

== Reducing Independent Set to Clique
We claim that $text("IndSet") scripts(<=)_P text("Clique")$. So we need a polynomial-time
procedure that takes an instance $(G, k)$ of independent set and builds an instance
$(G', k')$ of clique with the same answer. The new instance is also an undirected graph
with an integer, but $G'$ is a different graph from $G$.

=== The construction
Let $G' = (V, E')$ be the *complement* of $G$: it has the same vertices, and

$ u v in E' quad <==> quad u v in.not E quad "for all distinct" u, v in V $

Let $k' = k$.

```
IndSetToClique(G = (V, E), k):
  build an adjacency matrix for G
  E′ ← ∅
  for each pair of distinct vertices u, v
    if uv ∉ E
      add uv to E′
  return (G′ = (V, E′), k)
```

The reduction only transforms the input. It never looks for an independent set in $G$
or a clique in $G'$, and it does not know whether the answer is yes or no. The
correctness proof below checks that the two answers always agree.

=== Running time
The reduction builds a table of the edges of $G$ and checks every pair of vertices, so
it runs in $O(|V|^2)$ time (plus $O(|E|)$ to read the input). This is polynomial in
the input size.

The running time of a reduction counts only the transformation. We have no algorithm
for clique here and do not know how long one would take, so the analysis says nothing
about the time to solve either problem.

#trap[Always state that the reduction runs in polynomial time, and check it. A
reduction that takes a very long time is not useful, and it is not a Karp
reduction.]

=== Correctness
It remains to show that this is a many-one reduction, that is, the following claim.

*Claim:* $G$ has an independent set of size $k$ if and only if $G'$ has a clique of
size $k'$.

The claim is an "if and only if," so we prove both directions.

$arrow.double.r$ Suppose $S$ is an independent set in $G$ with $|S| = k$. Take any two
distinct vertices $u, v in S$. Because $S$ is independent, $u v in.not E$. By the
construction of $G'$, $u v in E'$. So every pair of vertices of $S$ is adjacent in
$G'$, and the same set $S$ is a clique in $G'$ of size $k = k'$.

$arrow.double.l$ Suppose $S'$ is a clique in $G'$ with $|S'| = k'$. Take any two
distinct vertices $u, v in S'$. Because $S'$ is a clique, $u v in E'$. By the
definition of $E'$, $u v in.not E$. So no two vertices of $S'$ share an edge in $G$,
and the same set $S'$ is an independent set in $G$ of size $k' = k$.

The first direction maps yes instances of independent set to yes instances of clique.
The second shows that a yes instance of clique can come only from a yes instance of
independent set, so no instances map to no instances.

#trap[Proving only the first direction is not enough. That direction alone would allow
a reduction that maps every instance to a fixed yes instance of $B$.]

*Example (not from lecture):* Applying the reduction to the graph from the previous
example gives the complement $G'$ below. The graph $G$ has $7$ of the $binom(6, 2) = 15$
possible edges, so $G'$ has the other $8$. The independent set ${b, d, f}$ of $G$ is a
clique in $G'$ (bold edges).

#let comp-edges = (("a", "d"), ("a", "e"), ("b", "d"), ("b", "e"), ("b", "f"), ("c", "e"), ("c", "f"), ("d", "f"))
#align(center, grid(
  columns: 2,
  column-gutter: 3em,
  align: center,
  stack(spacing: 6pt,
    graph-pic(hex-pos, hex-edges, marked: ("b", "d", "f"), unit: 40pt),
    text(size: 0.85em)[$G$, with $k = 3$]),
  stack(spacing: 6pt,
    graph-pic(hex-pos, comp-edges, marked: ("b", "d", "f"),
      bold: (("b", "d"), ("b", "f"), ("d", "f")), unit: 40pt),
    text(size: 0.85em)[$G'$, with $k' = 3$]),
))

=== Reducing clique to independent set
The same construction also proves $text("Clique") scripts(<=)_P text("IndSet")$. Given an
instance $(G, k)$ of clique, output the complement $G'$ together with $k$. The argument
above, with the roles of $G$ and $G'$ exchanged, shows that $G$ has a clique of size
$k$ if and only if $G'$ has an independent set of size $k$, because the complement of
$G'$ is $G$ again. A single construction that works in both directions is rare, but it
happens here. Independent set and clique are therefore equally hard up to polynomial
factors.

#keyidea[A Karp reduction from $A$ to $B$ has three parts:
- an algorithm that transforms any instance $x$ of $A$ into an instance $f(x)$ of $B$,
  without solving either problem;
- a proof that this algorithm runs in polynomial time;
- a proof that $x$ is a yes instance of $A$ if and only if $f(x)$ is a yes instance of
  $B$, with both directions argued separately.]
]

#show: notes
#set heading(numbering: "1.1")
#body
