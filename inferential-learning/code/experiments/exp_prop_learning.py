"""Experiment B: learning natural deduction (sequent form) from human proofs,
coherence pruning, sparse world feedback, and Post-completeness.

Parts
-----
``learning``  For the version-space learner (tagged MDL anti-unification with
              most-specific membership guards), its untagged variant and an
              'aggressive' learner (plain LGG per coarse bucket, Plotkin style):
              positive learning, + coherence pruning (designated coherent contexts
              only, no world), + coherence with sparse world feedback (2 observed
              valuations), as functions of the number N of human proofs and of
              the noise setting.  Measures: unsound active rules, exact recovery
              of the 13 classical ND rules, fallacy fates, an adversarial prover
              (derivations of bottom / non-tautologies accepted step by step by
              the learned verifier), completeness on random tautologies within a
              budget (next to the target calculus under the same budget), and
              acceptance of held-out valid/invalid steps.
``blame``     Blame priors for coherence-only pruning: support-weighted hitting sets
              versus repair-cost weights, against the aggressive learner.
``post``      Post-completeness with a 'bold' learner: candidate schemas (hand
              picked, pairwise LGGs of target rules, random schemas) are added to
              classical ND iff no derivation of bottom from the empty context is
              found; checks that coherent <=> classically valid, exhibits the
              derivations; non-structural rules and the role of designated
              contexts / world feedback; tonk and order dependence.
``ipc``       Intuitionistic contrast: excluded middle etc. are coherent over IPC
              (certified by classical soundness), not IPC-derivable (certified by
              Kripke countermodels), and change the logic; a bold learner trained
              on intuitionistic human proofs ends classical.

Usage::

    python experiments/exp_prop_learning.py                 # everything (3 worker processes)
    python experiments/exp_prop_learning.py --quick         # smoke test
    python experiments/exp_prop_learning.py --part post     # one part
    python experiments/exp_prop_learning.py --resume        # continue an interrupted learning grid
    python experiments/exp_prop_learning.py --report-only   # rebuild .md / plots from the JSON

Writes results/prop_learning.json, results/prop_learning.md and PNG plots.
Deterministic given the seeds (all randomness is seeded; dictionaries are
iterated in sorted order).
"""
from __future__ import annotations

import argparse
import json
import multiprocessing as mp
import os
import random
import statistics
import sys
import time
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

from cil.domains.prop import (BOT, CLASSICAL_RULES, FALLACY_RULES, INTUITIONISTIC_RULES, TARGET_BY_NAME, TONK_E,
                              TONK_I, PropHumanConfig, PropWorld, Prover, Seq, SeqRule, designated_contexts, fmt,
                              format_proof, generate_corpus, kripke_countermodel, kripke_valid_formula,
                              parse_formula, parse_rule, proof_steps, random_formula, random_tautologies,
                              rule_sound, tonk_interpretable, valid)
from cil.prop_eval import (acceptance_rates, adversarial_attack, completeness, fallacy_report, heldout_steps,
                           recovery_report, tonk_like, unsound_active)
from cil.seqlearn import BoldLearner, CoherencePruner, PruneConfig, SeqLearner, prepare_training
from cil.terms import App, Var, lgg_tuples

RESULTS = os.path.join(ROOT, "results")
STEM = "prop_learning"

LEARNERS = {
    "vs": dict(key_mode="tag", cluster="mdl"),
    "vs_untagged": dict(key_mode="abstract", cluster="mdl"),
    "aggressive": dict(key_mode="coarse", cluster="lgg"),
}
NOISE = {
    "clean": dict(),
    "fallacies": dict(fallacy_rate=0.3),
    "noise": dict(noise_rate=0.05),
    "both": dict(fallacy_rate=0.3, noise_rate=0.05),
}
PHASES = ["positive", "coherence", "world"]
EVAL = dict(n_taus=25, taus_conn=(2, 5), comp_budget=2000, attack_budget=1000, attack_random=8, heldout_n=120)
PRUNE = dict(n_designated=4, n_world=2)


# ---------------------------------------------------------------------------
# Evaluation with caching (identical calculi are evaluated once per process)
# ---------------------------------------------------------------------------

_CACHE = {}


def _taus(seed):
    k = ("taus", seed)
    if k not in _CACHE:
        _CACHE[k] = random_tautologies(EVAL["n_taus"], seed=31337 + seed, conn_range=EVAL["taus_conn"])
    return _CACHE[k]


def _heldout(seed):
    k = ("heldout", seed)
    if k not in _CACHE:
        _CACHE[k] = heldout_steps(seed, n=EVAL["heldout_n"])
    return _CACHE[k]


def target_completeness(seed, rules=CLASSICAL_RULES, name="classical"):
    k = ("target", name, seed)
    if k not in _CACHE:
        _CACHE[k] = completeness([(r.name, r) for r in rules], _taus(seed), EVAL["comp_budget"])
    return _CACHE[k]


def evaluate(calc, seed: int, examples: bool = False) -> dict:
    sig = (tuple(sorted(str(lr.rule.canonical()) for lr in calc.active())), seed)
    if sig in _CACHE:
        r = dict(_CACHE[sig])
        r["cached"] = True
        return r
    act = calc.active()
    uns = unsound_active(calc)
    rec = recovery_report(calc)
    att = adversarial_attack(calc, seed, n_random=EVAL["attack_random"], budget=EVAL["attack_budget"],
                             n_contexts=4)
    comp = completeness(calc.rule_list(), _taus(seed), EVAL["comp_budget"])
    sound_rules = [(sid, r) for sid, r in calc.rule_list() if rule_sound(r)]
    comp_s = comp if len(sound_rules) == len(calc.rule_list()) else completeness(sound_rules, _taus(seed),
                                                                                 EVAL["comp_budget"])
    base = target_completeness(seed)
    rates = acceptance_rates(calc.accepts, _heldout(seed))
    out = {
        "n_active": len(act), "n_unsound": len(uns), "unsound_rules": [str(lr.rule) for lr in uns][:20],
        "n_tonk_like": sum(tonk_like(lr.rule) for lr in act),
        "recovery": rec, "n_exact": sum(v == "exact" for v in rec.values()),
        "n_exact_or_stronger": sum(v in ("exact", "guard_stronger") for v in rec.values()),
        "fallacies": {k: v["status"] for k, v in fallacy_report(calc).items()},
        "attack": {k: att[k] for k in ("n_goals", "n_exploits", "rate", "derives_bottom", "exploited_goals")},
        "attack_examples": att["examples"][:1] if examples else [],
        "completeness_any": comp["frac"], "completeness": comp_s["frac"], "completeness_target": base["frac"],
        "completeness_rel": comp_s["proved"] / max(1, base["proved"]),
        "heldout": rates,
    }
    _CACHE[sig] = out
    return out


# ---------------------------------------------------------------------------
# Learning grid
# ---------------------------------------------------------------------------


def task_key(t):
    return f"{t['learner']}|{t['N']}|{t['noise']}|{t['seed']}|{t.get('weight', 'repair')}|{t.get('guard', 'ms')}"


def run_task(t) -> dict:
    t0 = time.time()
    c0 = time.process_time()
    cfg = PropHumanConfig(**NOISE[t["noise"]])
    ds = generate_corpus(t["N"], cfg, seed=t["seed"])
    steps = prepare_training(ds)
    learner = SeqLearner(**LEARNERS[t["learner"]],
                         guard_mode="most_specific" if t.get("guard", "ms") == "ms" else "none")
    calc0 = learner.fit(steps=steps)
    kinds = Counter(h.kind for h in steps)
    rec = {"task": t, "key": task_key(t), "corpus": {"n_steps": len(steps), "kinds": dict(sorted(kinds.items()))},
           "phases": {}}
    phases = t.get("phases", PHASES)
    for ph in phases:
        t1 = time.time()
        calc = calc0.copy()
        info = {}
        if ph != "positive":
            pc = PruneConfig(seed=t["seed"], use_world=(ph == "world"), weight=t.get("weight", "repair"),
                             n_designated=PRUNE["n_designated"], n_world=PRUNE["n_world"])
            pr = CoherencePruner(calc, pc, learner)
            hist = pr.run()
            acts = Counter(a["action"] for h in hist for a in h["actions"])
            info = {"rounds": len(hist), "queries": pr.queries, "search_nodes": pr.search_nodes,
                    "actions": dict(sorted(acts.items())),
                    "lost_steps": sum(a.get("lost", 0) for h in hist for a in h["actions"]),
                    "example_bag": pr.examples[0] if pr.examples else None}
        ev = evaluate(calc, t["seed"], examples=(t["N"] == 100 and t["noise"] == "both"))
        ev.update(info)
        ev["seconds"] = round(time.time() - t1, 1)
        rec["phases"][ph] = ev
    rec["seconds"] = round(time.time() - t0, 1)
    rec["cpu_seconds"] = round(time.process_time() - c0, 1)
    return rec


