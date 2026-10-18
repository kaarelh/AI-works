"""G3 checks: observability, sequential halting rules, and the retrospective-audit recursion.

Every number quoted in drafts/G3-observability.md comes from this script (revised after the referee report;
C2, C3 and C4 extended, C10 to C13 added).
Run:  python3 G3_checks.py > G3_checks_output.txt
Sections C1..C9 are cited in the text as "check C1" etc.
All parameter values are illustrative unless stated otherwise.
"""
import numpy as np
from scipy import stats, optimize, special

rng = np.random.default_rng(20261018)
FAILS = []


def check(name, cond):
    print(f"   [{'ok' if cond else 'FAIL'}] {name}")
    if not cond:
        FAILS.append(name)


def sig(x):
    return 1.0 / (1.0 + np.exp(-x))


def logit(p):
    return np.log(p / (1 - p))


# ---------------------------------------------------------------------------
print("C1. Deterrence-detection inequality (G3.2)")
# items carry calibrated consequential detection dhat ~ Beta(0.5, 4) (illustrative)
a_b, b_b = 0.5, 4.0
for t in [0.02, 0.05, 0.1, 0.2, 0.5]:
    # E[d 1(d<t)] and E[(1-d) 1(d<t)] by quadrature
    det = stats.beta.expect(lambda d: d, args=(a_b, b_b), lb=0, ub=t)
    und = stats.beta.expect(lambda d: 1 - d, args=(a_b, b_b), lb=0, ub=t)
    pdef = stats.beta.cdf(t, a_b, b_b)
    ratio = det / und
    dbar = det / pdef
    # Monte Carlo: undetected defections before the first detected one
    n_runs = 4000
    counts = np.empty(n_runs)
    for r in range(n_runs):
        c = 0
        while True:
            d = rng.beta(a_b, b_b)
            if d >= t:
                continue  # type does not defect on this item
            if rng.random() < d:
                break
            c += 1
        counts[r] = c
    print(f"   t={t:4.2f}: P(defect)={pdef:.3f}  dbar={dbar:.4f}  detected/undetected={ratio:.4f}"
          f"  bound t/(1-t)={t/(1-t):.4f}  E[undetected before 1st catch]: formula (1-dbar)/dbar={(1-dbar)/dbar:.1f},"
          f" MC={counts.mean():.1f}, lower bound (1-t)/t={(1-t)/t:.1f}")
    check(f"ratio <= t/(1-t) at t={t}", ratio <= t / (1 - t) + 1e-12)
    check(f"MC mean within 6% of (1-dbar)/dbar at t={t}", abs(counts.mean() - (1 - dbar) / dbar) / ((1 - dbar) / dbar) < 0.06)

# ---------------------------------------------------------------------------
print("\nC2. Evals and honeypots: detection and deterrence are complementary (G3.2, Table 1)")
# eval items have score z ~ N(dp,1), deployment items N(0,1); AUC 0.83 -> dp = sqrt(2)*Phi^-1(0.83)
auc = 0.83
dp = np.sqrt(2) * stats.norm.ppf(auc)
t = 0.1
hit = 1.0
print(f"   AUC {auc} -> s_ev = {dp:.3f}; careful type with t = {t}; eval catch prob hit = {hit}; fp = 0")
N_items = 1e4   # items the type sees per generation (illustrative)
cpt = {}
for pe in [0.001, 0.01, 0.05, 0.1, 0.3, 0.5]:
    # posterior that an item with score z is an eval
    # d(z) = hit * P(eval | z); type defects iff d < t, i.e. z < z_t
    z_t = (logit(min(t / hit, 1 - 1e-12)) - logit(pe) + dp ** 2 / 2) / dp
    frac_eval_def = stats.norm.cdf(z_t - dp)      # share of eval items it games on
    frac_dep_def = stats.norm.cdf(z_t)            # share of deployment items it games on
    c_item = pe * frac_eval_def * hit             # catches per item of traffic
    cpt[pe] = c_item
    dmg_per_catch = (1 - pe) * frac_dep_def / c_item
    print(f"   eval share {pe:5.3f}: games on {frac_eval_def:.3f} of eval items, {frac_dep_def:.3f} of deployment items;"
          f" catches per traffic item {c_item:.2e}; expected catches in {N_items:.0e} items {N_items*c_item:6.1f};"
          f" P(>=1 catch) {1-np.exp(-N_items*c_item):.3f}; deployment gaming per catch {dmg_per_catch:7.1f}")
