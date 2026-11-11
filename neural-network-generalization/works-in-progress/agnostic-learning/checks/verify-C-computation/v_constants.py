"""Independent recomputation of the explicit constants of C.md (computation referee).

Written from the formulas in C.md (C.3.1)-(C.3.3), (C.4.2), Theorem C.5(d); not copied from C_scripts.
 1. A_L table and Corollary C.2.1 sample sizes quoted in C.8 item 6.
 2. eps_n(d) of (C.4.2) as DEFINED (factor (2 n^a)^gamma) versus the C.8 tabulation (factor ceil(n^a)^gamma).
 3. The polynomial majorant (C.3.3): log(1/(c h_rho)) <= Lambda_L, random parameters.
 4. Monotonicity of A_L in m, B (and in rho) used in Corollary C.2.2.
 5. Lemma C.3.1 "in particular": RHS of (C.3.1) <= (A_L - 1)/sigma^2 whenever sigma^2 <= 1/N; and P0(tbar) <= tbar^(L-2) P0(1).
 6. Corollary C.2.2: explicit K1, K2, K from the proof chain, and the empirical sup of eps_n / [d^2 n^((4+g)a) log(dn)/(eta n)].
 7. Separate exponents (a, b, beta): exponent 2a+2b+gamma*beta-1 by log-log regression of the bound.
 8. Theorem C.5(d) thresholds and their ratio versus 64 A_L / m_nu.
"""
import numpy as np
rng = np.random.default_rng(11)
LOG = np.log

def consts(d, m, B, rho, L, m_nu=1.0, M_nu=1.0, tbar=1.0):
    c_nu = 3.0 / 8.0 * min(1.0, np.sqrt(m_nu))
    b0 = 2.0 * np.sqrt((2.0 / m_nu) * (2 * LOG(9.0) + LOG(4.0 * L)))
    A0 = 2.0 + 3.0 * m * B + tbar * b0
    P0 = 1.0 + 2.0 * m * B * (d + L + 1) * A0 ** (L - 2)
    h = rho / (2.0 * P0)
    Estar = d * (d + 1) * B ** 2 + 2.0 * (L - 1) * m ** 2 * B ** 2
    return dict(c=c_nu, b0=b0, A0=A0, P0=P0, h=h, Estar=Estar)

def A_L(d, m, B, rho, L, m_nu=1.0, M_nu=1.0):
    k = consts(d, m, B, rho, L, m_nu, M_nu)
    return 1.0 + M_nu / 2.0 * k['Estar'] + (d + 2 + (L - 2) * m) * LOG(1.0 / (k['c'] * k['h'])) + LOG(2.0)

def Lambda_L(d, m, B, rho, L, m_nu=1.0):
    b0 = 2.0 * np.sqrt((2.0 / m_nu) * (2 * LOG(9.0) + LOG(4.0 * L)))
    return LOG(1 / rho) + (L - 1) * LOG(m * B) + LOG(d + L + 1) + (L - 2) * LOG(5 + b0) + LOG(16 / min(1.0, np.sqrt(m_nu)))

print("1. A_L and Corollary C.2.1 sample size (Gaussian, eta=1/8, gamma=1, N=m, eps=0.1, rho=eps/8):")
quoted = {(10, 1, 2, 2): (346, 5.5e4), (10, 10, 2, 3): (1387, 2.2e6), (100, 10, 2, 3): (2.3e4, 3.7e7), (10, 100, 2, 3): (8.3e4, 1.3e9)}
for (d, m, B, L), (Aq, nq) in quoted.items():
    A = A_L(d, m, B, 0.1 / 8, L)
    n = 2 * A * m / (0.125 * 0.1) - 1
    print(f"   (d,m,B,L)=({d},{m},{B},{L}): A_L={A:10.1f} (quoted {Aq})   n >= {n:.3e} (quoted {nq:.1e})")
print(f"   b0(L=3, Gaussian) = {consts(1,1,1,1,3)['b0']:.4f} (quoted ~7.42)")

print("\n2. eps_n(d) of (C.4.2) (d=10, L=3, gamma=1, eta=1/8): as defined [(2n^a)^g]  vs  as tabulated in C.8 [ceil(n^a)^g]")
for a in [0.05, 0.1, 0.15, 0.19]:
    out = []
    for e in [6, 9, 12, 15, 18]:
        n = 10.0 ** e
        A = A_L(10, n ** a, n ** a, 1 / n, 3)
        defd = 4 / n + (2 * n ** a) * A / (0.125 * (n + 1))
        tab = 4 / n + np.ceil(n ** a) * A / (0.125 * (n + 1))
        out.append(f"1e{e}: {defd:.2e} / {tab:.2e} (x{defd/tab:.2f})")
    print(f"   a={a}: " + "  ".join(out))

print("\n3. Majorant (C.3.3): log(1/(c_nu h_rho)) <= Lambda_L over 200000 random parameter tuples")
worst = np.inf
for _ in range(200000):
    L = int(rng.integers(2, 12)); d = int(np.exp(rng.uniform(0, LOG(1e5)))); m = int(np.exp(rng.uniform(0, LOG(1e4))))
    B = np.exp(rng.uniform(0, LOG(1e4))); rho = np.exp(rng.uniform(LOG(1e-15), 0)); m_nu = np.exp(rng.uniform(LOG(1e-3), 0))
    k = consts(d, m, B, rho, L, m_nu)
    lhs = LOG(1 / (k['c'] * k['h'])); rhs = Lambda_L(d, m, B, rho, L, m_nu)
    worst = min(worst, rhs - lhs)
