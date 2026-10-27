# Part 9 audit: protocol and leakage

Scope: code and process only. No held-out result file was opened. The one held-out number quoted below appears in the
orchestrator's own chat text, which I had to read to establish what the orchestrator saw.

Sources:
- Builder transcripts: S = `wf_65211ed2-329/agent-a22184199223d0857`; I1 = `agent-a8221d3409e741891`; killed I2 =
  `agent-a87cb4981cf075528`; resumed I2 = `wf_b9ff17dd-83e/agent-af6ae557a302399a0`.
- The main session transcript (`addd33f6-...jsonl`), cited as `main[k]` (record k).
- Git history of the working branch.

Transcript records are cited as `[k]`. All reasoning blocks in the builder transcripts are redacted, so intent can only
be inferred from actions.

Checks I ran (about 1.5 CPU-minutes, nothing written under `gd-circuit-growth/`):
- `compare_part9.rule_part()`, imported on its own;
- the S builder's `rule.py` (dev suites only);
- a toy equivalence check of hyb_portfolio2 against p9_sum;
- an accept-set summary computed from the dlheld5 *definitions*.

## Verdict

**No held-out data or results reached any builder.** S, I1 and both I2 sessions saw only:
- the names of held-out files and processes (`ls results`, `ps`);
- the PROTOCOL text;
- for S, the source code of `make_dl_heldout4_suite`.

**Every freeze held.** The md5s match, no learner was edited after its freeze, and the gates reruns assert the frozen md5
at import. The one post-freeze change to hyb_portfolio2 (a crash fix) is now recorded and does not change any result.

**The integration rule was applied correctly.** I reproduced both parts from the dev files:
- (i) p9_sum −2.30 against v1 −1.71, with no dev target worse by more than 0.5;
- (ii) p9_gates −0.105, p9_bank −0.007, v1 +0.046.

hyb_portfolio2 is p9_gates with only the DFG path changed, plus the crash fix.

**The learners contain no dataset names, test data, target identity or column-order constants.**

**The main problem is Q1 (sum features): it has no clean held-out test.**
- `dlheld4` is exposed. The full target source was shown to S, and the orchestrator's own task prompt quoted a truncated
  held-out target; the second is not recorded anywhere.
- `dlheld5` is blind to target identities, but not to the design. Its generative family was written 35 s after the
  orchestrator read S's summary, including S's list of what it cannot do. The family lies entirely inside S's
  representational class, leaves out every class S listed as unsupported, and uses accept sets far more oscillatory than
  any dev or dlheld4 target. That favours S over the networks and over v1.

**Q2 (images) is clean from a leakage standpoint.**

## Findings (most severe first)

### M1 (major): dlheld5, "the clean test", was specified after S's capabilities and limits were known, and sits inside S's hypothesis class

Evidence:
- **Timing.** `main[9437]` (23:07:46) printed the full S result from the workflow journal, including:
  > Not searched: products of more than two blocks, sums with more than one modulating character (e.g. t + 2 x6 x7 + 2
  > x8 x9 x10 ...), and unequal integer weights inside a block

  `main[9445]` (23:08:21) appended `make_dl_heldout5_suite` 35 s later.
- **The family matches S's representable set exactly** (`study/boolfuncs.py:386-418`):
  - one signed ±1 sum with an arbitrary accept set: S's additive block;
  - optionally XOR with one character, or AND / OR with one literal: each needs exactly one modulating character, which
    is S's modulated block;
  - `sign(t + w·chi_T + 1/2)`: exactly the form S's DESIGN.md says modulated blocks cover (DESIGN.md:35-38).
- **Every class S documented as unsupported is absent** (p9_sum/DESIGN.md:289-296):
  - more than one modulating character, as in dlheld4 `sumpar` (boolfuncs.py:347);
  - symmetric functions nested inside gates, as in `majsym` (349) and `symand`, whose `x7 | x8` part needs 3
    modulators (345);
  - functions of two separate sums, as in dev `twosym`;
  - unequal integer weights inside a block.
