# Non-Gaussian controls companion: verification

The [12-page companion](../../non-gaussian-controls.pdf) has a [complete independent manuscript audit](fixed-rank-entropy-companion-independent-audit.md) at the exact hash of [its source](../../source/non-gaussian-controls.tex). This is conventional AI-agent mathematical checking, **not Lean verification or human peer review**.

The audit covers the fixed-rank arbitrary-entropy blocks, arbitrary Gaussian controls, bounded-entrywise-norm quadratic tanh tilts, scalar Poisson factories, continuous-coordinate projections, separate norm oracle, physical normalization and polynomial-bit completion. It does not establish a compiler for arbitrary conditional posterior row laws or bounds on all backward costates.

Supporting component checks are included alongside it. Earlier snapshot hashes refer to the mathematical notes before later status links or organizational summaries. The final manuscript audit matches the source packaged here, renamed from its scratch `paper.tex` to `non-gaussian-controls.tex` without changing its contents.

The [build manifest](build-manifest.json) records an isolated clean build, exact source/PDF hashes and page count. The [compiler log](clean-build.log) has no LaTeX warnings or overfull/underfull boxes. The title/abstract page was visually inspected.

[Detailed derivations](../../research-notes/non-gaussian-controls/README.md) preserve the supporting proofs and explicitly marked intermediate limitations. The companion PDF is the current presentation.

The [normalized ridge-difference audit](normalized-ridge-difference-tilt-compiler-audit.md) checks the additional representation theorem, weighted component entropy and squared-entropy bounds, common isometry, and physical scaling. The full manuscript audit includes the assembled theorem and proof.
