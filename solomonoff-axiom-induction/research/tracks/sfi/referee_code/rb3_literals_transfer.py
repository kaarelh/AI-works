"""rb3_literals_transfer.py -- referee B, thread `sfi`.  Exact finite checks of notes.md
Rem 5.4 (AI-paper Prop E.1 as an encoding effect) and Thm 5.1 (SAI is SOI on positive literals),
with randomly drawn priors.

World: n atoms R(w_1..w_n) (n = 1..8), propositional; background B = empty (all valuations).
Hypotheses:
  * SAI, coin-free: a random family of consistent theories (sets of formulas over the atoms: random
    literal sets, random clauses, implications chains, "all true", random model sets), random
    weights 2^-l, plus the empty theory and the 2^n complete literal theories (weight 2^-(n+3));
  * SAI, one tape: random theory machines that read tape bits: atom i gets R or not-R from tape bit
    i with a per-machine bias pattern, possibly copying earlier bits (shared randomness);
  * FIall (plain W on sentences): the consistent theories read as labellers that answer their
    decisions, plus the inconsistent assigner "accept every sentence" (weight 2^-3).
Data process of AI-paper Prop E.1: at step i a fair coin shows psi = R(w_i) or not-R(w_i); the datum
is (psi, 1).  Exact expectation over all 2^n coin sequences.
Checks:
  (1) expected cumulative loss (semimeasure convention) of the SAI mixtures is >= n, for every n
      and every random prior drawn (40 priors per n);  a + a' <= 1 at every step;
  (2) FIall's loss is <= -log2(2^-3) + log2 W(empty) on every sequence (bounded);
  (3) re-encoding (not-R(w),1) -> (R(w),0) leaves M_A and W_A unchanged on every sequence (automatic
      here, since hypotheses act on data through their models; listed only as a sanity check);
  (4) Thm 5.1 on positive literal data: with the maps theory -> string labeller (its decision on
      R(t_x)) and string labeller -> theory of its literals, M_A(D) and M_F(D^str) satisfy
      M_A <= 2^c M_F and M_F <= 2^c M_A with c the map overhead, on all positive literal data
      sets of size <= 3, and the three-way weights (prove / refute / neither vs 1 / 0 / undefined)
      agree within the same constants.
Seed 20261016.  Output: rb3_literals_transfer.out
"""
import itertools
import math
import random
from fractions import Fraction as Fr

