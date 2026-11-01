"""What a MAP call costs beyond enumeration: the perturbed MAP problem of
perturb-and-MAP, max_x [-theta F(x) + sum_i gamma_i(x_i)], for one-hidden-layer
nets as a mixed-integer program solved by HiGHS (scipy.optimize.milp), with a
time limit. Reported: solve time, nodes, and the gap between the solver's
dual bound (what a certified bound would have to use) and its incumbent, in
nats (the units of log Z). For d <= 24 the exact value (enumeration) is
reported too.

Formulation (x = 2u - 1, u binary; z_j = 2 w_j.u + b_j - sum_i w_ji):
  minimise theta sum_j a_j h_j - sum_i (gamma_i(+1) - gamma_i(-1)) u_i
  a_j > 0: h_j >= z_j, h_j >= 0 (the minimisation makes h_j = relu(z_j));
  a_j < 0: h_j <= z_j + M-_j (1 - s_j), h_j <= M+_j s_j, s_j binary
  (big-M from the exact range of z_j on the cube).
HiGHS works in floating point with tolerances, so its dual bound is not a
certificate; this script only measures cost.

Usage: python3 map_cost.py [names...]       (suite nets; results/map_cost.json)
       python3 map_cost.py --scaling          (own nets trained here, d = 24,
       32, 40, 48, one hidden layer of width 32, 1500 steps of MSE training;
       time limit 600 s; results/map_cost_scaling.json)
       python3 map_cost.py --width            (own nets, d in {32, 48, 64} x
       width in {32, 64}: perturbed MAP and min f; results/map_cost_width.json)"""

import json
import math
import os
import sys
import time

import numpy as np
from scipy.optimize import LinearConstraint, milp, Bounds
from scipy.sparse import lil_matrix

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")


def map_milp(net, theta, gp, gm, time_limit=120.0):
    """max_x [-theta F(x) + sum_i (gp_i [x_i=1] + gm_i [x_i=-1])] by MILP."""
    W, b, a, c = na.one_layer(net)
    m, d = W.shape
    neg = [j for j in range(m) if a[j] < 0]
    nv = d + m + len(neg)
    cost = np.zeros(nv)
    cost[:d] = -(gp - gm)
    cost[d:d + m] = theta * a
    integ = np.zeros(nv)
    integ[:d] = 1
    integ[d + m:] = 1
    lo_b = np.zeros(nv)
    hi_b = np.ones(nv)
    rng_lo = b - np.abs(W).sum(1)
    rng_hi = b + np.abs(W).sum(1)
    hi_b[d:d + m] = np.maximum(rng_hi, 0.0)
    rows, lbs, ubs = [], [], []
    A = lil_matrix((2 * m + len(neg), nv))
    r = 0
    off = b - W.sum(1)
    for j in range(m):
        if a[j] > 0:
            A[r, :d] = -2 * W[j]
            A[r, d + j] = 1.0
            lbs.append(off[j])
            ubs.append(np.inf)
            r += 1
    for k, j in enumerate(neg):
        Mm, Mp = max(-rng_lo[j], 0.0), max(rng_hi[j], 0.0)
        A[r, :d] = -2 * W[j]
        A[r, d + j] = 1.0
        A[r, d + m + k] = Mm
        lbs.append(-np.inf)
        ubs.append(off[j] + Mm)
        r += 1
        A[r, d + j] = 1.0
        A[r, d + m + k] = -Mp
        lbs.append(-np.inf)
        ubs.append(0.0)
        r += 1
    A = A[:r].tocsr()
    t0 = time.time()
    res = milp(cost, integrality=integ, bounds=Bounds(lo_b, hi_b),
               constraints=LinearConstraint(A, np.array(lbs), np.array(ubs)),
               options={"time_limit": time_limit, "disp": False})
    sec = time.time() - t0
    const = -theta * c + float(gm.sum())
    inc = const - res.fun if res.fun is not None else None
    dual = const - getattr(res, "mip_dual_bound", np.nan) if getattr(res, "mip_dual_bound", None) is not None else None
    return {"seconds": sec, "status": int(res.status), "message": res.message, "incumbent": inc, "dual_upper": dual,
            "gap_nats": (dual - inc) if (inc is not None and dual is not None) else None,
            "nodes": int(getattr(res, "mip_node_count", -1) or -1)}


