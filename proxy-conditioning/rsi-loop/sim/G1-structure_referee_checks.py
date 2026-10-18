"""Referee checks for drafts/G1-structure.md (adversarial review).

Run: python3 G1-structure_referee_checks.py > G1-structure_referee_checks_output.txt
Sections:
  R1  (P) operator: does checkable repair reach the conditional ledger L_C = omega_A - omega_C?
  R2  (P) operator: does an unchecked-cell leak charge G and C_U equally?  (G1.3 "same evidence")
  R3  (P) operator: frontier gain from checkable training vs the G1.2(3) cap -ln(1-sh)
  R4  transfer coefficient under (P) vs the (Sel) formula Cov/Var; reciprocity normaliser
  R5  channel C_iota: is A's default-logit loss bounded? (half-gain identity, long runs)
  R6  sharp constant in G1.6's behaviour-probability bound
  R7  three-persona sign flip of lambda_+ (channel A trajectory: G loses weight though pi_G > pi_A)
  R8  appendix approximation for res_RL in channel A
  R9  loop map variants: T1.10i's gamma(1-q) factor; (P)-style partial transfer of gamma_chk to L_C
"""
import numpy as np

np.set_printoptions(precision=5, suppress=True)
rng = np.random.default_rng(7)


def softmax(z):
    z = np.asarray(z, float); z = z - z.max(); e = np.exp(z); return e / e.sum()


def logit(p):
    return np.log(p / (1 - p))


def sft_step(om, shift, pi_y):
    w = softmax(om + shift); P = w @ pi_y
    return w * (pi_y - P) / P


def rl_step(om, shift, piX, gap):
    """expected REINFORCE gradient, X earns `gap` more than I (gap<0: X penalised)."""
    w = softmax(om + shift); P = w @ piX
    return gap * w * (piX - P)


def hdr(s):
    print("\n" + "=" * 78 + "\n" + s + "\n" + "=" * 78)


delta = 0.01
names = ["A", "G", "C_U"]
pi_K = np.array([delta, 1 - delta, delta])      # checked cell: C_U behaves like A
pi_U = np.array([delta, 1 - delta, 1 - delta])  # unchecked cell: C_U games like G
w0 = np.array([0.989, 0.010, 0.001])
om0 = np.log(w0)

# ---------------------------------------------------------------------------
hdr("R1. (P): checkable repair on a checked cell, persona weights A,G,C_U = 0.989, 0.010, 0.001")
eps = 0.02
for mode in ["SFT on I", "RL, X penalised (gap -1)"]:
    om = om0.copy()
    LG0, LC0 = om[0] - om[1], om[0] - om[2]
    for N in [1, 100, 1000, 10000]:
        pass
    om = om0.copy(); rows = []
    marks = {1, 100, 1000, 10000, 100000}
    for k in range(1, 100001):
        if mode.startswith("SFT"):
            om = om + eps * sft_step(om, 0, 1 - pi_K)   # trains on output I
        else:
            om = om + eps * rl_step(om, 0, pi_K, -1.0)
        if k in marks:
            rows.append((k, (om[0] - om[1]) - LG0, (om[0] - om[2]) - LC0))
    print(f"{mode}:")
    for k, dG, dC in rows:
        print(f"   N={k:6d}  rise of L_G={dG:8.4f}  rise of L_C={dC:8.4f}  ratio L_C/L_G={dC/dG:6.3f}")
print("Under (Sel)/Bayes (T1.1) the rise of L_C would be exactly 0. Under (P) it is about varpi_A/(1+varpi_A) ~ 1/2 of L_G's.")

# ---------------------------------------------------------------------------
hdr("R2. (P): one rewarded X event in an unchecked cell; ledger changes per eps")
for wts in [(0.989, 0.010, 0.001), (0.989, 0.001, 0.010), (0.98, 0.0, 0.02)]:
    w = np.array(wts) + 1e-300
    om = np.log(w)
    S = sft_step(om, 0, pi_U)
    R = rl_step(om, 0, pi_U, 1.0)
    print(f"weights {wts}: SFT dL_G={S[0]-S[1]:+.4f} dL_C={S[0]-S[2]:+.4f} ;  RL dL_G={R[0]-R[1]:+.5f} dL_C={R[0]-R[2]:+.5f}")
print("dL_G != dL_C: under (P) the two do not 'receive the same unchecked-cell evidence'; the larger persona gains")
print("more logit, and L_C falls even when C_U is absent-ish, because G's gain is paid for by omega_A (direct coupling).")

