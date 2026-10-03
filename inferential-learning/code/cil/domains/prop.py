"""Propositional natural deduction in sequent form (domain for Task B).

Formulas
--------
Formulas are :mod:`cil.terms` terms.  Atoms are 0-ary applications with a
lower-case name (``p, q, r, s``), falsum is ``App('bot')``, and the connectives
are ``not/1``, ``and/2``, ``or/2``, ``imp/2`` (plus ``tonk/2`` for Prior's
connective, used only in the Post-completeness experiment).  ``TOP`` is the
abbreviation ``~bot``.  Formula *metavariables* are :class:`cil.terms.Var`.

ASCII syntax (``parse_formula`` / ``fmt``; ``fmt(t, uni=True)`` gives Unicode)::

    imp := or ('->' imp)?          right associative, lowest precedence
    or  := and (('|' | 'tonk') and)*
    and := un ('&' un)*
    un  := '~' un | atom
    atom:= 'bot' | 'top' | lower-case name (atom) | Upper-case name or ?name
           (metavariable) | '(' imp ')'

Sequents and rules
------------------
A sequent :class:`Seq` is ``Gamma |- A`` with ``Gamma`` a finite *set* of
formulas.  A rule :class:`SeqRule` is a schema

    Gamma, E_1 |- A_1 ; ... ; Gamma, E_k |- A_k   /   Gamma, E_0 |- A_0   [guard]

with ONE context metavariable ``Gamma`` shared by all sequents (additive natural
deduction), formula metavariables in the ``A_i`` and in the explicit extra
assumptions ``E_i``, and optionally *set* metavariables in place of an ``E_i``
(printed ``$X``; they arise when anti-unification generalises different
numbers of extra assumptions).  Guards (:class:`MemGuard`) are conjunctions
of atoms ``mem t`` for formula patterns ``t`` over the rule's metavariables:
"the formula t is a member of Gamma" (an open assumption).  Rule strings::

    "G, A |- B / G |- A -> B"            ->I
    "/ G |- A [mem A]"                   assumption
    "G |- A -> B ; G |- A / G |- B"      ->E

A concrete step (premise sequents, conclusion sequent) is an instance of a
rule iff there are sigma and a set Gamma with ``ctx_i = Gamma u sigma(E_i)``,
``succ_i = sigma(A_i)`` and the guard holding for Gamma.  Gamma can be taken to
be the intersection of all contexts of the step (:func:`match_step`).

Semantics (ground truth -- used by the simulator and the evaluation, never by
the learners): classical truth tables (bit-parallel masks), local soundness of
steps and rules, and Kripke models with up to three worlds for intuitionistic
logic.  A rule is classically sound (validity preserving under all
substitutions and all Gamma) iff its *local formula*

    AND_mem (g -> X) & AND_i ((g & E_i) -> A_i)   ->   ((g & E_0) -> A_0)

is a tautology, metavariables and the context atom g read as atoms (proof:
substitute TOP/BOT along a falsifying row, as in Post's theorem).

Also here: the generic backward :class:`Prover` over arbitrary rule sets (used
for the human simulator in IPC, the coherence search, the adversary and the
completeness measurement), the target calculi (classical and intuitionistic
natural deduction), the systematic fallacies, the human-proof simulator and the
sparse world oracle.
"""
from __future__ import annotations

import itertools
import random
import re
from dataclasses import dataclass, field
from typing import Dict, FrozenSet, Iterable, Iterator, List, Optional, Sequence, Tuple, Union

from ..terms import (App, Term, Var, canonical_tuple, match, match_tuple, nonvar_size, pretty, subst,
                     variables)

__all__ = [
    "BOT", "TOP", "atom", "neg", "conj", "disj", "imp", "tonk", "parse_formula", "fmt", "subformulas",
    "formula_atoms", "Seq", "seq", "PStep", "SeqRule", "parse_rule", "EMPTY_CTX", "ctx_term",
    "match_step", "licenses", "local_sound_step", "rule_sound", "valid", "satisfiable",
    "truth_value", "Prover", "ProofNode", "proof_steps", "proof_rules", "format_proof",
    "CLASSICAL_RULES", "INTUITIONISTIC_RULES", "TARGET_BY_NAME", "FALLACY_RULES", "TONK_I", "TONK_E",
    "PropHumanConfig", "PDerivation", "generate_corpus", "random_formula", "random_tautologies",
    "PropWorld", "designated_contexts", "MemGuard", "TRUE_GUARD", "kripke_countermodel", "kripke_valid_formula", "TEMPLATES",
]

# ---------------------------------------------------------------------------
# Formula constructors
# ---------------------------------------------------------------------------

BOT = App("bot")
TOP = App("not", (BOT,))
_RESERVED = {"bot", "top", "tonk", "mem", "ctx", "seq", "step", "ok", "not", "and", "or", "imp"}
CONNECTIVES = {"not": 1, "and": 2, "or": 2, "imp": 2, "tonk": 2}


def atom(name: str) -> App:
    return App(name)


def neg(a: Term) -> App:
    return App("not", (a,))


def conj(a: Term, b: Term) -> App:
    return App("and", (a, b))


def disj(a: Term, b: Term) -> App:
    return App("or", (a, b))


def imp(a: Term, b: Term) -> App:
    return App("imp", (a, b))


def tonk(a: Term, b: Term) -> App:
    return App("tonk", (a, b))


_FKEY: Dict[Term, tuple] = {}


def fkey(t: Term):
    """Deterministic sort key for formulas (memoised)."""
    k = _FKEY.get(t)
    if k is None:
        if len(_FKEY) > 500000:
            _FKEY.clear()
        k = (t.size, pretty(t))
        _FKEY[t] = k
    return k


def subformulas(ts: Union[Term, Iterable[Term]]) -> set:
    out = set()
    stack = [ts] if isinstance(ts, (App, Var)) else list(ts)
    while stack:
        u = stack.pop()
        if u in out:
            continue
        out.add(u)
        if type(u) is App:
            stack.extend(u.args)
    return out


def formula_atoms(ts: Union[Term, Iterable[Term]]) -> set:
    """Names of the propositional atoms (not bot) occurring in the formula(s)."""
    return {u.head for u in subformulas(ts) if type(u) is App and not u.args and u.head != "bot"}


# ---------------------------------------------------------------------------
# Parsing and printing
# ---------------------------------------------------------------------------

_TOK = re.compile(r"\s*(?:(\|-|⊢|->|→)|(\$[A-Za-z_][\w']*)|(\?[A-Za-z_][\w']*)|([A-Za-z_][\w']*)|(\S))")


def _tokenize(s: str) -> List[str]:
    out, pos = [], 0
    s = s.rstrip()
    while pos < len(s):
        m = _TOK.match(s, pos)
        if not m:
            raise SyntaxError(f"cannot tokenize {s[pos:]!r}")
        pos = m.end()
        tok = next(g for g in m.groups() if g is not None)
        out.append({"→": "->", "⊢": "|-", "∧": "&", "∨": "|", "¬": "~", "⊥": "bot", "⊤": "top"}.get(tok, tok))
    return out


class _FParser:
    def __init__(self, toks: List[str], i: int = 0):
        self.t, self.i = toks, i

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else None

    def take(self, want=None):
        tok = self.peek()
        if tok is None or (want is not None and tok != want):
            raise SyntaxError(f"expected {want!r}, got {tok!r}")
        self.i += 1
        return tok

    def imp(self):
        a = self.disj()
        if self.peek() == "->":
            self.take()
            return imp(a, self.imp())
        return a

    def disj(self):
        a = self.conj()
        while self.peek() in ("|", "tonk"):
            op = "or" if self.take() == "|" else "tonk"
            a = App(op, (a, self.conj()))
        return a

    def conj(self):
        a = self.un()
        while self.peek() == "&":
            self.take()
            a = conj(a, self.un())
        return a

    def un(self):
        if self.peek() == "~":
            self.take()
            return neg(self.un())
        return self.atom()

    def atom(self):
        tok = self.take()
        if tok == "(":
            a = self.imp()
            self.take(")")
            return a
        if tok == "bot":
            return BOT
        if tok == "top":
            return TOP
        if tok.startswith("?"):
            return Var(tok[1:])
        if re.match(r"^[A-Za-z_]", tok):
            if tok[0].isupper():
                return Var(tok)
            if tok in _RESERVED:
                raise SyntaxError(f"reserved word {tok!r}")
            return App(tok)
        raise SyntaxError(f"unexpected token {tok!r}")


def parse_formula(s: str) -> Term:
    p = _FParser(_tokenize(s))
    t = p.imp()
    if p.i != len(p.t):
        raise SyntaxError(f"trailing input in {s!r}")
    return t


_PREC = {"imp": 1, "or": 2, "tonk": 2, "and": 3, "not": 4}
_ASCII = {"imp": " -> ", "or": " | ", "tonk": " tonk ", "and": " & "}
_UNI = {"imp": " → ", "or": " ∨ ", "tonk": " tonk ", "and": " ∧ "}


