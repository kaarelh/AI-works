# Referee B (computation and counterexamples) for thread `shape`

*Adversarial referee report, 2026-10-16. Object: `notes.md` (this folder, 543 lines, as of 02:22) and `checks/`. Independent code: `referee_code/refB_*.py`, each seeded (20261016) or deterministic, outputs `refB_*.out` next to each script. Referee A's files in `referee_code/` (`refA_*`) were not used.*

*Status: IN PROGRESS (skeleton written first for restart safety).*

## Plan

1. Re-run the developer's scripts c1-c6 on scratch copies and compare outputs.
2. Independent library (`refB_lib.py`): clauses, parallel unit propagation UP_k, forward chaining FC_k, brute-force entailment and prime implicates, GF(2) algebra.
3. Independent checks, one script per target: T1 (Lemma 1.5, Lemma 1.7, Prop 1.8, Thm 1.11), T2 (Lemma 2.1 to Cor 2.8, Rem 2.9), T3 (Props 3.1-3.3, Lemma 3.4, Thm 3.6 at n=4, simplex with auxiliary variables), T4 (Prop 4.2), T6 (Lemma 6.1, Thm 6.2 exact), T7 (Thm 7.1, exact s_k(m), Conj 7.1b).

## Progress log (restart safety)

* Developer scripts c1-c6 re-run on scratch copies (`/tmp/claude-0/.../scratchpad/shape_rerun/`): all six outputs identical to the saved ones apart from the timing line (c1 29 s, c2 157 s, c3 1.5 s, c4 4.7 s, c5 1.3 s, c6 366 s).
* refB_t2_linear: done (all T2 claims confirmed; Remark 2.9 minima are 4 and 3, not 6 and 4).
* refB_t3_aux: done (Prop 3.1-3.3, Lemma 3.4, Thm 3.6 at n=4,5 confirmed; simplex circuit library with auxiliary variables is UP-usable and polynomial: evidence for the Thm 1.12 / Cor 2.8 reading issue).
* refB_t4_rules: done (trivial sound rules exist: "exactly m 2^(m-1) sound rules" false as stated; FC = UP confirmed).
