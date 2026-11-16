#!/usr/bin/env python3
"""
Check of Proposition X5 of the attack report (rehearsal with a non-uniform audit).
Protocol R with step 3 changed: the call put to the human is call j of the run with
probability pi_j(h_j), a function of the history before the answer of call j, with
sum_j pi_j <= 1 on every run.  Claim, for every class, prior and scaffold:
     sum_t E[ E_{Q_{M^(t)}} sum_j pi_j(h_j) KL(P || M^(t))(x_j) ] <= ln(W/w(P)),
and for a function human the same with e_{M^(t)}(x_j) (the probability of an unfaithful
call at j) in place of KL.  The file's remark "(i) the index J_t is uniform" after
Theorem 5.1 is the special case pi_j = 1/L.

Exact enumeration on random small instances (generator of rehearsal-core_attack_r1.py);
pi_j(h_j) is a random table, normalised so that the sum along every run is at most 1.
"""
import math, random, importlib.util, os, itertools
from collections import defaultdict

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("atk_r1", os.path.join(here, "rehearsal-core_attack_r1.py"))
R1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(R1)
STOP = -1

def weighted_functionals(inst, C, KL, TV, pi):
    nx, ny, L = inst['nx'], inst['ny'], inst['L']
    lam = bet = 0.0; q = [0.0]*nx
    for z, pz in enumerate(inst['D0']):
        stack = [((), pz)]
        while stack:
            hist, pr = stack.pop()
            j = len(hist)+1
            if j > L: continue
            x = inst['nxt'][(z, hist)]
            if x == STOP: continue
            w = pi[(z, hist)]
            lam += pr*w*KL[x]; bet += pr*w*TV[x]; q[x] += pr*w
            for y in range(ny+1):
                if C[x][y] > 0: stack.append((hist+(y,), pr*C[x][y]))
    return lam, bet, q

def run(inst, pi, n):
    nx, ny = inst['nx'], inst['ny']; P = inst['hyps'][0]
    states = {(): 1.0}; S_lam = S_bet = 0.0
    for t in range(1, n+1):
        new = defaultdict(float)
        for key, pr in states.items():
            post, M = R1.mixture(inst, key)
            KL, TV, H2 = R1.divergences(inst, M)
            lam, bet, q = weighted_functionals(inst, M, KL, TV, pi)
            S_lam += pr*lam; S_bet += pr*bet
            asked = sum(q)
            if asked < 1.0: new[key] += pr*(1.0-asked)
            d = dict(key)
            for x in range(nx):
                if q[x] <= 0: continue
                for y in range(ny):
                    if P[x][y] <= 0: continue
                    d2 = dict(d); d2[(x, y)] = d2.get((x, y), 0)+1
                    new[tuple(sorted(d2.items()))] += pr*q[x]*P[x][y]
        states = dict(new)
    return S_lam, S_bet

def main():
    rng = random.Random(505)
    worst = 0.0; worst_fn = 0.0; cnt = 0
    for it in range(600):
        human = rng.choice(['det', 'stoch'])
        nx, ny, L, nz, nh, n = rng.choice([(3, 2, 2, 2, 3, 5), (3, 2, 3, 1, 4, 4), (4, 2, 3, 2, 3, 3), (2, 2, 2, 1, 2, 6)])
        inst = R1.make_instance(rng, nx, ny, L, nz, nh, human)
        W = sum(inst['w']); c = math.log(W/inst['w'][0])
        if c < 1e-6: continue
        # random weights on (z, history), then normalised by the largest sum along a run
        raw = {k: rng.random()**rng.choice([1, 4]) for k in inst['nxt']}
        mx = 0.0
        for z in range(nz):
            for hist in itertools.product(range(ny+1), repeat=L-1):
                s = 0.0
                for j in range(1, L+1):
                    h = hist[:j-1]
                    if inst['nxt'][(z, h)] == STOP: break
                    s += raw[(z, h)]
                mx = max(mx, s)
        pi = {k: v/mx for k, v in raw.items()}
        S_lam, S_bet = run(inst, pi, n)
        cnt += 1
        worst = max(worst, S_lam/c)
        if all(max(r) == 1.0 for r in inst['hyps'][0]): worst_fn = max(worst_fn, S_bet/c)
    print(f"{cnt} random instances with a random audit rule pi_j(h_j):")
    print(f"  largest sum_t E sum_j pi_j KL_j / ln(W/w(P))                 = {worst:.6f}   (claim: <= 1)")
    print(f"  function humans: largest sum_t E sum_j pi_j e_j / ln(W/w(f)) = {worst_fn:.6f}   (claim: <= 1)")

if __name__ == '__main__':
    main()
