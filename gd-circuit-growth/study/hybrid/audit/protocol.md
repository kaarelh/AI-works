# Part 8 audit, lens: protocol and leakage

Scope: the three frozen designs (`study/hybrid/hyb_{stage,union,portfolio}/learner.py`, primary = hyb_portfolio), the
Part 8 harness (`common.py`, `eval_toy.py`, `eval_real.py`, `run_heldout.py`, `compare_hybrid.py`, the job runner
`scratchpad/hybrid/run_jobs.py`), and the three builders' transcripts:

- `agent-a7121f2cccb992047.jsonl`: hyb_stage
- `agent-aba2178b610cd3caa.jsonl`: hyb_union
- `agent-ad2817045570fad1a.jsonl`: hyb_portfolio

All three are in `/root/.claude/projects/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/subagents/workflows/wf_777b36a2-474/`.
"Lnn" below means line nn of the transcript file. I extracted every tool call and result (238 calls in all). No held-out
result for any hyb_* learner was opened. My experiments used only the dev `designed` suite: about 2.5 CPU-minutes, at
nice 19, with one thread.

## Verdict

**No real held-out access, and no test-data use inside any learner.** No builder loaded, evaluated or read results
for a held-out toy suite or a HELDOUT / HELDOUT2 dataset. All data loads and evaluations are on the designed suite or
the 5 DEV datasets, and the image-scale checks used synthetic arrays.

The freeze holds:
- the md5 sums in PROTOCOL.md match the files now;
- no builder edited learner.py after its freeze;
- the dev result files postdate the freezes;
- re-running the frozen hyb_portfolio reproduced its dev errors exactly.

Four things change how the held-out numbers must be labelled or computed:
1. **Toy runs see the inputs in their natural order (no `harness.Permuted`).** All three designs break ties toward low
   column indices, through DFG's search and through LightGBM. Every toy suite puts the relevant inputs first. This makes
   n* optimistic at small n by up to 0.25 in log2 on dev targets.
2. **The Part 7 held-out set (HELDOUT) is not blind at the reference level.** The builders were told to read
   STANDARD-TASKS.md, and the primary's builder read its per-dataset held-out table for MLP, MLP-L2 and HGB.
3. **The toy suites `random` and `dlheld` are not blind for the DFG component that all three designs contain.** DFG
   v1.1 was developed against `random`, is post-hoc on `dlheld`, and has already been run on `dlheld2`. Only `dlheld3`
   is fresh.
4. **hyb_union stops on a 480 s wall-clock limit** that never fired on dev. Its large-n held-out results therefore
   depend on machine load.

None of these is a blocker for the primary's headline if it is reported with the labels below. The cleanest held-out
evidence is HELDOUT2 for tabular data and `dlheld3` for the toy suites.

---

## 1. Held-out access in the transcripts

**Method.**
- I listed every Bash, Read, Grep and Glob call.
- I collected every `DATA.load(...)`, `SH.evaluate`, `TH.evaluate`, `eval_toy.py` and `eval_real.py` invocation, and
  every dataset list passed to a builder's scripts (`dev.py`, `smoke_real.py`, `one.py`, `knn.py`, `real_compare.py`,
  `cmp*.py`, `summ.py`, `refs_table.py`).
- I scanned every tool result for held-out dataset and suite names.

**Real access: none.**
- Every dataset list is a subset of `optdigits, magic, kr_vs_kp, satimage, spambase`.
- `data.py` was only run with explicit dev names: stage L16 of its calls, and portfolio L60, `python3 data.py optdigits
  magic kr_vs_kp satimage spambase`. Its no-argument `__main__` would have printed the HELDOUT summaries.
- Every toy evaluation is `designed`, through `eval_toy.py`, `toy_part.py` (union L334, equivalent to `eval_toy.py`)
  or the builders' `smoke.py` / `toydev.py` / `prof.py` on designed targets.
- Results listings were filtered to dev names: stage L34, union L34 and portfolio L46 used
  `ls ... | grep -E "optdigits|magic|kr_vs_kp|satimage|spambase"`.

Name-only exposures:
- `ls hybrid/results` (portfolio L25) showed the file names `toy__hgb__{random,dlheld,dlheld2,dlheld3}.json`.
- `ls discrete_learner/results` (union L45, stage L57) showed `dfg-*__random/dlheld*.json` names.
- `ls mlp_l2*` (stage L264, union L40) showed held-out file names.
- `ps` (portfolio L125) showed `python3 mlp.py texture churn ... sleep`.

None of these files was opened.

