# Referee check of Prop A2' (Q1 anchors: (R)&(D) in DT-degree; fails in SO-degree), own code.
# PA language, de Bruijn binders.  A template = data common prefix + ONE shared metavariable group G
# (positions pairwise incomparable, arguments: in-scope bound variables or closed terms 0, S0;
# arity <= 1 or 2) + fresh fully-applied metavariables elsewhere (cover anything).  As in r3, a covering
# template missing a probe exists iff such a group exists.  DT-degree: the group must contain a member
# whose arguments are pairwise distinct bound variables (a pattern occurrence); SO-degree: no condition.
import itertools, sys

Z = ('0',)
def S(t): return ('S', t)
def PL(a, b): return ('+', a, b)
def EQ(a, b): return ('=', a, b)
def AND(f, g): return ('&', f, g)
def IMP(f, g): return ('>', f, g)
def ALL(f): return ('A', f)
def ix(k): return ('#%d' % k,)
def is_ix(t): return len(t) == 1 and t[0][0] == '#'
def ixv(t): return int(t[0][1:])
X = ('x',)   # placeholder for the free variable

def plugx(phi, t, d=0):
    if phi == X: return t      # closed t: no shifting needed
    if len(phi) == 1: return phi
    if phi[0] == 'A': return ('A', plugx(phi[1], t, d + 1))
    return (phi[0],) + tuple(plugx(c, t, d) for c in phi[1:])

def at(t, p):
    for i in p: t = t[1 + i]
    return t

def depth_at(t, p):
    d = 0
    for i in p:
        if t[0] == 'A': d += 1
        t = t[1 + i]
    return d

def common_region(D):
    region, frontier = [], []
    def walk(ts, p):
        region.append(p)
        h = ts[0][0]; n = len(ts[0])
        if not all(t[0] == h and len(t) == n and (n > 1 or t == ts[0]) for t in ts):
            frontier.append(p); return
        for i in range(1, n): walk([t[i] for t in ts], p + (i - 1,))
    walk(D, ())
    return region, frontier

def shift_arg(a, e):
    return ix(ixv(a) + e) if is_ix(a) else a

def body_exists(conts, args, e=0):
    """exists beta (closed except holes) with beta[args_s] == conts[s] for all s?"""
    # option: a hole
    for m in range(len(args[0])):
        if all(conts[s] == shift_arg(args[s][m], e) for s in range(len(conts))):
            return True
    c0 = conts[0]
    if any(c[0] != c0[0] or len(c) != len(c0) for c in conts): return False
    if len(c0) == 1:
        if is_ix(c0) and ixv(c0) >= e: return False      # loose bound variable must come from a hole
        return all(c == c0 for c in conts)
    e2 = e + (1 if c0[0] == 'A' else 0)
    return all(body_exists([c[i] for c in conts], args, e2) for i in range(1, len(c0)))

def rigid_ok(D0, frontier, G, x):
    cut = set(G) | set(frontier)
    def walk(t, u, p):
        if p in cut: return True
        if t[0] != u[0] or len(t) != len(u): return False
        if len(t) == 1: return t == u
        return all(walk(t[i], u[i], p + (i - 1,)) for i in range(1, len(t)))
    return walk(D0, x, ())

def group_covers(G, args, x):
    try: conts = [at(x, p) for p in G]
    except Exception: return False
    return body_exists(conts, args)

CLOSED_ARGS = [Z, S(Z), PL(Z, Z)]
def search(D, probes, dt, AMAX=2, GMAX=3):
    D0 = D[0]
    region, frontier = common_region(D)
    for pr in probes:
        if not rigid_ok(D0, frontier, (), pr): return 'base'
    def leq(p, q): return q[:len(p)] == p
    for gs in range(1, GMAX + 1):
        for G in itertools.combinations(region, gs):
            if any(leq(a, b) or leq(b, a) for a, b in itertools.combinations(G, 2)): continue
            scopes = [[ix(k) for k in range(depth_at(D0, p))] + CLOSED_ARGS for p in G]
            for ar in range(0, AMAX + 1):
                for tups in itertools.product(*[list(itertools.product(sc, repeat=ar)) for sc in scopes]):
                    if dt and ar > 0 and not any(all(is_ix(a) for a in t) and len(set(t)) == len(t) for t in tups):
                        continue
                    if not all(group_covers(G, tups, x) for x in D): continue
                    for pr in probes:
                        if not rigid_ok(D0, frontier, G, pr) or not group_covers(G, tups, pr):
                            return (G, tups, pr)
    return None

x0 = X
PHIS = {
    'x+0=x': EQ(PL(x0, Z), x0),
    'Ay(x+y=y+x)': ALL(EQ(PL(x0, ix(0)), PL(ix(0), x0))),
    'Ay(y=x > x=y) & x=x': AND(ALL(IMP(EQ(ix(0), x0), EQ(x0, ix(0)))), EQ(x0, x0)),
    'Ay(Sy=x > y+S0=x)': ALL(IMP(EQ(S(ix(0)), x0), EQ(PL(ix(0), S(Z)), x0))),
}
TERMS = [Z, S(Z), S(S(Z)), PL(Z, Z), PL(S(Z), Z), S(PL(Z, Z))]
PROBE_TERMS = [S(S(S(Z))), PL(S(Z), S(Z)), PL(S(S(Z)), Z), Z, S(Z)]
for name, phi in PHIS.items():
    probes = [plugx(phi, t) for t in PROBE_TERMS]
    res = {'DT': [0, 0], 'SO': [0, 0]}
    ex_so = None
    for t1, t2 in itertools.combinations(TERMS, 2):
        R = t1[0] != t2[0]
        D = [plugx(phi, t1), plugx(phi, t2)]
        for cls in ('DT', 'SO'):
            cx = search(D, probes, dt=(cls == 'DT'))
            anchor = cx is None
            if cls == 'DT': res[cls][0] += (anchor == R); res[cls][1] += 1
            else:
                res[cls][0] += anchor; res[cls][1] += R
                if R and not anchor and ex_so is None: ex_so = ((t1, t2), cx[:2])
    print('%-22s DT: anchor<=>(R) on %d/%d pairs | SO: anchors %d among %d (R)-pairs; e.g. non-anchor %s'
          % (name, res['DT'][0], res['DT'][1], res['SO'][0], res['SO'][1], ex_so))
    sys.stdout.flush()
