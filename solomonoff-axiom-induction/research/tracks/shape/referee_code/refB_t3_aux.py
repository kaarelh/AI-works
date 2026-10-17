"""Referee B, thread `shape`, target T3 (intermediate concepts) and Theorem 1.12 for the simplex family.

Independent of checks/. Seed 20261016. Writes refB_t3_aux.out next to itself.

Checks
 A  Prop 3.1: the chain encoding is propagation complete on all variables (all partial assignments to base and
    auxiliary variables, consistent and inconsistent), m = 4..7, c = 0, 1; clause count 4m - 6.
 B  Prop 3.2: circuit library with chain encodings: usable on random systems.
 S  The simplex family WITH auxiliary variables (bears on Thm 1.12, Cor 2.8 reading, Summary item 2, Sec. 10):
    the circuit library of chain encodings is UP-usable, r = 3 (exhaustive) and r = 4 (all minimal questions,
    projection over all 2^15 base points); listing lengths of PI (no aux), circuit library (aux) and GE core.
 C  Prop 3.3: core direct vs core chain-encoded vs the arc-consistency closure (brute force per constraint).
 D  Lemma 3.4: usable theories with auxiliary variables detect every inconsistent base partial assignment.
 E  Thm 3.6 at n = 4 (all subsets) and n = 5 (sampled): determination of x_t <=> XOR system unsat <=> t in span;
    dim H_n = n + 1 and k = M - n; UP on a usable theory for H_4 computes the monotone function.
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


def full_entailment(models_list, alpha, nvars):
    pts = [x for x in models_list if point_agrees(x, alpha)]
    if not pts:
        return False, set()
    dom = {abs(L) for L in alpha}
    out = set()
    for v in range(1, nvars + 1):
        if v in dom:
            continue
        vals = {bit(x, v) for x in pts}
        if len(vals) == 1:
            out.add(v if vals.pop() else -v)
    return True, out


def proj_by_up(F, m, S):
    """Check proj F = S using UP on full base assignments (valid when every aux variable is a function of the
    base variables that UP computes); falls back to 'unknown' otherwise."""
    S = set(S)
    for x in range(1 << m):
        alpha = frozenset(v if bit(x, v) else -v for v in range(1, m + 1))
        res = up(F, alpha)
        if res is None:
            if x in S:
                return False, ("conflict on a point of S", x)
            continue
        vars_F = {abs(L) for C in F for L in C}
        if not all((v in res) or (-v in res) for v in vars_F):
            return None, ("aux undetermined", x)
        if not all(any(L in res for L in C) for C in F):
            return False, ("final assignment falsifies F", x)
        if x not in S:
            return False, ("point outside S in projection", x)
    return True, None


def minimal_questions(law_pts, m):
    deq = derived_equations(law_pts, m)
    circ = circuits_of(deq)
    qs = []
    for u in circ:
        vs = support(u, m)
        for j in vs:
            rest = [v for v in vs if v != j]
            for vals in product((0, 1), repeat=len(rest)):
                alpha = frozenset(v if b else -v for v, b in zip(rest, vals))
                val = (deq[u] + sum(vals)) % 2
                qs.append((alpha, j if val else -j))
    return qs, deq, circ


def circuit_library(deq, circ, m, force_chain=False):
    F = []
    nxt = m + 1
    for u in circ:
        vs = support(u, m)
        if force_chain and len(vs) >= 4:
            G, nxt = chain_encoding(vs, deq[u], nxt)
        elif len(vs) <= 3 or 2 ** (len(vs) - 1) <= 4 * len(vs) - 6:
            G = eq_clauses(u, deq[u], m)
        else:
            G, nxt = chain_encoding(vs, deq[u], nxt)
        F += G
    return F, nxt - 1


P("# refB_t3_aux.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
# ------------------------------------------------------------------ A
P("== A: Prop 3.1: chain encoding propagation complete on all variables (exhaustive)")
for m in range(4, 8):
    for c in (0, 1):
        vs = list(range(1, m + 1))
        F, nxt = chain_encoding(vs, c, m + 1)
        N = nxt - 1
        mods = models(F, N)
        assert len(mods) == 2 ** (m - 1)
        assert projection(F, N, m) == set(x for x in range(1 << m) if popcount(x) % 2 == c)
        fails = ncons = ninc = 0
        for alpha in partial_assignments(range(1, N + 1)):
            cons, ent = full_entailment(mods, alpha, N)
            res = up(F, alpha)
            if not cons:
                ninc += 1
                fails += (res is not None)
                continue
            ncons += 1
            if res is None or not (ent <= res) or any((L not in alpha and L not in ent) for L in res):
                fails += 1
        P(f"  m={m} c={c}: clauses={len(F)} (4m-6={4 * m - 6}), aux={N - m}; partial assignments: {ncons} consistent, "
          f"{ninc} inconsistent; failures={fails}")

# ------------------------------------------------------------------ B
P("== B: Prop 3.2: circuit library (chain encodings of circuits of weight >= 4) usable on random systems")
for trial in range(6):
    m = rng.choice([6, 7, 8])
    k = rng.choice([2, 3, 4])
    while True:
        rows = [rng.randrange(1, 1 << m) for _ in range(k)]
        if rank(rows) == k:
            break
    consts = [rng.randrange(2) for _ in range(k)]
    pts = affine_points(rows, consts, m)
    qs, deq, circ = minimal_questions(pts, m)
    F, N = circuit_library(deq, circ, m, force_chain=True)
    pr, why = proj_by_up(F, m, pts)
    ok, n, fail = usable(F, N, pts, m, check_proj=False, check_conflicts=True)
    size_formula = sum(2 ** (popcount(u) - 1) if popcount(u) <= 3 else 4 * popcount(u) - 6 for u in circ)
    P(f"  m={m} k={k}: circuits={len(circ)} (weights {sorted(popcount(u) for u in circ)}), library clauses={len(F)} "
      f"(formula {size_formula}), aux={N - m}; proj==S: {pr}; usable+conflict-complete: {ok} ({n} entailed literals)")
# the record's size formula sum min(2^{|u|-1}, 4|u|-6) at weight 1
P(f"  record's size formula min(2^(|u|-1), 4|u|-6) at |u| = 1, 2, 3: {[min(2 ** (w - 1), 4 * w - 6) for w in (1, 2, 3)]}")

# ------------------------------------------------------------------ S
P("== S: simplex family with auxiliary variables (UP reasoner, explicit theories over X u Y)")
for r in (3, 4):
    m = 2 ** r - 1
    rows = [sum(1 << (c - 1) for c in range(1, m + 1) if (c >> i) & 1) for i in range(r)]
    pts = affine_points(rows, [0] * r, m)
    qs, deq, circ = minimal_questions(pts, m)
    F, N = circuit_library(deq, circ, m, force_chain=True)
    pr, why = proj_by_up(F, m, pts)
    bad = 0
    for alpha, L in qs:
        res = up(F, alpha)
        if res is None or L not in res:
            bad += 1
    # random partial assignments: soundness and completeness on base literals, conflicts on inconsistent ones
    rbad = 0
    nsamp = 4000 if r == 4 else 0
    for _ in range(nsamp):
        alpha = frozenset(v if rng.random() < 0.5 else -v for v in range(1, m + 1) if rng.random() < 0.6)
        cons, ent = entailed(pts, m, alpha)
        res = up(F, alpha)
        if not cons:
            rbad += (res is not None)
            continue
        if res is None:
            rbad += 1
            continue
        base = {L for L in res if abs(L) <= m}
        rbad += (base != set(alpha) | ent)
    exh = ""
    if r == 3:
        ok, n, fail = usable(F, N, pts, m, check_proj=False, check_conflicts=True)
        exh = f"; exhaustive usability over all 3^7 base partial assignments: {ok} ({n} entailed literals)"
    width = (m + 1) // 2
    P(f"  r={r} m={m}: circuit library with chain encodings: {len(F)} clauses, {N - m} aux "
      f"(m(4*{width}-6) = {m * (4 * width - 6)}); proj==S over all 2^{m} base points: {pr}; "
      f"minimal questions failed: {bad}/{len(qs)}; random partial assignments failed: {rbad}/{nsamp}{exh}")
P("  listing lengths (record's l_lst, Elias delta for l_N) and clause counts:")
P("   r  m | PI over X: clauses, bits | circuit library with aux: clauses, aux, bits | GE core: r equations, bits")
for r in range(3, 8):
    m = 2 ** r - 1
    w = (m + 1) // 2
    # PI over X
    npi = m * 2 ** (w - 1)
    lw = math.ceil(math.log2(m)) + 1
    bits_pi = ell_N(0) + ell_N(npi) + npi * (ell_N(w) + w * lw)
    # circuit library with chain encodings: per circuit 4w-6 clauses, w-2 aux; clauses of width 3 (and 2 of width 2)
    ncl = m * (4 * w - 6)
    naux = m * (w - 2)
    N = m + naux
    lw2 = math.ceil(math.log2(N)) + 1
    bits_lib = ell_N(naux) + ell_N(ncl) + m * ((4 * w - 8) * (ell_N(3) + 3 * lw2) + 2 * (ell_N(2) + 2 * lw2))
    # GE core: r equations of weight w, each listed by support and constant
    bits_ge = ell_N(0) + ell_N(r) + r * (ell_N(w) + w * math.ceil(math.log2(m)) + 1)
    P(f"   {r} {m:3d} | {npi}, {bits_pi:.4g} | {ncl}, {naux}, {bits_lib} | {r}, {bits_ge}")

# ------------------------------------------------------------------ C
P("== C: Prop 3.3: core direct vs core chain-encoded (private aux) vs arc-consistency closure")


def ac_closure(rows, consts, m, alpha):
    """Arc-consistency closure by brute force per constraint. Returns set of literals or None (contradiction)."""
    state = set(alpha)
    changed = True
    while changed:
        changed = False
        for r, c in zip(rows, consts):
            vs = support(r, m)
            loc = [L for L in state if abs(L) in vs]
            sols = [vals for vals in product((0, 1), repeat=len(vs)) if sum(vals) % 2 == c
                    and all((vals[vs.index(abs(L))] == 1) == (L > 0) for L in loc)]
            if not sols:
                return None
            for i, v in enumerate(vs):
                vals = {s[i] for s in sols}
                if len(vals) == 1:
                    L = v if vals.pop() else -v
                    if L not in state:
                        state.add(L)
                        changed = True
    return state


for trial in range(5):
    m = rng.choice([7, 8, 9])
    k = rng.choice([3, 4, 5])
    while True:
        rows = []
        for _ in range(k):
            w = rng.choice([3, 4, 5])
            rows.append(sum(1 << (v - 1) for v in rng.sample(range(1, m + 1), w)))
        if rank(rows) == k:
            break
    consts = [rng.randrange(2) for _ in range(k)]
    direct = []
    for r, c in zip(rows, consts):
        direct += eq_clauses(r, c, m)
    chained = []
    nxt = m + 1
    for r, c in zip(rows, consts):
        G, nxt = chain_encoding(support(r, m), c, nxt)
        chained += G
    diff1 = diff2 = 0
    n = 0
    for alpha in partial_assignments(range(1, m + 1)):
        n += 1
        a = up(direct, alpha)
        b = up(chained, alpha)
        cl = ac_closure(rows, consts, m, alpha)
        A = None if a is None else frozenset(L for L in a if abs(L) <= m)
        B = None if b is None else frozenset(L for L in b if abs(L) <= m)
        Cc = None if cl is None else frozenset(cl)
        diff1 += (A != B)
        diff2 += (B != Cc)
    P(f"  m={m} k={k} row weights {[popcount(r) for r in rows]}: {n} base partial assignments; "
      f"direct != chained: {diff1}; chained != AC closure: {diff2}")

# ------------------------------------------------------------------ D
P("== D: Lemma 3.4: usable theories detect every inconsistent base partial assignment (and a non-usable one need not)")
for m in (5, 6, 7):
    F, nxt = chain_encoding(list(range(1, m + 1)), 1, m + 1)
    S = [x for x in range(1 << m) if popcount(x) % 2 == 1]
    ok, n, fail = usable(F, nxt - 1, S, m, check_proj=False, check_conflicts=True)
    P(f"  chain encoding of parity m={m}: usable and conflict-complete: {ok}")
# non-usable core: does it miss conflicts?
m = 6
rows = [0b000111, 0b011100, 0b110001]
consts = [0, 1, 0]
pts = affine_points(rows, consts, m)
core = []
for r, c in zip(rows, consts):
    core += eq_clauses(r, c, m)
okU, _, _ = usable(core, m, pts, m)
missed = 0
for alpha in partial_assignments(range(1, m + 1)):
    cons, _ = entailed(pts, m, alpha)
    if not cons and up(core, alpha) is not None:
        missed += 1
P(f"  control: a core that is not usable ({okU}) misses {missed} inconsistent base partial assignments")

# ------------------------------------------------------------------ E
P("== E: Thm 3.6: the hidden-state law H_n")


def hidden_state(n):
    gs = []
    for trip in combinations(range(n), 3):
        u = sum(1 << i for i in trip)
        for c in (0, 1):
            gs.append((u, c))
    return gs


for n in (3, 4, 5):
    gs = hidden_state(n)
    M = len(gs)
    m = M + 1
    # points: z in GF(2)^{n+1}, z = (zbits over n, z0)
    pts = set()
    for zb in range(1 << n):
        for z0 in (0, 1):
            x = 0
            for e, (u, c) in enumerate(gs):
                if (popcount(u & zb) + c * z0) % 2:
                    x |= 1 << e
            if z0:
                x |= 1 << M
            pts.add(x)
    dim = int(math.log2(len(pts)))
    P(f"  n={n}: M={M}, m={m}, dim H_n={dim} (n+1={n + 1}), k = m - dim = {m - dim} (M-n={M - n})")
    if n == 3:
        continue
    vecs = [(u | (c << n)) for (u, c) in gs]
    tvec = 1 << n
    subsets = range(1 << M) if n == 4 else [rng.randrange(1 << M) for _ in range(3000)]
    bad = 0
    nunsat = 0
    for Smask in subsets:
        sel = [e for e in range(M) if (Smask >> e) & 1]
        det = len({(x >> M) & 1 for x in pts if all(((x >> e) & 1) == 0 for e in sel)}) == 1
        unsat = not any(all((popcount(gs[e][0] & y) % 2) == gs[e][1] for e in sel) for y in range(1 << n))
        inspan = tvec in span([vecs[e] for e in sel])
        nunsat += unsat
        bad += not (det == unsat == inspan)
    P(f"   subsets tested: {len(subsets)}; unsat: {nunsat}; mismatches among (determined, XOR-unsat, t in span): {bad}")
    if n == 4:
        qs, deq, circ = minimal_questions(sorted(pts), m)
        F, N = circuit_library(deq, circ, m, force_chain=True)
        pr, why = proj_by_up(F, m, pts)
        badq = sum(1 for alpha, L in qs if (lambda r: r is None or L not in r)(up(F, alpha)))
        mono_bad = 0
        for Smask in range(1 << M):
            sel = [e for e in range(M) if (Smask >> e) & 1]
            alpha = frozenset(-(e + 1) for e in sel)
            res = up(F, alpha)
            unsat = not any(all((popcount(gs[e][0] & y) % 2) == gs[e][1] for e in sel) for y in range(1 << n))
            derived = res is not None and (-m) in res
            mono_bad += (derived != unsat) or res is None or (m in res)
        P(f"   n=4: circuits={len(circ)} (weights {sorted(set(popcount(u) for u in circ))}); circuit library: {len(F)} clauses, "
          f"{N - m} aux; proj==S: {pr}; minimal questions failed {badq}/{len(qs)}; "
          f"UP derives not-x_t from alpha_S iff XOR-unsat: mismatches {mono_bad}/256")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t3_aux.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
