# Independent audit: essential tiny components on canonical nearbaseline paths

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `4bd9ef93a4e003b292ef200bb2cdff2b44fca8dc97c9057ebae64909ccc0160d`.

The construction uses the actual d=1 augmented Boolean inputs, whose free preactivation covariance is diagonal. Free tanh cooling therefore produces q I_2 at q of order log(M)/M without entropy cost. Splitting this into common and dictator components is exact.

Holding the common component uses the full conditional-mean feature construction from `critical-rate-foundations.tex`, equations `critical-residual-nonincreasing` and `critical-component-growth`, and the proof of `critical-cheap-holding`. Its selected Gaussian inflation is O(q), with entropy O(q^2). Conditional Gaussian Poincare improves the residual contraction to 1-cq because the preserved common component has variance bounded below by cq. Holding for C_A M layers suppresses the dictator below M^(-A), at total entropy O_A(log^2(M)/M). The Gaussian first-chaos PSD lower bound, applied to the constant-diagonal covariance and positive inflation, simultaneously retains a polynomial lower bound. Exchange symmetry ensures the exact two-component decomposition at the selected middle layer.

The displayed bounded score has unit second moment and the required dictator correlations. The general-start prescribed-growth proof yields cost O(p+Delta log(p/v_f)) and length O(log(p/v_f)/Delta+1/Delta). With Delta and p of order log(M)/M and inverse-polynomial v_f, these are O_A(log^2(M)/M) and O_A(M). Holding the correct component then purifies its residual to any prescribed inverse-polynomial scale at the same cost and depth orders.

I checked the scalar lifting interface directly in `critical-rate-foundations.tex`, lemma `critical-scalar-lift`: a scalar continuation of length m preserves a factor (1-delta)^(2m) of its target variance and adds at most 12 m delta to its action when the scalar cost is at most three. Together with the increasing scalar-path length O(1/p), this gives the asserted O(M^(-R)/p) overhead. The imported inverse-depth lower bound also establishes the stated O_A(log^2(H)/H) distance from the actual minimum action at that depth.

After deleting the one dictator coordinate, the two query features are exactly equal. Every finite-relative-entropy row law preserves the diagonal Gaussian support, so equality persists at every subsequent layer and a linear readout cannot give opposite labels. This proves the deletion obstruction without making any assumptions about later controls.

The source correctly distinguishes an explicitly constructed nearoptimal path from an exact global optimizer. It proves no learning lower bound and does not obstruct a compiler that retains the small component at polynomial precision. It does show that nearbaseline action and scalar occupation budgets alone cannot justify deleting every sufficiently small feature component.
