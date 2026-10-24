# Main-theorem statement audit — 23 October 2026

This review compares the main claims of all fifteen main papers with their Lean theorem statements. It starts from public snapshot `7c69c4abe5f93476d59c95b4d04d13b33ff01301`. Six parallel AI-agent reviews read the manuscript sources and unfolded the formal definitions; the coordinating agent reviewed their findings and made the documentation corrections below. This is a semantic review, not human peer review or an independent reimplementation of the proofs.

The checks cover the actual network and teacher classes, coordinate priors, conditioning events and positive normalizers, training/test distributions, posterior mixtures, error and confidence thresholds, quantifier and limit order, width restrictions, and advertised numerical budgets. Matching a proof to a Lean proposition is a separate question from whether that proposition expresses the manuscript claim.

## Findings and corrections

The reviewed main statements match their intended models subject to the following explicit qualifications. No additional assumed analytic premise or substituted learner was found.

1. **The original robust and improved original-support theorems use a narrower circuit-width convention in Lean.** `LayeredBooleanCircuit` reserves a counted constant-`+1` wire at every stage, including the final stage. Width-one targets other than constant `+1` under the papers' prose convention need formal width two. Consequently those learner-width-one cases are not certified. The original paper already acknowledged this in its introduction; the FAQ, collection/leaf READMEs, coverage record, and improved paper's status paragraph now state it too. The formal width guarantee and polynomial exponents remain as proved.
2. **The ReLU/GELU polynomial-depth manuscript needed an explicit constant-wire requirement.** Its earlier phrase “constant wires count” did not require a reserved constant at every stage. A broader reading would allow a one-wire literal teacher and a width-one ReLU learner. That learner's output has one weak sign everywhere, so it cannot fit both labels with strict signed margins. The manuscript now explicitly requires the counted constant-one wire at every stage, including the final stage, matching `LayeredNorCircuit`. For an ordinary width-`C₀` circuit without it, the stated construction uses width `C₀+1` for ReLU and `2(C₀+1)` for GELU. The Lean theorem already had the necessary assumption; no Lean source changed.
3. **Previously recorded coverage exclusions remain.** In particular, the improved original-support paper's sixth-power width rate and degree-46 envelope are proved, but its separate printed numerical `16/ε` allocation is not. The prefix-circuit converse proves its abstract syntax, code lengths and Kraft bound, without a bitstring serializer/parser. Optional extensions and ancillary continuous-limit/classification claims are not all included. See the [complete second-batch coverage table](../BatchTwo-coverage.md).

No other substantive mismatch was found in the reviewed main statements. This finding does not certify every assertion or informal proof in the papers.

## Paper-by-paper review

| Main paper | Finding | Detailed review |
|---|---|---|
| Original 1: strong-prior generalization | Matches, including the scale threshold's dependencies | [Original positive results](original-positive.md) |
| Original 2: every fixed `γ>1`, all eligible widths | Matches the actual finite prior and sample bound | [Original positive results](original-positive.md) |
| Original 3: mean field, all eligible widths | Matches, including strict-confidence failure and full mixtures | [Original positive results](original-positive.md) |
| Original 4: subcritical exponential lower bound | Matches, including common constants over all `γ<1` and width-first limit | [Original lower bound and robustness](original-lower-robust.md) |
| Original 5: polynomial depth under internal-noise stability | Matches for the formal reserved-constant circuit class; width-one qualification above | [Original lower bound and robustness](original-lower-robust.md) |
| Second 1: Lipschitz activations, including ReLU/GELU | Matches the strong-prior and uniform-scale formulas and existential endpoint polynomials | [Activations](activations.md) |
| Second 2: polynomial-depth ReLU/GELU | Matches after the manuscript's constant-wire convention is made explicit | [Activations](activations.md) |
| Second 3: improved original-support polynomial | Matches for the formal circuit class and certified budgets; width-one and numerical exclusions above | [Polynomials and online learning](polynomials-online.md) |
| Second 4: one hidden layer | All three boxed formulas match | [Polynomials and online learning](polynomials-online.md) |
| Second 5: total online mistakes | Core and three neural regimes match; exact small-width bounds have separate endpoints | [Polynomials and online learning](polynomials-online.md) |
| Second 6: circuit-induction converses | Matches actual circuits, priors and sampled mistakes; abstract-code qualification above | [Converses](converses.md) |
| Second 7: polynomial-depth neural converse | Matches gain support, output cap, exact ceiling and iterated-limit order | [Converses](converses.md) |
| Second 8: non-Gaussian priors | Both main statements match the actual independent coordinate law | [Priors and continuous domains](priors-continuous.md) |
| Second 9: continuous input regression | Both main statements match actual tolerance conditioning and teacher/domain assumptions | [Priors and continuous domains](priors-continuous.md) |
| Second 10: continuous-regression depth lower bound | All three main regimes match, including fixed input law and critical strict-confidence threshold | [Priors and continuous domains](priors-continuous.md) |

## Machine checks and source identity

All **1,313** source/configuration files in the published verification manifest were checked against both the public-source worktree and the previous fresh-build directory: no differences. No Lean mathematical source was edited during this audit.

The following checks were rerun using that hash-matched build and the pinned Lean 4.32.0 toolchain:

| Check | Result |
|---|---|
| `lake env lean Audit.lean` | Pass: 14,578 proved project declarations, only `propext`, `Classical.choice`, `Quot.sound` |
| `lake env lean CheckMain.lean` | Pass: four original exact proposition types |
| `lake env lean CheckRobust.lean` | Pass: original robust exact proposition type |
| `lake env lean CheckConfidence.lean` | Pass: strict-confidence corollaries |
| `lake env lean CheckParity.lean` | Pass: parity implementation/lower-bound supplement |
| `lake env lean NeuralGeneralization/BatchTwoAudit.lean` | Pass: second-batch main endpoint axiom closures |

The [machine record](kernel-recheck.json) and adjacent text outputs record the coordinating checks. The [original-positive review](original-positive.md#proof-boundary-and-machine-recheck) records the additional type/confidence reruns. These use the earlier checked artifacts; this is **not a new fresh-source rebuild**. The [earlier fresh build](../verification/batch-two-2026-10-23/README.md) remains the source-build evidence.

The revised ReLU/GELU and improved original-support PDFs were rebuilt, and isolated rebuilds were compared with their published PDF text. The [document-build record](document-checks.json) records these checks. Documentation hashes and the collection catalog were refreshed. The FAQ now distinguishes the sharper verified bounds from still-unformalized auxiliary results.
