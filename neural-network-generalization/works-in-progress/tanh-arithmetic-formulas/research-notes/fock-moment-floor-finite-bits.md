# Moment floors remove the tiny-coefficient gap in the Fock formula construction

25 October 2026. Precision completion, independently audited in
`fock-moment-floor-finite-bits-audit.md` (Sections 2--6 passed). This
note concerns the equal-diagonal Gaussian/Fock scalar formulas in
`gaussian-fock-scalar-formulas.md`, not arbitrary critical controlled paths.
The input set is the Boolean cube and initial coordinates are the usual
normalized signed coordinate/constant functions. The same proof permits
initial arithmetic formulas with polynomial bit complexity and size.

The key device is input-independent artificial noise. It does not change
any represented mean. It makes importance coefficients well-conditioned
after an internal, nonuniform RMS normalization, even if the original
Hilbert--Schmidt controls have arbitrarily tiny entries in a countable basis.

## 1. Resources and proposed conclusion

Use the path and notation of the Fock note. Let the number of linear and
Gaussian feature primitives be H, let S be the sum of the Hilbert--Schmidt
perturbation norms, and let Q=sum q_j. Suppose, in an ambient R>=2,

    H, d, T0, ||v|| <= poly(R),
    S+Q <= C log R.

The actual means have the unit-norm properties required by the Fock note,
and the final linear readout has signed margin at least one on the cube.
Controls and readout vectors may have countable support and arbitrary real
coordinates. No lower bound on their nonzero entries is assumed.

The conclusion is a polynomial-size, polynomial-bit rational
arithmetic sign-formula majority for the target, hence nonuniform PNC1 by
the imported arithmetic-formula theorem. This removes the control-entry
precision hypothesis in Section 5 of the Fock note. It does not remove the
equal-diagonal or compatible-coordinate-map hypotheses.

## 2. Noise injection and its cost

For any coordinate oracle X_i(x), put

    barV_i = 2^-d sum_x E X_i(x)^2.

If barV_i=0, the coordinate oracle is zero almost surely at every cube input;
replace it by the exact zero expression. Otherwise inject an independent
Rademacher sign epsilon_i and define

    X_i^+ = X_i + sqrt(delta barV_i) epsilon_i,        (1)

where delta>0 is a fixed inverse polynomial, for example a sufficiently small
constant times (H+1)^-2. Then

    E X_i^+(x)=E X_i(x),
    barV_i^+=(1+delta)barV_i,
    Var(X_i^+(x)) >= gamma barV_i^+ for every x,
    gamma=delta/(1+delta).                          (2)

Thus both variance and second moment have a pointwise floor proportional to
the average second moment. The noise coefficient is a nonuniform constant;
its possible smallness will cancel under the normalization below.

Summing (1) over the coordinates shows that a pointwise trace bound V becomes
at most (1+delta)V. Each coordinate formula receives only one extra addition
and one constant leaf. Inject noise initially and immediately after each
linear/Fock primitive, before any averaging reset; inject it once more after
a reset to restore (2). There are at most O(H) such injections along a
trajectory. Their aggregate increase is O(H delta), and their formula-work
contribution is additive O(H) before multiplication by the previously proved
exp[O(S+Q)] factor. The trace-reset proof therefore still gives

    trace moment <=2,
    common expected coordinate size <=
             C(T0+H) exp[C(S+Q+H delta)].           (3)

Thresholds in the reset argument can be slightly reduced to leave room for
the injections. A reset lowers a trace bound near two to at most 3/2; its
subsequent factor 1+delta leaves a fixed gap below 7/4. Consequently the
number of resets remains O(S+Q+H delta)+O(1), and at most a fixed number
of injections is needed per primitive.

All means and therefore all target labels remain unchanged. All auxiliary
noise signs belong to the random expression shape and are independent of x.

## 3. Internal RMS normalization

Associate to every oracle type its nonuniform scale

    a_i = sqrt(barV_i).

Rewrite every realized scalar expression so that the corresponding subtree
computes X_i/a_i, with its scale absorbed into the coefficients at its parent.
This is an algebraic change of constants; no reciprocal a_i is evaluated as
an input-dependent operation. Zero-RMS oracle types have already been removed.

We will not bound the individual a_i. Instead we bound the new coefficient
ratios. Noise injection is immediately benign: (1), divided by its new RMS,
has coefficients

    1/sqrt(1+delta),  sqrt(delta/(1+delta)),           (4)

on the normalized old child and the Rademacher leaf. These are bounded.
An exact scalar copy similarly has normalized coefficient +1 or -1, however
small its original scalar multiplier was.

## 4. Linear near-copy nodes

Consider a scalar linear primitive of the form

    Y = a X_0 + (B/p) C_J X_J,

where B is Bernoulli(p), J has probabilities p_j, and all child samples and
the two displayed branches are independent. This includes the near-copy
row sampler; zero copied terms can be omitted. Let barV_Y be its averaged
second moment. The independent-noise floors of the stored children give

    barV_Y >= gamma [a^2 barV_0
                    +(1/p) sum_j p_j C_j^2 barV_j]. (5)

Indeed the two independent summands' variances add. Conditional variance of
the sampled second summand is at least its average conditional child-noise
variance. Averaging over x preserves the bound. Cancellation of the means
cannot invalidate (5).

The normalized copied coefficient has magnitude at most gamma^-1/2. For the
normalized coefficient on a selected perturbation child, (5) gives

    E_(B,J) [1_(B=1) |(C_J/p) sqrt(barV_J/barV_Y)|^2]
       <= gamma^-1.                                (6)

