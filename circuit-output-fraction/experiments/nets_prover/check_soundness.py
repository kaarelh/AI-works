"""Soundness checks for rareprob.nets_prover against exact rational counts.

1. Bounds. For random and adversarial nets (random weights at scales 1e-6 ..
   1e6, small-integer weights with many exact ties f = t, nets with a point at
   f = t - 2^-60 that float64 evaluates to t, trained nets) and random
   subcubes: every 'lin' and 'quad' bound (honest certificates from the
   prover's optimisers, and random parameters) must be <= the exact minimum
   of sign * f over the subcube (computed in rational arithmetic).
2. Exact certificates. prove + verify with no open leaf must return exactly
   p (exact rational count), for every net.
3. Malformed and dishonest arguments (on each net): forged SAFE / FAIL leaves
   with garbage, NaN, inf, wrong-shape or adversarially scaled parameters,
   quad certificates whose shift is slightly too large, tampered tree
   structure (split on a fixed coordinate, out-of-range or non-integer
   coordinates, truncated or extended trees, unknown kinds), sample budgets
   of every type. Each verdict must contain the exact p, or be [0, 1].
4. Coverage of the sampled part: honest hybrid arguments with open leaves,
   repeated with fresh coins at delta = 0.1; miss rate must be <= ~delta.
5. Sub-cube arguments (prove / verify with `root`), the verifier's cap on
   enumeration (ENUM leaves above max_enum_r free inputs are sampled instead),
   and witness lists (duplicates, non-failing and malformed points mixed in).

Usage: python3 check_soundness.py [n_nets]  -> results/soundness.json
"""
import copy
import json
import math
import os
import sys
import time
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import MLP, train_constant  # noqa: E402
from rareprob.nets_prover import (CertNet, ProverConfig, prove, verify, _opt_quad, _opt_alpha,  # noqa: E402
                                  witness_lower_bound, SAFE, FAIL, ENUM, OPEN, SPLIT)


def exact_values(cn: CertNet):
    """Exact f on every point of the cube (Fractions), d <= 12."""
    d = cn.d
    pts = np.array([[1.0 if (i >> k) & 1 else -1.0 for k in range(d)] for i in range(1 << d)])
    vals = [cn.exact_f(x) for x in pts]
    return pts, vals


def make_nets(rng, n_random):
    nets = []
    # random weights at many scales, 1 or 2 hidden layers
    for i in range(n_random):
        d = int(rng.integers(6, 11))
        L = int(rng.integers(1, 3))
        widths = [int(rng.integers(3, 12)) for _ in range(L)]
        scale = 10.0 ** rng.uniform(-6, 6)
        sizes = [d] + widths + [1]
        Ws = [rng.normal(0, 1, (b, a)) * scale for a, b in zip(sizes[:-1], sizes[1:])]
        bs = [rng.normal(0, 1, b) * scale for b in sizes[1:]]
        # threshold near the median of f so that p is moderate
        net = MLP(Ws, bs, threshold=0.0)
        X = rng.choice([-1.0, 1.0], size=(512, d))
        net.threshold = float(np.quantile(net.forward(X), rng.uniform(0.0, 0.3)))
        nets.append((f"random{i}", net))
    # small-integer weights: many exact ties f = t
    for i in range(4):
        d = 8
        sizes = [d, 6, 1] if i % 2 == 0 else [d, 5, 4, 1]
        Ws = [rng.integers(-2, 3, (b, a)).astype(float) for a, b in zip(sizes[:-1], sizes[1:])]
        bs = [rng.integers(-2, 3, b).astype(float) for b in sizes[1:]]
        net = MLP(Ws, bs, threshold=0.0)
        X = rng.choice([-1.0, 1.0], size=(512, d))
        vals = net.forward(X)
        net.threshold = float(np.median(vals))  # an attained integer value: exact ties
        nets.append((f"ties{i}", net))
    # f = 1/2 - 2^-60 relu(x_1): x_1 = +1 fails exactly, float64 says 1/2
    W1 = np.zeros((2, 8))
    W1[0, 0] = 1.0
    W1[1, 1] = 1.0
    net = MLP([W1, np.array([[-2.0 ** -60, 1e-3]])], [np.zeros(2), np.array([0.5])], threshold=0.5)
    nets.append(("tiny_gap", net))
    # trained nets (small d)
    for i, (loss, steps) in enumerate([("mse", 600), ("bce", 60), ("mse", 400)]):
        w = [12] if i < 2 else [8, 8]
        net, _ = train_constant(10, w, steps, rng, loss=loss)
        nets.append((f"trained_{loss}{i}", net))
    return nets


