# c7_rulecode.py -- the cost of the extra forall-elimination step of H_all = {Ax phi} against the instance schema
# H_sch = {phi(z)} on instance data, under different codes for the RULE choices of a derivation (referee issue M5;
# notes-final.md section 5.5).  Closed form; deterministic.  Output c7_rulecode.out.
#
# A derivation of a datum phi(t) is [ax] under H_sch and [allE at depth 0, ax at depth 1] under H_all.  The term t
# costs the same under both (same grammar, same position), and so does the citation index (one axiom each), so the
# difference of code lengths is the difference of the rule codes (plus the prior, not included here).
# Rule codes:
#   fixed   uniform over R rules: log2 R bits per node (c4_bdtrc.py used R = 10)
#   shared  one learned Dirichlet(1/2) (= sequential KT) rule distribution for all nodes
#   depth   one learned rule distribution per depth of the node in the derivation
# Two practices:
#   (i)  pure: every datum is a phi-instance (the setting of c4_bdtrc.py part (B));
#   (ii) mixed: a fraction f of the data are phi-instances, the rest are direct citations of other (ground) axioms,
#        as in a practice that also cites Q1..Q7.  Then the root context sees 'ax' from the ground citations.
import math
LG = math.lgamma
def kt_bits(counts, A):
    n = sum(counts)
    return -(LG(A / 2) - LG(n + A / 2) + sum(LG(c + 0.5) - LG(0.5) for c in counts)) / math.log(2)

OUT = []
def say(s=''):
    print(s); OUT.append(s)

for R in (10, 2):
    say('R = %d rules%s' % (R, '  (the track\'s calculus)' if R == 10 else '  (the minimal calculus {cite, allE} of track universal)'))
    say('  (i) pure instance data: L(H_all) - L(H_sch) in bits')
    say('  %9s %12s %12s %10s %12s' % ('n', 'fixed', 'shared', 'depth', 'depth/log2n'))
    for n in (10, 30, 100, 300, 1000, 3000, 10 ** 4, 10 ** 5, 10 ** 6):
        fixed = n * math.log2(R)
        shared = kt_bits([n, n], R) - kt_bits([n], R)
        depth = kt_bits([n], R) + kt_bits([n], R) - kt_bits([n], R)
        say('  %9d %12.1f %12.1f %10.1f %12.2f' % (n, fixed, shared, depth, depth / math.log2(n)))
    say('  (ii) mixed practice, fraction f of phi-instances; per-datum difference at n = 10^6 and its limit')
    for f in (0.9, 0.5, 0.1):
        n = 10 ** 6
        ni = round(f * n); ng = n - ni
        # H_sch: depth 0 sees ax for all n data.  H_all: depth 0 sees allE (ni) and ax (ng); depth 1 sees ax (ni).
        d_depth = (kt_bits([ni, ng], R) + kt_bits([ni], R)) - kt_bits([n], R)
        # shared context: H_sch emits n 'ax'; H_all emits ni 'allE' and n 'ax'
        d_shared = kt_bits([ni, n], R) - kt_bits([n], R)
        h = -(f * math.log2(f) + (1 - f) * math.log2(1 - f))
        say('      f=%.1f  depth: %10.1f bits (%.4f per datum; binary entropy h(f) = %.4f)   shared: %10.1f (%.4f per'
            ' datum)' % (f, d_depth, d_depth / n, h, d_shared, d_shared / n))
    say()
say('Reading.  Fixed code: log2 R bits per instance datum, exponential posterior odds.  Learned shared code: still')
say('linear.  Learned depth-indexed code on pure instance data: (R-1)/2 log2 n + O(1), polynomial odds.  In a mixed')
say('practice the extra step shares its context with other rules and costs about h(f)/f bits per instance datum')
say('(linear again).  The direction (H_sch preferred) holds under every code; the rate is a property of the code')
say('and of the practice.')
open('c7_rulecode.out', 'w').write('\n'.join(OUT) + '\n')
