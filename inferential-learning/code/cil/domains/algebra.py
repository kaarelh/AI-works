"""Field / ring algebra over partial terms: the experimental workhorse domain.

Contents
--------
* **Semantics.**  Terms over ``+ - * / ^ neg sqrt``, integer literals and
  object variables (atoms ``x, y, ...``) denote *partial* functions of the
  atoms: ``a/0`` is undefined, ``sqrt(a)`` is undefined for ``a < 0``,
  ``a^n`` is defined only for integer ``n`` (and ``0^n`` undefined for
  ``n < 0``; ``0^0 = 1``).  All operations are strict (undefined in =>
  undefined out).  Exact arithmetic uses ``fractions.Fraction``; square roots
  of non-squares fall back to 60-digit ``mpmath`` floats compared with a
  relative tolerance.  Equality of partial values is *Kleene (strong)*
  equality: both undefined, or both defined and equal.
* **Validity.**  A step ``s -> t`` in a context with facts ``F`` is *valid* iff
  ``[[s]] ~= [[t]]`` at every assignment of reals to the atoms satisfying ``F``.
  (So unguarded ``x/x -> 1`` is invalid: at ``x = 0`` the lhs is undefined.)
* **Guard language** ``defined(v)``, ``nonzero(v)``, ``nonneg(v)`` (conjunctions)
  and a sound, incomplete syntactic **entailment** procedure ``entails(F, fact)``.
* **Target calculus** ``TARGET_RULES`` (41 rewrite schemas, 13 of them guarded)
  plus the built-in, non-learned **arith** step (evaluate a numeral expression).
* **Systematic fallacies** ``FALLACIES`` and a **human derivation generator**
  with sporadic noise (:class:`HumanConfig`, :func:`generate_corpus`).
* **World oracle** :class:`WorldOracle`: random-point evaluation
  (Schwartz-Zippel style) with points drawn from a mixture of special small
  values and random rationals, restricted to points satisfying the facts.
"""
from __future__ import annotations

import math
import random
from dataclasses import dataclass, field
from fractions import Fraction
from functools import lru_cache
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

import mpmath

from ..rules import (Fact, Facts, Guard, RewriteRule, Step, TRUE_GUARD, all_rewrites, diff_chain,
                     guard_satisfied, rule_from_strings)
from ..terms import (App, Term, Var, atoms, is_numeral, num, numeral_value, parse, positions, pretty,
                     replace, subst, subterm, subterms, variables)

mpmath.mp.dps = 60
_EPS = mpmath.mpf("1e-35")
_REL_TOL = mpmath.mpf("1e-30")
MAX_EXP = 64
MAX_BITS = 6000


class _Undef:
    __slots__ = ()

    def __repr__(self):
        return "UNDEF"


UNDEF = _Undef()


class EvalSkip(Exception):
    """Raised when a point cannot be evaluated reliably (overflow etc.)."""


# ---------------------------------------------------------------------------
# Evaluation
# ---------------------------------------------------------------------------


def _to_mpf(v):
    if isinstance(v, Fraction):
        return mpmath.mpf(v.numerator) / v.denominator
    return v


def _is_zero(v) -> bool:
    if isinstance(v, Fraction):
        return v == 0
    return abs(v) < _EPS


def _sign(v) -> int:
    if isinstance(v, Fraction):
        return (v > 0) - (v < 0)
    if abs(v) < _EPS:
        return 0
    return 1 if v > 0 else -1


def _check_size(v):
    if isinstance(v, Fraction):
        if v.numerator.bit_length() > MAX_BITS or v.denominator.bit_length() > MAX_BITS:
            raise EvalSkip("too large")
    elif abs(v) > mpmath.mpf(10) ** 500:
        raise EvalSkip("too large")
    return v


def _as_int(v) -> Optional[int]:
    if isinstance(v, Fraction):
        return int(v) if v.denominator == 1 else None
    r = mpmath.nint(v)
    if abs(v - r) < _EPS:
        return int(r)
    return None


def _sqrt(v):
    s = _sign(v)
    if s < 0:
        return UNDEF
    if s == 0:
        return Fraction(0)
    if isinstance(v, Fraction):
        n, d = v.numerator, v.denominator
        rn, rd = math.isqrt(n), math.isqrt(d)
        if rn * rn == n and rd * rd == d:
            return Fraction(rn, rd)
    return mpmath.sqrt(_to_mpf(v))


