# Finite precision for correlated Poisson subtraction and direct-integral coordinates

25 October 2026. New precision lemma for independent audit. This extends the
moment-floor method to a Poisson product and its Taylor subtraction using
the SAME realized child expressions. It is a precision/computation lemma,
not a proof of a non-Gaussian path compiler or of its expected-work bounds.

## 1. A multilinear coefficient bound from independent noise floors

Fix the Boolean cube with its uniform law. Let X_1,...,X_K be independent
child oracle calls conditional on the input, and write

    X_i(x)=U_i(x)+sigma_i epsilon_i,
    a_i^2=E_x E X_i(x)^2>0,
    sigma_i^2>=gamma a_i^2,       0<gamma<=1.

The epsilon_i are independent Rademacher signs, independent of all bases U_i
and of x. This is the explicit additive noise used by the moment-floor
construction. Different occurrences of the same X_i in the polynomial below
refer to the same realized child, including its noise sign. The bases need
not be independent for the argument, although actual oracle calls can be.

Let

    P(X_1,...,X_K)=sum_(S subset [K]) c_S product_(i in S) X_i

be any real multilinear polynomial. Define A_P^2=E_x E P(X)^2. Then

    A_P^2 >= (1/2) [gamma/(1+2K)]^K
                    max_S |c_S product_(i in S)a_i|^2.             (1)

For K=0 use the obvious constant identity. If a_i=0, replace that child by
zero before applying the statement. If A_P=0, (1) shows that every surviving
polynomial coefficient is zero.

Proof. Set V_i=U_i/a_i and s_i=sigma_i/a_i>=sqrt(gamma). Since the noise is
independent and centered, E_x E V_i^2<=1. Markov and a union bound give an
event of probability at least1/2 on which all |V_i|<=sqrt(2K). Put
c'_S=c_S product_(i in S)a_i. For fixed base values v on this event, expand
P(a_i(v_i+s_i epsilon_i)) in the orthonormal Walsh basis:

    d_T=(product_(i in T)s_i)
                   sum_(S superset T)c'_S product_(j in S\T)v_j.

Triangular translation inversion gives

    c'_S=sum_(T superset S) d_T (product_(i in T)s_i^-1)
                                      product_(j in T\S)(-v_j).

Cauchy--Schwarz therefore bounds |c'_S|^2 by

    (sum_T d_T^2) gamma^(-|S|)
                         (1+2K/gamma)^(K-|S|)
       <= (sum_T d_T^2) [(1+2K)/gamma]^K.

The first factor is the conditional second moment over the independent noise
signs. Integrating on the good base event proves (1).

Thus every coefficient of P in RMS-normalized children, divided by the
parent's cube RMS, has magnitude at most

    sqrt(2) [(1+2K)/gamma]^(K/2).                    (2)

This controls cancellation, not just products of moment profiles. No
frequency, coefficient, or nonzero-RMS lower bound is used.

## 2. A compact normalized representation of the Poisson residual

Apply (1) to

    Z=product_(i=1)^K(1+i r_i X_i),
    R=Im Z-sum_i r_i X_i.

The residual is exactly the sum of odd-degree monomials of degree at least
three. This equality requires the same X_i in the product and subtraction;
independent redraws would not work. Taking r_i=omega/lambda gives the usual
Poisson sine residual, and arbitrary common Fourier prefactors may multiply R.

Expanding all 2^K monomials is unnecessary. Use four real components indexed
by the degree classes

    0, 1, E={even degrees>=2}, O={odd degrees>=3}.

The components are respectively the constant real term, the degree-one
imaginary coefficient, the higher even real terms, and the higher odd
imaginary coefficient. Multiplying two factors on disjoint child-index sets
is a fixed bilinear operation on these four components. The degree classes
are closed under addition; an odd-times-odd product contributes the usual
minus sign from i^2. There are at most16 component products at a node.
The final O component is R. The E component is Re Z-1.

For each block of factors and each degree class C, let M_C be the maximum
absolute monomial coefficient in that component AFTER substituting
X_i=a_i Y_i. Set M_C=0 if its monomial set is empty or all coefficients vanish.
The two child blocks have disjoint variable sets, so every parent monomial
has a unique pair of child monomials and a unique pair of degree classes.
Consequently

    M_C=max_(A+B=C) M_A(left) M_B(right).             (3)

Normalize a nonzero component by M_C. Every coefficient of the resulting
four-dimensional bilinear multiplication rule is then

    +/- M_A(left)M_B(right)/M_C,

whose magnitude is at most one. A zero component is the zero vector
coordinate. A leaf has constant component1 and normalized linear component
sign(r_i)Y_i; all its coefficients are bounded.

The final component scaling, including any external Fourier multiplier c,
has magnitude |c| M_C/A_(cP_C). By (1), this is bounded by (2). Thus the
entire conditional residual oracle, normalized by its RMS, has an O(K)-node
formula over a fixed four-dimensional real vector algebra, with all internal
coefficients bounded by one and its output coefficient bounded by (2).

More generally, any fixed linear combination of the four degree components
has the same conclusion: the component monomial sets are disjoint, so its
largest coefficient is max_C |c_C|M_C. Constant terms should first be combined
exactly. Subtracting a fixed number of lower Taylor degrees can likewise use
a fixed-dimensional degree-category algebra. This covers the ordinary sine,
cosine, cosine-minus-one, and cubic sine residual factories. It does not
assert a normalized small-formula representation for an arbitrary
multilinear polynomial supplied without such a representation.

For real products product_i(1+r_i X_i), use the same degree classes with
the real multiplication signs instead of the i-parity signs. A product
minus its constant or linear Taylor terms is handled by selecting the
corresponding classes. Thus the same construction covers real Poisson
exponential products and their fixed-order subtractions.

