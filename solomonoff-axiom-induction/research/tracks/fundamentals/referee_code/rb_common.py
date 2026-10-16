"""rb_common.py -- referee B's shared finite stand-in for thread `fundamentals`.

Written independently of the developer's checks/ (not copied, different representation):

* Sentences are propositional formulas as syntax trees (nested tuples), so that syntactically
  different but logically equivalent sentences exist.  The content of a sentence is its model set,
  a frozenset of valuation indices over k atoms, computed by a truth table.
* A theory machine is a finite list of pairs (w, formula) with w a binary string: "after reading w
  from the tape, emit the formula".  Its law is computed exactly by enumerating every tape prefix
  of the machine's horizon (the longest w), each with weight 2^-N (Fractions).  The random theory
  on a tape is the set of emitted formulas; its content is the intersection of their model sets
  (the empty frozenset = inconsistent).
* A toy universal theory machine G_U is built from a finite list of machines G_i and a prefix-free
  set of "programs" p_i: G_U = {(p_i w, chi) : (w, chi) in G_i}; tapes with no program prefix
  emit nothing (empty theory), as in Def 1.4 of the notes.
* A "focal law" is a dict {model set: mass}; all one-tape quantities of the notes are functions of
  the focal law of A_omega (Prop 2.1(g)), and are computed from it here.

No randomness lives in this module; every script seeds its own random.Random(20261016).
"""
from fractions import Fraction as Fr
import itertools
import math

# ---------------------------------------------------------------- syntax
TOP = ('top',)
BOT = ('bot',)


def At(i):
    return ('atom', i)


def Not(f):
    return ('not', f)


def And(*fs):
    fs = list(fs)
    if not fs:
        return TOP
    out = fs[-1]
    for f in reversed(fs[:-1]):
        out = ('and', f, out)
    return out


def Or(*fs):
    fs = list(fs)
    if not fs:
        return BOT
    out = fs[-1]
    for f in reversed(fs[:-1]):
        out = ('or', f, out)
    return out


def Imp(f, g):
    return ('imp', f, g)


def Iff(f, g):
    return ('iff', f, g)


def lit(f, b):
    """phi^1 = phi, phi^0 = not phi."""
    return f if b == 1 else Not(f)


class Logic:
    """Propositional logic over k atoms with truth-table semantics."""

    def __init__(self, k):
        self.k = k
        self.nv = 1 << k
        self.ALL = frozenset(range(self.nv))
        self._cache = {}

    def val(self, f, v):
        t = f[0]
        if t == 'atom':
            return (v >> f[1]) & 1 == 1
        if t == 'not':
            return not self.val(f[1], v)
        if t == 'and':
            return self.val(f[1], v) and self.val(f[2], v)
        if t == 'or':
            return self.val(f[1], v) or self.val(f[2], v)
        if t == 'imp':
            return (not self.val(f[1], v)) or self.val(f[2], v)
        if t == 'iff':
            return self.val(f[1], v) == self.val(f[2], v)
        if t == 'top':
            return True
        if t == 'bot':
            return False
        raise ValueError(f)

    def mod(self, f):
        """model set of a formula (cached)."""
        r = self._cache.get(f)
        if r is None:
            r = frozenset(v for v in range(self.nv) if self.val(f, v))
            self._cache[f] = r
        return r

    def mod_set(self, fs):
        m = self.ALL
        for f in fs:
            m = m & self.mod(f)
        return m

    def proves(self, F, f):
        """a theory with model set F proves f (an inconsistent theory proves everything)."""
        return F <= self.mod(f)

    def decides(self, F, f):
        return F <= self.mod(f) or not (F & self.mod(f))

    def formula_of(self, S):
        """a canonical formula (DNF of valuations) with model set S."""
        terms = []
        for v in sorted(S):
            terms.append(And(*[lit(At(i), (v >> i) & 1) for i in range(self.k)]))
        return Or(*terms) if terms else BOT


# ---------------------------------------------------------------- data
# a data set: list of (formula, label) with label in {1, 0, 'i'}; distinct formulas (partial function)

