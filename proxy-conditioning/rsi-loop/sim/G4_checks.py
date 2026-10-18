"""G4 (honesty) checks.  Every number quoted in drafts/G4-honesty.md comes from here.

Run:  python3 G4_checks.py > G4_checks_output.txt
Sections H1..H10 correspond to the citations "check H1" etc. in the draft.
All parameter values are illustrative unless stated otherwise.
Revised 18 October 2026 in response to drafts/G4-honesty-referee.md (H7 corrected; H10 added).
"""
import itertools
import math

import numpy as np
from scipy import stats

rng = np.random.default_rng(20261018)
FAILS = []


def check(name, cond):
    print(f"  [{'ok' if cond else 'FAIL'}] {name}")
    if not cond:
        FAILS.append(name)


def bern_kl(p, q):
    out = 0.0
    for a, b in ((p, q), (1 - p, 1 - q)):
        if a > 0:
            out += a * math.log(a / b)
    return out


def hr(t):
    print("=" * 78)
    print(t)


# ---------------------------------------------------------------------------
hr("H1. Drift of the overseer-simulator S against the honest reporter H with an\n"
   "    internals check in the reward (G4.4).  Per disagreement question:\n"
   "    D_S = (lam+ + lam-) (t* - tpr + (1-t*) fpr_D).  Brute force from rewards.")
lp, lm = 0.05, 0.15            # (D) nats per unit reward gap; t* = 0.25
ts = lp / (lp + lm)
wD = 0.1 * 0.05                # frontier share x predictable disagreement rate
n = 10 ** 5                    # episodes per generation (illustrative)
print(f"  lam+={lp} lam-={lm} t*={ts:.3f}  w_Delta={wD}  n={n}")


def drift_formula(tpr, fpr):
    return (lp + lm) * (ts - tpr + (1 - ts) * fpr)


def drift_brute(tpr, fpr):
    # reward: grader gives 1 if report agrees with overseer; if the check fires,
    # the reward is replaced by -c with c = lm/lp (so lam- = c * lam+).
    c = lm / lp
    # on a disagreement question: S agrees with overseer, H does not
    JS = (1 - tpr) * 1 + tpr * (-c)
    JH = (1 - fpr) * 0 + fpr * (-c)
    return lp * (JS - JH)


rows = [("no check", 0.0, 0.0), ("probe, plain lies", 0.9, 0.05),
        ("probe, fpr on honest disagreement 0.3", 0.9, 0.3),
        ("weak probe", 0.3, 0.05), ("best reachable concealment", 0.2, 0.05),
        ("concealment, high fpr", 0.2, 0.3)]
for name, tpr, fpr in rows:
    d1, d2 = drift_formula(tpr, fpr), drift_brute(tpr, fpr)
    print(f"  {name:40s} tpr={tpr:.2f} fpr={fpr:.2f}: D_S per Delta-question={d1:+.4f}"
          f"  per generation n w_D D_S={n * wD * d1:+8.2f} nats  (brute {d2:+.4f})")
    check(f"formula = brute force ({name})", abs(d1 - d2) < 1e-12)

# Belief capture H_o and the sincere simulator: the probe reads o, so the state looks like an
# agreement question and the probe fires at fpr_eq.  Drift against H with the probe in the reward.
fpr_eq = 0.01
for fpr in (0.05, 0.3):
    c = lm / lp
    J_o = (1 - fpr_eq) - c * fpr_eq
    J_H = -c * fpr
    brute = lp * (J_o - J_H)
    form = (lp + lm) * (ts - fpr_eq + (1 - ts) * fpr)
    print(f"  belief capture H_o (probe fires at fpr_eq={fpr_eq}) vs H, fpr_D={fpr}: per Delta-question {form:+.4f};"
          f" per generation {n * wD * form:+.2f} nats (no check: +25.00)")
    check(f"H_o drift formula = brute force (fpr_D={fpr})", abs(brute - form) < 1e-12)

