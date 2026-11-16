"""Referee's checks of Section 3 of research/prove-c/one-mind.md (stochastic human), in exact rational arithmetic
where the statement is exact.

(A) Example 3.1: exact Bayes over all functions for N_z = 3 and three values of eps; every data list with
    distinct inputs of length 0, 1, 2; the run law of a posterior draw per run and of the per-call mixture.
    Then the consequence (the sum over n rounds) by simulation with the exact per-input posterior.
(B) Proposition 3.2: all members of F_z enumerated for R = 2 and R = 3; parts (a) to (d); then full Bayes over
    F = F_z x F_z (N_z = 2) on random data of the three kinds.
(C) Referee's addition to Remark 3.3(iii): a four-call variant of Proposition 3.2 in which, under the
    posterior-draw driver, the per-call mixture also stays far from Q_P, for about 8 * 2^K rounds, while the
    regret bound of Remark 3.3(iii) holds with equality in the weighted form
        sum_t E[ w_t(P) * KL(Q_P || Q_{M^(t)}) ] <= L K ln 2.
(D) Referee's proposition: with the weights squared, one program drawn from (or maximising) the posterior after
    mixture-driven rehearsal is close to the human system in whole-run Hellinger distance. Exact check of the
    supermartingale behind it; the two families of (A) and (B) under squared weights; Monte Carlo on random classes.
Usage: python3 one-mind_check_stochastic.py
"""
import itertools
import math
import random
from fractions import Fraction as Fr