def build_tasks(quick: bool):
    tasks = []
    if quick:
        for N in (10, 50):
            tasks.append(dict(learner="vs", N=N, noise="both", seed=0))
        tasks.append(dict(learner="aggressive", N=20, noise="clean", seed=0))
        return tasks
    seeds = [0, 1, 2]
    for N in (5, 10, 20, 50, 100, 200):
        for noise in NOISE:
            for s in seeds:
                tasks.append(dict(learner="vs", N=N, noise=noise, seed=s))
    for lname, Ns in (("vs_untagged", (10, 50, 100)), ("aggressive", (10, 50, 200))):
        for N in Ns:
            for noise in ("clean", "both"):
                for s in seeds:
                    tasks.append(dict(learner=lname, N=N, noise=noise, seed=s))
    # blame priors (coherence only): support-weighted vs repair-cost hitting sets
    for lname in ("aggressive", "vs"):
        for noise in ("clean", "both"):
            for s in seeds:
                tasks.append(dict(learner=lname, N=50, noise=noise, seed=s, weight="support",
                                  phases=["coherence"]))
    # no guards from positives: the assumption rule must be monster-barred by coherence
    for noise in ("clean", "fallacies"):
        for s in seeds:
            tasks.append(dict(learner="vs", N=50, noise=noise, seed=s, guard="none",
                              phases=["positive", "coherence"]))
    return tasks


def run_learning(quick: bool, workers: int, resume: bool):
    tasks = build_tasks(quick)
    stem = STEM + ("_quick" if quick else "")
    partial = os.path.join(RESULTS, stem + ".partial.jsonl")
    done = {}
    if resume and os.path.exists(partial):
        with open(partial) as f:
            for line in f:
                r = json.loads(line)
                done[r["key"]] = r
    elif os.path.exists(partial):
        os.remove(partial)
    todo = [t for t in tasks if task_key(t) not in done]
    # heavy tasks first for better load balance
    todo.sort(key=lambda t: (-t["N"], t["learner"], t["noise"], t["seed"]))
    print(f"learning grid: {len(tasks)} tasks, {len(todo)} to run, {workers} workers", flush=True)
    t0 = time.time()
    if workers > 1 and len(todo) > 1:
        with mp.Pool(workers) as pool:
            for i, r in enumerate(pool.imap_unordered(run_task, todo)):
                done[r["key"]] = r
                with open(partial, "a") as f:
                    f.write(json.dumps(r) + "\n")
                print(f"  [{i + 1}/{len(todo)}] {r['key']} {r['seconds']}s wall, {r.get('cpu_seconds')}s cpu "
                      f"(elapsed {time.time() - t0:.0f}s)", flush=True)
    else:
        for i, t in enumerate(todo):
            r = run_task(t)
            done[r["key"]] = r
            with open(partial, "a") as f:
                f.write(json.dumps(r) + "\n")
            print(f"  [{i + 1}/{len(todo)}] {r['key']} {r['seconds']}s", flush=True)
    return [done[task_key(t)] for t in tasks], time.time() - t0


# ---------------------------------------------------------------------------
# Post-completeness: the bold learner
# ---------------------------------------------------------------------------

HAND_CANDIDATES = [
    # (name, rule string(s), comment)
    ("p -> q (axiom schema)", ["/ G |- A -> B"], "any implication"),
    ("Peirce", ["/ G |- ((A -> B) -> A) -> A"], "classically valid"),
    ("excluded middle", ["/ G |- A | ~A"], "classically valid"),
    ("double negation elim.", ["G |- ~~A / G |- A"], "classically valid"),
    ("(A -> B) -> C |- A -> B -> C", ["G |- (A -> B) -> C / G |- A -> B -> C"], "valid although it looks wrong"),
    ("A -> B -> C |- (A -> B) -> C", ["G |- A -> B -> C / G |- (A -> B) -> C"], "invalid converse"),
    ("A | B |- A", ["G |- A | B / G |- A"], "disjunction elimination without cases"),
    ("affirming the consequent", ["G |- A -> B ; G |- B / G |- A"], "fallacy AC"),
    ("denying the antecedent", ["G |- A -> B ; G |- ~A / G |- ~B"], "fallacy DA"),
    ("illegitimate discharge", ["G |- A -> B ; G, A |- A / G |- B"], "fallacy ID (scope error)"),
    ("assumption dropping", ["G, A |- B / G |- B"], "context bookkeeping error"),
    ("converse", ["G |- A -> B / G |- B -> A"], ""),
    ("wrong De Morgan", ["G |- ~(A & B) / G |- ~A & ~B"], ""),
    ("A |- A & B", ["G |- A / G |- A & B"], ""),
    ("contraposition (valid)", ["G |- A -> B / G |- ~B -> ~A"], "classically valid"),
    ("tonk-like A |- B", ["G |- A / G |- B"], "over-generalised anti-unification"),
    ("unguarded assumption rule", ["/ G |- A"], "positive data never show the side condition"),
    ("tonk (I and E together)", ["G |- A / G |- A tonk B", "G |- A tonk B / G |- B"], "Prior 1960"),
    ("weakening (valid)", ["G |- B / G, A |- B"], "admissible structural rule"),
    ("|- p  (non-structural)", ["/ G |- p"], "mentions a specific atom"),
    ("p |- q  (non-structural)", ["G |- p / G |- q"], "mentions specific atoms"),
]


def _tonk_safe_sound(rules):
    try:
        return all(rule_sound(r) for r in rules)
    except ValueError:
        return tonk_interpretable(rules) is not None


def bold_table(base, candidates, designated=(frozenset(),), probe_budget=400, blind_budget=3000, examples=6,
               names=None):
    rows = []
    n_ex = 0
    for name, rules, comment in candidates:
        rules = [parse_rule(x) if isinstance(x, str) else x for x in rules]
        bold = BoldLearner(base, designated=designated, probe_budget=probe_budget, blind_budget=blind_budget)
        extra = [(f"C{i}" if len(rules) > 1 else "CAND", r) for i, r in enumerate(rules)]
        t0 = time.time()
        res = bold.offer(extra)
        sound = _tonk_safe_sound(rules)
        row = {"name": name, "rules": [str(r) for r in rules], "comment": comment, "classically_valid": sound,
               "coherent": res["accepted"], "source": res["source"], "nodes": res["nodes"],
               "seconds": round(time.time() - t0, 2)}
        if res["proof"] is not None:
            steps = proof_steps(res["proof"])
            row["proof_steps"] = len(steps)
            if n_ex < examples:
                row["proof"] = format_proof(res["proof"], names=names)
                n_ex += 1
        rows.append(row)
    return rows


def _random_schema(rng: random.Random) -> SeqRule:
    mv = [Var("A"), Var("B"), Var("C")]

    def f(n):
        if n <= 0:
            return rng.choice(mv + mv + [BOT])
        op = rng.choices(["imp", "and", "or", "not"], weights=[3, 2, 2, 2])[0]
        if op == "not":
            return App("not", (f(n - 1),))
        k = rng.randint(0, n - 1)
        return App(op, (f(k), f(n - 1 - k)))

    k = rng.choice([0, 1, 1, 2])
    prems = []
    for _ in range(k):
        ext = App("ctx", (f(rng.randint(0, 1)),)) if rng.random() < 0.25 else App("ctx", ())
        prems.append((ext, f(rng.randint(0, 3))))
    concl = (App("ctx", ()), f(rng.randint(0, 3)))
    return SeqRule(prems, concl)


