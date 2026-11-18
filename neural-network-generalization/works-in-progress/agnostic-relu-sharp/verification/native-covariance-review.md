# Independent review: native-covariance ReLU obstruction

Reviewed 18 November 2026 (UTC). This is an independent AI-agent mathematical check, not a Lean formalization.

## Verdict

The proof supports extension of the sharp ReLU obstruction to every actual finite canonical prior exponent gamma>=1, simultaneously over all temperatures, at a larger polynomial learner width. No substantive mathematical gap was found. The matched positive exponent boundary remains proved in the strong-prior limit and at finite gamma>=2 (all gamma>=1 for a single hidden layer); the lower-bound extension alone does not upgrade that positive theorem.

## Proof checks

- The shifted-half-integer ReLU identity implements each Boolean parity exactly with all hinge arguments at distance at least1/2 from zero. The augmented-row and squared-coefficient bounds give M=(D+1)2^D and T_c<=20(D+1)n/2^D by normalized Fourier Parseval.
- The balanced replicated first layer and two-group subsequent layers have weighted mean energy at most L R^2. In particular the second-layer bound is2 M T_c a_2^2<=Q_2 a_2^2, and every later matrix/readout uses N(1/k_++1/k_-)<=6. The product of gains is exactly1/beta.
- Gaussian covariance is unchanged throughout. Therefore KL is exactly the standardized squared mean divided by two, with no width-dependent covariance entropy penalty.
- Every first-layer field has variance at most two, even on ignored real-valued input coordinates. Gaussian smoothing changes a ReLU hinge with margin beta/2 by at most exp(-beta^2/16). Summing absolute coefficients and dividing by beta gives precisely e_n.
- For any centered symmetric background, E ReLU(u+Z)-E ReLU(-u+Z)=u. Conditional on previous layers, the paired groups share the same Gaussian variance and independent rows, so the conditional signed-mean recurrences are exact, independent of that variance.
- The mean matrix Frobenius bound R implies the second-moment recursion E S_l<=(R^2+1)E S_(l-1), with E S_1<=2(R^2+1). This avoids assuming that the signed scalar gain equals the matrix operator norm.
- Gaussian field variance and the one-Lipschitz variance contraction give Var F_1<=2Q_2/N and conditional Var D_l<=6 S_(l-1)/N. Iterating total variance gives the first-layer contribution at most2(R^2+1)^H/N, each hidden contribution at most12(R^2+1)^H/N, and readout contribution at most2(R^2+1)^H/N. Their sum is below the stated12H(R^2+1)^H/N.
- For the noisy empirical-mean memorizer, R^2=O_H(n^(1/L)d^(5/L)), beta^2 grows polynomially up to logs, and e_n=o(n^-2). Width at least12H n(R^2+1)^H gives variance at most1/n and hence the required empirical variational comparison uniformly over gamma and width. The width order is O_H(m+n^(2-1/L) polylog n).
- At high regularization, normalized Gaussian operator-norm tails and the evidence lower bound bound the posterior moment of T^L. The input sensitivity factor1/sqrt(d) is correct. Its inner-pair half-difference is O_H(n^(1/2-Ha-Lb) polylog n), which vanishes under the strict lower-bound exponent condition.
- The mean, clipped-mean, and mean-of-clipped-output risks are handled directly. Jensen supplies the corresponding Gibbs-risk lower bounds. The proof uses the original common sample event and does not introduce a temperature-dependent input distribution.

## Source correspondence

Reviewed source: `raw/relu-native-covariance.tex`.
Source SHA256 at this review: `0b0c6a7ce335d7ce500cc0f73b2b8e6ea2b24f88783c6f2a7cb504ab3f7ffd83`.
The two reported missing-backslash typos have been repaired in the reviewed final source. The added localized-noise and fixed-width-four corollary also checks: the same native memorizer is zero in target on negative-tag inputs, its extra comparison loss is at most2/n, and the mean-energy term remains unchanged; the high-temperature half-difference vanishes under the corresponding existing strict exponent condition. The localized-noise constant remains p² exp(-p)/256. The final package should additionally record hashes of its integrated TeX and PDF.
