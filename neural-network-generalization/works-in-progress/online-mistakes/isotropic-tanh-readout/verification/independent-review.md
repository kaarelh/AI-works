# Independent mathematical review

Reviewer: separate ChatGPT-6 Astra research agent (`wide_tanh`).
Date: 6 November 2026.

All five source files and their theorem correspondence were reviewed. No mathematical error was found. This is an AI-agent review, not a Lean verification.

Final reviewed source hashes:

| Source | SHA-256 |
|---|---|
| `source/paper.tex` | `eab80a2624d7de185f917834e05a175d9d981d3a99f5b030493cc6d7013a5fb2` |
| `source/dual.tex` | `7f7be0ad477e146261f2d4cc6c08dc25723dfe6070470449a4cf47a5c66d55e1` |
| `source/posterior.tex` | `921f88aaabdf0433c196c3ad73b37d5b74679885890f5e0a2af7a000a7096624` |
| `source/selector.tex` | `b64cf59a362f6fd6a923d28143056545db4ee0e8985cbf87d1eb1efd14fdd378` |
| `source/teacher.tex` | `65fa6474f78d38c0a36af2406c3e0aec5a9eb343ce5f04078bf13b2f7f524d6d` |

## Main theorem and scope

The model uses fixed ordinary tanh, one hidden layer, the full Boolean cube, one constant input coordinate, a linear readout, independent Gaussian weights with exactly equal first-layer coordinate variances, global strict output margin greater than one half, and exact labels. The prior has the stated extra readout variance divisor `A_N`, where **any positive sequence tending to infinity** is allowed. No monotonicity or lower rate of divergence is used. Gamma may equal one, and the positive variance prefactor is arbitrary and fixed.

The result does **not** cover `A_N=1`, a fixed bounded correction uniformly across the target family, every width above the teacher width, or a polynomial width threshold. Subpolynomial corrections preserve the power-law exponents but still change the prior. The abstract and scope section preserve this distinction.

For each fixed target, the input permutation is independent of width and prior parameters. It has at most `4k+3` calibration examples followed by exactly `2^k-k-1` designated rounds. The finite number of histories permits one threshold beyond which every width has the claimed posterior behavior. Posterior sampling is handled by a union bound; no unfavorable tie selection or independence of predictions is assumed.

## Exact scalar theorem

The KKT representation and normalization `sum mu_i=Q` are correct. The atomwise dual bound includes arbitrary hidden directions and arbitrary signed readout weights. After orienting an atom to make its active-data average nonnegative, nonnegative active scores give the tanh Jensen bound. A negative active score gives the complementary `1-p` bound. The explicit readout penalty makes the latter case no cheaper than the scalar dual value.

The strict concavity of `tanh²(sqrt(v))` follows from the displayed logarithmic derivative; the scalar radius is the unique minimizer. Completing the square and averaging the dual inequality gives the exact network energy minimum at **every width**, without assuming threshold outputs or global margin in the lower bound. Readout amplification handles strict margins.

The common Boolean-data penalty is valid: a minimal positive KKT support is linearly independent, its Gram determinant is a positive integer bounded by `D^D`, and Cramer's rule gives the required positive coefficient lower bound. The resulting penalty is finite for every fixed training set, which is all that arbitrary divergence of `A_N` needs.

## Selector geometry

The diagonal calibration inequalities bound the coordinate-sum variables. The paired carry constraints force the binary lower bounds on the antisymmetric coefficients. At query `q_t`, the condition `t>=k` removes the remaining bias slack, giving the exact convex affine minimum. The equality case is unique. Its scores are odd integers on the entire cube and therefore have global absolute margin at least one. It fits every earlier negative query and predicts the next one positively. The exact squared-norm increment is `4(t+1)`.

The permutation has no repeated input, and the target is an affine threshold function even though the exhibited bounded-weight shallow teacher uses more neurons. The linear Boolean circuit construction and essential-input lower bound give the claimed Theta(k) complexity.

## Bounded-weight teacher

Both even and odd parity cases in the top Fourier coefficient calculation were checked. The odd-integer tanh approximation bound, central-binomial induction, signed feature mixture, Hoeffding constant, cube union bound, and readout-weight bound are correct. The construction gives strict uniform approximation error below one quarter and hence signed margin strictly greater than three quarters.

The comparator's Fourier expansion has l1 norm at most `k+1`; the selector increases this to at most `k+2`. Substitution yields the stated explicit O(k^4) width bound at the same shallow depth. The lower bound is exponential in Boolean circuit size and superpolynomial (stretched exponential relative to the displayed polynomial bound) in the bounded-weight shallow teacher complexity; it is not claimed to be exponential in that width bound itself.

## Actual posterior at arbitrary diverging correction

The normalized coordinates have exactly `P=N(d+2)` independent Gaussians with variance `sigma_N²`. Their squared norm is the energy. The scalar profile gap is at least a positive constant times `log² A_N`.

The amplified scalar witness has global margin slack of order `log²(A_N)/A_N`. In whitened coordinates its output gradient is uniformly bounded on a radius-one neighborhood, because the readout coordinate norm is O(sqrt(A_N)). Consequently the radius-`A_N^-2` ball lies in the full strict-margin cell and adds negligible energy.

The Gaussian lower-mass calculation keeps `P*sigma_N²` together. This factor is bounded when gamma is at least one, so the volume cost is only `O(N(1+log A_N))`, with no spurious `N log N` loss at gamma equal to one. The chi-square upper bound covers **every** correct-next-label network. After division, the negative term `-Omega(N^gamma log² A_N)` dominates the displayed volume corrections for every diverging sequence. This includes arbitrarily slow divergence and arbitrarily fast divergence.

## IID comparison

The nonthreshold-energy lemma sums nonnegative deficits over the entire finite cube and proves a gap of order `A_N` above the threshold baseline. A strict full-target cell gives a denominator uniformly valid for every target-consistent history. The same Gaussian comparison therefore sends total nonthreshold posterior mass to zero uniformly over training samples and their input distribution.

A finite threshold-class consistency bound then gives the stated sample complexity. On the good sample event, posterior mean population error is at most epsilon/4 plus the nonthreshold mass. Taking the latter at most epsilon/12 and applying Markov's inequality gives the **strict greater-than-two-thirds correct-label confidence** conclusion, as well as majority accuracy.

## Final source additions checked

The final main statement explicitly includes the strict greater-than-two-thirds confidence convention already proved by the IID theorem. The added reference-scaling comparison proposition was independently checked. Rounded cloning of the bounded Fourier teacher gives first-layer energy at most `d(d+1)` and readout energy at most `2B²` at every `N>=2n_k`, preserving its strict margin. The scalar profile has lower bound `sqrt(d*Q_t)` by `tanh r<=r` and the arithmetic-geometric mean inequality. Thus the polynomial-energy true teacher beats every listed scalar witness for large k under `A=1`. The text correctly says this does not compare all wide wrong functions or resolve the canonical-prior online problem. The final paper hash above includes both additions; the other four source hashes are unchanged.