**Synthetic scaling checks** (allowed by the prompt): portfolio L131 and L258, stage L201 and L337, union L152. Each
generates `X = rng.random(...)` arrays of shape 60000 x 784 with synthetic labels. No real image data was used.

**Exposure through prose: allowed by the prompt, but it must be disclosed (Finding 2 and Finding 3).**

| builder | read | held-out content seen |
|---|---|---|
| portfolio (primary) | L35: `cat standard_tasks/STANDARD-TASKS.md \| head -250` | Part 7 summary bullets, the per-learner held-out cell counts, and **the per-dataset table of test errors at n = 300 / 3000 / full for MLP, MLP-L2, dfg_*, linear and hgb on all 13 HELDOUT datasets**. For example, the line `\| mnist \| 60000 \| 0.025 \| – \| ... \| 0.022 \|` is in the L36 result. |
| union | L33: same file, `head -200` | summary, counts, and the table rows for mnist, fashion_mnist, adult, letter, pendigits and connect_4 |
| stage | L34: same file, `head -150` | summary bullets and counts only (e.g. "5.5–7.2% on MNIST against the MLP's 2.5%"; HGB "clearly better on adult, dna and ring") |
| portfolio L32, union L29 | `DISCRETE-LEARNER.md`, first 250–300 lines | DFG's summary rows on held-out 1 / 2 and on `random`, and the statement that `random` was a development check and that v1.1 is post-hoc on held-out 1. The tie-break-bias paragraph (lines 207–212) also falls inside these lines. |
| union | L49: `grep -n "def make_suite" -A 80 boolfuncs.py` | It overran into `make_random_suite`. The L50 output shows its docstring and generator: 4–8 inputs, 3–8 fan-in-2 AND/OR/XOR gates, relevant inputs `range(k)`. No individual targets were shown. |

The union builder's frozen DESIGN.md:190 quotes "Default HGB (100 full iterations) gets 2.2% on MNIST". That is a
Part 7 held-out number taken from that prose.

**Independence.**
- All three prompts are identical apart from the folder and the design angle (I diffed them). They contain no
  held-out numbers, even though the orchestrator had already run HGB on the toy held-out suites and on HELDOUT2
  (commit 3db0b9b9, 06:51) before the portfolio prompt (07:53).
- The portfolio builder listed `hyb_stage/` and `hyb_union/` (L25) but read none of their files.
- The union builder (L66) and the portfolio builder (L25) read PROTOCOL.md, so they knew the designation rule; the
  stage builder never read it.

## 2. What `fit()` uses

**Inputs.** All three designs use only `(X, y, types, C, rng, budget)`:
- no reference to test data, file I/O or dataset names (grep for dataset names, `open(` and `environ` in all three
  files; `HP_VERBOSE` only prints);
- no toy-target identity;
- no data cached across fits. The module-level state is the `_DFG` module cache in portfolio and the deterministic
  `_PEN` chi² cache in union. In stage, `self._big` is reassigned at the start of every fit (stage:547) before
  `_gb_params` reads it.

**Encodings and statistics.**
- Encodings use training statistics only, e.g. `encode_standard(A, types, ref=X, domain=dom)` (portfolio:247–248).
- Some unsupervised statistics are computed on all training rows, including the rows later held out for internal
  validation: stage `_Enc(X)` for the nearest-neighbour block (stage:541), and union `enc_fit(X)` / `knn_prep(X)`
  (union:335, 360). This is harmless.

**Branches on data shape.** These are driven by column types and size only:
- portfolio `dfg_ok` (C = 2, all columns binary or categorical, at most 256 one-hot columns; portfolio:275);
- stage `binary_inputs` (stage:454).

Thresholds that fall on held-out sizes are all compute regimes keyed to image shape (Finding 5):
- portfolio `n*d > 1e7` (portfolio:104–107, 249, 353): MNIST and Fashion-MNIST at n ≥ 30000 only;
- stage `n*dz*C > 5e7` (stage:547): images at n ≥ 10000;
- union `n*p*K > 2e7` (union:165): images at n ≥ 3000. connect_4 is just below it.

No dev dataset reaches any of these thresholds. Each was set from synthetic timing and is disclosed in its DESIGN.md.
Every other threshold is exercised on dev: K-fold up to n = 3000, a holdout above it, `lin_one_n`, `n_cv`, `n_val`
and `rf_cv_n`.

**Column order.** No design permutes or inspects column positions, but all three break exact ties by enumeration
order:
- DFG `offer` keeps the first candidate on a tie (strict `>`, dfg.py:152), and its forced variant takes `top` (dfg.py:255–256);
- stage keeps the first candidate in `offer` (stage:164) and in its forced variant (stage:318–319);
- union keeps the first entry of its candidate pool in insertion order (union:566);
- LightGBM picks the lower column index. I verified this: with identical columns 3 and 7, the root split is on 3.

