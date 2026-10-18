"""Referee checks for drafts/G3-observability.md.

Run: python3 G3-observability_referee_checks.py > G3-observability_referee_checks_output.txt
Sections R1..R8 are cited in drafts/G3-observability-referee.md.
All parameter values are the draft's illustrative ones unless stated.
"""
import numpy as np
from scipy import stats

rng = np.random.default_rng(7)


def logit(p):
    return np.log(p / (1 - p))


def sig(x):
    return 1 / (1 + np.exp(-x))


# ---------------------------------------------------------------------------
print("R1. Eval table (G3.2 / C2): catches per unit of traffic, and P(caught) at fixed traffic")
auc, t = 0.83, 0.1
dp = np.sqrt(2) * stats.norm.ppf(auc)
N_items = 1e4  # total items the type sees in a generation (illustrative)
for pe in [0.001, 0.01, 0.05, 0.1, 0.3, 0.5]:
    z_t = (logit(t) - logit(pe) + dp ** 2 / 2) / dp
    ev = stats.norm.cdf(z_t - dp)
    dep = stats.norm.cdf(z_t)
    catches_per_item = pe * ev           # hit = 1, fp = 0: every eval-item gaming is a catch
    exp_catches = N_items * catches_per_item
    p_caught = 1 - np.exp(-exp_catches)
    dmg_per_catch = (1 - pe) * dep / catches_per_item
    print(f"   pe={pe:5.3f}: games on {ev:.3f} of evals, {dep:.3f} of deployment; catches per traffic item"
          f" {catches_per_item:.2e}; expected catches in {N_items:.0e} items {exp_catches:7.1f};"
          f" P(at least one) {p_caught:.3f}; deployment gaming per catch {dmg_per_catch:7.1f}")
print("   -> catches per traffic item are non-monotone in pe (peak near pe ~ 0.1);"
      " with fp = 0 a single catch is decisive, so the type is caught w.p. ~1 at every pe >= 0.01 here.")

# ---------------------------------------------------------------------------
print("\nR2. CUSUM with a fixed alternative vs a defector below the reference value (G3.4)")
fp, dy_design, n_dep, K = 1e-4, 1e-4, 1e5, 30
dbar = 0.05
Omega = np.log(K * n_dep / 0.05)
B = 1000
l0 = fp * B
l1 = (fp + dy_design) * B
a, b = np.log(l1 / l0), l1 - l0
ref = b / a / B - fp   # excess flag rate per item at which drift is zero
print(f"   design alternative excess {dy_design:.1e}/item; zero-drift excess (reference value) = {ref:.2e}/item; Omega = {Omega:.2f}")


def run(dy, n_batches):
    lam = (fp + dy) * B
    W = 0.0
    c = rng.poisson(lam, size=n_batches)
    for i, ci in enumerate(c):
        W = max(0.0, W + ci * a - b)
        if W >= Omega:
            return i + 1
    return None


nb = int(K * n_dep / B)
for dy in [1e-4, 6e-5, 4e-5, 3e-5, 2e-5]:
    reps = 200
    hits = 0
    dmg = []
    for _ in range(reps):
        r = run(dy, nb)
        if r is not None:
            hits += 1
            items = r * B
        else:
            items = K * n_dep
        p_def = dy / dbar
        dmg.append(items * p_def * (1 - dbar))
    print(f"   defector excess {dy:.1e}/item (p_def = {dy/dbar:.4f}): P(alarm within K=30 gens) = {hits/reps:.2f};"
          f" mean unflagged defections before alarm or horizon = {np.mean(dmg):.0f}")
print("   -> below the reference value the CUSUM essentially never alarms; damage over the horizon is"
      " linear in K n_dep, not Omega/vis. Use a GLR / mixture CUSUM or a bank of references.")

# ---------------------------------------------------------------------------
print("\nR3. C3 fp = 1e-3 row: predicted delay vs horizon")
fp3, dy3 = 1e-3, 1e-4
kl = (fp3 + dy3) * np.log(1 + dy3 / fp3) - dy3
delay_items = Omega / kl
horizon_dmg = K * n_dep * (dy3 / dbar) * (1 - dbar)
print(f"   delay = {delay_items/n_dep:.1f} generations > K = {K}; total unflagged defections over the whole horizon = {horizon_dmg:.0f}"
      f" < the tabulated 7,029 'before alarm'")
l0 = fp3 * B; l1 = (fp3 + dy3) * B
a3, b3 = np.log(l1 / l0), l1 - l0
reps, hits = 200, 0
for _ in range(reps):
    W = 0.0
    c = rng.poisson((fp3 + dy3) * B, size=nb)
    for ci in c:
        W = max(0.0, W + ci * a3 - b3)
        if W >= Omega:
            hits += 1
            break
print(f"   MC: P(alarm within 30 generations) = {hits/reps:.2f}")

# ---------------------------------------------------------------------------
print("\nR4. G3.4a: a stable off-task lineage is not invisible to a raw disagreement statistic")
pA = np.array([0.98, 0.02])       # A: near-deterministic answers
pX = np.array([0.80, 0.20])       # X: off task, noisier, same lineage at k and k+1
disA = 1 - (pA ** 2).sum()
disX = 1 - (pX ** 2).sum()
print(f"   disagreement rate (A,A) = {disA:.3f}; (X,X) = {disX:.3f}: differs although theta_k = theta_k+1."
      " Zero evidence holds only for a change-point test whose baseline is the lineage's own history.")

