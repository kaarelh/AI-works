"""c4: predictive confirmation of 'all future data are phi-instances' (Prop. U8 in notes.md).

Hypotheses about the stream: H_sch (point mass, prior pi0) emits only phi-instances; a noisy hypothesis T_eps
emits a non-instance with probability eps and otherwise an instance with the same instance law.  After n
instances the instance factors cancel, so everything depends on eps only.
 (a) Bayes-Laplace with a point mass: eps ~ pi0 * delta_0 + (1-pi0) * Uniform(0,1).
     P(all future are instances | n) = pi0 / (pi0 + (1-pi0)/(n+1));  with pi0 = 0 it is 0 for every n,
     while P(next m are instances | n) = (n+1)/(n+m+1)  (Hutter 2007's Bayes-Laplace example).
 (b) a countable 'universal-style' family eps_j = 2^-j with prior (1-pi0)/(j(j+1)):
     1 - P(all future | n) ~ (1-pi0)/(pi0 log2 n).
 (c) the expected-sum bound  sum_n (1 - M(I | D_n)) <= ln(1/pi0)  (here deterministic: all data are instances).
Output c4_confirm.out."""
import math
import mpmath as mp

OUT = []


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


def laplace_all_future(n, pi0):
    return pi0 / (pi0 + (1 - pi0) / (n + 1))


def laplace_next_m(n, m, pi0):
    return (pi0 + (1 - pi0) / (n + m + 1)) / (pi0 + (1 - pi0) / (n + 1))


def main():
    mp.mp.dps = 30
    pi0 = 0.01
    say('c4_confirm')
    say('(a) Bayes-Laplace with point mass pi0 = %.2f at eps = 0' % pi0)
    say('    n     P(all future | n) exact   via quadrature    1-P   (1-pi0)/(pi0 (n+1))   P(next 10^6 | n), pi0=0')
    for n in [0, 1, 10, 100, 1000, 10 ** 4, 10 ** 6]:
        ex = laplace_all_future(n, pi0)
        integral = mp.quad(lambda e: (1 - e) ** n, [0, 1])
        quad = pi0 / (pi0 + (1 - pi0) * integral)
        assert abs(ex - float(quad)) < 1e-12
        say('  %7d   %.12f   %.12f   %.3e   %.3e   %.6f' % (n, ex, float(quad), 1 - ex,
                                                            (1 - pi0) / (pi0 * (n + 1)), laplace_next_m(n, 10 ** 6, 0.0)))
    # (b) dyadic family
    say('\n(b) eps_j = 2^-j, prior (1-pi0)/(j(j+1)), pi0 = %.2f' % pi0)
    say('    n         S_n = sum_j pi_j (1-2^-j)^n   S_n * log2(n)    1 - P(all future | n) = S_n/(pi0+S_n)')
    J = 600
    for k in [1, 2, 3, 4, 6, 8, 10, 12, 15, 20, 30, 50]:
        n = mp.mpf(10) ** k
        s = mp.fsum((1 - pi0) / (j * (j + 1)) * mp.exp(n * mp.log1p(-mp.mpf(2) ** (-j))) for j in range(1, J))
        s += (1 - pi0) / J  # tail j >= J, where (1-2^-j)^n = 1 to within n 2^-J
        miss = s / (pi0 + s)
        say('  10^%-3d    %.6e                    %.4f           %.6e' % (k, float(s), float(s * mp.log(n, 2)),
                                                                      float(miss)))
    # (c) expected-sum bound, both families
    say('\n(c) sum_n (1 - M(I | D_n)) versus ln(1/pi0) = %.4f' % math.log(1 / pi0))
    tot = 0.0
    for n in range(10 ** 6):
        tot += 1 - laplace_next_m(n, 1, pi0)
    say('  Laplace with point mass: sum over n < 10^6 = %.4f (tail ~ sum (1-pi0)/(pi0 n^2) < %.4f)'
        % (tot, (1 - pi0) / pi0 / 10 ** 6 * 2))
    assert tot <= math.log(1 / pi0)
    J = 200
    w = {j: (1 - pi0) / (j * (j + 1)) for j in range(1, J)}
    w0 = pi0
    tot = 0.0
    for n in range(2 * 10 ** 5):
        Z = w0 + sum(w.values())
        MI = (w0 + sum(wj * (1 - 2.0 ** -j) for j, wj in w.items())) / Z
        tot += 1 - MI
        for j in w:
            w[j] *= (1 - 2.0 ** -j)
    say('  dyadic family: sum over n < 2*10^5 = %.4f' % tot)
    assert tot <= math.log(1 / pi0)
    # (d) non-monotone confirmation: one instance lowers the posterior of the law sigma_phi
    q = 0.5
    post = (q * (1 - q)) / (q * (1 - q) + (1 - q))
    say('\n(d) prior 1/2 on sigma_phi and 1/2 on phi(Sz), numerals q = 1/2, datum phi(S0): '
        'posterior of sigma_phi = %.4f < 1/2' % post)
    open('c4_confirm.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()
