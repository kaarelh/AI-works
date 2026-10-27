"""Budget fractions of the frozen dev runs (own counts) and a projection of the gates block at the grid cells the dev run skipped."""
import json, math
R = "/home/user/AI-works/gd-circuit-growth/study/standard_tasks/results/"
def budget(n, d=784, C=10):
    P = d * 256 + 256 + 256 * 256 + 256 + 256 * C + C; S = int(min(10000, max(2000, math.ceil(50 * n / 128)))); return 3 * 6.0 * P * 128 * S
for n in (100, 300, 1000, 3000, 10000, 30000, 60000): print("budget", n, f"{budget(n):.4g}")
for ds in ("mnist", "fashion_mnist", "qd_dev"):
    g = json.load(open(R + f"p9_gates-dev__{ds}.json")); b = json.load(open(R + f"p9_bank-dev__{ds}.json")); v = json.load(open(R + f"hyb_portfolio__{ds}.json"))
    for i, n in enumerate(g["ns"]):
        j = v["ns"].index(n)
        print(ds, n, "gates", round(g["flops"][i][0] / budget(n), 3), "bank", round(b["flops"][i][0] / budget(n), 3), "v1(s0)", round(v["flops"][j][0] / budget(n), 3),
              "gates-v1", f"{(g['flops'][i][0] - v['flops'][j][0]):.3g}", "cpu gates/bank/v1", round(g["cpu_seconds"][i][0]), round(b["cpu_seconds"][i][0]), round(v["cpu_seconds"][j][0]))
# projection of the gates block (own count) on QuickDraw shapes, measured: a = 676 active columns, mean bins 60, code per tree from ggbt_count
d, a, m = 784, 676, 3 * 676 + 300
def tree(n_fit, bag, bins=60.0, ff=0.12, L=31):
    F = d + m; return 2 * ff * F * bag * n_fit * 2.6 + 12 * ff * F * bins * (2 * L - 3) + 2 * ff * F * bins * (L - 2) + 22 * n_fit
def gates(n):
    pool = 2 * min(n, 20000) * a * a + 2 * n * d * a
    if n <= 3000:
        K = 5 if n > 500 else 10; ntr = n * (K - 1) / K; H = n
        g = K * (2 * ntr * d * m + 1000 * tree(ntr, 1.0) + 2 * (n / K) * d * m) + (2 * n * d * m + 1000 * tree(n, 1.0))
    else:
        h = min(6000, n // 5); H = h; nt = n - h; nf = nt - min(5000, 0.1 * nt); bag = 0.5 if nf > 20000 else 1.0; rounds = 400
        g = 2 * nt * d * m + rounds * 10 * tree(nf, bag) + 2 * h * d * m
        if n * d <= 1e7: g += 2 * n * d * m + 250 * 10 * tree(n, 1.0)
    knn = 2 * H * n * a
    return pool, knn, g
for n in (100, 300, 1000, 3000, 10000, 30000, 60000):
    p, k, g = gates(n); print("gates proj", n, f"pool {p:.3g} gknn {k:.3g} ggbt {g:.3g} total {p + k + g:.3g} = {(p + k + g) / budget(n):.3f} of budget")
# prediction FLOPs per query (upper: all three kNN scans kept)
for n in (1000, 3000, 10000, 30000, 60000):
    q = 2 * 2 * n * d + 2 * n * a + 2 * d * a + 2 * d * m + 9 * n + 4e4
    print("pred/query", n, f"{q:.3g}", "x MLP 2P", round(q / (2 * 269322)), "x mlp_strong", round(q / (6 * 269322)), "test set 10000 / budget", round(1e4 * q / budget(n), 3))