def random_schema_candidates(n: int, seed: int):
    rng = random.Random(seed)
    out, seen = [], set()
    while len(out) < n:
        r = _random_schema(rng)
        if r.key() in seen:
            continue
        # skip trivial instances of the assumption rule's shape (conclusion among premise succedents)
        seen.add(r.key())
        out.append((f"R{len(out)}", [r], "random"))
    return out


def lgg_candidates():
    """Pairwise LGGs of target rules with the same number of premises: the
    over-generalisations an aggressive anti-unifier would propose."""
    out, seen = [], set()
    rules = CLASSICAL_RULES
    for i in range(len(rules)):
        for j in range(i + 1, len(rules)):
            a, b = rules[i], rules[j]
            if a.n_prems != b.n_prems:
                continue
            (g,) = lgg_tuples([(a.canonical().term(),), (b.canonical().term(),)])
            if type(g) is Var or any(type(x) is Var for x in g.args):
                continue
            r = SeqRule.from_term(g)
            if r.key() in seen or any(r.variant_of(t, check_guard=False) for t in rules):
                continue
            seen.add(r.key())
            out.append((f"lgg({a.name},{b.name})", [r], ""))
    return out


def run_post(quick: bool) -> dict:
    t0 = time.time()
    base = [(r.name, r) for r in CLASSICAL_RULES]
    out = {}
    out["hand"] = bold_table(base, HAND_CANDIDATES, examples=8)
    out["lgg"] = bold_table(base, lgg_candidates(), examples=2)
    nr = 30 if quick else 150
    out["random"] = bold_table(base, random_schema_candidates(nr, seed=5), examples=2)
    # non-structural rules: empty context only / + designated contexts / + world
    des = designated_contexts(6, seed=1) + [frozenset([parse_formula("p"), parse_formula("~q")])]
    ns = [c for c in HAND_CANDIDATES if "non-structural" in c[0]]
    rows = []
    for name, rules, comment in ns:
        r_empty = bold_table(base, [(name, rules, comment)], designated=(frozenset(),), examples=0)[0]
        r_des = bold_table(base, [(name, rules, comment)], designated=des, examples=1)[0]
        w = PropWorld(n_obs=2, seed=3)
        rr = [parse_rule(x) for x in rules]
        refuted = any(w.step_refuted(tuple(Seq((), a) for e, a in r.prems), Seq((), r.concl[1])) is not None
                      for r in rr)
        rows.append({"name": name, "coherent_empty": r_empty["coherent"], "coherent_designated": r_des["coherent"],
                     "designated_proof": r_des.get("proof"), "world_refutes": refuted,
                     "world_valuations": w.valuations})
    out["nonstructural"] = {"designated": [sorted(fmt(f) for f in G) for G in des], "rows": rows}
    # tonk: order dependence of the bold learner (new vocabulary: no unique maximal extension)
    tonk_rows = []
    for order in (["tonkI", "tonkE"], ["tonkE", "tonkI"]):
        bold = BoldLearner(base)
        res = []
        for nm in order:
            rule = TONK_I if nm == "tonkI" else TONK_E
            r = bold.offer([(nm, rule)])
            res.append({"offered": nm, "accepted": r["accepted"],
                        "proof": format_proof(r["proof"]) if r["proof"] is not None else None})
        tonk_rows.append({"order": order, "results": res})
    out["tonk"] = {"orders": tonk_rows, "interpretable": {
        "tonkI": tonk_interpretable([TONK_I]), "tonkE": tonk_interpretable([TONK_E]),
        "both": tonk_interpretable([TONK_I, TONK_E])}}
    # 'everything derivable' once an incoherent rule is admitted: the derivation of
    # |- bot found by the bold learner is reused as a lemma
    bad = parse_rule("G |- A | B / G |- A")
    found = BoldLearner(base).offer([("CAND", bad)])
    pr = Prover(base + [("CAND", bad)], budget=3000, max_depth=10)
    pr.add_lemma(found["proof"])
    goals = ["|- p", "|- ~p", "|- p & ~p", "q |- ~q", "|- (p -> q) & ~(p -> q)"]
    exp = {}
    for g in goals:
        node = pr.prove(_seq(g), extra_pool=[BOT, parse_formula("bot | ~bot")])
        exp[g] = node is not None
    out["explosion"] = {"rule": str(bad), "goals": exp,
                        "example": format_proof(pr.prove(_seq("|- p & ~p"), extra_pool=[BOT]))}
    # the same with a calculus learned from clean human proofs (version-space learner + coherence)
    ds = generate_corpus(100, PropHumanConfig(), seed=0)
    learner = SeqLearner(**LEARNERS["vs"])
    calc = learner.fit(steps=prepare_training(ds))
    CoherencePruner(calc, PruneConfig(seed=0), learner).run()
    lbase = calc.rule_list()
    names = {lr.sid: f"L{lr.sid}" for lr in calc.rules}
    out["learned_base"] = {"rules": [str(r) for _, r in lbase],
                           "hand": bold_table(lbase, HAND_CANDIDATES, examples=2, names=names)}
    out["trace"] = pruning_trace()
    out["seconds"] = round(time.time() - t0, 1)
    return out


def pruning_trace(N=100, noise="fallacies", seed=0) -> dict:
    """A worked example: learned unsound rules, the adversary's derivations, and
    what each round of coherence pruning did."""
    ds = generate_corpus(N, PropHumanConfig(**NOISE[noise]), seed=seed)
    learner = SeqLearner(**LEARNERS["vs"])
    calc = learner.fit(steps=prepare_training(ds))
    names = {lr.sid: f"L{lr.sid}" for lr in calc.rules}
    before = [f"L{lr.sid} (support {lr.support}): {lr.rule.show()}" for lr in unsound_active(calc)]
    att = adversarial_attack(calc, seed, n_random=8, budget=1000)
    pr = CoherencePruner(calc, PruneConfig(seed=seed), learner)
    hist = pr.run()
    rounds = []
    for h in hist:
        acts = []
        for a in h["actions"]:
            lr = calc.by_id(a["sid"])
            note = ""
            if a["action"] == "guard":
                note = " -> now " + ("sound" if rule_sound(lr.rule) else "UNSOUND")
                if lr.support < calc.m:
                    note += ", inactive (support < m: equivalent to deletion)"
            acts.append(f"L{lr.sid}: {lr.log[-1] if lr.log else a['action']}{note}")
        rounds.append({"round": h["round"], "bags": h["bags"], "actions": acts})
    att2 = adversarial_attack(calc, seed, n_random=8, budget=1000)
    return {"setting": f"vs, N = {N}, noise {noise}, seed {seed}", "unsound_before": before,
            "attack_before": {"n_exploits": att["n_exploits"], "n_goals": att["n_goals"], "examples": att["examples"]},
            "rounds": rounds, "bags": pr.examples[:2], "unsound_after": [str(lr.rule) for lr in unsound_active(calc)],
            "attack_after": att2["n_exploits"], "recovery_after": recovery_report(calc)}


def _seq(s):
    from cil.domains.prop import seq
    return seq(s)


# ---------------------------------------------------------------------------
# Intuitionistic contrast
# ---------------------------------------------------------------------------

IPC_CANDIDATES = [
    ("excluded middle", ["/ G |- A | ~A"]),
    ("double negation elim.", ["G |- ~~A / G |- A"]),
    ("reductio (RAA)", ["G, ~A |- bot / G |- A"]),
    ("Peirce", ["/ G |- ((A -> B) -> A) -> A"]),
    ("weak excluded middle", ["/ G |- ~A | ~~A"]),
    ("Dummett linearity", ["/ G |- (A -> B) | (B -> A)"]),
    ("p -> q (axiom schema)", ["/ G |- A -> B"]),
    ("A | B |- A", ["G |- A | B / G |- A"]),
    ("affirming the consequent", ["G |- A -> B ; G |- B / G |- A"]),
]
CLASSICAL_PROBES = ["~~p -> p", "p | ~p", "((p -> q) -> p) -> p", "(p -> q) | (q -> p)", "~(p & q) -> ~p | ~q",
                    "(~p -> p) -> p", "~p | ~~p"]