def evaluate(t: Term, env: Dict[str, object]):
    """Value of ``t`` (Fraction / mpf / UNDEF).  ``env`` maps atom names (and
    schematic variable names prefixed with '?') to values (possibly UNDEF)."""
    if type(t) is Var:
        return env["?" + t.name]
    h, args = t.head, t.args
    if not args:
        if h.isdigit():
            return Fraction(int(h))
        return env[h]
    vals = [evaluate(a, env) for a in args]
    if any(v is UNDEF for v in vals):
        return UNDEF
    if h == "+" or h == "-" or h == "*":
        a, b = vals
        if not (isinstance(a, Fraction) and isinstance(b, Fraction)):
            a, b = _to_mpf(a), _to_mpf(b)
        r = a + b if h == "+" else (a - b if h == "-" else a * b)
        return _check_size(r)
    if h == "/":
        a, b = vals
        if _is_zero(b):
            return UNDEF
        if not (isinstance(a, Fraction) and isinstance(b, Fraction)):
            a, b = _to_mpf(a), _to_mpf(b)
        return _check_size(a / b)
    if h == "neg":
        return -vals[0]
    if h == "^":
        a, e = vals
        n = _as_int(e)
        if n is None:
            return UNDEF
        if abs(n) > MAX_EXP:
            raise EvalSkip("exponent too large")
        if n < 0 and _is_zero(a):
            return UNDEF
        if n == 0:
            return Fraction(1)
        if isinstance(a, Fraction):
            bits = max(a.numerator.bit_length(), a.denominator.bit_length())
            if bits * abs(n) > MAX_BITS:
                raise EvalSkip("power too large")
            return a ** n
        return _check_size(a ** n)
    if h == "sqrt":
        return _sqrt(vals[0])
    raise ValueError(f"unknown function symbol {h!r}")


def values_equal(a, b) -> bool:
    """Kleene equality of partial values (with tolerance for mpf values)."""
    if a is UNDEF or b is UNDEF:
        return a is b
    if isinstance(a, Fraction) and isinstance(b, Fraction):
        return a == b
    a, b = _to_mpf(a), _to_mpf(b)
    scale = max(mpmath.mpf(1), abs(a), abs(b))
    return abs(a - b) <= _REL_TOL * scale


def fact_holds(fact: Fact, env) -> bool:
    """Semantic truth of a fact at a point."""
    pred, t = fact
    v = evaluate(t, env)
    if v is UNDEF:
        return False
    if pred == "defined":
        return True
    s = _sign(v)
    if pred == "nonzero":
        return s != 0
    if pred == "nonneg":
        return s >= 0
    if pred == "pos":
        return s > 0
    raise ValueError(pred)


# ---------------------------------------------------------------------------
# Syntactic entailment for the guard language (sound, incomplete)
# ---------------------------------------------------------------------------

GUARD_PREDS: Tuple[str, ...] = ("defined", "nonzero", "nonneg")
_STRONGER = {  # p(t) in the facts implies q(t) for q in _STRONGER[p]
    "pos": {"pos", "nonzero", "nonneg", "defined"},
    "nonzero": {"nonzero", "defined"},
    "nonneg": {"nonneg", "defined"},
    "defined": {"defined"},
}


def pred_implies(p: str, q: str) -> bool:
    return q in _STRONGER.get(p, {p})


def _known(F: Facts, pred: str, t: Term) -> bool:
    for p in ("pos", "nonzero", "nonneg", "defined"):
        if pred in _STRONGER[p] and (p, t) in F:
            return True
    return False


def _int_exponent(e: Term) -> Optional[int]:
    return numeral_value(e)


@lru_cache(maxsize=1_000_000)
def entails(F: Facts, fact: Fact) -> bool:
    """Does the set of facts ``F`` syntactically entail ``fact``?

    Sound w.r.t. the partial semantics: if it returns True then the fact holds
    at every point satisfying ``F``.  Rules: membership (with pos => nonzero,
    nonneg => defined, nonzero => defined), numerals, and structural rules such
    as nonzero(a*b) <= nonzero(a) & nonzero(b), nonneg(a^2) <= defined(a),
    pos(a+b) <= pos(a) & nonneg(b), defined(a/b) <= defined(a) & nonzero(b),
    defined(sqrt a) <= nonneg(a)."""
    pred, t = fact
    if pred == "defined":
        return _defined(F, t)
    if pred == "nonzero":
        return _nonzero(F, t)
    if pred == "nonneg":
        return _nonneg(F, t)
    if pred == "pos":
        return _pos(F, t)
    return False


