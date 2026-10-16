#!/usr/bin/env python3
"""rb5_kolmogorov.py -- referee B, thread `fundamentals`: the Kolmogorov predictor (Prop 5.3(b), Thm 11.3).

Independent of the developer's c3_kolmogorov.py (different representation: syntax-tree sentences from
rb_common, explicit prefix-free codes with Kraft-checked lengths, a toy law built from the same list).

A "program list" is a list of (code, theory) with codes prefix-free binary strings and theories finite sets of
propositional formulas (stand-ins for r.e. axiom sets W_{V(p)}).  K_A(D) := min |code| over programs whose
theory is consistent and proves psi_D.  The Kolmogorov predictor uses the prec-first compatible program, where
prec is either "length then code" (refines length) or a random total order.  The toy law of the list gives
program p the mass 2^-|p| and the remaining mass to the empty theory (tapes with no program).

R5.1  Prop 5.3(b): exhaustive adversary (all consistent reveal sequences without repeats from a pool of
      sentences, both labels) on random lists, order refining length: failures (errors + abstentions) <=
      #{programs of length <= k} <= 2^k, k = max_t K_A(D_t).  Also the same search with a random order, to see
      whether "refines length" is needed for the bound (it is used in the proof).
R5.2  Thm 11.3: the adversary of the proof (w* = the w whose pi(w) is prec-last; present not desc(v) for a
      random open v != w*) on random lists with decoys, both kinds of order: exactly 2^m - 1 failures; data true
      at w*; with a length-refining order K_A(D) = |pi(w*)| >= m (Kraft); Bayes argmax mistakes on the same
      sequence <= -log(mass Ext{desc(w*)} / M(empty)).
R5.3  Thm 11.3, choice of w*: the same adversary with w* chosen as the w whose pi(w) is prec-FIRST; how often
      the loop stops before 2^m - 1 steps (shows the proof's choice of w* matters).
Seed 20261016.  Output: rb5_kolmogorov.out.
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

import rb_common as C
from rb_common import At, Not, And, Or, Imp, Iff, TOP, BOT, lit

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def rand_formula(k, depth):
    if depth == 0 or rng.random() < 0.3:
        return At(rng.randrange(k))
    op = rng.choice(['not', 'and', 'or', 'imp', 'iff'])
    if op == 'not':
        return Not(rand_formula(k, depth - 1))
    return (op, rand_formula(k, depth - 1), rand_formula(k, depth - 1))


def prefix_free_codes(lengths):
    """canonical prefix-free code with the given lengths (Kraft sum <= 1 required); returns codes in input order."""
    assert sum(Fr(1, 2 ** l) for l in lengths) <= 1
    order = sorted(range(len(lengths)), key=lambda i: lengths[i])
    codes = [None] * len(lengths)
    nxt = Fr(0)
    for i in order:
        l = lengths[i]
        codes[i] = format(int(nxt * 2 ** l), '0{}b'.format(l))
        nxt += Fr(1, 2 ** l)
    for a, b in itertools.permutations(codes, 2):
        assert not b.startswith(a)
    return codes


def random_lengths(n, lo, hi):
    """n lengths in [lo, hi] with Kraft sum <= 1 (resample)."""
    while True:
        ls = [rng.randint(lo, hi) for _ in range(n)]
        if sum(Fr(1, 2 ** l) for l in ls) <= 1:
            return ls


class Programs:
    def __init__(self, L, items, order='length'):
        self.L = L
        self.items = items                      # list of (code, model set of the theory)
        if order == 'length':
            self.order = sorted(range(len(items)), key=lambda i: (len(items[i][0]), items[i][0]))
        else:
            self.order = list(range(len(items)))
            rng.shuffle(self.order)

    def compatible(self, i, p):
        F = self.items[i][1]
        return bool(F) and F <= p

    def first(self, D):
        p = C.psi_mod(self.L, D)
        for i in self.order:
            if self.compatible(i, p):
                return i
        return None

    def KA(self, D):
        p = C.psi_mod(self.L, D)
        ls = [len(c) for i, (c, F) in enumerate(self.items) if self.compatible(i, p)]
        return min(ls) if ls else math.inf

    def law(self):
        law = {}
        tot = Fr(0)
        for (c, F) in self.items:
            w = Fr(1, 2 ** len(c))
            law[F] = law.get(F, Fr(0)) + w
            tot += w
        law[self.L.ALL] = law.get(self.L.ALL, Fr(0)) + (1 - tot)
        return law


def k_predict(P, D, f):
    i = P.first(D)
    F = P.items[i][1]
    if P.L.proves(F, f):
        return 1
    if P.L.proves(F, Not(f)):
        return 0
    return None


def r5_1():
    k_atoms = 3
    L = C.Logic(k_atoms)
    res = {}
    for order in ('length', 'random'):
        worst_count = -10 ** 9
        worst_kraft = -10 ** 9
        nseq = 0
        nlists = 0
        for trial in range(25):
            n = 10
            ls = random_lengths(n, 1, 6)
            codes = prefix_free_codes(ls)
            items = []
            for c in codes:
                th = [rand_formula(k_atoms, 2) for _ in range(rng.randint(1, 3))]
                items.append((c, L.mod_set(th)))
            P = Programs(L, items, order)
            pool = [rand_formula(k_atoms, 2) for _ in range(5)]
            # distinct by syntax
            pool = list(dict.fromkeys(pool))
            nlists += 1

            def dfs(D, fails, kmax):
                nonlocal worst_count, worst_kraft, nseq
                if D:
                    nseq += 1
                    nprog = sum(1 for (c, F) in items if len(c) <= kmax)
                    worst_count = max(worst_count, fails - nprog)
                    worst_kraft = max(worst_kraft, fails - 2 ** kmax)
                used = {f for f, _ in D}
                for f in pool:
                    if f in used:
                        continue
                    for y in (1, 0):
                        D2 = D + [(f, y)]
                        if not C.psi_mod(L, D2):
                            continue
                        if P.first(D2) is None:
                            continue       # sup K_A would be infinite; bound vacuous
                        pred = k_predict(P, D, f)
                        dfs(D2, fails + (pred != y), max(kmax, P.KA(D2)))

            if P.first([]) is None:
                continue
            dfs([], 0, P.KA([]))
        res[order] = (nlists, nseq, worst_count, worst_kraft)
    for order, (nl, ns, wc, wk) in res.items():
        out(f"R5.1 Prop 5.3(b), order = {order}: {nl} random lists (10 programs, lengths 1..6), {ns} consistent reveal "
            f"sequences (exhaustive, pool of 5 sentences, both labels): max of failures - #(programs of length <= k) = {wc}; "
            f"max of failures - 2^k = {wk}  [<= 0 claimed for 'length']")


def thm11_3_run(m, extra_decoys, order, wstar_rule='last', choose='random'):
    L = C.Logic(m)
    A = [At(i) for i in range(m)]

    def desc(w):
        return And(*[lit(A[i], w[i]) for i in range(m)])

    words = list(itertools.product((0, 1), repeat=m))
    theories = [L.mod(desc(w)) for w in words]
    # decoys: random consistent theories, some proving desc(v) for some v, some weaker; one inconsistent; empty
    for _ in range(extra_decoys):
        th = L.mod_set([rand_formula(m, 2) for _ in range(rng.randint(1, 3))])
        theories.append(th)
    theories.append(frozenset())
    theories.append(L.ALL)
    n = len(theories)
    ls = random_lengths(n, max(1, m - 1), m + 5)
    codes = prefix_free_codes(ls)
    items = list(zip(codes, theories))
    P = Programs(L, items, order)
    # pi(w): prec-first program consistent and proving desc(w)
    pos = {i: r for r, i in enumerate(P.order)}
    pi = {}
    for w in words:
        dm = L.mod(desc(w))
        cands = [i for i in P.order if items[i][1] and items[i][1] <= dm]
        pi[w] = cands[0]
    if wstar_rule == 'last':
        wstar = max(words, key=lambda w: pos[pi[w]])
    else:
        wstar = min(words, key=lambda w: pos[pi[w]])
    dstar = L.mod(desc(wstar))
    D = []
    fails = 0
    steps = 0
    while True:
        i = P.first(D)
        F = items[i][1]
        if F <= dstar:
            break
        opens = [v for v in words if (F & L.mod(desc(v)))]
        assert opens, "open set empty"
        cand = [v for v in opens if v != wstar]
        assert cand, "only w* open but p does not prove desc(w*)"
        v = rng.choice(cand) if choose == 'random' else cand[0]
        f = Not(desc(v))
        assert all(g != f for g, _ in D), "sentence presented twice"
        pred = k_predict(P, D, f)
        fails += (pred != 1)
        steps += 1
        D.append((f, 1))
    true_at_wstar = all(L.mod(f) >= dstar for f, _ in D)
    KA = P.KA(D)
    # Bayes argmax mistakes on the same sequence (trichotomy of the toy law)
    law = P.law()
    Z = C.consistent_mass(law)
    mist = 0
    for t in range(len(D)):
        b, d, i3 = C.tri(L, law, D[:t], D[t][0])
        best = max((b, 1), (d, 0), (i3, 'i'), key=lambda z: z[0])
        # ties count against the predictor
        if best[1] != 1 or [b, d, i3].count(best[0]) > 1:
            mist += 1
    extT = sum((x for F, x in law.items() if F and F <= dstar), Fr(0))
    bayes_bound = -C.lg(extT / Z)
    return dict(steps=steps, fails=fails, true=true_at_wstar, KA=KA, len_pi_wstar=len(items[pi[wstar]][0]),
                mist=mist, bound=bayes_bound, n=n)


def r5_2():
    rows = []
    for m in (2, 3, 4):
        for order in ('length', 'random'):
            ok_steps = ok_true = ok_ka = ok_bayes = ok_kraft = 0
            N = 12
            maxmist = 0
            for trial in range(N):
                r = thm11_3_run(m, extra_decoys=3 * m, order=order)
                ok_steps += (r['steps'] == 2 ** m - 1 and r['fails'] == 2 ** m - 1)
                ok_true += r['true']
                if order == 'length':
                    ok_ka += (r['KA'] == r['len_pi_wstar'] and r['KA'] >= m)
                ok_bayes += (r['mist'] <= r['bound'] + 1e-12)
                ok_kraft += (r['fails'] <= 2 ** r['KA'])
                maxmist = max(maxmist, r['mist'])
            ka = f"K_A(D) = |pi(w*)| >= m in {ok_ka} of {N}" if order == 'length' else "K_A >= m not claimed"
            out(f"R5.2 Thm 11.3, m = {m}, order = {order}: exactly 2^m-1 = {2 ** m - 1} steps, all failures, in {ok_steps} of {N}; "
                f"data true at w* in {ok_true} of {N}; {ka}; failures <= 2^K_A in {ok_kraft} of {N}; "
                f"Bayes mistakes <= -log(Ext/M(empty)) in {ok_bayes} of {N} (max mistakes {maxmist})")


def r5_3():
    for m in (2, 3, 4):
        early = 0
        N = 30
        for trial in range(N):
            r = thm11_3_run(m, extra_decoys=3 * m, order='length', wstar_rule='first')
            early += (r['steps'] < 2 ** m - 1)
        out(f"R5.3 Thm 11.3 with w* = argmin_w prec(pi(w)) instead of argmax, m = {m}: loop stops before 2^m - 1 steps "
            f"in {early} of {N} lists (the proof's choice of w* is needed)")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r5_1()
    r5_2()
    r5_3()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb5_kolmogorov.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
