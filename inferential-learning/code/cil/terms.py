"""First-order terms: representation, parsing, printing, substitution, matching,
unification and (Plotkin) anti-unification.

Representation
--------------
* ``Var(name)``           -- a *schematic* (meta) variable, printed ``?name``.
* ``App(head, args)``     -- a function application.  Constants are ``App`` with
  no arguments.  Integer literals are constants whose head is a string of
  decimal digits (``App('3')``); negative numbers are written ``neg(3)``.
  Object-level symbols such as the algebraic unknowns ``x, y`` are *constants*
  (they cannot be instantiated by matching); only ``Var`` is schematic.

Infix syntax understood by :func:`parse` / produced by :func:`pretty`::

    expr   := term (('+' | '-') term)*            left associative
    term   := unary (('*' | '/') unary)*          left associative
    unary  := '-' unary | power
    power  := atom ('^' unary)?                   right associative
    atom   := INT | IDENT | IDENT '(' expr (',' expr)* ')' | '?' IDENT | '(' expr ')'

Heads used for the operators: ``+ - * / ^`` and ``neg`` (unary minus).
So ``-x^2`` is ``neg(x^2)``, ``-a*b`` is ``(neg a)*b`` and ``2^-1`` is ``2^(neg 1)``.

Positions are tuples of argument indices (the root is ``()``).

Everything here is purely syntactic and domain independent.
"""
from __future__ import annotations

import re
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Tuple, Union

__all__ = [
    "Var", "App", "Term", "Pos", "Subst",
    "num", "const", "app", "is_numeral", "numeral_value", "is_atom",
    "parse", "parse_pattern", "pretty",
    "subst", "variables", "var_set", "atoms",
    "match", "match_tuple", "is_instance", "is_instance_tuple",
    "unify", "unify_tuple", "rename_vars", "rename_apart",
    "canonical", "canonical_tuple", "is_variant", "is_variant_tuple",
    "lgg", "lgg_many", "lgg_tuples", "lgg_tuples_subst", "nonvar_size",
    "positions", "subterm", "replace", "subterms", "depth",
    "BINARY_OPS", "HOLE", "plug",
]

# ---------------------------------------------------------------------------
# Term classes
# ---------------------------------------------------------------------------


class Var:
    """A schematic variable.  Immutable and hashable."""

    __slots__ = ("name", "_h")
    size = 1          # number of nodes
    ground = False    # contains no Var

    def __init__(self, name: str):
        self.name = name
        self._h = hash(("?", name))

    def __eq__(self, other):
        return self is other or (type(other) is Var and other.name == self.name)

    def __ne__(self, other):
        return not self.__eq__(other)

    def __hash__(self):
        return self._h

    def __repr__(self):
        return f"Var({self.name!r})"

    def __str__(self):
        return "?" + self.name

    def __lt__(self, other):  # deterministic sorting helper
        return _sort_key(self) < _sort_key(other)


class App:
    """A function application ``head(args...)``; constants have ``args == ()``."""

    __slots__ = ("head", "args", "_h", "size", "ground")

    def __init__(self, head: str, args: Sequence["Term"] = ()):
        self.head = head
        self.args = tuple(args)
        self._h = hash((head, self.args))
        self.size = 1 + sum(a.size for a in self.args)
        self.ground = all(a.ground for a in self.args)

    def __eq__(self, other):
        if self is other:
            return True
        if type(other) is not App or other._h != self._h:
            return False
        return self.head == other.head and self.args == other.args

    def __ne__(self, other):
        return not self.__eq__(other)

    def __hash__(self):
        return self._h

    def __repr__(self):
        if not self.args:
            return f"App({self.head!r})"
        return f"App({self.head!r}, {list(self.args)!r})"

    def __str__(self):
        return pretty(self)

    def __lt__(self, other):
        return _sort_key(self) < _sort_key(other)


Term = Union[Var, App]
Pos = Tuple[int, ...]
Subst = Dict[str, Term]


def _sort_key(t: Term):
    if type(t) is Var:
        return (0, t.name)
    return (1, t.head, len(t.args), tuple(_sort_key(a) for a in t.args))


# ---------------------------------------------------------------------------
# Constructors / predicates
# ---------------------------------------------------------------------------

_DIGITS = re.compile(r"^\d+$")


def num(n: int) -> App:
    """Integer literal; negative integers become ``neg(|n|)``."""
    if n < 0:
        return App("neg", (App(str(-n)),))
    return App(str(n))