def run_ipc(quick: bool) -> dict:
    t0 = time.time()
    base = [(r.name, r) for r in INTUITIONISTIC_RULES]
    rows = []
    for name, rs in IPC_CANDIDATES:
        rules = [parse_rule(x) for x in rs]
        bold = BoldLearner(base, probe_budget=400, blind_budget=3000)
        res = bold.offer([(f"CAND{i}" if len(rules) > 1 else "CAND", r) for i, r in enumerate(rules)])
        km = kripke_countermodel(rules[0])
        ext = base + [("CAND", r) for r in rules]
        proves = {}
        for g in CLASSICAL_PROBES:
            f = parse_formula(g)
            pb = Prover(base, budget=3000, max_depth=12).prove(Seq((), f)) is not None
            pe = Prover(ext, budget=3000, max_depth=12).prove(Seq((), f)) is not None
            proves[g] = {"ipc": pb, "ipc+cand": pe, "kripke_valid": kripke_valid_formula(f)}
        rows.append({"name": name, "rules": [str(r) for r in rules], "classically_valid": all(map(rule_sound, rules)),
                     "coherent_over_ipc": res["accepted"], "kripke_countermodel": km["frame"] if km else None,
                     "proves": proves,
                     "bottom_proof": format_proof(res["proof"]) if res["proof"] is not None else None})
    # bold learner sequence over IPC: offer everything in order
    bold = BoldLearner(base, probe_budget=400, blind_budget=3000)
    seqres = []
    for name, rs in IPC_CANDIDATES:
        rules = [parse_rule(x) for x in rs]
        r = bold.offer([(name, rr) for rr in rules])
        seqres.append({"name": name, "accepted": r["accepted"]})
    taus = _taus(0)
    comp_ipc = completeness(base, taus, EVAL["comp_budget"])
    comp_bold = completeness(bold.rules, taus, EVAL["comp_budget"])
    comp_cpc = target_completeness(0)
    # learning from intuitionistic human proofs, then the bold phase
    n_h = 20 if quick else 60
    ds = generate_corpus(n_h, PropHumanConfig(logic="intuitionistic"), seed=0)
    learner = SeqLearner(**LEARNERS["vs"])
    calc = learner.fit(steps=prepare_training(ds))
    CoherencePruner(calc, PruneConfig(seed=0), learner).run()
    lrules = calc.rule_list()
    rec = recovery_report(calc, INTUITIONISTIC_RULES)
    raa_learned = any(lr.rule.variant_of(TARGET_BY_NAME["raa"], check_guard=False) for lr in calc.active())
    lb = BoldLearner(lrules, probe_budget=400, blind_budget=3000)
    lseq = []
    for name, rs in IPC_CANDIDATES:
        r = lb.offer([(name, parse_rule(x)) for x in rs])
        lseq.append({"name": name, "accepted": r["accepted"]})
    comp_l0 = completeness(lrules, taus, EVAL["comp_budget"])
    comp_l1 = completeness(lb.rules, taus, EVAL["comp_budget"])
    kv = [kripke_valid_formula(f) for f in taus]
    learned_probe = {g: {"before": Prover(lrules, 3000, 12).prove(Seq((), parse_formula(g))) is not None,
                         "after": Prover(lb.rules, 3000, 12).prove(Seq((), parse_formula(g))) is not None}
                     for g in CLASSICAL_PROBES}
    return {"rows": rows, "bold_sequence": seqres,
            "completeness": {"ipc": comp_ipc["frac"], "ipc_bold": comp_bold["frac"], "cpc": comp_cpc["frac"],
                             "n_taus": len(taus), "frac_kripke_valid": sum(kv) / len(kv)},
            "learned": {"n_proofs": n_h, "recovery": rec, "raa_learned": raa_learned,
                        "unsound": [str(lr.rule) for lr in unsound_active(calc)],
                        "kripke_unsound": [str(lr.rule) for lr in calc.active() if kripke_countermodel(lr.rule)],
                        "bold_sequence": lseq, "completeness_before": comp_l0["frac"],
                        "completeness_after": comp_l1["frac"], "probes": learned_probe},
            "seconds": round(time.time() - t0, 1)}


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------


def _ms(xs, fmt_="{:.2f}"):
    xs = [x for x in xs if x is not None]
    if not xs:
        return "–"
    m = statistics.mean(xs)
    sd = statistics.pstdev(xs) if len(xs) > 1 else 0.0
    return (fmt_ + " ± " + fmt_).format(m, sd)


def _recs(records, **kw):
    out = []
    for r in records:
        t = r["task"]
        if all(t.get(k, {"weight": "repair", "guard": "ms"}.get(k)) == v for k, v in kw.items()):
            out.append(r)
    return out


def _ngoals(records):
    for r in records:
        for p in r["phases"].values():
            return p["attack"]["n_goals"]
    return 0


def learning_tables(records) -> list:
    L = []
    for lname in ("vs", "vs_untagged", "aggressive"):
        rs = _recs(records, learner=lname, weight="repair", guard="ms")
        if not rs:
            continue
        L.append(f"\n### learner `{lname}`\n")
        L.append("| N | noise | phase | unsound active | tonk-like | exact /13 | exact or stronger guard /13 | "
                 "adversary exploits (of " + str(_ngoals(records)) + ") | derives ⊢⊥ | sound completeness (target) | FA invalid | acc. valid ID / OOD |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|---|")
        Ns = sorted({r["task"]["N"] for r in rs})
        for N in Ns:
            for noise in NOISE:
                grp = [r for r in rs if r["task"]["N"] == N and r["task"]["noise"] == noise]
                if not grp:
                    continue
                for ph in PHASES:
                    ps = [r["phases"][ph] for r in grp if ph in r["phases"]]
                    if not ps:
                        continue
                    L.append(f"| {N} | {noise} | {ph} | {_ms([p['n_unsound'] for p in ps], '{:.1f}')} | "
                             f"{_ms([p['n_tonk_like'] for p in ps], '{:.1f}')} | "
                             f"{_ms([p['n_exact'] for p in ps], '{:.1f}')} | "
                             f"{_ms([p['n_exact_or_stronger'] for p in ps], '{:.1f}')} | "
                             f"{_ms([p['attack']['n_exploits'] for p in ps], '{:.1f}')} | "
                             f"{sum(p['attack']['derives_bottom'] for p in ps)}/{len(ps)} | "
                             f"{_ms([p['completeness'] for p in ps])} ({_ms([p['completeness_target'] for p in ps])}) | "
                             f"{_ms([p['heldout']['invalid'] for p in ps])} | "
                             f"{_ms([p['heldout']['valid_id'] for p in ps])} / {_ms([p['heldout']['valid_ood'] for p in ps])} |")
    return L