# ---------------------------------------------------------------- (A) Example 3.1
def part_A():
    print("(A) Example 3.1, exact (N_z = 3; all 8 functions; all data lists with distinct inputs of length <= 2)")
    NZ = 3
    for eps in (Fr(1, 10), Fr(1, 4), Fr(1, 2)):
        P = {1: 1 - eps, 0: eps}
        funcs = list(itertools.product((0, 1), repeat=NZ))
        prior = {s: Fr(1, 2) * math.prod(P[s[z]] for z in range(NZ)) for s in funcs}
        assert sum(prior.values()) + Fr(1, 2) == 1
        target = Fr(3, 2) * eps * (1 - eps)
        ndata = 0
        for k in range(0, 3):
            for zs in itertools.permutations(range(NZ), k):
                for ys in itertools.product((0, 1), repeat=k):
                    ndata += 1
                    wP = Fr(1, 2) * math.prod(P[y] for y in ys)
                    wF = {s: prior[s] for s in funcs if all(s[z] == y for z, y in zip(zs, ys))}
                    tot = wP + sum(wF.values())
                    wP, wF = wP / tot, {s: q / tot for s, q in wF.items()}
                    assert wP == Fr(1, 2)                                            # (a)
                    tv_total = Fr(0)
                    for z in range(NZ):
                        m1 = wP * P[1] + sum(q for s, q in wF.items() if s[z] == 1)   # mixture's Pr[answer 1 | z]
                        tv_one = tv_mix = Fr(0)
                        maj0_one = maj0_P = Fr(0)
                        for run in itertools.product((0, 1), repeat=3):
                            qP = math.prod(P[y] for y in run)
                            q1 = wP * qP + (sum(q for s, q in wF.items() if s[z] == run[0]) if len(set(run)) == 1 else 0)
                            qm = math.prod(m1 if y == 1 else 1 - m1 for y in run)
                            tv_one += abs(q1 - qP) / 2
                            tv_mix += abs(qm - qP) / 2
                            if sum(run) <= 1:
                                maj0_one += q1
                                maj0_P += qP
                        if z not in zs:                                              # fresh input
                            assert tv_one == target and tv_mix == 0                  # (b), (c)
                            assert maj0_P == 3 * eps ** 2 - 2 * eps ** 3
                            assert maj0_one == Fr(1, 2) * eps + Fr(1, 2) * (3 * eps ** 2 - 2 * eps ** 3)
                        tv_total += tv_one / NZ
                    assert tv_total >= target * (1 - Fr(k, NZ))
        print(f"   eps = {eps}: {ndata} data lists; posterior of P = 1/2 in all; at every fresh z: TV(one draw per run, Q_P) = "
              f"{target} = (3/2)eps(1-eps), TV(per-call mixture, Q_P) = 0, majority-0 probabilities as stated")
    # a repeated input: two different answers refute F, two equal answers favour it
    eps = Fr(1, 10)
    P = {1: 1 - eps, 0: eps}
    for ys in ((0, 1), (1, 1), (0, 0)):
        lf = sum(Fr(1, 2) * P[s] for s in (0, 1) if all(s == y for y in ys))          # prior on s(z) is P(.|z)
        lp = Fr(1, 2) * math.prod(P[y] for y in ys)
        print(f"   the same input asked twice, answers {ys}: posterior of P = {lp / (lp + lf)}")

    # the consequence: sum over n rounds, N_z = n^2/eta; exact per-input bookkeeping, Monte Carlo over rehearsals
    print("   consequence (simulation of the rehearsal; posterior and TV computed exactly from the per-input record):")
    print("      eps     n    eta      N_z    mean of sum_t TV(Qbar_t, Q_P)   (1-2eta) n (3/2)eps(1-eps)   mean of sum_t TV(Q_M, Q_P)   eta")
    rng = random.Random(3)
    for eps, n, eta in ((0.5, 40, 0.1), (0.1, 60, 0.05), (0.25, 100, 0.2)):
        NZ = int(math.ceil(n * n / eta))
        p1 = 1 - eps
        tot_one = tot_mix = 0.0
        trials = 300
        for _ in range(trials):
            rec = {}                       # z -> list of answers
            logodds = 0.0                  # log of (posterior mass of F)/(posterior mass of P); -inf when F is refuted
            for t in range(n):
                wF = 0.0 if logodds == -math.inf else 1.0 / (1.0 + math.exp(-logodds))
                # TV of the run laws = average over z of the conditional TVs; fresh inputs dominate
                k = len(rec)
                tv_one = (1 - k / NZ) * wF * 3 * eps * (1 - eps)
                tv_mix = 0.0
                for z, ans in rec.items():
                    if wF > 0:
                        y = ans[0]
                        py = p1 if y == 1 else eps
                        tv_one += wF * (1 - py ** 3) / NZ
                        m1 = (1 - wF) * p1 + wF * (1.0 if y == 1 else 0.0)
                        tv_mix += sum(abs(math.prod(m1 if b else 1 - m1 for b in run) - math.prod(p1 if b else eps for b in run))
                                      for run in itertools.product((0, 1), repeat=3)) / 2 / NZ
                tot_one += tv_one
                tot_mix += tv_mix
                z = rng.randrange(NZ)
                y = 1 if rng.random() < p1 else 0
                if z in rec:
                    if logodds != -math.inf:
                        logodds = logodds - math.log(p1 if y == 1 else eps) if y == rec[z][0] else -math.inf
                    rec[z].append(y)
                else:
                    rec[z] = [y]
        bound = (1 - 2 * eta) * n * 1.5 * eps * (1 - eps)
        assert tot_one / trials >= bound and tot_mix / trials <= eta + 1e-9
        print(f"   {eps:7.2f} {n:5d} {eta:6.2f} {NZ:8d} {tot_one / trials:20.4f} {bound:28.4f} {tot_mix / trials:24.5f} {eta:12.3f}")


# ---------------------------------------------------------------- (B) Proposition 3.2
def members_Fz(R):
    """All members of F_z as dicts: key 'z' -> r*, key (r, j) -> bit, for r in range(R), j in (2, 3)."""
    out = []
    for rs in range(R):
        others = [r for r in range(R) if r != rs]
        for c in (0, 1):
            for bits in itertools.product((0, 1), repeat=2 * len(others)):
                s = {'z': rs, (rs, 2): c, (rs, 3): c}
                for i, r in enumerate(others):
                    s[(r, 2)], s[(r, 3)] = bits[2 * i], bits[2 * i + 1]
                out.append(s)
    return out


