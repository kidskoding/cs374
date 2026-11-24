#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  - *Subproblem* (in English: what $F(...)$ returns, and for which part of the input, e.g. the suffix $A[i .. n]$): #todo
  - *Answer* (which call gives the final answer): #todo
  - *Recurrence* (base case(s), and the recursive case: try every choice, then where do you continue?): #todo
  - *Memoization* (array and its size): #todo
  - *Evaluation order*: #todo
  - *Running time* (number of entries × time per entry): #todo
]

#let body = [
== Lab 7B: Longest Subsequences (October 9)

A *_subsequence_* of a sequence (for example, an array, a linked list, or a string), obtained by
removing zero or more elements and keeping the rest in the same sequence order. A subsequence
is called a *_substring_* if its elements are contiguous in the original sequence. For example:

- #lit("SUBSEQUENCE"), #lit("UBSEQU"), and the empty string $eps$ are all substrings of #lit("SUBSEQUENCE");
- #lit("SBSQNC"), #lit("UEQUE"), and #lit("EEE") are all subsequences of #lit("SUBSEQUENCE") but not substrings;
- #lit("QUEUE"), #lit("SSS"), and #lit("FOOBAR") are not subsequences of #lit("SUBSEQUENCE").

#hrule

Describe and analyze *_dynamic programming_* algorithms for the following longest-subsequence
problems. Use the recurrences you developed on Wednesday.

*The second page of this handout includes detailed steps on how you should develop
dynamic programming algorithms.*

+ Given an array $A[1 .. n]$ of integers, compute the length of a longest *_decreasing_* subsequence
  of $A$. A sequence $B[1 .. ell]$ is _decreasing_ if $B[i] < B[i - 1]$ for every index $i >= 2$.

  - Let $"LDS"(i)$ represent the length of the longest decreasing subsequence that starts with $A[i]$
  - Therefore, $"LDS"(i) = 1 + max{ "LDS"(j) : j > i "and" A[j] < A[i] }$ (if there's no such j, then $"LDS"(i) = 1$)
  - the longest decreasing subsequence can start anywhere, so the answer is the max of $"LDS"(i)$ over all from 1 to $n$, meaning every starting position
  - the answer is $max_(1 <= i <= n) "LDS"(i)$, since the subsequence can start anywhere
  - we can memoize $"LDS"$ in an array from $"LDS"[1..n]$
  - $"LDS"(i)$ only reads $"LDS"(j)$ for $j > i$, so we fill $i$ from $n$ down to $1$
  - There are $n$ entries and each takes $O(n)$ time to check every $j > i$, so the algorithm runs in $O(n^2)$ time

+ Given an array $A[1 .. n]$ of integers, compute the length of a longest *_alternating_* subsequence
  of $A$. A sequence $B[1 .. ell]$ is _alternating_ if $B[i] < B[i - 1]$ for every even index $i >= 2$, and
  $B[i] > B[i - 1]$ for every odd index $i >= 3$.

  #skeleton

+ Given an array $A[1 .. n]$ of integers, compute the length of a longest *_convex_* subsequence
  of $A$. A sequence $B[1 .. ell]$ is _convex_ if $B[i] - B[i - 1] > B[i - 1] - B[i - 2]$ for every index
  $i >= 3$.

  #skeleton

+ Given an array $A[1 .. n]$, compute the length of a longest *_palindrome_* subsequence of $A$.
  Recall that a sequence $B[1 .. ell]$ is a _palindrome_ if $B[i] = B[ell - i + 1]$ for every index $i$.

  #skeleton

+ Given an array $A[1 .. n]$, compute the length of a *_shortest_* palindrome *_supersequence_* of $A$.
  Sequence $B$ is a _supersequence_ of another sequence $C$ if and only if $C$ is a subsequence of $B$.

  #skeleton

#pagebreak()

#block(stroke: 0.5pt, inset: 1em, width: 100%)[
*Basic steps in developing a dynamic programming algorithm*

+ *Formulate the problem recursively.* This is the hard part. There are two distinct but
  equally important things to include in your formulation.

  #set enum(numbering: "(a)")
  + *Specification.* First, give a clear and precise English description of the problem you
    are claiming to solve. Not _how_ to solve the problem, but _what_ the problem actually is.
    Omitting this step in homeworks or exams may result in a 0 score!
  + *Solution.* Second, give a clear recursive formula or algorithm for the whole problem
    in terms of the answers to smaller instances of _exactly_ the same problem. It generally
    helps to think in terms of a recursive definition of your inputs and outputs. If you
    discover that you need a solution to a _similar_ problem, or a slightly _related_ problem,
    you're attacking the wrong problem; go back to step 1.
  + *Don't optimize prematurely.* It may be tempting to ignore "obviously" suboptimal
    choices, because that will yield an "obviously" faster algorithm, but it's usually a bad
    idea, for two reasons. First, the optimization may not actually improve the running
    time of the final dynamic programming algorithm. But more importantly, many
    "obvious" optimizations are actually incorrect! _First make it work; then optimize._

+ *Build solutions to your recurrence from the bottom up.* Write an algorithm that starts
  with the base cases of your recurrence and works its way up to the final solution, by
  considering intermediate subproblems in the correct order.

  #set enum(numbering: "(a)")
  + *Identify the subproblems.* What are all the different ways can your recursive
    algorithm call itself, starting with some initial input?
  + *Analyze running time.* Add up the running times of all possible subproblems, _ignoring
    the recursive calls_.
  + *Choose a memoization data structure.* For most problems, each recursive subproblem
    can be identified by a few integers, so you can use a multidimensional array. But
    some problems need a more complicated data structure.
  + *Identify dependencies.* Except for the base cases, every recursive subproblem
    depends on other subproblems---which ones? Draw a picture of your data structure,
    pick a generic element, and draw arrows from each of the other elements it depends
    on. Then formalize your picture.
  + *Find a good evaluation order.* Order the subproblems so that each subproblem
    comes _after_ the subproblems it depends on. Typically, you should consider the base
    cases first, then the subproblems that depends only on base cases, and so on. _Be
    careful!_
  + *Write down the algorithm.* You know what order to consider the subproblems, and
    you know how to solve each subproblem. So do that! If your data structure is an array,
    this usually means writing a few nested for-loops around your original recurrence.

+ *Try to improve.* What's the bottleneck in your algorithm? Can you find a faster algorithm
  by modifying the recurrence? Can you tighten the time analysis? Now is the time to think
  about removing "obviously" redundant or suboptimal choices. (But always make sure that
  your optimizations are correct!!)
]
]

#show: notes
#body
