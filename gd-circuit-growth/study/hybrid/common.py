"""Common harness for Part 8: one discrete learner, scored on both the toy Boolean suites (against the study's networks)
and the standard tasks (against MLPs).

LEARNER API (the standard-task API, plus a budget):  fit(X, y, types, C, rng, budget=None) -> dict(predict=callable(X) ->
int labels in 0..C-1, flops=float, info=dict).  types in {'binary', 'categorical', 'continuous', 'ordinal'}.
If budget is None the learner must use budget_real(X, types, C, n) (below).

BUDGETS (FLOPs per fit, multiply-add = 2, everything counted including model selection):
  standard tasks: 3 MLP training runs = the baseline MLP's own cost with its learning-rate selection
                  (3 x harness.mlp_flops; the L2 MLP's selection costs 5 runs);
  toy suites:     1 network run (discrete_learner/harness.gd_flops(d)), as for DFG in Part 6.
Library tree boosters (xgboost / lightgbm / sklearn) must be charged an explicit analytic FLOP estimate (documented).

DATA ACCESS RULES: development may use the toy 'designed' suite and the 5 standard DEV datasets only.  The toy suites
'random', 'dlheld', 'dlheld2', 'dlheld3' and the standard HELDOUT and HELDOUT2 datasets are for the final evaluation.
"""
import os, sys, importlib, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "standard_tasks"))
import harness as SH                                      # standard-task harness (and data via SH.DATA)


def budget_real(X, types, C, n):
    return 3.0 * SH.mlp_flops(X, types, C, n)


def toy_budget(d):
    P = d * 128 + 128 + 128 * 128 + 128 + 128
    return 6 * P * 64 * 20000 + 10 * P * 20000           # = discrete_learner.harness.gd_flops(d) for d != 120


class ToyAdapter:
    """Run a standard-API learner on the toy suites: +-1 inputs are 'binary' columns, labels +-1 -> classes {0, 1},
    budget = one network run."""

    def __init__(self, learner):
        self.inner, self.name = learner, learner.name

    def fit(self, X, y, rng):
        X = np.asarray(X, dtype=np.float64); yy = (np.asarray(y) > 0).astype(np.int64)
        if yy.min() == yy.max():                          # one class only (tiny n): predict it
            c = 1.0 if yy[0] == 1 else -1.0
            return dict(predict=lambda Z: np.full(len(Z), c), flops=0.0)
        out = self.inner.fit(X, yy, ["binary"] * X.shape[1], 2, rng, budget=toy_budget(X.shape[1]))
        pr = out["predict"]
        out["predict"] = lambda Z, pr=pr: np.where(np.asarray(pr(np.asarray(Z, dtype=np.float64))) == 1, 1.0, -1.0)
        return out


def load_learner(spec):
    """'module:Class' or 'module:Class:{json kwargs}' (module relative to study/hybrid)."""
    import json
    mod, cls, *kw = spec.split(":", 2)
    return getattr(importlib.import_module(mod), cls)(**(json.loads(kw[0]) if kw else {}))
