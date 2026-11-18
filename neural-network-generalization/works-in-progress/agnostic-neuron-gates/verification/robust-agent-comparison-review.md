# Independent review of the continuous neuron-gate comparison

Reviewed by the robust-prior agent on 18 November 2026. No substantive gap found in the current `comparison.md`.

Checked the Gamma gate scalar estimates, inactive total-Gamma conditioning, Student interval entropy, and all-width group embedding. Disjointness is used only in the enlarged latent space, where selected gates identify their fixed groups; data processing then bounds actual-weight KL. The location entropy correctly cancels all V log N terms up to V log(2m), including N=m.

Checked the uniform sup-norm L2 recursion. A gate is independent of the feature entering that gate, and incoming row factors are independent of preceding features. The inactive gate sum is bounded deterministically; weighted Cauchy then gives epsilon² times the preceding L2 path bound, without any hidden N factor. Active block bounds include zero teacher edges and all biases. Unselected rows can have O(m) input magnitude, which is included in D. The resulting D^H sensitivity enters only logarithmically in KL.

The comparison precision and K0/K1 substitution support the sharp all-data expected oracle. The teacher coefficient cap enters logarithmically for Student factors; the stated Gaussian-factor alternative has its additional quadratic coefficient cost. This review does not independently rederive the separately cited high-probability PAC-Bayes inequality.

This is a conventional mathematical review, not a Lean verification.
