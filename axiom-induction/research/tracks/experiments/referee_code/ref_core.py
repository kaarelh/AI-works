"""Referee: independent reimplementations of the key probability computations of the experiments track.

Written from the descriptions in the track notes (sections 1.2-1.7), not from the track's code.  Only the dtrc
parser/printer (a prior package, ../axiom-schemas/code/dtrc) is reused, to read sentences written as strings.

Contents
  q_term, q_form           the instantiation grammar Q (natural-log probabilities)
  sample_term, sample_form an independent sampler for Q
  match                    an independent DT° matcher (pattern occurrences first, then a full check)
  l0                       L0 citation coefficient
  prior_bits, theory_bits  the prior code of notes section 1.3
  dir_marg                 Dirichlet(alpha)-integrated mixture marginal by brute force over assignments, or by
                           the exact DP for <= 2 overlapping components
  l1_coef                  L1 chain coefficient for one component by brute-force backward enumeration (K <= 2)
  chain_sample             an independent forward sampler for the L1 chain
"""
import itertools
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', '..', 'axiom-schemas', 'code')))
from dtrc.syntax import parse, pp  # noqa: E402  (parser only)

NEG = float('-inf')

# ------------------------------------------------------------------------------------------------ grammar Q
TW = {'0': 0.45, 'S': 0.35, '+': 0.10, '*': 0.10}
FW = {'=': 0.35, '<': 0.20, 'not': 0.10, 'and': 0.10, 'or': 0.05, 'imp': 0.10, 'iff': 0.02, 'all': 0.05,
      'ex': 0.03}
VARW, PARW = 0.3, 0.15
ARITY = {'0': 0, 'S': 1, '+': 2, '*': 2}


class Q:
    def __init__(self, tw=None, fw=None, varw=VARW, parw=PARW):
        self.tw = dict(TW if tw is None else tw)
        self.fw = dict(FW if fw is None else fw)
        self.varw, self.parw = varw, parw

    def term_opts(self, nv, ap):
        """option -> probability at a term node with nv variables in scope"""
        o = dict(self.tw)
        if nv > 0:
            o['var'] = self.varw
        if ap:
            o['par'] = self.parw
        z = sum(o.values())
        return {k: v / z for k, v in o.items()}

    def q_term(self, t, nh, nb, ap):
        o = self.term_opts(nh + nb, ap)
        h = t[0]
        if h == 'v':
            return math.log(o['var'] / (nh + nb)) if ('var' in o and t[1] < nb) else NEG
        if h == 'h':
            return math.log(o['var'] / (nh + nb)) if ('var' in o and t[1] < nh) else NEG
        if h == 'p':
            return math.log(o['par']) if ('par' in o and t[1] == 'w0') else NEG
        if h not in o:
            return NEG
        r = math.log(o[h])
        for k in t[1:]:
            r += self.q_term(k, nh, nb, ap)
        return r

    def q_form(self, f, nh, nb, ap):
        h = f[0]
        z = sum(self.fw.values())
        if h not in self.fw:
            return NEG
        r = math.log(self.fw[h] / z)
        if h in ('=', '<'):
            return r + self.q_term(f[1], nh, nb, ap) + self.q_term(f[2], nh, nb, ap)
        if h in ('all', 'ex'):
            return r + self.q_form(f[1], nh, nb + 1, ap)
        return r + sum(self.q_form(k, nh, nb, ap) for k in f[1:])

    def sample_term(self, rng, nh, nb, ap):
        o = self.term_opts(nh + nb, ap)
        ks = sorted(o)
        x = rng.random()
        acc = 0
        for k in ks:
            acc += o[k]
            if x < acc:
                break
        if k == 'var':
            i = rng.randrange(nh + nb)
            return ('v', i) if i < nb else ('h', i - nb)
        if k == 'par':
            return ('p', 'w0')
        return (k,) + tuple(self.sample_term(rng, nh, nb, ap) for _ in range(ARITY[k]))

    def sample_form(self, rng, nh, nb, ap):
        z = sum(self.fw.values())
        ks = sorted(self.fw)
        x = rng.random() * z
        acc = 0
        for k in ks:
            acc += self.fw[k]
            if x < acc:
                break
        if k in ('=', '<'):
            return (k, self.sample_term(rng, nh, nb, ap), self.sample_term(rng, nh, nb, ap))
        if k in ('all', 'ex'):
            return (k, self.sample_form(rng, nh, nb + 1, ap))
        n = 1 if k == 'not' else 2
        return (k,) + tuple(self.sample_form(rng, nh, nb, ap) for _ in range(n))


