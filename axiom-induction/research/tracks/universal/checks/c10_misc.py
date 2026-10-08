"""c10: smaller revision checks (referee issues m4, m5, m8, m9, m11, missed questions 1, 4, 5).

(a) m8   The calculus {cite p_c, forall-elim c, and-intro a, and-elim e} with the and-rules on quantified formulas:
         own Monte Carlo sampler and own fixed-point computation of the 'spine' formula R = c D_all^2 / D_sigma.
(b) m4   Learned weights under L1-sel with a background schema B = {psi(z)} (psi = Sx != 0, disjoint instances):
         Bayes factor (B + forall x phi) : (B + sigma_phi) -> h(w*) = c/(c + w*(1-c))^2 (Prop B2), by quadrature.
         Also: the pointwise ordering under L1 and L1-norm (Thm B with learned weights), asserted on a grid.
(c) m5   Prop U12(b) with equal priors on T_both and T_sch+B: log Bayes factor against n, for several f_q, against
         the predicted linear rate; per-instance log-ratio at several theta.
(d) m9   Inconsistent hypotheses in the class of c2: mass Inc of inconsistent theories, and Bel_cons(forall x phi).
(e) Q1   Unknown selection filter: joint posterior over (theory, filter), against the predicted prior-share limit.
(f) Q4   Prior sensitivity: the prior share of H_forall in {H_forall, H_sch} under the codes used across tracks.
(g) m11  Borel-Cantelli for the maximum of geometric numerals: P(K_n >= 3 log_{1/q} n) <= n^-2.
(h) Q5   Noise mixtures keep the direction of Thm B: random-parameter assertion.
Seeded.  Output: c10_misc.out."""
import math
import random
import sys
import time

sys.dont_write_bytecode = True
import numpy as np
from scipy.special import gammaln

from common import P, NumLaw, GWLaw, FormLaw, PHIS, size, logsumexp, NEG_INF
from rev_common import LN2, log_int, log_beta_fn

OUT = []


def say(s=''):
    print(s, flush=True)
    OUT.append(s)


# ---------------------------------------------------------------------------------------------- (a)
def catalan_D(x):
    return 1.0 if x == 0 else (1 - math.sqrt(max(0.0, 1 - 4 * x))) / (2 * x)


def spine(pc, c, a, e, theory):
    """least fixed point by iteration from 0 of Z = D(eaZ)(pc + c P_U + a Z^2), P_U = pc D (forall) or 0 (sigma)"""
    Z = 0.0
    for _ in range(200000):
        d = catalan_D(e * a * Z)
        PU = pc * d if theory == 'forall' else 0.0
        Zn = d * (pc + c * PU + a * Z * Z)
        if abs(Zn - Z) < 1e-15:
            Z = Zn
            break
        Z = Zn
    d = catalan_D(e * a * Z)
    inst = c * pc * d * d if theory == 'forall' else pc * d
    return Z, d, inst


def sample_and(theory, pc, c, a, e, rng, budget):
    budget[0] -= 1
    if budget[0] < 0:
        raise OverflowError
    u = rng.random()
    if u < pc:
        return 'U' if theory == 'forall' else 'I'
    if u < pc + c:
        p = sample_and(theory, pc, c, a, e, rng, budget)
        return 'I' if p == 'U' else None
    if u < pc + c + a:
        l = sample_and(theory, pc, c, a, e, rng, budget)
        if l is None:
            return None
        r = sample_and(theory, pc, c, a, e, rng, budget)
        if r is None:
            return None
        return ('&', l, r)
    p = sample_and(theory, pc, c, a, e, rng, budget)
    if not isinstance(p, tuple):
        return None
    return p[1] if rng.random() < 0.5 else p[2]


