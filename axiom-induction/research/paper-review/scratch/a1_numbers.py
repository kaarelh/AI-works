"""a1 (review, math A): independent recomputation of closed-form numbers in
sections model / ident / sound and their appendices.  Seeded; writes a1_numbers.out next to itself."""
import math
import numpy as np
from scipy.special import gammaln

out = []
def p(*a):
    s = " ".join(str(x) for x in a)
    print(s); out.append(s)

# ---- 1. c_{K,alpha} and Table tab:ident:c2 predictions (Prop ident:splitlzero) ----
def cKa(K, a):
    return gammaln(K * a) - K * gammaln(a) + (K - 1) / 2 * math.log(2 * math.pi)
K, a = 4, 0.5
p("c_{4,1/2} =", round(cKa(K, a), 4))
pvec = np.array([.5, .3, .1, .1]); rvec = np.array([.4, .3, .2, .1])
KL = float(np.sum(rvec * np.log(rvec / pvec)))
p("KL(r||p) misspecified =", round(KL, 5))
for n in [10**2, 10**3, 10**4, 10**5, 10**6]:
    well = (K - 1) / 2 - (K - 1) / 2 * math.log(n) + cKa(K, a)
    mis_paper = n * KL - (K - 1) / 2 * math.log(n) + cKa(K, a)
    mis_corr = mis_paper + (K - 1) / 2
    p(f"n={n:>8}: well-spec pred {well:9.3f} | misspec pred (paper) {mis_paper:10.3f} | misspec pred + (K-1)/2 {mis_corr:10.3f}")

# exact Monte Carlo of Delta_n = ln DirMult(n_f; 1/2) - sum n_f ln p_f under r (independent of c2)
rng = np.random.default_rng(20261008)
def lndirmult(counts, a):
    Kk = len(counts); n = counts.sum()
    return gammaln(Kk * a) - gammaln(Kk * a + n) + np.sum(gammaln(a + counts) - gammaln(a), axis=-1)
for n in [100, 1000, 10000]:
    R = 20000
    cnt = rng.multinomial(n, rvec, size=R)
    d = (gammaln(K * a) - gammaln(K * a + n) + np.sum(gammaln(a + cnt) - gammaln(a), axis=1)) - cnt @ np.log(pvec)
    p(f"MC misspec n={n}: mean Delta = {d.mean():.3f} (s.e. {d.std()/math.sqrt(R):.3f}), 20000 runs")
for n in [100, 1000]:
    R = 20000
    cnt = rng.multinomial(n, pvec, size=R)
    d = (gammaln(K * a) - gammaln(K * a + n) + np.sum(gammaln(a + cnt) - gammaln(a), axis=1)) - cnt @ np.log(pvec)
    p(f"MC wellspec n={n}: mean Delta = {d.mean():.3f} (s.e. {d.std()/math.sqrt(R):.3f})")

# ---- 2. Prop ident:spare (d1) limits ----
def d1lim(A, a1, asig, w1):
    return gammaln(A + asig) + gammaln(a1) - gammaln(A) - gammaln(a1 + asig) + asig * math.log(w1)
for asig in (0.5, 1, 2):
    p(f"(d1) A=1, a1=1/2, w1*=1/2, alpha_sigma={asig}: ln R_inf = {d1lim(1, .5, asig, .5):.4f}")

# ---- 3. spare (a) with pa's K=8 numbers (prior 15 bits) ----
def spare_a_bits(A, asig, n):
    lnR = gammaln(A + asig) + gammaln(A + n) - gammaln(A) - gammaln(A + asig + n)
    return -lnR / math.log(2)
for n in (1000, 3000):
    exact = spare_a_bits(4.0, 0.5, n) + 15
    asym = 0.5 * math.log2(n) + (gammaln(4) - gammaln(4.5)) / math.log(2) + 15
    p(f"pa spare F->F, K=8, n={n}: exact {exact:.3f} bits, asymptotic {asym:.3f} bits (paper: 19.03 / 19.82)")
# E5(a): one-component T (A=1/2), spare alpha 1/2: log2 BF at n=1, 4096
for n in (1, 4096):
    p(f"E5(a) log2 BF at n={n}: {-spare_a_bits(0.5, 0.5, n):.3f}")

# ---- 4. constants in Lemma sound:regret and Example 4.9 ----
p("1/(e pi) =", round(1 / (math.e * math.pi), 4))
p("KT regret constant 0.5 ln(pi/2) =", round(0.5 * math.log(math.pi / 2), 4))
nx = math.exp(2 * (math.log(99) - 0.5 * math.log(math.pi / 2)))
p(f"deterministic crossing n where 0.5 ln n + 0.5 ln(pi/2) = ln 99 (eps=0, chi2 term 0): {nx:.0f}")

