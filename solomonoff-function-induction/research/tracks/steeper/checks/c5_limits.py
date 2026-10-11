"""c5: limits of the trick (notes Section 2.6) and small structural facts, re-verified with
independent code (several are T5 results).

(a) Lemma 3.1 (hull) and Thm 3.2 (separable components: component j kept iff rate r_j/k_j > c):
    brute force over random instances.
(b) Guard erosion (three options none / unguarded / guarded): selection path in c.
(c) Non-identifiability: strictly proper scores (log, Brier, spherical) prefer the teacher's channel
    to the 'good model' on imitation data; held-out log loss picks the error-memorising end.
(d) Block telescoping (Prop 6.3 / T5 Prop 2.6): in-context Bayes mixture pays log(1/w) per block.
(e) Power-posterior concentration bound of Prop 2.9 evaluated for Hanni-size numbers.
Seeded: random.seed(5), numpy default_rng(5).
Revision 2026-10-11: part (e) computes J_g from the formula (referee minor 3).
"""
import itertools, random
from math import log2, sqrt
import numpy as np
random.seed(5); rng = np.random.default_rng(5)
def H(q): return 0.0 if q in (0, 1) else -(q*log2(q)+(1-q)*log2(1-q))

print("=" * 78)
print("(a) hull and separable thresholds")
viol = 0; tests = 0
for _ in range(400):
    m = random.randint(1, 9); k = [random.randint(1, 80) for _ in range(m)]; r = [random.random()*0.05 for _ in range(m)]
    for c in [10**(-random.uniform(1, 5)) for _ in range(20)]:
        if any(abs(rj/kj - c) < 1e-12 for rj, kj in zip(r, k)): continue
        tests += 1
        best = min(itertools.product([0, 1], repeat=m), key=lambda S: sum(s*(c*kj - rj) for s, kj, rj in zip(S, k, r)))
        if best != tuple(int(rj/kj > c) for kj, rj in zip(k, r)): viol += 1
print(f"  separable: component kept iff rate > c: {viol} violations in {tests} (instance, c) pairs")
def lower_hull(P):
    P = sorted(set(P)); Hh = []
    for q in P:
        while len(Hh) >= 2 and (Hh[-1][0]-Hh[-2][0])*(q[1]-Hh[-2][1]) - (Hh[-1][1]-Hh[-2][1])*(q[0]-Hh[-2][0]) <= 0: Hh.pop()
        Hh.append(q)
    out = [Hh[0]]
    for q in Hh[1:]:
        if q[1] < out[-1][1]: out.append(q)
    return out
off = mono = notsel = 0
for _ in range(300):
    A = [(random.randint(0, 200), random.random()) for _ in range(random.randint(2, 40))]
    Hv = lower_hull(A); prev = None
    for c in sorted([10**(-random.uniform(-1, 4)) for _ in range(300)], reverse=True):
        val = min(c*a + b for a, b in A); mins = [q for q in A if abs(c*q[0] + q[1] - val) < 1e-12]
        for q in mins:
            on = q in Hv or any(x1 <= q[0] <= x2 and abs((x2-x1)*(q[1]-y1) - (y2-y1)*(q[0]-x1)) < 1e-9
                               for (x1, y1), (x2, y2) in zip(Hv, Hv[1:]))
            off += (not on)
        cur = min(mins)
        if prev is not None and (cur[0] < prev[0] or cur[1] > prev[1] + 1e-12): mono += 1
        prev = cur
    for i, v in enumerate(Hv):
        lo = (Hv[i][1]-Hv[i+1][1])/(Hv[i+1][0]-Hv[i][0]) if i+1 < len(Hv) else 0.0
        hi = (Hv[i-1][1]-Hv[i][1])/(Hv[i][0]-Hv[i-1][0]) if i > 0 else float("inf")
        c = (lo + hi)/2 if hi < float("inf") else 2*lo + 1
        vals = sorted(c*a + b for a, b in A)
        if abs(vals[0] - (c*v[0] + v[1])) > 1e-12: notsel += 1
print(f"  hull: minimisers off the lower hull {off}; monotonicity violations {mono}; vertices not selectable {notsel}")

