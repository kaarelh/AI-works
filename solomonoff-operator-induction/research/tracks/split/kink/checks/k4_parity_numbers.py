"""k4: numbers for the noisy random parity as an instance of the kink theorem (notes.md Prop 4.2 and Cor 4.3).

Full truth table, idiosyncratic errors (m = d), B = infinity, |E| = pN flips with deficiency delta_E.
For each (d, p, kappa, delta_E):
  * the level-(t+1) exclusion steepness sigma_t(lambda) = N (Psi_t - H(p)) / (kappa_g + min(d, s(t+1)+Lambda_1)),
    Psi_t = max(G_t, F_t(L_lambda)), with G_t from Lemma teacher:floor and F_t from Lemma
    teacher:sharpfloor at the information budget L_lambda + kappa, L_lambda = d + kappa_g + (b0+kappa)/(lambda-1);
  * for t0 = 1, 2, ...: the lambda-range {lambda > 1 : lambda < sigma_t(lambda) for all t0 <= t <= max(t0, T)}
    on which every lambda-MAP has level <= t0 (knows the parity up to s(t0) + 2 log d + kappa bits);
  * comparison with the window (1, N c_hi) of thm:teacher:main / cor:teacher:fulltable (p < 0.056);
  * identification bounds at lambda = 2 and 105 for d = m = 20, p = 2^-10 (as in app:teacher:fulltable);
  * (d) the crossovers of G_1 and of the limits of F_t with H(p), and an interval check that the limit
    of F_2 exceeds H(p) on (0, 1/4] (notes.md Cor 4.3);
  * (e) N H(p) - L_E by lgamma against the Stirling series used for N > 2^24.
The script's L_lambda is the notes' bar-ell_lambda (a length cap).
Every occurrence of kappa is set to the stated value (0: an illustration; 30: robustness), and the
constant in j of the sharp floor is 2 kappa (budget kappa + lemma constant kappa), as in the paper's tables.
Deterministic (no randomness).
"""
import math

LN2 = math.log(2)


def H(q):
    return 0.0 if q in (0, 1) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / LN2


def NH_minus_LE(N, s0):
    """N H(s0/N) - log2 binom(N, s0): exact (lgamma) for N <= 2^24, else the Stirling series
    1/2 log2(2 pi s0 (N-s0)/N) + log2(e) (1/(12 s0) + 1/(12 (N-s0)) - 1/(12 N)) + O(s0^-3), whose
    error is below 1e-9 bits for the sizes used here."""
    p = s0 / N
    if N <= 2 ** 24:
        return N * H(p) - log2binom(N, s0)
    return 0.5 * math.log2(2 * math.pi * s0 * (N - s0) / N) + math.log2(math.e) * (
        1 / (12 * s0) + 1 / (12 * (N - s0)) - 1 / (12 * N))


def s_of(t):
    return 2 * t + 2 * math.log2(t + 1)


def G(t, p):
    return 1 - math.log2(1 + (2.0 ** -t if t != math.inf else 0.0) + 2 * p)


def least_j(rhs):
    """least integer j >= 0 with j - 2 log2(j+1) > rhs (j - 2 log2(j+1) is increasing for j >= 2).
    For rhs > 2^50 float arithmetic cannot resolve single steps; we return the upper bound
    ceil(rhs + 2 log2(rhs + 2) + 1), which only enlarges gamma (a weaker, still valid bound)."""
    if rhs > 2.0 ** 50:
        return math.ceil(rhs + 2 * math.log2(rhs + 2) + 1)
    j = max(0, int(rhs + 2 * math.log2(max(rhs, 1.0) + 1)) - 3)
    while j > 0 and (j - 1) - 2 * math.log2(j) > rhs:
        j -= 1
    while j - 2 * math.log2(j + 1) <= rhs:
        j += 1
    return j


_GCACHE = {}


