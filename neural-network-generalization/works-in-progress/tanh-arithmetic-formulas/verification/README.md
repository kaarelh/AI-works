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

## Fourier-increment activation extension

The [assembled appendix audit](fourier-increment-low-product-compiler-independent-audit.md) checks the extension to normalized erf, arctan, softsign, and the stated Fourier class. It covers the generic width-compression changes, mixed activation normal form, deterministic spectral approximation, internal scale bounds, and polynomial-bit arithmetic circuits. The [research derivation](../research-notes/fourier-increment-low-product-compiler.md) records the development. This structural extension does not import a new posterior ceiling or resolve the critical conditional-tilt problem.

## Quadratic Gaussian variance occupation

The [four-page note](../gaussian-quadratic-occupation.pdf) has an [independent proof-note audit](gaussian-fock-quadratic-occupation-nongaussian-audit.md) and an [independent final assembled audit](gaussian-fock-quadratic-occupation-assembled-audit.md). The latter checks exact TeX SHA256 `2a860b2edca3c62a6b082534452845db5a590b568ade1e854dac020831c77137`, preserved byte-for-byte in `source/gaussian-quadratic-occupation.tex`. The [assembly record](gaussian-fock-quadratic-occupation-manuscript-assembly.md) describes the derivation and its scratch build; the [publication build manifest](gaussian-quadratic-occupation-build.json) records the packaged PDF and source hashes.

The result concerns equal-diagonal Gaussian Fock maps in compatible coordinate bases and exact real-coefficient formulas. The free near-critical `δ²H` scale is a feature/readout representation statement. No variable-diagonal improvement, finite-bit theorem, or original posterior learning guarantee is asserted. These are conventional mathematical checks, not Lean verification.

## Critical internal-control research notes

The [scoped audit guide](critical-internal-controls/README.md) covers the new signed-alignment, first-crossing, and bounded-density finite-chaos notes. The first two allow arbitrary finite-entropy internal controls; the local scalar construction has a bounded-density hypothesis and explicit approximation limits. The [manifest](critical-internal-controls/manifest.json) identifies the final checked snapshots. These notes are not Lean verified and do not claim that their separate conclusions already compose into a general critical-posterior theorem.

The separate [centered variable-diagonal follow-up](../research-notes/gaussian-diagonal-defect-quadratic-occupation.md) has an [independent final audit](gaussian-diagonal-defect-quadratic-occupation-independent-audit.md). It checks the strict diagonal-ratio telescope, normalized defect oracle, weighted coefficient estimates, convex-mixture control update, and condition-number charge. Its conclusion concerns exact real formulas for centered compatible Gaussian controls; it does not add a finite-bit or posterior theorem.

The [universal scalar-occupation audit](universal-quadratic-variance-and-diagonal-occupation-audit.md) checks entropy-to-relative-variance comparison, quadratic maximum-variance occupation, and logarithmic diagonal-spread control for arbitrary row laws. Its conclusions are scalar inequalities, not an extension of the Gaussian feature compiler.
