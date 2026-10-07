"""Evaluation for the propositional natural-deduction domain.

Ground truth (classical truth tables, the target calculus, the fallacy list) is
used ONLY here and in the simulator, never by the learners.

* :func:`unsound_active`, :func:`recovery_report`, :func:`fallacy_report`:
  schema-level reports (soundness of a rule schema is decided exactly, see
  :func:`cil.domains.prop.rule_sound`).
* :func:`adversarial_attack`: an adversarial prover.  It knows the learned
  rules and searches (backward, budgeted) for derivations -- every step of which
  the learned verifier accepts -- of ``|- bot``, of fixed non-tautologies, of
  random invalid sequents, and of bottom from fresh satisfiable contexts.
* :func:`completeness`: fraction of random tautologies proved within a budget
  (reported next to the target calculus under the same prover and budget).
* :func:`heldout_steps` / :func:`acceptance_rates`: held-out valid steps (in
  and out of distribution) and invalid steps (fallacy instances, context
  errors, tonk-like steps, random mutations), labelled by local soundness.
"""
from __future__ import annotations

import random
from collections import defaultdict
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Sequence

from .domains.prop import (ATOMS, ATOMS_OOD, BOT, CLASSICAL_RULES, FALLACY_RULES, PStep, PropHumanConfig, Prover,
                           Seq, SeqRule, _mutate_step, fmt, format_proof, generate_corpus, local_sound_step,
                           match_step, neg, imp, parse_formula, proof_steps, random_formula, random_tautologies,
                           rule_sound, satisfiable, seq, valid, licenses)
from .terms import Var, subst

__all__ = [
    "unsound_active", "tonk_like", "recovery_report", "guard_relation", "fallacy_report", "adversarial_attack", "completeness",
    "heldout_steps", "acceptance_rates", "LabeledPStep", "FIXED_BAD_GOALS",
]


# ---------------------------------------------------------------------------
# Schema-level reports
# ---------------------------------------------------------------------------


def unsound_active(calc) -> list:
    return [lr for lr in calc.active() if not rule_sound(lr.rule)]


def tonk_like(rule: SeqRule) -> bool:
    """An unsound rule whose conclusion is a bare metavariable that does not
    occur in the premises: from the premises, *anything* follows (Prior's tonk,
    composed: A |- A tonk B |- B)."""
    c = rule.concl[1]
    if type(c) is not Var or c == BOT:
        return False
    for e, a in rule.prems:
        fs = [a] + (list(e.args) if not isinstance(e, Var) else [])
        if any(c.name in {v for v in _vars(f)} for f in fs):
            return False
    return not rule_sound(rule)


def _vars(t):
    from .terms import variables
    return variables(t)


def guard_relation(learned: SeqRule, target: SeqRule) -> Optional[str]:
    """'equiv' | 'stronger' | 'weaker' | 'incomparable' comparing the guards of two
    rules that are variants up to their guards (None otherwise).  A stronger
    guard requires more memberships (it is more restrictive)."""
    a, b = learned.canonical(), target.canonical()
    if a.term() != b.term():
        return None
    ga, gb = a.guard.pats, b.guard.pats
    if ga == gb:
        return "equiv"
    if ga >= gb:
        return "stronger"
    if ga <= gb:
        return "weaker"
    return "incomparable"


def recovery_report(calc, targets: Sequence[SeqRule] = CLASSICAL_RULES) -> Dict[str, str]:
    """Per target rule: 'exact' (an active learned rule is a variant, guard
    included), 'guard_stronger' / 'guard_weaker' / 'guard_incomparable' (variant
    up to the guard), 'specialized' (only proper instances are active),
    'generalized' (only strictly more general active rules license it), or
    'missing'."""
    act = calc.active()
    order = ["exact", "guard_stronger", "guard_weaker", "guard_incomparable"]
    names = {"equiv": "exact", "stronger": "guard_stronger", "weaker": "guard_weaker",
             "incomparable": "guard_incomparable"}
    out = {}
    for t in targets:
        rels = [guard_relation(lr.rule, t) for lr in act]
        rels = [names[r] for r in rels if r is not None]
        if rels:
            out[t.name] = min(rels, key=order.index)
        elif any(t.subsumes(lr.rule) for lr in act):
            out[t.name] = "specialized"
        elif any(lr.rule.subsumes(t) for lr in act):
            out[t.name] = "generalized"
        else:
            out[t.name] = "missing"
    return out


