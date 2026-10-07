# refuters.py -- sound (one-sided) refutation procedures used as the "world/coherence" oracle.
# Every procedure returns True only if the formula (read under universal closure of its parameters) is FALSE in the
# intended structure (N for arithmetic, V for set theory), or logically false.  None of them is complete.
#
#  A. arithmetic world (Delta_0 evaluation + trusted logic):
#       refute_arith(s, B): instantiate parameters by numerals <= B (forall-E), then recursive refute/verify:
#       universal quantifiers refuted by a numeral counterexample <= B (forall-E), existentials verified by a witness
#       <= B, closed atoms evaluated; a universal is VERIFIED only if its quantifier-free body is valid in
#       EUF + the true closed equations of N (congruence closure; a logic derivation).
#  B. set-theory world (hereditarily finite counterexamples, sound by Delta_0 absoluteness):
#       refute_hf(s, n): parameters := elements of V_n; unbounded forall refuted by an HF counterexample; bounded
#       quantifiers (forall x (x in t -> ..), exists x (x in t & ..)) evaluated exactly over members; unbounded
#       exists verified by an HF witness.  HF is transitive, so Delta_0 facts about HF sets hold in V.
#  C. pure logic (+ designated true premises): Skolemize, ground over a depth-bounded Herbrand universe, DPLL;
#       sound by Herbrand's theorem (equality treated only by reflexivity, which is sound for unsat claims).
import itertools
from functools import lru_cache
from dtlib import kids, rebuild, BINDERS, params, shift, fbv

# ------------------------------------------------------------------ helpers: substitute a constant for v0
def subst0(body, c, j=0):
    """body under one binder; replace ('v', j) by constant c (closed), lower other free indices"""
    h = body[0]
    if h == 'v':
        if body[1] == j: return c
        if body[1] > j: return ('v', body[1] - 1)
        return body
    if h in BINDERS: return (h, subst0(body[1], c, j + 1))
    ks = kids(body)
    if not ks: return body
    return rebuild(body, [subst0(k, c, j) for k in ks])

def subst_params(t, env):
    if t[0] == 'p': return env.get(t[1], t)
    ks = kids(t)
    if not ks: return t
    return rebuild(t, [subst_params(k, env) for k in ks])

# ================================================================== A. arithmetic
def tval(t):
    h = t[0]
    if h == '0': return 0
    if h == '#': return t[1]
    if h == 'S':
        v = tval(t[1]); return None if v is None else v + 1
    if h in ('+', '*'):
        a, b = tval(t[1]), tval(t[2])
        if a is None or b is None: return None
        return a + b if h == '+' else a * b
    return None

class Arith:
    def __init__(self, B=4, W=6):
        self.B, self.W = B, W     # forall-E counterexample bound, witness bound
    def refute(self, f):
        h = f[0]
        if h == '=':
            a, b = tval(f[1]), tval(f[2])
            return a is not None and b is not None and a != b
        if h == 'bot': return True
        if h == 'top': return False
        if h == 'not': return self.verify(f[1])
        if h == 'and': return self.refute(f[1]) or self.refute(f[2])
        if h == 'or': return self.refute(f[1]) and self.refute(f[2])
        if h == 'imp': return self.refute(f[2]) and self.verify(f[1])
        if h == 'iff': return (self.verify(f[1]) and self.refute(f[2])) or (self.refute(f[1]) and self.verify(f[2]))
        if h == 'all': return any(self.refute(subst0(f[1], ('#', n))) for n in range(self.B + 1))
        if h == 'ex':
            return euf_valid(('not', f[1]))     # body false for a generic element: forall x not(body)
        return False
    def verify(self, f):
        h = f[0]
        if h == '=':
            a, b = tval(f[1]), tval(f[2])
            if a is not None and b is not None: return a == b
            return f[1] == f[2]
        if h == 'top': return True
        if h == 'bot': return False
        if h == 'not': return self.refute(f[1])
        if h == 'and': return self.verify(f[1]) and self.verify(f[2])
        if h == 'or': return self.verify(f[1]) or self.verify(f[2])
        if h == 'imp': return self.refute(f[1]) or self.verify(f[2])
        if h == 'iff': return (self.verify(f[1]) and self.verify(f[2])) or (self.refute(f[1]) and self.refute(f[2]))
        if h == 'ex': return any(self.verify(subst0(f[1], ('#', n))) for n in range(self.W + 1))
        if h == 'all': return euf_valid(f[1])
        return False