def _prec(t: Term) -> int:
    if type(t) is App and t.args:
        return _PREC.get(t.head, 5)
    return 5


def fmt(t: Term, uni: bool = False) -> str:
    """Inverse of :func:`parse_formula` (``uni=True``: Unicode symbols)."""
    if type(t) is Var:
        if t.name[:1].isupper() and t.name != "G" and re.match(r"^[A-Za-z_][\w']*$", t.name):
            return t.name
        return "?" + t.name
    if not t.args:
        if t.head == "bot":
            return "⊥" if uni else "bot"
        return t.head
    if t.head == "not" and len(t.args) == 1:
        a = t.args[0]
        s = fmt(a, uni)
        return ("¬" if uni else "~") + (f"({s})" if _prec(a) < 4 else s)
    if t.head in _ASCII and len(t.args) == 2:
        p = _PREC[t.head]
        a, b = t.args
        sa, sb = fmt(a, uni), fmt(b, uni)
        if t.head == "imp":
            la, lb = _prec(a) <= p, _prec(b) < p
        else:
            la, lb = _prec(a) < p, _prec(b) <= p
        sa = f"({sa})" if la else sa
        sb = f"({sb})" if lb else sb
        return sa + (_UNI if uni else _ASCII)[t.head] + sb
    return t.head + "(" + ", ".join(fmt(a, uni) for a in t.args) + ")"


# ---------------------------------------------------------------------------
# Sequents and steps
# ---------------------------------------------------------------------------


class Seq:
    """A sequent ``ctx |- succ`` (ctx a frozenset of formulas).  Immutable."""

    __slots__ = ("ctx", "succ", "_h", "_sorted")

    def __init__(self, ctx: Iterable[Term], succ: Term):
        self.ctx = ctx if isinstance(ctx, frozenset) else frozenset(ctx)
        self.succ = succ
        self._h = hash((self.ctx, succ))
        self._sorted = None

    def __eq__(self, o):
        return self is o or (type(o) is Seq and o._h == self._h and o.succ == self.succ and o.ctx == self.ctx)

    def __hash__(self):
        return self._h

    @property
    def sorted_ctx(self) -> Tuple[Term, ...]:
        if self._sorted is None:
            self._sorted = tuple(sorted(self.ctx, key=fkey))
        return self._sorted

    def formulas(self) -> List[Term]:
        return list(self.sorted_ctx) + [self.succ]

    def show(self, uni: bool = False) -> str:
        c = ", ".join(fmt(f, uni) for f in self.sorted_ctx)
        return (c + " " if c else "") + ("⊢ " if uni else "|- ") + fmt(self.succ, uni)

    __str__ = show

    def __repr__(self):
        return f"Seq({self.show()})"


def seq(s: str) -> Seq:
    """Parse ``"p, q -> r |- r"`` into a concrete sequent."""
    left, right = s.split("|-") if "|-" in s else s.split("⊢")
    ctx = [parse_formula(x) for x in _split_top(left)] if left.strip() else []
    return Seq(ctx, parse_formula(right))


def _split_top(s: str, sep: str = ",") -> List[str]:
    out, depth, cur = [], 0, ""
    for ch in s:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        if ch == sep and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return [x.strip() for x in out if x.strip()]


@dataclass
class PStep:
    """One inference step of a (human or machine) derivation.

    ``tag`` is the rule name cited by the human; ``kind`` is the hidden
    generation label ('valid', 'fallacy:<name>', 'noise') -- never read by
    learners."""

    prems: Tuple[Seq, ...]
    concl: Seq
    tag: str = ""
    kind: str = "valid"

    def show(self, uni: bool = False) -> str:
        ps = " ; ".join(p.show(uni) for p in self.prems)
        return f"{ps} / {self.concl.show(uni)}  [{self.tag}]"

    __str__ = show


EMPTY_CTX = App("ctx", ())


def ctx_term(fs: Iterable[Term]) -> App:
    return App("ctx", tuple(sorted(set(fs), key=fkey)))


# ---------------------------------------------------------------------------
# Guards: membership of formula patterns in the shared context
# ---------------------------------------------------------------------------


class MemGuard:
    """Conjunction of atoms ``mem t`` (``t`` a formula pattern): for an instance
    sigma and context Gamma the guard holds iff ``sigma(t)`` is in Gamma for
    every atom.  Immutable and hashable."""

    __slots__ = ("pats",)

    def __init__(self, pats: Iterable[Term] = ()):
        self.pats = frozenset(pats)

    def __iter__(self):
        return iter(sorted(self.pats, key=fkey))

    def __len__(self):
        return len(self.pats)

    def __bool__(self):
        return bool(self.pats)

    def __eq__(self, o):
        return isinstance(o, MemGuard) and o.pats == self.pats

    def __hash__(self):
        return hash(self.pats)

    def __and__(self, o: "MemGuard") -> "MemGuard":
        return MemGuard(self.pats | o.pats)

    def subst(self, sigma: dict) -> "MemGuard":
        return MemGuard(subst(p, sigma) for p in self.pats)

    def holds(self, sigma: dict, ctx: FrozenSet[Term]) -> bool:
        for p in self.pats:
            t = subst(p, sigma)
            if not t.ground or t not in ctx:
                return False
        return True

    def show(self, uni: bool = False) -> str:
        return ", ".join("mem " + fmt(p, uni) for p in self)

    __str__ = show

    def __repr__(self):
        return f"MemGuard({self.show()})"


TRUE_GUARD = MemGuard()


# ---------------------------------------------------------------------------
# Rule schemas over sequents
# ---------------------------------------------------------------------------

Ext = Term          # App('ctx', formulas) or a set metavariable Var
SeqPat = Tuple[Ext, Term]


class SeqRule:
    """Sequent rule schema (see module docstring)."""

    __slots__ = ("prems", "concl", "guard", "name", "_canon", "_info")

    def __init__(self, prems: Sequence[SeqPat], concl: SeqPat, guard: MemGuard = TRUE_GUARD, name: str = ""):
        self.prems = tuple((e, a) for e, a in prems)
        self.concl = (concl[0], concl[1])
        self.guard = guard
        self.name = name
        self._canon = None
        self._info = None

    # -- structure --------------------------------------------------------
    def term(self) -> App:
        return App("step", tuple(App("seq", (e, a)) for e, a in self.prems + (self.concl,)))

    @staticmethod
    def from_term(t: Term, guard: MemGuard = TRUE_GUARD, name: str = "") -> "SeqRule":
        if type(t) is not App or t.head != "step" or not t.args:
            raise ValueError(f"not a step term: {t}")
        seqs = []
        for s in t.args:
            if type(s) is not App or s.head != "seq":
                raise ValueError(f"not a seq term: {s}")
            seqs.append((s.args[0], s.args[1]))
        return SeqRule(seqs[:-1], seqs[-1], guard, name)

    @property
    def n_prems(self) -> int:
        return len(self.prems)

    def set_vars(self) -> List[str]:
        out = []
        for e, _ in self.prems + (self.concl,):
            if type(e) is Var and e.name not in out:
                out.append(e.name)
        return out

    def formula_vars(self) -> List[str]:
        sv = set(self.set_vars())
        fs = []
        for e, a in self.prems + (self.concl,):
            if type(e) is App:
                fs.extend(e.args)
            fs.append(a)
        return [v for v in variables(tuple(fs)) if v not in sv]

    def constants(self) -> set:
        fs = []
        for e, a in self.prems + (self.concl,):
            if type(e) is App:
                fs.extend(e.args)
            fs.append(a)
        return formula_atoms(fs)

    def canonical(self) -> "SeqRule":
        if self._canon is None:
            t = self.term()
            names = variables(t)
            m = {n: Var(f"v{i}") for i, n in enumerate(names)}
            (ct,) = canonical_tuple((t,))
            self._canon = SeqRule.from_term(ct, self.guard.subst(m), self.name)
        return self._canon

    def key(self):
        c = self.canonical()
        return (c.term(), c.guard)

    def shape_key(self):
        return self.canonical().term()

    def variant_of(self, other: "SeqRule", check_guard: bool = True) -> bool:
        return self.key() == other.key() if check_guard else self.shape_key() == other.shape_key()

    def subsumes(self, other: "SeqRule") -> bool:
        """``other`` (as an unguarded schema) is an instance of ``self``."""
        if self.n_prems != other.n_prems:
            return False
        mine = canonical_tuple((self.term(),), prefix="s")[0]
        return match(mine, other.canonical().term()) is not None

    def guard_candidates(self) -> List[Term]:
        """Patterns available to the guard language: the non-trivial formula
        patterns occurring in the rule (subterms of succedents and explicit
        extra assumptions that contain a metavariable), smallest first."""
        fs = []
        for e, a in self.prems + (self.concl,):
            fs.append(a)
            if type(e) is App:
                fs.extend(e.args)
        out = {u for u in subformulas(fs) if not u.ground and not (type(u) is App and u.head == "ctx")}
        return sorted(out, key=fkey)

    def with_guard(self, g: MemGuard, name: Optional[str] = None) -> "SeqRule":
        return SeqRule(self.prems, self.concl, g, self.name if name is None else name)

    def size(self) -> int:
        return self.term().size

    def info(self):
        """Cached analysis used by the prover."""
        if self._info is None:
            prem_fpats = []
            for e, a in self.prems:
                prem_fpats.append(a)
                if type(e) is App:
                    prem_fpats.extend(e.args)
            concl_vars = set(variables(self.concl[1]))
            if type(self.concl[0]) is App:
                concl_vars |= set(variables(self.concl[0].args))
            else:
                concl_vars.add(self.concl[0].name)
            self._info = {"prem_fpats": prem_fpats, "concl_vars": concl_vars,
                          "set_vars": set(self.set_vars())}
        return self._info

    # -- printing -----------------------------------------------------------
    def _show_seq(self, e: Ext, a: Term, uni: bool) -> str:
        items = ["Γ" if uni else "G"]
        if type(e) is Var:
            items.append(("Δ" if uni else "$") + e.name)
        else:
            items.extend(fmt(f, uni) for f in e.args)
        return ", ".join(items) + (" ⊢ " if uni else " |- ") + fmt(a, uni)

    def show(self, uni: bool = False) -> str:
        ps = " ; ".join(self._show_seq(e, a, uni) for e, a in self.prems)
        s = (ps + " " if ps else "") + "/ " + self._show_seq(self.concl[0], self.concl[1], uni)
        if self.guard:
            s += " [" + self.guard.show(uni) + "]"
        if self.name:
            s = f"{self.name}: {s}"
        return s

    def __str__(self):
        return self.show()

    def __repr__(self):
        return f"SeqRule({self.show()})"