def _defined(F, t) -> bool:
    if type(t) is Var:
        return _known(F, "defined", t)
    h, args = t.head, t.args
    if not args:
        return True
    if _known(F, "defined", t):
        return True
    if h in ("+", "-", "*"):
        return _defined(F, args[0]) and _defined(F, args[1])
    if h == "neg":
        return _defined(F, args[0])
    if h == "/":
        return _defined(F, args[0]) and entails(F, ("nonzero", args[1]))
    if h == "^":
        n = _int_exponent(args[1])
        if n is None:
            return False
        return _defined(F, args[0]) if n >= 0 else entails(F, ("nonzero", args[0]))
    if h == "sqrt":
        return entails(F, ("nonneg", args[0]))
    return False


def _nonzero(F, t) -> bool:
    if _known(F, "nonzero", t):
        return True
    if type(t) is Var:
        return False
    h, args = t.head, t.args
    v = numeral_value(t)
    if v is not None:
        return v != 0
    if not args:
        return False
    if h == "neg":
        return entails(F, ("nonzero", args[0]))
    if h == "*" or h == "/":
        return entails(F, ("nonzero", args[0])) and entails(F, ("nonzero", args[1]))
    if h == "^":
        n = _int_exponent(args[1])
        if n is None:
            return False
        if n == 0:
            return _defined(F, args[0])
        return entails(F, ("nonzero", args[0]))
    if h == "sqrt":
        return entails(F, ("pos", args[0]))
    return entails(F, ("pos", t))


def _pos(F, t) -> bool:
    if _known(F, "pos", t):
        return True
    if type(t) is Var:
        return False
    h, args = t.head, t.args
    if is_numeral(t):
        return int(h) > 0
    if not args:
        return False
    if h == "+":
        a, b = args
        return ((entails(F, ("pos", a)) and entails(F, ("nonneg", b)))
                or (entails(F, ("nonneg", a)) and entails(F, ("pos", b))))
    if h == "*" or h == "/":
        return entails(F, ("pos", args[0])) and entails(F, ("pos", args[1]))
    if h == "^":
        n = _int_exponent(args[1])
        if n is None:
            return False
        if n == 0:
            return _defined(F, args[0])
        if n % 2 == 0:
            return entails(F, ("nonzero", args[0]))
        return entails(F, ("pos", args[0]))
    if h == "sqrt":
        return entails(F, ("pos", args[0]))
    return False


def _nonneg(F, t) -> bool:
    if _known(F, "nonneg", t):
        return True
    if type(t) is Var:
        return False
    h, args = t.head, t.args
    if is_numeral(t):
        return True
    if not args:
        return False
    if _pos(F, t):
        return True
    if h == "+":
        return entails(F, ("nonneg", args[0])) and entails(F, ("nonneg", args[1]))
    if h == "*":
        a, b = args
        if a == b:
            return _defined(F, a)
        return entails(F, ("nonneg", a)) and entails(F, ("nonneg", b))
    if h == "/":
        return entails(F, ("nonneg", args[0])) and entails(F, ("pos", args[1]))
    if h == "^":
        n = _int_exponent(args[1])
        if n is None:
            return False
        if n % 2 == 0:
            return _defined(F, args[0]) if n >= 0 else entails(F, ("nonzero", args[0]))
        return entails(F, ("nonneg", args[0])) if n >= 0 else entails(F, ("pos", args[0]))
    if h == "sqrt":
        return entails(F, ("nonneg", args[0]))
    return False


# ---------------------------------------------------------------------------
# Built-in arithmetic (numeral evaluation) -- trusted computation, not learned
# ---------------------------------------------------------------------------


def canonical_numeral(q: Fraction) -> Term:
    """Canonical literal for a rational: ``n``, ``neg(n)`` or ``p/q`` (q > 1)."""
    if q.denominator == 1:
        return num(int(q))
    return App("/", (num(q.numerator), num(q.denominator)))


def is_numeral_expr(t: Term) -> bool:
    """Ground and built only from integer literals and the operators."""
    return t.ground and not atoms(t)


def numeral_expr_value(t: Term):
    """Exact rational value of a numeral expression, UNDEF, or None when the
    value is irrational / not computable / ``t`` is not a numeral expression."""
    if not is_numeral_expr(t):
        return None
    try:
        v = evaluate(t, {})
    except (EvalSkip, KeyError, ValueError):
        return None
    if v is UNDEF:
        return UNDEF
    if isinstance(v, Fraction):
        return v
    return None


def is_canonical_numeral(t: Term) -> bool:
    v = numeral_expr_value(t)
    return isinstance(v, Fraction) and canonical_numeral(v) == t


def arith_step_ok(before: Term, after: Term) -> bool:
    """Is the step a correct numeral evaluation at some position on the
    difference chain?  (The rewritten subterm is a non-canonical numeral
    expression with a defined rational value; the result is its canonical
    literal.)"""
    for _, u, v in diff_chain(before, after):
        if u.ground and not atoms(u) and not is_canonical_numeral(u):
            q = numeral_expr_value(u)
            if isinstance(q, Fraction) and canonical_numeral(q) == v:
                return True
    return False


