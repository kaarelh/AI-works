# Compression, coding, and polynomial-budget review

Reviewed 23 October 2026 against the draft `source/paper.tex` for *Polynomial-depth Bayesian learning with general Lipschitz activations under balanced neuron-averaging stability*.

This is an independent AI-agent mathematical review of the partition-tail, posterior-truncation, finite-coding, statistical, and degree-13 arguments. It is not a Lean formalization or human peer review. The target-neighborhood lemma was checked for its role and budget growth, but its detailed Gaussian-cylinder verification is assigned a separate review.

**Finding: the reviewed arguments are correct as written.** They use the actual fixed activation throughout, permit a nonzero activation offset, preserve the stated simultaneous quantifiers, and give the claimed jointly polynomial envelope. No mathematical correction is required in these sections.

## Exact collected network and Gaussian partition tail

For fixed balanced partitions, projecting first-layer rows makes those rows identical inside each population. At later layers, multiplication by the right averaging projection followed by the left projection gives the displayed collected coefficient

`U^s_ab = (1/k_s,a) sum_{i in a, j in b} W^s_ij`.

All neurons in the same population therefore compute exactly the same activation, for every scalar activation. No positive homogeneity, boundedness, or zero-at-zero property is used. The readout coefficient is the sum of the original coefficients in a population.

The compressed coordinates for a fixed partition tuple use disjoint subsets of the original independent Gaussian coordinates. Their variances are exactly those displayed. Balance gives all three inequalities needed after weighting the energy:

- `N/(q k) <= 2` for the first layer;
- `k_previous/k_current <= 2` for internal matrices;
- `q k/N <= 2` for the readout.

Thus each weighted coordinate variance is at most `2t²/N`. At exponential-moment parameter `N/(8t²)`, each coordinate contributes at most `sqrt(2)`. The parameter count is precisely `P_q = q(d+2)+(H-1)q²`. The number of ordered partition tuples is at most `q^(HN)`; counting some inadmissible labelings only enlarges this upper bound. For `q <= N`, `P_q/N <= d+2+(H-1)q`. Summing over `q <= min(N,Q)` proves the stated partition tail. In particular, this controls every partition before the posterior chooses a witness depending on the weights.

## Posterior truncation and normalization

The denominator is the raw Gaussian mass of the support intersected with all training-margin constraints. The target cylinder is a subset for every noiseless sample and for either optional global-margin convention. Its lower bound therefore applies directly; normalizing the support prior first cancels from the conditional ratio.

The actual readout law gives `N E_v/t²` a chi-square distribution with `N` degrees of freedom. For the stated `B_r`, the exponential-moment estimate divided by the target-cylinder lower bound is at most

`exp[-(N/t²)(B_r/8-D_*)] <= (epsilon/4)^(N/t²) <= epsilon/4`.

On its complement, the support provides `q <= 1+B_r <= Q`. In the partition tail, `log Q`, `HN log Q`, and the parameter-count term are bounded by `N/t²` times the respective positive terms included in `J/8`, since `N >= 1` and `t <= 1`. Dividing again by the target-cylinder mass leaves at most `epsilon/4`. Hence discarded posterior mass is at most `epsilon/2`, uniformly for every sample, width, scale, and optional-margin choice. No independence between the witness partition and the sampled weights is assumed.

## Finite coding with a nonzero offset

Energy at most `J` and width `q <= Q` bound every coefficient by `sqrt(QJ)`: the first-layer coefficient bound is `sqrt(qJ/d)`, the internal bound is `sqrt(J)`, and the readout bound is `sqrt(J/q)`, all no larger than that common bound for `d,q >= 1`.

Padding is valid even when `phi(0)` is nonzero. Every new neuron's incoming coefficients are zero, so it outputs `phi(0)`, while all its outgoing coefficients and its readout coefficient are zero. Existing coordinates and the final output are unchanged at every layer. Rounding preserves these zeros. This explicitly handles the issue that would invalidate an assertion that zero-weight neurons necessarily have zero output.

