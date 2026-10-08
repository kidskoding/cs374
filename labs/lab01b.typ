#import "../setup.typ": *

#let body = [
== Lab 1B: Regular Expressions

A _regular expression_ is compact notation for a language (that is, a set of strings). Formally, a regular language is one of the following:

- The symbol $emptyset$ (representing the empty set)
- Any string (representing the set containing only that string)
- $bold(R) + bold(S)$ for some regular expressions $R$ and $S$ (representing alternation / union)
- $bold(R) dot bold(S)$ or $bold(R S)$ for some regular expressions $R$ and $S$ (representing concatenation)
- $bold(R)^*$ for some regular expression $R$ (representing Kleene closure / unbounded repetition)

In the absence of parentheses, Kleene closure has highest precedence, followed by concatenation. For example:

$ lit("O") + lit("RE")^* = lit("O") + lit("R")(lit("E")^*) &= {lits("O", "R", "RE", "REE", "REEE", "REEEE", "REEEEE", "REEEEEE", "REEEEEEE"), dots} \
  lit("O") + (lit("RE"))^* &= {eps, lits("O", "RE", "RERE", "RERERE", "RERERERE", "RERERERERE", "RERERERERERE"), dots} \
  (lit("O") + lit("R")) lit("E")^* &= {lits("O", "R", "OE", "RE", "OEE", "REE", "OEEE", "REEE", "OEEEE", "REEEE", "OEEEEE"), dots} \
  (lit("O") + lit("RE"))^* &= {eps, lits("O", "OO", "RE", "OOO", "ORE", "REO", "OOOO", "OORE", "OREO", "REOO", "RERE"), dots} $

#hrule

Give regular expressions for each of the following languages over the binary alphabet ${lits("0", "1")}$. (For extra practice, find multiple regular expressions for each language.)

#set enum(start: 0)
+ All strings.

  #boxed[$(lit("0") + lit("1"))^*$]

+ All strings containing the substring $lit("000")$.

  #boxed[$(lit("(0 + 1)* 000 (0 + 1)*"))$]

+ All strings _not_ containing the substring $lit("000")$.

  #boxed[$(lit("1") + lit("01") + lit("001"))^* (eps + lit("0") + lit("00"))$]

+ All strings in which every run of $lit("0")$s has length at least 3.

+ All strings in which the _last_ $lit("1")$ appears before the _first_ substring $lit("000")$.

+ All strings containing at least three $lit("0")$s.

+ Every string except $lit("000")$. _[Hint: Don't try to be clever.]_
]

#show: notes
#body
