"""Numerical check of Lemma A3.2 (SGD clocks concentrate around drift clocks).

Toy dictionary of ../A-discrete-model.md section 5 (2205 depth-one gates on d = 30).
Before the first firing the residual is r = y (population mean of y is 0 for maj3,
par2), so the drift clock of candidate m is t * E[y g_m] and the SGD clock is
sum_i eta <y, g_m>_{B_i} over fresh batches B_i of size b.

For several (eta, b) we report, over 5 seeds, the largest deviation
max_{i <= I0} max_m |S_hat - S_bar| up to time t0, the proved bound
R sqrt(2 eta t0 log(2M/delta)/b) (R = 1, delta = 0.05), and the first firing time
of the SGD clock race (threshold Theta = 1, time in units of Theta) against the
population value 1/max_m U_m.

E[y g_m] is computed exactly on a 256-point orthogonal-array design (see below).

Run: python3 sgd_clock_check.py > sgd_clock_check.txt   (a few minutes, one core)
"""
import itertools, math
import numpy as np

D = 30

PI, PJ = map(np.array, zip(*itertools.combinations(range(D), 2)))

def gates(X):
    """all 2205 depth-one gates, vectorized: identities, 4 AND-types and XOR per pair"""
    a, b = X[:, PI], X[:, PJ]
    pa, pb = a > 0, b > 0
    cols = [X,
            np.where(pa & pb, 1.0, -1.0), np.where(~pa & pb, 1.0, -1.0),
            np.where(pa & ~pb, 1.0, -1.0), np.where(~pa & ~pb, 1.0, -1.0), a * b]
    return np.concatenate(cols, 1).astype(np.float32)

def target(name, X):
    if name == "maj3":
        return np.sign(X[:, 0] + X[:, 1] + X[:, 2])
    if name == "par2":
        return X[:, 0] * X[:, 1]

# Exact population utilities from a 256-point design: full factorial on (x1,x2,x3) times a
# strength-2 orthogonal array on the other 27 coordinates (27 of the 31 nonzero GF(2)^5
# characters). Every depth-one gate depends on <= 2 coordinates and y on x1..x3, so the
# joint law of (x1, x2, x3, x_i, x_j) on the design is uniform and design averages are exact.
Z = np.array(list(itertools.product([0, 1], repeat=5)))
C = np.array([[(c >> k) & 1 for k in range(5)] for c in range(1, 28)])
OA = np.where((Z @ C.T) % 2 == 0, 1.0, -1.0)                       # 32 x 27
F3 = np.array(list(itertools.product([-1.0, 1.0], repeat=3)))       # 8 x 3
Xexact = np.array([np.concatenate([f, o]) for f in F3 for o in OA], dtype=np.float32)
Gexact = gates(Xexact)
M = Gexact.shape[1]
print(f"# Lemma A3.2 check: M = {M} candidates, R = 1, delta = 0.05, threshold Theta = 1")
for name in ["maj3", "par2"]:
    U = (Gexact.T @ target(name, Xexact)) / len(Xexact)     # exact population utilities
    t_pop = 1.0 / np.max(np.abs(U))
    print(f"\n## {name}: max |U| = {np.max(np.abs(U)):.3f} (population first firing at t/Theta = {t_pop:.3f})")
    print(f"{'eta':>6} {'b':>4} {'t0':>4} | {'max dev (median, max over seeds)':>34} | {'bound':>6} | first firing (median, min, max)")
    for eta, b in [(0.05, 64), (0.01, 64), (0.002, 64), (0.01, 8), (0.01, 512)]:
        t0 = 1.5 * t_pop
        I0 = int(round(t0 / eta))
        devs, fires = [], []
        for seed in range(5):
            r = np.random.default_rng([seed, int(eta * 1e4), b, len(name)])
            S = np.zeros(M); dev = 0.0; fire = None
            for i in range(1, I0 + 1):
                Xb = r.choice([-1.0, 1.0], size=(b, D)).astype(np.float32)
                yb = target(name, Xb)
                S += eta * (gates(Xb).T @ yb) / b
                dev = max(dev, float(np.max(np.abs(S - i * eta * U))))
                if fire is None and np.max(np.abs(S)) >= 1.0:
                    fire = i * eta
            devs.append(dev); fires.append(fire if fire is not None else np.nan)
        bound = math.sqrt(2 * eta * t0 * math.log(2 * M / 0.05) / b)
        f = np.array(fires)
        print(f"{eta:6.3f} {b:4d} {t0:4.2f} | {np.median(devs):16.3f} {np.max(devs):16.3f} | {bound:6.3f} | "
              f"{np.nanmedian(f):.3f} {np.nanmin(f):.3f} {np.nanmax(f):.3f}")
print("\n(drift clocks use exact population utilities; the bound is the 1-delta quantile bound of Lemma A3.2)")