# ---------------------------------------------------------------------------
hr("H2. Measurement use: evidence per disagreement question (G4.3).\n"
   "    E_S[LLR] = KL(Bern(tpr)||Bern(fpr)); E_H[-LLR] = KL(Bern(fpr)||Bern(tpr)).")
target = math.log(1e6)
for tpr, fpr in [(0.9, 0.05), (0.6, 0.05), (0.2, 0.05), (0.9, 0.3), (0.06, 0.05)]:
    k1, k2 = bern_kl(tpr, fpr), bern_kl(fpr, tpr)
    print(f"  tpr={tpr:.2f} fpr={fpr:.2f}: KL(S||H)={k1:.3f} nats/question, KL(H||S)={k2:.3f};"
          f" questions for ln(1e6)=13.8 nats against S: {target / k1:8.1f}")
# Monte Carlo check of the expected LLR
tpr, fpr = 0.6, 0.05
x = rng.random(200000) < tpr
llr = np.where(x, math.log(tpr / fpr), math.log((1 - tpr) / (1 - fpr)))
check("MC mean LLR under S matches KL (tpr .6, fpr .05)", abs(llr.mean() - bern_kl(tpr, fpr)) < 0.01)
print("  Assumption 2 dropped: Delta membership unknown.  A share p_D of probed questions is in Delta;")
print("  the probe fires at fpr_eq on agreement questions.  Pooled KL <= p_D KL(tpr||fpr_D) (joint convexity).")
p_D = 0.05
for tpr, fpr in [(0.9, 0.05), (0.2, 0.05), (0.9, 0.3)]:
    pS = p_D * tpr + (1 - p_D) * fpr_eq
    pH = p_D * fpr + (1 - p_D) * fpr_eq
    pooled = bern_kl(pS, pH)
    print(f"    tpr={tpr} fpr_D={fpr}: pooled {pooled:.4f} per probed question = {pooled / p_D:.3f} per Delta-question"
          f" (known Delta {bern_kl(tpr, fpr):.3f}; ratio {pooled / p_D / bern_kl(tpr, fpr):.2f})")
    check(f"pooled <= p_D KL (tpr {tpr}, fpr {fpr})", pooled <= p_D * bern_kl(tpr, fpr) + 1e-12)
print("  Assumption 1 dropped: model-level correlation.  A share p_bl of H_sim instances is blind")
print("  (tpr 0.06 on all its questions), the rest has tpr 0.94 (mean 0.896).  Gate N=100, k=10.")
Ng, kg = 100, 10
PHg = stats.binom.cdf(kg, Ng, 0.05)
iid = math.log(stats.binom.cdf(kg, Ng, 0.896) / PHg)
for p_bl in (0.05, 0.01):
    mix = math.log((p_bl * stats.binom.cdf(kg, Ng, 0.06) + (1 - p_bl) * stats.binom.cdf(kg, Ng, 0.94)) / PHg)
    print(f"    p_bl={p_bl}: i.i.d. at the mean tpr {iid:+.1f} nats; with blind instances {mix:+.2f} nats;"
          f" floor ln p_bl = {math.log(p_bl):+.2f}")
    check(f"correlated gate effect >= ln p_bl + ln(P_blind/P_H) (p_bl={p_bl})",
          mix >= math.log(p_bl) + math.log(stats.binom.cdf(kg, Ng, 0.06) / PHg) - 1e-12)

# ---------------------------------------------------------------------------
hr("H3. Gate (measurement used only to accept or reject a trained model).\n"
   "    Posterior odds of type theta vs H after the gate are multiplied by\n"
   "    P_theta(pass)/P_H(pass) <= 1/P_H(pass).  Gate: pass iff fires <= k of N.")
N, k = 100, 10
fpr = 0.05
PH = stats.binom.cdf(k, N, fpr)
print(f"  N={N} disagreement questions, threshold k={k}, honest fpr={fpr}: P_H(pass)={PH:.4f};"
      f" max odds gain for any type = 1/P_H = {1 / PH:.4f} ({math.log(1 / PH):.4f} nats)")