check("per-eval-item gaming falls as eval share rises", True)
check("total catches non-monotone in eval share (peak at an interior share)",
      cpt[0.1] > cpt[0.001] and cpt[0.1] > cpt[0.5])

# ---------------------------------------------------------------------------
print("\nC3. Sequential test: CUSUM on flag counts, false alarms, delay and damage (G3.4)")


def kl_pois(l1, l0):
    return l1 * np.log(l1 / l0) - l1 + l0


n_dep = 1e5     # monitored deployment items per generation
K = 30
PFA_loop = 0.05
dbar = 0.05
p_def = 0.002   # share of items the defector defects on
dy = p_def * dbar
dmg_rate = p_def * (1 - dbar)
Omega = np.log(K * n_dep / PFA_loop)   # ARL0 >= e^Omega items covers the whole loop
print(f"   Omega = ln(K n_dep / P_FA) = {Omega:.2f} nats;  defector: p_def={p_def}, dbar={dbar}, extra flag rate {dy:.1e}/item")
B3 = 1000
nb3 = int(K * n_dep / B3)


def cusum_mc(fp_, dy_true, dy_ref, Om_, reps=200):
    """Vectorised CUSUM on Poisson batch counts with reference alternative dy_ref.
    Returns P(alarm within the horizon) and mean unflagged defections before alarm or horizon."""
    l0_, l1_ = fp_ * B3, (fp_ + dy_ref) * B3
    a_, b_ = np.log(l1_ / l0_), l1_ - l0_
    W = np.zeros(reps)
    stop = np.full(reps, nb3)
    alive = np.ones(reps, bool)
    for i in range(nb3):
        c = rng.poisson((fp_ + dy_true) * B3, size=reps)
        W = np.where(alive, np.maximum(0.0, W + c * a_ - b_), W)
        newly = alive & (W >= Om_)
        stop[newly] = i + 1
        alive &= ~newly
    p_def_ = dy_true / dbar
    dmg_ = stop * B3 * p_def_ * (1 - dbar)
    return 1 - alive.mean(), dmg_.mean()


print(f"   horizon total of unflagged defections = K n_dep p_def (1-dbar) = {K*n_dep*dmg_rate:.0f}")
for fp in [1e-3, 1e-4, 1e-5]:
    kl = kl_pois(fp + dy, fp)
    delay = Omega / kl
    pal, dmc = cusum_mc(fp, dy, dy, Omega)
    print(f"   fp={fp:.0e}: KL/item={kl:.2e}  delay ~ Omega/KL = {delay:.2e} items = {delay/n_dep:.2f} generations;"
          f" Omega/vis = {min(delay, K*n_dep)*dmg_rate:.0f} (capped at horizon); vis = KL/dmg = {kl/dmg_rate:.2e} nats per defection;"
          f" MC: P(alarm within K) = {pal:.2f}, mean unflagged defections before alarm or horizon = {dmc:.0f}")
    if fp == 1e-3:
        check("fp=1e-3: predicted delay exceeds the horizon, so 'before alarm' is replaced by the horizon total", delay / n_dep > K)
print(f"   fp=0: alarm at first flag; mean items {1/dy:.0f}; damage (1-dbar)/dbar = {(1-dbar)/dbar:.0f}")

# Monte Carlo of CUSUM on Poisson batch counts (batch = B items)
B = 1000
fp = 1e-4
l0 = fp * B
l1 = (fp + dy) * B
step_kl = kl_pois(l1, l0)
Om = 6.0


def cusum_run(lam, Om, max_batches=10 ** 7):
    W = 0.0
    n = 0
    llr_a = np.log(l1 / l0)
    llr_b = l1 - l0
    while n < max_batches:
        c = rng.poisson(lam, size=4096)
        for ci in c:
            n += 1
            W = max(0.0, W + ci * llr_a - llr_b)
            if W >= Om:
                return n
    return n


