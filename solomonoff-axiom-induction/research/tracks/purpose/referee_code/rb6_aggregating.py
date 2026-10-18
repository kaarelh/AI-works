"""rb6_aggregating.py -- referee B, track `purpose`, target T5 (independent code).

Seed 20261018.  Writes rb6_aggregating.out next to itself.

  A. Mixability of square loss on [-B, B] at eta = c / B^2: for each pool pi, the least over gamma of
     max over omega of [(gamma - omega)^2 - g_pi(omega)], g_pi(omega) = -(1/eta) ln sum_i pi_i exp(-eta (g_i-omega)^2)
     (omega on a 2001-point grid plus endpoints; gamma by bounded scalar minimisation of a convex function).
     Feasible iff <= 0.  Bisection on c for the worst pool found.  Also the exp-concavity threshold 1/(8 B^2).
  B. Absolute loss: g(0) + g(1) for pi = (delta_0 + delta_1)/2 (closed form) < 1 for every eta.
  C. A small purpose-SAI (Definition T5.1) in the finite atom model of rb1: theory machines are finite lists of
     (probability, theory); questions are partitions of the atoms with values m(a) = mean atom index of the cell;
     the act of a machine is the mean of its answer distribution (default 0 if it proves no answer); the AA with
     prefix-code weights 2^-l(i) and Vovk's substitution for square loss; check L_AA <= L_i + ln(1/w_i)/eta for
     every machine i on random and adversarial question/answer sequences.
  D. Scale of the guarantee: the developer's toy laws as experts (p5 part C setting) -- report L_AA next to L_A
     (the record reports only the final weight) and the regret bound in units of B^2; and what the bound means for
     longitudes (B = 10800 arcmin).
"""
import math
import os
import random
from fractions import Fraction as Fr

import numpy as np
from scipy import optimize

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ------------------------------------------------------------------------------------------------ A
def gap_for_pool(preds, ws, eta, B, nom=2001):
    om = np.concatenate([np.linspace(-B, B, nom), [-B, B]])
    E = np.exp(-eta * (np.asarray(preds)[:, None] - om[None, :]) ** 2)
    g = -np.log(np.asarray(ws) @ E) / eta
    f = lambda gam: float(np.max((gam - om) ** 2 - g))
    r = optimize.minimize_scalar(f, bounds=(-B, B), method="bounded", options={"xatol": 1e-12})
    return r.fun


def part_A(rng):
    out("\n== A. square loss on [-B, B]: worst infeasibility max_pi min_gamma max_omega [(gamma-omega)^2 - g_pi(omega)]")
    for B in (1.0, 7.0):
        for c in (0.45, 0.5, 0.51, 0.55, 0.6):
            eta = c / B ** 2
            worst = -1e9
            # endpoint pools (the known worst case) and random pools
            for p in np.linspace(0.02, 0.98, 49):
                worst = max(worst, gap_for_pool([-B, B], [p, 1 - p], eta, B))
            for _ in range(300):
                k = rng.integers(2, 6)
                preds = rng.uniform(-B, B, k)
                ws = rng.dirichlet(np.ones(k))
                worst = max(worst, gap_for_pool(preds, ws, eta, B))
            out("   B=%4.1f c=%.2f: worst gap / B^2 = %+.3e (%s)" % (B, c, worst / B ** 2,
                                                         "mixable on these pools" if worst <= 1e-6 * B * B else "NOT mixable"))
    # bisection for the threshold over two-point pools {-d, d} (a search over all two-point pools on a 21 x 21 x 19
    # grid at c = 0.51 found the worst at d = 0.2, p = 1/2: the binding pools are narrow and central, not the endpoints)
    def worst_pool(c):
        return max(gap_for_pool([-d, d], [p, 1 - p], c, 1.0, nom=8001)
                   for d in (0.02, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0) for p in (0.3, 0.5, 0.7))
    lo, hi = 0.3, 0.8
    for _ in range(30):
        mid = 0.5 * (lo + hi)
        if worst_pool(mid) <= 1e-10:
            lo = mid
        else:
            hi = mid
    out("   bisection over two-point pools {-d, d} (B = 1): largest feasible c = %.5f (claim: 1/2)" % lo)
    # exp-concavity of exp(-eta (gamma - omega)^2) in gamma on [-B, B]^2: second derivative sign
    B = 1.0
    gs = np.linspace(-B, B, 801)
    for c in (0.12, 0.125, 0.13):
        eta = c / B ** 2
        d2 = (4 * eta ** 2 * (gs[:, None] - gs[None, :]) ** 2 - 2 * eta)
        out("   exp-concavity at eta = %.3f/B^2: max second-derivative factor %+.4f (%s)" % (
            c, float(d2.max()), "concave" if d2.max() <= 1e-12 else "not concave"))