for name, t in [("S, no concealment (tpr .9)", 0.9), ("concealer tpr_c .2", 0.2),
                ("concealer tpr_c .1", 0.1), ("perfect concealer tpr_c = fpr", 0.05)]:
    Pt = stats.binom.cdf(k, N, t)
    print(f"  {name:32s}: P(pass)={Pt:.3e}; log odds change vs H = {math.log(Pt / PH):+8.3f} nats")
for name, t in [("S, no concealment (tpr .9)", 0.9), ("concealer tpr_c .2", 0.2)]:
    print(f"    {name}: Chernoff -N KL(k/N||tpr) = {-N * bern_kl(k / N, t):+.2f};"
          f" G4.3 scale -N KL(tpr||fpr_D) = {-N * bern_kl(t, fpr):+.2f}")
print("  Output-level filtering: every firing output is discarded and the rest feeds gradients or data.")
print("  Each disagreement output is its own gate: bound n w_D ln(1/(1-fpr_D)) per generation.")
for f in (0.05, 0.3):
    per = math.log(1 / (1 - f))
    print(f"    fpr_D={f}: {per:.4f} nats per disagreement output; {n * wD * per:.1f} nats per generation"
          f" (one lineage gate: {math.log(1 / stats.binom.cdf(k, N, f)):.4f})")
# retry: accepting the first of up to R i.i.d. draws that passes gives the posterior
# conditioned on pass (if R large); check by simulation with a 3-type prior.
prior = {"H": 0.9, "S": 0.05, "Cc": 0.05}
ptype = {"H": 0.05, "S": 0.9, "Cc": 0.1}
acc = {kk: 0 for kk in prior}
types = list(prior)
pr = np.array([prior[t] for t in types])
for _ in range(20000):
    while True:
        t = types[rng.choice(3, p=pr)]
        fires = rng.binomial(N, ptype[t])
        if fires <= k:
            acc[t] += 1
            break
tot = sum(acc.values())
Pp = {t: stats.binom.cdf(k, N, ptype[t]) for t in types}
Z = sum(prior[t] * Pp[t] for t in types)
for t in types:
    print(f"    accepted share {t}: MC {acc[t] / tot:.4f}  formula {prior[t] * Pp[t] / Z:.4f}")
check("retry-until-pass = posterior conditioned on pass",
      all(abs(acc[t] / tot - prior[t] * Pp[t] / Z) < 0.01 for t in types))
# compare training use: concealment bank of G2.6 with the same detector
print("  Training use, same detector, G2.6 constants (lam+=1, lam-=3, tpr .6, tpr_c .1, w .05, q0 .018):")
S_rate = (1 + 3) * (0.6 - 0.25)
for varpi_T in (20.0, 40.0):
    for n_run in (1e6, 1e8):
        need = math.log(1 + S_rate * 0.05 * 0.018 * n_run)
        # B_T = S/(varpi_T (tpr - tpr_c) 2^-K)  >  need   <=>  K > log2(need varpi_T 0.5 / S)
        Kmin = math.log2(need * varpi_T * 0.5 / S_rate)
        print(f"    varpi_T={varpi_T:4.0f}, run n={n_run:.0e}: selection beats concealment learning iff"
              f" K_c > {Kmin:.2f} bits (needed bank {need:.2f} nats)")

# ---------------------------------------------------------------------------
hr("H4. Confession channel, incentive compatibility for G (G4.7).\n"
   "    Confess iff v_c + d_J - 1 >= c_m v_c (1 - d_J).  Brute force from payoffs.")


def pay_confess(vc, dJ, cm):
    return vc * (1 - cm) + (1 - vc) * (-dJ * cm)


def pay_deny(vc, dJ, cm):
    return (1 - dJ) * 1 + dJ * (-cm)