SEED = 20261016
C_MAP = 2
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def run_n(n, rng, priors=40):
    NV = 1 << n
    FULL = (1 << NV) - 1
    atom = [sum(1 << v for v in range(NV) if (v >> i) & 1) for i in range(n)]
    NEG = lambda m: FULL & ~m

    def rand_theory():
        r = rng.random()
        m = FULL
        if r < 0.3:
            for i in rng.sample(range(n), rng.randint(0, n)):
                m &= atom[i] if rng.random() < 0.5 else NEG(atom[i])
        elif r < 0.55:
            for _ in range(rng.randint(1, 3)):
                cl = 0
                for i in rng.sample(range(n), min(n, rng.randint(1, 3))):
                    cl |= atom[i] if rng.random() < 0.5 else NEG(atom[i])
                m &= cl
        elif r < 0.75:
            for i in range(n - 1):
                if rng.random() < 0.6:
                    m &= NEG(atom[i]) | atom[i + 1]
        elif r < 0.85:
            for i in range(n):
                m &= atom[i]
        else:
            m = rng.getrandbits(NV) | (1 << rng.randrange(NV))
        return m if m else FULL

    def tape_machine():
        """returns a function tape -> model mask; tape = tuple of n bits."""
        kind = rng.randrange(3)
        bias = [rng.choice([None, 0, 1]) for _ in range(n)]
        src = [rng.randrange(i) if i and rng.random() < 0.4 else i for i in range(n)]

        def th(tape):
            m = FULL
            for i in range(n):
                if kind == 0:     # fair coin per atom
                    b = tape[i]
                elif kind == 1:   # fixed bias or coin
                    b = tape[i] if bias[i] is None else bias[i]
                else:             # shared randomness: copy an earlier bit
                    b = tape[src[i]]
                m &= atom[i] if b else NEG(atom[i])
            return m
        return th

    tapes = list(itertools.product((0, 1), repeat=n))
    worst_gap = None
    infs = [0]
    viol1 = viol_aa = viol2 = viol3 = 0
    for pr in range(priors):
        theories = [(rng.randint(2, 9), rand_theory()) for _ in range(12)] + [(3, FULL)]
        for bits in itertools.product((0, 1), repeat=n):      # lookup tables: complete literal theories
            m = FULL
            for i, b in enumerate(bits):
                m &= atom[i] if b else NEG(atom[i])
            theories.append((n + 3, m))
        machines = [(rng.randint(2, 9), tape_machine()) for _ in range(6)]
        mach_models = [(l, [th(t) for t in tapes]) for l, th in machines]

        def WA(Dm):   # Dm: model mask of the data (conjunction); coin-free
            return sum(Fr(1, 2 ** l) for l, m in theories if m and (m & ~Dm) & FULL == 0)

        cacheA = {}

        def MA(Dm):   # one tape mixture of tape machines plus the coin-free theories as tape-ignoring
            if Dm in cacheA:
                return cacheA[Dm]
            s = WA(Dm)
            for l, ms in mach_models:
                s += Fr(sum(1 for m in ms if m and (m & ~Dm) & FULL == 0), len(tapes) * 2 ** l)
            cacheA[Dm] = s
            return s

        def FIall(seq):   # labellers: consistent theories answer their decisions; accept-all
            s = Fr(1, 8)  # accept-all is compatible with every all-true data set
            for l, m in theories:
                ok = all(((m & ~(atom[i] if c else NEG(atom[i]))) & FULL) == 0 for i, c in seq)
                s += Fr(1, 2 ** l) if ok else 0
            return s

        expA = 0.0
        expW = 0.0
        for coins in itertools.product((0, 1), repeat=n):
            Dm = FULL
            Dm2 = FULL       # re-encoded: (R(w_i), coin) -- same mask by construction; check via recompute
            seq = []
            lossA = 0.0
            for i, c in enumerate(coins):
                psi = atom[i] if c else NEG(atom[i])
                a = MA(Dm & psi) / MA(Dm) if MA(Dm) else 0
                ap = MA(Dm & NEG(psi)) / MA(Dm) if MA(Dm) else 0
                if a + ap > 1:
                    viol_aa += 1
                Dm &= psi
                seq.append((i, c))
            lA = (-math.log2(MA(Dm)) if MA(Dm) else math.inf) + math.log2(MA(FULL))
            lW = (-math.log2(WA(Dm)) if WA(Dm) else math.inf) + math.log2(WA(FULL))
            expA += lA / 2 ** n
            expW += lW / 2 ** n
            lF = -math.log2(FIall(seq)) + math.log2(FIall([]))
            if lF > 3 + math.log2(FIall([])) + 1e-9:
                viol2 += 1
            # (3) re-encoding: data {(not R(w_i),1)} vs {(R(w_i),0)} have the same Cn, hence the same mask;
            # recompute M_A on the re-encoded data through its literal list
            Dm_re = FULL
            for i, c in seq:
                Dm_re &= atom[i] if c == 1 else NEG(atom[i])     # (R(w_i), c): label c on the positive literal
            if MA(Dm_re) != MA(Dm) or WA(Dm_re) != WA(Dm):
                viol3 += 1
        for e, name in ((expA, 'M_A'), (expW, 'W_A')):
            if float(e) < n - 1e-9:
                viol1 += 1
            g = float(e) - n
            worst_gap = g if worst_gap is None else min(worst_gap, g)
        infs[0] += math.isinf(expW)
    return worst_gap, viol1, viol_aa, viol2, viol3, infs[0]