def refute_arith(s, B=3, W=6):
    ps = params(s)
    A = Arith(B, W)
    for vals in itertools.product(range(B + 1), repeat=len(ps)):
        env = {p: ('#', v) for p, v in zip(ps, vals)}
        if A.refute(subst_params(s, env)):
            return {p: v for p, v in zip(ps, vals)}
    return None

# ---- EUF + Diag(N) validity of a quantifier-free body with one free bound variable v0 (generic element g)
G = ('g',)
def to_node(t):
    h = t[0]
    if h == 'v': return G if t[1] == 0 else None
    if h in ('0', '#'): return ('#', 0 if h == '0' else t[1])
    if h in ('S', '+', '*'):
        args = [to_node(a) for a in kids(t)]
        if any(a is None for a in args): return None
        if all(a[0] == '#' for a in args):
            v = [a[1] for a in args]
            return ('#', v[0] + 1 if h == 'S' else v[0] + v[1] if h == '+' else v[0] * v[1])
        return (h,) + tuple(args)
    return None

class CC:
    def __init__(self): self.par = {}
    def add(self, n):
        if n in self.par: return
        self.par[n] = n
        if n[0] in ('S', '+', '*'):
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
            sig = {}
            for n in nodes:
                if n[0] not in ('S', '+', '*'): continue
                key = (n[0],) + tuple(self.find(a) for a in n[1:])
                if key in sig: changed |= self.union(n, sig[key])
                else: sig[key] = n
            numof = {}
            for n in list(self.par):
                if n[0] == '#': numof.setdefault(self.find(n), n[1])
            for n in nodes:
                if n[0] not in ('S', '+', '*'): continue
                vals = [numof.get(self.find(a)) for a in n[1:]]
                if all(v is not None for v in vals):
                    val = vals[0] + 1 if n[0] == 'S' else vals[0] + vals[1] if n[0] == '+' else vals[0] * vals[1]
                    m = ('#', val)
                    if m not in self.par: self.add(m)
                    changed |= self.union(n, m)
    def clash(self):
        seen = {}
        for n in self.par:
            if n[0] == '#':
                r = self.find(n)
                if r in seen and seen[r] != n[1]: return True
                seen[r] = n[1]
        return False

def sat_lits(pos, neg):
    cc = CC()
    for s, t in pos + neg: cc.add(s); cc.add(t)
    for s, t in pos: cc.union(s, t)
    cc.close()
    if cc.clash(): return False
    return all(cc.find(s) != cc.find(t) for s, t in neg)

def qf_atoms(f, acc):
    h = f[0]
    if h == '=':
        a, b = to_node(f[1]), to_node(f[2])
        if a is None or b is None: return False
        acc.add((a, b)); return True
    if h in ('top', 'bot'): return True
    if h in ('not', 'and', 'or', 'imp', 'iff'):
        return all(qf_atoms(k, acc) for k in kids(f))
    return False

def qf_eval(f, val):
    h = f[0]
    if h == '=': return val[(to_node(f[1]), to_node(f[2]))]
    if h == 'top': return True
    if h == 'bot': return False
    if h == 'not': return not qf_eval(f[1], val)
    if h == 'and': return qf_eval(f[1], val) and qf_eval(f[2], val)
    if h == 'or': return qf_eval(f[1], val) or qf_eval(f[2], val)
    if h == 'imp': return (not qf_eval(f[1], val)) or qf_eval(f[2], val)
    if h == 'iff': return qf_eval(f[1], val) == qf_eval(f[2], val)