def random_subcube(rng, d):
    x0 = np.zeros(d)
    r = int(rng.integers(0, d + 1))
    fixed = rng.choice(d, d - r, replace=False)
    x0[fixed] = rng.choice([-1.0, 1.0], d - r)
    return x0


def in_subcube(pts, x0):
    m = x0 != 0
    return np.all(pts[:, m] == x0[m], axis=1)


def check_bounds(cn, pts, vals, rng, n_sub=40):
    viol = 0
    checks = 0
    for _ in range(n_sub):
        x0 = random_subcube(rng, cn.d)
        sel = np.nonzero(in_subcube(pts, x0))[0]
        vmin = min(vals[i] for i in sel)
        vmax = max(vals[i] for i in sel)
        ivs, c, c_abs = cn.intervals(x0[None])
        cands = [("lin0+", cn.check_lin(x0[None], None, 1, ivs)[0], 1),
                 ("lin0-", cn.check_lin(x0[None], None, -1, ivs)[0], -1)]
        al, _ = _opt_alpha(cn, x0[None], 1, ivs, c, 30)
        cands.append(("linopt+", cn.check_lin(x0[None], [al] + [None] * (cn.L - 1), 1, ivs)[0], 1))
        ral = [rng.uniform(-0.5, 1.5, (1, m)) for m in cn.widths]
        cands.append(("linrand+", cn.check_lin(x0[None], ral, 1, ivs)[0], 1))
        cands.append(("linrand-", cn.check_lin(x0[None], ral, -1, ivs)[0], -1))
        if (x0 == 0).sum() >= 1:
            for sign in (1, -1):
                certs, lq = _opt_quad(cn, x0[None], sign, 80)
                cands.append((f"quadopt{sign}", lq[0], sign))
                n = int((x0 == 0).sum()) + 1
                th = rng.uniform(0, 1, (cn.widths[0], 2))
                mu = rng.normal(0, 1, n) * (abs(cn.t) + 1)
                cands.append((f"quadrand{sign}", cn.check_quad(x0, None, th, mu, -abs(rng.normal()) * 10, sign), sign))
                if certs[0] is not None:
                    # a slightly too large shift must not be accepted with a wrong bound
                    c2 = certs[0]
                    for bump in (1e-12, 1e-9, 1e-6, 1e-3):
                        cands.append((f"quadbump{sign}", cn.check_quad(x0, None, c2["theta"], c2["mu"],
                                                                     c2["shift"] + bump, sign), sign))
        for name, lb, sign in cands:
            checks += 1
            ref = vmin if sign == 1 else -vmax
            if math.isfinite(lb) and Fraction(lb) > ref:
                viol += 1
                print("  BOUND VIOLATION", name, lb, float(ref))
    return checks, viol


