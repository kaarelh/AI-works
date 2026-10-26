# Formula register rank gives polynomial learning at fixed rank

26 October 2026. Scratch proof for integration into the structural
Boolean paper; not a polynomial upper for arbitrary Boolean formulas.

## Statement

Let a fan-in-at-most-two Boolean formula have s nodes, d input variables,
and Horton--Strahler rank r. Leaves have rank0, unary gates retain their
child's rank, and a binary gate with child ranks a,b has rank max(a,b)
when a!=b and rank a+1 when a=b. Repeated occurrences of the same input
variable are allowed; internal gates have the usual tree/formula structure.

There is a threshold circuit for the formula with depth O(r+1), width
polynomial in d+s+2, and normalized margin1 integer gate coefficients
of magnitude polynomial in d+s+2. The polynomial degrees are universal
and do not depend on r.

Thus, writing

`E_r=log(d+L+3)+(r+1)log(d+s+L+3)`,

the original globally margined/exact-fit Gaussian tanh posterior has
sample bound exp(O(E_r)), with the standard epsilon/delta factors,
at every realizable width and every0<t<=1, when L>=C E_r.
This is polynomial in d+s+L for every fixed r. A complete balanced
binary formula has r=Theta(log s), so the theorem alone remains
quasipolynomial for unrestricted formulas.

## Explicit constant-depth unary-map composition

Use0/1 bits for the circuit construction. A unary Boolean map u_i is
specified by a_i=u_i(0), b_i=u_i(1). Define

`R_i=1[a_i=b_i]` (reset) and `F_i=1[a_i=1,b_i=0]` (flip).

If R_i=1 the map outputs the constant a_i; otherwise it is identity
or negation according to F_i. For input y0 and a sequence of m maps,
the composite output is y0 XOR the parity of all flips if there is
no reset. Otherwise, if j is the last reset, the output is a_j XOR
the parity of flips at indices greater than j.

For each0<=j<=m and1<=k<=m-j, compute in one threshold stage

`U_(j,k)=1[sum_(i>j) F_i >= k]`.

The alternating sum

`P_j=sum_(k=1)^(m-j) (-1)^(k+1) U_(j,k)`

is exactly the parity of that suffix. One additional threshold gate
testing P_j>=1/2 produces its0/1 bit. The empty suffix is the
constant0. There are O(m²) gates; count tests can be written with
integer score `2 sum F_i-(2k-1)`, whose nonzero margin is at least1.
The parity test likewise has score `2 sum (-1)^(k+1)U_(j,k)-1`.
Their integer coefficient magnitudes and row norms are polynomial in m.

For1<=j<=m, define `J_j=R_j AND (AND_(i>j) NOT R_i)`, and put
`J_0=AND_(i>=1) NOT R_i`, `a_0=y0`. These mutually exclusive and
exhaustive last-reset indicators are unbounded-fanin threshold gates.
The final answer is

`OR_(j=0)^m [J_j AND (a_j XOR P_j)]`.

Each XOR uses a fixed-size constant-depth Boolean circuit. All suffix
parities, all last-reset indicators, and all final choices are evaluated
in parallel. This is a constant-depth threshold implementation of the
four-element unary transformation monoid, with O((m+1)²) gates and
polynomially bounded integer coefficients. A constant rail supplies
biases. Converting0/1 wires to signed Boolean wires changes only fixed
factors and polynomial bias magnitudes, preserving unit margins.

## Formula decomposition and complete resource accounting

At a binary node of rank k there is at most one child of rank k;
otherwise its rank would be k+1. Form maximal paths using parent--child
edges of equal rank. Every off-path child of a rank-k path has rank
strictly below k. Its lowest node is either a leaf/unary chain at rank0,
or a binary gate whose two children have smaller rank. Therefore its
bottom bit can be computed from lower-rank outputs in constant depth.

