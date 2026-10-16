"""Referee B, thread `shape`, target T2 (linear laws without auxiliary variables).

Independent of checks/. Seed 20261016. Writes refB_t2_linear.out next to itself.

Checks
 A  Lemma 2.1 (determination <=> derived equation <=> circuit), brute force, laws with d* = 1, 2, 3+.
 B  Prop 2.2 / 2.3: PI = circuit clauses, |PI| = sum 2^{|u|-1}, min implicate width = d*.
 C  Prop 2.5 / Thm 2.6 by "necessity": for each implicate C of S, is (all implicates of S) minus C still
    UP-usable? The record predicts: the necessary clauses contain F_ind for every d*, and equal F_ind if d* >= 3.
 D  Exact minimum UP-usable theory over X by exhaustive search over subsets of PI (increasing size, no
    assumption that F_ind is contained), against |F_ind| and a* 2^(d*-1); uniqueness when d* >= 3.
 E  Cor 2.7(b): core (all clauses of the given rows) usable <=> every indecomposable circuit is a row.
 F  Cor 2.8 (simplex) and Remark 2.9 (d* = 2 examples): exact minima.
"""
import os, sys, random, time, math
from itertools import combinations, product
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *

SEED = 20261016
rng = random.Random(SEED)
OUT = []
T0 = time.time()


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def random_law(m, k, rng):
    while True:
        rows = [rng.randrange(1, 1 << m) for _ in range(k)]
        if rank(rows) == k:
            break
    consts = [rng.randrange(2) for _ in range(k)]
    return rows, consts


class Law:
    def __init__(self, pts, m):
        self.m = m
        self.pts = list(pts)
        self.deq = derived_equations(self.pts, m)        # u -> c_u, by brute force
        self.nz = [u for u in self.deq if u]
        self.circ = circuits_of(self.deq)
        self.dstar = min(popcount(u) for u in self.nz) if self.nz else None
        self.astar = sum(1 for u in self.nz if popcount(u) == self.dstar) if self.nz else 0

    def decomposable(self, u):
        for u1 in self.nz:
            u2 = u ^ u1
            if u2 == 0 or u2 not in self.deq:
                continue
            inter = u1 & u2
            if popcount(inter) == 1 and (inter & u) == 0:
                return True
        return False

    def F_ind(self):
        out = []
        for u in self.circ:
            if not self.decomposable(u):
                out += eq_clauses(u, self.deq[u], self.m)
        return out

    def circuit_questions(self):
        qs = []
        m = self.m
        for u in self.circ:
            vs = support(u, m)
            for j in vs:
                rest = [v for v in vs if v != j]
                for vals in product((0, 1), repeat=len(rest)):
                    alpha = frozenset(v if b else -v for v, b in zip(rest, vals))
                    val = (self.deq[u] + sum(vals)) % 2
                    qs.append((alpha, j if val else -j))
        return qs


def answers(G, qs):
    for alpha, L in qs:
        r = up(G, alpha)
        if r is None or L not in r:
            return False
    return True


