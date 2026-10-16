"""c5: learning know-how pattern by pattern (thread `shape`, target T6).

Seed 20261016.  Writes c5_learning.out next to itself.

Law: one parity law x_1 + ... + x_m = 0 (m = 4, 5, 6).  Questions Q_{m-1}: antecedent on m-1 variables, the
remaining variable asked; m 2^(m-1) questions, 2^(m-1) value patterns (violating points), m questions each.

* MAP inducer without auxiliary variables, reasoner UP: at each checkpoint, a theory of least listing length
  among those UP-compatible with the data seen (exact, by integer programming: compatibility with
  |S| = m-1 questions is a set-cover condition, see notes Lemma 6.2).  We count the questions of Q_{m-1}
  on which it fails (errs, abstains, or is inconsistent with the antecedent), the unseen patterns, and check
  failures >= unseen patterns (Thm 6.3(b)).
* MAP inducer over linear theories, reasoner GE: the cheapest affine subspace compatible with the data
  (exhaustive over all affine subspaces for m <= 5).
* Coupon collector: E[#unseen patterns after T questions] = 2^(m-1) (1 - 2^(1-m))^T, against simulation.
"""
import random, sys, time, math
from itertools import product, combinations
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import popcount

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


def elias_delta_len(n):
    n = n + 1  # allow 0
    L = n.bit_length() - 1
    return L + 2 * ((L + 1).bit_length() - 1) + 1


def clause_cost(width, m):
    return elias_delta_len(width) + width * (math.ceil(math.log2(m)) + 1)


def questions(m):
    """List of (alpha_mask_vars, alpha_vals, j, v): antecedent = all vars except j with values; answer x_j = v."""
    qs = []
    for j in range(m):
        for x in range(1 << m):
            if popcount(x) % 2 != 0:
                continue  # x is the positive point gamma (in the law)
            qs.append((j, x))  # question: alpha = x minus coordinate j; answer x_j = x_j; pattern = x ^ (1<<j)
    return qs


def all_clauses(m):
    """Clauses as (support mask, falsifying assignment on support as mask)."""
    out = []
    for T in range(1, 1 << m):
        sub = T
        # enumerate assignments beta on T: iterate over submasks of T
        b = T
        while True:
            out.append((T, b))
            if b == 0:
                break
            b = (b - 1) & T
    return out


def violated(clause, x):
    T, beta = clause
    return (x & T) == beta


def answers(F, m, j, x):
    """UP on F from alpha = x without coordinate j. Returns 'correct', 'wrong', 'abstain', 'inconsistent'."""
    # clauses falsified entirely by alpha (not mentioning j): inconsistent
    T_all = ((1 << m) - 1) & ~(1 << j)
    derive = set()
    for (T, beta) in F:
        if not (T >> j & 1):
            if (x & T) == beta:
                return 'inconsistent'
            continue
        # clause mentions j: fires iff alpha falsifies all its other literals
        Tr = T & ~(1 << j)
        if (x & Tr) == (beta & Tr):
            # derived literal: x_j != beta_j
            derive.add(1 - ((beta >> j) & 1))
    if len(derive) == 2:
        return 'inconsistent'
    if not derive:
        return 'abstain'
    v = derive.pop()
    return 'correct' if v == ((x >> j) & 1) else 'wrong'


def map_noaux(m, seen, cl_all, costs):
    """Least-cost set of clauses UP-compatible with the seen questions (set cover ILP)."""
    gammas = {x for (j, x) in seen}
    allowed = [i for i, c in enumerate(cl_all) if not any(violated(c, g) for g in gammas)]
    # coverage: clause C covers question (j, x) iff j in supp(C) and C subset of C_pattern, pattern = x ^ e_j,
    # i.e. pattern restricted to supp(C) equals beta (C falsified by the pattern)
    qlist = sorted(set(seen))
    rows = []
    for (j, x) in qlist:
        pat = x ^ (1 << j)
        cov = [ii for ii, i in enumerate(allowed) if (cl_all[i][0] >> j & 1) and violated(cl_all[i], pat)]
        rows.append(cov)
    nvar = len(allowed)
    if nvar == 0:
        return []
    A = np.zeros((len(rows), nvar))
    for r, cov in enumerate(rows):
        for ii in cov:
            A[r, ii] = 1
    c = np.array([costs[i] for i in allowed], dtype=float)
    res = milp(c, constraints=[LinearConstraint(A, lb=np.ones(len(rows)), ub=np.inf)],
               integrality=np.ones(nvar), bounds=Bounds(0, 1))
    assert res.status == 0, res.message
    chosen = [cl_all[allowed[ii]] for ii in range(nvar) if res.x[ii] > 0.5]
    # inclusion-minimality (the theorem is stated for inclusion-minimal theories): prune redundant clauses
    changed = True
    while changed:
        changed = False
        for C in list(chosen):
            G = [D for D in chosen if D != C]
            if all(any((D[0] >> j & 1) and violated(D, x ^ (1 << j)) for D in G) for (j, x) in qlist):
                chosen = G
                changed = True
                break
    return chosen