_ARITH_MAX = 10 ** 6


def arith_rewrites(term: Term) -> List[Tuple[Tuple[int, ...], Term]]:
    """Small-step arithmetic: evaluate an operator node all of whose arguments
    are canonical numerals (e.g. ``2*3 -> 6``, ``sqrt(4) -> 2``, ``2/4 -> 1/2``)."""
    out = []
    for p, u in subterms(term):
        if type(u) is not App or not u.args or not u.ground:
            continue
        if not all(is_canonical_numeral(a) for a in u.args):
            continue
        if is_canonical_numeral(u):
            continue
        q = numeral_expr_value(u)
        if isinstance(q, Fraction) and abs(q.numerator) < _ARITH_MAX and q.denominator < _ARITH_MAX:
            out.append((p, replace(term, p, canonical_numeral(q))))
    return out


# ---------------------------------------------------------------------------
# Target calculus and fallacies
# ---------------------------------------------------------------------------

_R = rule_from_strings
TARGET_RULES: List[RewriteRule] = [
    # additive structure
    _R("a + b", "b + a", name="add_comm"),
    _R("(a + b) + c", "a + (b + c)", name="add_assoc"),
    _R("a + (b + c)", "(a + b) + c", name="add_assoc_rev"),
    _R("a + 0", "a", name="add_zero"),
    _R("0 + a", "a", name="zero_add"),
    _R("a + a", "2*a", name="add_self"),
    # multiplicative structure
    _R("a*b", "b*a", name="mul_comm"),
    _R("(a*b)*c", "a*(b*c)", name="mul_assoc"),
    _R("a*(b*c)", "(a*b)*c", name="mul_assoc_rev"),
    _R("a*1", "a", name="mul_one"),
    _R("1*a", "a", name="one_mul"),
    _R("a*0", "0", [("defined", "a")], name="mul_zero"),
    _R("0*a", "0", [("defined", "a")], name="zero_mul"),
    # distributivity
    _R("a*(b + c)", "a*b + a*c", name="distrib_l"),
    _R("(a + b)*c", "a*c + b*c", name="distrib_r"),
    _R("a*b + a*c", "a*(b + c)", name="factor_l"),
    # negation and subtraction
    _R("a - b", "a + (-b)", name="sub_def"),
    _R("a + (-b)", "a - b", name="sub_undef"),
    _R("-(-a)", "a", name="neg_neg"),
    _R("-(a + b)", "-a + (-b)", name="neg_add"),
    _R("a - a", "0", [("defined", "a")], name="sub_self"),
    _R("(-a)*b", "-(a*b)", name="neg_mul"),
    # division
    _R("a/a", "1", [("nonzero", "a")], name="div_self"),
    _R("a/1", "a", name="div_one"),
    _R("0/a", "0", [("nonzero", "a")], name="zero_div"),
    _R("(a + b)/c", "a/c + b/c", name="div_add"),
    _R("a/c + b/c", "(a + b)/c", name="add_frac_same"),
    _R("(a/b)*(c/d)", "(a*c)/(b*d)", name="mul_frac"),
    _R("a*(b/c)", "(a*b)/c", name="mul_div"),
    _R("(a*b)/(a*c)", "b/c", [("nonzero", "a")], name="cancel_factor"),
    _R("a/(b/c)", "(a*c)/b", [("nonzero", "c")], name="div_div"),
    # powers
    _R("a^2", "a*a", name="pow_two"),
    _R("a*a", "a^2", name="sq_fold"),
    _R("a^1", "a", name="pow_one"),
    _R("a^0", "1", [("defined", "a")], name="pow_zero"),
    _R("(a*b)^n", "a^n*b^n", name="mul_pow"),
    _R("(a + b)^2", "a^2 + 2*a*b + b^2", name="binom_sq"),
    _R("(a + b)*(a - b)", "a^2 - b^2", name="diff_sq"),
    # roots
    _R("sqrt(a^2)", "a", [("nonneg", "a")], name="sqrt_sq"),
    _R("sqrt(a)^2", "a", [("nonneg", "a")], name="sq_sqrt"),
    _R("sqrt(a*b)", "sqrt(a)*sqrt(b)", [("nonneg", "a"), ("nonneg", "b")], name="sqrt_mul"),
]
TARGET_BY_NAME: Dict[str, RewriteRule] = {r.name: r for r in TARGET_RULES}
GUARDED_TARGETS = [r.name for r in TARGET_RULES if r.guard]


