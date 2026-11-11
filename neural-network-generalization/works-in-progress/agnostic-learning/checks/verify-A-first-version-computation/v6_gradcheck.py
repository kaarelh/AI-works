"""Finite-difference check of the analytic gradient in A_scripts/spc_small_d.py (function fg), by re-executing
its definitions (copied verbatim up to the optimisation loop) on a tiny instance."""
import sys, math, itertools, re
import numpy as np
import os
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "A", "spc_small_d.py")).read()
head = src.split("best = None")[0]
for (d, H, N, c) in [(3, 2, 5, 1.0), (3, 3, 4, 2.0), (4, 4, 3, 0.5)]:
    g = {"__name__": "x"}
    sys.argv = ["x", str(d), str(H), str(N), str(c), "3", "1"]
    exec(head, g)
    rng = np.random.default_rng(0)
    P = sum(g["sizes"])
    p = rng.normal(size=P) * 0.7
    F, grad, _, _ = g["fg"](p)
    num = np.zeros(P); h = 1e-6
    for i in range(P):
        e = np.zeros(P); e[i] = h
        num[i] = (g["fg"](p + e)[0] - g["fg"](p - e)[0]) / (2 * h)
    print(f"d={d} H={H} N={N} c={c}: max |analytic - numeric| = {np.max(np.abs(grad - num)):.2e} (scale {np.max(np.abs(num)):.2e})")