_RNAME = re.compile(r"^\s*([A-Za-z_][\w']*)\s*:\s*")


def _parse_seqpat(s: str) -> SeqPat:
    if "|-" not in s:
        raise SyntaxError(f"no |- in {s!r}")
    left, right = s.split("|-", 1)
    items = _split_top(left)
    if items and items[0] == "G":
        items = items[1:]
    setv = [x for x in items if x.startswith("$")]
    fs = [x for x in items if not x.startswith("$")]
    if setv:
        if fs or len(setv) > 1:
            raise SyntaxError("a sequent pattern has either one set variable or explicit formulas")
        e: Ext = Var(setv[0][1:])
    else:
        e = ctx_term([parse_formula(x) for x in fs])
    return (e, parse_formula(right))


def parse_rule(s: str, name: str = "") -> SeqRule:
    """Parse ``[name:] prem ; prem / concl [mem A, mem B]`` (inverse of ``str``)."""
    m = _RNAME.match(s)
    if m and "|-" not in m.group(1):
        name = name or m.group(1)
        s = s[m.end():]
    guard = TRUE_GUARD
    gm = re.search(r"\[([^\]]*)\]\s*$", s)
    if gm and "mem" in gm.group(1):
        pats = []
        for part in _split_top(gm.group(1)):
            if not part.startswith("mem "):
                raise SyntaxError(f"bad guard atom {part!r}")
            pats.append(parse_formula(part[4:]))
        guard = MemGuard(pats)
        s = s[:gm.start()]
    if "/" not in s:
        raise SyntaxError(f"no '/' in rule {s!r}")
    left, right = s.rsplit("/", 1)
    prems = [_parse_seqpat(p) for p in left.split(";") if p.strip()]
    return SeqRule(prems, _parse_seqpat(right), guard, name)


# ---------------------------------------------------------------------------
# Matching a concrete step against a rule (verification)
# ---------------------------------------------------------------------------


def _match_members(pats: Sequence[Term], members: Sequence[Term], sigma: dict) -> Iterator[dict]:
    """Extensions of sigma under which every pattern matches some member."""
    if not pats:
        yield sigma
        return
    p, rest = pats[0], pats[1:]
    if p.ground:
        if p in members:
            yield from _match_members(rest, members, sigma)
        return
    for m in members:
        s = match(p, m, sigma)
        if s is not None:
            yield from _match_members(rest, members, s)


def _guard_ok(guard: MemGuard, sigma: dict, base: FrozenSet[Term]) -> bool:
    return guard.holds(sigma, base)


def _match_ext(i, pats, seqs, base, sigma, guard):
    if i == len(pats):
        return sigma if _guard_ok(guard, sigma, base) else None
    ext = pats[i][0]
    s = seqs[i]
    D = s.ctx - base
    if type(ext) is Var:
        b = sigma.get(ext.name)
        if b is None:
            s2 = dict(sigma)
            s2[ext.name] = ctx_term(D)
            return _match_ext(i + 1, pats, seqs, base, s2, guard)
        if type(b) is not App or b.head != "ctx":
            return None
        bset = set(b.args)
        if D <= bset and bset <= s.ctx:
            return _match_ext(i + 1, pats, seqs, base, sigma, guard)
        return None
    for s2 in _match_members(ext.args, s.sorted_ctx, sigma):
        img = {subst(f, s2) for f in ext.args}
        if D <= img:
            r = _match_ext(i + 1, pats, seqs, base, s2, guard)
            if r is not None:
                return r
    return None


def match_step(rule: SeqRule, prems: Sequence[Seq], concl: Seq, check_guard: bool = True) -> Optional[dict]:
    """sigma witnessing that (prems / concl) is an instance of ``rule`` with the
    premises in the given order, or None.  Gamma = intersection of all contexts
    (the maximal choice, which is without loss of generality)."""
    if len(prems) != rule.n_prems:
        return None
    seqs = list(prems) + [concl]
    pats = list(rule.prems) + [rule.concl]
    sigma = match_tuple([a for _, a in pats], [s.succ for s in seqs])
    if sigma is None:
        return None
    base = seqs[0].ctx
    for s in seqs[1:]:
        base = base & s.ctx
    return _match_ext(0, pats, seqs, base, sigma, rule.guard if check_guard else TRUE_GUARD)


def licenses(rule: SeqRule, prems: Sequence[Seq], concl: Seq, check_guard: bool = True) -> Optional[dict]:
    """Like :func:`match_step` but premises are an unordered collection."""
    if len(prems) != rule.n_prems:
        return None
    if len(prems) <= 1:
        return match_step(rule, prems, concl, check_guard)
    seen = set()
    for perm in itertools.permutations(prems):
        if perm in seen:
            continue
        seen.add(perm)
        s = match_step(rule, perm, concl, check_guard)
        if s is not None:
            return s
    return None


# ---------------------------------------------------------------------------
# Classical semantics (bit-parallel truth tables)
# ---------------------------------------------------------------------------


def _var_key(t: Term) -> str:
    return "?" + t.name if type(t) is Var else t.head


class _TT:
    """Truth-table evaluation over a fixed list of atom keys."""

    def __init__(self, keys: Sequence[str]):
        self.keys = list(keys)
        n = len(self.keys)
        self.rows = 1 << n
        self.full = (1 << self.rows) - 1
        self.env = {}
        for i, k in enumerate(self.keys):
            m = 0
            for r in range(self.rows):
                if (r >> i) & 1:
                    m |= 1 << r
            self.env[k] = m
        self.memo: Dict[Term, int] = {}

    def mask(self, t: Term) -> int:
        m = self.memo.get(t)
        if m is not None:
            return m
        if type(t) is Var:
            m = self.env[_var_key(t)]
        elif t.head == "ctx":
            m = self.full
            for a in t.args:
                m &= self.mask(a)
        elif not t.args:
            m = 0 if t.head == "bot" else self.env[t.head]
        elif t.head == "not":
            m = self.full & ~self.mask(t.args[0])
        elif t.head == "and":
            m = self.mask(t.args[0]) & self.mask(t.args[1])
        elif t.head == "or":
            m = self.mask(t.args[0]) | self.mask(t.args[1])
        elif t.head == "imp":
            m = (self.full & ~self.mask(t.args[0])) | self.mask(t.args[1])
        else:
            raise ValueError(f"no truth table for {t.head!r}")
        self.memo[t] = m
        return m


def _keys_of(fs: Iterable[Term]) -> List[str]:
    ks = set()
    for u in subformulas(list(fs)):
        if type(u) is Var:
            ks.add("?" + u.name)
        elif not u.args and u.head != "bot":
            ks.add(u.head)
    return sorted(ks)


def valid(ctx: Iterable[Term], succ: Term) -> bool:
    """Classical entailment ctx |= succ."""
    ctx = list(ctx)
    tt = _TT(_keys_of(ctx + [succ]))
    c = tt.full
    for f in ctx:
        c &= tt.mask(f)
    return c & ~tt.mask(succ) & tt.full == 0


def satisfiable(fs: Iterable[Term]) -> bool:
    fs = list(fs)
    tt = _TT(_keys_of(fs))
    c = tt.full
    for f in fs:
        c &= tt.mask(f)
    return c != 0


