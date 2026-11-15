# Standalone review of the dense Gaussian manuscript

Reviewed `paper.tex`, `gaussian-section.tex`, `finite-section.tex`, `discussion.tex`, and `smooth-section.tex` on 14 November 2026, including the revised introduction and nearby-input obstruction. This report concerns the current manuscript's dense Gaussian learners. It replaces the earlier review of a broader draft.

This is an independent mathematical reading, not a Lean verification or external peer review. The manuscript was not edited by this reviewer.

## Assessment

I found no mathematical blocker in the current positive theorems or the nearby-input obstruction. The stated improvements follow from proved statistical and variational inequalities; they do not assume the desired learning conclusion. Every reviewed learner uses independent Gaussian coordinates in a fixed dense architecture. The cloned teacher is only a comparison point or comparison measure in the proof.

The main improvement is substantive but limited: for total depth `L = H+1 ≥ 3`, retaining the learner's energy penalty gives a fixed-teacher remainder of order `O-tilde(n^(-1/H))`. One hidden layer has a square-root rate. The finite-scale theorem also obtains these fixed-teacher exponents, with additional complexity terms. None of the results establishes a teacher-parameter-count rate with favorable dependence on arbitrary depth.

## Strong-prior theorem

- The teacher cloning construction preserves the function at every integer width `N ≥ m`, including widths that are not multiples of `m`. The bounds on clone-group ratios and readout weights give the displayed energy cap.
- The variable-threshold clipping inequality has the stated `1/(2 sqrt(n))` remainder. The positive mixture representation of `tanh(su)/s` has total mass one. Together they justify the recursive convex-hull capacity argument.
- The capacity estimate uses the `H` energy terms after the first layer, hence the exponent `H/2`. Omitting the first-layer energy in this estimate is legitimate because the halfspace comparison controls that layer without a norm restriction.
- The halfspace argument permits arbitrary real inputs. Its use in the strong-prior section does not require the bounded-input assumption needed later for the finite-scale perturbation calculation.
- The dyadic event is common to all learner widths. The optimizer satisfies `q ≤ 1/λ`, and `λ^(H/2) = a_n` gives `a_n q^(H/2) ≤ λq` for `H ≥ 2`. Thus the improved exponent comes from a valid absorption step.
- The two teacher concentration formulas are now clearly alternative choices with their own events. Their minimum is not silently asserted at the original confidence level.
- Coercivity gives compact nonempty minimizer sets at each finite width. The Laplace argument proves the stated posterior-risk upper limits pointwise in width; it does not prove a width-uniform rate of convergence in the prior scale.
- For one hidden layer, `sup_q [a sqrt(q) − λq] = a²/(4λ)` gives the stated bound and the optional teacher-energy tuning.
- The growing-teacher corollary correctly chooses a deterministic population-risk minimizer in a compact class. It does not require simultaneous concentration over all teachers. Its Bernstein powers yield the stated thresholds `α < 1/(4H)` for `H ≥ 2` and `α < 1/4` for the energy-tuned one-hidden-layer result.

## Finite-scale theorem

The finite-scale section controls the actual posterior with prior scale `σ² = N^(−γ)`; it does not use a limit in either prior scale or learner width.

- The all-energy deviation lemma is valid. Dyadic peeling treats energies up to `8/λ`; above that threshold, the clipped loss bound of four makes the energy penalty sufficient. The calibration `λ^p ≥ 2^(4p−2) A_n` has the correct constant.
- Under the prior, `N^γ Q_N` is chi-square with `P_N = N(d+2)+(H−1)N²` degrees of freedom. The exponential moment and entropy variational inequality give the stated lower bound on KL.
- Combining that lower bound with posterior variational optimality gives the displayed comparison for empirical risk plus `λQ_N/2`. The signs and factors of two are correct.
- The dimension ratio satisfies `P_N/N^γ ≤ d+H+1` for `γ ≥ 2`. When `H = 1`, the quadratic parameter-count term disappears, and the same argument works for every `γ ≥ 1`.
- The Gaussian comparison measure has mean at an exact teacher clone and covariance equal to `r²` times the original dense Gaussian covariance. Its KL is correctly bounded by a teacher-energy translation term plus `P_N log(1/r)`.
- The clone's internal operator norms and scaled readout norm are bounded independently of learner width. Independence of each layer's Gaussian perturbation from earlier activations justifies the recursive second-moment bound.
- The resulting perturbation estimate is uniformly pointwise in the input. It does not assert that a single random draw is uniformly close over all inputs; the weaker statement is exactly what the empirical-risk comparison needs.
- The radius `ρ = λ/[4(U+1)]`, `r = ρ/K_g` gives comparison empirical risk at most the teacher's empirical risk plus `λ`.
- The event is simultaneous in both all eligible widths and all claimed real exponents `γ`: its two constituent concentration events depend on neither parameter.
- At one hidden layer, the estimate `A_n sqrt(2k) ≤ λk/2 + A_n²/λ` is correct. It gives the stated finite-scale square-root rate for a fixed teacher throughout `γ ≥ 1`.