def part_a():
    say('(a) and-detours on quantified formulas (Remark after U3): own sampler, own fixed point')
    sys.setrecursionlimit(100000)
    pc, c, a, e = 0.35, 0.15, 0.25, 0.25
    N = 1000000
    res = {}
    for th, seed in [('forall', 101), ('sigma', 102)]:
        rng = random.Random(seed)
        inst = trunc = succ = 0
        for _ in range(N):
            try:
                f = sample_and(th, pc, c, a, e, rng, [20000])
            except OverflowError:
                trunc += 1
                continue
            if f is not None:
                succ += 1
                if f == 'I':
                    inst += 1
        Z, d, pi = spine(pc, c, a, e, th)
        res[th] = (inst / N, pi, succ / N, Z, d, trunc)
        say('  %-6s P(instance): MC %.5f, fixed point %.5f | P(success): MC %.5f, fixed point %.5f | D = %.5f | '
            'truncated %d' % (th, inst / N, pi, succ / N, Z, d, trunc))
    pf, ps = res['forall'][0], res['sigma'][0]
    R = pf / ps
    se = R * math.sqrt((1 - pf) / (pf * N) + (1 - ps) / (ps * N))
    Rx = res['forall'][1] / res['sigma'][1]
    say('  R = P_forall(instance)/P_sigma(instance): MC %.5f +- %.5f, fixed point %.5f, c = %.2f, (R_MC - c)/se = %.1f'
        % (R, se, Rx, c, (R - c) / se))


# ---------------------------------------------------------------------------------------------- (b)
def part_b():
    say('\n(b) learned weights, background B = {psi(z)} with disjoint instances, C_min, c = 0.3, uniform weight prior')
    c = 0.3

    def h(we):
        return c / (c + we * (1 - c)) ** 2

    # pointwise ordering under L1 and L1-norm, on a grid of w, for both datum kinds (phi-instance, psi-instance)
    worst = -1.0
    for w in np.linspace(0.001, 0.999, 999):
        for Zs in [1 - c, 0.5, 1.0]:  # Z_sigma (1-c for qf phi); other values allowed by Thm B's argument
            ZB = 0.7
            Zall = (1 - w) * ZB + w * ((1 - c) + c * Zs)
            Zsch = (1 - w) * ZB + w * Zs
            for PB, Ps in [(0.0, 0.2), (0.3, 0.0), (0.1, 0.1)]:
                l1 = ((1 - w) * PB + w * c * Ps) - ((1 - w) * PB + w * Ps)
                l1n = ((1 - w) * PB + w * c * Ps) / Zall - ((1 - w) * PB + w * Ps) / Zsch
                worst = max(worst, l1, l1n)
    say('  pointwise L1 and L1-norm: max of P_{B+forall,w}(d) - P_{B+sigma,w}(d) over the grid = %.2e (<= 0)' % worst)
    assert worst <= 1e-15
    say('  L1-sel Bayes factor (B+forall):(B+sigma) = E_Beta(n_phi+1, n_psi+1)[h], h(w) = c/(c+w(1-c))^2')
    for wstar in [0.1, 0.3, 0.5, 0.8]:
        row = []
        for n in [10, 100, 1000, 10 ** 4, 10 ** 5]:
            vals = []
            for s in range(10):
                rng = np.random.default_rng(1200 + s)
                nphi = int(rng.binomial(n, wstar))
                npsi = n - nphi

                def g_all(t):  # integrand over w (uniform prior) of w_e(w)^nphi (1-w_e(w))^npsi, w = sigmoid(t)
                    lw = -np.logaddexp(0.0, -t)
                    l1w = -np.logaddexp(0.0, t)
                    w = np.exp(lw)
                    den = np.log((1 - w) + w * c)
                    lwe = math.log(c) + lw - den
                    l1we = l1w - den
                    return nphi * lwe + npsi * l1we + lw + l1w

                def g_sch(t):
                    lw = -np.logaddexp(0.0, -t)
                    l1w = -np.logaddexp(0.0, t)
                    return nphi * lw + npsi * l1w + lw + l1w
                vals.append(math.exp(log_int(g_all) - log_int(g_sch)))
            row.append('%.4f' % np.mean(vals))
        say('  w* = %.1f: mean BF at n = 10, 1e2, 1e3, 1e4, 1e5: %s ; h(w*) = %.4f' % (wstar, ' '.join(row), h(wstar)))
    say('  h(w) > 1 iff w < sqrt(c)/(1+sqrt(c)) = %.4f; h ranges over [c, 1/c] = [%.2f, %.2f]'
        % (math.sqrt(c) / (1 + math.sqrt(c)), c, 1 / c))


