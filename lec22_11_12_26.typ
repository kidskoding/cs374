#import "setup.typ": *

#let body = [
= Lecture 22 (Nov 12) - NP-Hardness: P, NP, NP-Completeness, SAT, and 3SAT

Lecture 21 introduced reductions as a way to show that one problem is at least as hard
as another. This lecture finishes the examples among three graph problems and then
explains why we believe that none of them has a polynomial-time algorithm. We define
the complexity classes P and NP, the notions of NP-hardness and NP-completeness, and
the first NP-complete problem, SAT. We close by reducing SAT to the more structured
problem 3SAT, a convenient starting point for the NP-hardness proofs of Lectures 23
and 24.

== Recap: Three Problems and Karp Reductions
Each of the following problems takes an undirected graph $G = (V, E)$ and an integer
$k$ as input.
- *Independent set* (IS): is there a subset $S subset.eq V$ with $|S| = k$ such that no
  two vertices of $S$ share an edge?
- *Clique*: is there a subset $S subset.eq V$ with $|S| = k$ such that every pair of
  vertices of $S$ shares an edge?
- *Vertex cover* (VC): is there a subset $S subset.eq V$ with $|S| = k$ that covers
  every edge, meaning that for every edge $u v$, $u in S$ or $v in S$ (or both)?

Decision problems of this kind are often stated with "at least $k$" or "at most $k$."
For these three problems, "exactly $k$" is equivalent. Removing vertices from an
independent set or a clique leaves an independent set or a clique, so if one of size
at least $k$ exists, then one of size exactly $k$ exists. Adding vertices to a vertex
cover leaves a vertex cover, so if one of size at most $k$ exists, then one of size
exactly $k$ exists. For a problem such as shortest paths, the inequality "at most $k$"
is the natural form.

Recall from Lecture 21 that a *Karp reduction* (a polynomial-time many-one reduction)
from a problem $A$ to a problem $B$ is a polynomial-time algorithm that transforms any
input $x$ for $A$ into an input $x'$ for $B$ such that $x$ is a yes instance of $A$ if
and only if $x'$ is a yes instance of $B$. Lecture 21 gave a Karp reduction from
independent set to clique: keep $k$ and replace $G$ by its complement.

== Independent Set Reduces to Vertex Cover
#theorem[There is a Karp reduction from independent set to vertex cover.]

The reduction is given an input $(G, k)$ for independent set and produces an input
$(G', k')$ for vertex cover:

$ G' = G, quad quad k' = |V| - k $

Copying the graph and computing $k'$ is the entire algorithm. It takes constant time
if the graph is reused, or linear time if it is copied, so it certainly runs in
polynomial time.

#trap[The reduction algorithm does not know the answer to the independent set
instance. It sees only the graph $G$ and the integer $k$, and it never knows whether an
independent set of size $k$ exists, or which vertices it would contain. Its output can
therefore depend only on $(G, k)$. The correctness proof, on the other hand, may talk
about independent sets and vertex covers that may or may not exist.]

=== Correctness
We must show that $G$ has an independent set of size $k$ if and only if $G' = G$ has a
vertex cover of size $k' = |V| - k$.

($==>$) Suppose that $S$ is an independent set of size $k$ in $G$. No edge of $G$ has
both endpoints in $S$, so every edge has at least one endpoint in $V without S$. Thus
$V without S$ covers every edge, and it is a vertex cover of size
$|V| - |S| = |V| - k = k'$.

($<==$) Suppose that $S'$ is a vertex cover of size $|V| - k$ in $G' = G$. For every
edge $u v in E$, we have $u in S'$ or $v in S'$, which means that $u in.not V without S'$
or $v in.not V without S'$. So no edge has both endpoints in $V without S'$, and
$V without S'$ is an independent set. Its size is $|V| - |S'| = |V| - (|V| - k) = k$.

Reductions are often not obviously correct from the description of the
transformation alone, so a complete answer describes the reduction
algorithm, argues that it runs in polynomial time, and proves both directions of the
"if and only if." For reductions out of independent set, the algorithms are so short
that writing them down can feel pointless, but the proof is still required.

