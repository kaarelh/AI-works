"""Referee check r6: is the memoriser prior of Prop U6 proper with r_s = 2^-(|s|+1) (lambda = 1, as in c3)?

U6 needs sum_s r_s < infinity (so that Z0 = prod_s (1 - r_s) > 0).  Size = dtrc symbol count (1 per node).
 (1) Number T(n) of closed terms of size n over {0, S, +, *}; T(x) = x + x T + 2 x T^2 has radius
     x* = 1/(1 + 2 sqrt 2) = 0.2612 < 1/2.
 (2) Partial sums of 2^-(|s|+1) over closed atomic sentences t1 = t2 (|s| = 1 + |t1| + |t2|): diverge.
 (3) Restricted universes: closed instances of 0+x=x (|s| = 3 + 2|t|): converges (1/4 < x*);
     closed instances of Sx!=0, i.e. ~(S t = 0) (|s| = 4 + |t|): diverges; numeral instances only: converges.
Output: r6_prior_mass.out"""
import math

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


def main():
    NMAX = 120
    T = [0] * (NMAX + 1)
    T[1] = 1
    for n in range(2, NMAX + 1):
        T[n] = T[n - 1] + 2 * sum(T[i] * T[n - 1 - i] for i in range(1, n - 1))
    say('(1) T(n) for n = 1..10: %s' % T[1:11])
    say('    T(n+1)/T(n) at n = 119: %.4f  (1/x* = 1 + 2 sqrt 2 = %.4f)' % (T[120] / T[119], 1 + 2 * math.sqrt(2)))
    # (2) sum over closed atomic sentences t1 = t2 of 2^-(|s|+1), |s| = 1 + |t1| + |t2|, truncated at |s| <= L
    say('(2) partial sums over closed equations t1 = t2 with |s| <= L of 2^-(|s|+1):')
    for L in [10, 20, 40, 80, 120]:
        tot = 0.0
        for s in range(3, L + 1):
            cnt = sum(T[i] * T[s - 1 - i] for i in range(1, s - 1))
            tot += cnt * 2.0 ** -(s + 1)
        say('    L = %3d: %.4e' % (L, tot))
    say('(3) restricted universes, partial sums up to |t| <= 119:')
    s1 = sum(T[n] * 2.0 ** -(4 + 2 * n) for n in range(1, NMAX))
    s2 = [sum(T[n] * 2.0 ** -(5 + n) for n in range(1, m)) for m in (20, 60, 120)]
    s3 = sum(2.0 ** -(6 + 2 * k) for k in range(200))
    say('    instances 0+t=t, all closed t (r = 2^-(4+2|t|)): %.6f (converges: 1/4 < x*)' % s1)
    say('    instances ~(St=0), all closed t (r = 2^-(5+|t|)): partial sums %s (diverges)'
        % ', '.join('%.3e' % x for x in s2))
    say('    instances 0+S^k0=S^k0, numerals only: %.6f' % s3)
    open('r6_prior_mass.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
