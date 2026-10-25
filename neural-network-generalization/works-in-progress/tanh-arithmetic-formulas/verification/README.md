# Verification record

This is a conventionally checked research paper. The Fourier–Poisson estimator, finite-bit arithmetic compiler, and Bayesian PNC¹ converse have **not** been formalized in Lean.

- [Independent analytic and finite-bit audit](fourier-poisson-independent-audit.md): checks the estimator, work–second-moment recurrence, finite-cube selection, precision, complex-formula balancing, and primary complexity references. This audit was written against the research derivations before their assembly into the paper; those arguments now appear in the main source and its included appendices.
- [Independent posterior audit](fourier-posterior-independent-audit.md): checks the assembled posterior section, including the finite-scale quantifiers, cold limit, two majorities, and conditional complexity collapse. A second agent independently agreed with this audit.
- [Independent normal-form audit](fourier-normal-form-independent-audit.md): checks the included ordinary-tanh normal form, its use of the earlier width-compression theorem on a prefix, charged constant rails, classifier margins, physical-weight bounds, and finite precision. An explicit affine case was added in response to this review.
- The new Bayesian consequence imports the existing posterior representation ceiling explicitly. Its proof must keep the width and scale fixed before the input distribution and must handle posterior mixtures. The paper uses two majority reductions to cover every confidence-failure tolerance below `1/2`.
- The arithmetic complexity facts were checked against the primary Datta–Mahajan–Raghavendra Rao–Thomas–Vollmer paper, including the exact gate convention, Proposition 2.4, and Theorems 4.1–4.2.
- The ordinary-tanh normal-form appendices are included in full. Replacing their activation class by arbitrary lookup functions would not justify applying the tanh estimator.

The [dependency manifest](../DEPENDENCIES.json) records exact source hashes for imported repository results. The [publication check](publication-check.json) records the compiled manuscript and the scope of the checks; it is not a machine-checked proof certificate.