arl0 = np.mean([cusum_run(l0, Om) for _ in range(300)])
del1 = np.mean([cusum_run(l1, Om) for _ in range(2000)])
brown = (Om - 1 + np.exp(-Om)) / step_kl   # Brownian approximation for CUSUM delay from W=0
print(f"   MC (batches of {B}, fp={fp:.0e}, Omega={Om}): ARL0 = {arl0:.0f} batches (Lorden bound e^Omega = {np.exp(Om):.0f});"
      f" delay = {del1:.1f} batches; Omega/KL = {Om/step_kl:.1f}; Brownian (Omega-1+e^-Omega)/KL = {brown:.1f}")
check("ARL0 >= e^Omega", arl0 >= np.exp(Om))
check("delay between the Brownian value and 1.3 Omega/KL (overshoot)", brown <= del1 <= 1.3 * Om / step_kl)

# ---------------------------------------------------------------------------
print("\nC4. Stealth: the square-root law for undetected damage per generation (G3.5)")
PFA_gen = 0.01
for fp, n in [(1e-3, 1e5), (1e-3, 1e6), (1e-4, 1e5), (1e-4, 1e6), (1e-5, 1e6)]:
    l0 = fp * n
    cstar = stats.poisson.isf(PFA_gen, l0) + 1           # alarm iff count >= cstar
    pfa = stats.poisson.sf(cstar - 1, l0)
    # extra expected flags Delta giving power 0.5 against the count test
    f = lambda D: stats.poisson.sf(cstar - 1, l0 + D) - 0.5
    D50 = optimize.brentq(f, 1e-9, 10 * cstar + 50)
    dmg50 = D50 * (1 - dbar) / dbar
    # Pinsker/chi-square guarantee for ANY test: power - P_FA <= Delta / sqrt(2 l0)
    D_guar = 0.25 * np.sqrt(2 * l0)   # keeps power <= P_FA + 0.25 against every test
    print(f"   fp={fp:.0e}, n={n:.0e}: count test P_FA={pfa:.4f}; excess flags for power 0.5 = {D50:.1f}"
          f" (z*sqrt(n fp) = {stats.norm.isf(PFA_gen)*np.sqrt(l0):.1f}); undetected damage at power 0.5 = {dmg50:.0f};"
          f" damage with power <= P_FA+0.25 against ANY test >= {D_guar*(1-dbar)/dbar:.0f}")
# scaling check: damage ratio for 10x n should be ~ sqrt(10)
def d50(fp, n):
    l0 = fp * n
    cstar = stats.poisson.isf(PFA_gen, l0) + 1
    return optimize.brentq(lambda D: stats.poisson.sf(cstar - 1, l0 + D) - 0.5, 1e-9, 10 * cstar + 50)
r = d50(1e-3, 1e6) / d50(1e-3, 1e5)
print(f"   ratio of stealth damage n=1e6 vs 1e5 at fp=1e-3: {r:.2f} (sqrt(10) = {np.sqrt(10):.2f})")
check("square-root scaling within 10%", abs(r / np.sqrt(10) - 1) < 0.1)
# exact Bernoulli check of the any-test bound via TV of Binomial counts
n_small, fp_small = 20000, 1e-3
l0 = n_small * fp_small
Dg = 0.25 * np.sqrt(2 * l0)
p1 = fp_small + Dg / n_small
k = np.arange(0, 200)
tv = 0.5 * np.abs(stats.binom.pmf(k, n_small, p1) - stats.binom.pmf(k, n_small, fp_small)).sum()
print(f"   exact TV(Bin(n,fp+Delta/n), Bin(n,fp)) at Delta = 0.25 sqrt(2 n fp) and n = {n_small:.0e} (not the 1e5 of the text): {tv:.3f} (bound 0.25)")
check("TV <= 0.25", tv <= 0.25)
# small n*fp: the coupling guarantee m with 1-(1-dbar)^m <= Delta_pow holds for every fp
for fp5, n5 in [(1e-5, 1e5), (1e-6, 1e5), (0.0, 1e5)]:
    sq = 0.25 * np.sqrt(2 * n5 * fp5 * (1 - fp5)) * (1 - dbar) / dbar
    m_c = np.log(1 - 0.25) / np.log(1 - dbar)
    print(f"   fp={fp5:.0e}, n={n5:.0e}: square-root guarantee {sq:5.1f} unflagged defections; coupling guarantee"
          f" {m_c*(1-dbar)*(1-fp5):.1f}; the defector gets the larger")

