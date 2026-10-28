"""Relaxation gap versus subcube dimension r: for random subcubes of
dimension r (random free coordinates, random values of the fixed ones), the
exact minimum of f (enumeration), and the verifier-checked lower bounds of
'lin' with default slopes, 'lin' with the prover's optimised slopes and
'quad' (Shor certificate, the prover's optimiser). Also f at the box centre
(free coordinates 0), which every box relaxation (LP, CROWN, MILP over the
box, any convex relaxation over the box) is bounded by.

Usage: python3 gap_scan.py [n_per_r]  -> results/gap_scan.json
"""
import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import CertNet, _opt_alpha, _opt_quad  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
NAMES = ["mse_d24_w32_s1500", "mse_d28_w64_s1500", "bce_d28_w32_s100", "bce_d28_w32_s150",
         "mse_d28_w32x32_s500", "bce_d28_w64x64_s100", "mse_d64_w64_s1000", "mse_d64_w64_s3000",
         "bce_d64_w64_s100", "bce_d64_w64_s1000"]
RS = [4, 6, 8, 10, 12, 14, 16]


def main():
    n_per = int(sys.argv[1]) if len(sys.argv) > 1 else 16
    out_path = os.path.join(HERE, "results", "gap_scan.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for name in NAMES:
        if name in out:
            continue
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        rng = np.random.default_rng(11)
        d, t = cn.d, cn.t
        rec = {}
        for r in RS:
            X0 = np.zeros((n_per, d))
            for b in range(n_per):
                fixed = rng.choice(d, d - r, replace=False)
                X0[b, fixed] = rng.choice([-1.0, 1.0], d - r)
            t0 = time.time()
            mins = np.array([cn.enum_points(x)[1].min() for x in X0])
            centre = cn.forward(X0)
            ivs, c, c_abs = cn.intervals(X0)
            lin0 = cn.check_lin(X0, None, 1, ivs)
            al, _ = _opt_alpha(cn, X0, 1, ivs, c, 80)
            lin = np.maximum(lin0, cn.check_lin(X0, [al] + [None] * (cn.L - 1), 1, ivs))
            _, quad = _opt_quad(cn, X0, 1, 300)
            quad = np.maximum(quad, lin)
            rec[r] = {"min_minus_t": (mins - t).tolist(), "centre_minus_t": (centre - t).tolist(),
                      "lin0_minus_t": (lin0 - t).tolist(), "lin_minus_t": (lin - t).tolist(),
                      "quad_minus_t": (quad - t).tolist(),
                      "frac_pure": float((mins >= t).mean()), "frac_lin": float((lin >= t).mean()),
                      "frac_quad": float((quad >= t).mean()), "frac_centre_ok": float((centre >= t).mean()),
                      "median_gap_lin": float(np.median(mins - lin)), "median_gap_quad": float(np.median(mins - quad)),
                      "median_margin": float(np.median(mins - t))}
            print(f"{name:22s} r={r:2d} pure {rec[r]['frac_pure']:.2f} lin {rec[r]['frac_lin']:.2f} "
                  f"quad {rec[r]['frac_quad']:.2f} centre-ok {rec[r]['frac_centre_ok']:.2f} | median margin "
                  f"{rec[r]['median_margin']:.3f} gap lin {rec[r]['median_gap_lin']:.3f} quad "
                  f"{rec[r]['median_gap_quad']:.3f} ({time.time() - t0:.0f}s)", flush=True)
        out[name] = rec
        json.dump(out, open(out_path, "w"), indent=1)


if __name__ == "__main__":
    main()
