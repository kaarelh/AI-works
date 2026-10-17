"""c1: linear laws without auxiliary variables (thread `shape`, targets T2, T1-lemma).

Independent of scout N2's n1_xor_usability.py.  Seed 20261016.  Writes c1_linear_noaux.out next to itself.

A  determination lemma: x_j is a function of x_S on S  <=>  some derived equation u has j in supp(u) <= S+{j}
   (brute force over all (S, j) for random systems).
B  prime implicates by brute force  ==  clauses on circuit supports violating the circuit (Prop 2.3);
   PI(S) is UP-usable in ONE round (UP_1).
C  every prime implicate has width >= d_* (Prop 2.4(a)); the CNF lower bound (1-2^-k) 2^{d_*}.
D  exact minimum UP-usable theories over the base variables (exhaustive search over subsets of PI,
   which is w.l.o.g. by the subsumption lemma) for small random systems, against the bounds
   a_* 2^{d_*-1} (Prop 2.4(b), d_*>=3) and the isolated-circuit bound (Prop 2.5 here).
E  simplex family: sizes; r=3 deletion test (every clause of PI is needed).
F  d_* = 2: the bound a_* 2^{d_*-1} fails (counterexample kept).
G  subsumption lemma check: replacing clauses by subsuming prime implicates never loses a UP_k derivation.
"""
import random, sys, time
from itertools import combinations, product
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import *

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


t0 = time.time()
P(f"# c1_linear_noaux.py  seed={SEED}  python={sys.version.split()[0]}")

# ------------------------------------------------------------------ A
P("== A: determination lemma vs brute-force entailment")
for trial in range(4):
    m, k = (7, 3) if trial < 2 else (8, 4)
    law = AffineLaw(m, random_system(rng, m, k))
    cw = law.codewords
    checked = mism = 0
    for S in range(1 << m):
        for j in range(m):
            if S >> j & 1:
                continue
            # brute force: is x_j a function of x_S on the law?
            seen = {}
            func = True
            for x in law.sols:
                key = x & S
                v = x >> j & 1
                if key in seen and seen[key] != v:
                    func = False
                    break
                seen[key] = v
            lin = any((u >> j & 1) and (u & ~(S | (1 << j))) == 0 for u in cw)
            checked += 1
            mism += (func != lin)
    P(f"  trial {trial}: m={m} k={k} (S,j) pairs={checked} mismatches={mism}")

# ------------------------------------------------------------------ B, C
P("== B/C: prime implicates = circuit clauses; width >= d_*; PI usable in one UP round")
for trial in range(6):
    m, k = [(6, 2), (6, 3), (7, 3), (7, 4), (8, 4), (8, 5)][trial]
    law = AffineLaw(m, random_system(rng, m, k))
    pis = prime_implicates_bruteforce(law.sols, m)
    circ = law.circuits()
    pred = []
    for u in circ:
        pred += parity_clauses(u, law.const[u], m)
    same = set(map(frozenset, pis)) == set(map(frozenset, pred))
    dmin = law.dmin()
    minw = min(len(c) for c in pis)
    ok1, nq, fail = usable(pis, m, m, law.sols, rounds=1)
    lbc = (1 - 2 ** (-law.k)) * 2 ** dmin
    P(f"  trial {trial}: m={m} k={law.k} d*={dmin} circuits={len(circ)} |PI|={len(pis)} PI==circuit clauses: {same}; "
      f"min width={minw} (>= d*: {minw >= dmin}); PI UP_1-usable: {ok1} ({nq} entailed literals); CNF lb={lbc:.2f}")


# ------------------------------------------------------------------ D
def circuit_questions(law):
    """Questions (alpha on supp(u)-{j}, x_j) for circuits u; usability <=> UP answers all of them."""
    qs = []
    for u in law.circuits():
        vs = [v for v in range(law.m) if u >> v & 1]
        for j in vs:
            rest = [v for v in vs if v != j]
            for bits in product((0, 1), repeat=len(rest)):
                alpha = dict(zip(rest, bits))
                val = (law.const[u] + sum(bits)) % 2
                qs.append((alpha, (j, val)))
    return qs


def answers_all(F, m, qs, rounds=None):
    for alpha, (j, val) in qs:
        a = up(F, m, alpha, rounds)
        if a is None or a[j] != val:
            return False
    return True


def isolated(law, u, j):
    m = law.m
    rest = u & ~(1 << j)
    for u2 in law.codewords:
        out = u2 & ~u
        if popcount(out) == 1 and (u2 & ~(rest | out)) == 0:
            return False
    return True


