import sys, itertools, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
import boolfuncs as B
S = B.make_dl_symdev_suite(30)
nb = {'band11': 1836, 'ex3of8': 664, 'far9': 296, 'ssym9': 324, 'sym7': 329, 'symxpar': 1410, 'thrsum': 330, 'twosym': 1817}
v2 = {'sym7': 110, 'ex3of8': 117, 'band11': 828, 'far9': 87, 'ssym9': 111, 'symxpar': 111, 'twosym': 415, 'thrsum': 81}
rows = []
for name, t in S.items():
    rel = t["relevant"]; k = len(rel)
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=k))); Xf = np.zeros((len(X), 30)); Xf[:, rel] = X
    f = t["fn"](Xf)
    c1 = X.T @ f / len(X)
    C2 = (X * f[:, None]).T @ X / len(X); np.fill_diagonal(C2, 0)
    th2 = np.abs(np.linalg.eigvalsh(C2)).max(); th1 = np.linalg.norm(c1)
    rows.append((name, k, th1, th2, nb[name], v2[name]))
    print(f"{name:8s} k={k:2d} |deg-1 vector|={th1:.3f} top |eig| of deg-2 matrix={th2:.3f} nets_best n*={nb[name]:5d} v2 n*={v2[name]:4d}")
r = [x for x in rows if x[2] < 1e-9]
lt, ln = np.log([x[3] for x in r]), np.log([x[4] for x in r])
print("targets with no degree-1 signal:", [x[0] for x in r], " log-log slope of nets_best n* vs deg-2 spike:", round(np.polyfit(lt, ln, 1)[0], 2),
      " Spearman-like rank agreement:", np.argsort(np.argsort(-lt)).tolist(), np.argsort(np.argsort(ln)).tolist())
lv = np.log([x[5] for x in r]); print(" v2 slope:", round(np.polyfit(lt, lv, 1)[0], 2))
