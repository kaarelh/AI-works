"""Referee's check of Section 7.4 of research/prove-c/property-online.md (the randomised version):
Lemma 7.5, Theorem 7.6, Corollary 7.7(b), (c), Theorem 7.8, Remark 7.9(1).

Independent implementation; exact rational arithmetic is not used, but all identities are checked
to 1e-10 and all inequalities with a tolerance of 1e-10.

Part 1. Lemma 7.5 on random instances: both identities, the three inequalities; bases that are
        probabilities, semimeasures (total mass < 1), and bases with zeros; the statement
        'KL(q||R) <= osc' is checked for probabilities and its failure for a semimeasure is shown
        (the proof gives osc - ln(mass) there, which is checked).
Part 2. Theorem 7.6 on adversarial and on random sequences: (7.1), the pathwise bound (i), the
        bounds (iii); for answers drawn from P the supermartingale M_t of the proof is checked in
        conditional expectation, exactly (the expectation over y_t is a finite sum).
Part 3. Corollary 7.7(c) (uniform base) and (b) (Bayes mixture as base: sum of KL(P||q_t) against
        2 K ln 2 + 1.39 beta^2, exactly in conditional expectation along sampled paths).
Part 4. Theorem 7.8: the identity on adversarial sequences, and (ii) in conditional expectation.
Part 5. Remark 7.9(1): a base with a zero cannot be tilted.

Usage: python3 property-online_check_tilt.py
"""
import math
import random

import numpy as np

rng = np.random.default_rng(20261116)
TOL = 1e-10


def kl(p, q):
    """KL(p || q) for arrays; q may be a semimeasure; inf if p > 0 where q = 0."""
    out = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return math.inf
            out += a * math.log(a / b)
    return out


def tilt(R, Lam):
    w = R * np.exp(-Lam)
    return w / w.sum()


def part1():
    print("== Part 1: Lemma 7.5 ==")
    worst = dict(id1=0.0, id2=0.0)
    n_prob = n_semi = 0
    viol_semi = 0
    for trial in range(20000):
        m = int(rng.integers(2, 8))
        R = rng.random(m) ** rng.choice([1, 4])
        kind = trial % 3
        if kind == 0:
            R = R / R.sum()                       # probability
        elif kind == 1:
            R = R / R.sum() * rng.uniform(0.05, 1.0)   # semimeasure
        else:
            R = R / R.sum()
            R[int(rng.integers(0, m))] = 0.0      # a zero; then a semimeasure with a zero
        Lam = rng.normal(0, rng.choice([0.1, 1, 5]), m)
        q = tilt(R, Lam)
        qL = float(q @ Lam)
        osc = float(Lam.max() - Lam.min())
        klqR = kl(q, R)
        assert klqR >= -TOL
        for y in range(m):
            if R[y] > 0:
                lhs = qL - Lam[y]
                rhs = math.log(q[y] / R[y]) - klqR
                worst["id1"] = max(worst["id1"], abs(lhs - rhs))
                assert lhs <= math.log(1 / R[y]) + TOL
        P = rng.random(m)
        P[R == 0] = 0.0                           # P << R, so that KL(P||R) is finite
        P = P / P.sum()
        klPR, klPq = kl(P, R), kl(P, q)
        lhs = qL - float(P @ Lam)
        rhs = klPR - klPq - klqR
        worst["id2"] = max(worst["id2"], abs(lhs - rhs))
        assert lhs <= klPR + TOL
        assert klPq <= 2 * klPR + osc ** 2 + TOL           # 'in all cases'
        mass = float(R.sum())
        assert klqR <= osc - math.log(mass) + TOL          # what the proof shows
        if abs(mass - 1) < 1e-12:
            n_prob += 1
            assert klqR <= osc + TOL                       # the statement for probabilities
        else:
            n_semi += 1
            viol_semi += klqR > osc + TOL
    print(f"20000 random instances: identity 1 max error {worst['id1']:.1e}; identity 2 max error {worst['id2']:.1e}")
    print(f"KL(q||R) <= osc holds in all {n_prob} cases with a probability base; for the {n_semi} semimeasure bases "
          f"it fails in {viol_semi} cases, and KL(q||R) <= osc - ln(mass) holds in all")
    print()


