"""Oracle ceiling for envelopes that are functions of a few quantised hidden
pre-activations (the family of group_tilt_envelope without the tilt): with
hindsight, the smallest such envelope dominating 1_C is the indicator of the
DP cells that contain at least one failing point, and its mass

    Z*_S = sum over cells s of the grid of z_S with a failure of D(cell s)

is a lower bound on the mass of EVERY envelope that depends on x only through
the quantised forms of S (sound or not). Grids as in the DP of
rareprob.nets_analytic (budget 300 per axis for pairs, 60 for triples).

Per net (d = 24, exhaustive): the best pair and triple among the 8 positive
units with the largest lift Pr[|z_j| < sd_j/2 | fail] / Pr[|z_j| < sd_j/2],
their Z*, and K* = Z*/p. A sound envelope of this family would in addition
have to certify every non-failing cell (min of F over the cell >= t), which
by the box barrier needs exact (verification-hard) reasoning per cell.

Output: results/few_forms.json"""

import itertools
import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, _half_inputs  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")


def run(name, p):
    net = load_net(os.path.join(NETS, name + ".npz"))
    W, b, a, c = na.one_layer(net)
    orc = na.EnumMAPOracle(net)
    F = orc.F
    fail = F < net.threshold
    k1, k2 = orc.k1, orc.k2
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    ia, ib = np.nonzero(fail)
    Xf = np.concatenate([HA[ia], HB[ib]], axis=1)
    pos = np.nonzero(a > 0)[0]
    sd = np.linalg.norm(W, axis=1)
    lifts = {}
    for j in pos:
        zf = Xf @ W[j] + b[j]
        # Pr[|z_j| < sd/2] under D by the exact DP law of the quantised form (lower end)
        fm = na.quantize(W[j:j + 1], b[j:j + 1], na.grid_for(W[j:j + 1], 4096))
        law = na.form_dp(fm.N)
        s = law.values(0).ravel()
        zl, zh = fm.z_lo(s, 0), fm.z_hi(s, 0)
        pin = float(law.P.ravel()[(zh < sd[j] / 2) & (zl > -sd[j] / 2)].sum())
        lifts[int(j)] = float(np.mean(np.abs(zf) < sd[j] / 2)) / max(pin, 1e-300)
    top = sorted(lifts, key=lambda j: -lifts[j])[:8]
    rec = {"name": name, "p": p, "lifts_top8": {str(j): lifts[j] for j in top}}
    for size, budget in ((1, 4096), (2, 300), (3, 60)):
        best = None
        for S in itertools.combinations(top, size):
            S = list(S)
            q = na.grid_for(W[S], budget)
            fm = na.quantize(W[S], b[S], q)
            # cell index of every cube point, via the halves
            sA = HA @ fm.N[:, :k1].T + fm.S  # (2^k1, k)
            sB = HB @ fm.N[:, k1:].T
            dims = 2 * fm.S + 1
            mult = np.cumprod(np.concatenate([[1], dims[:-1]])).astype(np.int64)
            cA = (sA.astype(np.int64) @ mult)
            cB = (sB.astype(np.int64) @ mult)
            ncell = int(np.prod(dims))
            hit = np.zeros(ncell, dtype=bool)
            hit[cA[ia] + cB[ib]] = True
            mass = 0
            for s0 in range(0, len(cA), 256):
                idx = (cA[s0:s0 + 256, None] + cB[None, :]).ravel()
                mass += int(hit[idx].sum())
            Z = mass / float(F.size)
            if best is None or Z < best[1]:
                best = (S, Z)
        rec[f"best_{size}"] = {"S": [int(j) for j in best[0]], "Zstar": best[1],
                               "Kstar": best[1] / p if p else None}
    return rec


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    names = sys.argv[1:] or [e["name"] for e in suite if e["d"] <= 24]
    out = {}
    for nm in names:
        e = next(x for x in suite if x["name"] == nm)
        r = run(nm, e.get("p_exact"))
        out[nm] = r
        print(json.dumps(r), flush=True)
        with open(os.path.join(HERE, "results", "few_forms.json"), "w") as f:
            json.dump(out, f, indent=1)
