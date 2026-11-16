#!/usr/bin/env python3
"""
Attack on Propositions 6.2 and 6.3 of research/prove-c/rehearsal-core.md (the last
round can be worse than the random round): an independent exact recomputation of
both examples, in the logarithmic domain, on a grid that includes the edges of the
stated ranges (L = 2, n = L for 6.2; L = 4, n = 100 L for 6.3).

6.2  claim: for every L >= 2 and n >= L,
        E Lambda(M^(n+1)) >= ((L-1)/8) L K ln2 / n   and   avg_t E Lambda(M^(t)) <= L K ln2 / n.
     Remark (iii): in every posterior state beta(M) <= 8.4 L^2/n.
6.3  claim: for L >= 4, n >= 100 L, lambda = 1.1272 sqrt(L) - 1, N = ceil(1.6262 sqrt(L)),
        E beta(M^(n+1)) >= ((L-1)/(40 sqrt(L))) L K ln2 / n   and   avg_t E beta(M^(t)) <= L K ln2 / n.
     Also evaluated: u(M^(n+1)) (probability of an unfaithful run), which the file
     says stays below L K ln2/n in this example.
"""
import math
import numpy as np

def ex62(L, n):
    p = L/(3.0*n); kappa = 8.0*L/n
    ln_eta = math.log(2.0)-8.0*L; ln_phi = -80.0*L
    eta = math.exp(ln_eta)
    lnW = math.log1p(eta+math.exp(ln_eta+ln_phi))
    Kln2 = lnW-ln_eta-ln_phi
    one_m_e = -math.expm1(-kappa)          # 1 - e^{-kappa}
    def early(k):
        # log weights of g, h, f
        lg = -kappa*k; lh = ln_eta; lf = ln_eta+ln_phi
        m = max(lg, lh, lf)
        lnZ = m+math.log(math.exp(lg-m)+math.exp(lh-m)+math.exp(lf-m))
        a = math.exp(lg-lnZ)
        psi = math.exp(lh-lnZ)+math.exp(lf-lnZ)
        KLc = -math.log1p(-a*one_m_e)
        KLr = -math.log(psi)
        KLb = -(lf-lnZ)
        ec = a*one_m_e; er = 1.0-psi; eb = 1.0-math.exp(lf-lnZ)
        Lam = (1-p)*L*KLc+p*(KLr+psi*(L-1)*KLb+(1-psi)*(L-1)*KLc)
        bet = (1-p)*L*ec+p*(er+psi*(L-1)*eb+(1-psi)*(L-1)*ec)
        return Lam, bet, psi
    # state R: r asked, b not asked: weights h : f = 1 : phi
    KLb_R = -ln_phi+math.log1p(math.exp(ln_phi))
    Lam_R = p*(L-1)*KLb_R
    bet_R = p*(L-1)/(1.0+math.exp(ln_phi))
    pE = 1.0; pR = 0.0; pF = 0.0
    sumLam = 0.0; sumBet = 0.0; maxbeta = 0.0
    for t in range(1, n+2):
        Lam_E, bet_E, psi = early(t-1)
        ELam = pE*Lam_E+pR*Lam_R
        Ebet = pE*bet_E+pR*bet_R
        maxbeta = max(maxbeta, bet_E if pE > 0 else 0.0, bet_R if pR > 0 else 0.0)
        if t == n+1:
            lastLam, lastBet = ELam, Ebet
            break
        sumLam += ELam; sumBet += Ebet
        to_r = p/L; to_b = p*psi*(L-1)/L
        pF += pE*to_b+pR*p*(L-1)/L
        pR = pR*(1-p*(L-1)/L)+pE*to_r
        pE = pE*(1-to_r-to_b)
    bound = L*Kln2/n
    return dict(L=L, n=n, Kln2=Kln2, bound=bound, avg=sumLam/n, last=lastLam,
                ratio=lastLam/bound, claim=(L-1)/8.0, pE=pE, lastBet=lastBet,
                maxbeta=maxbeta, betacap=8.4*L*L/n)