def scaling():
    from rareprob.nets import train_constant
    out = {}
    rng = np.random.default_rng(5)
    for d in (24, 32, 40, 48):
        net, _ = train_constant(d, [32], 1500, np.random.default_rng(100 + d))
        recs = []
        for rep in range(2):
            gp = rng.gumbel(size=d) - np.euler_gamma
            gm = rng.gumbel(size=d) - np.euler_gamma
            rec = map_milp(net, 20.0, gp, gm, time_limit=600.0)
            recs.append(rec)
            print(d, json.dumps(rec), flush=True)
        out[d] = {"d": d, "widths": [32], "theta": 20.0, "calls": recs}
        with open(os.path.join(HERE, "results", "map_cost_scaling.json"), "w") as f:
            json.dump(out, f, indent=1)


def scaling_width():
    """d in {32, 48, 64} x width in {32, 64}, 1500 MSE steps (own nets): two
    perturbed MAP calls (theta = 20) and the unperturbed verification problem
    min_x F(x) (theta = 1, zero perturbation), time limit 300 s each."""
    from rareprob.nets import train_constant
    out = {}
    rng = np.random.default_rng(6)
    for d in (32, 48, 64):
        for w in (32, 64):
            net, _ = train_constant(d, [w], 1500, np.random.default_rng(1000 + d + w))
            X = np.random.default_rng(0).choice([-1.0, 1.0], size=(200000, d))
            f = net.forward(X)
            z = float((f.mean() - net.threshold) / f.std())
            recs = []
            for rep in range(2):
                gp = rng.gumbel(size=d) - np.euler_gamma
                gm = rng.gumbel(size=d) - np.euler_gamma
                recs.append(map_milp(net, 20.0, gp, gm, time_limit=300.0))
            ver = map_milp(net, 1.0, np.zeros(d), np.zeros(d), time_limit=300.0)
            key = f"d{d}_w{w}"
            out[key] = {"d": d, "width": w, "z": z, "theta": 20.0, "calls": recs, "min_f_problem": ver,
                        "min_f": -ver["incumbent"] if ver["incumbent"] is not None else None,
                        "min_f_lower": -ver["dual_upper"] if ver["dual_upper"] is not None else None}
            print(key, json.dumps(out[key]), flush=True)
            with open(os.path.join(HERE, "results", "map_cost_width.json"), "w") as fh:
                json.dump(out, fh, indent=1)


if __name__ == "__main__":
    if sys.argv[1:] == ["--scaling"]:
        scaling()
        sys.exit(0)
    if sys.argv[1:] == ["--width"]:
        scaling_width()
        sys.exit(0)
    names = sys.argv[1:] or ["mse_d24_w32_s1500", "bce_d28_w32_s60", "mse_d64_w64_s1000", "bce_d64_w64_s300"]
    out = {}
    rng = np.random.default_rng(3)
    for nm in names:
        net = load_net(os.path.join(NETS, nm + ".npz"))
        theta = 20.0
        recs = []
        orc = na.EnumMAPOracle(net) if net.d <= 24 else None
        for rep in range(3):
            gp = rng.gumbel(size=net.d) - np.euler_gamma
            gm = rng.gumbel(size=net.d) - np.euler_gamma
            rec = map_milp(net, theta, gp, gm, time_limit=300.0 if net.d > 30 else 120.0)
            if orc is not None:
                k1 = orc.k1
                gA = np.zeros(1 << k1)
                gB = np.zeros(1 << orc.k2)
                idxA = np.arange(1 << k1)
                idxB = np.arange(1 << orc.k2)
                for i in range(k1):
                    gA += np.where((idxA >> i) & 1, gp[i], gm[i])
                for i in range(orc.k2):
                    gB += np.where((idxB >> i) & 1, gp[k1 + i], gm[k1 + i])
                rec["exact"] = orc.max_perturbed(theta, gA, gB)
            recs.append(rec)
            print(nm, json.dumps(rec), flush=True)
        out[nm] = {"d": net.d, "widths": net.widths, "theta": theta, "calls": recs}
        with open(os.path.join(HERE, "results", "map_cost.json"), "w") as f:
            json.dump(out, f, indent=1)
