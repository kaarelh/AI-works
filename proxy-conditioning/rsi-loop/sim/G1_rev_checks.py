"""G1 revision checks: numbers introduced or corrected in the revised drafts/G1-structure.md.

Run: python3 G1_rev_checks.py > G1_rev_checks_output.txt
Sections (cited in the draft as "check V1" ... "check V9"):
  V1  (P): spillover fraction sp of checkable repair onto a proxy-equivalent minority type (closed form vs runs)
  V2  (P): transfer coefficient formula with product weights; reciprocity normaliser; check-D prior
  V3  sharp behaviour bound zeta(1-P)/2 (SFT) and zeta Delta P(1-P)/2 (RL); ledger bound 2 zeta (1-P)
  V4  zero expected gradient of SFT on the model's own samples
  V5  channel G_iota: A's default-logit loss, closed form u + e^u = 2 zeta N + 1 (SFT), RL analogue
  V6  quenched reading: inoculation through iota-conditional types (Bayes over fixed types)
  V7  channel A, RL residual: exact (1-delta-a)/(1-2delta)
  V8  three personas: sign of the ledger change (general formula)
  V9  loop map: q evaluated after each update, T1.10i's (1-q) factor, spillover fraction sp, scenarios
  V10 strong-sieve sharedness (exact value)
"""
import numpy as np

rng = np.random.default_rng(2026)
np.set_printoptions(precision=5, suppress=True)
n_checks = 0
n_fail = 0


def check(name, ok):
    global n_checks, n_fail
    n_checks += 1
    n_fail += (not ok)
    print(f"[{'OK ' if ok else 'FAIL'}] {name}")


def hdr(s):
    print("\n" + "=" * 78 + "\n" + s + "\n" + "=" * 78)


def softmax(z):
    z = np.asarray(z, float); z = z - z.max(); e = np.exp(z); return e / e.sum()


def logit(p):
    return np.log(p / (1 - p))


def sft_S(om, piy, shift=0.0):
    w = softmax(om + shift); P = w @ piy
    return w * (piy - P) / P, P


def rl_g(om, piX, gap=1.0, shift=0.0):
    w = softmax(om + shift); P = w @ piX
    return gap * w * (piX - P), P


zeta = 0.02  # step size

# ---------------------------------------------------------------------------
hdr("V1. (P): spillover fraction of checkable repair onto the conditional ledger (hard propensities)")
# personas A, G, G_U. Checked cell: A and G_U emit I, G emits X.
for wts in [(0.989, 0.010, 0.001), (0.90, 0.05, 0.05), (0.5, 0.25, 0.25), (0.6, 0.39, 0.01)]:
    w = np.array(wts); om = np.log(w)
    piI = np.array([1.0, 0.0, 1.0])
    S, P = sft_S(om, piI)
    dLG, dLC = S[0] - S[1], S[0] - S[2]
    cf = (w[0] - w[2]) / (1 + w[0] - w[1])
    g, _ = rl_g(om, 1 - piI, gap=-1.0)
    rdLG, rdLC = g[0] - g[1], g[0] - g[2]
    print(f"weights {wts}: SFT sp={dLC/dLG:.4f}  RL sp={rdLC/rdLG:.4f}  closed form (vA-vC)/(1+vA-vG)={cf:.4f}")
    check(f"V1 closed form sp at {wts}", abs(dLC / dLG - cf) < 1e-12 and abs(rdLC / rdLG - cf) < 1e-12)
# over a run
w = np.array([0.989, 0.010, 0.001]); om = np.log(w); om0 = om.copy()
piI = np.array([1.0, 0.0, 1.0])
for N in range(1, 20001):
    S, _ = sft_S(om, piI); om = om + zeta * S
    if N in (100, 1000, 20000):
        dLG = (om[0] - om[1]) - (om0[0] - om0[1]); dLC = (om[0] - om[2]) - (om0[0] - om0[2])
        print(f"   SFT run N={N:6d}: rise L_G={dLG:.3f}, rise L_C={dLC:.3f}, cumulative sp={dLC/dLG:.3f}")