def const(name: str) -> App:
    return App(name)


def app(head: str, *args: Term) -> App:
    return App(head, args)


def is_numeral(t: Term) -> bool:
    """True for a non-negative integer literal such as ``3``."""
    return type(t) is App and not t.args and t.head.isdigit()


def numeral_value(t: Term) -> Optional[int]:
    """Integer value of ``n`` or ``neg(n)``, else None."""
    if is_numeral(t):
        return int(t.head)
    if type(t) is App and t.head == "neg" and len(t.args) == 1 and is_numeral(t.args[0]):
        return -int(t.args[0].head)
    return None


def is_atom(t: Term) -> bool:
    """An object-level constant that is not a numeral (e.g. the unknown ``x``)."""
    return type(t) is App and not t.args and not t.head.isdigit()


BINARY_OPS = {"+": 1, "-": 1, "*": 2, "/": 2, "^": 4}
_NEG_PREC = 3
_ATOM_PREC = 5

# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

_TOKEN = re.compile(r"\s*(?:(\d+)|(\?[A-Za-z_][A-Za-z0-9_']*)|([A-Za-z_][A-Za-z0-9_']*)|(\S))")


def _tokenize(s: str) -> List[Tuple[str, str]]:
    toks = []
    pos = 0
    s = s.rstrip()
    while pos < len(s):
        m = _TOKEN.match(s, pos)
        if not m:
            raise SyntaxError(f"cannot tokenize at {s[pos:]!r}")
        pos = m.end()
        if m.group(1):
            toks.append(("int", m.group(1)))
        elif m.group(2):
            toks.append(("var", m.group(2)[1:]))
        elif m.group(3):
            toks.append(("id", m.group(3)))
        else:
            toks.append(("op", m.group(4)))
    return toks


class _Parser:
    def __init__(self, s: str, var_names):
        self.toks = _tokenize(s)
        self.i = 0
        self.var_names = var_names

    def peek(self):
        return self.toks[self.i] if self.i < len(self.toks) else (None, None)

    def take(self, kind=None, val=None):
        tok = self.peek()
        if tok[0] is None:
            raise SyntaxError("unexpected end of input")
        if (kind and tok[0] != kind) or (val and tok[1] != val):
            raise SyntaxError(f"expected {val or kind}, got {tok[1]!r}")
        self.i += 1
        return tok

    def parse(self) -> Term:
        t = self.expr()
        if self.i != len(self.toks):
            raise SyntaxError(f"trailing input at token {self.toks[self.i]!r}")
        return t

    def expr(self):
        t = self.term()
        while self.peek() in (("op", "+"), ("op", "-")):
            op = self.take()[1]
            t = App(op, (t, self.term()))
        return t

    def term(self):
        t = self.unary()
        while self.peek() in (("op", "*"), ("op", "/")):
            op = self.take()[1]
            t = App(op, (t, self.unary()))
        return t

    def unary(self):
        if self.peek() == ("op", "-"):
            self.take()
            return App("neg", (self.unary(),))
        return self.power()

    def power(self):
        base = self.atom()
        if self.peek() == ("op", "^"):
            self.take()
            return App("^", (base, self.unary()))
        return base

    def atom(self):
        kind, val = self.peek()
        if kind == "int":
            self.take()
            return App(str(int(val)))
        if kind == "var":
            self.take()
            return Var(val)
        if kind == "id":
            self.take()
            if self.peek() == ("op", "("):
                self.take()
                args = [self.expr()]
                while self.peek() == ("op", ","):
                    self.take()
                    args.append(self.expr())
                self.take("op", ")")
                return App(val, tuple(args))
            if self.var_names == "all" or (self.var_names and val in self.var_names):
                return Var(val)
            return App(val)
        if (kind, val) == ("op", "("):
            self.take()
            t = self.expr()
            self.take("op", ")")
            return t
        raise SyntaxError(f"unexpected token {val!r}")


def parse(s: str, var_names: Union[None, str, Iterable[str]] = None) -> Term:
    """Parse infix syntax.  Bare identifiers are constants unless listed in
    ``var_names`` (or ``var_names == 'all'``); ``?name`` is always a Var."""
    if var_names is not None and var_names != "all":
        var_names = set(var_names)
    return _Parser(s, var_names).parse()