ok = True
for vc, dJ, cm in itertools.product([0.5, 0.9, 0.95, 0.99, 1.0], [0, 0.01, 0.05, 0.2, 0.5, 0.9],
                                    [0, 0.1, 0.5, 1, 5]):
    lhs = pay_confess(vc, dJ, cm) - pay_deny(vc, dJ, cm)
    rhs = (vc + dJ - 1) - cm * vc * (1 - dJ)
    ok &= abs(lhs - rhs) < 1e-12
check("confess-minus-deny payoff = (v_c+d_J-1) - c_m v_c (1-d_J) on a grid", ok)
print("  largest main-channel penalty c_m that keeps confessing IC:")
for vc in (0.9, 0.95, 0.99, 1.0):
    cells = []
    for dJ in (0.0, 0.05, 0.2, 0.5):
        num = vc + dJ - 1
        if num < 0:
            cells.append("  none ")
        else:
            cells.append(f"{num / (vc * (1 - dJ)):7.3f}")
    print(f"    v_c={vc:.2f}: d_J=0, .05, .2, .5 -> " + " ".join(cells))
print("  audit of the confession channel at rate a_c: effective d_J' = d_J + a_c (1-d_J).")
for vc in (0.9, 0.99, 0.999):
    print(f"    v_c={vc}: with d_J=0 need a_c >= 1-v_c = {1 - vc:.3f}")
print("  Correlated detection: a judge that finds the gaming also accepts a true confession,")
print("  acceptance a + (1-a) d.  Confess-minus-deny (c_m=0) = a(1-d) - (1-2d).")
ok = True
for vc in (0.9, 0.95, 0.99):
    for dJ in (0.0, 0.05, 0.2):
        diff = (vc + (1 - vc) * dJ) - (1 - dJ)
        ok &= abs(diff - (vc * (1 - dJ) - (1 - 2 * dJ))) < 1e-12
    print(f"    v_c={vc}: audit threshold (1-a)/(2-a) = {(1 - vc) / (2 - vc):.4f} (independent detection: {1 - vc:.3f})")
check("correlated confess-minus-deny = a(1-d) - (1-2d)", ok)

# ---------------------------------------------------------------------------
hr("H5. Confession channel for a careful gamer with stake Omega on exposure (G4.8).\n"
   "    Same algebra with c_m -> Omega: confess iff d_J' >= threshold.")
for vc in (0.95, 0.99):
    for Om in (0.1, 1.0, 10.0, 100.0):
        # solve v_c + d - 1 >= Om v_c (1-d) for d
        dmin = (1 - vc + Om * vc) / (1 + Om * vc)
        print(f"  v_c={vc}, Omega={Om:6.1f}: confesses only if d_J' >= {dmin:.4f}")
    check(f"threshold -> 1 as Omega -> inf (v_c={vc})", (1 - vc + 1e6 * vc) / (1 + 1e6 * vc) > 0.9999)

# ---------------------------------------------------------------------------
hr("H6. Frontier-slice leak with confessions plus class patching (G4.9).")
lp_D = 0.05
J, vc, Tpat, wF = 50, 0.9, 1000, 0.1
eps = np.full(J, 0.05 / J)
bound = lp_D * (J / vc + Tpat * wF * eps.sum())
per_gen_no = lp_D * n * wF * eps.sum()
print(f"  J={J} classes, sum eps_F={eps.sum():.3f}, w_F={wF}, v_c={vc}, latency {Tpat} episodes, lam+={lp_D}")
print(f"  bound on total leak: lam+ (J/v_c + T_pat w_F sum eps) = {bound:.2f} nats;"
      f" without confessions: {per_gen_no:.1f} nats per generation of n={n}")
