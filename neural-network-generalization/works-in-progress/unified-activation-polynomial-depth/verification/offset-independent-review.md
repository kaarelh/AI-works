# Independent review of the original-prior activation-offset extension

Date: 23 October 2026 (publication timezone). This is an AI-agent mathematical review, not Lean verification or human peer review. It checks the actual `source/offset-extension.tex` and the referenced capacity, Gaussian projection, exponential-tilt, RKHS-certificate, and endpoint reconstruction arguments in the earlier unified-activation manuscript. It does not infer the new result merely from the old theorem, whose zero-at-zero hypothesis excludes it.

**Finding:** no substantive gap found in the bounded-offset extension as written. In particular, the proof supplies a real replacement for the mean-field normalization that would otherwise fail at a nonzero activation offset. The existence and polynomial bounds for the auxiliary finite networks follow from the explicit local constructions and a fixed finite number of compositions; they are not assumed as an endpoint premise.

## Actual learner and quantifiers

The learner retains the original independent Gaussian coordinates and only the global absolute-margin restriction before noiseless label conditioning. There is no neuron-averaging restriction in this appendix and no replacement by a centered-activation learner with independent biases. Its theorem chooses one polynomial after fixed depth, Lipschitz bound, and offset bound, before activation, teacher resources, distribution, accuracy and learner width/scale. The final good sample event is common to every `N≥C` and every `0<t≤1` for the fixed target and activation. These are the claimed all-`γ≥1` conventions, including actual finite mean field.

The coefficient bound `B` remains a separate variable from teacher width `C`. It enters the target-cylinder rate through the teacher-state recurrence and squared centers. The endpoint compressor itself depends only on dimension, energy budget, fixed depth and the activation bounds. Substitution of the polynomial target-rate budget consequently retains polynomial dependence on both `C` and `B`; no step silently replaces `B` by `C` or hides it in a fixed constant.

## Capacity and small-scale steps

The centered RMS-state construction is an exact deterministic network identity. Its added constant column has norm bounded by `b` times the original matrix Frobenius norm, and its added readout coordinate has squared magnitude at most `b²N‖v‖²`. The total transformed squared norms are bounded by `(1+b²)κ_N+H`. The earlier zero-at-zero product-norm capacity lemma therefore gives the printed capacity bound for the entire heterogeneous bounded-offset auxiliary class. This changes only a counting representation, not the learner's prior.

The target cylinder's balanced cloning is valid for arbitrary activations. The displayed `B_0` is conservative: tripling the readout gives readout energy at most `18C²B²`, while the stated budget leaves additional room. The teacher-state, perturbation, and Gaussian interval estimates justify the positive target mass at every width and scale.

The spectral RMS bound also holds with offsets. Explicitly, if `R≥2`, then

```text
M_s ≤ R^(s−1)(b+λ√(2K)) + b(R^(s−1)−1)/(R−1)
    ≤ (2b+λ√(2K)) R^(s−1).
```

This geometric sum justifies the printed `U` bound; an invariant induction using only `M_s≤b+RM_(s−1)` and `M_(s−1)≤UR^(s−2)` would not suffice by itself. The stated cutoff leaves more than enough room for output discrepancy below `1/8`, and the doubled readout has the claimed energy budget. No new activation assumption is used in the Gaussian spectral tail.

## Mean-field tail reduction

The outer-product error constant `14` follows from the two support-count estimates and

```text
2λ B_c [b+λ√M δ_i] + λ² B_c².
```

After averaging, the three terms are the ones printed in the proof. The bounds `T≥b/λ` and `T≥2B_c` convert their constants to `4+8+2=14`. The next-diagonal bound follows directly by squaring `b+λB_c+λ√M δ_i`.

The exact normalization

```text
s_i = √(1+δ_i²),   v_i = u_i/s_i,
ψ_i(q) = φ(s_i q)/s_i,   c_i = w_i s_i²/N
```

preserves the Lipschitz bound and gives offset at most `b`, RKHS norm at most one, and total mass at most `A+1`. It has no singularity at `δ_i=0`. When the incoming Gram matrix is zero, the bulk keeps the constant feature `φ(0)` and the tail vanishes, as it should.

