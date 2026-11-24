#import "setup.typ": *

#let body = [
= Lecture 01 (Aug 25) - Introduction to CS 374

== Alphabets
Let Σ be an *alphabet*, that is, an arbitrary finite set of symbols or characters.
Two examples of alphabets are the following:

- $Sigma = { A , B , dots.h , Z }$
- $Sigma = { 0 , 1 }$

== Strings
A *string* or *word* is a finite sequence of symbols from an alphabet.
Formally, $w$ is a string over Σ if it is one of the following:

- the *empty string*, or
- an ordered pair $(a , x)$, where $a in Sigma$ and $x$ is a string over Σ.

=== Example
$ S T R I N G & = ( S , ( T R I N G ) )\
 & = ( S , ( T , ( R I N G ) ) )\
 & = dots.h\
 & = ( S , ( T , ( R , ( I , ( N , ( G , epsilon ) ) ) ) ) ) $

== Functions
Functions on strings are defined recursively. For example, the *length* $abs(w)$
of a string $w$ is the number of symbols in $w$:

$ abs(w) := cases(delim: "{", 0 & " if " w = epsilon, 1 + abs(x) & " if " w = a x) $

=== Example
$ abs(H A T) & = 1 + abs(A T)\
 & = 1 + ( 1 + abs(T) )\
 & = 1 + ( 1 + ( 1 + abs(epsilon) ) )\
 & = #box(stroke: black, inset: 3pt, [$ 3 $]) $

== Concatenation
The *concatenation* $w concat z$ of two strings $w$ and $z$ is defined as follows:

$ w concat z := cases(delim: "{", z & " if " w = epsilon, ( a , x concat z ) & " if " w = a x) $

=== Example
$ N O W concat H E R E & = N dot.op ( O W concat H E R E )\
 & = N dot.op ( O dot.op ( W concat H E R E ) )\
 & = N dot.op ( O dot.op ( W dot.op ( epsilon concat H E R E ) ) )\
 & = N dot.op ( O dot.op ( W dot.op H E R E ) )\
 & = #box(stroke: black, inset: 3pt, [$ N O W H E R E $]) $

== Induction
A proof by induction follows this outline:

- Consider an arbitrary object, usually of size $n$.
- Explicitly state a strong inductive hypothesis (that is, `for all k < n`).
- Explicitly handle each case for the object.
- Use the inductive hypothesis wherever it is useful.
- End by pointing out that every case has been handled.

=== Example 1
We prove that for every string $w$,

$ w concat epsilon = w $

Let $w$ be an arbitrary string, and assume that $x concat epsilon = x$ for all strings $x$ with $abs(x) < abs(w)$.

First suppose that $w = epsilon$. Then

$ w concat epsilon & = epsilon concat epsilon && quad "since " w = epsilon\
 & = epsilon && quad "by definition of concatenation " ( concat )\
 & = w && quad "since " w = epsilon $

=== Example 2
Now suppose that $w = a concat x$ for some symbol $a$ and string $x$. To prove that $w concat epsilon = w$ in all cases, we must also handle this one:

$ w concat epsilon & = ( a dot.op x ) concat epsilon && quad ( w = a x )\
 & = a dot.op ( x concat epsilon ) && quad ( "by definition of " concat )\
 & = a dot.op x && quad ( "inductive hypothesis" )\
 & = w && quad ( w = a x ) $

Therefore $w concat epsilon = w$ in all cases.

=== Example 3
Let $w$ and $z$ be arbitrary strings, and assume that $abs(x concat z) = abs(x) + abs(z)$ for every string $x$ such that $abs(x) < abs(w)$.

+ Suppose that $w = epsilon$. Then

  $ abs(w concat z) & = abs(epsilon concat z) && quad w = epsilon\
   & = abs(z) && quad "by definition of concatenation " concat\
   & = 0 + abs(z) && quad "arithmetic"\
   & = abs(epsilon) + abs(z) && quad "by definition of length of string"\
   & = abs(w) + abs(z) && quad w = epsilon $

+ Suppose that $w = a dot.op x$ for some symbol $a$ and string $x$. Then

  $ abs(w concat z) & = abs(( a dot.op x ) concat z) && quad w = a dot.op x\
   & = abs(a dot.op ( x concat z )) && quad "by definition of concatenation " concat\
   & = 1 + abs(x concat z) && quad "inductive hypothesis"\
   & = 1 + abs(x) + abs(z) && quad "by definition of length of string"\
   & = abs(w) + abs(z) && quad w = a dot.op x $

]

#show: notes
#set heading(numbering: "1.1")
#body
