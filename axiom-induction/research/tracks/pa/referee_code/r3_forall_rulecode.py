# r3_forall_rulecode.py -- referee for track "pa", section 4.5 ("The universal sentence loses under L1 ... its posterior
# odds fall like 2^(-3.3n). This is H4's prediction").  The track charges the extra forall-E step a FIXED log2(10)
# bits per datum.  Here the derivation's rule choices are coded the way the track itself recommends for the
# instantiation grammar in section 2: by a learned (Dirichlet(1/2) = sequential KT) distribution, either with one
# shared context or with the node's depth in the derivation tree as context.
#
# Data: n closed instances t+0=t.  H_sch = {z+0=z}: each datum is the derivation [ax].  H_all = {Ax(x+0=x)}: each
# datum is [forall-E at the root, ax below it].  The term t costs the same under both (it is drawn from the same
# grammar Q at the same position) and cancels, as does the citation index (one axiom in each theory).
# Reported: L(H_all) - L(H_sch) in bits, i.e. log2 of the posterior odds H_sch : H_all, without the prior term
# (the track adds 5 bits for one extra template symbol).  Deterministic.  Output: r3_forall_rulecode.out.
import math, os
HERE = os.path.dirname(os.path.abspath(__file__))
R = 10                     # number of rules, as in the track's calculus
lg = math.lgamma
def kt(counts, alphabet=R):
    """-log2 of the Dirichlet(1/2) marginal (= sequential KT) of a count vector over `alphabet` symbols."""
    n = sum(counts)
    v = lg(alphabet / 2) - lg(n + alphabet / 2) + sum(lg(c + 0.5) - lg(0.5) for c in counts)
    return -v / math.log(2)

out = []
out.append('L(H_all) - L(H_sch) in bits (positive: the posterior prefers the instance schema), rule codes:')
out.append('  fixed   : uniform over 10 rules, as in c4_bdtrc.py (log2 10 per extra step)')
out.append('  shared  : learned rule distribution, one context for all derivation nodes')
out.append('  depth   : learned rule distribution, context = depth of the node in the derivation tree')
out.append('%8s %10s %10s %10s %14s' % ('n', 'fixed', 'shared', 'depth', 'depth/log2(n)'))
for n in (10, 30, 100, 300, 1000, 3000, 10 ** 4, 10 ** 5, 10 ** 6):
    fixed = n * math.log2(R)
    # shared context: H_sch emits n 'ax'; H_all emits n 'allE' and n 'ax'
    shared = kt([n, n]) - kt([n])
    # depth context: H_sch: depth 0 -> n 'ax'.  H_all: depth 0 -> n 'allE', depth 1 -> n 'ax'
    depth = (kt([n]) + kt([n])) - kt([n])
    out.append('%8d %10.1f %10.1f %10.1f %14.2f' % (n, fixed, shared, depth, depth / math.log2(n)))
out.append('Reading: with a fixed or a shared rule code the penalty is linear (3.3 or about 2 bits per datum); with a')
out.append('depth-conditioned rule code it is (R-1)/2 * log2 n + O(1) = 4.5 log2 n: polynomial posterior odds, not')
out.append('exponential.  The direction (H_sch favoured) survives; the exponential rate is a property of the rule code.')
open(os.path.join(HERE, 'r3_forall_rulecode.out'), 'w').write('\n'.join(out) + '\n')
print('\n'.join(out))
