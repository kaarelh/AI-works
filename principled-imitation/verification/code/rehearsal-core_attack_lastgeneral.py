#!/usr/bin/env python3
"""
Attack on the upper bounds for the last round, Propositions 6.1 and 6.4 of
research/prove-c/rehearsal-core.md, by exact enumeration of Protocol R on random small
instances and a local search over the weights, the hypotheses and the law of the
top-level input.  (Generator and enumeration primitives: rehearsal-core_attack_r1.py.)

Part 1 (6.1(a)).  Scaffold whose inputs do not depend on the answers, deterministic human:
        E beta(M^(n+1)) <= L (ln(W/w(f)) + 1)/n.
        Also reported: the largest E beta(M^(n+1)) / (L ln(W/w(f))/n) found (is the "+1" needed?).
Part 2 (6.1(b)).  Same scaffolds, any human:  E chi(M^(n+1)) <= L (ln(1/w(P))/2 + ln S + 1)/n,
        S = sum of the square roots of the weights.
Part 3 (6.4).     Any scaffold, deterministic human, B0 = L ln(W/w(f))/n < 1/2:
        E u(M^(n+1)) <= 2 L B0 (1 + ln(1/(2 B0))) + 2 B0 + 2 L/n.
        Exploration of the question the file leaves open: how large can
        E u(M^(n+1)) / B0 and E beta(M^(n+1)) / B0 be made on small instances?
"""
import math, random, importlib.util, os, itertools
from collections import defaultdict

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("atk_r1", os.path.join(here, "rehearsal-core_attack_r1.py"))
R1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(R1)
STOP = -1

def make_nonadaptive(rng, inst):
    L, nz, ny = inst['L'], inst['nz'], inst['ny']
    for z in range(nz):
        length = rng.choice([L, L, max(1, L-1)])
        xs = [rng.randrange(inst['nx']) for _ in range(L)]
        for j in range(1, L+1):
            for hist in itertools.product(range(ny+1), repeat=j-1):
                inst['nxt'][(z, hist)] = xs[j-1] if j <= length else STOP
    return inst

def u_of(inst, M, f):
    """probability that a run of the kernel M is not the run of the human system (function f)."""
    L = inst['L']; u = 0.0
    for z, pz in enumerate(inst['D0']):
        hist = (); prod = 1.0
        for j in range(1, L+1):
            x = inst['nxt'][(z, hist)]
            if x == STOP: break
            prod *= M[x][f[x]]
            hist = hist+(f[x],)
        u += pz*(1.0-prod)
    return u

def evaluate(inst, n):
    nx, ny, L = inst['nx'], inst['ny'], inst['L']
    P = inst['hyps'][0]
    det = all(max(P[x]) == 1.0 for x in range(nx))
    f = [max(range(ny), key=lambda y: P[x][y]) for x in range(nx)] if det else None
    states = {(): 1.0}
    res = dict(sum_beta=0.0, sum_u=0.0, sum_lam=0.0)
    for t in range(1, n+2):
        new = defaultdict(float)
        E = dict(lam=0.0, beta=0.0, chi=0.0, u=0.0)
        for key, pr in states.items():
            post, M = R1.mixture(inst, key)
            KL, TV, H2 = R1.divergences(inst, M)
            lam, bet, chi, elen, q = R1.run_functionals(inst, M, KL, TV, H2)
            E['lam'] += pr*lam; E['beta'] += pr*bet; E['chi'] += pr*chi
            if det: E['u'] += pr*u_of(inst, M, f)
            if t == n+1: continue
            asked = sum(q)
            if asked < 1.0: new[key] += pr*(1.0-asked)
            d = dict(key)
            for x in range(nx):
                if q[x] <= 0: continue
                for y in range(ny):
                    if P[x][y] <= 0: continue
                    d2 = dict(d); d2[(x, y)] = d2.get((x, y), 0)+1
                    new[tuple(sorted(d2.items()))] += pr*q[x]*P[x][y]
        if t <= n:
            res['sum_beta'] += E['beta']; res['sum_u'] += E['u']; res['sum_lam'] += E['lam']
            states = dict(new)
        else:
            res['last'] = E
    res['det'] = det
    return res

def consts(inst):
    W = sum(inst['w']); c = math.log(W/inst['w'][0])
    if c < 1e-6: raise ValueError
    return W, c