# ------------------------------------------------------------------------------------------------ syntax
LEAF = ('0', 'v', 'p', 'h')


def ch(t):
    if t[0] in LEAF:
        return ()
    if t[0] == 'M':
        return t[2]
    return t[1:]


def has(t, pred):
    if pred(t):
        return True
    return any(has(k, pred) for k in ch(t))


def has_w0(t):
    return has(t, lambda u: u[0] == 'p')


def shift(t, d, cut=0):
    h = t[0]
    if h == 'v':
        return ('v', t[1] + d) if t[1] >= cut else t
    if h in LEAF:
        return t
    if h in ('all', 'ex'):
        return (h, shift(t[1], d, cut + 1))
    if h == 'M':
        return ('M', t[1], tuple(shift(a, d, cut) for a in t[2]))
    return (h,) + tuple(shift(k, d, cut) for k in t[1:])


def plug(body, args, depth=0):
    """replace hole h_i by args[i] (args live at the occurrence; shift under the body's own binders)"""
    h = body[0]
    if h == 'h':
        return shift(args[body[1]], depth)
    if h in LEAF:
        return body
    if h in ('all', 'ex'):
        return (h, plug(body[1], args, depth + 1))
    return (h,) + tuple(plug(k, args, depth) for k in body[1:])


def inst(T, th):
    h = T[0]
    if h == 'M':
        args = tuple(inst(a, th) for a in T[2])
        return plug(th[T[1]], args)
    if h in LEAF:
        return T
    return (h,) + tuple(inst(k, th) for k in T[1:])


def metas(T, acc=None):
    acc = {} if acc is None else acc
    if T[0] == 'M':
        acc.setdefault(T[1], len(T[2]))
    for k in ch(T):
        metas(k, acc)
    return acc


def abstract(s, argidx):
    """body for a pattern occurrence M(v_{i1}..v_{ir}) whose instance is s: free index i_j -> hole j.
    Returns None if s uses another outer bound variable."""
    pos = {i: j for j, i in enumerate(argidx)}

    def go(u, d):
        h = u[0]
        if h == 'v':
            if u[1] < d:
                return u
            k = u[1] - d
            if k in pos:
                return ('h', pos[k])
            raise ValueError
        if h in LEAF:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], d + 1))
        return (h,) + tuple(go(k, d) for k in u[1:])
    try:
        return go(s, 0)
    except ValueError:
        return None


def match(T, s):
    """the unique theta with inst(T, theta) == s, or None (DT° templates: every metavariable has an occurrence
    whose arguments are distinct bound variables)"""
    th = {}

    def collect(t, u):
        h = t[0]
        if h == 'M':
            if all(a[0] == 'v' for a in t[2]) and len(set(a[1] for a in t[2])) == len(t[2]):
                if t[1] not in th:
                    b = abstract(u, [a[1] for a in t[2]])
                    if b is None:
                        raise ValueError
                    th[t[1]] = b
            return
        if h != u[0]:
            raise ValueError
        if h in LEAF:
            if t != u:
                raise ValueError
            return
        if len(t) != len(u):
            raise ValueError
        for a, b in zip(t[1:], u[1:]):
            collect(a, b)
    try:
        collect(T, s)
    except ValueError:
        return None
    if set(th) != set(metas(T)):
        return None
    return th if inst(T, th) == s else None


def meta_is_formula(name):
    return name[0].isupper()


def l0(T, guards, s, q):
    """log a(d) for citing component T (guards: name -> 'open'/'closed', default closed)"""
    th = match(T, s)
    if th is None:
        return NEG
    r = 0.0
    for m, ar in metas(T).items():
        ap = guards.get(m, 'closed') == 'open'
        b = th[m]
        if not ap and has_w0(b):
            return NEG
        r += q.q_form(b, ar, 0, ap) if meta_is_formula(m) else q.q_term(b, ar, 0, ap)
    return r


