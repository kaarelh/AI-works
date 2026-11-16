"""Stochastic human: one posterior draw per run against the per-call mixture.
(1) Example 3.1 (one question asked three times), exact Bayes over all functions, small N_z.
(2) Proposition 3.2 (class C2), exact Bayes over all 4096 members for N_z = 3, R = 2, three kinds of data.
(3) Proposition 3.2, larger R and N_z, by the closed-form update of the posterior ratio.
Usage: python3 one-mind_stochastic.py"""
import itertools, math
import numpy as np

rng = np.random.default_rng(0)

# ---------- (1) Example 3.1 ----------
def example31(nz, eps, rounds, trials):
    funcs = np.array(list(itertools.product((0, 1), repeat=nz)))           # s(z) in {0,1}; 1 = "right"
    prior_f = 0.5 * np.prod(np.where(funcs == 1, 1 - eps, eps), axis=1)
    pP = lambda y: 1 - eps if y == 1 else eps
    out = []
    for _ in range(trials):
        wf, wP, seen, rows = prior_f.copy(), 0.5, set(), []
        for t in range(rounds):
            tot = wf.sum() + wP
            post_f, post_P = wf / tot, wP / tot
            # exact TV between the run law of a posterior draw per run and Q_P, and for the per-call mixture
            tv_one = tv_mix = 0.0
            for z in range(nz):
                m1 = post_P * (1 - eps) + post_f[funcs[:, z] == 1].sum()   # mixture's Pr[answer 1 | z]
                for run in itertools.product((0, 1), repeat=3):
                    qP = math.prod(pP(y) for y in run)
                    q1 = post_P * qP + (post_f[funcs[:, z] == run[0]].sum() if len(set(run)) == 1 else 0.0)
                    qm = math.prod(m1 if y == 1 else 1 - m1 for y in run)
                    tv_one += abs(q1 - qP) / (2 * nz); tv_mix += abs(qm - qP) / (2 * nz)
            rows.append((len(seen) == t, post_P, tv_one, tv_mix))           # first flag: all asked z distinct so far
            z = int(rng.integers(nz)); seen.add(z)
            y = 1 if rng.random() < 1 - eps else 0                          # every call of the run has input z
            wf = np.where(funcs[:, z] == y, wf, 0.0); wP *= pP(y)
        out.append(rows)
    return out

print("(1) Example 3.1: exact posterior over all 2^nz functions and P; nz = 10, eps = 0.1")
res = example31(10, 0.1, 4, 200)
print(" round  runs with distinct z so far   posterior of P    TV(one draw per run, Q_P)   TV(per-call mixture, Q_P)")
for t in range(4):
    sel = [r[t] for r in res if r[t][0]]
    pp, t1, tm = (np.array([s[i] for s in sel]) for i in (1, 2, 3))
    fresh = (10 - t) / 10
    print(f"{t + 1:6d} {len(sel):12d} {pp.min():18.6f}..{pp.max():.6f} {t1.min():14.6f}..{t1.max():.6f}"
          f"   {tm.max():12.2e}   formula (3/2)eps(1-eps)*(fresh fraction) = {1.5 * 0.1 * 0.9 * fresh:.6f}")

# ---------- (2) class C2, brute force ----------
NZ, R = 3, 2
def all_members():
    per_z = []                      # one z: (r*, common bit c, bits at the other r: (b2, b3))
    for rs in range(R):
        for c in (0, 1):
            for b2 in (0, 1):
                for b3 in (0, 1):
                    table = {('z',): rs}
                    for r in range(R):
                        table[(r, 2)], table[(r, 3)] = (c, c) if r == rs else (b2, b3)
                    per_z.append(table)
    return list(itertools.product(per_z, repeat=NZ))
MEMBERS = all_members()
def val(s, x):                      # x = (z,) or (z, r, j)
    return s[x[0]][('z',)] if len(x) == 1 else s[x[0]][(x[1], x[2])]
def brute_ratio(data):
    """(posterior mass of F)/(posterior mass of P) by enumeration; prior masses 1/2 and 1/2."""
    lf = sum(all(val(s, x) == y for x, y in data) for s in MEMBERS) / len(MEMBERS)
    lp = math.prod(1 / R if len(x) == 1 else 0.5 for x, y in data)
    return lf / lp
def closed_ratio(rounds):
    """rounds: list of (kind, z, r_d, r', b, b') at pairwise distinct z; the closed form of Proposition 3.2."""
    ratio = 1.0
    for kind, z, rd, rp, b, bp in rounds:
        if kind == 'all' and rp == rd:
            ratio *= 2.0 * (b == bp)
        if kind == 'human':
            ratio *= 2.0 * (b == bp)
    return ratio
ok = 0
for _ in range(300):
    zs = rng.permutation(NZ)
    data, rounds = [], []
    for z in zs:
        z = int(z); kind = ('one', 'all', 'human')[int(rng.integers(3))]
        rd, rp, b, bp = (int(rng.integers(R)), int(rng.integers(R)), int(rng.integers(2)), int(rng.integers(2)))
        if kind == 'one':           # one uniformly chosen call of the driver's run; driver's first answer rd
            j = int(rng.integers(1, 4))
            data.append(((z,), rp) if j == 1 else ((z, rd, j), b))
        elif kind == 'all':         # all three calls of the driver's run
            data += [((z,), rp), ((z, rd, 2), b), ((z, rd, 3), bp)]
        else:                       # a recorded run of the human system
            data += [((z,), rp), ((z, rp, 2), b), ((z, rp, 3), bp)]
        rounds.append((kind, z, rd, rp, b, bp))
    assert abs(brute_ratio(data) - closed_ratio(rounds)) < 1e-12
    ok += 1
print(f"\n(2) class C2 with N_z = {NZ}, R = {R}: {len(MEMBERS)} functions enumerated; closed-form posterior ratio "
      f"equals brute-force Bayes in {ok}/300 random data sets (mixed kinds of rounds, distinct z)")

# ---------- (3) class C2, larger, closed form ----------
def c2_sim(kind, R, nz, n, trials):
    """Returns mean over trials of: fraction of rounds t <= n with TV(one draw per run, Q_P) >= 1/4 at fresh z;
    final posterior of P; whether all asked z were distinct."""
    frac, pfin, distinct = [], [], 0
    for _ in range(trials):
        ratio, seen, good, coll = 1.0, set(), 0, False
        for t in range(n):
            wP = 1.0 / (1.0 + ratio)
            good += (1 - wP) / 2 >= 0.25 - 1e-12       # TV at a fresh z is (1 - w_t(P))/2
            z = int(rng.integers(nz)); coll |= z in seen; seen.add(z)
            rd, rp, b, bp = int(rng.integers(R)), int(rng.integers(R)), int(rng.integers(2)), int(rng.integers(2))
            if (kind == 'all' and rp == rd) or kind == 'human':
                ratio *= 2.0 * (b == bp)
        frac.append(good / n); pfin.append(1.0 / (1.0 + ratio)); distinct += not coll
    return np.mean(frac), np.mean(pfin), distinct / trials
print("\n(3) class C2, R = 1000, N_z = 10^7, n = 100 rounds, 2000 rehearsals (updates valid on rehearsals with distinct z)")
print(" data put to the human                      rounds with TV>=1/4 at fresh z   mean final posterior of P   distinct z")
for kind, name in (('one', 'one call of the driver run'), ('all', 'all calls of the driver run'),
                   ('human', 'a recorded human-system run')):
    f, p, d = c2_sim(kind, 1000, 10 ** 7, 100, 2000)
    print(f" {name:40s} {f:20.4f} {p:26.4f} {d:14.4f}")
