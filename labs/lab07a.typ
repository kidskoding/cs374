#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  - *What the function returns* (in English, with its parameters): #todo
  - *Base case(s)*: #todo
  - *Divide* (which recursive calls, on which smaller inputs): #todo
  - *Combine* (how the recursive results give the answer): #todo
  - *Running time* (recurrence, then its solution): #todo
]

// A sequence in angle brackets; positions in `hl` (1-indexed) are the handout's
// red underlined example answer.
#let seq-inline(xs, hl: ()) = [⟨] + xs.enumerate().map(((i, v)) => if i + 1 in hl {
  underline(text(fill: warn-color, weight: "bold")[#v])
} else [#v]).join([, ]) + [⟩]
#let seq(xs, hl: ()) = align(center, seq-inline(xs, hl: hl))

#let pi-digits = (3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6, 2, 7)

#let body = [
== Lab 7A: Recursive Backtracking (October 7)

A *_subsequence_* of a sequence (for example, an array, linked list, or string),
obtained by removing zero or more elements and keeping the rest in the same order. A
subsequence is called a *_substring_* or an *_interval_* if its elements are contiguous
in the original sequence. For example:

- #lit[SUBSEQUENCE], #lit[UBSEQU], and the empty string $epsilon$ are all substrings
  (and therefore subsequences) of the string #lit[SUBSEQUENCE];
- #lit[SBSQNC], #lit[SQUEE], and #lit[EEE] are all subsequences of #lit[SUBSEQUENCE]
  but not substrings;
- #lit[QUEUE], #lit[EQUUS], and #lit[DIMAGGIO] are not subsequences (and therefore not
  substrings) of #lit[SUBSEQUENCE].

#hrule

*Questions to ask while designing a recursive backtracking algorithm:*

- *How you would systematically solve the problem yourself?* By hand, not by writing
  code. What sequence of decisions do you need to make? For each decision, what are
  your options?
- *After you've made some decisions, what portion(s) of the input data is(are)
  left?* Equivalently, what is the "shape" of your recursive subproblems? Prefixes,
  suffixes, intervals, or something else? Do you need to remember anything else about
  your past decisions to make consistent future decisions?
- *How can you specify the "shape" of a subproblem with only a small number of
  parameters?* (typically indices into an input array)?
- *What precise recursive problem are you trying to solve?* Equivalently, after
  making some decisions, what question are you asking about the remaining input data?
  #text(fill: warn-color)[*_This is the most important step._*]
- Finally, develop a recursive algorithm that answers the precise question you
  specified in the previous step. Your recursive algorithm should explore all possible
  options for exactly one decision, and each decision should be evaluated by
  recursively solving any resulting subproblem(s).

#hrule

Describe *_recursive backtracking_* algorithms for the following longest-subsequence
problems. _Don't worry about running times._

1. Given an array $A[1 .. n]$ of integers, compute the length of a longest
  *_decreasing_* subsequence. A sequence $B[1 .. ell]$ is _decreasing_ if
  $B[i] < B[i - 1]$ for every index $i >= 2$.

  For example, given the array

  #seq(pi-digits, hl: (6, 8, 11, 20, 22))

  your algorithm should return the integer 5, because $chevron.l 9, 6, 5, 4, 2 chevron.r$
  is a longest decreasing subsequence (one of many).

  #skeleton

2. Given an array $A[1 .. n]$ of integers, compute the length of a longest
  *_alternating_* subsequence. A sequence $B[1 .. ell]$ is _alternating_ if
  $B[i] < B[i - 1]$ for every even index $i >= 2$, and $B[i] > B[i - 1]$ for every odd
  index $i >= 3$.

  For example, given the array

  #seq(pi-digits, hl: (1, 2, 3, 4, 5, 7, 8, 9, 12, 14, 15, 16, 19, 20, 21, 22, 23))

  your algorithm should return the integer 17, because
  $chevron.l 3, 1, 4, 1, 5, 2, 6, 5, 8, 7, 9, 3, 8, 4, 6, 2, 7 chevron.r$ is a longest
  alternating subsequence (one of many).

  #skeleton

3. Given an array $A[1 .. n]$ of integers, compute the length of a longest *_convex_*
  subsequence of $A$. A sequence $B[1 .. ell]$ is _convex_ if
  $B[i] - B[i - 1] > B[i - 1] - B[i - 2]$ for every index $i >= 3$.

  For example, given the array

  #seq(pi-digits, hl: (1, 2, 4, 7, 11, 13))

  your algorithm should return the integer 6, because
  $chevron.l 3, 1, 1, 2, 5, 9 chevron.r$ is a longest convex subsequence (one of many).

  #skeleton

#hrule
*Harder problems to think about later:*

4. Given an array $A[1 .. n]$, compute the length of a longest *_palindrome_*
  subsequence of $A$. Recall that a sequence $B[1 .. ell]$ is a _palindrome_ if
  $B[i] = B[ell - i + 1]$ for every index $i$.

  For example, given the array

  #seq(pi-digits, hl: (3, 6, 9, 10, 11, 13, 20))

  your algorithm should return the integer 7, because
  $chevron.l 4, 9, 5, 3, 5, 9, 4 chevron.r$ is a longest palindrome subsequence (one of
  many).

  #skeleton

5. Given an array $A[1 .. n]$, compute the length of a *_shortest_* palindrome
  *_supersequence_* of $A$. Sequence $B$ is a _supersequence_ of another sequence $C$
  if and only if $C$ is a subsequence of $B$.

  For example, given the array

  #seq((3, 1, 4, 1, 5, 9, 2, 6, 5, 3))

  your algorithm should return the integer 15, because
  #seq-inline((3, 5, 6, 2, 9, 5, 1, 4, 1, 5, 9, 2, 6, 5, 3), hl: (1, 7, 8, 9, 10, 11, 12, 13, 14, 15))
  is a shortest palindrome supersequence.

  #skeleton
]

#show: notes
#body