# ------------------------------------------------------------------------------------------------ prior code
PF = {'=': 0.20, '<': 0.10, 'not': 0.10, 'and': 0.10, 'or': 0.05, 'imp': 0.10, 'iff': 0.05, 'all': 0.10,
      'ex': 0.05, 'M': 0.15}
PT = {'0': 0.30, 'S': 0.20, '+': 0.10, '*': 0.10, 'var': 0.15, 'param': 0.05, 'M': 0.10}


def prior_bits(T):
    """code length (bits) of one template, notes section 1.3, metavariables numbered by first occurrence"""
    seen = {'F': [], 'T': []}
    tot = [0.0]

    def topts(nb, allow_m):
        o = {k: v for k, v in PT.items() if (k != 'var' or nb > 0) and (k != 'M' or allow_m)}
        z = sum(o.values())
        return {k: -math.log2(v / z) for k, v in o.items()}

    def meta(t, sort, nb):
        lst = seen[sort]
        tot[0] += math.log2(len(lst) + 1)
        if t[1] not in lst:
            lst.append(t[1])
            tot[0] += len(t[2]) + 1 + 1
        for a in t[2]:
            term(a, nb, False)

    def term(t, nb, allow_m=True):
        o = topts(nb, allow_m)
        h = t[0]
        if h == 'M':
            tot[0] += o['M']
            meta(t, 'T', nb)
        elif h == 'v':
            tot[0] += o['var'] + math.log2(nb)
        elif h == 'p':
            tot[0] += o['param']
        else:
            tot[0] += o[h]
            for k in t[1:]:
                term(k, nb, allow_m)

    zf = sum(PF.values())

    def form(f, nb):
        h = f[0]
        tot[0] += -math.log2(PF['M' if h == 'M' else h] / zf)
        if h == 'M':
            meta(f, 'F', nb)
        elif h in ('=', '<'):
            term(f[1], nb)
            term(f[2], nb)
        elif h in ('all', 'ex'):
            form(f[1], nb + 1)
        else:
            for k in f[1:]:
                form(k, nb)
    form(T, 0)
    return tot[0]


def theory_bits(temps):
    m = len(temps)
    return 2 * int(math.floor(math.log2(m))) + 1 + sum(prior_bits(T) for T in temps) - math.lgamma(m + 1) / math.log(2)


# ------------------------------------------------------------------------------------------------ Dirichlet
def lse(xs):
    xs = [x for x in xs if x != NEG]
    if not xs:
        return NEG
    m = max(xs)
    return m + math.log(sum(math.exp(x - m) for x in xs))


def dir_moment(counts, alpha):
    m, n = len(counts), sum(counts)
    return (math.lgamma(m * alpha) - math.lgamma(m * alpha + n)
            + sum(math.lgamma(alpha + c) - math.lgamma(alpha) for c in counts))


def dir_marg(coefs, m, alpha=0.5):
    """log E_w prod_j sum_i w_i a_ij; coefs: list of dicts i -> log a_ij.  Exact: groups data by their
    covering set; for each distinct covering pattern the assignment sum is done by enumerating count vectors
    (multinomial over the data of that pattern), which is exact and independent of the track's DP."""
    fixed = [0] * m
    base = 0.0
    amb = []
    for c in coefs:
        if not c:
            return NEG
        if len(c) == 1:
            (i, v), = c.items()
            fixed[i] += 1
            base += v
        else:
            amb.append(c)
    if not amb:
        return base + dir_moment(fixed, alpha)
    # sum over assignments of ambiguous data: recursive over data with a dict of count vectors (exact)
    states = {tuple(fixed): base}
    for c in amb:
        new = {}
        for st, lw in states.items():
            for i, v in c.items():
                s2 = list(st)
                s2[i] += 1
                s2 = tuple(s2)
                new[s2] = lse([new.get(s2, NEG), lw + v])
        states = new
    return lse([lw + dir_moment(list(st), alpha) for st, lw in states.items()])