@dataclass(frozen=True)
class Fallacy:
    """A systematic human error.  ``kind == 'schema'``: an invalid rewrite
    schema; ``kind == 'guard_drop'``: a valid guarded target rule applied when
    its guard is *not* known to hold.  ``tag`` is the rule the human believes
    they are using."""

    name: str
    rule: RewriteRule
    tag: str
    kind: str


FALLACIES: List[Fallacy] = [
    Fallacy("freshman_dream", _R("(a + b)^2", "a^2 + b^2", name="F_freshman"), "binom_sq", "schema"),
    Fallacy("cancel_unguarded", _R("a/a", "1", name="F_cancel"), "div_self", "guard_drop"),
    Fallacy("sqrt_unguarded", _R("sqrt(a^2)", "a", name="F_sqrt"), "sqrt_sq", "guard_drop"),
    Fallacy("frac_split", _R("(a + b)/(c + d)", "a/c + b/d", name="F_fracsplit"), "div_add", "schema"),
    Fallacy("neg_distrib", _R("-(a + b)", "-a + b", name="F_negdist"), "neg_add", "schema"),
]
FALLACY_BY_NAME: Dict[str, Fallacy] = {f.name: f for f in FALLACIES}


# ---------------------------------------------------------------------------
# World oracle: random numerical evaluation
# ---------------------------------------------------------------------------

SPECIAL_VALUES = [Fraction(v) for v in (0, 1, -1, 2, -2, 3, -3)] + [Fraction(1, 2), Fraction(-1, 2)]


class WorldOracle:
    """Truth-value feedback by evaluation at random points.

    ``counterexample(s, t, facts)`` searches for a point satisfying ``facts``
    where ``[[s]]`` and ``[[t]]`` differ (Kleene equality).  A returned point is
    a certain refutation (one-sided error): if ``s = t`` is valid no point is
    ever returned.  Each call counts as one *query*.  Points mix special values
    (0, +-1, +-2, +-3, +-1/2; probability ``p_special``) with random rationals
    p/q, |p| <= 40, 1 <= q <= 15 (Schwartz-Zippel)."""

    def __init__(self, seed: int = 0, n_points: int = 12, p_special: float = 0.4, max_tries: int = 300):
        self.rng = random.Random(seed)
        self.n_points = n_points
        self.p_special = p_special
        self.max_tries = max_tries
        self.queries = 0

    def _value(self):
        if self.rng.random() < self.p_special:
            return self.rng.choice(SPECIAL_VALUES)
        return Fraction(self.rng.randint(-40, 40), self.rng.randint(1, 15))

    def sample_points(self, names: Iterable[str], facts: Facts = frozenset(), n: Optional[int] = None) -> List[dict]:
        names = sorted(set(names) | {a for _, t in facts for a in atoms(t)})
        n = self.n_points if n is None else n
        out = []
        tries = 0
        while len(out) < n and tries < self.max_tries:
            tries += 1
            env = {a: self._value() for a in names}
            try:
                if all(fact_holds(f, env) for f in facts):
                    out.append(env)
            except EvalSkip:
                continue
        return out

    def counterexample(self, s: Term, t: Term, facts: Facts = frozenset(), n: Optional[int] = None) -> Optional[dict]:
        self.queries += 1
        if s == t:
            return None
        for env in self.sample_points(atoms(s) | atoms(t), facts, n):
            try:
                if not values_equal(evaluate(s, env), evaluate(t, env)):
                    return env
            except EvalSkip:
                continue
        return None

    def equivalent(self, s: Term, t: Term, facts: Facts = frozenset(), n: Optional[int] = None) -> bool:
        """True iff no counterexample was found (probably valid)."""
        return self.counterexample(s, t, facts, n) is None

    def satisfiable(self, facts: Facts, n: int = 3) -> bool:
        return len(self.sample_points((), facts, n)) >= n


