#!/usr/bin/env python3
"""rb1_machines.py -- referee B, thread `fundamentals`: tape-level checks of Sections 1-4.

Everything is computed at the level of tapes (rb_common.machine_law enumerates all tape prefixes),
so the identities below are tested against the one-tape definitions, not against a formula for them.

R1.1  Thm 4.1 mixture identity: law of G_U (enumerated tapes) == sum_i 2^-|p_i| law(G_i) + (1-Omega) delta_empty.
R1.2  Prop 2.1(a): M(D) > 0 => D consistent; M3(D) > 0 => D consistent and B+D^pm decides no iota-sentence.
R1.3  Prop 2.1(b),(f): nu(D+1) + nu(D+0) + nu3(D+iota) = nu(D), and the same for three-valued bases.
R1.4  Prop 2.1(c): syntactic variants with the same content get the same weight; entailed free, contradicting fatal.
R1.5  Prop 2.1(d): order independence of the semimeasure loss over all orders, with repeats inserted.
R1.6  Prop 2.1(e): 0 < M(empty) = 1 - Inc_0 < 1 when the list has the empty and the {bot} machine.
R1.7  Prop 2.1(g): M3(D) == Unif{omega consistent : f_omega contains D}, f_omega computed per tape.
R1.8  Thm 3.2: the machine G_alpha has inconsistency probability = alpha (dyadic truncation at the horizon),
      and Inc_0 = 2^-|p_alpha| alpha + gamma_alpha in the toy universal machine.
R1.9  Prop 4.3: with B <= Cn(B'), the machine emitting B' plus G_U has, under background B, exactly the law M^{B'}.
R1.10 Thm 4.4: a faithful translation (definitional extension) -- (T1), (T2) on random Gamma; push-forward
      event == E_D exactly; pull-back event contains the translated event.
Seed 20261016.  Output: rb1_machines.out next to this script.
"""
import itertools
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
        return At(rng.randrange(k)) if rng.random() < 0.85 else (TOP if rng.random() < 0.5 else BOT)
    op = rng.choice(['not', 'and', 'or', 'imp', 'iff'])
    if op == 'not':
        return Not(rand_formula(k, depth - 1))
    a, b = rand_formula(k, depth - 1), rand_formula(k, depth - 1)
    return {'and': ('and', a, b), 'or': ('or', a, b), 'imp': ('imp', a, b), 'iff': ('iff', a, b)}[op]


def rand_machine(k, maxw=3, npairs=4):
    G = []
    for _ in range(rng.randint(1, npairs)):
        n = rng.randint(0, maxw)
        w = ''.join(rng.choice('01') for _ in range(n))
        G.append((w, rand_formula(k, 2)))
    return G


def rand_prefix_free(r):
    """r codes from a random binary tree; leaves not used as codes are 'no program'."""
    leaves = ['']
    while len(leaves) < r + rng.randint(1, 2):
        i = rng.randrange(len(leaves))
        x = leaves.pop(i)
        if len(x) >= 5:
            leaves.append(x)
            continue
        leaves += [x + '0', x + '1']
    rng.shuffle(leaves)
    return leaves[:r]


def coin_machine(k):
    return [(''.join(rng.choice('01') for _ in range(0)) + '0' * 0, TOP)] + \
        [(w, lit(At(len(w) - 1), int(w[-1]))) for n in range(1, k + 1) for w in
         (''.join(b) for b in itertools.product('01', repeat=n))]


def rand_data(L, k, n, consistent=True):
    v = rng.randrange(L.nv)
    D = []
    used = set()
    while len(D) < n:
        f = rand_formula(k, 2)
        if f in used:
            continue
        used.add(f)
        if consistent:
            D.append((f, 1 if v in L.mod(f) else 0))
        else:
            D.append((f, rng.randint(0, 1)))
    return D


def setup(k):
    L = C.Logic(k)
    machines = [[], [('', BOT)], coin_machine(k)]
    for _ in range(4):
        machines.append(rand_machine(k))
    codes = rand_prefix_free(len(machines))
    GU = C.universal_machine(machines, codes)
    return L, machines, codes, GU


