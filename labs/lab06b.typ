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
== Lab 6B: Karatsuba and Binary-to-Decimal Conversion (October 1)

#strike[In lecture on Thursday, we saw]
#text(fill: warn-color, weight: "bold")[In lecture next Tuesday, we will see] a
divide-and-conquer algorithm, due to Karatsuba, that multiplies two $n$-digit integers
using $O(n^(lg 3))$ single-digit additions, subtractions, and multiplications. In this
lab, we'll look at one application of Karatsuba's algorithm: converting a number from
binary to decimal.

(The standard algorithm that computes one decimal digit of $x$ at a time, by computing
$x mod 10$ and then recursively converting $floor(x\/10)$, requires $Theta(n^2)$ time.)

#hrule

1. Consider the following recurrence, originally used by the Sanksrit prosodist
  Piṅgala in the second century #smallcaps[bce], to compute the number $2^n$:

  $ 2^n = cases(
    1 & "if" n = 0,
    (2^(n\/2))^2 & "if" n > 0 "is even",
    2 dot (2^(floor(n\/2)))^2 & "if" n "is odd",
  ) $

  We can use this algorithm to compute the decimal representation of $2^n$, by
  representing all numbers using arrays of decimal digits, and implementing squaring
  and doubling using decimal arithmetic. Suppose we use Karatsuba's algorithm for
  decimal multiplication. What is the running time of the resulting algorithm?

  #skeleton

2. We can use a similar algorithm to convert the binary representation of any integer
  into its decimal representation. Suppose we are given an integer $x$ as an array of
  $n$ bits (binary digits). Write $x = a dot 2^(n\/2) + b$, where $a$ is represented
  by the top $n\/2$ bits of $x$, and $b$ is represented by the bottom $n\/2$ bits of
  $x$. Then we can convert $x$ into decimal as follows:

  #enum(
    numbering: "(a)",
    [Recursively convert $a$ into decimal.],
    [Recursively convert $2^(n\/2)$ into decimal.],
    [Recursively convert $b$ into decimal.],
    [Compute $x = a dot 2^(n\/2) + b$ using decimal multiplication and addition.],
  )

  Now suppose we use Karatsuba's algorithm for decimal multiplication. What is the
  running time of the resulting algorithm? (For simplicity, you can assume $n$ is a
  power of 2.)

  #skeleton

3. Now suppose instead of converting $2^(n\/2)$ to decimal by recursively calling the
  algorithm from problem 2, we use the specialized algorithm for powers of 2 from
  problem 1. Now what is the running time of the resulting algorithm (assuming we use
  Karatsuba's multiplication algorithm as before)?

  #skeleton

#hrule
*Harder problem to think about about later:*

4. In fact, it is possible to multiply two $n$-digit decimal numbers in $O(n log n)$
  time. Describe an algorithm to compute the decimal representation of an arbitrary
  $n$-bit binary number in $O(n log^2 n)$ time.

  #skeleton

#align(center, block(
  width: 75%,
  inset: 6pt,
  stroke: 0.5pt,
  text(size: 0.9em)[
    #set par(justify: false)
    #set align(left)
    The cost is the effort to review the code before it can go on and the effort to
    maintain it forever after. Please don't do this.
    #align(right)[--- Guido van Rossum (January 23, 2022)]
  ],
))
]

#show: notes
#body
