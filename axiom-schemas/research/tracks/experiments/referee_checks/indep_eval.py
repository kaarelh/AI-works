"""Independent evaluators written by the referee (no code shared with dtrc's oracles except the tuple syntax).

ZF: exact truth in a finite structure M = V_4 u {extras}, with HF sets interpreted standardly, extras never
elements of HF sets, arbitrary irreflexive membership into/among extras.  The dtrc ZF oracle's soundness proof
uses only: standard HF sets, irreflexive membership (its only use of Foundation), equality = identity, and the
existence of an element outside any finite set considered.  Hence every True/False verdict of the dtrc oracle
must hold in every such M (with enough extras).  A disagreement refutes the proof as written.

PA: three-valued bounded evaluator in N; definitive answers only from exact bounded quantifiers (x<t with t a
numeral), counterexamples (forall) and witnesses (exists).  Sound by construction."""

def strip_close(s):
    # universal closure of parameters, independently re-implemented
    params = []
    def collect(t):
        if t[0] == 'p':
            if t[1] not in params: params.append(t[1])
            return
        if t[0] in ('v', '0', 'h'): return
        if t[0] in ('M', 'C'): raise ValueError
        for k in t[1:]: collect(k)
    collect(s)
    n = len(params)
    def go(t, d):
        if t[0] == 'p':
            return ('v', d + n - 1 - params.index(t[1]))
        if t[0] in ('v', '0'): return t
        if t[0] in ('all', 'ex'): return (t[0], go(t[1], d + 1))
        return (t[0],) + tuple(go(k, d) for k in t[1:])
    b = go(s, 0)
    for _ in range(n): b = ('all', b)
    return b

# ------------------------------------------------------------------ ZF finite structures
def hf_level(k):
    cur = {frozenset()}
    for _ in range(k - 1):
        cur = cur | {frozenset(x) for x in powerset(sorted(cur, key=repr))}
    return cur

def powerset(xs):
    out = [[]]
    for x in xs:
        out = out + [o + [x] for o in out]
    return out

class Struct:
    def __init__(self, rng, n_extra=6, p_hf_in_extra=0.3, p_extra_in_extra=0.3):
        self.hf = sorted(hf_level(4), key=lambda s: (len(repr(s)), repr(s)))
        assert len(self.hf) == 16
        self.extras = ['e%d' % i for i in range(n_extra)]
        self.M = self.hf + self.extras
        self.rel = set()
        for e in self.extras:
            for c in self.hf:
                if rng.random() < p_hf_in_extra: self.rel.add((c, e))
            for f in self.extras:
                if f != e and rng.random() < p_extra_in_extra: self.rel.add((f, e))
    def mem(self, a, b):
        if isinstance(b, frozenset):
            return isinstance(a, frozenset) and a in b
        return (a, b) in self.rel
    def ev(self, f, env):
        h = f[0]
        if h == 'in': return self.mem(env[f[1][1]], env[f[2][1]])
        if h == '=': return env[f[1][1]] == env[f[2][1]]
        if h == 'not': return not self.ev(f[1], env)
        if h == 'and': return self.ev(f[1], env) and self.ev(f[2], env)
        if h == 'or': return self.ev(f[1], env) or self.ev(f[2], env)
        if h == 'imp': return (not self.ev(f[1], env)) or self.ev(f[2], env)
        if h == 'iff': return self.ev(f[1], env) == self.ev(f[2], env)
        if h == 'all': return all(self.ev(f[1], [x] + env) for x in self.M)
        if h == 'ex': return any(self.ev(f[1], [x] + env) for x in self.M)
        raise ValueError(h)
    def truth(self, s):
        return self.ev(strip_close(s), [])

def qdepth(f):
    if f[0] in ('v', 'p', '0', 'h'): return 0
    d = max((qdepth(k) for k in f[1:] if isinstance(k, tuple)), default=0)
    return d + (1 if f[0] in ('all', 'ex') else 0)

# ------------------------------------------------------------------ PA bounded three-valued
class PABounded:
    def __init__(self, B=12, cap=200):
        self.B, self.cap = B, cap
    def term(self, t, env):
        h = t[0]
        if h == '0': return 0
        if h == 'v': return env[t[1]]
        if h == 'S': return self.term(t[1], env) + 1
        if h == '+': return self.term(t[1], env) + self.term(t[2], env)
        if h == '*': return self.term(t[1], env) * self.term(t[2], env)
        raise ValueError(t)
    def uses0(self, t, cut=0):
        if t[0] == 'v': return t[1] == cut
        if t[0] in ('0', 'p'): return False
        if t[0] in ('all', 'ex'): return self.uses0(t[1], cut + 1)
        return any(self.uses0(k, cut) for k in t[1:])
    def ev(self, f, env):
        h = f[0]
        if h == '=': return self.term(f[1], env) == self.term(f[2], env)
        if h == '<': return self.term(f[1], env) < self.term(f[2], env)
        if h == 'not':
            r = self.ev(f[1], env); return None if r is None else not r
        if h in ('and', 'or', 'imp', 'iff'):
            a = self.ev(f[1], env); b = self.ev(f[2], env)
            if h == 'and':
                if a is False or b is False: return False
                return True if (a and b) else None
            if h == 'or':
                if a is True or b is True: return True
                return False if (a is False and b is False) else None
            if h == 'imp':
                if a is False or b is True: return True
                return False if (a is True and b is False) else None
            if a is None or b is None: return None
            return a == b
        if h in ('all', 'ex'):
            body = f[1]
            isall = h == 'all'
            if not self.uses0(body):
                return self.ev(body, [0] + env)   # vacuous
            conn = 'imp' if isall else 'and'
            # exact bounded form  x < t  (t not mentioning x)
            if body[0] == conn and body[1][0] == '<' and body[1][1] == ('v', 0) and not self.uses0(body[1][2]):
                n = self.term(body[1][2], [0] + env)
                if n <= self.cap:
                    vals = [self.ev(body[2], [x] + env) for x in range(n)]
                    if isall:
                        if False in vals: return False
                        return True if all(v is True for v in vals) else None
                    if True in vals: return True
                    return False if all(v is False for v in vals) else None
            unknown = False
            for x in range(self.B):
                r = self.ev(body, [x] + env)
                if isall and r is False: return False
                if (not isall) and r is True: return True
            return None
        raise ValueError(h)
    def truth(self, s):
        return self.ev(strip_close(s), [])