def r1_1():
    out("R1.1 Thm 4.1 mixture identity (law of G_U from enumerated tapes vs the mixture formula)")
    worst = 0
    for trial in range(40):
        L, machines, codes, GU = setup(3)
        direct = C.machine_law(L, GU)
        mix = C.mixture_law(L, machines, codes)
        keys = set(direct) | set(mix)
        diff = max(abs(direct.get(m, Fr(0)) - mix.get(m, Fr(0))) for m in keys)
        worst = max(worst, diff)
    out(f"     40 random toy universal machines (3 atoms, 7 machines, random prefix-free codes): max |difference| = {worst}")


def r1_2_to_7():
    out("R1.2-R1.7 Prop 2.1 at tape level")
    cnt = dict(a=0, a3=0, b=0, f=0, c=0, d=0, e=0, g=0, pos=0)
    worst = dict(b=Fr(0), f=Fr(0), d=0.0, g=Fr(0))
    for trial in range(60):
        L, machines, codes, GU = setup(3)
        law = C.machine_law(L, GU)
        # (e)
        M0 = C.M(L, law, [])
        inc0 = law.get(frozenset(), Fr(0))
        cnt['e'] += int(0 < M0 < 1 and M0 == 1 - inc0)
        for _ in range(8):
            D = rand_data(L, 3, rng.randint(0, 3), consistent=rng.random() < 0.7)
            # three-valued data with some iota labels
            D3 = [(f, ('i' if rng.random() < 0.3 else y)) for (f, y) in D]
            # (a)
            if C.M(L, law, D) > 0:
                cnt['pos'] += 1
                cnt['a'] += int(bool(C.psi_mod(L, D)))
            if C.M(L, law, D3) > 0:
                p = C.psi_mod(L, D3)
                ok = bool(p) and all(not L.decides(p, f) for (f, y) in D3 if y == 'i')
                cnt['a3'] += int(ok)
                cnt['a3n'] = cnt.get('a3n', 0) + 1
            # (b),(f): new sentence phi
            phi = rand_formula(3, 2)
            if any(f == phi for (f, _) in D):
                continue
            two = [(f, y) for (f, y) in D]
            s = C.M(L, law, two + [(phi, 1)]) + C.M(L, law, two + [(phi, 0)]) + C.M(L, law, two + [(phi, 'i')])
            worst['b'] = max(worst['b'], abs(s - C.M(L, law, two)))
            s3 = sum(C.M(L, law, D3 + [(phi, y)]) for y in (1, 0, 'i'))
            worst['f'] = max(worst['f'], abs(s3 - C.M(L, law, D3)))
            # (c): syntactic variants
            var = [(Not(Not(f)), y) if rng.random() < 0.5 else (And(f, f), y) for (f, y) in two]
            cnt['var_ok'] = cnt.get('var_ok', 0) + int(C.M(L, law, var) == C.M(L, law, two))
            cnt['var_n'] = cnt.get('var_n', 0) + 1
            # entailed / contradicting
            if two and C.psi_mod(L, two):
                ent = Or(And(*[lit(f, y) for (f, y) in two]), rand_formula(3, 1))
                if ent not in [f for f, _ in two]:
                    ok = C.M(L, law, two + [(ent, 1)]) == C.M(L, law, two) and C.M(L, law, two + [(ent, 0)]) == 0
                    cnt['c_ent'] = cnt.get('c_ent', 0) + int(ok)
                    cnt['c_ent_n'] = cnt.get('c_ent_n', 0) + 1
            # (d): order independence with a repeat
            seq = two + ([two[0]] if two else [])
            if C.M(L, law, two) > 0:
                target = C.lg(C.M(L, law, [])) - C.lg(C.M(L, law, two))
                for perm in set(itertools.permutations(range(len(seq)))):
                    Lsum = 0.0
                    Dt = []
                    for idx in perm:
                        f, y = seq[idx]
                        if any(g == f for (g, _) in Dt):
                            continue  # repeat: factor 1 (stored label)
                        Lsum += C.lg(C.M(L, law, Dt)) - C.lg(C.M(L, law, Dt + [(f, y)]))
                        Dt.append((f, y))
                    worst['d'] = max(worst['d'], abs(Lsum - target))
            # (g): containment functional per tape
            N = max(len(w) for (w, _) in GU)
            tot = Fr(0)
            for bits in itertools.product('01', repeat=N):
                tape = ''.join(bits)
                F = L.mod_set([f for (w, f) in GU if tape.startswith(w)])
                if not F:
                    continue
                okk = True
                for (f, y) in D3:
                    lab = 1 if L.proves(F, f) else (0 if L.proves(F, Not(f)) else 'i')
                    if lab != y:
                        okk = False
                        break
                if okk:
                    tot += Fr(1, 2 ** N)
            worst['g'] = max(worst['g'], abs(tot - C.M(L, law, D3)))
    out(f"     (a) M(D)>0 => D consistent: {cnt['a']} of {cnt['pos']};  M3(D)>0 => consistent and no iota-sentence decided: "
        f"{cnt['a3']} of {cnt.get('a3n', 0)}")
    out(f"     (b) max |nu(D+1)+nu(D+0)+nu3(D+iota) - nu(D)| = {worst['b']};  (f) three-valued base: {worst['f']}")
    out(f"     (c) syntactic variants (double negation, phi&phi) same weight in {cnt.get('var_ok', 0)} of {cnt.get('var_n', 0)}; "
        f"entailed datum free and contradicting datum fatal in {cnt.get('c_ent', 0)} of {cnt.get('c_ent_n', 0)}")
    out(f"     (d) max |loss over all orders with a repeat - (log M(empty) - log M(D))| = {worst['d']:.2e}")
    out(f"     (e) 0 < M(empty) = 1 - Inc_0 < 1 in {cnt['e']} of 60 toy universal machines")
    out(f"     (g) max |M3(D) - Unif{{consistent tapes with f_omega containing D}}| = {worst['g']}")


