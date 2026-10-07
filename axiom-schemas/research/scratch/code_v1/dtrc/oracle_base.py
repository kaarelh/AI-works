"""Shared machinery for the sound three-valued evaluators: Kleene connectives plus *supervaluation* of
quantifier-free subformulas (when Kleene gives 'unknown', enumerate all truth assignments to the distinct
unknown atoms; if every assignment gives the same value, that value is certified, since the actual
assignment is one of them)."""
from .syntax import BINDERS, LEAVES, close_params


class Budget(Exception):
    pass


class ThreeValued:
    max_super_atoms = 8

    def __init__(self, max_steps):
        self.max_steps = max_steps
        self.steps = 0
        self._qf = {}

    # subclass interface
    def atom(self, f, env):
        """returns (value, key) where value in {True, False, None} and key identifies the proposition"""
        raise NotImplementedError

    def quant(self, isall, body, env, level):
        raise NotImplementedError

    def is_qf(self, f):
        k = id(f)
        r = self._qf.get(k)
        if r is None:
            h = f[0]
            if h in BINDERS:
                r = False
            elif h in ('not', 'and', 'or', 'imp', 'iff'):
                r = all(self.is_qf(g) for g in f[1:])
            else:
                r = True
            self._qf[k] = (r, f)
            return r
        return r[0]

    def vkey(self, x):
        """hashable key of a value (subclass may override)"""
        return x

    def envkey(self, env):
        return tuple(self.vkey(x) for x in env)

    def ev(self, f, env, level=0):
        self.steps += 1
        if self.steps > self.max_steps:
            raise Budget
        h = f[0]
        if h in BINDERS:
            key = (f, self.envkey(env))
            r = self._memo.get(key, 0)
            if r != 0:
                return r
            r = self.quant(h == 'all', f[1], env, level)
            self._memo[key] = r
            return r
        if h not in ('not', 'and', 'or', 'imp', 'iff'):
            return self.atom(f, env)[0]
        r = self._kleene(f, env, level)
        if r is None:
            r = self.supervaluate(f, env, level)
        return r

    def _kleene(self, f, env, level):
        h = f[0]
        if h == 'not':
            r = self.ev(f[1], env, level)
            return None if r is None else (not r)
        if h == 'and':
            a = self.ev(f[1], env, level)
            if a is False:
                return False
            b = self.ev(f[2], env, level)
            if b is False:
                return False
            return True if (a and b) else None
        if h == 'or':
            a = self.ev(f[1], env, level)
            if a is True:
                return True
            b = self.ev(f[2], env, level)
            if b is True:
                return True
            return False if (a is False and b is False) else None
        if h == 'imp':
            a = self.ev(f[1], env, level)
            if a is False:
                return True
            b = self.ev(f[2], env, level)
            if b is True:
                return True
            return False if (a is True and b is False) else None
        if h == 'iff':
            a = self.ev(f[1], env, level)
            if a is None:
                # still evaluate b for side conditions? not needed
                return None
            b = self.ev(f[2], env, level)
            if b is None:
                return None
            return a == b
        raise ValueError(h)

    def _leaf(self, g, env, level):
        """value and key of a propositional leaf: an atom, or a quantified subformula (opaque)"""
        if g[0] in BINDERS:
            return self.ev(g, env, level), ('Q', g, self.envkey(env))
        return self.atom(g, env)

    def supervaluate(self, f, env, level=0):
        """f is a propositional combination of leaves (atoms and quantified subformulas)"""
        atoms = {}      # key -> value
        order = []

        def collect(g):
            h = g[0]
            if h in ('not', 'and', 'or', 'imp', 'iff'):
                for x in g[1:]:
                    collect(x)
                return
            v, key = self._leaf(g, env, level)
            if key not in atoms:
                atoms[key] = v
                if v is None:
                    order.append(key)
        collect(f)
        if not order or len(order) > self.max_super_atoms:
            return None

        def pv(g, asg):
            h = g[0]
            if h == 'not':
                return not pv(g[1], asg)
            if h == 'and':
                return pv(g[1], asg) and pv(g[2], asg)
            if h == 'or':
                return pv(g[1], asg) or pv(g[2], asg)
            if h == 'imp':
                return (not pv(g[1], asg)) or pv(g[2], asg)
            if h == 'iff':
                return pv(g[1], asg) == pv(g[2], asg)
            key = self._leaf(g, env, level)[1]
            v = atoms[key]
            return asg[key] if v is None else v
        result = None
        n = len(order)
        for mask in range(1 << n):
            asg = {order[i]: bool(mask >> i & 1) for i in range(n)}
            r = pv(f, asg)
            if result is None:
                result = r
            elif result != r:
                return None
        return result

    @staticmethod
    def combine(isall, it):
        unknown = False
        for r in it:
            if isall and r is False:
                return False
            if (not isall) and r is True:
                return True
            if r is None:
                unknown = True
        if unknown:
            return None
        return True if isall else False

    def truth(self, sentence):
        """True / False / None for the universal closure of the sentence"""
        self.steps = 0
        self._qf = {}
        self._memo = {}
        f = strip_vacuous(close_params(sentence))
        try:
            return self.ev(f, [])
        except Budget:
            return None
        except RecursionError:
            return None


def no_v0(t, cut=0):
    h = t[0]
    if h == 'v':
        return t[1] != cut
    if h in LEAVES:
        return True
    if h in BINDERS:
        return no_v0(t[1], cut + 1)
    return all(no_v0(k, cut) for k in t[1:])


def _uses0(t, cut=0):
    h = t[0]
    if h == 'v':
        return t[1] == cut
    if h in LEAVES:
        return False
    if h in BINDERS:
        return _uses0(t[1], cut + 1)
    return any(_uses0(k, cut) for k in t[1:])


def _down(t, cut=0):
    """remove the (unused) binder at index cut: indices > cut decrease by one"""
    h = t[0]
    if h == 'v':
        return ('v', t[1] - 1) if t[1] > cut else t
    if h in LEAVES:
        return t
    if h in BINDERS:
        return (h, _down(t[1], cut + 1))
    return (h,) + tuple(_down(k, cut) for k in t[1:])


def strip_vacuous(f):
    """Qx.phi with x not free in phi  ->  phi   (sound: the domain is nonempty)"""
    h = f[0]
    if h in BINDERS:
        b = strip_vacuous(f[1])
        if not _uses0(b):
            return _down(b)
        return (h, b)
    if h in LEAVES or h in ('=', '<', 'in'):
        return f
    return (h,) + tuple(strip_vacuous(k) for k in f[1:])
