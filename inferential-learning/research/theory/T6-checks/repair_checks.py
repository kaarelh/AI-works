"""T6 repair checks (added after adversarial verification; see the Verification log of T6).

(A) Thm 1.5(c) needs soundness: the referee's 3-sentence counterexample, plus random finite frames
    (with soundness: 0 failures of (b) and (c); without: failures of (c) exist).
    Prop 1.3 does not need soundness: random unsound frames, 0 failures.
(B) Def 4.0 / Cor 4.2 for Lindenbaum semantics: with M = Fix(C) the falsum condition can never hold;
    with M = Fix(C) minus {S} and an explosive falsum, C = Th o Mod, Mod(bot) is empty and
    "T != S iff Mod(T) nonempty" (random finite closure systems). Non-explosive bot: counterexample.
(C) Thm 3.5 by exact MILP (integer multiplicities, any repetition allowed) for k = 3, 4, 5:
    min (sum_Phi P_k - m) over valid counting sequents with m <= k-2 is 0; with m <= k-1 it is -1/(k-1).
(D) Section 0 / Thm 5.2 needs a generating valuation: h(p) = a in the 4-element Heyting chain generates
    a 3-element subalgebra, and the reduced matrix is <H_3,{1}>, not <H_4,{1}>.
"""
import itertools, random
from fractions import Fraction
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds

# ---------------------------------------------------------------- (A), (B): finite closure systems
def closure_system(n, rng, extra=4):
    S = frozenset(range(n))
    fam = {S}
    for _ in range(rng.randint(0, extra)):
        fam.add(frozenset(x for x in range(n) if rng.random() < 0.5))
    changed = True
    while changed:                               # close under pairwise intersection
        changed = False
        for a in list(fam):
            for b in list(fam):
                c = a & b
                if c not in fam:
                    fam.add(c); changed = True
    return fam

def C_of(fam, X):
    out = frozenset(range(max(len(t) for t in fam)))
    for T in fam:
        if X <= T:
            out = out & T
    return out

def subsets(n):
    for r in range(n + 1):
        for X in itertools.combinations(range(n), r):
            yield frozenset(X)

def Mod(models, X):   # a model is identified with its theory Th({m})
    return [m for m in models if X <= m]

def ThMod(models, X, n):
    out = frozenset(range(n))
    for m in Mod(models, X):
        out = out & m
    return out

def points(fam, n):
    S = frozenset(range(n)); pts = []
    for T in fam:
        if T == S:
            continue
        above = [U for U in fam if T < U]
        common = frozenset(range(n))
        for U in above:
            common &= U
        if common - T:                         # some sigma not in T lies in every strictly larger closed set
            pts.append(T)
    return pts

# referee's counterexample to Thm 1.5(c) without soundness: S = {a, b, bot} = {0, 1, 2}
fam = {frozenset(), frozenset({0}), frozenset({0, 1, 2})}
models = [frozenset({0, 1})]
n = 3; S = frozenset(range(n))
weak = all(Mod(models, X) for X in subsets(n) if C_of(fam, X) != S)
maximal = [T for T in fam if T != S and not any(T < U and U != S for U in fam)]
realized = all(T in models for T in maximal)
sound = all(m in fam for m in models)
print("(A) referee counterexample: sound=%s weakly complete=%s maximal theories realized=%s  -> (c)(=>) fails without soundness"
      % (sound, weak, realized))
assert weak and not realized and not sound

rng = random.Random(7)
fail_b = fail_c = fail_c_unsound = fail_13_unsound = tested = tested_u = 0
for trial in range(6000):
    n = rng.randint(2, 5); S = frozenset(range(n))
    fam = closure_system(n, rng)
    use_sound = trial % 2 == 0
    if use_sound:
        cand = [T for T in fam if T != S or rng.random() < 0.1]
    else:
        cand = list(subsets(n))
    models = [m for m in cand if rng.random() < 0.5]
    if not models:
        continue
    strong = all(C_of(fam, X) == ThMod(models, X, n) for X in subsets(n))
    # image of Th = {Th(K)}: compute as all intersections of subfamilies of models (plus S)
    image = {S} | set(models)                      # {Th(K)} = closure of the Th({m}) under intersections
    changed = True
    while changed:
        changed = False
        for a in list(image):
            for b in list(image):
                if (a & b) not in image:
                    image.add(a & b); changed = True
    prop13 = ((image == fam) == strong)
    if not use_sound:
        tested_u += 1
        fail_13_unsound += (not prop13)
    if any(m == S for m in models):
        continue                                   # hypothesis of (c): Th({m}) != S
    weak = all(Mod(models, X) for X in subsets(n) if C_of(fam, X) != S)
    maximal = [T for T in fam if T != S and not any(T < U and U != S for U in fam)]
    realized_max = all(T in models for T in maximal)
    if use_sound:
        tested += 1
        pts_real = all(P in models for P in points(fam, n))
        fail_b += (strong != pts_real)
        fail_c += (weak != realized_max)
    else:
        fail_c_unsound += (weak != realized_max)
print("(A) sound random frames: %d tested; failures of 1.5(b): %d, of 1.5(c): %d" % (tested, fail_b, fail_c))
print("(A) unsound random frames: %d tested; failures of Prop 1.3: %d; failures of 1.5(c): %d (expected > 0)"
      % (tested_u, fail_13_unsound, fail_c_unsound))
assert fail_b == 0 and fail_c == 0 and fail_13_unsound == 0 and fail_c_unsound > 0

