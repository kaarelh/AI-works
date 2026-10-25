# Independent audit: assembled all-derivatives appendix

25 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** for the final linear-depth theorem, its proof, and the finite-order Gevrey evaluation proposition. Checked source SHA256 `efd2b11e60550469fd3e4e032b85c23af8e20f5205320618c5cf5561d7b31fec`.

The derivative, band separation and growing finite-difference calculations were independently checked against the original construction and the [research note](../research-notes/all-derivatives-bounded-counterexample.md). The final version makes the stronger amplification choice a_d=2^(m_d-2), within the O(d) weight bound. Its exact identity is delta_d a_d^(d+1)=tau 2^-16. All ideal preactivations form a geometric sequence of total magnitude at most twice this fixed small endpoint, so the usual relative-error bootstrap is uniform even as the gain grows. There are d+4 weighted layers. Width remains O(log d), and O(d log d) parameter bits suffice.

Because depth is again linear in d, the original fixed-q memorizer works without the previous logarithmic overhead. The cold, fixed-gap and critical every-sample posterior lower bounds retain their exp(O_gamma(d)) actual finite-width thresholds. The strengthened rate is exp(Omega(L)), with every derivative globally bounded. This supersedes the earlier log-loss snapshot.

For the Gevrey proposition, replace the fixed order by its integer ceiling and use an integer upper bound for A. A regular rational mesh of radius (2 A n^(s0-1))^-1 gives Taylor remainder C 2^-n. The number of intervals is polynomial in R,n, and their centers have polynomial bit length. Taylor coefficients have logarithmic magnitude O(n log n). Absolute coefficient rounding at 2^-p/(8n), followed by polynomial-precision rational arithmetic on arguments of magnitude at most one, gives the claimed polynomial-size nonuniform evaluator. No efficient coefficient-generation assumption is needed. Composing with the constructed teacher at precision O(d log d) contradicts its circuit-hard target tables, so the exclusion of finite-order Gevrey bounds follows.

The activation remains computationally encoded; this is not a theorem about tanh or another standard efficiently evaluable activation.