def ex63(L, n, lam=None, N=None, cmax=None):
    if lam is None: lam = 1.1272*math.sqrt(L)-1.0
    if N is None: N = math.ceil(1.6262*math.sqrt(L))
    p = L/(3.0*n); kappa = (lam+1.0)/n; eta = math.exp(-lam)
    Kln2 = N*math.log(2.0)+math.log1p(math.exp(lam))
    if cmax is None: cmax = int(4*L+200)
    cs = np.arange(cmax+1)
    frac = (1.0-1.0/N)**cs                 # E[1 - |A|/N | c trap questions]
    alive = np.zeros(cmax+1); dead = np.zeros(cmax+1)
    alive[0] = 1.0
    one_m_e = -math.expm1(-kappa)
    sumBet = 0.0; dropped = 0.0
    for t in range(1, n+2):
        k = (t-1)-cs                        # questions at c so far, for alive states
        G = 1.0/(1.0+eta*np.exp(kappa*np.maximum(k, 0)))   # = e^{-kappa k}/(e^{-kappa k}+eta)
        ec = G*one_m_e
        beta_alive = (1-p)*L*ec+p*(G+(1-G)*(L-1)*0.5*frac+G*(L-1)*ec)
        beta_dead = p*(L-1)*0.5*frac
        # probability that the run is unfaithful
        # z = 0: 1-(1-ec)^L ; z>=1: G (wrong at r) + (1-G) * frac * (1-2^-(L-1))  [+ wrong calls at c after a wrong r are already counted]
        u_alive = (1-p)*(1-(1-ec)**L)+p*(G+(1-G)*frac*(1-0.5**(L-1)))
        u_dead = p*frac*(1-0.5**(L-1))
        Ebet = float(alive@beta_alive+dead@beta_dead)
        Eu = float(alive@u_alive+dead@u_dead)
        if t == n+1:
            lastBet, lastU = Ebet, Eu
            break
        sumBet += Ebet
        to_r = p/L
        to_trap_alive = p*(1-G)*(L-1)/L
        to_trap_dead = p*(L-1)/L
        new_alive = alive*(1-to_r-to_trap_alive)
        mv = alive*to_trap_alive
        new_alive[1:] += mv[:-1]; dropped += mv[-1]
        new_dead = dead*(1-to_trap_dead)+alive*to_r
        mv = dead*to_trap_dead
        new_dead[1:] += mv[:-1]; dropped += mv[-1]
        alive, dead = new_alive, new_dead
    bound = L*Kln2/n
    return dict(L=L, n=n, N=N, lam=lam, Kln2=Kln2, bound=bound, avg=sumBet/n, last=lastBet,
                ratio=lastBet/bound, claim=(L-1)/(40.0*math.sqrt(L)), lastU=lastU,
                u_ratio=lastU/bound, dropped=dropped)

def main():
    print("== Proposition 6.2 (divergence of the last round) ==")
    worst_margin = 1e9
    for L in [2, 3, 4, 5, 8, 16, 40]:
        for n in sorted(set([L, L+1, 2*L, 5*L, 50*L, 4000])):
            if n < L: continue
            r = ex62(L, n)
            ok1 = r['ratio'] >= r['claim']; ok2 = r['avg'] <= r['bound']*(1+1e-12)
            ok3 = r['maxbeta'] <= r['betacap']*(1+1e-12)
            worst_margin = min(worst_margin, r['ratio']/r['claim'])
            print(f"L={L:3d} n={n:6d}: last/bound = {r['ratio']:8.4f} >= (L-1)/8 = {r['claim']:6.3f}: {ok1};  avg/bound = {r['avg']/r['bound']:.4f} <= 1: {ok2};  "
                  f"max beta over states = {r['maxbeta']:.4g} <= 8.4 L^2/n = {r['betacap']:.4g}: {ok3}")
    print(f"smallest (last/bound)/((L-1)/8) on the grid: {worst_margin:.4f}  (the claim needs >= 1)")
    print()
    print("== Proposition 6.3 (number of unfaithful calls of the last round) ==")
    worst_margin = 1e9
    for L in [4, 5, 9, 16, 25, 100, 400, 1600]:
        for mult in [100, 101, 300, 1000]:
            n = mult*L
            if L >= 400 and mult > 100: continue
            r = ex63(L, n)
            ok1 = r['ratio'] >= r['claim']; ok2 = r['avg'] <= r['bound']*(1+1e-12)
            worst_margin = min(worst_margin, r['ratio']/r['claim'])
            print(f"L={L:5d} n={n:7d} N={r['N']:3d} lambda={r['lam']:.3f}: last/bound = {r['ratio']:.4f} >= (L-1)/(40 sqrt L) = {r['claim']:.4f}: {ok1};  "
                  f"avg/bound = {r['avg']/r['bound']:.4f} <= 1: {ok2};  u(last)/bound = {r['u_ratio']:.4f};  dropped {r['dropped']:.1e}")
    print(f"smallest (last/bound)/claim on the grid: {worst_margin:.4f}  (the claim needs >= 1)")

if __name__ == '__main__':
    main()