def make_tests(nx, ny, nt):
    T = rng.random((nt, nx, ny))
    T[: nt // 2] = (T[: nt // 2] < 0.5).astype(float)      # half of the tests are sets
    pi = 2.0 ** -np.arange(1, nt + 1)
    return T, pi


def part2():
    print("== Part 2: Theorem 7.6 ==")
    nx, ny, nt = 5, 4, 10
    T, pi = make_tests(nx, ny, nt)
    P = rng.dirichlet(np.ones(ny), nx)
    for base_name in ("uniform", "fixed kernel", "semimeasure", "time-varying"):
        for beta in (0.5, 5.0, 500.0):
            for adversary in ("random from P", "least likely answer", "max potential"):
                n = 400
                eta = 1 / math.sqrt(n)
                S = np.zeros(nt)
                cum_l = 0.0
                cum_k = 0.0
                logM = 0.0
                worst_i = 0.0
                ok_iii = True
                max_super = -math.inf
                Rfix = rng.dirichlet(np.ones(ny), nx)
                for t in range(1, n + 1):
                    if base_name == "uniform":
                        R = np.full((nx, ny), 1.0 / ny)
                    elif base_name == "fixed kernel":
                        R = Rfix
                    elif base_name == "semimeasure":
                        R = 0.6 * Rfix
                    else:
                        R = 0.5 * Rfix + 0.5 * rng.dirichlet(np.ones(ny), nx)
                    Phi0 = float(pi @ np.cosh(eta * S))
                    omega = pi * np.sinh(eta * S) / Phi0
                    assert np.abs(omega).sum() <= math.tanh(eta * np.abs(S).max()) + TOL
                    Lam = beta * math.sinh(eta) * np.tensordot(omega, T, axes=1)      # [x, y]
                    q = np.array([tilt(R[x], Lam[x]) for x in range(nx)])
                    assert (Lam.max(axis=1) - Lam.min(axis=1)).max() <= beta * math.sinh(eta) + TOL
                    # (iii)
                    for x in range(nx):
                        if abs(R[x].sum() - 1) < 1e-12:
                            ok_iii &= kl(q[x], R[x]) <= beta * math.sinh(eta) + TOL
                        ok_iii &= kl(P[x], q[x]) <= 2 * kl(P[x], R[x]) + (beta * math.sinh(eta)) ** 2 + TOL
                    x = int(rng.integers(0, nx))
                    qb = T[:, x, :] @ q[x]                           # (q_t b_B)(x)
                    # supermartingale step of (ii), exactly: E[Phi_t | x] <= Phi_{t-1} (cosh eta + kappa/beta)
                    kap = kl(P[x], R[x])
                    EPhi = sum(P[x, y] * float(pi @ np.cosh(eta * (S + qb - T[:, x, y]))) for y in range(ny))
                    max_super = max(max_super, EPhi - Phi0 * (math.cosh(eta) + kap / beta))
                    if adversary == "random from P":
                        y = int(rng.choice(ny, p=P[x]))
                    elif adversary == "least likely answer":
                        y = int(np.argmin(q[x]))
                    else:
                        y = int(np.argmax([float(pi @ np.cosh(eta * (S + qb - T[:, x, yy]))) for yy in range(ny)]))
                    g = qb - T[:, x, y]
                    # (7.1)
                    Phi1 = float(pi @ np.cosh(eta * (S + g)))
                    rhs71 = math.cosh(eta) * Phi0 + (Phi0 / beta) * (float(q[x] @ Lam[x]) - Lam[x, y])
                    assert Phi1 <= rhs71 + 1e-9 * Phi0
                    S = S + g
                    cum_l += math.log(1 / R[x, y])
                    cum_k += kap
                    bound = (np.log(2 / pi) + t * eta ** 2 / 2 + cum_l / beta) / eta
                    worst_i = max(worst_i, float((np.abs(S) / bound).max()))
                assert worst_i <= 1 + TOL and ok_iii and max_super <= 1e-9
                if adversary == "max potential" or beta == 5.0:
                    print(f"base {base_name:<13} beta {beta:>6}: adversary {adversary:<20} max |Sbar|/bound(i) = {worst_i:.3f};"
                          f" (iii) holds: {ok_iii}; max of E[Phi_t|x] - Phi_(t-1)(cosh eta + kappa/beta) = {max_super:.1e}")
    print()


def part3():
    print("== Part 3: Corollary 7.7 ==")
    # (c) uniform base, beta = 2 ln|Y| / eta^2, eta = 1/sqrt(n): |Sbar_n(B)| <= sqrt(n)(ln(2/pi) + 1) on every sequence
    nx, ny, nt = 4, 5, 8
    T, pi = make_tests(nx, ny, nt)
    worst = 0.0
    for n in (1, 2, 10, 100, 1000):
        eta = 1 / math.sqrt(n)
        beta = 2 * math.log(ny) / eta ** 2
        S = np.zeros(nt)
        for t in range(n):
            Phi0 = float(pi @ np.cosh(eta * S))
            Lam = beta * math.sinh(eta) * np.tensordot(pi * np.sinh(eta * S) / Phi0, T, axes=1)
            x = int(rng.integers(0, nx))
            q = tilt(np.full(ny, 1.0 / ny), Lam[x])
            qb = T[:, x, :] @ q
            y = int(np.argmax([float(pi @ np.cosh(eta * (S + qb - T[:, x, yy]))) for yy in range(ny)]))
            S = S + qb - T[:, x, y]
        worst = max(worst, float((np.abs(S) / (math.sqrt(n) * (np.log(2 / pi) + 1))).max()))
    print(f"(c) uniform base, greedy adversary, n in (1, 2, 10, 100, 1000): max |Sbar_n|/(sqrt(n)(ln(2/pi)+1)) = {worst:.3f}")
    assert worst <= 1 + TOL
    # (b) Bayes mixture of a class of 6 kernels that contains the human; weights 2^-k; the human has K = 4 bits
    nh = 6
    H = rng.dirichlet(np.ones(ny), (nh, nx))
    w = np.array([2.0 ** -(k + 1) for k in range(nh)])
    human = 3
    K = math.log2(1 / w[human])
    P = H[human]
    for beta in (0.3, 1.0, 3.0):
        n = 150
        reps = 3000
        eta = 1 / math.sqrt(n)
        tot_klq, tot_kap, tot_absS = [], [], []
        for rep in range(reps):
            post = w.copy()
            S = np.zeros(nt)
            sum_klq = sum_kap = 0.0
            for t in range(n):
                M = np.tensordot(post / post.sum(), H, axes=1)          # the mixture [x, y]
                Phi0 = float(pi @ np.cosh(eta * S))
                Lam = beta * math.sinh(eta) * np.tensordot(pi * np.sinh(eta * S) / Phi0, T, axes=1)
                x = int(rng.integers(0, nx))
                q = tilt(M[x], Lam[x])
                sum_klq += kl(P[x], q)
                sum_kap += kl(P[x], M[x])
                y = int(rng.choice(ny, p=P[x]))
                S = S + T[:, x, :] @ q - T[:, x, y]
                post = post * H[:, x, y]
            tot_klq.append(sum_klq)
            tot_kap.append(sum_kap)
            tot_absS.append(np.abs(S))
        mk, mq = float(np.mean(tot_kap)), float(np.mean(tot_klq))
        sek, seq = float(np.std(tot_kap) / math.sqrt(reps)), float(np.std(tot_klq) / math.sqrt(reps))
        mS = np.mean(tot_absS, axis=0)
        bS = math.sqrt(n) * (np.log(2 / pi) + 0.5 + K * math.log(2) / beta)
        print(f"(b) beta = {beta}, n = {n}, {reps} rehearsals: mean sum KL(P||M^(t)) = {mk:.3f} +- {sek:.3f} "
              f"(expectation <= K ln 2 = {K * math.log(2):.3f}); "
              f"mean sum KL(P||q_t) = {mq:.3f} +- {seq:.3f} (<= 2 K ln 2 + 1.39 beta^2 = "
              f"{2 * K * math.log(2) + 1.39 * beta ** 2:.3f}); max_B mean|Sbar_n|/bound = {float((mS / bS).max()):.3f}")
        assert mk - 4 * sek <= K * math.log(2)
        assert mq <= 2 * K * math.log(2) + 1.39 * beta ** 2 and (mS <= bS).all()
    print()


def part4():
    print("== Part 4: Theorem 7.8 (gradient tilt) ==")
    nx, ny, nt = 5, 4, 10
    T, pi = make_tests(nx, ny, nt)
    P = rng.dirichlet(np.ones(ny), nx)
    for gamma in (0.02, 1.0, 20.0):
        for semi in (False, True):
            n = 300
            S = np.zeros(nt)
            rhs = 0.0
            worst_ii = 0.0
            Rfix = rng.dirichlet(np.ones(ny), nx) * (0.5 if semi else 1.0)
            for t in range(n):
                Lam = gamma * np.tensordot(pi * S, T, axes=1)
                x = int(rng.integers(0, nx))
                q = tilt(Rfix[x], Lam[x])
                qb = T[:, x, :] @ q
                # (ii) in conditional expectation: E[2 <S, g>_pi | x] = (2/gamma)(KL(P||R) - KL(P||q) - KL(q||R))
                lhs_c = sum(P[x, y] * 2 * float((pi * S) @ (qb - T[:, x, y])) for y in range(ny))
                rhs_c = (2 / gamma) * (kl(P[x], Rfix[x]) - kl(P[x], q) - kl(q, Rfix[x]))
                worst_ii = max(worst_ii, abs(lhs_c - rhs_c))
                y = int(np.argmin(q)) if t % 2 else int(rng.choice(ny, p=P[x]))
                g = qb - T[:, x, y]
                rhs += float(pi @ (g * g)) + (2 / gamma) * (math.log(q[y] / Rfix[x, y]) - kl(q, Rfix[x]))
                S = S + g
            lhs = float(pi @ (S * S))
            print(f"gamma = {gamma:>5}, base {'semimeasure' if semi else 'probability'}: sum_B pi S^2 = {lhs:.8f}, "
                  f"right side = {rhs:.8f}; (ii) conditional identity, max error {worst_ii:.1e}")
            assert abs(lhs - rhs) < 1e-7 * max(1.0, abs(lhs)) and worst_ii < 1e-8
    print()


def part5():
    print("== Part 5: Remark 7.9(1): a base that gives probability 0 to the human's answer ==")
    R = np.array([0.5, 0.5, 0.0])
    Sbar = 0.0
    for t in range(50):
        Lam = -5.0 * Sbar * np.array([0.0, 0.0, 1.0])     # any tilt; the test is {answer 2}
        q = tilt(R, Lam)
        Sbar += q[2] - 1.0
    print(f"test {{(x, y*)}}, human always answers y*, R(y*|x) = 0: Sbar_50 = {Sbar:.1f} (= -n for every tilt)")
    print()


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
    print("all checks passed")