def dir_marg_brute(coefs, m, alpha=0.5):
    """literal sum over all assignments (tiny cases only)"""
    out = []
    for z in itertools.product(*[sorted(c) for c in coefs]):
        cnt = [0] * m
        lp = 0.0
        for j, i in enumerate(z):
            cnt[i] += 1
            lp += coefs[j][i]
        out.append(lp + dir_moment(cnt, alpha))
    return lse(out)


# ------------------------------------------------------------------------------------------------ L1 chain
def elim(s, t):
    """psi[t/x] for s = forall x psi (t closed: no bound variables)"""
    def go(u, d):
        h = u[0]
        if h == 'v':
            if u[1] == d:
                return t
            return ('v', u[1] - 1) if u[1] > d else u
        if h in LEAF:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], d + 1))
        return (h,) + tuple(go(k, d) for k in u[1:])
    return go(s[1], 0)


def gen_rule(s):
    def go(u, d):
        h = u[0]
        if h == 'p':
            return ('v', d)
        if h in LEAF:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], d + 1))
        return (h,) + tuple(go(k, d) for k in u[1:])
    return ('all', go(s, 0))


def is_mp_comp(T):
    if T[0] != 'imp':
        return False
    return set(metas(T[1])) <= set(metas(T[2]))


class Theory1:
    """a theory = list of (template, guards)"""

    def __init__(self, comps):
        self.comps = [(T, dict(g)) for T, g in comps]


def applicable(th, s):
    rs = []
    if s[0] == 'all':
        rs.append('elim')
    if has_w0(s):
        rs.append('gen')
    mps = [(T, g) for T, g in th.comps if is_mp_comp(T) and mp_match(T, g, s) is not None]
    if mps:
        rs.append('mp')
    return rs, mps


def mp_match(T, g, s):
    A = T[1]
    if not metas(A):
        return {} if A == s else None
    th = match(A, s)
    if th is None:
        return None
    for m, b in th.items():
        if g.get(m, 'closed') == 'closed' and has_w0(b):
            return None
    return th


def chain_sample(th, w, q, qe, qe_open, K, c_stop, rng, cw=None):
    """independent forward sampler of the L1 chain"""
    cw = cw or {'elim': 1.0, 'gen': 1.0, 'mp': 1.0}
    x = rng.random() * sum(w)
    i = 0
    acc = 0.0
    for i, wi in enumerate(w):
        acc += wi
        if x < acc:
            break
    T, g = th.comps[i]
    tht = {}
    for m, ar in metas(T).items():
        ap = g.get(m, 'closed') == 'open'
        tht[m] = q.sample_form(rng, ar, 0, ap) if meta_is_formula(m) else q.sample_term(rng, ar, 0, ap)
    s = inst(T, tht)
    for k in range(K):
        rs, mps = applicable(th, s)
        if not rs:
            break
        if rng.random() < c_stop:
            break
        tot = sum(cw[r] for r in rs)
        x = rng.random() * tot
        acc = 0.0
        for r in rs:
            acc += cw[r]
            if x < acc:
                break
        if r == 'elim':
            s = elim(s, qe.sample_term(rng, 0, 0, qe_open))
        elif r == 'gen':
            s = gen_rule(s)
        else:
            T2, g2 = mps[rng.randrange(len(mps))]
            th2 = dict(mp_match(T2, g2, s))
            for m, ar in metas(T2[2]).items():
                if m not in th2:
                    ap = g2.get(m, 'closed') == 'open'
                    th2[m] = q.sample_form(rng, ar, 0, ap) if meta_is_formula(m) else q.sample_term(rng, ar, 0, ap)
            s = inst(T2[2], th2)
    return s


def closed_occ(s):
    """term -> list of (path, binder depth) for terms with no bound variable (they may contain w0)"""
    out = {}

    def go(u, path, d, sort):
        if sort == 'T':
            if not has(u, lambda x: x[0] == 'v'):
                out.setdefault(u, []).append((path, d))
            for i, k in enumerate(u[1:] if u[0] not in LEAF else ()):
                go(k, path + (i,), d, 'T')
            return
        h = u[0]
        if h in ('=', '<'):
            go(u[1], path + (0,), d, 'T')
            go(u[2], path + (1,), d, 'T')
        elif h in ('all', 'ex'):
            go(u[1], path + (0,), d + 1, 'F')
        else:
            for i, k in enumerate(u[1:]):
                go(k, path + (i,), d, 'F')
    go(s, (), 0, 'F')
    return out