For the finite atom approximation, every atom has magnitude at most `R_A=b+λ√M`. The stated `n_A` suffices for the Hoeffding union bound over all `m²` entries. The RKHS certificate and covariance tolerance `η²` give activation error at most `5λη/4`; the resulting outer-product error, after multiplying by total mass `A+1`, is less than `ξ/8` with the printed `η`. Filling unused sampling probability with the **identically zero activation** is necessary and correctly stated. A dummy using the original activation at zero would incorrectly add constant covariance.

The weights `a_l Σ_y β_j(y)h_l(y)` implement the atom's linear input exactly. They use the preceding physical feature evaluations and fixed real coefficients, rather than consulting the input-dependent covariance at prediction time.

## Bounded bulk and finite physical reconstruction

Mollification changes the activation uniformly by at most `λτ`, and its derivative bounds do not require a zero offset. On the cutoff support, `T≥b/λ` absorbs the offset in `O(λT)`. The additional derivative contributions are precisely of the stated orders `b/T` and `b log(2m)/T²`. Thus the earlier sparse exponential-tilt certificate and normalized Gaussian covariance-stability calculation apply to the actual bounded smooth features.

A smoothing scale can be chosen explicitly as the minimum of one and a sufficiently small universal multiple of `α/[λ²(T+1)]`. Its reciprocal, the tilt budget, sparse certificate size, and covariance-stability constant all have polynomial bounds in the stated resources. The tail error with the chosen `T` is at most `14α/256<α/16`. The subsequent displayed error allocations sum to less than `α`.

The tilted Gaussian coordinate bound is polynomial because the cutoff radius involves the square root of the tilt log-density bound, rather than its exponential. The original intersection argument gives a positive-probability finite sample satisfying both covariance accuracy and coordinate bounds. Evaluating the actual activation on those rows and assigning the cutoff values to fixed covariance coefficients realizes the bounded bulk. The hidden physical-value recurrence gains the additive `b` stated in the appendix. Together with the atom construction, this gives genuine finite feedforward networks with bounded coefficients and values.

Backward selection of reciprocal-polynomial covariance tolerances and forward reconstruction compose these bounds only `H` times. At fixed depth this proves polynomial width and energy bounds; no lower spectral-eigenvalue assumption is needed. The readout RKHS certificate has `ℓ¹` norm at most `16K`, so final covariance error `1/(128K)` adds at most `1/8` to the readout's initial `1/8` approximation. Doubling the readout therefore restores the original strict sign margin. Padding with auxiliary zero activations is valid in the counting class.

## Uniformity in scale and final learning step

The conditional preactivation law is centered Gaussian with covariance `t²Q_(s−1)` even when hidden activations have nonzero means: `Q_(s−1)` is their raw Gram matrix. This distinction is correctly stated. Scaling by `t≤1` does not enlarge a diagonal or approximation budget. In a weighted-feature representation it multiplies bulk incoming coefficients by `t` and atom coefficients by `t²`; it leaves all offset bounds unchanged. Readout tails decrease. The same endpoint polynomials and exceptional probability therefore apply uniformly down to arbitrarily small positive `t`.

The three-way small-scale, large-width endpoint, and bounded-width energy decomposition compares each bad raw mass to the actual positive target mass. Its thresholds and combined energy have polynomial upper envelopes in `d,C,B,log(1/ε)` for fixed `L,λ,b`. One finite bounded-offset sign-function class contains every retained realization. The final finite-class union bound then yields a common sample event over every eligible width and scale, with full posterior mixtures and the stated confidence corollary.

This review supports the conventional proof extension. It does not extend the previous Lean verification label to this appendix, establish a joint polynomial-depth result for the unrestricted prior, or verify arbitrary noisy/real-valued regression variants.

## Reviewed source

The source hash is recorded below. A subsequent insertion of the displayed geometric-sum explanation, without changing a bound or theorem, is a clarification of the argument checked here.

```text
19beb939ea0d68d1f036c6ffeb88e8aa0d3de5bd8b98d7bec7b9e652472d4ef9  source/offset-extension.tex
```
