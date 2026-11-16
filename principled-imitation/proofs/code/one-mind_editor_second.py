"""Editor's checks of the second round for part one-mind (proofs/one-mind.md), 16 November 2026.

Written without using code from any earlier script of this part. Everything is exact:
full enumeration of runs, of data paths and of classes. There is no Monte Carlo; the
random number generators only draw the instances. Floats, with the tolerance TOL.

Parts
  T1  Theorem 3.8 and Remark 3.9: every data path of a mixture-driven rehearsal of n rounds is
      enumerated with its probability. Hypotheses may be semimeasures, the inputs depend on the
      answers, runs have variable length. Checked: the supermartingales of Steps 1 and 3 (means
      at most 1), E[S] <= delta*W, E[Pi_2(A)] <= delta, Pr[a member of A beats P] <= delta,
      the event of (b), the inequality of Step 4 at every data state, the inequality of Step 5
      on every path, and Remark 3.9 in the same way with the prior's own weights.
  T2  Proposition 3.5(a) for a rehearsal driven by posterior draws (exact, by dynamic programming
      over the data): the sum of E[w_t(P) KL(Q_P || Q_M^(t))], the chain rule, the per-round
      inequality, the supermartingale 1/w_t(P) and the maximal inequality.
      Proposition 3.5(b): the class F'_z for R = 2 and R = 3, statements (i) to (iv).
  T3  Example 3.6: the probability that some function of a random codebook fits the data, by
      enumeration of all codebooks on the asked inputs; where the square wins (part (b)).
  T4  Remark 3.7(i): with a repeated input the member of largest posterior weight of Example 3.1
      can be a function; with distinct inputs it is P.
  T5  Definition 4.1, Proposition 4.6, Corollary 4.4 and Remark 4.5 by brute force over all
      top-level inputs; Proposition 4.3(b) after any at most n questions (exact dynamic programme).
  T6  Proposition 5.7 by enumeration of every data path of a rehearsal driven by posterior draws.
  T7  Small facts used in the decisions on the note's text (findings N1, N7, N10) and arithmetic.

Run:  python3 one-mind_editor_second.py > one-mind_editor_second.out     (about two minutes)
"""
import itertools
import math
import random

import numpy as np

LN2 = math.log(2.0)
TOL = 1e-9
FAILED = []


def check(cond, what):
    if not cond:
        FAILED.append(what)
        print("   !!! FAILED:", what)


# --------------------------------------------------------------------------------------------
# A scaffold as an explicit tree. Answers are 0 .. A-1; the last one is "no answer" (bottom).
# --------------------------------------------------------------------------------------------
class Tree:
    def __init__(self, mu, L, table, nx, A):
        self.mu, self.L, self.table, self.nx, self.A = mu, L, table, nx, A

    def nxt(self, z, ys):
        if len(ys) >= self.L:
            return -1
        return self.table[(z, ys)]


def random_tree(rng, nz, nx, A, L, stop):
    mu = [rng.random() + 0.2 for _ in range(nz)]
    s = sum(mu)
    mu = [m / s for m in mu]
    table = {}
    for z in range(nz):
        for d in range(L):
            for ys in itertools.product(range(A), repeat=d):
                if d > 0 and table[(z, ys[:-1])] < 0:
                    table[(z, ys)] = -1          # below a STOP nothing is asked
                elif d > 0 and rng.random() < stop:
                    table[(z, ys)] = -1
                else:
                    table[(z, ys)] = rng.randrange(nx)
    return Tree(mu, L, table, nx, A)


def visits(tr, S):
    """Expected number of calls at each input in a run answered by the kernel S (nx x A)."""
    v = np.zeros(tr.nx)

    def rec(z, ys, p):
        x = tr.nxt(z, ys)
        if x < 0:
            return
        v[x] += p
        for y in range(tr.A):
            q = S[x, y]
            if q > 0.0:
                rec(z, ys + (y,), p * q)

    for z, m in enumerate(tr.mu):
        rec(z, (), m)
    return v


def bc_runs(tr, S1, S2):
    """Bhattacharyya coefficient of the two run laws (same marginal on z)."""
    def rec(z, ys):
        x = tr.nxt(z, ys)
        if x < 0:
            return 1.0
        tot = 0.0
        for y in range(tr.A):
            c = S1[x, y] * S2[x, y]
            if c > 0.0:
                tot += math.sqrt(c) * rec(z, ys + (y,))
        return tot

    return sum(m * rec(z, ()) for z, m in enumerate(tr.mu))


def kl_runs(tr, P, M):
    """KL(Q_P || Q_M) by enumeration of the runs of P."""
    tot = 0.0

    def rec(z, ys, p, logratio):
        nonlocal tot
        x = tr.nxt(z, ys)
        if x < 0:
            tot += p * logratio
            return
        for y in range(tr.A):
            a = P[x, y]
            if a > 0.0:
                rec(z, ys + (y,), p * a, logratio + math.log(a / M[x, y]))

    for z, m in enumerate(tr.mu):
        rec(z, (), m, 0.0)
    return tot


def h2(p, q):
    return 1.0 - float(np.sqrt(p * q).sum())


def random_kernel(rng, nx, A, kind, P=None):
    """kind: 'sampler' (no mass on bottom), 'semi' (some mass on bottom), 'func', 'near' (close to P)."""
    S = np.zeros((nx, A))
    for x in range(nx):
        if kind == 'func':
            S[x, rng.randrange(A - 1)] = 1.0
        elif kind == 'near':
            e = np.array([rng.random() for _ in range(A - 1)])
            e /= e.sum()
            lam = rng.choice([0.1, 0.3, 0.6])
            S[x, :A - 1] = (1 - lam) * P[x, :A - 1] + lam * e
        else:
            e = np.array([rng.random() ** 2 + 0.02 for _ in range(A - 1)])
            e /= e.sum()
            miss = rng.uniform(0.05, 0.5) if kind == 'semi' else 0.0
            S[x, :A - 1] = (1 - miss) * e
            S[x, A - 1] = miss
    return S


