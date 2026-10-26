# Part 8 audit, lens "discreteness": is it really a discrete method, and what does the work?

Scope: code and process of the three frozen designs (`study/hybrid/hyb_{stage,union,portfolio}/learner.py` + DESIGN.md),
the harness (`common.py`, `eval_toy.py`, `eval_real.py`, `run_heldout.py`, `compare_hybrid.py`,
`standard_tasks/{harness,data,mlp}.py`), DFG (`discrete_learner/dfg.py`) and the three builder transcripts.
No held-out result was read. Every run below used dev data only (toy `designed`, the 5 DEV datasets), plus metadata
(column types, C) of the held-out datasets, with no labels and no results. All runs used `nice -n 19`, one thread and
`PYTHONDONTWRITEBYTECODE=1`. Total about 6 CPU-minutes. Nothing was written under `gd-circuit-growth/`. Scripts and
outputs are in `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/audit/disc_work/`:

| script | what it does |
|---|---|
| `toy_lin.py` | L2 logistic regression alone on the toy inputs (λ by 5-fold CV) |
| `toy_attr.py` | splits the toy n* by component |
| `stage_feats.py`, `stage_readout_abl.py` | what hyb_stage's stage 1 admits on real data, and a readout ablation |
| `dfg_quad.py` | where DFG's spectral and linear blocks fire on the toy suite |
| `port_abl.py` | hyb_portfolio with member families removed |
| `dsmeta.py` | which datasets let the DFG member run |
| `devcells.py` | dev-only per-cell comparison |

## Verdict in one paragraph

Under the stated rules (discrete features plus convex readouts; no network, no gradient descent on feature parameters,
no continuous-kernel machine), all three designs are *admissible*, with one exception: the spectral block's (u·z)²
features. Their directions u are continuous eigenvectors. This matters for hyb_stage on real data, and for the primary
design only through DFG on Boolean inputs. But the two halves of the headline are carried by *different* components.

- **Toy suites:** carried by Part 6's exhaustive Fourier-character search (DFG). On the 15 designed targets that need
  nonlinear features, hyb_portfolio is exactly at DFG v1's level (mean log2 n* ratio −3.45 against −3.47). On the 6
  halfspace-like targets, a plain cross-validated logistic regression on the raw inputs already beats the networks
  clearly, and the hybrids add GBT to it.
- **Real tasks:** carried by a classical stacked ensemble (LightGBM, ExtraTrees, kNN votes, logistic regression). The
  primary design's only discrete-search member (DFG) is switched off on 22 of the 23 held-out real datasets. On the one
  dev dataset where it runs (kr_vs_kp), removing it changes nothing.

So hyb_portfolio is an AutoML-style portfolio that dispatches by input type: essentially AutoGluon's model zoo without
its neural nets, plus DFG. It is not one discrete mechanism that explains both results. The headline is defensible only
if it is phrased that way (section 6).

## 1. Component inventory and classification

Legend:
- **D** = discrete feature chosen by search, a test or a finite grid.
- **R** = convex readout or stacking weight.
- **B** = borderline (judged in section 2).
- **C** = continuous feature parameter.

### hyb_portfolio (primary)

| component | where | class | note |
|---|---|---|---|
| DFG v1.1 member, `dfg` / `dfg_forced`: Fourier characters χ_S of degree ≤ 4 (5–6 subsampled), extensions, local Walsh | learner.py:298–332 → dfg.py `_fit` | D | only if C = 2 and **every** column is binary or categorical (learner.py:275) |
| DFG linear block (all inputs as degree-1 characters), Hebbian background `Z @ bg` | dfg.py:240–244, 281, 289 | R on identity features (D on ±1 inputs) | |
| DFG spectral block, features (u·x)² − ‖u‖² | dfg.py:246–253, 269 | **C** | u = eigenvector of mean(r x xᵀ) |
| DFG LS + 15-step logistic readout | dfg.py:274–279 | R | |
| `gbt`: LightGBM, 100 rounds, 31 leaves | learner.py:110–126, 348–356 | D (splits) + Newton leaf values: **B** | |
| `et`: ExtraTrees, 100 trees, out-of-bag votes | learner.py:134–155, 359–363 | D (random thresholds), leaf class frequencies | |
| `knn_{std,raw}_{1,3,9,27}`: leave-one-out vote fractions | learner.py:162–187, 335–345 | **B** (prototype votes under a Euclidean metric) | |
| `lin_{0.05,1}`: L2 logistic regression on the standardized encoding | learner.py:85–97, 366–371 | R on identity features: **B** | always offered |
| stacker: s_c = b_c + Σ w_m L_m, w ≥ 0, L-BFGS-B | learner.py:195–215, 373–380 | R | |

