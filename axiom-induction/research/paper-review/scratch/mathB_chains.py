"""Independent check (review B) of the exact chain laws of Sections univ (C_min, C_open).

Written from the paper's definitions only; does not import any track code.
phi = 0+x=x.  States of a chain conclusion:
  ('all', k)  : forall y phi(S^k y)          (k = 0 is forall x phi)
  ('cl', m)   : phi(S^m 0)                   (closed numeral instance)
  ('par', k)  : phi(S^k p)                   (instance at the parameter p)
A chain: cite (prob K) an axiom, then a sequence of operations, each forall-E (prob c, term t ~ Q)
or Gen (prob g); every prefix of a chain is itself a chain whose conclusion is an output.
mu(s) = sum over chains with conclusion s.  We compute mu by iterating the one-step operator.
"""
import math
import numpy as np
from scipy.optimize import minimize

M = 200  # numeral cutoff; Q_num tail 2^-200 negligible


def Qnum(q):
    return np.array([(1 - q) * q ** j for j in range(M)])


def step(dist, c, g, rho, q):
    """Apply one operation (forall-E with prob c, Gen with prob g) to a distribution of states."""
    out = {}
    Qn = Qnum(q)
    for s, w in dist.items():
        kind, k = s
        if kind == 'all':
            # forall-E with term t ~ Q_open = rho [p] + (1-rho) Q_num
            out[('par', k)] = out.get(('par', k), 0) + w * c * rho
            for m in range(M - k):
                out[('cl', k + m)] = out.get(('cl', k + m), 0) + w * c * (1 - rho) * Qn[m]
        elif kind == 'par':
            out[('all', k)] = out.get(('all', k), 0) + w * g  # Gen abstracts p
        # closed instances: no rule applies
    return out


def law(initial, c, g, rho, q, iters=200):
    tot = dict(initial)
    cur = dict(initial)
    for _ in range(iters):
        cur = step(cur, c, g, rho, q)
        if not cur:
            break
        for s, w in cur.items():
            tot[s] = tot.get(s, 0) + w
    return tot


def cite_template(k, weight, K, rho, q, guard_closed):
    """Cite phi(S^k z): z ~ Q_open (unguarded) or Q_num (closed guard)."""
    Qn = Qnum(q)
    d = {}
    if guard_closed:
        for m in range(M - k):
            d[('cl', k + m)] = d.get(('cl', k + m), 0) + K * weight * Qn[m]
    else:
        d[('par', k)] = K * weight * rho
        for m in range(M - k):
            d[('cl', k + m)] = d.get(('cl', k + m), 0) + K * weight * (1 - rho) * Qn[m]
    return d


def merge(*ds):
    out = {}
    for d in ds:
        for s, w in d.items():
            out[s] = out.get(s, 0) + w
    return out


def theory_law(axioms, c, g, rho, q):
    """axioms: list of (type, k, weight); type in {'all','tpl_open','tpl_closed','sent'}."""
    K = 1 - c - g
    init = {}
    for typ, k, w in axioms:
        if typ == 'all':
            init = merge(init, {('all', k): K * w})
        elif typ == 'tpl_open':
            init = merge(init, cite_template(k, w, K, rho, q, False))
        elif typ == 'tpl_closed':
            init = merge(init, cite_template(k, w, K, rho, q, True))
        elif typ == 'sent':
            init = merge(init, {('cl', k): K * w})
    return law(init, c, g, rho, q)


def closed_vec(L):
    v = np.zeros(M)
    for (kind, k), w in L.items():
        if kind == 'cl' and k < M:
            v[k] += w
    return v


def KL_closed(L, q):
    """KL(P* || normalised L) with P* = Q_num on closed instances."""
    Z = sum(L.values())
    p = closed_vec(L) / Z
    Ps = Qnum(q)
    mask = Ps > 1e-300
    return float(np.sum(Ps[mask] * (np.log(Ps[mask]) - np.log(np.maximum(p[mask], 1e-300)))))