Once that bottom bit is available, walk upward along the path. Each
gate is a unary Boolean map on the carried bit, with the off-path
child value as its other argument. For any fixed binary gate truth
table, a_i and b_i are unary functions of that off-path bit, so they
are computable in constant depth. Unary gates on the path contribute
fixed maps. The preceding unary-monoid circuit evaluates the whole
path in constant threshold depth.

Process ranks0,1,...,r. All paths of the same rank are independent
given lower-rank outputs and are processed in parallel. Keep raw
input bits, a constant rail, and previously computed path-root values
on ordinary copy wires. There are at most s path roots and paths;
the sum of squared path lengths is at most s². Thus at each rank
all gates, copies, and connections are polynomial in d+s+2, and
all coefficient row norms are polynomial in that quantity. The
total depth is O(r+1), with polynomial degrees independent of r.

Applying the audited heterogeneous Gaussian-prefix theorem yields
the stated posterior exponent and padding condition. Small learner
widths use the same full-class VC completion as in that theorem;
the formula compiler itself need not fit in every such width.

## Scope

This exploits the single-bit nature of a formula path. It does not
assert a constant-depth compiler for arbitrary constant-width
branching programs: larger state monoids can be nonsolvable and
include the A5 word problem. It also does not identify a narrow
real-valued tanh state with one Boolean bit.

Unlike a change of Gaussian mass allocation, the construction genuinely
reduces the target threshold depth before invoking the posterior theorem.
For general formulas r can be logarithmic in s, leaving the familiar
quasipolynomial upper and the open polynomial-formula question.

## All-depth completion at fixed rank

Let `R=d+s+L+3`. The published uniform target theorem, including its
short-padding part (Theorem1.1 of the uniform-target-classes companion),
applies to a threshold circuit with q stages, width C0, row/coordinate
bound B, and every learner L>=q+1. Its sufficient sample resource is

`(d+C0+B+q+L+4)^{C(q+1)^2}`.

Our compiler has q<=C(r+1) and C0,B<=R^C with universal constants.
Therefore every L>=C(r+1) has sufficient samples

`(C/epsilon)[R^{C(r+1)^2}(1+log(1/epsilon))^C+log(1/delta)]`.

This retains every actual realizable width and every0<t<=1, exactly
as in the imported theorem. Thus each fixed-rank family has polynomial
samples at every learner depth large enough to hold its constant-depth
threshold implementation; no logarithmic learner-depth padding is
needed for this fixed-rank polynomial assertion.

## Rank at most one: every learner depth L>=2

A rank-zero formula is a literal or constant after composing its unary
gates, so its Fourier variation is1. For rank one, all rank-one nodes
lie on one path. Its bottom value y0 is a Boolean function of at most
two literals, hence the signed bit `f0=2y0-1` has Fourier variation at
most2 by Parseval and Cauchy--Schwarz on at most four coefficients.
Every off-path input is rank zero, hence a literal or constant.

Use the reset/flip notation above, with m maps above the bottom gate.
Each R_i and1-R_i is a literal indicator or a constant0/1, with Fourier
variation at most1. Each signed reset value `g_i=2a_i-1` and flip sign
`eta_i=(-1)^{F_i}` is a signed literal or constant, with variation1.
Put `J_0=product_i(1-R_i)` and
`J_j=R_j product_(i>j)(1-R_i)`. The exact signed output is

`f=J_0 f0 product_i eta_i + sum_(j=1)^m J_j g_j product_(i>j) eta_i`.

The Fourier l1 norm is submultiplicative on the Boolean cube, including
when literals or subexpressions share variables. Thus

`A(f)<=2+m<=s+2`.

The published uniform Fourier-target theorem (Theorem1.2 of the same
companion) consequently gives polynomial samples in d+s+L at **every
L>=2**, all actual realizable widths, and all0<t<=1. This does not
require the formula's threshold compilation to fit into that learner
width or hidden depth. It imports the Fourier seed and the theorem's
finite-width completion. Rank two does not inherit a polynomial
Fourier bound from this argument: parity of disjoint two-input ANDs
already has exponentially growing Fourier variation.