# ---------------------------------------------------------------------------
print("\nR5. G3.7: false flags (T2.1') shift the deterrence condition")
gF, kF, a_r, hit = 1.0, 20.0, 0.1, 0.8
tF = gF / (gF + kF)
for rho0 in [0.0, 0.05, 0.2]:
    # rollback probability on compliance rho0 (false flags); on targeted defection 1-(1-rho0)(1-P)
    # payoff difference: defect - comply = gF(1 - P_tot) - kF P_tot - [ -kF rho0 ]  (irr = 0, gain lost on rollback)
    def need():
        lo, hi = 0.0, 1.0
        for _ in range(60):
            m = (lo + hi) / 2
            P = a_r * hit * m
            Ptot = 1 - (1 - rho0) * (1 - P)
            diff = gF * (1 - Ptot) - kF * Ptot + kF * rho0
            if diff > 0:
                lo = m
            else:
                hi = m
        return hi
    print(f"   rollback prob on compliant work rho0 = {rho0:.2f}: minimal tr*p_hon = {need():.3f}"
          f" (draft, rho0 = 0: {tF/(a_r*hit):.3f})")
print("   -> unchanged: rollbacks from false flags independent of defection multiply both payoffs by (1-rho0)."
      " False flags act on G3.7 only through p_hon (designer reluctance), not through t*_F as in T2.1'.")

# ---------------------------------------------------------------------------
print("\nR6. G3.8: base case matters. Trusted terminal auditor, and infinite-horizon multiplicity")
tcol = tF
for ocol in [0.2, 0.5, 0.9]:
    one_step = a_r * hit * 1.0 * (1 - ocol) >= tcol
    full_if_trusted_terminal = a_r * hit * 1.0 >= tcol   # tr_{K-1} = 1, same hit at the terminal step
    print(f"   o_col={ocol}: G3.8 full trust (untrusted terminal) = {one_step};"
          f" with trusted terminal auditor of equal hit = {full_if_trusted_terminal};"
          f" infinite horizon: tr=1 is an equilibrium = {a_r*hit >= tcol}, tr=1-o_col is an equilibrium = {not one_step}")
for hit_term in [0.8, 0.3, 0.05]:
    print(f"   trusted terminal auditor with hit {hit_term}: chain fully trusted iff a_r*hit_term*p_hon >= t* -> {a_r*hit_term >= tcol}")

# ---------------------------------------------------------------------------
print("\nR7. G3.9(3): non-stationary backward induction vs the closed-form k_x")
corr, ph = 0.2, 1.0
o_dag = 1 - tF / (a_r * hit * ph * (1 - corr))
L_dag = np.log((1 - o_dag) / o_dag)
L0, net, Kc = 4.0, -0.3, 30
L = L0 + net * np.arange(Kc + 2)
o = sig(-L)
ocol = o + corr * (1 - o)       # use the auditor's (generation k+1) off-task prob for k's auditor
# tr[k] = truthfulness of k+1 auditing k; colluder at k+1 has its own collusion prob with auditor k+2
tr = np.zeros(Kc)
tr[Kc - 1] = 1 - ocol[Kc]
for k in range(Kc - 2, -1, -1):
    tr[k] = 1.0 if a_r * hit * ph * tr[k + 1] >= tF else 1 - ocol[k + 1]
deterred = a_r * hit * ph * tr >= tF
first_bad = int(np.argmin(deterred)) if not deterred.all() else None
kx = int(np.ceil((L0 - L_dag) / (-net)))
print(f"   o_dagger = {o_dag:.3f}, L_dagger = {L_dag:.2f}; closed-form k_x = {kx}; first undeterred generation"
      f" under non-stationary backward induction (auditor's o at k+1) = {first_bad}")
# with o_col indexed at the auditee's k (as the draft does)
tr2 = np.zeros(Kc)
tr2[Kc - 1] = 1 - ocol[Kc - 1]
for k in range(Kc - 2, -1, -1):
    tr2[k] = 1.0 if a_r * hit * ph * tr2[k + 1] >= tF else 1 - ocol[k]
det2 = a_r * hit * ph * tr2 >= tF
print(f"   same with o_col at the auditee's index: first undeterred = {int(np.argmin(det2)) if not det2.all() else None}")
print("   undeterred pattern (1 = deterred), auditor-indexed:", "".join(str(int(x)) for x in deterred))

# ---------------------------------------------------------------------------
print("\nR8. G3.5 at small n*fp: the chi-square/Pinsker bound vs the exact fp = 0 case")
for fp5, n5 in [(1e-5, 1e5), (1e-6, 1e5), (0.0, 1e5)]:
    db = 0.05
    dpow = 0.25
    if fp5 > 0:
        bound = dpow * np.sqrt(2 * n5 * fp5 / (1 - fp5)) * (1 - db) / db
    else:
        bound = 0.0
    # exact: with fp=0, the defector keeps P(any flag) <= dpow by making m defections with 1-(1-db)^m <= dpow
    m = np.log(1 - dpow) / np.log(1 - db)
    print(f"   fp={fp5:.0e}, n={n5:.0e}: G3.5 guarantee {bound:6.1f} unflagged defections; exact fp=0 benchmark"
          f" {m*(1-db):.1f} (bound is loose when n*fp <~ 1)")