def truth_value(f: Term, v: Dict[str, bool]) -> bool:
    """Value of a ground formula at valuation v (atoms missing from v are false)."""
    if not f.args:
        return False if f.head == "bot" else bool(v.get(f.head, False))
    if f.head == "not":
        return not truth_value(f.args[0], v)
    a = truth_value(f.args[0], v)
    if f.head == "and":
        return a and truth_value(f.args[1], v)
    if f.head == "or":
        return a or truth_value(f.args[1], v)
    if f.head == "imp":
        return (not a) or truth_value(f.args[1], v)
    raise ValueError(f.head)


def local_sound_step(prems: Sequence[Seq], concl: Seq) -> bool:
    """Truth preservation of a concrete step at every valuation: if every premise
    sequent holds at v (v |= ctx_i implies v |= succ_i) then so does the conclusion."""
    fs = []
    for s in list(prems) + [concl]:
        fs.extend(s.ctx)
        fs.append(s.succ)
    tt = _TT(_keys_of(fs))

    def holds(s: Seq) -> int:
        c = tt.full
        for f in s.ctx:
            c &= tt.mask(f)
        return (tt.full & ~c) | tt.mask(s.succ)

    p = tt.full
    for s in prems:
        p &= holds(s)
    return p & ~holds(concl) & tt.full == 0


def rule_sound(rule: SeqRule) -> bool:
    """Classical soundness of a rule schema (exact; see module docstring)."""
    fs = list(rule.guard.pats)
    for e, a in rule.prems + (rule.concl,):
        fs.append(a)
        if type(e) is App:
            fs.extend(e.args)
    keys = _keys_of(fs) + ["@g"] + ["?" + v for v in rule.set_vars()]
    if any(_has_tonk(f) for f in fs):
        raise ValueError("tonk has no truth table; use tonk_interpretable")
    tt = _TT(sorted(set(keys)))
    g = tt.env["@g"]

    def emask(e):
        return tt.env["?" + e.name] if type(e) is Var else tt.mask(e)

    def holds(e, a):
        return (tt.full & ~(g & emask(e))) | tt.mask(a)

    p = tt.full
    for gp in rule.guard.pats:
        p &= (tt.full & ~g) | tt.mask(gp)
    for e, a in rule.prems:
        p &= holds(e, a)
    return p & ~holds(*rule.concl) & tt.full == 0


def _has_tonk(t: Term) -> bool:
    return any(type(u) is App and u.head == "tonk" for u in subformulas(t))


def tonk_interpretable(rules: Sequence[SeqRule]) -> Optional[int]:
    """Is there a binary truth function for ``tonk`` making every rule locally
    sound?  Returns the truth function as a 4-bit table index or None."""
    for code in range(16):
        def tr(t):
            if type(t) is App and t.head == "tonk":
                a, b = tr(t.args[0]), tr(t.args[1])
                # encode f(a,b) by the DNF over the 4 rows selected by `code`
                rows = []
                for ia, ib in itertools.product((0, 1), repeat=2):
                    if (code >> (2 * ia + ib)) & 1:
                        rows.append(conj(a if ia else neg(a), b if ib else neg(b)))
                out = BOT
                for r in rows:
                    out = r if out == BOT else disj(out, r)
                return out
            if type(t) is App and t.args:
                return App(t.head, tuple(tr(x) for x in t.args))
            return t

        ok = True
        for r in rules:
            tr_ext = lambda e: e if type(e) is Var else App("ctx", tuple(tr(f) for f in e.args))
            rr = SeqRule([(tr_ext(e), tr(a)) for e, a in r.prems], (tr_ext(r.concl[0]), tr(r.concl[1])), r.guard)
            if not rule_sound(rr):
                ok = False
                break
        if ok:
            return code
    return None


__all__.append("tonk_interpretable")


# ---------------------------------------------------------------------------
# Kripke semantics (intuitionistic), frames with at most three worlds
# ---------------------------------------------------------------------------

def _frame(name, n, pairs):
    leq = [[w == v for v in range(n)] for w in range(n)]
    for a, b in pairs:
        leq[a][b] = True
    up = [sum(1 << v for v in range(n) if leq[w][v]) for w in range(n)]
    upsets = [m for m in range(1 << n) if all(not ((m >> w) & 1) or (m & up[w]) == up[w] for w in range(n))]
    return {"name": name, "n": n, "up": up, "upsets": upsets, "all": (1 << n) - 1}


KRIPKE_FRAMES = [
    _frame("1-world", 1, []),
    _frame("2-chain", 2, [(0, 1)]),
    _frame("3-chain", 3, [(0, 1), (1, 2), (0, 2)]),
    _frame("V", 3, [(0, 1), (0, 2)]),
]


def _force(t: Term, env: dict, fr: dict, memo: dict) -> int:
    m = memo.get(t)
    if m is not None:
        return m
    if type(t) is Var:
        m = env["?" + t.name]
    elif t.head == "ctx":
        m = fr["all"]
        for a in t.args:
            m &= _force(a, env, fr, memo)
    elif not t.args:
        m = 0 if t.head == "bot" else env[t.head]
    elif t.head == "and":
        m = _force(t.args[0], env, fr, memo) & _force(t.args[1], env, fr, memo)
    elif t.head == "or":
        m = _force(t.args[0], env, fr, memo) | _force(t.args[1], env, fr, memo)
    elif t.head in ("imp", "not"):
        a = _force(t.args[0], env, fr, memo)
        b = 0 if t.head == "not" else _force(t.args[1], env, fr, memo)
        m = 0
        for w in range(fr["n"]):
            if (fr["up"][w] & a & ~b) == 0:
                m |= 1 << w
    else:
        raise ValueError(t.head)
    memo[t] = m
    return m


def kripke_countermodel(rule: SeqRule, frames=KRIPKE_FRAMES) -> Optional[dict]:
    """A Kripke model (frame + up-set assignment) in which every premise sequent
    is globally valid but the conclusion is not, or None.  Every rule of
    intuitionistic natural deduction preserves global validity in every model,
    so a countermodel certifies that the rule is not IPC-derivable."""
    fs = list(rule.guard.pats)
    for e, a in rule.prems + (rule.concl,):
        fs.append(a)
        if type(e) is App:
            fs.extend(e.args)
    keys = sorted(set(_keys_of(fs) + ["@g"] + ["?" + v for v in rule.set_vars()]))
    for fr in frames:
        for combo in itertools.product(fr["upsets"], repeat=len(keys)):
            env = dict(zip(keys, combo))
            g = env["@g"]
            memo: dict = {}

            def holds(e, a):
                em = env["?" + e.name] if type(e) is Var else _force(e, env, fr, memo)
                return (g & em & ~_force(a, env, fr, memo)) == 0

            if any((g & ~_force(gp, env, fr, memo)) for gp in rule.guard.pats):
                continue
            if all(holds(e, a) for e, a in rule.prems) and not holds(*rule.concl):
                return {"frame": fr["name"], "assignment": {k: bin(v) for k, v in env.items()}}
    return None


def kripke_valid_formula(f: Term) -> bool:
    """Is f valid in all Kripke models over the small frames?  (A necessary
    condition for IPC-provability; False certifies IPC-unprovability.)"""
    return kripke_countermodel(SeqRule([], (EMPTY_CTX, f))) is None


# ---------------------------------------------------------------------------
# Target calculi and fallacies
# ---------------------------------------------------------------------------

_ND = [
    ("ax", "/ G |- A [mem A]"),
    ("andI", "G |- A ; G |- B / G |- A & B"),
    ("andE1", "G |- A & B / G |- A"),
    ("andE2", "G |- A & B / G |- B"),
    ("orI1", "G |- A / G |- A | B"),
    ("orI2", "G |- B / G |- A | B"),
    ("orE", "G |- A | B ; G, A |- C ; G, B |- C / G |- C"),
    ("impI", "G, A |- B / G |- A -> B"),
    ("impE", "G |- A -> B ; G |- A / G |- B"),
    ("notI", "G, A |- bot / G |- ~A"),
    ("notE", "G |- ~A ; G |- A / G |- bot"),
    ("efq", "G |- bot / G |- A"),
]
INTUITIONISTIC_RULES: List[SeqRule] = [parse_rule(s, n) for n, s in _ND]
CLASSICAL_RULES: List[SeqRule] = INTUITIONISTIC_RULES + [parse_rule("G, ~A |- bot / G |- A", "raa")]
TARGET_BY_NAME: Dict[str, SeqRule] = {r.name: r for r in CLASSICAL_RULES}
TAGS = [r.name for r in CLASSICAL_RULES]

# systematic fallacies (the tag is the rule the human believes they are using)
FALLACY_RULES: Dict[str, Tuple[SeqRule, str]] = {
    "AC": (parse_rule("G |- A -> B ; G |- B / G |- A", "AC"), "impE"),           # affirming the consequent
    "DA": (parse_rule("G |- A -> B ; G |- ~A / G |- ~B", "DA"), "impE"),         # denying the antecedent
    "ID": (parse_rule("G |- A -> B ; G, A |- A / G |- B", "ID"), "impE"),        # illegitimate discharge
}
TONK_I = parse_rule("G |- A / G |- A tonk B", "tonkI")
TONK_E = parse_rule("G |- A tonk B / G |- B", "tonkE")