def isolated_bound(law):
    tot = 0
    forced = []
    for u in law.circuits():
        vs = [v for v in range(law.m) if u >> v & 1]
        if any(isolated(law, u, j) for j in vs):
            tot += 2 ** (len(vs) - 1)
            forced += parity_clauses(u, law.const[u], law.m)
    return tot, forced


P("== D: exact minimum UP-usable theories over the base variables (exhaustive), against the bounds")
P("   columns: m k d* a* | a*2^(d*-1) (d*>=3) | isolated bound | min usable | |PI| | min==isolated | search size")
ninst = 0
eq_iso = 0
tries = 0
while ninst < 30 and tries < 20000:
    tries += 1
    m = rng.choice([5, 6, 7, 7, 8])
    k = rng.choice([2, 3, 3, 4])
    if k >= m - 1:
        continue
    law = AffineLaw(m, random_system(rng, m, k))
    if law.dmin() < 2:
        continue  # skip laws that fix a variable outright
    pis = prime_implicates_bruteforce(law.sols, m)
    if len(pis) > 90:
        continue
    iso, forced = isolated_bound(law)
    forced_set = set(map(frozenset, forced))
    free = [c for c in pis if frozenset(c) not in forced_set]
    if len(free) > 30:
        continue
    qs = circuit_questions(law)
    found = None
    nsearch = 0
    for s in range(0, len(free) + 1):
        if s > 6:
            break
        for add in combinations(free, s):
            nsearch += 1
            F = list(forced) + list(add)
            if answers_all(F, m, qs):
                found = F
                break
        if found is not None:
            break
    if found is None:
        continue
    ok, _, _ = usable(found, m, m, law.sols)
    assert ok
    dmin = law.dmin()
    astar = sum(1 for u in law.codewords if popcount(u) == dmin)
    lbb = astar * 2 ** (dmin - 1) if dmin >= 3 else None
    ninst += 1
    eq_iso += (len(found) == iso)
    # (b) bound must hold
    if lbb is not None:
        assert len(found) >= lbb
    assert len(found) >= iso
    P(f"  m={m} k={law.k} d*={dmin} a*={astar} | {lbb} | {iso} | {len(found)} | {len(pis)} | {len(found) == iso} | {nsearch}")
P(f"  instances={ninst}; min == isolated bound in {eq_iso}/{ninst}; all minima >= both bounds (asserted)")

# ------------------------------------------------------------------ E
P("== E: simplex family S_r (m = 2^r - 1 variables, r equations, all nonzero columns)")
P("  r=2 (m=3, d*=2): the law is x1=x2=x3; |PI|=6 but two equivalences (4 clauses) are UP-usable, so the r>=3 claim fails here (d*=2)")
for r in range(3, 8):
    m = 2 ** r - 1
    d = 2 ** (r - 1)
    a = m
    P(f"  r={r} m={m}: d*={d} a*={a}; GE core r eqs ({r*(m+1)} bits dense); CNF lb (1-2^-r)2^d={(1-2**-r)*2**d:.0f}; "
      f"min UP-usable no-aux = |PI| = m 2^((m-1)/2) = {m * 2 ** ((m - 1) // 2)}")
r = 3
m = 7
eqs = []
for i in range(r):
    row = 0
    for col in range(1, 2 ** r):
        if col >> i & 1:
            row |= 1 << (col - 1)
    eqs.append((row, 0))
law = AffineLaw(m, eqs)
pis = prime_implicates_bruteforce(law.sols, m)
P(f"  r=3 check: codeword weights={sorted({popcount(u) for u in law.codewords})}, circuits={len(law.circuits())}, |PI|={len(pis)}")
ok, nq, _ = usable(pis, m, m, law.sols)
breaks = 0
for i in range(len(pis)):
    F = pis[:i] + pis[i + 1:]
    ok2, _, _ = usable(F, m, m, law.sols)
    breaks += (not ok2)
P(f"  PI usable: {ok} ({nq} entailed literals); deleting any one of the {len(pis)} clauses breaks usability: {breaks}/{len(pis)}")

# ------------------------------------------------------------------ F
P("== F: d* = 2 counterexample to the a* 2^(d*-1) bound")
# x0=x1=x2=x3 (three equations x0+x1=0, x1+x2=0, x2+x3=0) on m=4
m = 4
law = AffineLaw(m, [(0b0011, 0), (0b0110, 0), (0b1100, 0)])
dmin = law.dmin()
astar = sum(1 for u in law.codewords if popcount(u) == dmin)
chain = []
for i in range(3):
    chain += parity_clauses((1 << i) | (1 << (i + 1)), 0, m)
