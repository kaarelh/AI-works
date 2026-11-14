"""Terms and identities over the signature {0, S, f} (plus optional background symbols).

A term is a nested tuple:
    ("v", i)            variable number i
    ("0",)              zero
    ("S", t)            successor
    ("f", t1, ..., tk)  the function being learned (arity k)
    (h, t1, ..., tk)    any other function symbol h (auxiliary or background), where stated

An identity is a pair of terms (s, t), read as: s = t for all values of the variables.
"""
import itertools


def V(i):
    return ("v", i)


Z = ("0",)


def S(t, n=1):
    for _ in range(n):
        t = ("S", t)
    return t


def num(n):
    return S(Z, n)


def F(*args):
    return ("f",) + args


def D(t, n=1):
    """n-fold application of the symbol d (doubling, where it is used)."""
    for _ in range(n):
        t = ("d", t)
    return t


def size(t):
    """Number of symbols."""
    return 1 + sum(size(a) for a in t[1:] if isinstance(a, tuple))


def show(t):
    h = t[0]
    if h == "v":
        return "xyzuvw"[t[1]]
    if h == "0":
        return "0"
    if h == "S":
        n = 0
        while t[0] == "S":
            t, n = t[1], n + 1
        return (f"S^{n}" if n > 3 else "S" * n) + ("(" + show(t) + ")" if t[0] not in "v0" else show(t))
    return h + "(" + ",".join(show(a) for a in t[1:]) + ")"


def show_id(e):
    return show(e[0]) + " = " + show(e[1])


def tsize(theory):
    return sum(size(s) + size(t) for s, t in theory)


def variables(t, acc=None):
    acc = set() if acc is None else acc
    if t[0] == "v":
        acc.add(t[1])
    else:
        for a in t[1:]:
            variables(a, acc)
    return acc


class Stuck(Exception):
    pass


def ev(t, env, interp):
    """Value of t under the assignment env. interp maps each function symbol to a Python
    function (which may raise Stuck when a value is not available). Returns (value, radius),
    where radius is 1 + the largest argument at which f was applied (0 if f was not applied)."""
    h = t[0]
    if h == "v":
        return env[t[1]], 0
    if h == "0":
        return 0, 0
    if h == "S":
        v, r = ev(t[1], env, interp)
        return v + 1, r
    vals, rad = [], 0
    for a in t[1:]:
        v, r = ev(a, env, interp)
        vals.append(v)
        rad = max(rad, r)
    if h == "f":
        rad = max([rad] + [v + 1 for v in vals])
    return interp[h](*vals), rad


def holds(e, interp, rng):
    """Is the identity true at every assignment with values in rng? Returns a refuting
    assignment or None."""
    vs = sorted(variables(e[0]) | variables(e[1]))
    for u in itertools.product(rng, repeat=len(vs)):
        env = dict(zip(vs, u))
        if ev(e[0], env, interp)[0] != ev(e[1], env, interp)[0]:
            return env
    return None


def terms_by_size(maxsize, arity, nvars):
    """All terms over {0, S, f} of each size, with variables 0..nvars-1."""
    by = {1: [V(i) for i in range(nvars)] + [Z]}
    for s in range(2, maxsize + 1):
        cur = [("S", t) for t in by[s - 1]]
        if arity == 1:
            cur += [("f", t) for t in by[s - 1]]
        else:
            for a in range(1, s - 1):
                cur += [("f", t1, t2) for t1 in by[a] for t2 in by[s - 1 - a]]
        by[s] = cur
    return by


def forward_chain(theory, rng, background=None, max_rounds=10000):
    """Sound derivation of values of the function symbols from a set of identities.

    background maps symbols with given values (for example doubling) to Python functions; all
    other function symbols start with no known values. Each identity is instantiated with
    numerals from rng. If one side evaluates to a number using the values derived so far, and
    the other side is h(args) for a function symbol h with arguments that evaluate, the value
    of h at those arguments is derived (a valid equational inference; no cancellation of S).
    Returns (table, conflict): table maps (symbol, args) to the derived value, conflict
    describes a derived equation between two different numerals, or is None."""
    background = background or {}
    known = {}

    class Interp(dict):
        def __missing__(self, h):
            def look(*args):
                if (h, args) in known:
                    return known[(h, args)]
                raise Stuck
            return look

    interp = Interp(background)

    def try_ev(t, env):
        try:
            return ev(t, env, interp)[0]
        except Stuck:
            return None

    def head(t, env):
        if t[0] in ("v", "0", "S") or t[0] in background:
            return None
        args = []
        for a in t[1:]:
            v = try_ev(a, env)
            if v is None:
                return None
            args.append(v)
        return t[0], tuple(args)

    insts = []
    for s, t in theory:
        vs = sorted(variables(s) | variables(t))
        for u in itertools.product(rng, repeat=len(vs)):
            insts.append((s, t, dict(zip(vs, u))))
    for _ in range(max_rounds):
        changed = False
        rest = []
        for s, t, env in insts:
            a, b = try_ev(s, env), try_ev(t, env)
            if a is not None and b is not None:
                if a != b:
                    return known, f"{show_id((s, t))} at {env}: {a} != {b}"
                continue
            rest.append((s, t, env))
            for val, other in ((a, t), (b, s)):
                if val is None:
                    continue
                hd = head(other, env)
                if hd is not None:
                    known[hd] = val
                    changed = True
        insts = rest
        if not changed:
            break
    return known, None
