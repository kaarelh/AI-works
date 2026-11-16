#!/usr/bin/env python3
"""
Attack on Theorem 5.1 (R1), Lemma 4.3, Proposition 5.2 and Proposition 9.1 of
research/prove-c/rehearsal-core.md by exact enumeration of Protocol R on random
small instances, followed by a local search that tries to push each ratio above 1.

Instance:
  X = {0..nx-1}, Y = {0..ny-1}, the extra answer index ny stands for "no answer".
  Scaffold: z in {0..nz-1} with law D0, no internal randomness; next_j is a random
            table of (z, y_1..y_{j-1}) with values in X or STOP; horizon L; the
            answers seen by the scaffold include "no answer".
  Class:    nh hypotheses nu[h][x][y], y < ny, rows of sum <= 1 (semimeasures allowed),
            weights w with W = sum w <= 1.  The human is hypothesis 0 (a sampler).
Protocol R (Definition 5.0) is enumerated exactly: the state after t rounds is the
multiset of recorded pairs; all runs of the mixture are enumerated.

Checked for every instance (all exact up to floating point):
  (A) sum_t E Lambda(M^(t)) <= L ln(W/w(P))                       [5.1(a)]
  (B) sum_t E chi(M^(t))    <= (L/2) ln(W/w(P))                   [5.1(b)]
  (C) function human: sum_t E beta(M^(t)) <= L ln(W/w(f)), and on every path
      sum_{asked t} e_t <= ln(W/w(f))                             [5.1(c), 4.2]
  (D) E beta(M^(T)) <= sqrt(lbar L ln(W/w(P))/(2n))               [9.1(a)]
  (E) tail bounds of Lemma 4.3 / Proposition 5.2(b): for every threshold v,
      function human:  Pr[ sum_t beta(M^(t))/L > ln(W/w) + v ] <= exp(-v)
      any human:       Pr[ sum_t chi(M^(t))/L  > ln(W/w)/2 + v ] <= exp(-v)
The script prints the largest value of (left side)/(right side) found.
"""
import math, random, sys, itertools
from collections import defaultdict

STOP = -1

def rand_row(rng, ny, kind):
    """a row nu(.|x) on Y (index ny = missing mass is implicit)."""
    if kind == 'det':
        r = [0.0]*ny; r[rng.randrange(ny)] = 1.0; return r
    if kind == 'sparse':
        r = [0.0]*ny
        a, b = rng.sample(range(ny), 2) if ny >= 2 else (0, 0)
        p = rng.choice([0.01, 0.1, 0.3, 0.5, 0.9, 0.99])
        r[a] += p; r[b] += 1-p; return r
    if kind == 'semi':
        r = [rng.random() for _ in range(ny)]
        s = sum(r); deficit = rng.choice([0.0, 0.2, 0.6, 0.95])
        return [v/s*(1-deficit) for v in r]
    r = [rng.gammavariate(rng.choice([0.2, 1.0]), 1.0)+1e-12 for _ in range(ny)]
    s = sum(r); return [v/s for v in r]