A fixed coefficient grid in `[-R,R]` can include zero, have rounding error at most `zeta`, and use at most `3+4R/zeta` values. There are exactly `P_Q` coefficients at padded width `Q`, giving the displayed log-cardinality bound. The fixed activation is not encoded or varied in this class.

For both the padded and rounded networks, `|phi(u)| <= b+lambda |u|` and the displayed `A_g` imply hidden coordinate magnitude at most `A_g^s`. At the first layer, this uses `b+lambda(d+1)R <= A_g`; at later layers it uses `b+lambda QR <= A_g`. The coordinate error recurrence follows by splitting each matrix-product difference into a state error and a coefficient error. Since `lambda QR <= A_g` and `lambda Q <= A_g`, it gives `e_s <= s zeta A_g^s`. The linear readout adds one analogous term, bounding the output difference by `(H+1) zeta A_g^(H+1) = 1/32`.

Clipping is 1-Lipschitz, so the support's `1/16` discrepancy plus rounding's `1/32` yields `3/32`. The potentially exponential hidden magnitudes and required precision are used only through `log(1/zeta)` in the final code length.

## Statistical bound and confidence convention

If a posterior draw fits signed training margin strictly above `1/2`, its signed clipped training output equals `1/2`. Its approximating grid predictor therefore has signed clipped training output at least `13/32`. Conversely, a test failure with original signed output at most `1/4` gives grid signed clipped output at most `11/32`.

For each grid predictor, the displayed bad-input set is consequently avoided by the training sample and contains every original test failure. If its population mass exceeds `epsilon/2`, its sample-avoidance probability is at most `exp(-n epsilon/2)`. Union bounding over the fixed grid class yields the exact stated `2/epsilon` sample threshold. Adding at most `epsilon/2` discarded posterior mass proves the full posterior-average conclusion.

This common good-sample event depends on the fixed activation, target and resource budgets, but not on `N`, `t`, or the optional global-margin switch. The proof therefore establishes the advertised simultaneity without a union bound over infinitely many widths or scales. The theorem does not claim a simultaneous event for an activation selected from an uncountable class after observing the data.

The confidence corollary correctly applies the theorem at accuracy `epsilon/3`; failure of strict posterior confidence `>2/3` means correct-margin probability at most `2/3`, hence posterior error at least `1/3`. Integrating bounds the failure mass by `epsilon`. This controls arbitrary posterior mixtures and handles equality at the confidence threshold correctly.

## Joint degree-13 envelope

All variables in `S_0` are nonnegative and the positive integer/resource lower bounds make `S_0` uniformly bounded away from one. The displayed estimates are consistent:

1. `R_* = O(S_0³)`, `A_* = O(S_0³)`, and `V = O(S_0²)`. In particular `sqrt(log(2H)) = O(S_0)` suffices for the Gaussian bulk term.
2. The explicit `M`, `E`, and `rho` formulas give `log(1/rho) = O(H log S_0)`. No exponential quantity appears outside this logarithm in `D_*`.
3. The largest term in `B_0` is `H C² B²`, of total degree five; `q_0 = O(S_0²)`. Hence `D_* = O(S_0⁵)`.
4. It follows that `Q = O(S_0⁵)`, `J = O(S_0⁶)`, `R = O(S_0⁶)`, and `A_g = O(S_0¹²)`.
5. `P_Q = O(S_0¹¹)`, while `log(3+4R/zeta) = O(H log S_0) = O(S_0²)`. Their product is `O(S_0¹³)`.

One universal constant therefore dominates the explicit sample threshold by the stated `K_0/epsilon [S_0^13+log(1/delta)]`. The outer inverse-accuracy factor and the confidence logarithm remain exactly where the theorem places them. The argument could retain a sharper `O(S_0^12 log S_0)` envelope, but the simpler degree-13 statement is valid and deliberately conservative.

The scope remains essential: this theorem changes the prior by balanced population-averaging stability and assumes a bounded-weight same-activation teacher with a global sign margin. It proves neither that ordinary training produces such prior-supported networks nor that the unrestricted Gaussian prior has polynomial-depth learning.
