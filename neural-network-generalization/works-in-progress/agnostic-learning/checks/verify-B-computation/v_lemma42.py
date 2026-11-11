"""Independent check of B.md Lemma 4.2 (explicit size of the repository's energy cover).

Exact count (paper.tex Lemma compression + Prop energy-cover + Remark cube):
  r = min{1, a sqrt(d)/(8 K^{L/2})},  log2 s = d log2(1 + 2 sqrt(d)/r)   (upper bound for s),
  D_T = max{1, ceil(log2 s)},  lambda = a 2^{-L} K^{-(L-1)/2}/(4(L-1)),
  J = max{ceil(4K), ceil(256 lambda^{-4} [D_T + ln(L/lambda)])},
  Delta = a/(4(d+L+1)(2J^2)^L),  P = J(d+1)+(L-2)J^2+J,  ln|H| <= P ln(1 + 2(J+1)/Delta).
Claims checked:
  Step 1: D_T <= 1 + 0.722 d L ell;  ln(L/lambda) <= 2L + (L/2) ell;  Xi <= 3 d L ell.
  Step 2: J <= Jbar = C_J d K^{2(L-1)} a^{-4} ell,  C_J = 196609 L (L-1)^4 16^L.
  Step 3: ln|H| <= Gamma_L.
  Step 4: ln Jbar <= ln C_J + (2L+1) ell;  ln(2^{L+5}(d+L+1)/a) <= L+5+ell;
          Gamma_L <= (L-1) C_J^2 C_log d^2 K^{4(L-1)} a^{-8} ell^3 (L>=3),  <= 3 C_J C_log d^2 K^2 a^{-4} ell^2 (L=2).
Everything in mpmath with 60 digits (J can be ~1e100)."""
import itertools, math
import mpmath as mp
mp.mp.dps = 60

def exact(L, d, K, a):
    L, d = int(L), int(d); K = mp.mpf(K); a = mp.mpf(a)
    r = min(mp.mpf(1), a * mp.sqrt(d) / (8 * K ** (mp.mpf(L) / 2)))
    log2s = d * mp.log(1 + 2 * mp.sqrt(d) / r, 2)
    DT = max(1, int(mp.ceil(log2s)))
    lam = a * mp.mpf(2) ** (-L) * K ** (-(mp.mpf(L) - 1) / 2) / (4 * (L - 1))
    Xi = DT + mp.log(L / lam)
    J = max(mp.ceil(4 * K), mp.ceil(256 * lam ** -4 * Xi))
    Delta = a / (4 * (d + L + 1) * (2 * J * J) ** L)
    P = J * (d + 1) + (L - 2) * J * J + J
    lnH = P * mp.log(1 + 2 * (J + 1) / Delta)
    return dict(r=r, log2s=log2s, DT=DT, lam=lam, Xi=Xi, J=J, Delta=Delta, P=P, lnH=lnH)

def claims(L, d, K, a):
    e = exact(L, d, K, a)
    K = mp.mpf(K); a = mp.mpf(a)
    ell = mp.log(17 * d * K / a)
    CJ = 196609 * L * (L - 1) ** 4 * mp.mpf(16) ** L
    Jbar = CJ * d * K ** (2 * (L - 1)) * a ** -4 * ell
    Gam = ((L - 2) * Jbar ** 2 + (d + 2) * Jbar) * ((2 * L + 1) * mp.log(Jbar) + mp.log(mp.mpf(2) ** (L + 5) * (d + L + 1) / a))
    Clog = (2 * L + 1) * (mp.log(CJ) + 2 * L + 1) + L + 6
    if L >= 3:
        poly = (L - 1) * CJ ** 2 * Clog * d ** 2 * K ** (4 * (L - 1)) * a ** -8 * ell ** 3
    else:
        poly = 3 * CJ * Clog * d ** 2 * K ** 2 * a ** -4 * ell ** 2
    out = {
        "DT<=1+0.722dLell": e["DT"] <= 1 + mp.mpf("0.722") * d * L * ell,
        "lnL/lam<=2L+L/2ell": mp.log(L / e["lam"]) <= 2 * L + mp.mpf(L) / 2 * ell,
        "Xi<=3dLell": e["Xi"] <= 3 * d * L * ell,
        "J<=Jbar": e["J"] <= Jbar,
        "lnH<=Gamma": e["lnH"] <= Gam,
        "lnJbar<=lnCJ+(2L+1)ell": mp.log(Jbar) <= mp.log(CJ) + (2 * L + 1) * ell,
        "ln2^(L+5)..<=L+5+ell": mp.log(mp.mpf(2) ** (L + 5) * (d + L + 1) / a) <= L + 5 + ell,
        "Gamma<=poly": Gam <= poly,
    }
    ratios = dict(lnH_over_Gamma=float(e["lnH"] / Gam), Gamma_over_poly=float(Gam / poly), J_over_Jbar=float(e["J"] / Jbar))
    return out, ratios

if __name__ == "__main__":
    fails = {}
    worst = {}
    count = 0
    for L in [2, 3, 4, 5, 8, 12, 20, 40]:
        for d in [1, 2, 3, 10, 100, 1000]:
            for K in [1, 1.5, 10, 1e3, 1e6, 1e12]:
                for a in [1, 0.5, 1e-2, 1e-4, 1e-8]:
                    out, rat = claims(L, d, K, a)
                    count += 1
                    for k, v in out.items():
                        if not v:
                            fails.setdefault(k, []).append((L, d, K, a))
                    for k, v in rat.items():
                        worst[k] = max(worst.get(k, 0), v)
    print(f"grid points: {count}")
    for k in ["DT<=1+0.722dLell", "lnL/lam<=2L+L/2ell", "Xi<=3dLell", "J<=Jbar", "lnH<=Gamma",
              "lnJbar<=lnCJ+(2L+1)ell", "ln2^(L+5)..<=L+5+ell", "Gamma<=poly"]:
        f = fails.get(k, [])
        print(f"  {k:26s}: {'OK' if not f else 'FAIL at ' + str(f[:5]) + (' ...' if len(f) > 5 else '')}  ({len(f)} failures)")
    print("max ratios over grid:", {k: f"{v:.3g}" for k, v in worst.items()})

    # The proof's own justification of 'ln(2^{L+5}(d+L+1)/a) <= L+5+ell' via ln(d+L+1)+ln(1/a) <= ell fails when L+1 > 16 d K;
    # check whether the sub-step (not the conclusion) fails anywhere:
    sub = [(L, d) for L in range(2, 200) for d in [1, 2, 3] if math.log(d + L + 1) > math.log(17 * d)]
    print("sub-step ln(d+L+1) <= ln(17 d K) (K=1) fails for (L,d) e.g.:", sub[:3], "... count", len(sub))

    # Step-1 constants 0.722 and 1.207: 1/(2 ln 2) and 2/ln 17 + 1/2
    print("1/(2 ln2) =", 1 / (2 * math.log(2)), "  1/ln17 =", 1 / math.log(17), "  2/ln17+0.5 =", 2 / math.log(17) + 0.5)
    print("ln(4L(L-1))+L ln2 - 2L for L=2..6:", [round(math.log(4 * L * (L - 1)) + L * math.log(2) - 2 * L, 3) for L in range(2, 7)])
    print("C_J numeric check 65536*3+1 =", 65536 * 3 + 1)