def parse_pattern(s: str) -> Term:
    """Parse with every bare (non-function) identifier read as a schematic Var."""
    return parse(s, "all")


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------


def _prec(t: Term) -> int:
    if type(t) is App:
        if t.head in BINARY_OPS and len(t.args) == 2:
            return BINARY_OPS[t.head]
        if t.head == "neg" and len(t.args) == 1:
            return _NEG_PREC
    return _ATOM_PREC


def pretty(t: Term) -> str:
    """Inverse of :func:`parse` (``parse(pretty(t)) == t`` for every term)."""
    if type(t) is Var:
        return "?" + t.name
    h, args = t.head, t.args
    if h in BINARY_OPS and len(args) == 2:
        p = BINARY_OPS[h]
        a, b = args
        if h == "^":
            ls = _wrap(a, _prec(a) < _ATOM_PREC)
            rs = _wrap(b, _prec(b) < _NEG_PREC or _prec(b) == _NEG_PREC)
            return f"{ls}^{rs}"
        ls = _wrap(a, _prec(a) < p)
        # right operand: needs strictly higher precedence (left associativity);
        # a unary minus on the right is parenthesised for readability.
        rs = _wrap(b, _prec(b) <= p or _prec(b) == _NEG_PREC)
        sep = " " if p == 1 else ""
        return f"{ls}{sep}{h}{sep}{rs}"
    if h == "neg" and len(args) == 1:
        a = args[0]
        return "-" + _wrap(a, _prec(a) < _NEG_PREC)
    if not args:
        return h
    return h + "(" + ", ".join(pretty(a) for a in args) + ")"


def _wrap(t: Term, paren: bool) -> str:
    s = pretty(t)
    return f"({s})" if paren else s


# ---------------------------------------------------------------------------
# Variables, substitution, positions
# ---------------------------------------------------------------------------


def variables(t: Union[Term, Sequence[Term]]) -> List[str]:
    """Variable names in order of first occurrence (preorder, left to right)."""
    out: List[str] = []
    seen = set()
    stack = list(reversed(t)) if isinstance(t, (tuple, list)) else [t]
    while stack:
        u = stack.pop()
        if type(u) is Var:
            if u.name not in seen:
                seen.add(u.name)
                out.append(u.name)
        elif not u.ground:
            stack.extend(reversed(u.args))
    return out


def var_set(t: Union[Term, Sequence[Term]]) -> set:
    return set(variables(t))


def atoms(t: Term) -> set:
    """Object-level non-numeral constants occurring in ``t``."""
    out = set()
    stack = [t]
    while stack:
        u = stack.pop()
        if type(u) is App:
            if not u.args:
                if not u.head.isdigit():
                    out.add(u.head)
            else:
                stack.extend(u.args)
    return out


def subst(t: Term, sigma: Subst) -> Term:
    """Apply a substitution (dict var-name -> term), simultaneously."""
    if t.ground or not sigma:
        return t
    if type(t) is Var:
        return sigma.get(t.name, t)
    return App(t.head, tuple(subst(a, sigma) for a in t.args))


def positions(t: Term) -> List[Pos]:
    """All positions of ``t`` in preorder."""
    out: List[Pos] = []

    def go(u, p):
        out.append(p)
        if type(u) is App:
            for i, a in enumerate(u.args):
                go(a, p + (i,))

    go(t, ())
    return out


def subterms(t: Term) -> Iterator[Tuple[Pos, Term]]:
    """Yield (position, subterm) pairs in preorder."""
    stack = [((), t)]
    while stack:
        p, u = stack.pop()
        yield p, u
        if type(u) is App:
            for i in range(len(u.args) - 1, -1, -1):
                stack.append((p + (i,), u.args[i]))


def subterm(t: Term, pos: Pos) -> Term:
    for i in pos:
        t = t.args[i]
    return t


def replace(t: Term, pos: Pos, new: Term) -> Term:
    """``t[new]_pos`` -- replace the subterm at ``pos``."""
    if not pos:
        return new
    i = pos[0]
    args = list(t.args)
    args[i] = replace(args[i], pos[1:], new)
    return App(t.head, tuple(args))


def depth(t: Term) -> int:
    if type(t) is Var or not t.args:
        return 1
    return 1 + max(depth(a) for a in t.args)


HOLE = Var("[]")


