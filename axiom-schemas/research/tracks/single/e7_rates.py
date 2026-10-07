# e7: sample complexity (Theorem E).  For a target T* and a finite law Lambda over substitutions,
# compute the witness-event parameters rho_q, nu_{M,m}, kappa_{sigma,r} EXACTLY (over the pool) and
# compare  P[D_N is not an anchor]  (Monte Carlo, 2000 runs per N, anchor status by the theorem's
# events (R*)&(N)&(U°), which e4/e5 validate)  with the bound
#     sum_q (1-rho_q)^(N-1) + sum_{M,m} (1-nu)^N + sum_{(sigma,r)} (1-kappa)^floor(N/2).
import sys, random, math, itertools
from dtcore import *
from dtfeat import Prefix
from dtwitness import events, skeleton_positions

rng = random.Random(2024)


def upairs(T):
    occ = occurrences(T)
    occd = {o[0]: o for o in occ}
    pos = skeleton_positions(T)
    out = []
    for (sp, nm, args, d) in occ:
        for r, (t, dr, sr) in pos.items():
            if r == sp or comparable(r, sp) or sr != msort(nm):
                continue
            valid = False
            if r in occd and occd[r][1] == nm:
                um = {}
                valid = all(Prefix.align(a, b, um) for a, b in zip(args, occd[r][2]))
            if not valid:
                out.append((sp, r))
    return out


def params(T, pool, w):
    """exact witness parameters for the law w over pool (list of substitutions)"""
    data = [instantiate(T, th) for th in pool]
    occ = occurrences(T)
    res = {'rho': [], 'nu': [], 'kappa': []}
    for (p, nm, args, d) in occ:
        dist = {}
        for s, wi in zip(data, w):
            k = node_key(sub(s, p))
            dist[k] = dist.get(k, 0) + wi
        res['rho'].append(1 - max(dist.values()))
    ars = {o[1]: len(o[2]) for o in occ}
    for nm, n in ars.items():
        for m in range(n):
            res['nu'].append(sum(wi for th, wi in zip(pool, w) if m in holes(th[nm])))
    for (sp, r) in upairs(T):
        kap = 0.0
        for (a, wa), (b, wb) in itertools.product(list(zip(data, w)), repeat=2):
            um = {}
            if not (Prefix.align(sub(a, sp), sub(a, r), um) and Prefix.align(sub(b, sp), sub(b, r), um)):
                kap += wa * wb
        res['kappa'].append(kap)
    return res


def bound(res, N):
    b = sum((1 - r) ** (N - 1) for r in res['rho'])
    b += sum((1 - v) ** N for v in res['nu'])
    b += sum((1 - k) ** (N // 2) for k in res['kappa'])
    return b


def mc(T, pool, w, N, runs=2000):
    bad = 0
    for _ in range(runs):
        ths = rng.choices(pool, weights=w, k=N)
        ev, D = events(T, ths)
        if not ev['pred']:
            bad += 1
    return bad / runs


X, Y = H(0), H(1)
cases = []
# (1) induction, motives from a small pool (closed and open, several roots)
ind_pool = [{'P': m} for m in [eq(X, X), eq(X, Z), eq(Z, Z), NOT(eq(X, Z)), NOT(eq(Z, S(Z))),
                               eq(add(X, Z), X), ALL(eq(V(0), X)), AND(eq(X, X), eq(Z, Z))]]
ind_w = [0.3, 0.25, 0.1, 0.1, 0.05, 0.1, 0.05, 0.05]
cases.append(('Induction', T_IND, ind_pool, ind_w))
# (2) the counterexample template of Prop. D4 (term metavariable of arity 2)
Tu = AND(ALL(ALL(eq(S(M('f', V(1), V(0))), Z))), ALL(ALL(eq(M('f', V(1), S(V(0))), Z))))
u_pool = [{'f': b} for b in [X, Y, S(X), S(Y), Z, add(X, Y), S(Z), PA]]
u_w = [0.3, 0.2, 0.2, 0.1, 0.05, 0.05, 0.05, 0.05]
cases.append(('Prop D4 template', Tu, u_pool, u_w))
# (3) Separation
sep_pool = [{'P': b} for b in [mem(X, PA), mem(X, Y), NOT(mem(X, X)), eq(X, PA), mem(PA, PB),
                               EX(AND(mem(V(0), X), mem(V(0), Y))), OR(mem(X, PA), mem(X, PB))]]
sep_w = [0.3, 0.05, 0.15, 0.2, 0.1, 0.1, 0.1]
cases.append(('Separation', T_SEP, sep_pool, sep_w))

if __name__ == "__main__":
  for name, T, pool, w in cases:
      res = params(T, pool, w)
      print('==', name, '  T* =', pp(T))
      print('   rho_q =', ['%.3f' % x for x in res['rho']])
      print('   nu    =', ['%.3f' % x for x in res['nu']])
      print('   #U-pairs = %d, kappa min = %s, #kappa<1: %d' % (
          len(res['kappa']), ('%.3f' % min(res['kappa'])) if res['kappa'] else '-',
          sum(1 for k in res['kappa'] if k < 1)))
      print('   N   MC P[not anchor]   bound')
      for N in [2, 3, 4, 6, 8, 12, 16, 24]:
          print('   %2d   %.4f            %.4f' % (N, mc(T, pool, w, N), bound(res, N)))