def make_report(res: dict, quick: bool) -> str:
    L = []
    L.append("# Propositional natural deduction: learning rules from human proofs, coherence, world feedback, "
             "Post-completeness\n")
    L.append("_Auto-generated by `experiments/exp_prop_learning.py`" + (" (QUICK smoke run)" if quick else "") +
             "; raw data `results/prop_learning" + ("_quick" if quick else "") +
             ".json`. Mean ± sd over seeds (population sd)._\n")
    L.append("## Setup (short)\n")
    L.append("* **Formulas** over atoms p, q, r (4th atom s out of distribution) with →, ∧, ∨, ¬, ⊥. **Steps** are "
             "sequent-style natural-deduction inferences `Γ,E₁ ⊢ A₁ ; … / Γ,E₀ ⊢ A₀` with explicit assumption sets. "
             "**Target**: classical ND (13 rules: assumption `/ Γ ⊢ A [mem A]`, ∧I, ∧E₁, ∧E₂, ∨I₁, ∨I₂, ∨E, →I, →E, "
             "¬I, ¬E, EFQ, RAA); IPC = the same without RAA.")
    L.append("* **Rules** are schemas with one shared context metavariable Γ, formula metavariables, set "
             "metavariables (from anti-unifying different numbers of extra assumptions) and guards `mem t` "
             "(t is an open assumption).")
    L.append("* **Human proofs**: random tautologies (templates + random premise→conclusion exercises) proved by a "
             "randomised, human-like backward strategy (introductions for the goal, eliminations of assumptions, "
             "lemmas, reductio as a last resort; tableau-style fallback). Noise settings: `fallacies` = at each "
             "opportunity, with prob. 0.3, affirming the consequent (AC), denying the antecedent (DA) or illegitimate "
             "discharge / scope error (ID: using a discharged assumption as the minor premise of →E), all cited as "
             "→E; `noise` = 5% of steps randomly corrupted (conclusion, premise or context) with a random rule tag; "
             "`both`.")
    L.append("* **Learners**: `vs` = version-space learner: buckets by the cited rule, MDL agglomerative "
             "anti-unification of step cores (hierarchical over shared-subterm groups), guards = most specific "
             "`mem` conjunction holding in ≥90% of members, conservative verifier with support threshold m = 2; "
             "`vs_untagged` = same with tag-free buckets (shared-subterm abstraction); `aggressive` = plain LGG of "
             "each coarse bucket (premise count × extra-assumption arities): Plotkin's learner.")
    L.append("* **Coherence pruning** (`coherence`): designated coherent contexts = ∅ plus 4 satisfiable "
             "contingent premise sets. Negative bags = derivations of ⊥ found by (i) *Post probes*: instantiate a "
             "rule's metavariables with ⊥/¬⊥ (set metavariables with {}/{⊥}), assume its guard, prove the premises "
             "with the current calculus and try to refute the conclusion; (ii) blind backward search for Γ_d ⊢ ⊥. "
             "Bags are diversified (re-search with a bag member blocked). Blame = implicit minimum-weight hitting "
             "set (block the candidate set, search again, until coherent within budget); weight of blaming a rule = "
             "human steps lost by its cheapest repair that blocks the incriminated instances; repairs: minimal "
             "`mem` guard (monster-barring), split the cluster by MDL (undo an over-generalisation), delete. "
             "`world` = the same plus sparse world feedback: 2 observed valuations (of 16) answer whether a single "
             "step is refuted at an observed world (rule instances with metavariables ↦ literals, and steps of "
             "bags).")
    L.append("* **Adversarial prover**: budgeted backward search *with the learned rules* (every step accepted by "
             "the learned verifier) for 22 fixed non-theorems (incl. ⊢ ⊥), 8 random invalid sequents and Γ ⊢ ⊥ for "
             "4 fresh satisfiable Γ (34 goals). **Completeness**: fraction of 25 random tautologies (2–5 "
             "connectives) proved within 2000 expansions, next to the target calculus under the same prover. "
             "**Held-out steps**: valid steps from fresh human proofs (ID) and from larger 4-atom exercises (OOD); "
             "invalid steps = instances of unsound schemas (fallacies, assumption dropping, tonk-like, converse, …) "
             "and random mutations, all locally unsound.\n")
    if "learning" in res:
        recs = res["learning"]["records"]
        L += key_findings(res)
        L += interpretation(res)
        L.append("\n## 1. Learning grid\n")
        L.append("Exact = an active learned rule is a variant of the target rule *with the same guard*; "
                 "'or stronger guard' also counts a more restrictive guard (sound, possibly less complete). "
                 "*Unsound active* rules are exactly the white-box exploitable ones (a falsifying truth-table row "
                 "gives an invalid step the verifier accepts); the search-based adversary is a weaker, goal-driven "
                 "attacker. FA invalid = acceptance rate of held-out invalid steps. *Sound completeness* = fraction "
                 "of the random tautologies proved within the budget using only the classically sound active rules "
                 "(an incoherent calculus 'proves' everything, so raw completeness, stored as `completeness_any`, is "
                 "meaningless before pruning). In parentheses: the target calculus under the same prover and budget.\n")
        L += learning_tables(recs)
        L += exhibits(res)
        L += blame_section(recs)
        L += fallacy_section(recs)
    if "post" in res:
        L += post_section(res["post"])
    if "ipc" in res:
        L += ipc_section(res["ipc"])
    L += caveats()
    return "\n".join(L) + "\n"


def key_findings(res):
    recs = res["learning"]["records"]
    L = ["## Key findings (computed)\n"]
    vs = _recs(recs, learner="vs", weight="repair", guard="ms")

    def agg(ph, noise=None, Nmin=0):
        ps = [r["phases"][ph] for r in vs if ph in r["phases"] and (noise is None or r["task"]["noise"] == noise)
              and r["task"]["N"] >= Nmin]
        return ps

    for noise in NOISE:
        pos, coh, wor = agg("positive", noise, 50), agg("coherence", noise, 50), agg("world", noise, 50)
        if not pos:
            continue
        L.append(f"* **`vs`, noise `{noise}`, N ≥ 50** — unsound active rules: positive {_ms([p['n_unsound'] for p in pos], '{:.1f}')}, "
                 f"+coherence {_ms([p['n_unsound'] for p in coh], '{:.1f}')}, +world {_ms([p['n_unsound'] for p in wor], '{:.1f}')}; "
                 f"adversary exploits (of {_ngoals(recs)} goals): {_ms([p['attack']['n_exploits'] for p in pos], '{:.1f}')} → "
                 f"{_ms([p['attack']['n_exploits'] for p in coh], '{:.1f}')} → {_ms([p['attack']['n_exploits'] for p in wor], '{:.1f}')}; "
                 f"sound completeness {_ms([p['completeness'] for p in pos])} → {_ms([p['completeness'] for p in coh])} → "
                 f"{_ms([p['completeness'] for p in wor])} (target {_ms([p['completeness_target'] for p in pos])}); "
                 f"rules exact-or-stronger /13 after coherence {_ms([p['n_exact_or_stronger'] for p in coh], '{:.1f}')}.")
    for ph in PHASES:
        ps = agg(ph)
        if ps:
            nb = sum(p["attack"]["derives_bottom"] for p in ps)
            nu = sum(p["n_unsound"] > 0 for p in ps)
            L.append(f"* Over all {len(ps)} `vs` runs, phase `{ph}`: runs with ≥1 unsound active rule {nu}; runs in which "
                     f"the adversary derives ⊢ ⊥ {nb}; total adversary exploits {sum(p['attack']['n_exploits'] for p in ps)}.")
    ag = _recs(recs, learner="aggressive", weight="repair")
    if ag:
        pos = [r["phases"]["positive"] for r in ag if "positive" in r["phases"]]
        coh = [r["phases"]["coherence"] for r in ag if "coherence" in r["phases"]]
        L.append(f"* **Aggressive anti-unification** (`aggressive`, {len(pos)} runs) produces tonk-like rules "
                 f"(mean {_ms([p['n_tonk_like'] for p in pos], '{:.1f}')} per run); the adversary derives ⊢ ⊥ in "
                 f"{sum(p['attack']['derives_bottom'] for p in pos)}/{len(pos)} runs. After coherence pruning: tonk-like "
                 f"{_ms([p['n_tonk_like'] for p in coh], '{:.1f}')}, ⊢ ⊥ derivable in {sum(p['attack']['derives_bottom'] for p in coh)}/{len(coh)}, "
                 f"exact-or-stronger /13 {_ms([p['n_exact_or_stronger'] for p in coh], '{:.1f}')}.")
    if "post" in res:
        P = res["post"]
        allrows = P["hand"] + P["lgg"] + P["random"]
        struct = [r for r in allrows if "non-structural" not in r["name"]]
        vc = sum(r["classically_valid"] and r["coherent"] for r in struct)
        vi = sum(r["classically_valid"] and not r["coherent"] for r in struct)
        ic = sum((not r["classically_valid"]) and r["coherent"] for r in struct)
        ii = sum((not r["classically_valid"]) and not r["coherent"] for r in struct)
        L.append(f"* **Post-completeness (bold learner over classical ND)**, {len(struct)} structural candidate schemas "
                 f"(hand-picked, pairwise LGGs of target rules, random): valid & coherent {vc}, valid & incoherent {vi}, "
                 f"invalid & coherent (search failed) {ic}, invalid & incoherent {ii}. Every invalid schema for which ⊥ was "
                 "found yields an explicit derivation of ⊢ ⊥ (see §3).")
    if "ipc" in res:
        I = res["ipc"]
        acc = [r["name"] for r in I["rows"] if r["coherent_over_ipc"]]
        L.append(f"* **IPC**: coherent additions to intuitionistic ND: {', '.join(acc)}; each has a Kripke countermodel "
                 f"(not IPC-derivable). After the bold sequence, completeness on classical tautologies "
                 f"{I['completeness']['ipc']:.2f} → {I['completeness']['ipc_bold']:.2f} (classical ND {I['completeness']['cpc']:.2f}).")
    return L


