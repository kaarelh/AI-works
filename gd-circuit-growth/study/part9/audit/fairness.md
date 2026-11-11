# Part 9 audit: fairness of the references (QuickDraw images, symmetric toy suites, compute)

Auditor lens: **fairness**. Scope: code and process only. I read no held-out results: no files for hyb_portfolio2,
p9_*, or hyb_portfolio on qd_a, qd_b, dlheld4, dlheld5 or dlheld6. I also did not open the reference result files on
qd_a and qd_b; I only listed their names. Dev results I read: `standard_tasks/results/{mlp,mlp_l2unit,mlp_strong,mlp_strong1,hyb_portfolio,p9_gates-dev,p9_bank-dev}__qd_dev.json`,
the MNIST and Fashion-MNIST MLP files, and `compare_hybrid.toy_nstars('dlsymdev')`.

**Compute I used.** About 9.5 CPU-minutes in all: one pinned core, `nice -n 19`, under 1 GB. Nothing was written under
gd-circuit-growth/. The probe scripts are in `scratchpad/p9/audit/fair/`: `qt_probe.py`, `strong_enc.py`,
`strong_var.py`, `mlp_pooled.py`, `fourier.py` and `spike.py`. Every probe imports the repository's own
`mlp_strong.make_net` / `encode` and `p9_gates.learner.pool_sets` without changing them. All probes are seed 0, with
one network per configuration. Two cells reproduced the recorded numbers exactly (n = 1000: 0.2931; n = 10000 at
wd 0.1: 0.1922), so the probe numbers can be compared with the result files.

## Verdict

- **Toy networks on the symmetric suites: plausible, no defect.** Their sample sizes are what GD theory predicts for
  targets whose lowest nonzero Fourier level is degree 2. Their n* follows the strength of the degree-2 signal, with
  the same slope as v2's n*. v2 is about 3× lower in level.
- **Image references: plausible.** The learning curves are reasonable for permutation-invariant MLPs on QuickDraw.
  mlp_strong reaches 86.8% at n = 60000 on qd_dev.
- **But the image references are not at the FLOP frontier.** In my probe, a single network of width 512 with the
  same recipe uses 0.83 of the 3-run budget. It beats mlp_strong's ensemble, which costs 2× the budget, at
  n = 60000: 0.1265 against 0.1324. That shrinks the dev margin of p9_gates at n = 60000 by about a third.
- **The FLOP-equal comparison is not CPU-equal.** The gates member uses about 4–12× the CPU time of the MLP runs its
  FLOP budget corresponds to.
- **One reporting bug.** The pre-registered `mlp_l2unit` reference is silently missing from the QuickDraw tables.
- **One undocumented recipe change.** On QuickDraw, `mlp_strong` uses quantile-transformed pixels, not [0, 1]
  pixels. My probes show this does not weaken it.

**Effect on the pre-registered verdicts.** None of the findings is likely to flip Q2's sign at n = 10000 on dev. The
gates margin there (0.1467 against ≥ 0.1749) is larger than anything a wider, longer or more regularized MLP achieved
in my probes. They do change the size of the Q2 margins at n ≥ 30000, and what the Q2 claim may say.

## Probe results (qd_dev, seed 0, test error on the fixed 10000-point test set; binomial s.e. ≈ 0.004)

