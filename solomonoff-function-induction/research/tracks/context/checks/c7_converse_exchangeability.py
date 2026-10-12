"""c7: the combinatorial steps behind Prop 2.10, Prop 2.16 and Cor 2.17 (notes-final.md, Section 2.4),
checked exactly on a finite mixture that has deterministic total, deterministic partial, product
(private randomness) and shared-randomness hypotheses, so that undefined mass is present.

nu(D) = sum_h w_h * Pr_h[F extends D], with sum_h w_h < 1 (semimeasure).  Inputs X = {0..NX-1}, labels {0,1}.

Checks
  (1) Disjointness (Prop 2.10): for the target f and every subset B of X,
        sum_{x in B} [nu(f|B\\x) - nu(f|B)] <= nu(empty) - nu(f|B),
      and for the defined-wrong part mu(x) = sum_{y != f(x)} nu(f|B\\x + (x,y)):  sum_x mu(x) <= nu(empty) - nu(f|B).
  (2) Order: e_wr(x) <= e_norm(x) <= e_LOO(x) is NOT claimed in general; we check e_wr <= e_norm and e_wr <= e_LOO
      (both hold because sum_y nu(f|A + (x,y)) <= nu(f|A)).
  (3) Exchangeability (Cor 2.17): for i.i.d. x_1..x_m, x* from a distribution pi on X (repeats allowed),
        E[e(x*)] = E[ (1/(m+1)) * sum_{x in S, multiplicity 1} e_LOO(x; S) ]   (S = set of sampled values)
                <= E[ (nu(empty) - nu(f|S)) / ((m+1) nu(f|S)) ],
      computed exactly by enumerating all (m+1)-tuples, for several m and pi.
  (4) Markov form (Cor 2.17(a)): with hypotheses = (law, realisation) pairs, each a deterministic partial
      function h with weight w_h, and eps_h = pi{x : h(x) != f(x) or undefined},
        E[e(x*)] = E[ sum_{h extends D} w_h eps_h / nu(D) ] <= min_eps [ eps + nu(empty) e^{-eps m} / nu(f) ],
      checked exactly for the same m and pi (nu(f) <= nu(D) because f is a total labelling extending D).
Seed 7.
"""
import itertools
import numpy as np

rng = np.random.default_rng(7)
NX = 5
LAB = (0, 1)
out = []


def P(s):
    print(s)
    out.append(s)


# hypotheses as explicit finite laws over partial functions X -> {0,1,None}
hyps = []  # list of (weight, list of (prob, assignment tuple))
# deterministic total functions
for _ in range(6):
    a = tuple(int(v) for v in rng.integers(0, 2, NX))
    hyps.append([(1.0, a)])
# deterministic partial functions
for _ in range(4):
    a = tuple(None if rng.random() < 0.3 else int(rng.integers(0, 2)) for _ in range(NX))
    hyps.append([(1.0, a)])
# product laws with an undefined option (private randomness per input)
for _ in range(3):
    probs = rng.dirichlet([1, 1, 0.3], size=NX)  # P(0), P(1), P(undefined)
    law = []
    for a in itertools.product((0, 1, None), repeat=NX):
        p = 1.0
        for i, v in enumerate(a):
            p *= probs[i][0 if v == 0 else (1 if v == 1 else 2)]
        law.append((p, a))
    hyps.append(law)
# shared randomness: one coin for all inputs, and one coin per parity class of the input
hyps.append([(0.5, tuple([0] * NX)), (0.5, tuple([1] * NX))])
law = []
for c0, c1 in itertools.product((0, 1), repeat=2):
    law.append((0.25, tuple(c0 if i % 2 == 0 else c1 for i in range(NX))))
hyps.append(law)

w = rng.dirichlet(np.ones(len(hyps))) * 0.9  # total mass 0.9 < 1


def nu(D):
    """D: dict input -> label"""
    tot = 0.0
    for wh, law in zip(w, hyps):
        tot += wh * sum(p for p, a in law if all(a[x] == y for x, y in D.items()))
    return tot


# choose the target: the total labelling with the largest nu
cands = list(itertools.product(LAB, repeat=NX))
f = max(cands, key=lambda a: nu(dict(enumerate(a))))
P(f"target f = {f}; nu(empty) = {nu({}):.6f}; nu(f) = {nu(dict(enumerate(f))):.6f}")

cache = {}


def nuS(S, extra=None):
    key = (tuple(sorted(S)), extra)
    if key not in cache:
        D = {x: f[x] for x in S}
        if extra is not None:
            D[extra[0]] = extra[1]
        cache[key] = nu(D)
    return cache[key]


