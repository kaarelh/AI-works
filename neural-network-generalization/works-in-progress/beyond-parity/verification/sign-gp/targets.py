"""Target Boolean functions on {-1,1}^d (juntas on the first coordinates) and their
Fourier / leap / threshold-degree profiles.  `python3 targets.py` writes targets.json."""
import json, os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import cube, fourier_profile, leap, threshold_degree, sign_rep_feasible, stair_sum

HERE = os.path.dirname(os.path.abspath(__file__))

TARGETS = ["parity_full", "parity2", "parity3", "parity4", "maj7", "and3", "stair4", "leap1_td3", "rand4", "stair5",
           "cond_par3_maj3"]


def _leap1_table():
    with open(os.path.join(HERE, "leap1_choice.json")) as fh:
        c = json.load(fh)
    return c["k"], np.array(c["f"])


def _rand4_table():
    rng = np.random.default_rng(2026)
    while True:
        f = rng.choice([-1, 1], size=16)
        _, supp, _, _ = fourier_profile(f, 4)
        U = 0
        for m in supp:
            U |= m
        if U == 15:
            return f


def junta(name, d):
    """(k, truth table on cube(k)) such that target(x) = table[index of x_{1..k}]."""
    if name == "parity_full":
        k = d
        Xk = cube(k)
        return k, np.prod(Xk, axis=1).astype(int)
    if name.startswith("parity"):
        k = int(name[len("parity"):])
        return k, np.prod(cube(k), axis=1).astype(int)
    if name.startswith("maj"):
        k = int(name[3:])
        s = cube(k).sum(axis=1)
        return k, np.sign(s).astype(int)
    if name == "and3":
        Xk = cube(3)
        return 3, np.where(np.all(Xk == 1, axis=1), 1, -1)
    if name == "stair4":
        # sign(x1 + x1x2 + x1x2x3 + x1x2x3x4) has ties (sum 0); break ties toward the first term,
        # i.e. sign(S4 + x1/2).
        Xk = cube(4).astype(float)
        s = stair_sum(Xk, 4) + 0.5 * Xk[:, 0]
        return 4, np.sign(s).astype(int)
    if name == "stair5":
        Xk = cube(5).astype(float)
        return 5, np.sign(stair_sum(Xk, 5)).astype(int)
    if name == "leap1_td3":
        return _leap1_table()
    if name == "rand4":
        return 4, _rand4_table()
    if name == "cond_par3_maj3":
        # x4 ? x1x2x3 : MAJ(x1,x2,x3): leap 1, Fourier degree 4, threshold degree 3
        Xk = cube(4).astype(int)
        par = Xk[:, 0] * Xk[:, 1] * Xk[:, 2]
        maj = np.sign(Xk[:, :3].sum(axis=1))
        return 4, np.where(Xk[:, 3] == 1, par, maj).astype(int)
    raise KeyError(name)


def target_values(name, d):
    """Values on the full cube(d) in cube(d) order.  cube(d) index bits 0..k-1 are coordinates 1..k,
    so the junta index of x is simply idx mod 2^k."""
    k, tab = junta(name, d)
    idx = np.arange(2 ** d) % (2 ** k)
    return tab[idx].astype(float)


def profile(name, d):
    k, tab = junta(name, d)
    c, supp, w, deg = fourier_profile(tab, k)
    lp = leap(supp)
    if name == "parity_full" and k > 8:
        td = k  # Minsky-Papert: parity on k bits has threshold degree k (LP-checked for k<=8 below)
        td_note = "Minsky-Papert (parity on k bits has threshold degree k)"
    else:
        td = threshold_degree(tab, k)
        td_note = "LP"
    return dict(name=name, d=d, junta_size=k, mean=float(np.mean(tab)), fourier_degree=deg,
                fourier_weight_by_degree=[float(v) for v in w], n_support_sets=len(supp),
                threshold_degree=td, threshold_degree_method=td_note, leap=lp,
                support=[[i + 1 for i in range(k) if (m >> i) & 1] for m in supp] if len(supp) <= 40 else "omitted",
                coeffs={",".join(str(i + 1) for i in range(k) if (m >> i) & 1) or "0": float(c[m]) for m in supp}
                if len(supp) <= 40 else "omitted")


if __name__ == "__main__":
    out = {}
    # sanity: the literal 4-term staircase sign is not Boolean
    X4 = cube(4).astype(float)
    S4 = stair_sum(X4, 4)
    out["stair4_raw_check"] = dict(values=sorted(set(S4.tolist())), frac_zero=float(np.mean(S4 == 0)),
                                   note="sign(x1+x1x2+x1x2x3+x1x2x3x4) is 0 on this fraction of inputs, so not "
                                        "Boolean; stair4 breaks ties toward x1 (sign(S4 + x1/2)).")
    # parity threshold-degree LP spot check for small k
    out["parity_td_lp_check"] = {k: int(threshold_degree(np.prod(cube(k), axis=1), k)) for k in range(2, 9)}
    for d in (10, 12):
        for t in TARGETS:
            out[f"{t}@d{d}"] = profile(t, d)
            tv = target_values(t, d)
            assert set(np.unique(tv)) <= {-1.0, 1.0} and len(np.unique(tv)) == 2, t
    json.dump(out, open(os.path.join(HERE, "targets.json"), "w"), indent=1)
    for key, v in out.items():
        if key.endswith("@d12"):
            print(f"{v['name']:12s} k={v['junta_size']:2d} mean={v['mean']:+.3f} deg={v['fourier_degree']:2d} "
                  f"thr={v['threshold_degree']:2d} leap={v['leap']:2d} W=" +
                  " ".join(f"{x:.3f}" for x in v['fourier_weight_by_degree'][:9]))
    print(out["stair4_raw_check"], out["parity_td_lp_check"])