def gammas(p, s0, d, budget, delta, kappa, gmax=40):
    """[(g, gamma_g)] of Lemma teacher:sharpfloor at information budget I <= budget (cached)."""
    key = (p, s0, d, round(budget, 9), delta, kappa)
    if key not in _GCACHE:
        out = []
        for g in range(1, gmax + 1):
            rhs = delta + budget + 1 + 2 * math.log2(d) + 2 * math.log2(s0) + g + 2 * math.log2(g) + kappa
            j = least_j(rhs)
            out.append((g, math.sqrt(j * LN2 / (2 * s0))))
        _GCACHE[key] = out
    return _GCACHE[key]


def F(t, p, s0, d, budget, delta, kappa):
    """sharp floor for level > t at information budget I <= budget, optimised over g."""
    tt = 2.0 ** -t if t != math.inf else 0.0
    return max(1 - math.log2(1 + (1 - 2 * p) * tt + 2 * p * (2 * gm + 2.0 ** (1 - g)))
               for g, gm in gammas(p, s0, d, budget, delta, kappa))


def Kp(p):
    # K(p): for p = 2^-r use 2 log r (as kappa_g of def:teacher:instance); for p = h/2^e use
    # 2 log(h+1) + 2 log(e+1) (as in tab:algstat:numbers)
    r = -math.log2(p)
    if abs(r - round(r)) < 1e-12:
        return 2 * math.log2(round(r))
    for e in range(1, 40):
        h = p * 2 ** e
        if abs(h - round(h)) < 1e-12:
            return 2 * math.log2(round(h) + 1) + 2 * math.log2(e + 1)
    raise ValueError


class Inst:
    def __init__(self, d, p, kappa, delta, use_sharp=True):
        self.d, self.p, self.kappa, self.delta = d, p, kappa, delta
        self.N = 2 ** d
        self.s0 = round(p * self.N)
        assert abs(self.s0 - p * self.N) < 1e-9
        self.kg = 2 * math.log2(d) + Kp(p) + kappa
        self.L1 = 4 * math.log2(d) + kappa                        # Lambda_1 with m = d, B = inf
        self.NH = self.N * H(p)
        self.gapE = NH_minus_LE(self.N, self.s0)                 # N H(p) - L_E, computed stably
        self.LE = self.NH - self.gapE
        self.b0 = self.kg + self.gapE + delta + 2 * math.log2(d) + kappa
        self.use_sharp = use_sharp
        self.T = 1
        while s_of(self.T + 1) + self.L1 < d:
            self.T += 1

    def Llam(self, lam):
        return self.d + self.kg + (self.b0 + self.kappa) / (lam - 1)

    def Psi(self, t, lam):
        g = G(t, self.p)
        if not self.use_sharp:
            return g
        return max(g, F(t, self.p, self.s0, self.d, self.Llam(lam) + self.kappa, self.delta, self.kappa))

    def sigma(self, t, lam):
        den = self.kg + min(self.d, s_of(t + 1) + self.L1)
        return self.N * (self.Psi(t, lam) - H(self.p)) / den

    def ok(self, t0, lam):
        # levels t+1 with t >= max(t0, T) have the saturated denominator kappa_g + d and a numerator
        # nondecreasing in t, so the condition at t = max(t0, T) implies all of them
        return all(lam < self.sigma(t, lam) for t in range(t0, max(t0, self.T) + 1))

    def lam_range(self, t0):
        """(lambda_min, lambda_max) of {lambda > 1: ok}, by scanning a log grid and bisection."""
        top = int(4 * (math.log10(self.N) + 1))
        grid = [1 + 10.0 ** e for e in [x / 4 for x in range(-48, top + 1)]]
        oks = [self.ok(t0, l) for l in grid]
        if not any(oks):
            return None
        i0 = oks.index(True)
        i1 = len(oks) - 1 - oks[::-1].index(True)
        assert all(oks[i0:i1 + 1]), "range not an interval on the grid"

        def bis(a, b, want_ok_at_b):
            for _ in range(50):
                mlog = math.sqrt((a - 1) * (b - 1))
                m = 1 + mlog
                if self.ok(t0, m) == want_ok_at_b:
                    b = m
                else:
                    a = m
            return b
        lo = 1.0 if i0 == 0 else bis(grid[i0 - 1], grid[i0], True)
        hi = grid[i1] if i1 == len(grid) - 1 else bis(grid[i1 + 1], grid[i1], True)
        return lo, hi

    def c_hi_window(self):
        """N c_hi of thm:teacher:main with m = d, B = inf (G-based; needs G_1 > H(p))."""
        p, d = self.p, self.d
        tstar = (d - self.L1) / 4
        g1 = G(1, p)
        if tstar >= 2:
            c = min((g1 - H(p)) / (8 + self.L1 + self.kg), (G(tstar - 1, p) - H(p)) / (d + self.kg))
        else:
            c = (g1 - H(p)) / (d + self.kg)
        return self.N * c

    def ident(self, lam, t0):
        """identification bounds for every lambda-MAP at lambda (assumed in the level-<=t0 range)."""
        d, k = self.d, self.kappa
        w = self.kg + s_of(t0) + self.L1
        Ll = self.Llam(lam)
        I_bound = (Ll - d) + s_of(t0) + 2 * math.log2(d) + k
        R_hi = (self.NH + lam * w) / self.N
        u_lo = max(0.5 + 2.0 ** (-t0 - 1), 2.0 ** -R_hi - self.p)
        # sharp floor: R >= -log(p + (1-2p) u + p(2 gam + 2^(1-g))) => u >= ...
        best_u = u_lo
        gl = gammas(self.p, self.s0, d, I_bound, self.delta, k)
        for g, gam in gl:
            u_s = (2.0 ** -R_hi - self.p - self.p * (2 * gam + 2.0 ** (1 - g))) / (1 - 2 * self.p)
            best_u = max(best_u, u_s)
        best_e = min(1.0, min(1 - best_u + gam + 2.0 ** -g for g, gam in gl))
        return dict(Kag=s_of(t0) + 2 * math.log2(d) + k, len_lo=d - s_of(t0) - self.L1, len_hi=Ll - d,
                    fit_excess=lam * w, fit_deficit=lam * (self.b0 + k) / (lam - 1),
                    suff=self.b0 + (lam - 1) * w, I=I_bound, u=best_u, e=best_e)