def _nonstructural(rule_str: str) -> bool:
    try:
        return bool(parse_rule(rule_str).constants())
    except Exception:
        return False


def interpretation(res):
    recs = res["learning"]["records"]
    vs = _recs(recs, learner="vs", weight="repair", guard="ms")
    L = ["\n## Interpretation (numbers computed from the runs above)\n"]

    def P(ph, noises, Nmin=0, Nmax=10 ** 9, rs=vs):
        return [r["phases"][ph] for r in rs if ph in r["phases"] and r["task"]["noise"] in noises
                and Nmin <= r["task"]["N"] <= Nmax]

    # 1. clean data
    cl = P("positive", ["clean"], 20)
    if cl:
        st = Counter(v for p in cl for k, v in p["recovery"].items())
        strong = Counter(k for p in cl for k, v in p["recovery"].items() if v == "guard_stronger")
        L.append(f"**1. Positive examples recover the calculus, including its context side condition.** On clean "
                 f"data (`vs`, N ≥ 20, {len(cl)} runs) runs with an unsound active rule: "
                 f"{sum(p['n_unsound'] > 0 for p in cl)}; target rules recovered exactly or with a stronger guard: "
                 f"{_ms([p['n_exact_or_stronger'] for p in cl], '{:.1f}')}/13. The assumption rule's side condition "
                 f"`mem A` is learned from positives as the most specific guard (exact in "
                 f"{sum(p['recovery']['ax'] == 'exact' for p in cl)}/{len(cl)} runs). Rules most often learned with a "
                 f"*stronger* guard: {', '.join(f'{k} ({v}/{len(cl)})' for k, v in strong.most_common(4)) or 'none'} "
                 "— the simulated humans only eliminate ∧ and ∨ from open assumptions, so the version space's most "
                 "specific hypothesis requires that (sound, but it rejects some valid steps out of distribution: "
                 f"held-out valid OOD acceptance {_ms([p['heldout']['valid_ood'] for p in cl])}).")
    # 2. errors survive positive learning
    er = P("positive", ["fallacies", "noise", "both"], 20)
    if er:
        L.append(f"\n**2. Positive data cannot exclude systematic errors or noise.** With fallacies and/or noise "
                 f"(N ≥ 20, {len(er)} runs): runs with an unsound active rule {sum(p['n_unsound'] > 0 for p in er)}, "
                 f"mean unsound active {_ms([p['n_unsound'] for p in er], '{:.1f}')}, of which tonk-like (conclusion "
                 f"unconstrained by the premises) {_ms([p['n_tonk_like'] for p in er], '{:.1f}')}; the adversary derives "
                 f"⊢ ⊥ in {sum(p['attack']['derives_bottom'] for p in er)}/{len(er)} runs and the verifier accepts "
                 f"{_ms([p['heldout']['invalid'] for p in er])} of held-out invalid steps. Fallacies reach the support "
                 "threshold because they are *systematic*; noise produces tonk-like rules because MDL anti-unification "
                 "merges unrelated corrupted steps that share a skeleton (the two-part code charges nothing for a "
                 "variable binding). Gold's problem in miniature.")
    # 3. coherence
    co = P("coherence", ["fallacies", "noise", "both"], 20)
    co_small = P("coherence", ["fallacies", "noise", "both"], 0, 10)
    if co:
        resid = [u for p in P("coherence", list(NOISE), 0) + P("world", list(NOISE), 0) for u in p["unsound_rules"]]
        ns = sum(_nonstructural(u) for u in resid)
        L.append(f"\n**3. Coherence alone (no world) removes them — Post-completeness at work.** After coherence "
                 f"pruning (N ≥ 20, {len(co)} runs with errors): runs with an unsound active rule "
                 f"{sum(p['n_unsound'] > 0 for p in co)}, adversary derives ⊢ ⊥ in "
                 f"{sum(p['attack']['derives_bottom'] for p in co)}, total adversary exploits "
                 f"{sum(p['attack']['n_exploits'] for p in co)}, held-out invalid acceptance "
                 f"{_ms([p['heldout']['invalid'] for p in co])}; target rules exact-or-stronger "
                 f"{_ms([p['n_exact_or_stronger'] for p in co], '{:.1f}')}/13; sound completeness "
                 f"{_ms([p['completeness'] for p in co])} vs target {_ms([p['completeness_target'] for p in co])}; "
                 f"human steps lost by the repairs {_ms([p.get('lost_steps', 0) for p in co], '{:.0f}')}. "
                 "Every schematic rule that is classically invalid has a falsifying row; substituting ⊥/¬⊥ along it turns "
                 "the rule into 'from provable closed premises infer a refutable closed conclusion', a short derivation "
                 "of ⊢ ⊥ that the Post probes find. "
                 f"Of the {len(resid)} unsound rules that survive pruning in any run (coherence or world phase), "
                 f"{ns} are *non-structural* (they mention specific atoms, typically split-children of an "
                 "over-general rule that require a specific contingent formula as an open assumption): Post's "
                 "substitution is unavailable for them, so neither the empty context nor random designated contexts "
                 "refute them; 2 observed valuations witness them only by chance.")
        if co_small:
            L.append(f"At N ≤ 10 ({len(co_small)} runs) coherence leaves unsound rules in "
                     f"{sum(p['n_unsound'] > 0 for p in co_small)} runs: with few human proofs the learned calculus may "
                     "lack the rules needed to *derive* the contradiction (coherence is only as strong as the "
                     "calculus that searches for it).")
    wo = P("world", ["fallacies", "noise", "both"], 20)
    if wo:
        L.append(f"\n**4. Sparse world feedback** (2 of 16 valuations; N ≥ 20, {len(wo)} runs): runs with an unsound "
                 f"active rule {sum(p['n_unsound'] > 0 for p in wo)}, oracle queries {_ms([p.get('queries', 0) for p in wo], '{:.0f}')}, "
                 f"pruning rounds {_ms([p.get('rounds', 0) for p in wo], '{:.1f}')} vs "
                 f"{_ms([p.get('rounds', 0) for p in co], '{:.1f}')} for coherence alone. For schematic rules even one "
                 "observed valuation is a complete soundness test: instantiating metavariables by the literals a / ¬a "
                 "realises every truth-table row at the observed world (Post's substitution again), and a refuted step "
                 "pinpoints the guilty rule, so no hitting-set guesswork is needed. Its real value is (i) exact blame "
                 "and (ii) non-structural rules, which coherence cannot reach.")
    return L


def exhibits(res):
    """Worked example (computed in the post part): learned unsound rules, the
    adversary's derivations, and the pruning rounds."""
    T = res.get("post", {}).get("trace")
    if not T:
        return []
    L = [f"\n### Worked example ({T['setting']})\n",
         "Unsound active rules after positive learning (L*n* = learned rule *n*):\n"]
    L += [f"* `{u}`" for u in T["unsound_before"]]
    A = T["attack_before"]
    L.append(f"\nThe adversary derives {A['n_exploits']} of its {A['n_goals']} invalid goals; e.g. (every step accepted "
             "by the learned verifier):\n")
    for ex in A["examples"][:2]:
        L.append(f"Goal `{ex['goal']}`:\n```\n{ex['proof']}\n```")
    L.append("Coherence pruning (no world feedback):\n")
    for rd in T["rounds"]:
        L.append(f"* round {rd['round']}: {rd['bags']} negative bags" +
                 ("; " + "; ".join(f"`{a}`" for a in rd["actions"]) if rd["actions"] else "; nothing to repair"))
    for b in T["bags"][:1]:
        L.append(f"\nA negative bag of round {b['round']} ({b['source']} search):\n```\n{b['proof']}\n```")
    L.append(f"\nAfter pruning: unsound active rules {len(T['unsound_after'])}, adversary exploits {T['attack_after']}, "
             f"recovery {dict(Counter(T['recovery_after'].values()))}.")
    return L