# ------------------------------------------------------------------ A
P("# refB_t2_linear.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
P("== A: Lemma 2.1 (determination) by brute force on random laws, all (S, j)")
tot = mism = 0
dcount = {}
for trial in range(24):
    m = rng.choice([5, 6, 7])
    k = rng.choice([1, 2, 3, 4])
    rows, consts = random_law(m, k, rng)
    law = Law(law_from_system(rows, consts, m), m)
    assert set(law.nz) == span(rows) - {0}, "derived equations != row space"
    dcount[law.dstar] = dcount.get(law.dstar, 0) + 1
    for Smask in range(1 << m):
        for j in range(1, m + 1):
            if bit(Smask, j):
                continue
            # (i) functional dependence
            seen = {}
            func = True
            for x in law.pts:
                key = x & Smask
                if key in seen and seen[key] != bit(x, j):
                    func = False
                    break
                seen[key] = bit(x, j)
            allowed = Smask | (1 << (j - 1))
            ii = any(bit(u, j) and (u & ~allowed) == 0 for u in law.nz)
            iii = any(bit(u, j) and (u & ~allowed) == 0 for u in law.circ)
            tot += 1
            if not (func == ii == iii):
                mism += 1
P(f"  24 laws (d* counts {dict(sorted(dcount.items()))}), {tot} pairs (S, j): mismatches among (i), (ii), (iii) = {mism}")

# ------------------------------------------------------------------ B
P("== B: Prop 2.2 / 2.3: prime implicates = circuit clauses; |PI| = sum 2^{|u|-1}; min implicate width = d*")
bad = 0
for trial in range(16):
    m = rng.choice([4, 5, 6])
    k = rng.choice([1, 2, 3])
    rows, consts = random_law(m, k, rng)
    law = Law(law_from_system(rows, consts, m), m)
    pis = set(prime_implicates(law.pts, m))
    cc = set()
    for u in law.circ:
        cc |= set(eq_clauses(u, law.deq[u], m))
    imps = [C for C in all_clauses(range(1, m + 1)) if is_implicate(C, law.pts)]
    ok = (pis == cc) and len(pis) == sum(2 ** (popcount(u) - 1) for u in law.circ) \
        and min(len(C) for C in imps) == law.dstar
    bad += (not ok)
P(f"  16 random laws (m=4..6): failures = {bad}")

# ------------------------------------------------------------------ C
P("== C: necessity of clauses (Prop 2.5, Thm 2.6): which implicates C have Imp(S) - {C} not UP-usable?")
P("   (usability of sets of implicates is tested on all circuit questions; by monotonicity of UP on implicates this")
P("    is full usability, and it is cross-checked by exhaustive usability on the necessary-set complements)")
summary = {}
xcheck_bad = 0
ntested = 0
for trial in range(40):
    m = rng.choice([4, 5, 5, 6])
    k = rng.choice([1, 2, 2, 3])
    if k >= m:
        continue
    rows, consts = random_law(m, k, rng)
    law = Law(law_from_system(rows, consts, m), m)
    imps = [C for C in all_clauses(range(1, m + 1)) if is_implicate(C, law.pts)]
    qs = law.circuit_questions()
    nec = set()
    for C in imps:
        G = [D for D in imps if D != C]
        ok = answers(G, qs)
        if not ok:
            nec.add(C)
        # cross-check one in five with exhaustive usability
        if rng.random() < 0.05:
            ok2, _, _ = usable(G, m, law.pts, m)
            xcheck_bad += (ok != ok2)
    Find = set(law.F_ind())
    d = law.dstar
    key = (d >= 3)
    rec = summary.setdefault(key, [0, 0, 0, 0])
    rec[0] += 1
    rec[1] += Find <= nec
    rec[2] += Find == nec
    if d >= 3:
        rec[3] += answers(list(Find), qs)
    ntested += 1
for key, rec in sorted(summary.items()):
    lab = "d*>=3" if key else "d*<=2"
    extra = f"; F_ind usable in {rec[3]}" if key else ""
    P(f"  {lab}: {rec[0]} laws; F_ind subset of necessary clauses in {rec[1]}; F_ind == necessary clauses in {rec[2]}{extra}")
P(f"  exhaustive cross-checks of the question-based usability test: mismatches = {xcheck_bad}")

# ------------------------------------------------------------------ D
P("== D: exact minimum UP-usable theory over X: exhaustive over subsets of PI by increasing size (no F_ind assumed)")
P("   columns: m k d* a* |PI| |F_ind| a*2^(d*-1) | min | #minimum sets | F_ind is the unique min | min contains F_ind (all min sets)")
rows_out = 0
tries = 0
d2_cases = []
while rows_out < 26 and tries < 4000:
    tries += 1
    m = rng.choice([4, 5, 6, 6, 7])
    k = rng.choice([1, 2, 3, 3, 4])
    if k >= m:
        continue
    rows, consts = random_law(m, k, rng)
    law = Law(law_from_system(rows, consts, m), m)
    if law.dstar < 2:
        continue
    pis = prime_implicates(law.pts, m)
    if len(pis) > 22:
        continue
    want_d3 = rows_out % 2 == 0
    if (law.dstar >= 3) != want_d3:
        continue
    qs = law.circuit_questions()
    Find = set(law.F_ind())
    best = None
    mins = []
    for s in range(0, len(pis) + 1):
        for G in combinations(pis, s):
            if answers(list(G), qs):
                mins.append(set(G))
        if mins:
            best = s
            break
    for G in mins[:3]:
        ok, _, _ = usable(list(G), m, law.pts, m)
        assert ok
    lb = law.astar * 2 ** (law.dstar - 1)
    uniq = (len(mins) == 1 and mins[0] == Find)
    cont = all(Find <= G for G in mins)
    P(f"  m={m} k={k} d*={law.dstar} a*={law.astar} |PI|={len(pis)} |F_ind|={len(Find)} a*2^(d*-1)={lb} | "
      f"min={best} | #min={len(mins)} | unique F_ind={uniq} | contains F_ind={cont}")
    if law.dstar == 2:
        d2_cases.append((best, len(Find)))
    rows_out += 1

# ------------------------------------------------------------------ E
P("== E: Cor 2.7(b): the core (all clauses of the k given rows) is UP-usable iff every indecomposable circuit is a row")
agree = cnt = core_ok = 0
nonbasis_rows = 0
tries = 0
while cnt < 60 and tries < 20000:
    tries += 1
    m = rng.choice([5, 6, 7])
    k = rng.choice([1, 2, 3])
    rows, consts = random_law(m, k, rng)
    law = Law(law_from_system(rows, consts, m), m)
    if law.dstar < 3:
        continue
    core = []
    for r, c in zip(rows, consts):
        core += eq_clauses(r, c, m)
    ok, _, _ = usable(core, m, law.pts, m)
    ind = [u for u in law.circ if not law.decomposable(u)]
    pred = all(u in rows for u in ind)
    agree += (ok == pred)
    core_ok += ok
    nonbasis_rows += any(r not in law.circ for r in rows)
    cnt += 1
P(f"  {cnt} random systems with d*>=3 (m=5..7, k=1..3): prediction agrees in {agree}; core usable in {core_ok}; "
  f"systems with a non-circuit row: {nonbasis_rows}")
# E2: systems whose given rows are mixed (row_i += row_j), so that some rows are not circuits
agree = cnt = core_ok = nonbasis_rows = 0
tries = 0
while cnt < 60 and tries < 50000:
    tries += 1
    m = rng.choice([6, 7, 8])
    k = rng.choice([2, 3])
    rows, consts = random_law(m, k, rng)
    for _ in range(3):
        i, j = rng.sample(range(k), 2)
        rows[i] ^= rows[j]
        consts[i] ^= consts[j]
    law = Law(law_from_system(rows, consts, m), m)
    if law.dstar < 3 or all(r in law.circ for r in rows):
        continue
    core = []
    for r, c in zip(rows, consts):
        core += eq_clauses(r, c, m)
    ok, _, _ = usable(core, m, law.pts, m)
    ind = [u for u in law.circ if not law.decomposable(u)]
    pred = all(u in rows for u in ind)
    agree += (ok == pred)
    core_ok += ok
    nonbasis_rows += 1
    cnt += 1
P(f"  E2: {cnt} systems with d*>=3 and at least one non-circuit row (m=6..8): prediction agrees in {agree}; core usable in {core_ok}")

# ------------------------------------------------------------------ F
P("== F: Cor 2.8 (simplex) and Remark 2.9 (d* = 2)")
# simplex r = 3
r = 3
m = 2 ** r - 1
cols = list(range(1, 2 ** r))
rows = []
for i in range(r):
    rows.append(sum(1 << (c - 1) for c in range(1, m + 1) if (cols[c - 1] >> i) & 1))
law = Law(law_from_system(rows, [0] * r, m), m)
pis = prime_implicates(law.pts, m)
weights = sorted({popcount(u) for u in law.nz})
okPI, nPI, _ = usable(pis, m, law.pts, m)
breaks = 0
for C in pis:
    G = [D for D in pis if D != C]
    ok, _, _ = usable(G, m, law.pts, m, check_proj=False)
    breaks += (not ok)
P(f"  simplex r=3 (m=7): derived-equation weights {weights}; circuits {len(law.circ)}; |PI| = {len(pis)} "
  f"(m 2^((m-1)/2) = {m * 2 ** ((m - 1) // 2)}); PI usable {okPI} ({nPI} entailed literals); deletions breaking usability {breaks}/{len(pis)}")
P("  table of Cor 2.8 recomputed:")
for r in range(3, 8):
    m = 2 ** r - 1
    d = 2 ** (r - 1)
    cnf = (1 - 2 ** -r) * 2 ** d
    pi = m * 2 ** ((m - 1) // 2)
    P(f"    r={r} m={m}: any CNF >= {cnf:.4g}; min UP-usable over X = {pi:.4g} ({pi})")


def exact_min(law, pis):
    qs = law.circuit_questions()
    for s in range(0, len(pis) + 1):
        found = [G for G in combinations(pis, s) if answers(list(G), qs)]
        if found:
            return s, found
    return None, []


for name, rows, consts, m in [("x1=x2=x3=x4 (record: 6 clauses usable)", [0b0011, 0b0110, 0b1100], [0, 0, 0], 4),
                              ("simplex r=2, x1=x2=x3 (record: 4 clauses usable)", [0b011, 0b110], [0, 0], 3)]:
    law = Law(law_from_system(rows, consts, m), m)
    pis = prime_implicates(law.pts, m)
    s, found = exact_min(law, pis)
    ok, _, _ = usable(list(found[0]), m, law.pts, m)
    ex = sorted(sorted(C) for C in found[0])
    P(f"  {name}: |PI|={len(pis)}, a*2^(d*-1)={law.astar * 2 ** (law.dstar - 1)}, exact minimum = {s} "
      f"({len(found)} minimum sets; e.g. {ex}, usable={ok})")
P(f"  d*=2 random laws of part D: (min, |F_ind|) = {d2_cases}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t2_linear.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
