"""Experiment C: average-case-accurate learned verifiers are exploited by proof
search; conservative rule-learned verifiers are not.

Domain: the partial field algebra of ``cil.domains.algebra``.  Every verifier
below is put under the same black-box adversarial prover
(:func:`cil.provers.prove`: bidirectional best-first search over a broad
proposal distribution of target-rule, fallacy, near-miss, arithmetic, random
and goal-directed 'leap' steps; a step is usable iff the verifier accepts it).
The prover is given 23 FALSE goal equations (``1 = 2``, ``x = x + 1``, the
freshman's dream, unguarded ``x/x = 1``, ...) and 33 TRUE target identities
(several of them the same equations under the facts that make them true).

Verifiers compared
  (a) statistical baselines (``cil.baselines.StatisticalVerifier``): logistic
      regression, gradient boosting and a random forest on hashed subterm-shape
      n-gram + tree-edit features, trained (with oracle labels) on human steps
      vs. perturbed human steps, human errors and fallacy instances; thresholds
      calibrated to in-distribution balanced precision 0.95 / 0.99 / 0.999 /
      1.0 (plus the default 0.5);
  (b) conservative LGG / version-space verifiers learned from positive
      examples only (``cil.learners.LGGLearner``): no guards, most-specific
      guards, and most-specific guards learned from a CLEAN corpus;
  (c) the same LGG calculus after the coherence / world-feedback loop
      (``cil.learners.CoherenceRepairer``): pure coherence (no world), bag-level
      and step-level world feedback;
  (d) the ground-truth target calculus.
Metrics: false goals proved within the budget, true goals proved
(productivity), time-to-first-false-proof (verifier queries), false equations
derived per 1000 queries, certainly-invalid accepted steps, and a Goodhart
curve: in-distribution precision vs. P(a search of budget B proves a false
goal) as B grows.

Extension (``--retrain``): PRM800K-style adversarial retraining of the
gradient-boosted verifier on the exploits the prover finds, evaluated on the
same false goals and on fresh held-out false goals.

Usage:
    python experiments/exp_adversarial_prover.py               # main run (4 workers)
    python experiments/exp_adversarial_prover.py --retrain     # extension; then rebuilds the report
    python experiments/exp_adversarial_prover.py --quick       # smoke test (~1 min; --quick --retrain ~1.5 min)
    python experiments/exp_adversarial_prover.py --report-only # rebuild .md / plots from the JSON files
    python experiments/exp_adversarial_prover.py --resume      # skip search tasks already in the .partial.jsonl
Writes results/adversarial_prover.json, adversarial_prover_retrain.json and
adversarial_prover.md (``*_quick.*`` for --quick), plus PNG plots.
Deterministic given the seeds (OMP_NUM_THREADS is pinned to 1; checked across
PYTHONHASHSEED values).  Measured cost on a shared 4-core container under
heavy load from other jobs: main run 20 CPU-minutes (22 min wall), extension
12 CPU-minutes (14 min wall); on 4 idle cores each should take roughly a
quarter of its CPU time plus the serial training phases (an estimate, not
measured here).
Every finished main-run search task is appended to
results/adversarial_prover.partial.jsonl, so an interrupted run loses at most
the tasks in flight (--resume).
"""
from __future__ import annotations

import os

os.environ.setdefault("OMP_NUM_THREADS", "1")       # deterministic, no oversubscription
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")

import argparse
import json
import multiprocessing as mp
import statistics
import sys
import time
from collections import Counter, defaultdict
from functools import lru_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

import numpy as np

from cil.baselines import StatisticalVerifier, binary_metrics, build_step_dataset, calibrate_threshold, roc_auc
from cil.domains.algebra import ALGEBRA, TARGET_RULES, HumanConfig, WorldOracle, generate_corpus
from cil.evaluation import make_invalid_steps, make_valid_steps, recovery_report, unsound_active
from cil.learners import CoherenceConfig, CoherenceRepairer, LGGLearner, prepare_training
from cil.baselines import LabeledExample
from cil.provers import (FALSE_GOALS, FRESH_FALSE_GOALS, TRUE_GOALS, EdgeChecker, ProposalGenerator, RuleSetVerifier,
                         arith_either, prove)

RESULTS = os.path.join(ROOT, "results")

FULL = dict(
    seeds=[0, 1, 2],
    n_train=500,                 # human derivations used for training (every verifier)
    n_heldout=300,               # fresh derivations for the in-distribution calibration / test sets
    n_fallacy_train=300,         # fallacy-instance negatives for the statistical baselines
    n_fallacy_heldout=200,
    noise=dict(noise_rate=0.05, fallacy_rate=0.3),
    b_true=1500,                 # verifier-query budget per TRUE goal (the target calculus needs <= ~1100)
    b_false=3000,                # verifier-query budget per FALSE goal
    stat_models={"gboost": ["t0.5", "p0.9", "p0.95", "p0.99", "p1.0"],
                 "forest": ["t0.5", "p0.99", "p1.0"],
                 "logreg": ["t0.5", "p0.95", "p0.99"]},
    rule_verifiers=["target", "lgg_pos", "lgg_ms", "lgg_ms_clean", "lgg_coherence", "lgg_world_bag",
                    "lgg_world_step"],
    heldout_eval_n=300,
    checkpoints=[1, 3, 10, 30, 100, 300, 1000, 2000, 3000],
)
QUICK = dict(FULL, seeds=[0], n_train=150, n_heldout=100, n_fallacy_train=100, n_fallacy_heldout=60,
             b_true=800, b_false=1000, heldout_eval_n=60,
             stat_models={"gboost": ["t0.5", "p0.99", "p1.0"], "logreg": ["p0.99"]},
             rule_verifiers=["target", "lgg_pos", "lgg_world_step"],
             checkpoints=[1, 3, 10, 30, 100, 300, 1000])

VERIFIER_LABELS = {
    "target": "(d) ground-truth target calculus",
    "lgg_pos": "(b) LGG, positive only, no guards",
    "lgg_ms": "(b) LGG, positive only, most-specific guards",
    "lgg_ms_clean": "(b) LGG, positive only, most-specific guards, CLEAN corpus",
    "lgg_coherence": "(c) LGG + pure coherence (no world)",
    "lgg_world_bag": "(c) LGG + bag-level world feedback",
    "lgg_world_step": "(c) LGG + step-level world feedback",
}
MODEL_LABELS = {"gboost": "gradient boosting", "forest": "random forest", "logreg": "logistic regression"}

CFG = dict(FULL)          # set in main()
DATA = {}                 # seed -> labelled ID datasets (filled in the parent before forking)
MODELS = {}               # (seed, model) -> StatisticalVerifier
THRESH = {}               # (seed, model) -> {threshold name: tau}
CALCS = {}                # (seed, name) -> verifier object


# ---------------------------------------------------------------------------
# Phase 1: data, statistical models, rule-learned calculi
# ---------------------------------------------------------------------------


@lru_cache(maxsize=16)
def corpus_steps(N: int, noisy: bool, seed: int):
    cfg = HumanConfig(**CFG["noise"]) if noisy else HumanConfig()
    return prepare_training(generate_corpus(N, cfg, seed=seed), ALGEBRA)


def build_data(seed: int, with_eval: bool = True):
    """Labelled training set and in-distribution held-out set (split into
    calibration / test halves by derivation parity) for one seed."""
    t0 = time.time()
    lab = WorldOracle(seed=8000 + seed, n_points=30)
    train = build_step_dataset(corpus_steps(CFG["n_train"], True, seed), lab, seed=seed,
                               n_fallacy=CFG["n_fallacy_train"])
    held = build_step_dataset(corpus_steps(CFG["n_heldout"], True, 1000 + seed),
                              WorldOracle(seed=8500 + seed, n_points=30), seed=50 + seed,
                              n_fallacy=CFG["n_fallacy_heldout"])
    cal = [e for e in held if e.group % 2 == 0]
    test = [e for e in held if e.group % 2 != 0]
    return seed, {"train": train, "cal": cal, "test": test, "heldout_eval": eval_heldout(seed) if with_eval else None,
                  "seconds": round(time.time() - t0, 1)}


def eval_heldout(seed: int):
    """The held-out sets of exp_algebra_learning (synthetic valid / invalid steps, ID and OOD)."""
    n = CFG["heldout_eval_n"]
    lab = WorldOracle(seed=10 ** 6 + seed, n_points=60)
    return {
        "valid_id": make_valid_steps(n, "id", seed=100 + seed),
        "valid_ood": make_valid_steps(n, "ood", seed=200 + seed),
        "invalid_id": make_invalid_steps(n, "id", seed=300 + seed, label_oracle=lab),
        "invalid_ood": make_invalid_steps(n, "ood", seed=400 + seed, label_oracle=lab),
    }


def _source_name(e) -> str:
    if e.source.startswith("human"):
        return "human step (valid)" if e.label else "human error (refuted)"
    return {"perturb_any": "perturbation (anywhere)", "perturb_core": "perturbation (in core)",
            "fallacy_inst": "fallacy instance"}.get(e.source, e.source)


def _source_rates(accepted, examples):
    by = defaultdict(list)
    for a, e in zip(accepted, examples):
        by[_source_name(e)].append(int(a))
    return {k: sum(v) / len(v) for k, v in sorted(by.items())}


def id_metrics_rule(accepts, seed: int):
    """In-distribution behaviour of a rule-based verifier on the same test split."""
    test = DATA[seed]["test"]
    acc = [bool(accepts(e.before, e.after, e.facts)) for e in test]
    y = [e.label for e in test]
    m = binary_metrics([1.0 if a else 0.0 for a in acc], y, 0.5)
    m["by_source"] = _source_rates(acc, test)
    return m


