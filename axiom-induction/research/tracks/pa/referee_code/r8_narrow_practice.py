# r8_narrow_practice.py -- referee for track "pa", Prop. 3.5(c) and F8 ("if the community uses only Sigma_n motives,
# every DT^o theory that covers its practice as citations contains PA-strength induction"; "Inside DT^o the
# posterior lands on the L-infinity (PA) side").
#
# Counterexample practice: Q (ground, as in u7) plus induction on motives of two shapes only,
#     Ex(s = t)  (Sigma_1)   and   ~(s = t)  (open),   s, t random terms (u7's rand_term), x free.
# Theory H_narrow = Q + T_E + T_N with TERM metavariables only:
#     T_E = Ind(lambda x. Ez (A(x,z) = B(x,z))),   T_N = Ind(lambda x. ~(C(x) = D(x))).
# Every instance of T_E is Sigma_1-induction and every instance of T_N is open induction, so Q + H_narrow is
# contained in I-Sigma_1, which does not prove Con(I-Sigma_1) (Goedel II), while PA does.  So H_narrow covers the
# practice as citations and is strictly weaker than PA: the statement of Prop. 3.5(c) fails for this practice (the
# per-connective wrappers of Prop. 2.2 need a FORMULA metavariable under the connective).
#
# Posterior: the track's positional shared grammar (c4_bdtrc.codelength).  (i) Validation at small n with the
# track's own code.  (ii) Closed form: H_true and H_narrow code the term subtrees in the same contexts, so their
# difference is the root symbol (ex / not) at the motive-root context, the '=' symbol at the two depth-3 contexts
# (both Dirichlet(1/2) over the 9 formula symbols), the template index (8 versus 9 templates), and the prior.
# Seeded (random.Random(31)).  Output: r8_narrow_practice.out next to this script.
import sys, os, math, random
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'checks'))
import c4_bdtrc as c4
from c2_mdl import plug_template
from dtlib import M, H, V, EX, NOT, eq, size, canon_params, Ind, T_IND, match
from practice import Q, rand_term, X
OUT = []
def say(s=''):
    print(s, flush=True); OUT.append(s)

T_E = plug_template(EX(eq(M('tA', H(0), V(0)), M('tB', H(0), V(0)))))
T_N = plug_template(NOT(eq(M('tC', H(0)), M('tD', H(0)))))
HYP = {'H_true = Q + T_Ind': dict(Q, Ind=T_IND), 'H_narrow = Q + T_E + T_N': dict(Q, IE=T_E, IN=T_N)}

def motive(rng):
    while True:
        if rng.random() < 0.5:
            m = EX(eq(rand_term(rng, 2, [X, V(0)]), rand_term(rng, 2, [X, V(0)])))
        else:
            m = NOT(eq(rand_term(rng, 2, [X]), rand_term(rng, 2, [X])))
        if 'h' in repr(m): return m          # x occurs

def data(n, rng):
    out = []
    keys = sorted(Q)
    for _ in range(n):
        if rng.random() < 0.5:
            out.append(canon_params(Ind(motive(rng))))
        else:
            out.append(Q[rng.choice(keys)])
    return out

lg = math.lgamma
def dbits(counts, a):
    n = sum(counts)
    return -(lg(a / 2) - lg(n + a / 2) + sum(lg(c + 0.5) - lg(0.5) for c in counts)) / math.log(2)

def closed_form(qcounts, n_e, n_n):
    """L(H_narrow) - L(H_true) without the prior: index + root + depth-3 '=' contexts."""
    idx_true = dbits(list(qcounts) + [n_e + n_n], 8)
    idx_narrow = dbits(list(qcounts) + [n_e, n_n], 9)
    root = dbits([n_e, n_n], 9)
    below = dbits([n_e], 9) + dbits([n_n], 9)
    return idx_narrow - (idx_true + root + below)

prior_diff = 5 * (size(T_E) + size(T_N) - size(T_IND))
say('template sizes: |T_Ind| = %d, |T_E| = %d, |T_N| = %d; prior difference L_prior(H_narrow) - L_prior(H_true) = %d bits'
    % (size(T_IND), size(T_E), size(T_N), prior_diff))
say()
say('(i) validation with the track\'s positional code (c4_bdtrc.codelength), seed 31')
rng = random.Random(31)
D = data(2000, rng)
for n in (100, 300, 1000, 2000):
    Dn = D[:n]
    assert all(c4.codelength({'x': T}, [d])[0] < math.inf for d in Dn for T in [T_IND] if d not in Q.values())
    Ls = {k: c4.codelength(Hh, Dn)[0] for k, Hh in HYP.items()}
    n_e = sum(1 for d in Dn if d not in Q.values() and match(T_E, d) is not None)
    n_n = sum(1 for d in Dn if d not in Q.values() and match(T_N, d) is not None)
    qc = [sum(1 for d in Dn if d == Q[k]) for k in sorted(Q)]
    cf = closed_form(qc, n_e, n_n) + prior_diff
    say('  n=%5d  L(H_narrow)-L(H_true): track code %+8.1f   closed form %+8.1f   (inductions: %d Ex-shape, %d ~-shape)'
        % (n, Ls['H_narrow = Q + T_E + T_N'] - Ls['H_true = Q + T_Ind'], cf, n_e, n_n))
say()
say('(ii) closed form at expected counts (p_ind = 1/2, shapes 1/2 each, Q axioms uniform): L(H_narrow) - L(H_true)')
cross = None
for e in range(3, 41):
    n = 2 ** e
    q = [n / 2 / 7] * 7
    d = closed_form(q, n / 4, n / 4) + prior_diff
    if e % 3 == 0 or (cross is None and d < 0):
        say('  n=2^%-2d  %+9.1f bits%s' % (e, d, '   <- H_narrow (weaker than PA) now preferred' if d < 0 and cross is None else ''))
    if d < 0 and cross is None: cross = e
say('Reading: the weaker theory gains 11.5 bits per doubling of n (H_true pays (9-1)/2 log2 n in each of the three')
say('formula contexts that H_narrow fixes, 12 log2 n; H_narrow pays 1/2 log2 n for one extra index weight) and overtakes Q + T_Ind near')
say('n = 2^%d.  This is the never-used-parts mechanism of the track\'s own section 2.3 / F3, and it lands the posterior on' % cross)
say('the weaker side, not the L-infinity side.')
open(os.path.join(HERE, 'r8_narrow_practice.out'), 'w').write('\n'.join(OUT) + '\n')
