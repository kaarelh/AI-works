"""Experiment: learning an algebra calculus from (noisy) human derivations,
then repairing it with coherence / world feedback.

Measures, as a function of the number N of human derivations and of the noise
setting:
  (i)   exact recovery of the 41 target schemas (up to variable renaming, with
        guards compared up to logical equivalence),
  (ii)  whether fallacy schemas are learned,
  (iii) whether coherence / world feedback deletes or repairs them,
  (iv)  soundness of the resulting conservative verifier on held-out VALID and
        INVALID steps, in distribution and out of distribution (terms ~4x larger
        than the humans used), and against a white-box adversarial prover,
  (v)   completeness on held-out valid steps (systematic generalisation).
Baselines: a liberal learner (support threshold m = 1, no coherence) and a
supervised average-case ML verifier (gradient boosting on step features).

Usage:
    python experiments/exp_algebra_learning.py            # full grid (~30 min on 4 cores)
    python experiments/exp_algebra_learning.py --quick    # smoke test (~2 min)
Writes results/algebra_learning.json, results/algebra_learning.md and PNG plots.
Everything is deterministic given the seeds below.
"""
from __future__ import annotations

import argparse
import json
import multiprocessing as mp
import os
import statistics
import sys
import time
from collections import Counter, defaultdict
from functools import lru_cache

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

from cil.domains.algebra import (ALGEBRA, FALLACIES, GUARDED_TARGETS, TARGET_RULES, HumanConfig, WorldOracle,
                                 generate_corpus)
from cil.evaluation import (MLVerifier, acceptance_rates, adversarial_attack, fallacy_report, make_invalid_steps,
                            make_valid_steps, recovery_report, unsound_active)
from cil.learners import CoherenceConfig, CoherenceRepairer, LGGLearner, prepare_training

RESULTS = os.path.join(ROOT, "results")

NOISE = {
    "clean": dict(),
    "sporadic": dict(noise_rate=0.05),
    "fallacies": dict(fallacy_rate=0.3),
    "both": dict(noise_rate=0.05, fallacy_rate=0.3),
}

LEARNERS = {
    # name: (tagged, guard_mode, m, gen_support)
    "tagged": (True, "none", 2, None),
    "untagged": (False, "none", 2, None),
    "tagged_ms": (True, "most_specific", 2, None),
    "untagged_ms": (False, "most_specific", 2, None),
    "untagged_nogen": (False, "none", 2, 0),
    "tagged_m1": (True, "none", 1, None),   # liberal baseline
}

HELDOUT_N = 300

# probing budgets of the coherence search (per schema and round)
BUDGETS = {
    "default": dict(basis_probes=40, probes_per_schema=8),
    "small": dict(basis_probes=10, probes_per_schema=3),
    "tiny": dict(basis_probes=3, probes_per_schema=1),
}


@lru_cache(maxsize=8)
def heldout(seed: int):
    lab = WorldOracle(seed=10 ** 6 + seed, n_points=60)
    return {
        "valid_id": make_valid_steps(HELDOUT_N, "id", seed=100 + seed),
        "valid_ood": make_valid_steps(HELDOUT_N, "ood", seed=200 + seed),
        "invalid_id": make_invalid_steps(HELDOUT_N, "id", seed=300 + seed, label_oracle=lab),
        "invalid_ood": make_invalid_steps(HELDOUT_N, "ood", seed=400 + seed, label_oracle=lab),
    }


@lru_cache(maxsize=64)
def corpus_steps(N: int, noise: str, seed: int):
    corp = generate_corpus(N, HumanConfig(**NOISE[noise]), seed=seed)
    steps = prepare_training(corp, ALGEBRA)
    return steps


_TASK_FIELDS = ("kind", "N", "noise", "seed", "learner", "mode", "nosplit", "budget")


def task_key(t):
    return tuple(str(t.get(k) or "") for k in _TASK_FIELDS)


def corpus_stats(steps):
    kinds = Counter(h.kind.split(":")[0] for h in steps)
    fal = Counter(h.kind.split(":")[1] for h in steps if h.kind.startswith("fallacy"))
    tags = Counter(h.tag for h in steps if h.kind == "valid")
    return {"n_steps": len(steps), "kinds": dict(kinds), "fallacy_counts": dict(fal), "valid_tag_counts": dict(tags)}


def evaluate(accepts, seed: int):
    H = heldout(seed)
    out = {}
    for k, steps in H.items():
        out[k] = acceptance_rates(accepts, steps)
    return out


