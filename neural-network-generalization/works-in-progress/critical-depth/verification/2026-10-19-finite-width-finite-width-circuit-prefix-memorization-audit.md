# Independent audit: rare finite-width Boolean circuit prefix

Auditor: `depth_memorization`. Date: 2026-10-19 (research round identifier).

Audited source: `source/critical-finite-width-circuit-prefix.tex`.

Current audited SHA-256: `4de365738a40063f994336c130d703533ba6c43429cd0c91af4c9486ef21a628`.

**Verdict: the finite-width circuit-prefix lemma and the sharpened exp(O(T)) resource remark pass independent mathematical reconstruction.** This is an AI-agent mathematical audit, not Lean verification.

## Finite-width construction

- The prescribed group fractions decrease with depth. The width condition implies `N p_j >= 1` at every layer. Thus integer rounding gives `k_j <= 2 N p_j`, keeps all groups disjoint, and bounds the total designated fraction by the amount used in the entropy calculation.
- The first-layer translated Gaussian row has KL at most `a^2 B^2/(2 p_0)` with `p_0=1/d`, matching the first-layer Gaussian normalization. A later group row averages the preceding wire groups; its translation has squared norm at most `a^2 B^2/(N p_{j-1})`, giving the same normalized entropy formula.
- The translations are fixed by the circuit and its group partition. The controlled prefix is a product of translated Gaussian weight laws, not a law conditioned on success. Its total entropy divided by N is at most `1/(8L)`, including integer rounding.
- Previous wire error <= eta gives preactivation mean of the correct sign and magnitude at least `a(1-B sqrt(W) eta) >= 3a/4`. The looser `a/2` used for the saturation estimate is valid. The first Gaussian variance is at most two, and later variances at most one.
- Gaussian exponential moments imply Boolean mean error <= eta/4 and squared-feature deficit <= eta/2. Conditional group Hoeffding estimates and a union over all inputs, gates, and layers are covered by the stated explicit width condition.
- The heat derivative of the free diagonal map is `E[1-4 tanh^2+3 tanh^4]`, with absolute value at most one. Hence errors in the diagonal recursion accumulate additively, giving the stated `2j eta` bound.
- The final target-group unit vector provides an exact Gaussian projection direction. Its score coefficient is `sqrt(p)` times the empirical group mean. The residual is positive semidefinite by orthogonal projection, and its diagonal differs from the deterministic target by at most `(2h+3) eta`. The deterministic residual is nonnegative because the designated target group is part of the total designated fraction.
- The component/residual metric bound follows directly from the coefficient error and `(sqrt(u)-sqrt(v))^2 <= |u-v|`. No uniform full-covariance approximation is assumed.

## Seed-relative accuracy and quantitative width

The final remark uses

`T=log(d+2)+h log(C+B+h+L+2)`, `a=K T`, and `eta=8 exp(4-a)`.

Since `T >= h log(h+2)`, the inequality `h log(T) <= 2T` follows from `log x <= x` and `h log h <= T`. Consequently

`log(1/p_h) <= C (1+log K) T`.

For any fixed prescribed accuracy exponents, a sufficiently large constant K makes the linear K coefficient of `log(1/eta)` dominate the logarithmic K coefficient of the required seed-relative accuracy. The gate-margin requirement is also covered. The condition on delta in the final remark correctly restricts `log(1/delta)` to O(T), yielding sufficient width `exp(O(T))`. For arbitrary smaller delta the explicit width bound retains its necessary `1+log(1/delta)` factor.

The earlier informal note omitted that failure-probability qualification in one polynomial-width sentence. The author corrected the note; the theorem's explicit width condition was already correct. No substantive mathematical correction to the lemma was required.
