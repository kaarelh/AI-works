"""f7: the closeness lemma (notes-final Lemma 4.6) and the robust near-imitation theorem (Theorem 4.7), in
machine-free form.  Seeds: (A) default_rng(71); (B) default_rng(72) for the random programs; (C) default_rng(73);
(D) deterministic arithmetic.

Notation (notes-final Setting 4.1).  Cells w in W = {0..2^m-1}, uniform.  Inputs x ~ mu(.|w).  The human's
coin law rho on B, response h(x, b) injective in b, kernel nu_H(h(x,b)|x) = rho(b).  The world's coupling
beta: W -> B has exact type rho.  For a program pi (a sub-probability kernel nu_pi(.|x)):
  q~_w(b)  := prod_x nu_pi(h(x,b)|x)^mu(x|w)            (geometric mean over the cell's inputs)
  Dbar(pi) := 2^-m sum_w D_half(rho || q~_w),  D_half(P||Q) := -2 log2 sum_b sqrt(P(b) Q(b))
  R_beta(pi) := 2^-m sum_w E_{x~mu(.|w)} [-log2 nu_pi(h(x, beta(w))|x)]
  ED(pi)   := E_{x~mu} D_half(nu_H(.|x) || nu_pi(.|x))     (the behavioural divergence from the human)
Facts checked:
 (A) Hoelder: ED(pi) <= Dbar(pi), cell by cell; sum_b q~_w(b) <= sum_b q_w(b) <= 1 (q_w the arithmetic mean);
     the identity -log2 Q(beta) = 2^(m-1) (H(rho) + R_beta(pi)) for Q(beta') := prod_w sqrt(rho q~_w)(beta'(w));
     and sum over ALL beta' in B^W of Q(beta') = Z := prod_w sum_b sqrt(rho(b) q~_w(b)) <= 1 (brute force).
 (B) Counting form of the closeness lemma, exhaustively over the type class (|T_rho| = 2^L couplings), in an
     explicit prefix class C with Kraft sum k_C: for every j,
        P_beta'[ exists pi in C: Dbar(pi) >= H + R_beta'(pi) - 2 (L - l(pi) - j) / 2^m ]  <=  k_C 2^-j,
     and the counting form of the coding lemma (Lemma 4.4):
        P_beta'[ exists pi in C: 2^m R_beta'(pi) <= L - l(pi) - j ]  <=  k_C 2^-j.
 (C) For m = 6, 8, 10 (random couplings and a few structured ones): the population J_c-minimiser at c = a 2^-m,
     its divergence ED and Hellinger gap, and the machine-free form of Theorem 4.7(d)'s bound.
 (D) The bound of Theorem 4.7 at Paper 2's sizes, machine constant set to 0 (an illustration).
"""
import itertools
from math import comb, log2, sqrt, log, floor
import numpy as np

LOG2E = 1 / log(2)


def H(p):
    p = np.asarray(p, float)
    p = p[p > 0]
    return float(-(p * np.log2(p)).sum())


def dhalf(P, Q):
    """Renyi-1/2 divergence D_half(P||Q) = -2 log2 sum sqrt(P Q), Q possibly a sub-probability."""
    s = float(np.sum(np.sqrt(np.asarray(P) * np.asarray(Q))))
    return float("inf") if s <= 0 else -2 * log2(s)


def gamma_len(t):
    return 2 * floor(log2(t)) + 1 if t >= 1 else 0


