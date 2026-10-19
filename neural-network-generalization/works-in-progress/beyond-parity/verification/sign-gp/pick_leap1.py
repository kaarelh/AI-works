"""Classify all leap-1 4-juntas (depending on all 4 bits) with threshold degree 3 up to
NPN equivalence (input permutations, input negations, output negation: these preserve the Fourier
support pattern, leap and threshold degree), compute exact eps_1, eps_2 for each class, and pick the
class representative maximizing (eps_2, eps_1, balance).  Writes leap1_choice.json and leap1_classes.json."""
import json, os, sys, itertools
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import cube, fourier_profile, leap, sign_rep_feasible
from ptf_disagreement import eps_r

k = 4
X = cube(k)
code_of = {tuple(x): i for i, x in enumerate(X.tolist())}
maps = []
for perm in itertools.permutations(range(k)):
    for neg in itertools.product([1, -1], repeat=k):
        idx = [code_of[tuple(neg[j] * x[perm[j]] for j in range(k))] for x in X.tolist()]
        maps.append(np.array(idx))


def canon(f):
    best = None
    for mp in maps:
        for s in (1, -1):
            g = tuple((s * f[mp]).tolist())
            if best is None or g < best:
                best = g
    return best


classes = {}
for code in range(2 ** 16):
    f = np.array([1 - 2 * ((code >> i) & 1) for i in range(16)])
    c, supp, w, deg = fourier_profile(f, k)
    U = 0
    for m in supp:
        U |= m
    if U != 15 or leap(supp) != 1:
        continue
    # threshold degree 3 <=> not sign-representable in degree 2 (degree 3 always works unless parity-like 4)
    if sign_rep_feasible(f, k, 2):
        continue
    cf = canon(f)
    classes.setdefault(cf, 0)
    classes[cf] += 1
print("NPN classes of leap-1, all-variable, threshold-degree>=3 4-juntas:", len(classes),
      "functions:", sum(classes.values()), flush=True)
rows = []
for cf, cnt in classes.items():
    f = np.array(cf, dtype=float)
    c, supp, w, deg = fourier_profile(f, k)
    td = 3 if sign_rep_feasible(f, k, 3) else 4
    e1, _ = eps_r(f, k, 1)
    e2, _ = eps_r(f, k, 2)
    rows.append(dict(f=[int(v) for v in f], count=cnt, threshold_degree=td, fourier_degree=deg, leap=leap(supp),
                     eps1=e1, eps2=e2, mean=float(f.mean()), weight=[float(v) for v in w],
                     coeffs={",".join(str(i + 1) for i in range(k) if (m >> i) & 1) or "0": float(c[m])
                             for m in supp}))
rows.sort(key=lambda r: (-r["eps2"], -r["eps1"], abs(r["mean"]), -r["weight"][1]))
for r in rows:
    print(r["f"], "cnt", r["count"], "td", r["threshold_degree"], "deg", r["fourier_degree"], "eps1", r["eps1"],
          "eps2", r["eps2"], "mean", r["mean"], "W", [round(v, 3) for v in r["weight"]])
json.dump(rows, open(os.path.join(HERE, "leap1_classes.json"), "w"), indent=1)
choice = dict(k=4, f=rows[0]["f"], note="NPN-class representative maximizing (eps2, eps1, balance) among leap-1 "
              "4-juntas of threshold degree 3; see leap1_classes.json", **{kk: rows[0][kk] for kk in
              ("threshold_degree", "fourier_degree", "leap", "eps1", "eps2", "coeffs", "weight", "mean")})
json.dump(choice, open(os.path.join(HERE, "leap1_choice.json"), "w"), indent=1)
print("CHOICE", choice)
