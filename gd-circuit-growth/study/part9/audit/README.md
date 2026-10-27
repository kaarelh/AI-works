# Part 9 audits

Four independent audits, run on code and process before any held-out result of `hyb_portfolio2` was read (workflow
"Pre-results audits of Part 9", 27 October 2026, 02:00–02:55 UTC). Each auditor wrote its report and kept its probe scripts
in the session scratchpad; they are copied here unchanged.

| report | lens | scripts |
|---|---|---|
| [`protocol.md`](protocol.md) | protocol and leakage: what each builder and the orchestrator saw, freezes, the integration rule | `protocol_work/` (transcript-search scripts; the transcript extracts they produced are not committed) |
| [`compute.md`](compute.md) | compute accounting: FLOP charges, budgets, CPU time, prediction cost | `compute_work/` |
| [`discreteness.md`](discreteness.md) | discreteness and permutation invariance of the new components | `disc/` |
| [`fairness.md`](fairness.md) | strength of the image and toy references | `fair/` |

What was done on the findings: PROTOCOL.md (Amendments 3 and 4, and the corrections in the freeze and crash-fix
sections) and PART9.md §8.