# ---------------------------------------------------------------------------
hdr("R3. (P): frontier on-task log-odds gain from SFT on intended outputs at checked cells (check-D prior)")
cells = ["ck1", "ck2", "uk1", "F"]
personas = {"A": set(), "G": {"ck1", "ck2", "uk1", "F"}, "C_U": {"uk1", "F"},
            "C_1": {"ck1", "uk1"}, "C_2": {"ck2"}, "C_F": {"F"}}
prior = np.array([0.975, 0.010, 0.005, 0.004, 0.004, 0.002])
gm = np.array([[1.0 if c in personas[p] else 0.0 for c in cells] for p in personas])
piX = delta + (1 - 2 * delta) * gm  # soft propensities, persona x cell


def frontier_onlogodds(om):
    w = softmax(om); P = w @ piX[:, 3]; return logit(1 - P)


def sh_of(mu):
    mu = mu / mu.sum()
    return (mu @ (gm[:, 3] * np.maximum(gm[:, 0], gm[:, 1]))) / (mu @ gm[:, 3])


cap = -np.log(1 - sh_of(prior))
om = np.log(prior); base = frontier_onlogodds(om)
marks = {100, 1000, 10000, 100000}
for k in range(1, 100001):
    c = k % 2  # alternate ck1, ck2
    om = om + eps * sft_step(om, 0, 1 - piX[:, c])
    if k in marks:
        print(f"   N={k:6d} SFT steps on I at ck1/ck2: frontier gain {frontier_onlogodds(om)-base:.3f} nats; "
              f"(Sel) cap -ln(1-sh) = {cap:.3f}")
print("Under (P) the cap is exceeded: the gain comes from omega_A absorbing G's lost mass, not from sh.")

# ---------------------------------------------------------------------------
hdr("R4. Transfer coefficients under (P) vs the (Sel) formula, check-D prior, cells ck1 -> F and F -> ck1")
mu = prior / prior.sum()
m = mu @ gm


def tr_sel(i, j):  # Tr_{j <- i}
    cov = mu @ (gm[:, i] * gm[:, j]) - m[i] * m[j]
    return cov / (m[i] * (1 - m[i]))


def tr_P(i, j, mode="SFT"):
    om = np.log(mu); h = 1e-7
    if mode == "SFT":
        d = sft_step(om, 0, piX[:, i])
    else:
        d = rl_step(om, 0, piX[:, i], 1.0)
    P_before = softmax(om) @ piX
    P_after = softmax(om + h * d) @ piX
    return (P_after[j] - P_before[j]) / (P_after[i] - P_before[i])


for (i, j) in [(0, 3), (3, 0), (0, 1), (2, 3)]:
    print(f"   Tr_{{{cells[j]}<-{cells[i]}}}: (Sel) {tr_sel(i, j):.3f}   (P) SFT {tr_P(i, j):.3f}   (P) RL {tr_P(i, j, 'RL'):.3f}")
# reciprocity normalisers
Vsel = m * (1 - m)
w = softmax(np.log(mu)); P = w @ piX
VP = np.array([np.sum(w ** 2 * (piX[:, c] - P[c]) ** 2) for c in range(4)])
i, j = 0, 3
print(f"   (Sel) reciprocity Tr_ji Var_i - Tr_ij Var_j = {tr_sel(i,j)*Vsel[i]-tr_sel(j,i)*Vsel[j]:.2e}")
print(f"   (P)  with the observable Var=P(1-P): {tr_P(i,j)*P[i]*(1-P[i]) - tr_P(j,i)*P[j]*(1-P[j]):.2e}"
      f"  (relative {abs(tr_P(i,j)*P[i]*(1-P[i]) / (tr_P(j,i)*P[j]*(1-P[j])) - 1):.2f})")
print(f"   (P)  with V_P(x)=sum varpi^2 (pi-P)^2:  {tr_P(i,j)*VP[i] - tr_P(j,i)*VP[j]:.2e}")

# ---------------------------------------------------------------------------
hdr("R5. Channel C_iota (A and C_iota only, j_0=0.5): A's cumulative default-logit loss vs number of events")
om = np.log(np.array([0.995, 0.005]))
sh = np.array([0.0, np.log(0.995 / 0.005)])
pix = np.array([1e-12, 1 - 1e-12])
loss = 0.0; marks = {3000, 30000, 300000}
for k in range(1, 300001):
    S = sft_step(om, sh, pix); om = om + eps * S; loss += -eps * S[0]
    if k in marks:
        print(f"   N={k:7d}  A's logit loss {loss:.3f} nats; 0.5*ln(2*eps*N) = {0.5*np.log(2*eps*k):.3f}")
