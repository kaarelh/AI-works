# Part 9 audits

Four independent audits of code and process (workflow "Pre-results audits of Part 9", 27 October 2026, 02:13–03:01 UTC).
The auditors opened no held-out result file; the protocol auditor saw the one p9_sum `dlheld5` log line (h5t0; p9_sum is
identical to v2 on toy inputs) quoted in the orchestrator's chat. The orchestrator saw v2's small-n `qd_a` / `qd_b` progress
lines (test errors at n ≤ 1000) at 02:40 UTC, during the audits, and at 03:03, just after them, but no Q2 cell and no toy
result (PROTOCOL.md, Amendment 4). Each auditor wrote
its report and kept its probe scripts in the session scratchpad; they are copied here unchanged.

| report | lens | scripts |
|---|---|---|
| [`protocol.md`](protocol.md) | protocol and leakage: what each builder and the orchestrator saw, freezes, the integration rule | `protocol_work/` (transcript-search scripts; the transcript extracts they produced are not committed) |
| [`compute.md`](compute.md) | compute accounting: FLOP charges, budgets, CPU time, prediction cost | `compute_work/` |
| [`discreteness.md`](discreteness.md) | discreteness and permutation invariance of the new components | `disc/` |
| [`fairness.md`](fairness.md) | strength of the image and toy references | `fair/` |

What was done on the findings: PROTOCOL.md (Amendments 3 and 4, and the corrections in the freeze and crash-fix
sections) and PART9.md §1.1 and §8.