def make_instance(rng, nx, ny, L, nz, nh, human, allow_semi=True):
    D0 = [rng.gammavariate(1.0, 1.0)+1e-9 for _ in range(nz)]
    s = sum(D0); D0 = [v/s for v in D0]
    nxt = {}
    pstop = rng.choice([0.0, 0.15, 0.4])
    for z in range(nz):
        for j in range(1, L+1):
            for hist in itertools.product(range(ny+1), repeat=j-1):
                if j > 1 and rng.random() < pstop:
                    nxt[(z, hist)] = STOP
                else:
                    nxt[(z, hist)] = rng.randrange(nx)
    hyps = []
    # the human
    if human == 'det':
        hyps.append([rand_row(rng, ny, 'det') for _ in range(nx)])
    else:
        hyps.append([rand_row(rng, ny, rng.choice(['dense', 'sparse', 'det'])) for _ in range(nx)])
    for h in range(1, nh):
        style = rng.choice(['det', 'mixed', 'near', 'semi'] if allow_semi else ['det', 'mixed', 'near'])
        rows = []
        for x in range(nx):
            if style == 'det':
                rows.append(rand_row(rng, ny, 'det'))
            elif style == 'near':
                # the human except at a few inputs
                rows.append(list(hyps[0][x]) if rng.random() < 0.6 else rand_row(rng, ny, rng.choice(['det', 'sparse'])))
            elif style == 'semi':
                rows.append(rand_row(rng, ny, 'semi'))
            else:
                rows.append(rand_row(rng, ny, rng.choice(['det', 'sparse', 'dense'])))
        hyps.append(rows)
    w = [rng.gammavariate(rng.choice([0.3, 1.0]), 1.0)+1e-6 for _ in range(nh)]
    if rng.random() < 0.5:
        w[0] *= rng.choice([1e-3, 1e-2, 1e-1])
    s = sum(w); W = rng.choice([1.0, 1.0, 0.7, 0.3])
    w = [v/s*W for v in w]
    return dict(nx=nx, ny=ny, L=L, nz=nz, nh=nh, D0=D0, nxt=nxt, hyps=hyps, w=w)

def mixture(inst, counts):
    """posterior weights and mixture kernel M[x][y], y <= ny (last = no answer)."""
    nx, ny, nh = inst['nx'], inst['ny'], inst['nh']
    lik = []
    for h in range(nh):
        l = inst['w'][h]
        for (x, y), c in counts:
            v = inst['hyps'][h][x][y]
            if v <= 0.0:
                l = 0.0; break
            l *= v**c
        lik.append(l)
    xi = sum(lik)
    post = [l/xi for l in lik]
    M = []
    for x in range(nx):
        row = [sum(post[h]*inst['hyps'][h][x][y] for h in range(nh)) for y in range(ny)]
        row.append(max(0.0, 1.0-sum(row)))
        M.append(row)
    return post, M

def divergences(inst, M):
    """per input: KL(P||M), TV(P,M), H2(P,M)."""
    nx, ny = inst['nx'], inst['ny']
    P = inst['hyps'][0]
    KL, TV, H2 = [], [], []
    for x in range(nx):
        kl = 0.0; tv = 0.0; bc = 0.0
        for y in range(ny):
            p = P[x][y]; q = M[x][y]
            if p > 0:
                kl += p*math.log(p/q)
            tv += abs(p-q); bc += math.sqrt(p*q)
        tv += M[x][ny]
        KL.append(kl); TV.append(tv/2); H2.append(1.0-bc)
    return KL, TV, H2

def run_functionals(inst, C, KL, TV, H2):
    """E over a run of the kernel C of sum_j KL, TV, H2; E len; law of the asked input."""
    nx, ny, L = inst['nx'], inst['ny'], inst['L']
    lam = bet = chi = elen = 0.0
    q = [0.0]*nx
    for z, pz in enumerate(inst['D0']):
        stack = [((), pz)]
        while stack:
            hist, pr = stack.pop()
            j = len(hist)+1
            if j > L:
                continue
            x = inst['nxt'][(z, hist)]
            if x == STOP:
                continue
            lam += pr*KL[x]; bet += pr*TV[x]; chi += pr*H2[x]; elen += pr
            q[x] += pr/L
            for y in range(ny+1):
                if C[x][y] > 0:
                    stack.append((hist+(y,), pr*C[x][y]))
    return lam, bet, chi, elen, q