In particular the fourth-order cosine remainder

    Re Z-1+sum_(i<j) r_i r_j X_i X_j

is the even-degree-at-least-four component. Use the fixed six categories
{0,1,2,3,even>=4,odd>=5}; the same unique-monomial-decomposition argument
proves (3) and bounds every normalized bilinear coefficient. The real
exponential remainder product_i(1-r_i X_i)-1+sum_i r_i X_i uses the
three categories {0,1,degree>=2}. These are the correlated fourth-/second-
order subtractions needed in the rank-one norm-update calculation.

## 3. Why repeated local expansion does not cause a hidden blowup

The four-component construction is a formula over a fixed-dimensional real
algebra, not an ordinary real scalar formula at each intermediate step.
Scalar child formulas enter only once as vector leaves. Component operations
are bilinear or affine in each separate argument. The whole recursively
constructed expression can remain in this representation until its random
seed is fixed. Its expected work is charged in constant-dimensional vector
operations, O(K) per product, as for ordinary complex arithmetic.

One global balancing argument converts the resulting finite tree to an
ordinary real arithmetic formula with only polynomial growth. If the state
dimension is bounded by a fixed D, a one-hole context is affine in the D
real coordinates of its subtree Q:

    F=F[Q=0]+sum_(l=1)^D [F[Q=e_l]-F[Q=0]] Q_l.

Choose Q of one-third to two-thirds of the tree size, up to constants.
Recursively balance Q and the D+1 substituted contexts. Only a fixed number
of copies is introduced at each recursion level, giving polynomial size and
logarithmic depth. Now expand each fixed-dimensional bilinear operation into
its constant-size scalar arithmetic implementation. The resulting growth is
again polynomial because the depth is logarithmic.

The tree may mix ordinary scalar nodes, complex/Re/Im nodes, and the
four-component nodes, by padding their state spaces to one fixed D.
All coefficients introduced by balancing are0,1,-1 and existing bounded
coefficients. Correlated syntactic copies of a child retain their fixed seed;
the global scalar expansion charges their full size. This is a direct
extension of the already audited complex real-affine balancing lemma.

Therefore a polynomial-size good seed with K at most polynomial at each
active node, and inverse-polynomial gamma, yields polynomial size and
polynomial logarithmic coefficient magnitude. There is no repeated
per-layer K^2 scalar expansion in this reasoning.

## 4. Mixtures, conditional RMS scales, and tiny Fourier factors

Let theta include every input-independent random parameter at an outer
factory node, such as its frequency, Poisson count, row coordinate, and
phase. Apply Sections1--3 conditionally on theta, with the corresponding
child oracle types. Let A_theta be the conditional cube RMS and let
A^2=E_theta A_theta^2 be the mixed oracle RMS. Zero-RMS conditional types
return zero. The final mixture-to-oracle factor satisfies

    E_theta (A_theta/A)^2=1.

An expected-call-count union bound therefore excludes exceptionally large
selected ratios with positive probability, simultaneously with the usual
classification and formula-size good-seed events. Section1 bounds the
conditional normalized coefficients even when the external Fourier factor
is singular near frequency zero: that factor appears in both numerator and
conditional RMS and cancels. No new conditional output noise of size
comparable to the uncancelled complex product is required. Such noise would
indeed spoil a singular residual moment estimate.

If a stored output needs its own pointwise floor, inject the original tiny
noise using its FULL MIXED cube RMS. This increases its second moment only
by the chosen factor1+delta and does not undo the proved residual cancellation.
Inputs to later primitives then have the independent-noise form required
by Section1.

The expected-work and second-moment bounds of the surrounding factory must
still be proved separately. This note only converts already-controlled
correlated multilinear factories to finite-bit formulas.

## 5. Standard-Borel direct integrals need no finite coordinate support

The prior countable-coordinate moment-floor argument extends to a real
Hilbert space L2(I,nu), with I a standard-Borel space, nu sigma-finite,
and measurable oracle
families. Replace coordinate sums by integrals. The invariant is

    integral_I E X_i(x)^2 dnu(i)<=V,
    ess sup_i E size(X_i)<=T.

The cube-averaged moments barV_i are measurable and integrable. For an
actually requested coordinate i, generate a fresh Rademacher noise sign and
use sqrt(delta barV_i) as its amplitude. There is no need to construct an
uncountable jointly independent noise field: each realized finite expression
requests finitely many coordinates, and its fresh signs are sampled then.

Hilbert--Schmidt operators have square-integrable kernels. Their row and
entry samplers use densities proportional to squared kernels; the sampled
readout uses density |v(i)|^2/||v||^2. All trace moment calculations and all
conditional RMS inequalities are the same Tonelli computations with
integrals. Rows or coordinates failing on null sets can be assigned zero
versions. The joint-noise lower bound and expected-call-count union bounds
are uniform in the selected oracle type, so they remain valid for continuous
coordinate laws. The finite cube ensures that an oracle of zero averaged
RMS vanishes at every relevant input almost surely.

After a seed is fixed, only finitely many selected real constants remain.
The normalized coefficient bounds above, followed by global vector-algebra
balancing, give polynomial-bit rounding exactly as in the countable case.
This establishes the precision extension for direct-integral feature
coordinates, conditional on the stated measurable oracle construction and
its uniform expected-work/trace-moment bounds.

## Scope

The polynomial lemma is multilinear in DISTINCT underlying child samples.
The same child may reappear in different monomials, as required for Taylor
subtraction. It does not cover a child squared inside a monomial unless
that square has been implemented with independent child draws or a separate
higher-degree noise/interpolation argument. Standard Poisson products and
their same-child low-degree subtractions are multilinear and are covered.