def euf_valid(body, max_atoms=10):
    """body: quantifier-free formula whose only free bound variable is v0 (read as a generic element g);
    True iff body is true for every interpretation of g in every algebra extending N (so: forall x body is true)."""
    atoms = set()
    if not qf_atoms(body, atoms): return False
    atoms = sorted(atoms)
    if len(atoms) > max_atoms: return False
    for bits in itertools.product([False, True], repeat=len(atoms)):
        val = dict(zip(atoms, bits))
        if qf_eval(body, val): continue
        pos = [a for a, b in zip(atoms, bits) if b]
        neg = [a for a, b in zip(atoms, bits) if not b]
        if sat_lits(pos, neg): return False
    return True

# ================================================================== B. hereditarily finite sets
def hf_key(a):
    return (hf_rank(a), len(a), tuple(sorted(hf_key(x) for x in a)))

@lru_cache(maxsize=None)
def hf_rank(a):
    return 0 if not a else 1 + max(hf_rank(x) for x in a)

def Vn(n):
    cur = set()
    for _ in range(n):
        elems = sorted(cur, key=hf_key)
        cur = set(frozenset(c) for r in range(len(elems) + 1) for c in itertools.combinations(elems, r))
    return sorted(cur, key=hf_key)

def bounded(f, kind):
    """recognize forall x (x in t -> psi) / exists x (x in t & psi) with t closed (no v0)"""
    b = f[1]
    if kind == 'all' and b[0] == 'imp' and b[1][0] == 'in' and b[1][1] == ('v', 0) and 0 not in fbv(b[1][2]):
        return b[1][2], b[2]
    if kind == 'ex' and b[0] == 'and' and b[1][0] == 'in' and b[1][1] == ('v', 0) and 0 not in fbv(b[1][2]):
        return b[1][2], b[2]
    return None

class HF:
    def __init__(self, n=3):
        self.dom = Vn(n)
    def const(self, t):
        if t[0] == '#': return t[1]
        return None
    def refute(self, f):
        h = f[0]
        if h in ('in', '='):
            a, b = self.const(f[1]), self.const(f[2])
            if a is None or b is None: return False
            return (a not in b) if h == 'in' else (a != b)
        if h == 'bot': return True
        if h == 'top': return False
        if h == 'not': return self.verify(f[1])
        if h == 'and': return self.refute(f[1]) or self.refute(f[2])
        if h == 'or': return self.refute(f[1]) and self.refute(f[2])
        if h == 'imp': return self.refute(f[2]) and self.verify(f[1])
        if h == 'iff': return (self.verify(f[1]) and self.refute(f[2])) or (self.refute(f[1]) and self.verify(f[2]))
        if h == 'all':
            bd = bounded(f, 'all')
            if bd is not None:
                t = self.const(shift_down1(bd[0]))
                if t is None: return False
                return any(self.refute(subst0(bd[1], ('#', m))) for m in t)
            return any(self.refute(subst0(f[1], ('#', m))) for m in self.dom)
        if h == 'ex':
            bd = bounded(f, 'ex')
            if bd is not None:
                t = self.const(shift_down1(bd[0]))
                if t is None: return False
                return all(self.refute(subst0(bd[1], ('#', m))) for m in t)
            b = f[1]
            if b[0] == 'in' and b[1] == ('v', 0) and 0 not in fbv(b[2]):     # exists y (y in t)
                t = self.const(shift_down1(b[2]))
                return t is not None and len(t) == 0
            return False
        return False
    def verify(self, f):
        h = f[0]
        if h in ('in', '='):
            a, b = self.const(f[1]), self.const(f[2])
            if a is None or b is None: return f[0] == '=' and f[1] == f[2]
            return (a in b) if h == 'in' else (a == b)
        if h == 'top': return True
        if h == 'bot': return False
        if h == 'not': return self.refute(f[1])
        if h == 'and': return self.verify(f[1]) and self.verify(f[2])
        if h == 'or': return self.verify(f[1]) or self.verify(f[2])
        if h == 'imp': return self.refute(f[1]) or self.verify(f[2])
        if h == 'iff': return (self.verify(f[1]) and self.verify(f[2])) or (self.refute(f[1]) and self.refute(f[2]))
        if h == 'ex':
            bd = bounded(f, 'ex')
            if bd is not None:
                t = self.const(shift_down1(bd[0]))
                if t is None: return False
                return any(self.verify(subst0(bd[1], ('#', m))) for m in t)
            return any(self.verify(subst0(f[1], ('#', m))) for m in self.dom)
        if h == 'all':
            bd = bounded(f, 'all')
            if bd is not None:
                t = self.const(shift_down1(bd[0]))
                if t is None: return False
                return all(self.verify(subst0(bd[1], ('#', m))) for m in t)
            return False
        return False