print("The loss is not bounded: it grows like (1/2) ln N. Every other persona's default odds against A rise by it.")

# ---------------------------------------------------------------------------
hdr("R6. Sharp constant for G1.6's behaviour-probability bound")
best = 0.0
for _ in range(200000):
    K = rng.integers(2, 6)
    om = rng.normal(0, 3, K); s1 = rng.normal(0, 3, K); s2 = rng.normal(0, 3, K)
    py = rng.integers(0, 2, K).astype(float); py = np.clip(py, 1e-9, 1 - 1e-9)
    f = rng.integers(0, 2, K).astype(float)
    S = sft_step(om, s1, py); P = softmax(om + s1) @ py
    if P > 1 - 1e-6:
        continue
    wp = softmax(om + s2)
    best = max(best, abs(np.sum(wp * (f - wp @ f) * S)) / (1 - P))
print(f"   max |Delta E_x' f| / (eps (1-P)) over random deterministic instances: {best:.4f}  (draft bound 2; claimed sharp bound 1/2)")
# constructed near-extremal instance: x' = x, two personas, f = y-indicator
for a in [0.5]:
    om = np.log(np.array([a, 1 - a])); py = np.array([1.0 - 1e-12, 1e-12])
    S = sft_step(om, 0, py); P = softmax(om) @ py; wp = softmax(om); f = py
    print(f"   two personas, varpi=0.5, f=1[y]: ratio {abs(np.sum(wp*(f-wp@f)*S))/(1-P):.4f}")

# ---------------------------------------------------------------------------
hdr("R7. Three personas: sign of lambda_+ need not follow pi_G - pi_A (draft's channel-A trajectory)")
om = np.log(np.array([0.985, 0.010, 0.005]))
piA = np.array([0.9, 1 - delta, delta])
S = sft_step(om, 0, piA)
print(f"   first event: S(A)={S[0]:+.5f} S(G)={S[1]:+.5f} S(C)={S[2]:+.5f}; ledger change dL_G/eps = {S[0]-S[1]:+.5f} (>0: toward A)")
print("   although pi_G = 0.99 > pi_A = 0.9 on the rewarded X. G1.5's 'three things set lambda_+' holds only for two personas.")

# ---------------------------------------------------------------------------
hdr("R8. Appendix approximation res_RL (channel A)")
for a in [0.1, 0.5, 0.9]:
    exact = (1 - delta - a) / (1 - 2 * delta)
    print(f"   a={a}: exact (1-delta-a)/(1-2delta)={exact:.4f}; appendix (1-a)/(1-delta)={(1-a)/(1-delta):.4f}; body 1-a={1-a:.2f}")

# ---------------------------------------------------------------------------
hdr("R9. Illustrative loop (draft's E parameters) under variants")


def loop(gam_chk=3.0, gam_nb=0.5, kap=0.3, leak0=1.0, leak1=5.0, frac_chk_to_C=0.0, one_minus_q=False, K=60):
    LG, LC = np.log(0.989 / 0.010), np.log(0.989 / 0.001)
    for k in range(1, K + 1):
        eG, eC = np.exp(min(-LG, 50)), np.exp(min(-LC, 50))
        q = (eG + eC) / (1 + eG + eC)
        f = (1 - q) if one_minus_q else 1.0
        leak = leak0 + leak1 * q
        LG = max(LG + f * (gam_chk + gam_nb) - kap - leak, -50)
        LC = max(LC + f * (gam_nb + frac_chk_to_C * gam_chk) - kap - leak, -50)
        eG, eC = np.exp(min(-LG, 50)), np.exp(min(-LC, 50))
        if (eG + eC) / (1 + eG + eC) > 0.5:
            return k
    return None


print(f"   draft S2:                                   fails at {loop()}")
print(f"   S2 with T1.10i's gamma(1-q_k):              fails at {loop(one_minus_q=True)}")
for fr in [0.1, 0.2, 0.25, 0.3, 0.5]:
    print(f"   S2 with a fraction {fr:.2f} of gamma_chk reaching L_C: fails at {loop(frac_chk_to_C=fr)}")
print("   (threshold fraction = (kappa_L g + leak0 - gamma_nb)/gamma_chk = %.3f)" % ((0.3 + 1.0 - 0.5) / 3.0))
