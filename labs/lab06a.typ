#import "../setup.typ": *

#let todo = text(fill: warn-color, weight: "bold")[TODO]

#let skeleton = [
  - *What the function returns* (in English, with its parameters): #todo
  - *Base case(s)*: #todo
  - *Divide* (which recursive calls, on which smaller inputs): #todo
  - *Combine* (how the recursive results give the answer): #todo
  - *Running time* (recurrence, then its solution): #todo
]

#let body = [
== Lab 6A: Binary Search (September 30)

Here are several problems that are easy to solve in $O(n)$ time, essentially by brute
force. Your task is to design algorithms for these problems that are significantly
faster.

#hrule

1. Suppose we are given an array $A[1 .. n]$ of $n$ distinct integers, which could be
  positive, negative, or zero, sorted in increasing order so that
  $A[1] < A[2] < dots.c < A[n]$.

  #enum(
    numbering: "(a)",
    [Describe a fast algorithm that either computes an index $i$ such that $A[i] = i$
      or correctly reports that no such index exists.

      #skeleton],
    [Suppose we know in advance that $A[1] > 0$. Describe an even faster algorithm
      that either computes an index $i$ such that $A[i] = i$ or correctly reports that
      no such index exists. _[Hint: This is *really* easy.]_

      #skeleton],
  )

2. Suppose we are given an array $A[1 .. n]$ such that $A[1] >= A[2]$ and
  $A[n - 1] <= A[n]$. We say that an element $A[x]$ is a *_local minimum_* if both
  $A[x - 1] >= A[x]$ and $A[x] <= A[x + 1]$. For example, there are exactly six local
  minima in the following array:

  #figure(
    table(
      columns: (1.7em,) * 16,
      rows: (1.5em, 1em),
      align: center + horizon,
      stroke: (x, y) => if y == 0 { 0.5pt } else { none },
      ..(9, 7, 7, 2, 1, 3, 7, 5, 4, 7, 3, 3, 4, 8, 6, 9)
        .enumerate()
        .map(((i, v)) => if i + 1 in (2, 5, 9, 11, 12, 15) {
          text(fill: warn-color, weight: "bold")[#v]
        } else [#v]),
      ..range(1, 17).map(i => if i in (2, 5, 9, 11, 12, 15) {
        text(fill: warn-color, size: 0.8em)[▲]
      } else []),
    ),
  )

  Describe and analyze a fast algorithm that returns the index of one local minimum.
  For example, given the array above, your algorithm could return the integer 9,
  because $A[9]$ is a local minimum. _[Hint: With the given boundary conditions, any
  array *must* contain at least one local minimum. Why?]_

  #skeleton

3. Suppose you are given two sorted arrays $A[1 .. n]$ and $B[1 .. n]$ containing
  distinct integers. Describe a fast algorithm to find the median (meaning the $n$th
  smallest element) of the union $A union B$. For example, given the input

  $ A[1 .. 8] = [0, 1, 6, 9, 12, 13, 18, 20] quad quad
    B[1 .. 8] = [2, 4, 5, 8, 17, 19, 21, 23] $

  your algorithm should return the integer 9. _[Hint: What can you learn by comparing
  one element of $A$ with one element of $B$?]_

  #skeleton

#hrule
*Harder problem to think about later:*

4. Now suppose you are given two sorted arrays $A[1 .. m]$ and $B[1 .. n]$ and an
  integer $k$. Describe a fast algorithm to find the $k$th smallest element in the
  union $A union B$. For example, given the input

  $ A[1 .. 8] = [0, 1, 6, 9, 12, 13, 18, 20] quad quad
    B[1 .. 5] = [2, 5, 7, 17, 19] quad quad k = 6 $

  your algorithm should return the integer 7.

  #skeleton
]

#show: notes
#body
