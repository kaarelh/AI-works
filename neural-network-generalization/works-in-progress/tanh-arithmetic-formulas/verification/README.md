# Verification record

This is a conventionally checked research paper. The Fourier–Poisson estimator, finite-bit arithmetic compiler, and Bayesian PNC¹ converse have **not** been formalized in Lean.

- [Independent analytic and finite-bit audit](fourier-poisson-independent-audit.md): checks the estimator, work–second-moment recurrence, finite-cube selection, precision, complex-formula balancing, and primary complexity references. This audit was written against the research derivations before their assembly into the paper; those arguments now appear in the main source and its included appendices.
- [Independent posterior audit](fourier-posterior-independent-audit.md): checks the assembled posterior section, including the finite-scale quantifiers, cold limit, two majorities, and conditional complexity collapse. A second agent independently agreed with this audit.
- [Independent normal-form audit](fourier-normal-form-independent-audit.md): checks the included ordinary-tanh normal form, its use of the earlier width-compression theorem on a prefix, charged constant rails, classifier margins, physical-weight bounds, and finite precision. An explicit affine case was added in response to this review.
- The new Bayesian consequence imports the existing posterior representation ceiling explicitly. Its proof must keep the width and scale fixed before the input distribution and must handle posterior mixtures. The paper uses two majority reductions to cover every confidence-failure tolerance below `1/2`.
- The arithmetic complexity facts were checked against the primary Datta–Mahajan–Raghavendra Rao–Thomas–Vollmer paper, including the exact gate convention, Proposition 2.4, and Theorems 4.1–4.2.
- The ordinary-tanh normal-form appendices are included in full. Replacing their activation class by arbitrary lookup functions would not justify applying the tanh estimator.

The [dependency manifest](../DEPENDENCIES.json) records exact source hashes for imported repository results. The [publication check](publication-check.json) records the compiled manuscript and the scope of the checks; it is not a machine-checked proof certificate.

The separate [online converse note](../research-notes/online-depth-independent-circuit-converse.md) has an [independent conventional audit](online-depth-independent-circuit-converse-audit.md). It uses a distribution-universal total-mistake hypothesis; it is not part of the PDF or a Lean formalization.

## Gaussian-controls companion

The [Gaussian-controls companion](../gaussian-controls.pdf) has two independent final manuscript checks: the [occupation and scope audit](gaussian-control-manuscript-occupation-audit.md) and the [finite-bit and assembled-path audit](noncentral-gaussian-and-manuscript-finite-n-audit.md). Their final entries both review TeX SHA256 `2ecc9d221a6da039d426375eee70feb3a0a900a8cef51941fb3f25f52a34bd1b`, which is preserved exactly in the published source despite its filename changing to `source/gaussian-controls.tex`.

The [strict Gaussian-baseline gap audit](gaussian-scalar-baseline-gap-independent-audit.md) separately checks why `V_*^G > V_*`, the Gaussian class's own Bellman and occupation estimates, and its inverse-depth lower bound. The final manuscript reviews additionally check attainability from the actual augmented Boolean input. Earlier entries in these audit records describe intermediate snapshots; the final entries supersede their old unrestricted-baseline interpretation.

The [proof-note guide](../research-notes/gaussian-controls-guide.md) maps the component proofs to their audits. The [companion build record](gaussian-controls-build.json) identifies its exact source, PDF, proof-note snapshots, and imported target-component construction. No Gaussian replacement theorem for the original posterior is claimed, and none of these companion results is Lean verified.

A [fresh independent challenge audit](independent-pnc1-challenge.md) reconstructed the main paper without relying on earlier verdicts and found no substantive gap. It includes an independent direct rational construction for the constant-gap majority step. This is an additional conventional mathematical check, not Lean verification.

The [non-Gaussian controls companion](../non-gaussian-controls.pdf) has its own [complete manuscript and component audit record](non-gaussian-controls/README.md). It covers specified controlled feature paths, including arbitrary Gaussian layers, and does not establish the full critical-posterior converse. It is not Lean verified.