*Example (not from lecture):* In the graph below, $S = {b, d}$ (shaded) is an
independent set of size $2$. Its complement ${a, c}$ is a vertex cover of size
$4 - 2 = 2$: every edge touches $a$ or $c$.

#align(center, graph-pic(
  (a: (0, 0), b: (1.5, 0), c: (1.5, 1.2), d: (0, 1.2)),
  (("a", "b"), ("b", "c"), ("c", "d"), ("d", "a"), ("a", "c")),
  marked: ("b", "d"),
  unit: 50pt,
))

=== Consequences
The reduction shows that a polynomial-time algorithm for vertex cover would give one
for independent set: transform the instance by computing $k'$, then solve vertex cover.
By the contrapositive, if independent set has no polynomial-time algorithm, then
neither does vertex cover.

The same transformation, with the same proof up to the arithmetic at the end of each
direction, also reduces vertex cover to independent set. Usually a transformation in
one direction does not also work in the other; it happens to work here, as it did for
independent set and clique.

Reductions compose. Reducing vertex cover to independent set and then independent set
to clique gives a polynomial-time transformation from vertex cover to clique, and
similarly clique reduces to independent set and then to vertex cover. So these three
problems have the same difficulty up to polynomial extra work: if any one of them has a
polynomial-time algorithm, all three do, and if any one of them has none, none of them
does. The vast majority of computer scientists believe that none of the three has a
polynomial-time algorithm, and the rest of this lecture explains why.

== The Class P
A *complexity class* is a collection of problems grouped by the resources (such as
time or space) needed to solve them. Every decision problem $A$ corresponds to the
language of its yes instances, and complexity theorists usually phrase complexity
classes as sets of languages.

*P* is the set of decision problems that can be solved in polynomial time. More
precisely, $A in P$ if and only if there is a function
$Q_A : Sigma^* -> {"False", "True"}$ and a constant $c$ such that
- $Q_A (x)$ can be computed in $O(|x|^c)$ time, and
- $Q_A (x) = "True"$ if and only if $x$ is a yes instance of $A$.

The function $Q_A$ is the polynomial-time algorithm for $A$.

*Example:* Given an unweighted directed graph $G$, vertices $s$ and $t$, and an integer
$k$, is the distance from $s$ to $t$ at most $k$? This problem is in P, because we can
compute the distance with breadth-first search, Dijkstra's algorithm, or even
Bellman-Ford. Any polynomial-time algorithm suffices.

Independent set is probably not in P, but it has another useful property. If
$(G, k)$ is a yes instance and someone tells us which vertices form the independent
set, we can check the answer quickly: we confirm that the list has $k$ vertices of $G$
and that no edge joins two of them. Many problems share this property: whenever the
answer is yes, there is a short proof of that fact which can be checked quickly.

== The Class NP
Informally, *NP* is the set of decision problems for which every yes instance has a
proof that the answer is yes, where the proof has polynomial size and can be verified
in polynomial time.

Formally, $A in "NP"$ if and only if there is a function
$R_A : Sigma^* times Sigma^* -> {"False", "True"}$, called the *verifier*, and a
constant $c$ such that
- $R_A (x, y)$ can be computed in time polynomial in $|x|$ and $|y|$, and
- for every input $x$,
  $ x "is a yes instance of" A <==> (exists y : |y| = O(|x|^c) "and" R_A (x, y) = "True"). $

A string $y$ with $R_A (x, y) = "True"$ is a *certificate* for $x$. The certificate is
a string describing why the answer is yes, or equivalently a proof that the answer is
yes. Each yes instance has at least one certificate that makes the verifier accept,
and possibly many. A no instance has no certificate at all: whatever string we hand
the verifier, it checks that string against $x$ and rejects. The verifier comes with
the problem itself.

As a rule of thumb, if a problem asks "is there a thing that does such-and-such?" and we
can check in polynomial time that a given thing does such-and-such, then the problem
is in NP, with the thing itself as the certificate.