# ----------------------------------------------------------------------------------------------------------
print("(A) Hoelder step, semimeasure, identity: latent cause, |B| = 3, |Y| = 4, 8 cells, 6 inputs")
rng = np.random.default_rng(71)
m, NB, NY, NX = 3, 3, 4, 6
NW = 2 ** m
rho = np.array([4, 2, 2]) / 8.0                     # rho(b) 2^m integer
Hrho = H(rho)
worst_holder, worst_mass_geo, worst_mass_ar, worst_ident, worst_Z = -np.inf, 0.0, 0.0, 0.0, 0.0
for inst in range(20):
    # mu(x|w): random support of size 1..3, rational masses
    mu = np.zeros((NW, NX))
    for w in range(NW):
        sup = rng.choice(NX, size=rng.integers(1, 4), replace=False)
        wts = rng.integers(1, 5, size=len(sup)).astype(float)
        mu[w, sup] = wts / wts.sum()
    # h(x, b): injective in b for each x
    h = np.array([rng.permutation(NY)[:NB] for _ in range(NX)])          # h[x, b] in Y
    beta = rng.permutation(np.repeat(np.arange(NB), (rho * NW).astype(int)))  # exact type rho
    for prog in range(40):
        nu = rng.random((NX, NY)) ** rng.choice([1, 3])
        nu = nu / nu.sum(1, keepdims=True) * rng.choice([1.0, 0.9, 0.6])     # sub-probabilities
        if prog % 4 == 0:                                                   # some zeros
            nu[rng.random((NX, NY)) < 0.15] = 0.0
        if prog == 0:                                                       # the human itself
            nu = np.zeros((NX, NY))
            for x in range(NX):
                nu[x, h[x]] = rho
        pull = np.stack([nu[np.arange(NX), h[:, b]] for b in range(NB)], 1)  # pull[x, b] = nu(h(x,b)|x)
        with np.errstate(divide="ignore"):
            lp = np.log2(pull)
        lw = -(mu @ np.where(np.isfinite(lp), lp, -1e300))                 # l_w(b) = E[-log nu(h(x,b)|x)]
        qt = np.exp2(-lw)                                                   # geometric means q~_w(b)
        qa = mu @ pull                                                      # arithmetic means q_w(b)
        worst_mass_geo = max(worst_mass_geo, (qt.sum(1) - qa.sum(1)).max())
        worst_mass_ar = max(worst_mass_ar, qa.sum(1).max())
        for w in range(NW):
            sup = np.nonzero(mu[w])[0]
            ed_w = sum(mu[w, x] * dhalf(rho, pull[x]) for x in sup)
            dw = dhalf(rho, qt[w])
            if np.isfinite(dw):
                worst_holder = max(worst_holder, ed_w - dw)
        R = lw[np.arange(NW), beta].mean()
        if np.isfinite(R) and R < 1e200:
            negLogQ = 0.5 * (-np.log2(rho[beta]).sum() + lw[np.arange(NW), beta].sum())
            worst_ident = max(worst_ident, abs(negLogQ - 0.5 * NW * (Hrho + R)))
        if inst < 3 and prog < 8:                                           # brute force over B^W
            sq = np.sqrt(rho[None, :] * qt)                                 # sq[w, b]
            tot = 0.0
            for bb in itertools.product(range(NB), repeat=NW):
                tot += np.prod(sq[np.arange(NW), bb])
            Z = np.prod(sq.sum(1))
            worst_Z = max(worst_Z, abs(tot - Z), Z - 1.0)
print(f"  20 instances x 40 programs (sub-probabilities, zeros, and the human):")
print(f"  max_w,pi [E_(x|w) D_half(nu_H||nu_pi) - D_half(rho||q~_w)] = {worst_holder:.3e}  (must be <= 0)")
print(f"  max [sum_b q~_w - sum_b q_w] = {worst_mass_geo:.3e} (<= 0);  max sum_b q_w = {worst_mass_ar:.6f} (<= 1)")
print(f"  max |-log2 Q(beta) - 2^(m-1)(H + R)| = {worst_ident:.2e}  (identity, exact type)")
print(f"  brute force over all 3^8 couplings: max(|sum Q - Z|, Z - 1) = {worst_Z:.2e}  (<= 0 up to rounding)")