def fallacy_report(calc) -> Dict[str, dict]:
    """For each systematic fallacy: 'survived' (an active unsound rule licenses
    its schema or a special case of it: the fallacy schema is an instance of the
    rule, or the rule is an instance of the fallacy schema, e.g. affirming the
    consequent for the atom p only), 'removed' (a rule of that shape was learned
    at some point but none survives), 'inactive' (learned, but no active unsound
    rule of that shape: support < m, or only sound special cases) or
    'never_learned'."""
    out = {}
    for name, (frule, _) in FALLACY_RULES.items():
        shape = [lr for lr in calc.rules if lr.rule.variant_of(frule, check_guard=False)
                 or (frule.subsumes(lr.rule))]
        # REVIEW FIX: an active unsound *special case* of the fallacy (frule.subsumes(lr.rule)), e.g.
        # 'G |- p -> X1 ; G |- X1 / G |- p', was previously reported as 'inactive' although it is active
        # and unsound; it now counts as 'survived' (the unsound-rule counts were always correct).
        surv = [lr for lr in calc.active() if (lr.rule.subsumes(frule) or frule.subsumes(lr.rule))
                and not rule_sound(lr.rule)]
        if surv:
            st = "survived"
        elif any(lr.status in ("deleted", "split") or "GUARDED" in " ".join(lr.log) for lr in shape):
            st = "removed"
        elif shape:
            st = "inactive"
        else:
            st = "never_learned"
        out[name] = {"status": st, "learned": bool(shape), "surviving_rules": [str(lr.rule) for lr in surv]}
    return out


# ---------------------------------------------------------------------------
# Adversarial prover
# ---------------------------------------------------------------------------

FIXED_BAD_GOALS = [
    "|- bot", "|- p", "|- ~p", "|- p -> q", "|- (p -> q) -> q -> p", "|- (p -> q) -> ~p -> ~q",
    "|- p | q -> p", "|- (p -> q) -> q", "|- ~(p & q) -> ~p", "|- p -> p & q", "|- ~~p & ~p",
    "p |- q", "p -> q |- q -> p", "p | q |- p", "~~p |- q", "p -> q, q |- p", "p -> q, ~p |- ~q",
    "p, ~q |- bot", "p | q, ~p |- bot", "p -> q, ~q |- bot", "p & ~q |- bot", "~p, ~q |- p | q",
]


def _random_invalid(rng: random.Random, n: int, atoms_=ATOMS_OOD) -> List[Seq]:
    out, seen = [], set()
    while len(out) < n:
        G = frozenset(random_formula(rng, rng.randint(0, 2), atoms_, p_bot=0.0) for _ in range(rng.randint(0, 2)))
        A = random_formula(rng, rng.randint(0, 3), atoms_)
        s = Seq(G, A)
        if s in seen or not satisfiable(G) or valid(G, A):
            continue
        seen.add(s)
        out.append(s)
    return out


def adversarial_attack(calc, seed: int, n_random: int = 20, budget: int = 2000, max_depth: int = 10,
                       n_contexts: int = 6) -> Dict[str, object]:
    """Search, with the learned rules, for derivations of invalid sequents.

    Goals: :data:`FIXED_BAD_GOALS`, ``n_random`` random invalid sequents and
    ``Gamma |- bot`` for ``n_contexts`` fresh satisfiable contexts (none of which
    the learner saw).  Every derivation found is re-checked step by step with
    the learned verifier.  Returns counts and up to three example exploits."""
    rng = random.Random(7919 + seed)
    goals = [seq(s) for s in FIXED_BAD_GOALS] + _random_invalid(rng, n_random)
    for _ in range(n_contexts):
        while True:
            G = frozenset(random_formula(rng, rng.randint(0, 2), ATOMS_OOD, p_bot=0.0) for _ in range(rng.randint(1, 3)))
            if satisfiable(G):
                break
        goals.append(Seq(G, BOT))
    rules = calc.rule_list()
    pr = Prover(rules, budget=budget, max_depth=max_depth)
    names = {lr.sid: f"L{lr.sid}" for lr in calc.rules}
    exploits, examples = [], []
    for g in goals:
        node = pr.prove(g)
        if node is None:
            continue
        steps = proof_steps(node)
        assert all(calc.accepts(st.prems, st.concl) for st in steps), "prover produced an unaccepted step"
        assert not valid(g.ctx, g.succ)
        exploits.append(g.show())
        if len(examples) < 3:
            examples.append({"goal": g.show(uni=True), "proof": format_proof(node, names=names)})
    bot_ok = any(e == "|- bot" for e in exploits)
    return {"n_goals": len(goals), "n_exploits": len(exploits), "rate": len(exploits) / len(goals),
            "derives_bottom": bot_ok, "exploited_goals": exploits[:30], "examples": examples,
            "nodes": pr.total_nodes}


