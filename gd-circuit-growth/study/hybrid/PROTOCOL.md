# Part 8 protocol (written before any design result was seen)

**Question.** Is there a discrete learner that beats gradient-descent-trained networks both on the toy Boolean suites of
Parts 1-6 and on the standard tasks of Part 7?

**Data access.** Development uses the toy `designed` suite (21 targets) and the 5 standard DEV datasets only. Final
evaluation: toy suites `random` (20), `dlheld` (12), `dlheld2` (7) and the fresh `dlheld3` (10, defined for Part 8);
standard HELDOUT (13: MNIST, Fashion-MNIST, 11 PMLB) and the fresh HELDOUT2 (10 PMLB), both fixed in commit 04a215b2
before any Part 8 design work.

**Budgets.** Toy: one network training run per fit (1.62e11 FLOPs at d = 30). Standard tasks: 3 MLP training runs per fit
(the baseline MLP's own cost including its learning-rate selection). Everything is counted, model selection included.

**Designs.** Three independent builders (stagewise DFG -> boosted trees; unified boosting over tree / character / linear
weak learners; portfolio + stacking), each frozen after development, then run once on the full dev evaluation.

**Primary design (fixed rule, applied to the full dev evaluation before any held-out run).** Dev scores:
  * toy: mean over targets of log2(n* learner / n* networks) over targets both learn (`eval_toy.py` report), plus the
    clearly-better / clearly-worse counts;
  * real: mean over (dataset, n) cells of log2(err / min(err mlp, err mlp_l2)) with errors floored at 0.002, plus
    better / worse cell counts (> 10 % relative and > 2 s.e.).
A design "beats GD on dev" if on both sides its mean log2 ratio is < 0 and it has more better than worse
targets/cells. The primary design is the one that beats GD on dev with the lowest sum of the two mean log2 ratios; if
none does, the one with the lowest sum. All three frozen designs are evaluated on the held-out sets; the headline is the
primary's.

**Held-out references.** Toy: the study's networks (μP MLP d-128-128-1, Adam, 20000 steps, fixed training sets).
Standard: `mlp` (baseline), `mlp_reg` (L2-regularized MLP selected on validation: `mlp_l2` on tabular, `mlp_l2unit` on
images, now at every n) and `mlp_best` (per cell the best of five MLP variants chosen with hindsight on the test set).
Verdicts as in Part 7 (`compare_hybrid.py`).

## Designation (recorded after the full dev runs, before any held-out run)

Frozen files: `hyb_stage/learner.py` md5 75bbfc0898b78b74000c812fd87cecc3, `hyb_union/learner.py` md5
d780099c98f6551a374775a3ee7de6dd, `hyb_portfolio/learner.py` md5 063bcd91e0b221c948760ec1ba28e042.

Dev scores recomputed independently from the result files (verdicts with Part 7's rule, including the binomial test-set
noise floor, which makes the small dev test sets resolve few cells; the builders' self-reported counts omitted that floor):

| design | toy mean log2 n* ratio | toy better / worse (of 21) | real mean log2 err ratio vs min(mlp, mlp_l2) | real better / worse (of 24) | sum |
|---|---|---|---|---|---|
| hyb_stage | -2.79 | 21 / 0 | -0.122 | 1 / 0 | -2.91 |
| hyb_union | -2.52 | 21 / 0 | -0.127 | 0 / 0 | -2.65 |
| hyb_portfolio | -2.98 | 21 / 0 | -0.248 | 1 / 0 | -3.23 |

hyb_stage and hyb_portfolio beat GD on dev by the rule (hyb_union has no better cell); **the primary design is
hyb_portfolio** (lowest sum; it is also best on each side separately).

Reporting addition fixed now, before held-out runs: per split, the number of datasets on which the learner's mean log2
error ratio (over n) is below 0, with a two-sided exact sign test over datasets.