# ----------------------------------------------------------------------------------------------------------
def build_class(NXc, rng_c, n_random=256, tmax=4, s0=4):
    """An explicit prefix class on inputs X for the coin-flipping human Bern(1/4) (binary B = Y, h(x,b) = b).
    Tags: '00' fair coin (l = 2); '010' + 4 bits: Bern(j/16) everywhere (l = 7; the human is j = 4);
    '011' + gamma(t) + ceil(log2 C(|X|,t)) + 4 + 1 bits: T-memorisers 'y = 1 w.p. on (1 or 15/16) on T,
    Bern(j/16) elsewhere'; '10' + log2|X| bits: interval memorisers (deterministic: y = 1 exactly on the s0
    cyclically consecutive inputs starting at i); '11' + 8 bits: random kernels (l = 10).  Kraft <= 1.
    Returns (lengths, kernels nu[pi, x] = P(y = 1 | x), names)."""
    L, K, names = [], [], []
    L.append(2); K.append(np.full(NXc, 0.5)); names.append("fair coin")
    for j in range(1, 16):
        L.append(7); K.append(np.full(NXc, j / 16)); names.append(f"Bern({j}/16)")
    for t in range(1, tmax + 1):
        lt = 3 + gamma_len(t) + (comb(NXc, t) - 1).bit_length() + 5
        for T in itertools.combinations(range(NXc), t):
            for j in range(1, 16):
                for on in (1.0, 15 / 16):
                    v = np.full(NXc, j / 16)
                    v[list(T)] = on
                    L.append(lt); K.append(v); names.append(f"mem t={t} q={j}/16 on={on:.3f}")
    for i in range(NXc):
        v = np.zeros(NXc)
        v[[(i + k) % NXc for k in range(s0)]] = 1.0
        L.append(2 + (NXc - 1).bit_length()); K.append(v); names.append(f"interval@{i}")
    for r in range(n_random):
        v = rng_c.beta(0.5, 1.5, size=NXc)
        L.append(10); K.append(v); names.append(f"random#{r}")
    return np.array(L, float), np.array(K), names


def class_quantities(K, mu_c, rho_c):
    """Per program: l_w(b) (cell log-losses), Dbar, ED, Hellinger gap.  Binary B = Y, h(x,b) = b."""
    with np.errstate(divide="ignore"):
        l1 = -np.log2(K)                          # -log nu(1|x)
        l0 = -np.log2(1 - K)                      # -log nu(0|x)
    BIG = 1e6
    l1 = np.minimum(l1, BIG); l0 = np.minimum(l0, BIG)
    lw0 = l0 @ mu_c.T                             # [pi, w]
    lw1 = l1 @ mu_c.T
    qt0, qt1 = np.exp2(-lw0), np.exp2(-lw1)
    with np.errstate(divide="ignore"):         # deterministic kernels in the latent case: Dbar = inf
        Dw = -2 * np.log2(np.sqrt(rho_c[0] * qt0) + np.sqrt(rho_c[1] * qt1))
    Dbar = Dw.mean(1)
    Dx = -2 * np.log2(np.sqrt(rho_c[0] * (1 - K)) + np.sqrt(rho_c[1] * K))   # [pi, x]
    px = mu_c.mean(0)                                                         # input law mu
    ED = Dx @ px
    Hel = (1 - (np.sqrt(rho_c[0] * (1 - K)) + np.sqrt(rho_c[1] * K))) @ px
    return lw0, lw1, Dbar, ED, Hel


print()
print("(B) counting forms, exhaustively over the type class: coin-flipping human Bern(1/4), 16 cells, s0 = 4")
rng = np.random.default_rng(72)
m = 4
NW = 2 ** m
s0 = 4
rho_c = np.array([1 - s0 / NW, s0 / NW])
Hc = H(rho_c)
Lb = log2(comb(NW, s0))
couplings = np.array([[1 if w in S else 0 for w in range(NW)] for S in itertools.combinations(range(NW), s0)],
                     float)                                                   # [beta', w], 1 = coin 1
