#!/usr/bin/env python3
"""Adversarial exact checks for Sections 4 and 5 of research/prove-b/hellinger-runs.md
(Theorem A, the per-call mixture, Theorem B, Theorem B', Proposition 5.6) and for two statements
proposed in the attack report.

For Theorems A, B, B' only the run laws matter: a hypothesis is a probability vector on a finite set of
R runs, the recorded runs are N independent draws from q*, and the data are the vector of counts.
All expectations are exact sums over the count vectors with multinomial weights.

 (1) Theorem 4.2(a): sum_t E KL(q*||qhat_t) <= min_nu [ln(1/w(nu)) + N KL(q*||q_nu)]   (random + hill climbing)
 (2) Theorem 5.1(a),(b): expected posterior mass of B_eps and the MAP event, against beta, all admissible s
 (3) Theorem 5.5: tempered posterior
 (4) NEW (attack report, finding on Proposition 5.6): for lambda > 1, alpha = 1/lambda,
        E sum_nu Pi_lambda(nu) (-ln A_alpha(nu)) <= ln(1/w(nu*))/N + alpha KL(q*||q_nu*)
     and the same with the lambda-MAP in place of the posterior average; hence in H^2 with the factor
     1/(2 min(alpha, 1-alpha)).   Truth inside or outside the class.
 (5) Example 4.6: the law that Theorem A is about, (1/N) sum_t Q_{M_t}, by enumeration of all sequences of
     top-level inputs; table of the smallest L at which the per-call mixture violates the two bounds.

Run:  python3 hellinger-runs_attack_recorded.py        (about 2 minutes)
"""
import math, time, itertools
import numpy as np
from math import lgamma

rng = np.random.default_rng(4626)
LN2 = math.log(2.0)

def count_vectors(N, R):
    if R == 1:
        yield (N,); return
    for k in range(N + 1):
        for rest in count_vectors(N - k, R - 1):
            yield (k,) + rest

def multinom_logp(c, logq):
    N = sum(c)
    s = lgamma(N + 1)
    for ci, lq in zip(c, logq):
        if ci > 0:
            if lq == -np.inf: return -np.inf
            s += ci * lq - lgamma(ci + 1)
    return s

def safe_log(a):
    with np.errstate(divide='ignore'):
        return np.log(a)

def kl(p, q):
    with np.errstate(divide='ignore', invalid='ignore'):
        t = np.where(p > 0, p * (safe_log(p) - safe_log(q)), 0.0)
    return float(t.sum())

def random_class(inside):
    R = int(rng.integers(2, 5)); H = int(rng.integers(2, 7))
    conc = float(rng.choice([0.3, 1.0, 3.0]))
    q = rng.dirichlet(np.ones(R) * conc, size=H)
    if rng.random() < 0.4:                      # exact zeros in some hypotheses
        z = rng.random(q.shape) < 0.25
        q = np.where(z, 0.0, q); q = np.where(q.sum(1, keepdims=True) > 0, q, 1.0); q = q / q.sum(1, keepdims=True)
    ell = rng.integers(1, 7, size=H).astype(float)
    while (2.0 ** (-ell)).sum() > 1: ell += 1
    if rng.random() < 0.5:                      # non-integer lengths with Kraft sum exactly 1
        w = rng.dirichlet(np.ones(H) * 0.6); w = np.maximum(w, 1e-5); w /= w.sum(); ell = -np.log2(w)
    w = 2.0 ** (-ell)
    if inside:
        qs = q[0].copy()
    else:
        qs = rng.dirichlet(np.ones(R) * conc)
        if rng.random() < 0.3: qs = 0.5 * qs + 0.5 * q[int(rng.integers(H))]
    return q, w, ell, qs

def loglik(c, logq):
    """log-likelihood of each hypothesis for counts c (0 * -inf := 0)."""
    c = np.asarray(c, float)
    with np.errstate(invalid='ignore'):
        t = np.where(c[None, :] > 0, c[None, :] * logq, 0.0)
    return t.sum(1)

# ------------------------------------------------------------------ (1) Theorem A
def thmA_gap(q, w, qs, N):
    R = q.shape[1]; logq = safe_log(q); logqs = safe_log(qs)
    tot = 0.0
    for t in range(1, N + 1):
        for c in count_vectors(t - 1, R):
            lp = multinom_logp(c, logqs)
            if lp == -np.inf: continue
            ll = loglik(c, logq)
            if not np.isfinite(ll).any(): return None       # posterior undefined on a set of positive probability
            post = w * np.exp(ll - ll[np.isfinite(ll)].max()); post /= post.sum()
            qhat = post @ q
            tot += math.exp(lp) * kl(qs, qhat)
    rhs = min(math.log(1 / w[h]) + N * kl(qs, q[h]) for h in range(len(w)))
    return tot, rhs

