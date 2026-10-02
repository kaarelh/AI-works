"""Evaluation utilities: recovery / fallacy reports, held-out step sets
(in-distribution and out-of-distribution), an adversarial prover, and an
average-case ML verifier baseline.

Ground truth is used ONLY here (never by the learners): the target calculus,
the fallacy list, and an independent high-sample world oracle for labelling.
"""
from __future__ import annotations

import random
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Sequence, Tuple

from .domains import algebra as alg
from .rules import Guard, RewriteRule, TRUE_GUARD, diff_chain, guard_satisfied
from .terms import (App, HOLE, Term, Var, atoms, canonical_tuple, match_tuple, num, plug, positions,
                    replace, subst, subterm, variables)

# ---------------------------------------------------------------------------
# Schema-level reports
# ---------------------------------------------------------------------------


def _rename_map(learned: RewriteRule, target: RewriteRule) -> Optional[Dict[str, str]]:
    """Variable map learned -> target if the two are variants (ignoring guards)."""
    th = match_tuple((learned.lhs, learned.rhs), (target.lhs, target.rhs))
    if th is None or any(type(t) is not Var for t in th.values()):
        return None
    inv = match_tuple((target.lhs, target.rhs), (learned.lhs, learned.rhs))
    if inv is None or any(type(t) is not Var for t in inv.values()):
        return None
    return {k: v.name for k, v in th.items()}


def guard_relation(learned: RewriteRule, target: RewriteRule) -> Optional[str]:
    """'equiv' | 'stronger' | 'weaker' | 'incomparable' (learned vs target guard),
    or None if the schemas are not variants."""
    m = _rename_map(learned, target)
    if m is None:
        return None
    g = learned.guard.rename(m)
    a = g.implies(target.guard, alg.pred_implies)
    b = target.guard.implies(g, alg.pred_implies)
    if a and b:
        return "equiv"
    if a:
        return "stronger"
    if b:
        return "weaker"
    return "incomparable"


def recovery_report(calc, targets: Sequence[RewriteRule] = alg.TARGET_RULES) -> Dict[str, str]:
    """Per target rule: 'exact' (variant with equivalent guard), 'guard_stronger',
    'guard_weaker', 'guard_incomparable', 'specialized' (only proper instances
    are active), or 'missing'."""
    act = calc.active()
    out = {}
    order = ["exact", "guard_stronger", "guard_weaker", "guard_incomparable"]
    for r in targets:
        rels = [guard_relation(s.rule, r) for s in act]
        rels = [x for x in rels if x is not None]
        if rels:
            names = {"equiv": "exact", "stronger": "guard_stronger", "weaker": "guard_weaker",
                     "incomparable": "guard_incomparable"}
            out[r.name] = min((names[x] for x in rels), key=order.index)
        elif any(r.subsumes(s.rule) for s in act):
            out[r.name] = "specialized"
        else:
            out[r.name] = "missing"
    return out


def unsound_active(calc, seed: int = 0, n: int = 250) -> List:
    return [s for s in calc.active() if not alg.schema_sound(s.rule, seed=seed, n=n)]


def fallacy_report(calc, fallacies: Sequence[alg.Fallacy] = alg.FALLACIES, seed: int = 0) -> Dict[str, dict]:
    """For each fallacy: was a schema of its shape ever learned, what happened to
    it, and does any ACTIVE *unsound* schema still license its instances?"""
    out = {}
    for f in fallacies:
        shape = [s for s in calc.schemas if s.rule.variant_of(f.rule, check_guard=False)]
        learned_any = bool(shape)
        accepting = [s for s in calc.active() if f.rule.subsumes(s.rule)
                     and not alg.schema_sound(s.rule, seed=seed, n=200)]
        if f.kind == "guard_drop":
            target = alg.TARGET_BY_NAME[f.tag]
            act_shape = [s for s in calc.active() if s.rule.variant_of(target, check_guard=False)]
            rels = [guard_relation(s.rule, target) for s in act_shape]
            if accepting:
                status = "survived"
            elif any(r in ("equiv", "stronger") for r in rels) and any("REPAIRED" in "".join(s.log) for s in act_shape):
                status = "repaired"
            elif any(r in ("equiv", "stronger") for r in rels):
                status = "guarded"
            elif learned_any:
                status = "deleted"
            else:
                status = "never_learned"
        else:
            if accepting:
                status = "survived"
            elif learned_any:
                status = "deleted" if all(s.status in ("deleted", "split") or s.support < calc.m for s in shape) else "inactive"
            else:
                status = "never_learned"
        out[f.name] = {"status": status, "learned_shape": learned_any,
                       "active_unsound_instances": len(accepting)}
    return out