for case in ("feature", "latent"):
    if case == "feature":
        NXc = NW
        mu_c = np.eye(NW)
    else:
        NXc = 8                                    # x = w mod 8 with prob 3/4, else uniform on 8 inputs
        mu_c = np.full((NW, NXc), 0.25 / NXc)
        mu_c[np.arange(NW), np.arange(NW) % NXc] += 0.75
    Lc, Kc, names = build_class(NXc=NXc, rng_c=rng, tmax=4 if case == "feature" else 3, s0=s0 if case ==
                                "feature" else 2)
    kraft = float(np.sum(np.exp2(-Lc)))
    lw0, lw1, Dbar, ED, Hel = class_quantities(Kc, mu_c, rho_c)
    assert np.all(ED <= Dbar + 1e-9), "Hoelder step violated"
    base = lw0.sum(1)                                              # [pi]
    diff = (lw1 - lw0)                                             # [pi, w]
    best_close = np.full(len(couplings), -np.inf)                  # max_pi d_close(pi, beta')
    best_code = np.full(len(couplings), -np.inf)                   # max_pi d_code(pi, beta')
    for s in range(0, len(Lc), 4000):
        R = (base[s:s + 4000][None, :] + couplings @ diff[s:s + 4000].T) / NW     # [beta', pi]
        inf_R = R >= 1e4                           # the capped log-losses (1e6) mark R = infinity
        R = np.minimum(R, 1e5)
        lp = Lc[s:s + 4000][None, :]
        with np.errstate(invalid="ignore"):
            d_close = Lb - lp - 0.5 * NW * (Hc + R - Dbar[s:s + 4000][None, :])
        d_close = np.where(inf_R, -np.inf, d_close)   # R = inf: Q_pi(beta') = 0, the event cannot occur
        d_code = np.where(inf_R, -np.inf, Lb - lp - NW * R)
        best_close = np.maximum(best_close, d_close.max(1))
        best_code = np.maximum(best_code, d_code.max(1))
    print(f"  {case} case: |X| = {NXc}, class size {len(Lc)}, Kraft sum k_C = {kraft:.4f}, "
          f"L = log2 C(16,4) = {Lb:.3f}, max_pi (ED - Dbar) = {np.max(ED - Dbar):.2e}")
    print("     j : P[closeness event]  P[coding event]   k_C 2^-j")
    ok = True
    for j in (-2, 0, 1, 2, 3, 4, 5, 6, 8):
        pc = float(np.mean(best_close >= j)); pk = float(np.mean(best_code >= j))
        bound = kraft * 2.0 ** (-j)
        ok &= (pc <= bound + 1e-12) and (pk <= bound + 1e-12)
        print(f"    {j:2d} : {pc:10.5f}         {pk:10.5f}        {bound:9.5f}")
    print(f"     all j within k_C 2^-j: {ok};  max deficiency over couplings: closeness {best_close.max():.3f},"
          f" coding {best_code.max():.3f}; couplings with positive closeness deficiency: "
          f"{int(np.sum(best_close > 0))} of {len(couplings)}")


# ----------------------------------------------------------------------------------------------------------
print()
print("(C) population J_c-minimisers, feature case, coin-flipping human Bern(1/4), larger m, exact over the class")
print("    class: '00' fair coin (l = 2); '010' Bern(j/16) (l = 7; human j = 4, so l_0 = 7); '011' T-memorisers")
print("    (any t <= s0, q in {j/16}, on in {1, 15/16}; l = 8 + gamma(t) + ceil(log2 C(2^m, t))); '10' the 2^m")
print("    interval memorisers (l = 2 + m); '11' 256 random kernels (l = 10).  For a given coupling the best")
print("    T of each size is a subset of the coin-1 cells, so the memorisers are evaluated in closed form.")
rng = np.random.default_rng(73)