def blame_section(recs):
    L = ["\n## 2. Blame priors for coherence-only pruning\n",
         "Coherence alone says only that *some* rule in a derivation of ⊥ is wrong. Which rule to blame needs a "
         "prior. `support` = minimum hitting set weighted by the number of human steps a rule licenses (prefer "
         "removing rarely used rules). `repair` (default) = weight by the human steps lost by the rule's cheapest "
         "repair that blocks the incriminated instances (equal to support when deletion is the only repair). N = 50.\n",
         "| learner | noise | prior | unsound active | tonk-like | exact or stronger /13 | adversary exploits | completeness | steps lost |",
         "|---|---|---|---|---|---|---|---|---|"]
    for lname in ("aggressive", "vs"):
        for noise in ("clean", "both"):
            for w in ("support", "repair"):
                rs = [r for r in recs if r["task"]["learner"] == lname and r["task"]["noise"] == noise
                      and r["task"]["N"] == 50 and r["task"].get("weight", "repair") == w
                      and r["task"].get("guard", "ms") == "ms" and "coherence" in r["phases"]]
                if not rs:
                    continue
                ps = [r["phases"]["coherence"] for r in rs]
                L.append(f"| {lname} | {noise} | {w} | {_ms([p['n_unsound'] for p in ps], '{:.1f}')} | "
                         f"{_ms([p['n_tonk_like'] for p in ps], '{:.1f}')} | {_ms([p['n_exact_or_stronger'] for p in ps], '{:.1f}')} | "
                         f"{_ms([p['attack']['n_exploits'] for p in ps], '{:.1f}')} | {_ms([p['completeness'] for p in ps])} | "
                         f"{_ms([p.get('lost_steps', 0) for p in ps], '{:.0f}')} |")
    ng = [r for r in recs if r["task"].get("guard") == "none"]
    if ng:
        L.append("\n**No guards from positive data** (`vs`, guard_mode none, N = 50): the learned assumption rule is "
                 "`/ Γ ⊢ A` (from any context, anything) — positive data never display the side condition A ∈ Γ.\n")
        L.append("| noise | phase | unsound active | assumption rule recovered exactly | adversary exploits | completeness |")
        L.append("|---|---|---|---|---|---|")
        for noise in ("clean", "fallacies"):
            for ph in ("positive", "coherence"):
                ps = [r["phases"][ph] for r in ng if r["task"]["noise"] == noise and ph in r["phases"]]
                if ps:
                    L.append(f"| {noise} | {ph} | {_ms([p['n_unsound'] for p in ps], '{:.1f}')} | "
                             f"{sum(p['recovery']['ax'] == 'exact' for p in ps)}/{len(ps)} | "
                             f"{_ms([p['attack']['n_exploits'] for p in ps], '{:.1f}')} | {_ms([p['completeness'] for p in ps])} |")
    return L


def fallacy_section(recs):
    L = ["\n## Fallacy fates (`vs`, noise `fallacies` and `both`)\n",
         "Counts over runs: survived (an active unsound rule licenses the fallacy schema) / removed / inactive "
         "(support < m) / never learned.\n",
         "| N | phase | AC | DA | ID |", "|---|---|---|---|---|"]
    vs = [r for r in _recs(recs, learner="vs", weight="repair", guard="ms") if r["task"]["noise"] in ("fallacies", "both")]
    for N in sorted({r["task"]["N"] for r in vs}):
        for ph in PHASES:
            ps = [r["phases"][ph] for r in vs if r["task"]["N"] == N and ph in r["phases"]]
            cells = []
            for f in ("AC", "DA", "ID"):
                c = Counter(p["fallacies"][f] for p in ps)
                cells.append(f"{c.get('survived', 0)}/{c.get('removed', 0)}/{c.get('inactive', 0)}/{c.get('never_learned', 0)}")
            L.append(f"| {N} | {ph} | " + " | ".join(cells) + " |")
    return L


def post_section(P):
    L = ["\n## 3. Post-completeness: the bold learner over classical ND\n",
         "A candidate schema is added iff no derivation of ⊢ ⊥ (from the empty context) is found with base + "
         "candidate (Post probes of the candidate with budget 400 per search, blind search budget 3000). "
         "'valid' = classically sound schema (exact truth-table check of its local formula; for tonk: some binary "
         "truth function makes the rules sound).\n",
         "| candidate | rule(s) | classically valid | coherent (accepted) | ⊥ found by | proof steps |",
         "|---|---|---|---|---|---|"]
    for r in P["hand"]:
        L.append(f"| {r['name']} | `{' ; '.join(r['rules'])}` | {r['classically_valid']} | {r['coherent']} | "
                 f"{r['source'] or '–'} | {r.get('proof_steps', '–')} |")
    for title, key in (("Pairwise LGGs of target rules", "lgg"), ("Random schemas", "random")):
        rows = P[key]
        c = Counter((r["classically_valid"], r["coherent"]) for r in rows)
        L.append(f"\n**{title}** ({len(rows)}): valid & coherent {c.get((True, True), 0)}, valid & incoherent "
                 f"{c.get((True, False), 0)}, invalid & incoherent {c.get((False, False), 0)}, invalid & coherent "
                 f"(no ⊥ found within budget) {c.get((False, True), 0)}.")
        miss = [r for r in rows if not r["classically_valid"] and r["coherent"]]
        for r in miss[:5]:
            L.append(f"  * not refuted: `{r['rules'][0]}`")
        steps = [r["proof_steps"] for r in rows if r.get("proof_steps")]
        if steps:
            L.append(f"  * derivations of ⊥: median {statistics.median(steps)} steps, max {max(steps)}.")
    L.append("\n**Exhibited derivations of ⊢ ⊥** (rule `CAND` is the candidate; line format: sequent, rule, premise lines):\n")
    for r in P["hand"]:
        if r.get("proof"):
            L.append(f"*{r['name']}* `{' ; '.join(r['rules'])}`\n```\n{r['proof']}\n```")
    E = P["explosion"]
    L.append(f"\nOnce `{E['rule']}` is admitted (and its derivation of ⊢ ⊥ is available as a lemma), everything is "
             "derivable: " + ", ".join(f"`{g}`: {'derived' if v else 'not found'}" for g, v in E["goals"].items()) +
             (f". E.g.\n```\n{E['example']}\n```\n" if E.get("example") else ".\n"))
    NS = P["nonstructural"]
    L.append("**Non-structural rules** (mention specific atoms, so ⊥/⊤ cannot be substituted). Designated contexts: " +
             "; ".join("{" + ", ".join(G) + "}" for G in NS["designated"]) + ".\n")
    L.append("| rule | coherent w.r.t. ∅ only | coherent w.r.t. designated contexts | refuted by 2 observed valuations |")
    L.append("|---|---|---|---|")
    for r in NS["rows"]:
        L.append(f"| {r['name']} | {r['coherent_empty']} | {r['coherent_designated']} | {r['world_refutes']} |")
    for r in NS["rows"]:
        if r.get("designated_proof"):
            L.append(f"\n*{r['name']}* refuted in a designated context:\n```\n{r['designated_proof']}\n```")
    T = P["tonk"]
    L.append("\n**tonk and order dependence.** " + "; ".join(
        f"offered {' then '.join(o['order'])}: " + ", ".join(f"{x['offered']} {'accepted' if x['accepted'] else 'rejected'}"
                                                           for x in o["results"]) for o in T["orders"]) +
             f". Truth-table interpretations exist for tonk-I alone ({T['interpretable']['tonkI'] is not None}) and "
             f"tonk-E alone ({T['interpretable']['tonkE'] is not None}) but not for both "
             f"({T['interpretable']['both'] is not None}).")
    for o in T["orders"]:
        for x in o["results"]:
            if x["proof"]:
                L.append(f"\n{x['offered']} after {o['order'][0]}:\n```\n{x['proof']}\n```")
                break
        break
    LB = P["learned_base"]
    c = Counter((r["classically_valid"], r["coherent"]) for r in LB["hand"] if "non-structural" not in r["name"])
    L.append(f"\n**Base = a learned calculus** (`vs`, N = 100 clean, after coherence; {len(LB['rules'])} active rules): "
             f"hand-picked structural candidates: valid & coherent {c.get((True, True), 0)}, valid & incoherent "
             f"{c.get((True, False), 0)}, invalid & incoherent {c.get((False, False), 0)}, invalid & coherent "
             f"{c.get((False, True), 0)}.")
    return L


