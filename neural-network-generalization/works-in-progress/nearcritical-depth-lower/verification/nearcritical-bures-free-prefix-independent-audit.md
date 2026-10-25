# Independent audit: nearcritical free-prefix width

25 October 2026. Audited by the supercritical-assembly agent independently of the finite-N-audit agent who derived `nearcritical-bures-free-prefix.md`.

**Conclusion:** the free-prefix claim passes this audit. It is a finite-N prior whitening statement, not a posterior theorem.

The key Gaussian regression inequality is valid: conditional second moments are affine increasing functions of W², while sech⁴(tW) decreases with W², giving E[Delta² sech⁴(tW)] <= EDelta² E sech⁴(tW). Under Bures error at most c epsilon^(3/2), every interpolated row variance stays above q_*−O(epsilon²), so the squared L2 propagation gain is 1+O(epsilon²). The transformed outputs need not be Gaussian: covariance Bures distance is bounded by the L2 cost of any coupling, including this nonlinear one.

The initial finite burn has O(epsilon^-2 D) layers, hence only exp(O(D)) amplification. The chosen sampling tolerance is inverse exp(O(D)); conditional Hoeffding and a union bound require N>=exp(AD)log(h+2). After burn, the entrywise box of radius c epsilon³/m is invariant under the population map plus the same sampling tolerance. This prevents a hidden dependence exponential in the entire arbitrary prefix length.

The population Hermite coefficient b_3(q)>=c q² follows from the strictly negative covariance of Z² and sech²(t sqrt(q)Z), continuity on bounded positive q, and its nonzero Taylor limit at zero. The resulting correlation mixing and scalar attraction reach the stated entrywise radius within the advertised burn. The operator square-root estimate used for sampling Bures error is valid for noncommuting positive semidefinite matrices.

One minor prose correction was reported to the author: the final consequence should say the controlled-stage checks are ensured by N at least an exp(CD) threshold, not that they require N at most that threshold. No mathematical correction was required.