# leak at an unchecked cell (both G and G_U emit X): common-mode decomposition
w = np.array([0.989, 0.010, 0.001]); om = np.log(w)
piX = np.array([0.0, 1.0, 1.0])
S, P = sft_S(om, piX)
print(f"leak, hard propensities: dL_G/zeta={S[0]-S[1]:+.3f}, dL_G_U/zeta={S[0]-S[2]:+.3f}; "
      f"common mode dOmega_A/zeta={S[0]:+.3f}; own terms {S[1]:+.3f}, {S[2]:+.3f}")
check("V1 leak common mode = -varpi_A", abs(S[0] + w[0]) < 1e-12)

# ---------------------------------------------------------------------------
hdr("V2. (P) transfer coefficient (product weights) vs (Sel), check-D prior")
cells = ["ck1", "ck2", "uk1", "F"]
regions = {"A": set(), "G": {"ck1", "ck2", "uk1", "F"}, "G_U": {"uk1", "F"},
           "G_{ck1,uk1}": {"ck1", "uk1"}, "G_{ck2}": {"ck2"}, "G_{F}": {"F"}}
names = list(regions)
mu0 = np.array([0.975, 0.010, 0.005, 0.004, 0.004, 0.002])
gm = np.array([[1.0 if c in regions[p] else 0.0 for c in cells] for p in names])
delta = 0.01
piXc = delta + (1 - 2 * delta) * gm


def tr_sel(mu, i, j):
    gi, gj = gm[:, i], gm[:, j]
    mi, mj = mu @ gi, mu @ gj
    return (mu @ (gi * gj) - mi * mj) / (mu @ gi - mi ** 2)


def tr_P(mu, i, j, piX=piXc):
    w = mu / mu.sum()
    Pi, Pj = w @ piX[:, i], w @ piX[:, j]
    num = np.sum(w * w * (piX[:, j] - Pj) * (piX[:, i] - Pi))
    den = np.sum(w * w * (piX[:, i] - Pi) ** 2)
    return num / den, den


def tr_P_numeric(mu, i, j, h=1e-7):
    om = np.log(mu)
    w = softmax(om); Pi0, Pj0 = w @ piXc[:, i], w @ piXc[:, j]
    S, _ = sft_S(om, piXc[:, i])
    w1 = softmax(om + h * S)
    return ((w1 @ piXc[:, j]) - Pj0) / ((w1 @ piXc[:, i]) - Pi0)


for (a, b) in [("ck1", "F"), ("F", "ck1"), ("ck1", "ck2"), ("uk1", "F")]:
    i, j = cells.index(a), cells.index(b)
    tp, _ = tr_P(mu0, i, j)
    tn = tr_P_numeric(mu0, i, j)
    print(f"Tr_{{{b}<-{a}}}: (Sel, hard) {tr_sel(mu0, i, j):.3f}   (P) formula {tp:.3f}   (P) numeric {tn:.3f}")
    check(f"V2 (P) formula matches numeric for {b}<-{a}", abs(tp - tn) < 1e-4)
i, j = cells.index("ck1"), cells.index("F")
tij, Vi = tr_P(mu0, i, j); tji, Vj = tr_P(mu0, j, i)
print(f"(P) reciprocity with V_P: {tij*Vi - tji*Vj:.2e}")
Pi, Pj = mu0 @ piXc[:, i], mu0 @ piXc[:, j]
print(f"(P) reciprocity with observable P(1-P): relative violation "
      f"{(tij*Pi*(1-Pi) - tji*Pj*(1-Pj))/(tij*Pi*(1-Pi)):.3f}")
check("V2 (P) reciprocity with V_P", abs(tij * Vi - tji * Vj) < 1e-12)