def ipc_section(I):
    L = ["\n## 4. Intuitionistic contrast: coherence cannot pin IPC down from above\n",
         "Base = intuitionistic ND (no RAA). 'coherent' = accepted by the bold learner (no ⊢ ⊥ found); for the "
         "classically valid candidates this is also *certified*: all rules are classically sound, so no derivation "
         "of ⊥ exists at all. 'Kripke countermodel' certifies non-derivability in IPC.\n",
         "| candidate | classically valid | coherent over IPC | Kripke countermodel | newly provable (of the probe formulas) |",
         "|---|---|---|---|---|"]
    for r in I["rows"]:
        new = [g for g, v in r["proves"].items() if v["ipc+cand"] and not v["ipc"]]
        newtxt = (", ".join("`" + g + "`" for g in new) or "–") if r["coherent_over_ipc"] else \
            "(incoherent: ⊢ ⊥, hence everything)"
        L.append(f"| {r['name']} | {r['classically_valid']} | {r['coherent_over_ipc']} | {r['kripke_countermodel'] or '–'} | "
                 f"{newtxt} |")
    L.append("\nProbe formulas: " + ", ".join(f"`{g}`" for g in CLASSICAL_PROBES) +
             ". None is Kripke-valid except as noted: " +
             ", ".join(f"`{g}`: {v['kripke_valid']}" for g, v in I["rows"][0]["proves"].items()) + ".\n")
    L.append("Bold sequence over IPC (offered in table order): " +
             ", ".join(f"{x['name']} {'✓' if x['accepted'] else '✗'}" for x in I["bold_sequence"]) +
             f". Completeness on the {I['completeness']['n_taus']} random classical tautologies: IPC "
             f"{I['completeness']['ipc']:.2f} → bold extension {I['completeness']['ipc_bold']:.2f} (classical ND "
             f"{I['completeness']['cpc']:.2f}); fraction of these tautologies that are Kripke-valid (≈ IPC theorems): "
             f"{I['completeness']['frac_kripke_valid']:.2f}.\n")
    Lr = I["learned"]
    L.append(f"**Learned from intuitionistic human proofs** (N = {Lr['n_proofs']}, `vs` + coherence): recovery of the 12 IPC "
             f"rules {dict(Counter(Lr['recovery'].values()))}; RAA learned: {Lr['raa_learned']}; classically unsound "
             f"active rules: {len(Lr['unsound'])}; Kripke-unsound active rules: {len(Lr['kripke_unsound'])}. Bold phase: " +
             ", ".join(f"{x['name']} {'✓' if x['accepted'] else '✗'}" for x in Lr["bold_sequence"]) +
             f". Completeness on classical tautologies {Lr['completeness_before']:.2f} → {Lr['completeness_after']:.2f}. "
             "Probe formulas provable before → after: " +
             ", ".join(f"`{g}` {int(v['before'])}→{int(v['after'])}" for g, v in Lr["probes"].items()) + ".")
    for r in I["rows"]:
        if r["bottom_proof"]:
            L.append(f"\n*{r['name']}* over IPC derives ⊥:\n```\n{r['bottom_proof']}\n```")
            break
    return L


def caveats():
    return ["\n## Caveats\n",
            "* *Realisability*: valid human steps are exact instances of the 13 target rules; the guard language "
            "(`mem t`) contains the one side condition the target needs. Fallacies are cited as →E.",
            "* *Search-bounded coherence*: 'coherent' means no derivation of ⊥ was found within the budget; Post "
            "probes are a heuristic implementation of the constructive content of Post-completeness, not a decision "
            "procedure. Soundness of learned rules is decided exactly (truth tables), adversary results are "
            "search-bounded.",
            "* *Completeness* is measured with one budgeted prover; the target calculus does not reach 1.0 either. "
            "Relative completeness (learned vs target under the same budget) is the meaningful number.",
            "* *Classical blame is easy here*: for schematic (structural) rules over a Post-complete base, coherence "
            "alone is a complete soundness test; the hard part is blame assignment, which needs a prior (§2). "
            "Non-structural rules (mentioning specific atoms) need designated contexts or world feedback (§3).",
            "* Few seeds (3); sd over seeds, not confidence intervals."]


# ---------------------------------------------------------------------------
# Plots
# ---------------------------------------------------------------------------


def make_plots(res, quick):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception as e:  # pragma: no cover
        print("no matplotlib:", e)
        return []
    if "learning" not in res:
        return []
    recs = _recs(res["learning"]["records"], learner="vs", weight="repair", guard="ms")
    files = []
    colors = {"positive": "#7a7a7a", "coherence": "#2b6cb0", "world": "#c05621"}
    for metric, ylabel, fname in (("n_unsound", "unsound active rules", "prop_unsound.png"),
                                  ("attack", "adversary exploits (of 34 goals)", "prop_exploits.png"),
                                  ("completeness", "sound completeness (random tautologies)", "prop_completeness.png")):
        fig, axes = plt.subplots(1, 4, figsize=(15, 3.4), sharey=True)
        for ax, noise in zip(axes, NOISE):
            for ph in PHASES:
                Ns = sorted({r["task"]["N"] for r in recs if r["task"]["noise"] == noise})
                ys = []
                for N in Ns:
                    ps = [r["phases"][ph] for r in recs if r["task"]["N"] == N and r["task"]["noise"] == noise
                          and ph in r["phases"]]
                    if metric == "attack":
                        ys.append(statistics.mean(p["attack"]["n_exploits"] for p in ps))
                    else:
                        ys.append(statistics.mean(p[metric] for p in ps))
                ax.plot(Ns, ys, marker="o", label=ph, color=colors[ph])
            if metric == "completeness":
                Ns = sorted({r["task"]["N"] for r in recs if r["task"]["noise"] == noise})
                ys = [statistics.mean(r["phases"]["positive"]["completeness_target"] for r in recs
                                      if r["task"]["N"] == N and r["task"]["noise"] == noise) for N in Ns]
                ax.plot(Ns, ys, ls="--", color="black", label="target calculus")
            ax.set_xscale("log")
            ax.set_title(f"noise: {noise}")
            ax.set_xlabel("human proofs N")
            ax.grid(alpha=0.3)
        axes[0].set_ylabel(ylabel)
        axes[-1].legend(fontsize=8)
        fig.tight_layout()
        path = os.path.join(RESULTS, fname.replace(".png", "_quick.png") if quick else fname)
        fig.savefig(path, dpi=120)
        plt.close(fig)
        files.append(path)
    return files


# ---------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--part", default="all", choices=["all", "learning", "post", "ipc"])
    ap.add_argument("--workers", type=int, default=3)
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--report-only", action="store_true")
    args = ap.parse_args()
    os.makedirs(RESULTS, exist_ok=True)
    stem = STEM + ("_quick" if args.quick else "")
    jpath = os.path.join(RESULTS, stem + ".json")
    res = {}
    if os.path.exists(jpath) and (args.report_only or args.part != "all"):
        with open(jpath) as f:
            res = json.load(f)
    if not args.report_only:
        t0 = time.time()
        if args.part in ("all", "post"):
            print("post-completeness ...", flush=True)
            res["post"] = run_post(args.quick)
            print(f"  done in {res['post']['seconds']}s", flush=True)
        if args.part in ("all", "ipc"):
            print("intuitionistic contrast ...", flush=True)
            res["ipc"] = run_ipc(args.quick)
            print(f"  done in {res['ipc']['seconds']}s", flush=True)
        if args.part in ("all", "learning"):
            recs, secs = run_learning(args.quick, args.workers, args.resume)
            res["learning"] = {"records": recs, "seconds": round(secs, 1), "eval": EVAL, "prune": PRUNE}
        res["meta"] = {"quick": args.quick, "python": sys.version.split()[0]}
        with open(jpath, "w") as f:
            json.dump(res, f, indent=1, default=str)
    rep = make_report(res, args.quick)
    with open(os.path.join(RESULTS, stem + ".md"), "w") as f:
        f.write(rep)
    for p in make_plots(res, args.quick):
        print("wrote", p)
    print("wrote", jpath, "and", stem + ".md")


if __name__ == "__main__":
    main()
