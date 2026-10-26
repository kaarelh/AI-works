# Geometrically shrinking separators improve the structural exponent

26 October 2026. New scratch derivation, pending independent audit.

## Claim

For a fan-in-two Boolean circuit whose underlying undirected graph is
planar and has `v` vertices, there is a layered threshold realization
with heterogeneous prefix budget

`S = O(sqrt(v) + log(d+L+3) + log(v+3) log(v+d+L+3))`.

Consequently the original Gaussian tanh posterior, at every realizable
width and uniformly over `0<t<=1`, has sufficient samples

`(C/epsilon)[exp(C S)(1+log(1/epsilon))^C+log(1/delta)]`

when `L>=C S`. For polynomial `d,v` in `L`, the sufficient exponent is
`O(sqrt(v)+log² L)`, which is `o(L)` for `v=o(L²)`.

The same statement holds, with constants depending on the excluded
minor, for each fixed proper minor-closed graph class. The input graph
is the ordinary circuit graph; no planarity of its gate-scope completion
is assumed. This is a structural upper, not a generic compiler theorem.

## Weighted separator input

Use the standard weighted separator theorem: an n-vertex planar graph
with arbitrary nonnegative vertex weights can be partitioned as
`A disjoint B disjoint Z`, with no A--B edge, each side having at most
`beta=2/3` of the total weight, and `|Z|<=c sqrt(n)`.

Primary source: Lipton--Tarjan, *A Separator Theorem for Planar Graphs*,
SIAM J. Applied Mathematics36(2),177--189(1979), weighted theorem in the
paper, DOI https://doi.org/10.1137/0136016 ; original Stanford report
https://i.stanford.edu/pub/cstr/reports/cs/tr/77/627/CS-TR-77-627.pdf .

For the minor-free extension, Alon--Seymour--Thomas give the analogous
weighted `O_H(sqrt n)` theorem; their component-weight bound1/2 can be
grouped into two sides of weight at most2/3.
https://research.ibm.com/publications/separator-theorem-for-graphs-with-an-excluded-minor-and-its-applications

## A decomposition with decreasing bag sizes

A recursive subproblem consists of disjoint interior and boundary sets
`I,B`, with the induced graph on `I union B`; every edge from I to the
outside of that subproblem is absent. Initially I is the whole vertex
set and B is empty. Write `m=|I|`, `b=|B|`. If I is empty, use the leaf
bag B and stop.

First apply the weighted separator theorem with weight1 on I and0 on B.
Let its separator be Z0 and its two remaining sides U0,U1. Thus each
side has at most beta*m interior vertices. In each nonempty Ui, apply
the theorem again, now with weight1 on inherited boundary vertices
`B intersect Ui` and0 elsewhere. If this total weight is0, any split
with empty separator and one side suffices. Let these extra separators
be Z1,Z2 and their at most four remaining sides be P_a. Set

`Z=Z0 union Z1 union Z2`, `bag_t=B union Z`,

`I_a=I intersect P_a`, `B_a=(B intersect P_a) union Z`.

The recursive induced graph for child a is on `I_a union B_a`.
Including all Z in every child is harmless and makes the decomposition
explicit. Different P_a have no edges between them. Each child obeys

`|I_a|<=beta*m`,
`|B_a|<=beta*b+3c sqrt(m+b)`.

The old boundary outside P_a is not adjacent to I_a, except through Z,
which has already been included. The old recursive invariant therefore
persists. Parent bags contain every old boundary and all new separator
vertices. Induction proves edge coverage and running intersection:
separator vertices included in several children are joined through the
parent bag, whereas other vertices enter only their unique child.
Thus these bags form a tree decomposition with at most four children.

Put `M_l=beta^l v`. At every depth l before termination, the interior
size is at most M_l and the boundary size is at most `A sqrt(M_l)` for
a universal A. Indeed, choose A so large that

`beta*A+3c sqrt(1+A) <= A sqrt(beta)`.

This is possible since `sqrt(beta)>beta`. Whenever `M_l>=1`,

`beta*A sqrt(M_l)+3c sqrt(M_l+A sqrt(M_l))`
` <=[beta*A+3c sqrt(1+A)]sqrt(M_l)`
` <=A sqrt(M_(l+1))`.

If M_l<1, integer interior sizes are0 and the node is a leaf. The depth
is therefore O(log(v+3)), and every bag at level l has size
`O(sqrt(M_l))`, including the last constant-size level. The number of
bags is at most `4^O(log(v+3))`, hence polynomial in v. Duplicate
boundary-only leaves cause no problem and can be retained under this
polynomial bound.

Enlarge every bag by the at most two predecessors of each circuit
vertex in it. As in the audited low-treewidth construction, this
preserves running intersection and covers every gate's full scope,
while multiplying each bag size by at most3. Thus the geometric
level bound survives without assuming the scope graph is planar.

## Scheduling the dynamic program is essential

Use the audited bag-assignment dynamic program. A bag of size b has
at most `2^b` Boolean entries. Each entry is the AND of its local
constraints and, for each of at most four children, the OR of compatible
child entries. It uses a constant number of unbounded-fanin threshold
stages per decomposition level. Row norms and widths at level l have
logarithms

`O(sqrt(M_l)+log(v+d+3))`.

Process the decomposition levels from deepest to root. Carry the raw
Boolean input bits and a constant rail through all stages. Compute a
bag's local literal constraints only at that bag's scheduled level.
Leaf tables are likewise created at their own level, not at the first
physical layer. After a child level is merged into its parent, discard
the child tables. Tables are never retained longer than a constant
number of stages.

This schedule avoids a real pitfall: computing every local table at the
first stage and retaining root tables throughout would charge the
largest separator at every layer and reintroduce `sqrt(v) log v`.
The carried raw input rails cost only `O(log(d+2))` per stage.

The geometric sum is

`sum_l sqrt(M_l) <= sqrt(v)/(1-sqrt(beta))`.

Hence the sum of logarithmic stage widths and row norms is
`O(sqrt(v)+log(v+3)log(v+d+3))`. With
`q=O(log(v+3))` stages, the heterogeneous Gaussian prefix budget
adds only `q log(q+L+3)+log(d+L+3)`, proving the claim.

## Why this does not solve the generic case

Arbitrary polynomial-size circuits need not be in any fixed minor-free
class. Generic planarization can introduce quadratically many vertices;
substituting that increase into the square-root exponent returns a
linear-in-size budget. The theorem therefore strengthens a positive
structural family without proving an unrestricted sublinear-depth bound.