def train_stat(args):
    seed, model = args
    t0 = time.time()
    d = DATA[seed]
    v = StatisticalVerifier(model, seed=seed, n_hash=512).fit(d["train"])
    fit_s = time.time() - t0
    out = {"fit_seconds": round(fit_s, 1), "train_size": v.train_size, "train_pos": v.train_pos}
    cal, test = d["cal"], d["test"]
    sc_cal = v.score_batch([(e.before, e.after, e.facts) for e in cal])
    sc_test = v.score_batch([(e.before, e.after, e.facts) for e in test])
    y_cal, y_test = [e.label for e in cal], [e.label for e in test]
    builtin_test = [v.builtin(e.before, e.after) for e in test]
    taus = {}
    for name in sorted({t for ts in CFG["stat_models"].values() for t in ts}):
        taus[name] = 0.5 if name == "t0.5" else calibrate_threshold(sc_cal, y_cal, float(name[1:]))
    out["auc_test"] = roc_auc(sc_test, y_test)
    out["n_cal"], out["n_test"] = len(cal), len(test)
    out["thresholds"] = {}
    H = d["heldout_eval"]
    hscores = {k: v.score_batch([(s.before, s.after, s.facts) for s in steps]) for k, steps in H.items()}
    for name, tau in taus.items():
        m = binary_metrics(sc_test, y_test, tau)
        m["calibration"] = binary_metrics(sc_cal, y_cal, tau)
        acc = [b or s >= tau for b, s in zip(builtin_test, sc_test)]
        m["by_source"] = _source_rates(acc, test)
        m["heldout_eval"] = {k: float(np.mean([v.builtin(s.before, s.after) or sc >= tau
                                               for s, sc in zip(H[k], hscores[k])])) for k in H}
        out["thresholds"][name] = m
    v._cache.clear()
    v._ecache.clear()
    out["seconds"] = round(time.time() - t0, 1)
    return (seed, model), v, taus, out


def build_rule(args):
    seed, name = args
    t0 = time.time()
    info = {}
    if name == "target":
        calc = RuleSetVerifier(TARGET_RULES)
    else:
        noisy = name != "lgg_ms_clean"
        steps = corpus_steps(CFG["n_train"], noisy, seed)
        gmode = "most_specific" if name in ("lgg_ms", "lgg_ms_clean") else "none"
        calc = LGGLearner(ALGEBRA, tagged=True, guard_mode=gmode, m=2).fit(steps=steps)
        mode = {"lgg_coherence": "numeral", "lgg_world_bag": "bag", "lgg_world_step": "step"}.get(name)
        if mode:
            rep = CoherenceRepairer(calc, CoherenceConfig(mode=mode, seed=seed), oracle=WorldOracle(seed=7000 + seed))
            hist = rep.run()
            info["coherence"] = {"mode": mode, "queries": rep.queries, "rounds": len(hist),
                                 "actions": dict(Counter(a["action"] for h in hist for a in h["actions"]))}
        rec = recovery_report(calc)
        un = unsound_active(calc, seed=seed)
        info.update(n_active=len(calc.active()), n_exact=sum(v == "exact" for v in rec.values()),
                    unsound_active=[str(s.rule) for s in un], recovery=rec)
    info["id"] = id_metrics_rule(calc.accepts, seed)
    info["seconds"] = round(time.time() - t0, 1)
    return (seed, name), calc, info


def phase1_task(task):
    if task[0] == "stat":
        return ("stat",) + train_stat(task[1:])
    return ("rule",) + build_rule(task[1:])


# ---------------------------------------------------------------------------
# Phase 2: adversarial search
# ---------------------------------------------------------------------------


def _explain_edge(verifier, a, b, facts):
    """Why the verifier accepted the edge {a, b}: a score or a licensing schema."""
    if isinstance(verifier, StatisticalVerifier):
        if arith_either(a, b):
            return "arith"
        return round(verifier.edge_scores(a, [b], facts)[0], 4)
    for x, y in ((a, b), (b, a)):
        e = verifier.explain(x, y, facts)
        if e is not None:
            if isinstance(e, str):
                return e
            return str(e[0].rule) if hasattr(e[0], "rule") else str(e[0])
    return None


def _compress(at, cps):
    return [sum(1 for q in at if q <= c) for c in cps]


def run_goals(verifier, seed: int):
    proposer = ProposalGenerator()
    edge_oracle = WorldOracle(seed=9000 + seed, n_points=60)
    out = []
    for i, g in enumerate(FALSE_GOALS + TRUE_GOALS):
        budget = CFG["b_true"] if g.true else CFG["b_false"]
        ch = EdgeChecker(verifier)
        r = prove(g, ch, proposer, budget, seed=1000 * seed + i, truth_seed=12345 + seed)
        d = r.to_dict(with_proof=True)
        d.pop("derived_false_at")
        d["derived_false_cp"] = _compress(r.derived_false, CFG["checkpoints"])
        d["true"] = g.true
        d["budget"] = budget
        if r.proved:
            edges = []
            for (a, b), lab in zip(zip(r.proof, r.proof[1:]), r.proof_labels):
                valid = edge_oracle.counterexample(a, b, g.facts, n=60) is None
                edges.append({"from": str(a), "to": str(b), "proposal": lab, "valid": valid,
                              "why": _explain_edge(verifier, a, b, g.facts)})
            d["edges"] = edges
            d["proof_sound"] = all(e["valid"] for e in edges)
        out.append(d)
    return out


def search_task(task):
    t0 = time.time()
    if task["family"] == "statistical":
        key = (task["seed"], task["model"])
        v = MODELS[key].with_threshold(THRESH[key][task["threshold_name"]])
        task = dict(task, threshold=v.threshold)
    else:
        v = CALCS[(task["seed"], task["verifier"])]
    goals = run_goals(v, task["seed"])
    return dict(task, goals=goals, seconds=round(time.time() - t0, 1))


def task_key(t):
    return f"{t['family']}|{t['seed']}|{t.get('model') or t.get('verifier')}|{t.get('threshold_name', '')}"


def build_search_tasks():
    tasks = []
    for seed in CFG["seeds"]:
        for model, ths in CFG["stat_models"].items():
            for th in ths:
                tasks.append({"family": "statistical", "seed": seed, "model": model, "verifier": f"{model}@{th}",
                              "threshold_name": th})
        for name in CFG["rule_verifiers"]:
            tasks.append({"family": "rule", "seed": seed, "verifier": name})
    # expensive tasks first (high thresholds search to the full budget)
    def cost(t):
        if t["family"] != "statistical":
            return 2 + (1 if t["verifier"] in ("lgg_world_step", "lgg_world_bag", "target", "lgg_ms_clean") else 0)
        if t["threshold_name"] in ("p1.0", "p0.99") or t["model"] == "logreg":
            return 10 + (1 if t["model"] == "forest" else 0)
        return 1
    tasks.sort(key=lambda t: -cost(t))
    return tasks


# ---------------------------------------------------------------------------
# Aggregation
# ---------------------------------------------------------------------------


def _ms(xs, fmt="{:.1f}"):
    xs = [x for x in xs if x is not None]
    if not xs:
        return "-"
    if len(xs) == 1:
        return fmt.format(xs[0])
    return (fmt + " ± " + fmt).format(statistics.mean(xs), statistics.pstdev(xs))