def shift_down1(t):
    """t occurs under one binder but does not use it: express it outside"""
    from dtlib import shift_down
    return shift_down(t, 1)

def refute_hf(s, n=3):
    ps = params(s)
    W = HF(n)
    for vals in itertools.product(W.dom, repeat=len(ps)):
        env = {p: ('#', v) for p, v in zip(ps, vals)}
        if W.refute(subst_params(s, env)):
            return {p: sorted(v, key=hf_key) for p, v in zip(ps, vals)}
    return None

# ================================================================== C. pure logic via Herbrand + DPLL
def to_named(f, env=(), ctr=None):
    """de Bruijn -> named variables ('var', k); parameters become constants ('c', name)"""
    if ctr is None: ctr = [0]
    h = f[0]
    if h == 'v': return env[len(env) - 1 - f[1]]
    if h == 'p': return ('c', f[1])
    if h == '#': return ('c', repr(f[1]))
    if h in BINDERS:
        ctr[0] += 1
        x = ('var', ctr[0])
        return (h, x, to_named(f[1], env + (x,), ctr))
    ks = kids(f)
    if not ks: return f
    return rebuild(f, [to_named(k, env, ctr) for k in ks])

def nnf(f, pos=True):
    h = f[0]
    if h == 'not': return nnf(f[1], not pos)
    if h == 'imp': return nnf(('or', ('not', f[1]), f[2]), pos)
    if h == 'iff': return nnf(('and', ('imp', f[1], f[2]), ('imp', f[2], f[1])), pos)
    if h in ('and', 'or'):
        hh = h if pos else ('or' if h == 'and' else 'and')
        return (hh, nnf(f[1], pos), nnf(f[2], pos))
    if h in ('all', 'ex'):
        hh = h if pos else ('ex' if h == 'all' else 'all')
        return (hh, f[1], nnf(f[2], pos))
    if h == 'top': return ('top',) if pos else ('bot',)
    if h == 'bot': return ('bot',) if pos else ('top',)
    return f if pos else ('not', f)

def substv(t, x, u):
    if t == x: return u
    if t[0] in ('all', 'ex'):
        return (t[0], t[1], substv(t[2], x, u)) if t[1] != x else t
    if t[0] in ('c', 'var'): return t
    if t[0] == 'sk': return ('sk', t[1]) + tuple(substv(a, x, u) for a in t[2:])
    ks = kids(t) if t[0] not in ('c', 'var', 'sk') else ()
    if t[0] in ('=', 'in', 'not', 'and', 'or', 'S', '+', '*'):
        return (t[0],) + tuple(substv(k, x, u) for k in t[1:])
    return t

def skolem(f, univ=(), ctr=None):
    if ctr is None: ctr = [0]
    h = f[0]
    if h == 'ex':
        ctr[0] += 1
        sk = ('sk', ctr[0]) + tuple(univ)
        return skolem(substv(f[2], f[1], sk), univ, ctr)
    if h == 'all':
        return ('all', f[1], skolem(f[2], univ + (f[1],), ctr))
    if h in ('and', 'or'):
        return (h, skolem(f[1], univ, ctr), skolem(f[2], univ, ctr))
    return f