def tamper(arg, rng, d, m_widths, kind):
    """A dishonest or malformed variant of an honest argument."""
    a = copy.deepcopy(arg)
    tree = a["tree"]
    if kind == "forge_safe":  # every ENUM leaf claimed SAFE with garbage slopes
        for i, nd in enumerate(tree):
            if nd[0] == ENUM:
                tree[i] = (SAFE, {"kind": "lin", "alpha": [rng.uniform(-1, 2, m) for m in m_widths]})
    elif kind == "forge_fail":
        for i, nd in enumerate(tree):
            if nd[0] in (ENUM, SAFE):
                tree[i] = (FAIL, {"kind": "lin", "alpha": [np.full(m, np.nan) for m in m_widths]})
    elif kind == "forge_quad":
        for i, nd in enumerate(tree):
            if nd[0] in (ENUM, FAIL):
                n = d + 1  # wrong size in general
                tree[i] = (SAFE, {"kind": "quad", "alpha": None, "theta": rng.uniform(0, 1, (m_widths[0], 2)),
                                  "mu": rng.normal(0, 1e6, n), "shift": 1e9})
    elif kind == "quad_shapes":
        for i, nd in enumerate(tree):
            if nd[0] == ENUM:
                tree[i] = (SAFE, {"kind": "quad", "alpha": [None] * len(m_widths), "theta": "x",
                                  "mu": [math.inf], "shift": float("nan")})
    elif kind == "bad_alpha_shape":
        for i, nd in enumerate(tree):
            if nd[0] in (SAFE, ENUM):
                tree[i] = (SAFE, {"kind": "lin", "alpha": [np.ones(m + 1) for m in m_widths]})
    elif kind == "no_cert":
        for i, nd in enumerate(tree):
            if nd[0] == ENUM:
                tree[i] = (SAFE,)
    elif kind == "unknown_cert":
        for i, nd in enumerate(tree):
            if nd[0] == ENUM:
                tree[i] = (SAFE, {"kind": "trust-me"})
    elif kind == "split_fixed":
        a["tree"] = [(SPLIT, 0), (SPLIT, 0), (ENUM,), (ENUM,), (ENUM,)]
    elif kind == "split_range":
        a["tree"] = [(SPLIT, d), (ENUM,), (ENUM,)]
    elif kind == "split_float":
        a["tree"] = [(SPLIT, 1.0), (SAFE, {"kind": "lin", "alpha": None}), (SAFE, {"kind": "lin", "alpha": None})]
    elif kind == "split_bool":
        a["tree"] = [(SPLIT, True), (SAFE, {"kind": "lin", "alpha": None}), (SAFE, {"kind": "lin", "alpha": None})]
    elif kind == "truncate":
        a["tree"] = tree[:-1] if len(tree) > 1 else [(SPLIT, 0)]
    elif kind == "extend":
        a["tree"] = tree + [(ENUM,)]
    elif kind == "unknown_kind":
        a["tree"] = [("magic",)]
    elif kind == "empty":
        a["tree"] = []
    elif kind == "all_safe_root":
        a["tree"] = [(SAFE, {"kind": "lin", "alpha": None})]
    elif kind == "all_fail_root":
        a["tree"] = [(FAIL, {"kind": "lin", "alpha": None})]
    elif kind == "open_root_nosamples":
        a["tree"] = [(OPEN,)]
        a["samples"] = 0
    elif kind == "open_root_badsamples":
        a["tree"] = [(OPEN,)]
        a["samples"] = "many"
    elif kind == "open_root_negsamples":
        a["tree"] = [(OPEN,)]
        a["samples"] = -5
    elif kind == "open_root_samples":
        a["tree"] = [(OPEN,)]
        a["samples"] = 4000
    return a


TAMPER = ["forge_safe", "forge_fail", "forge_quad", "quad_shapes", "bad_alpha_shape", "no_cert", "unknown_cert",
          "split_fixed", "split_range", "split_float", "split_bool", "truncate", "extend", "unknown_kind", "empty",
          "all_safe_root", "all_fail_root", "open_root_nosamples", "open_root_badsamples", "open_root_negsamples",
          "open_root_samples"]