def schema_counterexample(rule: RewriteRule, rng: random.Random, n: int = 300,
                          p_undef: float = 0.12, p_irr: float = 0.08) -> Optional[dict]:
    """Semantic soundness test of a *schema* (used for evaluation only).

    A schema is sound iff ``[[l]] ~= [[r]]`` for every assignment of values in
    R u {undefined} to its variables satisfying its guard *semantically*
    (every ground instance is then valid in every context entailing the guard,
    because entailment is sound).  Values are drawn from special values,
    random rationals, a few irrationals (sqrt 2, sqrt 3) and UNDEF."""
    vs = rule.vars()
    obj = sorted(atoms(rule.lhs) | atoms(rule.rhs))   # object atoms: always defined reals
    for _ in range(n):
        env = {a: (rng.choice(SPECIAL_VALUES) if rng.random() < 0.4
                   else Fraction(rng.randint(-40, 40), rng.randint(1, 15))) for a in obj}
        for v in vs:
            r = rng.random()
            if r < p_undef:
                env["?" + v] = UNDEF
            elif r < p_undef + p_irr:
                env["?" + v] = rng.choice([1, -1]) * mpmath.sqrt(rng.choice([2, 3, 5]))
            elif r < 0.55:
                env["?" + v] = rng.choice(SPECIAL_VALUES)
            else:
                env["?" + v] = Fraction(rng.randint(-40, 40), rng.randint(1, 15))
        ok = True
        for p, v in rule.guard.atoms:
            val = env["?" + v]
            if val is UNDEF:
                ok = False
            elif p == "nonzero" and _sign(val) == 0:
                ok = False
            elif p == "nonneg" and _sign(val) < 0:
                ok = False
            if not ok:
                break
        if not ok:
            continue
        try:
            if not values_equal(evaluate(rule.lhs, env), evaluate(rule.rhs, env)):
                return env
        except EvalSkip:
            continue
    return None


def schema_sound(rule: RewriteRule, seed: int = 0, n: int = 300) -> bool:
    return schema_counterexample(rule, random.Random(seed), n) is None


# ---------------------------------------------------------------------------
# Random terms
# ---------------------------------------------------------------------------

ATOMS = ("x", "y", "z", "a", "b")


def random_term(rng: random.Random, size: int, atoms_: Sequence[str] = ATOMS,
                nums: Sequence[int] = (1, 2, 3), p_div: float = 0.12, p_sqrt: float = 0.05,
                p_pow: float = 0.1, p_neg: float = 0.08) -> Term:
    """Random ground term with approximately ``size`` nodes."""
    if size <= 1:
        if rng.random() < 0.65:
            return App(rng.choice(list(atoms_)))
        return num(rng.choice(list(nums)))
    r = rng.random()
    if r < p_neg and size >= 2:
        return App("neg", (random_term(rng, size - 1, atoms_, nums, p_div, p_sqrt, p_pow, p_neg),))
    r -= p_neg
    if r < p_sqrt and size >= 2:
        return App("sqrt", (random_term(rng, size - 1, atoms_, nums, p_div, p_sqrt, p_pow, p_neg),))
    r -= p_sqrt
    if r < p_pow and size >= 3:
        base = random_term(rng, size - 2, atoms_, nums, p_div, p_sqrt, p_pow, p_neg)
        return App("^", (base, num(rng.choice([2, 2, 3]))))
    r -= p_pow
    if r < p_div:
        op = "/"
    else:
        op = rng.choice(["+", "+", "*", "*", "-"])
    left = rng.randint(1, size - 2) if size >= 3 else 1
    right = max(1, size - 1 - left)
    return App(op, (random_term(rng, left, atoms_, nums, p_div, p_sqrt, p_pow, p_neg),
                    random_term(rng, right, atoms_, nums, p_div, p_sqrt, p_pow, p_neg)))


def random_context(rng: random.Random, depth_: int, size: int = 3) -> Term:
    """Random context ``C[.]`` (a term containing the hole ``Var('[]')``)."""
    from ..terms import HOLE
    c: Term = HOLE
    for _ in range(depth_):
        other = random_term(rng, size)
        op = rng.choice(["+", "*", "-", "+", "*"])
        c = App(op, (c, other)) if rng.random() < 0.5 else App(op, (other, c))
    return c


def instantiate(rule: RewriteRule, rng: random.Random, size_range=(1, 3), atoms_: Sequence[str] = ATOMS) -> Dict[str, Term]:
    """Random substitution for a rule's variables (exponent variable ``n`` of
    ``mul_pow`` is instantiated with a small literal, like humans do)."""
    sigma = {}
    for v in rule.vars():
        if v == "n":
            sigma[v] = num(rng.choice([2, 3]))
        else:
            sigma[v] = random_term(rng, rng.randint(*size_range), atoms_)
    return sigma


# ---------------------------------------------------------------------------
# Simulated human derivations
# ---------------------------------------------------------------------------


@dataclass
class HumanConfig:
    """Parameters of the simulated human corpus.

    noise_rate      probability that a step is a sporadic random (mostly invalid) mutation
    fallacy_rate    probability of committing a systematic fallacy when one is applicable
                    (float for all, or dict fallacy-name -> rate)
    fallacies       which fallacies the population is prone to
    """

    noise_rate: float = 0.0
    fallacy_rate: object = 0.0
    fallacies: Tuple[str, ...] = tuple(f.name for f in FALLACIES)
    min_len: int = 3
    max_len: int = 7
    size_cap: int = 45
    seed_size: Tuple[int, int] = (1, 3)
    p_initial_fact: float = 0.3
    p_focus_first: float = 0.85

    def rate(self, fallacy: str) -> float:
        if fallacy not in self.fallacies:
            return 0.0
        if isinstance(self.fallacy_rate, dict):
            return float(self.fallacy_rate.get(fallacy, 0.0))
        return float(self.fallacy_rate)


