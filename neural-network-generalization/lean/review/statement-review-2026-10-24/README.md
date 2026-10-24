# Independent main-statement review and rebuild — 24 October 2026

This review asks whether each Lean main theorem statement captures the main theorem of its paper. It covers all fifteen formalized main results, the original five and the ten of the second batch, at public snapshot `a59cbb3f`. It was carried out independently of the [23 October statement audit](../statement-audit-2026-10-23/README.md); reviewers formed their own judgment before reading it. These are AI-agent reviews, not human peer review.

**Result: every main statement matches its paper's main theorem.** No reviewer or red-team agent found a statement that is vacuous, trivially provable, about a different object, or materially weaker than the paper. The findings are documentation overstatements and record-keeping issues, listed below; the overstatements are corrected.

## Method

Twelve reviewers each took one paper, or two closely related papers. Each read the main theorems in the LaTeX source, then unfolded every definition in the Lean endpoint down to Mathlib primitives. They compared the network, activation, prior and scales, conditioning events and normalizers, sample law, posterior, error and confidence criteria, quantifier and limit order, constants, and target classes clause by clause. They also hunted for junk-value loopholes: natural subtraction, `x/0 = 0`, `log 0 = 0`, a zero posterior when the normalizer vanishes, the liminf of an unbounded sequence, `toReal` of infinity, an unsatisfiable sample-size hypothesis, misplaced existentials, and a single minimizer in place of the full posterior mixture. A verification stage was set to re-check every critical or major finding; none was reported. Three red-team agents then tried to break the fifteen statements directly, by trivial proofs or deviant readings, and none succeeded.

## Verdicts

| Paper | Lean endpoint(s) | Verdict |
|---|---|---|
| Original 1: strong-prior limit | `MainStatements.StrongPriorGeneralization` | Matches (σ₀ after `N, ε`, before `D, δ, n`; denominators positive for every sample) |
| Original 2: fixed `γ>1` | `MainStatements.AboveMeanFieldGeneralization` | Matches |
| Original 3: mean field | `MainStatements.MeanFieldGeneralization` | Matches, including strict `>2/3` and full mixtures |
| Original 4: subcritical lower bound | `MainStatements.SubcriticalExponentialLowerBound` | Matches (constants before `γ`; liminf over width of a `[0,1]`-valued sequence) |
| Original 5: polynomial depth, robust | `RobustMainStatements.RobustPolynomialDepthGeneralization` | Matches for the reserved-constant circuit class (width-one qualification disclosed) |
| ReLU, GELU, Lipschitz activations | `BatchTwoActivation.strong_prior_manuscript_learning`, `uniform_manuscript_learning`, GELU compiler | Matches; the endpoint polynomial is existential as in the paper (coverage wording corrected) |
| Polynomial-depth ReLU/GELU | `BatchTwoMerging.manuscript_relu_learning`, `manuscript_gelu_learning`, `quadratic_polynomial_depth_*` | Matches |
| Improved original-support bounds | `BatchTwoImprovedLearning.*`, `BatchTwoImprovedGlobalLearning.*` | Matches; `16/ε` allocation excluded as disclosed |
| One hidden layer | `BatchTwoShallow.shallow_*_all_width_all_scale` | The three explicit budgets match; the Õ summary is not formalized (now stated) |
| Total online mistakes | `BatchTwoOnlineSharp.*_online_paper`, generic theorems | Matches for cumulative and sampled errors; majority/confidence conversions are generic lemmas only (now stated) |
| Circuit-induction converses | deterministic, geometric and prefix IID converses | Matches; prefix code is abstract syntax (disclosed) |
| Polynomial-depth neural converse | `BatchTwoNeuralConverse.polynomial_depth_mistake_converse` and corollaries | Matches |
| Non-Gaussian priors | `BatchTwoNonGaussian.strongPrior`, `finiteScale` | Matches (coverage wording of the coordinate law corrected) |
| Continuous domains | `BatchTwoContinuous.strongPriorRegression`, `finiteScaleRegression` | Matches; covers the Gaussian as `m=M=1` (coverage wording corrected) |
| Continuous-regression depth lower bound | strong, finite-`γ` and critical endpoints | Matches |