# ---------------------------------------------------------------------------
# Generic backward prover
# ---------------------------------------------------------------------------


class ProofNode:
    """A derivation tree node: conclusion ``seq`` obtained by rule ``rid``
    (a learned schema id or a rule name) from ``children``."""

    __slots__ = ("seq", "rid", "children", "sigma", "kind")

    def __init__(self, seq: Seq, rid, children=(), sigma=None, kind: str = "valid"):
        self.seq = seq
        self.rid = rid
        self.children = tuple(children)
        self.sigma = sigma
        self.kind = kind

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)

    def depth(self) -> int:
        return 1 + max((c.depth() for c in self.children), default=0)


def proof_steps(node: ProofNode) -> List[PStep]:
    """Post-order list of the steps of a derivation (shared subproofs repeated)."""
    out: List[PStep] = []

    def go(n):
        for c in n.children:
            go(c)
        out.append(PStep(tuple(c.seq for c in n.children), n.seq, str(n.rid), n.kind))

    go(node)
    return out


def proof_rules(node: ProofNode) -> set:
    out = set()
    stack = [node]
    while stack:
        n = stack.pop()
        out.add(n.rid)
        stack.extend(n.children)
    return out


def format_proof(node: ProofNode, uni: bool = True, names: Optional[dict] = None) -> str:
    """Numbered-line (Fitch-like, but with explicit contexts) rendering."""
    lines: List[str] = []
    num: Dict[int, int] = {}

    def go(n):
        key = id(n)
        if key in num:
            return num[key]
        refs = [go(c) for c in n.children]
        lines.append((n, refs))
        num[key] = len(lines)
        return len(lines)

    go(node)
    out = []
    for i, (n, refs) in enumerate(lines, 1):
        nm = names.get(n.rid, str(n.rid)) if names else str(n.rid)
        r = f"{nm}" + (" " + ",".join(map(str, refs)) if refs else "")
        out.append(f"{i:>3}. {n.seq.show(uni):<44} {r}")
    return "\n".join(out)


class _Budget(Exception):
    pass


def make_pool(formulas: Iterable[Term], basis: Sequence[Term] = (BOT, TOP), negations: bool = True) -> List[Term]:
    sub = subformulas(list(formulas)) | set(basis)
    pool = set(sub)
    if negations:
        pool |= {neg(f) for f in sub if not (type(f) is App and f.head == "not")}
    return sorted((f for f in pool if f.ground), key=fkey)


class _RuleInfo:
    """Precomputed structure of a rule for backward application."""

    __slots__ = ("rule", "csucc", "cext", "cext_args", "prems", "fpats", "set_vars", "guard_pats", "ax_like")

    def __init__(self, rule: SeqRule):
        self.rule = rule
        self.csucc = rule.concl[1]
        self.cext = rule.concl[0]
        self.cext_args = tuple(self.cext.args) if type(self.cext) is App else None
        self.prems = []
        fp = []
        for e, a in rule.prems:
            if type(e) is Var:
                self.prems.append((e.name, None, a))
            else:
                self.prems.append((None, tuple(e.args), a))
                fp.extend(e.args)
            fp.append(a)
        self.fpats = [(p, frozenset(variables(p)), nonvar_size(p)) for p in fp]
        self.set_vars = rule.set_vars()
        self.guard_pats = list(rule.guard)
        # the standard assumption rule:  / G |- A [mem A]
        self.ax_like = (rule.n_prems == 0 and type(self.csucc) is Var and self.cext_args == ()
                        and self.guard_pats == [self.csucc])


class Prover:
    """Depth-bounded, budgeted backward search over an arbitrary rule set.

    ``rules`` is a list of ``(rid, SeqRule)``.  Rule instances are found by
    matching the conclusion against the goal; premise metavariables not bound
    by the conclusion are instantiated from a finite *pool* of formulas (the
    subformulas of the top goal, their negations and the closed basis
    ``{bot, ~bot}``), by matching the most structured premise pattern against
    the pool (a subformula-property heuristic).  Unbound set variables in
    premises are tried as {}, {the premise's own succedent} and {bot}.  Search is
    iterative deepening with success and failure caches; ``budget`` counts goal
    expansions.  Every returned derivation is, by construction, a tree of rule
    instances (checked by the tests with :func:`match_step`)."""

    def __init__(self, rules: Sequence[Tuple[object, SeqRule]], budget: int = 3000, max_depth: int = 10,
                 basis: Sequence[Term] = (BOT, TOP), max_inst: int = 24):
        self.rules = list(rules)
        self.budget = budget
        self.max_depth = max_depth
        self.basis = tuple(basis)
        self.max_inst = max_inst
        self.success: Dict[Seq, ProofNode] = {}
        self.failed: Dict[Seq, int] = {}
        self._cands: Dict[Seq, list] = {}
        self._closable_memo: Dict[Seq, bool] = {}
        self.nodes = 0
        self.total_nodes = 0
        self._pool_key = None
        self.info = {id(r): _RuleInfo(r) for _, r in self.rules}
        self.zero = [(rid, r) for rid, r in self.rules if r.n_prems == 0]
        self._by_head: Dict[object, List[Tuple[object, SeqRule]]] = {}
        for rid, r in self.rules:
            if r.n_prems == 0:
                continue
            h = r.concl[1].head if type(r.concl[1]) is App else None
            self._by_head.setdefault(h, []).append((rid, r))
        self.pool: List[Term] = []
        self.pool_set: set = set()
        self.pool_by_head: Dict[str, List[Term]] = {}

    # -- pool -----------------------------------------------------------------
    def set_pool(self, formulas: Iterable[Term]):
        pool = make_pool(formulas, self.basis)
        key = tuple(pool)
        if key != self._pool_key:
            self._pool_key = key
            self.failed = {}
            self._cands = {}
        self.pool = pool
        self.pool_set = set(pool)
        self.pool_by_head = {}
        for f in pool:
            self.pool_by_head.setdefault(f.head, []).append(f)

    def add_lemma(self, node: ProofNode):
        self.success[node.seq] = node

    # -- rule instances -------------------------------------------------------
    def _bind_free(self, ri: _RuleInfo, sigma: dict, ctx: FrozenSet[Term], cap: int) -> Iterator[dict]:
        best = None
        for p, vs, nv in ri.fpats:
            if any(v not in sigma for v in vs):
                if best is None or nv > best[2]:
                    best = (p, vs, nv)
        if best is None:
            yield sigma
            return
        pat = best[0]
        if type(pat) is Var:
            cands = self.pool + sorted(ctx - self.pool_set, key=fkey)
        else:
            cands = self.pool_by_head.get(pat.head, [])
            extra = [f for f in ctx if f.head == pat.head and f not in self.pool_set]
            if extra:
                cands = cands + sorted(extra, key=fkey)
        n = 0
        for f in cands:
            s = match(pat, f, sigma)
            if s is None:
                continue
            for s2 in self._bind_free(ri, s, ctx, cap):
                yield s2
                n += 1
                if n >= cap:
                    return

    def instances(self, rule: SeqRule, goal: Seq) -> List[Tuple[dict, Tuple[Seq, ...]]]:
        """Backward instances of ``rule`` whose conclusion is ``goal``."""
        ri = self.info.get(id(rule)) or _RuleInfo(rule)
        if ri.ax_like:
            return [({ri.csucc.name: goal.succ}, ())] if goal.succ in goal.ctx else []
        s0 = match(ri.csucc, goal.succ)
        if s0 is None:
            return []
        opts = []
        if ri.cext_args is None:
            s0[ri.cext.name] = EMPTY_CTX
            opts.append((s0, goal.ctx))
        elif not ri.cext_args:
            opts.append((s0, goal.ctx))
        else:
            for s in _match_members(ri.cext_args, goal.sorted_ctx, s0):
                opts.append((s, goal.ctx))
                opts.append((s, goal.ctx - {subst(f, s) for f in ri.cext_args}))
        out = []
        for s, G in opts:
            gs = [s]
            for gp in ri.guard_pats:
                nxt = []
                for s1 in gs:
                    t = subst(gp, s1)
                    if t.ground:
                        if t in G:
                            nxt.append(s1)
                    else:
                        for f in sorted(G, key=fkey):
                            s2 = match(t, f, s1)
                            if s2 is not None:
                                nxt.append(s2)
                gs = nxt
            for s1 in gs:
                for s2 in self._bind_free(ri, s1, G, self.max_inst):
                    setopts = [s2]
                    for v in ri.set_vars:
                        if v in s2:
                            continue
                        new = []
                        for s3 in setopts:
                            succs = [subst(a, s3) for ev, _, a in ri.prems if ev == v]
                            for c in [EMPTY_CTX] + [ctx_term([x]) for x in succs[:1]] + [ctx_term([BOT])]:
                                s4 = dict(s3)
                                s4[v] = c
                                new.append(s4)
                        setopts = new
                    for s3 in setopts:
                        prems = []
                        ok = True
                        for ev, eargs, a in ri.prems:
                            A = subst(a, s3)
                            if not A.ground:
                                ok = False
                                break
                            if ev is not None:
                                E = s3[ev].args
                            else:
                                E = tuple(subst(f, s3) for f in eargs)
                                if not all(x.ground for x in E):
                                    ok = False
                                    break
                            prems.append(Seq(G.union(E) if E else G, A))
                        if ok:
                            out.append((s3, tuple(prems)))
                            if len(out) >= self.max_inst:
                                return out
        return out

    # -- search -----------------------------------------------------------------
    def _closable(self, s: Seq) -> bool:
        if s in self.success:
            return True
        r = self._closable_memo.get(s)
        if r is None:
            r = any(self.instances(rule, s) for _, rule in self.zero)
            self._closable_memo[s] = r
        return r

    def _h(self, p: Seq, goal: Seq) -> float:
        if self._closable(p):
            return 0.0
        return 1.0 + p.succ.size + (4.0 if p.succ == BOT else 0.0) - 0.5 * len(p.ctx - goal.ctx)

    def _candidates(self, goal: Seq) -> list:
        c = self._cands.get(goal)
        if c is None:
            c = []
            h = goal.succ.head if type(goal.succ) is App else None
            for rid, r in self._by_head.get(h, []) + self._by_head.get(None, []):
                for sigma, prems in self.instances(r, goal):
                    if goal not in prems:
                        c.append((rid, sigma, prems))
            self._cands[goal] = c
        return c

    def _search(self, goal: Seq, d: int, path: set) -> Optional[ProofNode]:
        hit = self.success.get(goal)
        if hit is not None:
            return hit
        if self.failed.get(goal, 0) >= d or goal in path:
            return None
        self.nodes += 1
        if self.nodes > self.budget:
            raise _Budget()
        for rid, r in self.zero:
            inst = self.instances(r, goal)
            if inst:
                node = ProofNode(goal, rid, (), inst[0][0])
                self.success[goal] = node
                return node
        cands = self._candidates(goal)
        if d <= 1 or not cands:
            self.failed[goal] = max(self.failed.get(goal, 0), d)
            return None
        scored = sorted(((sum(self._h(p, goal) for p in prems), k) for k, (_, _, prems) in enumerate(cands)))
        path.add(goal)
        try:
            for _, k in scored:
                rid, sigma, prems = cands[k]
                order = sorted(range(len(prems)), key=lambda i: -self._h(prems[i], goal))
                res = [None] * len(prems)
                ok = True
                for i in order:
                    r = self._search(prems[i], d - 1, path)
                    if r is None:
                        ok = False
                        break
                    res[i] = r
                if ok:
                    node = ProofNode(goal, rid, res, sigma)
                    self.success[goal] = node
                    return node
        finally:
            path.discard(goal)
        self.failed[goal] = max(self.failed.get(goal, 0), d)
        return None

    def prove(self, goal: Seq, extra_pool: Iterable[Term] = (), budget: Optional[int] = None,
              max_depth: Optional[int] = None) -> Optional[ProofNode]:
        """Search for a derivation of ``goal``; None if none was found within the
        budget / depth bound."""
        self.set_pool(list(goal.ctx) + [goal.succ] + list(extra_pool))
        self.nodes = 0
        b0 = self.budget
        if budget is not None:
            self.budget = budget
        try:
            for d in range(1, (max_depth or self.max_depth) + 1):
                try:
                    r = self._search(goal, d, set())
                except _Budget:
                    return None
                if r is not None:
                    return r
            return None
        finally:
            self.total_nodes += self.nodes
            self.budget = b0