def plug(context: Term, filler: Term) -> Term:
    """Fill every occurrence of the hole ``HOLE`` in ``context``; a context
    ``C[.]`` is just a term containing ``HOLE``."""
    return subst(context, {HOLE.name: filler})


# ---------------------------------------------------------------------------
# Matching (one-way) and unification
# ---------------------------------------------------------------------------


def match(pattern: Term, term: Term, sigma: Optional[Subst] = None) -> Optional[Subst]:
    """Return sigma extending ``sigma`` with ``subst(pattern, sigma) == term``,
    or None.  Variables occurring in ``term`` are treated as rigid symbols."""
    s: Subst = dict(sigma) if sigma else {}
    stack = [(pattern, term)]
    while stack:
        p, t = stack.pop()
        if type(p) is Var:
            b = s.get(p.name)
            if b is None:
                s[p.name] = t
            elif b != t:
                return None
        else:
            if p.ground:
                if p != t:
                    return None
                continue
            if type(t) is not App or t.head != p.head or len(t.args) != len(p.args):
                return None
            stack.extend(zip(p.args, t.args))
    return s


def match_tuple(patterns: Sequence[Term], terms: Sequence[Term],
                sigma: Optional[Subst] = None) -> Optional[Subst]:
    """Simultaneous matching with one consistent substitution."""
    if len(patterns) != len(terms):
        return None
    s = dict(sigma) if sigma else {}
    for p, t in zip(patterns, terms):
        s = match(p, t, s)
        if s is None:
            return None
    return s


def is_instance(term: Term, pattern: Term) -> bool:
    return match(pattern, term) is not None


def is_instance_tuple(terms: Sequence[Term], patterns: Sequence[Term]) -> bool:
    return match_tuple(patterns, terms) is not None


def _walk(t: Term, s: Subst) -> Term:
    while type(t) is Var and t.name in s:
        t = s[t.name]
    return t


def _occurs(name: str, t: Term, s: Subst) -> bool:
    stack = [t]
    while stack:
        u = _walk(stack.pop(), s)
        if type(u) is Var:
            if u.name == name:
                return True
        elif not u.ground:
            stack.extend(u.args)
    return False


def _resolve(t: Term, s: Subst) -> Term:
    t = _walk(t, s)
    if type(t) is Var or t.ground:
        return t
    return App(t.head, tuple(_resolve(a, s) for a in t.args))


def unify_tuple(lefts: Sequence[Term], rights: Sequence[Term],
                sigma: Optional[Subst] = None) -> Optional[Subst]:
    """Most general (idempotent) unifier of the pairs, with occurs check."""
    if len(lefts) != len(rights):
        return None
    s: Subst = dict(sigma) if sigma else {}
    stack = list(zip(lefts, rights))
    while stack:
        a, b = stack.pop()
        a, b = _walk(a, s), _walk(b, s)
        if a is b or a == b:
            continue
        if type(a) is Var:
            if _occurs(a.name, b, s):
                return None
            s[a.name] = b
        elif type(b) is Var:
            if _occurs(b.name, a, s):
                return None
            s[b.name] = a
        else:
            if a.head != b.head or len(a.args) != len(b.args):
                return None
            stack.extend(zip(a.args, b.args))
    return {k: _resolve(v, s) for k, v in s.items()}


def unify(a: Term, b: Term, sigma: Optional[Subst] = None) -> Optional[Subst]:
    return unify_tuple((a,), (b,), sigma)


def rename_vars(t: Term, mapping: Dict[str, str]) -> Term:
    return subst(t, {k: Var(v) for k, v in mapping.items()})


def rename_apart(t: Union[Term, Sequence[Term]], suffix: str = "'"):
    """Rename every variable ``v`` to ``v + suffix`` (term or tuple of terms)."""
    names = variables(t)
    m = {n: Var(n + suffix) for n in names}
    if isinstance(t, (tuple, list)):
        return tuple(subst(u, m) for u in t)
    return subst(t, m)


def canonical_tuple(ts: Sequence[Term], prefix: str = "v") -> Tuple[Term, ...]:
    """Rename variables to ``v0, v1, ...`` in order of first occurrence across
    the tuple.  Two tuples are variants iff their canonical forms are equal."""
    names = variables(tuple(ts))
    m = {n: Var(f"{prefix}{i}") for i, n in enumerate(names)}
    return tuple(subst(u, m) for u in ts)


def canonical(t: Term, prefix: str = "v") -> Term:
    return canonical_tuple((t,), prefix)[0]


