# Verification of the ordinary-tanh online lower bound

**The improved main theorem and its finite-scale prediction consequences are Lean verified.** The theorem concerns the actual independent Gaussian tanh-network posterior, with the initial strict output margin on the full Boolean cube and subsequent conditioning on the observed signs and margins. Its proof has no analytic certificate assumptions, admitted steps, or added axioms. The transitive axiom checks report only `propext`, `Classical.choice`, and `Quot.sound`.

- [Main proof](../../../../lean/NeuralGeneralization/OnlineLowerTanhMain.lean)
- [Concrete statement, resources, and finite-scale consequences](../../../../lean/NeuralGeneralization/OnlineLowerTanhConcreteStatement.lean)
- [Exact theorem-type and axiom checks](../../../../lean/CheckOnlineLowerTanh.lean)
- [Paper-to-Lean correspondence](../../../../lean/review/OnlineLowerTanh-main-correspondence.md)
- [Independent global analytic review](../../../../lean/review/OnlineLowerTanh-global-independent-audit.md)
- [Independent full-statement review](../../../../lean/review/OnlineLowerTanh-independent-statement-audit.md)

## Statement and coverage

The exact construction has `m=6k+6`, `d=Θ(k log² k)`, a same-depth teacher of width `C=O(k² log² k)`, and exactly `2^(k−1)` designated rounds. The teacher has margin at least one and all coefficients bounded by `C`; the target also has a NAND circuit with at most `17d+5` gates. The resulting mistake count is `exp(Ω(√C/log(C+2)))`. Here `C` is the width of the displayed teacher, not an asserted minimum width.

One fixed full-cube input permutation works for every sufficiently large fixed finite learner width. The Gaussian scale then tends to zero at that fixed width. The correct-label posterior probability tends to zero at every designated round. At sufficiently small positive scale, every designated majority prediction is wrong, correct-label confidence is below `1/3`, and fresh independent posterior sampling gives all designated errors simultaneously with probability arbitrarily close to one. Posterior normalizers are proved positive for every positive scale and every round.

The calibration prefix can be large. The sufficient construction-index and learner-width thresholds are existential; no scale threshold uniform over all learner widths is claimed. This is an adversarial-order lower bound, not an IID sample-complexity lower bound.

The formal proof includes the global single-parity estimate for every real incoming vector; affine support bounds with arbitrary bias and irrelevant coordinates; physical code localization; actual optimized tanh costs and their strict path ordering; calibration and rounding for arbitrary real network outputs; bounded teacher and circuit constructions; integer neuron allocation at every sufficiently large width; and the Gaussian posterior comparison. Intermediate certificates are instantiated with proved constructions before the main theorem is exported.

The proof need not follow the manuscript line by line. In particular, the formal scalar proof uses high-order derivative bounds and mixed differences of the actual optimized cost in place of the paper's inverse-Laplace presentation. The main theorem and its resources are unchanged. Verification of that theorem does **not** mean every stronger standalone appendix equality or uniqueness claim has a separately exported Lean statement; the unused first-derivative residual CLT is likewise outside that separate-statement claim.

## Reproduction

From `neural-network-generalization/lean`, using its pinned Lean 4.32.0 and mathlib versions:

```sh
lake build NeuralGeneralization.OnlineLowerTanhMain
lake env lean CheckOnlineLowerTanh.lean
```

The check file assigns each proof to its exact public proposition and prints its transitive axioms. The [main correspondence record](../../../../lean/review/OnlineLowerTanh-main-correspondence.md) records the checked build and source closure.

From this paper's folder, `bash build.sh` rebuilds the PDF and reruns the [exact rational curvature certificate](certify_curvature.py). That independent certificate remains useful for the conventional proof; the Lean proof does not trust an external numerical computation. The [build record](build-record.json) records the source and PDF hashes and the PDF checks.