# ---------------------------------------------------------------------------------------------- (c)
def part_c():
    say('\n(c) Prop U12(b) with equal priors on T_both and T_sch+B (C_min, c = 0.3, uniform weight prior)')
    c = 0.3
    for L in [3, 10]:
        SB = sum(c ** k for k in range(L + 2))

        def both_ll(nq, ni):
            def g(t):
                lt = -np.logaddexp(0.0, -t)
                l1t = -np.logaddexp(0.0, t)
                th = np.exp(lt)
                return nq * lt + ni * np.log(1 - th + th * c) - (nq + ni) * np.log1p(th * c) + lt + l1t
            return log_int(g)

        def schB_ll(nq, ni):
            def g(t):
                lt = -np.logaddexp(0.0, -t)
                l1t = -np.logaddexp(0.0, t)
                th = np.exp(lt)
                ZB = th * SB + 1 - th
                return nq * (lt + L * math.log(c)) + ni * np.log((1 - th) + th * c ** (L + 1)) - (nq + ni) * np.log(ZB) + lt + l1t
            return log_int(g)

        def rate(fq):
            ths = np.linspace(1e-6, 1 - 1e-6, 200001)
            a = fq * np.log(ths / (1 + ths * c)) + (1 - fq) * np.log((1 - ths + ths * c) / (1 + ths * c)) if fq > 0 else \
                np.log((1 - ths + ths * c) / (1 + ths * c))
            ZB = ths * SB + 1 - ths
            b = (fq * np.log(ths * c ** L / ZB) if fq > 0 else 0.0) + (1 - fq) * np.log(((1 - ths) + ths * c ** (L + 1)) / ZB)
            return float(np.max(a) - np.max(b))
        say('  L = %d: per-instance log P_both - log P_sch+B at theta = 0.05, 0.2, 0.5, 0.9: %s'
            % (L, ' '.join('%.3f' % (math.log((1 - t + t * c) / (1 + t * c)) - math.log(((1 - t) + t * c ** (L + 1)) / (t * SB + 1 - t)))
                           for t in [0.05, 0.2, 0.5, 0.9])))
        for fq in [0.0, 0.01, 0.05, 0.2]:
            row = []
            for n in [10, 100, 1000, 10 ** 4, 10 ** 5]:
                vals = []
                for s in range(20):
                    rng = np.random.default_rng(1300 + s)
                    nq = int(rng.binomial(n, fq))
                    vals.append(both_ll(nq, n - nq) - schB_ll(nq, n - nq))
                row.append('%9.3f' % np.mean(vals))
            pr = rate(fq)
            say('    f_q = %.2f: mean log BF (T_both : T_sch+B) at n = 10..1e5: %s | predicted slope %.4f/datum%s'
                % (fq, ' '.join(row), pr, '' if fq > 0 else ' (limit log(1+c+..+c^L) = %.3f)'
                   % math.log(sum(c ** k for k in range(L + 1)))))


# ---------------------------------------------------------------------------------------------- (d)
INCONSISTENT = {  # over-general templates of c2 that have a refutable instance in pure logic with equality
    '?A': '?A has the instance ~(0=0)',
    '~?B9': 'instance ~(0=0)',
    '~?y9=0': 'instance ~(0=0)',
    '~S?z=?y9': 'instance ~(S0=S0)',
}