On the toy suites the relevant inputs are columns 0..k−1, and the networks are symmetric under input permutation.
See Finding 1.

## 3. Internal model selection

**hyb_portfolio: honest.**
- At n ≤ 3000, every K-fold member is fitted on the other folds and predicts its own fold (portfolio:288–295).
- ExtraTrees supplies out-of-bag probabilities (portfolio:149–150, 363).
- kNN supplies leave-one-out votes, with `exclude_self_idx` (portfolio:340).
- At n > 3000, one stratified holdout H is used. Members are fitted on the rest; ExtraTrees' out-of-bag votes are
  evaluated on H, and the kNN leave-one-out votes for H are taken against all n.
- The stacker is fitted only on the H rows (portfolio:375), then the members are refitted on all n.

Two mismatches only make the stack conservative:
- the out-of-bag ExtraTrees probabilities come from about 37% of the trees;
- the out-of-fold DFG fits get `0.35/(K·variants)` of the budget each, while the final DFG fit gets up to 0.5 of it
  (portfolio:300, 392).

**hyb_stage: honest, with one small exception.**
- In the cross-validation folds, the nearest-neighbour votes for validation rows use only training-fold prototypes,
  and training rows get leave-one-out votes (stage:561–562).
- Stage-1 search runs per fold. The penalty λ, the forced variant (McNemar test), the stage set and the tree count T
  are all chosen on validation rows that are not used for fitting.
- The exception: the metric (z or raw) for the nearest-neighbour block is chosen by leave-one-out 3-NN error on the
  first ≤ 1000 rows, before the folds are split (stage:505–512, 542). Validation rows therefore help choose one binary
  setting, which makes the validation score of the configurations that use the block slightly optimistic (Finding 6).

**hyb_union: honest.**
- At n ≥ 1000, a 10% validation split is used only for early stopping and truncation, and the model is not refitted
  on all n (union:339–343, 652–664).
- kNN gives leave-one-out votes against a reference subset of the training rows.
- The forest gives 5-fold cross-fitted votes (n_tr < 2000) or out-of-bag votes.
- The linear stage gives out-of-fold scores at n_tr < 4000.
- The stacking init is fitted on training rows only.

## 4. Freeze

| design | md5 now = PROTOCOL.md:34–35 | last edit of learner.py (mtime) | full dev run launched | learner.py writes after launch |
|---|---|---|---|---|
| hyb_stage | 75bbfc08… yes; its sha256 d4840417… matches the builder's own record (L230, L364) | 07:12:03 (L225) | 07:12:21 (L230) | none (L235 is a `sed -n` read) |
| hyb_union | d780099c… yes (L354, L408) | 07:28:46 (L343) | 07:29:22 (L354) | none |
| hyb_portfolio | 063bcd91… yes; also equal to the scratchpad copy `hp/learner_frozen.py` (L258; `md5sum -c` at L314 and L351) | 08:35:06 (L253) | 08:36:07 (L258) | none |

- The dev result JSONs postdate these launches: stage 07:20–07:32, union 07:33–07:38, portfolio 08:40–08:50, and the
  toy files at 07:42, 08:03 and 09:05.
- The toy shards `hyb_portfolio-s1/2/3` use the same frozen class with only `name` changed (L258, merged at L351).
  hyb_union's `toy_part.py` is `ToyAdapter` plus `TH.evaluate(designed)` on the default grid (L334).
- The runtime dependencies (`dfg.py`, both harnesses, `data.py`, `common.py`, `boolfuncs.py`) are unchanged since
  before the builders started. `eval_toy.py` and `run_heldout.py` changed at 09:10 only in output naming
  (`--part`) and the `img:<ds>` option.
- My re-run of frozen hyb_portfolio reproduced its dev errors exactly at n = 16, 32 and 64 for par2, par3, par4 and
  andxor (3 seeds each).
- The held-out jobs started at 09:11:27 (`run_jobs.py`), after the designation commit b3489586 at 09:11:20.
- One deviation: the union builder froze an earlier version (md5 855484c0…, L223, 06:58:12), started the full dev
  run, killed it 12 s later after 3 optdigits seed-0 lines (L228–L238), and kept developing for another 30 minutes.
  Only dev data was involved (Finding 7).

---

## Findings (most severe first)

### F1 (major): toy suites are run without input permutation, and all three designs have a low-index tie-break bias