def analyse(m, n_random_beta, structured):
    NW = 2 ** m
    s0 = NW // 4
    rho = np.array([0.75, 0.25])
    Hr = H(rho)
    Lb = log2(comb(NW, s0))
    l0 = 7.0
    qs = np.arange(1, 16) / 16
    D_q = np.array([dhalf(rho, [1 - q, q]) for q in qs])                         # D_half(rho||Bern(q))
    Hel_q = np.array([1 - (sqrt(0.75 * (1 - q)) + sqrt(0.25 * q)) for q in qs])
    # rate laws and the fair coin: R, ED, Hel, length (independent of the coupling by exact type)
    progs = []                       # (length, R, ED, Hel, Dbar, name)
    progs.append((2.0, 1.0, dhalf(rho, [0.5, 0.5]), 1 - (sqrt(0.375) + sqrt(0.125)), dhalf(rho, [0.5, 0.5]),
                  "fair coin"))
    for k, q in enumerate(qs):
        R = 0.75 * -log2(1 - q) + 0.25 * -log2(q)
        progs.append((7.0, R, D_q[k], Hel_q[k], D_q[k], f"Bern({k + 1}/16)"))
    # T-memorisers with T inside the coin-1 cells (best placement), all t <= s0
    for t in range(1, s0 + 1):
        lt = 8 + gamma_len(t) + (comb(NW, t) - 1).bit_length()
        for k, q in enumerate(qs):
            for on in (1.0, 15 / 16):
                R = (t * -log2(on) + (s0 - t) * -log2(q) + (NW - s0) * -log2(1 - q)) / NW
                Don = dhalf(rho, [1 - on, on]); Hon = 1 - (sqrt(0.75 * (1 - on)) + sqrt(0.25 * on))
                ED = (t * Don + (NW - t) * D_q[k]) / NW
                Hl = (t * Hon + (NW - t) * Hel_q[k]) / NW
                progs.append((float(lt), R, ED, Hl, ED, f"mem t={t}"))
    fixed = np.array([p[:5] for p in progs])
    fixed_names = [p[5] for p in progs]
    # random kernels and interval memorisers depend on the coupling: precompute their per-cell losses
    RK = rng.beta(0.5, 1.5, size=(256, NW))
    rk_l1, rk_l0 = -np.log2(RK), -np.log2(1 - RK)
    rk_D = (-2 * np.log2(np.sqrt(0.75 * (1 - RK)) + np.sqrt(0.25 * RK))).mean(1)
    rk_H = (1 - (np.sqrt(0.75 * (1 - RK)) + np.sqrt(0.25 * RK))).mean(1)
    int_D = (s0 * dhalf(rho, [0, 1]) + (NW - s0) * dhalf(rho, [1, 0])) / NW
    int_H = (s0 * (1 - sqrt(0.25)) + (NW - s0) * (1 - sqrt(0.75))) / NW
    betas = [("random", rng.permutation(np.repeat([0, 1], [NW - s0, s0]))) for _ in range(n_random_beta)]
    for i in structured:
        b = np.zeros(NW, int); b[[(i + k) % NW for k in range(s0)]] = 1
        betas.append(("interval", b))
    out = []
    for kind, b in betas:
        S = b.astype(bool)
        rk_R = (rk_l1[:, S].sum(1) + rk_l0[:, ~S].sum(1)) / NW
        is_int = [np.array_equal(np.nonzero(b)[0], np.sort([(i + k) % NW for k in range(s0)])) for i in range(NW)]
        int_R = np.array([0.0 if ok else np.inf for ok in is_int])
        Ls = np.concatenate([fixed[:, 0], np.full(256, 10.0), np.full(NW, 2.0 + m)])
        Rs = np.concatenate([fixed[:, 1], rk_R, int_R])
        EDs = np.concatenate([fixed[:, 2], rk_D, np.full(NW, int_D)])
        Hs = np.concatenate([fixed[:, 3], rk_H, np.full(NW, int_H)])
        Dbars = EDs                                         # feature case: q~_w = nu(.|w), so Dbar = ED
        nm = fixed_names + ["random"] * 256 + ["interval"] * NW
        with np.errstate(invalid="ignore"):
            d_code = np.nanmax(Lb - Ls - NW * Rs)
            d_close = np.nanmax(Lb - Ls - 0.5 * NW * (Hr + Rs - Dbars))
        out.append((kind, Ls, Rs, EDs, Hs, nm, d_code, d_close))
    print(f"  m = {m}: 2^m = {NW}, s0 = {s0}, L = {Lb:.2f}, 2^m H - L = {NW * Hr - Lb:.2f}; window of the human in"
          f" this class: (s_+, s_-) with s_- = (1 - H)/(7 - 2) = {(1 - Hr) / 5:.4f} = {(1 - Hr) / 5 * NW:.2f} 2^-m")
    print("      a        c     couplings   P[argmin = human]  max ED(argmin)  max Hel(argmin)  Thm 4.7(d) bound"
          "  (machine-free, worst coupling)  argmin types")
    for a in (0.5, 0.9, 1.5, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0):
        c = a * 2.0 ** -m
        for kind in ("random", "interval"):
            sel = [o for o in out if o[0] == kind]
            if not sel:
                continue
            hits, eds, hels, bnds, kinds = 0, [], [], [], {}
            for (_, Ls, Rs, EDs, Hs, nm, d4, dcl) in sel:
                J = c * Ls + Rs
                ix = int(np.argmin(J))
                hits += nm[ix] == "Bern(4/16)"
                eds.append(max(float(EDs[ix]), 0.0) + 0.0); hels.append(max(float(Hs[ix]), 0.0) + 0.0)
                kinds[nm[ix]] = kinds.get(nm[ix], 0) + 1
                if a > 1:
                    G = l0 + NW * Hr - Lb + max(d4, 0.0)
                    bnds.append(a * l0 / NW + 2 * (l0 + G / (a - 1) + max(dcl, 0.0) + NW * Hr - Lb) / NW)
            bs = f"{max(bnds):8.4f}" if bnds else "     n/a"
            top = ", ".join(f"{k}:{v}" for k, v in sorted(kinds.items(), key=lambda kv: -kv[1])[:2])
            print(f"    {a:5.1f}  {c:.5f}  {kind:9s} {len(sel):4d}     {hits / len(sel):7.3f}        {max(eds):8.4f}"
                  f"        {max(hels):8.4f}         {bs}                          {top}")


