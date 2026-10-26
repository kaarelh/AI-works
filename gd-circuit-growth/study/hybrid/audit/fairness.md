# Part 8 audit, lens "fairness of the gradient-descent baselines"

Auditor scope: the code and process behind the references Part 8 compares against. On the toy side that is the
study's networks (`study/nn_train.py`). On the standard tasks it is the MLPs (`study/standard_tasks/mlp.py`,
`harness.py`, `hybrid/compare_hybrid.py`).

**What I read.**
- `hybrid/PROTOCOL.md`, `common.py`, `eval_toy.py`, `eval_real.py`, `run_heldout.py`, `compare_hybrid.py`, `refs.py`;
  `standard_tasks/{harness,data,mlp,mlp_large,baselines,compare}.py` and `STANDARD-TASKS.md`; `hyb_portfolio/DESIGN.md`.
- The README's earlier parts and `NN-STUDY-TABLES.md`.
- MLP, `linear` and `hgb` result files for the 5 DEV datasets and for MNIST and Fashion-MNIST.
- For every dataset, only the row counts of the MLP-variant files (coverage, not values).
- The networks' own trajectory files for every toy suite. These are references, not hybrid results.

No `hyb_*` held-out result was opened.

**What I ran.** Two analyses of the networks' stored trajectories, and a small re-training probe of the networks:
41 networks × 20000 steps, with the same targets, training sets, test set, init and μP multipliers. In total about
6.6 CPU-minutes, all under `nice -n 19` with one thread. Nothing was written under `gd-circuit-growth/`. Scripts and
outputs are in `scratchpad/hybrid/audit/fairness_work/`.

## Verdict

- **Toy side: the networks are one untuned, unregularized configuration, and they are not a strong representative of
  "networks trained by gradient descent" at the same compute.** The configuration is square loss, no weight decay, one
  learning rate, 20000 steps, read at the final step.
  - One standard change, chosen a priori and not tuned, lowers n* 1.7–1.9× on all 3 targets where the probe could pin
    n* down (thr10, mux, par3). That change is AdamW with decoupled weight decay 0.1 at the same width, steps and FLOPs.
  - Logistic loss plus weight decay gives at least 1.9–2.0× (thr10, mux).
  - The networks' n* are therefore inflated by about 0.8–1 in log2 on these targets. Part 8's toy margin
    (dev mean log2 −2.98) is overstated by a similar amount where this transfers.
  - The *sign* of the toy comparison survives on every probed target. The hybrid's margins there are −2.2 to −4.0.
  - The numbers do not survive: "≈8× less data than gradient descent" (designed suite), the per-target ratios, and
    probably several dense held-out targets with small margins. **Major.**
- **Standard-task side: the MLPs are plain, lightly tuned single networks.** Their errors are in the normal range for
  such networks:
  - MNIST `mlp_l2unit` 1.75% at n = 60000, against 1.6% published for a 2×800 MLP; baseline `mlp` 2.51%.
  - Fashion-MNIST `mlp` 11.0%.
  - Dev tabular: behind default `hgb` at full n by 5–30%, as the tabular-deep-learning literature predicts.

  The issue is the comparison, not the MLPs:
  - The primary learner is a cross-validated stacked ensemble of about 14 classical learners: LightGBM, ExtraTrees,
    8 kNN, 2 logistic regressions and 2 DFG members.
  - It uses ≤ 0.14 of its 3-MLP-run FLOP budget on dev, so the budget does not equalize anything.
  - Its dev margin over min(mlp, mlp_l2) is mean log2 −0.248, about 16% lower error. Standard, cheap MLP upgrades are
    reported to deliver gains of the same size: an ensemble of 3 networks costs exactly the 3-run budget; quantile
    input scaling; dropout.

  So the real-task claim is fragile to the strength of the MLP reference. It should be scoped as "beats the study's
  lightly tuned single MLPs", or tested against a stronger reference fixed *now*, before held-out hybrid results are
  read. **Major.**
- No blocker in this lens, provided the write-up states what the references are and drops or qualifies the magnitude
  claims. A sentence like "beats gradient descent by ~8× in data" would be a blocker-level overclaim.

## Findings

### F1 (major). Toy reference is an untuned, unregularized network; AdamW or logistic loss cut its n* by about 2× at the same compute

**Evidence.**
- `study/nn_train.py:67-68`: square loss.
- `nn_train.py:70-85`: Adam with μP multipliers and no weight decay.
- `nn_train.py:242,244`: lr 1e-3, 20000 steps.
- `discrete_learner/harness.py:89`: the reference is `test_err[-1]`, the final checkpoint.
- One learning rate and one width; no model selection of any kind.

