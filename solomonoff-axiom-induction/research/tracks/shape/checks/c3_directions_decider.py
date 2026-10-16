"""c3: directed rules against clauses (target T4) and the membership decider of PI (target T5).

Seed 20261016.  Writes c3_directions_decider.out next to itself.

A  one parity law on m variables, no auxiliary variables: every sound directed rule (premise P, conclusion l)
   has |P| = m-1; there are exactly m 2^(m-1) of them; each question with |S| = m-1 is served by exactly one;
   so the minimum direction-complete rule set has m 2^(m-1) rules against 2^(m-1) clauses (m = 2..7).
B  forward chaining with the rules of a clause set = unit propagation with the clause set, round by round
   (random clause sets with auxiliary variables).
C  chain encoding as rules: 3(4m-6)-2 rules, forward chaining is complete (m = 4..7).
D  the polynomial-time decider of PI(S) (rank test on the columns of the clause's support) agrees with brute force.
"""
import random, sys, time
from itertools import product, combinations
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import *

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


def fc(rules, N, alpha, rounds=None):
    """Forward chaining with directed rules (premise dict, conclusion literal), parallel rounds."""
    a = [-1] * N
    for v, s in alpha.items():
        a[v] = s
    t = 0
    while rounds is None or t < rounds:
        new = {}
        for prem, (v, s) in rules:
            if all(a[u] == b for u, b in prem):
                if a[v] == -1:
                    if v in new and new[v] != s:
                        return None
                    new[v] = s
                elif a[v] != s:
                    return None
        if not new:
            break
        for v, s in new.items():
            a[v] = s
        t += 1
    return a


def rules_of(F):
    R = []
    for C in F:
        for i, (v, s) in enumerate(C):
            prem = tuple((u, 1 - b) for j, (u, b) in enumerate(C) if j != i)
            R.append((prem, (v, s)))
    return R


t0 = time.time()
P(f"# c3_directions_decider.py  seed={SEED}  python={sys.version.split()[0]}")

P("== A: parity law, no auxiliary variables: sound directed rules")
for m in range(2, 8):
    c = 0
    sols = [x for x in range(1 << m) if popcount(x) % 2 == c]
    nsound = 0
    sizes = set()
    for j in range(m):
        others = [v for v in range(m) if v != j]
        for vals in product((-1, 0, 1), repeat=m - 1):
            alpha = {v: s for v, s in zip(others, vals) if s != -1}
            imp = law_implied(sols, m, alpha)
            if imp is None:
                continue
            for (v, s) in imp:
                if v == j:
                    nsound += 1
                    sizes.add(len(alpha))
    # each question (alpha on m-1 vars) served by exactly one sound rule: the rule with premise alpha itself
    P(f"  m={m}: sound rules = {nsound} (m 2^(m-1) = {m * 2 ** (m - 1)}); premise sizes = {sorted(sizes)}; "
      f"clauses needed = 2^(m-1) = {2 ** (m - 1)}; ratio = {nsound // 2 ** (m - 1)}")
    if m <= 5:
        F = parity_clauses((1 << m) - 1, c, m)
        R = rules_of(F)
        ok = all((lambda a: a is not None and all(a[v] == s for v, s in law_implied(sols, m, al)))(fc(R, m, al))
                 for al in all_partial_assignments(m) if law_implied(sols, m, al) is not None)
        breaks = 0
        for i in range(len(R)):
            R2 = R[:i] + R[i + 1:]
            ok2 = all((lambda a: a is not None and all(a[v] == s for v, s in law_implied(sols, m, al)))(fc(R2, m, al))
                      for al in all_partial_assignments(m) if law_implied(sols, m, al) is not None)
            breaks += (not ok2)
        P(f"         rules of the 2^(m-1) clauses: {len(R)} rules, forward chaining usable={ok}; deleting any one rule breaks it: {breaks}/{len(R)}")