print("=" * 78)
print("(b) guard erosion: none / unguarded / guarded")
M, eta = 64, 0.05
p_hit = 1 - eta + eta/M
gain = log2(M) + (p_hit*log2(p_hit) + (M-1)*(eta/M)*log2(eta/M))    # per G-context gain of the sigma-model
DG = log2(M/eta) - log2(M-1)
for (piG, pinG, ks, kG) in [(0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)]:
    opts = {"none": (0, 0.0), "unguarded": (ks, -piG*gain + pinG*log2(1/eta)),
            "guarded": (ks + kG, -piG*gain + pinG*log2(1/eta) - pinG*DG)}
    rho_s = -opts["unguarded"][1]/ks; rho_G = pinG*DG/kG
    path = []
    for c in np.logspace(-6, -1, 2000):
        sel = min(opts, key=lambda o: c*opts[o][0] + opts[o][1])
        if not path or path[-1][1] != sel: path.append((c, sel))
    print(f"  piG={piG}, pinG={pinG}: rate(unguarded) = {rho_s:.3e}, rate(guard) = {rho_G:.3e} (Delta_G = {DG:.3f}); "
          f"path (c increasing): {[(f'{c:.2e}', s) for c, s in path]}")

print("=" * 78)
print("(c) non-identifiability: teacher channel vs good model under strictly proper scores")
p = 2.0**-10
# teacher: on error inputs (mass p) label = error label w.p. 1; elsewhere the norm label w.p. 1.
# good model: puts 1-p on the norm label everywhere.  Expected scores under the teacher's data.
def scores(q):   # q = probability the forecaster gives to the label that actually occurs
    return {"log": log2(q) if q > 0 else -np.inf, "Brier": -(1-q)**2*2, "spherical": q/sqrt(q**2 + (1-q)**2)}
for name in ["log", "Brier", "spherical"]:
    teacher = scores(1.0)[name]
    good = (1-p)*scores(1-p)[name] + p*scores(p)[name]
    print(f"  {name:9s}: E score(teacher channel) = {teacher:.6f} > E score(good model) = {good:.6f}: {teacher > good}")
hyps = [(0, 1.0), (110, H(p)), (10100, 0.0)]
for c in [1e-1, 1e-3, 1e-5, 1e-7]:
    k_, r_ = min(hyps, key=lambda h: c*h[0] + h[1])
    print(f"  c={c:.0e}: selected K={k_:5d}, held-out log loss = {r_:.5f}")
print("  -> held-out log loss is smallest for the error-memorising selection (smallest c)")

print("=" * 78)
print("(d) block telescoping: in-context mixture loss on a block = -log2(sum_th w_th prod nu_th / sum w)")
worst = 0.0; gapmin = np.inf
for _ in range(2000):
    T = 3; w = rng.dirichlet(np.ones(T))*rng.uniform(0.5, 1.0)
    tabs = [rng.dirichlet(np.ones(3), size=(3, 3)) for _ in range(T)]   # nu_th(y | x, previous y)
    hist = []; prev = 0; tot = 0.0
    for i in range(6):
        x = int(rng.integers(0, 3)) if i == 0 else (prev + i) % 3
        lik = np.array([np.prod([tabs[t][xx][py][yy] for (xx, py, yy) in hist]) for t in range(T)])
        post = w*lik/np.sum(w*lik); pred = sum(post[t]*tabs[t][x][prev] for t in range(T))
        yv = int(rng.integers(0, 3)); tot += -log2(pred[yv]); hist.append((x, prev, yv)); prev = yv
    joint = np.array([np.prod([tabs[t][xx][py][yy] for (xx, py, yy) in hist]) for t in range(T)])
    exact = -log2(np.sum(w*joint)/np.sum(w)); bound = min(-log2(w[t]) - log2(joint[t]) for t in range(T))
    worst = max(worst, abs(tot - exact)); gapmin = min(gapmin, bound - tot)
print(f"  max |block loss - exact| = {worst:.1e}; min(bound - loss) = {gapmin:.3f} (>= 0 required)")

print("=" * 78)
print("(e) power-posterior concentration: mass(not eta-near-optimal)/weight(good) <= 2^(-N eta + (J_good + eta)/c)")
# Revision (referee minor 3): J_g is computed from the notes' formula J_g(c) = c(d + kappa_g) + H(p),
# kappa_g = 2 log2 d + 2 log2 r + kappa, with d = 100, r = 10 (p = 2^-10) and kappa = 0 (illustration),
# instead of the hard-coded values used before (0.0214, 0.1112, 0.0122).
d_, r_, kap_ = 100, 10, 0.0
kg_ = 2*log2(d_) + 2*log2(r_) + kap_
for (c, eta, N) in [(1e-4, 1e-3, 10**6), (1e-4, 1e-3, 10**7), (1e-3, 1e-3, 10**6), (1e-5, 1e-4, 10**7)]:
    Jg = c*(d_ + kg_) + H(2.0**-r_)
    print(f"  c={c:.0e}, J_c(good)={Jg:.4f}, eta={eta:.0e}, N={N:.0e}: log2 bound = {-N*eta + (Jg + eta)/c:.0f}")