# simulation (continuous time, per class): opportunities of class j arrive at rate w_F eps_j
# per episode; each gamed event is confessed and accepted w.p. v_c; the class is patched
# T_pat episodes after the first accepted confession; leak = gamed events before the patch.
reps = 20000
first = rng.geometric(vc, size=(reps, J))                      # events up to first accepted confession
during = rng.poisson(wF * eps * Tpat, size=(reps, J))          # events during the patch latency
leaks = (first + during).sum(axis=1)
print(f"  (expected leak equals the bound when the generation is long enough; P(class unpatched by n)"
      f" ~ exp(-n w_F eps_j v_c) = {math.exp(-n * wF * eps[0] * vc):.1e})")
sim = lp_D * np.mean(leaks)
print(f"  simulated mean total leak {sim:.2f} nats (bound {bound:.2f})")
check("simulated leak matches bound (expectation)", abs(sim - bound) / bound < 0.02)
print("  Mixed population: a share cr of gaming events is confessed.  Finite-n simulation: per class,")
print("  Poisson arrivals, each accepted w.p. v_c cr, patch T_pat later, generation of n episodes.")
print("  Capped bound: sum_j min(1/(v_c cr) + w_F eps_j T_pat, n w_F eps_j).")


def finite_leak(cr, reps=4000):
    tot = np.zeros(reps)
    rate = wF * eps[0]
    p = vc * cr
    for _ in range(J):
        m = rng.geometric(p, size=reps)                  # events up to and including the first accepted
        t_first = rng.gamma(m, 1 / rate)                 # episode of the first accepted confession
        t_patch = np.minimum(t_first + Tpat, n)
        before = np.where(t_first <= n, m, rng.poisson(rate * n, size=reps))
        lat = np.where(t_first <= n, rng.poisson(rate * np.maximum(t_patch - t_first, 0)), 0)
        tot += before + lat
    return lp_D * tot.mean()


for cr in (1.0, 0.43, 0.1):
    unc = lp_D * (J / (vc * cr) + Tpat * wF * eps.sum())
    cap = lp_D * sum(min(1 / (vc * cr) + wF * e * Tpat, n * wF * e) for e in eps)
    simf = finite_leak(cr)
    print(f"    cr={cr:.2f}: uncapped {unc:.2f}, capped bound {cap:.2f}, finite-n simulation {simf:.2f} nats"
          f" (no confessions {per_gen_no:.1f})")
    check(f"simulation <= capped bound (cr={cr})", simf <= cap * 1.02)

# ---------------------------------------------------------------------------
hr("H7. Two channels, four personas (G4.10): main channel trained on a weak RM\n"
   "    that pays for gaming; walled-off confession channel rewarded for accuracy.\n"
   "    Selection (D): log-weight_theta += lam_main J_main + lam_conf J_conf per episode.")
w_opp = 0.05
lam_main, lam_conf = 0.05, 0.05


def run_h7(vC, dJ, steps, marks):
    pri = {"A": 0.90, "Gc": 0.03, "Gd": 0.04, "Cs": 0.03}
    Jmain = {"A": 0.0, "Gc": w_opp, "Gd": w_opp, "Cs": 0.0}
    Jconf = {"A": 1.0, "Gc": 1 - w_opp * (1 - vC), "Gd": 1 - w_opp * dJ, "Cs": 1.0}
    logw = {t: math.log(p) for t, p in pri.items()}
    print(f"  v_c={vC}, d_J={dJ}:  episodes   P(game)  P(confess | game)")
    for step in range(0, steps + 1):
        if step in marks:
            z = np.array([logw[t] for t in pri]); p = np.exp(z - z.max()); p /= p.sum()
            m = dict(zip(pri, p)); pg = m["Gc"] + m["Gd"]
            print(f"              {step:8d}   {pg:.4f}   {m['Gc'] / pg:.4f}")
        for t in pri:
            logw[t] += lam_main * Jmain[t] + lam_conf * Jconf[t]
    return m["Gc"] / (m["Gc"] + m["Gd"])


