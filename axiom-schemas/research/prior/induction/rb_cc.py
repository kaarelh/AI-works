# Ground congruence closure over {0,S,+,*} with a fresh constant g, modulo the true closed equations of N.
# Decides whether a finite set of ground literals over N-numerals and g is satisfiable in some algebra that
# contains the standard model N as a subalgebra (i.e. consistent with the quantifier-free diagram of N).
# Classes: union-find over the subterm universe; an application node whose argument classes all contain a
# numeral is merged with the numeral of its value (this is how Diag+(N) enters).
from rb_core import *

def to_node(t):
    """normalize: closed subterms -> ('#', value); x is replaced by g before calling"""
    if t == ZERO: return ('#', 0)
    if t == ('g',): return t
    if len(t) == 1: raise ValueError('unexpected constant %s' % (t,))
    args = tuple(to_node(a) for a in t[1:])
    if all(a[0] == '#' for a in args):
        v = [a[1] for a in args]
        return ('#', v[0] + 1 if t[0] == 'S' else v[0] + v[1] if t[0] == '+' else v[0] * v[1])
    return (t[0],) + args

class CC:
    def __init__(self):
        self.par = {}
    def add(self, n):
        if n in self.par: return
        self.par[n] = n
        if n[0] != '#' and n != ('g',):
            for a in n[1:]: self.add(a)
    def find(self, n):
        while self.par[n] != n:
            self.par[n] = self.par[self.par[n]]; n = self.par[n]
        return n
    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra != rb: self.par[ra] = rb; return True
        return False
    def close(self):
        changed = True
        while changed:
            changed = False
            nodes = list(self.par)
            # congruence
            sig = {}
            for n in nodes:
                if n[0] in ('#',) or n == ('g',): continue
                key = (n[0],) + tuple(self.find(a) for a in n[1:])
                if key in sig:
                    changed |= self.union(n, sig[key])
                else: sig[key] = n
            # interpretation: numerals in argument classes
            numof = {}
            for n in list(self.par):
                if n[0] == '#': numof.setdefault(self.find(n), n[1])
            for n in nodes:
                if n[0] in ('#',) or n == ('g',): continue
                vals = [numof.get(self.find(a)) for a in n[1:]]
                if all(v is not None for v in vals):
                    val = vals[0] + 1 if n[0] == 'S' else vals[0] + vals[1] if n[0] == '+' else vals[0] * vals[1]
                    m = ('#', val)
                    if m not in self.par: self.add(m)
                    changed |= self.union(n, m)
    def numeral_clash(self):
        seen = {}
        for n in self.par:
            if n[0] == '#':
                r = self.find(n)
                if r in seen and seen[r] != n[1]: return True
                seen[r] = n[1]
        return False

def satisfiable(pos, neg):
    """pos, neg: lists of (s, t) node pairs (equalities / disequalities). Ground EUF + Diag(N)."""
    cc = CC()
    for s, t in pos + neg: cc.add(s); cc.add(t)
    for s, t in pos: cc.union(s, t)
    cc.close()
    if cc.numeral_clash(): return False
    return all(cc.find(s) != cc.find(t) for s, t in neg)

def lit(f):
    """atom or negated atom -> (positive?, (s,t)) with x already replaced by g"""
    if f[0] == '=': return True, (to_node(f[1]), to_node(f[2]))
    if f[0] == '~' and f[1][0] == '=': return False, (to_node(f[1][1]), to_node(f[1][2]))
    return None

def gsub(f):
    return sub_obj(f, X, ('g',)) if False else _gsub(f)
def _gsub(f):
    if f == X: return ('g',)
    if len(f) == 1: return f
    return (f[0],) + tuple(_gsub(a) for a in f[1:])

def step_valid_over_N(B, C):
    """is  Ax(B -> C)  true in every algebra extending N (hence FOL-derivable from Diag(N))?  B, C literals."""
    lb, lc = lit(_gsub(B)), lit(_gsub(C))
    if lb is None or lc is None: return None
    pos, neg = [], []
    (pos if lb[0] else neg).append(lb[1])
    # negate C
    (neg if lc[0] else pos).append(lc[1])
    return not satisfiable(pos, neg)