# --------------------------------------------------------------------------------------------
# T1  Theorem 3.8 and Remark 3.9
# --------------------------------------------------------------------------------------------
def thm38(tr, hyps, w, n, deltas, label):
    """hyps[0] is the human P. Enumerates every data path of n rounds of the mixture-driven rehearsal."""
    L, nx, A = tr.L, tr.nx, tr.A
    H = np.array(hyps)                      # nh x nx x A
    nh = len(hyps)
    P = H[0]
    W = float(w.sum())
    Kln2 = math.log(1.0 / w[0])
    S_half = float(np.sqrt(w).sum())
    h2P = np.array([[h2(H[i, x], P[x]) for x in range(nx)] for i in range(nh)])
    H2run = np.array([1.0 - bc_runs(tr, H[i], P) for i in range(nh)])
    cache = {}
    st = dict(step4=0.0, c23a=0.0, c23b=0.0, e4=0.0, states=0)

    def info(key, lik):
        if key in cache:
            return cache[key]
        post = w * lik
        post = post / post.sum()
        M = np.tensordot(post, H, axes=1)
        v = visits(tr, M)
        h = (h2P @ v) / L
        kappa = float(sum(v[x] * h2(P[x], M[x]) for x in range(nx)))
        # Step 4 at this data state, with exact run laws
        HMP = 1.0 - bc_runs(tr, M, P)
        if kappa > 1e-13:
            st['c23b'] = max(st['c23b'], HMP / (4 * kappa))
        else:
            check(HMP < 1e-9, label + ": kappa = 0 but H2(Q_M, Q_P) > 0")
        for i in range(nh):
            sig = float(sum(v[x] * h2(M[x], H[i, x]) for x in range(nx)))
            HMnu = 1.0 - bc_runs(tr, M, H[i])
            check(sig <= 2 * L * h[i] + 2 * kappa + TOL, label + ": (E4) at the inputs")
            if sig > 1e-13:
                st['c23a'] = max(st['c23a'], HMnu / (4 * sig))
            else:
                check(HMnu < 1e-9, label + ": sigma = 0 but H2(Q_M, Q_nu) > 0")
            check(H2run[i] <= 2 * HMnu + 2 * HMP + TOL, label + ": (E4) for run laws")
            rhs = 16 * L * h[i] + 24 * kappa
            if rhs > 1e-13:
                st['step4'] = max(st['step4'], H2run[i] / rhs)
            else:
                check(H2run[i] < 1e-9, label + ": right side of Step 4 is 0, left side is not")
        st['states'] += 1
        cache[key] = (v, h, kappa)
        return cache[key]

    acc = dict(prob=0.0, EN=np.zeros(nh), ENp=0.0, step5=0.0, paths=0)
    per = {d: dict(ES=0.0, EPi2A=0.0, beat=0.0, b=0.0, c_max=0.0, c_draw=0.0,
                   post39=0.0, sum39=0.0, beat39=0.0, ctrl=0.0, ctrl_b=0.0) for d in deltas}

    def leaf(prob, lik, sum_h, sum_k):
        acc['paths'] += 1
        acc['prob'] += prob
        ratio = lik / lik[0]
        acc['EN'] += prob * np.sqrt(ratio) * np.exp(sum_h)
        xi = float((w * lik).sum())
        acc['ENp'] += prob * math.sqrt(xi / (W * lik[0])) * math.exp(sum_k / L)
        # Step 5 on this path, for every member
        rhs5 = (16 * L / n) * sum_h + (24 / n) * sum_k
        with np.errstate(divide='ignore', invalid='ignore'):
            r5 = np.where(rhs5 > 1e-13, H2run / np.maximum(rhs5, 1e-300), 0.0)
        acc['step5'] = max(acc['step5'], float(r5.max()))
        check(bool(np.all(H2run <= rhs5 + TOL)), label + ": Step 5 on a path")
        pi2 = w * w * lik
        post = w * lik
        best = pi2 >= pi2.max() * (1 - 1e-12)          # all maximisers of w^2 * likelihood
        for d in deltas:
            ln1d = math.log(1.0 / d)
            a = Kln2 + ln1d
            Aset = sum_h >= a - 1e-12
            s = (w / w[0]) * np.sqrt(ratio)
            S = float(s[Aset].sum())
            Pi2A = float(pi2[Aset].sum() / pi2.sum())
            check(Pi2A <= min(1.0, S * S) + TOL and min(1.0, S * S) <= S + TOL,
                  label + ": Pi_2(A) <= min(1, S^2) <= S")
            beat = bool(np.any(Aset & (pi2 >= pi2[0] * (1 - 1e-12))))
            check((not beat) or S >= 1 - 1e-9, label + ": a member of A that beats P gives S >= 1")
            q = per[d]
            q['ES'] += prob * S
            q['EPi2A'] += prob * Pi2A
            q['beat'] += prob * beat
            q['b'] += prob * (sum_k >= L * (0.5 * Kln2 + ln1d) - 1e-12)
            # controls (not claims of the theorem): the thresholds of (a) and (b) halved
            Ahalf = sum_h >= 0.5 * a - 1e-12
            q['ctrl'] += prob * max(float(pi2[Ahalf].sum() / pi2.sum()),
                                    float(np.any(Ahalf & (pi2 >= pi2[0] * (1 - 1e-12)) & (np.arange(nh) > 0))))
            q['ctrl_b'] += prob * (sum_k >= 0.5 * L * (0.5 * Kln2 + ln1d) - 1e-12)
            bound_c = L * (28 * Kln2 + 40 * ln1d) / n
            q['c_max'] += prob * bool(np.any(best & (H2run >= bound_c)))
            q['c_draw'] += prob * float(pi2[H2run >= bound_c].sum() / pi2.sum())
            # Remark 3.9: the prior's own weights
            a39 = 0.5 * Kln2 + math.log(S_half / d)
            A39 = sum_h >= a39 - 1e-12
            terms = np.sqrt(w / w[0]) * np.sqrt(ratio)
            postA = float(post[A39].sum() / post.sum())
            sm = float(terms[A39].sum())
            check(postA <= sm + TOL, label + ": Remark 3.9, posterior mass of A <= sum of roots")
            beat39 = bool(np.any(A39 & (post >= post[0] * (1 - 1e-12))))
            check((not beat39) or sm >= 1 - 1e-9, label + ": Remark 3.9, a member that beats P gives sum >= 1")
            q['post39'] += prob * postA
            q['sum39'] += prob * sm
            q['beat39'] += prob * beat39

    def rec(t, key, lik, prob, sum_h, sum_k):
        if t == n:
            leaf(prob, lik, sum_h, sum_k)
            return
        v, h, kappa = info(key, lik)
        p_none = 1.0 - float(v.sum()) / L
        if p_none > 1e-14:
            rec(t + 1, key, lik, prob * p_none, sum_h + h, sum_k + kappa)
        for x in range(nx):
            if v[x] <= 0.0:
                continue
            for y in range(A):
                if P[x, y] <= 0.0:
                    continue
                key2 = tuple(sorted(key + ((x, y),)))
                rec(t + 1, key2, lik * H[:, x, y], prob * v[x] / L * P[x, y], sum_h + h, sum_k + kappa)

    rec(0, (), np.ones(nh), 1.0, np.zeros(nh), 0.0)
    check(abs(acc['prob'] - 1.0) < 1e-9, label + ": path probabilities add to 1")
    check(bool(np.all(acc['EN'] <= 1 + TOL)), label + ": E[N_n(nu)] <= 1")
    check(acc['ENp'] <= 1 + TOL, label + ": E[N'_n] <= 1")
    out = dict(paths=acc['paths'], states=st['states'], ENmax=float(acc['EN'].max()), ENp=acc['ENp'],
               step4=st['step4'], c23=max(st['c23a'], st['c23b']), step5=acc['step5'], W=W, S_half=S_half)
    for d in deltas:
        q = per[d]
        check(q['ES'] <= d * W + TOL, label + ": E[S] <= delta W")
        check(q['EPi2A'] <= d + TOL, label + ": E[Pi_2(A)] <= delta")
        check(q['beat'] <= d + TOL, label + ": Pr[a member of A beats P] <= delta")
        check(q['b'] <= d + TOL, label + ": the event of (b)")
        check(q['c_max'] <= 2 * d + TOL and q['c_draw'] <= 2 * d + TOL, label + ": (c)")
        check(q['sum39'] <= d + TOL and q['post39'] <= d + TOL and q['beat39'] <= d + TOL, label + ": Remark 3.9")
    out['per'] = per
    return out


