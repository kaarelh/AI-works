"""Reviewer check m2 (Paper 1, examples.tex / app-examples.tex): Eisenstat's example, written from
the paper's definitions only (no project code imported).

(a) Exact law of D_n by exhaustive enumeration over coin sequences zeta in {0,1}^n and bit
    prefixes b in {0,1}^L (exact rationals), compared with prop:ex:law(a)
    Pr[D_n = D] = C(n,N1) (2/9)^n r^(s+ - n), and with the normaliser Z(S) of the appendix.
    Also the worked example S = {0,1,3}.
(b) lem:ex:pstar: the Bayes conditional of label 1 at the next input, by enumeration, against the
    closed form (0/1 off the frontier; 2^k/(2^k+1) at touching histories).
(c) A frontier DP (written independently from the description in the proof of prop:ex:burnin):
    Pr[eta_n < tau_n], E N_touch(n), E L_{P*}(n), expected rule errors and Pr[no rule error], for
    n = 10, 20, 40, 80, 160, and the limits 3, 3*theta, 2, 1/2.
(d) theta, sigma^2, E UB_n / n and Var(UB_n)/n exactly from the laws of N^0_n and G.
Deterministic.
"""
import itertools
import math
from fractions import Fraction as Fr
from collections import defaultdict

THIRD = Fr(1, 3)
TWO3 = Fr(2, 3)


def run(b, zeta):
    """Return (ordered list of (index,label), ok). ok=False if the process runs past len(b);
    the list then holds the steps completed before the overflow."""
    L = len(b)
    revealed = set()
    hist = []
    for z in zeta:
        want = 1 if z == 1 else 0
        i = 0
        while True:
            if i >= L:
                return hist, False
            if i not in revealed and b[i] == want:
                break
            i += 1
        revealed.add(i)
        hist.append((i, want))
    return hist, True


def weight_b(b):
    w = Fr(1)
    for x in b:
        w *= THIRD if x == 1 else TWO3
    return w


def weight_z(zeta):
    w = Fr(1)
    for z in zeta:
        w *= TWO3 if z == 1 else THIRD
    return w


def part_a(n, L):
    law = defaultdict(Fr)
    for zeta in itertools.product((0, 1), repeat=n):
        wz = weight_z(zeta)
        for b in itertools.product((0, 1), repeat=L):
            hist, ok = run(b, zeta)
            if not ok:
                continue
            D = frozenset(hist)
            law[D] += wz * weight_b(b)
    # only data sets whose top index is far enough below L are exactly computed
    maxerr = Fr(0)
    checked = 0
    for D, p in law.items():
        S = sorted(i for i, _ in D)
        splus = S[-1] + 1
        if splus > L - 1:
            continue
        N1 = sum(lbl for _, lbl in D)
        top = dict(D)[S[-1]]
        r = TWO3 if top == 1 else THIRD
        formula = math.comb(n, N1) * Fr(2, 9) ** n * r ** (splus - n)
        maxerr = max(maxerr, abs(formula - p))
        checked += 1
    # Z(S): sum over possible labellings of S of C(n,N1) r^(s+-n)
    byS = defaultdict(list)
    for D in law:
        S = tuple(sorted(i for i, _ in D))
        if S[-1] + 1 <= L - 1:
            byS[S].append(D)
    zerr = 0
    for S, Ds in byS.items():
        splus = S[-1] + 1
        g = min(set(range(splus + 1)) - set(S))
        tot = Fr(0)
        for D in Ds:
            N1 = sum(lbl for _, lbl in D)
            top = dict(D)[S[-1]]
            r = TWO3 if top == 1 else THIRD
            tot += math.comb(n, N1) * r ** (splus - n)
        if g < splus:
            Z = (TWO3 ** (splus - n) + THIRD ** (splus - n)) * math.comb(n + g, g)
        else:
            Z = Fr(math.comb(2 * n, n))
        if Z != tot:
            zerr += 1
    return checked, maxerr, len(byS), zerr, law


def example_013(law):
    S = (0, 1, 3)
    Ds = [D for D in law if tuple(sorted(i for i, _ in D)) == S]
    tot = sum(law[D] for D in Ds)
    out = {}
    for D in Ds:
        lab = tuple(dict(D)[i] for i in S)
        out[lab] = law[D] / tot
    return out


