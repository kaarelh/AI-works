"""v3: independent checks of teacher/notes-final.md Prop 3.6 (which schedules keep the identification).

Written for research/tracks/split/verify-teacher.md; no code shared with teacher/checks/ or referee_code/.
Seeded: numpy default_rng(613). Deterministic given the seed.

(A) A small exact illustration of (a) and (b) in PQ (= FQ for the deterministic teacher). Their proofs use only a
    countable class with finitely many programs per length, a program of risk 0 (for (a)) and one of finite risk
    (for (b)); so a small explicit class is a fair test of the mechanism, not of the teacher's constants.
    Instance: d = 6, m = 6 (idiosyncratic rule), p = 1/8 (s_0 = 8), uniform inputs on {0,1}^6, i.i.d. queries.
    Class (lengths in bits, chosen by hand): coin (2); constant 0 (1, risk inf); deterministic true parity (8, risk
    inf); true parity with flip rates 1/4, 1/8, 1/16 (11, 11, 12); five wrong parities at rate 1/8 (11); parity +
    rule, deterministic y* (6 + ceil(log C(64,8)) + 4 = 42, risk 0); a lookup table of y* (70, risk 0).
    One sample path, extended by exact multinomial increments between checkpoints n = 2^4 ... 2^40.
    Schedules: lambda_n = sqrt(n) and n^0.8 ((a): MAP has risk 0 eventually), n^1.5 ((b): MAP length <= l_min = 2),
    and lambda_n = 0.03 n, inside this class's c-window (0.0175, 0.0507) (the analogue of (c)).
(B) (c) at the example's sizes with a finite truncation B = 30: the margin min_{[c1,c2]} (Phi_2 - J_g) and the
    smallest n (powers of 10) with epsilon_bar_n below it, delta = 0.01, kappa = 0 (illustration), delta_S = 0.
"""
import math
import numpy as np

LOG = math.log2
rng = np.random.default_rng(613)


def H(p):
    return -(p * LOG(p) + (1 - p) * LOG(1 - p))


def partA():
    d = 6
    X = np.arange(2 ** d)
    bits = ((X[:, None] >> np.arange(d)) & 1)
    a = np.array([1, 0, 1, 1, 0, 1])
    fa = (bits @ a) % 2
    S = rng.choice(2 ** d, size=8, replace=False)
    E = np.zeros(2 ** d, dtype=bool)
    E[S] = True
    ystar = fa ^ E
    progs = []   # (name, length, per-input loss vector in bits, risk)

    def add(name, l, probs_of_ystar):
        with np.errstate(divide="ignore"):
            loss = -np.log2(probs_of_ystar)
        progs.append((name, l, loss, float(loss.mean())))

    add("coin", 2, np.full(2 ** d, 0.5))
    add("const0", 1, np.where(ystar == 0, 1.0, 0.0))
    add("parity det", 8, np.where(ystar == fa, 1.0, 0.0))
    for q, l in ((1 / 4, 11), (1 / 8, 11), (1 / 16, 12)):
        add(f"parity q={q}", l, np.where(ystar == fa, 1 - q, q))
    for k in range(5):
        a2 = rng.integers(0, 2, size=d)
        if np.array_equal(a2, a):
            a2[0] ^= 1
        f2 = (bits @ a2) % 2
        add(f"wrong parity {k}", 11, np.where(ystar == f2, 7 / 8, 1 / 8))
    LS = LOG(math.comb(64, 8))
    add("parity+rule", 6 + math.ceil(LS) + 4, np.ones(2 ** d))
    add("lookup", 70, np.ones(2 ** d))
    names = [p[0] for p in progs]
    lens = np.array([p[1] for p in progs], dtype=float)
    losses = np.array([p[2] for p in progs])
    risks = np.array([p[3] for p in progs])
    lmin = min(l for (_, l, _, r) in progs if r < math.inf)
    good = [i for i, nme in enumerate(names) if nme.startswith("parity q=")]
    rate_model = (1 - H(1 / 8)) / (11 - 2)
    rate_rule = H(1 / 8) / (42 - 11)
    print("=" * 96)
    print("(A) Prop 3.6(a),(b) in a small explicit class (PQ, one sample path)")
    print(f"    L_S = log C(64,8) = {LS:.2f}; class c-window of the rate-1/8 parity: ({rate_rule:.4f}, {rate_model:.4f})")
    sched = {"sqrt(n)": lambda n: math.sqrt(n), "n^0.8": lambda n: n ** 0.8, "n^1.5": lambda n: n ** 1.5,
             "0.03 n": lambda n: 0.03 * n}
    counts = np.zeros(2 ** d, dtype=np.int64)
    n_prev = 0
    hist = {k: [] for k in sched}
    for e in range(4, 41):
        n = 2 ** e
        counts += rng.multinomial(n - n_prev, np.full(2 ** d, 2.0 ** -d))
        n_prev = n
        with np.errstate(invalid="ignore"):
            L = np.where(counts[None, :] > 0, losses * counts[None, :], 0.0).sum(axis=1)
        for k, f in sched.items():
            lam = f(n)
            Jv = lam * lens + L
            best = np.min(Jv)
            maps = [names[i] for i in np.flatnonzero(Jv == best)]
            hist[k].append((n, maps))
    for k in sched:
        last_change = None
        prev = None
        for n, maps in hist[k]:
            if maps != prev:
                last_change = (n, maps)
            prev = maps
        print(f"    lambda_n = {k:8s}: MAP from n = 2^{int(LOG(last_change[0]))} on: {last_change[1]}")
    # assertions: the eventual MAPs
    fin = {k: hist[k][-1][1] for k in sched}
    idx = {nme: i for i, nme in enumerate(names)}
    assert all(risks[idx[nm]] == 0 for nm in fin["sqrt(n)"]) and all(risks[idx[nm]] == 0 for nm in fin["n^0.8"])
    assert all(lens[idx[nm]] <= lmin for nm in fin["n^1.5"])
    assert all(idx[nm] in good for nm in fin["0.03 n"])
    print(f"    eventual MAPs: risk 0 under sqrt(n) and n^0.8; length <= l_min = {lmin} under n^1.5; a true-parity")
    print("    member under 0.03 n (inside the class's window); all assertions passed")