The probe (`fairness_work/toy_variants.py`) uses the same targets, training sets, test set, init keys and μP
multipliers, with batch 64 and 20000 steps. The reference uses seeds 0, 1, 2, and the variants use seeds 0 and 1 on the
same training sets.

| cell | reference test error, seeds 0/1/2 (`results/fixed_adam_*.npz`) | logistic loss | AdamW, decoupled wd 0.1 | logistic + wd 0.1 |
|---|---|---|---|---|
| par3, n = 512 | 0.403 / 0.378 / 0.286 | 0.461 / 0.422 | **0.005 / 0.000** | – |
| par3, n = 256 | 0.479 / 0.487 / 0.474 | – | 0.480 / 0.464 | 0.498 / 0.489 |
| mux, n = 1024 | 0.089 / 0.191 / 0.083 | **0.001 / 0.004** | **0.000 / 0.000** | – |
| mux, n = 512 | 0.283 / 0.320 / 0.327 | – | 0.173 / 0.204 | 0.151 / 0.126 |
| mux, n = 256 | 0.331 / 0.345 / 0.360 | – | 0.259 / 0.312 | – |
| thr10, n = 512 | 0.105 / 0.093 / 0.121 | **0.046 / 0.049** | **0.051 / 0.053** | – |
| thr10, n = 256 | 0.115 / 0.117 / 0.130 | – | 0.109 / 0.109 | **0.080 / 0.062** |
| thr10, n = 128 | 0.135 / 0.140 / 0.148 | – | 0.139 / 0.141 | – |
| par4, n = 1024 | 0.481 / 0.505 / 0.495 | – | 0.273 / 0.385 | – |
| majpar, n = 512 | 0.196 / 0.232 / 0.213 | – | 0.150 / 0.185 | – |
| stair5, n = 512 | 0.331 / 0.313 / 0.334 | – | 0.298 / 0.233 | – |
| maj9, n = 128 | 0.112 / 0.129 / 0.136 | – | 0.097 / 0.125 | – |

The re-implementation was checked: trained on 90% of n, it gives thr10@512 0.110 / 0.103 and par3@512 0.457 / 0.424.
These are close to the reference at 0.9n.

