# e1: Theorem A (matching).  (a) uniqueness: for random DT° templates T and random substitutions,
# the number of SO° matchers of s = T theta (counted by full projection/imitation) is exactly 1 and
# det_match returns theta; for random non-instances det_match and the general SO° test agree.
# (b) timing: det_match on instances of growing size (linear).  (c) subsumption by freezing agrees
# with explicit composition on random pairs T >= T sigma.
import sys, random, time
from dtcore import *
from dtrandom import rand_template, rand_theta, rand_body, arities, rand_term

rng = random.Random(3)
nT, uniq, rec, neg, negagree = 0, 0, 0, 0, 0
for _ in range(1500):
    T = rand_template(rng, nmeta=rng.choice([1, 2, 2]), max_derived=3)
    th = rand_theta(rng, T)
    s = instantiate(T, th)
    nT += 1
    if n_matchers(T, s) == 1:
        uniq += 1
    m = det_match(T, s)
    if m is not None and all(m[k] == th[k] for k in th):
        rec += 1
    # non-instance: instance of T with one derived occurrence perturbed (random other theta)
    th2 = rand_theta(rng, T)
    q = instantiate(T, th2)
    # splice: replace a random subterm position of q by a random term/formula of same sort
    from dtcore import positions as _pos
    cand = [(p, t, d, srt) for (p, t, d, srt) in _pos(q) if p]
    p, t, d, srt = rng.choice(cand)
    repl = rand_term(rng, d, 2) if srt == 'T' else eq(rand_term(rng, d, 2), Z)
    def put(u, path, v):
        if not path:
            return v
        ks = list(kids(u))
        ks[path[0]] = put(ks[path[0]], path[1:], v)
        return rebuild(u, ks)
    q2 = put(q, p, repl)
    a = det_match(T, q2) is not None
    b = covers(T, q2)
    neg += 1
    negagree += (a == b)
print('(a) random DT° templates:', nT, ' exactly one SO° matcher:', uniq, ' det_match recovers theta:', rec)
print('    perturbed queries:', neg, ' det_match agrees with general SO° membership:', negagree)

# (b) timing: T_ind and T_REP with large motives
def balanced(parts):
    while len(parts) > 1:
        parts = [AND(parts[i], parts[i + 1]) if i + 1 < len(parts) else parts[i]
                 for i in range(0, len(parts), 2)]
    return parts[0]
def big_motive(n):
    return balanced([eq(H(0), H(0))] + [ALL(eq(add(V(0), H(0)), S(Z))) for i in range(n)])
print('(b) timing (det_match on Ind(phi) with |phi| growing):')
for n in [10, 100, 1000, 10000, 100000]:
    s = Ind(big_motive(n))
    t = time.time()
    for _ in range(3):
        r = det_match(T_IND, s)
    dt = (time.time() - t) / 3
    print('    |s| = %7d   time %.4f s   ok=%s' % (size(s), dt, r is not None))
def big_rep(n):
    return balanced([mem(H(0), H(1))] + [EX(OR(mem(V(0), H(2)), eq(H(1), V(0)))) for i in range(n)])
for n in [10, 100, 1000, 10000, 100000]:
    s = instantiate(T_REP, {'P': big_rep(n)})
    t = time.time()
    r = det_match(T_REP, s)
    dt = time.time() - t
    print('    Replacement |s| = %7d   time %.4f s   ok=%s' % (size(s), dt, r is not None))

# (c) subsumption by freezing vs explicit composition
agree, tot = 0, 0
for _ in range(400):
    T = rand_template(rng, nmeta=1)
    nm, n = list(arities(T).items())[0]
    # sigma: M := lambda z. body with a fresh metavariable applied to holes (keeps DT°) or rigid
    if msort(nm) == 'T':
        cands = [S(M('g', *[H(i) for i in range(n)])), M('g', *[H(i) for i in range(n)][::-1]),
                 add(M('g', *[H(i) for i in range(n)]), Z)]
    else:
        cands = [NOT(M('G', *[H(i) for i in range(n)])), AND(M('G', *[H(i) for i in range(n)]), eq(Z, Z))]
    body = rng.choice(cands)
    T2 = instantiate(T, {nm: body})
    if not is_DT0(T2):
        continue
    tot += 1
    agree += subsumes(T, T2) and (not subsumes(T2, T) or equivalent(T, T2))
print('(c) T >= T sigma recognized by freezing:', agree, 'of', tot)
