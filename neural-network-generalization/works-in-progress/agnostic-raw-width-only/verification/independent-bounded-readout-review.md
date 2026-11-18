# Independent bounded-readout endpoint review — 18 November 2026

Reviewer: agnostic_proof_audit. Result: passes for the exact source in the adjacent manifest.

The readout prior has genuine bounded parameter support: v_j=P_j U_j, U_j and the bias uniform on [-1,1], so every raw function lies in [-2,2]. It is correctly identified as a different prior from the unrestricted-support principal model. No output activation is needed, but the support restriction is substantive.

I checked the final t-bit affine encoding. Its raw coefficient variation plus bias is exactly one, it remains within [-1,1] for approximate signed bits, and the stated rounding error is correct. Constant-depth integer division supplies this encoding with the existing compiler overhead. The selected Dirichlet latent centers sum to one, have minimum 2^-t/t, and leave every selected uniform-factor center a margin of at least 2^-t/t from the boundary. Relative gate precision and absolute factor precision give total coefficient error O(eta). Inactive gate mass O(eta) controls its output deterministically.

The gate entropy is log N per selected location plus logarithmic precision and the stated small-center term. Summing the latter costs O(t+log(t+1)) since N>=t. Disjoint locations cancel the log N costs as in the existing hidden comparison construction. The additional t-polynomial logarithmic costs fit the existing stable resource. The population comparison risk transfer uses bounded conditional mean and bounded comparison outputs; clipping the proof comparator cannot increase risk. Temperature 1024(1+sigma^2) safely implies the bounded-prediction leave-one-out temperature requirement at range [-2,2].

The resulting coefficient-one expected all-data oracle and C_n=n^(1/(4bh)), H<=n^(1/2), N>=n substitution are correct. The existing compiled-width and lower-depth requirements remain in force. This review does not extend the claim to unbounded conditional means, unrestricted readout support, or a coefficient-one high-probability theorem.
