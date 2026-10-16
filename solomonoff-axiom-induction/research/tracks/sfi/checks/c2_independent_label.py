"""c2_independent_label.py -- thread `sfi`, T6: a finite toy of the mechanism of Prop 2.12
(an observed "independent" label iota breaks the equivalence of SAI and consistent SOI) and of
the one-tape extension proved in notes.md (Prop 6.5): the density lemma that bounds the consistent
iota-mass of a random labeller on sentences outside an r.e.-like set J_w of certified-independent
sentences.

Finite world.  Propositional logic over 4 atoms (16 valuations); background B a mask with 8 models;
64 random sentences (distinct masks).  Ind := sentences that B decides neither way.
Coin-free side.
  * Three-valued labellers f: random partial maps on small random sets of sentences with labels in
    {1, 0, iota}; lengths l_f (prefix-code style), weight 2^{-l_f}.  f is *consistent* iff
    B & Gamma_f is satisfiable and B & Gamma_f decides none of f's iota-sentences.
  * Lookup labellers "iota on sigma, nothing else", length 6 + 2*ceil(log2(j+2)) for the j-th
    sentence (a stand-in for K(sigma)); consistent iff sigma in Ind.
  * Theories: the empty theory (weight 2^-3), random small theories, and the images Gamma_f of all
    labellers (weight 2^{-l_f-2}).
  Checks: (a) every consistent f extending D maps to a theory compatible with D (three-valued
  compatibility), for all three-valued D with |D| <= 2 drawn from 400 random data sets;
  (b) the diagonal: F_n := consistent labellers of length <= n, I_n := union of their iota-sets,
  I_n subset of Ind, sigma_n := first sentence of Ind \\ I_n; then W^{3,cons}({(sigma_n,iota)}) <=
  Omega^{>n} and W_A^3({(sigma_n,iota)}) >= 2^-3; (c) W^{3,cons}({(sigma_n,iota)}) >= 2^{-l(lookup)}
  (the gap is at most the lookup length); (d) a "list" labeller iota-on-S (S subset Ind, short)
  keeps every member of S at weight >= 2^{-l_S}: witnesses of a large gap cannot lie in S.
One-tape side (density lemma of Prop 6.5).
  * Random three-valued function machines F on tapes of length 8 (stopping trees per sentence).
  * C_F := consistent tapes.  For eps in {0.25, 0.1} and every prefix w with
    U(C_F | [w]) > 1 - eps: J_w := {sigma : U(f(sigma) = iota | [w]) > eps}.
    Check (e1) J_w subset of Ind; (e2) for sigma not in J_w, U(C_F & f(sigma)=iota | [w]) <= eps.
Seed 20261015.  Output: c2_independent_label.out
"""
import itertools
import math
import random

SEED = 20261015
NV = 16
FULL = (1 << NV) - 1
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def popc(x):
    return bin(x).count('1')


