"""e4: positive examples on small enumerated classes (track notes §4).

(a) Sparse parities on d = 16 bits.  Hypotheses chi_S, |S| <= 4, prior
    w(S) = 2^-(|S|+1) / C(d,|S|), plus the fair-coin law with weight 1/32.
    Loss is the order-free -log2 of the mixture.  Checks: loss <= -log2 w(S*)
    (= 13.13 bits for |S*| = 3) on every order, and the number of steps with
    P(correct label) <= 1/2 is at most that too; order independence.
(b) Thresholds f_theta(x) = [x >= theta] on {0,...,2^20}, prior
    w(theta) = 2^-(2 floor(log2(theta+1)) + 1) (Elias gamma).  Loss for random
    inputs, sorted inputs and the bisection (binary-search) inputs.
(c) Frozen label noise: labels chi_S*(x) xor Bern(eps) drawn once per input,
    d = 12, |S*| = 3, eps = 0.1, distinct inputs.  Mixture over chi_S (|S| <= 3)
    with a Laplace prior on the flip rate.  Regret against n h(eps) and the bound
    log2 C(n,e) + log2(n+1) - log2 w(S*)  (Prop 4.6).

Seed 20261011; output in e4_positive.out.txt.
"""
import itertools
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
import sfi_examples as se  # noqa: E402

OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def subsets_upto(d, kmax):
    out = []
    for k in range(kmax + 1):
        for S in itertools.combinations(range(d), k):
            out.append(S)
    return out


def parity_matrix(subsets, d):
    A = np.zeros((len(subsets), d), dtype=np.int8)
    for i, S in enumerate(subsets):
        A[i, list(S)] = 1
    return A