**Evidence.**
- `common.py:32-47` (`ToyAdapter`) and `eval_toy.py:14` pass the columns in their natural order. `run_jobs.py:22-24`
  runs every held-out toy job through this path.
- The study's own `discrete_learner/harness.py:39-50` (`Permuted`) exists for this reason: "a learner that breaks ties
  by enumeration order would otherwise be favoured at tiny n". DISCRETE-LEARNER.md:207–212 used it for Part 6's blind
  suite.
- Tie-breaks toward low indices: dfg.py:152 and 255; stage:164 and 318; union:566; and LightGBM (measured above).

**Measured on dev, hyb_portfolio, same training and test sets, 3 seeds; script `audit/protocol_work/exp/perm_check.py`.**

| target | n* natural order | n* permuted | log2 ratio to the networks |
|---|---|---|---|
| andxor | 33.8 | 40.2 | −3.48 → −3.23 |
| par3 | 52.1 | 55.2 | −4.02 → −3.93 |
| par4 | 55.0 | 55.7 | −5.63 → −5.61 |
| par2 | 16 | 16 | unchanged |

- The errors behind these: par3 at n = 32 is 0.337 in natural order and 0.468 permuted; andxor at n = 32 is 0.106
  and 0.134.
- hyb_stage on andxor at n = 32: 0.290 vs 0.357. hyb_union on the same cell: 0.244 vs 0.268.

**Consequence.**
- Each target's n* is optimistic by up to about 0.25 log2 when n* ≤ ~64. The suite-mean shift is probably a few
  hundredths, against −2.98 on dev.
- Verdicts will not flip, but every toy number, on dev and held-out, is biased in the learner's favour, and the
  designation scores carry the same bias.

**Fix.** Re-run the toy held-out suites with `TH.Permuted(common.ToyAdapter(L))`. Grid points n ≤ 512 are enough,
because the effect lives there and the fits are cheap. Report n* from the permuted errors, or report both and state
which is the headline. At minimum, disclose the bias with the numbers above.

### F2 (major): the Part 7 held-out set (HELDOUT, 11 tabular datasets plus 2 image datasets) is not blind at the reference level

**Evidence.**
- Portfolio L35 → L36: STANDARD-TASKS.md lines 1–250, including the per-dataset held-out error table (all 13
  datasets; MLP, MLP-L2, hgb, linear, dfg_*).
- Union L33 → L35: six datasets.
- Stage L34 → L37: summary only.
- hyb_union/DESIGN.md:190 quotes the held-out HGB MNIST error.
- The prompt told the builders to read this document. PROTOCOL.md:6–9 nevertheless presents HELDOUT as plain
  held-out data.

**Consequence.**
- The primary's builder knew where trees beat or lose to MLPs on each Part 7 held-out dataset, e.g. adult, dna, ring
  and nursery versus pendigits, twonorm and letter. It also knew the MNIST and Fashion-MNIST reference levels.
- A GBT-heavy portfolio's result on these splits is partly predictable from what the builder read. The results are
  valid as frozen-learner runs, but they are not a blind test of the design choices.

**Fix.**
- Label the "held-out tabular (Part 7 set)" and "held-out images" rows as *reference results known to the designers*.
- Make HELDOUT2 (fixed in 04a215b2 at 06:05, before any design, and never read) the headline tabular evidence.
- State in HYBRID.md that the images have no fresh replacement.

### F3 (major): toy suites `random`, `dlheld` and `dlheld2` are not blind for the DFG component

**Evidence.**
- hyb_portfolio imports DFG v1.1 unchanged as a member (portfolio:37–54, 298–332). hyb_stage and hyb_union port its
  search.
- DISCRETE-LEARNER.md (read by portfolio L32 and union L29) records the history:
  - `random` was "run twice with intermediate versions and read … a development check";
  - DFG v1.1 is "post-hoc" on held-out 1 (`dlheld`);
  - frozen v1's degree-5/6 search was added "knowing par5 was in the suite";
  - DFG v1.1's blind run on `dlheld2` is published: 7 of 7 better.
- The union builder also saw the generator of `make_random_suite` (L49 → L50).
- PROTOCOL.md:7 nevertheless lists all four suites as plain held-out data.

**Consequence.** Toy rows on `random` and `dlheld` are development or post-hoc data for the component that does the
work there. `dlheld2` is blind for DFG v1.1 but has already been used once. Only `dlheld3` (10 targets, fixed in
04a215b2) is a fresh test of the hybrids.

**Fix.** Report `dlheld3` as the toy headline. Label `dlheld2` "blind for DFG v1.1, used once", and label `random` and
`dlheld` "development / post-hoc for the DFG component". Pool across suites only with these labels.

