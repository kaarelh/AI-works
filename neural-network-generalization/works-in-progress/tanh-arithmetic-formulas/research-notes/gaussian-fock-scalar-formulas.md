# A scalar-formula construction for equal-diagonal Gaussian feature paths

25 October 2026. New proposed lemma, written for independent audit. This is
an exact random arithmetic-formula result in a real-constant model. A PNC1
corollary additionally needs the coefficient-size hypothesis in Section 5.
Neither general Gaussian control paths nor arbitrary critical controlled
paths are claimed to satisfy the hypotheses.

The main point is that degree-dependent averaging repairs the divergent
Hermite second-moment series without paying that averaging cost at every
layer. Rare creation of higher-degree coordinates charges the cost to the
physical Gaussian variance q.

## 1. Normalized Gaussian/Fock feature map

Let q>0 and let

    F(q) = E tanh(sqrt(q) Z)^2,       Z~N(0,1).

Expand tanh(sqrt(q) Z) in orthonormal probabilists' Hermite polynomials:

    tanh(sqrt(q) Z) = sum_(k odd>=1) a_k(q) H_k(Z),
    b_k(q) = a_k(q)/sqrt(F(q)).

Then sum b_k(q)^2=1. On a real separable Hilbert space H define

    G_q(u) = direct-sum_(k odd>=1) b_k(q) u^(tensor k)

for ||u||=1, using full ordered tensor powers. Its norm is one, and

    <G_q(u),G_q(v)> = sum_k b_k(q)^2 <u,v>^k
       = E[tanh(sqrt(q) Z_u)tanh(sqrt(q) Z_v)]/F(q),  (1)

where the two standard Gaussian variables have correlation <u,v>. Thus G_q
is a legitimate normalized feature representation of the Gaussian tanh
kernel. Full tensor powers contain redundant symmetric coordinates but have
the same norm and kernel; no combinatorial multiplicity is omitted.

The construction is orthogonally equivariant: an isometry U of H acts on the
new feature space by direct-sum U^(tensor k). This observation can absorb
consistent Gaussian coordinate choices. It does not make an arbitrary
dense change of an already constructed scalar-coordinate basis free.

## 2. A weighted Hermite tail bound

For all q>0,

    sum_(k odd>=3) k^2 b_k(q)^2 <= 6 q^2.             (2)

Indeed Gaussian Sobolev/Parseval gives

    sum_k k(k-1) a_k(q)^2
       = q^2 E[tanh''(sqrt(q) Z)^2].

For k>=3, k^2<=3 k(k-1)/2. Since

    tanh''(z)=-2 tanh(z) sech(z)^2,
    tanh''(z)^2<=4 tanh(z)^2,

the left side of (2), before normalization by F(q), is at most
6q^2 F(q). This proves (2). The Sobolev identity is justified by bounded
derivatives and Gaussian integrability; it also follows by L2 convergence
of the Hermite derivative expansion. In particular the estimate holds
without an asymptotic Taylor expansion or a bounded-degree truncation.

## 3. Degree-dependent averaging and rare coordinate creation

Suppose u(x) has norm exactly one on the finite input set X. For every
coordinate i let X_i(x) be an unbiased random scalar arithmetic formula,
with

    sum_i E X_i(x)^2 <= V,       V>=1,
    max_i E size(X_i) <= T,      T>=1.                (3)

The trace bound is pointwise in x, and the scalar child formulas are sampled
independently when called. Countably many coordinates are allowed.

For an odd degree k>=3, put m_k=ceil(k V). Replace each coordinate child by
the average of m_k independent copies. If W_i(x) denotes its second moment,

    sum_i W_i(x)
       = 1 + [sum_i E X_i(x)^2-1]/m_k
       <= 1+(V-1)/m_k.

Therefore

    [sum_i W_i(x)]^k <= exp(k(V-1)/m_k) <= e.        (4)

Choose p_k=min{1,q/k^2}. For a fixed ordered coordinate word
I=(i_1,...,i_k), return zero with probability 1-p_k; otherwise return

    b_k(q)/p_k times product_(r=1)^k Xbar_(i_r),     (5)

using independent averaged children, including when two indices coincide.
This is unbiased for the corresponding coordinate of G_q(u). Its expected
size is at most

    1+C p_k k m_k T <= 1+C q V T,                  (6)

uniformly in k and I. Although a very high-degree branch is expensive when
it occurs, its probability compensates that size.

Summing second moments over all ordered coordinate words and using (4),

    sum_I E Y_(k,I)^2 <= e b_k(q)^2/p_k.             (7)

All sums involve nonnegative terms, so countable coordinate spaces are
covered by monotone convergence. At degree one simply output b_1(q) X_i.
This copies an existing formula and changes its final scalar edge coefficient.
It does not create a fresh recursive child call. Scalar edge weights are
combined algebraically along copy chains. Converting the final weighted tree
to an ordinary arithmetic formula adds only a constant number of operations
per edge, rather than one operation for every skipped trajectory layer.

For 0<q<=q0 with any fixed q0<1, p_k=q/k^2 for every k>=3. Equations (2)
and (7) yield the pointwise total trace bound

    V_new <= b_1(q)^2 V + (e/q) sum_(k>=3)k^2 b_k(q)^2
           <= V+6e q.                              (8)