def put(u, path, new):
    if not path:
        return new
    ks = list(u[1:])
    ks[path[0]] = put(ks[path[0]], path[1:], new)
    return (u[0],) + tuple(ks)


def elim_preds(s, qe, qe_open, max_occ=14):
    """non-vacuous (pred, log Qe(t)) with elim(pred, t) = s"""
    out = []
    for t, occ in closed_occ(s).items():
        lt = qe.q_term(t, 0, 0, qe_open)
        if lt == NEG:
            continue
        if len(occ) > max_occ:
            raise OverflowError
        for r in range(1, len(occ) + 1):
            for S in itertools.combinations(occ, r):
                psi = s
                for path, d in S:
                    psi = put(psi, path, ('v', d))
                out.append((('all', psi), lt))
    return out


def ungen(s):
    if s[0] != 'all' or has_w0(s):
        return None

    def uses(u, d):
        if u[0] == 'v':
            return u[1] == d
        if u[0] in LEAF:
            return False
        if u[0] in ('all', 'ex'):
            return uses(u[1], d + 1)
        return any(uses(k, d) for k in u[1:])
    if not uses(s[1], 0):
        return None

    def go(u, d):
        h = u[0]
        if h == 'v':
            return ('p', 'w0') if u[1] == d else (('v', u[1] - 1) if u[1] > d else u)
        if h in LEAF:
            return u
        if h in ('all', 'ex'):
            return (h, go(u[1], d + 1))
        return (h,) + tuple(go(k, d) for k in u[1:])
    return go(s[1], 0)


def l1_coef(th, i, d, q, qe, qe_open, K, c_stop, cw=None, max_occ=14):
    """log P(datum = d | first citation = component i) under the chain, by brute-force backward enumeration:
    G_0(s) = L0 coefficient of component i; G_k(d) = sum over predecessors."""
    cw = cw or {'elim': 1.0, 'gen': 1.0, 'mp': 1.0}
    memo = {}

    def G(s, k):
        key = (s, k)
        if key in memo:
            return memo[key]
        if k == 0:
            T, g = th.comps[i]
            r = l0(T, g, s, q)
            memo[key] = r
            return r
        terms = []

        def via(pred, lx, rule):
            gp = G(pred, k - 1)
            if gp == NEG:
                return
            rs, mps = applicable(th, pred)
            if rule not in rs:
                return
            f = math.log(1 - c_stop) + math.log(cw[rule] / sum(cw[r] for r in rs)) + lx
            if rule == 'mp':
                f -= math.log(len(mps))
            terms.append(gp + f)
        for pred, lt in elim_preds(s, qe, qe_open, max_occ):
            via(pred, lt, 'elim')
        via(('all', shift(s, 1)), 0.0, 'elim')   # vacuous binder: sum_t Qe(t) = 1
        p = ungen(s)
        if p is not None:
            via(p, 0.0, 'gen')
        for T2, g2 in th.comps:
            if not is_mp_comp(T2):
                continue
            B = T2[2]
            thb = match(B, s) if metas(B) else ({} if B == s else None)
            if thb is None:
                continue
            if any(g2.get(m, 'closed') == 'closed' and has_w0(b) for m, b in thb.items()):
                continue
            lx = 0.0
            for m, ar in metas(B).items():
                if m not in metas(T2[1]):
                    ap = g2.get(m, 'closed') == 'open'
                    lx += q.q_form(thb[m], ar, 0, ap) if meta_is_formula(m) else q.q_term(thb[m], ar, 0, ap)
            pred = inst(T2[1], {m: thb[m] for m in metas(T2[1])}) if metas(T2[1]) else T2[1]
            via(pred, lx, 'mp')
        r = lse(terms)
        memo[key] = r
        return r
    out = []
    for k in range(K + 1):
        gk = G(d, k)
        if gk == NEG:
            continue
        if k == K:
            out.append(gk)
        else:
            rs, _ = applicable(th, d)
            out.append(gk + (math.log(c_stop) if rs else 0.0))
    return lse(out)