# ---------------------------------------------------------------------------
hdr("V3. Sharp surprise bounds: behaviour zeta(1-P)/2 (SFT), zeta Delta P(1-P)/2 (RL); ledger 2 zeta(1-P)")
worst_beh, worst_rl, worst_led = 0.0, 0.0, 0.0
for _ in range(100000):
    K = rng.integers(2, 6)
    w = rng.dirichlet(np.ones(K) * rng.choice([0.3, 1.0, 3.0]))
    piy = rng.uniform(0, 1, K) if rng.random() < 0.5 else rng.integers(0, 2, K).astype(float)
    P = w @ piy
    if P <= 1e-9 or P >= 1 - 1e-9:
        continue
    S = w * (piy - P) / P
    wp = rng.dirichlet(np.ones(K)) if rng.random() < 0.7 else w
    f = rng.uniform(0, 1, K) if rng.random() < 0.5 else rng.integers(0, 2, K).astype(float)
    Ef = wp @ f
    dE = np.sum(wp * (f - Ef) * S)  # first-order change per unit step
    worst_beh = max(worst_beh, abs(dE) / ((1 - P) / 2))
    worst_led = max(worst_led, (S.max() - S.min()) / (2 * (1 - P)))
    g = w * (piy - P)
    dEr = np.sum(wp * (f - Ef) * g)
    worst_rl = max(worst_rl, abs(dEr) / (P * (1 - P) / 2))
print(f"max |dE f| / (zeta(1-P)/2) = {worst_beh:.4f};  RL: max |dE f| / (zeta P(1-P)/2) = {worst_rl:.4f};"
      f"  ledger: max (S_max-S_min)/(2(1-P)) = {worst_led:.4f}")
check("V3 behaviour bound (SFT) <= 1", worst_beh <= 1 + 1e-9)
check("V3 behaviour bound (RL) <= 1", worst_rl <= 1 + 1e-9)
check("V3 ledger bound <= 1", worst_led <= 1 + 1e-9)
w = np.array([0.5, 0.5]); piy = np.array([1.0, 0.0]); P = 0.5
S = w * (piy - P) / P
print(f"attainment: two personas at 1/2, x'=x, f=1[y]: ratio {abs(np.sum(w*(piy-P)*S))/((1-P)/2):.4f}")

# ---------------------------------------------------------------------------
hdr("V4. SFT on the model's own samples has zero expected persona gradient")
mx = 0.0
for _ in range(1000):
    K = rng.integers(2, 6); w = rng.dirichlet(np.ones(K)); pX = rng.uniform(0, 1, K)
    P = w @ pX
    ES = P * (w * (pX - P) / P) + (1 - P) * (w * ((1 - pX) - (1 - P)) / (1 - P))
    mx = max(mx, np.abs(ES).max())
print(f"max |E_(y~P) S| = {mx:.1e}")
check("V4 zero expected gradient", mx < 1e-12)

# ---------------------------------------------------------------------------
hdr("V5. Channel G_iota (A and G_iota only, hard propensities, j_0=0.5): A's default-logit loss")
for mode in ["SFT", "RL"]:
    for N in (3000, 30000, 300000):
        om = np.zeros(2)  # A, G_iota ; in-context weights equal at start
        piX = np.array([0.0, 1.0])
        for _ in range(N):
            if mode == "SFT":
                S, _ = sft_S(om, piX)
            else:
                S, _ = rl_g(om, piX)
            om = om + zeta * S
        loss = -om[0]
        u_N = om[1] - om[0]
        if mode == "SFT":
            # closed form (continuous time): u + e^u = 2 zeta N + 1
            from scipy.optimize import brentq
            u_cf = brentq(lambda u: u + np.exp(u) - (2 * zeta * N + 1), -5, 50)
        else:
            # du/dN = 2 zeta j(1-j): 2u + e^u - e^{-u} = 2 zeta N
            from scipy.optimize import brentq
            u_cf = brentq(lambda u: 2 * u + np.exp(u) - np.exp(-u) - 2 * zeta * N, -5, 50)
        print(f"{mode} N={N:6d}: A's loss {loss:.3f} nats; half the in-context gain {u_N/2:.3f}; "
              f"closed form u/2 {u_cf/2:.3f}; (1/2)ln(2 zeta N) {0.5*np.log(2*zeta*N):.3f}")
        check(f"V5 {mode} closed form at N={N}", abs(u_N / 2 - u_cf / 2) < 0.02 and abs(loss - u_N / 2) < 1e-9)