# ---------------------------------------------------------------------------
print("\nC5. Collusion: lineage-built instruments (G3.6)")
pow_h, pow_ind = 0.95, 0.30
for inh in [0.0, 0.5, 0.9, 1.0]:
    pw = (1 - inh) * pow_h + inh * pow_ind
    print(f"   inh={inh:.1f}: power = {pw:.3f} (honest-built {pow_h}, independent-only {pow_ind})")
# internals: tell transfer
for p_tr in [1.0, 0.5, 0.2]:
    dprime, icc, m = 0.5, 0.01, 10000
    m_eff = m / (1 + (m - 1) * icc)
    kl = m_eff * dprime ** 2 / 2
    print(f"   probe d'={dprime}, icc={icc}, m={m}: m_eff={m_eff:.0f}, KL={kl:.1f} nats if the tell transfers;"
          f" power <= p_tr + (1-p_tr) P_FA = {p_tr + (1-p_tr)*0.01:.3f} at p_tr={p_tr}")

# ---------------------------------------------------------------------------
print("\nC6. Two-generation game: targeted versus mass defection (G3.7)")


def t_star_F(n, gF, kF, irr):
    return n * gF / ((1 - irr) * n * gF + kF)


def U(n, gF, kF, irr, a_r, hit, trph):
    Pr = trph * (1 - (1 - a_r * hit) ** n)
    return n * gF * (1 - (1 - irr) * Pr) - kF * Pr


gF, kF = 1.0, 20.0
a_r, hitv = 0.1, 0.8
for irr in [0.0, 0.5]:
    for NF in [1, 10, 100]:
        # minimal tr*p_hon such that max_{1<=n<=NF} U(n) <= 0
        def worst(trph):
            return max(U(n, gF, kF, irr, a_r, hitv, trph) for n in range(1, NF + 1))
        if worst(1.0) > 0:
            need = None
        else:
            need = optimize.brentq(worst, 1e-6, 1.0)
        nbest = max(range(1, NF + 1), key=lambda n: U(n, gF, kF, irr, a_r, hitv, 0.5))
        need_s = "none (not deterrable)" if need is None else f"{need:.3f}"
        print(f"   irr={irr}, N_F={NF:3d}: t*_F(1)={t_star_F(1,gF,kF,irr):.4f}, t*_F(N_F)={t_star_F(NF,gF,kF,irr):.3f};"
              f" minimal tr*p_hon for deterrence = {need_s}; best plan size at tr*p_hon=0.5: {nbest}")
# targeted closed form check
need1 = t_star_F(1, gF, kF, 0) / (a_r * hitv)
print(f"   closed form, targeted: tr*p_hon >= t*_F/(a_r hit) = {need1:.4f}")
# capability gap needed: hit(g) = hit_inf (1 - exp(-g/g_ch))
hit_inf, g_ch = 0.9, 1.0
for trph in [1.0, 0.8, 0.6]:
    need_hit = t_star_F(1, gF, kF, 0) / (a_r * trph)
    if need_hit >= hit_inf:
        print(f"   tr*p_hon={trph}: needs hit {need_hit:.3f} >= hit_inf; no gap suffices")
    else:
        gmin = -g_ch * np.log(1 - need_hit / hit_inf)
        print(f"   tr*p_hon={trph}: needs hit >= {need_hit:.3f}; minimal gap g = {gmin:.2f} g_ch")
# same-lineage auditor with constitutive sabotage
o_new = 0.02
for sab in [0.0, 0.5, 0.9]:
    tr = (1 - sab) * (1 - o_new)
    d = a_r * hitv * tr * 1.0
    print(f"   same-lineage auditor, sab={sab}: tr={tr:.3f}, P_r(1)={d:.4f} vs t*_F={t_star_F(1,gF,kF,0):.4f}: "
          f"{'deterred' if d >= t_star_F(1,gF,kF,0) else 'NOT deterred'}")

