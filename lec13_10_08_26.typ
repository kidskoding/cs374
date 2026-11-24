#import "setup.typ": *

// Call tree of the recursive Fibonacci algorithm, laid out with one column per leaf.
// With `memo: true`, a call whose answer is already in the array becomes a yellow
// lookup leaf instead of a subtree (calls run left child F(i-1) first).
#let fib-calls(i, depth, st, memo) = {
  let lookup = memo and i >= 2 and i in st.seen
  if i <= 1 or lookup {
    let x = st.leaf
    st.leaf += 1
    st.nodes.push((x: x, y: depth, label: i, kind: if lookup { "lookup" } else { "base" }))
    return (st, x)
  }
  let (st, x1) = fib-calls(i - 1, depth + 1, st, memo)
  let (st, x2) = fib-calls(i - 2, depth + 1, st, memo)
  let x = (x1 + x2) / 2
  st.nodes.push((x: x, y: depth, label: i, kind: "compute"))
  st.edges.push((x, depth, x1))
  st.edges.push((x, depth, x2))
  if memo { st.seen.push(i) }
  (st, x)
}

#let fib-tree(n, memo: false, unit: 26pt, row: 28pt) = {
  let (st, _) = fib-calls(n, 0, (nodes: (), edges: (), leaf: 0, seen: ()), memo)
  let depth = calc.max(..st.nodes.map(v => v.y))
  let nw = 22pt
  let nh = 14pt
  let px(x) = unit * (x + 0.5)
  let py(y) = row * y + nh / 2
  box(width: unit * st.leaf, height: row * depth + nh, {
    for (x, y, cx) in st.edges {
      place(line(start: (px(x), py(y) + nh / 2), end: (px(cx), py(y + 1) - nh / 2), stroke: 0.5pt + luma(130)))
    }
    for v in st.nodes {
      place(dx: px(v.x) - nw / 2, dy: py(v.y) - nh / 2, box(
        width: nw,
        height: nh,
        radius: 2pt,
        fill: if v.kind == "lookup" { mark-color } else if v.kind == "compute" { accent-light } else { white },
        stroke: 0.5pt + if v.kind == "compute" { accent } else { luma(110) },
        align(center + horizon, text(size: 0.75em, $F_#(v.label)$)),
      ))
    }
  })
}

// Memo array drawn as labelled cells. `target` is the entry being filled, `deps` the
// entries it reads. `order` is the fill direction arrow drawn underneath.
#let memo-array(labels, target: none, deps: (), order: none) = align(center, block(breakable: false, stack(
  spacing: 6pt,
  grid(
    columns: (2.6em,) * labels.len(),
    rows: 1.6em,
    stroke: 0.6pt,
    align: center + horizon,
    fill: (x, y) => if x == target { mark-color } else if x in deps { accent-light } else { white },
    ..labels.map(l => text(size: 0.85em, l)),
  ),
  if order != none { text(fill: accent, size: 0.9em, order) },
)))

#let body = [
= Lecture 13 (Oct 8) - Dynamic Programming: Fibonacci Numbers, Faster Text Segmentation

#keyidea[*Dynamic programming = backtracking + bottom-up evaluation:* We first find a
correct recurrence, which is the hard and creative step. We then fill a table in the
right order, which is easy and mechanical.]

== Fibonacci Numbers
For all integers $n >= 0$:

$ F_n = cases(
  0 & "if" n = 0,
  1 & "if" n = 1,
  F_(n - 1) + F_(n - 2) & "otherwise"
) $

Virahanka described these numbers around 800 CE. Fibonacci described them again in
1202, and his name stuck.

=== Recursive algorithm
The definition is already an algorithm:

```
RecFibo(n):
  if n = 0
    return 0
  else if n = 1
    return 1
  else
    return RecFibo(n − 1) + RecFibo(n − 2)
```

We count additions. Each call makes two recursive calls, of sizes $n - 1$ and $n - 2$,
and performs one addition:

$ T(n) = T(n - 1) + T(n - 2) + 1, #h(2em) T(0) = T(1) = 1 $

This is the Fibonacci recurrence again, with an extra $1$. Its solution is

$ T(n) = 2 F_(n + 1) - 1 = Theta(phi^n), #h(2em) phi = (1 + sqrt(5)) / 2 approx 1.618 $

so RecFibo runs in exponential time. Solving this recurrence is not required for this
course.

=== Why so slow?
The call tree for $F_5$ appears below. Each node shows the value it computes.

#align(center, fib-tree(5))

The same values are computed again and again, as the following table shows.

#align(center, table(
  columns: 6,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  [*Call*], [$F_4$], [$F_3$], [$F_2$], [$F_1$], [$F_0$],
  [*Times computed*], [1], [2], [3], [5], [3],
))