def main():
    n_random = int(sys.argv[1]) if len(sys.argv) > 1 else 16
    rng = np.random.default_rng(2026)
    t0 = time.time()
    report = {"nets": [], "bound_checks": 0, "bound_violations": 0, "exact_runs": 0, "exact_mismatch": 0,
              "tamper_runs": 0, "tamper_misses": 0, "tamper_rejected": 0, "tamper_demoted": 0,
              "coverage_runs": 0, "coverage_misses": 0}
    for name, net in make_nets(rng, n_random):
        try:
            cn = CertNet(net)
        except ValueError as e:
            print(name, "rejected by CertNet:", e)
            continue
        pts, vals = exact_values(cn)
        T = Fraction(cn.t)
        F = sum(1 for v in vals if v < T)
        ties = sum(1 for v in vals if v == T)
        p = Fraction(F, 1 << cn.d)
        ch, vi = check_bounds(cn, pts, vals, rng)
        report["bound_checks"] += ch
        report["bound_violations"] += vi
        rec = {"name": name, "d": cn.d, "widths": cn.widths, "F": F, "ties": ties, "bound_checks": ch, "bound_viol": vi}
        # honest exact certificate
        for kinds in [("lin",), ("lin", "quad")]:
            arg, info = prove(cn, ProverConfig(kinds=kinds, r_leaf=2, quad_rmin=2, quad_iters=60, alpha_iters=20,
                                               collapse=False))
            res = verify(cn, arg, rng=rng)
            report["exact_runs"] += 1
            ok = res.exact and res.F == F and res.contains(p)
            if not ok:
                report["exact_mismatch"] += 1
                print("  EXACT MISMATCH", name, kinds, res.F, F, res.lo, res.hi)
            rec[f"exact_{'+'.join(kinds)}"] = {"F": res.F, "leaves": res.leaves, "nodes": info.nodes}
        # dishonest variants (delta small so that a miss would be a bug, not bad luck)
        for kind in TAMPER:
            bad = tamper(arg, rng, cn.d, cn.widths, kind)
            if kind in ("forge_safe", "forge_fail", "forge_quad", "quad_shapes", "bad_alpha_shape", "no_cert",
                        "unknown_cert"):
                bad["samples"] = 3000
            res = verify(cn, bad, delta=1e-3, rng=rng)
            report["tamper_runs"] += 1
            report["tamper_rejected"] += res.rejected is not None
            report["tamper_demoted"] += res.demoted
            if not res.contains(p):
                report["tamper_misses"] += 1
                print("  TAMPER MISS", name, kind, float(p), res.lo, res.hi, res.rejected, res.demoted)
        # coverage of the sampled part: open every leaf that contains a failure
        arg_h, _ = prove(cn, ProverConfig(kinds=("lin",), r_leaf=2, collapse=False))
        tree = [(OPEN,) if nd[0] == ENUM else nd for nd in arg_h["tree"]]
        hy = {"tree": tree, "samples": 400}
        miss = 0
        for rep in range(25):
            res = verify(cn, hy, delta=0.1, rng=rng)
            miss += not res.contains(p)
        report["coverage_runs"] += 25
        # sub-cube arguments, enumeration cap, witness lists
        for rep in range(3):
            root = random_subcube(rng, cn.d)
            sel = np.nonzero(in_subcube(pts, root))[0]
            Fr = sum(1 for i in sel if vals[i] < T)
            arg_r, _ = prove(cn, ProverConfig(kinds=("lin", "quad"), r_leaf=2, quad_rmin=2, quad_iters=40,
                                              alpha_iters=20), root=root)
            res = verify(cn, arg_r, rng=rng, root=root)
            report["exact_runs"] += 1
            if not (res.exact and res.F == Fr and res.contains(Fraction(Fr, len(sel)))):
                report["exact_mismatch"] += 1
                print("  SUBCUBE MISMATCH", name, res.F, Fr)
        res = verify(cn, {"tree": [(ENUM,)], "samples": 0}, rng=rng, max_enum_r=3)
        report["tamper_runs"] += 1
        report["tamper_demoted"] += res.demoted
        if not res.contains(p) or (cn.d > 3 and res.exact):
            report["tamper_misses"] += 1
            print("  ENUM CAP MISS", name, res.lo, res.hi)
        fail_pts = [pts[i] for i in range(len(vals)) if vals[i] < T]
        junk = [pts[i] for i in range(min(5, len(vals)))] + [np.full(cn.d, 0.5)]
        wl, wk = witness_lower_bound(cn, fail_pts + fail_pts[:3] + junk)
        report["witness_runs"] = report.get("witness_runs", 0) + 1
        if wk != F or Fraction(wl) > p:
            report["witness_errors"] = report.get("witness_errors", 0) + 1
            print("  WITNESS ERROR", name, wk, F)
        report["coverage_misses"] += miss
        rec["coverage_miss"] = miss
        report["nets"].append(rec)
        print(f"{name:14s} d={cn.d} widths={cn.widths} F={F} ties={ties} bounds {ch} viol {vi} "
              f"cov-miss {miss}/25 ({time.time() - t0:.0f}s)", flush=True)
    report["seconds"] = time.time() - t0
    json.dump(report, open(os.path.join(HERE, "results", "soundness.json"), "w"), indent=1, default=str)
    print({k: v for k, v in report.items() if k != "nets"})


if __name__ == "__main__":
    main()
