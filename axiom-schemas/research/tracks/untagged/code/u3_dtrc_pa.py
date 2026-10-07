# u3: end-to-end DTRC on unlabelled PA data (Q1..Q7 in closure-normal form + raw induction instances), with the
# arithmetic world (Delta_0 + forall-E + EUF/Diag(N) verification of universals + pure logic).
# Reports: clusters vs hidden labels, number of coherence tests, the per-cluster unrefuted minimal templates,
# exactness of the induction cluster (all unrefuted minimal templates >= T_ind; one <= T_ind), and acceptance of
# held-out genuine instances and of near-miss false sentences.
import sys, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC, separation_check
from practice import *
import refuters as R

def run(n, seed, p_ind=0.5):
    rng = random.Random(seed)
    data = pa_data(n, rng, p_ind=p_ind)
    rng.shuffle(data)
    lab = {}
    for k, s in data: lab.setdefault(s, set()).add(k)
    W = World('arith', B=3, budget=1500, seed=seed)
    A = DTRC(W)
    t0 = time.time()
    cl = A.run([s for _, s in data])
    dt = time.time() - t0
    pure = all(len(set().union(*[lab[s] for s in C])) == 1 for C in cl)
    print('seed %d: n=%d distinct=%d clusters=%d  pure=%s  coherence tests=%d  refutation searches=%d  time=%.1fs'
          % (seed, n, len(lab), len(cl), pure, A.tests, W.calls, dt))
    ms = A.minsizes
    print('   v2: passes to audit fixpoint=%d  |N_final|=%d  |Min(X)| per test: max=%d mean=%.2f (=1 in %d/%d tests)'
          % (A.rounds, len(W.neg), max(ms), sum(ms) / len(ms), sum(1 for m in ms if m == 1), len(ms)))
    npairs, ntpl, unref = separation_check(W, lab)
    print('   v2: RS on D for the implemented oracle: %d cross pairs, %d minimal templates, unrefuted: %d; '
          're-audit after the check: %d inconsistent decisions; |N| now %d' % (npairs, ntpl, len(unref), len(A.audit()), len(W.neg)))
    for C, Ts in zip(A.clusters, A.templates):
        labs = set().union(*[lab[s] for s in C])
        tag = ','.join(sorted(labs))
        if tag == 'Ind':
            exact = all(subsumes(T, T_IND) for T in Ts) and len(Ts) > 0
            sound = any(subsumes(T_IND, T) for T in Ts)
            roots = sorted(set(s[2][1][0] if False else '' for s in C))
            print('   cluster %-4s size=%3d  unrefuted minimal templates=%d  exact(all >= T_ind)=%s  some <= T_ind=%s'
                  % (tag, len(C), len(Ts), exact, sound))
            for T in Ts[:2]: print('        ', pp(T))
        else:
            print('   cluster %-4s size=%3d  templates=%s' % (tag, len(C), [pp(T) for T in Ts]))
    return A

A = None
for seed in (1, 2, 3):
    A = run(40, seed)
# held-out tests with the last learner
rng = random.Random(99)
held = [canon_params(Ind(rand_motive(rng, 3))) for _ in range(200)]
acc = sum(A.accepts(s) for s in held)
print('held-out genuine induction instances accepted: %d/%d' % (acc, len(held)))
# near misses: step-by-2 induction, wrong base, mutated Q axioms, bare false sentences
def ind2(m):
    return IMP(AND(plug(m, [Z]), ALL(IMP(plug(m, [V(0)]), plug(m, [S(S(V(0)))])))), ALL(plug(m, [V(0)])))
def indS(m):
    return IMP(AND(plug(m, [S(Z)]), ALL(IMP(plug(m, [V(0)]), plug(m, [S(V(0))])))), ALL(plug(m, [V(0)])))
near = [canon_params(ind2(rand_motive(rng, 2))) for _ in range(50)] + [canon_params(indS(rand_motive(rng, 2))) for _ in range(50)]
near += [eq(add(a1, Z), Z), NOT(eq(S(a1), a1)), eq(mul(a1, S(Z)), a1), eq(Z, S(Z))]
print('near-miss non-instances accepted: %d/%d' % (sum(A.accepts(s) for s in near), len(near)))
# a near miss is genuine iff it equals the induction instance of its own conclusion's motive
def genuine(s):
    try:
        return s[0] == 'imp' and s[2][0] == 'all' and canon_params(Ind(abstract_motive(s[2][1]))) == s
    except Exception:
        return False
def abstract_motive(body):
    # body is the conclusion's matrix under one binder: replace ('v',0) at binder depth j by hole
    def R(t, j):
        if t[0] == 'v':
            if t[1] == j: return ('h', 0)
            if t[1] > j: return ('v', t[1] - 1)
            return t
        if t[0] in BINDERS: return (t[0], R(t[1], j + 1))
        ks = kids(t)
        return t if not ks else rebuild(t, [R(k, j) for k in ks])
    return R(body, 0)
bad = [s for s in near if A.accepts(s) and not genuine(s)]
print('near misses that are genuine induction instances (vacuous motives):', sum(genuine(s) for s in near))
print('accepted near misses that are NOT genuine:', len(bad))
for s in bad[:5]: print('   ', pp(s))
