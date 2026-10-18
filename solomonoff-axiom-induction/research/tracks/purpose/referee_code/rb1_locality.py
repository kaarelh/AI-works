"""rb1_locality.py -- referee B, track `purpose`, target T1 (independent code; nothing copied from checks/).

Seed 20261018.  Writes rb1_locality.out next to itself.  Exact rational arithmetic throughout parts A-D.

Model (different from the developer's p1, which uses one interval per random theory).  The quantity q takes one of
N atoms 0..N-1 (a finite stand-in for the cells of RCF interval sentences: an interval sentence with rational end
points is, relative to a fixed finite set of sentences, a union of atoms).  A sentence is a subset S of atoms
("q in S"), coded as a bitmask.  The background B says "q is one of the atoms".  A theory is a finite SET OF
SENTENCES; its value set is the intersection of its sentences; it is consistent iff the value set is non-empty,
proves S iff value set <= S, refutes S iff value set & S is empty.  A theory machine is a finite list of
(probability, theory), probabilities summing to 1; it may emit inconsistent theories with positive probability.
nu_G(D) = P(consistent and proves phi^D(phi) for every phi in dom D); for the three-valued law, label 'i' requires
neither proof nor refutation.

Parts
  A. T1.1(b),(c): cumulative loss in the semimeasure and three-valued conventions, in every order, with repeats,
     equals -log nu(D) + log nu(empty).  Exact.
  B. T1.2: the normalised convention: exact formula with the independent mass I_t; order dependence; non-locality
     (two machines, equal nu(D) and nu(empty), different normalised loss).  Largest order spread found.
  C. T1.3/T1.4: nu_G(D) = beta_G(C_D) for arbitrary (not only interval) sentence data; sum over a partition of
     beta_G(atom) <= nu_G(empty), with equality iff every consistent theory of G proves some atom.
  D. T1.5 on dithered grids (exact piecewise integration over the dither): separation probability, CRIGN identity,
     near-point asymptotics; and two COUNTEREXAMPLE checks of statements in notes.md:
       D4: "regime R already ranks the near forecast better, which a fixed question family cannot do" (p1 part E
           comment): a FIXED grid of width 5 ranks it better too.
       D5: summary item 1 / T6.2 row 6a "misses are graded ... never like squared error": with Gaussian-shaped
           forecasts the dithered-grid loss grows like (miss)^2/(2 sigma^2 ln 2), unboundedly, at every Delta.
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def lg(x):
    return math.log2(float(x))


# ----------------------------------------------------------------------------------------------- the atom model
class Model:
    def __init__(self, N):
        self.N = N
        self.FULL = (1 << N) - 1

    def value_set(self, theory):
        v = self.FULL
        for s in theory:
            v &= s
        return v

    def status(self, v, S):
        """for a theory with value set v: 1 proves S, 0 refutes S, 'i' independent; v must be non-empty"""
        if v & ~S == 0:
            return 1
        if v & S == 0:
            return 0
        return "i"

    def nu(self, G, D):
        """D: dict sentence-mask -> label in {1, 0, 'i'}"""
        tot = Fr(0)
        for p, th in G:
            v = self.value_set(th)
            if v == 0:
                continue
            if all(self.status(v, S) == y for S, y in D.items()):
                tot += p
        return tot


def rand_machine(rng, M, k=None, p_incons=0.2):
    k = k or rng.randint(2, 6)
    ws = [rng.randint(1, 7) for _ in range(k)]
    tot = sum(ws)
    G = []
    for w in ws:
        nsent = rng.randint(0, 3)
        th = [rng.randint(1, M.FULL) for _ in range(nsent)]
        if rng.random() < p_incons and M.N >= 2:          # force an inconsistency with positive probability
            a = rng.randrange(M.N)
            th += [1 << a, M.FULL & ~(1 << a)]
        G.append((Fr(w, tot), th))
    return G


def label_of(M, x, S):
    return 1 if (S >> x) & 1 else 0


# ----------------------------------------------------------------------------------------------- parts A-C
def part_A(rng):
    out("\n== A. semimeasure and three-valued conventions: cumulative loss along every reveal order (with repeats)")
    out("   equals -log nu(D) + log nu(empty)  [T1.1(b),(c)]")
    worst2, worst3, n2, n3, nord = 0.0, 0.0, 0, 0, 0
    for _ in range(400):
        M = Model(rng.randint(3, 7))
        G = rand_machine(rng, M)
        x = rng.randrange(M.N)
        sents = list({rng.randint(1, M.FULL) for _ in range(rng.randint(1, 4))})
        # two-valued data from the true value x
        D = {S: label_of(M, x, S) for S in sents}
        if M.nu(G, D) > 0:
            n2 += 1
            seq_base = list(D.items())
            for perm in itertools.permutations(seq_base):
                seq = list(perm)
                if rng.random() < 0.5:                    # insert a repeat
                    seq.insert(rng.randint(1, len(seq)), seq[rng.randrange(len(seq))]) if len(seq) > 0 else None
                L, cur = 0.0, {}
                for S, y in seq:
                    nxt = dict(cur)
                    nxt[S] = y
                    L += -lg(M.nu(G, nxt) / M.nu(G, cur))
                    cur = nxt
                worst2 = max(worst2, abs(L - (-lg(M.nu(G, D)) + lg(M.nu(G, {})))))
                nord += 1
        # three-valued data: label some sentences 'i' where G gives positive mass to independence
        D3 = {}
        for S in sents:
            D3[S] = rng.choice([label_of(M, x, S), "i"])
        if M.nu(G, D3) > 0:
            n3 += 1
            for perm in itertools.permutations(list(D3.items())):
                L, cur = 0.0, {}
                for S, y in perm:
                    nxt = dict(cur)
                    nxt[S] = y
                    # the three conditionals at this step sum to 1 relative to nu(cur) (Prop. 3.1(b) analogue)
                    tot = sum(M.nu(G, {**cur, S: yy}) for yy in (1, 0, "i")) if S not in cur else M.nu(G, cur)
                    assert tot == M.nu(G, cur), "three-valued conditionals do not sum to 1"
                    L += -lg(M.nu(G, nxt) / M.nu(G, cur))
                    cur = nxt
                worst3 = max(worst3, abs(L - (-lg(M.nu(G, D3)) + lg(M.nu(G, {})))))
    out("   two-valued: %d instances, %d (instance, order) pairs incl. random repeats; max deviation %.2e bits" % (n2, nord, worst2))
    out("   three-valued: %d instances, all orders; conditionals over {1,0,i} sum to nu(D_t-1) exactly (asserted);"
        " max deviation %.2e bits" % (n3, worst3))


def part_B(rng):
    out("\n== B. normalised convention [T1.2]: loss = -log nu(D) + log nu(empty) + sum_t log(1 - I_t); order and")
    out("   off-event mass matter")
    worst_formula, best_spread, best_inst = 0.0, 0.0, None
    nonlocal_found = None
    ninst = 0
    for _ in range(3000):
        M = Model(rng.randint(2, 5))
        G = rand_machine(rng, M)
        x = rng.randrange(M.N)
        sents = list({rng.randint(1, M.FULL) for _ in range(rng.randint(2, 3))})
        D = {S: label_of(M, x, S) for S in sents}
        if M.nu(G, D) == 0:
            continue
        ninst += 1
        losses = []
        for perm in itertools.permutations(list(D.items())):
            Ln, cur, corr = 0.0, {}, 0.0
            for S, y in perm:
                p1, p0 = M.nu(G, {**cur, S: 1}), M.nu(G, {**cur, S: 0})
                py = p1 if y == 1 else p0
                Ln += -lg(py / (p1 + p0))
                It = M.nu(G, {**cur, S: "i"}) / M.nu(G, cur)
                corr += lg(1 - It) if It < 1 else -math.inf
                cur = {**cur, S: y}
            formula = -lg(M.nu(G, D)) + lg(M.nu(G, {})) + corr
            worst_formula = max(worst_formula, abs(Ln - formula))
            losses.append(Ln)
        spread = max(losses) - min(losses)
        if spread > best_spread:
            best_spread, best_inst = spread, (M.N, G, x, D, losses)
    out("   %d random instances, all orders: max |normalised loss - formula| = %.2e bits" % (ninst, worst_formula))
    N, G, x, D, losses = best_inst
    out("   largest order spread found: %.4f bits (normalised losses over orders: %s)" % (
        best_spread, ", ".join("%.4f" % v for v in losses)))
    out("      instance: N=%d atoms, truth %d, machine %s, data %s" % (
        N, x, [(str(p), [bin(s) for s in th]) for p, th in G], {bin(k): v for k, v in D.items()}))
    # non-locality: same nu(D), nu(empty); different normalised loss -- explicit, built from atoms
    M = Model(3)
    S = 0b011                                   # "q in {0,1}"; truth x = 0, so D = {S: 1}
    G1 = [(Fr(1, 2), [0b001]), (Fr(1, 2), [])]  # proves S w.p. 1/2 (value set {0}), else the empty theory (silent)
    G2 = [(Fr(1, 2), [0b001]), (Fr(1, 2), [0b100])]  # else refutes S
    G3 = [(Fr(1, 2), [0b001]), (Fr(1, 4), [0b100]), (Fr(1, 4), [])]
    for name, G in (("silent elsewhere", G1), ("refutes elsewhere", G2), ("mixed", G3)):
        p1, p0 = M.nu(G, {S: 1}), M.nu(G, {S: 0})
        out("   %-18s nu(empty)=%s nu(D)=%s | semimeasure loss %.4f | normalised loss %.4f bits" % (
            name, M.nu(G, {}), M.nu(G, {S: 1}), -lg(M.nu(G, {S: 1})), -lg(p1 / (p1 + p0))))


def part_C(rng):
    out("\n== C. joint-cell identity and partitions [T1.3, T1.4] for arbitrary (non-interval) sentences")
    worst, nchk, n_eq, n_strict, n_pred_eq = 0, 0, 0, 0, 0
    for _ in range(2000):
        M = Model(rng.randint(2, 7))
        G = rand_machine(rng, M)
        x = rng.randrange(M.N)
        sents = list({rng.randint(1, M.FULL) for _ in range(rng.randint(1, 4))})
        D = {S: label_of(M, x, S) for S in sents}
        C = M.FULL
        for S, y in D.items():
            C &= S if y == 1 else (M.FULL & ~S)
        lhs, rhs = M.nu(G, D), M.nu(G, {C: 1})
        worst = max(worst, abs(float(lhs - rhs)))
        nchk += 1
        # partition generated by the sentences: atoms of the Boolean algebra
        cells = {}
        for a in range(M.N):
            key = tuple((S >> a) & 1 for S in sents)
            cells[key] = cells.get(key, 0) | (1 << a)
        tot = sum(M.nu(G, {c: 1}) for c in cells.values())
        assert tot <= M.nu(G, {}), "partition masses exceed nu(empty)"
        # equality iff every consistent theory proves some cell
        pred_eq = all(any(M.value_set(th) & ~c == 0 for c in cells.values()) for p, th in G if M.value_set(th) != 0)
        if tot == M.nu(G, {}):
            n_eq += 1
        else:
            n_strict += 1
        n_pred_eq += (pred_eq == (tot == M.nu(G, {})))
    out("   %d instances: max |nu(D) - nu(prove C_D)| = %g (exact); sum over cells of beta <= nu(empty) in all"
        " (%d equal, %d strict); equality characterised correctly in %d of %d" % (nchk, worst, n_eq, n_strict,
                                                                               n_pred_eq, nchk))


# ----------------------------------------------------------------------------------------------- part D
def cell_mass_profile(atoms, x, Delta):
    """atoms: list of (position, prob) (floats).  The cell of x in a uniformly dithered grid of width Delta is
    [x - r, x - r + Delta) with r uniform on [0, Delta).  Returns list of (length, mass) pieces over r."""
    bps = {0.0, Delta}
    for y, _ in atoms:
        for r in (x - y, x - y + Delta):
            if 0 < r < Delta:
                bps.add(r)
    bps = sorted(bps)
    pieces = []
    for a, b in zip(bps[:-1], bps[1:]):
        r = 0.5 * (a + b)
        lo, hi = x - r, x - r + Delta
        m = sum(p for y, p in atoms if lo <= y < hi)
        pieces.append((b - a, m))
    return pieces


def S_dither(atoms, x, Delta):
    return sum(l * (-math.log2(m)) for l, m in cell_mass_profile(atoms, x, Delta)) / Delta


def S_fixed(atoms, x, Delta, r):
    lo, hi = x - r, x - r + Delta
    m = sum(p for y, p in atoms if lo <= y < hi)
    return -math.log2(m) if m > 0 else math.inf


def crign_discrete(atoms, x):
    """int over t of -log2 P(X <= t) for t >= x and -log2 P(X > t) for t < x, for a discrete law"""
    ys = sorted(set([y for y, _ in atoms] + [x]))
    tot = 0.0
    for a, b in zip(ys[:-1], ys[1:]):
        t = 0.5 * (a + b)
        F = sum(p for y, p in atoms if y <= t)
        val = F if t >= x else 1 - F
        tot += (b - a) * (-math.log2(val))
    return tot


def part_D(rng):
    out("\n== D. random questions (dithered grid), exact integration over the dither [T1.5]")
    # D1 separation probability
    Delta = 1.0
    worst = 0.0
    for d in [0.0, 0.1, 0.37, 0.5, 0.99, 1.0, 1.7, 30.0]:
        pieces = cell_mass_profile([(d, 1.0)], 0.0, Delta)
        sep = sum(l for l, m in pieces if m == 0) / Delta
        worst = max(worst, abs(sep - min(abs(d) / Delta, 1)))
    out("   D1 separation probability of x=0, y=d equals min(|d|/Delta,1) at 8 distances: max error %.1e" % worst)
    # D2 CRIGN identity for forecasts supported in an interval J containing x with |J| <= Delta
    worst = 0.0
    for _ in range(300):
        Delta = rng.uniform(0.5, 3.0)
        L = rng.uniform(0.05, 1.0) * Delta
        a = rng.uniform(-L, 0.0)
        k = rng.randint(1, 6)
        ws = [rng.random() + 0.05 for _ in range(k)]
        atoms = [(a + rng.uniform(0, L), w / sum(ws)) for w in ws]
        x = rng.choice(atoms)[0]       # the truth is an atom, so every cell of x has positive mass
        S = S_dither(atoms, x, Delta)
        C = crign_discrete(atoms, x) / Delta
        worst = max(worst, abs(S - C))
    out("   D2 300 random discrete forecasts supported in J (|J| <= Delta, x in J): max |S_mu - CRIGN/Delta| = %.2e bits" % worst)
    # D3 near-point forecasts (1-s) delta_y + s * uniform on 64 atoms spaced 1 apart around 0, Delta = 1
    out("   D3 near-point forecasts P = (1-s) delta_y + s Unif(64 atoms at -31.5..31.5 step 1), x = 0, Delta = 1")
    base = [(-31.5 + i, 1 / 64) for i in range(64)]
    for d in (0.25, 0.5, 2.0):
        row = []
        for s in (1e-2, 1e-4, 1e-8):
            atoms = [(y, s * p) for y, p in base] + [(d, 1 - s)]
            S = S_dither(atoms, 0.0, 1.0)
            row.append("s=%g: S=%.4f, S/log2(1/s)=%.4f" % (s, S, S / math.log2(1 / s)))
        out("      d=%.2f (sep %.2f): %s" % (d, min(d, 1.0), "; ".join(row)))
    # D4 the author's example: fixed grid vs dithered grid
    out("   D4 author's example, truth 0: near = Unif{-2..2}, scattered = Unif{-20,-10,0,10,20}")
    near = [(float(v), 0.2) for v in range(-2, 3)]
    far = [(float(v), 0.2) for v in (-20, -10, 0, 10, 20)]
    for Delta in (1.0, 2.0, 5.0, 10.0):
        out("      Delta=%4.1f: dithered: near %.4f, scattered %.4f | FIXED grid with cell [-Delta/2, Delta/2): near %.4f,"
            " scattered %.4f | fixed grid, worst offset for near: %.4f" % (
                Delta, S_dither(near, 0.0, Delta), S_dither(far, 0.0, Delta), S_fixed(near, 0.0, Delta, Delta / 2),
                S_fixed(far, 0.0, Delta, Delta / 2),
                max(S_fixed(near, 0.0, Delta, r) for r in [i * Delta / 1000 for i in range(1000)])))
    out("      -> a FIXED question family (cells of width 5, one fixed offset) also ranks the near forecast better"
        " (0 vs 2.3219 bits);")
    out("         the dithered loss is the average over offsets of fixed-grid losses (it is a mixture of partitions).")
    # D5 Gaussian-shaped forecasts: squared-error grading of the miss, unbounded, at every Delta
    out("   D5 Gaussian-shaped forecasts N(y, 1) (discretised on a 0.001 grid over y +- 12), truth x = 0, dithered grid")
    def gauss_atoms(y, sd=1.0, h=0.001, w=12.0):
        n = int(2 * w / h)
        pts = [y - w + (i + 0.5) * h for i in range(n)]
        ps = [math.exp(-0.5 * ((t - y) / sd) ** 2) for t in pts]
        Z = sum(ps)
        return [(t, p / Z) for t, p in zip(pts, ps)]
    for Delta in (0.1, 1.0, 4.0):
        vals = []
        S0 = None
        for miss in (0.0, 1.0, 2.0, 4.0, 6.0):
            S = S_dither_fast(gauss_atoms(miss), 0.0, Delta)
            if S0 is None:
                S0 = S
            vals.append((miss, S - S0, miss ** 2 / (2 * math.log(2))))
        out("      Delta=%.1f: miss: S(miss)-S(0) [miss^2/(2 ln2)] = %s" % (
            Delta, "; ".join("%.0f: %.3f [%.3f]" % v for v in vals)))
    out("      -> the expected loss grows like (miss)^2/(2 sigma^2 ln 2) for large misses at EVERY Delta: a fixed or random")
    out("         question family does not bound the grading of misses once the forecast has Gaussian shape; T1.5(d) is a")
    out("         statement about near-point forecasts only.")


def S_dither_fast(atoms, x, Delta, M=4000):
    """midpoint rule over r with prefix sums (atoms sorted); used for the many-atom Gaussian forecasts"""
    import bisect
    ys = [y for y, _ in atoms]
    cum = [0.0]
    for _, p in atoms:
        cum.append(cum[-1] + p)
    tot = 0.0
    for i in range(M):
        r = (i + 0.5) * Delta / M
        lo, hi = x - r, x - r + Delta
        a = bisect.bisect_left(ys, lo)
        b = bisect.bisect_left(ys, hi)
        m = cum[b] - cum[a]
        tot += -math.log2(max(m, 1e-300))
    return tot / M


def main():
    rng = random.Random(SEED)
    out("# rb1_locality.py seed=%d (referee B, independent of checks/p1_locality.py)" % SEED)
    part_A(rng)
    part_B(rng)
    part_C(rng)
    part_D(rng)
    out("\n# done")
    with open(os.path.join(HERE, "rb1_locality.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