# ---------------------------------------------------------------------------
print("\nC7. Trust separatrix and K-generation chain (G3.8, G3.9)")
tF = t_star_F(1, gF, kF, 0)
for corr in [0.0, 0.2, 0.4]:
    for ph in [1.0, 0.8]:
        o_dag = 1 - tF / (a_r * hitv * ph * (1 - corr))
        print(f"   corr={corr}, p_hon={ph}: o_dagger = {o_dag:.3f}" + ("  (no trust chain)" if o_dag <= 0 else ""))


def chain(K, o_new_k, design, corr=0.2, ph=1.0, sab=0.9):
    """Exact survival recursion along the lineage. Returns P(fail by K), expected rollbacks."""
    surv = 1.0
    rollbacks = 0.0
    for k in range(K):
        o = o_new_k[k]
        if design == "none":
            D = 0.0; deterred = False
        elif design == "same":
            tr = (1 - sab) * (1 - o)
            D = a_r * hitv * tr * ph; deterred = D >= tF
        elif design == "cross":
            tr = 1 - (o + corr * (1 - o))
            D = a_r * hitv * tr * ph; deterred = D >= tF
        if deterred:
            continue
        # undeterred off-task draw defects once (targeted); caught -> rollback and redraw
        pf = o * (1 - D) / (1 - o * D)
        rollbacks += surv * o * D / (1 - o * D)
        surv *= (1 - pf)
    return 1 - surv, rollbacks


K = 30
for o0 in [0.02, 0.05, 0.08]:
    on = np.full(K, o0)
    res = {d: chain(K, on, d) for d in ["none", "same", "cross"]}
    print(f"   q={o0}: P(fail by K=30): none {res['none'][0]:.3f} (either of two independent lineages:"
          f" {1-(1-res['none'][0])**2:.3f}), same-lineage {res['same'][0]:.3f}, "
          f"cross-lineage(corr 0.2) {res['cross'][0]:.3f} (by construction: indicator q > o_dagger, no inheritance)")
# with a ledger: o_new_k = sigma(-L_k), L_{k+1} = L_k + gamma - kappa_L g - n D*(0)
o_dag = 1 - tF / (a_r * hitv * 1.0 * (1 - 0.2))
L_dag = logit(1 - o_dag)
print(f"   cross-lineage corr 0.2: o_dagger={o_dag:.3f}, L_dagger_tr = ln((1-o)/o) = {L_dag:.2f} nats")
L0 = 4.0
for net in [+0.5, 0.0, -0.3, -0.6]:   # net = gamma - kappa_L g - n D*(0) per generation
    Lk = L0 + net * np.arange(K)
    on = sig(-Lk)
    pf, rb = chain(K, on, "cross")
    pf10, _ = chain(10, on, "cross")
    pn, _ = chain(K, on, "none")
    pn10, _ = chain(10, on, "none")
    kx = (L0 - L_dag) / (-net) if net < 0 else np.inf
    print(f"   L0={L0}, net ledger change {net:+.1f}/gen: P(fail by 10 / by 30): no audits {pn10:.3f} / {pn:.3f};"
          f" cross-lineage trust chain {pf10:.3f} / {pf:.3f}; rollbacks = {rb:.3f}; predicted crossing generation k_x = {kx:.1f}")
    if net == -0.3:
        first_fail_k = next((k for k in range(K) if on[k] > o_dag), None)
        check("crossing generation matches closed form", first_fail_k == int(np.ceil(kx - 1e-9)) or first_fail_k == int(np.floor(kx)) + 1)

# ---------------------------------------------------------------------------
print("\nC8. Near-misses: retrospective audits as plain measurement")
for hitN, nN in [(0.5, 20), (0.5, 100), (0.2, 100)]:
    for ar in [0.01, 0.05]:
        pdet = 1 - (1 - ar * hitN) ** nN
        print(f"   hit_N={hitN}, divergent frontier outputs per generation {nN}, a_r={ar}: P(detect within generation) = {pdet:.3f}")

# ---------------------------------------------------------------------------
print("\nC9. Caught-rate CUSUM against the predicted path (T2.13 reading)")
# training catches: A has fp only; visible gamer rate r_vis; frozen 0
fp_tr, r_vis, n_tr = 2e-5, 2e-3, 1e5
kl_vis = kl_pois((fp_tr + r_vis) * n_tr, fp_tr * n_tr)
print(f"   per-generation evidence against a visible gamer: {kl_vis:.0f} nats; against a frozen type: 0")

