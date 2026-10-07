# Diagnostic for r3_anchor (A): how many covering metavariable groups the search actually visits on anchor
# pairs, how many of them use repeated arguments or parameter arguments, and that every one covers all
# probes (so the "no counterexample" verdict is not vacuous).  Also prints one found counterexample for a
# non-anchor pair of each kind.
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/cases/referee_code')
from zf_lib import *
from r3_anchor import *

def all_covering_groups(D, AMAX, GMAX, params=('a', 'b')):
    D0 = D[0]
    region, frontier = common_region(D)
    def sig(p): return tuple(skeleton(at(x, p)) for x in D)
    by = {}
    for p in region: by.setdefault(sig(p), []).append(p)
    def leq(p, q): return q[:len(p)] == p
    out = []
    for sg, plist in by.items():
        for gs in range(1, GMAX + 1):
            for G in itertools.combinations(plist, gs):
                if any(leq(a, b) or leq(b, a) for a, b in itertools.combinations(G, 2)): continue
                scopes = [list(range(depth_at(D0, p))) + list(params) for p in G]
                is_term = len(at(D0, G[0])) == 1
                for ar in range(0, (1 if is_term else AMAX) + 1):
                    for tups in itertools.product(*[list(itertools.product(sc, repeat=ar)) for sc in scopes]):
                        if all(group_covers(list(G), list(tups), x) for x in D):
                            out.append((G, tups))
    return out

h = hole
for sc, bodies, AMAX, GMAX in (('Sep', [('in', h(0), h(1)), ('neg', ('eq', h(0), par('a')))], 3, 2),
                               ('EInd', [('in', h(0), h(0)), ('neg', ('eq', h(0), h(0)))], 3, 3),
                               ('ReplJ', [('in', h(0), h(1)), ('neg', ('eq', h(0), par('a')))], 2, 3)):
    D = [to_db(instance(sc, b)) for b in bodies]
    probes = probes_for(sc)
    gs = all_covering_groups(D, AMAX, GMAX)
    rep = sum(1 for G, t in gs if any(len(set(x)) < len(x) for x in t))
    prm = sum(1 for G, t in gs if any(isinstance(a, str) for x in t for a in x))
    multi = sum(1 for G, t in gs if len(G) >= 2)
    region, frontier = common_region(D)
    allprobe = all(rigid_matches(D[0], region, frontier, list(G), pr) and group_covers(list(G), list(t), pr)
                   for G, t in gs for pr in probes)
    print('%-6s anchor pair %s: covering groups %d (shared by >=2 positions %d, with repeated args %d, with parameter args %d); all cover every probe: %s'
          % (sc, [b[0] for b in bodies], len(gs), multi, rep, prm, allprobe))

print()
for sc, bodies in (('Coll', [('eq', h(1), h(0)), ('neg', ('in', h(0), h(1)))]),      # N_A fails
                   ('ReplJ', [('in', h(0), par('a')), ('neg', ('eq', h(0), par('a')))]),  # N_y fails
                   ('EInd', [('in', h(0), h(0)), ('in', h(0), par('a'))])):           # R fails
    D = [to_db(instance(sc, b)) for b in bodies]
    cx = search_counterexample(D, probes_for(sc), 3, 3)
    print('%-6s non-anchor %s -> counterexample group/args: %s' % (sc, bodies, cx[:2] if cx and cx[0] != 'base' else cx[0] if cx else None))