def evaluate_calc(calc, seed: int, attack: bool = True):
    rec = recovery_report(calc)
    res = {
        "recovery": rec,
        "n_exact": sum(v == "exact" for v in rec.values()),
        "n_shape": sum(v in ("exact", "guard_stronger", "guard_weaker", "guard_incomparable") for v in rec.values()),
        "n_guarded_exact": sum(rec[n] == "exact" for n in GUARDED_TARGETS),
        "n_active": len(calc.active()),
        "n_unsound_active": len(unsound_active(calc, seed=seed)),
        "fallacies": fallacy_report(calc, seed=seed),
        "heldout": evaluate(calc.accepts, seed),
    }
    if attack:
        res["attack"] = adversarial_attack(calc, WorldOracle(seed=5000 + seed), seed=6000 + seed,
                                           trials_per_schema=8)
    return res


def run_task(task):
    kind = task["kind"]
    t0 = time.time()
    N, noise, seed = task["N"], task["noise"], task["seed"]
    steps = corpus_steps(N, noise, seed)
    rec = dict(task)
    rec["corpus"] = corpus_stats(steps)
    if kind in ("positive", "coherence"):
        tagged, gmode, m, gs = LEARNERS[task["learner"]]
        calc = LGGLearner(ALGEBRA, tagged=tagged, guard_mode=gmode, m=m, gen_support=gs).fit(steps=steps)
        if kind == "coherence":
            budget = BUDGETS[task.get("budget") or "default"]
            cfg = CoherenceConfig(mode=task["mode"], seed=seed, allow_split=not task.get("nosplit", False), **budget)
            rep = CoherenceRepairer(calc, cfg, oracle=WorldOracle(seed=7000 + seed))
            hist = rep.run()
            rec["coherence"] = {"queries": rep.queries, "rounds": len(hist),
                                "neg_bags": [h["neg_bags"] for h in hist],
                                "actions": Counter(a["action"] for h in hist for a in h["actions"])}
            if task.get("showcase"):
                rec["showcase"] = {"schemas": [s for s in calc.summary() if s["log"] or s["active"]]}
        rec.update(evaluate_calc(calc, seed, attack=task.get("attack", True)))
        # per-rule recovery vs number of human instances (sample-complexity view)
        tags = rec["corpus"]["valid_tag_counts"]
        rec["per_rule"] = {r.name: [tags.get(r.name, 0), rec["recovery"][r.name]] for r in TARGET_RULES}
    elif kind == "ml":
        ml = MLVerifier(seed=seed).fit(steps, WorldOracle(seed=8000 + seed))
        rec["heldout"] = evaluate(ml.accepts, seed)
        rec["train_size"] = ml.train_size
    rec["seconds"] = round(time.time() - t0, 2)
    return rec


def build_tasks(quick: bool):
    Ns = [20, 100] if quick else [5, 10, 20, 50, 100, 200, 500]
    seeds = [0] if quick else [0, 1, 2]
    coh_Ns = [100] if quick else [20, 50, 100, 200, 500]
    tasks = []
    for seed in seeds:
        for N in Ns:
            for noise in NOISE:
                for lname in ["tagged", "untagged", "tagged_ms", "tagged_m1"]:
                    tasks.append(dict(kind="positive", N=N, noise=noise, seed=seed, learner=lname,
                                      attack=N >= 20))
                if noise == "both":
                    for lname in ["untagged_ms", "untagged_nogen"]:
                        tasks.append(dict(kind="positive", N=N, noise=noise, seed=seed, learner=lname,
                                          attack=N >= 20))
        for N in coh_Ns:
            for noise in (["both"] if quick else ["clean", "fallacies", "both"]):
                for lname in ["tagged", "untagged"]:
                    for mode in ["numeral", "bag", "step"]:
                        tasks.append(dict(kind="coherence", N=N, noise=noise, seed=seed, learner=lname, mode=mode,
                                          showcase=(N == max(coh_Ns) and noise == "both" and seed == 0)))
        for N in ([100] if quick else [50, 200, 500]):
            tasks.append(dict(kind="ml", N=N, noise="both", seed=seed))
        # world-feedback budget sweep
        for N in ([100] if quick else [500]):
            for b in ["tiny", "small"]:
                for mode in ["numeral", "bag", "step"]:
                    tasks.append(dict(kind="coherence", N=N, noise="both", seed=seed, learner="tagged", mode=mode,
                                      budget=b))
        # ablation: coherence without split repair (refuted schemas can only be guarded or deleted)
        for N in ([100] if quick else [200, 500]):
            for lname in ["tagged", "untagged"]:
                tasks.append(dict(kind="coherence", N=N, noise="both", seed=seed, learner=lname, mode="step",
                                  nosplit=True))
    # longest first for better load balancing
    tasks.sort(key=lambda t: -(t["N"] * (3 if t["kind"] == "coherence" else 1)))
    return tasks