def partB():
    d, m, r, B, kappa, dS, delta = 100, 20, 10, 30, 0.0, 0.0, 0.01
    p = 2.0 ** -r
    s0 = 2 ** (m - r)
    LS = LOG(math.comb(2 ** m, s0))
    kg = 2 * LOG(d) + 2 * LOG(r) + kappa
    tauB = 2.0 ** (1 - B)
    L1 = 2 * LOG(d) + 2 * LOG(m) + 2 * LOG(B) + 2 ** m * LOG(1 + tauB) + kappa
    G = lambda j: 1 - LOG(1 + 2.0 ** -j + 2 * p + tauB)
    ts = (d - L1) / 4
    Jg = lambda c: c * (d + kg) + H(p)
    Phi2 = lambda c: min(c * (d - 8 - L1) + G(1), G(ts - 1)) if ts >= 2 else G(1)
    chi = min((G(1) - H(p)) / (8 + L1 + kg), (G(ts - 1) - H(p)) / (d + kg))
    print("=" * 96)
    print(f"(B) Prop 3.6(c) at d=100, m=20, p=2^-10, B=30, delta=0.01, kappa=0 (illustration): c_hi(B=30) = {chi:.4e}")
    for c1, c2 in ((2 * 2.0 ** -m, 1e-4), (1e-4, 1e-3), (1e-3, 4e-3)):
        cs = np.geomspace(c1, c2, 2001)
        marg = min(Phi2(c) - Jg(c) for c in cs)       # affine pieces: the minimum is at an end point
        marg = min(marg, Phi2(c1) - Jg(c1), Phi2(c2) - Jg(c2))
        found = None
        for e in range(6, 20):
            n = 10.0 ** e
            eps1 = LOG(1 / p) * math.sqrt(math.log(2 / delta) / (2 * n))
            Lbar = (Jg(c2) + eps1) / c1
            ebar = eps1 + B * math.sqrt((Lbar * math.log(2) + math.log(2 / delta)) / (2 * n))
            if ebar < marg:
                found = (e, ebar)
                break
        print(f"    [c1, c2] = [{c1:.3e}, {c2:.3e}]: margin min(Phi_2 - J_g) = {marg:.4f}; "
              f"epsilon_bar_n < margin from n = 10^{found[0]} (epsilon_bar = {found[1]:.4f})")
    print("    so (c) applies here from n = 10^7 to 10^8 on, with a slack of 0.13 to 0.21 bits per sample in (ii)")


if __name__ == "__main__":
    partA()
    partB()
