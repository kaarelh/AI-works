# Remark 7 of RT-width.fixed.md: failure of SP_1 at learner width ceil(n^alpha) against
# G_L(1, ceil(n^alpha), n^alpha) once alpha > L/(2(2L-1)), via B.md Lemma 9.2 + Prop 9.1(a).
# (i) build the Lemma 9.2 chain network with m=floor(n^a), B=n^a, delta0=(tanh 1)^{-H}/(m^H B^L);
#     check it fits D_{delta0} exactly with all weights in [-B,B];
# (ii) eta = delta0 ((n+1)/L)^{L/2}; check sign of log eta vs alpha - L/(2(2L-1)).
import mpmath as mp
mp.mp.dps = 80

def chain_net(m, B, H, x):
    t = mp.tanh(B * x)                    # first-layer rows (0, B)
    for _ in range(H - 1):
        t = mp.tanh(m * B * t)            # internal weights B, m inputs
    return t

ok = True
print("L  alpha   log10 n  | v<=B  fit-err  | log10 eta")
for L in [2, 3, 4, 6]:
    H = L - 1
    crit = mp.mpf(L) / (2 * (2 * L - 1))
    for alpha in [crit - mp.mpf('0.03'), crit + mp.mpf('0.03')]:
        for e in [20, 60, 200]:
            n = mp.mpf(10) ** e
            m = mp.floor(n ** alpha); B = n ** alpha
            delta0 = mp.tanh(1) ** (-H) / (m ** H * B ** L)
            if not (m * B >= mp.tanh(1) ** (-H) and delta0 <= 1):
                print("hypotheses of Lemma 9.2 fail at", L, alpha, e); ok = False; continue
            tH = chain_net(m, B, H, delta0)
            v = 1 / (m * tH)
            out_plus = m * v * chain_net(m, B, H, delta0)
            out_minus = m * v * chain_net(m, B, H, -delta0)
            fit_err = max(abs(out_plus - 1), abs(out_minus + 1))
            eta = delta0 * ((n + 1) / L) ** (mp.mpf(L) / 2)
            sign_ok = (mp.log10(eta) < 0) == (alpha > crit)
            ok = ok and (v <= B) and fit_err < mp.mpf(10) ** -60 and sign_ok
            print("%d  %.3f  %4d     | %-5s %.1e  | %s" % (L, float(alpha), e, bool(v <= B), float(fit_err), mp.nstr(mp.log10(eta), 6)))
print("all checks consistent:", ok)