def protocol_R(inst, n, track_tail=True):
    """exact enumeration. Returns sums and tail data."""
    nx, ny, L = inst['nx'], inst['ny'], inst['L']
    P = inst['hyps'][0]
    det = all(max(P[x]) == 1.0 for x in range(nx))
    # state: frozenset-like sorted tuple of ((x,y),count); value: dict {(Vbeta, Vchi, Ve): prob}
    states = {(): {(0.0, 0.0, 0.0): 1.0}}
    sum_lam = sum_bet = sum_chi = sum_len = 0.0
    lam_t = []; bet_t = []
    for t in range(1, n+2):
        new_states = defaultdict(lambda: defaultdict(float))
        E_lam = E_bet = E_chi = E_len = 0.0
        for counts, vd in states.items():
            pstate = sum(vd.values())
            post, M = mixture(inst, counts)
            KL, TV, H2 = divergences(inst, M)
            lam, bet, chi, elen, q = run_functionals(inst, M, KL, TV, H2)
            E_lam += pstate*lam; E_bet += pstate*bet; E_chi += pstate*chi; E_len += pstate*elen
            if t == n+1:
                continue
            asked = sum(q)
            cd = dict(counts)
            for (vb, vc, ve), pr in vd.items():
                vb2 = vb+bet/L; vc2 = vc+chi/L
                if asked < 1.0:
                    new_states[counts][(vb2, vc2, ve)] += pr*(1.0-asked)
                for x in range(nx):
                    if q[x] <= 0: continue
                    for y in range(ny):
                        if P[x][y] <= 0: continue
                        c2 = dict(cd); c2[(x, y)] = c2.get((x, y), 0)+1
                        key = tuple(sorted(c2.items()))
                        e = 1.0-M[x][y] if det else 0.0
                        new_states[key][(vb2, vc2, ve+e)] += pr*q[x]*P[x][y]
        lam_t.append(E_lam); bet_t.append(E_bet)
        if t <= n:
            sum_lam += E_lam; sum_bet += E_bet; sum_chi += E_chi; sum_len += E_len
            if not track_tail:
                # merge the tail coordinates to keep the state space small
                merged = {}
                for k, vd in new_states.items():
                    merged[k] = {(0.0, 0.0, 0.0): sum(vd.values())}
                states = merged
            else:
                states = {k: dict(v) for k, v in new_states.items()}
            final = states
    return dict(sum_lam=sum_lam, sum_bet=sum_bet, sum_chi=sum_chi, lbar=sum_len/n,
                last_lam=lam_t[-1], last_bet=bet_t[-1], det=det, final=final)

def ratios(inst, n, track_tail=True):
    L = inst['L']; W = sum(inst['w']); c = math.log(W/inst['w'][0])
    if c < 1e-6:
        # ln(W/w(P)) below 1e-6 is lost in floating-point rounding (a first version of the
        # search "found" ratios above 1 there: w(other)/w(P) of order 1e-16); such instances are skipped
        raise ValueError("ln(W/w(P)) too small for floating point")
    r = protocol_R(inst, n, track_tail)
    out = {}
    out['A'] = r['sum_lam']/(L*c)
    out['B'] = r['sum_chi']/(L*c/2)
    out['D'] = (r['sum_bet']/n)/math.sqrt(r['lbar']*L*c/(2*n)) if r['lbar'] > 0 else 0.0
    if r['det']:
        out['C'] = r['sum_bet']/(L*c)
    if track_tail:
        # tail checks: collect the law of V over all final states
        vb = defaultdict(float); vc = defaultdict(float); vemax = 0.0
        for k, vd in r['final'].items():
            for (b, ch, e), pr in vd.items():
                vb[b] += pr; vc[ch] += pr
                if pr > 0: vemax = max(vemax, e)
        def tail_ratio(dist, base):
            items = sorted(dist.items()); tot = 0.0; worst = 0.0
            # Pr[V >= v] * exp(v - base) for v at the atoms (>= is at least as strong as >)
            for v, pr in reversed(items):
                tot += pr
                if v > base:
                    worst = max(worst, tot*math.exp(v-base))
            return worst
        if r['det']:
            out['E_fn'] = tail_ratio(vb, c)
            out['C_path'] = vemax/c
        out['E_any'] = tail_ratio(vc, c/2)
    out['last_over_bound_lam'] = r['last_lam']/(L*c/n)
    return out