def strip_univ(f, acc):
    h = f[0]
    if h == 'all':
        acc.append(f[1]); return strip_univ(f[2], acc)
    if h in ('and', 'or'):
        return (h, strip_univ(f[1], acc), strip_univ(f[2], acc))
    return f

def consts_of(f, acc):
    if f[0] == 'c': acc.add(f); return
    if f[0] == 'sk':
        if len(f) == 2: acc.add(f)
        else: acc.add(('skf', f[1], len(f) - 2))
        for a in f[2:]: consts_of(a, acc)
        return
    if f[0] == 'var': return
    for k in f[1:]:
        if isinstance(k, tuple): consts_of(k, acc)

def ground_eval(f, val):
    """three-valued evaluation under partial assignment val (atom -> bool)"""
    h = f[0]
    if h == 'top': return True
    if h == 'bot': return False
    if h == 'not':
        v = ground_eval(f[1], val)
        return None if v is None else (not v)
    if h == 'and':
        a = ground_eval(f[1], val)
        if a is False: return False
        b = ground_eval(f[2], val)
        if b is False: return False
        return True if (a and b) else None
    if h == 'or':
        a = ground_eval(f[1], val)
        if a is True: return True
        b = ground_eval(f[2], val)
        if b is True: return True
        return False if (a is False and b is False) else None
    if h == '=' and f[1] == f[2]: return True
    return val.get(f)

def ground_atoms(f, acc):
    h = f[0]
    if h in ('=', 'in'):
        if not (h == '=' and f[1] == f[2]): acc.append(f)
        return
    if h in ('not', 'and', 'or'):
        for k in f[1:]: ground_atoms(k, acc)

class _Budget(Exception): pass
_NODES = [0, 10 ** 9]
def dpll(f, atoms, val, i=0):
    _NODES[0] += 1
    if _NODES[0] > _NODES[1]: raise _Budget()
    v = ground_eval(f, val)
    if v is True: return True
    if v is False: return False
    while i < len(atoms) and atoms[i] in val: i += 1
    if i >= len(atoms): return False
    a = atoms[i]
    for b in (True, False):
        val[a] = b
        if dpll(f, atoms, val, i + 1):
            del val[a]; return True
        del val[a]
    return False

def logic_unsat(formulas, depth=1, max_inst=300, max_terms=12, max_nodes=3000):
    """True if the conjunction of the formulas (parameters as constants) is unsatisfiable, found by grounding the
    Skolem form over Herbrand terms of depth <= depth.  Sound."""
    ctr = [0]
    clauses = []
    univs = []
    for f in formulas:
        g = skolem(nnf(to_named(f, (), ctr)), (), [len(clauses) * 1000])
        us = []
        body = strip_univ(g, us)
        clauses.append(body); univs.append(us)
    cs = set()
    for c in clauses: consts_of(c, cs)
    base = [c for c in cs if c[0] in ('c',) or (c[0] == 'sk' and len(c) == 2)]
    funs = [c for c in cs if c[0] == 'skf']
    if not base: base = [('c', '_d')]
    terms = list(base)
    for _ in range(depth):
        new = []
        for (_, k, ar) in funs:
            for args in itertools.product(terms, repeat=ar):
                new.append(('sk', k) + tuple(args))
        terms = list(dict.fromkeys(terms + new))[:max_terms]
    insts = []
    for body, us in zip(clauses, univs):
        n = 0
        for combo in itertools.product(terms, repeat=len(us)):
            g = body
            for x, t in zip(us, combo): g = substv(g, x, t)
            insts.append(g); n += 1
            if n > max_inst: break
    conj = insts[0]
    for g in insts[1:]: conj = ('and', conj, g)
    atoms = []
    ground_atoms(conj, atoms)
    atoms = list(dict.fromkeys(atoms))
    _NODES[0], _NODES[1] = 0, max_nodes
    try:
        return not dpll(conj, atoms, {})
    except _Budget:
        return False          # budget exhausted: no refutation claimed (sound)
