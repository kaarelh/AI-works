# Independent audit of critical-depth memorization and posterior lower bound

Auditor: depth_memorization. Audited the draft `critical.md`, the finite-domain LDP proof in `works-in-progress/critical-depth/source/critical-variational-background.tex`, and the final assembled `works-in-progress/continuous-depth-lower-bound/source/meanfield.tex`. The final source contains the fixed-distribution upgrade and the sharper confidence bound below. I found no substantive gap in that final source.

## Findings on the finite-support proof

I found no substantive gap in the proposed finite-support theorem. The points that require explicit justification are all supported by the construction:

1. **The initial seed is a full-domain feature law.** The feature law is a mixture of pushforwards of shifted Gaussian first-layer weights. Consequently its mean vector exists on the entire finite test domain, even though only its training coordinates are prescribed. If its mean is `a_n y` on the sample, mixing the law into the reference law with weight `1/D` gives covariance domination by the outer product of the original mean divided by `sqrt(D)`. Its seed amplitude is therefore `a_n/sqrt(D)`, not `a_n/D`, and its entropy is at most one. The full-domain covariance assertion is valid.

2. **No rank-dependent covariance scaling occurs.** Free layers use the original conditional Gaussian law. Their covariance retains the first Hermite component of the seed. The late amplification layers use Gaussian mean shifts along a genuine covariance-dominated vector. Each such shift has entropy at most `A²/2`, independently of the number of input points. Thus the construction does not hide a factor equal to the size of the finite support.

3. **Free cooling has polynomial signal loss.** The diagonal recursion is `q' = E tanh²(sqrt(q)Z)`. On `[0,1]`, `q' <= q−q²/100` is valid: `u²−tanh²u >=u⁴/6` on `|u|<=1`, and `E[Z⁴ 1{|Z|<=1}]/6>1/100`. Hence `q_s <=1/(1+s/100)`. The seed multiplier is exactly `h(q)=E sech²(sqrt(q)Z)`, by projection onto the independent scalar Gaussian carrying the rank-one component. Since `h(1)>=1/8`, `−log h(q)<=8q`, and the retained amplitude is at least `e^{-8}(1+H)^{-800}` times its starting amplitude. This estimate is loose but genuinely polynomial in depth.

4. **Layer placement removes the linear baseline entropy.** Choose an integer number `m` of amplification layers using the lower bound
   `u_min=e^{-8}(L+1)^{-800} a_n/sqrt(D)`.
   Then take `H=L−m−3` free layers, accounting for one first seed layer, `H` free layers, `m` amplification layers, and one final saturation layer. The depth condition makes `H>=0`. Choosing `m` from the bound using `L` avoids circular dependence between free-layer count and amplification count. The resulting cost is `O(log(D/a_n²)+log(L+1))` for fixed tolerance. The large hidden universal constants only make the exponential sample exponent small; they do not invalidate positivity of that exponent.

5. **The source LDP is exact and permits singular covariance.** It represents hidden features recursively using independent standard-Gaussian empirical measures, and output as `Q^{1/2}G/sqrt(N)`. Sanov plus the continuous contraction principle gives the stated good rate. Continuity follows from uniform convergence on compact Gaussian-coordinate sets and tightness, without inversion of covariance. Entropy contraction and the Gaussian output minimization give the pseudoinverse/range convention. Nothing in that proof depends on the original input set being Boolean; replacing its initial covariance by `(1+x dot y)/d` is legitimate for any fixed finite input set.

6. **The posterior argument treats mixtures.** Raw prior mass of pair-correct outputs has a strictly worse exponential rate than the training tube. Consequently posterior pair-correct mass tends to zero, and averaging at least one error per pair gives limiting Gibbs error at least one half. The sharper confidence conclusion uses the pairwise inequality `p(x_+)+p(x_−)<=1+b_N`, where `b_N` is posterior probability of both predictions being correct. If `b_N<1/3`, at least one point has correct-answer probability strictly below `2/3`. Thus confidence error also has lower limit at least one half. No selected-minimizer inference is used.

## A simpler low-rate Lipschitz estimate

The transport proof in the draft is valid. It can also be replaced by the following scalar entropy argument, which gives a slightly stronger constant and avoids invoking quadratic transport.

Let `j=D(ν || M_Q)`, and put `v=(e_x−e_y)^T Q(e_x−e_y)`. Under the reference law, the hidden difference obeys

`(H_x−H_y)² <= (G_x−G_y)²`,

where the right side has law `v Z²`. Entropy duality and the Gaussian square moment generating function therefore imply

`E_ν(H_x−H_y)² <= v(1+2sqrt(j)+2j) <= v exp(2sqrt(j))`.

For the first inequality, use the centered chi-square bound

`log E exp[t(Z²−1)] <= t²/(1−2t)`, `0<t<1/2`,

and optimize at `t=sqrt(j)/(1+2sqrt(j))`. The `j=0` case follows by continuity. If `v=0`, the difference vanishes reference-almost surely and hence under every finite-entropy law.

Multiplying over hidden layers and applying Cauchy–Schwarz, then applying the readout energy bound, gives for a path of total cost `A`

