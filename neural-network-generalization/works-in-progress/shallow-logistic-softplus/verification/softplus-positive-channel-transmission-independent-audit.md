# Independent audit: matched softplus positive-channel transmission

25 October 2026. Auditor: occupation-audit agent, independently of the author.
Conventional mathematical checking; not Lean verification.

Source SHA256: f50b2356920b968c4cdffc305f88c3055e0bb68221a8344e8f4ab8272aebd974

Verdict: PASS for the stated shallow-target cold/fixed-gamma>1 result. The
critical both-label posterior and arbitrary deep teachers remain outside it.

## Wire and energy

The indexing has L-1 hidden layers: the shallow teacher followed by m-1
new hidden layers, m=L-1. The prescribed r_j obey r_j<=1/(2q k_j), and
the gains telescope exactly. The additive softplus error at the two
endpoints is nonnegative and bounded by exp(-A+1/2); the displayed A
makes its accumulated error smaller than r_(m-1)/4. Monotonicity then
extends the two endpoint estimates to arbitrarily large |g|, so no hidden
upper bound on the teacher output is needed for the margin proof.

The constant channel is an actual zero-row neuron with value log2.
Its injection, transport, and final subtraction are charged. The first
injection estimate uses disjoint support of the teacher readout and
reserved constants. For odd N the factors N/floor(N/2) are bounded by
three, covered by the stated final constant64.

The reciprocal-pair sum is valid: pairing ratios (k+1)/k and k/(k+1)
leaves excess 2/[k(k+1)]+1/k^2+1/(k+1)^2 above two, which is summable.
Thus the apparent harmonic term cancels. The squared gain deviations
also sum as claimed. When m dominates log^2(T+2), the coefficient of
L in the energy is one, with only O(log^2(LT+2)) excess.

## Stability and posterior transfer

The rank-one witness matrices give the displayed propagator bound even
with arbitrary intervening diagonal contractions. Constant-channel
components do not feed into the next signal overlap except through the
first vector norm. All intermediate normalized state norms are bounded
by polynomial resources via the telescoping gains. Variation of
constants closes once eta P0 L<=1/2 and preserves a fixed margin.

Centering the realized softplus activation yields genuinely zero-fixing
1-Lipschitz scalar maps. The final anchor offset is bounded using an
opposite-label point and the normalized cube diameter two. Thus the
existing zero-preserving product-cover theorem applies to the enlarged
surrogate class, even though a surrogate need not be a native softplus
network.

The small operator Gaussian set can be chosen centrally symmetric and
convex with probability at least one half. Its witness shift has mass
at least one half exp(-K/(2 sigma^2)) by symmetry. Isoperimetry and this
denominator give the asserted energy-distance ceiling K+1. Freezing the
realized centered scalar maps and anchor offset makes subtraction a
legitimate deterministic perturbation comparison. The other-block
products are exp(O(log^2 resources)); hence the required small operator
scale and width threshold are quasipolynomial for every fixed gamma>1.

Below that width threshold, the ordinary parameter net and clipped
Gaussian neighborhood suffice because N itself is quasipolynomial.
The exact identity F(g)-F(-g)=g supplies a same-width deep witness:
clone the first teacher rows, divide their readout coefficients by clone
counts, and use two nearly equal complementary relay groups. This
makes its energy polynomial in teacher resources and L, uniformly in N.
Making this cloning detail explicit would improve the final exposition.
At N=1 all hidden softplus values are positive, so the represented truth
table is constant, as stated.

An integer-sum parity witness follows from a piecewise-linear ramp
interpolant and F(beta s)/beta approximations to ReLU; beta polynomial
in the number of breakpoints makes the accumulated error below a fixed
margin. Its first-layer affine shifts use the existing constant input.

No local-minimum calculation or numerical inference is used. The result
is a genuine subexponential-in-depth upper for the stated shallow target
family, with the theorem's depth threshold and width eligibility intact.

## Expository follow-up

The author added the requested first-row cloning and two-group relay detail, with no other mathematical change. Updated source SHA256: c2b8b4051b311dd54a226cd2fe748c5a14e3a0242c6f878c39a6125544dd3c50. The same PASS verdict applies.
