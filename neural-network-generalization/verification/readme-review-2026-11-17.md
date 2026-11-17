# Folder README review, 17 November 2026

All **197 tracked README files** in the NNBayes collection were reviewed against commit `c851d2aa123ee71f593613ec2c4b52d68814288d`. The revision changes **150** and preserves **47**, including frozen audit snapshots and already self-contained guides. The [per-file record](readme-review-2026-11-17.json) gives each disposition and its source hashes.

## Editorial changes

The collection README now introduces the model conventions before the results, then presents Lean coverage in one place. Paper folders introduce their question, result, and assumptions before build instructions and review history. Related follow-ups are grouped by subject. Notation is defined where needed, and references to earlier conversations or unnamed previous versions are replaced with explicit descriptions.

Dated audit snapshots remain dated evidence. Their historical counts, hashes, and then-open proof gaps are not presented as the current state of the collection. Existing heading anchors and useful links are retained.

## Evidence-backed status corrections

Current coverage descriptions follow the [sixteen-paper completion record](../lean/review/coverage-completion-2026-11-15.txt), [coverage inventory](../lean/review/coverage-extension-2026-10-30.txt), and [literal-budget correspondence](../lean/review/manuscript-literal-target-correspondence-2026-11-15.txt). These support retiring obsolete exclusions concerning the improved-support sample budget, circuit-width convention, fixed hard families in the conditional theorem, and the stated continuous-domain and non-Gaussian extensions. Separate online lower-bound proof packages retain their own verification scope.

Older online papers now distinguish their particular constructions' limitations from questions resolved by later tanh and ReLU papers. Experiment READMEs distinguish packaged checkpoints from omitted initial checkpoints. The nearcritical-depth verification guide distinguishes its original audit hashes from a subsequent explanatory source revision.

The catalog's tanh online paper checksum was stale. It now matches the unchanged published PDF and its existing [build record](../works-in-progress/online-mistakes/isotropic-tanh-allwidth/verification/build-record.json). This is a metadata correction, not a new PDF build or proof check.

## Validation and limits

The review includes per-folder editorial checks and an independent review of the collection README. Validation checks cover the complete 197-file inventory, local link destinations, preservation of heading anchors, and whitespace errors. Mathematical displays and embedded proofs were preserved; scope descriptions were checked against the cited records. The published-file checksum inventory was refreshed for the edited documents and metadata.

No Lean source, LaTeX source, PDF, experiment data, or historical audit snapshot was changed. No Lean or LaTeX rebuild was needed or run for this editorial revision. This review is not a new mathematical audit of all the papers.

The existing collection checker also scans the local dependency checkout and can treat mathematical expressions as Markdown links. On this workspace it reports two pre-existing false positives: `lean/.lake/packages/batteries/docs/README.md` refers to its upstream `./lean-toolchain`, and `](1+s)` in the agnostic paper's mathematical audit is a formula, not a link. These are outside the edited READMEs. Checks restricted to the published README links are recorded separately in the per-file review data.
