"""Sign-pattern (softplus) envelopes: exact mass, exact sampler, two-sided
intervals by the envelope estimator (rareprob.nets_analytic.
sign_pattern_envelope, envelope_interval).

Part 1 (suite): every one-hidden-layer net of experiments/nets. The envelope
with the smallest mass over n_split in {0, 4, 8, 12, 16}; when Z < 1, the
two-sided interval (eps = 0.1, delta = 0.05, at most 2e7 samples), compared
with the exact p (d <= 28) and with Monte Carlo's sample count
3 ln(2/delta) / (eps^2 p); for d = 64 (p unknown) the interval itself and the
Monte Carlo upper bound ln(2/delta)/N with the same number N of samples.

Part 2 (--shifted): the large-margin regime with exact p. Long-trained
logistic-loss nets (own, d = 24) have p = 0 at t = 0; the event [f < t'] is
studied at thresholds t' > 0 chosen so that the exact failure count is about
2000 and about 20 (exhaustive table); same envelope and interval.

Output: results/signpattern.json (part 1), results/signpattern_shifted.json
(part 2); own nets in results/own_*.npz."""

import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, train_constant  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
EPS, DELTA = 0.1, 0.05


def evaluate(net, p, max_samples=20_000_000, seed=1):
    t0 = time.time()
    env = na.sign_pattern_envelope(net)
    rec = {"logZ": env.logZ, "Z": math.exp(min(env.logZ, 50.0)), "theta": env.theta, "n_split": len(env.N),
           "f0_minus_t": float(net.forward(np.zeros((1, net.d)))[0]) - float(net.threshold),
           "seconds_envelope": time.time() - t0}
    if p:
        rec["K"] = rec["Z"] / p
        rec["N_MC"] = 3 * math.log(2 / DELTA) / (EPS ** 2 * p)
    if env.logZ < 0:
        t1 = time.time()
        est = na.envelope_interval(env, eps=EPS, delta=DELTA, max_samples=max_samples, rng=np.random.default_rng(seed))
        rec.update({"lo": est.lo, "hi": est.hi, "value": est.value, "samples": est.samples,
                    "seconds_sampling": time.time() - t1,
                    "mc_upper_same_N": math.log(2 / DELTA) / est.samples})
        if p is not None:
            rec["covers"] = bool(est.lo <= p <= est.hi)
        if p:
            rec["speedup_samples"] = rec["N_MC"] / est.samples
    return rec


def part1():
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out_path = os.path.join(HERE, "results", "signpattern.json")
    res = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for e in suite:
        if len(e["widths"]) != 1 or e["name"] in res:
            continue
        net = load_net(os.path.join(NETS, e["name"] + ".npz"))
        r = {"name": e["name"], "p": e.get("p_exact"), **evaluate(net, e.get("p_exact"))}
        res[e["name"]] = r
        print(json.dumps(r), flush=True)
        with open(out_path, "w") as f:
            json.dump(res, f, indent=1)


def part2():
    out = {}
    for w, steps in ((32, 400), (32, 800), (64, 400), (64, 800)):
        net, _ = train_constant(24, [w], steps, np.random.default_rng(7000 + w), loss="bce")
        tag = f"own_bce_d24_w{w}_s{steps}"
        np.savez(os.path.join(HERE, "results", tag + ".npz"), W0=net.Ws[0], b0=net.bs[0], W1=net.Ws[1],
                 b1=net.bs[1], threshold=net.threshold, loss=net.loss)
        orc = na.EnumMAPOracle(net)
        vals = np.sort(orc.F.ravel())
        for target in (2000, 20):
            # a threshold strictly between the target-th and (target+1)-th smallest
            # outputs, so the exact count is target (up to ties)
            tt = float(0.5 * (vals[target - 1] + vals[target]))
            net.threshold = tt
            cnt = int(np.sum(vals < tt))
            p = cnt / vals.size
            r = {"name": tag, "threshold": tt, "count": cnt, "p": p, **evaluate(net, p)}
            out[f"{tag}_t{target}"] = r
            print(json.dumps(r), flush=True)
            with open(os.path.join(HERE, "results", "signpattern_shifted.json"), "w") as f:
                json.dump(out, f, indent=1)


if __name__ == "__main__":
    if sys.argv[1:] == ["--shifted"]:
        part2()
    else:
        part1()
