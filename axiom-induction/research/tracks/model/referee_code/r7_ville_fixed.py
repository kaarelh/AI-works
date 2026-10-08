"""r7 (referee): Theorem 4.1 of notes.md in its own setting (fixed weights, L0), with a richer class than c4.

Data: t + 0 = t, t ~ Q (root law p over {0, S, +, *}); truth T* = {z+0=z}.  Class (fixed weights), final version:
  * C*: T* and its root split (same generator), prior weight 0.05 each before normalisation;
  * spares T* + {q_1} with q_1 := 0+0=S0 and weight e in {0.002, 0.02};
  * boosters: (1-w-e) Q on z+0=z, plus weight w on a frequent instance f (0+0=0 or S0+0=S0), plus e = 0.002 on q_1;
  * the over-general {z1+0=z2}.
Every competitor proves the invalid q_1; the only non-provers are the members of C*.  (A first run used three
queries q_j, each proved by different competitors, plus missing-root splits; the other hypotheses then guarded each
query and the test could not bite, so it was replaced by this version.)
Prover: queries q_1 at every time (accept-or-nothing; no escalation).  The verifier accepts q iff the posterior
mass of {T : q not in Th(T)} is <= delta.  Thm 4.1: P(exists t: some invalid q accepted) <= delta / pi(C*).
For contrast, the bound delta / pi(T*) of the brief's H3 (C* replaced by {T*}) is also printed.
"""
import math
import random

out = []
rng = random.Random(707)
P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
ARITY = {'0': 0, 'S': 1, '+': 2, '*': 2}

def sample(rng):
    f = rng.choices(list(P), [P[s] for s in P])[0]
    return (f,) + tuple(sample(rng) for _ in range(ARITY[f]))

def q(t):
    r = P[t[0]]
    for c in t[1:]:
        r *= q(c)
    return r

ZERO = ('0',)
S0 = ('S', ZERO)
# hypotheses: (name, prior, loglik function of t, set of invalid q_j it proves)
H = []
H.append(('T*', 0.05, lambda t: math.log(q(t)), set()))
H.append(('T_split', 0.05, lambda t: math.log(P[t[0]] * (q(t) / P[t[0]])), set()))
for j in (1,):
    for e in (0.002, 0.02):
        H.append((f'spare{j},{e}', 0.03, (lambda e: lambda t: math.log((1 - e) * q(t)))(e), {j}))
    for f in (ZERO, S0):
        for w in (0.3, 0.6):
            e = 0.002
            H.append((f'boost{j},{f[0]},{w}', 0.02,
                      (lambda w, e, f: lambda t: math.log((1 - w - e) * q(t) + (w if t == f else 0.0)))(w, e, f), {j}))
H.append(('over', 0.02, lambda t: math.log(q(t) * q(t)), {1}))
tot = sum(h[1] for h in H)
H = [(nm, pr / tot, ll, pv) for nm, pr, ll, pv in H]
piC = sum(h[1] for h in H if h[0] in ('T*', 'T_split'))
piT = [h[1] for h in H if h[0] == 'T*'][0]
out.append(f"{len(H)} hypotheses; pi(C*) = {piC:.4f}, pi(T*) = {piT:.4f}")

R, NMAX = 4000, 400
for delta in (0.05, 0.02, 0.005):
    hits = 0
    for _ in range(R):
        lp = [math.log(h[1]) for h in H]
        bad = False
        for n in range(NMAX):
            t = sample(rng)
            for i, h in enumerate(H):
                if lp[i] > -math.inf:
                    v = h[2](t)
                    lp[i] = lp[i] + v
            mx = max(lp)
            w = [math.exp(x - mx) if x > -math.inf else 0.0 for x in lp]
            Z = sum(w)
            for j in (1,):
                nonder = sum(wi for wi, h in zip(w, H) if j not in h[3]) / Z
                if nonder <= delta:
                    bad = True
            if bad:
                break
        hits += bad
    out.append(f"delta = {delta}: P(exists n <= {NMAX}: an invalid q_j accepted) ~ {hits / R:.4f};  "
               f"Thm 4.1 bound delta/pi(C*) = {delta / piC:.4f};  brief's delta/pi(T*) = {delta / piT:.4f}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