ok, _, _ = usable(chain, m, m, law.sols)
P(f"  law x0=x1=x2=x3: d*={dmin} a*={astar}, a* 2^(d*-1)={astar * 2 ** (dmin - 1)}; the 3 equivalences as 6 clauses are UP-usable: {ok}")

# ------------------------------------------------------------------ G
P("== G: subsumption lemma: replacing a sound clause by a subsuming prime implicate keeps every UP_k derivation")
viol = 0
tests = 0
for trial in range(40):
    m, k = 6, rng.choice([2, 3])
    law = AffineLaw(m, random_system(rng, m, k))
    pis = prime_implicates_bruteforce(law.sols, m)
    # random sound non-prime clauses: extend prime implicates by random extra literals
    F = []
    for _ in range(rng.randint(3, 10)):
        c = list(rng.choice(pis))
        used = {v for v, s in c}
        for v in range(m):
            if v not in used and rng.random() < 0.3:
                c.append((v, rng.randint(0, 1)))
        F.append(tuple(c))
    # replacement: each clause by some prime implicate contained in it
    G = []
    for c in F:
        cs = set(c)
        subs = [p for p in pis if set(p) <= cs]
        G.append(rng.choice(subs))
    for kr in (1, 2, 3, None):
        for alpha in all_partial_assignments(m):
            if not law.consistent(alpha):
                continue
            a = up(F, m, alpha, kr)
            b = up(G, m, alpha, kr)
            tests += 1
            if a is None or b is None or any(a[v] != -1 and b[v] != a[v] for v in range(m)):
                viol += 1
P(f"  {tests} (theory, alpha, k) runs: violations={viol}")
# ------------------------------------------------------------------ H
P("== H: exact minimum for d*>=3 (Thm 2.6 here): the clauses of the indecomposable circuits form the unique minimum")
P("   indecomposable := no split u = u' + u'' into codewords whose supports meet in exactly one i outside supp(u)")


def decomposable(law, u):
    for u2 in law.codewords:
        out = u2 & ~u
        if popcount(out) == 1 and u2 != u:
            u3 = u ^ u2
            if u3 and (u2 & u3) == out:
                return True
    return False


stats = {}
equiv_bad = 0
del_tests = del_breaks = 0
nH = 0
while nH < 600:
    m = rng.choice([7, 8, 9, 10])
    k = rng.choice([2, 3, 4, 5])
    if k >= m - 2:
        continue
    law = AffineLaw(m, random_system(rng, m, k))
    d = law.dmin()
    if d < 3:
        continue
    nH += 1
    circ = law.circuits()
    # equivalence: isolated at some j  <=>  isolated at every j  <=>  indecomposable
    for u in circ:
        vs = [v for v in range(m) if u >> v & 1]
        iso_flags = [isolated(law, u, j) for j in vs]
        dec = decomposable(law, u)
        if not (all(iso_flags) == any(iso_flags) == (not dec)):
            equiv_bad += 1
    Fiso = []
    nind = 0
    for u in circ:
        if not decomposable(law, u):
            nind += 1
            Fiso += parity_clauses(u, law.const[u], m)
    qs = circuit_questions(law)
    ok = answers_all(Fiso, m, qs)
    key = (d, ok)
    stats[key] = stats.get(key, 0) + 1
    # necessity by deletion (on the first 60 instances): removing any clause of F_iso breaks usability
    if nH <= 60:
        for i in range(len(Fiso)):
            G = Fiso[:i] + Fiso[i + 1:]
            del_tests += 1
            del_breaks += (not answers_all(G, m, qs))
P(f"  {nH} random laws with d*>=3 (m=7..10, k=2..5): (d*, F_iso usable) counts = {dict(sorted(stats.items()))}")
P(f"  equivalence isolated-at-some-j / isolated-at-all-j / indecomposable violated in {equiv_bad} circuits")
P(f"  deletion test on 60 laws: {del_breaks}/{del_tests} single-clause deletions from F_iso break usability")
# d* = 2: F_iso need not be usable
cnt2 = [0, 0]
for _ in range(300):
    m = rng.choice([6, 7, 8]); k = rng.choice([2, 3, 4])
    law = AffineLaw(m, random_system(rng, m, k))
    if law.dmin() != 2:
        continue
    Fiso = []
    for u in law.circuits():
        if not decomposable(law, u):
            Fiso += parity_clauses(u, law.const[u], m)
    cnt2[answers_all(Fiso, m, circuit_questions(law))] += 1
P(f"  d*=2 laws: F_iso usable in {cnt2[1]}, not usable in {cnt2[0]} (the theorem needs d*>=3)")
P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
