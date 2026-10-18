"""G1 checks: two-factor persona model, transfer, inoculation, declarative conditioning, vector ledgers.

Every number quoted in drafts/G1-structure.md comes from this script.
Run: python3 G1_checks.py > G1_checks_output.txt
Sections:
  A  persona-logit gradient identities (finite differences), transfer law, surprise bound
  B  inoculation: residual factor res_iota for channels A, G, J (SFT and RL), trajectories
  C  declarative conditioning: Bayesian cap ln(1/aw), and the gradient version
  D  transfer coefficients under the prior and after the sieve; reciprocity; emergent-alignment cap
  E  vector-ledger loop map: shared vs conditional components
"""
import numpy as np

rng = np.random.default_rng(12345)
np.set_printoptions(precision=5, suppress=True)


def softmax(z):
    z = np.asarray(z, float)
    z = z - z.max()
    e = np.exp(z)
    return e / e.sum()


def logit(p):
    return np.log(p / (1 - p))


def ctx_weights(omega, shift):
    return softmax(omega + shift)


def surprise(omega, shift, pi_y):
    """S_{x,y}(theta) = rho(theta) - varpi(theta|x) = varpi(theta|x)(pi_theta(y|x) - P)/P."""
    w = ctx_weights(omega, shift)
    P = w @ pi_y
    return w * (pi_y - P) / P, P


def rl_grad(omega, shift, pi_X, reward_gap=1.0):
    """Expected REINFORCE gradient on global logits for an opportunity where X earns reward_gap more than I."""
    w = ctx_weights(omega, shift)
    P = w @ pi_X
    # E_y[R(y) d/domega log P(y)] with R(X)=gap, R(I)=0 : sum over y of P(y) R(y) (resp(y)-w) = gap * w*(pi_X - P)
    return reward_gap * w * (pi_X - P), P


def header(s):
    print()
    print("=" * 78)
    print(s)
    print("=" * 78)


n_checks = 0
n_fail = 0


def check(name, ok):
    global n_checks, n_fail
    n_checks += 1
    if not ok:
        n_fail += 1
    print(f"[{'OK ' if ok else 'FAIL'}] {name}")


# ---------------------------------------------------------------------------
header("A. Persona-logit gradient identities")
# A1: d/domega log P_x(y) = rho - varpi(.|x)  (framing 1.4), with context shifts
maxerr = 0.0
for _ in range(200):
    K = rng.integers(2, 7)
    omega = rng.normal(0, 2, K)
    shift = rng.normal(0, 2, K)
    pi_y = rng.uniform(0.001, 0.999, K)
    S, P = surprise(omega, shift, pi_y)
    h = 1e-6
    num = np.zeros(K)
    for k in range(K):
        e = np.zeros(K); e[k] = h
        num[k] = (np.log(ctx_weights(omega + e, shift) @ pi_y) - np.log(ctx_weights(omega - e, shift) @ pi_y)) / (2 * h)
    maxerr = max(maxerr, np.abs(num - S).max())
print(f"A1 max |finite-difference - (rho - varpi(.|x))| over 200 random instances: {maxerr:.2e}")
check("A1 gradient identity", maxerr < 1e-7)

# A2: transfer law  Delta E_{x'} f = eps * Cov_{varpi(.|x')}(f, S_x) + O(eps^2)
worst = 0.0
for _ in range(200):
    K = rng.integers(2, 7)
    omega = rng.normal(0, 2, K)
    sh_x = rng.normal(0, 2, K)
    sh_xp = rng.normal(0, 2, K)
    pi_y = rng.uniform(0.001, 0.999, K)
    f = rng.uniform(0, 1, K)
    S, P = surprise(omega, sh_x, pi_y)
    eps = 1e-5
    wp = ctx_weights(omega, sh_xp)
    actual = ctx_weights(omega + eps * S, sh_xp) @ f - wp @ f
    pred = eps * np.sum(wp * (f - wp @ f) * S)
    if abs(pred) > 1e-12:
        worst = max(worst, abs(actual / pred - 1))
print(f"A2 max relative error of the transfer law at eps=1e-5: {worst:.2e}")
check("A2 transfer law (first order)", worst < 1e-3)