def perturb(rng, inst, scale):
    import copy
    I = copy.deepcopy(inst)
    nh, nx, ny = I['nh'], I['nx'], I['ny']
    # weights
    for h in range(nh):
        I['w'][h] *= math.exp(scale*rng.gauss(0, 1))
    s = sum(I['w'])
    if s > 1.0:
        I['w'] = [v/s for v in I['w']]
    # D0
    D0 = [v*math.exp(scale*rng.gauss(0, 1)) for v in I['D0']]
    s = sum(D0); I['D0'] = [v/s for v in D0]
    # kernels of the non-human hypotheses (and of a stochastic human)
    for h in range(nh):
        for x in range(nx):
            row = I['hyps'][h][x]
            if h == 0 and max(row) == 1.0:
                continue
            if rng.random() < 0.3:
                tot = sum(row)
                r2 = [max(1e-12, v*math.exp(scale*rng.gauss(0, 1))) if v > 0 else (1e-3 if rng.random() < 0.05 else 0.0) for v in row]
                s2 = sum(r2)
                if h == 0:
                    r2 = [v/s2 for v in r2]
                elif s2 > 1.0:
                    r2 = [v/s2 for v in r2]
                I['hyps'][h][x] = r2
    return I

def main():
    rng = random.Random(20261115)
    worst = defaultdict(float); worst_desc = {}
    n_inst = 0
    configs = []
    for human in ['det', 'stoch']:
        for (nx, ny, L, nz, nh, n) in [(3, 2, 2, 2, 3, 5), (4, 2, 2, 2, 5, 4), (3, 2, 3, 2, 4, 4), (4, 3, 2, 1, 4, 3), (3, 2, 3, 1, 6, 4), (2, 2, 2, 1, 2, 6)]:
            configs.append((human, nx, ny, L, nz, nh, n))
    per_config = 150
    for (human, nx, ny, L, nz, nh, n) in configs:
        for _ in range(per_config):
            inst = make_instance(rng, nx, ny, L, nz, nh, human)
            try:
                out = ratios(inst, n)
            except (ZeroDivisionError, ValueError):
                continue
            n_inst += 1
            for k, v in out.items():
                if v > worst[k]:
                    worst[k] = v; worst_desc[k] = (human, nx, ny, L, nz, nh, n)
    print(f"random instances evaluated: {n_inst}")
    for k in ['A', 'B', 'C', 'C_path', 'D', 'E_fn', 'E_any']:
        print(f"  largest ratio {k}: {worst[k]:.6f}   (config {worst_desc.get(k)})")
    print(f"  (for information) largest E Lambda(M^(n+1)) / (L ln(W/w)/n) seen: {worst['last_over_bound_lam']:.3f}")

    # local search: try to push A, C, D above 1
    print("local search (random perturbations, accept if the ratio grows):")
    for target, human in [('A', 'stoch'), ('A', 'det'), ('C', 'det'), ('D', 'stoch'), ('B', 'stoch')]:
        best_overall = 0.0
        for restart in range(6):
            nx, ny, L, nz, nh, n = rng.choice([(3, 2, 2, 2, 3, 4), (2, 2, 2, 1, 2, 4), (3, 2, 3, 1, 3, 3)])
            inst = make_instance(rng, nx, ny, L, nz, nh, human)
            try:
                cur = ratios(inst, n, track_tail=False).get(target, 0.0)
            except (ZeroDivisionError, ValueError):
                continue
            for it in range(250):
                cand = perturb(rng, inst, rng.choice([0.05, 0.3, 1.0]))
                try:
                    val = ratios(cand, n, track_tail=False).get(target, 0.0)
                except (ZeroDivisionError, ValueError, OverflowError):
                    continue
                if val > cur:
                    cur = val; inst = cand
            best_overall = max(best_overall, cur)
        print(f"  target {target}, human {human}: best ratio reached {best_overall:.6f}")
    print("A ratio above 1 (beyond rounding) in any line would be a counterexample.")

if __name__ == '__main__':
    main()