def part_d():
    say('\n(d) inconsistent hypotheses in the class of c2 (20 seeds, n <= 50): Inc = posterior mass of inconsistent '
        'theories; Bel_cons = mass of consistent provers of forall x phi (= H_forall here)')
    import c2_odds as c2
    from common import pp
    NS = [0, 1, 2, 5, 10, 20, 50]
    for lawname, law in [('numerals q=1/2', NumLaw(0.5)), ('GW', GWLaw())]:
        flaw = FormLaw(law)
        for phiname, (s_sch, s_all) in PHIS.items():
            sig, al = P(s_sch), P(s_all)
            og = c2.overgeneral(sig) + [P('?A')]
            osp = c2.subst_z(sig, ('S', ('M', 'z', ())))
            rs = c2.root_split(sig, law)
            hyps = {'forall': [(al, 1.0)], 'sch': [(sig, 1.0)], 'overspec': [(osp, 1.0)],
                    'split-fixed': [(A, w) for A, w, f in rs]}
            incons = set()
            for i, tau in enumerate(og):
                hyps['og%d' % i] = [(tau, 1.0)]
                if pp(tau) in INCONSISTENT:
                    incons.add('og%d' % i)
            prior = {h: c2.prior_logw([A for A, *_ in th]) for h, th in hyps.items()}
            lines = []
            for v in ['L0-closure', 'L1-norm', 'L1-sel']:
                accI = {n: 0.0 for n in NS}
                accB = {n: 0.0 for n in NS}
                cache = {}
                for seed in range(20):
                    rng = random.Random(1000 + seed)
                    data = [c2.P_inst(sig, law.sample(rng)) for _ in range(NS[-1])]
                    ll = {h: 0.0 for h in hyps}
                    for n in range(NS[-1] + 1):
                        if n in accI:
                            post = {h: prior[h] + ll[h] for h in hyps}
                            Zp = logsumexp(list(post.values()))
                            m = {h: math.exp(post[h] - Zp) for h in post}
                            accI[n] += sum(m[h] for h in incons) / 20
                            accB[n] += m['forall'] / 20
                        if n == NS[-1]:
                            break
                        d = data[n]
                        for h, th in hyps.items():
                            if ll[h] == NEG_INF:
                                continue
                            key = (h, d)
                            if key not in cache:
                                cache[key] = c2.lik(v, th, d, law, flaw)
                            ll[h] += cache[key]
                lines.append('    %-10s Inc: %s | Bel_cons: %s' % (v, ' '.join('%.3f' % accI[n] for n in NS),
                                                                 ' '.join('%.3f' % accB[n] for n in NS)))
            say('  %s, %s; inconsistent members: %s' % (phiname, lawname,
                                                      ', '.join(pp(hyps[h][0][0]) for h in sorted(incons))))
            for l_ in lines:
                say(l_)
    say('  (n = %s)' % NS)


# ---------------------------------------------------------------------------------------------- (e)
def part_e():
    say('\n(e) unknown selection filter (Prop U10(e)): theories {H_forall, H_sch} x filters '
        '{S_all, S_cqf, S_inst, S_Sroot}; C_min, c = 0.3, numerals q = 1/2, phi = 0+x=x')
    c, q = 0.3, 0.5
    piT = {'forall': 1 / 3, 'sch': 2 / 3}
    nu = {'all': 0.25, 'cqf': 0.25, 'inst': 0.25, 'Sroot': 0.25}

    def logp(T, S, j):
        lq = math.log(1 - q) + j * math.log(q)
        if S == 'Sroot':
            return NEG_INF if j == 0 else lq - math.log(q)
        if T == 'forall' and S == 'all':
            return lq + math.log(c / (1 + c))
        return lq
    pred = piT['forall'] * (nu['cqf'] + nu['inst']) / (piT['forall'] * (nu['cqf'] + nu['inst'])
                                                        + piT['sch'] * (nu['all'] + nu['cqf'] + nu['inst']))
    NS = [0, 1, 2, 5, 10, 20, 50, 100, 1000]
    acc = {n: 0.0 for n in NS}
    for s in range(50):
        rng = random.Random(1400 + s)
        ll = {(T, S): math.log(piT[T] * nu[S]) for T in piT for S in nu}
        for n in range(NS[-1] + 1):
            if n in acc:
                Zp = logsumexp(list(ll.values()))
                acc[n] += sum(math.exp(v - Zp) for (T, S), v in ll.items() if T == 'forall') / 50
            if n == NS[-1]:
                break
            j = 0
            while rng.random() < q:
                j += 1
            for key in ll:
                if ll[key] > NEG_INF:
                    lp = logp(key[0], key[1], j)
                    ll[key] = NEG_INF if lp == NEG_INF else ll[key] + lp
    say('  P(T |- forall x phi | D_n), mean over 50 seeds, n = %s:' % NS)
    say('    ' + ' '.join('%.4f' % acc[n] for n in NS))
    say('  predicted limit pi(H_forall) nu(S_cqf, S_inst) / [pi(H_forall) nu(S_cqf, S_inst) + pi(H_sch) nu(S_all, '
        'S_cqf, S_inst)] = %.4f' % pred)