# ---------------------------------------------------------------------------
# Random formulas, tautologies and exercises
# ---------------------------------------------------------------------------

ATOMS = ("p", "q", "r")
ATOMS_OOD = ("p", "q", "r", "s")


def random_formula(rng: random.Random, n_conn: int, atoms_: Sequence[str] = ATOMS, p_bot: float = 0.04) -> Term:
    """Random formula with exactly ``n_conn`` connectives."""
    if n_conn <= 0:
        return BOT if rng.random() < p_bot else App(rng.choice(list(atoms_)))
    op = rng.choices(["imp", "and", "or", "not"], weights=[3, 2, 2, 2])[0]
    if op == "not":
        return neg(random_formula(rng, n_conn - 1, atoms_, p_bot))
    k = rng.randint(0, n_conn - 1)
    return App(op, (random_formula(rng, k, atoms_, p_bot), random_formula(rng, n_conn - 1 - k, atoms_, p_bot)))


def random_tautologies(n: int, seed: int, conn_range=(2, 6), atoms_: Sequence[str] = ATOMS) -> List[Term]:
    """``n`` distinct random classical tautologies (rejection sampling)."""
    rng = random.Random(seed)
    out, seen = [], set()
    tries = 0
    while len(out) < n and tries < 200000:
        tries += 1
        f = random_formula(rng, rng.randint(*conn_range), atoms_)
        if f in seen or not formula_atoms(f):
            continue
        if valid([], f):
            seen.add(f)
            out.append(f)
    return out


TEMPLATES = [
    "A -> A", "A -> B -> A", "(A -> B) -> (B -> C) -> A -> C", "A & B -> B & A", "A | B -> B | A",
    "(A -> B) -> ~B -> ~A", "~(A | B) -> ~A & ~B", "~A & ~B -> ~(A | B)", "~(A & B) -> ~A | ~B",
    "A & (B | C) -> A & B | A & C", "(A -> B) & (A -> C) -> A -> B & C", "(A -> B -> C) -> A & B -> C",
    "(A & B -> C) -> A -> B -> C", "A | ~A", "~~A -> A", "((A -> B) -> A) -> A", "(A -> B) | (B -> A)",
    "(A | B) & ~A -> B", "(A -> B) & A -> B", "(A -> B) & ~B -> ~A", "(~A -> A) -> A", "(A -> B) -> ~A | B",
    "~A | B -> A -> B", "~(A -> B) -> A", "~(A -> B) -> ~B", "A & ~A -> B", "A -> ~~A",
    "(A | B) & (A -> C) & (B -> C) -> C", "(A -> C) & (B -> C) -> A | B -> C", "~A -> A -> B",
    # valid exercises in which the fallacies give the right answer for a wrong reason
    "(A -> B) -> (B -> A) -> B -> A", "(A -> B) -> (B -> A) -> ~A -> ~B", "(A -> B) -> (~A -> B) -> B",
    "(A -> B) & (~A -> B) -> B", "(A -> B) -> (B -> C) -> (C -> A) -> B -> A",
]
_TEMPLATE_F = [parse_formula(s) for s in TEMPLATES]


@dataclass
class PropHumanConfig:
    """Simulated human population.

    noise_rate     probability that a recorded step is replaced by a random mutation
                   (with a random rule tag)
    fallacy_rate   probability of committing a fallacy at an opportunity (float, or
                   dict fallacy-name -> rate); fallacies: AC, DA, ID
    logic          'classical' (target = classical ND) or 'intuitionistic'
    regime         'id' (exercise sizes used for training) or 'ood' (larger)"""

    noise_rate: float = 0.0
    fallacy_rate: object = 0.0
    fallacies: Tuple[str, ...] = ("AC", "DA", "ID")
    logic: str = "classical"
    regime: str = "id"
    template_frac: float = 0.5
    max_depth: int = 16

    def rate(self, name: str) -> float:
        if name not in self.fallacies:
            return 0.0
        if isinstance(self.fallacy_rate, dict):
            return float(self.fallacy_rate.get(name, 0.0))
        return float(self.fallacy_rate)


@dataclass
class PDerivation:
    goal: Term
    steps: List[PStep]
    proof: ProofNode = None

    def show(self, uni: bool = True) -> str:
        return f"⊢ {fmt(self.goal, uni)}\n" + format_proof(self.proof, uni)


class _SemCache:
    def __init__(self):
        self.v: Dict[Tuple[FrozenSet[Term], Term], bool] = {}
        self.s: Dict[FrozenSet[Term], bool] = {}

    def valid(self, ctx, a):
        k = (ctx, a)
        r = self.v.get(k)
        if r is None:
            r = valid(ctx, a)
            self.v[k] = r
        return r

    def sat(self, ctx):
        r = self.s.get(ctx)
        if r is None:
            r = satisfiable(ctx)
            self.s[ctx] = r
        return r


def _N(G, A, rid, kids=(), kind="valid") -> ProofNode:
    return ProofNode(Seq(G, A), rid, kids, None, kind)