def T1():
    print("T1  Theorem 3.8 and Remark 3.9: all data paths of a mixture-driven rehearsal, exact")
    deltas = [0.9, 0.5, 0.2]
    rng = random.Random(20261116)
    worst = dict(ES=0.0, Pi2=0.0, beat=0.0, b=0.0, s39=0.0, p39=0.0, b39=0.0, EN=0.0, ENp=0.0,
                 step4=0.0, c23=0.0, step5=0.0, ctrl=0.0, ctrl_b=0.0)
    tot_paths = tot_states = 0
    ninst = 0

    def absorb(o):
        nonlocal tot_paths, tot_states, ninst
        ninst += 1
        tot_paths += o['paths']
        tot_states += o['states']
        worst['EN'] = max(worst['EN'], o['ENmax'])
        worst['ENp'] = max(worst['ENp'], o['ENp'])
        worst['step4'] = max(worst['step4'], o['step4'])
        worst['c23'] = max(worst['c23'], o['c23'])
        worst['step5'] = max(worst['step5'], o['step5'])
        for d, q in o['per'].items():
            worst['ES'] = max(worst['ES'], q['ES'] / (d * o['W']))
            worst['Pi2'] = max(worst['Pi2'], q['EPi2A'] / d)
            worst['beat'] = max(worst['beat'], q['beat'] / d)
            worst['b'] = max(worst['b'], q['b'] / d)
            worst['s39'] = max(worst['s39'], q['sum39'] / d)
            worst['p39'] = max(worst['p39'], q['post39'] / d)
            worst['b39'] = max(worst['b39'], q['beat39'] / d)
            worst['ctrl'] = max(worst['ctrl'], q['ctrl'] / d)
            worst['ctrl_b'] = max(worst['ctrl_b'], q['ctrl_b'] / d)

    # (i) random instances: inputs depend on the answers, variable length, semimeasures
    for it in range(24):
        L = rng.choice([1, 2, 3])
        nx = rng.choice([2, 3])
        A = 3                                     # two answers and bottom
        tr = random_tree(rng, rng.choice([1, 2]), nx, A, L, stop=0.25)
        P = random_kernel(rng, nx, A, 'sampler')
        kinds = [rng.choice(['sampler', 'semi', 'func', 'near', 'near']) for _ in range(rng.choice([2, 3, 4]))]
        hyps = [P] + [random_kernel(rng, nx, A, k, P) for k in kinds]
        wP = rng.choice([0.15, 0.4, 0.7])
        rest = np.array([rng.random() + 0.1 for _ in kinds])
        rest = rest / rest.sum() * (rng.choice([0.6, 1.0]) - wP if wP < 0.6 else 1.0 - wP)
        w = np.concatenate([[wP], rest])
        n = 6 if nx == 2 else 5
        absorb(thm38(tr, hyps, w, n, deltas, "T1 random %d" % it))
    print("    %d random instances (L = 1..3, 2 or 3 inputs, two answers and 'no answer', 3 to 5 hypotheses, n = 6 or 5)" % ninst)

    # (ii) coins on one input, L = 1: more rounds, so that the set A is not empty
    ncoin = 0
    for p in [0.5, 0.7, 0.9]:
        for q in [0.05, 0.3, 0.6, 0.95]:
            if abs(p - q) < 0.05:
                continue
            for wP in [0.05, 0.3, 0.7]:
                for n in [3, 5, 8, 12]:
                    tr = Tree([1.0], 1, {(0, ()): 0}, 1, 3)
                    P = np.array([[p, 1 - p, 0.0]])
                    Q = np.array([[q, 1 - q, 0.0]])
                    R = np.array([[0.5 * q, 0.3, 0.7 - 0.5 * q]])       # a semimeasure
                    w = np.array([wP, 0.7 * (1 - wP), 0.3 * (1 - wP)])
                    absorb(thm38(tr, [P, Q, R], w, n, deltas, "T1 coins"))
                    ncoin += 1
    print("    %d instances with three coins on one input (L = 1, n = 3, 5, 8, 12); %d data paths and %d data states in all"
          % (ncoin, tot_paths, tot_states))
    print("    largest E[N_n(nu)] = %.6f, largest E[N'_n] = %.6f   (Steps 1 and 3: at most 1)" % (worst['EN'], worst['ENp']))
    print("    Step 2, over delta in %s: largest E[S]/(delta W) = %.4f, E[Pi_2(A)]/delta = %.4f, Pr[a member of A beats P]/delta = %.4f"
          % (deltas, worst['ES'], worst['Pi2'], worst['beat']))
    print("    Step 3: largest Pr[sum kappa_t >= L(K ln2/2 + ln(1/delta))]/delta = %.4f" % worst['b'])
    print("    Step 4 at every data state: largest H2(Q_nu,Q_P)/(16 L h + 24 kappa) = %.4f; largest ratio in the two uses of Corollary 2.3 = %.4f"
          % (worst['step4'], worst['c23']))
    print("    Step 5 on every path and for every member: largest H2(Q_nu,Q_P)/((16L/n) sum h + (24/n) sum kappa) = %.4f" % worst['step5'])
    print("    Remark 3.9 (plain weights, a = K ln2/2 + ln(S_half/delta)): largest E[sum of roots]/delta = %.4f, E[posterior mass of A]/delta = %.4f, Pr[beats P]/delta = %.4f"
          % (worst['s39'], worst['p39'], worst['b39']))
    print("    controls, not claims: with the threshold of (a) halved the failure probability reaches %.2f delta, with that of (b) halved %.2f delta;"
          % (worst['ctrl'], worst['ctrl_b']))
    print("      so the enumerations above confirm the steps but would not notice a threshold wrong by a factor 2")
    # (iii) a sharper test of (a): two coins, one input, L = 1, weights of total 1; h_t = H2(q, p) in every round,
    #       so A = {the other coin} from the first n with n*H2 >= a on, and everything is a binomial sum
    def two_coins(pp, qq, wP, n, sq):
        lw = math.log((1 - wP) / wP) * (2 if sq else 1)
        mass = beat = 0.0
        for k in range(n + 1):
            lb = math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1) + k * math.log(pp) + (n - k) * math.log(1 - pp)
            lr = lw + k * math.log(qq / pp) + (n - k) * math.log((1 - qq) / (1 - pp))     # log of weight ratio times likelihood ratio
            pk = math.exp(lb)
            mass += pk / (1.0 + math.exp(-lr)) if lr > -700 else 0.0
            beat += pk * (lr >= -1e-12)
        return mass, beat
    w_a = w_ctrl = w_39 = 0.0
    ncase = 0
    for pp in [0.5, 0.7, 0.9, 0.99]:
        for qq in [0.02, 0.2, 0.4, 0.6, 0.8, 0.97]:
            hh = 1 - math.sqrt(pp * qq) - math.sqrt((1 - pp) * (1 - qq))
            if hh < 0.004:
                continue
            for wP in [0.5, 0.1, 0.01, 0.001]:
                for d in [0.5, 0.1, 0.01]:
                    a = math.log(1 / wP) + math.log(1 / d)
                    n1 = int(math.ceil(a / hh - 1e-12))
                    mass, beat = two_coins(pp, qq, wP, n1, True)
                    check(mass <= d + TOL and beat <= d + TOL, "T1 two coins, (a)")
                    w_a = max(w_a, mass / d, beat / d)
                    nh_ = max(1, int(math.ceil(0.5 * a / hh - 1e-12)))
                    mass, beat = two_coins(pp, qq, wP, nh_, True)
                    w_ctrl = max(w_ctrl, mass / d, beat / d)
                    s_half = math.sqrt(wP) + math.sqrt(1 - wP)
                    a39 = 0.5 * math.log(1 / wP) + math.log(s_half / d)
                    n39 = int(math.ceil(a39 / hh - 1e-12))
                    mass, beat = two_coins(pp, qq, wP, n39, False)
                    check(mass <= d + TOL and beat <= d + TOL, "T1 two coins, Remark 3.9")
                    w_39 = max(w_39, mass / d, beat / d)
                    ncase += 1
    print("    two coins on one input, binomial sums, %d cases (p, q, w(P) down to 0.001, delta down to 0.01), at the first n with n*H2 >= a:" % ncase)
    print("      largest of E[Pi_2(A)]/delta and Pr[the other coin beats P]/delta = %.4f; Remark 3.9 with the plain weights: %.4f; control with the threshold halved: %.1f (above 1: this test would notice)"
          % (w_a, w_39, w_ctrl))
    # constants
    c = 2.96414723
    print("    constants: 16 + 24/2 = %d, 16 + 24 = %d; with c* < 2.9642 in place of 4: 7c* = %.3f, 10c* = %.3f (stated: 21 and 30)"
          % (16 + 12, 40, 7 * c, 10 * c))
    check(16 + 12 == 28 and 7 * c <= 21 and 10 * c <= 30, "constants of Theorem 3.8")
    print("    Remark 3.9: 16/2 + 24/2 = %d; weights 1/B: S_half = sqrt(B), 20 + 16/2 = %d; equal weights c < 1/B give 12 ln(1/c) + 16 ln B, not 28 ln B"
          % (20, 28))
    for B in [2, 7, 100]:
        wts = np.array([random.Random(B).random() + 0.01 for _ in range(B)])
        wts = wts / wts.sum() * 0.9
        check(np.sqrt(wts).sum() <= math.sqrt(B * wts.sum()) + 1e-12 and abs(np.sqrt(np.ones(B) / B).sum() - math.sqrt(B)) < 1e-9,
              "S_half <= sqrt(B W), with equality for the weights 1/B")
    print("    for B hypotheses: S_half <= sqrt(B * W) <= sqrt(B) (Cauchy-Schwarz), with equality for the weights 1/B: checked for B = 2, 7, 100")