def main():
    rng = random.Random(SEED)
    out('c2_independent_label.py  seed %d' % SEED)
    # background with 8 models
    models = rng.sample(range(NV), 8)
    B = sum(1 << v for v in models)
    # 64 distinct random sentences
    S = []
    seen = set()
    nonB = [v for v in range(NV) if not (B >> v) & 1]
    while len(S) < 64:
        kind = len(S) % 4          # 0,1: random; 2: entailed by B; 3: refuted by B
        m = rng.getrandbits(NV)
        if kind == 2:
            m |= B
        elif kind == 3:
            m &= FULL & ~B
        if m not in seen and m not in (0, FULL):
            seen.add(m)
            S.append(m)
    NS = len(S)
    NEG = lambda m: FULL & ~m
    ind = [bool(B & S[i]) and bool(B & NEG(S[i])) for i in range(NS)]
    out('background models %d; sentences %d; B-independent sentences %d' % (popc(B), NS, sum(ind)))

    def lit(i, y):
        return S[i] if y == 1 else NEG(S[i])

    def decides(tm, i):
        return (tm & NEG(S[i])) == 0 or (tm & S[i]) == 0

    def lab_consistent(lab):
        tm = B
        for i, y in lab.items():
            if y in (0, 1):
                tm &= lit(i, y)
        if tm == 0:
            return False
        return all(not decides(tm, i) for i, y in lab.items() if y == 'iota')

    # ---------------- coin-free labellers
    labellers = []  # (length, labdict)
    for idx in range(160):
        l = 3 + idx // 8           # 8 labellers per length, lengths 3..22
        k = rng.randint(0, 6)
        dom = rng.sample(range(NS), k)
        lab = {i: rng.choice([1, 0, 'iota', 'iota']) for i in dom}
        labellers.append((l, lab))
    lookup = [(6 + 2 * math.ceil(math.log2(j + 2)), {j: 'iota'}) for j in range(NS)]
    # a short list labeller: iota on the first 6 independent sentences
    Slist = [i for i in range(NS) if ind[i]][:6]
    listlab = (5, {i: 'iota' for i in Slist})
    allf = labellers + lookup + [listlab]
    cons = [lab_consistent(lab) for _, lab in allf]
    out('labellers: %d random (%d consistent), %d lookup (%d consistent), 1 list labeller (consistent: %s)'
        % (len(labellers), sum(cons[:len(labellers)]), len(lookup), sum(cons[len(labellers):len(labellers) + NS]),
           cons[-1]))

    # theories: empty, random, images
    theories = [(3, [])]
    for _ in range(60):
        k = rng.randint(1, 4)
        theories.append((rng.randint(4, 14), [lit(i, rng.choice([0, 1])) for i in rng.sample(range(NS), k)]))
    for (l, lab), c in zip(allf, cons):
        theories.append((l + 2, [lit(i, y) for i, y in lab.items() if y in (0, 1)]))

    def theory_tm(ax):
        tm = B
        for m in ax:
            tm &= m
        return tm

    th_tm = [theory_tm(ax) for _, ax in theories]

    def th_compatible(tm, D):
        if tm == 0:
            return False
        for i, y in D:
            if y == 'iota':
                if decides(tm, i):
                    return False
            elif (tm & NEG(lit(i, y))) != 0:
                return False
        return True

    def W3cons(D):
        return sum(2.0 ** -l for (l, lab), c in zip(allf, cons)
                   if c and all(lab.get(i) == y for i, y in D))

    def WA3(D):
        return sum(2.0 ** -l for (l, _), tm in zip(theories, th_tm) if th_compatible(tm, D))

    # (a) tape-free inclusion via the image map, on random three-valued data sets
    viol = 0
    tested = 0
    for _ in range(400):
        k = rng.randint(1, 2)
        D = tuple((i, rng.choice([1, 0, 'iota'])) for i in rng.sample(range(NS), k))
        for ((l, lab), c), tm in zip(zip(allf, cons), th_tm[1 + 60:]):
            if c and all(lab.get(i) == y for i, y in D):
                tested += 1
                if not th_compatible(tm, D):
                    viol += 1
    out('(a) consistent labeller f extending D -> theory Gamma_f compatible with D: %d pairs tested,'
        ' violations %d' % (tested, viol))

    # (b), (c) the diagonal
    out('(b),(c) diagonal witnesses sigma_n (first independent sentence outside I_n):')
    out('    n  |F_n| |I_n| I_n<=Ind  sigma_n  W3cons(sigma_n)  Omega^{>n}   W_A3(sigma_n)  2^-l(lookup)  checks')
    lengths = sorted(set(l for l, _ in allf))
    allok = True
    for n in lengths:
        Fn = [(l, lab) for (l, lab), c in zip(allf, cons) if c and l <= n]
        In = set(i for _, lab in Fn for i, y in lab.items() if y == 'iota')
        sub = all(ind[i] for i in In)
        rest = [i for i in range(NS) if ind[i] and i not in In]
        if not rest:
            out('   %2d  %4d %4d %s   (Ind exhausted: the finite analogue of productivity ends here)'
                % (n, len(Fn), len(In), sub))
            break
        sg = rest[0]
        D = ((sg, 'iota'),)
        w3 = W3cons(D)
        om = sum(2.0 ** -l for l, _ in allf if l > n)
        wa = WA3(D)
        lk = 2.0 ** -lookup[sg][0]
        ok = sub and w3 <= om + 1e-15 and wa >= 2 ** -3 and w3 >= lk
        allok &= ok
        out('   %2d  %4d %4d %-5s  %5d    %.3e     %.3e   %.3e      %.3e   %s'
            % (n, len(Fn), len(In), sub, sg, w3, om, wa, lk, 'ok' if ok else 'FAIL'))
    out('    all rows ok: %s' % allok)
    # (d) list labeller
    vals = [W3cons(((i, 'iota'),)) for i in Slist]
    out('(d) list labeller (length %d) on S = %s: min W3cons over S = %.3e >= 2^-%d = %.3e: %s'
        % (listlab[0], Slist, min(vals), listlab[0], 2.0 ** -listlab[0], min(vals) >= 2.0 ** -listlab[0]))

    # ---------------- one-tape: the density lemma
    LT = 8
    TAPES = [''.join(b) for b in itertools.product('01', repeat=LT)]
    PREF = [''.join(b) for n in range(LT + 1) for b in itertools.product('01', repeat=n)]

    def random_machine():
        # active set of 8 sentences; 1/0 labels follow a random B-model with prob 0.85
        active = set(rng.sample(range(NS), 8))
        v = rng.choice(models)
        F = []
        for i in range(NS):
            halts = {}
            if i not in active:
                halts[''] = None
                F.append(halts)
                continue
            truth = 1 if (S[i] >> v) & 1 else 0
            stack = ['']
            while stack:
                w = stack.pop()
                if len(w) == LT or rng.random() < 0.3:
                    r = rng.random()
                    if r < 0.3:
                        halts[w] = None
                    elif r < 0.6:
                        halts[w] = 'iota'
                    else:
                        halts[w] = truth if rng.random() < 0.85 else 1 - truth
                else:
                    stack.extend([w + '0', w + '1'])
            F.append(halts)
        return F

    def labels_on(F, om):
        lab = {}
        for i in range(NS):
            for n in range(LT + 1):
                if om[:n] in F[i]:
                    if F[i][om[:n]] is not None:
                        lab[i] = F[i][om[:n]]
                    break
        return lab

    e1 = e2 = nw = 0
    nmach = 0
    fracs = []
    for trial in range(40):
        F = random_machine()
        labs = {om: labels_on(F, om) for om in TAPES}
        C = {om: lab_consistent(labs[om]) for om in TAPES}
        frac = sum(C.values()) / len(TAPES)
        fracs.append(frac)
        if frac == 0:
            continue
        nmach += 1
        for eps in (0.25, 0.1):
            for w in PREF:
                ext = [om for om in TAPES if om.startswith(w)]
                cw = sum(1 for om in ext if C[om]) / len(ext)
                if cw <= 1 - eps:
                    continue
                nw += 1
                for i in range(NS):
                    iota_mass = sum(1 for om in ext if labs[om].get(i) == 'iota') / len(ext)
                    if iota_mass > eps:
                        if not ind[i]:
                            e1 += 1
                    else:
                        cm = sum(1 for om in ext if C[om] and labs[om].get(i) == 'iota') / len(ext)
                        if cm > eps + 1e-12:
                            e2 += 1
    out('one-tape density lemma: %d random machines with a consistent tape (consistent fraction of tapes:'
        ' median %.3f), %d dense prefixes (eps = 0.25, 0.1)' % (nmach, sorted(fracs)[len(fracs) // 2], nw))
    out('    (e1) J_w not contained in Ind: %d cases; (e2) sigma outside J_w with consistent iota-mass'
        ' > eps in [w]: %d cases' % (e1, e2))
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