- **The accept sets are far more oscillatory.** Each t-value is accepted with probability 1/2 (boolfuncs.py:389), and
  the generated h5s targets have 3, 3, 4, 4, 4, 5, 5, 5 separate runs of accepted t-values (k = 5 to 13).
  - Every hand-written dlsymdev and dlheld4 target has 1 or 2 runs: intervals, tails, or a single value or pair.
  - A many-run function of a sum carries high-degree Fourier weight, which is costly for gradient-descent networks and
    for v1's character search. S's block represents it at the same cost as an interval (one group per value).
- **What is clean.** No rejection criterion uses performance: only accept mass in [0.25, 0.75] and |mean| ≤ 0.5.
  Seed 9393 was used once with no trial run. boolfuncs.py has not changed since commit 7449313e (23:08:41).

Consequence:
- PROTOCOL.md:60 calls dlheld5 "the clean test" of Q1. In fact it tests whether S finds functions it can represent,
  in a regime chosen to be hard for its comparators.
- A favourable Q1 answer on dlheld5 does not show that sum features help on signed-sum structure in general.
- Together with M2, Q1 has no held-out suite that is blind to both the target identities and the design.

Fix:
- Qualify the PROTOCOL / write-up wording. Suggested: "blind to target identities; family specified by the
  orchestrator after reading S's design summary; within S's representable class; S-favourable accept sets".
- Report dlheld5 by sub-family (h5s none / gated, h5t, h5rf).
- Better: fix now, before any dlheld5 or v2 toy result is read, a `dlheld6` drawn from a family stated independently
  of S. It should include multi-character modulation, products of two sums, unequal integer weights, nested gates and
  interval-type accept sets in the proportions of the original dlheld4 description. Run v2, v1 and the networks on it,
  and answer Q1 on it.

### M2 (major): the dlheld4 exposure is complete, stayed in S's working context, and the record is incomplete

Evidence:
- **What S saw.** S's `[61]` ran `grep -n "def make_dl_symdev_suite" -A 60 boolfuncs.py | head -90`. Its output `[62]`
  (20:17:41) printed the whole of `make_dl_heldout4_suite` (boolfuncs.py:329-368): all 10 hand-written targets with
  formulas and descriptions, and the random-formula generator with its seeds (8181 + 2, probe seed 5). The two random
  formulas were not materialised, but they are deterministic from the code shown.