analyse(6, 100, structured=[0, 5])
analyse(8, 100, structured=[0, 17])
analyse(10, 50, structured=[0, 100])
print("  (ED and Hel: the Renyi-1/2 divergence and the Hellinger gap of the selected program from the human,"
      " averaged over inputs.  The bound uses l_0 = 7, the exact 2^m H - L, and the class's own coding and"
      " closeness deficiencies at the coupling, clipped at 0; it is the machine-free form of Theorem 4.7(d)"
      " with eps = 0.  ED(fair coin) = 0.1000.)")

# ----------------------------------------------------------------------------------------------------------
print()
print("(D) Theorem 4.7 at Paper 2's sizes, machine constant kappa = 0 (an illustration)")


def thm47(l0, m, Bsz, Hr, a, delta=0.0):
    """Bound on E_x D_half for near-optimal programs (eps = 0) at c = a 2^-m."""
    logterm = Bsz * log2(2 ** m + 1)
    Em = 2 * log2(2 ** (m - 1) * (2 * Hr + a * l0 / 2 ** m) + 1)      # 2 log(k+1) with R <= H + a l0 / 2^m
    num = (a + 2 + 2 / (a - 1)) * l0 + (2 + 2 / (a - 1)) * (delta + logterm) + 2 * Em + 2
    return num / 2 ** m


rows = [("coin human, rho = Bern(2^-10), m = 20", 2 * log2(10 + 1) + 10 + 2, 20, 2, H([1 - 2**-10, 2**-10])),
        ("parity human, d = 100, m = 20, p = 2^-10", 100 + 2 * log2(100) + 2 * log2(10), 20, 2,
         H([1 - 2**-10, 2**-10])),
        ("R1 world, m = 10 (l_0 ~ 2^m)", 1024 + 2 * log2(11), 10, 2, H([1 - 1 / 16, 1 / 16]))]
for name, l0, mm, Bsz, Hr in rows:
    print(f"  {name}: l_0 ~ {l0:.1f} bits, 2^m = {2**mm}")
    for a in (1.5, 2.0, 4.0, 105.0, 1000.0):
        b = thm47(l0, mm, Bsz, Hr, a)
        hel = b * log(2) / 2
        tv = sqrt(2 * hel)
        print(f"     a = {a:7.1f} (c = {a * 2.0**-mm:.2e}): E D_half <= {b:.3e}; Hellinger gap <= {hel:.3e}; "
              f"mean TV <= {min(tv, 1):.3f}" + ("   (vacuous)" if b >= 1 else ""))