# ---------------------------------------------------------------------------
# Completeness
# ---------------------------------------------------------------------------


def completeness(rules, taus: Sequence, budget: int = 3000, max_depth: int = 12) -> Dict[str, object]:
    """Fraction of the tautologies ``taus`` proved by the rule list within the budget."""
    pr = Prover(rules, budget=budget, max_depth=max_depth)
    proved = []
    for f in taus:
        pr.success.clear()
        proved.append(pr.prove(Seq((), f)) is not None)
    return {"n": len(taus), "proved": sum(proved), "frac": sum(proved) / max(1, len(taus)), "flags": proved,
            "nodes": pr.total_nodes}


# ---------------------------------------------------------------------------
# Held-out steps
# ---------------------------------------------------------------------------


@dataclass
class LabeledPStep:
    prems: tuple
    concl: Seq
    valid: bool
    kind: str


def _rand_ctx(rng, atoms_, k_max=2):
    return frozenset(random_formula(rng, rng.randint(0, 2), atoms_) for _ in range(rng.randint(0, k_max)))


def _invalid_instances(rng: random.Random, n: int, atoms_) -> List[LabeledPStep]:
    """Instances of unsound schemas with random formulas and contexts, kept only
    if locally unsound (truly invalid as single steps)."""
    schemas = {name: r for name, (r, _) in FALLACY_RULES.items()}
    from .domains.prop import parse_rule
    schemas.update({
        "drop_assumption": parse_rule("G, A |- B / G |- B"),          # context bookkeeping error
        "tonk": parse_rule("G |- A / G |- B"),                        # tonk-like over-generalisation
        "converse": parse_rule("G |- A -> B / G |- B -> A"),
        "orE_one_case": parse_rule("G |- A | B ; G, A |- C / G |- C"),
        "andI_wrong": parse_rule("G |- A / G |- A & B"),
    })
    names = sorted(schemas)
    out = []
    tries = 0
    while len(out) < n and tries < 50 * n:
        tries += 1
        name = names[len(out) % len(names)]
        r = schemas[name]
        sig = {v: random_formula(rng, rng.randint(0, 2), atoms_) for v in r.formula_vars()}
        G = _rand_ctx(rng, atoms_)
        def inst(e, a):
            return Seq(G | {subst(f, sig) for f in e.args}, subst(a, sig))
        prems = tuple(inst(e, a) for e, a in r.prems)
        concl = inst(*r.concl)
        if local_sound_step(prems, concl):
            continue
        out.append(LabeledPStep(prems, concl, False, f"invalid:{name}"))
    return out


def heldout_steps(seed: int, n: int = 200) -> Dict[str, List[LabeledPStep]]:
    """Held-out labelled steps: 'valid_id', 'valid_ood' (from fresh clean human
    proofs; OOD = larger exercises over 4 atoms), 'invalid' (unsound-schema
    instances and random mutations of valid steps, all locally unsound)."""
    rng = random.Random(4242 + seed)
    out: Dict[str, List[LabeledPStep]] = {}
    for regime in ("id", "ood"):
        ds = generate_corpus(60, PropHumanConfig(regime=regime), seed=9000 + seed + (0 if regime == "id" else 500))
        steps = [st for d in ds for st in d.steps]
        uniq = list({(st.prems, st.concl): st for st in steps}.values())
        rng.shuffle(uniq)
        out[f"valid_{regime}"] = [LabeledPStep(st.prems, st.concl, True, "valid") for st in uniq[:n]]
    inv = _invalid_instances(rng, n // 2, ATOMS_OOD)
    ds = generate_corpus(30, PropHumanConfig(), seed=9900 + seed)
    pool = [st for d in ds for st in d.steps]
    k = 0
    while len(inv) < n and k < 50 * n:
        k += 1
        m = _mutate_step(rng, rng.choice(pool), ATOMS)
        if m is not None and not local_sound_step(m.prems, m.concl):
            inv.append(LabeledPStep(m.prems, m.concl, False, "invalid:mutation"))
    out["invalid"] = inv
    return out


def acceptance_rates(accept: Callable, sets: Dict[str, List[LabeledPStep]]) -> Dict[str, float]:
    """Acceptance rate per set, and per invalid kind."""
    res = {}
    by_kind = defaultdict(list)
    for name, steps in sets.items():
        acc = [bool(accept(s.prems, s.concl)) for s in steps]
        res[name] = sum(acc) / max(1, len(acc))
        if name == "invalid":
            for s, a in zip(steps, acc):
                by_kind[s.kind].append(a)
    for k, v in sorted(by_kind.items()):
        res[k] = sum(v) / len(v)
    return res