# (1) and (2)
ok1 = True; ok2 = True; worst_slack = np.inf
for r in range(1, NX + 1):
    for B in itertools.combinations(range(NX), r):
        nB = nuS(B)
        s_loo = sum(nuS(tuple(z for z in B if z != x)) - nB for x in B)
        s_mu = 0.0
        for x in B:
            A = tuple(z for z in B if z != x)
            mu = sum(nuS(A, (x, y)) for y in LAB if y != f[x])
            s_mu += mu
            nA = nuS(A)
            e_wr = mu / nA
            e_norm = mu / sum(nuS(A, (x, y)) for y in LAB)
            e_loo = 1 - nB / nA
            ok2 &= (e_wr <= e_norm + 1e-15) and (e_wr <= e_loo + 1e-15)
        bound = nu({}) - nB
        ok1 &= (s_loo <= bound + 1e-15) and (s_mu <= bound + 1e-15)
        worst_slack = min(worst_slack, bound - s_loo)
P(f"(1) disjointness: sum_x [nu(f|B\\x)-nu(f|B)] <= nu(empty)-nu(f|B) and sum_x mu(x) <= same, all {2**NX-1} sets B: {ok1} "
  f"(min slack {worst_slack:.3e})")
P(f"(2) e_wr <= e_norm and e_wr <= e_LOO at every point of every B: {ok2}")


# (3) exchangeability, exact enumeration
def e_sem(train_set, x):
    """semimeasure-convention error at x given the training set (as a set); 0 if x was seen"""
    if x in train_set:
        return 0.0
    A = tuple(sorted(train_set))
    return 1 - nuS(tuple(sorted(A + (x,)))) / nuS(A)


ok3 = True
for trial in range(3):
    pi = rng.dirichlet(np.ones(NX) * (0.5 + trial))
    for m in (1, 2, 4, 6):
        Ee = 0.0; Eid = 0.0; Eb = 0.0
        for tup in itertools.product(range(NX), repeat=m + 1):
            p = float(np.prod([pi[i] for i in tup]))
            train, xs = tup[:m], tup[m]
            Ee += p * e_sem(set(train), xs)
            S = set(tup)
            counts = {x: tup.count(x) for x in S}
            St = tuple(sorted(S))
            nSf = nuS(St)
            loo = sum(1 - nSf / nuS(tuple(z for z in St if z != x)) for x in S if counts[x] == 1)
            Eid += p * loo / (m + 1)
            Eb += p * (nu({}) - nSf) / ((m + 1) * nSf)
        ok = abs(Ee - Eid) < 1e-12 and Ee <= Eb + 1e-15
        ok3 &= ok
        # (4) Markov form
        hyps_flat = [(wh * p_, a) for wh, law in zip(w, hyps) for p_, a in law]
        eps_h = [sum(pi[x] for x in range(NX) if a[x] != f[x]) for _, a in hyps_flat]
        nf = nu(dict(enumerate(f)))
        mk = min(e_ + nu({}) * np.exp(-e_ * m) / nf for e_ in np.linspace(0, 1, 2001))
        ok4 = Ee <= mk + 1e-12
        ok3 &= ok4
        P(f"(3) pi #{trial} m={m}: E e(x*) = {Ee:.6f}; exchangeability identity error {abs(Ee - Eid):.1e}; "
          f"bound E[(nu(empty)-nu(f|S))/((m+1)nu(f|S))] = {Eb:.6f}; holds: {ok}; "
          f"(4) Markov bound min_eps[eps + nu(empty)e^(-eps m)/nu(f)] = {mk:.6f}; holds: {ok4}")
P(f"(3)+(4) all identities and bounds hold: {ok3}")
# (4') the Markov bound at larger m, against the exact expectation computed by the hypothesis-level formula
pi = rng.dirichlet(np.ones(NX))
hyps_flat = [(wh * p_, a) for wh, law in zip(w, hyps) for p_, a in law]
nf = nu(dict(enumerate(f)))
for m in (20, 50, 100, 200):
    # exact E e(x*) = sum over samples ... computed via hypotheses: E[sum_{h extends D_m} w_h eps_h / nu(D_m)] needs
    # the joint law of D_m; we use the upper bound E <= sum_h w_h eps_h (1-eps_h)^m / nu(f) (exact Markov step)
    mstep = sum(wh * sum(pi[x] for x in range(NX) if a[x] != f[x]) *
                (1 - sum(pi[x] for x in range(NX) if a[x] != f[x])) ** m for wh, a in hyps_flat) / nf
    mk = min(e_ + nu({}) * np.exp(-e_ * m) / nf for e_ in np.linspace(0, 1, 20001))
    P(f"(4') m={m}: sum_h w_h eps_h (1-eps_h)^m / nu(f) = {mstep:.3e} <= min_eps[...] = {mk:.3e}: {mstep <= mk + 1e-15}; "
      f"(ln(nu(empty)/nu(f)) + ln m + 1)/m = {(np.log(nu({}) / nf) + np.log(m) + 1) / m:.3e}")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