# ---------------------------------------------------------------------------------------------- (f)
def part_f():
    say('\n(f) prior share of H_forall in {H_forall, H_sch} under the codes used in the project (phi = 0+x=x)')
    al, sch = P('forall x. 0+x=x'), P('0+?z=?z')
    rows = []
    # this track: dtrc symbols + 1 per axiom, lambda = 1
    b_all, b_sch = size(al) + 1, size(sch) + 1
    rows.append(('universal (dtrc symbols + 1 per axiom, lambda=1)', b_all, b_sch))
    # track model, Definition 1.3: 4 bits per token (16 tokens: 0 S + * < = , 5 connectives, A E, IDX PAR MV),
    # IDX gamma(k+1), MV new: 1 + gamma(arity+1) + 1 (sort), MV old: 1 + gamma(index+1); theory: gamma(1) = 1 bit
    tok = 4
    m_all = 1 + 6 * tok + 2 * 1             # tokens A,=,+,0,IDX,IDX; two gamma(1)
    m_sch = 1 + 5 * tok + (1 + 1 + 1) + (1 + 1)  # tokens =,+,0,MV,MV
    rows.append(('model (prefix code, Def 1.3, 4 bits/token)', m_all, m_sch))
    try:
        sys.path.insert(0, '/home/user/AI-works/axiom-induction/code')
        from bai.grammar import TemplateCode, theory_bits
        e_all, e_sch = theory_bits([al]), theory_bits([sch])
        rows.append(('experiments (bai TemplateCode, closed guard)', e_all, e_sch))
    except Exception as ex:  # pragma: no cover
        say('  (could not import bai: %r)' % ex)
    for beta, name in [(5.0, 'pa (beta = 5 bits/symbol)'), (math.log2(23), 'pa (beta = log2 23)')]:
        rows.append((name, beta * size(al), beta * size(sch)))
    for name, ba, bs in rows:
        share = 1 / (1 + 2 ** (ba - bs))
        say('  %-52s bits(H_forall) %6.2f  bits(H_sch) %6.2f  share of H_forall %.3f' % (name, ba, bs, share))
    say('  (with lambda = 2 in the model code the bit difference doubles: share %.3f)' % (1 / (1 + 2 ** (2 * (m_all - m_sch)))))


# ---------------------------------------------------------------------------------------------- (g)
def part_g():
    say('\n(g) P(K_n >= 3 log_{1/q} n) for the maximum K_n of n geometric numerals (q = 1/2 and 0.9), exact, vs n^-2')
    for q in [0.5, 0.9]:
        row = []
        for n in [10, 100, 10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6]:
            x = math.ceil(3 * math.log(n) / math.log(1 / q))
            p = -math.expm1(n * math.log1p(-q ** x))
            row.append('n=%d: %.2e <= %.2e' % (n, p, n ** -2.0))
            assert p <= n ** -2.0
        say('  q=%.1f  %s' % (q, '; '.join(row)))


# ---------------------------------------------------------------------------------------------- (h)
def part_h():
    say('\n(h) noise mixtures (Prop U2n): random parameters, per-datum ratio of the noisy laws')
    rng = random.Random(1500)
    worst_l1, worst_norm, lo_l1 = -1.0, -1.0, 2.0
    for _ in range(200000):
        c = rng.uniform(1e-3, 1 - 1e-3)
        eta = rng.uniform(0, 1)
        Ps = rng.uniform(0, 1 - c)       # sub-probability of the instance under sigma (cite, Z_sigma <= 1)
        Zs = rng.uniform(max(Ps, 1e-9), 1)
        N = rng.uniform(0, 1)
        Zall = (1 - c) + c * Zs
        r1 = ((1 - eta) * c * Ps + eta * N) / ((1 - eta) * Ps + eta * N) if (Ps + N) > 0 else 1.0
        rn = ((1 - eta) * c * Ps / Zall + eta * N) / ((1 - eta) * Ps / Zs + eta * N)
        worst_l1 = max(worst_l1, r1)
        lo_l1 = min(lo_l1, r1 / c)
        worst_norm = max(worst_norm, rn)
    say('  L1 (unnormalised components): max ratio %.6f (<= 1), min ratio/c %.6f (>= 1); '
        'L1-norm components: max ratio %.6f (<= 1)' % (worst_l1, lo_l1, worst_norm))
    assert worst_l1 <= 1 + 1e-12 and worst_norm <= 1 + 1e-12 and lo_l1 >= 1 - 1e-12


if __name__ == '__main__':
    t0 = time.time()
    say('c10_misc')
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
    part_f()
    part_g()
    part_h()
    print('runtime %.0f s' % (time.time() - t0))
    open('c10_misc.out', 'w').write('\n'.join(OUT) + '\n')