P("== B: forward chaining with the rules of F equals unit propagation with F, round by round")
mism = runs = 0
for trial in range(200):
    N = rng.randint(4, 8)
    F = []
    for _ in range(rng.randint(2, 12)):
        w = rng.randint(1, min(4, N))
        vs = rng.sample(range(N), w)
        F.append(tuple((v, rng.randint(0, 1)) for v in vs))
    R = rules_of(F)
    for _ in range(20):
        alpha = {v: rng.randint(0, 1) for v in rng.sample(range(N), rng.randint(0, N))}
        for k in (1, 2, 3, None):
            a = up(F, N, alpha, k)
            b = fc(R, N, alpha, k)
            runs += 1
            mism += (a != b)
P(f"  {runs} runs: mismatches={mism}")

P("== C: the chain encoding written as directed rules")
for m in range(4, 8):
    F, naux = chain_encoding(list(range(m)), 0, m)
    N = m + naux
    R = rules_of(F)
    sols = [x for x in range(1 << m) if popcount(x) % 2 == 0]
    ok, nq, fail = True, 0, None
    for al in all_partial_assignments(m):
        imp = law_implied(sols, m, al)
        if imp is None or not imp:
            continue
        a = fc(R, N, al)
        nq += len(imp)
        if a is None or any(a[v] != s for v, s in imp):
            ok = False
            break
    P(f"  m={m}: clauses={len(F)}, rules={len(R)} (3(4m-6)-2={3*(4*m-6)-2}); max clause width={max(len(C) for C in F)}; "
      f"forward chaining usable={ok} ({nq} entailed literals); no-aux rules m 2^(m-1)={m * 2 ** (m - 1)}")

P("== D: the decider of PI(S): C in PI iff the derived equations supported in supp(C) are exactly {0, 1_supp(C)} "
  "and the falsifying assignment violates 1_supp(C)")


def decide_pi(law_rows_aug, m, C):
    """Polynomial-time decider: rows of [A|b] (aug ints, bit m = constant). C clause (literals)."""
    T = 0
    beta = {}
    for v, s in C:
        T |= 1 << v
        beta[v] = 1 - s
    # derived equations supported in T: combinations y of rows with (yA) zero outside T.
    # Gaussian elimination: project rows to coordinates outside T, find kernel combinations.
    rows = law_rows_aug
    outside = ((1 << m) - 1) & ~T
    # build vectors: (projection outside T) with tag bits recording which rows were combined
    k = len(rows)
    vecs = [((r & outside), 1 << i) for i, r in enumerate(rows)]
    basis = []
    kernel = []
    for proj, tag in vecs:
        for (p, bp, tp) in basis:
            if proj >> p & 1:
                proj ^= bp
                tag ^= tp
        if proj:
            basis.append((proj.bit_length() - 1, proj, tag))
        else:
            kernel.append(tag)
    # kernel combos give derived equations supported in T; their span must be {0, u} with supp(u) = T
    eqs = set()
    combos = [0]
    for t in kernel:
        combos += [c ^ t for c in combos]
    for cmb in combos:
        v = 0
        for i in range(k):
            if cmb >> i & 1:
                v ^= rows[i]
        eqs.add(v)
    us = {v & ((1 << m) - 1): v >> m for v in eqs}
    nz = [u for u in us if u]
    if len(nz) != 1 or nz[0] != T:
        return False
    cu = us[T]
    par = sum(beta.values()) % 2
    return par != cu


agree = tot = 0
for trial in range(30):
    m = rng.choice([6, 7, 8])
    k = rng.choice([2, 3, 4])
    eqs = random_system(rng, m, k)
    law = AffineLaw(m, eqs)
    pis = set(map(frozenset, prime_implicates_bruteforce(law.sols, m)))
    aug = [r | (c << m) for r, c in eqs]
    for _ in range(300):
        w = rng.randint(1, m)
        vs = rng.sample(range(m), w)
        C = tuple((v, rng.randint(0, 1)) for v in vs)
        tot += 1
        agree += (decide_pi(aug, m, C) == (frozenset(C) in pis))
    for C in list(pis)[:50]:
        tot += 1
        agree += decide_pi(aug, m, tuple(C))
P(f"  {tot} clauses (random and prime) on 30 random laws: decider agrees with brute force in {agree}")
P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