### hyb_stage

| component | where | class |
|---|---|---|
| characters on bits (binary inputs; one-hot categoricals; thermometer bits [x > t] at training quantiles) | learner.py:37–91, 121–310 | D |
| linear block (all z columns), z background always in the readout | learner.py:283–289, 460–469 | R on identity features: **B** |
| spectral block (Zl·u)² − mean, u = top eigenvectors of mean(R_q z zᵀ) | learner.py:290–310, 333 | **C** |
| NN votes, log((count + 0.5)/(k + 0.5C)), k ∈ {1, 3, 9, 27}, metric from 2 options | learner.py:476–518 | **B** |
| softmax / logistic readout, λ by CV | learner.py:340–388 | R |
| LightGBM on stage-1 margins, or trees alone, chosen by CV | learner.py:391–440, 590–607 | **B** (as GBT) |

### hyb_union

| component | where | class |
|---|---|---|
| F0: L2 logistic / softmax regression on the linear encoding, λ by CV, always fitted | learner.py:137–186, 347 | R on identity features: **B** |
| honest blocks (kNN votes, ExtraTrees votes, the LR score) plus a ridge-Newton stack | learner.py:357–420, 465–490 | B / D / R |
| boosting families per round, scored by the Newton statistic: tree (LightGBM, `objective="none"`) | learner.py:421–443, 503–522 | D + Newton leaves: **B** |
| … parity (exhaustive characters on ±1 or median bits) | learner.py:524–570 | D |
| … linear (a Newton step on all inputs) | learner.py:572–578 | R on identity features |
| … knn, forest, lr blocks | learner.py:580–600 | R |
| no spectral block | | |

No design contains a neural network, gradient descent on a continuous feature parameter, an SVM or a kernel ridge.

## 2. Borderline cases, judged