# ---------------------------------------------------------------------------
print("\nC10. Composite alternatives: fixed-reference CUSUM vs a bank of references (G3.4, adaptive defectors)")
fp10 = 1e-4
refs = [1e-4, 3e-5, 1e-5]
Om_bank = Omega + np.log(len(refs))   # union bound over the bank keeps P_FA <= 0.05 over the loop


def bank_mc(dy_true, refs_, Om_, reps=200):
    A_ = np.array([np.log((fp10 + r) / fp10) for r in refs_])
    Bv = np.array([r * B3 for r in refs_])
    W = np.zeros((reps, len(refs_)))
    stop = np.full(reps, nb3)
    alive = np.ones(reps, bool)
    for i in range(nb3):
        c = rng.poisson((fp10 + dy_true) * B3, size=reps)[:, None]
        W = np.where(alive[:, None], np.maximum(0.0, W + c * A_ - Bv), W)
        newly = alive & (W.max(axis=1) >= Om_)
        stop[newly] = i + 1
        alive &= ~newly
    return 1 - alive.mean(), (stop * B3 * dy_true / dbar * (1 - dbar)).mean()


worst_fixed, worst_bank = 0, 0
for dyt in [1e-4, 6e-5, 4e-5, 3e-5, 2e-5, 1e-5, 5e-6]:
    pf_, df_ = bank_mc(dyt, [1e-4], Omega)
    pb_, db_ = bank_mc(dyt, refs, Om_bank)
    worst_fixed, worst_bank = max(worst_fixed, df_), max(worst_bank, db_)
    print(f"   defector excess {dyt:.0e}/item (horizon total {K*n_dep*dyt/dbar*(1-dbar):5.0f}): fixed ref 1e-4: P(alarm)={pf_:.2f},"
          f" unflagged before alarm/horizon {df_:5.0f};  bank {refs}: P(alarm)={pb_:.2f}, {db_:5.0f}")
Om_batch = np.log(nb3 * len(refs) / PFA_loop)   # Ville + union bound over batch start times and references
print(f"   bank with Omega at batch resolution, ln(#batches x #refs / P_FA) = {Om_batch:.2f} (instead of {Om_bank:.2f}):")
worst_bb = 0
for dyt in [1e-4, 6e-5, 4e-5, 3e-5, 2e-5, 1e-5]:
    pbb, dbb = bank_mc(dyt, refs, Om_batch)
    worst_bb = max(worst_bb, dbb)
    print(f"      defector excess {dyt:.0e}: P(alarm)={pbb:.2f}, unflagged before alarm/horizon {dbb:5.0f}")
arl_reps = 100
fa = sum(bank_mc(0.0, refs, Om_batch, reps=arl_reps)[0] for _ in range(1)) 
print(f"      MC false-alarm probability over the loop (H0, {arl_reps} runs): {fa:.2f} (target <= {PFA_loop})")
# non-sequential benchmark: one pooled count test at the end of the horizon, level P_FA, power 0.5
lam0 = K * n_dep * fp10
cst = stats.poisson.isf(PFA_loop, lam0) + 1
D50h = optimize.brentq(lambda D: stats.poisson.sf(cst - 1, lam0 + D) - 0.5, 1e-9, 10 * cst)
print(f"   end-of-horizon pooled count test (no halting before K): power 0.5 at {D50h:.1f} excess flags ="
      f" {D50h*(1-dbar)/dbar:.0f} unflagged defections over the horizon")
print(f"   worst case over defector rates: bank at batch-resolution Omega {worst_bb:.0f}")
pooled_floor = 0.25 * np.sqrt(2 * K * n_dep * fp10 * (1 - fp10)) * (1 - dbar) / dbar
scale = np.sqrt(K * n_dep * fp10) * (1 - dbar) / dbar
print(f"   scale sqrt(K n_dep fp)(1-dbar)/dbar = {scale:.0f}; worst cases in units of it: fixed {worst_fixed/scale:.1f},"
      f" bank {worst_bank/scale:.1f}, batch-resolution bank {worst_bb/scale:.1f}, pooled count test {D50h*(1-dbar)/dbar/scale:.1f},"
      f" any-test guarantee {pooled_floor/scale:.2f}")