# ------------------------------------------------------------------------------------------------ B
def part_B():
    out("\n== B. absolute loss, pi = (delta_0 + delta_1)/2 on outcomes {0,1}: g(0) + g(1) = -(2/eta) ln((1+e^-eta)/2)")
    for eta in (1e-3, 0.1, 1.0, 10.0, 1e3):
        v = -(2 / eta) * math.log((1 + math.exp(-eta)) / 2)
        out("   eta=%g: g(0)+g(1) = %.6f (< 1: no gamma satisfies gamma <= g(0) and 1-gamma <= g(1))" % (eta, v))


# ------------------------------------------------------------------------------------------------ C
class AtomModel:
    def __init__(self, N):
        self.N, self.FULL = N, (1 << N) - 1

    def vset(self, th):
        v = self.FULL
        for s in th:
            v &= s
        return v

    def nu_proves(self, G, conds):
        """P(consistent and value set inside every mask in conds)"""
        tot = 0.0
        for p, th in G:
            v = self.vset(th)
            if v and all(v & ~c == 0 for c in conds):
                tot += p
        return tot


def act(M, G, past, cells, vals):
    num = [M.nu_proves(G, past + [c]) for c in cells]
    den = sum(num)
    if den <= 0:
        return 0.0
    return sum(n * v for n, v in zip(num, vals)) / den


def part_C(rng):
    out("\n== C. purpose-SAI (Def. T5.1) on a finite atom model, square loss, AA with Vovk's substitution")
    pyr = random.Random(SEED)
    N = 8
    M = AtomModel(N)
    B = float(N - 1)       # values m(a) in [0, N-1]; centre them to [-B/2, B/2] -> range half-width B/2
    half = B / 2
    eta = 1 / (2 * half ** 2)
    worst_slack = math.inf
    nmach_total = 0
    for trial in range(40):
        # pool of machines with prefix-code weights 2^-(i+1)
        pool = []
        for i in range(25):
            k = pyr.randint(1, 4)
            ws = [pyr.randint(1, 5) for _ in range(k)]
            G = []
            for w in ws:
                th = [pyr.randint(1, M.FULL) for _ in range(pyr.randint(0, 2))]
                G.append((w / sum(ws), th))
            pool.append(G)
        # a machine that knows the truth (value fixed per trial) and one that is always silent
        x = pyr.randrange(N)
        pool[3] = [(1.0, [1 << x])]
        pool[4] = [(1.0, [])]
        w = np.array([2.0 ** -(i + 1) for i in range(len(pool))])
        L = np.zeros(len(pool))
        LAA = 0.0
        past = []
        adversarial = trial % 2 == 1
        for t in range(30):
            # a random partition of the atoms into 2-4 cells (a question)
            labels = [pyr.randrange(pyr.randint(2, 4)) for _ in range(N)]
            cells = {}
            for a, l in enumerate(labels):
                cells[l] = cells.get(l, 0) | (1 << a)
            cells = list(cells.values())
            vals = [float(np.mean([a for a in range(N) if (c >> a) & 1])) - half for c in cells]
            preds = np.array([act(M, G, past, cells, vals) for G in pool])
            # AA prediction by Vovk's substitution for square loss on [-half, half]
            post = w * np.exp(-eta * L)
            post /= post.sum()
            gfun = lambda om: -math.log(float(np.sum(post * np.exp(-eta * (preds - om) ** 2)))) / eta
            gamma = (gfun(-half) - gfun(half)) / (4 * half)
            # the true answer: the cell of x; adversarial trials choose the cell maximising the AA's loss among cells
            # consistent with ... (no consistency needed for the regret bound: any outcome sequence)
            if adversarial:
                j = max(range(len(cells)), key=lambda j: (gamma - vals[j]) ** 2)
            else:
                j = next(j for j, c in enumerate(cells) if (c >> x) & 1)
            om = vals[j]
            LAA += (gamma - om) ** 2
            L += (preds - om) ** 2
            past.append(cells[j])
        slack = np.min(L + np.log(1 / w) / eta - LAA)
        worst_slack = min(worst_slack, float(slack))
        nmach_total += len(pool)
    out("   40 trials (20 truthful, 20 adversarial answer sequences), 25 machines each, 30 questions: min over trials"
        " and machines of [L_i + ln(1/w_i)/eta - L_AA] = %+.4f (>= 0: the regret bound T5.2 holds)" % worst_slack)