**(a) Logistic regression on standardized raw inputs** (all three designs: portfolio's `lin`, union's F0 and `linear`
family, stage's z background).

- *On the toy suites:* the inputs are ±1, so x_j = χ_{j} is a degree-1 Fourier character, and a linear readout on them
  is a readout on discrete features.
- *On continuous real data:* the identity features are continuous, and they are not chosen by any search or test. All
  three designs include them unconditionally. The model is a zero-hidden-layer network fitted to its convex optimum.
  The optimiser (L-BFGS) is irrelevant because the optimum is unique.
- *Judgement:* allowed as a "convex readout / linear background", but it contributes nothing that is discrete. Where it
  carries a result, the result is "a convex linear model beats an over-parameterised MLP", not "discrete beats GD".
- *Measured on the designed toy suite* (`toy_lin.py`): λ-cross-validated L2 logistic regression on the 30 raw inputs.
  - It clearly beats the networks (log2 < −0.25) on 6 of 21 targets: dict −0.82, and3 −0.71, maj3 −1.07, maj9 −1.69,
    thr10 −2.25, rand2 −0.99.
  - dlist5 is −0.20.
  - It never reaches 10% error on the other 14.
- *On real data* it is not decisive:
  - `linear` alone is +0.54 against min(mlp, mlp_l2) on dev, never better than the MLP.
  - Dropping `lin` from the portfolio at n = 100 (2 seeds) moves the error by −0.004 to +0.009.

**(b) Gradient boosting** (LightGBM in all three designs; hyb_union is itself a Newton-boosting method).

- The weak learners are discrete: axis-aligned splits from ≤ 255 histogram bins, chosen greedily by the gain G²/(H + λ).
- Each leaf value is one shrunken Newton step −lr·G/(H + λ) on a fixed partition, and it is never revisited.
- The ensemble is functional gradient descent in function space. No continuous feature parameter is iterated.
- *Judgement:* passes the rule ("no gradient descent on feature parameters"). But the line that separates these designs
  from the networks is "no continuous feature parameters", not "no gradients". DFG's residual is itself the square-loss
  gradient, and hyb_union scores every family by gradient and Hessian statistics.
- *Wording:* the headline must say "beats gradient-descent-trained neural networks", never "beats gradient descent".

**(c) kNN votes** (portfolio and stage; union as a block).

- The prototypes are all training points, k is from a 4-value grid, the metric is one of two fixed Euclidean encodings,
  and the votes are counts.
- Nothing is searched or tested. The inductive bias is the Euclidean geometry of the chosen encoding.
- It is a kernel smoother with a rank-uniform kernel. The same smoother with Gaussian weights would be the excluded
  "continuous kernel", so the line is thin.
- *Judgement:* allowed by the letter of the rules, which list "nearest-neighbour … prototype features" explicitly. Describe
  it as nearest-neighbour memory under a fixed metric, not as learned discrete features.
- It carries the image-like data. Removing kNN from the portfolio at n = 300 (2 seeds):
  - optdigits: 0.0456 → 0.0520 (+14%);
  - satimage: 0.1218 → 0.1311 (+8%).

**(d) Spectral (u·z)² block** (hyb_stage learner.py:290–310 and 333; DFG dfg.py:246–253 and 269).

- u is a continuous unit vector in R^{d_z}: an eigenvector of the residual-weighted second-moment matrix with the
  diagonal removed.
- A test (Wigner edge, or a permutation null) admits it, but its parameters come from a closed-form spectral estimate,
  not from a finite dictionary.
- It is not iterative gradient descent. It is one-shot continuous feature learning: principal-Hessian directions. The top
  eigenvector of mean(r x xᵀ) is the direction that early, small-initialisation gradient descent on a single quadratic
  unit converges to (power iteration on that matrix).
- *Judgement:* violates "features must be discrete objects chosen by search/tests". Disclose it, or ablate it.
- *Usage, hyb_stage on real dev data* (`stage_feats.py`, seed 0): it fires on every dev dataset at n ≥ 1000 (gate n ≥ 4 d_z):
  - optdigits@1000: 18 quad features;
  - magic, satimage, kr_vs_kp: 4 each; magic@3000: 5;
  - spambase: 2.
- *Removing them from the stage-1 readout* (`stage_readout_abl.py`, λ = 1e-2 / 1e-3):
  - optdigits@1000: 0.054 / 0.040 → 0.078 / 0.052;
  - magic@1000: 0.163 / 0.162 → 0.174 / 0.174;
  - the others within ±0.003.
- *Usage, DFG on the designed toy suite* (`dfg_quad.py`, n = 256 / 1024 / 4096, seed 0): it fires only at n = 256, for
  dlist5 and rand0 (2 features each). Part 6 (DISCRETE-LEARNER.md:204, 279–283) records that the spectral block is DFG's
  first route on the **held-out** target majxor (MAJ5 ⊕ MAJ5, suite dlheld).

**Clean cases:** ExtraTrees (random thresholds, leaf frequencies), thermometer, median and one-hot bits (finite
threshold gates), and the stacking weights (convex). These are clean under the rule.

## 3. What carries which result

### Toy (designed suite, dev; `toy_attr.py`)

Each entry is n*, with the log2 ratio against the networks in brackets.

| target group | networks | lin only | DFG v1 | hyb_stage | hyb_union | hyb_portfolio |
|---|---|---|---|---|---|---|
| maj9 | 263 | 82 (−1.69) | 107 | 79 | 82 | 89 |
| thr10 | 563 | 118 (−2.25) | 164 | 117 | 122 | 122 |
| mean of the 6 LR-winnable targets | | −1.26 | −1.12 | −1.87 | −1.37 | −1.79 |
| mean of the other 15 targets | | never on 14 | −3.47 | −3.16 | −2.98 | −3.45 |
| mean of all 21 | | | −2.80 | −2.79 | −2.52 | −2.98 |

- **The nonlinear targets** (parities, staircases, mux, majpar, parmaj, sparsepoly, random formulas, dnf3, dlist5) are
  carried by the exhaustive character search. The portfolio reproduces DFG v1 there (−3.45 against −3.47). Default HGB
  never learns par4 and is slower than the networks on par3 (builder prompt).
- **The halfspace-like targets** (dict, and3, maj3, maj9, thr10, rand2) are carried by a convex linear model.
  - On maj9 and thr10 every hybrid equals logistic regression alone.
  - The portfolio's whole improvement over DFG v1 (−2.98 against −2.80) comes from these 6 targets: −1.79 against
    −1.12, which is 0.67 × 6/21 = 0.19. It comes from LR + GBT, not from discrete search.
  - Early hyb_union dev logs show `picks` all zero (prediction = LR start alone) on maj9, and3, dlist5, thr10 ≤ 512,
    dnf3 ≤ 512 and rand2 (union transcript, around lines 1078–1089 and 1886–1951 of the dump).
- **Held-out suites contain at least 6 more targets of this kind:** maj15, thr30 (dlheld), thr20, maj21 (dlheld2), and
  thrint, dlist8 (dlheld3). Expect LR alone to carry them too. (These are suite definitions in boolfuncs.py; no results
  were read.)

### Real (dev)

- **Single learners against min(mlp, mlp_l2)** (`devcells.py`, existing reference files): `linear` +0.54 (0 of 24 cells
  below 0); default `hgb` +0.03 (14 of 24 below 0); hyb_portfolio −0.25. The gain comes from **ensembling classical
  learners**, not from any single one.
- **Half of the portfolio's dev score is kr_vs_kp:** its 4 cells account for 2.96 of the 5.98 summed log2. On the other
  20 cells the mean is −0.15. Default HGB alone is already −0.43 / −0.46 / −1.20 on kr_vs_kp at n = 300 / 1000 / 2397:
  trees carry this dataset.
- **DFG contributes nothing measurable on real dev.**
  - kr_vs_kp is the only dev dataset where DFG can run.
  - hyb_portfolio with and without DFG (`port_abl.py`, 2 seeds): n = 300 0.0313 / 0.0313; n = 1000 0.0106 / 0.0106
    (identical), although DFG gets stack weight 0.15–0.23.
- **On the held-out sets DFG can run on only 1 of 23 datasets: mushroom** (`dsmeta.py`: C = 2 and no continuous column).
  On the other 22, hyb_portfolio is {LightGBM, ExtraTrees, kNN ×8, LR ×2} plus a stacker, by construction
  (learner.py:275).
- **Members per dataset** (portfolio dev weights, seed 0; builder transcript and `port_abl.py`):

  | dataset | members carrying it |
  |---|---|
  | optdigits | kNN-raw + ExtraTrees + GBT; LR has the largest weight at n = 100 |
  | satimage | kNN-raw + ExtraTrees (+ LR at n = 100) |
  | magic, spambase | GBT + ExtraTrees (+ LR at n = 100) |
  | kr_vs_kp | GBT + ExtraTrees (+ DFG, ineffective) |

- **hyb_union** (dev logs): the parity family is essentially never picked on real data (at most 1 pick in up to 418
  rounds). Real-data behaviour is LR + a stacked ExtraTrees / kNN block at n < 1000, then LightGBM rounds.
- **hyb_stage** is the one design whose discrete search plausibly helps on real data (`stage_readout_abl.py`):
  - removing the characters from the stage-1 readout raises the error on kr_vs_kp@1000 from 0.024 to 0.050–0.058, and
    on magic@3000 from 0.151 to 0.162–0.171;
  - on satimage the characters *hurt* (0.145 / 0.136 with them, 0.127 / 0.126 without);
  - pre-freeze logs show hyb_stage often choosing trees alone (`s2`) on magic and satimage at n ≤ 3000, so whether the
    characters reach the final model is not recorded.

## 4. More than an AutoML ensemble?

- **hyb_portfolio:** no. On real data it is a one-layer log-linear stack of LightGBM, ExtraTrees, kNN and logistic
  regression. That is a subset of AutoGluon-Tabular's default zoo and stacking (Erickson et al. 2020), without the neural
  nets. Its DESIGN.md says so itself ("The design is an AutoML-style ensemble; it does not unify the structure classes",
  DESIGN.md:181–184). Its one non-standard member is gated to Boolean C = 2 inputs.
- **hyb_union:** structurally more (one loss, significance-gated competition of families, honest out-of-fold blocks).
  Empirically the families do not interleave on real data: its DESIGN.md:192–196 expects that "LR + ExtraTrees + kNN
  stack, then gradient boosting" would do about as well, and that was not ablated.
- **hyb_stage:** the most integrated design (characters on threshold bits, linear background and kNN votes in one convex
  readout, then trees on the margins). Its stage choice is a CV selection among {s1, s12, s2}, which is AutoML-like.
- **The real-data half of the headline restates known results:** tree ensembles beat MLPs on medium tabular data
  (Grinsztajn et al. 2022), stacking beats single models, and kNN is strong on pixel data at small n. The genuinely new
  part is Part 6's DFG, and it acts on the toy side.

## 5. Findings

| # | severity | finding |
|---|---|---|
| F1 | major (blocker for "single discrete mechanism" phrasing) | Real-data side of the primary is a classical stack; DFG is gated off on 22/23 held-out datasets and inert on kr_vs_kp |
| F2 | major | Logistic regression on raw inputs carries the halfspace-like toy targets |
| F3 | major | The spectral (u·z)² features have continuous directions |
| F4 | major (process) | Attribution is not recorded and no ablations were run |
| F5 | minor | GBT is functional gradient descent |
| F6 | minor | kNN is Euclidean memory that carries the image-like data |
| F7 | minor | LR on continuous inputs is a linear model, not discrete features |
| F8 | minor | hyb_union / hyb_stage component usage on real data |
| F9 | minor (cross-lens) | Toy runs are not input-permuted |

**F1. Major (a blocker for any headline that says or implies a single discrete mechanism, or "DFG generalises").**
- *Evidence:*
  - `hyb_portfolio/learner.py:275`: `dfg_ok = ... C == 2 and len(cat_or_bin) == d ...`.
  - Held-out metadata: eligible only on mushroom.
  - Dev: no-DFG is identical on kr_vs_kp; DESIGN.md:181–184.
- *What it changes:* "one discrete learner beats GD on both" holds only for a fit() that dispatches by input type. DFG
  serves the Boolean toy inputs; a LightGBM + ExtraTrees + kNN + LR stack serves everything else. No discrete-search
  component contributes measurably to the real-task result.
- *Fix:*
  - Phrase the claim as in section 6.
  - Report, per held-out split, which member families were eligible.
  - Add the reference "classical stack" = `hyb_portfolio.learner:Learner:{"members": ["gbt","et","knn","lin"],
    "name": "hyb_portfolio_noDFG"}`. On 22/23 held-out datasets it is identical by construction, so it needs a run only
    on mushroom and the toy suites.

**F2. Major.** Convex logistic regression on the raw inputs carries the halfspace-like toy targets.
- *Evidence:*
  - `toy_lin.py`: 6/21 designed targets are clearly beaten by LR alone.
  - The hybrids equal LR on maj9 and thr10.
  - The portfolio's gain over DFG v1 lies entirely on those 6 targets (−1.79 against −1.12; on the other 15, −3.45
    against −3.47).
  - Code: portfolio `lin` (learner.py:366–371), union F0 (learner.py:347), stage z background (learner.py:466–467).
