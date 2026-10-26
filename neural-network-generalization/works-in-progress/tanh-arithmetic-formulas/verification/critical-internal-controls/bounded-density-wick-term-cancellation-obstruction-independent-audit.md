# Independent audit: bounded-density Wick-term cancellation

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `f15b8766501ca758eb96adfc863e557f3275e684e9fd09c54fa7c483f9d9b93f`.

The centered sign density is normalized, lies in [1-epsilon,1+epsilon], and has KL O(epsilon^2). The complete degree-K covariance perturbation is bounded by epsilon. The normalized Hermite product coefficient at degree 2K is exactly sqrt(binomial(2K,K)), and its density pairing is positive epsilon E|H_(2K)|/2.

The Taylor polynomial divided by its nonzero constant term has the stated coefficients. On an interval of width c/sqrt(K), the cosh bound keeps its magnitude above half that at zero. Combining the resulting K^(-3/4) Gaussian L1 lower bound with the central-binomial estimate gives the claimed c epsilon 2^K/K individual contribution.

The second-moment lower bound for any one-term importance estimator is Cauchy--Schwarz, and conditional Jensen extends it to unbiased internal term estimators. Thus the exponential loss is an actual obstruction to absolute separate-term sampling, even in one dimension with bounded density and small entropy.

The final scope is correct: aggregation of the whole covariance coefficient can retain the cancellations, so this is not a formula-complexity, NN, or learning lower bound. Dependence of the example density on K suffices to disprove a uniform polynomial estimate; no fixed-density divergence is claimed.

## Expanded analytic and exact-tanh examples

**PASS** for the expanded source at SHA256 `c934a7f5b919b95fe35e70a486c1d511175cefa653e6929be230aaac74af05fa`.

The single-frequency analytic density in Section 4 has the stated exact top contraction, by the Gaussian Hermite--Fourier identity. Stirling gives the stronger lower bound c epsilon 2^K/sqrt(K).

In Section 5, the negative frequency-one coefficient exactly cancels the second Hermite moment; normalization and evenness give mass one and mean zero. The bound n^2 exp(-(n^2-1)/2)<=1 for n>=2 controls its magnitude, and exponential frequency decay gives analyticity on the stated open strip and bounded real derivatives of every fixed order. On K=2j^2+1, the selected n=2j frequency contributes the claimed lower bound. All other positive-frequency terms have its sign, while the sole negative term is negligible. Thus one fixed bounded analytic density with matched mean and variance retains exponential separate-term cancellation.

Section 6's Fourier interchange is justified separately at each odd degree. On t in [sqrt(k),sqrt(k)+1], the log ratio of t^k exp(-t^2/2) to its value at sqrt(k) is at least -1, and Stirling then gives the stated k^(-1/4) exp(-C_q sqrt(k)) lower bound. Combining its square with the top covariance term gives individual fully separated tanh/Wick terms that grow rather than tend to zero. The finite-subset Cauchy--Schwarz argument consequently rules out finite second moment for any one-index importance estimator of that separated expansion. The grouped polynomial covariances do converge, because the density is bounded and the Hermite activation partial sums converge in Gaussian L2.

The scope remains narrow and correctly stated: this excludes the fully separated importance-sampling strategy, not a factory that aggregates contractions or otherwise preserves cancellation, and not an NN representation or learning theorem.
