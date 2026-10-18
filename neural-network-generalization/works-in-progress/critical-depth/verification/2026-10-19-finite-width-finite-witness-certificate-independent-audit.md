# Independent audit: finite-width witness certificates and exceptional mass

Auditor: `/root/depth_continuous_lower`, 19 October 2026.

Reviewed source files:

- `source/critical-approximate-entropy-budget.tex`, SHA256 `49f89f7ff4e1c0622bbb5dfa4ec135f2f93e2f73247ee376e2f64148bbf7e413`.
- `source/critical-finite-width-certificate.tex`, SHA256 `6d7f660e55bf4619224f6e9ddb2e3d312b8d60df57bbfca2fb64f9ac040b48e6`.

I also checked the cited scalar-value modulus in the repository's `unrestricted-alternative-finite-width-upper.tex` and the original square-root entropy dyadic occupation proof.

**Verdict: both sources pass independent mathematical reconstruction.** The certificate is valid for arbitrary hidden-neuron-permutation-invariant events with the stated witness margin; it is not restricted to one fixed sign function. The exceptional-mass argument consequently avoids a union bound over the doubly exponential set of full sign patterns.

## Approximate entropy budget

The scalar suffix Bellman inequalities telescope with error at most C H sqrt(Delta), using the already established uniform one-half Holder modulus. The extension V(0)=V_* is legitimate for this comparison: at a zero reference variance finite entropy forces the controlled scalar coordinate to stay zero, so the one-step extended Bellman inequality is trivial. It is not asserting that the exact zero-state control problem itself can attain a nonzero margin.

Inflating D_j to D_j+Delta restores exact scalar dissipation. The prefix and total-cost budgets acquire at most O(H sqrt(Delta)), since Delta<=sqrt(Delta). The large-excess case follows by Cauchy--Schwarz. The small-excess last-exit proof also works with zero states: all zeros lie before the last exit from the low band, and every reciprocal division is restricted to a strictly positive band. The first transition is handled separately, so initial variance up to two causes no gap. One nonzero witness output suffices for the scalar readout lower bound.

## Exchangeable extraction

The identity a_{j+1}-a_j=conditional mutual information follows from exchangeability and the entropy chain rule. The resulting monotonicity bounds the randomized predictive-row KL and the average pair information. Conditional pair Pinsker bounds every off-diagonal covariance of a bounded observable, giving exactly the stated empirical-moment estimate.

Given preceding hidden weights, the current hidden rows remain exchangeable after conditioning on the function event: permuting those rows and the corresponding next-layer columns preserves the raw prior and the event, while future layers have been integrated out. Forward conditional KL therefore applies without an anticipative-conditioning issue. Singular preactivation covariances cause no problem under pushforward/data processing.

The actual readout, conditional on hidden weights under the reference law, has covariance Q_H/N. Hence N z^T Q_H^+ z is chi-square with rank at most m, and the stated exponential moment is s^(-rank/2). Entropy duality gives the displayed projected-action bound. This is the step allowing mixtures of signs in the event; replacing the readout by its conditional mean would not suffice.

The explicit choices of eta, kappa and N bound each term of the moment error by a fixed fraction of eta Delta squared. They also make the action expectation, divided by the good-event probability, at most A+tau. The requirements are polynomial in m,H,A+1,Delta inverse and tau inverse. Every extracted output is the output of the same original realization in E.

## Consistent path and compression

For m-dimensional covariances, the square-root coupling bound is at most m sqrt(Delta), using the trace norm bound by m squared times the maximum entry. Controlled Gaussian transfer preserves or decreases each KL cost and amplifies the coupling error by at most 1+sqrt(2D_j). The approximate entropy lemma therefore bounds the accumulated distortion by exp(C sqrt(L epsilon)) times a polynomial.

Choosing Delta polynomially small in m,L,A and exponentially small only in sqrt(L epsilon) makes the readout discrepancy at most1/16. The resulting consistent path has margin7/16. The anchored-compression proof has absolute output error at most3/32, independently of the starting margin, so it preserves these signs. Alternatively a fixed readout rescaling would permit direct invocation of its margin-one-half statement.

Crucially, the final compressed width depends on the witness only through log m<=d. The polynomial finite-N requirement depends on m, but the architecture width used to represent its restriction does not. This distinction is necessary and is correctly preserved in the theorem.

## Exceptional-mass class

Choose m strictly larger than the VC bound of the compressed fixed architecture. The class of functions whose restriction to every m-set is represented by that architecture has VC dimension below m: otherwise the original architecture would shatter the same set. For each witness Z, an exceptional event of raw mass at least exp(-NA) would contradict witness compression. Unioning these events over at most (2^d)^m witnesses gives exp(dR log2-NA). This is a union over witnesses, not over sign functions.

The case m>2^d is handled by the full Boolean class, whose VC dimension is then below R. The class and all certificate architecture bounds are independent of the training sample and of N. No quantitative lower bound on a target event, and hence no complete finite-width posterior learning theorem by itself, is claimed in these two source files.
