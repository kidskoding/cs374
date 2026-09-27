// CS 374 A, Homework 4, Problem 1. Standalone; homeworks/ is Git-ignored.
// Build: typst compile --root . homeworks/typst/hw04p1.typ homeworks/pdfs/hw04p1.pdf
#import "../../setup.typ": *

#let llm-note = [
  I used Claude (Anthropic) to draft these constructions and explain their
  structure to me. I checked every construction by hand against the examples in
  the handout and against several strings inside and outside each language, and
  typeset the submission myself.
]

#show: homework.with(
  title: "CS 374: Section A - Homework 4, Problem 1",
  date: "September 22, 2026",
)

Throughout, this homework let $M = (Sigma, Q, s, A, delta)$ be an arbitrary DFA accepting $L$,
with extended transition function $delta^*$, where $Sigma = {0, 1}$ and
$Sigma' = {0, 1, \#}$.

= Part (a)

$
"BackToFront"(L) = {y^R \# x | x, y in Sigma^* "and" x y in L}
$

is regular. Define an NFA $M' = (Sigma', Q', s', A', delta')$ with
$epsilon$-transitions as follows.

#boxed[
$
Q' &= (Q times Q times {1, 2}) union {s'} \
s' &"is an explicit state in" Q' \
A' &= {(h, h, 2) | h in Q} \
delta'(s', epsilon) &= {(h, f, 1) | h in Q "and" f in A} \
delta'(s', a) &= emptyset & #h(1.5em) "for every" a in Sigma' \
delta'((h, r, 1), epsilon) &= delta'((h, q, 2), epsilon) = emptyset \
delta'((h, r, 1), a) &= {(h, p, 1) | p in Q "and" delta(p, a) = r} & #h(1.5em) "for every" a in Sigma \
delta'((h, r, 1), \#) &= cases({(h, s, 2)} & "if" r = h, emptyset & "otherwise") \
delta'((h, q, 2), a) &= {(h, delta(q, a), 2)} & #h(1.5em) "for every" a in Sigma \
delta'((h, q, 2), \#) &= emptyset
$
]

*Why this is correct.* $M'$ runs two copies of $M$ on the two halves of $x y$, in
the order the input presents them: the suffix $y$ arrives first and reversed, so
$M'$ runs $M$ backwards on it, and the prefix $x$ arrives second and in order, so
$M'$ runs $M$ forwards on it.

- The start state $s'$ guesses, without reading any input, the state $h$ that $M$
  reaches after the prefix $x$ and an accepting state $f in A$ that $M$ reaches
  at the end of $x y$.
- A state $(h, r, 1)$ means: the guess is $h$, and $delta^*(r, u^R) = f$ for the
  portion $u$ of the input read so far. Reading $a$ moves from $r$ to any $p$
  with $delta(p, a) = r$, one step of $M$ in reverse.
- The transition on $\#$ fires only when $r = h$; the input read so far is then
  exactly $y^R$, so this test says $delta^*(h, y) = f in A$. Only one $\#$ is ever
  read, since states with third component $2$ have no $\#$ transition.
- A state $(h, q, 2)$ means $delta^*(s, v) = q$ for the portion $v$ read since
  the $\#$, and $M'$ accepts only at $(h, h, 2)$.

So $M'$ accepts $w$ exactly when $w = y^R \# x$ for strings $x, y in Sigma^*$ and
states $h in Q$, $f in A$ with $delta^*(s, x) = h$ and $delta^*(h, y) = f$. Since
$delta^*(s, x y) = delta^*(h, y) = f in A$, that happens exactly when $x y in L$,
so $L(M') = "BackToFront"(L)$ and this language is regular.

#disclosures(llm: llm-note)

#pagebreak()

= Part (b)

$
"FrontToBack"(L) = {y x^R | x, y in Sigma^* "and" x y in L}
$

is regular. There is no separator this time, so the machine must guess where $y$
ends and $x^R$ begins, and the two halves arrive in the opposite order from part
(a): the suffix $y$ comes first and in order, and the prefix $x$ comes last and
reversed. Define an NFA $M'' = (Sigma', Q'', s'', A'', delta'')$ with
$epsilon$-transitions as follows.

#boxed[
$
Q'' &= (Q times Q times {1, 2}) union {s''} \
s'' &"is an explicit state in" Q'' \
A'' &= {(h, s, 2) | h in Q} \
delta''(s'', epsilon) &= {(h, h, 1) | h in Q} \
delta''(s'', a) &= emptyset & #h(1.5em) "for every" a in Sigma' \
delta''((h, q, 1), epsilon) &= cases({(h, h, 2)} & "if" q in A, emptyset & "otherwise") \
delta''((h, q, 1), a) &= {(h, delta(q, a), 1)} & #h(1.5em) "for every" a in Sigma \
delta''((h, r, 2), epsilon) &= emptyset \
delta''((h, r, 2), a) &= {(h, p, 2) | p in Q "and" delta(p, a) = r} & #h(1.5em) "for every" a in Sigma \
delta''(z, \#) &= emptyset & #h(1.5em) "for every" z in Q''
$
]

*Why this is correct.* Again $M''$ runs two copies of $M$, one on each half of
the word $x y in L$, in the order the input presents them, but now the forwards
copy runs first and the backwards copy runs second.

- The start state $s''$ guesses the state $h$ that $M$ reaches after the prefix
  $x$ and starts the first copy of $M$ there. The guess $h$ sits in the first
  component of every state and is never changed.
- A state $(h, q, 1)$ means: the guess is $h$, and $delta^*(h, u) = q$ for the
  portion $u$ of the input read so far. This phase simulates $M$ forwards from
  the guessed state $h$ instead of from $s$.
- The $epsilon$-transition from $(h, q, 1)$ to $(h, h, 2)$ is the guess that the
  first half of the input is over. It exists only when $q in A$, so taking it
  records that the portion $y$ read so far satisfies $delta^*(h, y) in A$.
- A state $(h, r, 2)$ means: the guess is still $h$, and $delta^*(r, v^R) = h$
  for the portion $v$ read since the $epsilon$-transition; as in part (a) this
  runs $M$ in reverse. The only accepting states are the states $(h, s, 2)$, so
  acceptance demands $delta^*(s, v^R) = h$.

So $M''$ accepts $w$ if and only if $w = y v$ for strings $y, v in Sigma^*$ and a
state $h in Q$ with $delta^*(h, y) in A$ and $delta^*(s, v^R) = h$. Writing
$x = v^R$, this says $w = y x^R$ where $delta^*(s, x) = h$ and
$delta^*(s, x y) = delta^*(h, y) in A$, that is, $x y in L$. Hence
$L(M'') = "FrontToBack"(L)$, which is therefore regular. No string containing
$\#$ is accepted, as it should be, because $"FrontToBack"(L) subset.eq Sigma^*$.

#disclosures(llm: llm-note)