def r1_8():
    out("R1.8 Thm 3.2: the machine G_alpha and the decomposition of Inc_0")
    L = C.Logic(1)
    worst = Fr(0)
    for trial in range(30):
        # a left-c.e. alpha given by increasing dyadic approximations alpha_s (finite stand-in of a halting set)
        halting = sorted(rng.sample(range(1, 9), rng.randint(1, 5)))
        alphas = []
        a = Fr(0)
        order = halting[:]
        rng.shuffle(order)                     # enumerated in a random order: alpha_s increases
        for n in order:
            a += Fr(1, 2 ** (n + 1))
            alphas.append(a)
        N = 10
        G = []
        for n in range(N + 1):
            for bits in itertools.product('01', repeat=n):
                w = ''.join(bits)
                val = Fr(int(w, 2) if w else 0, 2 ** n)
                if any(val + Fr(1, 2 ** n) <= s for s in alphas):
                    G.append((w, BOT))
        law = C.machine_law(L, G) if G else {L.ALL: Fr(1)}
        inc = law.get(frozenset(), Fr(0))
        alpha = alphas[-1]
        expect = Fr(int(alpha * 2 ** N), 2 ** N)   # alpha is dyadic with denominator <= 2^10 here
        worst = max(worst, abs(inc - expect))
        # decomposition inside a toy universal machine with G_alpha at code p
        machines = [[], [('', BOT)], G, [('', At(0))]]
        codes = ['0', '10', '110', '1110']
        lawU = C.mixture_law(L, machines, codes)
        inc0 = lawU.get(frozenset(), Fr(0))
        gamma = Fr(1, 2)  # the {bot} machine at code '10' contributes 2^-2 * 1 ... computed below
        gamma = sum(Fr(1, 2 ** len(p)) * C.machine_law(L, m).get(frozenset(), Fr(0))
                    for m, p in zip(machines, codes) if p != '110' and m)
        worst = max(worst, abs(inc0 - (Fr(1, 8) * inc + gamma)))
    out(f"     30 random dyadic alphas (horizon 10): max |Inc(G_alpha) - alpha| and decomposition error = {worst}")


def r1_9():
    out("R1.9 Prop 4.3: the background as a prior shift")
    worst = Fr(0)
    for trial in range(30):
        L, machines, codes, GU = setup(3)
        B = rand_formula(3, 1)
        Bp = And(B, rand_formula(3, 1))        # B' proves B
        if not L.mod(Bp):
            continue
        GB = [('', Bp)] + GU
        law_shift = C.machine_law(L, GB, B=B)
        law_Bp = C.machine_law(L, GU, B=Bp)
        for _ in range(5):
            D = rand_data(L, 3, rng.randint(0, 3))
            worst = max(worst, abs(C.M(L, law_shift, D, B=B) - C.M(L, law_Bp, D, B=Bp)))
    out(f"     nu^B_{{G_B'}}(D) == M^{{B'}}(D): max |difference| over 30 x 5 cases = {worst}")


