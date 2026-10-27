"""Every 3-CNF is a one-hidden-layer ReLU net of the test-bed form, so the
paper's worst-case barriers apply to the class of all such nets.

For a clause C_i, z_i(x) = sum_{l in C_i} [l is false] - 2 with
[x_k false] = (1 - x_k)/2 and [not x_k false] = (1 + x_k)/2, so on the cube
relu(z_i) = 1 if C_i is violated and 0 otherwise; with f = sum_i relu(z_i)
and t = 1/2, the event f(x) < t is "x satisfies the CNF" and p is the
fraction of satisfying assignments. All weights are +-1/2 or half-integers
(exact floats), the output weights are all positive, and f(0) = 0 < t: the
centre of the cube is a fractional "failing point", so no bound valid on the
box (the LP relaxation's x = 1/2 in SAT) certifies anything at the root.

Checked here: the exact count by branch and bound equals the number of
satisfying assignments counted directly, for random 3-CNFs, and f(0) < t.
Writes results/check_cnf_encoding.json.
"""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import MLP  # noqa: E402
from rareprob.nets_verify import bab  # noqa: E402


def cnf_net(clauses, d):
    m = len(clauses)
    W = np.zeros((m, d))
    b = np.full(m, -2.0)
    for i, cl in enumerate(clauses):
        for lit in cl:
            k = abs(lit) - 1
            # [lit false]: positive literal x_k false iff x_k = -1: (1 - x_k)/2
            s = -0.5 if lit > 0 else 0.5
            W[i, k] += s
            b[i] += 0.5
    return MLP([W, np.ones((1, m))], [b, np.zeros(1)], threshold=0.5, loss="mse")


def count_sat(clauses, d):
    idx = np.arange(1 << d)
    X = np.where((idx[:, None] >> np.arange(d)) & 1, 1, -1)
    ok = np.ones(len(X), dtype=bool)
    for cl in clauses:
        sat = np.zeros(len(X), dtype=bool)
        for lit in cl:
            sat |= (X[:, abs(lit) - 1] == (1 if lit > 0 else -1))
        ok &= sat
    return int(ok.sum())


def main():
    rng = np.random.default_rng(3)
    rows = []
    for trial in range(40):
        d = int(rng.integers(6, 15))
        m = int(rng.integers(d, 5 * d))
        clauses = []
        for _ in range(m):
            vs = rng.choice(d, 3, replace=False) + 1
            clauses.append([int(v) * int(rng.choice([-1, 1])) for v in vs])
        net = cnf_net(clauses, d)
        res = bab(net, r_enum=2, min_rate=0.0)
        n_sat = count_sat(clauses, d)
        f0 = float(net.forward(np.zeros((1, d)))[0])
        assert res.exact and res.fail == n_sat and f0 < 0.5
        rows.append(dict(d=d, m=m, n_sat=n_sat, bab_fpe=res.fpe, nodes_bounded=res.nodes_bounded,
                         certified_safe_nodes=res.certified_safe_nodes, f0=f0))
    out = dict(trials=len(rows), all_match=True, rows=rows)
    json.dump(out, open(os.path.join(HERE, "results", "check_cnf_encoding.json"), "w"), indent=1)
    print("all", len(rows), "CNF nets: exact count = #SAT, f(0) = 0 < 1/2")


if __name__ == "__main__":
    main()
