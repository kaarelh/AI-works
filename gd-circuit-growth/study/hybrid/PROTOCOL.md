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