print("=" * 100)
print("(a) p = 2^-10 (G_1 > H(p)): level-1 range vs the teacher window (1, N c_hi]")
for d in [20, 30, 60, 100]:
    for kappa in [0, 30]:
        for delta in [0, 20]:
            I = Inst(d, 2.0 ** -10, kappa, delta)
            rG = Inst(d, 2.0 ** -10, kappa, delta, use_sharp=False).lam_range(1)
            rS = I.lam_range(1)
            print(f"  d={d:3d} kappa={kappa:2d} delta_E={delta:2d}: N c_hi = {I.c_hi_window():.6g}; level-1 range "
                  f"(G floors) = ({rG[0]:.6g}, {rG[1]:.6g}); with sharp floor = ({rS[0]:.6g}, {rS[1]:.6g})")

print("=" * 100)
print("(b) identification at d = m = 20, p = 2^-10 (compare app:teacher:fulltable: lambda=2: u>=0.991,")
print("    l<=d+58.2, I<=70.8, e<=0.220 at kappa=0, delta=0)")
for kappa in [0, 30]:
    for delta in [0, 20]:
        I = Inst(20, 2.0 ** -10, kappa, delta)
        for lam in [2, 105]:
            b = I.ident(lam, 1)
            print(f"  kappa={kappa:2d} delta_E={delta:2d} lambda={lam:3d}: K(a|pi)<={b['Kag']:.1f}, u>={b['u']:.3f}, "
                  f"l in [d{b['len_lo']-20:+.1f}, d+{b['len_hi']:.1f}], fit <= NH(p)+{b['fit_excess']:.1f} and >= NH(p)-{b['fit_deficit']:.1f}, "
                  f"sufficiency deficiency <= {b['suff']:.1f}, I<={b['I']:.1f}, e<={b['e']:.3f}")