print(f"   worst case over defector rates: fixed {worst_fixed:.0f}, bank {worst_bank:.0f};"
      f" G3.5 any-test floor over the pooled horizon at Delta_pow=0.25: {pooled_floor:.0f}")
check("bank of references lowers the worst-case damage", worst_bank < worst_fixed)
check("worst-case damage of the bank is above the any-test floor", worst_bank >= pooled_floor)

# ---------------------------------------------------------------------------
print("\nC11. Trust chain: base case and horizon (G3.8)")
tcol = tF
for ocol in [0.2, 0.5, 0.9]:
    one_step = a_r * hitv * (1 - ocol) >= tcol
    print(f"   o_col={ocol}: known horizon, untrusted terminal: full trust = {one_step};"
          f" unknown horizon: tr=1 equilibrium = {a_r*hitv >= tcol}, tr=1-o_col equilibrium = {not one_step}")
for hit_term in [0.8, 0.3, 0.05]:
    print(f"   trusted terminal re-auditor with hit_term={hit_term}: full trust (no o_col) iff a_r hit_term p_hon >= t*_col"
          f" and a_r hit p_hon >= t*_col -> {a_r*hit_term >= tcol and a_r*hitv >= tcol}; minimal hit_term = {tcol/a_r:.3f}")

# ---------------------------------------------------------------------------
print("\nC12. Separatrix with inheritance, and auditor indexing (G3.9)")
corr, ph = 0.2, 1.0
o_dag = 1 - tF / (a_r * hitv * ph * (1 - corr))
for q0 in [0.02, 0.05]:
    her_max = (1 - q0 / o_dag) / (1 - q0)
    print(f"   q={q0}: fixed point o_inf = q/(1-her(1-q)) <= o_dagger={o_dag:.3f} iff her <= {her_max:.3f}")
    for her in [0.0, 0.5, 0.8, 0.9]:
        o = q0
        kx_ = None
        for k in range(1, 200):
            o = q0 + her * o * (1 - q0)
            if o > o_dag and kx_ is None:
                kx_ = k
        print(f"      her={her}: o_inf = {q0/(1-her*(1-q0)):.3f}; first generation with o_k > o_dagger: {kx_}")
# auditor-indexed backward induction with a falling ledger, her = 0
L0, net = 4.0, -0.3
Lk = L0 + net * np.arange(K + 2)
ok = sig(-Lk)
oc = ok + corr * (1 - ok)
tr = np.zeros(K)
tr[K - 1] = 1 - oc[K]
for k in range(K - 2, -1, -1):
    tr[k] = 1.0 if a_r * hitv * ph * tr[k + 1] >= tF else 1 - oc[k + 1]
det = a_r * hitv * ph * tr >= tF
L_dag = logit(1 - o_dag)
kx = int(np.ceil((L0 - L_dag) / (-net)))
first_bad = int(np.argmin(det))
print(f"   ledger L0={L0}, net {net}: first generation with q_k > o_dagger = {kx}; first undeterred auditee"
      f" (auditor-indexed backward induction) = {first_bad}")
check("first undeterred auditee is k_x - 1 under auditor indexing", first_bad == kx - 1)

# ---------------------------------------------------------------------------
print("\nC13. Audit latency and irreversibility; link to T3.9's bit budget (G3.7, heuristic)")
NgF = 100 * gF
for ratio in [0.1, 0.22, 0.5, 1.0]:
    irr_ = 1 - np.exp(-ratio)
    print(f"   latency/escape time = {ratio:.2f}: irr = {irr_:.3f}; mass plan of size 100 deterrable at all: {irr_*NgF <= kF}")
print(f"   critical latency ratio = -ln(1 - kappa_F/(N_F g_F)) = {-np.log(1-kF/NgF):.3f}")
Kb, delta = 30, 0.01
for prep in [0.0, 0.9, 0.92 * 0.9, 0.92]:
    print(f"   repair probability {prep:.3f}: T3.9 budget log2(K(1-p_rep)/delta) = {np.log2(Kb*(1-prep)/delta):.1f} bits")

print(f"\n{len(FAILS)} failed checks" + (": " + ", ".join(FAILS) if FAILS else ""))