`|z(x)−z(y)| <= sqrt(2A/d) exp(sqrt((L−1)A)) |x−y|`.

The weaker factor `exp(sqrt(2(L−1)A))` in the draft remains valid and suffices.

## Extension to the fixed nonatomic Cantor distribution

A functional LDP is unnecessary for this extension. It suffices to apply finite-dimensional LDPs separately to the fixed training set and to each coupled test pair, and then use bounded convergence.

Fix the nonatomic invariant Cantor measure `μ` from `continuous-lower.md`, supported in `[-.65,-.5] union [.5,.65]`. At depth `L=h+1`, the teacher is `f_h(x(t))=F^h(t)` and preserves this value range on the support.

Generate a test pair by choosing a uniform prefix word `σ` of length `h` and an independent `v~μ`, and setting

`t_+=φ_σ(φ_+(v))`, `t_−=φ_σ(φ_−(v))`.

The average of the two marginal distributions is exactly `μ`, by its Bernoulli inverse-branch construction. The corresponding points on the circle satisfy

`|x(t_+)−x(t_−)| <=3·3^{-h}`,

and their teacher output gap is at least one. If both are accurate to `τ=1/4`, the predicted output gap is at least one half. The same low-rate estimate therefore gives raw rate at least `h/100` for pair-correct outputs, for all sufficiently large `h`.

For a fixed separated training sample `S`, the seed/amplification construction applies to the signs of its labels. Its output can be chosen within `0.006` of `±3/5`: take the final saturation accuracy `η=1/100`. Since the actual teacher labels lie in `±[.5,.65]`, this gives training error at most `.106<ρ=1/8`. Consequently the open training tube has rate at most `C(log(n+1)+log(L+1))`, just as in the finite-support proof. The final output need not equal the real labels exactly; this extension concerns the stated positive training tolerance.

Fix `S` satisfying the quantitative separation event and fix one test pair. Write `A_S` for the training tube and `B_pair` for pair correctness. Then

`posterior_N(B_pair) <= prior_N(B_pair)/prior_N(A_S)`.

The numerator uses only the two test coordinates, so its finite-domain LDP yields upper exponential rate at most `−h/100`. The denominator uses only the finite training coordinates, so its LDP lower bound yields rate greater than `−h/200` when `n<=exp(c_*h)` and `c_*` is sufficiently small. Thus

`posterior_N(B_pair) ->0`

for every fixed pair. The ratio inequality shows that no joint functional LDP is needed, and even a joint LDP on training-plus-test points is optional.

The posterior pair probability lies in `[0,1]`, so bounded convergence over the coupled pair distribution gives

`E_pair posterior_N(B_pair) ->0`.

At least one member of every pair is inaccurate outside `B_pair`. Averaging posterior errors over the pair coupling therefore yields

`liminf_{N->∞} Gibbs_τ_error >=1/2`.

For the sharper posterior-confidence conclusion, set `b_N(pair)=posterior_N(B_pair)` and use inclusion–exclusion:

`p_N(x_+)+p_N(x_−)<=1+b_N(pair)`.

When `b_N(pair)<1/3`, both probabilities cannot be at least `2/3`, so at least one point has probability strictly below `2/3`. Since a fair choice of one member of the pair has distribution `μ`, Markov gives

`μ{p_N(x)<2/3} >= (1−3 E_pair b_N)/2`.

Therefore

`liminf_{N->∞} μ{p_N(x)<2/3} >=1/2`.

This conclusion holds for each fixed quantitative-separated training sample. The sample-separation event has probability at least `49/50`: with `Δ_n=(100n²)^{-1/α}`, the nonatomic small-ball estimate and a union bound give failure probability at most `n²(2Δ_n)^α=2^α/100<=1/50`. No finite-support atom correction is present.

Thus the result genuinely uses one fixed nonatomic distribution on the unit circle for every teacher depth. The order is fixed depth and fixed finite sample first, then learner width tending to infinity. The conclusion is a samplewise lower limit of at least one half, not a statement that the error is eventually at least exactly one half. For every fixed `r<1/2`, the error is eventually at least `r` for each good sample; Fatou also gives `liminf_N P_S{confidence error>=r}>=49/50`. No uniform width threshold in growing depth, and no exact real-value conditioning result at the critical exponent, follows from this bounded-convergence argument.

## Final-source check

I re-read the complete assembled `source/meanfield.tex`, including its actual finite-width law representation, entropy-contraction calculation, singular-covariance metric bound, first-layer Gaussian mixture, free-cooling inequalities, explicit layer allocation, training-label tolerance calculation, separate training/test-pair LDP comparisons, and bounded-convergence argument. They match the checked mathematics above. The strict events and limits are consistent: training uses `<1/8`, correctness uses `<=1/4`, and the confidence lower bound uses `<2/3` with a samplewise `liminf`.

The audited `meanfield.tex` SHA-256 was `032d8d3a5febf5c841096f320b971368f0f3caeac6ad2428c7ff1954c6fbd05e`. This is a mathematical review, not a Lean verification.