def _subterms(fs):
    stack = list(fs)
    while stack:
        f = stack.pop()
        yield f
        if f[0] in ('not',):
            stack.append(f[1])
        elif f[0] in ('and', 'or', 'imp', 'iff'):
            stack += [f[1], f[2]]


def r1_10():
    out("R1.10 Thm 4.4: faithful translations into L'(k+1) with B' = (q_k <-> q_0 & q_1), tau a random onto substitution")
    k = 2
    L = C.Logic(k)
    Lp = C.Logic(k + 1)
    Bp = Iff(At(k), And(At(0), At(1)))

    # tau is induced by a substitution sigma: atom p_i -> an L'-formula; it is faithful (T1) iff the map
    # g: Mod(B') -> Val(L), u -> (sigma(p_i)(u))_i is onto.  Search for an onto sigma that uses q_k.
    while True:
        sigma = [rand_formula(k + 1, 2) for _ in range(k)]
        if not any('atom' == t[0] and t[1] == k for t in _subterms(sigma)):
            continue
        img = {tuple(int(u in Lp.mod(sg)) for sg in sigma) for u in Lp.mod(Bp)}
        if len(img) == L.nv:
            break
    out(f"     substitution sigma = {sigma}")

    def tau(f):
        t = f[0]
        if t == 'atom':
            return sigma[f[1]]
        if t in ('top', 'bot'):
            return f
        if t == 'not':
            return Not(tau(f[1]))
        return (t, tau(f[1]), tau(f[2]))

    # (T1), (T2) on random Gamma
    bad = 0
    for _ in range(400):
        Gam = [rand_formula(k, 2) for _ in range(rng.randint(0, 3))]
        phi = rand_formula(k, 2)
        lhs = L.mod_set(Gam) <= L.mod(phi)
        rhs = (Lp.mod(Bp) & Lp.mod_set([tau(g) for g in Gam])) <= Lp.mod(tau(phi))
        t2 = Lp.mod(Bp) <= Lp.mod(Iff(tau(Not(phi)), Not(tau(phi))))
        bad += int(lhs != rhs or not t2)
    out(f"     (T1),(T2) violated in {bad} of 400 random (Gamma, phi)")
    # push-forward and pull-back on random laws over L-theories (as machines emitting L-formulas)
    worst_push = Fr(0)
    pull_ok = 0
    ntest = 0
    for trial in range(30):
        G = rand_machine(k, maxw=2, npairs=4)
        law = C.machine_law(L, G)
        Gp = [(w, tau(f)) for (w, f) in G]
        lawp = C.machine_law(Lp, Gp, B=Bp)
        # a random L'-machine for the pull-back
        H = rand_machine(k + 1, maxw=2, npairs=3)
        lawH = C.machine_law(Lp, H, B=Bp)
        # pull-back content: tau*(A') = {phi : B' + A' |- tau(phi)}; its model set over L
        all_L_sets = [frozenset(S) for r in range(L.nv + 1) for S in itertools.combinations(range(L.nv), r)]

        def pull(Fp):
            m = L.ALL
            for S in all_L_sets:
                if Fp <= Lp.mod(tau(L.formula_of(S))):
                    m = m & S
            return m
        for _ in range(6):
            D = rand_data(L, k, rng.randint(1, 3))
            tD = [(tau(f), y) for (f, y) in D]
            worst_push = max(worst_push, abs(C.M(L, law, D) - C.M(Lp, lawp, tD, B=Bp)))
            # pull-back: every L'-theory compatible with tau D pulls back to an L-theory compatible with D
            for Fp, x in lawH.items():
                if Fp and Fp <= C.psi_mod(Lp, tD, B=Bp):
                    ntest += 1
                    Fpull = pull(Fp)
                    pull_ok += int(bool(Fpull) and Fpull <= C.psi_mod(L, D))
    out(f"     push-forward: max |M(D) - M'(tau D)| for the image machine = {worst_push};  "
        f"pull-back keeps consistency and compatibility in {pull_ok} of {ntest} cases")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r1_1()
    r1_2_to_7()
    r1_8()
    r1_9()
    r1_10()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb1_machines.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
