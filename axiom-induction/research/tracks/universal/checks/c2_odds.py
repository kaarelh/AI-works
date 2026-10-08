"""c2: exact posteriors over a small hypothesis class for data phi(t), t ~ Q i.i.d. (closed setting).

For each of the five examples phi and each likelihood variant (L0-strict, L0-closure, L1, L1-norm, L1-sel) we
compute exact log-likelihoods of every hypothesis on seeded data streams and report
  (a) the exact log-odds identities for H_forall : H_sch (Prop. U2), asserted along every path;
  (b) mean posterior masses of hypothesis groups at several n;
  (c) for every over-general template tau: P_tau(I) (instance mass), the per-datum KL rate
      KL(P_sch || P_tau) and the size-principle bound -log P_tau(I) <= KL (Prop. U4);
  (d) the over-specific template phi(Sz): survival probability and the per-datum gain while it survives.
Hypotheses: H_forall = {forall x phi}, H_sch = {phi(z)}, every template obtained from phi(z) by replacing one
subterm/subformula by a fresh metavariable (over-general), phi(Sz) (over-specific), the formula metavariable
?A, and the root split {phi(f(z1..zr)) : f a root symbol of Q} with fixed weights p_f and with Laplace
(Dirichlet(1)) weights.  Prior: 2^{-(symbols + 1 per axiom)}.  Output: c2_odds.out."""
import math
import random
from common import (P, pp, num, NumLaw, GWLaw, FormLaw, PHIS, lp_template, lp_L0strict, lp_L0closure, lp_L1,
                    log_Z_L1, lp_L1sel, prior_logw, NEG_INF, logsumexp, size)
from dtrc.syntax import positions, replace_at, sort_of
from dtrc.templates import match, geq

OUT = []
C = 0.3
NS = [0, 1, 2, 3, 5, 10, 20, 50, 100, 200]
SEEDS = 50
CACHE = {}


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


def overgeneral(sig):
    """templates obtained by replacing one proper subterm/subformula of sig by a fresh metavariable"""
    out = []
    for path, sub in positions(sig):
        if not path:
            continue
        fresh = ('M', 'B9', ()) if sort_of(sub) == 'F' else ('M', 'y9', ())
        tau = replace_at(sig, path, fresh)
        if sub[0] == 'M' and sum(1 for _, s in positions(sig) if s == sub) == 1:
            continue  # replacing the only occurrence of z by a fresh metavariable is a renaming
        if any(geq(tau, t2) and geq(t2, tau) for t2 in out):
            continue
        if geq(tau, sig) and not geq(sig, tau):
            out.append(tau)
    return out


def subst_z(sig, rep):
    h = sig[0]
    if h == 'M' and sig[1] == 'z':
        return rep
    if h in ('0', 'v', 'p', 'h'):
        return sig
    if h == 'M':
        return sig
    if h in ('all', 'ex', 'not', 'S'):
        return (h, subst_z(sig[1], rep))
    return (h,) + tuple(subst_z(k, rep) for k in sig[1:])


def root_split(sig, law):
    parts = []
    for f, pf in law.root_probs().items():
        if f == '0':
            rep = ('0',)
        elif f == 'S':
            rep = ('S', ('M', 'a', ()))
        else:
            rep = (f, ('M', 'a', ()), ('M', 'b', ()))
        parts.append((subst_z(sig, rep), pf, f))
    return parts