# --------------------------------------------------------------------------------------------
# T2  Proposition 3.5
# --------------------------------------------------------------------------------------------
def prop35a(tr, hyps, w, n, deltas, label):
    L, nx, A = tr.L, tr.nx, tr.A
    H = np.array(hyps)
    nh = len(hyps)
    P = H[0]
    W = float(w.sum())
    vis = np.array([visits(tr, H[i]) for i in range(nh)])        # nh x nx
    visP = vis[0]
    thr = {d: (1.0 / w[0]) / d for d in deltas}                    # 2^K / delta
    total = 0.0
    worst_round = 0.0
    frontier = {((), tuple(False for _ in deltas)): (1.0, np.ones(nh))}
    exceed = {d: 0.0 for d in deltas}
    for t in range(n):
        new = {}
        for (key, flags), (prob, lik) in frontier.items():
            post = w * lik
            post = post / post.sum()
            wP = post[0]
            flags = tuple(f or (1.0 / wP >= thr[d] * (1 - 1e-12)) for f, d in zip(flags, deltas))
            M = np.tensordot(post, H, axes=1)
            vbar = post @ vis
            klx = np.array([sum(P[x, y] * math.log(P[x, y] / M[x, y]) for y in range(A) if P[x, y] > 0) for x in range(nx)])
            KLrun = kl_runs(tr, P, M)
            check(abs(KLrun - float(visP @ klx)) < 1e-9, label + ": chain rule for KL along the runs of P")
            asked = float(vbar @ klx) / L
            check(asked >= wP * KLrun / L - TOL, label + ": per-round inequality of 3.5(a)")
            if asked > 1e-13:
                worst_round = max(worst_round, (wP * KLrun / L) / asked)
            total += prob * wP * KLrun
            # supermartingale 1/w_t(P)
            nxt = (1.0 - float(vbar.sum()) / L) * (1.0 / wP)
            p_none = 1.0 - float(vbar.sum()) / L
            if p_none > 1e-14:
                k2 = (key, flags)
                if k2 in new:
                    new[k2] = (new[k2][0] + prob * p_none, lik)
                else:
                    new[k2] = (prob * p_none, lik)
            for x in range(nx):
                if vbar[x] <= 0:
                    continue
                for y in range(A):
                    if P[x, y] <= 0:
                        continue
                    lik2 = lik * H[:, x, y]
                    post2 = w * lik2
                    nxt += vbar[x] / L * P[x, y] * (post2.sum() / post2[0])
                    k2 = (tuple(sorted(key + ((x, y),))), flags)
                    pr = prob * vbar[x] / L * P[x, y]
                    if k2 in new:
                        new[k2] = (new[k2][0] + pr, lik2)
                    else:
                        new[k2] = (pr, lik2)
            # relative tolerance: 1/w_t(P) reaches 4e7 on these instances, where an absolute 1e-9 is below rounding
            check(nxt <= (1.0 / wP) * (1 + 1e-12) + TOL, label + ": 1/w_t(P) is a supermartingale")
        frontier = new
    for (key, flags), (prob, lik) in frontier.items():
        post = w * lik
        wP = post[0] / post.sum()
        for f, d in zip(flags, deltas):
            if f or (1.0 / wP >= thr[d] * (1 - 1e-12)):
                exceed[d] += prob
    bound = L * math.log(W / w[0])
    check(total <= bound + TOL, label + ": sum of E[w_t(P) KL(Q_P||Q_M)] <= L ln(W/w(P))")
    for d in deltas:
        check(exceed[d] <= d * W + TOL, label + ": maximal inequality")
    return total / bound, worst_round, max(exceed[d] / d for d in deltas)


def fprime(R):
    """The members of F'_z of Proposition 3.5(b), as dictionaries input -> answer ('*' is the star)."""
    members = []
    free_pairs = [(r, b) for r in range(R) for b in (0, 1)]
    for rstar in range(R):
        others = [r for r in range(R) if r != rstar]
        for c in (0, 1):
            for bits in itertools.product((0, 1), repeat=2 * len(others)):
                for four in itertools.product((0, 1), repeat=len(free_pairs)):
                    s = {('z',): rstar, (rstar, 2): c, (rstar, 3): c}
                    for i, r in enumerate(others):
                        s[(r, 2)] = bits[2 * i]
                        s[(r, 3)] = bits[2 * i + 1]
                    for r in range(R):
                        for b in (0, 1):
                            for b2 in (0, 1):
                                s[(r, b, b2, 4)] = '*' if b != b2 else four[free_pairs.index((r, b))]
                    members.append(s)
    return members


