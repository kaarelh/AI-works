"""Common harness: learning curves of a learner on the standard tasks, in the same format as the MLP baseline.

LEARNER API.  An object with .name and .fit(X, y, types, C, rng) -> dict(predict=callable(X)->int labels, flops=float,
[info=dict]).  X: (n, d) raw features as loaded by data.load (continuous columns raw; 'binary' and 'categorical' columns
hold their integer codes); types: list of 'binary' / 'categorical' / 'continuous' (anything else: treat as continuous);
y: (n,) ints in 0..C-1.  fit may use only (X, y, types, C, rng) - in particular not the test set.

PROTOCOL.  For each dataset, a fixed test set (MNIST / Fashion-MNIST: the standard 10000; PMLB: a fixed random 25%,
at most 10000), and for each seed a permutation of the remaining pool; the training set of size n is its first n points
(nested across n).  Grid: n in 100, 300, 1000, 3000, 10000, 30000, 60000 up to the pool size, plus the whole pool.
Seeds 0, 1, 2.  Metric: test error (1 - accuracy).

COMPUTE.  FLOPs, multiply-add = 2.  The MLP's are 6 P x batch x steps per training run (mlp.py); a learner reports its
own.  Results: results/<learner>__<dataset>.json with err[n_index][seed], flops, cpu_seconds.
"""
import os, sys, time, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import data as DATA

RES = os.path.join(HERE, "results")


def evaluate(learner, names, ns=None, seeds=(0, 1, 2), verbose=True, tag=None):
    os.makedirs(RES, exist_ok=True)
    out = {}
    for name in names:
        D = DATA.load(name); grid = ns or DATA.grid(D)
        grid = [n for n in grid if n <= len(D["y"]) - D["n_test"]]
        err = np.full((len(grid), len(seeds)), np.nan); fl = np.zeros_like(err); cpu = np.zeros_like(err)
        for b, s in enumerate(seeds):
            pool, te = DATA.splits(D, s); Xte, yte = D["X"][te], D["y"][te]
            for a, n in enumerate(grid):
                tr = pool[:n]; t0 = time.process_time()
                fit = learner.fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([s, n, 4242]))
                cpu[a, b] = time.process_time() - t0
                err[a, b] = float(np.mean(np.asarray(fit["predict"](Xte)) != yte)); fl[a, b] = float(fit.get("flops", np.nan))
                if verbose:
                    print(f"  {name} n={n} seed={s} err={err[a, b]:.4f} flops={fl[a, b]:.3g} cpu={cpu[a, b]:.1f}s", flush=True)
        r = dict(learner=tag or learner.name, dataset=name, ns=grid, seeds=list(seeds), err=err.tolist(), flops=fl.tolist(),
                 cpu_seconds=cpu.tolist())
        json.dump(r, open(os.path.join(RES, f"{r['learner']}__{name}.json"), "w"))
        out[name] = r
        if verbose:
            print(f"{name}: err by n " + " ".join(f"{n}:{e:.4f}" for n, e in zip(grid, np.nanmean(err, 1))), flush=True)
    return out


def encode_standard(X, types, ref=None, domain=None):
    """The MLP's encoding, also available to learners: continuous -> standardized (with ref's mean/std, default X's);
    binary -> +-1; categorical -> one-hot over domain[j] (the column's possible codes; default: those seen in ref)."""
    ref = X if ref is None else ref
    cols = []
    for j, t in enumerate(types):
        x, r = X[:, j], ref[:, j]
        if t == "categorical":
            for v in (domain[j] if domain is not None else np.unique(r)):
                cols.append(np.where(x == v, 1.0, 0.0))
        elif t == "binary":
            lo = np.min(r); cols.append(np.where(x > lo, 1.0, -1.0))
        else:
            m, sd = r.mean(), r.std(); cols.append((x - m) / (sd if sd > 1e-12 else 1.0))
    return np.stack(cols, 1)


def load_result(learner, name):
    p = os.path.join(RES, f"{learner}__{name}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def mlp_flops(X, types, C, n, domain=None):
    """FLOPs of one MLP training run at training-set size n (the per-fit budget for discrete learners): 6 P x 128 x S
    with P the parameter count of the d_enc-256-256-C network on the standard encoding and S = mlp.n_steps(n)."""
    import math
    d = encode_standard(X[:2], types, ref=X, domain=domain).shape[1]
    W, B = 256, 128
    P = d * W + W + W * W + W + W * C + C
    S = int(min(10000, max(2000, math.ceil(50 * n / B))))
    return 6.0 * P * B * S
