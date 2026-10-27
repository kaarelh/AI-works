# Verification record

The proofs and the code of this project were checked by AI referees, not by humans. This folder records every referee report, every fix, and an audit of how each finding was resolved. `make_reports.py` renders the raw records in `raw/` as the Markdown reports in `reports/`; `summary.json` lists every report with its counts.

## Process

| round | what | reports | findings (critical / major / minor) |
|---|---|---|---|
| 1 | one referee per theorem group, two lenses (line-by-line proof check; counterexample hunting) for the core groups, plus an adversarial code review with executable tests | 18 | 8 / 45 / 141 |
| fix 1 | one fixer per topic, editing only its own files; then an independent re-review of each fix | 6 fixes, 6 re-reviews | (re-review findings fed into round 2) |
| new results | integration of local threshold circuits and of affine/linear structure: proofs re-derived, code and experiments written, then two referees per topic and a fix | 4 | 1 / 10 / 34 |
| 2 | consolidation: residual re-review findings and all cross-file edits | 7 owners | |
| 3 (final) | a fresh referee per topic, reviewing the current text and code from scratch and auditing every earlier finding | 12 | 4 / 4 / 72 |
| fix 3 | final fixes; all experiments rerun on the final code; then a consistency referee on abstract, introduction, experiments, discussion and README, and its fixes | 8 owners, 1 referee | consistency: 0 / 3 / 23, all fixed |

Audit in round 3 of the 239 findings of the earlier rounds: 231 resolved, 5 partially resolved (all minor, then fixed in fix 3), 3 superseded because the text was removed.

## What the referees caught

Errors in statements (all corrected in the paper as published):

- the black-box surprise theorem: part (b) was first argued in the wrong direction (soundness invoked on the circuit with the other circuit's argument), and later stated in a model where an earlier theorem already gives a stronger bound; it is now stated for a verifier that knows a certified envelope and evaluates the rest;
- proposals: a prover could supply a sampler and a probability mass function that disagree, inflating lower bounds arbitrarily; proposals must now be self-certifying;
- the argument system's exact rule trusted determinism of d-DNNFs, which is coNP-hard to check; the FPRAS-guided sampler had no valid interval;
- context width was defined on a flattened NNF, which made the window-CNF example false;
- several corollaries of DFSB (read-once compositions, O(1) trees, exact cutset conditioning with sampling switched on, invariance under small rewrites) were false as worded;
- an ETH remark did not follow; "the prover helps exactly when the proof system is not weakly automatable" overstated a one-directional result;
- certified telescoping assumed every stage ratio is at least 1/2; the independence procedure depended on an undefined quantity; unateness ignored XOR and negative-weight thresholds;
- a claimed O(sqrt n) looseness for integer-weight thresholds is false (counterexamples with looseness exponential in n).

Soundness bugs in the code (all fixed, each with a regression test):

- floating-point underflow made the envelope estimator, DFSB and variable elimination return intervals such as [0, 0] for tiny but positive p;
- clauses with repeated literals gave wrong Harris and Janson bounds and wrong CFTP stage guarantees;
- the verifier read supports from the prover's own envelope object, so a malformed envelope passed the decomposability check; proof objects could show different clauses to the checker on different reads;
- threshold gates were evaluated in floating point with a tolerance, so for some weights the code computed a different function from the one the paper defines; threshold gates are now exact rational arithmetic everywhere, and constants are 0 or 1;
- the tilting envelope failed to dominate the circuit for thresholds just above an integer.

## Status

- The final referees found no remaining error in the mathematics of any topic beyond minor items, which were fixed. Their verdicts per topic are in `reports/round3-final-*.md`.
- The code passes its test suite (327 tests), and the coverage experiment, run against exact rational ground truth without slack, shows no interval missing its exact value.
- The referees are AI systems. They re-derived proofs and ran adversarial numerical checks, but their judgement is not a substitute for human review, and citations were checked against abstracts and secondary sources where full texts were not reachable.

## Files

- `raw/round1_batch1.json`, `raw/round1_batch23.json`: first-round referee reports.
- `raw/round1_fixes_and_rereviews.json`: the fixers' reports and the independent re-reviews.
- `raw/new_results_integration.json`: integration, referee reports and fixes for the local-threshold and affine results.
- `raw/round2_consolidation.json`: the consolidation round.
- `raw/round3_final_referee.json`, `raw/round3_final_fixes.json`: the final referee round and the fixes after it.
- `raw/round3_consistency_and_sync.json`: the final experiment rerun, the text synchronisation, the consistency referee and the last fixes.
- `reports/`: all of the above as Markdown.
