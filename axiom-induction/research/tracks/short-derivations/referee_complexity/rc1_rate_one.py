"""rc1: the soft sandwich at rate 1 (notes Thm 5.2(b), Prop 5.3, Cor 5.4, open problem 1).

Claim under test (notes Prop 5.3, §0.1, §0.2 S3 row, §8 problem 1): "Whether (b) holds at kappa is [open]", i.e.
whether  l_AI^sigma_kappa(D) <= l_FIcert^sigma_{kappa,kappa}(D) + O(1)  for all D.

Referee argument (refutation). In the code Code_K of Def 5.1 every derivation code contains at least one 2-bit line
tag, the 2-bit end tag and the code of its last formula. So l^bit_p(psi) >= |psi|_bit + 4 for every hypothesis p, and
  l_AI(D) >= kappa * sum_i (|phi_i^{b_i}|_bit + 4)                       (sharpened Prop 5.3(iii)).
On D^X with X = empty set, the verifier V_0(phi_w, eps) = rej has lambda = 0, so
  l_FIcert_{kappa,kappa}(D_n) <= |V_0| + kappa * sum_i |phi_{w_i}|_bit.
Since |not phi|_bit = |phi|_bit + b_s, the difference is >= kappa (b_s + 4) n - |V_0|, unbounded. On X = all words the
difference is >= 4 kappa n - |V_1|. Hence (b) fails at rate 1 (and, by Prop 5.3(i),(ii), no joint rate gives a
two-sided constant-regret equivalence; with separate rates (kappa_c, kappa_s) the same sequences force kappa_s = kappa
and then the same linear gap).

This script
  (1) re-implements |chi|_bit of Def 5.1 (b_s bits per preorder token, IDX/PAR escape + Elias-gamma(value + 1)) and
      cross-checks it against the notes' kcore.formula_bits and the logic referee's rk.fbits;
  (2) builds the one-line derivation of not phi_w from Ax = {not phi_v : v word}, checks it with kcore and rk, and
      confirms its code length is |not phi_w|_bit + 4 = |phi_w|_bit + b_s + 4 (so the AI lower bound is attained,
      i.e. l_AI(D^0_n) = kappa * sum (|phi|_bit + b_s + 4) + O(1));
  (3) tabulates, for n up to 2^17, the lower bound on l_AI and the upper bound on l_FIcert_{kappa,kappa} on D^0 and
      D^all, and the gap per datum;
  (4) checks the length-lexicographic sum bound of Prop 5.3(i): sum_{i<=n} |w_i| >= (n/2)(log2 n - 3);
  (5) prints the constants e_1 = 31 b_s + 24 and r = max(2 b_s, 2 + e_1) of Thm 5.2(b) for small b_s.
Deterministic; writes rc1_rate_one.out next to itself.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'checks'))
sys.path.insert(0, os.path.join(HERE, '..', 'referee_logic'))
import kcore as K  # noqa: E402
import rk  # noqa: E402

out = []


def P(*a):
    out.append(' '.join(str(x) for x in a))


# ---------------------------------------------------------------- (1) my own |chi|_bit
def gamma_bits(n):
    """Elias gamma length for n >= 1: floor(log2 n) zeros, then the binary of n."""
    assert n >= 1
    L = 0
    while (n >> L) > 1:
        L += 1
    return 2 * L + 1


def my_bits(x, bs):
    """x in kcore representation. One token of bs bits per node; idx/par add gamma(value + 1)."""
    tag = x[0]
    if tag in ('idx', 'par'):
        return bs + gamma_bits(x[1] + 1)
    if tag in ('fn', 'rel'):
        return bs + sum(my_bits(a, bs) for a in x[2])
    if tag == 'eq':
        return bs + my_bits(x[1], bs) + my_bits(x[2], bs)
    if tag in ('not', 'all'):
        return bs + my_bits(x[1], bs)
    if tag == 'imp':
        return bs + my_bits(x[1], bs) + my_bits(x[2], bs)
    raise ValueError(x)


def to_rk(x):
    tag = x[0]
    if tag == 'idx':
        return ('i', x[1])
    if tag == 'par':
        return ('p', x[1])
    if tag == 'fn':
        return ('c', x[1], tuple(to_rk(a) for a in x[2]))
    if tag == 'rel':
        return ('R', x[1], tuple(to_rk(a) for a in x[2]))
    if tag == 'eq':
        return ('=', to_rk(x[1]), to_rk(x[2]))
    if tag == 'not':
        return ('~', to_rk(x[1]))
    if tag == 'imp':
        return ('>', to_rk(x[1]), to_rk(x[2]))
    if tag == 'all':
        return ('A', to_rk(x[1]))
    raise ValueError(x)


E = ('fn', 'e', ())


def word_term(w):
    t = E
    for a in reversed(w):
        t = ('fn', 's' + a, (t,))
    return t


def phi(w):
    return ('rel', 'R', (word_term(w),))


# literal language {e, s0, s1, R}: sigma_L = 4 symbols, plus the 6 tokens not, imp, all, eq, IDX, PAR
SIGMA_L = 4
BS = math.ceil(math.log2(SIGMA_L + 6))
P('rc1_rate_one  (deterministic)')
P(f'literal language {{e, s0, s1, R}}: sigma_L = {SIGMA_L}, b_s = ceil(log2(sigma_L + 6)) = {BS}')

# cross-check the three implementations of |chi|_bit on all words up to length 10 and on a few formulas with indices
mism = 0
checked = 0
samples = [phi(w) for k in range(11) for w in (format(i, f'0{k}b') if k else '' for i in range(2 ** k))]
samples += [('not', f) for f in samples[:200]]
samples += [('all', ('eq', ('idx', 0), ('idx', 0))),
            ('all', ('imp', ('rel', 'R', (('idx', 0),)), ('eq', ('par', 7), ('par', 300))))]
for f in samples:
    a = my_bits(f, BS)
    b = K.formula_bits(f, BS)
    c = rk.fbits(to_rk(f), BS)
    checked += 1
    if not (a == b == c):
        mism += 1
P(f'(1) |chi|_bit: own implementation vs kcore.formula_bits vs rk.fbits on {checked} formulas: {mism} mismatches')
P(f'    |not phi|_bit - |phi|_bit = {my_bits(("not", phi("0110")), BS) - my_bits(phi("0110"), BS)} (= b_s)')

# ---------------------------------------------------------------- (2) one-line derivations attain the lower bound
bad_k = bad_rk = bad_len = 0
for k in range(9):
    for i in range(2 ** k):
        w = format(i, f'0{k}b') if k else ''
        neg = ('not', phi(w))
        lines = [(neg, ('ax',))]
        member = lambda f: f[0] == 'not' and f[1][0] == 'rel' and f[1][1] == 'R'  # noqa: E731  (all not phi_v)
        ok1, _ = K.check_derivation(lines, member)
        ok2, _ = rk.check([(to_rk(f), j) for f, j in lines], lambda g: g[0] == '~' and g[1][0] == 'R')
        bad_k += (not ok1)
        bad_rk += (not ok2)
        L1 = K.code_length(lines, BS)
        L2 = rk.code_len([(to_rk(f), j) for f, j in lines], BS)
        if not (L1 == L2 == my_bits(phi(w), BS) + BS + 4):
            bad_len += 1
P(f'(2) one-line derivations of not phi_w from {{not phi_v}}, |w| <= 8 (511 words): rejected by kcore {bad_k}, '
  f'by rk {bad_rk}; code length != |phi_w|_bit + b_s + 4: {bad_len}')
P('    Structural lower bound (Def 5.1): every code has >= 1 line tag (2 bits), the end tag (2 bits) and the last '
  'formula, so l^bit_p(psi) >= |psi|_bit + 4 for every p. With (2), on D^0 the AI loss is kappa*sum(|phi|_bit+b_s+4)+O(1).')


# ---------------------------------------------------------------- (3) the gap on D^0 and D^all
def words_lenlex():
    k = 0
    while True:
        for i in range(2 ** k):
            yield format(i, f'0{k}b') if k else ''
        k += 1


def phi_bits_word(w):
    # R + |w| function nodes + e : (|w| + 2) tokens, no indices
    return (len(w) + 2) * BS


V_BITS = 200  # a generous placeholder for |V_0| and |V_1|; the gap is linear in n, so the constant is irrelevant
P('(3) gap between the lower bound on l_AI_kappa and the upper bound on l_FIcert_{kappa,kappa}, '
  f'|V| := {V_BITS} bits (placeholder)')
P('    kappa   n        sum|phi|_bit   AI_lower(D^0)   FI_upper(D^0)   gap/n (D^0)   gap/n (D^all)   '
  'kappa(b_s+4)   4kappa')
for kappa in (1.0, 0.1):
    gen = words_lenlex()
    S = 0
    n = 0
    targets = {2 ** j for j in range(4, 18)}
    while n < 2 ** 17:
        w = next(gen)
        n += 1
        S += phi_bits_word(w)
        if n in targets:
            ai0 = kappa * (S + n * (BS + 4))
            fi0 = V_BITS + kappa * S
            ai1 = kappa * (S + 4 * n)
            fi1 = V_BITS + kappa * S
            if n in (2 ** 4, 2 ** 8, 2 ** 12, 2 ** 17):
                P(f'    {kappa:<6}  {n:<7}  {S:<13}  {ai0:<14.1f}  {fi0:<14.1f}  {(ai0 - fi0) / n:<12.3f}  '
                  f'{(ai1 - fi1) / n:<14.3f}  {kappa * (BS + 4):<13.1f}  {4 * kappa}')
P('    The gap per datum tends to kappa(b_s + 4) on D^0 and to 4 kappa on D^all: l_AI - l_FIcert_{kappa,kappa} -> infinity.')


# ---------------------------------------------------------------- (4) Prop 5.3(i): sum of word lengths
def sum_lengths(n):
    """sum_{i<=n} |w_i| in length-lexicographic order, exactly."""
    tot, k, left = 0, 0, n
    while left > 0:
        c = min(left, 2 ** k)
        tot += c * k
        left -= c
        k += 1
    return tot


worst = None
viol = 0
for n in list(range(1, 5000)) + [2 ** j + d for j in range(12, 40) for d in (-1, 0, 1, 2 ** (j - 1))]:
    s = sum_lengths(n)
    rhs = (n / 2) * (math.log2(n) - 3)
    if s < rhs:
        viol += 1
    ratio = (s - rhs) / n
    if worst is None or ratio < worst[0]:
        worst = (ratio, n)
P(f'(4) Prop 5.3(i) bound sum_{{i<=n}} |w_i| >= (n/2)(log2 n - 3): violations {viol}; '
  f'min (sum - rhs)/n = {worst[0]:.3f} at n = {worst[1]}')
P(f'    (the stronger sum >= n(log2 n - 2) holds as well: '
  f'{all(sum_lengths(n) >= n * (math.log2(n) - 2) for n in range(1, 5000))} for n < 5000)')

# ---------------------------------------------------------------- (5) the constants of Thm 5.2(b)
P('(5) Thm 5.2(b) constants: b_s, e_1 = 31 b_s + 24, r = max(2 b_s, 2 + e_1)')
for bs in range(3, 9):
    e1 = 31 * bs + 24
    P(f'    b_s = {bs}: e_1 = {e1}, r = {max(2 * bs, 2 + e1)}  (certificate rate of the first inequality: 2 b_s = {2 * bs})')

P('verdict: Thm 5.2(b) cannot hold with r = 1; the gap is linear in n on D^0 and on D^all (open problem 1 is refuted).')
with open(os.path.join(HERE, 'rc1_rate_one.out'), 'w') as fh:
    fh.write('\n'.join(out) + '\n')
print('\n'.join(out))