# ------------------------------------------------------------------------------------------------ D
def part_D(rng):
    out("\n== D. scale of the square-loss guarantee (the toy laws of T4(a) as experts)")
    n, M = 4000, 1000.0
    Bv = 1002.0
    eta = 1 / (2 * Bv ** 2)
    q = rng.uniform(-1000, 1000, n)
    pA = np.clip(q + rng.uniform(-1, 1, n), -Bv, Bv)
    pB = np.clip(q + rng.choice([-M, 0.0, M], size=n, p=[0.1, 0.8, 0.1]), -Bv, Bv)
    w = np.array([0.5, 0.5])
    L = np.zeros(2)
    LAA = 0.0
    LAA_t = []
    for t in range(n):
        post = w * np.exp(-eta * (L - L.min()))
        post /= post.sum()
        preds = np.array([pA[t], pB[t]])
        g = lambda om: -math.log(float(np.sum(post * np.exp(-eta * (preds - om) ** 2)))) / eta - eta * 0
        gamma = (g(-Bv) - g(Bv)) / (4 * Bv)
        LAA += (gamma - q[t]) ** 2
        L += (preds - q[t]) ** 2
        LAA_t.append(LAA)
    out("   n=%d: L_A = %.1f, L_B = %.4g, L_AA = %.1f; bound L_A + ln 2/eta = %.4g; L_AA / L_A = %.0f" % (
        n, L[0], L[1], LAA, L[0] + math.log(2) / eta, LAA / L[0]))
    k = next(i for i, v in enumerate(LAA_t) if v > 0.9 * LAA)
    out("   90%% of L_AA is incurred in the first %d rounds; final weight on A %.6f" % (k + 1,
                                                                                   (w * np.exp(-eta * (L - L.min())))[0] / np.sum(w * np.exp(-eta * (L - L.min())))))
    Bl = 10800.0
    out("   longitudes (outcomes in [-10800', 10800']): eta = 1/(2 B^2) = %.3g per arcmin^2; one bit of K(G) costs"
        " ln2/eta = %.3g arcmin^2 of cumulative square loss" % (1 / (2 * Bl ** 2), 2 * Bl ** 2 * math.log(2)))
    out("   e.g. K(G) = 2000 bits against a law with RMS error 1': the bound adds %.2g arcmin^2, i.e. it says nothing"
        " until n >> %.2g data" % (2000 * 2 * Bl ** 2 * math.log(2), 2000 * 2 * Bl ** 2 * math.log(2)))


def main():
    rng = np.random.default_rng(SEED)
    out("# rb6_aggregating.py seed=%d numpy %s (referee B, independent of checks/p5_aggregating.py)" % (SEED, np.__version__))
    part_A(rng)
    part_B()
    part_C(rng)
    part_D(rng)
    out("\n# done")
    with open(os.path.join(HERE, "rb6_aggregating.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