def is_variant(a: Term, b: Term) -> bool:
    return canonical(a) == canonical(b)


def is_variant_tuple(a: Sequence[Term], b: Sequence[Term]) -> bool:
    return len(a) == len(b) and canonical_tuple(a) == canonical_tuple(b)


# ---------------------------------------------------------------------------
# Anti-unification (least general generalisation, Plotkin 1970 / Reynolds 1970)
# ---------------------------------------------------------------------------


class _AU:
    """n-ary anti-unifier with a single consistent variable table.

    The generalisation of aligned subterms ``(t_1..t_n)`` is
      * ``t_1`` if all are identical and ground,
      * ``f(lgg of aligned args)`` if all are applications of the same ``f``/arity,
      * otherwise the variable assigned to the *tuple* ``(t_1..t_n)``; the same
        tuple always receives the same variable (this is what makes the result
        least general, e.g. lgg(f(a,a), f(b,b)) = f(X,X)).
    Variables occurring in the inputs are treated as rigid symbols of separate
    name spaces (so identical non-ground inputs are re-generalised)."""

    def __init__(self, prefix: str = "X"):
        self.table: Dict[Tuple[Term, ...], Var] = {}
        self.prefix = prefix

    def var_for(self, key: Tuple[Term, ...]) -> Var:
        v = self.table.get(key)
        if v is None:
            v = Var(f"{self.prefix}{len(self.table) + 1}")
            self.table[key] = v
        return v

    def gen(self, ts: Tuple[Term, ...]) -> Term:
        first = ts[0]
        if first.ground and all(u == first for u in ts[1:]):
            return first
        if type(first) is App and all(
            type(u) is App and u.head == first.head and len(u.args) == len(first.args) for u in ts[1:]
        ):
            return App(first.head, tuple(self.gen(tuple(u.args[i] for u in ts)) for i in range(len(first.args))))
        return self.var_for(ts)

    def substitutions(self, n: int) -> List[Subst]:
        """sigma_i with subst(generalisation, sigma_i) == input i."""
        return [{v.name: key[i] for key, v in self.table.items()} for i in range(n)]


def lgg(s: Term, t: Term, prefix: str = "X") -> Tuple[Term, Subst, Subst]:
    """Plotkin's least general generalisation of two terms.

    Returns ``(g, sigma1, sigma2)`` with ``g sigma1 == s`` and ``g sigma2 == t``."""
    au = _AU(prefix)
    g = au.gen((s, t))
    s1, s2 = au.substitutions(2)
    return g, s1, s2


def lgg_many(terms: Sequence[Term], prefix: str = "X") -> Term:
    """Least general generalisation of a non-empty sequence of terms."""
    if not terms:
        raise ValueError("lgg of empty sequence")
    return _AU(prefix).gen(tuple(terms))


def lgg_tuples(tuples: Sequence[Sequence[Term]], prefix: str = "X") -> Tuple[Term, ...]:
    """LGG of a set of equal-length tuples with ONE variable table shared by all
    components, e.g. rewrite cores (lhs, rhs): the lgg of ((x+0, x), (y+0, y))
    is (X1 + 0, X1), not (X1 + 0, X2)."""
    if not tuples:
        raise ValueError("lgg of empty sequence")
    k = len(tuples[0])
    if any(len(tp) != k for tp in tuples):
        raise ValueError("tuples of different lengths")
    au = _AU(prefix)
    return tuple(au.gen(tuple(tp[i] for tp in tuples)) for i in range(k))


def lgg_tuples_subst(tuples: Sequence[Sequence[Term]], prefix: str = "X") -> Tuple[Tuple[Term, ...], List[Subst]]:
    """Like :func:`lgg_tuples` but also returns, for each input tuple ``i``, the
    substitution ``theta_i`` with ``subst(g_j, theta_i) == tuples[i][j]``."""
    if not tuples:
        raise ValueError("lgg of empty sequence")
    k = len(tuples[0])
    au = _AU(prefix)
    g = tuple(au.gen(tuple(tp[i] for tp in tuples)) for i in range(k))
    return g, au.substitutions(len(tuples))


def nonvar_size(t: Term) -> int:
    """Number of non-variable nodes of ``t``."""
    if type(t) is Var:
        return 0
    if t.ground:
        return t.size
    return 1 + sum(nonvar_size(a) for a in t.args)
