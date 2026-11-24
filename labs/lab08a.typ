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

#let Ramp = math.italic("Ramp")
#let Length = math.italic("Length")

#let body = [
== Lab 8A: Sledding Ramps (October 14)

Amy Nancato, the director of the Parisa Tabriz School of Computing and Data Science, has
commissioned a series of snow ramps on the south slope of the Orchard Downs sledding
hill#footnote[The north slope is faster, but too short for an interesting contest.] and
challenged Banjin Nerfherder, head of the Department of Electrical and Computer Engineering,
to a sledding contest. Banjin and Amy will both sled down the hill, each trying to maximize their
air time. The winner gets to expand their unit into Siebel Center, the ECE Building, _and_ Campus
Instructional Facility; the loser has to move their entire unit under the Boneyard bridge behind
Everitt Lab.

Whenever Amy or Banjin reaches a ramp _while on the ground_, they can either use that ramp
to jump through the air, possibly flying over one or more ramps, or sled past that ramp and stay
on the ground. Obviously, if someone flies over a ramp, they cannot use that ramp to extend
their jump.

#hrule

+ Suppose you are given a pair of arrays as input:

  - A sorted array $Ramp[1 .. n]$, where $Ramp[i]$ is the distance from the top of the hill to
    the #box[$i$th] ramp.
  - An unsorted array $Length[1 .. n]$, where $Length[i]$ is the distance that any sledder
    who takes the #box[$i$th] ramp will travel through the air.

  Describe and analyze an algorithm to determine the maximum _total_ distance that Banjin
  or Amy can travel through the air.

  #skeleton

+ Uh-oh. The university lawyers heard about Amy and Banjin's little bet and immediately
  objected. To protect the university from both lawsuits and sky-rocketing insurance rates,
  they impose an upper bound on the number of jumps that either sledder can take.

  Describe and analyze an algorithm to determine the maximum total distance that Amy
  or Banjin can spend in the air _with at most $k$ jumps_, given the arrays $Ramp[1 .. n]$ and
  $Length[1 .. n]$ and the integer $k$ as input.

  #skeleton

#hrule
*Harder problem to think about later:*

3. When the lawyers realized that imposing their restriction didn't immediately shut down
  the contest, they added yet another restriction: No ramp may be used more than once!
  Disgusted by all the legal interference, Banjin and Amy give up on their bet and decide to
  cooperate to put on a good show for the spectators.

  Describe and analyze an algorithm to determine the maximum total distance that Amy
  and Banjin can spend in the air, each taking at most $k$ jumps (so at most $2k$ jumps total),
  and with each ramp used at most once. As in problem 2, your input consists of the arrays
  $Ramp[1 .. n]$ and $Length[1 .. n]$ and the integer $k$.

  #skeleton
]

#show: notes
#body
