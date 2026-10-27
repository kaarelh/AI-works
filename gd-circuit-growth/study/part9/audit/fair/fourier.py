import sys, itertools, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
import boolfuncs as B
S = B.make_dl_symdev_suite(30)
for name, t in S.items():
    rel = t["relevant"]; k = len(rel)
    X = np.array(list(itertools.product([-1.0, 1.0], repeat=k)))
    Xf = np.zeros((len(X), 30)); Xf[:, rel] = X
    f = t["fn"](Xf)
    mean = f.mean()
    c1 = np.array([np.mean(f * X[:, i]) for i in range(k)])
    c2 = np.array([np.mean(f * X[:, i] * X[:, j]) for i, j in itertools.combinations(range(k), 2)])
    # lowest degree with nonzero weight and weight per degree
    W = {}
    for deg in range(1, k + 1):
        w = 0.0
        for T in itertools.combinations(range(k), deg):
            c = np.mean(f * np.prod(X[:, list(T)], 1)); w += c * c
        W[deg] = w
    low = min([d for d in W if W[d] > 1e-12])
    print(f"{name:8s} k={k:2d} E[f]={mean:+.3f} max|c1|={np.abs(c1).max():.3f} max|c2|={np.abs(c2).max():.3f} lowest nonzero degree={low} "
          f"weight by degree: " + " ".join(f"{d}:{W[d]:.2f}" for d in W if W[d] > 0.005))