def transfer_check(rng):
    """Thm 5.1 on positive literals, finite: n = 4 inputs; theories over the 4 atoms; string
    labellers g: {0..3} -> {0,1,undef}; maps with overhead C_MAP."""
    n = 4
    NV = 1 << n
    FULL = (1 << NV) - 1
    atom = [sum(1 << v for v in range(NV) if (v >> i) & 1) for i in range(n)]
    NEG = lambda m: FULL & ~m
    viol = viol3 = cases = 0
    for trial in range(30):
        # SAI family: random consistent theories (any formulas) + images of string labellers
        th = []
        for _ in range(10):
            m = rng.getrandbits(NV) | (1 << rng.randrange(NV))
            th.append((rng.randint(2, 8), m))
        labs = []
        for _ in range(10):
            g = tuple(rng.choice([0, 1, None]) for _ in range(n))
            labs.append((rng.randint(2, 8), g))

        def lab_theory(g):
            m = FULL
            for i, y in enumerate(g):
                if y is not None:
                    m &= atom[i] if y else NEG(atom[i])
            return m

        def theory_lab(m):
            return tuple(1 if (m & ~atom[i]) & FULL == 0 else (0 if (m & atom[i]) == 0 else None) for i in range(n))

        TH = th + [(l + C_MAP, lab_theory(g)) for l, g in labs]          # SAI side, closed under one map
        LB = labs + [(l + C_MAP, theory_lab(m)) for l, m in th]          # SOI side
        TH2 = TH + [(l + C_MAP, lab_theory(g)) for l, g in LB[len(labs):]]
        LB2 = LB + [(l + C_MAP, theory_lab(m)) for l, m in TH[len(th):]]
        for k in range(0, 4):
            for dom in itertools.combinations(range(n), k):
                for ys in itertools.product((0, 1), repeat=k):
                    D = list(zip(dom, ys))
                    Dm = FULL
                    for i, y in D:
                        Dm &= atom[i] if y else NEG(atom[i])
                    MA = lambda T: sum(Fr(1, 2 ** l) for l, m in T if (m & ~Dm) & FULL == 0)
                    MF = lambda Lb: sum(Fr(1, 2 ** l) for l, g in Lb if all(g[i] == y for i, y in D))
                    cases += 1
                    if MA(TH) > 2 ** C_MAP * MF(LB2) or MF(LB) > 2 ** C_MAP * MA(TH2):
                        viol += 1
                    for x in range(n):
                        if x in dom:
                            continue
                        for o in (1, 0, None):
                            ma3 = sum(Fr(1, 2 ** l) for l, m in TH if (m & ~Dm) & FULL == 0 and theory_lab(m)[x] == o)
                            mf3 = sum(Fr(1, 2 ** l) for l, g in LB2 if all(g[i] == y for i, y in D) and g[x] == o)
                            mf3b = sum(Fr(1, 2 ** l) for l, g in LB if all(g[i] == y for i, y in D) and g[x] == o)
                            ma3b = sum(Fr(1, 2 ** l) for l, m in TH2 if (m & ~Dm) & FULL == 0 and theory_lab(m)[x] == o)
                            if ma3 > 2 ** C_MAP * mf3 or mf3b > 2 ** C_MAP * ma3b:
                                viol3 += 1
    return cases, viol, viol3


def main():
    rng = random.Random(SEED)
    out('rb3_literals_transfer.py  seed %d' % SEED)
    out('(1)-(3) AI-paper Prop E.1 data (fair-coin literals, all labelled true), 40 random priors per n:')
    out('   n   min over priors of (E loss - n) [M_A and W_A]   E loss < n   a+a\'>1   FIall unbounded   re-encoding changes M_A/W_A')
    for n in range(1, 9):
        npr = 40 if n <= 5 else 8
        g, v1, vaa, v2, v3, ni = run_n(n, rng, priors=npr)
        out('  %2d   %+.6f   (%2d priors; W_A loss infinite for %2d)   %d            %d        %d                 %d'
            % (n, g, npr, ni, v1, vaa, v2, v3))
    cases, v, v3 = transfer_check(rng)
    out('(4) Thm 5.1 on positive literals (n = 4, 30 random families, maps with overhead %d): %d data sets; '
        'violations of M_A <= 2^c M_F, M_F <= 2^c M_A: %d; of the three-way inequalities: %d' % (C_MAP, cases, v, v3))
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