| n | configuration (mlp_strong recipe unless noted) | test error | FLOPs vs 3-run budget | CPU s (1 core) |
|---|---|---|---|---|
| 1000 | quantile inputs (as run), wd 0 (the chosen value) | 0.2931 (= recorded) | 0.17 | 11 (+compile) |
| 1000 | [0, 1] inputs, wd 0 | 0.3083 | 0.17 | 11 |
| 10000 | quantile, wd 0.1 (chosen) | 0.1922 (= recorded) | 0.33 | 20–25 |
| 10000 | quantile, wd 1.0 | 0.1816 | 0.33 | 25 |
| 10000 | quantile, wd 3.0 (above the grid) | 0.1798 | 0.33 | 29 |
| 10000 | [0, 1], wd 0.1 / wd 1.0 | 0.1967 / 0.1887 | 0.33 | 20 |
| 10000 | [0, 1], wd 1.0, inputs [x, p9_gates' scale-9 pooled sums] (d = 1460) | 0.1820 | ≈ 0.55 | 32 |
| 10000 | **width 512**, quantile, wd 1.0 | **0.1756** | 0.82 | 56 |
| 60000 | recorded: mlp_strong1 (wd 1.0) / mlp_strong ensemble of 3 (2× budget) | 0.1370 / 0.1324 | 0.33 / 2.0 | – |
| 60000 | width 256, 2× steps (20000 steps, 43 epochs), wd 1.0 | 0.1344 | 0.67 | 111 |
| 60000 | **width 512**, 10000 steps, wd 1.0 | **0.1265** | 0.83 | 138 |
| ref. | p9_gates-dev at n = 1000 / 10000 / 60000 | 0.2217 / 0.1467 / 0.1147 | 0.24 / 0.25 / 0.43 (own count) | 132 / 376 / 1749 |

## Findings

### F1 (major): the strongest image reference is not at the FLOP frontier; a wider single MLP inside the budget beats it at large n

- **Evidence.**
  - `standard_tasks/mlp_strong.py:23` fixes W = 256 and WDS = (0, 0.1, 1.0).
  - On qd_dev, the chosen wd is the top of the grid (1.0) at n = 30000 and 60000, and for 2 of 3 seeds at n = 10000
    (`results/mlp_strong__qd_dev.json` `chosen_wd`).
  - Probe (`strong_var.py`): the same recipe at width 512 gives 0.1265 at n = 60000, using 0.83 of the 3-run FLOP
    budget. The protocol's best reference is mlp_strong = mlp_best on every qd_dev cell
    (`compare_hybrid.ref('mlp_best', 'qd_dev')` gives mlp_strong at all n). It scores 0.1324 at twice the budget.
    mlp_strong1 scores 0.1370.
  - At n = 10000, width 512 gives 0.1756, against 0.1749 for the ensemble and 0.1816 for a single width-256 network
    at wd 1.0.
  - wd 3.0 is level with wd 1.0 at n = 10000 (0.1798 against 0.1816), so the edge of the wd grid probably costs
    little.
  - Doubling the step count barely matters: 0.1370 → 0.1344 at n = 60000.
- **Consequence.** At n = 60000 on qd_dev, p9_gates' log2 ratio is −0.21 against mlp_best and −0.14 against the
  width-512 network. About a third of the large-n image margin comes from the reference's architecture, not from the
  learner. The held-out QuickDraw sets have the same structure, so Q2's margins against `mlp_strong` and `mlp_best`
  at n ≥ 30000 are probably overstated by a similar amount.
  - "Reasonable for QuickDraw?" Yes, as a baseline. 784-256-256-10, 21–50 epochs, AdamW with cosine decay, dropout
    0.1 and a 3-member ensemble is standard. The width is at the narrow end: Simard et al. 2003 used 800 hidden
    units, and Srivastava et al. 2014 used 2×1024 to 3×2048 dropout nets on permutation-invariant MNIST.
- **Fix.**
  - Add one reference before the held-out v2 results are read: `mlp_wide`, the mlp_strong recipe at width 512, wd in
    {0.1, 1, 3} chosen on validation, one network retrained (≈ 0.8–1.0 of the budget, so FLOP-matched). Optionally
    also an ensemble of 3 such networks.
  - Run it on qd_dev, qd_a and qd_b at n ≥ 3000, seed 0 at n ≥ 30000 (about 2–3 CPU-min per large cell).
  - Answer Q2 against `mlp_best` including it, and say so as a strengthening deviation.
  - Minimum: report the dev probe above and qualify the large-n margin.

### F2 (major): equal FLOPs is not equal compute; the gates member uses about 4–12× the CPU time of its budget's MLP runs

- **Evidence.**
  - p9_gates-dev on qd_dev: `cpu_seconds` 132, 376 and 1749 s at n = 1000, 10000 and 60000
    (`results/p9_gates-dev__qd_dev.json`). The own FLOP count is 0.24, 0.25 and 0.43 of `common.budget_real`
    (`hybrid/common.py:23-24`, 3 MLP runs).
  - The 3 MLP runs that budget corresponds to take about 33, 60 and 150 s on one core (my single-core measurements:
    11 s per 2000 steps, about 20 s for 3880 steps at n = 10000, about 48 s for 10000 steps).
  - At n = 60000 the gates fit therefore runs at about 1.5 GFLOP/s by its own count, against about 41 GFLOP/s for the
    MLP. That is about 27× less work per CPU second.
  - The LightGBM part is an analytic per-tree formula (`p9_gates/learner.py:267-272`, charged at 323-325). It does
    not charge data movement. DESIGN §7 records the per-tree subset copies (`CopyMultiValBinSubset`, 2.2–2.7× of
    ggbt's time) and about 6 GB peak RSS. At n = 60000 most of the counted FLOPs are dense BLAS (kNN scans,
    projections), while most of the CPU time is LightGBM.
  - Part 8 already noted "bought with more CPU time" (`hybrid/HYBRID.md` §6). Part 9 makes it much larger: 1749 s
    against v1's 98–209 s on qd_dev at n ≥ 30000 (`results/hyb_portfolio__qd_dev.json`).
- **Consequence.**
  - Under the study's stated currency (analytic FLOPs, prediction not charged), the comparison follows the protocol.
    As a statement about what each side could achieve with the same machine, it is not fair to the networks.
  - With about 1750 CPU-s, the MLP side could afford 3–5 width-1024 networks, or width-512 ensembles with longer
    dropout training.
  - The width trend measured in F1 (256 → 512: −8% relative at n = 60000) suggests that a CPU-matched wide ensemble
    would close most of the n = 60000 gap (0.1147 against 0.1265). This is an estimate, not a measurement.
  - At n = 10000 no MLP change I tried came near the gates' 0.1467 (best 0.1756). So the n ≤ 10000 margin looks real
    under either currency.
  - Prediction cost (≈ 500× an MLP per query, `p9_gates/DESIGN.md` §4) comes on top.
- **Fix.**
  - Report CPU seconds per fit next to FLOPs in every image table.
  - State Q2's answer as "at equal analytic FLOPs".
  - Add one CPU-matched reference on qd_dev, and ideally on qd_a and qd_b at n ≥ 10000, seed 0: for example an
    ensemble of 3 networks of 784-1024-1024-10 with dropout 0.1–0.3 and wd selected on validation, at roughly the
    gates' CPU time.
  - Let the reader see whether the large-n image win survives compute parity.

### F3 (major, scope and wording; verdict unaffected): the gates member recovers locality from pixel correlations, so "MLP is the right comparator" holds only formally

- **Evidence.**
  - PROTOCOL.md (opening paragraph) picks the MLP as comparator because the discrete members use no pixel adjacency.
    "a method using spatial structure would have to be compared with a CNN".
  - `p9_gates/learner.py:222-242`: the pooling sets are the k most correlated pixels. DESIGN §7 states that on
    images these are the spatial neighbours: "the sets recover local neighbourhoods from data".
  - GD-based methods that use exactly this information exist:
    - Le Roux, Bengio, Lamblin, Joliveau & Kégl, *Learning the 2-D topology of images*, NIPS 2007. They recover the
      layout of permuted pixels from pixel-intensity similarity with about 1000 images, then apply convolution-like
      models.
    - Coates & Ng, *Selecting receptive fields in deep networks*, NIPS 2011. They group features by correlation to
      form receptive fields without knowing the topology.
    - Neyshabur, *Towards learning convolutions from scratch*, NeurIPS 2020. β-LASSO fully connected networks learn
      local connectivity and approach CNN accuracy (CIFAR-10 ≈ 85%).
  - My probe (`mlp_pooled.py`): an MLP given the gates' own scale-9 pooled sums as extra inputs improves only from
    0.1887 to 0.1820 (n = 10000, same recipe, [0, 1] scaling). So the representation alone does not explain the
    gates' 0.1467 for an MLP. The win is not simply "locality handed to the learner".
- **Consequence.** The pre-registered Q2 rule is satisfied. But a "discrete beats GD on images" reading would not
  survive a GD network that uses the same correlation-derived neighbourhoods. CNNs reach well above 90% on 10-class
  QuickDraw subsets (informal reports up to about 96%). A locally connected or graph-convolutional network on the
  k = 9 correlation neighbourhoods, or a CNN on a Le Roux-recovered layout, would very likely beat 88.5%.
- **Fix.**
  - Word the image claim as "against permutation-invariant MLPs".
  - Cite the three works above as the stronger, information-matched GD comparators, and say they were not run.
  - If compute allows on dev: a locally connected layer (or a 1-hop graph convolution) over the gates' own pooling
    sets, trained with the mlp_strong recipe. That is the decisive information-matched reference.

### F4 (minor): mlp_strong on QuickDraw is not the documented recipe; it uses quantile-transformed pixels, not [0, 1] pixels

- **Evidence.**
  - `standard_tasks/mlp_strong.py:24` sets `IMAGES = ("mnist", "fashion_mnist")`, and `:111` sets
    `image = name in IMAGES`, which is False for qd_dev, qd_a and qd_b.
  - So the pixels go through `QuantileTransformer(output_distribution="normal")` (lines 32-36, `:35`). The module docstring
    (lines 4-5), `compare_hybrid.py`'s docstring and HYBRID.md all say "image pixels scaled to [0, 1]".
  - `qt_probe.py`: sklearn maps values equal to a column's training minimum to the lower clip. So every background
    pixel becomes −5.20, as do the 108 columns that are always 0 at n = 10000. Mean |z| is 4.16, and 76% of the
    entries have |z| > 3.
- **Consequence.** It does not weaken the reference. Quantile inputs were better than [0, 1] inputs in every paired
  probe: n = 1000, 0.2931 against 0.3083; n = 10000 at wd 1.0, 0.1816 against 0.1887; at wd 0.1, 0.1922 against
  0.1967. But mlp_strong on QuickDraw is a different recipe from mlp_strong on MNIST and Fashion-MNIST, and that is
  undocumented.
- **Fix.** Document it. Do not rerun: the reference would get weaker. If the inconsistency matters, run a [0, 1]
  variant as an extra reference and let mlp_best take the minimum.

### F5 (minor): the pre-registered `mlp_l2unit` (mlp_reg) reference is silently missing from every QuickDraw summary and table

- **Evidence.**
  - `hybrid/compare_hybrid.py:32` sets `IMG = ["mnist", "fashion_mnist"]`, and `:48` returns
    `load("mlp_l2unit" if ds in IMG else "mlp_l2", ds)`.
  - For qd_* this looks for `mlp_l2__qd_*.json`, which does not exist. `CH.ref('mlp_reg', 'qd_dev')` returns None
    (checked).
  - `part9/compare_part9.py:64-80` then skips the empty cells (`if not C: continue`, line 79), and the per-n table prints "–".
  - PROTOCOL.md (References) lists `mlp_l2unit` among the image references. The result files `mlp_l2unit__qd_*.json`
    exist.
- **Consequence.** A named reference is dropped without notice. mlp_best is unaffected, because it loads mlp_l2unit
  through `MLP_VARIANTS`. Q2, which uses mlp_strong and mlp_best, is unaffected.
- **Fix.** Map QuickDraw to mlp_l2unit, for example `ds in IMG or ds.startswith("qd_")` in `ref()`. Equivalently,
  special-case it in compare_part9. Then regenerate RESULTS.md.

### F6 (minor): toy networks on symmetric targets are plausible, but their regularization is untuned, and Q1's size is a constant factor at d = 30

- **Evidence.**
  - The networks are fixed configurations: `nn_train.py:23` (width 128, batch 64), `:246-248` (lr 1e-3, 20000
    steps). Only wd 0.1 and logistic + wd 0.1 were added.
  - On dlsymdev the two untuned knobs already cut n* by a mean of 0.85 in log2 (nets → nets_best). Examples: sym7
    670 → 329, ssym9 821 → 324, twosym 3389 → 1817. wd → cewd alone gave −0.30. The improvement is still monotone,
    so the frontier is probably not reached.
  - **Why hundreds of samples?** (`fourier.py`, `spike.py`.)
    - 6 of the 8 dlsymdev targets have no degree-1 Fourier weight: they are even in the index, or products. Their
      lowest nonzero level is degree 2, with small per-pair coefficients: sym7 0.156; ssym9 and far9 0.109; band11
      0.029; twosym 0.062.
    - The network can represent |s| ≤ 1 with 3 units on 1_S. But GD has to find 1_S from the degree-2 statistic
      E[f x xᵀ], whose spike along 1_S has eigenvalue 0.94 (sym7), 0.88 (ssym9, far9), 0.29 (band11) and 0.25
      (twosym), against sampling noise of about √(d/n).
    - nets_best's n* falls monotonically with that spike: 296–329 at 0.88–0.94, 1817–1836 at 0.25–0.29. The log-log
      slope is −1.45. v2's n* has the same slope (−1.42) at about 3× lower level.
    - This is the information-exponent picture: single-index learning by one-pass SGD needs about d^{k*−1} samples
      (≈ d log d for k* = 2). See Ben Arous, Gheissari & Jagannath, JMLR 2021; for the hypercube, leap complexity in
      Abbe, Boix-Adserà & Misiakiewicz, COLT 2022 / 2023.
    - Reusing batches, as the fixed-set multi-epoch training here does, can lower the exponent (Dandi et al., ICML
      2024). But an even link keeps the generative exponent at 2, and the SQ lower bound at about d samples
      (Damian, Pillaud-Vivien, Lee & Bruna, COLT 2024). Zweig & Bruna (ICLR 2024) analyse symmetric single-index
      targets.
    - So several hundred samples at d = 30 is expected for GD. A learner whose hypothesis class contains "subset sum
      with ±1 signs" can round a coarse spectral estimate to the exact index. DFG v1.2's block search uses modulated
      pair matrices and an eigendecomposition (`p9_sum/DESIGN.md` §3). That gives it a constant-factor edge at
      d = 30, not an edge in complexity class.
  - Toy compute is fair in CPU time as well: p9_sum takes at most 7.5 s per fit on dlsymdev (`p9_sum/DESIGN.md` §3),
    against about 10–15 s for one network run.
- **Consequence.** The networks are not mis-specified. Q1's sign on dlheld6 is very unlikely to change. Its size
  (about −2 in log2 on dev) is a constant factor, and it would probably shrink by another 0.2–0.5 with tuned weight
  decay. That is an estimate from the dev knob effects; I did not run it.
- **Fix.**
  - Before reading v2's dlheld6 results, add `nets_cewd_tuned` (logistic loss, wd in {0.1, 0.3, 1.0} chosen on a
    10% validation split per n) to the dlheld6 references, and let nets_best take it.
  - Frame Q1's toy win with the spike and information-exponent argument and the references above.
  - Optional (dev): a d = 60 run of sym7 and band11 for both sides, to test whether the factor grows with d.

