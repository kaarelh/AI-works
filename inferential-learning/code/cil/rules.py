"""Rule schemas, guards, steps, licensing and rewrite-core extraction.

A *rule schema* in general is ``premises |- conclusion  [guard]`` over
schematic variables (:class:`InferenceSchema`).  For the equational domain a
rule is an oriented rewrite schema ``l -> r [guard]`` (:class:`RewriteRule`).

Guards
------
A guard is a finite conjunction of atoms ``pred(v)`` where ``v`` is a
schematic variable of the rule and ``pred`` comes from a finite, domain
supplied guard language (for algebra: ``defined``, ``nonzero``, ``nonneg``).
For an instance ``sigma`` the guard is *satisfied in a context* (a finite set
of known facts ``F``) iff ``entails(F, (pred, sigma(v)))`` for every atom, where
``entails`` is a domain-supplied, sound decision procedure.

Steps
-----
A step is a pair ``(before, after)`` of ground terms (plus the context facts).
It is *licensed* by a rule ``R`` iff there is a position ``p`` and a matching
substitution ``sigma`` with ``before|p = sigma(l)``, ``after = before[sigma(r)]_p``
and the guard satisfied.  Because ``after`` must agree with ``before`` outside
``p``, the only candidate positions are the ancestors of the *minimal
difference position* (see :func:`diff_chain`); licensing checks all of them.

Rewrite cores
-------------
``diff_chain(before, after)`` returns the candidate cores
``(p, before|p, after|p)`` from the deepest (the minimal differing subterms)
up to the root.  The deepest core is the canonical one used for learning.
It is *ambiguous* in general: e.g. ``(y+0)+0 -> y+0`` is explained both by
``add_zero`` at the root and by ``add_zero`` at position (0,), because the
instance collapses.  Every consumer that needs exactness (licensing, guard
inference) therefore quantifies over the whole chain.
"""
from __future__ import annotations

import itertools
import re
from dataclasses import dataclass, field
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

from .terms import (App, Pos, Subst, Term, Var, canonical_tuple, is_variant_tuple, lgg_tuples,
                    match, match_tuple, pretty, replace, subst, subterm, subterms, variables)

__all__ = [
    "GuardAtom", "Guard", "TRUE_GUARD", "Fact", "Facts", "EntailFn",
    "RewriteRule", "InferenceSchema", "Step",
    "diff_chain", "minimal_core", "licenses", "explanations", "all_rewrites",
    "induce_schema", "guard_satisfied", "rule_from_strings", "rule_from_str",
]

GuardAtom = Tuple[str, str]            # (predicate, variable name)
Fact = Tuple[str, Term]                # (predicate, ground term)
Facts = FrozenSet[Fact]
EntailFn = Callable[[Facts, Fact], bool]


class Guard:
    """Conjunction of guard atoms (immutable)."""

    __slots__ = ("atoms",)

    def __init__(self, atoms: Iterable[GuardAtom] = ()):
        self.atoms: FrozenSet[GuardAtom] = frozenset(atoms)

    def __iter__(self):
        return iter(sorted(self.atoms))

    def __len__(self):
        return len(self.atoms)

    def __bool__(self):
        return bool(self.atoms)

    def __eq__(self, other):
        return isinstance(other, Guard) and other.atoms == self.atoms

    def __hash__(self):
        return hash(self.atoms)

    def __and__(self, other: "Guard") -> "Guard":
        return Guard(self.atoms | other.atoms)

    def rename(self, mapping: Dict[str, str]) -> "Guard":
        return Guard((p, mapping.get(v, v)) for p, v in self.atoms)

    def implies(self, other: "Guard", pred_implies: Optional[Callable[[str, str], bool]] = None) -> bool:
        """Syntactic implication: every atom of ``other`` is implied by some
        atom of ``self`` (``pred_implies(p, q)`` says p(v) implies q(v))."""
        pi = pred_implies or (lambda p, q: p == q)
        return all(any(v == w and pi(p, q) for p, v in self.atoms) for q, w in other.atoms)

    def __str__(self):
        if not self.atoms:
            return "true"
        return " & ".join(f"{p}(?{v})" for p, v in sorted(self.atoms))

    __repr__ = __str__


TRUE_GUARD = Guard()


def guard_satisfied(guard: Guard, sigma: Subst, facts: Facts, entails: Optional[EntailFn]) -> bool:
    if not guard.atoms:
        return True
    if entails is None:
        return False
    for p, v in guard.atoms:
        t = sigma.get(v)
        if t is None or not entails(facts, (p, t)):
            return False
    return True