def main():
    rng = random.Random(6104)
    # ---------------- Part 1
    worst1 = 0.0; worst1b = 0.0; cnt = 0
    def r_part1(inst, n):
        W, c = consts(inst); L = inst['L']
        r = evaluate(inst, n)
        return r['last']['beta']/(L*(c+1)/n), r['last']['beta']/(L*c/n)
    for it in range(200):
        nx, ny, L, nz, nh = rng.choice([(3, 2, 2, 2, 4), (4, 2, 1, 4, 5), (4, 2, 3, 2, 6), (3, 2, 1, 3, 8)])
        n = rng.choice([4, 8, 12])
        inst = make_nonadaptive(rng, R1.make_instance(rng, nx, ny, L, nz, nh, 'det'))
        try: a, b = r_part1(inst, n)
        except (ValueError, ZeroDivisionError): continue
        cnt += 1; worst1 = max(worst1, a); worst1b = max(worst1b, b)
    # local search
    for restart in range(5):
        nx, ny, L, nz, nh = rng.choice([(3, 2, 1, 3, 4), (3, 2, 2, 2, 5)])
        n = rng.choice([8, 12])
        inst = make_nonadaptive(rng, R1.make_instance(rng, nx, ny, L, nz, nh, 'det'))
        try: cur = r_part1(inst, n)
        except (ValueError, ZeroDivisionError): continue
        for step in range(150):
            cand = R1.perturb(rng, inst, rng.choice([0.05, 0.3, 1.0]))
            try: v = r_part1(cand, n)
            except (ValueError, ZeroDivisionError, OverflowError): continue
            if v[1] > cur[1]: cur = v; inst = cand
        worst1 = max(worst1, cur[0]); worst1b = max(worst1b, cur[1])
    print("== Part 1: Proposition 6.1(a) (inputs do not depend on the answers, deterministic human) ==")
    print(f"{cnt} random instances and a local search:")
    print(f"  largest E beta(M^(n+1)) / (L (ln(W/w(f)) + 1)/n) = {worst1:.4f}   (claim: <= 1)")
    print(f"  largest E beta(M^(n+1)) / (L  ln(W/w(f))/n)      = {worst1b:.4f}   (above 1 would show that the '+1' is needed)")
    # ---------------- Part 2
    worst2 = 0.0; cnt = 0
    for it in range(400):
        nx, ny, L, nz, nh = rng.choice([(3, 2, 2, 2, 3), (3, 2, 1, 3, 4), (2, 3, 2, 1, 3)])
        n = rng.choice([3, 4, 5])
        inst = make_nonadaptive(rng, R1.make_instance(rng, nx, ny, L, nz, nh, 'stoch'))
        try:
            W, c = consts(inst)
            r = evaluate(inst, n)
        except (ValueError, ZeroDivisionError): continue
        S = sum(math.sqrt(w) for w in inst['w'])
        bound = inst['L']*(0.5*math.log(1/inst['w'][0])+math.log(S)+1)/n
        cnt += 1; worst2 = max(worst2, r['last']['chi']/bound)
    print("== Part 2: Proposition 6.1(b) (inputs do not depend on the answers, any human) ==")
    print(f"{cnt} random instances: largest E chi(M^(n+1)) / bound = {worst2:.4f}   (claim: <= 1)")
    # ---------------- Part 3
    worst3 = 0.0; worst_u = 0.0; worst_b = 0.0; cnt = 0; cnt_thm = 0
    def r_part3(inst, n):
        W, c = consts(inst); L = inst['L']
        r = evaluate(inst, n)
        if not r['det']: raise ValueError
        B0 = L*c/n
        bound = 2*L*B0*(1+math.log(1/(2*B0)))+2*B0+2*L/n if 2*B0 < 1 else float('inf')
        return r['last']['u']/bound, r['last']['u']/B0, r['last']['beta']/B0, r['sum_u']/n/B0
    for it in range(250):
        nx, ny, L, nz, nh = rng.choice([(3, 2, 2, 2, 4), (4, 2, 3, 2, 5), (4, 2, 3, 1, 6), (3, 2, 3, 2, 6)])
        n = rng.choice([8, 12])
        inst = R1.make_instance(rng, nx, ny, L, nz, nh, 'det')
        try: a, b, c3, d = r_part3(inst, n)
        except (ValueError, ZeroDivisionError): continue
        cnt += 1
        if a > 0: cnt_thm += 1
        worst3 = max(worst3, a); worst_u = max(worst_u, b); worst_b = max(worst_b, c3)
    print("== Part 3: Proposition 6.4 (any scaffold, deterministic human) ==")
    print(f"{cnt} random instances ({cnt_thm} with 2 B0 < 1): largest E u(M^(n+1)) / (bound of 6.4) = {worst3:.4f}   (claim: <= 1)")
    print(f"  largest E u(M^(n+1))/B0 = {worst_u:.4f};  largest E beta(M^(n+1))/B0 = {worst_b:.4f}   (B0 = L ln(W/w(f))/n, the bound for a random round)")
    print("local search for a last round that is worse than the bound of the random round (hypotheses may be stochastic):")
    for target, idx in [('E u(M^(n+1))/B0', 1), ('E beta(M^(n+1))/B0', 2)]:
        best = 0.0; best_avg = 0.0
        for restart in range(5):
            nx, ny, L, nz, nh = rng.choice([(3, 2, 2, 2, 3), (3, 2, 3, 2, 4), (4, 2, 3, 1, 4), (3, 2, 4, 2, 3)])
            n = rng.choice([8, 12])
            inst = R1.make_instance(rng, nx, ny, L, nz, nh, 'det')
            try: cur = r_part3(inst, n)
            except (ValueError, ZeroDivisionError): continue
            for step in range(200):
                cand = R1.perturb(rng, inst, rng.choice([0.05, 0.3, 1.0]))
                try: v = r_part3(cand, n)
                except (ValueError, ZeroDivisionError, OverflowError): continue
                if v[idx] > cur[idx]: cur = v; inst = cand
            if cur[idx] > best: best = cur[idx]; best_avg = cur[3]
        print(f"  target {target}: best value found = {best:.4f}  (in that instance the average over the rounds of E u is {best_avg:.4f} B0)")

if __name__ == '__main__':
    main()