# ---------------------------------------------------------------------------
hdr("V6. Quenched reading (Bayes over fixed types A, G, G_iota): rewarded X under iota")
dl = 0.01
mu = np.array([0.985, 0.010, 0.005])   # A, G (games everywhere), G_iota (games iff instructed)
piX_iota = np.array([dl, 1 - dl, 1 - dl]); piX_0 = np.array([dl, 1 - dl, dl])
for N in (0, 10, 100, 1000):
    lw = np.log(mu) + N * np.log(piX_iota)
    post = np.exp(lw - lw.max()); post /= post.sum()
    lw0 = np.log(mu) + N * np.log(piX_0)
    post0 = np.exp(lw0 - lw0.max()); post0 /= post0.sum()
    print(f"N={N:5d}: with iota: default gaming {post @ piX_0:.4f} (L_G={lw[0]-lw[1]:+.2f}); "
          f"without iota: {post0 @ piX_0:.4f} (L_G={lw0[0]-lw0[1]:+.2f})")
lim = mu[1] / (mu[1] + mu[2])
print(f"long-run default gaming with iota -> mu(G)/(mu(G)+mu(G_iota)) = {lim:.4f} (times 1-delta, plus delta)")

# ---------------------------------------------------------------------------
hdr("V7. Channel A residual under RL (two personas, varpi_G = 0.01, softness delta=0.01)")
for a in (0.1, 0.5, 0.9):
    om = np.log(np.array([0.99, 0.01]))
    g0, _ = rl_g(om, np.array([dl, 1 - dl])); g1, _ = rl_g(om, np.array([a, 1 - dl]))
    res = (g1[0] - g1[1]) / (g0[0] - g0[1])
    print(f"a={a}: res_RL={res:.4f}; exact (1-delta-a)/(1-2delta)={(1-dl-a)/(1-2*dl):.4f}")
    check(f"V7 res_RL exact at a={a}", abs(res - (1 - dl - a) / (1 - 2 * dl)) < 1e-12)

# ---------------------------------------------------------------------------
hdr("V8. Three personas: sign of the A:G ledger change (draft's channel-A setting)")
om = np.log(np.array([0.985, 0.010, 0.005]))
piX = np.array([0.9, 1 - dl, dl])   # under iota: A emits X w.p. 0.9; G games; third persona does not (draft's run)
S, P = sft_S(om, piX)
w = softmax(om)
gen = (w[1] * (piX[1] - P) - w[0] * (piX[0] - P)) / P
print(f"S = {S}; dL_G/zeta = {S[0]-S[1]:+.5f}; general formula -[vG(piG-P)-vA(piA-P)]/P = {-gen:+.5f}")
check("V8 general formula", abs((S[0] - S[1]) + gen) < 1e-12)

# ---------------------------------------------------------------------------
hdr("V9. Loop map (illustrative), q evaluated after each update")


