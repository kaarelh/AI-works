# Second independent audit: finite-width witness certificates

Reviewed by the critical-depth agent, 2026-10-19.

Source: `source/critical-finite-width-certificate.tex`.

SHA256: `6d7f660e55bf4619224f6e9ddb2e3d312b8d60df57bbfca2fb64f9ac040b48e6`.

The full source passes this review, including the representation theorem and exceptional-mass corollary. Checks:

- Forward conditional row exchangeability is valid because the hidden-row permutation is paired with a permutation of columns in the next, still-integrated block. No backward conditional reference covariance is substituted.
- Exchangeability identifies the entropy increments with conditional pair information. The observable covariance/Pinsker estimate and averaging over a random short prefix give the displayed moment error, including the square-root dependence on total entropy.
- The actual readout, rather than its conditional mean, is used. Its projected reference energy has chi-square rank at most m even for a singular empirical covariance. The entropy estimate therefore loses only m log(1/eta)/N, not a width-independent baseline term. This is essential when the event includes multiple sign patterns.
- The explicit choices of eta, kappa and N make the covariance good event have probability at least 1-eta; selecting a realization inside it incurs the stated additional 1/(1-eta) factor, absorbed in the additive tau budget.
- With tau=1/(10L), the approximate covariance entropy lemma gives S<=C[log(L+1)+sqrt(L epsilon+1)] when Delta<=c/L^4. All assumptions use recorded empirical kernels and the actual recorded readout, as required.
- The square-root trace inequality gives a valid common Gaussian coupling, including singular kernels. The looser bound m sqrt(Delta) is adequate. Coupling transfer and triangle inequality produce the stated recurrence; layer entropy cannot increase under transfer.
- The readout transfer error is at most sqrt(2r)e_H. A tolerance inverse-polynomial in m,d,L,A+2 and exponential only in C sqrt(L epsilon) makes the error at most 1/16. The original margin 1/2 becomes at least 7/16.
- The anchored theorem is a representation result for arbitrary controlled outputs; it does not need the intermediate output to retain margin 1/2. Its additional 3/32 approximation preserves the signs. Its finite-set union bound is bounded by d since m<=2^d.
- The exceptional class is defined by representability of every m-input restriction. It has VC dimension below m without requiring one common representing network for all restrictions. The bad witness event is neuron-permutation invariant. A union bound over all witnesses contributes at most d m log 2, exactly as claimed.

No correction is requested. The source does not yet provide the target probability lower bound needed to turn exceptional-mass control into the proposed uniform finite-width posterior theorem; that is correctly separate work.
