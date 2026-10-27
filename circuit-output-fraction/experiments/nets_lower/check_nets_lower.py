"""Checks of the claims behind nets_lower (output: results/checks.txt).

1. forward_error_bound: |f_fl(x) - F(x)| <= E*/2, with F evaluated exactly in
   rational arithmetic, on all inputs of small nets (trained, random, and with
   weights of mixed magnitudes) and on random inputs of suite nets.
2. Unbiasedness of the fixed-level SMC estimator, including with a kernel that
   barely mixes (0 or 1 Metropolis steps), with block Gibbs, and with pooled
   selection: the mean of many replicates vs the exact p (z-score).
3. Coverage of betting_lower (fixed R and anytime-valid sequential use),
   clipped_kl_lower and min_markov_lower on synthetic nonnegative variables
   with known mean, including heavy-tailed and two-point laws.
"""

import math
import os
import sys
from fractions import Fraction

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import all_inputs, exact_failure_count, init_mlp, load_net, train_constant  # noqa: E402
from rareprob.nets_lower import (Evaluator, Plan, betting_lower, clipped_kl_lower, forward_error_bound,  # noqa: E402
                                 min_markov_lower, pilot_plan, run_smc)

OUT = os.path.join(HERE, "results")
LINES = []


def say(s):
    print(s, flush=True)
    LINES.append(s)


def exact_F(net, x):
    h = [Fraction(int(v)) for v in x]
    for li, (W, b) in enumerate(zip(net.Ws, net.bs)):
        z = [Fraction(float(b[j])) + sum(Fraction(float(W[j, i])) * h[i] for i in range(len(h)))
             for j in range(W.shape[0])]
        h = z if li == len(net.Ws) - 1 else [max(v, Fraction(0)) for v in z]
    return h[0]


def check_error_bound(rng):
    say("1. forward error bound")
    nets = []
    _, s = train_constant(8, [6], 300, rng, snapshots=(300,))
    nets.append(("trained d8 w6", s[300]))
    nets.append(("random d8 w5x4", init_mlp(8, [5, 4], rng)))
    m = init_mlp(8, [6], rng)
    m.Ws[0] = m.Ws[0] * np.exp(rng.uniform(-20, 20, m.Ws[0].shape))  # magnitudes 1e-9 .. 1e9
    nets.append(("mixed-magnitude d8 w6", m))
    for name, net in nets:
        E = forward_error_bound(net)
        X = all_inputs(net.d, 0, 1 << net.d)
        f = net.forward(X)
        worst = max(abs(Fraction(float(f[i])) - exact_F(net, X[i])) for i in range(len(X)))
        say(f"   {name}: E*/2 = {E / 2:.3g}, max |f_fl - F| over all {len(X)} inputs = {float(worst):.3g}, "
            f"ok = {worst <= Fraction(E / 2)}")
    for nm in ("mse_d24_w32_s1500", "mse_d28_w64_s1000"):
        path = os.path.join(HERE, "..", "nets", nm + ".npz")
        if not os.path.exists(path):
            continue
        net = load_net(path)
        E = forward_error_bound(net)
        X = np.where(rng.random((100, net.d)) < 0.5, -1.0, 1.0)
        f = net.forward(X)
        worst = max(abs(Fraction(float(f[i])) - exact_F(net, X[i])) for i in range(len(X)))
        say(f"   {nm}: E*/2 = {E / 2:.3g}, max |f_fl - F| on 100 random inputs = {float(worst):.3g}, "
            f"ok = {worst <= Fraction(E / 2)}")


def check_unbiased(rng):
    say("2. unbiasedness of fixed-level SMC (mean of replicates vs exact p)")
    d = 12
    _, s = train_constant(d, [16], 400, rng, snapshots=(400,))
    net = s[400]
    # put the threshold at a small quantile so that p is about 1e-3
    X = all_inputs(d, 0, 1 << d)
    f = net.forward(X)
    q = np.sort(f)[4]
    net.bs[-1] = net.bs[-1] + (net.threshold - (q + np.sort(f)[5]) / 2)
    p = exact_failure_count(net) / float(1 << d)
    ev = Evaluator(net)
    pil = pilot_plan(ev, 200, 0.3, 2, rng)
    base = pil.plan
    variants = {
        "MH, 2 steps": Plan(base.levels, 20, [2] * len(base.moves), [1] * len(base.flips)),
        "MH, 0 steps (no mixing)": Plan(base.levels, 20, [0] * len(base.moves), [1] * len(base.flips)),
        "MH, 1 step, 3 flips": Plan(base.levels, 20, [1] * len(base.moves), [3] * len(base.flips)),
        "block Gibbs r=2, 1 step": Plan(base.levels, 20, [1] * len(base.moves), [2] * len(base.flips), kernel="gibbs"),
        "MH, 2 steps, pooled": Plan(base.levels, 20, [2] * len(base.moves), [1] * len(base.flips), pool=True),
    }
    say(f"   net d={d}, exact p = {p:.4g}, levels {np.round(base.levels, 3).tolist()}")
    for name, plan in variants.items():
        Z = np.array([run_smc(ev, plan, rng).Z for _ in range(20000)])
        se = Z.std(ddof=1) / math.sqrt(len(Z))
        say(f"   {name:26s}: mean/p = {Z.mean() / p:.4f}, z-score = {(Z.mean() - p) / se:+.2f} "
            f"(20000 replicates, N = 20)")


def check_coverage(rng, trials=1000, delta=0.1):
    say(f"3. coverage of the lower bounds on synthetic laws (delta = {delta}, {trials} trials each; "
        f"a sound bound exceeds the mean in at most a delta fraction)")
    laws = {
        "two-point q=0.05": lambda n: (rng.random(n) < 0.05) / 0.05,
        "two-point q=0.5": lambda n: (rng.random(n) < 0.5) / 0.5,
        "lognormal sigma=2": lambda n: np.exp(rng.normal(-2.0, 2.0, n)),
        "exponential": lambda n: rng.exponential(1.0, n),
        "near-constant": lambda n: 1 + 0.01 * rng.normal(size=n),
    }
    for name, draw in laws.items():
        for R in (8, 32):
            miss = dict(bet=0, clip=0, minm=0, seq=0)
            for _ in range(trials):
                Z = np.maximum(draw(R), 0.0)
                mu = 1.0
                miss["bet"] += betting_lower(Z, delta) > mu
                miss["clip"] += clipped_kl_lower(Z, 2.0, delta) > mu
                miss["minm"] += min_markov_lower(Z, delta) > mu
                Lmax = max(betting_lower(Z[:i], delta) for i in range(1, R + 1))
                miss["seq"] += Lmax > mu
            say(f"   {name:18s} R={R:2d}: miss rate betting {miss['bet'] / trials:.4f}, sequential running max "
                f"{miss['seq'] / trials:.4f}, clipped {miss['clip'] / trials:.4f}, min-Markov {miss['minm'] / trials:.4f}")


def main():
    rng = np.random.default_rng(2026)
    check_error_bound(rng)
    check_unbiased(rng)
    check_coverage(rng)
    open(os.path.join(OUT, "checks.txt"), "w").write("\n".join(LINES) + "\n")


if __name__ == "__main__":
    main()