def _median_censored(values, budget):
    """Median of a list in which None means 'not within budget' (= +inf)."""
    vs = sorted(float("inf") if v is None else v for v in values)
    if not vs:
        return None
    m = vs[len(vs) // 2] if len(vs) % 2 else 0.5 * (vs[len(vs) // 2 - 1] + vs[len(vs) // 2])
    return m


def config_order(R):
    """Verifier configurations in display order: statistical (by model, threshold), then rule-based."""
    keys = []
    for model, ths in R["config"]["stat_models"].items():
        for th in ths:
            keys.append(f"{model}@{th}")
    keys += R["config"]["rule_verifiers"]
    return keys


def aggregate(R):
    """Per verifier configuration: per-seed summaries."""
    cps = R["config"]["checkpoints"]
    out = {}
    by = defaultdict(list)
    for run in R["runs"]:
        by[run["verifier"]].append(run)
    for key, runs in by.items():
        runs = sorted(runs, key=lambda r: r["seed"])
        per_seed = []
        false_times, first_false = [], []
        for run in runs:
            G = run["goals"]
            F = [g for g in G if not g["true"]]
            T = [g for g in G if g["true"]]
            q = sum(g["queries"] for g in G)
            acc = sum(g["accepted"] for g in G)
            inv = sum(g["invalid_edges_lb"] for g in G)
            per_seed.append({
                "seed": run["seed"], "false_proved": sum(g["proved"] for g in F),
                "true_proved": sum(g["proved"] for g in T),
                "true_proved_sound": sum(g["proved"] and g.get("proof_sound", False) for g in T),
                "derived_false": sum(g["n_derived_false"] for g in G),
                "derived_false_per_1k": 1000 * sum(g["n_derived_false"] for g in G) / max(1, q),
                "invalid_edges_lb": inv, "accepted": acc, "queries": q,
                "search_precision_ub": 1 - inv / acc if acc else None,
                "threshold": run.get("threshold"),
            })
            false_times += [g["queries"] if g["proved"] else None for g in F]
            first_false += [g["first_false"] for g in G]
        cats, schemas = Counter(), Counter()
        n_inv_proof_edges = 0
        for run in runs:
            unsound = set(R["rule_info"].get(str(run["seed"]), {}).get(key, {}).get("unsound_active", []))
            for g in run["goals"]:
                for e in g.get("edges", []):
                    if e["valid"]:
                        continue
                    n_inv_proof_edges += 1
                    cats[edge_category(e["proposal"])] += 1
                    if run["family"] == "rule":
                        why = str(e["why"])
                        schemas[(why.split(": ", 1)[-1], why in unsound)] += 1
        bF = R["config"]["b_false"]
        goodhart = [sum(1 for t in false_times if t is not None and t <= c) / max(1, len(false_times)) for c in cps]
        out[key] = {
            "per_seed": per_seed,
            "median_time_to_false_proof": _median_censored(false_times, bF),
            "median_time_to_first_false_eq": _median_censored(first_false, bF),
            "p_false_proof_within": dict(zip(map(str, cps), goodhart)),
            "n_false_searches": len(false_times),
            "invalid_proof_edges": n_inv_proof_edges,
            "exploit_categories": dict(cats),
            "exploited_schemas": [[k[0], k[1], v] for k, v in schemas.most_common()],
        }
    return out


EDGE_CATEGORIES = ["target rule outside its guard", "fallacy schema", "near-miss schema", "random mutation",
                   "goal-directed leap / graft", "arithmetic", "other"]


def edge_category(label: str) -> str:
    """Kind of proposal that produced a proof edge (for the exploit anatomy)."""
    from cil.domains.algebra import TARGET_BY_NAME
    if label in ("leap", "graft"):
        return "goal-directed leap / graft"
    if label == "mutation":
        return "random mutation"
    if label in ("arith", "arith_bwd"):
        return "arithmetic"
    if label[:4] in ("fwd:", "bwd:"):
        name = label[4:]
        if name in TARGET_BY_NAME:
            return "target rule outside its guard"
        if name.startswith("F_"):
            return "fallacy schema"
        if name.startswith("nm_"):
            return "near-miss schema"
    return "other"


def id_summary(R, key):
    """Mean in-distribution metrics (test split) for a verifier configuration."""
    if "@" in key:
        model, th = key.split("@")
        ms = [R["id_metrics"][str(s)][model]["thresholds"][th] for s in R["config"]["seeds"]
              if model in R["id_metrics"].get(str(s), {})]
    else:
        ms = [R["rule_info"][str(s)][key]["id"] for s in R["config"]["seeds"] if key in R["rule_info"].get(str(s), {})]
    return ms


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------


def _fmt_t(x):
    if x is None:
        return "-"
    if x == float("inf"):
        return "> budget"
    return f"{x:.0f}"


def make_report(R, quick: bool) -> str:
    A = aggregate(R)
    C = R["config"]
    seeds = C["seeds"]
    nF, nT = len(FALSE_GOALS), len(TRUE_GOALS)
    keys = [k for k in config_order(R) if k in A]
    L = []
    P = L.append
    P("# Experiment C: adversarial proof search against learned verifiers\n")
    P(f"_Auto-generated by `experiments/exp_adversarial_prover.py`{' --quick' if quick else ''}; seeds {seeds}; "
      f"mean ± sd over seeds. Raw data: `results/{R['stem']}.json`. Total wall time {R.get('seconds', 0):.0f} s "
      "on a shared, heavily loaded 4-core container._\n")

    P("## Setup\n")
    P(f"* **Domain and corpus.** Partial field algebra (`cil.domains.algebra`). Every learned verifier is trained on "
      f"N = {C['n_train']} simulated human derivations with sporadic noise (5%) and systematic fallacies (rate 0.3). "
      f"The only exception is `lgg_ms_clean`, trained on a clean corpus of the same size.")
    P("* **(a) Statistical baselines (PRM-like).** These are `cil.baselines.StatisticalVerifier` models: logistic "
      "regression, histogram gradient boosting and a random forest. Features are hashed bags of subterm-shape "
      "n-grams of the rewrite core (lhs, rhs and their difference), root-shape pairs, an abstract rule signature, "
      "and numeric tree-edit features. The training data are oracle-labelled:")
    P("  * positives: valid human steps;")
    P("  * negatives: refuted human steps, perturbations of human steps (anywhere, and inside the rewritten core), "
      "and instances of the five known fallacies.")
    P("  So the baselines get *more* supervision than the positive-only rule learner. Thresholds are calibrated on "
      "an in-distribution calibration set to a target balanced precision TPR/(TPR+FPR) (`pX` = precision X: "
      + "; ".join(f"{MODEL_LABELS[m]} " + ", ".join(f"`{t}`" for t in ts) for m, ts in C["stat_models"].items())
      + "). `t0.5` is the default 0.5 threshold. In-distribution numbers below are on a separate test split of "
      f"fresh human derivations (N = {C['n_heldout']}, split by derivation).")
    P("* **(b) Conservative LGG / version-space verifiers, positive examples only** (`cil.learners.LGGLearner`, "
      "tagged, support m = 2):")
    P("  * `lgg_pos`: unguarded schemas;")
    P("  * `lgg_ms`: most-specific guards;")
    P("  * `lgg_ms_clean`: most-specific guards learned from a clean corpus (the realizable, noise-free case).")
    P("* **(c) LGG + coherence / world feedback** (`cil.learners.CoherenceRepairer`, default budget): "
      "`lgg_coherence` is pure coherence with no world; `lgg_world_bag` gets world feedback on derivation "
      "endpoints; `lgg_world_step` gets it on single steps.")
    P("* **(d) `target`**: the ground-truth calculus (41 guarded schemas).")
    P("* **The adversarial prover** (`cil.provers.prove`) is black-box: it sees only accept/reject. It runs a "
      "bidirectional best-first search, and a proof is a path whose every edge is accepted in some orientation. "
      "Candidate steps come from:")
    P("  * target rules, fallacies and near-miss schemas applied forward and backward with guards ignored;")
    P("  * arithmetic, forward and backward;")
    P("  * random mutations;")
    P("  * goal-directed leaps and grafts.")
    P(f"  The budget is verifier queries: {C['b_false']} per false goal and {C['b_true']} per true goal. The goals "
      f"are {nF} FALSE equations and {nT} TRUE identities, listed at the end. Truth is checked by exact evaluation "
      "at random and boundary points with Kleene equality; 'x/x = 1' is false because the lhs is undefined at x = 0.")
    P("* **Metrics.**")
    P("  * *Derived false equations*: every term u reached from a root r gives a derived equation r = u. It is "
      "counted as false when exact evaluation at 5 fixed points refutes it.")
    P("  * *Certainly invalid accepted steps*: accepted edges from a node with r = u unrefuted to a node with "
      "r = v refuted (a lower bound on the invalid steps accepted).")
    P("  * *Search precision*: 1 minus the fraction of accepted edges that are certainly invalid. This is an upper "
      "bound on the precision on the steps the prover actually used.")
    P("  * *Proofs*: every edge of every found proof is checked by a 60-point oracle.\n")

    # ---------------- headline
    P("## Key findings (computed)\n")
    stat_keys = [k for k in keys if "@" in k]
    rule_keys = [k for k in keys if "@" not in k]

    def m(key, field):
        return [s[field] for s in A[key]["per_seed"]]

    def idm(key, field):
        return [x[field] for x in id_summary(R, key)]

    gb = [k for k in stat_keys if k.startswith("gboost@")]
    if gb:
        k05 = "gboost@t0.5" if "gboost@t0.5" in A else gb[0]
        k99 = "gboost@p0.99" if "gboost@p0.99" in A else gb[-1]
        k100 = "gboost@p1.0" if "gboost@p1.0" in A else gb[-1]
        P(f"* **The statistical verifier is accurate in distribution and still proves falsehoods.** Gradient boosting "
          f"reaches test AUC {_ms([R['id_metrics'][str(s)]['gboost']['auc_test'] for s in seeds], '{:.3f}')} and "
          f"accuracy {_ms(idm(k05, 'accuracy'), '{:.3f}')} on held-out human-like steps "
          f"(balanced accuracy {_ms(idm(k05, 'balanced_accuracy'), '{:.3f}')}). At the default threshold the prover "
          f"proves {_ms(m(k05, 'false_proved'))}/{nF} false goals. Calibrated to in-distribution balanced precision "
          f"{_ms(idm(k99, 'balanced_precision'), '{:.3f}')} (`p0.99`, recall {_ms(idm(k99, 'tpr'), '{:.2f}')}), it "
          f"still proves {_ms(m(k99, 'false_proved'))}/{nF}; "
          + (f"the median time-to-false-proof is {_fmt_t(A[k99]['median_time_to_false_proof'])} queries."
             if A[k99]['median_time_to_false_proof'] not in (None, float('inf')) else
             f"the first false equation is derived after a median of "
             f"{_fmt_t(A[k99]['median_time_to_first_false_eq'])} queries."))
        head = ("Even the strictest threshold is exploited." if statistics.mean(m(k100, "false_proved")) > 0 else
                "The strictest threshold avoids false proofs only by giving up productivity.")
        P(f"* **{head}** At `p1.0`, with zero false "
          f"accepts on the calibration set and test balanced precision {_ms(idm(k100, 'balanced_precision'), '{:.4f}')}, "
          f"recall falls to {_ms(idm(k100, 'tpr'), '{:.2f}')}. The verifier then proves only "
          f"{_ms(m(k100, 'true_proved'))}/{nT} true identities and {_ms(m(k100, 'false_proved'))}/{nF} false "
          f"goals. It still commits to {_ms(m(k100, 'derived_false_per_1k'), '{:.0f}')} false derived equations per "
          f"1000 queries, and its precision on the steps the search actually used is at most "
          f"{_ms(m(k100, 'search_precision_ub'), '{:.2f}')}.")
    rpath = os.path.join(RESULTS, f"{R['stem']}_retrain.json")
    if os.path.exists(rpath):
        with open(rpath) as f:
            RTj = json.load(f)
        fr = [RTj["seeds"][sd][0] for sd in sorted(RTj["seeds"])]
        la = [RTj["seeds"][sd][-1] for sd in sorted(RTj["seeds"])]
        P(f"* **Patching the classifier with its own exploits helps but does not make it sound** (section 7). "
          f"After {RTj['config']['rounds']} rounds of PRM800K-style adversarial retraining (gradient boosting, "
          f"`{RTj['config']['precision']}`):")
        P(f"  * false proofs on the harvested goals fall from {statistics.mean(r['patch_false_proved'] for r in fr):.1f} "
          f"to {statistics.mean(r['patch_false_proved'] for r in la):.1f}/{nF};")
        P(f"  * the patched verifier still proves {statistics.mean(r['fresh_false_proved'] for r in la):.1f}/"
          f"{len(FRESH_FALSE_GOALS)} held-out fresh false goals;")
        P(f"  * it still derives {statistics.mean(r['derived_false_per_1k'] for r in la):.1f} false equations per "
          f"1000 queries;")
        P(f"  * it proves {statistics.mean(r['true_proved'] for r in la):.1f}/{nT} true identities.")
    for name in ("lgg_world_step", "lgg_world_bag", "target"):
        if name in A:
            P(f"* **`{name}`** ({VERIFIER_LABELS[name]}): false goals proved {_ms(m(name, 'false_proved'))}/{nF}, "
              f"true goals proved {_ms(m(name, 'true_proved'))}/{nT}, false equations derived "
              f"{_ms(m(name, 'derived_false'), '{:.0f}')}, in-distribution recall {_ms(idm(name, 'tpr'), '{:.3f}')} "
              f"at false-accept rate {_ms(idm(name, 'fpr'), '{:.4f}')}.")
    for name in ("lgg_pos", "lgg_ms", "lgg_ms_clean", "lgg_coherence"):
        if name in A:
            P(f"* `{name}` ({VERIFIER_LABELS[name]}): false goals proved {_ms(m(name, 'false_proved'))}/{nF}, "
              f"true {_ms(m(name, 'true_proved'))}/{nT}, unsound active schemas "
              f"{_ms([len(R['rule_info'][str(s)][name].get('unsound_active', [])) for s in seeds])}.")
    P("")
    interpretation(R, A, P)

    # ---------------- table 1: in-distribution accuracy
    P("## 1. In-distribution accuracy of the verifiers\n")
    P("Test split of fresh human-like steps. The valid steps are the oracle-valid human steps. The invalid steps are "
      "human errors, perturbations and fallacy instances. Columns:")
    P("* *TPR*: recall on valid steps.")
    P("* *FPR*: false-accept rate on invalid steps.")
    P("* *bal. prec.*: TPR/(TPR+FPR).")
    P("* *acc.*: raw accuracy.")
    P("* *eval-ID/OOD*: acceptance on the synthetic held-out sets of `exp_algebra_learning`, given as valid "
      "acceptance / invalid acceptance.\n")
    P("| verifier | threshold τ | AUC | TPR | FPR | bal. prec. | acc. | eval-ID valid/invalid | eval-OOD valid/invalid |")
    P("|---|---|---|---|---|---|---|---|---|")
    for key in keys:
        ms = id_summary(R, key)
        if not ms:
            continue
        if "@" in key:
            model = key.split("@")[0]
            auc = _ms([R["id_metrics"][str(s)][model]["auc_test"] for s in seeds], "{:.3f}")
            tau = _ms([x["threshold"] for x in ms], "{:.4f}")
            he = [x["heldout_eval"] for x in ms]
            eid = f"{_ms([h['valid_id'] for h in he], '{:.2f}')} / {_ms([h['invalid_id'] for h in he], '{:.2f}')}"
            eood = f"{_ms([h['valid_ood'] for h in he], '{:.2f}')} / {_ms([h['invalid_ood'] for h in he], '{:.2f}')}"
        else:
            auc, tau, eid, eood = "-", "-", "-", "-"
        P(f"| `{key}` | {tau} | {auc} | {_ms([x['tpr'] for x in ms], '{:.3f}')} | {_ms([x['fpr'] for x in ms], '{:.4f}')} | "
          f"{_ms([x['balanced_precision'] for x in ms], '{:.4f}')} | {_ms([x['accuracy'] for x in ms], '{:.3f}')} | {eid} | {eood} |")
    P("")
    # by-source acceptance for the GB thresholds
    if gb:
        P("Acceptance rate by source of the step, test split (gradient boosting, mean over seeds):\n")
        srcs = sorted({s for k in gb for x in id_summary(R, k) for s in x["by_source"]})
        P("| threshold | " + " | ".join(srcs) + " |")
        P("|---|" + "---|" * len(srcs))
        for k in gb:
            xs = id_summary(R, k)
            P(f"| `{k.split('@')[1]}` | " + " | ".join(
                _ms([x["by_source"].get(s) for x in xs if s in x["by_source"]], "{:.3f}") for s in srcs) + " |")
        P("")

    # ---------------- table 2: main comparison
    P("## 2. Soundness and productivity under adversarial search\n")
    P("Columns:")
    P(f"* *false proved*: false goals proved (of {nF}; budget {C['b_false']} queries each).")
    P(f"* *true proved*: true goals proved (of {nT}; budget {C['b_true']}). The number in parentheses counts proofs "
      "whose every edge is valid.")
    P("* *t-false*: median queries to a false proof over all (false goal, seed) searches. '> budget' means fewer "
      "than half of them succeeded.")
    P("* *t-first-false-eq*: median queries until the first false equation is derived, over all searches.")
    P("* *false eq./1k q.*: false equations derived per 1000 queries.")
    P("* *invalid steps*: certainly invalid accepted steps, summed over the goals (lower bound).")
    P("* *search prec. ≤*: the upper bound on precision on the accepted steps defined in the setup.")
    P("* *ID bal. prec.* and *ID recall*: from table 1.\n")
    P("| verifier | ID bal. prec. | ID recall | false proved | true proved (sound) | t-false | t-first-false-eq | false eq./1k q. | invalid steps | search prec. ≤ |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for key in keys:
        a = A[key]
        ms = id_summary(R, key)
        P(f"| `{key}` | {_ms([x['balanced_precision'] for x in ms], '{:.4f}')} | {_ms([x['tpr'] for x in ms], '{:.3f}')} | "
          f"{_ms(m(key, 'false_proved'))} | {_ms(m(key, 'true_proved'))} ({_ms(m(key, 'true_proved_sound'))}) | "
          f"{_fmt_t(a['median_time_to_false_proof'])} | {_fmt_t(a['median_time_to_first_false_eq'])} | "
          f"{_ms(m(key, 'derived_false_per_1k'), '{:.1f}')} | {_ms(m(key, 'invalid_edges_lb'), '{:.0f}')} | "
          f"{_ms(m(key, 'search_precision_ub'), '{:.3f}')} |")
    P("")
    P("Plots: `results/adversarial_goodhart.png` (Goodhart curves) and `results/adversarial_frontier.png` "
      "(productivity vs soundness).\n")

    # ---------------- table 3: Goodhart
    P("## 3. Goodhart curve: in-distribution precision vs P(false proof within budget B)\n")
    P(f"P = fraction of the {len(seeds)} × {nF} (seed, false goal) searches that found a proof within B verifier "
      "queries. Thresholds are ordered by in-distribution balanced precision (test split).\n")
    cps = C["checkpoints"]
    P("| verifier | ID bal. prec. | ID FPR | " + " | ".join(f"B={c}" for c in cps) + " |")
    P("|---|---|---|" + "---|" * len(cps))
    for key in keys:
        ms = id_summary(R, key)
        pf = A[key]["p_false_proof_within"]
        P(f"| `{key}` | {_ms([x['balanced_precision'] for x in ms], '{:.4f}')} | {_ms([x['fpr'] for x in ms], '{:.4f}')} | "
          + " | ".join(f"{pf[str(c)]:.2f}" for c in cps) + " |")
    P("")
    # derived false equations vs budget (mean per search)
    P("Mean number of false equations derived per FALSE-goal search, by budget (the search keeps committing to "
      "new falsehoods as B grows):\n")
    P("| verifier | " + " | ".join(f"B={c}" for c in cps) + " |")
    P("|---|" + "---|" * len(cps))
    for key in keys:
        runs = [r for r in R["runs"] if r["verifier"] == key]
        vals = []
        for i, c in enumerate(cps):
            xs = [g["derived_false_cp"][i] for r in runs for g in r["goals"] if not g["true"]]
            vals.append(statistics.mean(xs) if xs else 0)
        P(f"| `{key}` | " + " | ".join(f"{v:.1f}" for v in vals) + " |")
    P("")

    # ---------------- exploit anatomy
    P("## 3b. Anatomy of the exploits\n")
    P("Every invalid edge (oracle-refuted) in every proof found, false or true goal, classified by the proposal that "
      "produced it. A 'target rule outside its guard' edge applies a correct schema where its side condition fails. "
      "Columns give counts summed over seeds.\n")
    P("| verifier | invalid proof edges | " + " | ".join(EDGE_CATEGORIES[:-2]) + " |")
    P("|---|---|" + "---|" * (len(EDGE_CATEGORIES) - 2))
    for key in keys:
        a = A[key]
        if not a["invalid_proof_edges"]:
            continue
        P(f"| `{key}` | {a['invalid_proof_edges']} | " + " | ".join(
            str(a["exploit_categories"].get(c, 0)) for c in EDGE_CATEGORIES[:-2]) + " |")
    P("")
    P("For the rule-learned verifiers every accepted step has a licensing schema, so each invalid proof edge can be "
      "attributed to one. The table below lists those schemas, with whether the schema is among the calculus's "
      "*unsound active* schemas (random soundness test) and how many invalid proof edges it licensed (all seeds):\n")
    for key in rule_keys:
        ex = A[key]["exploited_schemas"]
        if not ex:
            continue
        tot = sum(c for _, _, c in ex)
        flagged = sum(c for _, u, c in ex if u)
        P(f"* `{key}`: {flagged}/{tot} invalid proof edges are licensed by a schema flagged unsound. Most used: "
          + "; ".join(f"`{sch}` ({c}{'' if u else ', not flagged'})" for sch, u, c in ex[:6]) + ".")
    P("")

    # ---------------- table 4: per goal
    P("## 4. Which false goals each verifier proves\n")
    P(f"Entry = number of seeds (of {len(seeds)}) in which the false goal was proved.\n")
    show = [k for k in keys if k in ("gboost@t0.5", "gboost@p0.99", "gboost@p1.0", "forest@p0.99", "forest@p1.0",
                                      "logreg@p0.95", "logreg@p0.99") or "@" not in k]
    P("| false goal | " + " | ".join(f"`{k}`" for k in show) + " |")
    P("|---|" + "---|" * len(show))
    for g in FALSE_GOALS:
        row = []
        for k in show:
            cnt = sum(1 for r in R["runs"] if r["verifier"] == k for x in r["goals"] if x["goal"] == g.name and x["proved"])
            row.append(str(cnt))
        P(f"| `{g}` ({g.note or 'value error'}) | " + " | ".join(row) + " |")
    P("")
    # true goals missed by sound verifiers
    P("True goals NOT proved (seeds in which the proof was missed), for the rule-based verifiers:\n")
    for k in rule_keys:
        miss = Counter(x["goal"] for r in R["runs"] if r["verifier"] == k for x in r["goals"] if x["true"] and not x["proved"])
        P(f"* `{k}`: " + (", ".join(f"{g} ({c})" for g, c in sorted(miss.items())) if miss else "none"))
    P("")

    # ---------------- table 5: what the rule-learned calculi contain
    P("## 5. The rule-learned verifiers: unsound active schemas (responsible for every false proof)\n")
    for k in rule_keys:
        if k == "target":
            continue
        P(f"**`{k}`** ({VERIFIER_LABELS[k]})\n")
        for s in seeds:
            info = R["rule_info"][str(s)][k]
            coh = info.get("coherence")
            extra = f"; coherence: {coh['mode']}, {coh['queries']} oracle queries, actions {coh['actions']}" if coh else ""
            P(f"* seed {s}: {info['n_active']} active schemas, {info['n_exact']}/41 targets exact{extra}; unsound active: "
              + (", ".join(f"`{u.split(': ', 1)[-1]}`" for u in info["unsound_active"]) if info["unsound_active"] else "none"))
        P("")

    # ---------------- examples
    P("## 6. Example false proofs\n")
    P("Each proof is a chain of accepted steps. ✗ marks an edge that the 60-point oracle refutes. Each edge shows "
      "why the verifier accepted it: the classifier's edge score for statistical verifiers, or the licensing schema "
      "for rule-based ones.\n")
    ex_keys = [k for k in ("gboost@p0.99", "gboost@p1.0", "forest@p0.99", "logreg@p0.99", "lgg_pos", "lgg_ms",
                           "lgg_coherence") if k in A]
    for k in ex_keys:
        shown = 0
        seen_goals = set()
        for r in sorted([r for r in R["runs"] if r["verifier"] == k], key=lambda r: r["seed"]):
            for g in r["goals"]:
                if g["true"] or not g["proved"] or g["goal"] in seen_goals or shown >= 3:
                    continue
                seen_goals.add(g["goal"])
                shown += 1
                goal = next(x for x in FALSE_GOALS if x.name == g["goal"])
                P(f"**`{k}`**, seed {r['seed']}, goal `{goal}`, found after {g['queries']} queries:\n")
                P("```")
                P(f"  {g['proof'][0]}")
                for e in g["edges"]:
                    P(f"{'✗' if not e['valid'] else ' '} = {e['to']}    [{e['proposal']}; {e['why']}]")
                P("```\n")
    # ---------------- extension
    rpath = os.path.join(RESULTS, f"{R['stem']}_retrain.json")
    if os.path.exists(rpath):
        with open(rpath) as f:
            retrain_section(json.load(f), P)
    # ---------------- goals
    P("## Goals\n")
    P("False goals: " + "; ".join(f"`{g}`" for g in FALSE_GOALS) + ".\n")
    P("True goals: " + "; ".join(f"`{g}`" for g in TRUE_GOALS) + ".\n")
    return "\n".join(L)


def interpretation(R, A, P):
    C = R["config"]
    nF, nT = len(FALSE_GOALS), len(TRUE_GOALS)
    keys = [k for k in config_order(R) if k in A]
    stat = [k for k in keys if "@" in k]
    rule = [k for k in keys if "@" not in k]

    def mean(key, f):
        xs = [s[f] for s in A[key]["per_seed"] if s[f] is not None]
        return statistics.mean(xs) if xs else None

    def idmean(key, f):
        xs = [x[f] for x in id_summary(R, key)]
        return statistics.mean(xs) if xs else None

    P("## Interpretation\n")
    if stat:
        any_false = [k for k in stat if mean(k, "derived_false") > 0]
        hi = [k for k in stat if (idmean(k, "balanced_precision") or 0) >= 0.99]
        P(f"1. **In-distribution accuracy does not transfer to the search distribution.** "
          f"{len(any_false)} of the {len(stat)} statistical configurations derive false equations under search.")
        if hi:
            worst = min(hi, key=lambda k: mean(k, "search_precision_ub"))
            P("   * The configurations with in-distribution balanced precision ≥ 0.99 are "
              + ", ".join(f"`{k}`" for k in hi) + ".")
            P(f"   * They still prove {min(mean(k, 'false_proved') for k in hi):.1f}–"
              f"{max(mean(k, 'false_proved') for k in hi):.1f} of the {nF} false goals.")
            P(f"   * On the steps the search actually took, their precision is at most "
              f"{mean(worst, 'search_precision_ub'):.3f} (`{worst}`).")
        cats = Counter()
        for k in stat:
            cats.update(A[k]["exploit_categories"])
        tot = sum(cats.values())
        if tot:
            P(f"   * The {tot} invalid proof edges (all statistical configurations and seeds; section 3b) split by "
              "proposal as follows:")
            for c, n in cats.most_common():
                P(f"     * {c}: {100 * n / tot:.0f}%")
            P("     These steps look like human steps and are not. The classifier scores surface similarity to "
              "valid steps, and nothing ties its acceptance region to validity off the training distribution.")
        sound_stat = [k for k in stat if mean(k, "false_proved") == 0]
        if sound_stat:
            bp = max(sound_stat, key=lambda k: mean(k, "true_proved"))
            P(f"   * Among the statistical configurations that proved no false goal, the most productive is `{bp}`. "
              f"It proves {mean(bp, 'true_proved'):.1f}/{nT} true identities and still derives "
              f"{mean(bp, 'derived_false_per_1k'):.0f} false equations per 1000 queries.")
        else:
            P("   * No statistical configuration avoided false proofs within the budget.")
    if "lgg_world_step" in A and "target" in A:
        ws, tg = mean("lgg_world_step", "true_proved"), mean("target", "true_proved")
        P("2. **Rule-learned verifiers fail only through identifiable schemas, and world feedback removes them.**")
        P(f"   * After step-level world feedback, the learned calculus proves {mean('lgg_world_step', 'false_proved'):.1f} "
          f"false goals and derives {mean('lgg_world_step', 'derived_false'):.1f} false equations.")
        P(f"   * It proves {ws:.1f}/{nT} true identities, against {tg:.1f}/{nT} for the ground-truth calculus. "
          + ("Soundness costs no productivity on this benchmark."
             if abs(ws - tg) < 1e-9 else
             f"Soundness costs {tg - ws:.1f} identities per seed (missed goals are listed in section 4)."))
        lacks = Counter()
        for sd in C["seeds"]:
            rec = R["rule_info"][str(sd)]["lgg_world_step"].get("recovery", {})
            for rn, st in rec.items():
                if st in ("missing", "specialized"):
                    lacks[f"{rn} ({st})"] += 1
        if lacks:
            P("   * Target rules that the repaired calculus lacks or holds only in specialised form (number of seeds): "
              + ", ".join(f"{k}: {v}" for k, v in sorted(lacks.items())) + ".")
        flagged = tot_e = 0
        for k in rule:
            for sch, u, c in A[k]["exploited_schemas"]:
                tot_e += c
                flagged += c if u else 0
        if tot_e:
            P(f"   * Every false proof of a rule-learned verifier runs through a named schema. "
              f"{flagged}/{tot_e} of their invalid proof edges are licensed by a schema that the random soundness "
              "test flags as unsound (section 3b).")
            P("   * A counterexample to such a schema deletes it or guards it, and that removes the whole family of "
              "exploits at once. A statistical verifier has no such unit of repair.")
        proj = [(k, sch) for k in rule for sch, u, c in A[k]["exploited_schemas"] if sch == "?X1 + ?X2 -> ?X2"]
        if proj:
            P("   * Example of a noise-born *tonk*: the projection schema `?X1 + ?X2 -> ?X2` (" +
              ", ".join(sorted({f'`{k}`' for k, _ in proj})) + "). Two coincidental noisy human steps give it support "
              "m = 2, and it alone collapses arithmetic (`1 = 1 + 1 = 2`).")
    if "lgg_ms_clean" in A and "lgg_ms" in A and "lgg_pos" in A:
        P("3. **Positive data suffice when they are clean and the guard language is adequate.**")
        P(f"   * `lgg_ms_clean` (most-specific guards, clean corpus) proves {mean('lgg_ms_clean', 'false_proved'):.1f} "
          f"false and {mean('lgg_ms_clean', 'true_proved'):.1f}/{nT} true goals. It plays the role of the "
          "conservative version-space verifier of theory T1, which is sound by construction when the data are "
          "noise-free and the target is realizable.")
        resid = sorted({u.split(": ", 1)[-1] for sd in C["seeds"]
                        for u in R["rule_info"][str(sd)]["lgg_ms_clean"].get("unsound_active", [])})
        if resid:
            nres = sum(bool(R["rule_info"][str(sd)]["lgg_ms_clean"].get("unsound_active")) for sd in C["seeds"])
            P(f"   * Realizability fails at the edges even here. In {nres}/{len(C['seeds'])} seeds an over-specialised "
              "schema is active whose true guard is outside the guard language, since guards only constrain "
              "schematic variables: " + ", ".join(f"`{u}`" for u in resid) + ". The prover did not reach it.")
        P(f"   * On the noisy corpus the same learner (`lgg_ms`) proves {mean('lgg_ms', 'false_proved'):.1f} false "
          f"goals. Without guards (`lgg_pos`) it proves {mean('lgg_pos', 'false_proved'):.1f}.")
        P("   * Systematic human errors and noise therefore require negative information: coherence or world feedback.")
    if "lgg_coherence" in A:
        notes = Counter()
        for r in R["runs"]:
            if r["verifier"] == "lgg_coherence":
                for g in r["goals"]:
                    if not g["true"] and g["proved"]:
                        notes[next(x.note for x in FALSE_GOALS if x.name == g["goal"]) or "value error"] += 1
        P(f"4. **Coherence without world feedback leaves the partiality errors.** `lgg_coherence` proves "
          f"{mean('lgg_coherence', 'false_proved'):.1f} false goals per seed.")
        if notes:
            P("   * By kind (goal × seed): " + "; ".join(f"{k}: {v}" for k, v in notes.most_common()) + ".")
        P("   * Equations such as '0/x = 0' and '0·(1/x) = 0' are true in the total 'meadow' semantics (1/0 = 0) and "
          "false in the partial one. Pure coherence cannot tell these meanings apart. World feedback that can "
          "observe 'undefined' can.")
    perfect = [k for k in keys if (idmean(k, "balanced_precision") or 0) >= 0.999]
    unsound_perfect = [k for k in perfect if mean(k, "false_proved") > 0]
    if unsound_perfect:
        P("5. **In-distribution precision does not rank verifiers by soundness, even among rule-based ones.** These "
          "verifiers have in-distribution balanced precision ≥ 0.999 and still prove false goals:")
        for k in unsound_perfect:
            P(f"   * `{k}`: ID balanced precision {idmean(k, 'balanced_precision'):.4f}, "
              f"{mean(k, 'false_proved'):.1f} false goals.")
        P("   Human-like test steps rarely probe the regions that search reaches: boundary points and "
          "definedness, and steps that pass for a known rule but are not instances of it.")
    sound = [k for k in rule if all(s["derived_false"] == 0 for s in A[k]["per_seed"])]
    tq = sum(s["queries"] for k in sound for s in A[k]["per_seed"])
    P("\n**Caveats.**")
    P("* *The prover is a heuristic black-box search with a modest budget.* 'Not proved' is not 'unprovable'.")
    if sound:
        P("  * The zeros of the rule-based verifiers " + ", ".join(f"`{k}`" for k in sound) + " are not search "
          f"luck. Together they derive no false equation at all in {tq:,} verifier queries.")
    P("  * The false proofs of the statistical verifiers are certified by exact evaluation.")
    P("* *Truth is measured, not proved.* False derived equations are refuted at exact rational points, so these "
      "counts are certain lower bounds. Proof edges are checked by a 60-point oracle. Schema soundness of the "
      "rule-based verifiers is random-tested (`schema_sound`).")
    P("* *The baselines are small models on hand-built features, trained on a few thousand steps.* More capacity "
      "and data would push in-distribution error down. They would not by themselves close the gap, because the "
      "acceptance region of a classifier is not closed under the substitution instances a prover can construct. "
      "Theory T1 Thm 2.1 shows that for every step distribution there are verifiers with arbitrarily small average "
      "error that accept a trivialising step. The experiment does not test whether larger learned verifiers are "
      "exploitable at the same rate.")
    P("* *World feedback is cheap here.* Random evaluation is an almost perfect oracle for these identities. The "
      "soundness of the conservative calculus rests on that oracle having been used during learning (section 5 "
      "lists the oracle queries).")
    P(f"* *Seeds.* {len(C['seeds'])} seed(s); ± is the sd over seeds.\n")


# ---------------------------------------------------------------------------
# Plots
# ---------------------------------------------------------------------------

INK, INK2, MUTED, GRID, SURF = "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#fcfcfb"
SERIES = {"gboost": "#2a78d6", "forest": "#eb6834", "logreg": "#1baf7a"}
BLUE_RAMP = ["#86b6ef", "#5598e7", "#2a78d6", "#1c5cab", "#104281", "#0d366b"]


def _style(ax):
    ax.set_facecolor(SURF)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    for s in ("left", "bottom"):
        ax.spines[s].set_color("#c3c2b7")
    ax.tick_params(colors=INK2, labelsize=8)
    ax.grid(True, color=GRID, linewidth=0.6)
    ax.set_axisbelow(True)


def make_plots(R, stem):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    A = aggregate(R)
    C = R["config"]
    cps = C["checkpoints"]
    keys = [k for k in config_order(R) if k in A]
    nF, nT = len(FALSE_GOALS), len(TRUE_GOALS)

    def idprec(key):
        ms = id_summary(R, key)
        return statistics.mean(x["balanced_precision"] for x in ms) if ms else None

    # ---- Goodhart figure
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), facecolor=SURF)
    ax = axes[0]
    _style(ax)
    gb = [k for k in keys if k.startswith("gboost@")]
    gb_sorted = sorted(gb, key=lambda k: idprec(k))
    ramp = BLUE_RAMP[-len(gb_sorted):] if len(gb_sorted) <= len(BLUE_RAMP) else BLUE_RAMP
    for k, col in zip(gb_sorted, ramp):
        ys = [A[k]["p_false_proof_within"][str(c)] for c in cps]
        ax.plot(cps, ys, color=col, linewidth=2, marker="o", markersize=4,
                label=f"GB {k.split('@')[1]} (ID prec. {idprec(k):.3f})")
    zero = [k for k in keys if "@" not in k and all(A[k]["p_false_proof_within"][str(c)] == 0 for c in cps)]
    for name in ("lgg_pos", "lgg_ms"):
        if name in A and name not in zero:
            ys = [A[name]["p_false_proof_within"][str(c)] for c in cps]
            ax.plot(cps, ys, color=MUTED, linewidth=1.5, linestyle=(0, (4, 2)) if name == "lgg_pos" else ":",
                    label=f"{name} (rule-learned, positive only)")
    if zero:
        ax.plot(cps, [0] * len(cps), color=INK, linewidth=1.5,
                label="never: " + ", ".join(zero))
    ax.set_xscale("log")
    ax.set_ylim(-0.03, 1.03)
    ax.set_xlabel("search budget B (verifier queries)", color=INK2, fontsize=9)
    ax.set_ylabel("P(false goal proved within B)", color=INK2, fontsize=9)
    ax.set_title("Gradient-boosted verifier: false proofs vs budget", color=INK, fontsize=10, loc="left")
    ax.legend(fontsize=7, frameon=False, loc="upper left")

    ax = axes[1]
    _style(ax)
    from matplotlib.lines import Line2D
    Bs = sorted({c for c in (30, 300, C["b_false"]) if c in cps})
    styles = dict(zip(Bs, ((":", "^", 1.0), ("--", "s", 1.0), ("-", "o", 1.8))[-len(Bs):]))
    used = []
    for model, col in SERIES.items():
        mk = [k for k in keys if k.startswith(model + "@")]
        if not mk:
            continue
        used.append(model)
        mk = sorted(mk, key=lambda k: idprec(k))
        xs = [idprec(k) for k in mk]
        for B in Bs:
            ls, mkr, lw = styles[B]
            ys = [A[k]["p_false_proof_within"][str(B)] for k in mk]
            ax.plot(xs, ys, color=col, linestyle=ls, linewidth=lw, marker=mkr, markersize=4.5)
    ax.set_xlabel("in-distribution balanced precision (held-out human-like steps)", color=INK2, fontsize=9)
    ax.set_ylabel("P(false goal proved within B)", color=INK2, fontsize=9)
    ax.set_ylim(-0.03, 1.03)
    ax.set_title("Goodhart curve: ID precision vs exploitability", color=INK, fontsize=10, loc="left")
    h1 = [Line2D([], [], color=SERIES[m], linewidth=2, label=MODEL_LABELS[m]) for m in used]
    h2 = [Line2D([], [], color=INK2, linestyle=styles[B][0], marker=styles[B][1], linewidth=styles[B][2],
                 markersize=4.5, label=f"budget B = {B}") for B in Bs]
    leg = ax.legend(handles=h1, fontsize=7, frameon=False, loc="lower left")
    ax.add_artist(leg)
    ax.legend(handles=h2, fontsize=7, frameon=False, loc="lower center")
    fig.tight_layout()
    fig.savefig(os.path.join(RESULTS, f"{stem}_goodhart.png"), dpi=150, facecolor=SURF)
    plt.close(fig)

    # ---- frontier: productivity vs soundness
    fig, ax = plt.subplots(figsize=(7.2, 4.8), facecolor=SURF)
    _style(ax)

    def mean(key, f):
        return statistics.mean(s[f] for s in A[key]["per_seed"])

    abbrev = {"gboost": "GB", "forest": "RF", "logreg": "LR"}
    pts = []        # (x, y, label) for the annotation pass
    for model, col in SERIES.items():
        mk = [k for k in keys if k.startswith(model + "@")]
        if not mk:
            continue
        mk = sorted(mk, key=lambda k: idprec(k))
        xs = [mean(k, "true_proved") for k in mk]
        ys = [mean(k, "false_proved") for k in mk]
        ax.plot(xs, ys, color=col, linewidth=1.5, marker="o", markersize=7, markeredgecolor=SURF,
                markeredgewidth=1.5, label=f"{MODEL_LABELS[model]} (thresholds)")
        pts += [(x, y, f"{abbrev[model]} {k.split('@')[1]}") for k, x, y in zip(mk, xs, ys)]
    rk = [k for k in keys if "@" not in k]
    for k in rk:
        x, y = mean(k, "true_proved"), mean(k, "false_proved")
        ax.plot([x], [y], marker="D", markersize=7, color=INK if y == 0 else MUTED, markeredgecolor=SURF,
                markeredgewidth=1.5, linestyle="none")
        pts.append((x, y, k))
    # merge the labels of (nearly) co-located points
    clusters = []
    for x, y, lab in pts:
        for c in clusters:
            if abs(c[0] - x) < 1.7 and abs(c[1] - y) < 1.4:
                c[2].append(lab)
                break
        else:
            clusters.append([x, y, [lab]])
    for x, y, labs in clusters:
        left, top = x > 0.75 * nT, y > 0.85 * nF
        ax.annotate(", ".join(labs) if top else "\n".join(labs), (x, y), textcoords="offset points",
                    xytext=((-8 if left else 6), (-7 if top else 4)), ha="right" if left else "left",
                    va="top" if top else "bottom", fontsize=6.5, color=INK2, linespacing=1.1)
    ax.plot([], [], marker="D", color=INK, linestyle="none", label="rule-based verifiers")
    ax.set_xlabel(f"true identities proved (of {nT})  →  productivity", color=INK2, fontsize=9)
    ax.set_ylabel(f"false goals proved (of {nF})  →  unsoundness", color=INK2, fontsize=9)
    ax.set_xlim(-1, nT + 1)
    ax.set_ylim(-1, nF + 1)
    ax.set_title("Soundness vs productivity under adversarial search (mean over seeds)", color=INK, fontsize=10,
                 loc="left")
    ax.legend(fontsize=7, frameon=False, loc="upper left")
    fig.tight_layout()
    fig.savefig(os.path.join(RESULTS, f"{stem}_frontier.png"), dpi=150, facecolor=SURF)
    plt.close(fig)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def run_all(quick: bool, workers: int, resume: bool, stem: str):
    CFG.update(QUICK if quick else FULL)
    t0 = time.time()
    partial = os.path.join(RESULTS, f"{stem}.partial.jsonl")
    done = {}
    if resume and os.path.exists(partial):
        with open(partial) as f:
            for line in f:
                rec = json.loads(line)
                done[task_key(rec)] = rec
    elif os.path.exists(partial):
        os.remove(partial)
    ctx = mp.get_context("fork")
    # phase 1a: labelled datasets
    with ctx.Pool(workers) as pool:
        for seed, d in pool.imap_unordered(build_data, CFG["seeds"]):
            DATA[seed] = d
    print(f"[{time.time() - t0:.0f}s] datasets built: " + ", ".join(
        f"seed {s}: train {len(DATA[s]['train'])}, cal {len(DATA[s]['cal'])}, test {len(DATA[s]['test'])}"
        for s in sorted(DATA)), flush=True)
    # phase 1b: models and calculi
    p1 = [("stat", s, m) for s in CFG["seeds"] for m in CFG["stat_models"]]
    p1 += [("rule", s, n) for s in CFG["seeds"] for n in CFG["rule_verifiers"]]
    p1.sort(key=lambda t: 0 if t[0] == "stat" and t[2] == "gboost" else 1)
    id_metrics = defaultdict(dict)
    rule_info = defaultdict(dict)
    with ctx.Pool(workers) as pool:
        for res in pool.imap_unordered(phase1_task, p1):
            if res[0] == "stat":
                _, key, v, taus, info = res
                MODELS[key], THRESH[key] = v, taus
                id_metrics[str(key[0])][key[1]] = info
            else:
                _, key, calc, info = res
                CALCS[key] = calc
                rule_info[str(key[0])][key[1]] = info
    print(f"[{time.time() - t0:.0f}s] phase 1 done", flush=True)
    # phase 2: searches
    tasks = [t for t in build_search_tasks() if task_key(t) not in done]
    runs = list(done.values())
    with ctx.Pool(workers) as pool, open(partial, "a") as pf:
        for rec in pool.imap_unordered(search_task, tasks):
            runs.append(rec)
            pf.write(json.dumps(rec) + "\n")
            pf.flush()
            nf = sum(g["proved"] for g in rec["goals"] if not g["true"])
            nt = sum(g["proved"] for g in rec["goals"] if g["true"])
            print(f"[{time.time() - t0:.0f}s] {task_key(rec)}: false {nf}, true {nt} ({rec['seconds']}s)", flush=True)
    runs.sort(key=lambda r: (r["seed"], r["verifier"]))
    R = {"stem": stem, "config": {k: v for k, v in CFG.items()}, "id_metrics": id_metrics, "rule_info": rule_info,
         "runs": runs, "goals": {"false": [str(g) for g in FALSE_GOALS], "true": [str(g) for g in TRUE_GOALS]},
         "seconds": round(time.time() - t0, 1)}
    with open(os.path.join(RESULTS, f"{stem}.json"), "w") as f:
        json.dump(R, f, indent=1)
    if os.path.exists(partial):
        os.remove(partial)
    return R