class RewriteRule:
    """Oriented rewrite schema ``lhs -> rhs [guard]``."""

    __slots__ = ("lhs", "rhs", "guard", "name", "_canon")

    def __init__(self, lhs: Term, rhs: Term, guard: Guard = TRUE_GUARD, name: str = ""):
        self.lhs = lhs
        self.rhs = rhs
        self.guard = guard
        self.name = name
        self._canon = None

    # -- structure -------------------------------------------------------
    def vars(self) -> List[str]:
        return variables((self.lhs, self.rhs))

    def is_range_restricted(self) -> bool:
        """rhs variables are lhs variables, guard variables are lhs variables,
        and the lhs is not a bare variable (so the rule is a proper rewrite)."""
        lv = set(variables(self.lhs))
        return (type(self.lhs) is not Var
                and set(variables(self.rhs)) <= lv
                and all(v in lv for _, v in self.guard.atoms))

    def canonical(self) -> "RewriteRule":
        """Variables renamed ``v0, v1, ...`` (guard renamed consistently)."""
        if self._canon is None:
            names = self.vars()
            m = {n: f"v{i}" for i, n in enumerate(names)}
            l, r = canonical_tuple((self.lhs, self.rhs))
            self._canon = RewriteRule(l, r, self.guard.rename(m), self.name)
        return self._canon

    def key(self):
        """Hashable identity up to variable renaming (including the guard)."""
        c = self.canonical()
        return (c.lhs, c.rhs, c.guard)

    def shape_key(self):
        """Identity up to renaming, ignoring the guard."""
        c = self.canonical()
        return (c.lhs, c.rhs)

    def variant_of(self, other: "RewriteRule", check_guard: bool = True) -> bool:
        if check_guard:
            return self.key() == other.key()
        return self.shape_key() == other.shape_key()

    def with_guard(self, guard: Guard, name: Optional[str] = None) -> "RewriteRule":
        return RewriteRule(self.lhs, self.rhs, guard, self.name if name is None else name)

    def size(self) -> int:
        return self.lhs.size + self.rhs.size

    def subsumes(self, other: "RewriteRule") -> bool:
        """``other`` (as an unguarded schema) is an instance of ``self``."""
        o = other.canonical()
        mine = canonical_tuple((self.lhs, self.rhs), prefix="s")
        return match_tuple(mine, (o.lhs, o.rhs)) is not None

    # -- application ------------------------------------------------------
    def match_at(self, term: Term) -> Optional[Subst]:
        return match(self.lhs, term)

    def rewrites(self, term: Term, facts: Facts = frozenset(), entails: Optional[EntailFn] = None,
                 check_guard: bool = True) -> List[Tuple[Pos, Term, Subst]]:
        """All one-step rewrites of ``term`` by this rule: (pos, new_term, sigma)."""
        out = []
        h = self.lhs.head if type(self.lhs) is App else None
        for p, u in subterms(term):
            if h is not None and (type(u) is not App or u.head != h):
                continue
            s = match(self.lhs, u)
            if s is None:
                continue
            if check_guard and not guard_satisfied(self.guard, s, facts, entails):
                continue
            out.append((p, replace(term, p, subst(self.rhs, s)), s))
        return out

    def __str__(self):
        g = "" if not self.guard else f"   [if {self.guard}]"
        nm = f"{self.name}: " if self.name else ""
        return f"{nm}{pretty(self.lhs)} -> {pretty(self.rhs)}{g}"

    def __repr__(self):
        return f"RewriteRule({self})"


def rule_from_strings(lhs: str, rhs: str, guard: Iterable[GuardAtom] = (), name: str = "") -> RewriteRule:
    """Build a rule from infix strings; bare identifiers are schematic vars."""
    from .terms import parse_pattern
    return RewriteRule(parse_pattern(lhs), parse_pattern(rhs), Guard(guard), name)


_GUARD_ATOM = re.compile(r"(\w+)\(\?([^)]+)\)")
_RULE_NAME = re.compile(r"^([A-Za-z_][\w']*): ")


def rule_from_str(s: str) -> RewriteRule:
    """Inverse of ``str(RewriteRule)``: parses ``[name: ]lhs -> rhs[   [if g & ...]]``
    where schematic variables are written ``?v`` and bare identifiers are
    object constants (used to re-analyse rules stored in result JSON files)."""
    from .terms import parse
    s = s.strip()
    name = ""
    m = _RULE_NAME.match(s)
    if m:
        name, s = m.group(1), s[m.end():]
    guard = TRUE_GUARD
    if "[if " in s:
        s, g = s.split("[if ", 1)
        guard = Guard((p, v) for p, v in _GUARD_ATOM.findall(g))
    lhs, rhs = s.split(" -> ")
    return RewriteRule(parse(lhs.strip()), parse(rhs.strip()), guard, name)


@dataclass(frozen=True)
class InferenceSchema:
    """General schema ``premises |- conclusion [guard]`` (for non-equational
    domains).  Licensing is simultaneous one-way matching of the tuple."""

    premises: Tuple[Term, ...]
    conclusion: Term
    guard: Guard = TRUE_GUARD
    name: str = ""

    def instance(self, premises: Sequence[Term], conclusion: Term, facts: Facts = frozenset(),
                 entails: Optional[EntailFn] = None) -> Optional[Subst]:
        s = match_tuple(tuple(self.premises) + (self.conclusion,), tuple(premises) + (conclusion,))
        if s is None or not guard_satisfied(self.guard, s, facts, entails):
            return None
        return s

    @staticmethod
    def induce(instances: Sequence[Tuple[Sequence[Term], Term]], name: str = "") -> "InferenceSchema":
        tps = [tuple(p) + (c,) for p, c in instances]
        g = lgg_tuples(tps)
        return InferenceSchema(tuple(g[:-1]), g[-1], TRUE_GUARD, name)