## Answers to the lens questions

1. **QuickDraw MLPs.**
   - Inputs:
     - `mlp` standardizes each pixel (`harness.py:61`). Rare pixels are amplified; this is the known Part 8 issue.
     - `mlp_l2unit` uses [0, 1] pixels.
     - `mlp_strong` uses quantile inputs on QuickDraw (F4). They are harmless, even helpful.
   - The 784-256-256-10 architecture and the step budget (21 epochs at n = 60000, 50 epochs at n ≤ 25600) are
     reasonable. Steps are not binding (2× steps: −0.003). Width is binding (F1).
   - The dev learning curve is plausible: mlp_strong's error is 45% at n = 100, 27% at 1000, 17.5% at 10000 and
     13.2% at 60000. I found no peer-reviewed MLP benchmark for 10-class QuickDraw bitmaps. Informal 10-class
     tutorials report CNNs up to about 96%, with MLPs and kNN below. The categories here are random, and the full
     numpy_bitmap set probably includes drawings the game did not recognise, so absolute numbers compare loosely.
     86.8% sits inside the expected 85–90% band.
   - A wider MLP narrows the large-n gap by about a third within the budget. A CPU-matched wide ensemble might close
     most of it at n = 60000 (estimate). Neither closes it at n = 10000 (F1, F2).
