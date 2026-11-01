"""Checks of the claims behind nets_lower (output: results/checks.txt).

1. forward_error_bound: |f - F| <= E*/2, with F evaluated exactly in rational
   arithmetic and f evaluated three ways (numpy, left-to-right sums, fused
   multiply-add), on all inputs of small nets (trained, random, weights of
   magnitudes 1e-17 .. 1e17 and down to the subnormal range), on the float64
   attacks of the red-team review, and on random inputs of suite nets; and
   the ratio of E* to the largest observed error.
2. Unbiasedness of the fixed-level SMC estimator, including with a kernel that
   does not mix at all (0 Metropolis steps): the mean of many replicates vs
   the exact D(A_K) (z-score). (Block Gibbs, pooled selection and soft levels:
   ablation.py unbiased.)
3. Coverage of betting_lower (fixed R and anytime-valid sequential use) on
   synthetic nonnegative variables with known mean, including heavy-tailed
   and two-point laws. (Clipped KL and min-Markov: ablation.py unbiased.)
"""

import math
import os
from fractions import Fraction

from common import RES, get_net
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
import adversarial_nets as A  # noqa: E402
from rareprob.nets import all_inputs, init_mlp, train_constant  # noqa: E402
from rareprob.nets_lower import Evaluator, Plan, betting_lower, forward_error_bound, pilot_plan, run_smc  # noqa: E402

LINES = []


def say(s):
    print(s, flush=True)
    LINES.append(s)


def worst_error(net, X):
    with np.errstate(all="ignore"):
        f = net.forward(X)
    worst = Fraction(0)
    for i in range(len(X)):
        F = A.exact_F(net, X[i])
        for v in (float(f[i]), A.sequential_forward(net, X[i]), A.fma_forward(net, X[i])):
            worst = max(worst, abs(Fraction(v) - F))
    return worst


def check_error_bound(rng):
    say("1. forward error bound: max over inputs and over three evaluation orders of |f - F|, against E*/2")
    nets = []
    _, s = train_constant(8, [6], 300, rng, snapshots=(300,))
    nets.append(("trained d8 w6", s[300], 256))
    nets.append(("random d8 w5x4", init_mlp(8, [5, 4], rng), 256))
    m = init_mlp(8, [6, 3], rng)
    m.Ws[0] = m.Ws[0] * np.exp(rng.uniform(-40, 40, m.Ws[0].shape))
    m.Ws[1] = m.Ws[1] * np.exp(rng.uniform(-300, 300, m.Ws[1].shape))
    nets.append(("magnitudes 1e-17..1e17, then 1e-130..1e130", m, 256))
    for name in ("underflow_mse_d10", "underflow_ball_bce_d12", "visible_ball_d14", "fma_tie_d10"):
        nets.append((f"red-team {name}", A.FLOAT_ATTACKS[name][0](), 256))
    for name in ("mse_d24_w32_s1500", "mse_d28_w64_s1000", "mse_d28_w32x32_s500", "bce_d28_w32_s100"):
        nets.append((f"suite {name}", get_net(name), 40))
    for name, net, n in nets:
        E = forward_error_bound(net)
        X = all_inputs(net.d, 0, 1 << net.d) if n >= 1 << net.d else np.where(rng.random((n, net.d)) < 0.5, -1.0, 1.0)
        w = worst_error(net, X)
        say(f"   {name}: E*/2 = {E / 2:.3g}, max |f - F| over {len(X)} inputs = {float(w):.3g}, "
            f"ok = {w <= Fraction(E) / 2}" + (f", E*/(2 max) = {E / 2 / float(w):.3g}" if w > 0 else ""))
    say(f"   red-team overflow_d5: E* = {forward_error_bound(A.overflow(5))} (no bound: an evaluation can overflow)")


def check_unbiased(rng):
    say("2. unbiasedness of fixed-level SMC (mean of replicates vs exact D(A_K))")
    d = 12
    _, s = train_constant(d, [16], 400, rng, snapshots=(400,))
    net = s[400]
    f = np.sort(net.forward(all_inputs(d, 0, 1 << d)))
    net.bs[-1] = net.bs[-1] + (net.threshold - (f[4] + f[5]) / 2)
    ev = Evaluator(net)
    fa = net.forward(all_inputs(d, 0, 1 << d))
    target = float(np.mean(fa < ev.t_cert))
    pil = pilot_plan(ev, 200, 0.3, 2, rng)
    base, nm = pil.plan, len(pil.plan.moves)
    say(f"   net d={d}, D(A_K) = {target:.4g}, {len(base.levels)} levels")
    for name, plan in {"MH, 2 steps, tuned flips": Plan(base.levels, 20, [2] * nm, list(base.flips)),
                       "MH, 0 steps (no mixing)": Plan(base.levels, 20, [0] * nm, [1] * nm),
                       "MH, 1 step, 3 flips": Plan(base.levels, 20, [1] * nm, [3] * nm)}.items():
        res = [run_smc(ev, plan, rng) for _ in range(20000)]
        Z = np.array([r.Z for r in res])
        se = Z.std(ddof=1) / math.sqrt(len(Z))
        say(f"   {name:26s}: mean/D(A_K) = {Z.mean() / target:.4f}, z-score = {(Z.mean() - target) / se:+.2f} "
            f"(20000 replicates, N = 20, flagged {sum(r.flagged for r in res)})")


def check_coverage(rng, trials=1000, delta=0.1):
    say(f"3. coverage of betting_lower on synthetic laws with mean 1 (delta = {delta}, {trials} trials each; "
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
            bet = seq = 0
            for _ in range(trials):
                Z = np.maximum(draw(R), 0.0)
                bet += betting_lower(Z, delta) > 1
                seq += max(betting_lower(Z[:i], delta) for i in range(1, R + 1)) > 1
            say(f"   {name:18s} R={R:2d}: miss rate betting {bet / trials:.4f}, "
                f"sequential running max {seq / trials:.4f}")


def main():
    rng = np.random.default_rng(2026)
    check_error_bound(rng)
    check_unbiased(rng)
    check_coverage(rng)
    open(os.path.join(RES, "checks.txt"), "w").write("\n".join(LINES) + "\n")


if __name__ == "__main__":
    main()