print("=" * 100)
print("(c) every flip rate below 1/4: least level t0 with a nonempty range, and the range")
for p in [1 / 16, 1 / 8, 3 / 16, 7 / 32, 15 / 64]:
    for d in [20, 30, 60, 100]:
        for kappa in [0, 30]:
            I = Inst(d, p, kappa, 0)
            out = None
            for t0 in range(1, max(I.T, 12) + 1):
                r = I.lam_range(t0)
                if r is not None:
                    out = (t0, r)
                    break
            G1 = G(1, p) - H(p)
            F1lim = 1 - math.log2(1.5 - p) - H(p)
            if out is None:
                print(f"  p={p:.4f} d={d:3d} kappa={kappa:2d}: no level with a nonempty range "
                      f"(G_1-H={G1:+.3f}, limit of F_1-H={F1lim:+.3f})")
            else:
                t0, (lo, hi) = out
                b = I.ident(max(2.0, lo * 1.01), t0) if hi > 2 else None
                extra = (f"; at lambda=2: K(a|pi)<={b['Kag']:.1f}, l>=d{b['len_lo']-d:+.1f}, l<=d+{b['len_hi']:.1f}, "
                         f"I<={b['I']:.1f} of L_E={I.LE:.4g}") if b else ""
                print(f"  p={p:.4f} d={d:3d} kappa={kappa:2d}: t0={t0} (s(t0)={s_of(t0):.1f}), lambda in "
                      f"({lo:.6g}, {hi:.4g}){extra}")

print("=" * 100)
print("(d) the crossovers: G_1 = H(p) at p = 0.0560 (window of thm:teacher:main); the limit of F_1,")
print("    1 - log(3/2 - p), equals H(p) at p = 0.123; the limit of F_2 exceeds H(p) for every p < 1/4")
def bisect(f, a, b):
    for _ in range(200):
        m = (a + b) / 2
        if f(a) * f(m) <= 0:
            b = m
        else:
            a = m
    return (a + b) / 2
print(f"  G_1(p) = H(p) at p = {bisect(lambda q: G(1, q) - H(q), 0.01, 0.2):.5f}")
print(f"  1 - log(3/2 - p) = H(p) at p = {bisect(lambda q: 1 - math.log2(1.5 - q) - H(q), 0.05, 0.24):.5f}")
for t in [1, 2, 3, 4, 6]:
    f = lambda q: 1 - math.log2(1 + (1 - 2 * q) * 2.0 ** -t) - H(q)
    if f(0.01) * f(0.25) > 0:
        print(f"  limit of F_{t} - H(p) has no zero in (0.01, 1/4): its value at p = 1/4 is {f(0.25):+.4f}, "
              f"min over a grid of (0.01, 1/4) is {min(f(0.01 + k * 0.24 / 1000) for k in range(1001)):+.4f}")
    else:
        print(f"  limit of F_{t} = H(p) at p = {bisect(f, 0.01, 0.25):.5f}")
# rigorous (interval) check that the limit of F_2 exceeds H(p) on (0, 1/4]: on a cell [a, b] the
# first term 1 - log(1 + (1-2p)/4) is increasing in p and H is increasing on (0, 1/2), so
# f_2 >= 1 - log(1 + (1-2a)/4) - H(b) there.
cells = 100000
worst = min(1 - math.log2(1 + (1 - 2 * (k * 0.25 / cells)) / 4) - H((k + 1) * 0.25 / cells) for k in range(cells))
print(f"  interval check over {cells} cells of (0, 1/4]: limit of F_2 - H(p) >= {worst:+.5f} > 0")
print("=" * 100)
print("(e) N H(p) - L_E: exact (lgamma) against the Stirling series used above 2^24")
for d_ in [16, 20, 24, 30]:
    N_ = 2 ** d_
    s_ = N_ // 1024
    exact = N_ * H(s_ / N_) - log2binom(N_, s_)
    stir = 0.5 * math.log2(2 * math.pi * s_ * (N_ - s_) / N_) + math.log2(math.e) * (
        1 / (12 * s_) + 1 / (12 * (N_ - s_)) - 1 / (12 * N_))
    print(f"  d={d_}, p=2^-10: lgamma {exact:.10f}, Stirling {stir:.10f}, difference {abs(exact - stir):.1e}")