# ---------------------------------------------------------------------------
# Held-out steps
# ---------------------------------------------------------------------------


@dataclass
class LabeledStep:
    before: Term
    after: Term
    facts: frozenset
    valid: bool
    kind: str
    rule: str = ""


_NASTY = {
    "nonzero": ["{u} - {u}", "{u}*({x} - 1)", "{x} - 2", "0*{u}", "{u}*0", "({x} - {x})*{u}", "{x}^2 - 1", "{x}"],
    "nonneg": ["-({u})^2 - 1", "{x} - 3", "-{x}", "{x} - {x} - 1", "-({u}*{u}) - 2", "{x}"],
    "defined": ["{u}/({x} - {x})", "{u}/({x} - 1)", "1/{x}", "sqrt({x} - 3)", "{u}/0", "sqrt(-1 - {x}^2)"],
}


def _nasty_term(rng: random.Random, pred: str, size: int) -> Term:
    from .terms import parse
    u = alg.random_term(rng, max(1, size))
    x = rng.choice(["x", "y", "z"])
    tmpl = rng.choice(_NASTY[pred])
    return parse(tmpl.format(u="(" + str(u) + ")", x=x))


def _instantiate(rng, rule: RewriteRule, size: int, n_values=(2, 3, 4, 5)) -> Dict[str, Term]:
    sig = {}
    for v in rule.vars():
        if v == "n":
            sig[v] = num(rng.choice(list(n_values)))
        else:
            sig[v] = alg.random_term(rng, rng.randint(max(1, size // 2), max(1, size)))
    return sig


def _embed(rng, core_before: Term, core_after: Term, ctx_depth: int, ctx_size: int):
    ctx = alg.random_context(rng, ctx_depth, size=ctx_size)
    return plug(ctx, core_before), plug(ctx, core_after)


_SIZES = {
    # (variable instance size, context depth, context operand size)
    "id": (2, (0, 2), (1, 3)),
    "ood": (7, (3, 5), (3, 6)),
}


def make_valid_steps(n: int, regime: str, seed: int, rules: Sequence[RewriteRule] = alg.TARGET_RULES,
                     oracle: Optional[alg.WorldOracle] = None) -> List[LabeledStep]:
    """Valid steps: random target rule instances (guard facts added to the
    context when needed and satisfiable) embedded in random contexts."""
    rng = random.Random(seed)
    sat = alg.WorldOracle(seed=seed + 1, n_points=3)
    vs, (d0, d1), (c0, c1) = _SIZES[regime]
    out = []
    while len(out) < n:
        r = rules[len(out) % len(rules)]
        sig = _instantiate(rng, r, vs, (2, 3) if regime == "id" else (2, 3, 4, 5, 6))
        lb, la = subst(r.lhs, sig), subst(r.rhs, sig)
        if lb == la:
            continue
        need = frozenset((p, sig[v]) for p, v in r.guard.atoms if not alg.entails(frozenset(), (p, sig[v])))
        extra = set()
        if rng.random() < 0.3:
            extra.add((rng.choice(["nonneg", "nonzero", "pos"]), App(rng.choice(["x", "y", "z"]))))
        facts = frozenset(set(need) | extra)
        if facts and not sat.satisfiable(facts):
            continue
        b, a = _embed(rng, lb, la, rng.randint(d0, d1), rng.randint(c0, c1))
        if b == a:
            continue
        out.append(LabeledStep(b, a, facts, True, "valid", r.name))
    return out


def _near_misses() -> List[RewriteRule]:
    """Plausible-looking invalid schemas: target rules with a perturbed rhs."""
    from .rules import rule_from_strings as R
    return [
        R("a - b", "b - a", name="nm_sub_comm"), R("a/b", "b/a", name="nm_div_comm"),
        R("(a - b) - c", "a - (b - c)", name="nm_sub_assoc"), R("a*(b - c)", "a*b - c", name="nm_distrib_drop"),
        R("(a + b)^2", "a^2 + a*b + b^2", name="nm_binom_1"), R("a^2 - b^2", "(a - b)^2", name="nm_diffsq"),
        R("(a + b)*c", "a*c + b", name="nm_distrib_r"), R("-(a*b)", "(-a)*(-b)", name="nm_negmul"),
        R("a/(b + c)", "a/b + a/c", name="nm_div_split"), R("sqrt(a + b)", "sqrt(a) + sqrt(b)", name="nm_sqrt_add"),
        R("a*a", "2*a", name="nm_sq_double"), R("(a*b)^2", "a^2*b", name="nm_mulpow"),
        R("a/(b*c)", "(a/b)*c", name="nm_divmul"), R("a - (b + c)", "a - b + c", name="nm_sub_add"),
    ]


NEAR_MISSES = _near_misses()


def make_invalid_steps(n: int, regime: str, seed: int, label_oracle: alg.WorldOracle,
                       kinds=("fallacy", "guard_violation", "mutation", "near_miss")) -> List[LabeledStep]:
    """Invalid steps of several kinds; kept only if ``label_oracle`` refutes them
    (a certain witness of invalidity)."""
    rng = random.Random(seed)
    vs, (d0, d1), (c0, c1) = _SIZES[regime]
    out = []
    guarded = [r for r in alg.TARGET_RULES if r.guard]
    tries = 0
    while len(out) < n and tries < 50 * n:
        tries += 1
        kind = kinds[len(out) % len(kinds)]
        name = ""
        if kind == "fallacy":
            f = rng.choice(alg.FALLACIES)
            sig = _instantiate(rng, f.rule, vs)
            if f.kind == "guard_drop":
                base = alg.TARGET_BY_NAME[f.tag]
                for p, v in base.guard.atoms:
                    if rng.random() < 0.7:
                        sig[v] = _nasty_term(rng, p, max(1, vs // 2))
            lb, la, name = subst(f.rule.lhs, sig), subst(f.rule.rhs, sig), f.name
        elif kind == "guard_violation":
            r = rng.choice(guarded)
            sig = _instantiate(rng, r, vs)
            for p, v in r.guard.atoms:
                sig[v] = _nasty_term(rng, p, max(1, vs // 2))
            lb, la, name = subst(r.lhs, sig), subst(r.rhs, sig), r.name
        elif kind == "near_miss":
            r = rng.choice(NEAR_MISSES)
            sig = _instantiate(rng, r, vs)
            lb, la, name = subst(r.lhs, sig), subst(r.rhs, sig), r.name
        else:  # mutation (the sporadic-noise model) of a random term
            t = alg.random_term(rng, rng.randint(4, 8) if regime == "id" else rng.randint(20, 45))
            m = alg._mutate(rng, t)
            if m is None:
                continue
            lb, la = t, m
        if lb == la:
            continue
        if kind == "mutation":
            b, a = lb, la
        else:
            b, a = _embed(rng, lb, la, rng.randint(d0, d1), rng.randint(c0, c1))
        facts = frozenset()
        if rng.random() < 0.3:
            facts = frozenset({(rng.choice(["nonneg", "nonzero", "pos"]), App(rng.choice(["x", "y", "z"])))})
        if label_oracle.counterexample(b, a, facts, n=60) is None:
            continue
        out.append(LabeledStep(b, a, facts, False, kind, name))
    return out


def acceptance_rates(accept: Callable[[Term, Term, frozenset], bool], steps: Sequence[LabeledStep]) -> Dict[str, float]:
    """Acceptance rate overall and per kind."""
    tot: Dict[str, List[int]] = {}
    for s in steps:
        a = int(bool(accept(s.before, s.after, s.facts)))
        tot.setdefault("all", []).append(a)
        tot.setdefault(s.kind, []).append(a)
    return {k: sum(v) / len(v) for k, v in tot.items() if v}


# ---------------------------------------------------------------------------
# Adversarial prover
# ---------------------------------------------------------------------------


def adversarial_attack(calc, oracle: alg.WorldOracle, seed: int, trials_per_schema: int = 12,
                       size: int = 6, extra_pool: Sequence[LabeledStep] = ()) -> Dict[str, object]:
    """White-box adversary against a learned calculus.

    For every active schema S it builds out-of-distribution instances whose
    learned guard is *entailed* (it adds exactly the learned guard facts to the
    context) while every other variable, and the variables of true-guard atoms
    that the learned guard misses, are instantiated with "nasty" terms (that can
    vanish, be negative or be undefined), embedded in large random contexts.
    It also replays a pool of pre-labelled invalid steps.  Every accepted step
    is checked by the oracle; returns counts of accepted invalid steps."""
    rng = random.Random(seed)
    found = []
    tried = 0
    for s in sorted(calc.active(), key=lambda s: s.sid):
        r = s.rule
        for _ in range(trials_per_schema):
            sig = {}
            for v in r.vars():
                if rng.random() < 0.5:
                    p = rng.choice(["nonzero", "nonneg", "defined"])
                    sig[v] = _nasty_term(rng, p, max(1, size // 2))
                else:
                    sig[v] = alg.random_term(rng, rng.randint(1, size))
            lb, la = subst(r.lhs, sig), subst(r.rhs, sig)
            if lb == la:
                continue
            facts = frozenset((p, sig[v]) for p, v in r.guard.atoms)
            ctx = alg.random_context(rng, rng.randint(2, 4), size=rng.randint(2, 5))
            b, a = plug(ctx, lb), plug(ctx, la)
            tried += 1
            if not calc.accepts(b, a, facts):
                continue
            if facts and not oracle.satisfiable(facts):
                continue
            if oracle.counterexample(b, a, facts, n=40) is not None:
                found.append((s.sid, str(r)))
    replay_acc = 0
    for st in extra_pool:
        if not st.valid and calc.accepts(st.before, st.after, st.facts):
            replay_acc += 1
    return {"tried": tried, "accepted_invalid": len(found),
            "schemas_exploited": sorted({f[1] for f in found}),
            "replay_accepted_invalid": replay_acc, "replay_size": len([x for x in extra_pool if not x.valid])}


# ---------------------------------------------------------------------------
# Average-case ML verifier baseline
# ---------------------------------------------------------------------------

_SYMS = ["+", "-", "*", "/", "^", "neg", "sqrt", "0", "1", "2", "3", "atom"]


def _sym_counts(t: Term) -> List[int]:
    c = dict.fromkeys(_SYMS, 0)
    stack = [t]
    while stack:
        u = stack.pop()
        if type(u) is App:
            if not u.args:
                key = u.head if u.head in c else ("atom" if not u.head.isdigit() else "3")
                c[key] += 1
            else:
                c[u.head if u.head in c else "atom"] += 1
                stack.extend(u.args)
    return [c[k] for k in _SYMS]


def step_features(before: Term, after: Term, facts=frozenset()) -> List[float]:
    """Hand-crafted features of a step's minimal rewrite core."""
    ch = diff_chain(before, after)
    if not ch:
        return [0.0] * (2 * len(_SYMS) + 10)
    _, u, v = ch[0]
    cu, cv = _sym_counts(u), _sym_counts(v)
    au, av = atoms(u), atoms(v)
    from .terms import depth, subterms
    sub_u = {w for _, w in subterms(u)}
    return ([float(x) for x in cu] + [float(y - x) for x, y in zip(cu, cv)]
            + [float(u.size), float(v.size), float(v.size - u.size), float(depth(u)), float(depth(v)),
               float(v in sub_u), float(len(au)), float(len(av - au)), float(len(ch)), float(len(facts))])


class MLVerifier:
    """Gradient-boosted classifier on :func:`step_features` (process-reward-model
    style).  Trained with *supervised* labels: positives = valid human steps,
    negatives = invalid human steps plus random corruptions of human steps."""

    def __init__(self, seed: int = 0, threshold: float = 0.5):
        from sklearn.ensemble import GradientBoostingClassifier
        self.clf = GradientBoostingClassifier(random_state=seed, n_estimators=150, max_depth=3)
        self.seed = seed
        self.threshold = threshold

    def fit(self, steps, label_oracle: alg.WorldOracle, n_neg_per: int = 1):
        rng = random.Random(self.seed)
        X, y = [], []
        for h in steps:
            if h.arith:
                continue
            valid = label_oracle.counterexample(h.before, h.after, h.facts, n=30) is None
            X.append(step_features(h.before, h.after, h.facts))
            y.append(int(valid))
            for _ in range(n_neg_per):
                m = alg._mutate(rng, h.after)
                if m is None or m == h.before:
                    continue
                if label_oracle.counterexample(h.before, m, h.facts, n=20) is None:
                    continue
                X.append(step_features(h.before, m, h.facts))
                y.append(0)
        self.clf.fit(X, y)
        self.train_size = len(y)
        return self

    def score(self, before, after, facts=frozenset()) -> float:
        return float(self.clf.predict_proba([step_features(before, after, facts)])[0][1])

    def accepts(self, before, after, facts=frozenset()) -> bool:
        if before == after:
            return True
        if alg.arith_step_ok(before, after):
            return True
        return self.score(before, after, facts) >= self.threshold


def black_box_attack(accept: Callable, oracle: alg.WorldOracle, seed: int, budget: int = 400) -> Dict[str, object]:
    """Black-box adversary: proposes OOD candidate steps (fallacies, guard
    violations, near misses, mutations, plus *valid-looking* schema
    applications with perturbed rhs) and counts accepted ones that the oracle
    refutes."""
    pool = make_invalid_steps(budget, "ood", seed, oracle)
    acc = [s for s in pool if accept(s.before, s.after, s.facts)]
    by_kind: Dict[str, int] = {}
    for s in acc:
        by_kind[s.kind] = by_kind.get(s.kind, 0) + 1
    return {"tried": len(pool), "accepted_invalid": len(acc), "by_kind": by_kind}