# ---------------------------------------------------------------------------
# Aggregation and report
# ---------------------------------------------------------------------------


def _ms(xs, fmt="{:.1f}"):
    xs = [x for x in xs if x is not None]
    if not xs:
        return "-"
    if len(xs) == 1:
        return fmt.format(xs[0])
    return (fmt + " ± " + fmt).format(statistics.mean(xs), statistics.pstdev(xs))


def _mean(xs):
    xs = [x for x in xs if x is not None]
    return statistics.mean(xs) if xs else None


def group(records, **kw):
    kw.setdefault("nosplit", None)
    kw.setdefault("budget", None)
    return [r for r in records if all(r.get(k) == v for k, v in kw.items())]


def fallacy_outcomes(records):
    out = defaultdict(Counter)
    for r in records:
        for f, d in r["fallacies"].items():
            out[f][d["status"]] += 1
    return out


def make_report(records, quick: bool):
    L = []
    P = L.append
    Ns = sorted({r["N"] for r in records if r["kind"] == "positive"})
    cohNs = sorted({r["N"] for r in records if r["kind"] == "coherence"})
    seeds = sorted({r["seed"] for r in records})
    nT = len(TARGET_RULES)
    P("# Algebra: learning inference rules from human steps + coherence / world feedback\n")
    P(f"_Auto-generated by `experiments/exp_algebra_learning.py`{' --quick' if quick else ''}; "
      f"seeds {seeds}; mean ± sd over seeds. Raw data: `results/algebra_learning.json`._\n")
    P("## Setup (short)\n")
    P(f"* **Target calculus**: {nT} oriented rewrite schemas for field algebra over *partial* terms "
      f"({len(GUARDED_TARGETS)} carry guards from the language defined/nonzero/nonneg: "
      + ", ".join(GUARDED_TARGETS) + "), plus built-in numeral arithmetic (trusted computation, not learned).")
    P("* **Human corpus**: N exercises; each step instantiates a target rule (assumptions needed by guards are "
      "stated in the exercise context). Noise settings: `clean`; `sporadic` (5% random mutations: drop an argument, "
      "swap, change operator/numeral, replace a subterm; tagged with a random rule name); `fallacies` (each "
      "opportunity for one of 5 systematic fallacies is taken with prob. 0.3: freshman's dream, unguarded x/x→1, "
      "unguarded sqrt(x²)→x, (a+b)/(c+d)→a/c+b/d, −(a+b)→−a+b); `both`.")
    P("* **Learner**: MDL-clustered Plotkin anti-unification of rewrite cores, bucketed by the human's rule tag "
      "(`tagged`) or by the shape key (`untagged`); `_ms` = guards = most specific conjunction entailed in every "
      "positive instance; `untagged_nogen` = no stage-2 generalisation between well-supported clusters; "
      "`tagged_m1` = liberal baseline with support threshold m = 1.")
    P("* **Conservative verifier**: accept a step iff it is reflexive, a correct numeral evaluation, or an instance "
      "(at a position on the step's difference chain) of an active learned schema with human support ≥ m = 2 whose "
      "guard is entailed by the context facts.")
    P("* **Coherence / world feedback** (Lakatos loop, ≤ 6 rounds): probe every active schema on boundary-basis and "
      "random instances, run short derivations with the learned calculus, detect contradictions, assign blame, then "
      "repair (minimal guard keeping ≥ m human instances) → split (undo an inductive leap: re-cluster the members by "
      "MDL) → delete. Modes: `numeral` = pure coherence (two derivations of distinct numerals from one ground term, "
      "or a derivation contradicting arithmetic; no world); `bag` = world feedback only on derivation endpoints "
      "(length ≥ 2), blame by Ochiai spectrum fault localisation; `step` = world feedback on single steps.")
    P("* **World oracle**: Kleene equality of partial values at boundary corner points + random rational points "
      "(Schwartz–Zippel), restricted to points satisfying the context facts.")
    P(f"* **Held-out sets** (per seed, labelled by an independent 60-point oracle): {HELDOUT_N} valid and "
      f"{HELDOUT_N} invalid steps in distribution (ID, ~10-node terms) and out of distribution (OOD, ~40-node "
      "terms, variable instances ~7 nodes); invalid kinds: fallacy instances, guard violations (instantiated with "
      "terms that vanish / go negative / are undefined), near-miss schemas, random mutations. White-box attack: for "
      "every active schema, instances on large terms whose learned guard is assumed as context facts while other "
      "variables are instantiated adversarially.\n")

    # ---------------- Key findings (all numbers computed from the records)
    P("## Key findings (computed)\n")
    Nmax = max(cohNs) if cohNs else None
    if Nmax:
        def row(kind, **kw):
            return group(records, kind=kind, N=Nmax, noise="both", **kw)
        pos_t = row("positive", learner="tagged")
        P(f"At N = {Nmax} derivations with sporadic noise and systematic fallacies (`both`):\n")
        if pos_t:
            P(f"* **Positive examples alone** (tagged LGG, m = 2): exact recovery {_ms([r['n_exact'] for r in pos_t])}/{nT} "
              f"(lhs→rhs shape {_ms([r['n_shape'] for r in pos_t])}/{nT}), but "
              f"{_ms([r['n_unsound_active'] for r in pos_t])} active schemas are unsound, the verifier accepts "
              f"{_ms([100 * r['heldout']['invalid_ood']['all'] for r in pos_t], '{:.0f}')}% of invalid OOD steps, and the "
              f"white-box prover finds {_ms([r['attack']['accepted_invalid'] for r in pos_t], '{:.0f}')} accepted invalid steps.")
        for mode, label in [("numeral", "Pure coherence (no world feedback)"), ("bag", "Bag-level world feedback"),
                            ("step", "Step-level world feedback")]:
            for lname in ["tagged", "untagged"]:
                g = row("coherence", learner=lname, mode=mode)
                if not g:
                    continue
                P(f"* **{label}**, `{lname}`: exact {_ms([r['n_exact'] for r in g])}/{nT} "
                  f"(guarded {_ms([r['n_guarded_exact'] for r in g])}/{len(GUARDED_TARGETS)}), unsound active "
                  f"{_ms([r['n_unsound_active'] for r in g])}, false accepts ID/OOD "
                  f"{_ms([r['heldout']['invalid_id']['all'] for r in g], '{:.3f}')} / "
                  f"{_ms([r['heldout']['invalid_ood']['all'] for r in g], '{:.3f}')}, completeness ID/OOD "
                  f"{_ms([r['heldout']['valid_id']['all'] for r in g], '{:.3f}')} / "
                  f"{_ms([r['heldout']['valid_ood']['all'] for r in g], '{:.3f}')}, white-box exploits "
                  f"{_ms([r['attack']['accepted_invalid'] for r in g], '{:.1f}')}, oracle queries "
                  f"{_ms([r['coherence']['queries'] for r in g], '{:.0f}')}.")
        ml = row("ml")
        if ml:
            P(f"* **Supervised ML verifier** (same corpus, *with* validity labels): completeness ID/OOD "
              f"{_ms([r['heldout']['valid_id']['all'] for r in ml], '{:.3f}')} / "
              f"{_ms([r['heldout']['valid_ood']['all'] for r in ml], '{:.3f}')}, false accepts ID/OOD "
              f"{_ms([r['heldout']['invalid_id']['all'] for r in ml], '{:.3f}')} / "
              f"{_ms([r['heldout']['invalid_ood']['all'] for r in ml], '{:.3f}')}.")
        allc = group(records, kind="coherence")
        for mode in ["numeral", "bag", "step"]:
            g = [r for r in allc if r["mode"] == mode]
            if g:
                P(f"* Over all {len(g)} `{mode}` runs (N ∈ {cohNs}, noise ∈ clean/fallacies/both, both learners): "
                  f"runs ending with ≥1 unsound active schema: {sum(r['n_unsound_active'] > 0 for r in g)}; "
                  f"runs with ≥1 white-box exploit: {sum(r['attack']['accepted_invalid'] > 0 for r in g)}; "
                  f"mean false-accept OOD {_mean([r['heldout']['invalid_ood']['all'] for r in g]):.4f}.")
        P("")

    # ---------------- Table 1: positive-only learning curves
    P("## 1. Positive examples only (no coherence)\n")
    P("Exact = schema and guard recovered up to renaming/equivalence; shape = lhs→rhs recovered (guard may differ); "
      "unsound = active learned schemas that are semantically unsound; FA-OOD = false-accept rate on invalid OOD "
      "steps; C-OOD = completeness (acceptance) on valid OOD steps.\n")
    for lname in ["tagged", "untagged", "tagged_ms", "tagged_m1"]:
        P(f"### learner `{lname}`\n")
        P(f"| N | noise | exact /{nT} | shape /{nT} | guarded exact /{len(GUARDED_TARGETS)} | unsound active | FA-ID | FA-OOD | C-ID | C-OOD |")
        P("|---|---|---|---|---|---|---|---|---|---|")
        for N in Ns:
            for noise in NOISE:
                g = group(records, kind="positive", learner=lname, N=N, noise=noise)
                if not g:
                    continue
                P(f"| {N} | {noise} | {_ms([r['n_exact'] for r in g])} | {_ms([r['n_shape'] for r in g])} | "
                  f"{_ms([r['n_guarded_exact'] for r in g])} | {_ms([r['n_unsound_active'] for r in g])} | "
                  f"{_ms([r['heldout']['invalid_id']['all'] for r in g], '{:.2f}')} | "
                  f"{_ms([r['heldout']['invalid_ood']['all'] for r in g], '{:.2f}')} | "
                  f"{_ms([r['heldout']['valid_id']['all'] for r in g], '{:.2f}')} | "
                  f"{_ms([r['heldout']['valid_ood']['all'] for r in g], '{:.2f}')} |")
        P("")
    # untagged variants on 'both'
    P("### untagged variants on noise = `both`\n")
    P("| N | learner | exact /41 | shape /41 | unsound active | FA-OOD | C-OOD |")
    P("|---|---|---|---|---|---|---|")
    for N in Ns:
        for lname in ["untagged", "untagged_ms", "untagged_nogen"]:
            g = group(records, kind="positive", learner=lname, N=N, noise="both")
            if g:
                P(f"| {N} | {lname} | {_ms([r['n_exact'] for r in g])} | {_ms([r['n_shape'] for r in g])} | "
                  f"{_ms([r['n_unsound_active'] for r in g])} | "
                  f"{_ms([r['heldout']['invalid_ood']['all'] for r in g], '{:.2f}')} | "
                  f"{_ms([r['heldout']['valid_ood']['all'] for r in g], '{:.2f}')} |")
    P("")

    # fallacies learned (positive only)
    P("### Are fallacies learned from positive data? (noise = `fallacies`/`both`)\n")
    P("Count of runs in which an *active unsound* schema licensing the fallacy exists (status `survived`). "
      "Note: with `guard_mode = none` the guard-dropping fallacies (unguarded x/x→1, sqrt(x²)→x) are learned "
      "whenever the rule itself is learned, because positive examples never display a guard; with most-specific "
      "guards (`tagged_ms`) they are learned only when humans actually commit them (a single unguarded use removes "
      "the guard from the intersection).\n")
    P("| learner | N | " + " | ".join(f.name for f in FALLACIES) + " |")
    P("|---|---|" + "---|" * len(FALLACIES))
    for lname in ["tagged", "tagged_ms"]:
        for N in Ns:
            g = [r for r in group(records, kind="positive", learner=lname, N=N) if r["noise"] in ("fallacies", "both")]
            if not g:
                continue
            fo = fallacy_outcomes(g)
            P(f"| {lname} | {N} | " + " | ".join(f"{fo[f.name]['survived']}/{len(g)}" for f in FALLACIES) + " |")
    P("")
    g = group(records, kind="positive", learner="tagged_ms", noise="clean")
    if g:
        P(f"Control: `tagged_ms` on clean data ends with ≥1 unsound active schema in "
          f"{sum(r['n_unsound_active'] > 0 for r in g)}/{len(g)} runs (most-specific guards are sound when the "
          f"positive data are).\n")

    # sample complexity view
    P("### Recovery vs number of human instances of a rule (`tagged`, all noise settings, positive only)\n")
    P("Fraction of (rule, run) pairs whose schema *shape* was recovered, by the number of valid human instances of "
      "that rule in the corpus.\n")
    bins = [(0, 0), (1, 1), (2, 2), (3, 4), (5, 8), (9, 16), (17, 10 ** 9)]
    P("| instances | pairs | shape recovered |")
    P("|---|---|---|")
    pr = [v for r in group(records, kind="positive", learner="tagged") for v in r["per_rule"].values()]
    for lo, hi in bins:
        sel = [st for n, st in pr if lo <= n <= hi]
        if sel:
            ok = sum(st not in ("missing", "specialized") for st in sel) / len(sel)
            P(f"| {lo}–{hi if hi < 10 ** 9 else '∞'} | {len(sel)} | {ok:.2f} |")
    P("")

    # ---------------- Table 2: coherence
    P("## 2. Coherence / world feedback (Lakatos loop)\n")
    for lname in ["tagged", "untagged"]:
        P(f"### learner `{lname}`\n")
        P(f"| N | noise | mode | exact /{nT} | guarded exact /{len(GUARDED_TARGETS)} | unsound active | FA-ID | FA-OOD | C-ID | C-OOD | "
          "white-box exploits | oracle queries | rounds |")
        P("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for N in cohNs:
            for noise in NOISE:
                base = group(records, kind="positive", learner=lname, N=N, noise=noise)
                rows = [("none (positive only)", base)] + [
                    (mode, group(records, kind="coherence", learner=lname, N=N, noise=noise, mode=mode))
                    for mode in ["numeral", "bag", "step"]]
                if not rows[1][1]:
                    continue
                for mode, g in rows:
                    if not g:
                        continue
                    att = [r["attack"]["accepted_invalid"] for r in g if "attack" in r]
                    q = [r["coherence"]["queries"] for r in g if "coherence" in r]
                    rd = [r["coherence"]["rounds"] for r in g if "coherence" in r]
                    P(f"| {N} | {noise} | {mode} | {_ms([r['n_exact'] for r in g])} | "
                      f"{_ms([r['n_guarded_exact'] for r in g])} | {_ms([r['n_unsound_active'] for r in g])} | "
                      f"{_ms([r['heldout']['invalid_id']['all'] for r in g], '{:.3f}')} | "
                      f"{_ms([r['heldout']['invalid_ood']['all'] for r in g], '{:.3f}')} | "
                      f"{_ms([r['heldout']['valid_id']['all'] for r in g], '{:.2f}')} | "
                      f"{_ms([r['heldout']['valid_ood']['all'] for r in g], '{:.2f}')} | "
                      f"{_ms(att, '{:.0f}')} | {_ms(q, '{:.0f}') if q else '-'} | {_ms(rd, '{:.1f}') if rd else '-'} |")
        P("")

    P("### Fate of each fallacy (all coherence runs with fallacies in the corpus)\n")
    P("`deleted` = learned then removed; `repaired` = guard-dropping fallacy turned into the correctly guarded rule; "
      "`survived` = an active unsound schema still licenses it; `never_learned` = support never reached m.\n")
    P("| learner | mode | " + " | ".join(f.name for f in FALLACIES) + " |")
    P("|---|---|" + "---|" * len(FALLACIES))
    for lname in ["tagged", "untagged"]:
        for mode in ["none", "numeral", "bag", "step"]:
            if mode == "none":
                g = [r for r in group(records, kind="positive", learner=lname)
                     if r["noise"] in ("fallacies", "both") and r["N"] in cohNs]
            else:
                g = [r for r in group(records, kind="coherence", learner=lname, mode=mode)
                     if r["noise"] in ("fallacies", "both")]
            if not g:
                continue
            fo = fallacy_outcomes(g)
            cells = []
            for f in FALLACIES:
                c = fo[f.name]
                cells.append(", ".join(f"{k} {v}" for k, v in sorted(c.items())))
            P(f"| {lname} | {mode} | " + " | ".join(cells) + " |")
    P("")

    P("### Which unsound schemas survive *pure coherence* (`numeral` mode)?\n")
    surv = Counter()
    gnum = group(records, kind="coherence", mode="numeral")
    for r in gnum:
        for name, st in r["recovery"].items():
            if st == "guard_weaker":
                surv[name] += 1
    P(f"Target rules learned with a guard *weaker* than the truth after pure-coherence repair "
      f"(count over {len(gnum)} runs):\n")
    P("| rule | runs |")
    P("|---|---|")
    for name, c in surv.most_common():
        P(f"| {name} | {c} |")
    P("")
    gstep = group(records, kind="coherence", mode="step")
    if gstep:
        P(f"With step-level world feedback the same count is "
          f"{sum(1 for r in gstep for st in r['recovery'].values() if st == 'guard_weaker')} over {len(gstep)} runs.\n")

    # ---------------- Table 3: baselines
    P("## 3. Average-case verifier baseline vs conservative verifier (noise = `both`)\n")
    P("FA = false-accept rate on held-out invalid steps (by kind for OOD); C = acceptance of held-out valid steps.\n")
    P("| N | verifier | C-ID | C-OOD | FA-ID | FA-OOD | FA-OOD fallacy | FA-OOD guard viol. | FA-OOD near miss | FA-OOD mutation |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    mlNs = sorted({r["N"] for r in records if r["kind"] == "ml"})
    for N in mlNs:
        rows = [("ML (supervised GBT)", group(records, kind="ml", N=N, noise="both")),
                ("liberal LGG, m=1", group(records, kind="positive", learner="tagged_m1", N=N, noise="both")),
                ("conservative LGG, positive only", group(records, kind="positive", learner="tagged", N=N, noise="both")),
                ("conservative + step feedback", group(records, kind="coherence", learner="tagged", mode="step", N=N, noise="both")),
                ("conservative + bag feedback", group(records, kind="coherence", learner="tagged", mode="bag", N=N, noise="both")),
                ("conservative + pure coherence", group(records, kind="coherence", learner="tagged", mode="numeral", N=N, noise="both"))]
        for name, g in rows:
            if not g:
                continue
            h = lambda k, sub="all": _ms([r["heldout"][k].get(sub) for r in g], "{:.3f}")
            P(f"| {N} | {name} | {h('valid_id')} | {h('valid_ood')} | {h('invalid_id')} | {h('invalid_ood')} | "
              f"{h('invalid_ood', 'fallacy')} | {h('invalid_ood', 'guard_violation')} | {h('invalid_ood', 'near_miss')} | "
              f"{h('invalid_ood', 'mutation')} |")
    P("")

    # ---------------- Budget sweep
    bud = [r for r in records if r.get("budget")]
    if bud:
        P("## 3c. How much world feedback is needed? (tagged, noise = `both`)\n")
        P("Probing budget per schema and round: tiny = 3 boundary + 1 random probe, small = 10 + 3, default = 40 + 8.\n")
        P("| N | mode | budget | oracle queries | exact /%d | unsound active | FA-OOD | white-box exploits |" % nT)
        P("|---|---|---|---|---|---|---|---|")
        for N in sorted({r["N"] for r in bud}):
            for mode in ["numeral", "bag", "step"]:
                for b in ["tiny", "small", "default"]:
                    g = group(records, kind="coherence", learner="tagged", mode=mode, N=N, noise="both",
                              budget=None if b == "default" else b)
                    if g:
                        P(f"| {N} | {mode} | {b} | {_ms([r['coherence']['queries'] for r in g], '{:.0f}')} | "
                          f"{_ms([r['n_exact'] for r in g])} | {_ms([r['n_unsound_active'] for r in g])} | "
                          f"{_ms([r['heldout']['invalid_ood']['all'] for r in g], '{:.3f}')} | "
                          f"{_ms([r['attack']['accepted_invalid'] for r in g], '{:.1f}')} |")
        P("")

    # ---------------- Ablation
    abl = [r for r in records if r.get("nosplit")]
    if abl:
        P("## 3b. Ablation: step-level repair without SPLIT (noise = `both`)\n")
        P("| N | learner | repair | exact /%d | unsound active | C-ID | C-OOD | white-box exploits |" % nT)
        P("|---|---|---|---|---|---|---|---|")
        for N in sorted({r["N"] for r in abl}):
            for lname in ["tagged", "untagged"]:
                for lab, g in [("guard→split→delete", group(records, kind="coherence", learner=lname, mode="step", N=N, noise="both")),
                               ("guard→delete", group(records, kind="coherence", learner=lname, mode="step", N=N, noise="both", nosplit=True))]:
                    if g:
                        P(f"| {N} | {lname} | {lab} | {_ms([r['n_exact'] for r in g])} | {_ms([r['n_unsound_active'] for r in g])} | "
                          f"{_ms([r['heldout']['valid_id']['all'] for r in g], '{:.3f}')} | "
                          f"{_ms([r['heldout']['valid_ood']['all'] for r in g], '{:.3f}')} | "
                          f"{_ms([r['attack']['accepted_invalid'] for r in g], '{:.1f}')} |")
        P("")

    # ---------------- Showcase
    sc = [r for r in records if r.get("showcase")]
    if sc:
        P("## 4. Showcase: repair logs (N = %d, noise = both, seed 0)\n" % sc[0]["N"])
        for r in sorted(sc, key=lambda r: (r["learner"], r["mode"])):
            if r["learner"] != "tagged":
                continue
            P(f"### mode `{r['mode']}`\n")
            P("```")
            interesting = [s for s in r["showcase"]["schemas"] if s["log"]]
            for s in interesting[:40]:
                P(f"{s['rule']}   [tag {s['tag']}, support {s['support']}, {'ACTIVE' if s['active'] else s['status']}]")
                for line in s["log"]:
                    P(f"      {line}")
            P("```\n")
    P("## 5. Runtime\n")
    P(f"Total task time {sum(r['seconds'] for r in records):.0f} s over {len(records)} tasks; "
      f"max single task {max(r['seconds'] for r in records):.0f} s.\n")
    return "\n".join(L)


def make_plots(records):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception:
        return []
    files = []
    colors = {"none": "#8a8f98", "numeral": "#d08c2d", "bag": "#4a7fc1", "step": "#2e9e6b"}
    for metric, ylabel, fname in [("n_exact", "exact recovery (of 41)", "algebra_exact_recovery.png"),
                                  ("fa_ood", "false-accept rate, invalid OOD steps", "algebra_false_accept.png"),
                                  ("n_unsound_active", "unsound active schemas", "algebra_unsound.png")]:
        fig, axes = plt.subplots(1, 2, figsize=(10, 3.8), sharey=True)
        for ax, lname in zip(axes, ["tagged", "untagged"]):
            for mode in ["none", "numeral", "bag", "step"]:
                xs, ys = [], []
                Ns = sorted({r["N"] for r in records if r["kind"] == "coherence"})
                for N in Ns:
                    if mode == "none":
                        g = group(records, kind="positive", learner=lname, N=N, noise="both")
                    else:
                        g = group(records, kind="coherence", learner=lname, N=N, noise="both", mode=mode)
                    if not g:
                        continue
                    vals = [r["heldout"]["invalid_ood"]["all"] if metric == "fa_ood" else r[metric] for r in g]
                    xs.append(N)
                    ys.append(_mean(vals))
                if xs:
                    ax.plot(xs, ys, marker="o", color=colors[mode], label=mode if mode != "none" else "positive only")
            ax.set_xscale("log")
            ax.set_title(f"{lname} learner, noise = both")
            ax.set_xlabel("human derivations N")
            ax.grid(alpha=0.3)
        axes[0].set_ylabel(ylabel)
        axes[0].legend(fontsize=8)
        fig.tight_layout()
        path = os.path.join(RESULTS, fname)
        fig.savefig(path, dpi=130)
        plt.close(fig)
        files.append(path)
    return files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--out", default=None)
    ap.add_argument("--resume", action="store_true", help="only run tasks missing from the saved JSON")
    ap.add_argument("--report-only", action="store_true",
                    help="regenerate the markdown report and plots from the saved JSON")
    args = ap.parse_args()
    os.makedirs(RESULTS, exist_ok=True)
    if args.report_only:
        stem = args.out or ("algebra_learning_quick" if args.quick else "algebra_learning")
        with open(os.path.join(RESULTS, stem + ".json")) as f:
            records = json.load(f)["records"]
        with open(os.path.join(RESULTS, stem + ".md"), "w") as f:
            f.write(make_report(records, args.quick))
        if not args.quick:
            make_plots(records)
        return
    tasks = build_tasks(args.quick)
    stem = args.out or ("algebra_learning_quick" if args.quick else "algebra_learning")
    records = []
    if args.resume and os.path.exists(os.path.join(RESULTS, stem + ".json")):
        with open(os.path.join(RESULTS, stem + ".json")) as f:
            records = json.load(f)["records"]
        done = {task_key(r) for r in records}
        tasks = [t for t in tasks if task_key(t) not in done]
    print(f"{len(tasks)} tasks", flush=True)
    t0 = time.time()
    ctx = mp.get_context("fork")
    with ctx.Pool(args.workers, maxtasksperchild=40) as pool:
        for i, rec in enumerate(pool.imap_unordered(run_task, tasks, chunksize=1)):
            records.append(rec)
            if (i + 1) % 20 == 0:
                print(f"  {i + 1}/{len(tasks)} done, {time.time() - t0:.0f}s", flush=True)
    key = lambda r: (r["kind"], r.get("learner", ""), r.get("mode", ""), bool(r.get("nosplit")),
                     r.get("budget") or "", r["noise"], r["N"], r["seed"])
    records.sort(key=key)
    with open(os.path.join(RESULTS, stem + ".json"), "w") as f:
        json.dump({"records": records, "wall_seconds": time.time() - t0}, f, indent=1, default=str)
    report = make_report(records, args.quick)
    with open(os.path.join(RESULTS, stem + ".md"), "w") as f:
        f.write(report)
    if not args.quick:
        make_plots(records)
    print(f"done in {time.time() - t0:.0f}s", flush=True)


if __name__ == "__main__":
    main()
