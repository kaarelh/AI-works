# Approximation research: proof reviews and publication checks

This record covers 30 research packages published in November 2026: 28 new packages and two substantially revised packages. The accompanying JSON identifies the exact PDFs, active source counts, review manifests, and build results. The collection README and technical FAQ describe the current results and their assumptions.

**These are conventional mathematical proofs, not Lean formalizations.** Independent AI agents checked the proofs and a separate reader checked the abstracts, introductions, and public summaries. Every active TeX source in this publication has a matching hash in a mathematical or presentation follow-up review. This is evidence about the specified source versions, not a guarantee against all mathematical errors or a claim of external peer review. The existing Lean sources and the formalization status of earlier papers are unchanged.

## Principal theorem distinctions

- The original independent Gaussian priors admit raw-output approximation guarantees at every mean-field-or-stronger scale. The general coefficient-free theorem uses a suitable fixed depth and regularity assumptions on continuous inputs. The arbitrary-input-law shallow tanh and ReLU theorems retain coefficient control, need no teacher-output cap, allow labels with only a finite second moment, and hold at every learner width that can contain the comparison. The finite-second-moment versions are confidence guarantees; the all-width ReLU expected-risk result assumes marginally sub-Gaussian labels. The sharper coefficient-free one-dimensional ReLU results distinguish the all-eligible-width theorem from the stronger theorem requiring learner width at least the sample count.
- The continuous-shrinkage priors are different weight priors on one prescribed dense architecture. Their normalized Gaussian and sinh-normal readouts have different rates and likelihood schedules. A full-support prior is not a prior over discrete architecture sizes.
- Expected-risk and high-probability statements are separate. Some high-probability events are common over widths and scales; others hold for each prescribed architecture with width-independent constants. A sharp expectation inequality is not itself a sharp high-probability theorem.
- A bounded output inside a likelihood, an extra bounded hidden layer before a raw readout, and a fully raw network are distinct learners. The papers state which construction is used. Comparison-only clipping does not modify the learner.
- Fixed-variance noisy-realizable results, including the exactly matched Gaussian-noise theorem, do not establish a fixed-variance agnostic oracle. Generic function-prior counterexamples are not asserted to be counterexamples to a particular neural prior.

## Publication checks

Each PDF was rebuilt from isolated source files with three LaTeX passes. Its extracted text matches the published PDF, and the final logs have no unresolved references or overfull boxes. The supplied build scripts were also run from temporary directories. All 30 first pages were rendered and inspected for titles, author order, and the author-order footnote; the final principal revisions were inspected separately.

The catalog records the current PDF hashes, and the collection checksum inventory includes the published files. Package-local Markdown links and the collection link check pass. An old plain-text polynomial was formatted as code to prevent it rendering as a broken link. The collection checker now skips downloaded `.lake` dependencies, recreates the empty build-log directory in isolated builds, and reads final logs rather than first-pass transcripts.