=== Examples
_Independent set is in NP._ For a yes instance $(G, k)$, the certificate is a list of
the vertices of an independent set $S$ of size $k$, which has polynomial size. The
verifier checks that $S$ is a subset of $V$, that $|S| = k$, and that no edge of $G$
joins two vertices of $S$. All of this takes polynomial time. If $(G, k)$ is a no
instance, then by definition $G$ has no independent set of size $k$, so every proposed
certificate fails one of the checks.

_Vertex cover is in NP._ For a yes instance $(G, k)$, the certificate is a vertex cover
$S$ of size $k$. The verifier checks that $|S| = k$ and then examines every edge of $G$
to confirm that it has an endpoint in $S$. A no instance has no vertex cover of size
$k$, so no certificate makes the verifier accept.

_Shortest path is in NP._ Given an unweighted graph, vertices $s$ and $t$, and an
integer $k$, the verifier ignores the certificate entirely, runs breadth-first search
or Dijkstra's algorithm from scratch, and accepts if and only if the distance is at
most $k$. The verifier only has to run in polynomial time, which it does. Since it solves the problem
itself, no certificate can fool it on a no instance.

=== P is contained in NP
The last example generalizes. If $A in P$, then $A in "NP"$: the certificate for a yes
instance can be the empty string, and the verifier solves the problem from scratch. In
terms of the functions above, we take $R_A (x, y) = Q_A (x)$. Thus

$ P subset.eq "NP". $

Whether the containment is proper is the open question "P = NP?" A problem in NP may
well be solvable in polynomial time; for many of them we do not know how.

#trap[NP does not stand for "not polynomial." It stands for *nondeterministic
polynomial*. Formally, P is the set of languages decided by a polynomial-time Turing
machine, and NP is the set of languages decided by a nondeterministic polynomial-time
Turing machine, which may guess which transition to make at every step. The
certificate tells the machine which transitions lead to an accepting state. Erickson's
notes have a chapter on nondeterministic Turing machines; in this course the verifier
definition is enough.]

== NP-Hardness and NP-Completeness
A problem $B$ is *NP-hard* if for every problem $A in "NP"$ there is a Karp reduction
from $A$ to $B$. In other words, a polynomial-time algorithm for $B$ would give a
polynomial-time algorithm for every problem in NP.

Many problems in NP appear very difficult to solve quickly, and we do not believe that
all of them can be. Almost everyone who knows these definitions believes that
$P != "NP"$. The belief rests on more than our failure to find fast algorithms: a
polynomial-time algorithm for every problem in NP would have many surprising
consequences, some of which appear below. So if $B$ is NP-hard, then $B$ probably has no
polynomial-time algorithm.

#keyidea[Showing that a problem is NP-hard is strong evidence that it has no
polynomial-time algorithm. Once a problem is shown to be NP-hard, we should stop
looking for an exact polynomial-time algorithm for it.]

Some NP-hard problems are themselves in NP. A problem $B$ is *NP-complete* if $B$ is
NP-hard and $B in "NP"$. NP-complete problems sit at the top of NP:
- If an NP-complete problem $B$ has a polynomial-time algorithm, then every problem in
  NP does, because $B$ is NP-hard. Then $P = "NP"$.
- If $P != "NP"$, some problem in NP has no polynomial-time algorithm. That problem
  reduces to $B$, so $B$ has no polynomial-time algorithm either.

So an NP-complete problem has a polynomial-time algorithm if and only if $P = "NP"$.
Other NP-hard problems lie outside NP and are harder still; for many of them we know
for certain that no polynomial-time algorithm exists. The picture below shows what we
believe the world looks like. EXP is the class of problems solvable in exponential
time, and the outer two classes are the recursive (decidable) and recursively
enumerable languages from earlier in the course. We do not need EXP or the classes
beyond it in this course.