# ------------------------------------------------------------------ (2),(3),(4)
def posterior_checks(q, w, ell, qs, N, lam, eps2, inside):
    H, R = q.shape; logq = safe_log(q); logqs = safe_log(qs)
    bc = np.sqrt(q * qs[None]).sum(1); H2 = 1 - bc
    alpha = 1.0 / lam
    def A(a):
        with np.errstate(divide='ignore', invalid='ignore'):
            return np.where(qs[None] > 0, qs[None] ** (1 - a) * q ** a, 0.0).sum(1)
    A_al = A(alpha); A_half = A(0.5)
    with np.errstate(divide='ignore'):
        mlogA_al = -np.log(A_al); mlogA_half = -np.log(A_half)
    E_mass = 0.0; P_map = 0.0; E_lam_renyi = 0.0; E_map_renyi = 0.0; E_temp = 0.0; E_lam_H2 = 0.0; E_map_H2 = 0.0
    bad = H2 >= eps2
    for c in count_vectors(N, R):
        lp = multinom_logp(c, logqs)
        if lp == -np.inf: continue
        pr = math.exp(lp)
        ll = loglik(c, logq)
        fin = np.isfinite(ll)
        if not fin.any(): return None
        a = lam * np.log(w) + ll; a = a - a[fin].max(); post = np.where(fin, np.exp(a), 0.0); post /= post.sum()
        E_mass += pr * post[bad].sum()
        if inside and bad.any():
            sc = lam * np.log(w) + ll
            if (sc[bad] >= sc[0] - 1e-12).any(): P_map += pr
        # lambda-posterior and lambda-MAP against the Renyi-type quantity -ln A_alpha (hypotheses with A = 0 have posterior 0)
        with np.errstate(invalid='ignore'):
            E_lam_renyi += pr * float(np.where(post > 0, post * mlogA_al, 0.0).sum())
        E_lam_H2 += pr * float((post * H2).sum())
        sc = np.where(fin, lam * np.log(w) + ll, -np.inf)
        cand = np.flatnonzero(sc >= sc.max() - 1e-12)
        worst = cand[np.argmax(mlogA_al[cand])]               # adversarial tie-breaking
        E_map_renyi += pr * mlogA_al[worst]; E_map_H2 += pr * H2[cand].max()
        # tempered posterior, alpha = 1/2
        b = np.log(w) + 0.5 * ll; b = b - b[fin].max(); tp = np.where(fin, np.exp(b), 0.0); tp /= tp.sum()
        with np.errstate(invalid='ignore'):
            E_temp += pr * float(np.where(tp > 0, tp * mlogA_half, 0.0).sum())
    kls = np.array([kl(qs, q[h]) for h in range(H)])
    oracle_al = float(np.min(np.log(1 / w) / N + alpha * kls))
    oracle_half = float(np.min(np.log(1 / w) / N + 0.5 * kls))
    out = dict(E_mass=E_mass, P_map=P_map, E_lam_renyi=E_lam_renyi, E_map_renyi=E_map_renyi, E_temp=E_temp,
               oracle_al=oracle_al, oracle_half=oracle_half, E_lam_H2=E_lam_H2, E_map_H2=E_map_H2,
               H2fac=2 * min(alpha, 1 - alpha))
    if inside:
        betas = []
        for s in np.linspace(alpha, 0.999, 25):
            betas.append(2.0 ** (lam * s * ell[0]) * (1 - eps2) ** (2 * min(s, 1 - s) * N))
        out['beta_min'] = min(betas)
    return out

# ------------------------------------------------------------------ (5) Example 4.6
def example46(N, L):
    """exact E KL(Q_f || Qbar) and E TV(Qbar, Q_f), Qbar = (1/N) sum_t Q_{M_t}; also the same for the draw per run."""
    B = 2 * N
    EKL = ETV = EKLrun = ETVrun = 0.0
    for zs in itertools.product(range(B), repeat=N):
        visited = set(); pz_call = np.zeros(B); pz_run = np.zeros(B)   # averages over t of Q(zeros | z)
        for t in range(N):
            v = len(visited); om = 1.0 / (2 * B - v)
            for z in range(B):
                if z in visited: pz_call[z] += 1.0; pz_run[z] += 1.0
                else: pz_call[z] += (1 - om) ** L; pz_run[z] += (1 - om)
            visited.add(zs[t])
        pz_call /= N; pz_run /= N
        EKL += np.mean(-np.log(pz_call)); ETV += np.mean(1 - pz_call)
        EKLrun += np.mean(-np.log(pz_run)); ETVrun += np.mean(1 - pz_run)
    n = B ** N
    return EKL / n, ETV / n, EKLrun / n, ETVrun / n