# ---------------------------------------------------------------------------
# Extension: iterated adversarial retraining of the statistical verifier
# ---------------------------------------------------------------------------
#
# PRM800K-style active learning: run the prover, harvest every accepted step
# that is certainly invalid (an edge from an unrefuted to a refuted derived
# equation), add the harvested steps (both orientations, oracle-confirmed) to
# the training negatives, retrain, recalibrate the threshold to the same
# in-distribution precision, repeat.  Exploits are harvested on FALSE_GOALS
# only; FRESH_FALSE_GOALS are never used for harvesting (a held-out test of
# whether the patches generalise).

RETRAIN = dict(seeds=[0, 1], rounds=4, model="gboost", precision="p0.99")
RETRAIN_QUICK = dict(seeds=[0], rounds=1, model="gboost", precision="p0.99")
RT = {}            # current verifier for the forked search workers


def prover_b() -> ProposalGenerator:
    """A differently configured adversary (more mutations, grafts and backward
    instantiations, larger batches) that is never used for harvesting."""
    return ProposalGenerator(n_mutations=20, n_grafts=8, bare_positions=4, n_inst=3, max_props=240)


def _rt_goal(args):
    kind, i, seed, rnd = args
    goals = {"patch": FALSE_GOALS, "fresh": FRESH_FALSE_GOALS, "true": TRUE_GOALS,
             "patchB": FALSE_GOALS, "freshB": FRESH_FALSE_GOALS}[kind]
    g = goals[i]
    harvested = [] if kind == "patch" else None
    budget = CFG["b_true"] if kind == "true" else CFG["b_false"]
    b = kind.endswith("B")
    r = prove(g, EdgeChecker(RT["v"]), prover_b() if b else ProposalGenerator(), budget,
              seed=1000 * seed + 100 * kind.startswith("fresh") + i + 7777 * b, depth_weight=1.0 if b else 0.5,
              truth_seed=12345 + seed, collect_invalid=harvested)
    return kind, i, {"goal": g.name, "proved": r.proved, "queries": r.queries, "first_false": r.first_false,
                     "n_derived_false": len(r.derived_false), "invalid_edges_lb": r.invalid_edges}, \
        [(u, v, g.facts) for u, v in (harvested or [])]