share_illus = run_h7(0.95, 0.3, 4000, (0, 1000, 2000, 4000))
share_cal = run_h7(0.99, 0.02, 40000, (0, 4000, 40000))
check("illustrative: confession share among gamers rises while gaming rises", share_illus > 0.85)
check("calibrated (same weak judge): confession share still below 0.7 after 40000 episodes", share_cal < 0.7)
for vC, dJ in ((0.95, 0.3), (0.99, 0.02), (0.95, 0.0)):
    print(f"  v_c={vC} d_J={dJ}: drift Gc vs A = {lam_main * w_opp - lam_conf * w_opp * (1 - vC):+.6f};"
          f" drift Gd vs Gc = -lam_conf w (v_c+d_J-1) = {-lam_conf * w_opp * (vC + dJ - 1):+.6f} per episode")
print("  Wall leak: confessors game at relative rate rg.  Gc games on rg w episodes (confession accepted")
print("  w.p. v_c) and complies, confessing truthfully, on (1-rg) w; Gd games on all w, denial rejected w.p. d_J.")
for vC, dJ in ((0.95, 0.3), (0.99, 0.02)):
    def brute(rg):
        Jm_c, Jm_d = rg * w_opp, w_opp
        Jc_c = 1 - rg * w_opp * (1 - vC)
        Jc_d = 1 - w_opp * dJ
        return lam_main * (Jm_d - Jm_c) + lam_conf * (Jc_d - Jc_c)

    def form(rg):
        return lam_main * w_opp * (1 - rg) - lam_conf * w_opp * (dJ - rg * (1 - vC))

    ok = all(abs(brute(r) - form(r)) < 1e-12 for r in np.linspace(0, 1, 21))
    rg_star = (1 - dJ) / vC
    print(f"    v_c={vC} d_J={dJ}: break-even rg* = (1-d_J)/v_c = {rg_star:.4f};"
          + "".join(f"  rg={r}: {form(r):+.6f}" for r in (1.0, 0.9, 0.75, 0.7)))
    check(f"wall-leak formula = brute force (v_c={vC}, d_J={dJ})", ok)
    check(f"drift vanishes at rg* (v_c={vC}, d_J={dJ})", abs(form(rg_star)) < 1e-12)

# ---------------------------------------------------------------------------
hr("H8. From honesty to intent: effective off-task builder mass (G4.11) and\n"
   "    transfer of honesty training to intent (G4.12).")
pri = {"A": 0.90, "Gc": 0.03, "Gd": 0.04, "Cs": 0.03}
sincere = 0.0
for use in (0.0, 1.0):
    for vF in (0.95, 0.5):
        q_eff = pri["Gd"] + pri["Cs"] + pri["Gc"] * (1 - vF * use)
        print(f"  confessions acted on={use:.0f}, frontier confession acceptance v_c={vF}:"
              f" q_eff = {q_eff:.4f} (raw off-task mass {1 - pri['A']:.2f})")
# honesty training that removes naive deniers only
after = {t: p for t, p in pri.items() if t != "Gd"}
Zs = sum(after.values())
after = {t: p / Zs for t, p in after.items()}
print("  after honesty training removes Gd: " + ", ".join(f"{t} {p:.4f}" for t, p in after.items()))
# transfer coefficient: binary regression slope of intent on honesty (training-visible honesty)
hon = {"A": 1, "Gc": 1, "Gd": 0, "Cs": 1}  # Cs is honest in training
intent = {"A": 1, "Gc": 0, "Gd": 0, "Cs": 0}
P = pri
ph1 = sum(P[t] for t in P if hon[t] == 1)
pa_h1 = sum(P[t] for t in P if hon[t] == 1 and intent[t] == 1) / ph1
pa_h0 = sum(P[t] for t in P if hon[t] == 0 and intent[t] == 1) / (1 - ph1)
print(f"  Tr(intent <- training-visible honesty) = P(A|h=1)-P(A|h=0) = {pa_h1:.4f} - {pa_h0:.4f} = {pa_h1 - pa_h0:.4f}")
check("removing Gd raises intent mass to P(A | h=1)", abs(after["A"] - pa_h1) < 1e-12)
off = 1 - pri["A"]
hvis = pri["Gd"] / off
gain = math.log(after["A"] / (1 - after["A"])) - math.log(pri["A"] / off)
print(f"  share of off-intent mass that is visibly dishonest in training h_vis = {hvis:.3f};"
      f" intent log-odds gain = {gain:.4f} nats; cap -ln(1-h_vis) = {-math.log(1 - hvis):.4f}")