The common expected coordinate size is at most T(1+C q V). Thus a single
free Gaussian feature layer has the same favorable small-budget form as
the near-copy theorem, even though its feature space has infinitely many
tensor coordinates.

For q>=q0, (7) gives V_new<=V+C(1+q). The maximum coordinate size is at most
C(1+q)V T. Average C(1+q) independent copies coordinatewise to reset the
trace bound to at most 3/2 when V<=2. Its total size multiplier is polynomial
in 1+q, whose logarithm is O(q) for q>=q0.

## 4. Composition with coordinate copies and Hilbert--Schmidt controls

Between these Gaussian feature steps, permit linear maps J_j+K_j, where J_j
is a signed coordinate injection and K_j is Hilbert--Schmidt. Assume every
true state entering a Gaussian feature map has norm exactly one, and all
other true intermediate means have norm at most one. Let

    S=sum_j ||K_j||_HS,       Q=sum_j q_j.

The near-copy row-sampling argument in
`near-copy-scalar-formula-compiler.md` works on countable coordinate spaces:
each row is square summable, and the sum of its squared row norms is exactly
||K_j||_HS^2. Hence a small linear perturbation raises trace moment by
O(||K_j||_HS), at common scalar-coordinate size multiplier
1+O(||K_j||_HS).

Use the coordinatewise two-copy resets whenever the deterministic trace
upper bound exceeds 7/4. Since the true mean norm is at most one, a reset
returns it to at most 3/2. Equations (8) and the near-copy bounds show that
there are at most C(S+Q)+C resets. Large steps have the same budget accounting
by Section 3 and the near-copy theorem. Starting from deterministic coordinate
formulas of size at most T0 and trace at most one, the result is

    E Y_i(x)=h_i(x),
    sum_i E Y_i(x)^2<=2,
    max_i E size(Y_i)<=C T0 exp[C(S+Q)].              (9)

The scalar final readout v in l2 is sampled with probabilities proportional
to v_i^2. It has second moment at most 2||v||^2 and the same expected size
bound. On a finite input set, averages and a fixed-seed majority
therefore give a correct global-margin classifier with real arithmetic
formulas of total size

    poly(log|X|+1,T0,||v||) exp[C(S+Q)].             (10)

The random shape is independent of x. Every realized expression is a finite
tree almost surely: the number of trajectory layers is finite, every sampled
coordinate word has finite degree, and all averaging counts are finite.
No vector child is shared across coordinates.

This is a genuine improvement over the naive unaveraged tensor recursion,
whose trace second moment contains sum b_k^2 V^k and may diverge whenever
V>1. Equation (4) eliminates that divergence before rare sampling is used.

## 5. Precision and applicability limits

The exact real-arithmetic claim (9)--(10) uses no coefficient description
bound. To infer PNC1, the constants in a polynomial-size good realization
must additionally admit polynomial-bit approximation without losing its
classification margin. This does not follow from Hilbert--Schmidt bounds
alone in a countably infinite basis.

A sufficient explicit condition, for an ambient R, is:

- the layer count, initial formula resources, and readout norm are polynomial
  in R, and S+Q=O(log R);
- each q_j and its reciprocal have logarithmic magnitude polynomial in R;
- every nonzero control or readout coordinate has logarithmic magnitude and
  inverse magnitude polynomial in R (uniformly over all coordinate indices);
- the initial coordinate formulas have polynomial-bit coefficients.

The uniform nonzero lower bound and square summability in particular force
finite support in the control matrices and readout, though its cardinality
may be exponential in a polynomial of R. No algorithm for finding that
support is claimed.

Under these conditions, every nonzero coefficient in a polynomial-size
realization has logarithmic magnitude polynomial in R. A nonzero rare
degree-k branch contains at least k child occurrences, so its k is bounded
by the realized formula size. The coefficients b_k have absolute value at
most one; 1/p_k<=max(1,k^2/q) has polynomial logarithmic magnitude. Row
sampling coefficients and branch reciprocals have the same bound by the
control assumption. Products of scalar copy coefficients over the polynomial
number of layers still have polynomial logarithmic magnitude.

The standard formula rounding argument then preserves all uniformly good
group outputs at polynomial bit precision. The resulting rational arithmetic
sign formulas and majority belong to nonuniform PNC1 by the imported theorem
used in the existing finite-bit completion.

Three obstacles prevent applying this as a general critical posterior result:

1. Equal physical query variances are needed for each common q_j and its
   fixed Hermite coefficients. With q=q(x), those coefficients are extra
   input-dependent functions, not constants in (5).
2. A general covariance control must be expressed relative to a consistent
   Fock coordinate system with small charged perturbation. Free orthogonal
   equivariance helps, but an arbitrary dense intermediate basis rotation
   is not automatically a cheap scalar-coordinate operation.
3. The coefficient lower bound above has not been deduced from Gaussian
   entropy/action control. A finite-rank or small Hilbert--Schmidt operator
   may have arbitrarily tiny entries in a chosen countable tensor basis.

Arbitrary finite-entropy non-Gaussian row tilts have additional difficulties
and are not addressed. In particular this note does not remove the cusp in
the prior canonical residual-radius construction; it uses a different,
Gaussian feature representation under stronger hypotheses.