- **The leak was used at write-up time.** p9_sum/DESIGN.md:289-293 (and S's returned summary) give
  `g(t_S + 2 x6 x7 + 2 x8 x9 x10)` as the example of an unsupported form. That is held-out `sumpar` (boolfuncs.py:347);
  no dev target has it (dev thrsum is `+ 3 x7 x8`). The same weakness list names "symmetric functions nested inside
  other gates", which are majsym and symand. S was predicting its held-out failures from the definitions.
- **Design parameters.** They were set at `[93]`/`[98]` (20:23-20:25), 6-7 minutes after the exposure, and never varied:
  - `sum_kmax=24` (dfg12.py:317): dev needs at most 11 (band11); held-out tail13 needs 13.
  - `sum_mod=4` modulators: every dev target needs at most 1; held-out symand and sumpar need 3. This one is
    inconclusive, because v1.1 already uses a top-4 cut for eigenvectors (dfg.py:251).
- **The orchestrator's prompt also leaked.** S's task prompt (`[1]`) gave "integer combinations of already-found
  characters (e.g. sign(x1+...+x5 + 2 x6 x7))". That is a truncation of held-out sumpar, not of the dev analog thrsum.
  The prompt was written by the orchestrator, who had defined dlheld4 minutes earlier.
- **What is clean.** S built no ad-hoc targets; every one of its evaluations used dlsymdev, designed or kr_vs_kp. It
  never loaded or ran dlheld4.

Consequence:
- Amendment 2 is right to report dlheld4 only "with the exposure noted", but it attributes the exposure to the grep
  alone.
- p9_sum/DESIGN.md:305 still says "the held-out `dlheld4` is the test".
- The DESIGN.md disclosure (lines 185-188) lists k_max and the two-block structure, but not the modulator count. An
  earlier draft (`[442]`) listed "4 modulators", and the corrected wording dropped it (`[448]`).

Fix:
- Extend Amendment 2 with the prompt example and the parameters set right after the exposure (k_max 24, 4 modulators,
  products of two).
- In the write-up, do not call dlheld4 a test of the sum-feature design. Its sumpar / majsym / symand rows are
  predictions S wrote with knowledge of the definitions.

### m1 (minor): post-freeze crash fix of hyb_portfolio2 (now recorded); residual record-keeping gaps

Evidence:
- **What broke.** The frozen file (md5 6837fa52, commit a2489545, 02:11:13) crashed on the first held-out image cells
  (qd_a and qd_b, n = 100). LightGBM raised "Reducing `min_data_in_leaf` with `feature_pre_filter=true`" at
  p9_gates/learner.py:313; see `main[9986]` and `main[9992]`.
- **The fix** is at hyb_portfolio2/learner.py:319-322, made at 02:14:07 and committed in 1a99637a / 37763afa
  (02:24). The new md5 e38af404 is recorded at PROTOCOL.md:78-85.
- **Why it changes nothing it did not crash on.**
  - For `mcs >= 20` the Dataset parameters are unchanged (`**{}`).
  - `n_fit >= 500` at every n ≥ 1000: fold training sets are at least n/2, and the early-stopping split keeps 0.9n.
  - No cell file was written by the old file: the qd_a n100_s0 cell dates from 02:26:02, after the 02:24:44 relaunch.
  - The toy path is unaffected. My check `eqtoy.py` gives identical predictions and identical FLOPs for the current v2
    and p9_sum on dlsymdev symxpar n = 256 and thrsum n = 128.
- **Residual gaps:**
  - (a) The recorded times are wrong. The freeze section is headed "~02:20 UTC" (PROTOCOL.md:63) but was committed at
    02:11:13, and the toy held-out lane started 02:11:20. The fix is dated "~02:45" (PROTOCOL.md:78) but was made at
    02:14 and committed at 02:24.
  - (b) `eval_cells.py:40,53` stores no learner md5 per cell or in the merged file, so a cell's provenance cannot be
    checked afterwards.
  - (c) The frozen p9_gates (2728ac2b) cannot fit any image with n_fit < 500. The gates dev evaluation never went below
    n = 1000, so the v2 image cells at n = 100 and 300 run a code path never exercised on dev. These cells are outside
    Q2 (n ≥ 10000).

Fix:
- Use commit timestamps in PROTOCOL.md.
- Write `hashlib.md5(learner file)` into each cell and into the merged JSON.
- State (c) in the write-up.
- Do not report p9_gates on its own at n ≤ 300 without the same fix.

### m2 (minor): the killed I2 scored the qd_dev test split, contradicting p9_bank/DESIGN.md §9

Evidence:
- **The killed I2 scored on test splits.** Its `lib.get` (`[77]`) returned `D["X"][te]`, so exp1-exp14 (MNIST, mostly
  n = 10000) were scored on the test split. Its `run_one.py` (`[229]`) also scored on `te`.
- **Including a qd_dev rule cell.** At `[266]` (23:34:00) it ran `run_one.py qd_dev 10000` and printed test error
  0.1626 (`[267]`). That is an integration-rule cell; the frozen p9_bank later scored 0.1612 there. Parameter changes
  (bank_fcap 2.0, an 8-value λ grid) were made in the same step.
- **The record says otherwise.** p9_bank/DESIGN.md:242-243 states "No surviving log shows `qd_dev` test use; whether the
  lost logs included any is unknown."
- **I1 and S are clean.**
  - I1 used `dev_common.get` throughout: train = pool[:n] with n ≤ 50000, validation = pool[50000:60000]. Its only
    test-split use was an optdigits equivalence check (`[454]`), where gates is inactive.
  - S's toy runs and its kr_vs_kp check follow the protocol; see m4 for the in-sample caveat.
  - The resumed I2 switched to pool[-10000:] validation (`[80]`, `[88]`, `[169]`).

Consequence:
- p9_bank's dev numbers are optimistic.
- p9_bank lost rule (ii) by 0.098 in log2, so the bias runs against the winner. The choice of p9_gates is robust.

Fix: correct DESIGN.md §9 and the PROTOCOL note to say the killed session also scored qd_dev n = 10000 on its test split.

### m3 (minor): the orchestrator saw held-out log lines before the v2 freeze; not recorded in PROTOCOL.md

Evidence:
- Progress monitors printed `tail -n 1` of the held-out logs: `v1_img_qd_a.log` at `main[9670]` (00:19:54),
  `v1_img_qd_b.log` at `main[9725]` (00:50:02), and `p9sum_toy_dlheld5.log` at `main[9791]` (01:17:13).
- The orchestrator acknowledged the last one in chat at `main[9796]`: "on target h5t0 it reached 10% test error at
  n=104, against 770 for the networks".
- The freeze section (PROTOCOL.md:75-76) records that p9_sum ran on dlheld4 and dlheld5 before the freeze. It does not
  record that results were seen.

Consequence:
- Both rule parts were mechanical, and I reproduced them exactly from dev files, so no integration decision could depend
  on what was seen.
- The record overstates blindness.

Fix: add one line to the freeze section, and make the progress monitors print cell counts rather than result lines.

### m4 (minor): rule (i) is in-sample for S

Evidence:
- `scratchpad/p9s/quick_port.py` calls `TH.evaluate` with the same targets, the same harness test samples and seeds 0-1
  as the frozen full evaluation.
- S explicitly fixed the two regressions that crossed the rule's 0.5 threshold on those cells: andxor +0.52 (`[398]`,
  forced block switched off) and sparsepoly +0.51 (`[471]`, acceptance rule changed).