The number of repeated computations also grows exponentially with $n$, so almost all
of the work is wasted.

== Memoization
Michie (1968) proposed *memo functions*. A memo function stores each result. When it
is called again with the same input, it returns the stored result and does not
compute it again. Turning a function into a memo function is called *memoization*.
The word is not a typo for "memorization"; it comes from _memo_, a written note.

To memoize a recursive algorithm, we proceed as follows.
+ Keep a global data structure outside the function calls.
+ On each call, check whether the answer is already stored. If it is, use it.
+ If it is not, compute it from scratch and store it before using it.

#trap[*Use an array, not a hash table:* Array access genuinely takes $O(1)$ time.
Hash tables take $O(1)$ time only in expectation, which gives the running time (or its
analysis) one more way to go wrong. A plain array is usually all we need.]

```
MemFibo(i):                         ⟨⟨F[2..n] is global⟩⟩
  if i = 0
    return 0
  else if i = 1
    return 1
  else
    if F[i] is undefined
      F[i] ← MemFibo(i − 1) + MemFibo(i − 2)
    return F[i]
```

=== Analysis
The call tree for $F_5$ with memoization appears below. Yellow nodes return
immediately after an array lookup.

#align(center, fib-tree(5, memo: true, unit: 34pt))

#v(0.3em)
#align(center, text(size: 0.9em)[
  #box(fill: accent-light, stroke: 0.5pt + accent, width: 8pt, height: 8pt) computed
  #h(1em)
  #box(fill: white, stroke: 0.5pt, width: 8pt, height: 8pt) base case
  #h(1em)
  #box(fill: mark-color, stroke: 0.5pt, width: 8pt, height: 8pt) array lookup
])

The tree is now a path with small leaves hanging off it. The algorithm fills the
array in order, $F[2], F[3], dots, F[n]$, from left to right. Each entry is filled
once, with one addition of two values that are already known, so the total time is

$ O(n) "entries" times O(1) "each" = #box(stroke: black, inset: 3pt, [$ O(n) $]) $

== Iterative Fibonacci
The memoized algorithm simply fills the array from small indices to large ones. We
can do the same thing explicitly, with a loop and no recursion:

#memo-array(($0$, $1$, $dots$, $i - 2$, $i - 1$, $i$, $dots$, $n$), target: 5, deps: (3, 4), order: [fill order: left to right #sym.arrow.r])

```
IterFibo(n):
  F[0] ← 0
  F[1] ← 1
  for i ← 2 to n
    F[i] ← F[i − 1] + F[i − 2]
  return F[n]
```

The algorithm is a single loop, so it performs $O(n)$ additions and is easy to
analyze. It is also faster in practice, because it uses no call stack and has no
function-call overhead.

== Dynamic Programming
IterFibo is our first example of *dynamic programming*. Dynamic programming involves
more than writing a recursive algorithm and memoizing it, and it is different from
making a table and filling it in. It has two parts, and both are required:

#align(center, table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 10pt, y: 6pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Part*], [*What*], [*Purpose*]),
  [1 #sym.dot Formulate recursively], [Backtracking: a recursive solution as a recurrence], [*Correctness*. The hard, creative part.],
  [2 #sym.dot Build bottom-up], [Fill a data structure with subproblem answers, usually iteratively], [*Speed*. Mostly mechanical with practice.],
))

Bellman popularized the method in the mid-1950s while working on military scheduling
problems. In its name, "programming" means planning a schedule, as in TV programming,
and has nothing to do with writing code. The method is "dynamic" because the table
changes over time as it fills. It is now probably the most important technique for
designing correct, efficient algorithms.

#trap[*Write out every step on homework and exams:* The steps appear in Erickson's
_Algorithms_ (chapter 3), on the back of the lab handout, and in the grading rubrics.
Skipping steps costs points, and it is how incorrect algorithms arise.]

== Faster Text Segmentation
Recall the text segmentation problem: given $A[1 .. n]$ and $text("IsWord")$, decide
whether $A$ can be split into words. We now carry out the whole process for this
problem.

=== Part 1: Formulate recursively
We use backtracking to find the subproblem. A solution is a sequence of decisions
(the next word); we try every option for the next decision and recurse on what is
left.

*(a) Specify the subproblem in English:* We give a *closed definition* of what the
function returns, in the manner of good documentation for a library function.

$ text("Splittable")(i) = "True if and only if the suffix" A[i .. n] "can be split into words" $

The definition may refer to the original input $A$, but it must not say how to
compute the value or how the value is used. It describes a well-defined problem on
its own. (The same idea appeared with context-free grammars, where we described the
language of each nonterminal on its own, without reference to the other
nonterminals.)

*(b) Give a recurrence:* Let $text("IsWord")(i, j)$ be true if and only if
$A[i .. j]$ is a word. Then