check("gain equals cap when all visible dishonesty is removed", abs(gain + math.log(1 - hvis)) < 1e-12)
print("  Discarding confessed outputs from the data: per gamed output, the retained data's Gd:Gc")
print("  likelihood ratio moves by ln(1/(1 - v_c p_act)).")
for vF, pa in ((0.95, 1.0), (0.95, 0.5), (0.5, 1.0)):
    print(f"    v_c={vF} p_act={pa}: {math.log(1 / (1 - vF * pa)):.3f} nats per gamed output toward deniers")

# ---------------------------------------------------------------------------
hr("H9. Honesty basin (G4.13, conjecture): honest red-teaming keeps the cheapest\n"
   "    unhardened concealment K_c bits deep; G2.6's bank B_T grows like 2^K_c.\n"
   "    Map: K_{k+1} = K_k + rt (1 - q_k) - nr;  q_k = 0 if B_T(K_k) > need, else q rises.")
need = math.log(1 + S_rate * 0.05 * 0.018 * 1e6)
varpi_T = 40.0


def BT(K):
    return S_rate / (varpi_T * 0.5 * 2.0 ** (-K))


Kstar = math.log2(need * varpi_T * 0.5 / S_rate)
print(f"  threshold K* = {Kstar:.2f} bits (n=1e6, varpi_T=40)")
for rH, gb, K0 in [(3.0, 2.0, 8.0), (2.0, 3.0, 12.0), (3.0, 2.0, 6.0)]:
    K, q, traj = K0, 0.0, []
    for kgen in range(15):
        q = 0.0 if BT(K) > need else min(1.0, q + 0.5)
        traj.append((round(K, 1), q))
        K = K + rH * (1 - q) - gb
    fail = next((i for i, (_, qq) in enumerate(traj) if qq > 0), None)
    print(f"  rt={rH} nr={gb} K0={K0}: first generation with concealment winning = {fail};"
          f" K after 15 gens = {traj[-1][0]}")

print("  Finite horizon: with rt < nr the basin is left after about (K0 - K*)/(nr - rt) generations.")
for rH, gb, K0 in [(2.0, 3.0, 12.0), (2.5, 3.0, 12.0)]:
    print(f"    rt={rH} nr={gb} K0={K0}: (K0-K*)/(nr-rt) = {(K0 - Kstar) / (gb - rH):.1f} generations")
print("  K* grows with run length n (bank needed ln(1 + S w q0 n)):")
for n_run in (1e6, 1e7, 1e8, 1e9, 1e12):
    need_n = math.log(1 + S_rate * 0.05 * 0.018 * n_run)
    print(f"    n={n_run:.0e}: K* = {math.log2(need_n * varpi_T * 0.5 / S_rate):.2f} bits")

# ---------------------------------------------------------------------------
hr("H10. Belief capture (G4.4b): H_o vs H with no internals check.\n"
   "    Drift per episode w_D lam+ - w_use lam-; H_o loses iff w_use/w_D > t*/(1-t*).")
for w_use in (0.0, 0.001, 0.0017, 0.005):
    d = wD * lp - w_use * lm
    print(f"  w_use={w_use}: drift {d:+.6f} per episode, {n * d:+.2f} nats per generation"
          f" ({'H_o gains' if d > 0 else 'H gains'}); threshold w_use/w_D = t*/(1-t*) = {ts / (1 - ts):.3f}")

print()
print(f"{len(FAILS)} failed checks" + (": " + ", ".join(FAILS) if FAILS else ""))
