# Independent training-vector concentration review

18 November 2026 — agnostic_proof_audit.

PR4 passes as an exact consequence of PR2. The compact symmetric unit-ridge dictionary induces a genuine norm on the linear span of its training evaluation vectors: bounded atoms ensure positive mass for any nonzero vector. The empirical squared loss is strictly convex on that span, so the penalized optimum has a unique training vector. Relative-subspace subgradient optimality and the quadratic expansion give objective excess at least ||b-b*||²/n, with exactly the stated coefficient. Every actual posterior amplitude representation has mass at least the minimum mass of its training vector. Integrating PR2 and applying Jensen proves both assertions. This concerns training predictions only and makes no test-risk claim.