if __name__ == '__main__':
    t0 = time.time()
    # (1)
    worst = -1e9; nrun = 0
    for rep in range(1500):
        q, w, ell, qs = random_class(inside=bool(rep % 2)); N = int(rng.integers(1, 9))
        r = thmA_gap(q, w, qs, N)
        if r is None or not np.isfinite(r[1]): continue
        nrun += 1; worst = max(worst, r[0] - r[1])
    print("(1) Theorem 4.2(a), %d random instances (R <= 4 runs, <= 6 hypotheses, N <= 8), truth inside or outside:" % nrun)
    print("    max of [sum_t E KL(q*||qhat_t)] - min_nu[ln(1/w) + N KL(q*||q_nu)] = %.3e  (must be <= 0)" % worst)
    # tightness: two mutually singular hypotheses
    q = np.array([[1.0, 0.0], [0.0, 1.0]]); w = np.array([0.25, 0.75]); r = thmA_gap(q, w, q[0], 5)
    print("    tight case (two singular hypotheses, w(P) = 1/4, N = 5): lhs = %.6f, rhs = %.6f" % r)
    # (2),(3),(4)
    v_mass = v_map = v_temp = v_lr = v_mr = v_lh = v_mh = -1e9; n_in = n_all = 0
    top_lr = top_mr = 0.0
    for rep in range(4000):
        inside = bool(rep % 2)
        q, w, ell, qs = random_class(inside)
        N = int(rng.integers(1, 31)); lam = float(rng.choice([1.02, 1.2, 1.5, 2.0, 2.0, 3.0, 5.0])); eps2 = float(rng.choice([0.002, 0.01, 0.05, 0.2]))
        o = posterior_checks(q, w, ell, qs, N, lam, eps2, inside)
        if o is None or not np.isfinite(o['oracle_al']): continue
        n_all += 1
        v_temp = max(v_temp, o['E_temp'] - o['oracle_half'])
        v_lr = max(v_lr, o['E_lam_renyi'] - o['oracle_al']); v_mr = max(v_mr, o['E_map_renyi'] - o['oracle_al'])
        v_lh = max(v_lh, o['E_lam_H2'] - o['oracle_al'] / o['H2fac']); v_mh = max(v_mh, o['E_map_H2'] - o['oracle_al'] / o['H2fac'])
        if o['oracle_al'] > 0:
            top_lr = max(top_lr, o['E_lam_renyi'] / o['oracle_al']); top_mr = max(top_mr, o['E_map_renyi'] / o['oracle_al'])
        if inside:
            n_in += 1
            v_mass = max(v_mass, o['E_mass'] - o['beta_min']); v_map = max(v_map, o['P_map'] - o['beta_min'])
    print("(2) Theorem 5.1, %d instances with the human in the class: max of E[mass of B_eps] - min_s beta = %.3e ; max of Pr[MAP event] - min_s beta = %.3e (must be <= 0)" % (n_in, v_mass, v_map))
    print("(3) Theorem 5.5 (alpha = 1/2), %d instances: max of lhs - rhs = %.3e (must be <= 0)" % (n_all, v_temp))
    print("(4) NEW oracle inequality for the posterior with weights w^lambda and for the lambda-MAP (alpha = 1/lambda), %d instances:" % n_all)
    print("    posterior: max of E sum Pi_lam (-ln A_alpha) - min_nu[ln(1/w)/N + alpha KL] = %.3e ; largest ratio lhs/rhs = %.4f" % (v_lr, top_lr))
    print("    MAP (worst tie-breaking): max of E(-ln A_alpha(MAP)) - the same = %.3e ; largest ratio = %.4f" % (v_mr, top_mr))
    print("    in H^2 (divided by 2 min(alpha,1-alpha)): posterior %.3e, MAP %.3e   (all must be <= 0)" % (v_lh, v_mh))
    # (5)
    print("(5) Example 4.6 with B = 2N, exact expectation over all (2N)^N sequences of top-level inputs; law = average over t of Q_{M_t}")
    print("    N  L | E KL per-call   ln2/N   L/(8N) | E TV per-call  sqrt(ln2/(2N)) | E KL draw-per-run  E TV draw-per-run")
    for N in [1, 2, 3, 4, 5]:
        for L in [1, 2, 3, 4, 5, 6, 12, 24]:
            a, b, c, d = example46(N, L)
            flag = ("KL>bound " if a > LN2 / N else "") + ("TV>bound" if b > math.sqrt(LN2 / (2 * N)) else "")
            print("    %d %2d | %.5f  %.5f  %.5f | %.5f  %.5f | %.5f  %.5f  %s" % (N, L, a, LN2 / N, L / (8 * N), b, math.sqrt(LN2 / (2 * N)), c, d, flag))
    print("time %.0f s" % (time.time() - t0))
