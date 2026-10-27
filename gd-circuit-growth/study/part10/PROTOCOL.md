# Part 10 protocol (written before any Part 10 design work)

The user's request (27 October 2026): put a couple more hours into a better discrete learner; then take the best learner
so far and interpret it on some tasks (what structure does it learn?); then write a paper about that learner: what kind of
learner it is, how well it does against baselines, and the interpretability results.

The current best learner is **v2** = `hyb_portfolio2` (Part 9, `study/part9/hyb_portfolio2/learner.py`, md5
`e38af40493816ef1bc82e4f16428dcdf`). Its known weaknesses (Part 9, PART9.md §6, §9):
- *Images.* At n = 60000 it ties a CPU-matched ensemble of 1024-wide MLPs and an MLP given its own pooled sums; a small
  CNN on unpermuted pixels is clearly better at n = 10000; a fit takes 20–30 CPU minutes at n = 60000.
- *Toy.* On the blind suite `dlheld6` it misses a residue class mod 3 of a 13-input count (h6_00), which the most
  regularized network learns, and is worse than that network on h6_10 (a band of a sum with a weight-3 inner literal).

**Data access.**
- *Development* (everything already seen): toy `designed`, `random`, `dlheld`–`dlheld6`, `dlsymdev`, and a new
  development draw **`dlfamdev`** (`boolfuncs.make_dl_famdev_suite`: seed 61616 from `dlheld6`'s family,
  part9/heldout6/FAMILY.md; targets fd_00 … fd_11); images MNIST, Fashion-MNIST, QuickDraw `qd_dev`, `qd_a`, `qd_b`;
  all tabular sets.
- *Held out, fixed now, before any design:*
  - toy **`dlheld7`** (`boolfuncs.make_dl_heldout7_suite`: seed 70707 from the same family; f7_00 … f7_11; controls are
    the family's C strata);
  - images **`qd_c`**, **`qd_d`** (`standard_tasks/data.py`: the next 20 categories, 30–49, of the seed-9191 draw that
    gave `qd_dev`, `qd_a`, `qd_b`; 60000 / 10000; the same fixed column permutation).
  Builders do not load, generate, print or inspect them; the orchestrator reads no held-out result of a Part 10 learner
  before that learner is frozen.

**Budgets** as in Parts 8–9: one network training run per toy fit; three MLP runs per image fit (`common.budget_real`);
everything counted; prediction reported separately. CPU time per fit is reported.

**Design.** Up to three independent builders, development data only, each changing one component of v2 and delivering
a full learner file (a copy of v2 with the change), a DESIGN.md, an md5 at freeze, and the fixed dev evaluation below.
- **T (toy component):** DFG v1.2's sum-feature search (residue / oscillatory accept sets, weighted sums, several
  modulators, small-n cost). Dev evaluation: `designed`, `dlsymdev`, `dlfamdev`, full toy grid, 3 seeds, inputs
  permuted; tabular check on kr_vs_kp at n = 1000.
- **I1, I2 (image component, two different angles):** a discrete, pixel-permutation-invariant image member replacing or
  extending `p9_gates`. Dev evaluation: the 8 cells {`qd_dev`, `fashion_mnist`} × n ∈ {1000, 10000} and {`qd_a`, `qd_b`}
  × n ∈ {3000, 10000}, seed 0, plus one large-n check (`qd_a`, n = 60000, seed 0) for error, budget and CPU.

**Integration rule (fixed now).** v3 = v2 with:
- (T) the toy component if, on `designed` + `dlsymdev` + `dlfamdev` (inputs permuted), its mean log2 n* ratio against v2
  is below −0.05 and no dev target is worse than v2 by more than 0.5 in log2;
- (I) the image variant with the lower mean log2(err / v2 err) over the 8 dev image cells, if that mean is below −0.05,
  its `qd_a` n = 60000 error is not above v2's 0.1197 by more than 5% relative, and its CPU per fit there is at most 1.5×
  v2's (1757 s) and within the FLOP budget.