def T2():
    print("T2  Proposition 3.5")
    rng = random.Random(35)
    deltas = [0.9, 0.5]
    worst_tot = worst_round = worst_max = 0.0
    ninst = 0
    for it in range(40):
        L = rng.choice([1, 2, 3])
        nx = rng.choice([2, 3])
        A = 3
        tr = random_tree(rng, rng.choice([1, 2, 3]), nx, A, L, stop=0.2)
        P = random_kernel(rng, nx, A, 'sampler')
        kinds = [rng.choice(['sampler', 'semi', 'near', 'near']) for _ in range(rng.choice([2, 3]))]
        hyps = [P] + [random_kernel(rng, nx, A, k, P) for k in kinds]
        wP = rng.choice([0.05, 0.3, 0.6])
        rest = np.array([rng.random() + 0.1 for _ in kinds])
        w = np.concatenate([[wP], rest / rest.sum() * (rng.choice([0.9, 1.0]) - wP)])
        a, b, c = prop35a(tr, hyps, w, 7, deltas, "T2 random %d" % it)
        worst_tot, worst_round, worst_max = max(worst_tot, a), max(worst_round, b), max(worst_max, c)
        ninst += 1
    print("    (a) %d random instances, posterior-draw driver, 7 rounds, exact over all data: largest sum_t E[w_t(P) KL(Q_P||Q_M^(t))] / (L ln(W/w(P))) = %.4f"
          % (ninst, worst_tot))
    print("        per round: largest (w_t(P)/L) KL(Q_P||Q_M) / (mean of the asked term) = %.4f; chain rule exact; 1/w_t(P) a supermartingale at every data state"
          % worst_round)
    print("        maximal inequality: largest Pr[sup_t 1/w_t(P) >= 2^K/delta]/delta = %.4f over delta in %s" % (worst_max, deltas))
    # (b): the class F'_z
    for R in (2, 3):
        mem = fprime(R)
        size = R * 2 * 4 ** (R - 1) * 2 ** (2 * R)
        check(len(mem) == size, "size of F'_z")
        ok_i = True
        cnt = {}
        for s in mem:
            for k_, v_ in s.items():
                cnt.setdefault(k_, {}).setdefault(v_, 0)
                cnt[k_][v_] += 1
        for k_, dist in cnt.items():
            if k_ == ('z',):
                ok_i &= all(abs(dist.get(r, 0) / len(mem) - 1.0 / R) < 1e-12 for r in range(R))
            elif len(k_) == 2 or (len(k_) == 4 and k_[1] == k_[2]):
                ok_i &= abs(dist.get(0, 0) / len(mem) - 0.5) < 1e-12 and abs(dist.get(1, 0) / len(mem) - 0.5) < 1e-12
            else:
                ok_i &= dist == {'*': len(mem)}
        ok_iii = all(s[(s[('z',)], 2)] == s[(s[('z',)], 3)] for s in mem)
        check(ok_i and ok_iii, "Proposition 3.5(b) (i), (ii), (iii)")
        # (iv): run law of the per-call mixture with posterior mass wF on F'_z, by enumeration of runs
        line = []
        for wF in (0.25, 0.5, 1 - 2.0 ** -5):
            def call_law(x):
                d = {}
                for v_, c_ in cnt[x].items():
                    d[v_] = d.get(v_, 0.0) + wF * c_ / len(mem)
                hum = [(r, 1.0 / R) for r in range(R)] if x == ('z',) else [(0, 0.5), (1, 0.5)]
                for v_, p_ in hum:
                    d[v_] = d.get(v_, 0.0) + (1 - wF) * p_
                return d
            QM, QP = {}, {}
            for r, pr in call_law(('z',)).items():
                for b, pb in call_law((r, 2)).items():
                    for b2, pb2 in call_law((r, 3)).items():
                        for y4, p4 in call_law((r, b, b2, 4)).items():
                            QM[(r, b, b2, y4)] = pr * pb * pb2 * p4
            for r in range(R):
                for b in (0, 1):
                    for b2 in (0, 1):
                        for y4 in (0, 1):
                            QP[(r, b, b2, y4)] = 1.0 / (R * 8)
            tv = 0.5 * sum(abs(QM.get(k_, 0.0) - QP.get(k_, 0.0)) for k_ in set(QM) | set(QP))
            kl = sum(p_ * math.log(p_ / QM[k_]) for k_, p_ in QP.items())
            check(abs(tv - wF / 2) < 1e-12 and abs(kl - 0.5 * math.log(1 / (1 - wF))) < 1e-12, "Proposition 3.5(b)(iv)")
            line.append("wF=%.4f: TV %.6f, KL %.6f" % (wF, tv, kl))
        print("    (b) R = %d: |F'_z| = %d; (i), (ii), (iii) hold for every member and input; (iv) %s" % (R, len(mem), "; ".join(line)))
    # the fresh-input chain, exactly
    for K in (1, 3, 6):
        wP = 2.0 ** -K
        alive = 1.0
        s = 0.0
        for t in range(1, 200000):
            s += alive * wP * 0.5 * K * LN2          # w_t(P) * KL(Q_P||Q_M) while F' lives
            alive *= 1 - wP / 8
        check(abs(s - 4 * K * LN2) < 1e-6 * 4 * K * LN2 + 1e-9, "equality in 3.5(a) on the chain")
        low = min(0.5 * (1 - wP) * (1 - 1 / (10 * (5 * 2 ** K))) * ((1 - wP / 8) ** (t - 1) - 1 / 20.0)
                  for t in range(1, 5 * 2 ** K + 2))
        check(low >= 0.07, "the bound 0.07")
        print("        K = %d, chain of fresh inputs: sum_t E[w_t(P) KL] = %.6f = L K ln2 = %.6f; expected life of F' = %d rounds; the lower bound at t <= 5*2^K+1 is at least %.4f"
              % (K, s, 4 * K * LN2, 8 * 2 ** K, low))


# --------------------------------------------------------------------------------------------
# T3  Example 3.6
# --------------------------------------------------------------------------------------------
def T3():
    print("T3  Example 3.6 (codebook class), exact")
    for (n, K) in [(2, 2), (3, 1), (2, 3), (3, 2)]:
        m = n + K - 2
        nf = 2 ** m
        # a codebook on the n asked (distinct) inputs is a list of nf strings of n bits
        if (2 ** n) ** nf <= 300000:
            tot = 0.0
            ncb = 0
            for cb in itertools.product(range(2 ** n), repeat=nf):
                tot += len(set(cb)) / 2.0 ** n          # fraction of answer strings matched by a function
                ncb += 1
            avg = tot / ncb
            how = "all %d codebooks" % ncb
        else:
            # too many codebooks to list: each string is missed by all nf functions with probability (1-2^-n)^nf
            avg = 1 - (1 - 2.0 ** -n) ** nf
            how = "the codebooks (not listed: by the formula)"
        formula = 1 - (1 - 2.0 ** -n) ** nf
        check(abs(avg - formula) < 1e-12 and formula >= 1 - math.exp(-2.0 ** (K - 2)) - 1e-12, "Example 3.6(a)")
        wf, wP = (1 - 2.0 ** -K) * 2.0 ** -m, 2.0 ** -K
        check(wf > wP * 2.0 ** -n, "a consistent function has the larger posterior weight")
        print("    n = %d, K = %d: Pr[some function fits] averaged over %s = %.6f = 1-(1-2^-n)^(2^m) = %.6f >= 1-exp(-2^(K-2)) = %.6f"
              % (n, K, how, avg, formula, 1 - math.exp(-2.0 ** (K - 2))))
    rows = []
    for n in range(1, 9):
        for K in range(1, 7):
            if n + K - 2 < 0:
                continue
            m = n + K - 2
            sq_f = ((1 - 2.0 ** -K) * 2.0 ** -m) ** 2        # w(s)^2 * likelihood 1
            sq_P = 2.0 ** (-2 * K) * 2.0 ** -n
            rows.append((n, K, sq_f < sq_P))
    check(all(ok for n, K, ok in rows if n >= 4), "Example 3.6(b) for n >= 4")
    bad = sorted((n, K) for n, K, ok in rows if not ok)
    print("    (b) with the weights squared P beats every function for all n >= 4 (so for n >= 5 as stated), K = 1..6; a fitting function beats P at (n, K) in %s" % bad)
    print("    K = 4: 1 - exp(-4) = %.5f; number of functions 2^(n+2); TV of a function's run law from Q_P = 1 - 1/8 = %.3f" % (1 - math.exp(-4), 7 / 8))


# --------------------------------------------------------------------------------------------
# T4  Remark 3.7(i)
# --------------------------------------------------------------------------------------------
def T4():
    print("T4  Remark 3.7(i): the member of largest posterior weight in Example 3.1")
    Nz, eps = 6, 0.1
    F = list(itertools.product((0, 1), repeat=Nz))
    pr = lambda y: (1 - eps) if y == 1 else eps

    def map_is_P(data):
        likP = 0.5 * math.prod(pr(y) for z, y in data)
        best = 0.0
        for s in F:
            if all(s[z] == y for z, y in data):
                best = max(best, 0.5 * math.prod(pr(v) for v in s))
        return likP > best, likP, best

    # all data with distinct inputs, up to Nz - 1 questions
    all_ok = True
    cnt = 0
    for q in range(0, Nz):
        for zs in itertools.combinations(range(Nz), q):
            for ys in itertools.product((0, 1), repeat=q):
                ok, _, _ = map_is_P(list(zip(zs, ys)))
                all_ok &= ok
                cnt += 1
    check(all_ok, "Remark 3.7(i) for distinct asked inputs")
    print("    N_z = %d, eps = %.1f: for all %d data lists with distinct inputs and at least one fresh input the member of largest posterior weight is P" % (Nz, eps, cnt))
    ok, likP, best = map_is_P([(0, 0), (0, 0)])
    check(not ok, "the counterexample with a repeated input")
    print("    data ((z,0),(z,0)), one input asked twice: posterior weight of P is proportional to %.5f, of the best function to %.5f: a function is the member of largest posterior weight"
          % (likP, best))