# (B) Lindenbaum semantics for a context of Def 4.0
bad = tested = 0
for trial in range(3000):
    n = rng.randint(2, 5); S = frozenset(range(n)); bot = 0
    fam = {T for T in closure_system(n, rng) if bot not in T or T == S}   # makes bot explosive: C({bot}) = S
    fam.add(S)
    # re-close under intersection (removing sets containing bot keeps intersection-closure? check)
    fam = {T for T in fam}
    ok_closed = all((a & b) in fam for a in fam for b in fam)
    if not ok_closed:
        continue
    tested += 1
    M_full = list(fam)                                 # Thm 1.4's canonical frame: falsum impossible
    assert Mod(M_full, frozenset({bot})), "S itself satisfies bot"
    M = [T for T in fam if T != S]                     # proper closed theories
    for X in subsets(n):
        if C_of(fam, X) != ThMod(M, X, n):
            bad += 1
    if Mod(M, frozenset({bot})):
        bad += 1
    for T in fam:
        if (T != S) != bool(Mod(M, T)):
            bad += 1
print("(B) %d random closure systems with explosive bot, M = Fix(C) minus {S}: C = Th o Mod, Mod(bot) empty, "
      "T != S iff Mod(T) nonempty -- violations: %d" % (tested, bad))
assert bad == 0
# non-explosive bot (R empty, C = identity on {bot, a}): bot derivable but belief state nonempty
n = 2; fam = set(subsets(n)); M = [T for T in fam if T != frozenset(range(n))]
print("(B) identity closure, K = {bot}: bot in T = {bot}, yet Mod({bot}) =", [sorted(m) for m in Mod(M, frozenset({0}))])

# ---------------------------------------------------------------- (C) Thm 3.5 by exact MILP
def thm35_milp(k, mmax, U=8):
    atoms = range(k); pairs = list(itertools.combinations(atoms, 2))
    worlds = list(itertools.product([0, 1], repeat=k))
    # F_k: A_i, not A_i, A_i & A_j, not(A_i & A_j)
    cols, P = [], []
    for i in atoms:
        cols.append([w[i] for w in worlds]); P.append(Fraction(1, k - 1))
        cols.append([1 - w[i] for w in worlds]); P.append(1 - Fraction(1, k - 1))
    for (i, j) in pairs:
        cols.append([w[i] * w[j] for w in worlds]); P.append(Fraction(0))
        cols.append([1 - w[i] * w[j] for w in worlds]); P.append(Fraction(1))
    F = len(cols); Tm = np.array(cols).T                       # worlds x F
    # variables: n_phi (F of them), m ; objective sum n P - m ; validity: T n - m >= 0
    c = np.array([float(p) for p in P] + [-1.0])
    A = np.hstack([Tm, -np.ones((len(worlds), 1))])
    cons = LinearConstraint(A, lb=np.zeros(len(worlds)), ub=np.full(len(worlds), np.inf))
    bounds = Bounds(lb=np.zeros(F + 1), ub=np.array([U] * F + [mmax]))
    r = milp(c, constraints=cons, integrality=np.ones(F + 1), bounds=bounds)
    x = np.round(r.x).astype(int)
    val = sum(Fraction(int(x[f])) * P[f] for f in range(F)) - int(x[F])   # exact re-evaluation
    assert all(int(Tm[w] @ x[:F]) >= x[F] for w in range(len(worlds)))   # exact validity
    # the repetition-free sequent of Thm 3.5(a): {not A_i} + {A_i & A_j}, m = k-1
    seq_a = [1 if (f < 2 * k and f % 2 == 1) or (f >= 2 * k and f % 2 == 0) else 0 for f in range(F)]
    assert all(int(Tm[w] @ np.array(seq_a)) >= k - 1 for w in range(len(worlds)))
    val_a = sum(P[f] * seq_a[f] for f in range(F)) - (k - 1)
    return val, int(x[F]), val_a

for k in (3, 4, 5):
    v1, m1, _ = thm35_milp(k, k - 2)
    v2, m2, va = thm35_milp(k, k - 1)
    print("(C) k=%d: min over valid sequents with m<=k-2: %s; with m<=k-1: %s (at m=%d); "
          "the repetition-free sequent of 3.5(a) attains %s" % (k, v1, v2, m2, va))
    assert v1 >= 0 and v2 == Fraction(-1, k - 1) == va

# ---------------------------------------------------------------- (D) generated submatrix of H_4
TOP = 3
def imp(x, y):
    return TOP if x <= y else y
gen = {0, 1}            # bottom constant and h(p) = a (= 1) in the chain 0 < a < b < 1, coded 0 < 1 < 2 < 3
changed = True
while changed:
    changed = False
    for x in list(gen):
        for y in list(gen):
            for z in (min(x, y), max(x, y), imp(x, y)):
                if z not in gen:
                    gen.add(z); changed = True
print("(D) subalgebra of H_4 generated by a:", sorted(gen), "(3 elements, a 3-chain: H_3, not H_4)")
assert sorted(gen) == [0, 1, 3]
# reducedness of <H_3,{1}>: no nontrivial congruence of the 3-chain is compatible with {top}
el = sorted(gen); cong_ok = []
for part in [[[0, 1], [3]], [[0], [1, 3]], [[0, 3], [1]], [[0, 1, 3]]]:
    cls = {x: i for i, b in enumerate(part) for x in b}
    compat_ops = all(cls[f(x, y)] == cls[f(x2, y2)]
                     for f in (min, max, imp) for x in el for y in el for x2 in el for y2 in el
                     if cls[x] == cls[x2] and cls[y] == cls[y2])
    compat_D = all(not (cls[x] == cls[TOP] and x != TOP) for x in el)
    cong_ok.append(compat_ops and compat_D)
print("(D) nontrivial congruences of H_3 compatible with {1}:", sum(cong_ok), "-> <H_3,{1}> is reduced")
assert sum(cong_ok) == 0
print("all repair checks passed")