#align(center, box(width: 380pt, height: 178pt, {
  let region(x, y, w, h, name) = place(dx: x, dy: y, rect(
    width: w, height: h, radius: 6pt, stroke: 0.6pt + accent, fill: accent-light.transparentize(40%),
    align(left + top, text(size: 0.8em, name)),
  ))
  region(0pt, 0pt, 380pt, 178pt, [Recursively enumerable])
  region(10pt, 20pt, 340pt, 150pt, [Recursive (decidable)])
  region(20pt, 40pt, 260pt, 122pt, [EXP])
  region(30pt, 60pt, 170pt, 94pt, [NP])
  region(40pt, 80pt, 60pt, 66pt, [P])
  place(dx: 140pt, dy: 52pt, rect(
    width: 236pt, height: 110pt, radius: 6pt,
    stroke: (paint: warn-color, thickness: 0.8pt, dash: "dashed"), fill: warn-light.transparentize(45%),
  ))
  place(dx: 290pt, dy: 56pt, text(size: 0.8em, fill: warn-color)[NP-hard])
  place(dx: 144pt, dy: 112pt, text(size: 0.75em, fill: warn-color)[NP-complete])
}))
#align(center, text(size: 0.85em)[The believed relationship among the classes, assuming
$P != "NP"$. NP-complete problems are the NP-hard problems inside NP.])

If $P = "NP"$, then verifying a
solution would be essentially as easy as finding one from scratch. Being able to
understand homework solutions would be the same as being able to solve the homework.
Checking that a password matches a stored hash would be as easy as finding a password
that matches the hash, so classical cryptography would break: one could recover
passwords from hashes or private keys from signed documents. On the positive side, we
could probably design medicines faster and solve many other problems with certainty,
assuming the polynomial-time algorithms were fast in practice. There is no proof in
either direction, so we assume that $P != "NP"$ and study the consequences.

== Satisfiability
So far no NP-complete problem has appeared. The canonical one is about Boolean
formulas.

Let $phi$ be a Boolean formula over variables $x_1, dots, x_n$. Each variable can be set
to True or False, and after all of them are set, $phi$ evaluates to True or False.
- A *literal* is a variable or its negation: $x$ or $overline(x)$.
- A *clause* is a disjunction (OR) of one or more literals.
- $phi$ is in *conjunctive normal form* (CNF) if it is a conjunction (AND) of clauses.

*SAT* is the decision problem: given a Boolean formula $phi$ in CNF, is there an
assignment of True and False to the variables that makes $phi$ True? Such an
assignment *satisfies* $phi$. Because $phi$ is a conjunction of clauses, a satisfying
assignment must make at least one literal True in every clause. A variable may appear in
several clauses, sometimes negated and sometimes not, so the choices for different
clauses interact.

*Example (not from lecture):* The formula
$ (x_1 or overline(x)_2 or x_4) and (x_2 or overline(x)_3) and (overline(x)_1 or x_3 or overline(x)_4) and (x_2 or x_4) $
is in CNF, with four clauses. It is satisfied by $x_1 = x_2 = x_3 = "True"$ and
$x_4 = "False"$: the clauses are made True by $x_1$, by $x_2$, by $x_3$ (or
$overline(x)_4$), and by $x_2$, respectively.

#theorem[SAT is NP-complete.]

_SAT is in NP._ The certificate for a yes instance is a satisfying assignment. The
verifier substitutes the values into $phi$ and checks that every clause contains a True
literal, in time linear in the length of $phi$. This is almost the definition of SAT,
which asks whether there is an assignment that makes the formula True.

_SAT is NP-hard._ Every problem in NP reduces to SAT. This is the Cook-Levin theorem.
We do not prove it in this course; the course notes give a paragraph with the
high-level idea. The proof involves many technical details, and we will never need to
repeat that kind of argument for another problem.

=== Proving other problems NP-hard
With one NP-hard problem in hand, further NP-hardness proofs become much easier, since
reductions compose.

#keyidea[To prove that a problem $B$ is NP-hard, give a Karp reduction from some
known NP-hard problem $A$ to $B$. Any problem in NP reduces to $A$ in polynomial time,
and $A$ reduces to $B$, so chaining the two reductions reduces every problem in NP to
$B$.]

For example, a Karp reduction from SAT to independent set would show that independent
set is NP-hard: any problem in NP reduces to SAT, and SAT reduces to independent set.

#trap[To show that $B$ is hard, reduce a known hard problem _to_
$B$. A reduction from $B$ to a hard problem only shows that $B$ is no harder than that
problem, which says nothing about whether $B$ is hard.]

