# Independent audit of the deep mean-field construction

Reviewer: the research agent assigned to the polynomial-depth mistake converse. Date: 22 October 2026.

This is an AI-agent mathematical check, not a Lean proof or human review.

## Fragments reviewed

- `meanfield-atoms.tex`, initial 155-line version.
- `../meanfield-alternative/bulk-tail.tex`, initial version.
- The sparse-dual argument from the existing mean-field paper, to check the normalization used by the bounded bulk certificate.

No substantive mathematical gap was found in these component fragments. The recursive reconstruction and final finite-width theorem were subsequently reviewed as described below.

## The main realization issue

The correct induction object is a weighted covariance

```text
Q'(x,y) = sum_i a_i h_i(x) h_i(y),   a_i >= 0,
```

where every `h_i` is the output of an ordinary neuron using the requested activation. This auxiliary covariance need not equal the compressed network's uniformly normalized empirical covariance. Its weights are absorbed into subsequent ordinary network weights:

- A Gaussian field of covariance `Q'` uses incoming coefficients `sqrt(a_i) xi_i`.
- An atom with certificate `beta` uses incoming coefficients `S a_i (beta · h_i)`.
- A sampled cutoff `r(Z)` is one number fixed for the entire neuron, and contributes coefficient `r(Z)^2/n` to the next weighted covariance. It is not evaluated on new inputs.
- A scaled GELU approximation `phi(Sv)/S` contributes coefficient `A/(n S^2)`; its actual neuron still evaluates `phi`.

The atom lemma chooses one finite list of certificates with `||beta||_1 <= 1/(4 eta)`. That same list works for every previous covariance within `eta^2` in maximum norm. Thus it can be used after earlier layers are randomly sampled; there is no illicit independence requirement for covariance transport or sample-dependent choices.

At the first layer, `Q0 beta` is directly an affine input map with coefficients `(1/d) sum_x beta(x) xbar`. Its entries are bounded by `1/(4 d eta)` before the scaling `S`.

Raw sampled neuron outputs are not necessarily bounded by the cutoff scale, since the cutoff may vanish. Instead, control Gaussian incoming coordinates using the tilted density ratio `exp(2 G F0)`, then propagate ordinary weight and activation bounds recursively. For a fixed number of layers this gives polynomial bounds. The sampled atom weights have the deterministic bound stated in the fragment.

## Checks of the component proofs

- The metric projection onto the Gaussian half-probability set gives `E exp(distance^2/4) <= 2`; the energy exceptional probability is `exp(-N K)`.
- The tail covariance error is at most `6 D M A/T`, using the tail-mass and tail-first-moment bounds separately.
- The smooth maximum cutoff has first and second derivative entry sums bounded independently of the number of inputs except for `log(2m)`.
- The ReLU smooth surrogate has uniform error `tau/2`; the bulk covariance replacement costs `O(T tau)`, including when sampling is performed under the surrogate tilt but ordinary ReLU is evaluated by the network.
- The Gaussian quotient derivative gives the displayed polynomial stability constant without estimating the reciprocal partition function exponentially.
- The bounded-observable sparse-dual certificate uses radius `G F0` after normalization, giving its stated `G^2 F0^2/(2s)` term and covariance discrepancy `K/G`.
- The RKHS tube projection's complementary-slackness identity gives the claimed `1/(4 eta)` certificate bound even for singular covariances.
- The sampled normalized atoms, covariance transport, and scaled GELU approximation all have the claimed errors with room in the constants.

One small LaTeX line-break issue in the bulk Gaussian derivative display was reported to its author for correction during compilation.

## General Lipschitz endpoint and recursive closure

The review was extended to `../common/generic-meanfield-atoms.tex` and `meanfield-closure.tex`.

For an arbitrary zero-at-zero Lipschitz activation, the normalized tail map `psi_delta(t) = phi(delta t)/delta` remains in the same Lipschitz class. The common capacity proof explicitly permits a different such map at every neuron. Its product-norm normalization applies unchanged neuron by neuron. Consequently the endpoint is a learning theorem for the original fixed-activation prior even though the counting reconstruction uses auxiliary activations. It does not establish an actual fixed-activation circuit compression or converse for every Lipschitz activation. The specialized ReLU/GELU atom construction supplies that stronger realization only in those cases.

One recursive bookkeeping gap was found and corrected by the author: a global covariance-diagonal bound inserted into every projection cutoff does not itself inductively bound all later diagonals by that same value. The corrected proof uses `M_0=2`, `M_s=2F^s`, applies the layer-s projection with `M_{s-1}`, and uses corresponding layerwise backward accuracy moduli. The maximum `M_H` only majorizes the resulting polynomial budgets.

After that correction, the complete endpoint closure checks out:

- The one-step errors sum to less than the requested accuracy.
- Each reciprocal backward modulus is polynomial, and a fixed-depth composition remains polynomial.
- Covariance transport is uniform in the already sampled reconstruction, so the selected atom certificates introduce no independence assumption.
- Gaussian coordinate cutoffs and deterministic atom weight bounds yield actual finite auxiliary networks with polynomial width, weights, and normalized energy.
- The final RKHS certificate has coefficient sum at most `16K`; covariance error `1/(128K)` and its approximation error add to at most `1/4`. Doubling the readout restores the required strict margin.
- The finite class and raw exceptional-mass bound give the stated posterior result at every width, with one sample event simultaneous in width for a fixed mean-field scaling.

## Uniformity over all widths and scales

The completed `uniform-supercritical.tex` was then audited in full. Its common finite-energy class resolves the continuum quantifier, yielding one training-sample event simultaneous over every admissible width and every scale `0 < t <= 1`.

- In the small-scale band, the spectral cutoff conditions depend only on `t`, and the raw exceptional mass is `L exp(-N K_s/(8t^2))`.
- In the complementary scale band at large widths, the endpoint construction remains valid with input covariance `t^2 Q`. Incoming Gaussian weights are multiplied by `t`, atom weights by `t^2`, and previous covariance error contracts by `t^2`; no bound deteriorates.
- At the remaining bounded widths, the total energy has law `(t^2/N) chi-square_p`, with `p/N` uniformly bounded by `D_*`. Dividing its moment-generating-function tail by the target mass gives exactly the displayed bound with budget `J_0`. This works simultaneously for the whole continuum of scales.
- A single auxiliary energy class with budget `J_*` contains the three constructions. Its finite-class PAC event therefore handles all scales and widths at once; no union bound over a continuum is used.

No substantive gap was found in this completed argument. The resulting fixed-depth polynomial has no exponent or constant depending on the prior exponent gamma. It is a learning theorem for the original fixed-activation posterior, with the auxiliary-network qualification described above.
