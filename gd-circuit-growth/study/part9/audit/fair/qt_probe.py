import sys, numpy as np, time
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/standard_tasks")
sys.dont_write_bytecode = True
import data as DATA, mlp_strong as MS
D = DATA.load("qd_dev"); X, y = D["X"], D["y"]
print("qd_dev in mlp_strong.IMAGES:", "qd_dev" in MS.IMAGES)
pool, te = DATA.splits(D, 0)
Xp = X[pool]
z = (Xp == 0).mean(0); one = (Xp == 1).mean(0)
print("pixel zero-fraction quantiles (10,50,90,99%):", np.round(np.quantile(z, [.1, .5, .9, .99]), 3), " frac of exact 1.0 among nonzero:", round(float(((Xp == 1).sum()) / (Xp > 0).sum()), 3))
for n in (100, 1000, 10000):
    tr = pool[:n]
    t0 = time.process_time()
    Ztr = MS.encode(X[tr], D["types"], X[tr], {}, image=False)
    Zte = MS.encode(X[te], D["types"], X[tr], {}, image=False)
    U = MS.encode(X[te], D["types"], X[tr], {}, image=True)
    const = (X[tr].std(0) == 0).sum()
    print(f"n={n}: const train cols {const}; quantile-encoded train range [{Ztr.min():.2f},{Ztr.max():.2f}] mean|z| {np.abs(Ztr).mean():.2f}; "
          f"test: frac entries |z|>3 {np.mean(np.abs(Zte) > 3):.4f} (train {np.mean(np.abs(Ztr) > 3):.4f}); value of 0-pixel per col median {np.median(np.median(np.where(X[te]==0, Zte, np.nan), 0)[~np.isnan(np.median(np.where(X[te]==0, Zte, np.nan),0))]):.2f}; "
          f"unit-encoded test max {U.max():.1f}; cpu {time.process_time()-t0:.1f}s")