$ text("Splittable")(i) = cases(
  "True" & "if" i > n,
  limits(or.big)_(j = i)^n (text("IsWord")(i, j) and text("Splittable")(j + 1)) & "otherwise"
) $

We prefer a recurrence to recursive pseudocode, because a recurrence makes part 2 much
cleaner.

*(c) Say how to answer the original problem:* The answer is
$text("Splittable")(1)$.

#keyidea[Part 1 is the difficult step, and part 2 is meaningless without it.
Everything after this point is mechanical.]

=== Part 2: Build solutions bottom-up
*(a) Identify the subproblems:* We list every way the function can be called. Each
call moves to a larger index, and the calls stop just past $n$, so the subproblems
are $text("Splittable")(i)$ for all $1 <= i <= n + 1$. (For Fibonacci, the
subproblems are $F_i$ for all $0 <= i <= n$.)

*(b) Choose a memoization data structure:* The data structure is usually an array,
sometimes a multidimensional one, and it must hold every subproblem. Here we use an
array $text("SplitTable")[1 .. n + 1]$.

#trap[*Pick descriptive names:* Name the array after the function whose values it
stores. Never call it `DP`, `OPT`, `ans` or `table`. The grader must be able to tell
what the array stores, and bad names lose points.]

*(c) Identify dependencies:* We ask which other entries must already be known
before we can fill entry $i$, and we read the answer off the recurrence. $text("Splittable")(i)$
needs $text("Splittable")(j + 1)$ for every $j >= i$, that is, every entry to its
right. A drawing of the array with arrows into entry $i$ shows these dependencies:

#memo-array(($1$, $dots$, $i$, $i + 1$, $i + 2$, $dots$, $n$, $n + 1$), target: 2, deps: (3, 4, 5, 6, 7), order: [#sym.arrow.l fill order: right to left])

*(d) Find an evaluation order:* We fill each entry only after every entry it depends
on. The dependencies point to larger indices, so we go from large indices to small
ones: $i$ from $n + 1$ down to $1$. The order may be stated as pseudocode ("for
$i <- n + 1$ down to $1$"), in words ("right to left"), or as a big arrow on the
drawing; all three are acceptable.

*(e) Write the algorithm:* We wrap the recurrence in loops that follow the evaluation
order, copying the recurrence as closely as possible:

```
FastSplittable(A[1..n]):
  for i ← n + 1 down to 1
    if i > n
      SplitTable[i] ← True
    else
      SplitTable[i] ← False
      for j ← i to n
        if IsWord(i, j) and SplitTable[j + 1]
          SplitTable[i] ← True
  return SplitTable[1]
```

- No "is it undefined?" check is needed, because the evaluation order guarantees that
  $text("SplitTable")[j + 1]$ is already filled when it is read.
- Erickson fills the base cases first and then loops over the remaining entries.
  Checking the base case inside the loop is also fine, and it copies the recurrence
  more directly.

*(f) Analyze the running time:* The running time is the number of subproblems
$times$ the time per subproblem. There are $n + 1$ subproblems, and each tries $O(n)$
values of $j$. The two nested loops give the same bound:

$ #box(stroke: black, inset: 3pt, [$ O(n^2) "calls to IsWord" $]) $

The running time has dropped from exponential to quadratic. (If $text("IsWord")$ took
time linear in the word's length, the total would be larger, perhaps $O(n^3)$.)

#keyidea[*On homework and exams the pseudocode is optional:* The subproblem
definition, recurrence, evaluation order and running time already describe the whole
algorithm. The rubric states what is required.]

== Summary: the Dynamic Programming Recipe
#align(center, table(
  columns: 2,
  inset: (x: 10pt, y: 5pt),
  stroke: 0.5pt,
  align: left,
  table.header([*Step*], [*Text segmentation*]),
  [1a. Define the subproblem in English], [$text("Splittable")(i)$: can $A[i .. n]$ be split?],
  [1b. Recurrence (with base cases)], [Big OR over the first word $A[i .. j]$],
  [1c. Which call answers the problem], [$text("Splittable")(1)$],
  [2a. All subproblems], [$1 <= i <= n + 1$],
  [2b. Data structure], [Array $text("SplitTable")[1 .. n + 1]$],
  [2c. Dependencies], [Entry $i$ needs every entry $> i$],
  [2d. Evaluation order], [$i$ from $n + 1$ down to $1$],
  [2e. Algorithm (optional)], [Loops around the recurrence],
  [2f. Running time], [$O(n^2)$ calls to IsWord],
))

The accompanying lab turns five backtracking solutions for sequence problems into
dynamic programming algorithms. The following lectures cover more backtracking
patterns that lead to good dynamic programming algorithms.
]

#show: notes
#set heading(numbering: "1.1")
#body
