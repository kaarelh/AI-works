"""Sound three-valued evaluator for first-order arithmetic sentences in the standard model N.

eval returns True / False / None (unknown).  True and False are *certified*:
  * concrete evaluation of atoms at numerals is exact;
  * symbolic atoms are decided by polynomial normal forms over N (variables range over naturals):
      s = t  is True if poly(s) == poly(t); False if poly(s)-poly(t) is a nonzero constant or has all
      coefficients >= 0 with positive constant term (or all <= 0 with negative constant term);
      s < t  is True if poly(t)-poly(s) has all coefficients >= 0 and constant >= 1; False if all
      coefficients <= 0 and constant <= 0;
  * connectives use Kleene's strong three-valued logic (sound for both verdicts);
  * Ax.f: symbolic variable first (a True/False verdict for a fresh symbol holds for every value); then a
      counterexample search over small numerals (a False found at a numeral is a genuine counterexample);
      bounded forms Ax(x<t -> f) with t a numeral are evaluated exactly; one-point forms Ax(x=t -> f) by
      substitution.  Ex.f dually.
A verdict is relative to all values of symbolic variables in the environment (a symbolic verdict is a
universally quantified claim), which is what makes the nested use sound.
Refutation = closure (parameters universally quantified) evaluates to False.
"""
from .syntax import BINDERS, LEAVES, close_params
from .oracle_base import ThreeValued, Budget, no_v0


class Poly:
    __slots__ = ('c',)

    def __init__(self, c):
        self.c = {m: v for m, v in c.items() if v != 0}

    @staticmethod
    def const(n):
        return Poly({(): n})

    @staticmethod
    def var(i):
        return Poly({((i, 1),): 1})

    def __add__(self, o):
        if isinstance(o, int):
            o = Poly.const(o)
        c = dict(self.c)
        for m, v in o.c.items():
            c[m] = c.get(m, 0) + v
        return Poly(c)

    __radd__ = __add__

    def __neg__(self):
        return Poly({m: -v for m, v in self.c.items()})

    def __sub__(self, o):
        if isinstance(o, int):
            o = Poly.const(o)
        return self + (-o)

    def __rsub__(self, o):
        return Poly.const(o) - self

    def __mul__(self, o):
        if isinstance(o, int):
            o = Poly.const(o)
        c = {}
        for m1, v1 in self.c.items():
            for m2, v2 in o.c.items():
                d = dict(m1)
                for (x, e) in m2:
                    d[x] = d.get(x, 0) + e
                m = tuple(sorted(d.items()))
                c[m] = c.get(m, 0) + v1 * v2
        return Poly(c)

    __rmul__ = __mul__

    def const_term(self):
        return self.c.get((), 0)

    def is_const(self):
        return all(m == () for m in self.c)

    def nonconst_coeffs(self):
        return [v for m, v in self.c.items() if m != ()]


def _sub(a, b):
    if isinstance(a, int) and isinstance(b, int):
        return a - b
    if isinstance(a, int):
        return Poly.const(a) - b
    return a - b


def _classify_eq(d):
    """d = s - t; True/False/None for s = t over N"""
    if isinstance(d, int):
        return d == 0
    if d.is_const():
        return d.const_term() == 0
    cs = d.nonconst_coeffs()
    k = d.const_term()
    if all(v >= 0 for v in cs) and k > 0:
        return False
    if all(v <= 0 for v in cs) and k < 0:
        return False
    return None


def _classify_pos(e):
    """e = t - s; True/False/None for s < t, i.e. e >= 1"""
    if isinstance(e, int):
        return e >= 1
    if e.is_const():
        return e.const_term() >= 1
    cs = e.nonconst_coeffs()
    k = e.const_term()
    if all(v >= 0 for v in cs) and k >= 1:
        return True
    if all(v <= 0 for v in cs) and k <= 0:
        return False
    return None


def _polykey(d):
    if isinstance(d, int):
        return d
    return tuple(sorted(d.c.items()))


class PAEval(ThreeValued):
    def __init__(self, bound=6, nested_bound=4, max_steps=40000, bounded_cap=64):
        super().__init__(max_steps)
        self.bound, self.nested_bound = bound, nested_bound
        self.bounded_cap = bounded_cap
        self.nsym = 0

    def vkey(self, x):
        return x if isinstance(x, int) else ('poly', _polykey(x))

    # ------------------------------------------------------------ terms
    def term(self, t, env):
        h = t[0]
        if h == '0':
            return 0
        if h == 'v':
            return env[t[1]]
        if h == 'S':
            return self.term(t[1], env) + 1
        if h == '+':
            return self.term(t[1], env) + self.term(t[2], env)
        if h == '*':
            a, b = self.term(t[1], env), self.term(t[2], env)
            if isinstance(a, int) and isinstance(b, int) and (a > 10 ** 12 or b > 10 ** 12):
                raise Budget
            return a * b
        raise ValueError('bad term %r' % (t,))

    def atom(self, f, env):
        h = f[0]
        if h == '=':
            d = _sub(self.term(f[1], env), self.term(f[2], env))
            v = _classify_eq(d)
            if isinstance(d, int):
                return v, ('=', d)
            k1, k2 = _polykey(d), _polykey(-d)
            return v, ('=', min(k1, k2))
        if h == '<':
            e = _sub(self.term(f[2], env), self.term(f[1], env))
            return _classify_pos(e), ('<', _polykey(e))
        raise ValueError('bad atom %r' % (h,))

    def quant(self, isall, body, env, level):
        conn = 'imp' if isall else 'and'
        # bounded / one-point forms
        if body[0] == conn and body[1][0] in ('<', '=') and body[1][1] == ('v', 0) and no_v0(body[1][2]):
            tv = self.term(body[1][2], [0] + env)          # index 0 unused in the bound term
            if body[1][0] == '=':
                return self.ev(body[2], [tv] + env, level + 1)
            if isinstance(tv, int) and tv <= self.bounded_cap:
                return self.combine(isall, (self.ev(body[2], [n] + env, level + 1) for n in range(tv)))
        # symbolic: a verdict for a fresh symbol holds for all values
        self.nsym += 1
        r = self.ev(body, [Poly.var(self.nsym)] + env, level + 1)
        if r is not None:
            return r
        # concrete search
        B = self.bound if level == 0 else self.nested_bound
        for n in range(B):
            r = self.ev(body, [n] + env, level + 1)
            if isall and r is False:
                return False
            if (not isall) and r is True:
                return True
        return None


def refutes(sentence, ev=None):
    ev = ev or PAEval()
    return ev.truth(sentence) is False