def main():
    c, g, rho, q = 0.3, 0.2, 0.1, 0.5
    K = 1 - c - g
    Wo = math.log((1 + g * rho) / (1 - rho))
    print('C_open defaults c,g,rho,q =', c, g, rho, q, ' W_o =', round(Wo, 6))
    Hall = theory_law([('all', 0, 1.0)], c, g, rho, q)
    Hopen = theory_law([('tpl_open', 0, 1.0)], c, g, rho, q)
    Hsch = theory_law([('tpl_closed', 0, 1.0)], c, g, rho, q)
    Zs = {n: sum(L.values()) for n, L in [('all', Hall), ('open', Hopen), ('sch', Hsch)]}
    print('Z_all, Z_open, Z_sch:', {k: round(v, 10) for k, v in Zs.items()})
    print('  predicted         :', round(K * (1 + c) / (1 - g * c * rho), 10), round(K * (1 + g * rho) / (1 - g * c * rho), 10), K)
    # per closed datum normalised ratios
    t = ('cl', 3)
    r_open_sch = (Hopen[t] / Zs['open']) / (Hsch[t] / Zs['sch'])
    r_all_sch = (Hall[t] / Zs['all']) / (Hsch[t] / Zs['sch'])
    r_all_open = (Hall[t] / Zs['all']) / (Hopen[t] / Zs['open'])
    print('normalised ratios open:sch, all:sch, all:open =', round(r_open_sch, 6), round(r_all_sch, 6), round(r_all_open, 6))
    print('  predicted                                   =', round((1 - rho) / (1 + g * rho), 6), round(c * (1 - rho) / (1 + c), 6), round(c * (1 + g * rho) / (1 + c), 6))
    print('unnormalised mu_all/mu_open at forall x phi =', round(Hall[('all', 0)] / Hopen[('all', 0)], 6), ' predicted 1/(g rho) =', 1 / (g * rho))
    print('KL(H_all) =', round(KL_closed(Hall, q), 6), ' predicted ln((1+c)/(c(1-rho))) =', round(math.log((1 + c) / (c * (1 - rho))), 6))
    print('KL(H_open)=', round(KL_closed(Hopen, q), 6), ' predicted W_o =', round(Wo, 6))

    # R_k: sentences phi(S^j 0), j<k, weights v_j; template phi(S^k z) unguarded, weight u.
    print('\nR_k: numerical inf_w KL vs q^k W_o')
    for (cc, gg, rr, qq) in [(0.3, 0.2, 0.1, 0.5), (0.5, 0.3, 0.3, 0.8), (0.2, 0.2, 0.5, 0.9)]:
        Wo2 = math.log((1 + gg * rr) / (1 - rr))
        res = []
        for k in range(1, 5):
            def f(x):
                ex = np.exp(x - x.max())
                w = ex / ex.sum()
                ax = [('sent', j, w[j]) for j in range(k)] + [('tpl_open', k, w[k])]
                L = theory_law(ax, cc, gg, rr, qq)
                return KL_closed(L, qq)
            best = None
            for trial in range(3):
                x0 = np.random.default_rng(trial).normal(size=k + 1)
                r = minimize(f, x0, method='Nelder-Mead', options={'xatol': 1e-10, 'fatol': 1e-13, 'maxiter': 6000})
                if best is None or r.fun < best.fun:
                    best = r
            res.append((k, best.fun, qq ** k * Wo2))
        print('  (c,g,rho,q)=', (cc, gg, rr, qq), ' '.join(f'k={k}: {a:.6f}/{b:.6f}' for k, a, b in res))

    # Waste lemma: random check
    rng = np.random.default_rng(1)
    worst = 0
    for _ in range(2000):
        tau = rng.uniform(0.01, 1)
        rw = rng.uniform(0.01, 5)
        pts = np.linspace(1e-6, 1 / (1 + rw) - 1e-9, 20001)
        ph = 1 - (1 + rw) * pts
        val = np.where(ph > 0, (1 - tau) * np.log(np.where(ph > 0, (1 - tau) / np.maximum(ph, 1e-300), 1)) + tau * np.log(tau / pts), np.inf)
        if tau == 1:
            val = tau * np.log(tau / pts)
        worst = max(worst, abs(val.min() - tau * math.log(1 + rw)))
    print('\nwaste lemma: max |grid min - tau ln(1+r_w)| over 2000 random (tau, r_w):', f'{worst:.2e}')


if __name__ == '__main__':
    main()
