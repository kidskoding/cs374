#import "../setup.typ": *

#let body = [
== Lab 1A: String Induction 

#linebreak()

The *reversal $w^R$* of a string $w$ is defined recursively as follows

$ w^R := cases(
  epsilon &"if" w = epsilon,
  x^R bullet a & "if" w = a x "for some symbol" a "and some string" x
) $

For example, $#raw("STRESSED")^R$ = `DESSERTS` and $#raw("WTF374")^R$ = `473FTW`
]

#show: notes
#body