print(f"   min slack Lambda_L - log(1/(c h)) = {worst:.4f}  (must be >= 0)")
# extreme corner: m = B = 1, small d, L = 2, rho = 1
k = consts(1, 1, 1, 1.0, 2); print(f"   corner d=m=B=rho=1, L=2: lhs={LOG(1/(k['c']*k['h'])):.4f}  Lambda={Lambda_L(1,1,1,1.0,2):.4f}")

print("\n4. Monotonicity of A_L: nondecreasing in m, B; nonincreasing in rho (grid, L=2..6)")
bad = 0
for L in range(2, 7):
    for d in [1, 3, 30, 300]:
        ms = np.linspace(1, 50, 60); Bs = np.linspace(1, 50, 60); rhos = np.logspace(-12, 0, 60)
        bad += np.sum(np.diff([A_L(d, m, 3.0, 0.1, L) for m in ms]) < 0)
        bad += np.sum(np.diff([A_L(d, 3.0, B, 0.1, L) for B in Bs]) < 0)
        bad += np.sum(np.diff([A_L(d, 3.0, 3.0, r, L) for r in rhos]) > 0)
print(f"   monotonicity violations: {bad}")

print("\n5. Lemma C.3.1: RHS(C.3.1) <= (A_L-1)/sigma^2 when sigma^2 <= 1/N; P0(tbar) <= tbar^(L-2) P0(1)")
viol1 = viol2 = 0
for _ in range(100000):
    L = int(rng.integers(2, 9)); d = int(rng.integers(1, 200)); m = int(rng.integers(1, 60)); B = rng.uniform(1, 20)
    N = int(rng.integers(m, 5000)); rho = np.exp(rng.uniform(LOG(1e-9), 0)); m_nu = rng.uniform(0.05, 1); M_nu = rng.uniform(1, 5)
    sig2 = np.exp(rng.uniform(LOG(1e-6), LOG(1.0 / N)))
    k = consts(d, m, B, rho, L, m_nu, M_nu)
    rhs = M_nu * k['Estar'] / (2 * sig2) + N * (d + 2 + (L - 2) * m) * LOG(1 / (k['c'] * k['h'])) + LOG(2)
    if rhs > (A_L(d, m, B, rho, L, m_nu, M_nu) - 1) / sig2 * (1 + 1e-12): viol1 += 1
    tb = np.exp(rng.uniform(0, LOG(1e4)))
    if consts(d, m, B, rho, L, m_nu, M_nu, tbar=tb)['P0'] > tb ** (L - 2) * k['P0'] * (1 + 1e-12): viol2 += 1
print(f"   violations: (in particular) {viol1}, (P0 scaling) {viol2}")

print("\n6. Corollary C.2.2 constant K (eps_n <= K d^2 n^((4+g)a) log(dn)/(eta n)); explicit K from the proof chain vs empirical")
for L in [2, 3, 5]:
    for g in [1.0, 2.0]:
        b0 = consts(1, 1, 1, 1, L)['b0']
        C0 = (L - 2) * LOG(5 + b0) + LOG(16)
        K1 = (2 * L - 1) + (LOG(L + 2) + C0) / LOG(2)          # Lambda_L <= K1 log(dn), alpha <= 1
        K2 = (1 + LOG(2)) / LOG(2) + L / LOG(2) + (L + 1) * K1   # A_L <= K2 d^2 n^(4a) log(dn)   (M_nu = 1)
        K = 2 ** g * K2 + 1 / (2 * LOG(2))
        emp = 0.0; chk = True
        for d in [1, 2, 10, 100, 1000, 10000]:
            for e in np.linspace(LOG(2) / LOG(10), 30, 40):
                n = 10.0 ** e
                for a in [0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 1.0]:
                    for eta in [1 / 8, 1e-3]:
                        if n ** a > 1e40: continue
                        A = A_L(d, n ** a, n ** a, 1 / n, L)
                        eps = 4 / n + (2 * n ** a) ** g * A / (eta * (n + 1))
                        ref = d ** 2 * n ** ((4 + g) * a) * LOG(d * n) / (eta * n)
                        emp = max(emp, eps / ref); chk &= eps <= K * ref
        print(f"   L={L} gamma={g}: explicit K={K:8.1f}  empirical sup ratio={emp:7.2f}  bound holds on grid: {chk}")

print("\n7. Separate exponents: slope of log(bound) vs log n at fixed d (L=3, gamma=1)")
for (a, b, beta) in [(0.1, 0.1, 0.1), (0.05, 0.2, 0.1), (0.1, 0.0, 0.3), (0.2, 0.05, 0.25)]:
    ns = np.array([1e20, 1e30]); vals = []
    for n in ns:
        A = A_L(10, n ** a, n ** b, 1 / n, 3)
        vals.append((2 * n ** beta) * A / (0.125 * (n + 1)))
    slope = (LOG(vals[1]) - LOG(vals[0])) / (LOG(ns[1]) - LOG(ns[0]))
    print(f"   a={a} b={b} beta={beta}: fitted slope {slope:+.4f}  predicted 2a+2b+gamma*beta-1 = {2*a+2*b+beta-1:+.4f}")

print("\n8. Theorem C.5(d): thresholds for the constant target, L=2, Gaussian, eta=1/8")
for (d, n) in [(2, 1e4), (10, 1e6), (10, 1e8), (100, 1e10)]:
    A = A_L(d, 1, 2, 1 / 16, 2); k = 0.125 * n
    up = 0.125 * (n + 1) / (4 * A); low = 4 * (4 * k + np.sqrt(2 * k))
    print(f"   d={d} n={n:.0e}: A_L(d,1,2,1/16)={A:7.1f}  upper N^g <= {up:.3e}  lower N^g >= {low:.3e}  ratio={low/up:9.1f}  64 A_L={64*A:9.1f}")