This bound is uniform over all rows and oracle types, with no lower bound on
the original C_j, p_j, or underlying control entries. Thus Markov bounds the
probability of a huge normalized selected coefficient by gamma^-1/M^2.
An immediate post-primitive noise injection only decreases these inherited
coefficient magnitudes by the factor (1+delta)^-1/2.

If the perturbation is absent identically, use the exact normalized copy
rule rather than (5). A final sampled readout obeys the sharper identity
E[normalized selected coefficient squared]=1 when its own RMS is used;
the final root needs no artificial noise for this bound.

## 5. Averaging and tensor nodes

For the average Xbar of m independent copies of a floored child X, the
pointwise variance bound in (2) gives

    barV_Xbar >= gamma barV_X/m,
    E Xbar(x)^2 >= gamma barV_X/m
                  >= (gamma/m) barV_Xbar.           (7)

The second inequality uses barV_Xbar<=barV_X. Therefore each normalized
coefficient in the m-term averaging formula has magnitude at most
1/sqrt(m gamma). This covers both degree-dependent child averages and the
global trace resets, provided noise has first been injected as specified.

For a degree-k Fock coordinate, write the active branch as

    Y=(B b/p) product_(r=1)^k Xbar_r,

with independent averaged children, each using m=m_k copies. Independence
conditional on x and (7) imply

    barV_Y = (b^2/p) E_x product_r E Xbar_r(x)^2
       >= (b^2/p) (gamma/m)^k product_r barV_Xbar_r.  (8)

Thus the one normalized coefficient on an active product has magnitude at
most

    p^-1/2 (m/gamma)^(k/2).                         (9)

The possibly arbitrarily small Hermite coefficient b cancels from this
bound. If b=0 the oracle is zero. If B=0 there is no product coefficient in
the realized expression. Degree-one copies were handled in Section 3.

Within the product, binary multiplication gates can have coefficient one;
only the full product's root coefficient needs (9). Each averaged child is
normalized separately, using (7).

## 6. A polynomial-size good seed also has controlled coefficients

Use the finite-set derandomization of the Fock note, with enough independent
groups that at least a fixed majority of group averages is within 1/2 of the
true output at every cube input. This event has probability at least 9/10,
after increasing its numerical constants. By (3), the expected total
arithmetic size B0 is polynomial in R. Markov gives a polynomial bound
B=100 B0 on the realized size except with probability at most 1/100.

Let C0 be a polynomial bound on the expected number of primitive-oracle
calls in these formulas. One may take C0=O((H+1)B0): suppressing copy-only
chains can reduce arithmetic size, but every such chain has at most O(H)
trajectory primitives. Alternatively, the added noise nodes already charge
every positive-RMS stored coordinate call. Known zero oracles stop at one
zero leaf.

For every linear primitive call, (6) holds conditionally on the caller's
choice of coordinate type. A union bound through the expected call count
therefore shows that all its normalized selected coefficients have magnitude
at most a polynomial M, outside probability at most

    C0/(gamma M^2).

Choose M large enough to make this at most 1/100. No finite-support bound
on the coordinate sampling distributions is used.

Similarly, for any tensor call, conditional on its type its active branch
has probability p. Hence the probability of seeing any active tensor branch
with p<eta is at most eta C0. Choose inverse-polynomial eta so this is at
most 1/100. This controls arbitrarily tiny q_j without having to encode
their reciprocals. On the size-bounded event every active product has
k,m<=B, since its k child averages each contain m full child occurrences.
Equation (9) now bounds its normalized coefficient by

    eta^-1/2 (B/gamma)^(B/2) = exp(poly(R)).          (10)

All averaged and injected-noise coefficients are already bounded by (4)
and (7). For the canonical cube seed, normalized initial leaves are simply
signed coordinate/constant functions with bounded coefficients. More general
polynomial-bit initial arithmetic formulas have nonzero values and nonzero
RMS scales of at least exp[-poly(R)], so their normalization also has
polynomial logarithmic magnitude.

The final root RMS is at least one because its mean has global unit margin,
and is at most sqrt(2)||v|| by the trace bound. Thus root de-normalization and
group averaging introduce only polynomial coefficients. The intersection
of the correct-classification event, size event, linear-coefficient event,
and active-probability event still has positive probability.

Fix such a seed. It gives ordinary finite scalar arithmetic trees of
polynomial size, with every coefficient at most exp(poly(R)) in magnitude,
and with a fixed majority of group outputs separated from zero by at least
1/2 on every Boolean input. Internal normalization constants need not be
specified individually: only the resulting bounded coefficient ratios are
placed in these trees.

## 7. Rational rounding and scope

For a size-B arithmetic formula on bounded Boolean leaves with coefficient
magnitudes at most exp(poly(R)), all intermediate values and all first
derivatives with respect to its coefficients have magnitude exp(poly(R)).
This follows by structural induction; multiplication adds the logarithmic
bounds, and addition adds at most logarithmic overhead. Equivalently, expand
the finite tree and bound the sum of absolute monomial coefficients.

Round every coefficient to a sufficiently fine inverse-exponential-in-a-
polynomial dyadic mesh. Polynomially many bits then ensure uniform output
error below 1/4 on all Boolean inputs. The fixed good majority of group
signs is unchanged. The existing rational arithmetic-formula balancing and
PNC1 composition theorem applies.

The argument would fail without some control of the input-dependent
coordinate moment profiles: products of nearly disjoint profiles could make
the normalization coefficient in (8) arbitrarily large. Artificial noise
provides exactly that missing lower bound without changing any means.

This precision completion applies to the abstract Fock/near-copy trajectory
proved in the companion note. Establishing that a general canonical critical
path admits such a trajectory, especially with varying query diagonals and
non-Gaussian row tilts, remains separate and unresolved.