def main():
    say('c2_odds: c = %.2f, prior 2^-(symbols+1 per axiom), %d seeds, n up to %d' % (C, SEEDS, NS[-1]))
    for lawname, law in [('numerals q=1/2', NumLaw(0.5)), ('GW(.4,.3,.2,.1)', GWLaw())]:
        flaw = FormLaw(law)
        for phiname, (s_sch, s_all) in PHIS.items():
            sig, al = P(s_sch), P(s_all)
            og = overgeneral(sig) + [P('?A')]
            osp = subst_z(sig, ('S', ('M', 'z', ())))
            rs = root_split(sig, law)
            hyps = {'forall': [(al, 1.0)], 'sch': [(sig, 1.0)], 'overspec': [(osp, 1.0)],
                    'split-fixed': [(A, w) for A, w, f in rs]}
            for i, tau in enumerate(og):
                hyps['og%d' % i] = [(tau, 1.0)]
            prior = {h: prior_logw([A for A, *_ in th]) for h, th in hyps.items()}
            prior['split-laplace'] = prior_logw([A for A, w, f in rs]) - math.log(2) * len(rs)  # weights cost
            say('\n=== phi = %s, law %s' % (phiname, lawname))
            say('  over-general templates: ' + '; '.join(pp(t) for t in og))
            say('  over-specific: %s;  root split: %s' % (pp(osp), '; '.join('%s[%.2f]' % (pp(A), w) for A, w, f in rs)))
            # (c) size principle: P_tau(I) and KL(P_sch || P_tau); exact sums for numerals when tau has only
            # term metavariables, otherwise Monte Carlo with standard errors
            from dtrc.templates import metas, instantiate
            rng = random.Random(7)
            data_big = [law.sample(rng) for _ in range(20000)]
            for i, tau in enumerate(og):
                ms = list(metas(tau))
                exact = isinstance(law, NumLaw) and all(nm[0].islower() for nm in ms)
                if exact:
                    import itertools
                    K = 60
                    pI = 0.0
                    for ks in itertools.product(range(K), repeat=len(ms)):
                        th = {nm: num(k) for nm, k in zip(ms, ks)}
                        if match(sig, instantiate(tau, th)) is not None:
                            pI += math.exp(sum(law.logp(num(k)) for k in ks))
                    pse = 0.0
                    kl, klse = 0.0, 0.0
                    for k in range(K):
                        d = P_inst(sig, num(k))
                        lt = lp_template(tau, d, law, flaw)
                        if lt == NEG_INF:
                            kl = float('inf')
                            break
                        kl += math.exp(law.logp(num(k))) * (lp_template(sig, d, law, flaw) - lt)
                else:
                    hits, M = 0, 200000
                    r2 = random.Random(8 + i)
                    for _ in range(M):
                        th = {nm: (flaw.sample(r2) if nm[0].isupper() else law.sample(r2)) for nm in ms}
                        if match(sig, instantiate(tau, th)) is not None:
                            hits += 1
                    pI = hits / M
                    pse = math.sqrt(pI * (1 - pI) / M)
                    lr = [lp_template(sig, P_inst(sig, t), law, flaw) - lp_template(tau, P_inst(sig, t), law, flaw)
                          for t in data_big]
                    if any(x == float('inf') for x in lr):
                        kl, klse = float('inf'), 0.0
                    else:
                        kl = sum(lr) / len(lr)
                        klse = math.sqrt(sum((x - kl) ** 2 for x in lr) / (len(lr) - 1) / len(lr))
                bound = -math.log(pI) if pI > 0 else float('inf')
                bse = pse / pI if pI > 0 else 0.0
                ok = (kl == float('inf')) or (bound <= kl + 2 * (klse + bse) + 1e-9)
                say('  size principle  %-14s P_tau(I) = %.4f%s  -log P_tau(I) = %.3f  KL = %s  bound holds: %s'
                    % (pp(tau), pI, ' (exact)' if exact else ' +- %.4f' % pse, bound,
                       'inf' if kl == float('inf') else '%.3f%s' % (kl, '' if exact else ' +- %.3f' % klse), ok))
                assert ok
            # (d) over-specific
            alive = sum(1 for t in data_big if t[0] == 'S') / len(data_big)
            sdata = [t for t in data_big if t[0] == 'S']
            gain = sum(lp_template(osp, P_inst(sig, t), law) - lp_template(sig, P_inst(sig, t), law)
                       for t in sdata) / max(1, len(sdata))
            say('  over-specific phi(Sz): P(datum survives) ~ %.4f; while alive log-odds gain per datum ~ %.3f nats'
                % (alive, gain))
            # (a), (b): posterior trajectories
            CACHE.clear()
            variants = ['L0-strict', 'L0-closure', 'L1', 'L1-norm', 'L1-sel']
            acc = {v: {n: {} for n in NS} for v in variants}
            for seed in range(SEEDS):
                rng = random.Random(1000 + seed)
                data = [P_inst(sig, law.sample(rng)) for _ in range(NS[-1])]
                for v in variants:
                    ll = {h: 0.0 for h in list(hyps) + ['split-laplace']}
                    counts = {}
                    for n in range(NS[-1] + 1):
                        if n in acc[v]:
                            # Laplace-weighted root split: Dirichlet(1) marginal of the root counts
                            k = len(rs)
                            nn = sum(counts.values())
                            lap = (math.lgamma(k) - math.lgamma(nn + k) + sum(math.lgamma(counts.get(f, 0) + 1) for _, _, f in rs))
                            ll['split-laplace'] = ll['_splitbody'] + lap if '_splitbody' in ll else lap
                            post = {h: prior[h] + ll[h] for h in prior}
                            Zp = logsumexp(list(post.values()))
                            masses = {h: math.exp(post[h] - Zp) for h in post}
                            grp = {'forall': masses['forall'], 'sch': masses['sch'], 'overspec': masses['overspec'],
                                   'overgeneral': sum(masses[h] for h in masses if h.startswith('og')),
                                   'split-fixed': masses['split-fixed'], 'split-laplace': masses['split-laplace']}
                            for gname, m in grp.items():
                                acc[v][n][gname] = acc[v][n].get(gname, 0.0) + m / SEEDS
                            # exact identities for H_forall : H_sch
                            lo = ll['forall'] - ll['sch']
                            expect = {'L0-strict': None, 'L0-closure': 0.0, 'L1': n * math.log(C),
                                      'L1-norm': n * (math.log(C) + log_Z_L1([(sig, 1.0)], C) - log_Z_L1([(al, 1.0)], C)),
                                      'L1-sel': 0.0}[v]
                            if expect is not None:
                                assert abs(lo - expect) < 1e-8, (v, n, lo, expect)
                            elif n > 0:
                                assert lo == NEG_INF or ll['forall'] == NEG_INF
                        if n == NS[-1]:
                            break
                        d = data[n]
                        for h, th in hyps.items():
                            if ll[h] == NEG_INF:
                                continue
                            key = (v, h, d)
                            if key not in CACHE:
                                CACHE[key] = lik(v, th, d, law, flaw)
                            ll[h] += CACHE[key]
                        # split-laplace: body part = product of the matched-subterm probabilities
                        for A, w, f in rs:
                            lt = lp_template(A, d, law, flaw)
                            if lt > NEG_INF:
                                counts[f] = counts.get(f, 0) + 1
                                ll['_splitbody'] = ll.get('_splitbody', 0.0) + lt + variant_shift(v, A)
                                break
            say('  mean posterior mass (over %d seeds):' % SEEDS)
            for v in variants:
                say('   %-10s ' % v + '  '.join('n=%-3d' % n for n in NS))
                for gname in ['forall', 'sch', 'overgeneral', 'overspec', 'split-fixed', 'split-laplace']:
                    say('     %-13s' % gname + ' '.join('%.3f' % acc[v][n][gname] for n in NS))
    open('c2_odds.out', 'w').write('\n'.join(OUT) + '\n')


def P_inst(sig, t):
    from dtrc.templates import instantiate
    return instantiate(sig, {'z': t})


def variant_shift(v, A):
    """log-factor of a citation of the qf template A under each variant, relative to its L0 citation"""
    if v in ('L0-strict', 'L0-closure', 'L1-sel'):
        return 0.0
    if v == 'L1':
        return math.log(1 - C)
    if v == 'L1-norm':
        return math.log(1 - C) - math.log(1 - C)  # Z = 1-c for a theory of qf templates
    raise ValueError(v)


def lik(v, th, d, law, flaw):
    if v == 'L0-strict':
        return lp_L0strict(th, d, law, flaw)
    if v == 'L0-closure':
        return lp_L0closure(th, d, law, flaw)
    if v == 'L1':
        return lp_L1(th, d, C, law, flaw)
    if v == 'L1-norm':
        return lp_L1(th, d, C, law, flaw) - log_Z_L1(th, C)
    if v == 'L1-sel':
        return lp_L1sel(th, d, C, law, flaw)
    raise ValueError(v)


if __name__ == '__main__':
    main()