def part_B():
    print("(B) Proposition 3.2, exact")
    for R in (2, 3):
        Fz = members_Fz(R)
        assert len(Fz) == R * 2 * 4 ** (R - 1)
        frac = lambda cond: Fr(sum(1 for s in Fz if cond(s)), len(Fz))
        # (a) every single answer has the same likelihood under the uniform law on F_z as under P
        for r in range(R):
            assert frac(lambda s: s['z'] == r) == Fr(1, R)
            for j in (2, 3):
                for b in (0, 1):
                    assert frac(lambda s: s[(r, j)] == b) == Fr(1, 2)
        # (b), (c) all three calls of a driver's run
        for rd, rp, b, bp in itertools.product(range(R), range(R), (0, 1), (0, 1)):
            lf = frac(lambda s: s['z'] == rp and s[(rd, 2)] == b and s[(rd, 3)] == bp)
            lp = Fr(1, 4 * R)
            factor = lf / lp
            assert factor == (1 if rd != rp else (2 if b == bp else 0))
        # (d) run law of a uniform member, against the human system and the per-call mixture
        runs = list(itertools.product(range(R), (0, 1), (0, 1)))
        qF = {run: frac(lambda s: s['z'] == run[0] and s[(run[0], 2)] == run[1] and s[(run[0], 3)] == run[2]) for run in runs}
        qP = {run: Fr(1, 4 * R) for run in runs}
        assert sum(abs(qF[r] - qP[r]) for r in runs) / 2 == Fr(1, 2)
        for wF in (Fr(1, 2), Fr(2, 3), Fr(9, 10)):                    # the mixture with any posterior odds
            M1 = {r: wF * frac(lambda s: s['z'] == r) + (1 - wF) * Fr(1, R) for r in range(R)}
            Mb = {(r, j, b): wF * frac(lambda s: s[(r, j)] == b) + (1 - wF) * Fr(1, 2) for r in range(R) for j in (2, 3) for b in (0, 1)}
            for run in runs:
                assert M1[run[0]] * Mb[(run[0], 2, run[1])] * Mb[(run[0], 3, run[2])] == qP[run]
            qbar = {run: wF * qF[run] + (1 - wF) * qP[run] for run in runs}
            assert sum(abs(qbar[r] - qP[r]) for r in runs) / 2 == wF / 2
        print(f"   R = {R}: |F_z| = {len(Fz)}; (a) single answers: likelihood ratio 1; (b),(c) factors 1 / 2 / 0 as stated; "
              f"(d) TV(uniform member, Q_P) = 1/2, per-call mixture exact, TV(Qbar, Q_P) = w(F)/2")
    # full Bayes over F = F_z x F_z, N_z = 2, R = 2 and 3: random data of the three kinds at distinct z
    rng = random.Random(5)
    for R in (2, 3):
        Fz = members_Fz(R)
        ok = 0
        for _ in range(200):
            data, pred = [], Fr(1)
            for z in (0, 1):
                kind = rng.choice(['one', 'all', 'human'])
                rd, rp, b, bp = rng.randrange(R), rng.randrange(R), rng.randrange(2), rng.randrange(2)
                if kind == 'one':
                    j = rng.randint(1, 3)
                    data.append((z, 'z', rp) if j == 1 else (z, (rd, j), b))
                elif kind == 'all':
                    data += [(z, 'z', rp), (z, (rd, 2), b), (z, (rd, 3), bp)]
                    if rd == rp:
                        pred *= 2 if b == bp else 0
                else:
                    data += [(z, 'z', rp), (z, (rp, 2), b), (z, (rp, 3), bp)]
                    pred *= 2 if b == bp else 0
            lf = Fr(sum(1 for s0 in Fz for s1 in Fz if all((s0, s1)[z][key] == val for z, key, val in data)), len(Fz) ** 2)
            lp = math.prod(Fr(1, R) if key == 'z' else Fr(1, 2) for z, key, val in data)
            assert lf / lp == pred
            ok += 1
        print(f"   N_z = 2, R = {R}: {len(Fz) ** 2} members; posterior odds of F against P equal the closed form in {ok}/200 random data sets")
    # the consequence: exact probability that the odds stay >= 1 for n rounds when all calls are asked (fresh z)
    for R, n in ((1000, 100), (50, 20), (2, 5)):
        exact = (1 - 1 / (2 * R)) ** n
        print(f"   R = {R}, n = {n}: Pr[no round has r' = r_d and b != b'] = {exact:.5f} >= 1 - n/(2R) = {1 - n / (2 * R):.5f}")
        assert exact >= 1 - n / (2 * R)


