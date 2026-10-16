#!/usr/bin/env python3
"""rb3_loss.py -- referee B, thread `fundamentals`: loss bounds, merging and limits on finite stand-ins.

R3.1  Thm 5.1: on adversarial reveal sequences decided by T, L(D_n) - L(empty) <= L(D_n) <= -log mass(Ext T).
R3.2  Prop 5.3(a): Bayes argmax over (Bel, Dis, Indep) -- an exhaustive adversary (depth-first search over all
      orders of a pool of T-decided sentences) maximises the number of mistakes; compare with
      -log(mass(Ext T) / M(empty)).
R3.3  Prop 5.2(c): "T plus fair coins on alpha_j" at code p: -log M(D) <= |p| + m (m coin data), tape level.
R3.4  Cor 5.5: three-valued loss -log M3(D) + log M(empty) <= -log mass[T] on trichotomy-labelled data.
R3.5  Prop 6.1(a), Prop 5.6 core: sum over pairwise incompatible S of Bel_0 <= M(empty); sum over all label
      vectors on a fixed domain of M(D_b) <= M(empty).
R3.6  Thm 5.4: three-valued merging identity sum_t E d_t = E log nu3(D_n)/M3(D_n) + log M(empty) and the bound
      <= -log w_G + log M(empty), exact enumeration, with a history- and coin-dependent question rule that
      also repeats questions; Pinsker sum.
R3.7  Props 8.1, 8.3: TV bound (a_n - a)/a_n; incomplete truth -- two-valued limit trichotomy formula and
      Indep >= mass[T*]/mass(Ext T*); three-valued data leave only [T*].
Seed 20261016.  Output: rb3_loss.out.
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


def rand_law(L, k, extra=()):
    machines = [[], [('', BOT)]]
    for _ in range(3):
        machines.append([('', rand_formula(k, 2)) for _ in range(rng.randint(1, 2))])
    for _ in range(2):
        G = []
        for _ in range(rng.randint(1, 4)):
            n = rng.randint(0, 2)
            G.append((''.join(rng.choice('01') for _ in range(n)), rand_formula(k, 2)))
        machines.append(G)
    machines += list(extra)
    codes = ['00', '010', '011', '100', '1010', '1011', '110', '11100', '11101', '11110'][:len(machines)]
    order = list(range(len(codes)))
    rng.shuffle(order)
    codes = [codes[i] for i in order]
    return C.mixture_law(L, machines, codes), machines, codes


def ext_mass(L, law, T):
    return sum((x for F, x in law.items() if F and F <= T), Fr(0))


def class_mass(L, law, T):
    return law.get(T, Fr(0))


def bayes_pred(L, law, D, f):
    b, d, i = C.tri(L, law, D, f)
    best = max(b, d, i)
    return [y for y, v in ((1, b), (0, d), ('i', i)) if v == best]


def r3_1_2():
    k = 3
    L = C.Logic(k)
    worst1 = -1e9
    worst2 = -1e9
    n1 = n2 = 0
    maxmist = 0
    for trial in range(40):
        T_formula = rand_formula(k, 2)
        law, _, _ = rand_law(L, k, extra=[[('', T_formula)]])
        T = L.mod(T_formula)
        if not T:
            continue
        E = ext_mass(L, law, T)
        if E == 0:
            continue
        M0 = C.M(L, law, [])
        pool = []
        seen = set()
        while len(pool) < 6:
            f = rand_formula(k, 2)
            if f in seen or not L.decides(T, f):
                continue
            seen.add(f)
            pool.append((f, 1 if L.proves(T, f) else 0))
        # R3.1 all orders of the pool
        for perm in itertools.permutations(pool):
            D = list(perm)
            n1 += 1
            loss = -C.lg(C.M(L, law, D))
            worst1 = max(worst1, loss - (-C.lg(E)))
        # R3.2 exhaustive adversary for mistakes (a mistake: some argmax label differs -- ties count against)
        best = [0]

        def dfs(D, used, mist):
            best[0] = max(best[0], mist)
            for j, (f, y) in enumerate(pool):
                if j in used:
                    continue
                preds = bayes_pred(L, law, D, f)
                m = int(any(p != y for p in preds))
                dfs(D + [(f, y)], used | {j}, mist + m)
        dfs([], frozenset(), 0)
        n2 += 1
        bound = -C.lg(E / M0)
        maxmist = max(maxmist, best[0])
        worst2 = max(worst2, best[0] - bound)
    out(f"R3.1 {n1} (T, order) cases: max of L(D_n) - (-log mass Ext T) = {worst1:.4f}  [<= 0]")
    out(f"R3.2 {n2} laws, exhaustive adversary over all orders of 6 T-decided sentences (ties count as mistakes): "
        f"max mistakes {maxmist}; max of mistakes - (-log(mass Ext T / M(empty))) = {worst2:.4f}  [<= 0]")


def r3_3():
    k = 4
    L = C.Logic(k)
    worst = -1e9
    cases = 0
    for trial in range(20):
        T_formula = Imp(At(0), At(1))                 # a law; coins on atoms 2, 3
        coin = [('', T_formula)] + [(w, lit(At(2 + len(w) - 1), int(w[-1])))
                                    for n in (1, 2) for w in (''.join(b) for b in itertools.product('01', repeat=n))]
        law, machines, codes = rand_law(L, k, extra=[coin])
        p = codes[len(machines) - 1]
        for _ in range(5):
            x = [rng.randint(0, 1) for _ in range(2)]
            D = []
            used = rng.sample([0, 1], rng.randint(1, 2))
            for j in used:
                D.append((At(2 + j), x[j]))
            D.append((Or(Not(At(0)), At(1)), 1))     # proved by T (syntactically different)
            m = len(used)
            cases += 1
            worst = max(worst, -C.lg(C.M(L, law, D)) - (len(p) + m))
    out(f"R3.3 laws plus coin facts, {cases} cases: max of -log M(D) - (|p| + m) = {worst:.4f}  [<= 0]")


def r3_4_5():
    k = 3
    L = C.Logic(k)
    worst4 = -1e9
    worst5a = Fr(-1)
    worst5b = Fr(-1)
    n4 = 0
    for trial in range(40):
        T_formula = rand_formula(k, 2)
        law, _, _ = rand_law(L, k, extra=[[('', T_formula)]])
        T = L.mod(T_formula)
        M0 = C.M(L, law, [])
        if T:
            D3 = []
            seen = set()
            while len(D3) < 5:
                f = rand_formula(k, 2)
                if f in seen:
                    continue
                seen.add(f)
                D3.append((f, 1 if L.proves(T, f) else (0 if L.proves(T, Not(f)) else 'i')))
            cm = class_mass(L, law, T)
            if cm > 0:
                n4 += 1
                worst4 = max(worst4, -C.lg(C.M(L, law, D3)) + C.lg(M0) - (-C.lg(cm)))
        # R3.5: pairwise incompatible S (a random partition of the valuations into blocks, as sentences)
        vals = list(range(L.nv))
        rng.shuffle(vals)
        cuts = sorted(rng.sample(range(1, L.nv), rng.randint(1, 5)))
        blocks = [vals[a:b] for a, b in zip([0] + cuts, cuts + [L.nv])]
        S = [L.formula_of(frozenset(bk)) for bk in blocks]
        tot = sum(C.bel0(L, law, s) for s in S)
        worst5a = max(worst5a, tot - M0)
        dom = [rand_formula(k, 2) for _ in range(3)]
        if len(set(dom)) == 3:
            tot = sum(C.M(L, law, list(zip(dom, b))) for b in itertools.product((0, 1), repeat=3))
            worst5b = max(worst5b, tot - M0)
    out(f"R3.4 {n4} three-valued presentations: max of (-log M3(D) + log M(empty)) - (-log mass[T]) = {worst4:.4f}  [<= 0]")
    out(f"R3.5 max of sum_S Bel_0 - M(empty) = {worst5a};  max of sum_b M(D_b) - M(empty) = {worst5b}  [<= 0]")


def r3_6():
    k = 3
    L = C.Logic(k)
    worst_id = 0.0
    worst_bd = -1e9
    worst_pin = -1e9
    n = 4
    for trial in range(40):
        # G: an a.s. consistent random theory (a machine whose every tape gives a consistent theory)
        while True:
            G = [(''.join(rng.choice('01') for _ in range(rng.randint(0, 2))), rand_formula(k, 2)) for _ in range(3)]
            nuG = C.machine_law(L, G)
            if frozenset() not in nuG:
                break
        law, machines, codes = rand_law(L, k, extra=[G])
        w = Fr(1, 2 ** len(codes[len(machines) - 1]))
        M0 = C.M(L, law, [])
        cands = [rand_formula(k, 2) for _ in range(5)]

        def rule(hist, xi):
            # history- and coin-dependent; may repeat an earlier question
            h = 0
            for (_, y) in hist:
                h = 3 * h + {1: 1, 0: 2, 'i': 0}[y]
            if hist and xi == 1 and (h % 3 == 0):
                return hist[0][0]                     # a repeat
            return cands[(h + 2 * xi + len(hist)) % len(cands)]

        def label(F, f):
            return 1 if L.proves(F, f) else (0 if L.proves(F, Not(f)) else 'i')

        sumE = 0.0
        Elog = 0.0
        pins = 0.0
        for xis in itertools.product((0, 1), repeat=n):
            pxi = 0.5 ** n
            for F, pt in nuG.items():
                hist = []
                for t in range(n):
                    f = rule(hist, xis[t])
                    if any(g == f for (g, _) in hist):
                        continue                       # repeat: d_t = 0
                    bn, bm = C.M(L, nuG, hist), C.M(L, law, hist)
                    d = 0.0
                    l1 = 0.0
                    for y in (1, 0, 'i'):
                        pn = C.M(L, nuG, hist + [(f, y)]) / bn
                        pm = C.M(L, law, hist + [(f, y)]) / bm
                        if pn > 0:
                            d += float(pn) * C.lg(pn / pm)
                        l1 += abs(float(pn - pm))
                    sumE += pxi * float(pt) * d
                    pins += pxi * float(pt) * l1 ** 2
                    hist.append((f, label(F, f)))
                Elog += pxi * float(pt) * (C.lg(C.M(L, nuG, hist)) - C.lg(C.M(L, law, hist)))
        rhs = Elog + C.lg(M0)
        worst_id = max(worst_id, abs(sumE - rhs))
        worst_bd = max(worst_bd, sumE - (-C.lg(w) + C.lg(M0)))
        worst_pin = max(worst_pin, pins - 2 * math.log(2) * (-C.lg(w)))
    out(f"R3.6 40 instances, n = 4 adaptive questions with repeats: max |sum E d_t - (E log nu3/M3 + log M(empty))| = "
        f"{worst_id:.2e}; max of sum E d_t - (-log w + log M(empty)) = {worst_bd:.4f}  [<= 0]; "
        f"max of Pinsker sum - 2 ln2 (-log w) = {worst_pin:.4f}  [<= 0]")


def r3_7():
    k = 3
    L = C.Logic(k)
    worst_tv = -1.0
    for trial in range(60):
        law, _, _ = rand_law(L, k)
        v0 = rng.randrange(L.nv)
        stream = []
        seen = set()
        while len(stream) < 7:
            f = rand_formula(k, 2)
            if f in seen:
                continue
            seen.add(f)
            stream.append((f, 1 if v0 in L.mod(f) else 0))
        a = C.M(L, law, stream)
        if a == 0:
            continue
        p_inf = C.psi_mod(L, stream)
        post_inf = {F: x / a for F, x in law.items() if F and F <= p_inf}
        for n in range(len(stream) + 1):
            an = C.M(L, law, stream[:n])
            pn = C.psi_mod(L, stream[:n])
            post = {F: x / an for F, x in law.items() if F and F <= pn}
            keys = set(post) | set(post_inf)
            tv = sum(abs(post.get(F, Fr(0)) - post_inf.get(F, Fr(0))) for F in keys) / 2
            worst_tv = max(worst_tv, float(tv - (an - a) / an))
    out(f"R3.7 Prop 8.1: max of TV(P_n, P_inf) - (a_n - a)/a_n over 60 streams and prefixes = {worst_tv:.3e}  [<= 0]")
    # Prop 8.3 on all model sets with random masses (a law with every theory present)
    worst_f = Fr(0)
    worst_i = Fr(0)
    ok3 = 0
    ntr = 0
    for trial in range(30):
        sets = [frozenset(S) for r in range(1, L.nv + 1) for S in itertools.combinations(range(L.nv), r)]
        raw = [Fr(rng.randint(1, 30)) for _ in sets]
        tot = sum(raw) * Fr(5, 4)                  # 1/5 of the mass inconsistent
        law = {S: r / tot for S, r in zip(sets, raw)}
        law[frozenset()] = 1 - sum(law.values())
        Tstar = rng.choice([S for S in sets if 2 <= len(S) < L.nv])
        TF = L.formula_of(Tstar)
        two = []
        three = []
        for S in sets:
            if len(S) == L.nv:
                continue
            f = L.formula_of(S)
            if Tstar <= S:
                two.append((f, 1)); three.append((f, 1))
            elif not (Tstar & S):
                two.append((f, 0)); three.append((f, 0))
            else:
                three.append((f, 'i'))
        ntr += 1
        for _ in range(5):
            psi_set = rng.choice([S for S in sets if (S & Tstar) and not Tstar <= S])
            psi = L.formula_of(psi_set)
            b, d, i = C.tri(L, law, two, psi)
            e = ext_mass(L, law, Tstar)
            fb = ext_mass(L, law, Tstar & psi_set) / e
            fd = ext_mass(L, law, Tstar - psi_set) / e
            worst_f = max(worst_f, abs(b - fb), abs(d - fd))
            worst_i = max(worst_i, class_mass(L, law, Tstar) / e - i)
        left = {F for F, x in law.items() if F and C.M(L, {F: Fr(1)}, three) > 0}
        ok3 += int(left == {Tstar})
    out(f"R3.7 Prop 8.3(a): limit Bel/Dis vs mass(Ext(T*+-psi))/mass(Ext T*): max |error| = {worst_f}; "
        f"max of mass[T*]/mass(Ext T*) - Indep = {worst_i}  [<= 0];  (c) three-valued data leave only [T*] in {ok3} of {ntr}")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r3_1_2()
    r3_3()
    r3_4_5()
    r3_6()
    r3_7()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb3_loss.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")