Consequence:
- "No dev target worse by more than 0.5" is met by construction. This is not a protocol violation, since the toy
  protocol has no validation split, but rule (i) is a sanity gate, not evidence.
- S's DESIGN.md:304-306 says so too.

Fix: say so in the write-up; rely on held-out Q1 only (see M1 and M2).

## Checked and clean

1. **Held-out access by builders.** Searching all four transcripts for qd_a, qd_b, dlheld4, dlheld5, heldout4/5 and
   HELDOUT3 found only these:
   - the PROTOCOL text, and the data.py source with its category-selection code (no category names);
   - `ls` of result and data directories, and `ps` lines of reference jobs;
   - S's single grep (M2);
   - I2b's explicit exclusion filter (`[57]`).

   Every `DATA.load` / `harness.evaluate` call used dev sets.
2. **Freezes:**
   - p9_sum: learner 42600014, dfg12 4ff2e0c9. The last pre-freeze check (f2624e63) differs only in its docstring
     (`git diff 2311b083 5160167c`). md5_before equals md5_after for the full run.
   - p9_gates: 2728ac2b, frozen at `[458]` 21:48:07; afterwards only DESIGN.md and the driver were edited. The
     `force_col_wise` speed-up was correctly *not* applied.
   - The gates reruns after the OOM kill and the two restarts (`main[9625]`, `main[9865]`) ran `run_full_dev.py`,
     which asserts the md5 from `learner.md5` at import. The merged notes carry 2728ac2b.
   - p9_bank: 51ae345e; no learner edits after 00:26.
3. **Integration.**
   - `diff p9_gates/learner.py <frozen v2>` shows three lines changed: the docstring header, the DFG module path
     (dfg.py to p9_sum/dfg12.py) and the default name.
   - p9_gates' additions to v1 sit inside `if is_image(types, d, dmin)` (hyb_portfolio2/learner.py:534) and the ggbt
     refit branch, with no rng drawn on other inputs.
   - `rule_part()` reproduces the PROTOCOL numbers. Its mlp_best is computed per cell from all MLP variants
     (compare_hybrid.ref), not from the stale mlp_best files.
4. **dlheld5 mechanics.** Seed used once, no performance-based rejection, no edits since 23:08:41. The *family* choice
   is the issue (M1).
5. **Inside the learners.** No dataset names, file reads or test data. The image gate checks only column types and d.
   Pooling sets come from training rows, with ties broken by data fingerprints. There are no hard-coded index arrays,
   which matters because qd_dev, qd_a and qd_b share one column permutation. The toy learner receives only (X, y, rng),
   with columns permuted per fit (harness.Permuted). eval_cells uses the same splits and rng as `harness.evaluate`.