# ---------------------------------------------------------------- (C) referee's addition
def part_C():
    print("(C) four-call variant (referee): x_1 = z, x_2 = (z,y_1,2), x_3 = (z,y_1,3), x_4 = (z,y_1,y_2,y_3,4); L = 4")
    R = 2
    BAD = 2
    # members of F_z: r*, common bit c at (r*,2),(r*,3); free bits at (r,2),(r,3) for r != r*;
    # at (r,b,b',4): a free bit if b = b', the answer BAD if b != b'.
    Fz = []
    for base in members_Fz(R):
        keys4 = [(r, b, b) for r in range(R) for b in (0, 1)]
        for bits in itertools.product((0, 1), repeat=len(keys4)):
            s = dict(base)
            for key, bit in zip(keys4, bits):
                s[key] = bit
            for r in range(R):
                s[(r, 0, 1)] = s[(r, 1, 0)] = BAD
            Fz.append(s)
    assert len(Fz) == R * 2 * 4 ** (R - 1) * 2 ** (2 * R)

    def human_law(key):
        return {r: Fr(1, R) for r in range(R)} if key == 'z' else {0: Fr(1, 2), 1: Fr(1, 2)}

    def bayes_factor(key, y):
        """(likelihood of the answer y at input key under the uniform law on F_z) / (likelihood under P)."""
        return Fr(sum(1 for s in Fz if s[key] == y), len(Fz)) / human_law(key)[y]

    def run_inputs(y1, y2, y3):
        return ['z', (y1, 2), (y1, 3), (y1, y2, y3)]

    # every question that can arise in a round at a fresh z, by driver
    factors_F, factors_P = set(), {}
    for s in Fz:                                                     # driver is a member of F
        y1 = s['z']; y2 = s[(y1, 2)]; y3 = s[(y1, 3)]
        assert y2 == y3                                              # its own run never has y_2 != y_3
        for key in run_inputs(y1, y2, y3):
            for y in human_law(key):
                factors_F.add(bayes_factor(key, y))
    for y1, y2, y3 in itertools.product(range(R), (0, 1), (0, 1)):   # driver is P
        for J, key in enumerate(run_inputs(y1, y2, y3), 1):
            for y in human_law(key):
                factors_P.setdefault((J, y2 != y3), set()).add(bayes_factor(key, y))
    assert factors_F == {Fr(1)}
    assert all(v == ({Fr(0)} if k == (4, True) else {Fr(1)}) for k, v in factors_P.items())
    print(f"   R = {R}: |F_z| = {len(Fz)}. Bayes factor of F against P for the one question of a round at a fresh z:")
    print("      driver in F: 1 for every call and every answer of the human;")
    print("      driver P: 1, except at call 4 after y_2 != y_3 (probability 1/2 * 1/4 = 1/8 of the P-driven rounds), where it is 0.")
    # the per-call mixture's run law at a fresh z, exactly, for posterior mass wF of F
    for wF in (Fr(1, 2), Fr(1023, 1024)):
        wP = 1 - wF

        def M(key):
            law = {}
            for y in list(human_law(key)) + [BAD]:
                q = wF * Fr(sum(1 for s in Fz if s[key] == y), len(Fz)) + wP * human_law(key).get(y, 0)
                if q:
                    law[y] = q
            return law

        tv = Fr(0)
        kl_terms = Fr(0)
        tot = Fr(0)
        for y1, y2, y3 in itertools.product(range(R), (0, 1), (0, 1)):
            keys = run_inputs(y1, y2, y3)
            pm = M(keys[0])[y1] * M(keys[1])[y2] * M(keys[2])[y3]
            pp = Fr(1, 4 * R)
            assert pm == pp                                          # the first three answers have the human's law
            for y4 in (0, 1, BAD):
                qm = pm * M(keys[3]).get(y4, 0)
                qp = pp * human_law(keys[3]).get(y4, 0)
                tv += abs(qm - qp) / 2
                tot += qm
        assert tot == 1 and tv == wF / 2
        # one posterior draw per run: w(P) Q_P + w(F) Q_F
        tv_bar = wF * Fr(1, 2)
        print(f"   posterior mass of F = {wF}: TV(Q_M, Q_P) at a fresh z = {tv} = w(F)/2;  TV(Qbar, Q_P) = {tv_bar};  "
              f"KL(Q_P || Q_M) = (1/2) ln(1/w(P)) = {0.5 * math.log(1 / float(wP)):.4f}")
    print("   consequence at fresh top-level inputs, prior w(P) = 2^-K, uniform prior on F of total mass 1 - 2^-K:")
    print("      K   driver            Pr[F refuted per round]   E[# rounds with F alive]   E[sum_t TV(Q_M^(t), Q_P)]   sum_t E[w_t(P) KL(Q_P||Q_M^(t))]   L K ln2")
    for K in (1, 5, 10, 20):
        wP = 2.0 ** (-K)
        wF = 1 - wP
        for driver, rate in (("posterior draw", wP / 8), ("mixture", 1 / 8)):
            rounds = 1 / rate
            sum_tv = (wF / 2) * rounds
            # regret along the driver's runs: posterior draw: w(P) * (1/2) ln(1/w(P)) per round; mixture: (1/2) ln(1/w(P))
            weighted = wP * 0.5 * math.log(1 / wP) * rounds
            print(f"   {K:4d}   {driver:15s} {rate:18.3e} {rounds:22.1f} {sum_tv:24.1f} {weighted:28.4f} {4 * K * math.log(2):16.4f}")
            if driver == "posterior draw":
                assert abs(weighted - 4 * K * math.log(2)) < 1e-9
    # comparison with the bound of Theorem R2 (stochastic human) summed over n rounds, for K = 10 and n = 8 * 2^K
    K = 10
    n = 8 * 2 ** K
    wP = 2.0 ** (-K)
    actual = (1 - wP) / 2 * (1 - (1 - wP / 8) ** n) / (wP / 8)
    r2 = 2 * math.sqrt(n * 4 * K * math.log(2))                      # sum over t <= n of 2 sqrt(L K ln2 / n)
    print(f"   K = 10, n = {n} rounds, posterior-draw driver: E[sum_t TV(Q_M^(t), Q_P)] = {actual:.0f}; "
          f"the bound of Theorem R2 for the mixture driver, n * 2 sqrt(L K ln2 / n) = {r2:.0f}")
    assert actual > r2




