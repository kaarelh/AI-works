# Independent review: quadratic width from neuron-population averaging

Reviewed research derivation: `population-averaging-quadratic.md`. The corresponding standalone [publication source](../neuron-averaging/source/paper.tex) includes the reviewed main theorem and both subsequently reviewed extensions.
Reviewer: independent Codex agent `/root/quadratic_cluster_review`.
Status: the stated theorem and proof pass this mathematical audit. This is not Lean verification or human review.

## Scope

The result is for a new, substantially stronger, target-independent support restriction. A network must admit balanced populations, at most `1 + N ||v||²` in number per hidden layer, such that replacing weights by their population averages changes every clipped output by at most `1/16`. The original RMS-noise condition may also be imposed. The theorem does not follow from the original RMS-noise condition alone.

The sample dependence is quadratic in Boolean teacher width **up to logarithms**, with explicit polynomial depth dependence, at all widths above the teacher width and all mean-field-or-stronger scales. It is not literally `a(d,L,epsilon,delta,c) C²` without logarithmic C factors.

## Independently checked calculations

1. **Population quotient.** For groups of sizes `k_{s,a}`, the exact compressed coefficients are the destination-row average of each source-group sum, first-layer row averages, and sums of readout coefficients. This quotient computes the population-averaged network exactly because tanh preserves vectors constant on each group.

2. **Gaussian covariance.** For each fixed partition tuple, all compressed coefficients depend on disjoint raw Gaussian coordinates and are independent. In the energy coordinates for `kappa_q`, their variances are respectively

   `t²/(q k_{1,a})`, `t² k_{s-1,b}/(N k_{s,a})`, and `t² q k_{H,a}/N²`.

   Each is at most `2 t²/N` for balanced nonempty groups. This remains valid for q=N and for q=1.

3. **Tail and adaptive partitions.** The moment bound at `lambda=N/(8t²)` is at most `2^(P_q/2)`. There are no more than `q^(HN)` labeled partition tuples. Using `q<=N` yields `P_q/N<=d+2+(H-1)Q`. A union bound over every partition, followed by division by the raw posterior-normalizer lower bound, justifies the stated J. There is no unproved independence assumption for the selected partition. The `(H+1)log Q` term is sufficient to absorb both the partition count and the sum over q.

4. **Target cylinder.** The existing robust cylinder is invariant under averaging using its own clone groups. The teacher center is unchanged; constrained coordinates are averaged within the same intervals; the unconstrained internal bulk is annihilated by the source projection. The averaged and original networks both have signed output above one. Their clipped outputs therefore agree exactly. Increasing the teacher readout to `max(4,256c)` gives `E_v>=2C`, making the population-count condition valid without modifying the prior using the unknown target.

5. **Finite code.** Energy at most J and quotient width at most Q imply every coefficient has magnitude at most `sqrt(QJ)`. Padding with zero neurons is exact for tanh. The stated mesh zeta and layerwise induction bound uniform output error by `1/32`. Hence log cardinality has order `L(dQ+LQ²) log(poly(d,L,Q,J))`.

6. **Statistical step.** Total clipped prediction error after averaging and rounding is at most `3/32`. A training signed margin above `1/2` implies candidate clipped signed score at least `13/32`; an original test margin at most `1/4` implies candidate score at most `11/32`. The ramp between these thresholds gives zero empirical risk for each selected candidate. For any fixed bounded nonnegative loss with mean r, `P(loss=0)<=1-r`, validating the finite-class zero-empirical-loss bound even though the ramp is not binary. Adding the two posterior discarded masses gives the stated epsilon guarantee.

7. **Quantifiers.** The grid class and statistical event depend on d,L,C,c,epsilon,delta through deterministic bounds, and not on learner width, prior scale, target wiring, or the observed sample. Therefore the same high-probability sample event works simultaneously for all N>=C and 0<t<=1.

## Presentation recommendations

- State the stronger structural condition prominently, before announcing a quadratic bound.
- Do not present the condition as established for gradient-descent-trained networks. It postulates a small population-averaged approximation and is close to an explicit compressibility assumption.
- Write the ramp argument using clipped candidate scores explicitly; raw-score comparisons also follow at these thresholds, but clipping avoids an unnecessary interpretive step.
- Keep the logarithmic qualification and distinguish Boolean-circuit width from arbitrary real-weight neural-network width.

No false mathematical step or missing analytic hypothesis was found in the reviewed argument.


## Additional review: calibrated populations and a literal quadratic envelope

The following extensions were independently checked after the main audit.

### Calibrating the population count by lambda

For a fixed prior-support parameter `lambda>=1`, replace the population cap by `q<=1+E_v/lambda`. Choosing target readout `a=max(4 sqrt(lambda),256c)` gives `E_v>=2 lambda C`, preserves the original RMS robustness proof, and changes the target normalized log-mass cost to

`D*=O((d+LC)log²(2dLC)+(lambda+c²)C)`.

The readout-tail threshold B is unchanged in form. Its population cap is now `Q=ceil(1+B/lambda)`. Using this Q in the same explicit J, grid and statistical formulas proves the extension. No tail estimate assumes lambda=1.

For arbitrary lambda, retain the explicit J containing D*: the baseline simplification `J=O(d+LQ+LlogQ)` need not persist. This has no adverse effect on the claimed rate at `lambda=d+L`, because J enters the parameter-code size only logarithmically. For this choice and fixed c and accuracy, `Q=tilde O(C)` and the sample rate is `tilde O(LdC+L²C²)`, with the displayed `1/epsilon` and confidence terms restored when they vary. The support is genuinely stronger when lambda increases.

### Removing logarithmic C factors with bounded fan-in

A single-output Boolean circuit of H stages and fan-in at most two can be backward-pruned: stage s has at most `2^(H-s)` required nonconstant ancestors. Include at most one true constant wire per stage for the neural implementation. The resulting width can be taken to satisfy

`C' <= min(C, 2^(H-1)+1)`.

One can retain the original circuit when C is below the displayed bound and use the pruned construction otherwise. Consolidating duplicate constants and retaining necessary ancestors also gives the width comparison directly. Thus `log C'=O(L)` for `L=H+1`, including H=1.

Use baseline lambda=1 and set `S=2+d+L+c+log(4/epsilon)`. The explicit formulas then give, with universal constants,

- `A_gate²=O(S²)` and `log(1/rho)=O(S)`;
- `D*=O(C'S³)` and `Q=O(C'S³)`;
- `J=O(C'S⁴)`;
- `P_Q=O(C'²S⁷)`;
- `log(3+4R/zeta)=O(S²)`.

The last bound uses `log C'=O(L)`, not an exponential upper bound on C' substituted into parameter counts. Therefore

`log|G| <= A C'² S⁹ <= A C² S⁹`

for a universal A. A sufficient sample size is consequently

`n >= [2A C² S⁹ + 2 log(1/delta)]/epsilon`.

This is a literal quadratic dependence on C with only polynomial dependence on depth and the remaining displayed resources. It applies to the same neuron-averaging prior as the main result; it does not establish such a rate under the original RMS robustness event alone.

Both extensions pass this independent mathematical review. Neither has been Lean verified.
