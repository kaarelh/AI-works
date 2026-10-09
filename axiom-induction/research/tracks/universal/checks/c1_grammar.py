"""c1: the derivation grammar.  Checks
 (1) the exact minimal-calculus likelihood lp_L1 against a Monte Carlo run of the procedural sampler;
 (2) the factorisation P_{forall x phi}(d) = c * P_{sigma_phi}(d) for every output d other than forall x phi
     (Prop. U1 in notes.md), for qf and quantified phi, numeral and Galton-Watson term laws;
 (3) the normalisers Z;
 (4) the closed forms of the calculus with Gen and a bare parameter (Prop. U11) against Monte Carlo.
Seeded; output written to c1_grammar.out."""
import math
import random
from collections import Counter
from common import (P, pp, num, NumLaw, GWLaw, OpenLaw, FormLaw, lp_L1, log_Z_L1, sample_derivation,
                    open_calculus_forms, NEG_INF)

OUT = []


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


def mc_check(theory, c, tlaw, N, seed, label, top=8):
    rng = random.Random(seed)
    cnt = Counter()
    fails = 0
    for _ in range(N):
        d = sample_derivation(theory, c, 0.0, tlaw, None, rng)
        if d is None:
            fails += 1
        else:
            cnt[d] += 1
    Z = math.exp(log_Z_L1(theory, c))
    say('  %s: N=%d  success freq %.5f  exact Z %.5f  z-score %.2f' % (
        label, N, 1 - fails / N, Z, ((1 - fails / N) - Z) / math.sqrt(Z * (1 - Z) / N + 1e-300)))
    worst = 0.0
    for d, k in cnt.most_common(top):
        p = math.exp(lp_L1(theory, d, c, tlaw))
        f = k / N
        z = (f - p) / math.sqrt(p * (1 - p) / N)
        worst = max(worst, abs(z))
        say('    %-34s freq %.5f exact %.5f z %+.2f' % (pp(d)[:34], f, p, z))
    return cnt, worst


def main():
    c = 0.3
    N = 200000
    say('c1_grammar: minimal calculus {cite, forall-elim}, c = %.2f' % c)
    cases = [
        ('0+x=x', '0+?z=?z', 'forall x. 0+x=x'),
        ('Sx!=0', '~(S ?z=0)', 'forall x. ~(S x=0)'),
        ('forall y. x+y=y+x', 'forall y. ?z+y=y+?z', 'forall x. forall y. x+y=y+x'),
    ]
    worst_all = 0.0
    for lawname, tlaw in [('numerals q=1/2', NumLaw(0.5)), ('GW(.4,.3,.2,.1)', GWLaw())]:
        for name, s_sch, s_all in cases:
            sch, al = P(s_sch), P(s_all)
            say('\nphi = %s, term law %s' % (name, lawname))
            cnt_a, w1 = mc_check([(al, 1.0)], c, tlaw, N, 11, 'H_forall')
            cnt_s, w2 = mc_check([(sch, 1.0)], c, tlaw, N, 12, 'H_sch')
            worst_all = max(worst_all, w1, w2)
            # factorisation on every output seen in either run
            maxdev, nchk = 0.0, 0
            for d in set(cnt_a) | set(cnt_s):
                if d == al:
                    continue
                la, ls = lp_L1([(al, 1.0)], d, c, tlaw), lp_L1([(sch, 1.0)], d, c, tlaw)
                assert la > NEG_INF and ls > NEG_INF, pp(d)
                maxdev = max(maxdev, abs((la - ls) - math.log(c)))
                nchk += 1
            say('  factorisation log P_forall(d) - log P_sch(d) = log c on %d outputs; max deviation %.2e'
                % (nchk, maxdev))
            assert maxdev < 1e-9
            Za, Zs = math.exp(log_Z_L1([(al, 1.0)], c)), math.exp(log_Z_L1([(sch, 1.0)], c))
            say('  Z_forall = %.6f = (1-c) + c Z_sch = %.6f;  normalised ratio c Z_sch / Z_forall = %.6f'
                % (Za, (1 - c) + c * Zs, c * Zs / Za))
            assert abs(Za - ((1 - c) + c * Zs)) < 1e-12
    say('\nmax |z| over all Monte Carlo comparisons (minimal calculus): %.2f' % worst_all)

    # ---- calculus with Gen and a bare parameter
    c, g, rho = 0.3, 0.2, 0.1
    base = NumLaw(0.5)
    Qo = OpenLaw(base, rho)
    sch, al = P('0+?z=?z'), P('forall x. 0+x=x')
    say('\nCalculus {cite, forall-elim (c=%.1f), Gen (g=%.1f)}, Q_open = %.1f*[w0] + %.1f*numerals(1/2)'
        % (c, g, rho, 1 - rho))
    theories = {
        'H_forall': ([(al, 1.0)], (1, 0, 0)),
        'H_open': ([(sch, 1.0, Qo)], (0, 1, 0)),
        'H_sch(guarded)': ([(sch, 1.0, base)], (0, 0, 1)),
        'H_both(.4 forall, .6 guarded)': ([(al, 0.4), (sch, 0.6, base)], (0.4, 0, 0.6)),
    }
    worst = 0.0
    for lab, (th, (wa, wo, ws)) in theories.items():
        rng = random.Random(21)
        cnt, fails = Counter(), 0
        for _ in range(N):
            d = sample_derivation(th, c, g, Qo, None, rng)
            if d is None:
                fails += 1
            else:
                cnt[d] += 1
        a, bp, bcl, Z = open_calculus_forms(c, g, rho, wa, wo, ws, base.logp)
        say('  %s: success freq %.5f exact Z %.5f' % (lab, 1 - fails / N, Z))
        rows = [(al, a), (P('0+w0=w0'), bp)] + [(P('0+%s=%s' % (k, k)), bcl(num(k))) for k in range(4)]
        for d, p in rows:
            f = cnt[d] / N
            z = (f - p) / math.sqrt(max(p * (1 - p), 1e-12) / N)
            if p > 0:
                worst = max(worst, abs(z))
            say('    %-14s freq %.5f exact %.5f z %+.2f' % (pp(d), f, p, z))
        other = set(cnt) - {d for d, _ in rows} - {P('0+%d=%d' % (k, k)) for k in range(40)}
        assert not other, [pp(x) for x in other]
    a1, bp1, b1, _ = open_calculus_forms(c, g, rho, 1, 0, 0, base.logp)
    a2, bp2, b2, _ = open_calculus_forms(c, g, rho, 0, 1, 0, base.logp)
    a3, bp3, b3, _ = open_calculus_forms(c, g, rho, 0, 0, 1, base.logp)
    t = num(2)
    say('  ratios at closed instance 0+2=2: forall/open = %.6f (c = %.2f); open/sch = %.6f '
        '((1-rho)/(1-g c rho) = %.6f); forall/sch = %.6f (c(1-rho)/(1-g c rho) = %.6f)'
        % (b1(t) / b2(t), c, b2(t) / b3(t), (1 - rho) / (1 - g * c * rho), b1(t) / b3(t),
           c * (1 - rho) / (1 - g * c * rho)))
    say('  ratios at forall x phi: forall/open = %.4f (1/(g rho) = %.4f); at 0+w0=w0: forall/open = %.4f'
        % (a1 / a2, 1 / (g * rho), bp1 / bp2))
    say('max |z| (calculus with Gen): %.2f' % worst)
    open('c1_grammar.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
