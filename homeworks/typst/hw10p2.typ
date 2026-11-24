// CS 374 A, Homework 10, Problem 2
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) as a tutor for this problem: it helped me understand
  the problem and guided me, through explanation and questions, toward a correct
  approach. I wrote and typeset this entire submission myself.
]

#let SM = smallcaps[StringMatch]
#let ThreeSat = [3#smallcaps[Sat]]
#let True = smallcaps[True]
#let False = smallcaps[False]

#show: homework.with(
  title: "CS 374: Section A - Homework 10, Problem 2",
  date: "November 17, 2026",
)

Say that a string $w in {lit("0"), lit("1")}^n$ *matches* a string
$s in {lit("0"), lit("1"), lit("2")}^n$ if $s[j] = w[j]$ for at least one
position $j$. We show that #SM is NP-hard by describing a polynomial time
reduction from #ThreeSat, which is NP-hard.

= Reduction

Let $Phi$ be a 3CNF formula with variables $x_1, ..., x_n$ and clauses
$C_1, ..., C_m$.

*Tautological clauses*: A clause that contains both $x_j$ and $not x_j$ is true
under every assignment. Removing it does not change whether $Phi$ is
satisfiable, so we first remove all such clauses in $O(m)$ time. From now on, no
clause contains a variable and its negation. If no clause is left, $Phi$ is
satisfiable, and we output the #True instance
$S = {lit("0")^n}$ (it is matched by $w = lit("0")^n$). If $n = 0$, $Phi$ has
no literals and so no clauses, which is this case.

*Main case*: For every clause $C_i$, build the string $s_i$ of length $n$ by
setting, for every position $1 <= j <= n$:

#boxed[
  $
  s_i [j] = cases(
    lit("1") & "if the literal" x_j "is in" C_i,
    lit("0") & "if the literal" not x_j "is in" C_i,
    lit("2") & "if" C_i "does not mention" x_j,
  )
  $
]

Since $C_i$ never contains both $x_j$ and $not x_j$, each $s_i[j]$ is
well-defined. Output $S = {s_1, ..., s_m}$. (If two clauses give the same
string, $S$ keeps one copy. Two clauses with the same string have the same
literals, so this changes nothing.)

*Example*: Applying this reduction to
$(not x_2 or not x_3) and (x_2 or x_3) and (not x_2 or x_3) and (x_2 or not x_3)$
over the variables $x_1, ..., x_4$ gives
$S = {#lits("2002", "2112", "2012", "2102")}$, the second example in the
problem. The formula rules out all four values of $(x_2, x_3)$, so it is not
satisfiable, and the answer for $S$ is #False.

= Correctness

Every string $w in {lit("0"), lit("1")}^n$ is the same thing as a truth
assignment to $x_1, ..., x_n$: set $x_j =$ #True if $w[j] = lit("1")$ and
$x_j =$ #False if $w[j] = lit("0")$. This is a one-to-one correspondence.

*Lemma*: For every clause $C_i$, the string $w$ matches $s_i$ if and only
if the corresponding assignment makes $C_i$ true.

*Proof*: Look at one position $j$. Since $w[j] in {lit("0"), lit("1")}$, a
position with $s_i [j] = lit("2")$ never agrees with $w$. Otherwise:

- If $s_i [j] = lit("1")$, then $x_j$ is in $C_i$, and $s_i [j] = w[j]$ exactly
  when $w[j] = lit("1")$, that is, when $x_j =$ #True, that is, when the
  literal $x_j$ is true.
- If $s_i [j] = lit("0")$, then $not x_j$ is in $C_i$, and $s_i [j] = w[j]$
  exactly when $w[j] = lit("0")$, that is, when $x_j =$ #False, that is, when
  the literal $not x_j$ is true.

So $s_i$ and $w$ agree at position $j$ if and only if $C_i$ contains a literal
on $x_j$ that is true. Then $w$ matches $s_i$ (agrees somewhere) if and only if
some literal of $C_i$ is true, that is, if and only if $C_i$ is true.
#h(1fr) $square$

#boxed[$Phi$ is satisfiable #h(1em) $<==>$ #h(1em) some $w in {lit("0"), lit("1")}^n$ matches every string of $S$]

$==>$ Suppose $Phi$ has a satisfying assignment. Let $w$ be its string:
$w[j] = lit("1")$ if $x_j =$ #True and $w[j] = lit("0")$ if $x_j =$ #False.
Every clause $C_i$ is true, so by the lemma $w$ matches every $s_i$. So the
#SM instance $S$ is #True.

$<==$ Suppose some $w in {lit("0"), lit("1")}^n$ matches every $s_i$. Let
$x_j =$ #True if $w[j] = lit("1")$ and $x_j =$ #False if $w[j] = lit("0")$. By
the lemma, every clause $C_i$ is true under this assignment, so $Phi$ is
satisfiable.

Removing the tautological clauses does not change satisfiability, and when no
clause is left, $Phi$ is satisfiable and the output $S = {lit("0")^n}$ is a
#True instance. So the reduction is correct in every case.

= Running time

Removing tautological clauses takes $O(m)$ time, since each clause has at most
$3$ literals. Each string $s_i$ has length $n$: we fill it with $lit("2")$ and
then write the at most $3$ literals of $C_i$, in $O(n)$ time. So the reduction
builds $m$ strings of length $n$ in #boxed[$O(m n)$ time]
which is polynomial in the size of $Phi$.

So #ThreeSat $<=_P$ #SM. Since #ThreeSat is NP-hard, #SM is NP-hard.
#h(1fr) $square$

#disclosures(sources: [None], llm: llm-note)