# ---- 5. Remark model:subcrit and Example model:qa ----
k = 2000
p(f"subcrit bound h(k)/h(0) at k=2000, rho=0.9: {0.9**k * 2*(k+1)/(k+2):.2e}")
# exact mean body size of Q_A from a formula root (k=0) and term root (k=0)
T1 = 1 / (1 - 0.6); T0 = 1 / (1 - 0.75)
F1 = (1 + 1.0 * T1) / (1 - 0.7)          # formula node with k>=1
F0 = (1 + 0.2 * F1 + 1.0 * T0) / (1 - 0.5)  # k=0: neg,and,imp keep k=0 (0.5); forall,exists go to k=1 (0.2)
p(f"Q_A exact mean size: formula root k=0 {F0:.3f} (paper empirical 14.62, bound 80); term root k=0 {T0:.3f}")
# weighted ratio check
p("Q_A weighted ratio formula node:", 0.7 * 1 + 1.0 * 0.05, " term node k=0:", 0.75 * 0.05 / 0.05, " k>0:", 0.6)

# ---- 6. Lemma model:lone computed values ----
for amp, a1 in ((0.15, 0.2), (0.3, 0.3), (0.4, 0.3)):
    m = 2 * amp + a1
    p0 = 1 - amp - a1
    if m < 1:
        p(f"(MP={amp}, Gen+AE={a1}) m={m:.2f}, E N = {1/(1-m):.3f}")
    else:
        roots = np.roots([amp, a1 - 1, p0])
        p(f"(MP={amp}, Gen+AE={a1}) m={m:.2f}, extinction q = {min(r.real for r in roots if r.real >= 0):.4f}")

# ---- 7. KL = H(Q) of the untruncated PCFG (Lemma model:size) ----
pr = np.array([.5, .3, .1, .1]); mch = .3 + .2 + .2
p(f"H(Q) = E[#nodes] H(root law) = {(1/(1-mch)) * float(-(pr*np.log(pr)).sum()):.4f} nats")

# ---- 8. Prop ident:sep region ----
for ax, lg, mp in ((0.6, 0.25, 0.15), (0.5, 0.3, 0.2), (0.3, 0.3, 0.4), (0.2, 0.4, 0.4)):
    p(f"(ax,lg,MP)=({ax},{lg},{mp}): ax/2={ax/2:.3f}, a_r/(1-a_r)={mp/(1-mp):.3f}, proved region: {ax/2 > mp/(1-mp)}")

# ---- 9. Ex ident:lonedq per-+ costs, odds drift ----
p("grammar 1: ln 1/(p+ p0) =", round(math.log(1 / (0.25 * 0.55)), 3), "; grammar 3:", round(math.log(1 / (0.0005 * 0.8995)), 3))
p("odds drift T_Q vs T_mix per datum:", round(7.758 - 4.904, 3))

# ---- 10. E5(b) Gold: L5 gain per datum ----
p("L5 gain per datum (bits):", round(3 - math.log2(5), 3), "; prior difference:", round(89.4 - 17.1, 1))

# ---- 11. Rem model:graded: the referee's numbers imply Z > 1 ----
for kappa, (PT, PT2, lT, lT2) in ((1.0, (3.2065e-02, 3.4560e-01, 5, 1)), (0.5, (4.3155e-02, 1.4910e-01, 5, 1))):
    ZT = 2 ** (-kappa * lT) / PT; ZT2 = 2 ** (-kappa * lT2) / PT2
    p(f"r6 kappa={kappa}: implied Z_T = {ZT:.3f}, Z_T' = {ZT2:.3f}  (Remark model:graded asserts Z <= 1 for kappa >= 1)")
# a genuine prefix code: gamma(#lines) + per line (2-bit tag, 2 bits per symbol over {a,b,~,>}, gamma refs for MP)
def gamma_len(k): return 2 * int(math.floor(math.log2(k))) + 1
lb_cite_b = gamma_len(1) + 2 + 2
lb_mp = gamma_len(3) + (2 + 2) + (2 + 2 * 3) + (2 + 2 + gamma_len(1) + gamma_len(2))
la = gamma_len(1) + 2 + 2
p(f"prefix code: l_T'(b) = {lb_cite_b} bits; l_T(b) via MP = {lb_mp} bits; l_T(a) = {la} bits")
p(f"  => P_T(b) <= 2^-{lb_mp}/2^-{la} = 2^-{lb_mp-la}, P_T'(b) >= 2^-{lb_cite_b}: the refutation holds with Z <= 1 too")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