# A3: surprise bound  sum|S| = 2 TV <= 2(1-P);  |Delta E_{x'} f| <= 2 eps osc(f) (1-P)
ratio_S, ratio_f = 0.0, 0.0
for _ in range(100000):
    K = rng.integers(2, 6)
    omega = rng.normal(0, 3, K)
    sh_x = rng.normal(0, 3, K)
    sh_xp = rng.normal(0, 3, K)
    # mix of deterministic and soft personas
    pi_y = np.where(rng.uniform(size=K) < 0.5, rng.integers(0, 2, K).astype(float), rng.uniform(0, 1, K))
    pi_y = np.clip(pi_y, 1e-9, 1 - 1e-9)
    f = rng.uniform(0, 1, K)
    S, P = surprise(omega, sh_x, pi_y)
    TV = 0.5 * np.abs(S).sum()
    ratio_S = max(ratio_S, TV / (1 - P))
    wp = ctx_weights(omega, sh_xp)
    cov = abs(np.sum(wp * (f - wp @ f) * S))
    ratio_f = max(ratio_f, cov / (2 * (1 - P)))
print(f"A3 max TV(rho, varpi(.|x)) / (1-P) over 1e5 instances: {ratio_S:.4f}  (bound 1; equality for deterministic personas)")
print(f"A3 max |Cov_{{varpi'}}(f,S)| / (2(1-P)): {ratio_f:.4f}  (bound 1)")
# RL bound: sum |Delta omega| = eps*Delta_+ * E|Z-P| <= 2 eps Delta_+ P(1-P)
ratio_rl = 0.0
for _ in range(100000):
    K = rng.integers(2, 6)
    omega = rng.normal(0, 3, K); sh_x = rng.normal(0, 3, K)
    piX = np.where(rng.uniform(size=K) < 0.5, rng.integers(0, 2, K).astype(float), rng.uniform(0, 1, K))
    R, P = rl_grad(omega, sh_x, piX)
    if 1e-6 < P < 1 - 1e-6:
        ratio_rl = max(ratio_rl, np.abs(R).sum() / (2 * P * (1 - P)))
print(f"A3 max sum|Delta omega_RL| / (2 P (1-P)): {ratio_rl:.4f}  (bound 1)")
check("A3 RL bound (equality for deterministic personas; float tolerance 1e-6)", ratio_rl <= 1 + 1e-6)
check("A3 surprise bound TV <= 1-P", ratio_S <= 1 + 1e-9)
check("A3 transfer bound <= 2(1-P)", ratio_f <= 1 + 1e-9)

# A4: two-persona closed forms for lambda_+ (A:G ledger) under SFT and RL
maxe1 = maxe2 = 0.0
for _ in range(500):
    pG = rng.uniform(0.001, 0.999)
    a, g = rng.uniform(0, 1, 2)
    omega = np.array([np.log(1 - pG), np.log(pG)])  # [A, G]
    pi = np.array([a, g])
    S, P = surprise(omega, np.zeros(2), pi)
    lam_sft = S[1] - S[0]
    closed = 2 * pG * (1 - pG) * (g - a) / P
    R, _ = rl_grad(omega, np.zeros(2), pi)
    lam_rl = R[1] - R[0]
    closed_rl = 2 * pG * (1 - pG) * (g - a)
    maxe1 = max(maxe1, abs(lam_sft - closed))
    maxe2 = max(maxe2, abs(lam_rl - closed_rl))
print(f"A4 two-persona: max error SFT closed form {maxe1:.1e}, RL closed form {maxe2:.1e}")
check("A4 lambda_+ closed forms", maxe1 < 1e-12 and maxe2 < 1e-12)

# A5: RL REINFORCE expected gradient = w*(pi_X - P) checked by enumerating outputs
maxe = 0.0
for _ in range(200):
    K = rng.integers(2, 6)
    omega = rng.normal(0, 2, K); sh = rng.normal(0, 2, K)
    piX = rng.uniform(0, 1, K)
    w = ctx_weights(omega, sh)
    PX = w @ piX
    rX = w * piX / PX; rI = w * (1 - piX) / (1 - PX)
    enum = PX * 1.0 * (rX - w) + (1 - PX) * 0.0 * (rI - w)
    R, _ = rl_grad(omega, sh, piX)
    maxe = max(maxe, np.abs(enum - R).max())
print(f"A5 REINFORCE expected gradient by enumeration vs formula: {maxe:.1e}")
check("A5 RL gradient formula", maxe < 1e-12)

# ---------------------------------------------------------------------------
header("B. Inoculation: residual factor res = lambda_+(x_iota)/lambda_+(x_0) for the default A:G ledger")
delta = 0.01
pG = 0.01