- *What it changes:* those targets' n* advantages, and part of the "21/21 clearly better", are linear-model wins over an
  over-parameterised MLP, not discrete-search wins. The same applies to ≥ 6 held-out targets (maj15, thr30, thr20,
  maj21, thrint, dlist8).
- *Fix:*
  - Add a "lin only" n* column to every toy table (`toy_lin.py` takes about 2 CPU-minutes per suite).
  - Report the clearly-better count both with and without the LR-winnable targets.
  - Describe the portfolio's toy gain over DFG v1 as coming from LR + GBT.

**F3. Major.** The spectral (u·z)² features have continuous directions.
- *Evidence:*
  - hyb_stage/learner.py:290–310 and 333; dfg.py:246–253 and 269.
  - hyb_stage/DESIGN.md:8–16 states "Every feature is a discrete object … linear and spectral blocks admitted by
    χ² / permutation-null tests" and "no gradient descent on any feature parameter". The second clause is true; the first
    is false for u.
  - hyb_portfolio/DESIGN.md:13 lists "what is discrete: characters" while DFG also carries spectral features.
  - Fires on all 5 dev datasets at n ≥ 1000 in hyb_stage. Removing it moves the stage-1 readout error by up to +0.024
    (optdigits@1000, λ = 1e-2) and +0.011 (magic@1000).
  - In the primary it acts only through DFG (Boolean C = 2). Part 6 says it is DFG's first route on majxor (dlheld).