class HumanProver:
    """Randomised, semantically guided natural-deduction proof construction for a
    *valid* goal, imitating human strategy (introduction rules for the goal's
    connective, elimination of assumptions, lemmas ('let'), reductio as a last
    resort), with systematic fallacies at their opportunities.  Falls back to a
    deterministic tableau-style construction (:meth:`tprove`) beyond
    ``max_depth``, which always terminates and is complete for classical logic."""

    def __init__(self, cfg: PropHumanConfig, rng: random.Random):
        self.cfg = cfg
        self.rng = rng
        self.sem = _SemCache()

    # -- deterministic complete construction (classical) ----------------------
    def tprove(self, G: FrozenSet[Term], A: Term) -> ProofNode:
        if A in G:
            return _N(G, A, "ax")
        h = A.head
        if h == "imp":
            B, C = A.args
            return _N(G, A, "impI", [self.tprove(G | {B}, C)])
        if h == "and":
            return _N(G, A, "andI", [self.tprove(G, A.args[0]), self.tprove(G, A.args[1])])
        if h == "not":
            return _N(G, A, "notI", [self.trefute(G | {A.args[0]})])
        if A == BOT:
            return self.trefute(G)
        if not self.sem.sat(G):
            return _N(G, A, "efq", [self.trefute(G)])
        if h == "or":
            B, C = A.args
            if self.sem.valid(G, B):
                return _N(G, A, "orI1", [self.tprove(G, B)])
            if self.sem.valid(G, C):
                return _N(G, A, "orI2", [self.tprove(G, C)])
        return _N(G, A, "raa", [self.trefute(G | {neg(A)})])

    def _cut(self, D, X, proof_x: ProofNode, proof_bot: ProofNode) -> ProofNode:
        """D |- bot from D |- X and D, X |- bot (via notI / notE)."""
        if X in D:
            return proof_bot
        return _N(D, BOT, "notE", [_N(D, neg(X), "notI", [proof_bot]), proof_x])

    def trefute(self, D: FrozenSet[Term]) -> ProofNode:
        """Proof of D |- bot for an unsatisfiable D (tableau expansion)."""
        if BOT in D:
            return _N(D, BOT, "ax")
        for f in sorted(D, key=fkey):
            if f.head == "not" and f.args[0] in D:
                return _N(D, BOT, "notE", [_N(D, f, "ax"), _N(D, f.args[0], "ax")])
        ax = lambda F: _N(D, F, "ax")
        for f in sorted(D, key=fkey):
            h = f.head
            if h == "and":
                B, C = f.args
                for X, rid in ((B, "andE1"), (C, "andE2")):
                    if X not in D:
                        return self._cut(D, X, _N(D, X, rid, [ax(f)]), self.trefute(D | {X}))
            elif h == "not" and f.args[0].head == "not":
                B = f.args[0].args[0]
                if B not in D:
                    Dn = D | {neg(B)}
                    pb = _N(D, B, "raa", [_N(Dn, BOT, "notE", [_N(Dn, f, "ax"), _N(Dn, neg(B), "ax")])])
                    return self._cut(D, B, pb, self.trefute(D | {B}))
            elif h == "not" and f.args[0].head == "or":
                B, C = f.args[0].args
                for X, rid in ((B, "orI1"), (C, "orI2")):
                    if neg(X) not in D:
                        DX = D | {X}
                        p = _N(D, neg(X), "notI", [_N(DX, BOT, "notE", [_N(DX, f, "ax"),
                                                                         _N(DX, f.args[0], rid, [_N(DX, X, "ax")])])])
                        return self._cut(D, neg(X), p, self.trefute(D | {neg(X)}))
            elif h == "not" and f.args[0].head == "imp":
                B, C = f.args[0].args
                if B not in D:
                    Dn = D | {neg(B)}
                    Dnb = Dn | {B}
                    inner = _N(Dnb, C, "efq", [_N(Dnb, BOT, "notE", [_N(Dnb, neg(B), "ax"), _N(Dnb, B, "ax")])])
                    p = _N(D, B, "raa", [_N(Dn, BOT, "notE", [_N(Dn, f, "ax"), _N(Dn, f.args[0], "impI", [inner])])])
                    return self._cut(D, B, p, self.trefute(D | {B}))
                if neg(C) not in D:
                    Dc = D | {C}
                    p = _N(D, neg(C), "notI", [_N(Dc, BOT, "notE", [
                        _N(Dc, f, "ax"), _N(Dc, f.args[0], "impI", [_N(Dc | {B}, C, "ax")])])])
                    return self._cut(D, neg(C), p, self.trefute(D | {neg(C)}))
            elif h == "not" and f.args[0].head == "and":
                B, C = f.args[0].args
                if neg(B) not in D and neg(C) not in D:
                    pb = _N(D, B, "raa", [self.trefute(D | {neg(B)})])
                    pc = _N(D, C, "raa", [self.trefute(D | {neg(C)})])
                    return _N(D, BOT, "notE", [ax(f), _N(D, f.args[0], "andI", [pb, pc])])
            elif h == "or":
                B, C = f.args
                if B not in D and C not in D:
                    return _N(D, BOT, "orE", [ax(f), self.trefute(D | {B}), self.trefute(D | {C})])
            elif h == "imp":
                B, C = f.args
                if neg(B) not in D and C not in D:
                    pB = _N(D, B, "raa", [self.trefute(D | {neg(B)})])
                    pC = _N(D, C, "impE", [ax(f), pB])
                    return self._cut(D, C, pC, self.trefute(D | {C}))
        raise ValueError("trefute called on a satisfiable set")

    # -- human-like randomised construction ----------------------------------
    def _fallacy(self, G, A, depth) -> Optional[ProofNode]:
        cfg, rng = self.cfg, self.rng
        opps = []
        imps = [f for f in sorted(G, key=fkey) if f.head == "imp"]
        if cfg.rate("AC") > 0 and A != BOT:
            # premises A -> B (an assumption) and B; conclude A
            for f in imps:
                if f.args[0] == A and f.args[1] != A:
                    opps.append(("AC", f))
        if cfg.rate("DA") > 0 and A.head == "not":
            B = A.args[0]
            for f in imps:
                if f.args[1] == B and self.sem.valid(G, neg(f.args[0])):
                    opps.append(("DA", f))
        if cfg.rate("ID") > 0:
            for f in imps:
                if f.args[1] == A and f.args[0] not in G and not self.sem.valid(G, f.args[0]):
                    opps.append(("ID", f))
        rng.shuffle(opps)
        for name, f in opps:
            if rng.random() >= cfg.rate(name):
                continue
            tag = FALLACY_RULES[name][1]
            kind = f"fallacy:{name}"
            if name == "AC":
                return _N(G, A, tag, [_N(G, f, "ax"), self.hprove(G, f.args[1], depth + 1)], kind)
            if name == "DA":
                return _N(G, A, tag, [_N(G, f, "ax"), self.hprove(G, neg(f.args[0]), depth + 1)], kind)
            if name == "ID":
                X = f.args[0]
                return _N(G, A, tag, [_N(G, f, "ax"), _N(G | {X}, X, "ax")], kind)
        return None

    def hprove(self, G: FrozenSet[Term], A: Term, depth: int = 0) -> ProofNode:
        cfg, rng, sem = self.cfg, self.rng, self.sem
        if A in G:
            return _N(G, A, "ax")
        if depth > cfg.max_depth:
            return self.tprove(G, A)
        fal = self._fallacy(G, A, depth)
        if fal is not None:
            return fal
        moves = []
        h = A.head
        if BOT in G and A != BOT:
            moves.append((6.0, "efq_ax", None))
        if h == "imp":
            moves.append((6.0, "impI", None))
        elif h == "and":
            moves.append((6.0, "andI", None))
        elif h == "not":
            moves.append((6.0, "notI", None))
        elif h == "or":
            if sem.valid(G, A.args[0]):
                moves.append((6.0, "orI1", None))
            if sem.valid(G, A.args[1]):
                moves.append((6.0, "orI2", None))
        for f in sorted(G, key=fkey):
            fh = f.head
            if fh == "and":
                if A in f.args:
                    moves.append((8.0, "andE", f))
                elif f.args[0] not in G or f.args[1] not in G:
                    moves.append((2.0, "let_and", f))
            elif fh == "imp":
                if f.args[1] == A and sem.valid(G, f.args[0]):
                    moves.append((5.0, "impE", f))
                elif f.args[1] not in G and f.args[1] != A and sem.valid(G, f.args[0]):
                    moves.append((1.5, "let_imp", f))
            elif fh == "or":
                if f.args[0] not in G and f.args[1] not in G:
                    moves.append((2.0, "orE", f))
            elif fh == "not" and A == BOT and sem.valid(G, f.args[0]):
                moves.append((5.0, "notE", f))
        if A != BOT and not sem.sat(G):
            moves.append((2.0, "efq", None))
        if cfg.logic == "classical" and A != BOT and neg(A) not in G:
            moves.append((1.0 if moves else 3.0, "raa", None))
        if not moves:
            return self.tprove(G, A)
        w, mv, f = rng.choices(moves, weights=[m[0] for m in moves])[0]
        d = depth + 1
        if mv == "efq_ax":
            return _N(G, A, "efq", [_N(G, BOT, "ax")])
        if mv == "impI":
            return _N(G, A, "impI", [self.hprove(G | {A.args[0]}, A.args[1], d)])
        if mv == "andI":
            return _N(G, A, "andI", [self.hprove(G, A.args[0], d), self.hprove(G, A.args[1], d)])
        if mv == "notI":
            return _N(G, A, "notI", [self.hprove(G | {A.args[0]}, BOT, d)])
        if mv == "orI1":
            return _N(G, A, "orI1", [self.hprove(G, A.args[0], d)])
        if mv == "orI2":
            return _N(G, A, "orI2", [self.hprove(G, A.args[1], d)])
        if mv == "andE":
            rid = "andE1" if f.args[0] == A else "andE2"
            return _N(G, A, rid, [_N(G, f, "ax")])
        if mv == "let_and":
            X, rid = (f.args[0], "andE1") if f.args[0] not in G else (f.args[1], "andE2")
            return self._let(G, A, X, _N(G, X, rid, [_N(G, f, "ax")]), d)
        if mv == "impE":
            return _N(G, A, "impE", [_N(G, f, "ax"), self.hprove(G, f.args[0], d)])
        if mv == "let_imp":
            X = f.args[1]
            px = _N(G, X, "impE", [_N(G, f, "ax"), self.hprove(G, f.args[0], d)])
            return self._let(G, A, X, px, d)
        if mv == "orE":
            B, C = f.args
            return _N(G, A, "orE", [_N(G, f, "ax"), self.hprove(G | {B}, A, d), self.hprove(G | {C}, A, d)])
        if mv == "notE":
            return _N(G, BOT, "notE", [_N(G, f, "ax"), self.hprove(G, f.args[0], d)])
        if mv == "efq":
            return _N(G, A, "efq", [self.hprove(G, BOT, d)])
        if mv == "raa":
            return _N(G, A, "raa", [self.hprove(G | {neg(A)}, BOT, d)])
        raise AssertionError(mv)

    def _let(self, G, A, X, proof_x, d) -> ProofNode:
        """Lemma X: prove G, X |- A, then ->I and ->E with G |- X."""
        inner = self.hprove(G | {X}, A, d)
        return _N(G, A, "impE", [_N(G, imp(X, A), "impI", [inner]), proof_x])