The finite one-hidden-layer default calibration is a fixed-teacher statement. It should not be confused with the separately energy-tuned growing-teacher result for the strong-prior learner. The current manuscript does not make that conflation.

## Raw-output smooth-loss appendix

- The appendix now explicitly identifies its different calibration of `λ`. Its raw-risk result is not attributed automatically to the main theorem's exact calibration.
- The bound `|z_w| ≤ sqrt(Q_N(w))` follows from bounded final-layer tanh activations. Therefore squared loss is bounded on each energy ball, although the full raw-output class is unbounded.
- Readout sign symmetry makes the absolute-supremum Rademacher convention in the cited theorem agree with the convention of the elementary capacity lemma.
- The shell inequality and all absorption constants check out. For `H ≥ 2`, the residual `q_n/λ_n` is no slower than `n^(−1/H)`.
- The weighted Laplace estimate is now explicit. Its Gaussian integral and exponential tail separation justify passing from compact minimizer sets to posterior averages of unbounded raw risk.
- Jensen's inequality then supports the ordinary raw posterior mean; the other clipping conventions follow by clipping's squared-loss contraction.
- The external smooth-loss result is used with its relevant assumptions, not with an assumed Bernstein condition on teacher excess loss. The project audit independently checked that the cited full-length SST Theorem 1 supplies a numerical constant below `10^5`.

The late-added one-hidden-layer teacher-energy tuning is also valid. Put `x = sqrt(V_n/(E_0+1))` and `λ_n = max{x,v_n}`. Then `λ_n ≤ x+v_n` and `V_n/λ_n ≤ V_n/x`, which give

`λ_n E + V_n/λ_n ≤ 2 sqrt(V_n(E_0+1)) + v_n E.`

Its contribution is `O-tilde(sqrt((E_0+1)/n) + E_0/n)`. For population-optimal teachers with width and weight magnitude at most `n^α`, the energy cap is `O(n^(4α))`, and all terms vanish for `0 ≤ α < 1/4`, with leading power `n^(2α−1/2)`.

## Nearby-input obstruction and scope

The new nearby-input proposition is valid for this same strong-prior learner. At input dimension one, the factors of learner width cancel in the product of layer Frobenius norms. Thus the optimizer's energy budget gives input Lipschitz constant at most `(Lλ)^(−L/2)`. The two-point risk identity then gives the lower bound `1 − 2r(Lλ)^(−L/2)`.

The proposition correctly passes the clipped prediction-difference bound to posterior averages by concentration on the compact minimizer set. The lower-limit formulation is appropriate; no existence of a unique limiting posterior or predictor is needed. The width-one teacher construction exactly fits both atoms with a first weight growing as `1/r`. This establishes the stated failure of a distribution-uniform width-only remainder for unbounded-weight teachers of this learner.

The revised wrapper accurately separates the strong-prior limit, the finite-scale theorem, and the different prediction conventions. The finite deep theorem requires `γ ≥ 2`; extending the improved result to `1 ≤ γ < 2` remains open here. Raw posterior means at finite scale are also left open. No computational guarantee or formal verification is claimed.

The discussion's schematic strong-prior display now explicitly uses `limsup`, and the obstruction uses `liminf`. No substantive review issue remains outstanding. Author order was left unchanged.