- *What it changes:* hyb_stage's "discrete" label is inaccurate. The primary's held-out majxor n* may rest on a continuous
  feature.
- *Fix:* either
  - re-label it as "one closed-form spectral feature-learning step (principal-Hessian directions), not discrete" and
    disclose it per design; or
  - run a diagnostic with the quad block disabled (a one-line flag in a scratch copy of dfg.py / hyb_stage, for example
    gating `blk.append(("quad", ...))`) on dlheld majxor and on hyb_stage's real cells, and report both.

**F4. Major (process).** Attribution is not recorded, and no ablations were run.
- *Evidence:*
  - `standard_tasks/harness.py:34–41` and `discrete_learner/harness.py:125–131` keep only err / flops / cpu, and drop
    `info` (weights, stage choices, family picks).
  - The running held-out job (`scratchpad/hybrid/run_jobs.py`) uses those harnesses unchanged.
  - Each DESIGN.md "which part handles which structure" section rests on ad-hoc seed-0 dev runs.
  - hyb_union DESIGN.md:196 says "not ablated". The portfolio's `members` argument exists (learner.py:221, 225) but was
    never used for a recorded ablation.
- *Also:* portfolio stack weights are not contribution measures. Members' log-probability scales differ; for example,
  smoothed kNN log-probabilities floor at log(0.1/C) (learner.py:343). And kr_vs_kp shows a weight of 0.15–0.23 with zero
  effect.