def _mutate_step(rng: random.Random, st: PStep, atoms_: Sequence[str]) -> Optional[PStep]:
    """A sporadic error: corrupt the conclusion, a premise or a context."""
    for _ in range(20):
        kind = rng.choice(["concl", "concl", "ctx_drop", "ctx_add", "prem"])
        prems, c = list(st.prems), st.concl
        if kind == "concl":
            subs = sorted(subformulas(c.succ), key=fkey)
            target = rng.choice(subs)
            new = random_formula(rng, rng.randint(0, 1), atoms_)
            succ = _replace_sub(c.succ, target, new)
            if succ == c.succ:
                continue
            c = Seq(c.ctx, succ)
        elif kind == "ctx_drop" and c.ctx:
            c = Seq(c.ctx - {rng.choice(c.sorted_ctx)}, c.succ)
        elif kind == "ctx_add":
            c = Seq(c.ctx | {random_formula(rng, rng.randint(0, 1), atoms_)}, c.succ)
        elif kind == "prem" and prems:
            i = rng.randrange(len(prems))
            p = prems[i]
            prems[i] = Seq(p.ctx, _replace_sub(p.succ, p.succ, random_formula(rng, rng.randint(0, 2), atoms_)))
        else:
            continue
        new = PStep(tuple(prems), c, rng.choice(TAGS), "noise")
        if (new.prems, new.concl) != (st.prems, st.concl):
            return new
    return None


def _replace_sub(t: Term, target: Term, new: Term) -> Term:
    if t == target:
        return new
    if type(t) is App and t.args:
        for i, a in enumerate(t.args):
            if target in subformulas(a):
                args = list(t.args)
                args[i] = _replace_sub(a, target, new)
                return App(t.head, tuple(args))
    return t


class PropHumanSimulator:
    """Exercises (tautologies) and their human proofs."""

    def __init__(self, cfg: PropHumanConfig, seed: int = 0):
        self.cfg = cfg
        self.rng = random.Random(seed)
        self.prover = HumanProver(cfg, self.rng)
        self.atoms = ATOMS if cfg.regime == "id" else ATOMS_OOD
        self._ipc_prover = None

    def _inst_template(self) -> Term:
        rng = self.rng
        T = rng.choice(_TEMPLATE_F)
        big = self.cfg.regime == "ood"
        sigma = {}
        for v in variables(T):
            sigma[v] = random_formula(rng, rng.choice([0, 0, 1, 1, 2] if not big else [1, 2, 2, 3]), self.atoms)
        return subst(T, sigma)

    def _random_exercise(self) -> Optional[Term]:
        rng = self.rng
        big = self.cfg.regime == "ood"
        for _ in range(300):
            k = rng.choice([1, 2, 2])
            G = [random_formula(rng, rng.randint(1, 3 if not big else 5), self.atoms) for _ in range(k)]
            A = random_formula(rng, rng.randint(0, 2 if not big else 4), self.atoms)
            if A in G or not satisfiable(G) or not valid(G, A) or valid([], A):
                continue
            goal = A
            for g in reversed(G):
                goal = imp(g, goal)
            return goal
        return None

    def exercise(self) -> Term:
        if self.rng.random() < self.cfg.template_frac:
            return self._inst_template()
        g = self._random_exercise()
        return g if g is not None else self._inst_template()

    def derivation(self) -> PDerivation:
        cfg = self.cfg
        while True:
            goal = self.exercise()
            if cfg.logic == "intuitionistic":
                if self._ipc_prover is None:
                    self._ipc_prover = Prover([(r.name, r) for r in INTUITIONISTIC_RULES], budget=4000, max_depth=12)
                if not kripke_valid_formula(goal):
                    continue
                proof = self._ipc_prover.prove(Seq((), goal))
                if proof is None:
                    continue
                self._ipc_prover.success.clear()
            else:
                proof = self.prover.hprove(frozenset(), goal)
            break
        steps = proof_steps(proof)
        if cfg.noise_rate:
            out = []
            for st in steps:
                if self.rng.random() < cfg.noise_rate:
                    m = _mutate_step(self.rng, st, self.atoms)
                    out.append(m if m is not None else st)
                else:
                    out.append(st)
            steps = out
        return PDerivation(goal, steps, proof)


def generate_corpus(n: int, config: Optional[PropHumanConfig] = None, seed: int = 0) -> List[PDerivation]:
    """``n`` simulated human proofs of tautologies (deterministic given seed)."""
    sim = PropHumanSimulator(config or PropHumanConfig(), seed=seed)
    return [sim.derivation() for _ in range(n)]


# ---------------------------------------------------------------------------
# Sparse world feedback and designated (coherent) contexts
# ---------------------------------------------------------------------------


class PropWorld:
    """World feedback on a few observed valuations ("rows of the truth table").

    The learner may ask whether a sequent, or a single step, is *refuted* at one
    of the observed worlds: a sequent is refuted at v if v satisfies its context
    but not its succedent; a step is refuted at v if all its premise sequents
    hold at v and its conclusion is refuted at v.  Answers are one-sided (a
    refutation is certain).  ``queries`` counts oracle calls."""

    def __init__(self, n_obs: int = 2, seed: int = 0, atoms_: Sequence[str] = ATOMS_OOD):
        rng = random.Random(seed)
        rows = list(itertools.product([False, True], repeat=len(atoms_)))
        self.atoms = tuple(atoms_)
        self.valuations = [dict(zip(atoms_, r)) for r in rng.sample(rows, min(n_obs, len(rows)))]
        self.queries = 0

    def _holds(self, s: Seq, v) -> bool:
        return (not all(truth_value(f, v) for f in s.ctx)) or truth_value(s.succ, v)

    def sequent_refuted(self, s: Seq) -> Optional[dict]:
        self.queries += 1
        for v in self.valuations:
            if not self._holds(s, v):
                return v
        return None

    def step_refuted(self, prems: Sequence[Seq], concl: Seq) -> Optional[dict]:
        self.queries += 1
        for v in self.valuations:
            if all(self._holds(p, v) for p in prems) and not self._holds(concl, v):
                return v
        return None


def designated_contexts(n: int, seed: int, atoms_: Sequence[str] = ATOMS) -> List[FrozenSet[Term]]:
    """The empty context plus ``n`` satisfiable contingent premise sets: the
    'coherent positions' certified by the environment."""
    rng = random.Random(seed)
    out = [frozenset()]
    while len(out) < n + 1:
        G = frozenset(random_formula(rng, rng.randint(0, 2), atoms_, p_bot=0.0) for _ in range(rng.randint(1, 3)))
        if satisfiable(G) and G not in out:
            out.append(G)
    return out