def run_retraining(quick: bool, workers: int):
    rcfg = RETRAIN_QUICK if quick else RETRAIN
    ctx = mp.get_context("fork")
    t0 = time.time()
    out = {"config": dict(rcfg, b_false=CFG["b_false"], b_true=CFG["b_true"], n_train=CFG["n_train"]),
           "fresh_goals": [str(g) for g in FRESH_FALSE_GOALS], "seeds": {}}
    for seed in rcfg["seeds"]:
        _, d = build_data(seed, with_eval=False)
        conf = WorldOracle(seed=8800 + seed, n_points=20)
        extra, seen = [], set()
        rounds = []
        for rnd in range(rcfg["rounds"] + 1):
            v = StatisticalVerifier(rcfg["model"], seed=seed, n_hash=512).fit(d["train"] + extra)
            sc_cal = v.score_batch([(e.before, e.after, e.facts) for e in d["cal"]])
            sc_test = v.score_batch([(e.before, e.after, e.facts) for e in d["test"]])
            y_cal, y_test = [e.label for e in d["cal"]], [e.label for e in d["test"]]
            tau = calibrate_threshold(sc_cal, y_cal, float(rcfg["precision"][1:]))
            idm = binary_metrics(sc_test, y_test, tau)
            idm["auc"] = roc_auc(sc_test, y_test)
            v._cache.clear()
            v._ecache.clear()
            RT["v"] = v.with_threshold(tau)
            tasks = [("patch", i, seed, rnd) for i in range(len(FALSE_GOALS))]
            tasks += [("fresh", i, seed, rnd) for i in range(len(FRESH_FALSE_GOALS))]
            tasks += [("true", i, seed, rnd) for i in range(len(TRUE_GOALS))]
            if rnd in (0, rcfg["rounds"]):          # the second adversary, first and last round only
                tasks += [("patchB", i, seed, rnd) for i in range(len(FALSE_GOALS))]
                tasks += [("freshB", i, seed, rnd) for i in range(len(FRESH_FALSE_GOALS))]
            res = defaultdict(dict)
            harvest = []
            with ctx.Pool(workers) as pool:
                for kind, i, rec, h in pool.imap_unordered(_rt_goal, tasks):
                    res[kind][i] = rec
                    harvest += h
            # oracle-confirmed new negatives (both orientations), deduplicated across rounds
            added = 0
            for u, w, F in sorted(harvest, key=lambda x: (str(x[0]), str(x[1]))):
                if (u, w, F) in seen:
                    continue
                seen.add((u, w, F))
                seen.add((w, u, F))
                if conf.counterexample(u, w, F, n=20) is None:
                    continue
                extra.append(LabeledExample(u, w, F, 0, "exploit", -10 ** 6 - len(extra)))
                extra.append(LabeledExample(w, u, F, 0, "exploit", -10 ** 6 - len(extra)))
                added += 2
            R = {k: [res[k][i] for i in sorted(res[k])] for k in res}
            rounds.append({
                "round": rnd, "threshold": tau, "train_size": len(d["train"]) + len(extra) - added,
                "id": idm, "exploits_harvested": len(harvest), "negatives_added": added,
                "patch_false_proved": sum(x["proved"] for x in R["patch"]),
                "fresh_false_proved": sum(x["proved"] for x in R["fresh"]),
                "true_proved": sum(x["proved"] for x in R["true"]),
                "patch_false_proved_B": sum(x["proved"] for x in R["patchB"]) if "patchB" in R else None,
                "fresh_false_proved_B": sum(x["proved"] for x in R["freshB"]) if "freshB" in R else None,
                "derived_false_per_1k": 1000 * sum(x["n_derived_false"] for k in R if not k.endswith("B")
                                                   for x in R[k])
                / max(1, sum(x["queries"] for k in R if not k.endswith("B") for x in R[k])),
                "goals": R,
            })
            print(f"[{time.time() - t0:.0f}s] retrain seed {seed} round {rnd}: tau {tau:.4f}, ID tpr "
                  f"{idm['tpr']:.3f} fpr {idm['fpr']:.4f}; false proved patch {rounds[-1]['patch_false_proved']}"
                  f"/{len(FALSE_GOALS)}, fresh {rounds[-1]['fresh_false_proved']}/{len(FRESH_FALSE_GOALS)}, true "
                  f"{rounds[-1]['true_proved']}/{len(TRUE_GOALS)}; +{added} negatives", flush=True)
        out["seeds"][str(seed)] = rounds
    out["seconds"] = round(time.time() - t0, 1)
    return out