- *What it changes:* any held-out statement about which component carried which cell is unsupported.
- *Fix:* after the headline numbers are fixed, run the frozen code (seed 0; n ∈ {100, 1000, max} per held-out dataset;
  2 targets per toy suite at n ≈ n*) with `info` logged, plus the ablations in section 7. Label all of it post hoc.

**F5. Minor.** GBT (LightGBM, all designs) and hyb_union's loop are functional (Newton) gradient descent over discrete
weak learners.
- *Judgement:* they pass the rule, because no continuous feature parameters are iterated.
- *Fix (wording):* say "beats gradient-descent-trained neural networks", and define "discrete" as "no continuous feature
  parameters; the hypothesis is a weighted sum of tree cells, Fourier characters, nearest-neighbour votes and the raw
  inputs".

**F6. Minor.** kNN votes are nonparametric memory under a fixed Euclidean metric.
- *Judgement:* allowed by the rules, but they carry the image-like data (no-kNN: +14% optdigits@300, +8% satimage@300)
  and, presumably, MNIST and Fashion-MNIST.
- *Fix:* describe them as such in the write-up. Note that a Gaussian-weighted version would fall under the excluded
  continuous kernels.

**F7. Minor.** LR on standardized continuous inputs (real data) uses identity features that are not selected by any test.
- It is a linear model, not discrete features.
- It is not decisive on real dev (dropping `lin` at n = 100: −0.004 to +0.009).
- *Fix:* label it as "linear background".

**F8. Minor (informational).**
- hyb_union's parity family is essentially unused on real data, so union on real data is LR + an ExtraTrees / kNN stack +
  LightGBM.
