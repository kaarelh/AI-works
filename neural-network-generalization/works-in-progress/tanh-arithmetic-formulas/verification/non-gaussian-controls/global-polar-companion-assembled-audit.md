# Assembled companion audit: global-polar extension and arbitrary endpoints

25 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at exact source SHA256 `2bc969e0dab8994a528b1e1e28eaace33b673b44e8d6969fcb74721d5e12d2c9`, for `source/non-gaussian-controls.tex` in the public tanh-arithmetic-formulas package.

I checked the abstract, Theorem 2, the full assembled Section 11, and their interaction with the unchanged arbitrary-endpoint corollary and Section 12. The abstract and theorem now correctly use actual row entropy in the accumulated budget. The normalized representation mass has only a uniform smallness restriction; it is not silently summed over the path.

The assembled proof faithfully supplies the independently audited weighted component-moment lemma, raw cubic/quartic residual bounds, the global covariance polar isometry, and its scalar adjoint and forward realizations. The auxiliary Gaussian envelope covariance is used only inside residual factories, so there is no hidden per-layer copy charge proportional to its represented mass. Both vector and separately maintained norm states are charged to q + sqrt(D_actual) + D_actual. The finite-bit reduction receives the same previously proved trace and common-work hypotheses.

The universal small threshold t0 can be chosen once to accommodate the finite list of rank polynomials and fixed moment orders used in these factories. The parameter A in the weighted-moment lemma is fixed before this choice; no uniform claim for arbitrarily large A at one fixed threshold is needed or used.

The arbitrary first-layer construction, final density deletion, endpoint corollary, and original fixed-rank and Gaussian interfaces remain as previously audited. In particular the final-density overhead is included explicitly, and the bounded-action simplification is not extended to growing action without that overhead.

The conclusion remains a represented-class theorem. The explicit final scope paragraph correctly leaves arbitrary conditional internal row laws of the original critical posterior unresolved. This is a conventional mathematical audit, not a Lean verification.