## Kernel recheck

The full project was rebuilt from the current sources with the pinned Lean 4.32.0 and the existing mathlib build at revision `81a5d257…`; mathlib itself was not rebuilt. The build completed with 4,617 jobs and no errors. `Audit.lean` (14,578 proved project declarations, standard axioms only), `CheckMain.lean`, `CheckRobust.lean`, `CheckParity.lean` and `CheckConfidence.lean` all pass. The 69 axiom reports of the batch-two audits list only `propext`, `Classical.choice` and `Quot.sound`. The global-margin `C⁶ log¹³` corollary, which the entry point does not import, was built separately and also uses only these axioms. Outputs: [rebuild.json](rebuild.json) and the `gate-*.txt` files.

## Corrected overstatements

These documentation corrections were made; no Lean source changed.

- **Coverage table, activations:** the printed `B(J_*)` formula holds with an existential endpoint polynomial that the proof enlarges, so the certified content is a polynomial bound depending only on depth and the Lipschitz constant. The reconstruction-energy witness is not part of that chain. The GELU consequence "teacher complexity at most `max{4,2C}`", the `>2/3` confidence remark and the every-`γ≥1` reparametrization are not stated as Lean theorems.
- **Coverage table, one hidden layer:** the Õ summary in `κ_C` and the sharpened budget's quadratic-up-to-logarithms consequence are not formalized; the width corollaries concern the first budget.
- **Coverage table, online mistakes:** the majority and confidence conversions are generic lemmas, not instantiated for the neural endpoints, and there is no infinite-IID majority statement. The nonuniform extension, the order counterexamples, and the merging extension beyond its specific support are outside certification.
- **Coverage table, improved bounds:** the appendix compressor is certified in the form the main theorem uses. The global-margin `C⁶ log¹³` corollary is outside the entry point.
- **Coverage table, non-Gaussian and continuous rows:** the coordinate law is stated exactly, and the continuous theorems cover the Gaussian prior.
- **Measurability:** the continuous-regression and critical depth endpoints bound sample events whose measurability is not proved in Lean. The events are measurable, so the statements are not weakened.
- **Collection README:** the strong-prior manuscript states no confidence guarantee; `CheckConfidence.lean` proves one as a corollary. The non-Gaussian summary now gives both curvature bounds. The online-mistakes row now says which statements Lean certifies.
- **FAQ:** "the shallow bounds" are the three explicit budgets, not the Õ summary.
- **Papers:** the robust paper's list of width-one exceptions now includes negated first-stage gates. The improved original-support paper no longer says the compressor is certified in full generality. Both PDFs were rebuilt; the theorem and proof text is unchanged.
- **Records:** the activation status record no longer says the compiler proves the whole GELU proposition. The continuous-depth status record no longer says the mean-field endpoint is outstanding. The depth paper's README marks exact interpolation as not formalized. `lean/README.md` marks the circuit-convention equivalence for `C ≥ 2` as an informal argument.

## Not changed

- **Lean docstrings.** `CheckConfidence.lean` attributes a `>2/3` guarantee to the strong-prior manuscript, and the mean-field docstrings cite "Theorem 1.1" for the printed Theorem 2.1. Changing them would alter verified sources, so they are recorded here instead.
- **Historical records.** Some older records carry stale source hashes, or remarks about earlier manuscript versions: `meanfield-semantic-review.txt`, `source-manifest.json`, the non-Gaussian theorem map, and the above-mean-field remark in `formal-coverage-inventory.txt`. The 23 October audit and this review cover the current text.
- **Small unformalized steps.** The one-line corollaries listed above, Lemma 3 of the ReLU/GELU paper at margin `1` (the theorems need only margin `1/2`), and the mean-field paper's activation remark are not Lean statements. None is claimed as one.
