"""eps_r(f) = min over polynomials p of degree <= r of P_x{ sign p(x) != f(x) } (ties count as errors),
computed exactly on the junta coordinates by a MILP (big-M with bounded coefficients |c|<=C).
This is a property of f only (restricting irrelevant coordinates cannot help).  Writes ptf_disagreement.json."""
import json, os, sys
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import cube, monomial_masks
import targets as T


def eps_r(tab, k, r, C=100.0):
    X = cube(k).astype(float)
    masks = monomial_masks(k, r)
    Phi = np.stack([np.prod(X[:, [i for i in range(k) if (m >> i) & 1]], axis=1) if m else np.ones(2 ** k)
                    for m in masks], axis=1)
    M = 1.0 + C * len(masks)
    P, N = len(masks), 2 ** k
    # variables: c (P, continuous in [-C,C]), e (N, binary).  f(x) p(x) + M e_x >= 1
    A = np.hstack([tab[:, None] * Phi, M * np.eye(N)])
    cons = LinearConstraint(A, lb=np.ones(N), ub=np.inf)
    obj = np.concatenate([np.zeros(P), np.ones(N)])
    integrality = np.concatenate([np.zeros(P), np.ones(N)])
    bounds = Bounds(np.concatenate([-C * np.ones(P), np.zeros(N)]), np.concatenate([C * np.ones(P), np.ones(N)]))
    res = milp(obj, constraints=[cons], integrality=integrality, bounds=bounds,
               options=dict(time_limit=120))
    return float(round(res.fun)) / N, res.status


if __name__ == "__main__":
    out = {}
    for t in T.TARGETS + ["stair5"]:
        if t == "parity_full":
            continue
        try:
            k, tab = T.junta(t, 12)
        except FileNotFoundError:
            continue
        row = {}
        for r in range(0, k + 1):
            e, st = eps_r(tab.astype(float), k, r)
            row[r] = dict(eps=e, milp_status=int(st))
            if e == 0:
                break
        out[t] = row
        print(t, {r: v["eps"] for r, v in row.items()}, flush=True)
    json.dump(out, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ptf_disagreement.json"), "w"),
              indent=1)