The original five formalized results and the ten-paper second batch retain their existing presentation. The new work is collected under [Approximation and noisy regression](../README.md#approximation-and-noisy-regression), with its review status stated explicitly.

[Independent review of the public summaries](agnostic-expansion-2026-11-18-live-docs.md) · [Exact README and FAQ hashes](agnostic-expansion-2026-11-18-live-docs.json).

## Package inventory

| Package | PDF pages | Active TeX sources | Build record |
|---|---:|---:|---|
| [agnostic-adaptive-calibration](../works-in-progress/agnostic-adaptive-calibration/) | 36 | 15 | [Isolated build](../works-in-progress/agnostic-adaptive-calibration/verification/build-record.json) |
| [agnostic-common-activations](../works-in-progress/agnostic-common-activations/) | 15 | 7 | [Isolated build](../works-in-progress/agnostic-common-activations/verification/build-record.json) |
| [agnostic-smooth-activations](../works-in-progress/agnostic-smooth-activations/) | 19 | 8 | [Isolated build](../works-in-progress/agnostic-smooth-activations/verification/build-record.json) |
| [agnostic-width-only-boolean](../works-in-progress/agnostic-width-only-boolean/) | 14 | 5 | [Isolated build](../works-in-progress/agnostic-width-only-boolean/verification/build-record.json) |
| [agnostic-width-only-regular](../works-in-progress/agnostic-width-only-regular/) | 17 | 7 | [Isolated build](../works-in-progress/agnostic-width-only-regular/verification/build-record.json) |
| [agnostic-heavy-tailed-width-only](../works-in-progress/agnostic-heavy-tailed-width-only/) | 19 | 9 | [Isolated build](../works-in-progress/agnostic-heavy-tailed-width-only/verification/build-record.json) |
| [agnostic-heavy-tailed-priors](../works-in-progress/agnostic-heavy-tailed-priors/) | 23 | 9 | [Isolated build](../works-in-progress/agnostic-heavy-tailed-priors/verification/build-record.json) |
| [agnostic-soft-gain-priors](../works-in-progress/agnostic-soft-gain-priors/) | 17 | 9 | [Isolated build](../works-in-progress/agnostic-soft-gain-priors/verification/build-record.json) |
| [agnostic-path-gain-priors](../works-in-progress/agnostic-path-gain-priors/) | 11 | 7 | [Isolated build](../works-in-progress/agnostic-path-gain-priors/verification/build-record.json) |
| [agnostic-stable-priors](../works-in-progress/agnostic-stable-priors/) | 10 | 5 | [Isolated build](../works-in-progress/agnostic-stable-priors/verification/build-record.json) |
| [agnostic-depth-obstruction](../works-in-progress/agnostic-depth-obstruction/) | 35 | 18 | [Isolated build](../works-in-progress/agnostic-depth-obstruction/verification/build-record.json) |
| [agnostic-all-scale-depth-obstruction](../works-in-progress/agnostic-all-scale-depth-obstruction/) | 50 | 23 | [Isolated build](../works-in-progress/agnostic-all-scale-depth-obstruction/verification/build-record.json) |
| [agnostic-depth-upper-bounds](../works-in-progress/agnostic-depth-upper-bounds/) | 16 | 5 | [Isolated build](../works-in-progress/agnostic-depth-upper-bounds/verification/build-record.json) |
| [agnostic-normalized-depth](../works-in-progress/agnostic-normalized-depth/) | 8 | 4 | [Isolated build](../works-in-progress/agnostic-normalized-depth/verification/build-record.json) |
| [agnostic-relu-sharp](../works-in-progress/agnostic-relu-sharp/) | 15 | 7 | [Isolated build](../works-in-progress/agnostic-relu-sharp/verification/build-record.json) |
| [agnostic-temperature-obstruction](../works-in-progress/agnostic-temperature-obstruction/) | 27 | 8 | [Isolated build](../works-in-progress/agnostic-temperature-obstruction/verification/build-record.json) |
| [agnostic-heavy-tailed-activations](../works-in-progress/agnostic-heavy-tailed-activations/) | 20 | 8 | [Isolated build](../works-in-progress/agnostic-heavy-tailed-activations/verification/build-record.json) |
| [agnostic-levy-fanin](../works-in-progress/agnostic-levy-fanin/) | 31 | 13 | [Isolated build](../works-in-progress/agnostic-levy-fanin/verification/build-record.json) |
| [agnostic-shallow-depth](../works-in-progress/agnostic-shallow-depth/) | 38 | 21 | [Isolated build](../works-in-progress/agnostic-shallow-depth/verification/build-record.json) |
| [agnostic-levy-width-only](../works-in-progress/agnostic-levy-width-only/) | 40 | 17 | [Isolated build](../works-in-progress/agnostic-levy-width-only/verification/build-record.json) |
| [agnostic-levy-function-prior](../works-in-progress/agnostic-levy-function-prior/) | 16 | 8 | [Isolated build](../works-in-progress/agnostic-levy-function-prior/verification/build-record.json) |
| [agnostic-levy-shared-circuits](../works-in-progress/agnostic-levy-shared-circuits/) | 17 | 10 | [Isolated build](../works-in-progress/agnostic-levy-shared-circuits/verification/build-record.json) |
| [agnostic-sharp-high-probability](../works-in-progress/agnostic-sharp-high-probability/) | 13 | 4 | [Isolated build](../works-in-progress/agnostic-sharp-high-probability/verification/build-record.json) |
| [agnostic-deep-sharp-high-probability](../works-in-progress/agnostic-deep-sharp-high-probability/) | 6 | 3 | [Isolated build](../works-in-progress/agnostic-deep-sharp-high-probability/verification/build-record.json) |
| [agnostic-neuron-gates](../works-in-progress/agnostic-neuron-gates/) | 23 | 12 | [Isolated build](../works-in-progress/agnostic-neuron-gates/verification/build-record.json) |
| [agnostic-raw-heavy-tail-obstruction](../works-in-progress/agnostic-raw-heavy-tail-obstruction/) | 14 | 6 | [Isolated build](../works-in-progress/agnostic-raw-heavy-tail-obstruction/verification/build-record.json) |
| [agnostic-raw-priors](../works-in-progress/agnostic-raw-priors/) | 54 | 28 | [Isolated build](../works-in-progress/agnostic-raw-priors/verification/build-record.json) |
| [agnostic-raw-width-only](../works-in-progress/agnostic-raw-width-only/) | 30 | 16 | [Isolated build](../works-in-progress/agnostic-raw-width-only/verification/build-record.json) |
| [agnostic-gaussian-raw-width-only](../works-in-progress/agnostic-gaussian-raw-width-only/) | 58 | 22 | [Isolated build](../works-in-progress/agnostic-gaussian-raw-width-only/verification/build-record.json) |
| [agnostic-relu-path-geometry](../works-in-progress/agnostic-relu-path-geometry/) | 8 | 8 | [Isolated build](../works-in-progress/agnostic-relu-path-geometry/verification/build-record.json) |

[Exact review and build inventory](agnostic-expansion-2026-11-18.json). Each package’s `verification/` directory gives the mathematical review scope and source hashes.