def part_b(n, L):
    """Conditional Pr[label 1 | history h (ordered), next input x] vs closed form."""
    joint = defaultdict(Fr)
    for zeta in itertools.product((0, 1), repeat=n):
        wz = weight_z(zeta)
        for b in itertools.product((0, 1), repeat=L):
            hist, ok = run(b, zeta)
            w = wz * weight_b(b)
            # record every step completed before a possible overflow (exact marginals of prefixes)
            for t in range(len(hist)):
                h = tuple(hist[:t])
                x, lbl = hist[t]
                joint[(h, x, lbl)] += w
    pairs = defaultdict(lambda: [Fr(0), Fr(0)])
    for (h, x, lbl), w in joint.items():
        pairs[(h, x)][lbl] += w
    maxdiff = 0.0
    n_checked = 0
    for (h, x), (w0, w1) in pairs.items():
        # skip pairs whose relevant indices are too close to the truncation L
        idx = [i for i, _ in h] + [x]
        if max(idx) > L - 4:
            continue
        tails = [i for i, l in h if l == 0]
        heads = [i for i, l in h if l == 1]
        tau = max(tails) + 1 if tails else 0
        eta = max(heads) + 1 if heads else 0
        F = max(tau, eta)
        rev = set(i for i, _ in h)
        g = min(set(range(F + 1)) - rev)
        if x < F:
            pred = Fr(0) if x < eta else Fr(1)
        elif g < F:
            pred = Fr(1) if tau <= eta else Fr(0)
        else:
            k = x - F
            pred = Fr(2 ** k, 2 ** k + 1)
        true = w1 / (w0 + w1)
        maxdiff = max(maxdiff, abs(float(true - pred)))
        n_checked += 1
    return n_checked, maxdiff


def frontier_dp(ns, U=400, M=200):
    """State: (side, u). side 'N' (nothing revealed), 'H' (heads ahead, u unrevealed tails in [tau,eta)),
    'T' (tails ahead, u unrevealed heads in [eta,tau)). u = 0 means touching (revealed set = [0,F)).
    Track probability mass, and accumulate expected touching steps, P* loss, rule errors; also the
    probability of no rule error so far (mass of an 'errfree' copy)."""
    lg = math.log2
    # step outcome distributions from a touching state: head at F+m (prob 2/9 (2/3)^m), tail at F+m (2/9 (1/3)^m)
    head_m = [(2 / 9) * (2 / 3) ** m for m in range(M)]
    tail_m = [(2 / 9) * (1 / 3) ** m for m in range(M)]
    # from H,u>=1: tail (1/3) -> u-1; head skipping m tails (2/9 (2/3)^m) -> u+m
    # from T,u>=1: head (2/3) -> u-1; tail skipping m heads (2/9 (1/3)^m) -> u+m
    dist = {('N', 0): 1.0}
    ok = {('N', 0): 1.0}            # mass of runs with no rule error so far
    Etouch = ErrE = LossE = 0.0
    out = {}
    for step in range(1, max(ns) + 1):
        new = defaultdict(float)
        newok = defaultdict(float)
        for (side, u), p in dist.items():
            pok = ok.get((side, u), 0.0)
            if u == 0:  # touching (including the start)
                Etouch += p
                for m in range(M):
                    # head at F+m
                    LossE += p * head_m[m] * lg(1 + 2.0 ** (-m))
                    err = (m == 0)
                    ErrE += p * head_m[m] * err
                    s2 = ('H', m)
                    new[s2] += p * head_m[m]
                    if not err:
                        newok[s2] += pok * head_m[m]
                    # tail at F+m
                    LossE += p * tail_m[m] * lg(1 + 2.0 ** m)
                    err = (m >= 1)
                    ErrE += p * tail_m[m] * err
                    s2 = ('T', m)
                    new[s2] += p * tail_m[m]
                    if not err:
                        newok[s2] += pok * tail_m[m]
            elif side == 'H':
                new[('H', u - 1)] += p / 3
                newok[('H', u - 1)] += pok / 3
                for m in range(M):
                    if u + m <= U:
                        new[('H', u + m)] += p * head_m[m]
                        newok[('H', u + m)] += pok * head_m[m]
            else:  # 'T', u >= 1: every step is a rule error
                ErrE += p
                new[('T', u - 1)] += p * 2 / 3
                for m in range(M):
                    if u + m <= U:
                        new[('T', u + m)] += p * tail_m[m]
        dist, ok = dict(new), dict(newok)
        if step in ns:
            behind = sum(p for (s, u), p in dist.items() if s == 'T')
            mass = sum(dist.values())
            out[step] = (behind, Etouch, LossE, ErrE, sum(ok.values()), mass)
    return out


