"""Independent checks (review B) for Section time: the counterexample family of Rem time:lonesize
(sizes, grammar nodes, code lengths in the referee's grammar), the stated linear bound, Lemma time:symexp on
that family, the one-node A4 example sizes, and the growth conditions of Cor time:hard / time:log."""
import math

# formulas in de Bruijn form: ('all', body) | ('eq', l, r); terms: ('plus', a, b) | ('par', i) | ('idx', i)
def size(f):
    tag = f[0]
    if tag == 'all':
        return 1 + size(f[1])
    if tag in ('eq', 'plus'):
        return 1 + size(f[1]) + size(f[2])
    return 1  # par, idx

def subst_top(body, t):
    """instantiate the outermost bound index (0) by the closed term t (no bound indices inside t)."""
    def go(f, depth):
        tag = f[0]
        if tag == 'all':
            return ('all', go(f[1], depth + 1))
        if tag in ('eq', 'plus'):
            return (tag, go(f[1], depth), go(f[2], depth))
        if tag == 'idx':
            return t if f[1] == depth else f
        return f
    return go(body, 0)

def gen(f, i):
    """Gen on parameter i: replace par i by idx 0 (no binders inside these formulas) and add forall."""
    def go(g, depth):
        tag = g[0]
        if tag == 'all':
            return ('all', go(g[1], depth + 1))
        if tag in ('eq', 'plus'):
            return (tag, go(g[1], depth), go(g[2], depth))
        if tag == 'par' and g[1] == i:
            return ('idx', depth)
        return g
    return ('all', go(f, 0))

pp = ('plus', ('par', 0), ('par', 0))
refl = ('all', ('eq', ('idx', 0), ('idx', 0)))
# referee's grammar: alpha_lg = 0.2 (logical citation, 7 schemas uniform), alpha_forallE = alpha_Gen = 0.1,
# term + : 0.1, parameter: 0.2, parameter index geometric ratio 1/2 (index 0 has prob 0.5)
cost_cite = -math.log(0.2 / 7)
cost_fE = -math.log(0.1 * 0.1 * (0.2 * 0.5) ** 2)
cost_gen = -math.log(0.1 * 0.5)
print('round cost = %.4f nats, citation + final forall-E = %.4f nats' % (cost_fE + cost_gen, cost_cite + cost_fE))
viol = []
for k in [0, 1, 2, 3, 5, 6, 8, 10, 12, 14]:
    f = refl
    for _ in range(k):
        f = subst_top(f[1], pp)
        f = gen(f, 0)
    f = subst_top(f[1], pp)
    nu = 1 + 8 * k + 6
    cost = cost_cite + cost_fE + k * (cost_fE + cost_gen)
    bound = 12.8 + 12.2 * k
    print(f'k={k:2d}: |phi_k|={size(f):7d} (2^(k+3)-1={2**(k+3)-1:7d})  nu={nu:4d}  -ln Pr={cost:8.3f}  '
          f'12.8+12.2k={bound:8.3f}  {"VIOLATED" if cost > bound else ""}')
    if cost > bound:
        viol.append(k)
print('k with -ln Pr(tree) > 12.8 + 12.2k:', viol, '(closed form: 12.7656 + 12.2061 k)')
for k in [30]:
    print(f'k=30: -ln Pr = {cost_cite + cost_fE + 30*(cost_fE+cost_gen):.3f} vs 12.8+12.2*30 = {12.8+12.2*30:.3f}')

# Lemma time:symexp bound on this family (no A4 citation: stronger bound (c_T+1) nu e^(nu/e))
aT = 4
cT = 2 * aT * aT
ok = all((2 ** (k + 3) - 1) <= (cT + 1) * (7 + 8 * k) * math.exp((7 + 8 * k) / math.e) for k in range(0, 60))
print('Lemma symexp bound holds on the family k<60:', ok, '; ln|phi_k|/nu at k=60:', round(math.log(2 ** 63 - 1) / (7 + 480), 4))

# one-node A4 example: forall x B_m(x) -> B_m(S^m 0), B_m(x) = (x+...+x = 0), m summands
for m in [10, 40, 80]:
    Bx = 2 * m + 1           # (m leaves + m-1 pluses) + '=' + '0'
    Bt = m * (m + 1) + (m - 1) + 2
    print(f'A4 example m={m}: size (forall counts 1) = {1 + (1 + Bx) + Bt}, paper/referee: ', {10: 145, 40: 1765, 80: 6725}[m])

# growth conditions
print('e^(1/e) =', round(math.e ** (1 / math.e), 4), '< 2')
for d in [1, 3, 10]:
    for name, s in [('m', lambda m: m), ('m^3', lambda m: m ** 3), ('2^m', lambda m: 2.0 ** m)]:
        vals = [s(m) ** 2 - (d + 1) * s(m + 1) for m in [5, 20, 40]]
        print(f'  d={d} s={name}: s(m)^2-(d+1)s(m+1) at m=5,20,40: {[round(v) for v in vals]}')