### F4 (major for hyb_union; does not affect the primary): wall-clock stop

**Evidence.**
- hyb_union/learner.py:495 checks `time.time() - t_start > self.time_limit`, with `time_limit = 480.0` (line 317).
- On dev the largest per-fit CPU time is 14 s (union) and 13 s (toy), so the limit never fired. The builder's
  synthetic MNIST-shape check stopped on it after 51 boosting rounds (DESIGN.md:176–190).
- The held-out jobs run under contention: 3 workers, nice 5, plus other jobs.
- `info["stop"]` is not saved by `SH.evaluate`.

**Consequence.**
- hyb_union is not a function of `(X, y, types, C, rng, budget)` alone. Its large-n held-out cells (images; possibly
  connect_4, adult, sleep, krkopt and letter at full n) depend on machine load and are not reproducible.
- That code path was never exercised on real data.
- hyb_portfolio and hyb_stage use the clock only for their `info` records.

**Fix.**
- Disclose this.
- Flag hyb_union cells whose `cpu_seconds` ≥ ~300 s as possibly stopped on time.
- If hyb_union is discussed beyond a footnote, re-run those cells on an idle machine, or record `info["rounds"]` /
  `info["stop"]` through a thin wrapper. The learner itself stays frozen.

### F5 (minor): large-input code paths were tuned on MNIST-shaped synthetic arrays and never run on dev

**Evidence.** portfolio:104–107, 249–251, 353–355; stage:546–551 and 394–396; union:165–167. The transcripts confirm
synthetic data only (portfolio L131 and L258; stage L201 and L337; union L152), as the prompt allowed.

**Consequence.** Image results at large n come from settings never checked on real data: booster subsampling, no
refit, 2 penalties, 200 trees, a λ subsample. This is not leakage, and if anything it handicaps the designs.

**Fix.** Keep the existing disclosures (portfolio DESIGN.md:177, stage DESIGN.md:95 and 259, union DESIGN.md:190), and
repeat them next to the image rows in HYBRID.md.

### F6 (minor): hyb_stage chooses its nearest-neighbour metric before the cross-validation split; some unsupervised encodings use validation rows

**Evidence.**
- stage:501–512 and 541–542 choose the metric by leave-one-out 3-NN error on rows `X[:1000]` of all n, before the
  folds or the holdout are defined.
- union:335 and 360 compute `enc_fit(X)` and `knn_prep(X)` on all rows, including the 10% validation split.

**Consequence.** Validation-selected settings (the nearest-neighbour on/off choice and the penalty λ) are slightly
optimistic. There is no effect on test sets.

**Fix.** Disclose. Correcting it would need a refreeze, which is not worth it.

### F7 (minor): hyb_union froze once, aborted its full dev run, and resumed development

**Evidence.** Union L223 (md5 855484c0…, run launched 06:58:12), L228–L238 (killed; 3 optdigits seed-0 lines seen),
then edits until 07:28:46 and the final freeze at L354.

**Consequence.** "Frozen, then run once" holds only for the second freeze. Only dev data was involved.

**Fix.** One sentence in HYBRID.md.

### F8 (minor): designation scores are in-sample to development

**Evidence.**
- The builders tuned on the same dev test sets and targets that produced the designation scores:
  - portfolio L149 chose `lam_w` by dev test error;
  - portfolio L242 swept all 21 designed targets before freezing;
  - stage and union ran repeated quick and full checks.
- PROTOCOL.md:40–47 uses these scores to pick the primary.

**Consequence.**
- "Beats GD on dev" is not evidence of generalization. The designation is still legitimate, since it is a fixed rule
  applied before any held-out run (b3489586 at 09:11:20; jobs from 09:11:27).
- Only 1 of 24 dev real cells resolves as better, which also shows the dev real side has little power.

**Fix.** Say so in HYBRID.md.

## Verified, no finding

- No `fit()` uses test data, dataset names, target identity or file state. No design caches data across fits.
- Out-of-fold, out-of-bag and leave-one-out stacking in hyb_portfolio is genuinely out-of-fold. hyb_union's
  validation split and hyb_stage's folds are never used for fitting what they select.
- The frozen md5 sums match and there were no edits after the freezes. The dependencies are unchanged, and the
  frozen portfolio reproduces its dev errors exactly.
- HELDOUT2 and `dlheld3` were fixed at 04a215b2 (06:05:12), before the first builder started (06:22). No builder read
  their definitions or results; for `dlheld3`, only the names in `eval_toy.py` were visible.
- The builders' prompts contain no held-out numbers.