def retrain_section(RT_, P):
    """Report section for the adversarial-retraining extension."""
    c = RT_["config"]
    seeds = sorted(RT_["seeds"])
    nF, nX, nT = len(FALSE_GOALS), len(FRESH_FALSE_GOALS), len(TRUE_GOALS)
    P("## 7. Extension: patching the statistical verifier with its own exploits\n")
    P(f"This is PRM800K-style adversarial data collection with the {MODEL_LABELS.get(c['model'], c['model'])} "
      f"verifier at `{c['precision']}`, over {c['rounds']} retraining round(s) (rounds 0 to {c['rounds']}) and "
      f"seeds {', '.join(seeds)}. Each round has four steps:")
    P("1. Run the prover.")
    P(f"2. Harvest every certainly-invalid accepted step from the searches on the {nF} false goals of the main "
      "experiment.")
    P("3. Confirm each harvested step with the oracle and add it to the training negatives in both orientations.")
    P("4. Retrain the model and recalibrate the threshold to the same in-distribution precision.")
    P("")
    P(f"The {nX} *fresh* false goals are never harvested. They test whether the patches generalise: "
      + "; ".join(f"`{g}`" for g in RT_["fresh_goals"]) + ".\n")
    P(f"Budgets: {c['b_false']} queries per false goal, {c['b_true']} per true goal. Runtime {RT_['seconds']:.0f} s. "
      "Columns:")
    P("* *+neg.*: harvested negatives added after the round.")
    P("* *false (harvest)*: false goals proved among those used for harvesting.")
    P("* *false (fresh)*: fresh false goals proved.")
    P("* *false eq./1k q.*: false equations derived per 1000 queries over the searches of the harvesting prover.")
    P("* *prover B*: the same false goals attacked by a second, differently configured prover that never "
      "harvests. It uses more mutations, grafts and backward instantiations and a different search seed and "
      "heuristic weight. It runs in the first and last rounds only.\n")
    P("| seed | round | train size | τ | ID AUC | ID TPR | ID FPR | false (harvest) | false (fresh) | prover B: harvest / fresh | true proved | false eq./1k q. | +neg. |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for sd in seeds:
        for r in RT_["seeds"][sd]:
            pb = (f"{r['patch_false_proved_B']}/{nF} / {r['fresh_false_proved_B']}/{nX}"
                  if r.get("patch_false_proved_B") is not None else "-")
            P(f"| {sd} | {r['round']} | {r['train_size']} | {r['threshold']:.4f} | {r['id']['auc']:.4f} | "
              f"{r['id']['tpr']:.3f} | {r['id']['fpr']:.4f} | {r['patch_false_proved']}/{nF} | "
              f"{r['fresh_false_proved']}/{nX} | {pb} | {r['true_proved']}/{nT} | {r['derived_false_per_1k']:.1f} | "
              f"{r['negatives_added']} |")
    P("")
    first = [RT_["seeds"][sd][0] for sd in seeds]
    last = [RT_["seeds"][sd][-1] for sd in seeds]
    P("**Reading.** Between the first and the last round, averaged over seeds:")
    P(f"* false goals proved on the harvested set go from "
      f"{statistics.mean(r['patch_false_proved'] for r in first):.1f} to "
      f"{statistics.mean(r['patch_false_proved'] for r in last):.1f};")
    P(f"* on the fresh set they go from {statistics.mean(r['fresh_false_proved'] for r in first):.1f} to "
      f"{statistics.mean(r['fresh_false_proved'] for r in last):.1f};")
    P(f"* true identities proved go from {statistics.mean(r['true_proved'] for r in first):.1f} to "
      f"{statistics.mean(r['true_proved'] for r in last):.1f};")
    P(f"* false equations derived per 1000 queries go from "
      f"{statistics.mean(r['derived_false_per_1k'] for r in first):.1f} to "
      f"{statistics.mean(r['derived_false_per_1k'] for r in last):.1f};")
    if all(r.get("patch_false_proved_B") is not None for r in first + last):
        P(f"* against prover B, false goals proved go from "
          f"{statistics.mean(r['patch_false_proved_B'] + r['fresh_false_proved_B'] for r in first):.1f} to "
          f"{statistics.mean(r['patch_false_proved_B'] + r['fresh_false_proved_B'] for r in last):.1f} "
          f"(harvest + fresh sets, of {nF + nX});")
    P(f"* the final round harvests {statistics.mean(r['exploits_harvested'] for r in last):.1f} new exploits per seed.")
    P("")
    fresh_last = statistics.mean(r["fresh_false_proved"] for r in last)
    dfe_last = statistics.mean(r["derived_false_per_1k"] for r in last)
    pb_last = (statistics.mean(r["patch_false_proved_B"] + r["fresh_false_proved_B"] for r in last)
               if all(r.get("patch_false_proved_B") is not None for r in last) else None)
    if fresh_last > 0 or dfe_last > 0 or (pb_last or 0) > 0:
        P("**Conclusion.** Adversarial retraining is an effective *practical* mitigation in this small closed domain. "
          "It does not produce a sound verifier. In the last round:")
        P(f"* the patched verifier still proves {fresh_last:.1f} fresh false goals per seed"
          + (f" and {pb_last:.1f} against the second prover" if pb_last is not None else "") + ";")
        P(f"* it still derives {dfe_last:.1f} false equations per 1000 queries;")
        P(f"* it proves {statistics.mean(r['true_proved'] for r in last):.1f}/{nT} true identities.")
        P("")
        P("Its soundness is relative to the attacks it was patched against. Contrast the rule-learned calculus "
          "with step-level world feedback in section 2. Its acceptance region is a finite set of schemas, each "
          "quantified over all instances. One counterexample per unsound schema repairs it (section 5), and it "
          "then derives no false equation at all.\n")
    else:
        P("**Conclusion.** In this run the patched verifier stopped producing false proofs and false derived "
          "equations within the budget. This is evidence of empirical robustness against these provers only. "
          "Nothing guarantees that a different prover would not find new exploits.\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--report-only", action="store_true")
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--retrain", action="store_true",
                    help="run only the adversarial-retraining extension (writes <stem>_retrain.json), then rebuild "
                         "the report from the existing main JSON if there is one")
    args = ap.parse_args()
    stem = "adversarial_prover_quick" if args.quick else "adversarial_prover"
    os.makedirs(RESULTS, exist_ok=True)
    if args.retrain:
        CFG.update(QUICK if args.quick else FULL)
        RT_ = run_retraining(args.quick, args.workers)
        with open(os.path.join(RESULTS, f"{stem}_retrain.json"), "w") as f:
            json.dump(RT_, f, indent=1)
        print(f"wrote results/{stem}_retrain.json")
        if not os.path.exists(os.path.join(RESULTS, f"{stem}.json")):
            return
        args.report_only = True
    if args.report_only:
        with open(os.path.join(RESULTS, f"{stem}.json")) as f:
            R = json.load(f)
        CFG.update(R["config"])
    else:
        R = run_all(args.quick, args.workers, args.resume, stem)
    md = make_report(R, args.quick)
    with open(os.path.join(RESULTS, f"{stem}.md"), "w") as f:
        f.write(md)
    make_plots(R, stem)
    print(f"wrote results/{stem}{'' if args.report_only else '.json, '}.md, _goodhart.png, _frontier.png")


if __name__ == "__main__":
    main()