def psi_mod(L, D, B=None):
    """model set of B + D^pm (two-valued part)."""
    m = L.ALL if B is None else L.mod(B)
    for (f, y) in D:
        if y in (0, 1):
            m = m & L.mod(lit(f, y))
    return m


# ---------------------------------------------------------------- theory machines
def machine_law(L, G, B=None):
    """exact focal law {model set of B + A_omega: mass} of a finite theory machine G = [(w, f), ...].
    Horizon N = max |w|; every tape prefix of length N has weight 2^-N."""
    N = max([len(w) for (w, _) in G], default=0)
    law = {}
    base = L.ALL if B is None else L.mod(B)
    for bits in itertools.product('01', repeat=N):
        tape = ''.join(bits)
        m = base
        for (w, f) in G:
            if tape.startswith(w):
                m = m & L.mod(f)
        law[m] = law.get(m, Fr(0)) + Fr(1, 2 ** N)
    return law


def universal_machine(machines, codes):
    """G_U from machines G_i and a prefix-free list of codes p_i."""
    for a, b in itertools.permutations(codes, 2):
        assert not b.startswith(a), "codes must be prefix-free"
    GU = []
    for G, p in zip(machines, codes):
        for (w, f) in G:
            GU.append((p + w, f))
        if not G:
            pass
    return GU


def mixture_law(L, machines, codes, B=None):
    """the mixture formula of Thm 4.1: sum_i 2^-|p_i| law(G_i) + (1 - Omega) delta_{empty theory}."""
    law = {}
    omega = Fr(0)
    for G, p in zip(machines, codes):
        w = Fr(1, 2 ** len(p))
        omega += w
        for m, x in machine_law(L, G, B).items():
            law[m] = law.get(m, Fr(0)) + w * x
    base = L.ALL if B is None else L.mod(B)
    law[base] = law.get(base, Fr(0)) + (1 - omega)
    return law


def add_laws(*pairs):
    out = {}
    for (w, law) in pairs:
        for m, x in law.items():
            out[m] = out.get(m, Fr(0)) + w * x
    return out


# ---------------------------------------------------------------- one-tape quantities from a focal law
def M(L, law, D, B=None):
    """two-valued M: consistent and proves psi_D; three-valued if D has 'i' labels."""
    p = psi_mod(L, D, B)
    tot = Fr(0)
    for F, x in law.items():
        if not F or not F <= p:
            continue
        ok = True
        for (f, y) in D:
            if y == 'i' and L.decides(F, f):
                ok = False
                break
        if ok:
            tot += x
    return tot


def consistent_mass(law):
    return sum((x for F, x in law.items() if F), Fr(0))


def bel(L, law, D, chi, B=None):
    """Bel_D(chi) for the posterior after two-valued D."""
    p = psi_mod(L, D, B)
    Z = sum((x for F, x in law.items() if F and F <= p), Fr(0))
    num = sum((x for F, x in law.items() if F and F <= p and L.proves(F, chi)), Fr(0))
    return num / Z


def bel0(L, law, chi):
    return sum((x for F, x in law.items() if F and L.proves(F, chi)), Fr(0))


def tri(L, law, D, f, B=None):
    b = bel(L, law, D, f, B)
    d = bel(L, law, D, Not(f), B)
    return b, d, 1 - b - d


def Mnc(L, law, D, B=None):
    p = psi_mod(L, D, B)
    return sum((x for F, x in law.items() if F & p), Fr(0))


def bel_nc(L, law, D, chi, B=None):
    p = psi_mod(L, D, B)
    Z = Mnc(L, law, D, B)
    num = sum((x for F, x in law.items() if (F & p) and (F & p) <= L.mod(chi)), Fr(0))
    return num / Z


def Mhalf(L, law, D, B=None):
    p = psi_mod(L, D, B)
    tot = Fr(0)
    for F, x in law.items():
        if not F or not (F & p):
            continue
        g = Fr(1)
        for (f, y) in D:
            if not L.proves(F, lit(f, y)):
                g /= 2
        tot += x * g
    return tot


def lg(x):
    return math.log2(x)