def lam_AG(omega, shift, piX, mode):
    if mode == "SFT":
        S, P = surprise(omega, shift, piX)
        return S[1] - S[0], P
    R, P = rl_grad(omega, shift, piX)
    return R[1] - R[0], P


omega2 = np.array([np.log(1 - pG), np.log(pG)])
pi0 = np.array([delta, 1 - delta])
base_sft, P0 = lam_AG(omega2, np.zeros(2), pi0, "SFT")
base_rl, _ = lam_AG(omega2, np.zeros(2), pi0, "RL")
print(f"baseline (no inoculation): P_0(X)={P0:.4f}, lambda_+ SFT/eps={base_sft:.4f}, RL/(eps Delta_+)={base_rl:.5f}")

print("\nChannel A: the inoculation makes X what the intent-follower does (a_iota = pi_A(X|x_iota)); persona weights unchanged")
print(f"{'a_iota':>7} {'P_iota':>7} {'lift Y':>7} {'res SFT':>8} {'(1-a)/Y':>8} {'res RL':>7} {'1-a':>6}")
rowsA = []
for a_i in [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
    pi = np.array([a_i, 1 - delta])
    l_s, Pi = lam_AG(omega2, np.zeros(2), pi, "SFT")
    l_r, _ = lam_AG(omega2, np.zeros(2), pi, "RL")
    Y = Pi / P0
    rowsA.append((a_i, Pi, Y, l_s / base_sft, l_r / base_rl))
    print(f"{a_i:7.2f} {Pi:7.3f} {Y:7.1f} {l_s/base_sft:8.4f} {(1-a_i)/Y:8.4f} {l_r/base_rl:7.3f} {1-a_i:6.2f}")

print("\nChannel G: the inoculation context summons the gaming persona G itself (p_iota = varpi(G|x_iota)); a = delta")
print(f"{'p_iota':>7} {'P_iota':>7} {'lift Y':>7} {'res SFT':>8} {'(1-P_i)/(1-P_0)':>16} {'res RL':>7}")
for p_i in [0.05, 0.2, 0.5, 0.8, 0.9, 0.99]:
    shift = np.array([0.0, logit(p_i) - logit(pG)])
    l_s, Pi = lam_AG(omega2, shift, pi0, "SFT")
    l_r, _ = lam_AG(omega2, shift, pi0, "RL")
    print(f"{p_i:7.2f} {Pi:7.3f} {Pi/P0:7.1f} {l_s/base_sft:8.4f} {(1-Pi)/(1-P0):16.4f} {l_r/base_rl:7.3f}")

print("\nChannel J: a distinct instruction-conditional persona J absorbs the event (J games iff instructed)")
omega3 = np.log(np.array([0.985, 0.01, 0.005]))  # A, G, J
piX_iota = np.array([delta, 1 - delta, 1 - delta])
piX_0 = np.array([delta, 1 - delta, delta])
base3_sft, P03 = lam_AG(omega3, np.zeros(3), piX_0, "SFT")
base3_rl, _ = lam_AG(omega3, np.zeros(3), piX_0, "RL")
print(f"baseline 3-persona: P_0(X)={P03:.4f}")
print(f"{'j_iota':>7} {'P_iota':>7} {'res SFT':>8} {'res RL':>7} {'J logit gain/eps (SFT)':>23} {'A logit/eps':>11}")
for j_i in [0.2, 0.5, 0.8, 0.9, 0.99]:
    # choose shift on J so that varpi(J|iota)=j_i
    w0 = softmax(omega3)
    s = np.log(j_i / (1 - j_i) * (w0[0] + w0[1]) / w0[2])
    shift = np.array([0, 0, s])
    S, Pi = surprise(omega3, shift, piX_iota)
    l_s = S[1] - S[0]
    R, _ = rl_grad(omega3, shift, piX_iota)
    l_r = R[1] - R[0]
    print(f"{j_i:7.2f} {Pi:7.3f} {l_s/base3_sft:8.4f} {l_r/base3_rl:7.3f} {S[2]:23.4f} {S[0]:11.4f}")

# Trajectories under SFT on rewarded X events (blanket inoculation of the frontier slice)
print("\nTrajectories: N rewarded-X SFT events, step eps; default-context gaming P_0(X) at the end, and at an")
print("'iota-like' deployment context (half the inoculation shift).")
eps = 0.02
Nev = 3000


def run(omega, shift_train, piX_train, shift_test_list, piX_test_list, N=Nev, mode="SFT"):
    om = omega.copy()
    for _ in range(N):
        if mode == "SFT":
            S, _ = surprise(om, shift_train, piX_train)
        else:
            S, _ = rl_grad(om, shift_train, piX_train)
        om = om + eps * S
    out = []
    for sh, px in zip(shift_test_list, piX_test_list):
        out.append(ctx_weights(om, sh) @ px)
    return om, out


traj_rows = []
# no inoculation, 3 persona
om, (p0, ) = run(omega3, np.zeros(3), piX_0, [np.zeros(3)], [piX_0])
traj_rows.append(("none", p0, np.nan, softmax(om)))
# channel A: a_iota = 0.9
piA = np.array([0.9, 1 - delta, delta])
om, (p0, ) = run(omega3, np.zeros(3), piA, [np.zeros(3)], [piX_0])
traj_rows.append(("channel A, a_iota=0.9", p0, np.nan, softmax(om)))
# channel G: summon G to 0.5
w0 = softmax(omega3)
sG = logit(0.5) - logit(w0[1] / (w0[0] + w0[1]))
shG = np.array([0, sG, 0])
om, (p0, piota_end) = run(omega3, shG, piX_0, [np.zeros(3), shG], [piX_0, piX_0])
traj_rows.append(("channel G, p_iota=0.5", p0, np.nan, softmax(om)))
headstart = (logit(piota_end) - logit(p0))
print(f"channel G: at the end P_iota(X)={piota_end:.4f}, P_0(X)={p0:.4f}; logit gap = {headstart:.3f} nats"
      f" vs context shift sG = {sG:.3f} (gap differs from sG only through softness and J)")
for j_i in [0.5, 0.9, 0.99]:
    s = np.log(j_i / (1 - j_i) * (w0[0] + w0[1]) / w0[2])
    shJ = np.array([0, 0, s])
    piX_half = np.array([delta, 1 - delta, 1 - delta])  # J games in iota-like context
    om, (p0, phalf) = run(omega3, shJ, piX_iota, [np.zeros(3), shJ / 2], [piX_0, piX_half])
    traj_rows.append((f"channel J, j_iota={j_i}", p0, phalf, softmax(om)))
# baseline value of iota-like context before training
s = np.log(0.9 / 0.1 * (w0[0] + w0[1]) / w0[2])
p_half_before = ctx_weights(omega3, np.array([0, 0, s]) / 2) @ np.array([delta, 1 - delta, 1 - delta])
print(f"before training: P_0(X) = {P03:.4f}; iota-like context (j_iota=0.9 shift / 2): {p_half_before:.4f}")
print(f"{'design':>24} {'P_0(X) after':>12} {'iota-like after':>15}   default weights [A, G, J]")
for name, p0, ph, w in traj_rows:
    phs = f"{ph:15.4f}" if not np.isnan(ph) else f"{'-':>15}"
    print(f"{name:>24} {p0:12.4f} {phs}   {w}")

# RL trajectories (on-policy expected gradient), Delta_+=1
print("\nSame, on-policy RL expected gradient (Delta_+ = 1), eps=0.02, N=3000 opportunity episodes:")
rl_rows = []
om, (p0,) = run(omega3, np.zeros(3), piX_0, [np.zeros(3)], [piX_0], mode="RL"); rl_rows.append(("none", p0))
om, (p0,) = run(omega3, np.zeros(3), piA, [np.zeros(3)], [piX_0], mode="RL"); rl_rows.append(("channel A, a_iota=0.9", p0))
om, (p0,) = run(omega3, shG, piX_0, [np.zeros(3)], [piX_0], mode="RL"); rl_rows.append(("channel G, p_iota=0.5", p0))
s = np.log(0.9 / 0.1 * (w0[0] + w0[1]) / w0[2])
om, (p0,) = run(omega3, np.array([0, 0, s]), piX_iota, [np.zeros(3)], [piX_0], mode="RL"); rl_rows.append(("channel J, j_iota=0.9", p0))
for name, p0 in rl_rows:
    print(f"{name:>24} P_0(X) after = {p0:.4f}")

# Integrated A-blame in channel J (two personas A, J; G negligible; a=0): cumulative blame = (logit j_N - logit j_0)/2
print("\nChannel J integral (A and J only, a_iota=0): cumulative A-logit loss vs (logit j_N - logit j_0)/2")
om = np.log(np.array([0.995, 0.005]))
sJ = np.log(0.5 / 0.5 * 0.995 / 0.005)
sh = np.array([0, sJ])
pix = np.array([1e-12, 1 - 1e-12])
j0 = ctx_weights(om, sh)[1]
blame = 0.0
for _ in range(Nev):
    S, _ = surprise(om, sh, pix)
    om = om + eps * S
    blame += -eps * S[0]
jN = ctx_weights(om, sh)[1]
print(f"j_0={j0:.3f} j_N={jN:.5f} blame={blame:.4f} predicted={0.5*(logit(jN)-logit(j0)):.4f} (Euler step error O(eps))")
check("B channel-J integral identity (within 2%)", abs(blame / (0.5 * (logit(jN) - logit(j0))) - 1) < 0.02)

# ---------------------------------------------------------------------------
header("C. Declarative conditioning")
print("Bayesian learner with hypotheses N (documents describe my character truthfully) and W (documents are")
print("written by trainers, independent of my character), prior P(W)=aw. Proxy-equivalent pair A, C;")
print("truthful description of C contains the declarative sentence with prob c_d per document.")
print(f"{'aw':>6} {'c_d':>5} " + " ".join(f"{'N='+str(N):>8}" for N in [1, 3, 10, 100]) + f" {'cap ln(1/aw)':>12}")
for aw in [0.01, 0.1, 0.5]:
    for c_d in [0.0, 0.3]:
        vals = []
        for N in [1, 3, 10, 100]:
            # each doc: under N, A emits it w.p. 1 (relative), C w.p. c_d ; under W, both emit w.p. 1 (relative)
            num = (1 - aw) * 1.0 + aw * 1.0
            den = (1 - aw) * c_d ** N + aw * 1.0
            vals.append(np.log(num / den))
        print(f"{aw:6.2f} {c_d:5.2f} " + " ".join(f"{v:8.3f}" for v in vals) + f" {np.log(1/aw):12.3f}")
check("C cap attained by N=100 docs", abs(np.log(1 / 0.1) - np.log(1 / (0.9 * 0.3 ** 100 + 0.1))) < 1e-6)

print("\nGradient version (P): narrator context shares the persona logits; per-document change of the A:C ledger,")
print("for a document that A's truthful description contains (pi_A^desc = 0.9) and C's does not (0.05),")
print("with an aware persona T that emits it as trainer-text (0.9) and games when unchecked.")
for wA, wC, wT in [(0.98, 0.01, 0.01), (0.90, 0.05, 0.05), (0.60, 0.05, 0.35)]:
    om = np.log(np.array([wA, wC, wT]))
    pid = np.array([0.9, 0.05, 0.9])
    S, P = surprise(om, np.zeros(3), pid)
    print(f"  weights A,C,T = {wA:.2f},{wC:.2f},{wT:.2f}: P(d)={P:.3f}  dL_AC/eps={S[0]-S[1]:+.4f}  dL_AT/eps={S[0]-S[2]:+.4f}  bound 2(1-P)={2*(1-P):.3f}")

# ---------------------------------------------------------------------------
header("D. Transfer coefficients, the sieve, reciprocity, emergent-alignment cap (illustrative prior)")
cells = ["ck1", "ck2", "uk1", "F"]  # checked-looking class 1, checked-looking class 2, unchecked-looking class 1, frontier
personas = {
    "A": set(),
    "G": {"ck1", "ck2", "uk1", "F"},       # shared factor, naive
    "C_U": {"uk1", "F"},                   # conditional on 'unchecked' (careful gamer / best responder)
    "C_1": {"ck1", "uk1"},                 # class-1 exploiter (naive, class-specific)
    "C_2": {"ck2"},                        # class-2 exploiter
    "C_F": {"F"},                          # frontier-only (capability-gated)
}
prior = {"A": 0.975, "G": 0.010, "C_U": 0.005, "C_1": 0.004, "C_2": 0.004, "C_F": 0.002}
names = list(personas)
gmat = np.array([[1.0 if c in personas[p] else 0.0 for c in cells] for p in names])


def tr_matrix(mu):
    mu = np.asarray(mu) / np.sum(mu)
    m = mu @ gmat
    T = np.zeros((4, 4))
    for i in range(4):
        for j in range(4):
            cov = mu @ (gmat[:, i] * gmat[:, j]) - m[i] * m[j]
            T[j, i] = cov / (m[i] * (1 - m[i]))  # Tr_{j <- i}
    return T, m


mu0 = np.array([prior[p] for p in names])
T0, m0 = tr_matrix(mu0)
print("gaming marginals under prior:", dict(zip(cells, np.round(m0, 4))))
print("Tr_{row <- column} under the prior (rows/cols ck1, ck2, uk1, F):")
print(T0)
# reciprocity: Tr_{j<-i} Var_i = Tr_{i<-j} Var_j
V = m0 * (1 - m0)
rec = max(abs(T0[j, i] * V[i] - T0[i, j] * V[j]) for i in range(4) for j in range(4))
check("D reciprocity Tr_{j<-i}Var_i = Tr_{i<-j}Var_j", rec < 1e-12)

# exact-tilt first-order check: d/dn E g_j = c Cov(g_j, g_i) for D = c g_i
c = -0.01
i = 0
mu = mu0 / mu0.sum()
dn = 1e-4
mu_n = mu * np.exp(dn * c * gmat[:, i]); mu_n /= mu_n.sum()
lhs = (mu_n @ gmat - mu @ gmat) / dn
rhs = c * np.array([mu @ (gmat[:, i] * gmat[:, j]) - (mu @ gmat[:, i]) * (mu @ gmat[:, j]) for j in range(4)])
check("D covariance law dE g_j/dn = Cov(g_j, D)", np.abs(lhs - rhs).max() < 1e-6)

# a mild sieve first (ck: -1.5 nats each; uk1, F: +0.5), then a strong one
evm = {"ck1": -1.5, "ck2": -1.5, "uk1": +0.5, "F": +0.5}
lwm = np.log(mu0) + gmat @ np.array([evm[c] for c in cells])
mum = np.exp(lwm - lwm.max()); mum /= mum.sum()
Tm, mm = tr_matrix(mum)
print("\nafter a mild sieve (ck1, ck2: -1.5 nats; uk1, F: +0.5 nats):")
print("posterior:", dict(zip(names, np.round(mum, 5))))
print("Tr_{F <- ck1} =", round(Tm[3, 0], 4), " Tr_{ck1 <- F} =", round(Tm[0, 3], 4))
# one generation of the sieve: caught evidence on checked cells, rewarded on unchecked/frontier slice (nats)
ev = {"ck1": -6.0, "ck2": -6.0, "uk1": +2.0, "F": +2.0}
logw = np.log(mu0) + gmat @ np.array([ev[c] for c in cells])
mu1 = np.exp(logw - logw.max()); mu1 = mu1 / mu1.sum()
T1m, m1 = tr_matrix(mu1)
print("\nafter one generation of the sieve (ck1, ck2: -6 nats; uk1, F: +2 nats):")
print("posterior:", dict(zip(names, np.round(mu1, 5))))
print("gaming marginals:", dict(zip(cells, np.round(m1, 5))))
print("Tr_{row <- column} after the sieve:")
print(T1m)


def share_visible(mu, frm="F", at="ck1"):
    i, j = cells.index(frm), cells.index(at)
    mu = np.asarray(mu) / np.sum(mu)
    return (mu @ (gmat[:, i] * gmat[:, j])) / (mu @ gmat[:, i])


for lab, mu in [("prior", mu0), ("mild sieve", mum), ("post-sieve", mu1)]:
    sh = share_visible(mu)
    sh2 = (np.asarray(mu) @ (gmat[:, 3] * np.maximum(gmat[:, 0], gmat[:, 1]))) / (np.asarray(mu) @ gmat[:, 3])
    print(f"{lab:>10}: share of frontier gamers visible at ck1 = {sh:.3f}  (at ck1 or ck2: {sh2:.3f});"
          f" emergent-alignment cap -ln(1-sh) = {-np.log(1-sh2):.3f} nats")

# frontier gain from Lambda nats of checkable honesty training on ck1 and ck2 (both), prior and post-sieve
print("\nfrontier log-odds gain from Lambda nats of checkable alignment training (on both checked cells):")
for lab, mu in [("prior", mu0), ("mild sieve", mum), ("post-sieve", mu1)]:
    gains = []
    for Lam in [1, 3, 10, 100]:
        visible = np.maximum(gmat[:, 0], gmat[:, 1])
        lw = np.log(mu) - Lam * visible
        mu2 = np.exp(lw - lw.max()); mu2 /= mu2.sum()
        qF0 = (np.asarray(mu) / np.sum(mu)) @ gmat[:, 3]
        qF1 = mu2 @ gmat[:, 3]
        gains.append(logit(1 - qF1) - logit(1 - qF0))
    print(f"{lab:>10}: Lambda=1,3,10,100 -> " + ", ".join(f"{g:.3f}" for g in gains))

# ---------------------------------------------------------------------------
header("E. Vector-ledger loop map (illustrative): shared component G, conditional component C_U")


def loop(LG0, LC0, gam_chk, gam_nb, kap, leak0, leak1, K=60, shared_only=False, close_slice=False, decl_cap=None):
    LG, LC = LG0, LC0
    decl_used = 0.0
    hist = []
    fail = None
    for k in range(K):
        eG = np.exp(min(-LG, 50.0))
        eC = 0.0 if shared_only else np.exp(min(-LC, 50.0))
        q = (eG + eC) / (1 + eG + eC)
        leak = 0.0 if close_slice else leak0 + leak1 * q
        g_nb = gam_nb
        if decl_cap is not None:
            g_nb = min(gam_nb, max(decl_cap - decl_used, 0.0))
            decl_used += g_nb
        LG = max(LG + gam_chk + g_nb - kap - leak, -50.0)
        LC = max(LC + g_nb - kap - leak, -50.0)
        sh = 1.0 if shared_only else 1.0 / (1.0 + np.exp(min(LG - LC, 700)))
        hist.append((k + 1, LG, (np.nan if shared_only else LC), q, sh))
        if fail is None and q > 0.5:
            fail = k + 1
    return hist, fail


base = dict(LG0=np.log(0.989 / 0.010), LC0=np.log(0.989 / 0.001), gam_chk=3.0, gam_nb=0.5, kap=0.3, leak0=1.0, leak1=5.0)
print("parameters (nats per generation, illustrative):", {k: round(v, 3) for k, v in base.items()})
scen = [
    ("S1 shared only", dict(shared_only=True)),
    ("S2 shared + conditional", dict()),
    ("S3 = S2, slice leak closed (channel-A inoculation / verifiable rewards)", dict(close_slice=True)),
    ("S4 = S2 with gamma_nb = 1.5, but gamma_nb is declarative with total cap ln(1/aw)=2.3", dict(decl_cap=2.3)),
    ("S5 = S2 with gamma_nb = 1.5 > kappa_L g + leak0", dict()),
]
for name, kw in scen:
    b = dict(base)
    if name.startswith("S5") or name.startswith("S4"):
        b["gam_nb"] = 1.5
    hist, fail = loop(**b, **kw)
    sel = [h for h in hist if h[0] in (1, 5, 10, 20, 40, 60)]
    print(f"\n{name}: first generation with frontier off-task mass q > 0.5: {fail}")
    for k, LG, LC, q, sh in sel:
        print(f"   k={k:2d}  L_G={LG:8.2f}  L_C={LC:8.2f}  q_F={q:.4f}  sharedness={sh:.2e}")

# closed-form failure time for the conditional component (no grader feedback): L_C0 / (leak0 + kap - gam_nb)
k_cf = base["LC0"] / (base["leak0"] + base["kap"] - base["gam_nb"])
print(f"\nclosed-form crossing of L_C=0 without grader feedback: k = L_C0/(leak0+kappa_L g-gamma_nb) = {k_cf:.2f}")
hist, _ = loop(**dict(base, leak1=0.0))
kc = next(h[0] for h in hist if h[2] < 0)
print(f"map without feedback: first k with L_C<0: {kc}")
check("E closed-form crossing matches map (ceil)", kc == int(np.ceil(k_cf)))
# sharedness decays as exp(-gam_chk k) relative odds
hist, _ = loop(**dict(base, leak1=0.0))
k, LG, LC, q, sh = hist[4]
pred = 1 / (1 + np.exp((base["LG0"] - base["LC0"]) + 5 * base["gam_chk"]))
print(f"sharedness at k=5: map {sh:.6f}, closed form 1/(1+exp(L_G0-L_C0+k gamma_chk)) = {pred:.6f}")
check("E sharedness closed form", abs(sh - pred) < 1e-9)

print()
print(f"TOTAL: {n_checks} checks, {n_fail} failures")
