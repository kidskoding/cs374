#import "../setup.typ": *

#let body = [
== Lab 1A: String Induction 

The following problems ask you to prove some "obvious" claims about recursively-defined string functions. In each case, we want a self-contained, step-by-step induction proof that builds on formal defintions and prior results, _not_ on intuition. In particular, your proofs must refer to the formal recursive defintions of string length and string concatenation:

$ |w| := cases(
  0       & quad "if" w = epsilon,
  1 + |x| & quad "if" w = a x "for some symbol" a "and some string" x
) $

$ w bullet z := cases(
  z & quad "if" w = epsilon,
  a dot (x bullet z) & quad "if" w = a x "for some symbol" a "and some string" x
) $

You may freely use the following results:

#lemma[$w bullet epsilon = w$ for all strings $w$.]
#lemma[$|w bullet z| = |w| + |z|$ for all strings $w$ and $z$.]
#lemma[$(w bullet y) bullet z = w bullet (y bullet z)$ for all strings $w, y$, and $z$.]

#line(length: 100%)
The *reversal $w^R$* of a string $w$ is defined recursively as follows

$ w^R := cases(
  epsilon      & quad "if" w = epsilon,
  x^R bullet a & quad "if" w = a x "for some symbol" a "and some string" x
) $

For example, $lit("STRESSED")^R = lit("DESSERTS")$ and $lit("WTF374")^R = lit("473FTW")$.

#linebreak()

+ Prove that $|w|= |w^R|$ for every string $w$.

  Assume that $|x| = |x^R|$ for every string $x$ shorter than $w$.

  *Case 1:* Suppose that $w = epsilon$.
  
  Then,
  $ |w^R| &= |epsilon^R| \
             &= |epsilon| && "by definition of reversal" \
             &= |w| $

  *Case 2:* $w = a x$ for some symbol $a$ and string $x$.

  Then,
  $ |w^R| &= |x^R bullet a| && quad "by definition of reversal" \ 
          &= |x^R| + |a| && quad "by definition of" bold("Lemma 2") \
          &= |x^R| + 1 && quad "by definition of length (since" |a| = |a epsilon| = 1 + |epsilon| = 1) \
          &= |x| + 1 && quad "by defintion of inductive hypothesis" \
          &= |a x|   && quad "by defintion of length" \
          &= |w|
  $

+ Prove that $(w bullet z)^R = z^R bullet w^R$ for all strings $w$ and $z$.

  Assume that $(x bullet z)^R = z^R bullet x^R$ for every string $x$ shorter than $w$ (and every string $z$)

  *Case 1*: Suppose that $w = epsilon$.

  Then,
  $ (w concat z)^R &= (epsilon concat z)^R \
                   &= z^R && quad "by definition of concatenation" \
                   &= z^R concat epsilon && quad "by definition of" bold("Lemma 1") \
                   &= z^R concat epsilon^R && quad "by definition of reversal" \
                   &= z^R concat w^R
  $ 

  *Case 2*: Suppose that $w = a x$ for some symbol $a$ and string $x$.

  Then,
  $ (w concat z)^R &= (a x concat z)^R \
                   &= (a dot (x concat z))^R && quad "by definition of concatenation" \
                   &= (x concat z)^R concat a && quad "by definition of reversal" \
                   &= (z^R concat x^R) concat a && quad "by definition of inductive hypothesis" \
                   &= z^R concat (x^R concat a) && quad "by definition of" bold("Lemma 3") \
                   &= z^R concat w^R && quad "by definition of reversal"
  $

+ Prove that $(w^R)^R = w$ for every string $w$

  Assume that $(x^R)^R = x$ for every string $x$ shorter than $w$.

  *Case 1*: Suppose that $w = epsilon$.

  Then,
  $ (w^R)^R &= (epsilon^R)^R \
            &= epsilon^R && quad "by definition of reversal" \
            &= epsilon && quad "by definition of reversal" \
            &= w
  $

  *Case 2*: Suppose that $w = a x$ for some symbol $a$ and string $x$

  Then,
  $ (w^R)^R &= ((a x)^R)^R \
            &= (x^R concat a)^R && quad "by definition of reversal" \
            &= a^R concat (x^R)^R && quad "by Problem 2" \
            &= a^R concat x && quad "by the inductive hypothesis" \
            &= a concat x && quad "by definition of reversal" (a = a epsilon; a^R = epsilon^R concat a = epsilon concat a = a) \
            &= a x && quad "by definition of concatenation" \
            &= w
  $
]

#show: notes
#body