@dataclass
class Step:
    """A single inference step ``before -> after`` in a derivation.

    ``tag`` is the rule name the (simulated) human cites; ``kind`` is the hidden
    generation label ('valid', 'arith', 'fallacy:<name>', 'noise') which learners
    must not look at."""

    before: Term
    after: Term
    tag: str = ""
    kind: str = "valid"
    meta: dict = field(default_factory=dict)


# ---------------------------------------------------------------------------
# Core extraction and licensing
# ---------------------------------------------------------------------------


def diff_chain(before: Term, after: Term) -> List[Tuple[Pos, Term, Term]]:
    """Candidate rewrite cores of a step, deepest first.

    Descend from the root while both terms have the same head/arity and differ
    in exactly one argument; the position reached is the minimal difference
    position ``p*``.  The chain lists ``(p, before|p, after|p)`` for ``p*`` and
    every ancestor of ``p*`` (closest first).  Empty iff ``before == after``.
    """
    if before == after:
        return []
    path: List[Pos] = [()]
    b, a = before, after
    pos: Pos = ()
    while (type(b) is App and type(a) is App and b.head == a.head and len(b.args) == len(a.args)):
        diff = [i for i in range(len(b.args)) if b.args[i] != a.args[i]]
        if len(diff) != 1:
            break
        i = diff[0]
        pos = pos + (i,)
        path.append(pos)
        b, a = b.args[i], a.args[i]
    chain = []
    for p in reversed(path):
        chain.append((p, subterm(before, p), subterm(after, p)))
    return chain


def minimal_core(before: Term, after: Term) -> Optional[Tuple[Pos, Term, Term]]:
    ch = diff_chain(before, after)
    return ch[0] if ch else None


def explanations(rule: RewriteRule, before: Term, after: Term, chain=None) -> List[Tuple[Pos, Subst]]:
    """All (position, sigma) such that the step is an *unguarded* instance of
    ``rule`` at that position (positions taken from the diff chain)."""
    ch = diff_chain(before, after) if chain is None else chain
    out = []
    pats = (rule.lhs, rule.rhs)
    for p, u, v in ch:
        s = match_tuple(pats, (u, v))
        if s is not None:
            out.append((p, s))
    return out


def licenses(rule: RewriteRule, before: Term, after: Term, facts: Facts = frozenset(),
             entails: Optional[EntailFn] = None, chain=None) -> Optional[Tuple[Pos, Subst]]:
    """Does ``rule`` license the step?  Returns a witnessing (pos, sigma) or None.

    Note: the rhs is matched jointly with the lhs, so a rule whose rhs has a
    variable not in its lhs is matched on the *step* (that variable is bound by
    the after-term); rules used for derivation must be range restricted."""
    for p, s in explanations(rule, before, after, chain):
        if guard_satisfied(rule.guard, s, facts, entails):
            return p, s
    return None


def all_rewrites(term: Term, rules: Sequence[RewriteRule], facts: Facts = frozenset(),
                 entails: Optional[EntailFn] = None, index: Optional[Dict[str, List[int]]] = None,
                 check_guard: bool = True) -> List[Tuple[int, Pos, Term, Subst]]:
    """All one-step rewrites of ``term`` by any rule: (rule index, pos, new, sigma).
    ``index`` maps lhs head symbols to rule indices (built if omitted)."""
    if index is None:
        index = {}
        for i, r in enumerate(rules):
            index.setdefault(r.lhs.head if type(r.lhs) is App else None, []).append(i)
    out = []
    for p, u in subterms(term):
        if type(u) is not App:
            continue
        for i in index.get(u.head, ()):
            r = rules[i]
            s = match(r.lhs, u)
            if s is None:
                continue
            if check_guard and not guard_satisfied(r.guard, s, facts, entails):
                continue
            out.append((i, p, replace(term, p, subst(r.rhs, s)), s))
    return out


def induce_schema(cores: Sequence[Tuple[Term, Term]], name: str = "") -> RewriteRule:
    """Least general (unguarded) rewrite schema covering all cores, via
    anti-unification of the (lhs, rhs) tuples with one shared variable table."""
    l, r = lgg_tuples([(u, v) for u, v in cores])
    return RewriteRule(l, r, TRUE_GUARD, name)


def guard_candidates(rule: RewriteRule, preds: Sequence[str], max_atoms: int) -> List[Guard]:
    """All conjunctions of at most ``max_atoms`` atoms ``pred(v)`` over the lhs
    variables, smallest first (deterministic order)."""
    vs = variables(rule.lhs)
    atoms = [(p, v) for v in vs for p in preds]
    out = []
    for k in range(1, max_atoms + 1):
        for combo in itertools.combinations(atoms, k):
            out.append(Guard(combo))
    return out


__all__.append("guard_candidates")