def ub_moments(n):
    """Exact E UB_n and Var UB_n from N0 ~ Bin(n,1/3) independent of G_j (sum of j geometrics)."""
    l3 = math.log2(3)
    a = 1.5 * l3 - 1
    # UB - (H/2) n = a (N0 - n/3) + l3 (G_N0 - N0/2); E = 0, Var = a^2 2n/9 + l3^2 * E[3/4 N0]
    return a, (a * a * 2 * n / 9 + l3 * l3 * 0.75 * n / 3) / n


if __name__ == "__main__":
    print("(a) exact law of D_n vs prop:ex:law(a), and Z(S)")
    for n, L in ((3, 12), (4, 12), (5, 13)):
        checked, maxerr, nS, zerr, law = part_a(n, L)
        print(f"  n={n} L={L}: data sets checked {checked}, max |formula - exact| = {maxerr}; "
              f"domains {nS}, Z(S) mismatches {zerr}")
        if n == 3:
            print("  S={0,1,3} conditional law of labellings:", {k: str(v) for k, v in example_013(law).items()})
    print("(b) P* closed form vs exact conditional")
    for n, L in ((3, 12), (4, 13)):
        nc, md = part_b(n, L)
        print(f"  n={n} L={L}: (history,input) pairs checked {nc}, max |diff| = {md:.3g}")
    print("(c) frontier DP")
    res = frontier_dp([10, 20, 40, 80, 160])
    for n, (behind, Et, Lp, Er, Pok, mass) in res.items():
        print(f"  n={n}: Pr[eta<tau]={behind:.3e}  E N_touch={Et:.4f}  E L_P*={Lp:.5f}  "
              f"E rule errors={Er:.4f}  Pr[no rule error]={Pok:.4f}  retained mass={mass:.12f}")
    theta = sum((2 / 9) * ((2 / 3) ** k * math.log2(1 + 2.0 ** -k) + (1 / 3) ** k * math.log2(1 + 2.0 ** k))
                for k in range(400))
    print(f"(d) theta = {theta:.10f}, 3*theta = {3 * theta:.8f}")
    l3 = math.log2(3)
    H = l3 - 2 / 3
    a = 1.5 * l3 - 1
    print(f"    H(1/3)/2 = {H / 2:.10f}, a = {a:.10f}, sigma^2 = {2 / 9 * a * a + 0.25 * l3 * l3:.10f}, "
          f"sigma = {math.sqrt(2 / 9 * a * a + 0.25 * l3 * l3):.6f}")
    print(f"    iid Bern(1/3) cost per step = log3 - 1/3 = {l3 - 1 / 3:.6f}")
    # return probability from touching and burn-in geometry
    ret = 2 / 9 + 2 / 9 + sum(2 / 9 * (2 / 3) ** k * 2.0 ** -k + 2 / 9 * (1 / 3) ** k for k in range(1, 200))
    print(f"    return probability from touching = {ret:.12f}")
    # B-steps per touching step and errors per cycle
    bsteps = sum(2 / 9 * (1 / 3) ** k * 2 * k for k in range(1, 200))
    print(f"    expected B-steps after a touching step = {bsteps:.12f}; errors per cycle = {2 / 9 + 1 / 9 + bsteps:.12f}")
    # Hoeffding constant in lem:ex:behind
    print(f"    1 + 1/(1-e^(-1/18)) = {1 + 1 / (1 - math.exp(-1 / 18)):.4f}")