# ---------------------------------------------------------------- (D) referee's proposition: squared weights
def part_D():
    """One program for a stochastic human from the data of Protocol R, with the weights squared.
    Proposition (referee). Mixture-driven rehearsal, n rounds, human P in H, K = log2(1/w(P)).
    Pi_2(nu | D_n) is proportional to w(nu)^2 nu(D_n). For nu_hat drawn from Pi_2, or maximising w^2 * likelihood:
      (a) with prob >= 1 - delta:  sum_t h_t(nu_hat) < K ln 2 + ln(1/delta),
          h_t(nu) := (1/L) E_{Q_M^(t)} sum_j H^2(nu, P)(x_j);
      (b) with prob >= 1 - 2 delta:  H^2(Q_nu_hat, Q_P) < [8 L (K ln 2 + ln(1/delta)) + 32 L^2 K ln 2 / delta] / n.
    """
    import numpy as np
    print("(D) squared weights (referee's proposition)")
    # D1: the families of Example 3.1 and Proposition 3.2 under squared weights, exactly
    for eps, NZ in ((Fr(1, 2), 3), (Fr(1, 10), 3), (Fr(1, 4), 4)):
        P = {1: 1 - eps, 0: eps}
        funcs = list(itertools.product((0, 1), repeat=NZ))
        prior = {s: Fr(1, 2) * math.prod(P[s[z]] for z in range(NZ)) for s in funcs}
        for k in range(0, 3):
            for zs in itertools.permutations(range(NZ), k):
                for ys in itertools.product((0, 1), repeat=k):
                    f2 = sum(prior[s] ** 2 for s in funcs if all(s[z] == y for z, y in zip(zs, ys)))
                    p2 = Fr(1, 4) * math.prod(P[y] for y in ys)
                    closed = math.prod(P[y] for y in ys) * (eps ** 2 + (1 - eps) ** 2) ** (NZ - k)
                    assert f2 / p2 == closed
    print("   Example 3.1 with weights w^2: (posterior mass of F)/(posterior mass of P) = prod_i P(y_i|z_i) * (eps^2+(1-eps)^2)^(#fresh inputs), exactly;")
    print(f"      for eps = 1/2 and N_z = 1600 (the class built for n = 40 rounds) this is 2^-1600; at weights w it is 1.")
    for R in (2, 3):
        size = (R * 2 * 4 ** (R - 1)) ** 2
        print(f"   Proposition 3.2 with weights w^2, N_z = 2, R = {R}: the odds of F against P are at most (odds at weights w)/|F| = (odds at weights w)/{size}")

    # D2: Monte Carlo of Protocol R on random classes of samplers with binary answers
    rng = np.random.default_rng(11)

    def make_instance(L, nz=4, nx=8, m=40):
        pz = rng.dirichlet(np.ones(nz))
        X1 = rng.integers(0, nx, nz)
        X2 = rng.integers(0, nx, (nz, 2))
        X3 = rng.integers(0, nx, (nz, 2, 2))
        stop2 = rng.random((nz, 2)) < 0.15                 # some runs stop after one call
        p = np.empty((m, nx))
        p[0] = rng.choice([0.1, 0.3, 0.5, 0.7, 0.9, 1.0], nx)        # the human; deterministic at some inputs
        for i in range(1, m):
            kind = i % 4
            if kind == 0:                                  # a fill-in: a function drawn from the human's law
                p[i] = (rng.random(nx) < p[0]).astype(float)
            elif kind == 1:                                # the human with a few inputs changed
                p[i] = p[0].copy()
                idx = rng.random(nx) < 0.3
                p[i][idx] = rng.random(idx.sum())
            elif kind == 2:                                # a slightly tilted human
                p[i] = np.clip(p[0] + rng.normal(0, 0.1, nx), 0.0, 1.0)
            else:
                p[i] = rng.random(nx)
        w = rng.dirichlet(np.ones(m) * 0.3)
        w[0] = max(w[0], 0.2)                              # K at most log2(5) + a little
        w = w / w.sum()
        return L, pz, X1, X2, X3, stop2, p, w

    def run_laws(inst):
        """Exact run laws: array (m, number of (z, answers) cells) of probabilities, for H^2(Q_nu, Q_P)."""
        L, pz, X1, X2, X3, stop2, p, w = inst
        cells = []
        for z in range(len(pz)):
            for y1 in (0, 1):
                q1 = np.where(y1, p[:, X1[z]], 1 - p[:, X1[z]])
                if L == 1 or stop2[z, y1]:
                    cells.append(pz[z] * q1)
                    continue
                for y2 in (0, 1):
                    q2 = np.where(y2, p[:, X2[z, y1]], 1 - p[:, X2[z, y1]])
                    if L == 2:
                        cells.append(pz[z] * q1 * q2)
                        continue
                    for y3 in (0, 1):
                        q3 = np.where(y3, p[:, X3[z, y1, y2]], 1 - p[:, X3[z, y1, y2]])
                        cells.append(pz[z] * q1 * q2 * q3)
        return np.array(cells).T

    def visit_measure(inst, M):
        """d(x) = expected number of calls at input x of a run answered by the sampler M (M[x] = Pr[answer 1])."""
        L, pz, X1, X2, X3, stop2, p, w = inst
        d = np.zeros(p.shape[1])
        for z in range(len(pz)):
            x1 = X1[z]
            d[x1] += pz[z]
            if L == 1:
                continue
            for y1 in (0, 1):
                if stop2[z, y1]:
                    continue
                q1 = M[x1] if y1 else 1 - M[x1]
                x2 = X2[z, y1]
                d[x2] += pz[z] * q1
                if L == 2:
                    continue
                for y2 in (0, 1):
                    q2 = M[x2] if y2 else 1 - M[x2]
                    d[X3[z, y1, y2]] += pz[z] * q1 * q2
        return d

    print("   Protocol R on random classes (40 samplers: the human, fill-ins, patched and tilted humans, random samplers):")
    print("      L   K(bits)     n  delta  trials   E[Pi_2(sum_t h_t >= a)]  (<= delta)   freq[2-MAP in that set]   "
          "bound (b)   E[Pi_2(H^2(Q_nu,Q_P) >= bound)]  (<= 2 delta)   E[Pi_1(same set)]   mean H^2 of a Pi_2 draw   of a Pi_1 draw")
    for L, n, delta, trials in ((1, 400, 0.25, 60), (2, 1500, 0.25, 40), (3, 3000, 0.25, 30)):
        inst = make_instance(L)
        L, pz, X1, X2, X3, stop2, p, w = inst
        m = len(w)
        K = -math.log2(w[0])
        a = K * math.log(2) + math.log(1 / delta)
        g = 1 - np.sqrt(p * p[0]) - np.sqrt((1 - p) * (1 - p[0]))     # H^2(nu, P)(x), shape (m, nx)
        laws = run_laws(inst)
        assert np.allclose(laws.sum(1), 1.0)
        H2 = 1 - np.sqrt(laws * laws[0]).sum(1)                       # exact H^2(Q_nu, Q_P)
        bound_b = (8 * L * a + 32 * L * L * K * math.log(2) / delta) / n
        acc_a = acc_map = acc_b = acc_b1 = mean2 = mean1 = 0.0
        for _ in range(trials):
            loglik = np.zeros(m)
            sum_h = np.zeros(m)
            with np.errstate(divide="ignore"):
                logw = np.log(w)
                for t in range(n):
                    post = np.exp(logw + loglik - (logw + loglik).max())
                    post /= post.sum()
                    M = post @ p
                    sum_h += g @ visit_measure(inst, M) / L
                    # one run of the mixture and one question
                    z = rng.choice(len(pz), p=pz)
                    xs = [X1[z]]
                    y1 = int(rng.random() < M[xs[0]])
                    if L >= 2 and not stop2[z, y1]:
                        xs.append(X2[z, y1])
                        y2 = int(rng.random() < M[xs[1]])
                        if L >= 3:
                            xs.append(X3[z, y1, y2])
                    J = rng.integers(1, L + 1)
                    if J <= len(xs):
                        x = xs[J - 1]
                        y = rng.random() < p[0, x]
                        loglik += np.log(p[:, x] if y else 1 - p[:, x])
                def posterior(lam):
                    s = lam * logw + loglik
                    q = np.exp(s - s.max())
                    return q / q.sum()
                pi2, pi1 = posterior(2.0), posterior(1.0)
            acc_a += pi2[sum_h >= a].sum()
            acc_map += float(sum_h[int(np.argmax(pi2))] >= a)
            acc_b += pi2[H2 >= bound_b].sum()
            acc_b1 += pi1[H2 >= bound_b].sum()
            mean2 += pi2 @ H2
            mean1 += pi1 @ H2
        assert acc_a / trials <= delta and acc_b / trials <= 2 * delta and acc_map / trials <= delta
        print(f"   {L:4d} {K:8.2f} {n:6d} {delta:5.2f} {trials:6d} {acc_a / trials:18.5f} {acc_map / trials:30.3f} {bound_b:20.4f}"
              f" {acc_b / trials:22.5f} {acc_b1 / trials:32.5f} {mean2 / trials:20.6f} {mean1 / trials:16.6f}")

    # D3: the supermartingale of step (a), exactly: E[N_n(nu)] <= 1 with
    #     N_n(nu) = prod_t sqrt(nu(y_t|x_t)/P(y_t|x_t)) * exp(h_t(nu)), by enumeration of all data sequences
    print("   exact expectation of N_n(nu) = prod_t sqrt(nu(y_t|x_t)/P(y_t|x_t)) exp(h_t(nu)) over all data sequences (L = 2, n = 4):")
    for trial in range(3):
        inst = make_instance(2, nz=2, nx=4, m=6)
        L, pz, X1, X2, X3, stop2, p, w = inst
        m = len(w)
        g = 1 - np.sqrt(p * p[0]) - np.sqrt((1 - p) * (1 - p[0]))
        EN = np.zeros(m)
        total = 0.0
        npaths = 0

        def rec(t, prob, lik, N):
            nonlocal total, npaths
            if t == 4:
                EN[:] += prob * N
                total += prob
                npaths += 1
                return
            post = w * lik
            post = post / post.sum()
            M = post @ p
            h = g @ visit_measure(inst, M) / L
            Nh = N * np.exp(h)
            for z in range(len(pz)):
                for y1 in (0, 1):
                    q1 = M[X1[z]] if y1 else 1 - M[X1[z]]
                    if q1 == 0:
                        continue
                    xs = [X1[z]] + ([] if stop2[z, y1] else [X2[z, y1]])
                    for J in (1, 2):
                        pr = prob * pz[z] * q1 / L
                        if J > len(xs):
                            rec(t + 1, pr, lik, Nh)
                            continue
                        x = xs[J - 1]
                        for y in (0, 1):
                            py = p[0, x] if y else 1 - p[0, x]
                            if py == 0:
                                continue
                            ly = p[:, x] if y else 1 - p[:, x]
                            rec(t + 1, pr * py, lik * ly, Nh * np.sqrt(ly / py))

        rec(0, 1.0, np.ones(m), np.ones(m))
        assert abs(total - 1) < 1e-9 and EN.max() <= 1 + 1e-9 and abs(EN[0] - 1) < 1e-9
        print(f"      instance {trial}: {npaths} data sequences; E[N_4(nu)] for nu != P between {EN[1:].min():.5f} and {EN[1:].max():.5f} (<= 1); for P it is {EN[0]:.6f}")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()
    print("all assertions passed")