@dataclass
class Derivation:
    facts: Facts
    steps: List[Step]
    start: Term
    focus: str = ""

    def __str__(self):
        lines = [f"context: {{{', '.join(f'{p}({pretty(t)})' for p, t in sorted(self.facts, key=str))}}}",
                 f"  {pretty(self.start)}"]
        for s in self.steps:
            lines.append(f"  = {pretty(s.after)}    [{s.tag}]{'' if s.kind in ('valid', 'arith') else '  <' + s.kind + '>'}")
        return "\n".join(lines)


# seed patterns: the lhs of every target rule, plus extra patterns that give the
# 'schema' fallacies their opportunities (a sum in the denominator).
_EXTRA_SEEDS = {"div_add": [parse("(a + b)/(c + d)", "all")]}


def _mutate(rng: random.Random, t: Term) -> Optional[Term]:
    """A sporadic random error at a random position."""
    ps = positions(t)
    for _ in range(20):
        p = rng.choice(ps)
        u = subterm(t, p)
        kind = rng.choice(["drop", "swap", "opchange", "numchange", "replace"])
        new = None
        if kind == "drop" and type(u) is App and u.args:
            new = rng.choice(u.args)
        elif kind == "swap" and type(u) is App and len(u.args) == 2:
            new = App(u.head, (u.args[1], u.args[0]))
        elif kind == "opchange" and type(u) is App and len(u.args) == 2 and u.head in "+-*/":
            new = App(rng.choice([o for o in "+-*/" if o != u.head]), u.args)
        elif kind == "numchange" and is_numeral(u):
            new = num(max(0, int(u.head) + rng.choice([-1, 1])))
        elif kind == "replace":
            new = random_term(rng, rng.randint(1, 2))
        if new is not None and new != u:
            return replace(t, p, new)
    return None


