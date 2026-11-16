#!/usr/bin/env python3
"""
Attack on Section 10 of research/prove-c/rehearsal-core.md (the online form: every call
is put to the human with probability q) by exact enumeration on random small instances
(the instance generator of rehearsal-core_attack_r1.py: stochastic humans, semimeasures,
inputs that depend on the answers, runs of variable length), followed by a local search.

Checked, with c := ln(W/w(P)):
  10.1   S_all    := sum over all steps of E KL(P || current mixture)(x)   <= c/q
         S_wrong  := E #(unasked steps answered differently from f)        <= (1-q) c/q   (function human)
  10.2   q = 1/L: E #questions <= r
  10.3   S_frozen := sum_i E Lambda(M_i), M_i the mixture at the start of run i,
                     <= c/(q (1-q)^(L-1)); the same for the variant with shadow questions.
The local search tries to push S_frozen above the bound, and reports the largest value of
S_frozen/(L c) found for q = 1/L (the file proves it is at most e and exhibits 1/(1-(1-1/L)^L)).
"""
import math, random, importlib.util, os, copy
from collections import defaultdict

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("atk_r1", os.path.join(here, "rehearsal-core_attack_r1.py"))
R1 = importlib.util.module_from_spec(spec); spec.loader.exec_module(R1)
STOP = -1

def online(inst, r, q, shadow=False):
    nx, ny, L = inst['nx'], inst['ny'], inst['L']
    P = inst['hyps'][0]
    det = all(max(P[x]) == 1.0 for x in range(nx))
    cache = {}
    def mix(key):
        if key not in cache:
            post, M = R1.mixture(inst, key)
            KL, TV, H2 = R1.divergences(inst, M)
            cache[key] = (M, KL, TV, H2)
        return cache[key]
    def add(key, x, y):
        d = dict(key); d[(x, y)] = d.get((x, y), 0)+1
        return tuple(sorted(d.items()))
    states = {(): 1.0}
    S_all = S_wrong = S_frozen = Nq = 0.0
    for i in range(r):
        new = defaultdict(float)
        for key0, p0 in states.items():
            M0, KL0, TV0, H20 = mix(key0)
            lam, bet, chi, elen, qd = R1.run_functionals(inst, M0, KL0, TV0, H20)
            S_frozen += p0*lam
            for z, pz in enumerate(inst['D0']):
                # stack entries: (history of passed answers, current data key, pending pairs (shadow), probability)
                stack = [((), key0, (), p0*pz)]
                while stack:
                    hist, key, pend, pr = stack.pop()
                    j = len(hist)+1
                    x = inst['nxt'].get((z, hist), STOP) if j <= L else STOP
                    if x == STOP:
                        k2 = key
                        for (xx, yy) in pend: k2 = add(k2, xx, yy)
                        new[k2] += pr
                        continue
                    M, KL, TV, H2 = mix(key)
                    S_all += pr*KL[x]
                    if not shadow:
                        # coin = 1: the human answers, the data change at once, the human's answer is passed
                        Nq += pr*q
                        for y in range(ny):
                            if P[x][y] > 0:
                                stack.append((hist+(y,), add(key, x, y), pend, pr*q*P[x][y]))
                        # coin = 0: the mixture answers
                        for y in range(ny+1):
                            if M[x][y] > 0:
                                if det and (y == ny or P[x][y] < 1.0): S_wrong += pr*(1-q)*M[x][y]
                                stack.append((hist+(y,), key, pend, pr*(1-q)*M[x][y]))
                    else:
                        # the frozen mixture answers every call; with probability q the human's answer is recorded for later
                        Nq += pr*q
                        for y in range(ny+1):
                            if M[x][y] <= 0: continue
                            stack.append((hist+(y,), key, pend, pr*(1-q)*M[x][y]))
                            for yh in range(ny):
                                if P[x][yh] > 0:
                                    stack.append((hist+(y,), key, pend+((x, yh),), pr*q*M[x][y]*P[x][yh]))
        states = dict(new)
    return dict(S_all=S_all, S_wrong=S_wrong, S_frozen=S_frozen, Nq=Nq, det=det)

def ratios(inst, r, q):
    W = sum(inst['w']); c = math.log(W/inst['w'][0]); L = inst['L']
    if c < 1e-6: raise ValueError
    o = online(inst, r, q); s = online(inst, r, q, shadow=True)
    out = {'10.1': o['S_all']/(c/q),
           '10.3': o['S_frozen']/(c/(q*(1-q)**(L-1))),
           '10.3shadow': s['S_frozen']/(c/(q*(1-q)**(L-1))),
           'Nq': o['Nq']/(r*L*q),
           'loss': o['S_frozen']/(L*c) if abs(q-1.0/L) < 1e-12 else 0.0,
           'loss_shadow': s['S_frozen']/(L*c) if abs(q-1.0/L) < 1e-12 else 0.0}
    if o['det']:
        out['10.1wrong'] = o['S_wrong']/((1-q)*c/q) if q < 1 else 0.0
    return out

def main():
    rng = random.Random(1003)
    worst = defaultdict(float); n = 0
    for it in range(500):
        human = rng.choice(['det', 'stoch'])
        nx, ny, L, nz, nh, r = rng.choice([(3, 2, 2, 2, 3, 3), (3, 2, 3, 1, 3, 2), (2, 2, 2, 1, 2, 4), (4, 2, 2, 2, 4, 3)])
        inst = R1.make_instance(rng, nx, ny, L, nz, nh, human)
        q = rng.choice([1.0/L, 1.0/L, 0.1, 0.5, 0.9])
        try:
            out = ratios(inst, r, q)
        except (ValueError, ZeroDivisionError):
            continue
        n += 1
        for k, v in out.items(): worst[k] = max(worst[k], v)
    print(f"{n} random instances; largest (left side)/(right side):")
    for k in ['10.1', '10.1wrong', 'Nq', '10.3', '10.3shadow']:
        print(f"  {k}: {worst[k]:.6f}")
    print(f"  largest S_frozen/(L ln(W/w(P))) at q = 1/L: online {worst['loss']:.4f}, shadow {worst['loss_shadow']:.4f}")
    print("local search for q = 1/L (maximise S_frozen/(L c); the file proves <= (1-1/L)^-(L-1) and exhibits 1/(1-(1-1/L)^L)):")
    for L, r in [(2, 6), (3, 4)]:
        best = 0.0
        for restart in range(5):
            nx, ny, nz, nh = rng.choice([(2, 2, 1, 2), (3, 2, 1, 3), (3, 2, 2, 2)])
            inst = R1.make_instance(rng, nx, ny, L, nz, nh, rng.choice(['det', 'stoch']))
            try: cur = ratios(inst, r, 1.0/L)['loss']
            except (ValueError, ZeroDivisionError): continue
            for step in range(150):
                cand = R1.perturb(rng, inst, rng.choice([0.05, 0.3, 1.0]))
                try: v = ratios(cand, r, 1.0/L)['loss']
                except (ValueError, ZeroDivisionError, OverflowError): continue
                if v > cur: cur = v; inst = cand
            best = max(best, cur)
        lim = sum((1-1.0/L)**(L*i) for i in range(r))
        print(f"  L={L}, r={r} runs: best S_frozen/(L c) found = {best:.4f};  the file's example gives {lim:.4f} for r runs "
              f"(limit {1/(1-(1-1.0/L)**L):.4f});  proved bound {(1-1.0/L)**(-(L-1)):.4f}")

if __name__ == '__main__':
    main()