== 3SAT
Many reductions are easier when the formula has a rigid structure. *3SAT* is SAT
restricted to CNF formulas with exactly three literals in every clause.

#theorem[3SAT is NP-complete.]

_3SAT is in NP._ It is a special case of SAT, so the same certificate (a satisfying
assignment) and the same verifier work.

_3SAT is NP-hard._ 3SAT is just as hard as SAT, even though it allows only formulas of
a restricted shape. We give a Karp reduction from SAT to 3SAT; chaining it after the reduction
from any NP problem to SAT shows that every problem in NP reduces to 3SAT.

=== Splitting long clauses
Given a CNF formula $phi$, we must build a CNF formula $phi'$ with exactly three
literals per clause that is satisfiable if and only if $phi$ is. As long as $phi$ has a
clause with more than three literals, we replace that clause by two clauses using a
new variable $z$ that appears nowhere else:

$ (ell_1 or ell_2 or ell_3 or dots or ell_m) quad arrow.long.squiggly quad
  (ell_1 or ell_2 or z) and (overline(z) or ell_3 or dots or ell_m), quad m >= 4. $

For instance,
$(x_1 or x_2 or x_3 or x_4 or x_5)$ becomes
$(x_1 or x_2 or z_1) and (overline(z)_1 or x_3 or x_4 or x_5)$.

_Claim._ An assignment of the original variables satisfies the long clause if and only
if it can be extended with a value for $z$ that satisfies both new clauses.

($==>$) Some literal $ell_i$ is True. If $i <= 2$, set $z = "False"$: the first clause
is satisfied by $ell_i$, and the second by $overline(z)$. If $i >= 3$, set
$z = "True"$: the first clause is satisfied by $z$, and the second by $ell_i$. For
example, if $x_2$ is the only True literal of $(x_1 or x_2 or x_3 or x_4 or x_5)$, we
set $z_1 = "False"$.

($<==$) Suppose that both new clauses are satisfied. If $z = "True"$, the second clause
must be satisfied by some $ell_i$ with $i >= 3$. If $z = "False"$, the first clause must
be satisfied by $ell_1$ or $ell_2$. Either way some literal of the original clause is
True.

Since $z$ appears in no other clause, the rest of the formula is unaffected, so the
whole new formula is satisfiable if and only if the old one is.

The second new clause has $m - 1$ literals, which may still be more than three. We
repeat the step until every clause has at most three literals. A clause with $m$
literals is split $m - 3$ times, so the number of new variables and new clauses is at
most the length of $phi$, and the reduction runs in polynomial time.

=== Padding short clauses
Clauses with one or two literals are padded with new variables until every clause has
exactly three literals. The standard construction, with fresh variables $y$ and $w$ used nowhere else, is

$ (a or b) quad arrow.long.squiggly quad (a or b or y) and (a or b or overline(y)) $
$ (a) quad arrow.long.squiggly quad (a or y or w) and (a or y or overline(w)) and (a or overline(y) or w) and (a or overline(y) or overline(w)) $

For each choice of values for $y$ and $w$, exactly one of the new clauses has all of
its padding literals False, so it reduces to the original clause, and every other new
clause contains a True padding literal. So an assignment satisfies the original clause
if and only if it can be extended to satisfy all the new clauses. This adds $O(1)$ variables and clauses per short clause.

```
SatTo3Sat(φ):
  while φ has a clause (ℓ1 ∨ ℓ2 ∨ ℓ3 ∨ … ∨ ℓm) with m ≥ 4
    z ← a new variable
    replace it by (ℓ1 ∨ ℓ2 ∨ z) ∧ (¬z ∨ ℓ3 ∨ … ∨ ℓm)
  for each clause with fewer than three literals
    pad it with new variables as above
  return φ
```

#keyidea[SAT and 3SAT are both NP-complete. 3SAT's rigid clause structure makes it a
convenient starting point for the NP-hardness proofs in Lectures 23 and 24. Converting CNF formulas into equivalent ones
with more structure is the basic skill behind such proofs.]
]

#show: notes
#set heading(numbering: "1.1")
#body
