import os, sys, time
os.environ.setdefault("OMP_NUM_THREADS", "1")
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import numpy as np, common as C
from models.sswm import SSWM
for T in (20000, 100000):
    M = SSWM(T=T)
    for fn in ("par3", "par4"):
        for n in (1024, 4096):
            Xte, yte = C.test_data(fn); errs = []; tms = []; t0 = time.time()
            for s in range(3):
                X, y = C.train_data(fn, s, n)
                r = M.fit(X, y, np.random.default_rng([s, n, 7]))
                errs.append(np.mean(r["predict"](Xte) != yte)); tms.append(r["time"])
            print(f"T={T} {fn} n={n}: test err per seed {np.round(errs, 2)} time {tms} ({time.time() - t0:.0f}s)", flush=True)