def loop(LG0, LC0, g_chk, g_nb, kap, leak0, leak1, K=80, sp=0.0, shared_only=False, close=False,
         decl_cap=None, one_minus_q=True):
    LG, LC, used = LG0, LC0, 0.0
    out, fail = [], None

    def qof(LG, LC):
        eG = np.exp(min(-LG, 50.0)); eC = 0.0 if shared_only else np.exp(min(-LC, 50.0))
        return (eG + eC) / (1 + eG + eC)
    q = qof(LG, LC)
    out.append((0, LG, LC, q, 1.0 if shared_only else 1 / (1 + np.exp(min(LG - LC, 700)))))
    for k in range(1, K + 1):
        gn = g_nb
        if decl_cap is not None:
            gn = min(g_nb, max(decl_cap - used, 0.0)); used += gn
        fac = (1 - q) if one_minus_q else 1.0
        leak = 0.0 if close else leak0 + leak1 * q
        LG = max(LG + (g_chk + gn) * fac - kap - leak, -50.0)
        LC = max(LC + (sp * g_chk + gn) * fac - kap - leak, -50.0)
        q = qof(LG, LC)
        sh = 1.0 if shared_only else 1 / (1 + np.exp(min(LG - LC, 700)))
        out.append((k, LG, LC, q, sh))
        if fail is None and q > 0.5:
            fail = k
    return out, fail


base = dict(LG0=np.log(0.989 / 0.010), LC0=np.log(0.989 / 0.001), g_chk=3.0, g_nb=0.5, kap=0.3,
            leak0=1.0, leak1=5.0)
print("parameters:", {k: round(v, 3) for k, v in base.items()})
scen = [("S1 shared only", dict(shared_only=True)),
        ("S2 shared + conditional (sp=0)", dict()),
        ("S2 without the (1-q) factor", dict(one_minus_q=False)),
        ("S3 S2 with the U-cell leak closed", dict(close=True)),
        ("S4 S2, gamma_nb=1.5 from declarative data capped at 2.3 nats in total", dict(g_nb=1.5, decl_cap=2.3)),
        ("S5 S2, gamma_nb=1.5 sustained", dict(g_nb=1.5))]
for nm, kw in scen:
    b = dict(base); b.update(kw)
    out, fail = loop(**b)
    sel = {r[0]: r for r in out}
    print(f"{nm}: first k with q>0.5 after k updates: {fail};  sharedness k=1: {sel[1][4]:.3g}, k=5: {sel[5][4]:.3g};"
          f"  q at k=0: {sel[0][3]:.4f}")
for sp in (0.1, 0.2, 0.25, 0.267, 0.27, 0.3, 0.5):
    out, fail = loop(**base, sp=sp)
    print(f"S2 with spillover sp={sp:5.3f}: failure after {fail} updates")
spstar = (base["kap"] + base["leak0"] - base["g_nb"]) / base["g_chk"]
print(f"threshold sp* = (kappa_L g + Lambda_U(0) - gamma_nb)/gamma_chk = {spstar:.4f}")
out, fail = loop(**base, sp=0.5)
print(f"(P)-like sp=0.5: sharedness at k=5 {out[5][4]:.3g}, L_C at k=20 {out[20][2]:.2f}")
# closed form crossing without feedback (q=0 leak, no (1-q))
print(f"closed form crossing (no grader feedback): L_C0/(Lambda_U(0)+kappa_L g-gamma_nb) = "
      f"{base['LC0']/(base['leak0']+base['kap']-base['g_nb']):.2f}")

# ---------------------------------------------------------------------------
hdr("V10. Strong-sieve sharedness, check-D prior (ck: -6 nats, uk1 and F: +2 nats)")
ev = np.array([-6.0, -6.0, 2.0, 2.0])
for lab, e in [("mild", np.array([-1.5, -1.5, 0.5, 0.5])), ("strong", ev)]:
    lw = np.log(mu0) + gm @ e
    m = np.exp(lw - lw.max()); m /= m.sum()
    shv = (m @ (gm[:, 3] * np.maximum(gm[:, 0], gm[:, 1]))) / (m @ gm[:, 3])
    print(f"{lab} sieve: sh = {shv:.2e}; cap -ln(1-sh) = {-np.log(1-shv):.2e} nats")

print(f"\nTOTAL: {n_checks} checks, {n_fail} failures")