- hyb_stage's characters do help kr_vs_kp and magic@3000 in the stage-1 readout. But hyb_stage often picks trees alone,
  and its final choice is not recorded.
- *Fix:* the F4 diagnostic pass.

**F9. Minor (cross-lens).** The toy runs are not input-permuted.
- `eval_toy.py:118` wraps the learner in `ToyAdapter` only, not `harness.Permuted`.
- DFG's forced small-n variant (portfolio `dfg_forced`, learner.py:329; hyb_stage `force`) breaks ties toward the
  low-index inputs, where every suite places the relevant ones.
- Part 6 measured +0.03 in mean log2, and par4@16 going from 0.17 to 0.40 error, with permuted inputs.
- *What it changes:* n ≤ 32 cells only.
- *Fix:* disclose it, or rerun the toy suites under `Permuted`.

## 6. The honest claim (proposed wording)

> One learner that never trains a neural network or any continuous feature parameter beats the study's
> gradient-descent-trained MLPs on both benchmarks. On the toy Boolean suites it needs fewer samples (n*); on the
> held-out standard datasets it has lower error than the baseline and L2-regularised MLPs [numbers from
> compare_hybrid]. The only exception is the spectral quadratic features, whose directions come from one
> eigendecomposition.
>
> The learner is a portfolio: Part 6's exhaustive Fourier-character search (DFG) plus a standard stacked ensemble of
> LightGBM boosted trees, ExtraTrees, k-nearest-neighbour votes and L2 logistic regression. Its weights are fitted by
> convex stacking.
>
> The two halves of the result are carried by different parts:
> - *Toy suites:* by the character search (on targets that need nonlinear features the hybrid is at DFG's level), and on
>   halfspace-like targets by the logistic readout, which alone already beats the networks there.
> - *Standard tasks:* by the classical non-neural ensemble. The character search is active on 1 of the 23 held-out
>   datasets, and contributed nothing on the one development dataset where it runs.
>
> This is an AutoML-style combination of specialists, not a single discrete mechanism. Its real-task half restates the
> known strength of tree ensembles, nearest neighbours and stacking over plain MLPs at small-to-medium n. "Discrete"
> means discrete features with convex or Newton-fitted coefficients. Gradient boosting is functional gradient descent
> over trees, and the nearest-neighbour votes use the Euclidean geometry of the input encoding.

For hyb_stage, add the spectral (u·z)² features as continuous. For hyb_union, say that its parity family is idle on real
data.

## 7. Ablations that would show what each component contributes

All use the frozen code with constructor arguments, except where a flag is noted. Run them on dev first. Held-out runs
come only after the headline is fixed, labelled post hoc.

1. **hyb_portfolio members** (argument `members`, learner.py:221, 225):
   - `{"gbt","et","knn","lin"}`, the classical stack, on the toy suites (quick grid) and on mushroom. On the other 22
     held-out datasets it is identical by construction; state that instead of running it.
   - `{"dfg"}` on the toy suites: the portfolio's toy gain beyond DFG.
   - Drop-one (no `knn` / `et` / `gbt` / `lin`) on the 5 dev datasets, 3 seeds.
2. **Best single member and oracle:** gbt, et, kNN (best k by leave-one-out) and lin alone, with the portfolio's own
   settings. Add the per-cell oracle best single member. Together these give the stacking gain.
3. **"lin only"** (`toy_lin.py`) as a reference column on every toy suite. It costs about 2 CPU-minutes per suite.
4. **Spectral block off:** a one-line gate in a scratch copy of dfg.py / hyb_stage `_grow`, run on dlheld majxor
   (all n, 3 seeds) and on hyb_stage's real dev cells.
5. **hyb_stage:** `stage2=False` (stage 1 only), `nn=False`, and trees alone (force `choice="s2"`). Add "no characters"
   (the readout on z + NN votes only) with a scratch flag.
6. **hyb_union:** `families` subsets, for example without `"parity"`, without `"tree"`, `("lr",)` (F0 only) and
   `("tree",)`.
7. **Attribution log:** the F4 diagnostic pass with `info` recorded (weights, `choice`, `picks`, the feature kinds
   admitted).