class HumanSimulator:
    """Generates derivations whose valid steps are instances of TARGET_RULES (or
    arith), with systematic fallacies and sporadic noise as configured."""

    def __init__(self, config: HumanConfig, seed: int = 0, rules: Sequence[RewriteRule] = TARGET_RULES):
        self.cfg = config
        self.rng = random.Random(seed)
        self.rules = list(rules)
        self.index: Dict[str, List[int]] = {}
        for i, r in enumerate(self.rules):
            self.index.setdefault(r.lhs.head, []).append(i)
        self.fallacies = [f for f in FALLACIES if config.rate(f.name) > 0]
        self.sat_oracle = WorldOracle(seed=seed + 7919, n_points=3)
        self._focus_cycle: List[str] = []
        self.uses: Dict[str, int] = {}

    # -- helpers ------------------------------------------------------------
    def _next_focus(self) -> RewriteRule:
        """Focus rules cycle through a fresh random permutation of the rules,
        so every rule is the focus of about n / |rules| derivations."""
        if not self._focus_cycle:
            self._focus_cycle = [r.name for r in self.rules]
            self.rng.shuffle(self._focus_cycle)
        name = self._focus_cycle.pop()
        return next(r for r in self.rules if r.name == name)

    def _seed_term(self, rule: RewriteRule) -> Term:
        pats = [rule.lhs] + _EXTRA_SEEDS.get(rule.name, [])
        pat = self.rng.choice(pats)
        sigma = {}
        for v in variables(pat):
            if v == "n":
                sigma[v] = num(self.rng.choice([2, 3]))
            else:
                sigma[v] = random_term(self.rng, self.rng.randint(*self.cfg.seed_size))
        core = subst(pat, sigma)
        ctx = random_context(self.rng, self.rng.choice([0, 0, 1, 1, 2]), size=self.rng.randint(1, 3))
        from ..terms import plug
        return plug(ctx, core)

    def _needed_facts(self, rule: RewriteRule, sigma, facts: Facts) -> List[Fact]:
        return [(p, sigma[v]) for p, v in sorted(rule.guard.atoms) if not entails(facts, (p, sigma[v]))]

    def _weight(self, before: Term, after: Term, mode: str) -> float:
        d = after.size - before.size
        if mode == "simplify":
            return 3.0 if d < 0 else (1.0 if d == 0 else 0.4)
        return 3.0 if d > 0 else (1.0 if d == 0 else 0.4)

    # -- main -----------------------------------------------------------------
    def derivation(self) -> Derivation:
        cfg, rng = self.cfg, self.rng
        focus = self._next_focus()
        t = self._seed_term(focus)
        start = t
        facts = set()
        if rng.random() < cfg.p_initial_fact:
            a = rng.choice(sorted(atoms(t)) or ["x"])
            facts.add((rng.choice(["nonneg", "nonzero", "pos"]), App(a)))
        mode = rng.choice(["simplify", "simplify", "expand"])
        L = rng.randint(cfg.min_len, cfg.max_len)
        steps: List[Step] = []
        visited = {t}
        decided = set()
        for k in range(L):
            F = frozenset(facts)
            # sporadic noise
            if cfg.noise_rate and rng.random() < cfg.noise_rate:
                new = _mutate(rng, t)
                if new is not None and new.size <= cfg.size_cap:
                    steps.append(Step(t, new, tag=rng.choice(self.rules).name, kind="noise"))
                    t = new
                    visited.add(t)
                    continue
            # systematic fallacies: each opportunity (fallacy, redex) is decided
            # once per derivation, with probability rate(fallacy)
            committed = None
            for f in self.fallacies:
                for p, new, s in f.rule.rewrites(t, check_guard=False):
                    if f.kind == "guard_drop":
                        base = TARGET_BY_NAME[f.tag]
                        if guard_satisfied(base.guard, s, F, entails):
                            continue  # the use would be valid: not an error
                    site = (f.name, subterm(t, p))
                    if site in decided or new in visited or new.size > cfg.size_cap:
                        continue
                    decided.add(site)
                    if committed is None and rng.random() < cfg.rate(f.name):
                        committed = (f, new)
            if committed is not None:
                f, new = committed
                steps.append(Step(t, new, tag=f.tag, kind=f"fallacy:{f.name}"))
                t = new
                visited.add(t)
                continue
            # valid steps (target rules, possibly adding needed assumptions) + arith
            by_rule: Dict[str, List[Tuple[Term, List[Fact]]]] = {}
            for i, p, new, s in all_rewrites(t, self.rules, index=self.index, check_guard=False):
                if new in visited or new.size > cfg.size_cap:
                    continue
                r = self.rules[i]
                need = self._needed_facts(r, s, F)
                if need:
                    if not self.sat_oracle.satisfiable(frozenset(facts | set(need))):
                        continue
                by_rule.setdefault(r.name, []).append((new, need))
            for p, new in arith_rewrites(t):
                if new not in visited:
                    by_rule.setdefault("arith", []).append((new, []))
            if not by_rule:
                break
            if k == 0 and focus.name in by_rule and rng.random() < cfg.p_focus_first:
                name = focus.name
            else:
                # rule-level choice: size preference x inverse-sqrt usage, so that
                # ubiquitous rules (commutativity) do not crowd out the others
                names = sorted(by_rule)
                ws = [max(self._weight(t, new, mode) for new, _ in by_rule[nm])
                      / math.sqrt(1.0 + self.uses.get(nm, 0)) for nm in names]
                name = rng.choices(names, weights=ws)[0]
            cands = by_rule[name]
            ws = [self._weight(t, new, mode) for new, _ in cands]
            new, need = cands[rng.choices(range(len(cands)), weights=ws)[0]]
            facts |= set(need)
            self.uses[name] = self.uses.get(name, 0) + 1
            steps.append(Step(t, new, tag=name, kind="arith" if name == "arith" else "valid"))
            t = new
            visited.add(t)
        return Derivation(frozenset(facts), steps, start, focus.name)


def generate_corpus(n: int, config: Optional[HumanConfig] = None, seed: int = 0) -> List[Derivation]:
    """``n`` simulated human derivations (deterministic given ``seed``)."""
    sim = HumanSimulator(config or HumanConfig(), seed=seed)
    out = []
    while len(out) < n:
        d = sim.derivation()
        if d.steps:
            out.append(d)
    return out


# ---------------------------------------------------------------------------
# Domain bundle used by the learners
# ---------------------------------------------------------------------------


class AlgebraDomain:
    """Everything a learner needs to know about the domain (no ground truth)."""

    guard_preds = GUARD_PREDS
    entails = staticmethod(entails)
    pred_implies = staticmethod(pred_implies)
    arith_step_ok = staticmethod(arith_step_ok)
    arith_rewrites = staticmethod(arith_rewrites)
    numeral_value = staticmethod(numeral_expr_value)
    is_numeral_value = staticmethod(is_canonical_numeral)

    @staticmethod
    def make_oracle(seed: int = 0, n_points: int = 12) -> WorldOracle:
        return WorldOracle(seed=seed, n_points=n_points)


ALGEBRA = AlgebraDomain()