def affine_subspaces(m):
    """All affine subspaces of GF(2)^m as frozensets, with the cheapest listing cost of a defining system."""
    from itertools import combinations
    vecs = list(range(1, 1 << m))
    out = {}
    # linear subspaces via spans of independent sets (small m)
    lin = {frozenset([0])}
    frontier = [frozenset([0])]
    while frontier:
        nf = []
        for Wd in frontier:
            for v in vecs:
                if v in Wd:
                    continue
                W2 = frozenset(Wd | {w ^ v for w in Wd})
                if W2 not in lin:
                    lin.add(W2)
                    nf.append(W2)
        frontier = nf
    for Wd in lin:
        # dual: vectors u with u.w = 0 for all w in Wd
        dual = [u for u in range(1 << m) if all(popcount(u & w) % 2 == 0 for w in Wd)]
        kdual = int(round(math.log2(len(dual))))
        # cheapest basis of the dual (exhaustive over bases)
        nz = [u for u in dual if u]
        best = None
        if kdual == 0:
            best = 0
        else:
            for B in combinations(sorted(nz, key=popcount), kdual):
                span = {0}
                for b in B:
                    span |= {s ^ b for s in span}
                if len(span) == len(dual):
                    cost = sum(elias_delta_len(popcount(b)) + popcount(b) * math.ceil(math.log2(m)) + 1 for b in B)
                    if best is None or cost < best:
                        best = cost
                    if kdual >= 3 and best is not None:
                        break  # sorted by weight: good enough for an upper bound on the cheapest
        cosets = set()
        for x in range(1 << m):
            cosets.add(frozenset(x ^ w for w in Wd))
        for W in cosets:
            out[W] = elias_delta_len(kdual) + best
    return out


t0 = time.time()
P(f"# c5_learning.py  seed={SEED}  python={sys.version.split()[0]}")
P("== coupon collector and the no-aux MAP inducer (UP) against the GE MAP inducer, random question orders")
for m in (4, 5, 6):
    qs = questions(m)
    cl_all = all_clauses(m)
    costs = [clause_cost(popcount(T), m) for (T, b) in cl_all]
    npat = 2 ** (m - 1)
    full_cost = npat * clause_cost(m, m)
    P(f"  m={m}: |Q_(m-1)|={len(qs)}, patterns={npat}; listing cost of the full no-aux theory ~ {full_cost} bits; "
      f"one parity equation ~ {elias_delta_len(1) + elias_delta_len(m) + m * math.ceil(math.log2(m)) + 1} bits")
    subs = affine_subspaces(m) if m <= 5 else None
    law = frozenset(x for x in range(1 << m) if popcount(x) % 2 == 0)
    nruns = 12 if m < 6 else 6
    checkpoints = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    agg = {T: [] for T in checkpoints}
    viol = 0
    first_full = []
    all_seen_at = []
    ge_correct_at = []
    for run in range(nruns):
        seq = [rng.choice(qs) for _ in range(checkpoints[-1])]
        seen_pats_time = None
        pats = set()
        for t, (j, x) in enumerate(seq, 1):
            pats.add(x ^ (1 << j))
            if len(pats) == npat and seen_pats_time is None:
                seen_pats_time = t
        all_seen_at.append(seen_pats_time)
        got_full = None
        got_ge = None
        for T in checkpoints:
            seen = seq[:T]
            F = map_noaux(m, seen, cl_all, costs)
            res = [answers(F, m, j, x) for (j, x) in qs]
            fails = sum(r != 'correct' for r in res)
            unseen = npat - len({x ^ (1 << j) for (j, x) in seen})
            if fails < unseen:
                viol += 1
            if fails == 0 and got_full is None:
                got_full = T
            ge_f = None
            if subs is not None:
                # GE MAP: cheapest affine W containing every seen gamma and making the answer unique
                best = None
                for W, cst in subs.items():
                    if all((x in W) and ((x ^ (1 << j)) not in W) for (j, x) in seen):
                        if best is None or cst < best[1]:
                            best = (W, cst)
                W = best[0]
                ge_f = sum(1 for (j, x) in qs if not (x in W and (x ^ (1 << j)) not in W))
                if ge_f == 0 and got_ge is None:
                    got_ge = T
            agg[T].append((fails, unseen, len(F), ge_f))
        first_full.append(got_full)
        ge_correct_at.append(got_ge)
    P(f"   checkpoint T | mean unseen patterns (theory 2^(m-1)(1-2^(1-m))^T) | mean no-aux MAP failures | mean clauses | mean GE-MAP failures")
    for T in checkpoints:
        f = [a[0] for a in agg[T]]
        u = [a[1] for a in agg[T]]
        nc = [a[2] for a in agg[T]]
        g = [a[3] for a in agg[T] if a[3] is not None]
        th = npat * (1 - 1 / npat) ** T
        gstr = f"{sum(g)/len(g):.2f}" if g else "n/a"
        P(f"   T={T:5d} | {sum(u)/len(u):7.2f} ({th:7.2f}) | {sum(f)/len(f):7.2f} | {sum(nc)/len(nc):6.2f} | {gstr}")
    P(f"   runs={nruns}: failures < unseen patterns in {viol} checkpoint(s) (theorem: never); all patterns seen at T = "
      f"{all_seen_at} (expected {npat * sum(1/i for i in range(1, npat+1)):.1f}); first fully correct no-aux MAP at checkpoint "
      f"{first_full}; first fully correct GE MAP at checkpoint {ge_correct_at}")
P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