n* (test error 0.1, the harness's log-interpolation, seeds 0–1 against seeds 0–1):

| target | reference n* | AdamW 0.1 n* | factor | logistic + wd n* | hybrid dev n* (DESIGN.md) | hybrid log2 ratio, against reference → against AdamW |
|---|---|---|---|---|---|---|
| thr10 | 492 (3 seeds: 563) | 286 | 1.72 | < 256 | 122 | −2.21 → about −1.2 (≥ −1.07 against logistic + wd) |
| mux | 1249 (1156) | 709 | 1.76 | about 623 | 70 | −4.04 → about −3.3 |
| par3 | 858 (843) | 443 | 1.93 | – | 52 | −4.02 → about −3.1 |
| par4 | 2728 | not pinned; error at n = 1024 0.33 against 0.49 | ≥ 1.3 likely | – | 55 | – |

- The weight-decay value was fixed before the run: 0.1, the common AdamW default for lr 1e-3. It was not tuned. Better
  values may exist.
- Effects partly stack: logistic + wd beats wd alone on thr10@256 (0.071 against 0.109) and on mux@512 (0.139 against
  0.189).
- Logistic loss alone helps thr10 and mux a lot but slightly hurts par3@512.
- μP-SGD, the only other optimizer the study ran, is worse than Adam on all 9 targets it was run on
  (`toy_traj.out`), so Adam is the better of the two tried. Weight decay and loss were never varied.
- The study's Part 1 (README §4) itself notes that cross-entropy and weight decay add dynamics the race model omits.
  They were excluded deliberately, which is fine for Parts 1–5 but not for Part 8's question.

**Consequence.**
- Per-target n* ratios and the toy mean log2 (dev −2.98) are overstated by roughly 0.7–1.0 in log2 on the probed
  targets (sparse and staged: par3, mux; dense: thr10).
- Sign and "clearly better" counts survive on the probed targets.
- The risk is on the dense or leap-1 targets where the hybrid's margins are smallest:
  - designed: and3 −1.41, dict −1.55, maj9 −1.57, dnf3 −1.75, parmaj −1.80, maj3 −1.96, rand2 −2.04;
  - held-out suites: maj15, thr30, maj21, thr20, thrint, sym8/9, dlist8, h*rf.

  There, regularization plus logistic loss (plus F2 and F3) could bring margins close to the −0.25 "clearly better"
  threshold.

**Fix (preferred).**
- Re-run the toy network reference with AdamW wd = 0.1, and ideally also logistic + wd 0.1, on all suites. Use the
  same n grid, seeds, steps and width; it costs the same FLOPs per run, so the hybrid's budget is unchanged.
- At the measured 0.4 ms per network-step on one core, that is about 33 networks × 20000 steps ≈ 4.4 CPU-min per
  target. Roughly 1.5 CPU-h for the designed suite and 3.6 CPU-h for the 49 held-out targets, per variant.
- Fix the variant(s) now, before held-out hybrid results are read.
- Report the hybrid against both the original and the regularized networks, and against their per-target better one.

**Fix (minimum).** State in the headline that the networks are one unregularized square-loss configuration. Report this
probe as a measured ~2× sensitivity of n*. Do not quote "x-fold less data than gradient descent" as a property of GD.

### F2 (minor). Final-checkpoint reading: networks overfit, then partly recover, on dense threshold or majority targets; the oracle-ES gain is mostly not realizable

**Evidence.** `fairness_work/toy_traj.py` output, `toy_traj.out`.
- On thr10, n = 512 (seed mean), test error is 0.087 at step 200, rises to 0.134 by step 1000, and is 0.106 at step
  20000.
- Picking each network's best checkpoint on the *test* set (oracle) lowers n*:
  - thr10 563 → 263; maj9 263 → 191 (designed);
  - thr30 528 → 364; majpar5 5229 → 2490; maj15 355 → 291 (dlheld);
  - thr20 593 → 327; maj21 413 → 280 (dlheld2);
  - thrint 546 → 334 (dlheld3).
- Mean log2 shift: −0.08 (designed), −0.17 (dlheld), −0.20 (dlheld2), −0.09 (dlheld3), 0.00 (random).
- A realizable version, a checkpoint chosen on a 10% validation split within the same single run (probe variant `es`),
  recovered little: thr10@512 gave 0.078 and 0.103, against 0.110 and 0.103 at the final step. mux and par3 gained
  nothing. That variant had a padding bug at step 0, which was excluded when re-scoring.

**Consequence.** It does not change the comparison by itself; it shows the reference is under-regularized (see F1). The
held-out suites dlheld and dlheld2, with several dense targets, are where this matters most.

**Fix.** Disclose. Weight decay (F1) is the effective way to capture this gain.

### F3 (minor). Training is truncated: n* is still falling at step 20000

**Evidence.** n* at 10k, 15k and 20k steps, from the same trajectories:
- mean log2(n*@20k / n*@15k) is −0.07 (designed), −0.06 (random), −0.08 (dlheld), −0.12 (dlheld2), −0.07 (dlheld3).
- Cells whose seed-mean test error still falls by more than 0.02 in the last 5000 steps include mux@1024
  (0.149 → 0.121), par3@512, par4@2048, rf05@1024, rf13@512 and xmaj@1024.
- The README's delayed-generalization list has test error first ≤ 0.1 at step 15000–20000 for mux@1024, dnf3@512,
  rmaj9@2048, rand1@512 and rand3@1024.

**Consequence.** 2–4× longer training would plausibly lower n* by a further ~0.1–0.3 in log2. That is small next to F1,
but it has the same sign.

**Fix.** Disclose. If F1 is re-run, consider 40000 steps, keeping the hybrid's budget at one 20000-step run, or state
that longer training is not given to the networks.

### F4 (minor; already partly disclosed in Part 3). Width

**Evidence.** README §3.2, `results_w*`:
- par4 n* is 3554, 3304, 2728 and 1899 at widths 32, 64, 128 and 256, and still falling.
- par3 n* is flat at 827–911; maj9 needs 1.6× more data at width 32.

This matches Edelman et al. (2023): width acts as parallel search for "lottery-ticket" neurons and trades directly
against samples on sparse parities.

**Consequence.**
- Order-≥4 features cost the width-128 network more data than a wider one would need.
- At *equal FLOPs*, though, width 256 costs 3.6× per step, so this is a compute trade-off and not a free improvement.

**Fix.** State the comparison as "against a width-128 network at that network's compute". Note that par4-type n* falls
with width (−0.52 log2 for 128 → 256).

### F5 (minor, framing). Literature: what the toy comparison does and does not show

- **Sparse parities.**
  - For standard two-layer nets trained by online (fresh-sample) SGD, sample complexity scales as
    d^(max(leap−1, 1)). This is the CSQ / leap barrier: Abbe, Boix-Adserà, Misiakiewicz, COLT 2022 and 2023; Barak et
    al., NeurIPS 2022, where SGD learns k-sparse parities near the SQ limit in n^O(k) steps.
  - Kou et al. (2024) match the SQ bound with about d^(k−1) samples using sign-SGD. Glasgow (ICLR 2024) gets
    d·polylog(d) for XOR (k = 2). Edelman et al. (2023) give an SQ-type trade-off for offline sparse parity among
    samples, width, time and restarts.
  - Information-theoretically, about k log d samples suffice.
  - So a learner that enumerates Fourier characters beats any standard-architecture GD *in exponent* on parities. The
    hybrid's wins on par3, par4, majpar, stair5, mux and sparsepoly (margins −3.5 to −5.6) are structural and will
    survive any reasonable tuning (F1 moves them by about 1).
- **Dense and leap-1 targets** (and3, dict, maj3, maj9, thr10, dnf3, dlist5, rand2, parmaj).
  - Gradient descent is not exponentially handicapped on these, so the comparison is a constant-factor one, and the
    constants depend on loss and regularization (F1, F2).
  - Logistic-loss and weakly regularized networks have provably better sample complexity than their kernels on XOR-like
    targets: Wei, Lee, Liu, Ma, NeurIPS 2019; Chizat & Bach, COLT 2020, max-margin in the variation norm.
  - Weight decay is the intervention that most reduces the data a network needs on algorithmic or parity-like tasks:
    Power et al. 2022 "Grokking"; Merrill, Tsilivis, Shukla 2023 on sparse parity.

  The probe agrees.
- **Recommended wording.** "On sparse Boolean targets, a learner that enumerates Fourier characters needs far less data
  than gradient descent on a generic MLP, as SQ / leap theory predicts. On dense targets its advantage is a constant
  factor, roughly halved against a weight-decayed network."

### F6 (major). Standard tasks: a CV-stacked ensemble of about 14 classical learners against a single, lightly tuned MLP; the FLOP budget does not equalize tuning effort

**Evidence.**
- `hybrid/common.py:24`: budget = 3 × `harness.mlp_flops`.
- `hyb_portfolio/DESIGN.md` §1, §4: about 14 members are combined by 10-fold, 5-fold or holdout stacking. Max FLOPs /
  budget on dev is 0.139, and 0.22 on the MNIST-shape synthetic test. Prediction cost is not counted; at MNIST size the
  kNN prediction alone is about 1/3 of the fit budget.
- `standard_tasks/mlp.py:24, 136, 176`: the MLP's three runs buy lr ∈ {1e-3, 3e-4} × 40 checkpoints, selected on *one*
  10% split (10 points at n = 100), then one retrain.
- DESIGN.md §5 says the real-task gain comes from kNN (raw metric), ExtraTrees and boosted trees, combined by stacking:
  "an AutoML-style ensemble".

**Consequence.**
- At equal FLOPs the MLP could be a *3-network ensemble*, which costs exactly the budget. Deep ensembles reliably lower
  MLP error: Lakshminarayanan et al. 2017; the ensembles in Gorishniy et al. 2021; TabM (Gorishniy et al., ICLR 2025)
  shows MLP ensembling closes most of the GBDT gap.
- Standard input handling for tabular MLPs (quantile or robust scaling, F7) and dropout are cheap and are reported to
  reduce plain-MLP error by roughly 5–20% on medium tabular data. Kadra et al. 2021 ("well-tuned simple nets") and
  RealMLP (Holzmüller et al., NeurIPS 2024) report larger gains with more tuning. These magnitudes are recalled from
  the papers' summaries and were not re-derived here.
- That is the same size as the dev margin, −0.248 mean log2 (16% lower error).
- The tabular "win" is also what the literature predicts for any GBDT/RF/kNN stack against a plain MLP:
  - Grinsztajn et al. 2022: trees beat NNs on medium tabular data, because of irregular target functions, uninformative
    features and non-rotation-invariant data.
  - Shwartz-Ziv & Armon 2022: XGBoost beats deep tabular models.
  - McElfresh et al. 2023: GBDTs are best on skewed or heavy-tailed, irregular datasets.
  - Olson et al. (PSB 2018) on the PMLB suite itself: tree ensembles lead.
  - AutoGluon-style stacking (Erickson et al. 2020) beats single models.

  The study's own default `hgb` already beats the baseline MLP on held-out tabular data in Part 7 (−0.07).
- It is evidence about "AutoML stack against a single MLP", not about discrete search against gradient descent. The
  image cells (below) are where the verdict depends most on the MLP's strength.

**Fix.**
- Define now (before held-out hybrid results are read) one stronger MLP reference, `mlp_strong`, and report it next to
  `mlp`, `mlp_reg` and `mlp_best`. The spec is in "Strongest reasonable MLP" below.
- Or scope the claim explicitly: "beats the study's lightly tuned single MLPs; tree and kNN stacks are known to beat
  plain MLPs on such tabular data."

### F7 (major for any table or claim that uses `mlp` on images). Baseline input encoding handicaps the MLP: per-pixel standardization on images, plain z-scoring of heavy-tailed tabular features

**Evidence.**
- `standard_tasks/harness.py:61`: z-scoring with the training mean and std per column.
- `mlp.py:107`: the baseline applies it to every MNIST/Fashion pixel. Near-constant border pixels have tiny std, so
  rare nonzero values become huge inputs. `mlp_unit` (raw [0, 1] pixels) fixes this and is better at every n ≤ 10000.
- Seed-mean test error:

  | dataset | n | `mlp` | `mlp_unit` | `mlp_l2unit` | `hgb` | `linear` |
  |---|---|---|---|---|---|---|
  | mnist | 100 | 0.310 | **0.270** | 0.300 | 0.347 | 0.292 |
  | mnist | 300 | 0.186 | **0.160** | 0.205 | 0.198 | 0.186 |
  | mnist | 1000 | 0.113 | 0.105 | **0.097** | 0.111 | 0.133 |
  | mnist | 3000 | 0.075 | 0.067 | **0.058** | 0.063 | 0.113 |
  | mnist | 10000 | 0.045 | 0.038 | **0.037** | 0.039 | 0.111 |
  | mnist | 30000 | 0.0365 | – | **0.0240** | 0.0271 | 0.092 |
  | mnist | 60000 | 0.0251 | – | **0.0175** | 0.0220 | 0.078 |
  | fashion | 1000 | 0.197 | **0.195** | 0.203 | 0.197 | 0.222 |
  | fashion | 3000 | 0.169 | 0.166 | 0.162 | **0.154** | 0.210 |
  | fashion | 10000 | 0.1445 | 0.141 | 0.142 | **0.129** | 0.204 |
  | fashion | 60000 | 0.110 | – | pending | **0.105** | 0.165 |

- Literature (no augmentation, permutation-invariant MLPs):
  - MNIST: 2-layer 800-unit MLP with cross-entropy 1.6% (Simard et al. 2003, as tabulated in Srivastava et al. 2014,
    Table 2); ReLU 3×1024 with dropout 1.25%; dropout + max-norm about 1.0%.
  - Fashion-MNIST: sklearn MLP 87.1% accuracy (12.9% error; Xiao et al. 2017 benchmark); typical Keras 2-layer MLPs
    with dropout 89–90%; well-regularized larger MLPs about 90–91% (recalled).
  - So `mlp_l2unit` (1.75%) is a reasonable plain MLP. Baseline `mlp` (2.51%) is 40% worse than it and about 1.6–2× a
    dropout MLP. Fashion `mlp` at 11.0% is typical, perhaps 0.5–1.5 points behind a well-regularized MLP.
- Tabular: spambase (word-frequency counts) and the held-out page_blocks, ann_thyroid, churn and adult (capital-gain)
  have heavy-tailed columns. Plain z-scoring is known to hurt MLPs there: Gorishniy et al. 2021 use a quantile
  transform for all deep models; RealMLP uses robust scaling + smooth clipping. Tree members are invariant to this.

**Consequence.**
- Against `mlp` on images, any hybrid "win" at n ≥ 1000 on MNIST is inflated by 15–50% (log2 0.2–0.6).
- `compare_hybrid.py` uses `mlp_l2unit` as `mlp_reg` on images, which is good. But `mlp` is still a reported
  reference, and `mlp_best` at n ≥ 30000 is only min(mlp, l2unit).
- MNIST and Fashion at n ≥ 10000 are the cells where a stronger MLP (dropout or ensemble) would most likely flip
  verdicts. The hybrid's image members are kNN, LightGBM and ExtraTrees; MNIST errors for those are typically about
  2–3% at full n (recalled). That is close to `mlp_l2unit`'s 1.75% and well above what a dropout or ensemble MLP gets.

**Fix.**
- Treat `mlp_reg`/`mlp_best` as the image reference in all headlines, and say why `mlp` is weak there.
- For tabular data, add a quantile-transformed (or log1p-transformed) input variant inside `mlp_strong` (F6). It costs
  no extra FLOPs.

### F8 (minor). `mlp_reg` is not uniformly stronger than `mlp`: fixed lr, final checkpoint, λ chosen on 10–30 points

**Evidence.**
- `mlp.py:35`: lr fixed at 1e-3, λ ∈ {1e-4..1e-1}.
- `mlp.py:174`: final checkpoint, smoothed over the last 4.
- `mlp.py:136`: 10 validation points at n = 100.
- `mlp.py:62`: coupled L2 inside Adam, which is known to regularize worse than decoupled decay (Loshchilov & Hutter,
  ICLR 2019).
- Cells where `mlp_l2` is clearly worse than the baseline:

  | cell | `mlp_l2` / `mlp_l2unit` | baseline |
  |---|---|---|
  | magic, n = 300 | 0.219 | `mlp` 0.179; λ = 0.1 picked by 2 of 3 seeds |
  | satimage, n = 100 | 0.171 | `mlp` 0.157 |
  | mnist, n = 100 | 0.300 | `mlp_unit` 0.270 |
  | mnist, n = 300 | 0.205 | `mlp_unit` 0.160 |

**Consequence.** Against `mlp_reg` alone, some small-n hybrid wins reflect the reference's selection noise. `mlp_best`
covers these cells, but only with hindsight.

**Fix.** The fair regularized reference selects on validation over the *union* of the configurations: {lr 1e-3, 3e-4}
× early stopping, and λ-grid × final. Selection needs the validation scores, which `mlp.py` does not save, so this needs
a re-run. That is cheap for tabular data at n ≤ 3000.

### F9 (minor). `mlp_best` is "best of five" in name only; `mlp_plus`'s weight decay is negligible

**Evidence.**
- `compare_hybrid.py:11, 29` and PROTOCOL.md "best of five MLP variants". Which variants exist (coverage check):

  | split | variants available |
  |---|---|
  | dev | `mlp`, `mlp_l2` (best of 2) |
  | HELDOUT2 | `mlp`, `mlp_l2` (best of 2) |
  | Part-7 held-out tabular, n ≤ 3000 | `mlp`, `mlp_plus`, `mlp_l2` (best of 3) |
  | Part-7 held-out tabular, n > 3000 | `mlp`, `mlp_l2` (best of 2) |
  | images, n ≤ 10000 | `mlp`, `mlp_unit`, `mlp_l2unit` (best of 3) |
  | images, n ≥ 30000 | `mlp`, `mlp_l2unit` (best of 2) |

- `mlp.py:29, 78`: `mlp_plus` uses decoupled decay 0.05 × lr 1e-3 = 5e-5 per step. Over its 2000 steps the total
  shrink factor is e^(−0.1), so it is effectively only an lr-grid variant.

**Consequence.** `mlp_best` is weaker than its description, unevenly across splits.

**Fix.** State the variant count per split in RESULTS / HYBRID.md. Describe `mlp_plus` as an lr-grid variant.

### F10 (minor). Selection at small n is close to random; the step cap and constant lr bind at large n

**Evidence.**
- At n = 100 the "first maximum" rule (`mlp.py:176`) on 10 validation points stopped at the very first checkpoint
  (step 50 of 2000) in 11 of 21 seed-cells across the 7 datasets inspected. For example, fashion_mnist [50, 50, 50] and
  satimage [100, 50, 50].
- `mlp.py:40`: S ≤ 10000 binds for n > 25600 (MNIST/Fashion 30000/60000, adult, connect_4, sleep), at 13–43 epochs
  with constant lr and no decay.
- The baseline's chosen checkpoints at MNIST n = 60000 are 6500–9000 of 10000, near the end. `l2unit` is read at the
  final step.

**Consequence.** Extra variance at n ≤ 300. Probably a few % of error left on the table at the largest n. A cosine or
linear decay is standard and costs nothing.

**Fix.** Disclose. Include a lr decay in `mlp_strong`.

### F11 (minor, process). Fashion-MNIST `mlp_l2unit` is missing at n = 30000 and 60000; missing rows are silently dropped

**Evidence.**
- Coverage check: `mlp_l2unit__fashion_mnist.json` has 5 of 6 grid rows, n ≤ 10000. A `mlp.py fashion_mnist` job is
  running now, and 60000 needs `mlp_large.py`.
- `standard_tasks/compare.py:36`: `curve()` truncates to the rows present, and `compare_hybrid.cells` then skips those
  n without warning.

**Fix.** Make sure both rows exist before `compare_hybrid.py` is run for the write-up, or print a warning for missing
reference rows.

### F12 (minor). Toy budget symmetry is fine; the toy tuning asymmetry is the F1 issue

- The toy budget (`common.py:27`, one 20000-step run, 1.62e11 FLOPs) matches what the networks spend.
- The hybrid uses 0.19–0.60 of it and does internal 10-fold CV stacking. The network does no selection at all.
- An AdamW or logistic-loss network costs the same FLOPs, so F1's stronger references fit the same budget. No budget
  change is needed.

## Strongest reasonable MLP, and the cheap variant that would move the comparison most

**Proposed `mlp_strong`.** Fix it now; it does not depend on any hybrid result.

1. **Inputs.**
   - Tabular: continuous columns through a quantile transform to a normal distribution, fitted on the training split
     (sklearn `QuantileTransformer(output_distribution="normal", n_quantiles=min(1000, n))`); binary ±1; categorical
     one-hot as now.
   - Images: raw [0, 1] pixels.
2. **Training.** AdamW, lr chosen from {1e-3, 3e-4}, decoupled wd ∈ {0, 0.1} (AdamW convention, p ← p − lr·wd·p), dropout 0.1 on both
   hidden layers, cosine decay to 0 over S steps, final checkpoint. Validation selection over this 4-config grid,
   smoothed over the last 4 checkpoints.
3. **Prediction.** Average of the softmax probabilities of 3 networks with the selected config retrained on all n (3
   seeds). The ensemble is the piece that costs exactly the protocol's 3-run budget.

Cost: about (4 + 3)/3 ≈ 2.3× the baseline's runs. For n ≤ 3000 tabular data that is minutes per dataset; images at
n ≥ 30000 are the expensive part and can be one seed, as for the hybrid. If its budget matters for the hybrid, keep the
hybrid at 3 baseline runs; it uses ≤ 0.14 of that anyway.

**If only one variant can be added: the 3-network ensemble** (`mlp_ens3`). Average three networks trained with
`mlp_l2`'s or `mlp`'s already-selected config.
- It is the only change that maps exactly onto the protocol's "3 MLP runs".
- It helps every dataset and n.
- It is the standard reply to an ensemble-vs-single-model comparison.

Second choice, for tabular data: the quantile input transform, which is zero-cost. For images: dropout.

**Where the baseline looks weakest** (allowed data plus Part 7's published table):
- **MNIST, every n ≥ 1000**, for `mlp`: 15–50% worse than `l2unit` (F7). At n ≤ 300, `l2unit` is worse than
  `mlp_unit`.
- **Fashion, n ≥ 3000**: `hgb` alone beats every MLP (0.154 against 0.162 at 3000; 0.129 against 0.141 at 10000).
- **kr_vs_kp, n ≥ 300.**
  - n = 300: `mlp` 0.061, `mlp_l2` 0.057, hgb 0.043.
  - n = 1000: `mlp` 0.031, `mlp_l2` 0.017, hgb 0.012.
  - Binary chess features, where trees and DFG are natural and MLPs need strong regularization.
- **spambase, every n**: MLP ≥ hgb by 10–15%, and heavy-tailed inputs (quantile transform would help).
- **satimage, full n**: 0.079 against hgb 0.068.
- **magic, n = 300**: `mlp_l2` 0.219 against `mlp` 0.179 (F8).
- **Part-7 held-out** (published in STANDARD-TASKS.md):
  - ring at n ≤ 300 (`mlp` 0.254 against `mlp_l2` 0.097);
  - dna at n = 300 (`mlp_l2` 0.119 against hgb 0.057);
  - adult at full n (0.143 against hgb 0.126).
- **HELDOUT2, by known dataset character only; no values were read:**
  - ann_thyroid and page_blocks: skewed, threshold-rule, imbalanced. In published comparisons trees are well ahead of
    MLPs.
  - churn, wine_quality_white: trees, ExtraTrees and kNN are typically clearly ahead.

  Expect large hybrid "wins" there that would shrink, but probably not vanish, against `mlp_strong`.

## Literature cited

- Abbe, Boix-Adserà, Misiakiewicz. Merged-staircase property, COLT 2022; leap complexity and saddle-to-saddle, COLT 2023
  (arXiv:2302.11055).
- Barak, Edelman, Goel, Kakade, Malach, Zhang. Hidden progress in deep learning: SGD learns parities near the
  computational limit. NeurIPS 2022.
- Edelman, Goel, Kakade, Malach, Zhang. Pareto frontiers in neural feature learning: data, compute, width, and luck.
  NeurIPS 2023 (arXiv:2309.03800). Covers width and sparse init against samples on sparse parity, and wide sparse-init
  MLPs on the Grinsztajn tabular tasks.
- Kou, Chen, Chen, Gu. Matching the statistical query lower bound for k-sparse parity with sign SGD. 2024.
- Glasgow. SGD finds then tunes features in two-layer networks with near-optimal sample complexity (XOR). ICLR 2024.
- Wei, Lee, Liu, Ma. Regularization matters: generalization and optimization of neural nets vs their induced kernel.
  NeurIPS 2019.
- Chizat, Bach. Implicit bias of gradient descent for wide two-layer networks trained with the logistic loss. COLT 2020.
- Power, Burda, Edwards, Babuschkin, Misra. Grokking. 2022. Merrill, Tsilivis, Shukla. A tale of two circuits: grokking
  as competition of sparse and dense subnetworks. 2023.
- Loshchilov, Hutter. Decoupled weight decay regularization. ICLR 2019.
- Srivastava et al. Dropout. JMLR 2014, Table 2 (MNIST: 2×800 standard net 1.60%, ReLU 3×1024 with dropout 1.25%).
- Xiao, Rasul, Vollgraf. Fashion-MNIST. 2017 (sklearn MLP 0.871).
- Lakshminarayanan, Pritzel, Blundell. Deep ensembles. NeurIPS 2017.
- Grinsztajn, Oyallon, Varoquaux. Why do tree-based models still outperform deep learning on tabular data? NeurIPS 2022
  D&B.
- Gorishniy, Rubachev, Khrulkov, Babenko. Revisiting deep learning models for tabular data. NeurIPS 2021. Gorishniy,
  Rubachev, Babenko. On embeddings for numerical features. NeurIPS 2022. Gorishniy et al. TabM. ICLR 2025.
- Kadra, Lindauer, Hutter, Grabocka. Well-tuned simple nets excel on tabular datasets. NeurIPS 2021.
- Shwartz-Ziv, Armon. Tabular data: deep learning is not all you need. Information Fusion 2022.
- McElfresh et al. When do neural nets outperform boosted trees on tabular data? NeurIPS 2023 D&B.
- Holzmüller, Grinsztajn, Steinwart. Better by default: strong pre-tuned MLPs and boosted trees on tabular data
  (RealMLP). NeurIPS 2024.
- Olson, La Cava, Mustahsan, Varik, Moore. Data-driven advice for applying ML to bioinformatics problems (PMLB,
  165 datasets). PSB 2018. Erickson et al. AutoGluon-Tabular. 2020.

Numbers marked "recalled" are from memory of the papers. The MNIST 1.60% / 1.25% figures and the Fashion-MNIST 0.871
figure were checked by web search against the papers' tables.

## Reproduce (all outputs in `scratchpad/hybrid/audit/fairness_work/`)

```
W=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/audit/fairness_work
nice -n 19 python3 -I $W/tab_mlp.py                     # MLP-variant table, dev + images
nice -n 19 python3 -I $W/toy_traj.py  > toy_traj.out    # n* at 10k/15k/20k steps, oracle ES, SGD and width
nice -n 19 python3 -I $W/toy_es.py                      # trajectories on dense targets
cd $W && E="nice -n 19 env OMP_NUM_THREADS=1 XLA_FLAGS=--xla_cpu_multi_thread_eigen=false"
$E python3 -B toy_variants.py ce   thr10:512,mux:1024,par3:512        # logistic loss
$E WD=0.1 python3 -B toy_variants.py wd thr10:512,mux:1024,par3:512   # AdamW 0.1 (also the second cell list in variants2.log)
$E python3 -B toy_variants.py es   thr10:512,mux:1024,par3:512        # validation early stopping (re-score excluding step 0)
$E WD=0.1 python3 -B toy_variants.py cewd thr10:256,mux:512,par3:256  # logistic + AdamW 0.1
```
Logs: `variants.log`, `variants2.log`, `variants3.log`; JSON: `toyvar_*.json`.
