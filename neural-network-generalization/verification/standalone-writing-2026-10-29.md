# Standalone writing review, 29 October 2026

The sixteen papers with formalized main results have been revised for readers who have not read this repository or the research conversation. The review also covers two supporting papers with component-level Lean coverage and the Boolean-depth paper's companion note. All nineteen PDFs were rebuilt. The mathematics and all Lean sources are unchanged.

[Source hashes, block comparisons, and isolated build results](standalone-writing-2026-10-29.json) · [Formal coverage of the original five and second ten](../lean/VERIFICATION.md) · [Conditional-impossibility proof and scope](../works-in-progress/conditional-nonpolynomial-learning/verification/)

## What changed

The paper-first reviewers received no conversation history. They read each assigned manuscript before consulting the repository's coverage records, recorded places that needed outside context, and then revised the prose. Further reviews compared the new explanations with the unchanged statements and their formal definitions.

The main changes are:

- Define the learner and prediction criterion before stating the contribution. In the conditional-impossibility abstract, “the original Gaussian tanh Bayesian learner” is replaced by the actual Gaussian variances, margin conditioning, and greater-than-two-thirds confidence criterion. Teacher complexity explicitly bounds both width and weight magnitude.
- Replace unexplained references such as “the supplied draft,” “this repair,” and “the original convention” with local definitions or an identified citation.
- Introduce regime names, complexity measures, risk notation, and technical terms before relying on them. Distinguish teacher and learner width, the two uses of depth, and the relevant orders of limits.
- Add proof roadmaps and explanations of what the principal estimates accomplish. Imported results are identified and stated with their needed assumptions; a standalone presentation does not claim to reproduce every cited technical proof.
- Make formalization scope readable within each paper, retaining the existing exclusions. A component-level proof, an uncertified numerical allocation, or a supplementary corollary does not acquire a broader verification claim through this revision.

Cross-review corrected two imprecise new explanations before publication: a reproducing-kernel approximation was initially described as exact, and an invariant scalar distribution needed to be distinguished from its image on the circle. The robustness paper's empirical appendix also now explains the saved matrices' row-vector convention and states that the longer training run used 240 **additional** epochs. These clarifications were checked against the saved training code and predeclared protocol; numerical claims are unchanged.

## Theorem correspondence safeguards

The comparison baseline is commit [`aea438eb`](https://github.com/kaarelh/AI-works/commit/aea438eb7f2ed833d0bc7d953b02b0dcf5c67f1f). Across the 89 LaTeX source files reviewed:

- All **1,907 tracked Lean source files** are byte-identical to the baseline. No formal definitions, statements, proofs, or axiom dependencies changed.
- All **254 proof environments** and **1,394 displayed-math blocks** are unchanged after ignoring TeX comments and whitespace.
- Of **279 named statement environments**, 277 are unchanged under the same comparison. Two have only nominal edits in the conditional-impossibility paper: “the original learner” now refers explicitly to the model section, and “Established analytic ceiling” is renamed “Posterior circuit ceiling,” with “original” removed from the equation-referenced posterior. Their hypotheses, quantifiers, and conclusions are unchanged.
- Reviews of the explanatory additions checked the actual prior, confidence threshold, target-complexity convention, width quantifier, input distribution, and limiting order against the existing statement audits and relevant Lean definitions.

The conditional-impossibility abstract and model received an additional paper-only reading and a comparison with `NNBayesStatement.lean` and the closed theorem. Its verification paragraph now specifies that the formal analytic bound covers the realizable-target, specified-sample-length instances needed for the reduction at exceptional mass `1/6`. It does not imply formalization of the stronger every-probability-level or fixed-hard-family statements.

Existing Lean builds continue to certify the unchanged sources. This editorial revision did **not** rerun those mathematical builds or enlarge their coverage. The source and PDF hashes in older build records describe their earlier manuscript snapshots; the linked JSON gives the revised manuscripts' hashes.

## Papers reviewed and rebuilt

The first sixteen rows have formalized main statements, subject to the linked coverage records. The last two have only component-level coverage.

| Paper | PDF pages |
|---|---:|
| [Strong-prior generalization](../main-results/strong-prior-generalization/paper.pdf) | 14 |
| [Above mean-field scaling](../main-results/gamma-above-one/paper.pdf) | 13 |
| [Mean-field learning at every eligible width](../main-results/meanfield-all-width/paper.pdf) | 13 |
| [Subcritical exponential parity lower bound](../main-results/subcritical-exponential/paper.pdf) | 26 |
| [Polynomial-depth learning with a robust prior](../main-results/robust-polynomial-depth/paper.pdf) | 52 |
| [ReLU, GELU, and general Lipschitz activations](../works-in-progress/unbounded-activations/paper.pdf) | 20 |
| [Polynomial-depth ReLU/GELU learning](../works-in-progress/relu-gelu-polynomial-depth/paper.pdf) | 8 |
| [Improved original-support bounds at all scales](../works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) | 14 |
| [Sharper one-hidden-layer bounds](../works-in-progress/improved-polynomials/shallow/paper.pdf) | 8 |
| [Total online mistakes](../works-in-progress/online-mistakes/upper/paper.pdf) | 10 |
| [Circuit-induction converses](../works-in-progress/online-mistakes/circuit-converse/paper.pdf) | 8 |
| [Polynomial-depth neural converse](../works-in-progress/online-mistakes/depth-polynomial-converse/paper.pdf) | 9 |
| [Non-Gaussian priors](../side-results/non-gaussian-priors/paper.pdf) | 22 |
| [Continuous-domain learning](../side-results/continuous-domains/paper.pdf) | 16 |
| [Exponential depth dependence in regression](../works-in-progress/continuous-depth-lower-bound/paper.pdf) | 17 |
| [Conditional nonpolynomial learning](../works-in-progress/conditional-nonpolynomial-learning/paper.pdf) | 12 |
| [Standard-scaling NNGP parity](../side-results/standard-nngp-parity/paper.pdf), coercivity component only | 35 |
| [Boolean-depth barriers](../works-in-progress/boolean-depth-barriers/paper.pdf), specified analytic components only | 46 |

The last paper's [uniform-scale target-class companion](../works-in-progress/boolean-depth-barriers/uniform-target-classes.pdf), 6 pages, was also revised and rebuilt. Its broader claims remain outside the component-only formalization.

## PDF and publication checks

Each paper was built using its packaged `build.sh`, then rebuilt in an isolated directory containing only its tracked source dependencies and build script. Extracted PDF text matches in every case, including the companion. Final logs contain no unresolved references, LaTeX warnings, or overfull boxes. Four papers retain underfull bibliography-box diagnostics, recorded in the JSON. First-page visual checks found no layout problems.

The catalog, source/PDF checksums, and index links were updated. This is a writing and correspondence review by AI agents, not external human peer review or a new proof of claims outside the existing formal coverage.