def h2(p):
    return 0.0 if p in (0.0, 1.0) else -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def main():
    rng = np.random.default_rng(20261011)
    say("e4_positive.py seed=20261011")

    # ---------------- (a) parities ----------------
    d, kmax = 16, 4
    subs = subsets_upto(d, kmax)
    A = parity_matrix(subs, d)
    logw = np.array([-(len(S) + 1) - math.log2(math.comb(d, len(S))) for S in subs])
    logw_noise = -5.0
    say("")
    say(f"(a) parities, d={d}, hypotheses |S|<={kmax} ({len(subs)}) + fair coin (w=1/32); target |S*|=3, "
        f"-log2 w(S*) = {3+1+math.log2(math.comb(d,3)):.3f}; log2 C(16,3) = {math.log2(math.comb(16,3)):.3f}")
    say("    m | mean loss  max loss | mean #steps P(correct)<=1/2  max | order-indep. max |diff| | P(S*|D) mean")
    for m in [4, 8, 16, 24, 32, 64]:
        losses, mistakes, diffs, post = [], [], [], []
        for _ in range(200):
            S = tuple(sorted(rng.choice(d, 3, replace=False)))
            target = np.zeros(d, dtype=np.int8)
            target[list(S)] = 1
            X = rng.integers(0, 2, size=(m, d), dtype=np.int8)
            y = (X @ target) % 2
            consistent_vals = (A @ X.T) % 2 == y[None, :]   # (H, m)
            # sequential: per-step raw conditional = mix(D_t)/mix(D_{t-1})
            prefix_ok = np.cumprod(consistent_vals, axis=1).astype(bool)
            mixt = []
            for t in range(m + 1):
                if t == 0:
                    lm = se.logsumexp2(np.concatenate([logw, [logw_noise]]))
                else:
                    lm = se.logsumexp2(np.concatenate([logw[prefix_ok[:, t - 1]], [logw_noise - t]]))
                mixt.append(lm)
            steps = np.diff(mixt)   # log2 P(y_t | D_{t-1}, x_t)
            losses.append(-mixt[-1])
            mistakes.append(int(np.sum(steps <= -1.0 + 1e-12)))
            # order independence
            perm = rng.permutation(m)
            ok2 = np.all(consistent_vals[:, perm], axis=1)
            l2 = -se.logsumexp2(np.concatenate([logw[ok2], [logw_noise - m]]))
            diffs.append(abs(l2 - losses[-1]))
            iS = subs.index(S)
            post.append(2 ** (logw[iS] + losses[-1]))
        say(f"  {m:3d} | {np.mean(losses):9.3f} {np.max(losses):9.3f} | {np.mean(mistakes):10.3f} {np.max(mistakes):6d} "
            f"| {np.max(diffs):.2e} | {np.mean(post):.4f}")
    # unit-vector order: reveals S coordinate by coordinate
    S = (2, 7, 11)
    target = np.zeros(d, dtype=np.int8)
    target[list(S)] = 1
    X = np.eye(d, dtype=np.int8)
    y = (X @ target) % 2
    cv = (A @ X.T) % 2 == y[None, :]
    pok = np.cumprod(cv, axis=1).astype(bool)
    cum = [-se.logsumexp2(np.concatenate([logw[pok[:, t]], [logw_noise - t - 1]])) for t in range(d)]
    say(f"    unit-vector order, S*={S}: cumulative loss after each of the 16 steps: "
        + " ".join(f"{c:.2f}" for c in cum))

    # ---------------- (b) thresholds ----------------
    say("")
    U = 2 ** 20
    th = np.arange(U + 1)
    lw = -(2 * np.floor(np.log2(th + 1)) + 1)
    w = np.exp2(lw)
    cw = np.concatenate([[0.0], np.cumsum(w)])   # cw[j] = sum_{theta < j} w

    def thr_loss(xs, theta):
        ys = xs >= theta
        a = xs[~ys].max() + 1 if np.any(~ys) else 0      # theta > max zero-labelled x
        b = xs[ys].min() if np.any(ys) else U            # theta <= min one-labelled x
        return -math.log2(cw[b + 1] - cw[a])
    say(f"(b) thresholds on {{0..2^20}}, Elias-gamma prior; total prior mass {w.sum():.6f}")
    say("    theta*    -log2 w | random m=20  sorted m=20 (same set) | random m=200 | bisection inputs (20 queries)")
    for theta in [5, 1000, 123456, 1000000]:
        xs = rng.integers(0, U + 1, size=20)
        l_rand = thr_loss(xs, theta)
        l_sorted = thr_loss(np.sort(xs), theta)
        l200 = thr_loss(rng.integers(0, U + 1, size=200), theta)
        lo, hi = 0, U + 1
        q = []
        while hi - lo > 1:
            mid = (lo + hi) // 2
            q.append(mid)
            if mid >= theta:
                hi = mid
            else:
                lo = mid
        l_bis = thr_loss(np.array(q), theta)
        say(f"    {theta:8d} {-lw[theta]:7.1f} | {l_rand:10.3f}  {l_sorted:10.3f}            | {l200:10.3f}   | {l_bis:8.3f} ({len(q)} queries)")

    # ---------------- (c) frozen noise ----------------
    say("")
    d = 12
    subs = subsets_upto(d, 3)
    A = parity_matrix(subs, d)
    logw = np.array([-(len(S) + 1) - math.log2(math.comb(d, len(S))) for S in subs])
    logw = logw - se.logsumexp2(logw)     # renormalise to a probability on |S| <= 3
    eps = 0.1
    all_x = np.array(list(itertools.product([0, 1], repeat=d)), dtype=np.int8)
    say(f"(c) frozen noise, d={d}, eps={eps}, |S*|=3, Laplace prior on the flip rate; n h(eps) per example = {h2(eps):.4f}")
    w3 = -logw[subs.index((0, 1, 2))]
    say("     n | mean L    mean oracle | regret vs oracle: mean    sd   [min, max] | -log2 w(S*) + 0.5 log2 n "
        "| max(L - bound) | mean P(S*|D)")
    say("       (oracle = -log2 of the true conditional law, i.e. e log2(1/eps) + (n-e) log2(1/(1-eps)), e = #flips;")
    say("        bound = log2 C(n,e) + log2(n+1) - log2 w(S*), Prop 4.6)")
    for n in [25, 50, 100, 200, 400, 800, 1600, 3200]:
        Ls, orc, slack, post = [], [], [], []
        for _ in range(100):
            S = tuple(sorted(rng.choice(d, 3, replace=False)))
            iS = subs.index(S)
            idx = rng.choice(len(all_x), size=n, replace=False)
            X = all_x[idx]
            clean = (X @ A[iS]) % 2
            flips = (rng.random(n) < eps).astype(np.int8)
            y = clean ^ flips
            disagree = ((A @ X.T) % 2 != y[None, :]).sum(axis=1)       # e_S
            comp = logw + se.log2_beta_counts(disagree, n - disagree)
            L = -se.logsumexp2(comp)
            Ls.append(L)
            e_star = int(disagree[iS])
            orc.append(e_star * math.log2(1 / eps) + (n - e_star) * math.log2(1 / (1 - eps)))
            bound = float(se.log2_binom(n, e_star)) + math.log2(n + 1) - logw[iS]
            slack.append(L - bound)
            post.append(2 ** (comp[iS] + L))
        reg = np.array(Ls) - np.array(orc)
        say(f"  {n:5d} | {np.mean(Ls):8.2f} {np.mean(orc):9.2f}  | {reg.mean():8.2f} {reg.std():6.2f} [{reg.min():6.2f},{reg.max():6.2f}] "
            f"| {w3 + 0.5*math.log2(n):8.2f}                 | {np.max(slack):9.2e}      | {np.mean(post):.4f}")
    with open(os.path.join(HERE, "e4_positive.out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