# --------------------------------------------------------------------------------------------
# T5  Section 4 by brute force
# --------------------------------------------------------------------------------------------
def g(a, b, s):
    """Trap function g_a at the input (b, s); g_0 is the zero function."""
    if a == 0:
        return 0
    return 1 if ((s == 0 and b == a) or s == a) else 0


def trap_run(z, answer):
    """Run of the trap scaffold on z; answer(j, b, s) gives the answer at call j with input (b, s)."""
    s = 0
    xs, ys = [], []
    for j, b in enumerate(z):
        y = answer(j, b, s)
        xs.append((b, s))
        ys.append(y)
        if s == 0 and y == 1:
            s = b
    return xs, ys


def T5():
    print("T5  Section 4 by brute force over all top-level inputs")
    # what a question does (Definition 4.1)
    N = 7
    ok = True
    for c in range(0, N + 1):                                 # the human's index (0: class A)
        for b in range(1, N + 1):
            for s in range(0, N + 1):
                ans = g(c, b, s)
                removed = [a for a in range(1, N + 1) if a != c and g(a, b, s) != ans]
                if ans == 0:
                    ok &= len(removed) <= 1
                else:
                    ok &= len(removed) == N - 1 if c != 0 else False
    check(ok, "Definition 4.1: a question answered 0 removes at most one member; answered 1, all but the human")
    print("    Definition 4.1, N = %d: a question answered 0 removes at most one member, a question answered 1 removes every member but the human: %s" % (N, ok))
    # Proposition 4.6(a) and Corollary 4.4(c): the run of a trap
    worst = 1e9
    for (n, L) in [(2, 2), (3, 3), (4, 3), (4, 4), (3, 2), (5, 4)]:
        N = 2 * n
        c0 = -(-L // 4)
        m0 = L - c0 + 1
        a = 1
        hit = tot = 0
        ok_runs = True
        for z in itertools.product(range(1, N + 1), repeat=L):
            xs, ys = trap_run(z, lambda j, b, s: g(a, b, s))
            first = next((i for i, b in enumerate(z) if b == a), None)
            ones = sum(ys)
            ok_runs &= ones == (0 if first is None else L - first)
            hit += ones >= c0
            tot += 1
        exact = 1 - (1 - 1.0 / N) ** m0
        check(ok_runs and abs(hit / tot - exact) < 1e-12 and exact >= (9 / 32) * L / n - 1e-12, "Proposition 4.6(a)")
        worst = min(worst, exact / ((9 / 32) * L / n))
    for n in range(1, 301):
        N = 2 * n
        for L in range(1, n + 1):
            m0 = L - (-(-L // 4)) + 1
            worst = min(worst, (1 - (1 - 1.0 / N) ** m0) / ((9 / 32) * L / n))
    check(worst >= 1.0, "Proposition 4.6(a), the bound (9/32) L/n")
    print("    Proposition 4.6(a): a trap's run has L - i + 1 answers 1 when its index first occurs at position i (6 sizes, all inputs); Pr[at least L/4 answers 1] = 1-(1-1/N)^m0; smallest ratio to (9/32)L/n over n <= 300, L <= n: %.4f" % worst)
    # Proposition 4.6(b): per-call mass of a surviving trap
    ok = all((1 + i) / (k * (1 + i) + 1) < 1.0 / k for k in range(1, 400) for i in (1e-6, 0.01, 1.0))
    check(ok, "Proposition 4.6(b)")
    # Corollary 4.4(b): tolerance relative to the human, class B; and the run of another member
    ok_tol = True
    ok_low = True
    sizes44 = [(6, 5), (4, 6)]
    for (N, L) in sizes44:
        c0 = -(-L // 4)
        m = c0 - 1
        astar = 2
        for z in itertools.product(range(1, N + 1), repeat=L):
            # human system with at most m answers replaced (all subsets of at most m calls, the replaced answer flipped)
            for k in range(0, m + 1):
                for calls in itertools.combinations(range(L), k):
                    xs, ys = trap_run(z, lambda j, b, s: (1 - g(astar, b, s)) if j in calls else g(astar, b, s))
                    diff = sum(y != g(astar, b, s) for (b, s), y in zip(xs, ys))
                    ok_tol &= diff <= k and diff < L / 4.0
            # a wrong member: at least L - j + 1 unfaithful calls when its index first occurs at position j
            for ahat in (1, 3):
                xs, ys = trap_run(z, lambda j, b, s: g(ahat, b, s))
                diff = sum(y != g(astar, b, s) for (b, s), y in zip(xs, ys))
                first = next((i for i, b in enumerate(z) if b == ahat), None)
                if first is not None:
                    ok_low &= diff >= L - first
    check(ok_tol and ok_low, "Corollary 4.4(b)")
    print("    Corollary 4.4(b), (N, L) in %s, one replaced answer allowed: the corrupted run of the human system has fewer than L/4 answers that differ from the human's at their inputs: %s;"
          " a member g_a other than the human has at least L - j + 1 unfaithful calls when a first occurs at position j: %s" % (sizes44, ok_tol, ok_low))
    # Corollary 4.4(c): a rule that sees the input of the run
    n, L = 4, 5
    N = 2 * n
    c0 = -(-L // 4)
    out_fixed = out_seeing = tot = 0
    for z in itertools.product(range(1, N + 1), repeat=L):
        xs, ys = trap_run(z, lambda j, b, s: g(1, b, s))
        out_fixed += sum(ys) >= c0
        a_seen = z[0]
        xs, ys = trap_run(z, lambda j, b, s: g(a_seen, b, s))
        out_seeing += sum(ys) >= c0
        tot += 1
    m0 = L - c0 + 1
    check(abs(out_fixed / tot - (1 - (1 - 1.0 / N) ** m0)) < 1e-12 and out_seeing == tot, "Corollary 4.4(c)")
    print("    Corollary 4.4(c), N = %d, L = %d, G = {fewer than L/4 answers 1}: a member fixed before the input is outside G with probability %.4f = 1-(1-1/N)^m0;"
          " the rule that sees z and deploys the trap of its first symbol is outside G with probability %.1f" % (N, L, out_fixed / tot, out_seeing / tot))
    # Proposition 4.3(b) after ANY at most n questions: posterior uniform on a set of size s >= n that contains a*
    worst_b = 0.0
    worst_vote = 0.0
    for n in (16, 17, 25, 40, 64):
        N = 2 * n
        for s in sorted(set([n, n + 1, (3 * n) // 2, N])):
            for L in sorted(set([1, 2, 3, 5, n // 2, n])):
                # dynamic programme over calls: state (type of flag, number of unfaithful calls)
                dist = {('zero', 0): 1.0}
                for _ in range(L):
                    nd = {}

                    def add(k_, p_):
                        nd[k_] = nd.get(k_, 0.0) + p_
                    for (fl, u), p in dist.items():
                        if fl == 'zero':
                            # input (b, 0): b = a* with probability 1/N
                            add(('star', u), p * (1.0 / N) * (1.0 / s))                 # human 1, draw g_a*: faithful
                            add(('zero', u + 1), p * (1.0 / N) * (1 - 1.0 / s))         # human 1, answer 0
                            add(('other', u + 1), p * ((s - 1.0) / N) * (1.0 / s))      # b in S, draw g_b: answer 1
                            add(('zero', u), p * (((s - 1.0) / N) * (1 - 1.0 / s) + (N - s) / float(N)))
                        elif fl == 'star':
                            add(('star', u), p * (1.0 / s))                             # human 1, draw g_a*
                            add(('star', u + 1), p * (1 - 1.0 / s))
                        else:
                            add(('other', u + 1), p * (1.0 / s))                        # human 0, draw g_flag
                            add(('other', u), p * (1 - 1.0 / s))
                    dist = nd
                tail = [0.0] * (L + 2)
                for (fl, u), p in dist.items():
                    for mm in range(0, u):
                        tail[mm] += p                                                   # more than mm unfaithful calls
                for mm in range(0, L):
                    bnd = L / (2.0 * n * n) + (3.0 * L / (2 * n)) ** (mm + 1) / math.factorial(mm + 1)
                    check(tail[mm] <= bnd + 1e-12, "Proposition 4.3(b) for |S| = %d" % s)
                    worst_b = max(worst_b, tail[mm] / bnd)
                    # the vote (the zero function while at least three members survive): Binomial(L, 1/N)
                    vote = sum(math.comb(L, i) * (1.0 / N) ** i * (1 - 1.0 / N) ** (L - i) for i in range(mm + 1, L + 1))
                    check(vote <= (L / (2.0 * n)) ** (mm + 1) / math.factorial(mm + 1) + 1e-15 and vote <= bnd, "Remark 4.5: the vote")
                    worst_vote = max(worst_vote, vote / bnd)
    print("    Proposition 4.3(b) for the posterior after any at most n questions (uniform on a set of size |S| >= n that contains the human; n = 16..64, L <= n, all m): largest Pr[more than m unfaithful calls]/bound = %.4f"
          % worst_b)
    print("    Remark 4.5: the vote's unfaithful calls are Binomial(L, 1/N); largest ratio to the committee's bound = %.4f" % worst_vote)
    check(abs(1.5 ** 3 / 6 - 0.5625) < 1e-12, "0.57")
    print("    Corollary 4.4(b): (3/2)^3/3! = %.4f <= 0.57" % (1.5 ** 3 / 6))


# --------------------------------------------------------------------------------------------
# T6  Proposition 5.7
# --------------------------------------------------------------------------------------------
def prop57(mu, L, nxt, funcs, w, n, deltas, label):
    """Class of functions funcs (funcs[0] = f, the human); nxt(z, ys) -> input or -1.
    Posterior-draw driver. Enumerates every data path of n rounds."""
    nh = len(funcs)
    nx = len(funcs[0])
    f = funcs[0]
    Kln2 = math.log(1.0 / w[0])

    def run(gf, z):
        ys, xs = (), []
        while True:
            x = nxt(z, ys)
            if x < 0:
                return xs, ys
            xs.append(x)
            ys = ys + (gf[x],)

    runs = [[run(gf, z) for z in range(len(mu))] for gf in funcs]
    unf = np.array([[runs[i][z] != runs[0][z] for z in range(len(mu))] for i in range(nh)])    # nh x nz
    u = unf @ np.array(mu)                                                                     # u(g)
    vis = np.zeros((nh, nx))
    for i in range(nh):
        for z, m in enumerate(mu):
            for x in runs[i][z][0]:
                vis[i, x] += m
    wrong = np.array([[funcs[i][x] != f[x] for x in range(nx)] for i in range(nh)])            # nh x nx
    c2 = 2.0 * L * L / (L + 1)
    cache = {}
    stt = dict(mu_ratio=0.0, step3=True, psi=True)

    def info(key):
        if key in cache:
            return cache[key]
        alive = np.array([all(funcs[i][x] == f[x] for x in key) for i in range(nh)])
        post = np.where(alive, w, 0.0)
        post = post / post.sum()
        vbar = post @ vis
        ebar = post @ wrong                              # removed mass if x is asked
        mu_t = float(vbar @ ebar) / L
        ubar = float(post @ u)
        dprime = wrong @ vbar                            # d'_t(g)
        # per (z): psi_L(u_t(z)) and the inequality of Theorem 2.1, Steps 1 to 3
        lhs = 0.0
        for z, m in enumerate(mu):
            uz = float(post @ unf[:, z])
            lhs += m * (uz - uz * uz * (L - 1) / (2.0 * L))
        stt['psi'] &= mu_t >= lhs / L - TOL and lhs / L >= ubar * (L + 1) / (2.0 * L * L) - TOL
        if ubar > 1e-13:
            stt['mu_ratio'] = max(stt['mu_ratio'], (ubar * (L + 1) / (2.0 * L * L)) / mu_t)
        stt['step3'] &= bool(np.all(dprime[alive] >= u[alive] - ubar - TOL))
        cache[key] = (alive, post, vbar, ebar, mu_t, ubar, dprime)
        return cache[key]

    acc = dict(prob=0.0, mart=0.0, paths=0)
    per = {d: dict(a=0.0, s1=0.0, b=0.0, c_mass=0.0, c_fail=0.0) for d in deltas}

    def rec(t, key, prob, sum_u, sum_mu, sum_d, mart):
        if t == n:
            alive = info(key)[0]
            acc['prob'] += prob
            acc['mart'] += prob * mart
            acc['paths'] += 1
            post = np.where(alive, w, 0.0)
            post = post / post.sum()
            for d in deltas:
                ln1d = math.log(1.0 / d)
                q = per[d]
                q['a'] += prob * (sum_u >= c2 * (Kln2 + ln1d) - 1e-12)
                s1 = bool(np.any(alive & (sum_d >= L * (np.log(1.0 / w) + ln1d) - 1e-12)))
                q['s1'] += prob * s1
                bnd = (L * (np.log(1.0 / w) + ln1d) + c2 * (Kln2 + ln1d)) / n
                q['b'] += prob * bool(np.any(alive & (u >= bnd - 1e-12)))
                bad = alive & (sum_d >= L * (Kln2 + ln1d) - 1e-12)
                q['c_mass'] += prob * float(post[bad].sum())
                q['c_fail'] += prob * float(post[u >= 3.0 * L * (Kln2 + ln1d) / n - 1e-12].sum())
            return
        alive, post, vbar, ebar, mu_t, ubar, dprime = info(key)
        p_none = 1.0 - float(vbar.sum()) / L
        if p_none > 1e-14:
            rec(t + 1, key, prob * p_none, sum_u + ubar, sum_mu + mu_t, sum_d + dprime, mart * 1.0 / (1 - mu_t))
        for x in range(nx):
            if vbar[x] <= 0:
                continue
            key2 = key if x in key else tuple(sorted(key + (x,)))
            rec(t + 1, key2, prob * vbar[x] / L, sum_u + ubar, sum_mu + mu_t, sum_d + dprime,
                mart * (1 - ebar[x]) / (1 - mu_t))

    rec(0, (), 1.0, 0.0, 0.0, np.zeros(nh), 1.0)
    check(abs(acc['prob'] - 1) < 1e-9 and abs(acc['mart'] - 1) < 1e-9, label + ": the martingale of (a) has mean 1")
    check(stt['psi'] and stt['step3'], label + ": per-state inequalities")
    res = dict(paths=acc['paths'], mu_ratio=stt['mu_ratio'])
    for d in deltas:
        q = per[d]
        check(q['a'] <= d + TOL, label + ": (a)")
        check(q['s1'] <= d + TOL, label + ": Step 1 with d'")
        check(q['b'] <= 2 * d + TOL, label + ": (b)")
        check(q['c_mass'] <= d + TOL and q['c_fail'] <= 2 * d + TOL, label + ": (c)")
    res['per'] = per
    return res


def T6():
    print("T6  Proposition 5.7: all data paths of a rehearsal driven by posterior draws, classes of functions, exact")
    rng = random.Random(57)
    deltas = [0.9, 0.5, 0.2]
    worst = dict(a=0.0, s1=0.0, b=0.0, cm=0.0, cf=0.0, mu=0.0)
    paths = 0
    ninst = 0

    def absorb(o):
        nonlocal paths, ninst
        ninst += 1
        paths += o['paths']
        worst['mu'] = max(worst['mu'], o['mu_ratio'])
        for d, q in o['per'].items():
            worst['a'] = max(worst['a'], q['a'] / d)
            worst['s1'] = max(worst['s1'], q['s1'] / d)
            worst['b'] = max(worst['b'], q['b'] / (2 * d))
            worst['cm'] = max(worst['cm'], q['c_mass'] / d)
            worst['cf'] = max(worst['cf'], q['c_fail'] / (2 * d))

    # (i) random classes on random scaffolds whose inputs depend on the answers
    for it in range(30):
        L = rng.choice([2, 3])
        nx = rng.choice([4, 5])
        nz = rng.choice([2, 3])
        tr = random_tree(rng, nz, nx, 2, L, stop=0.15)
        nh = rng.choice([4, 6, 8])
        f = tuple(rng.randrange(2) for _ in range(nx))
        funcs = [f]
        while len(funcs) < nh:
            gf = list(f)
            for x in rng.sample(range(nx), rng.choice([1, 1, 2])):
                gf[x] = 1 - gf[x]
            if tuple(gf) not in funcs:
                funcs.append(tuple(gf))
        wP = rng.choice([0.1, 0.3, 0.6])
        rest = np.array([rng.random() + 0.2 for _ in range(nh - 1)])
        w = np.concatenate([[wP], rest / rest.sum() * (1 - wP)])
        absorb(prop57(tr.mu, L, tr.nxt, funcs, w, 6, deltas, "T6 random %d" % it))
    nrand = ninst
    # (ii) the path scaffold of Example 2.4 with the chain class of Example 5.2 (one top-level input)
    for L in (2, 3, 4):
        M = L
        nx = L + 1                                    # inputs 0..L-1 are (1, j+1); input L is the star
        def nxt(z, ys, L=L):
            if len(ys) >= L:
                return -1
            return len(ys) if all(y == 0 for y in ys) else L
        f = tuple(0 for _ in range(nx))
        funcs = [f] + [tuple(1 if x == i else 0 for x in range(nx)) for i in range(M)]
        w = np.ones(M + 1) / (M + 1)
        absorb(prop57([1.0], L, nxt, funcs, w, 7 if L < 4 else 6, deltas, "T6 chain L=%d" % L))
    print("    %d random classes (4 to 8 functions, 4 or 5 inputs, L = 2 or 3, inputs depend on the answers, n = 6) and %d chain classes of Example 5.2 (L = 2, 3, 4); %d data paths"
          % (nrand, ninst - nrand, paths))
    print("    at every data state: mu_t >= E psi_L(u_t)/L >= u-bar_t (L+1)/(2L^2) (largest ratio of the last to mu_t: %.4f) and d'_t(g) >= u(g) - u-bar_t for every consistent g"
          % worst['mu'])
    print("    the martingale of (a) has mean 1 on every instance")
    print("    exact failure probabilities over delta in %s, divided by the allowed value: (a) %.4f [delta]; Step 1 with d' %.4f [delta]; (b) %.4f [2 delta]; (c) posterior mass of Bad_c %.4f [delta]; (c) itself %.4f [2 delta]"
          % (deltas, worst['a'], worst['s1'], worst['b'], worst['cm'], worst['cf']))
    ok = all(L + 2.0 * L * L / (L + 1) < 3 * L for L in range(1, 2000))
    check(ok, "L + 2L^2/(L+1) < 3L")
    print("    L + 2L^2/(L+1) = (3L^2+L)/(L+1) < 3L for L = 1..1999: %s" % ok)


# --------------------------------------------------------------------------------------------
# T7  Facts behind the decisions on the note's text
# --------------------------------------------------------------------------------------------
def T7():
    print("T7  Facts used in the decisions on the text of the note")
    # N1: class A with N = n; asking the n triggers refutes every trap
    n = 12
    survivors = [a for a in range(1, n + 1) if all(g(a, b, 0) == 0 for b in range(1, n + 1))]
    check(survivors == [], "N1")
    print("    N1: class A with N = n = %d: after the n questions (1,0), ..., (n,0), all answered 0, the surviving traps are %s; the posterior draw is then the human" % (n, survivors))
    # N7: in Proposition 5.1 a wrong driver can be removed with probability more than 1/L in an unfaithful round
    # scaffold: L = 2, inputs 0, 1, 2; call 1 at input 0; call 2 at input 1 after the answer 0 and at input 2 after the answer 1
    f = (0, 0, 0)
    gdr = (1, 0, 1)                                    # wrong at input 0 and at the input 2 that only its own run reaches
    def nxt(z, ys):
        if len(ys) == 0:
            return 0
        if len(ys) == 1:
            return 1 if ys[0] == 0 else 2
        return -1
    xs = []
    ys = ()
    while nxt(0, ys) >= 0:
        x = nxt(0, ys)
        xs.append(x)
        ys = ys + (gdr[x],)
    removed = sum(gdr[x] != f[x] for x in xs) / 2.0
    check(abs(removed - 1.0) < 1e-12, "N7")
    print("    N7: L = 2, a driver that is wrong at call 1 and at the off-path input of call 2: its unfaithful run removes it with probability %.1f > 1/L = 0.5; so 'at least 1/L'" % removed)
    # N10: Example 5.2 with equal weights depends on the order in which ties are broken
    for L in (3, 5):
        M = L
        # path scaffold with one top-level input: inputs 1..L on the main path, 0 is the star
        def asked(d, J):                      # the input of call J in the run of g_d (d = 0: the human f)
            return J if (d == 0 or J <= d) else 0
        gval = lambda d, x: 1 if (d != 0 and x == d) else 0
        # order g_1, ..., g_M, f: while g_d drives, a round removes g_d with probability p_d and nothing else
        exp_last = 0.0
        for d in range(1, M + 1):
            p_d = sum(gval(d, asked(d, J)) != 0 for J in range(1, L + 1)) / float(L)
            others = sum(gval(e, asked(d, J)) != 0 for J in range(1, L + 1) for e in range(d + 1, M + 1))
            check(abs(p_d - 1.0 / L) < 1e-12 and others == 0, "N10: reign of g_d")
            exp_last += 1.0 / p_d             # every round of the reign is unfaithful
        # order with f first: f drives from the first round on, and its runs are faithful
        exp_first = 0
        print("    N10: Example 5.2, L = M = %d, equal weights: with the order g_1, ..., g_M, f the expected number of unfaithful rounds is %.0f = L^2; with f first in the order it is %d"
              % (L, exp_last, exp_first))
    # the R2 constant of the table in Section 6, and the number quoted in Section 7.6
    nq, L, K = 8192, 4, 10
    old = 2 * math.sqrt(nq * L * K * LN2)
    new = math.sqrt(2 * nq * L * K * LN2)
    print("    R2 summed over n = 8192 rounds at L = 4, K = 10: n*2*sqrt(L K ln2/n) = %.0f (the constant of the prover's file), n*sqrt(2 L K ln2/n) = %.0f (Theorem 3.1(b) of hellinger-runs)" % (old, new))
    check(abs(old - 953) < 1 and abs(new - 674) < 1, "953 and 674")


if __name__ == "__main__":
    T1()
    T2()
    T3()
    T4()
    T5()
    T6()
    T7()
    print()
    if FAILED:
        print("FAILED CHECKS: %d" % len(FAILED))
        for f_ in sorted(set(FAILED)):
            print("  ", f_)
    else:
        print("all checks passed")