2. **Toy networks on dlsymdev.** They are reasonable. The "hundreds of samples" is the degree-2 cost described in
   F6, and it is consistent with the information-exponent and leap literature. The regularization is untuned (F6).
3. **Budget.** The FLOP-equal comparison is protocol-consistent but not compute-fair at large n (F2). The strongest
   reasonable references to mention are:
   - FLOP-matched: a width-512 MLP (one network, ≈ 0.8 of the budget) or an ensemble of 3 (≈ 2.5×).
   - CPU-matched: an ensemble of 3–5 width-1024 dropout MLPs.
   - Information-matched: a locally connected or graph-convolutional network on correlation-derived neighbourhoods,
     or a CNN on a layout recovered as in Le Roux et al. 2007, or a β-LASSO fully connected net (Neyshabur 2020).

## Literature

- Ben Arous, Gheissari, Jagannath. Online SGD on non-convex losses from high-dimensional inference. JMLR 2021
  (information exponent).
- Abbe, Boix-Adserà, Misiakiewicz. The merged-staircase property. COLT 2022; and SGD learning on neural networks:
  leap complexity and saddle-to-saddle dynamics. COLT 2023.
- Dandi, Troiani, Arnaboldi, Pesce, Zdeborová, Krzakala. The benefits of reusing batches for gradient descent in
  two-layer networks. ICML 2024 (arXiv 2402.03220).
- Damian, Pillaud-Vivien, Lee, Bruna. Computational-statistical gaps in Gaussian single-index models. COLT 2024
  (generative exponent).
- Zweig, Bruna. Symmetric single index learning. ICLR 2024 (arXiv 2310.02117).
- Le Roux, Bengio, Lamblin, Joliveau, Kégl. Learning the 2-D topology of images. NIPS 2007.
- Coates, Ng. Selecting receptive fields in deep networks. NIPS 2011.
- Neyshabur. Towards learning convolutions from scratch. NeurIPS 2020 (arXiv 2007.13657).
- Simard, Steinkraus, Platt. Best practices for CNNs applied to visual document analysis. ICDAR 2003 (800-unit MLP
  on MNIST).
- Srivastava, Hinton, Krizhevsky, Sutskever, Salakhutdinov. Dropout. JMLR 2014 (permutation-invariant MNIST MLPs).