If neither qualifies, v3 = v2.

**Held-out evaluation.**
- *Toy `dlheld7`:* n* (full grid, 3 seeds, inputs permuted) of v3 and v2; references `nets_wd`, `nets_cewd0.3`,
  `nets_cewd1.0` (the variants that were best on `dlheld6`; `nets_best` = their per-target minimum), `lin`, `hgb`.
- *Images `qd_c`, `qd_d`:* test error at n ∈ {1000, 10000, 60000} (3 seeds at n ≤ 10000, seed 0 at n = 60000) of v3,
  v2, v1, `hgb`; MLP references `mlp_strong`, `mlp_wide` (both at those cells), `mlp_xl` (n = 60000, at the weight decay
  `mlp_wide` chose there); the control `mlp_pool` (`qd_c`, n ∈ {10000, 60000}); the context `cnn` (`qd_c`,
  n ∈ {1000, 10000}).
- Verdict rules as in Parts 8–9 (`compare_hybrid.py`).

**Best-learner rule (fixed now).** v3 is the best learner so far if v3 ≠ v2 and, on the held-out sets, its mean log2
error ratio against v2 over the `qd_c` / `qd_d` cells with n ≥ 10000 is below 0 and its mean log2 n* ratio against v2
on `dlheld7` is at most +0.1 (if only one component changed, only that side's criterion applies; the other side is
identical by construction or must be). Otherwise v2 is.

**Interpretability** (after the held-out results, descriptive): on the best learner, on chosen toy targets (whether
the learned features match the target's true structure, and when they are found) and image sets (what the pooled
features and splits encode, class-level and pixel-level maps, prototypes). It is analysis, not evidence for a claim of
superiority.

**Paper:** about the best learner: what it is, how it does against baselines on every suite and dataset of the study,
and the interpretability results.

## Decisions (recorded as they are made)

**(T) toy component — adopted** (27 Oct, 21:35 UTC; computed by `compare_part10.py --dev` from the result files, before
any held-out run of a Part 10 learner). `p10_sum` (DFG v1.3: weighted sum blocks u = t + a·τ, forced blocks at n ≥ 48,
a beam search at n ≤ 128; `p10_sum/learner.py` md5 `5ee995add8601b90ee8b1d5612fede87`, `p10_sum/dfg13.py` md5
`69cabe5c50345cb24079198ed52b562f`, frozen 19:44 UTC) against v2 on `designed` + `dlsymdev` + `dlfamdev` (41 targets,
inputs permuted, 3 seeds): mean log2 n* ratio **−0.066** over the 40 targets both learn (< −0.05), largest per-target
increase **+0.26** (fd_06; ≤ 0.5). v2's dev fits are p9_sum's on `designed` and `dlsymdev` (identical code path on toy
inputs; checked: 110 of 110 seed-0 cells on `designed` equal) and hyb_portfolio2's on `dlfamdev`.

**(I) image component — pending** `p10_codes` (builder I2), which started only when the toy builder finished (the
workflow runs two agents at a time). `p10_hier` (I1; md5 `1da21bf797ca3f247103e31428d74fe5`) qualifies: mean
log2(err / v2 err) over the 8 dev cells **−0.071** against v2's own errors (the builder's −0.068 used Part 9's
p9_gates-dev errors for qd_dev and fashion_mnist; v2 itself was run on those 4 cells for Part 10), qd_a n = 60000 error
0.1108 (≤ 0.1257), 924 CPU s (≤ 2636), FLOP fraction 0.44.

**Scheduling.** v3's behaviour on toy inputs is fixed by (T) whatever (I) decides (the image members run only on images,
and both image candidates leave every non-image path bit-identical to v2), so v3's held-out toy evaluation starts now as
`p10_sum` on `dlheld7`; its results are not read before v3 is frozen, and v3 ≡ p10_sum on toy inputs is checked at
assembly.
