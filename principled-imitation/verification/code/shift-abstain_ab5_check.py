"""Independent check of Theorem 7.6, Corollary 7.7 and Example 7.9 of proofs/shift-abstain.md
(the batch rule Bat_eps; Proposition Ab5 of the note).

Written by the referee of Ab5, without using the lead's script proofs/code/shift-abstain_batch_rule.py.
Exact arithmetic (fractions) is used for eps*m, so that the strict inequality "> eps*m" of the rule
is decided exactly.

Parts.
 (1) Items 1 and 2, exhaustive: every class of 2 to 4 functions among the 8 binary functions on
     3 inputs and among the 9 ternary functions on 2 inputs, every human in the class, every set of
     asked inputs, every batch of length 1 to 6 (as a multiset: the rule depends only on the counts),
     nine values of eps.  Checked: at most eps*m wrong answers; T < 1/eps, T <= m, T <= |V| - 1;
     refused indices = those in R(z); for eps*m < 1 the rule is the unanimity rule.  On every fifth
     instance also with every member of V in the place of h and with three ways of choosing c (first,
     last, largest count): the order of H_b is not used by items 1 and 2.
 (2) Item 3, exact: classes of 2 (b = 1) and 4 (b = 2) binary functions on 3 or 4 inputs, laws P on a
     grid (some of them sub-probabilities), n = 1..12, four values of delta.  Pr[not E] is computed
     exactly by inclusion-exclusion over the set of asked inputs and compared with delta/2; on every
     asked set in E, every batch of length <= 5 and every eps of the grid, P(R(z)) <= T*gamma < gamma/eps.
 (3) Item 4, exact (multinomial enumeration of the batch): Pr[T >= 1] against delta' when
     p_c <= eps/e^2 and eps*m >= b ln 2 + ln(1/delta'); and what happens without eps >= e^2*gamma.
 (4) Item 6(b), exact (inclusion-exclusion over the members that are wrong at more than eps*m indices).
 (5) Corollary 7.7: the arithmetic, and the range of the balanced choice eps = sqrt(gamma).
 (6) Example 7.9(a) exhaustive on N = 10 thresholds; (b) by simulation; (c) exact construction with a
     seed different from the lead's, and the soundness of the input-by-input rule, exhaustive on small
     ordered streams.
 (7) Remark 7.10(a): the law of the asked calls when the inputs of a run do not depend on the answers;
     the expected number of calls of a fresh run in R(z); and a batch made of r runs: item 4 needs
     eps*r (runs), not eps*m (calls), to be large.

Run:  python3 shift-abstain_ab5_check.py   (a few minutes; fixed seeds)
"""
import itertools
import math
import random
from fractions import Fraction as Fr

EPS_GRID = [Fr(1), Fr(3, 4), Fr(1, 2), Fr(2, 5), Fr(1, 3), Fr(1, 4), Fr(1, 5), Fr(1, 6), Fr(1, 7)]


def bat_counts(V, h, cnt, eps, choose="first"):
    """Bat_eps on a batch given by its counts cnt[x].  V: list of functions (tuples), h in V.
    Returns (remaining set of inputs, list of chosen members)."""
    X = range(len(cnt))
    m = sum(cnt)
    rem = set(x for x in X if cnt[x] > 0)
    chosen = []
    while True:
        cands = []
        for c in V:
            k = sum(cnt[x] for x in rem if c[x] != h[x])
            if k > eps * m:
                cands.append((k, c))
        if not cands:
            break
        if choose == "first":
            k, c = cands[0]
        elif choose == "last":
            k, c = cands[-1]
        else:
            k, c = max(cands, key=lambda t: t[0])
        chosen.append(c)
        rem = set(x for x in rem if c[x] == h[x])
    return rem, chosen


def multisets(nx, mmax):
    for m in range(1, mmax + 1):
        for comb in itertools.combinations_with_replacement(range(nx), m):
            cnt = [0] * nx
            for x in comb:
                cnt[x] += 1
            yield cnt


def part1():
    print("(1) items 1 and 2, exhaustive")
    total = viol = unan = alt = 0
    worst = Fr(0)
    maxT = 0
    for nx, ny in ((3, 2), (2, 3)):
        F = list(itertools.product(range(ny), repeat=nx))
        batches = list(multisets(nx, 6))
        inst = 0
        for size in (2, 3, 4):
            for H in itertools.combinations(F, size):
                for f in H:
                    for r in range(nx + 1):
                        for A in itertools.combinations(range(nx), r):
                            V = [c for c in H if all(c[x] == f[x] for x in A)]
                            inst += 1
                            hs = [V[0]] if inst % 5 else V
                            rules = ["first"] if inst % 5 else ["first", "last", "max"]
                            for h in hs:
                                for rule in rules:
                                    for cnt in batches:
                                        m = sum(cnt)
                                        for eps in EPS_GRID:
                                            rem, ch = bat_counts(V, h, cnt, eps, rule)
                                            T = len(ch)
                                            wrong = sum(cnt[x] for x in rem if h[x] != f[x])
                                            R = set(x for x in range(nx) if any(c[x] != h[x] for c in ch))
                                            refused = set(x for x in range(nx) if cnt[x] > 0) - rem
                                            ok = (wrong <= eps * m and T * eps < 1 and T <= m
                                                  and T <= len(V) - 1
                                                  and refused == set(x for x in R if cnt[x] > 0))
                                            if eps * m < 1:
                                                unan += 1
                                                un = set(x for x in range(nx) if cnt[x] > 0
                                                         and all(c[x] == V[0][x] for c in V))
                                                ok = ok and rem == un and wrong == 0
                                            if h is not V[0] or rule != "first":
                                                alt += 1
                                            viol += 0 if ok else 1
                                            total += 1
                                            if eps * m > 0:
                                                worst = max(worst, Fr(wrong) / (eps * m))
                                            maxT = max(maxT, T)
        print(f"    |X|={nx}, |Y|={ny}: {inst} (class, human, asked set) instances")
    print(f"    (instance, h, rule, batch, eps) cases: {total}; of them with eps*m < 1: {unan};"
          f" with another h or another choice of c: {alt}")
    print(f"    violations: {viol}; largest wrong/(eps*m): {float(worst):.4f}; largest T: {maxT}")


def prob_hit_sets(p, p0, n):
    """Exact law of the set U of distinct asked inputs after n rounds; p0 = mass of 'no question'."""
    nx = len(p)
    out = {}
    for r in range(nx + 1):
        for U in itertools.combinations(range(nx), r):
            s = 0.0
            for k in range(len(U) + 1):
                for W in itertools.combinations(U, k):
                    s += (-1) ** (len(U) - k) * (p0 + sum(p[x] for x in W)) ** n
            out[U] = max(s, 0.0)
    return out


def part2():
    print("(2) item 3, exact")
    rnd = random.Random(7)
    worst_ratio = 0.0
    viol_event = viol_mass = nbatch = ninst = with_bad = gamma_lt1 = subprob = 0
    for trial in range(120):
        nx = rnd.choice([3, 4])
        F = list(itertools.product((0, 1), repeat=nx))
        b = rnd.choice([1, 2])
        H = rnd.sample(F, 2 ** b)
        f = rnd.choice(H)
        w = [rnd.randint(1, 6) for _ in range(nx)]
        p0 = rnd.choice([0.0, 0.0, 0.2])
        p = [(1 - p0) * wi / sum(w) for wi in w]
        n = rnd.randint(1, 12)
        delta = rnd.choice([0.9, 0.5, 0.25, 0.1])
        gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
        gamma_lt1 += gamma < 1
        subprob += p0 > 0
        law = prob_hit_sets(p, p0, n)
        assert abs(sum(law.values()) - 1) < 1e-9

        def mass(c, d):
            return sum(p[x] for x in range(nx) if c[x] != d[x])
        bad = 0.0
        for U, pr in law.items():
            inE = all(mass(c, d) <= gamma for c, d in itertools.combinations(H, 2)
                      if all(c[x] == d[x] for x in U))
            if not inE:
                bad += pr
                continue
            V = [c for c in H if all(c[x] == f[x] for x in U)]
            for cnt in multisets(nx, 5):
                for eps in EPS_GRID:
                    rem, ch = bat_counts(V, V[0], cnt, eps)
                    R = set(x for x in range(nx) if any(c[x] != V[0][x] for c in ch))
                    PR = sum(p[x] for x in R)
                    nbatch += 1
                    if not (PR <= len(ch) * gamma + 1e-12 and (PR < gamma / float(eps) or PR == 0)):
                        viol_mass += 1
        ninst += 1
        with_bad += bad > 0
        viol_event += bad >= delta / 2
        worst_ratio = max(worst_ratio, bad / delta)
    print(f"    instances {ninst} (gamma < 1 in {gamma_lt1}; sub-probability P in {subprob});"
          f" Pr[not E] > 0 in {with_bad}")
    print(f"    Pr[not E] >= delta/2 in {viol_event}; largest Pr[not E]/delta: {worst_ratio:.4f}")
    print(f"    (asked set, batch, eps) cases on E: {nbatch}; violations of P(R) <= T*gamma < gamma/eps: {viol_mass}")


def multinomial_counts(m, k):
    if k == 1:
        yield (m,)
        return
    for i in range(m + 1):
        for rest in multinomial_counts(m - i, k - 1):
            yield (i,) + rest


def log_multinom(m, cnt):
    return math.lgamma(m + 1) - sum(math.lgamma(c + 1) for c in cnt)


def part3():
    print("(3) item 4, exact over the batch")
    # X = {0,1,2}; h = 000; V = {h, c1 = 010, c2 = 001, c3 = 011}; b = 2 (|H_b| <= 4).
    b = 2
    for a, eps, dprime in ((0.004, Fr(1, 10), 0.1), (0.002, Fr(1, 20), 0.05), (0.002, Fr(3, 100), 0.3)):
        p = [1 - 2 * a, a, a]
        pc = {"010": a, "001": a, "011": 2 * a}
        assert max(pc.values()) <= float(eps) / math.e ** 2
        mmin = math.ceil((b * math.log(2) + math.log(1 / dprime)) / float(eps))
        for m in (mmin, 2 * mmin):
            pT = 0.0
            pc_over = {k: 0.0 for k in pc}
            for cnt in multinomial_counts(m, 3):
                lp = log_multinom(m, cnt) + sum(c * math.log(q) for c, q in zip(cnt, p) if c)
                pr = math.exp(lp)
                N = {"010": cnt[1], "001": cnt[2], "011": cnt[1] + cnt[2]}
                over = [k for k in N if N[k] > eps * m]
                for k in over:
                    pc_over[k] += pr
                if over:
                    pT += pr
            print(f"    a={a} eps={float(eps)} delta'={dprime} m={m}: Pr[T>=1]={pT:.3e}"
                  f" (bound 3*e^(-eps*m)={3 * math.exp(-float(eps) * m):.3e}, delta'={dprime});"
                  f" largest Pr[N_c > eps*m]={max(pc_over.values()):.3e} <= e^(-eps*m)={math.exp(-float(eps) * m):.3e}")
    # without eps >= e^2 * p_c: p_c = eps/2
    eps = Fr(1, 10)
    a = 0.05
    p = [1 - a, a, 0.0]
    for m in (60, 200):
        pT = 0.0
        for k1 in range(m + 1):
            if k1 > eps * m:
                pT += math.comb(m, k1) * a ** k1 * (1 - a) ** (m - k1)
        print(f"    hypothesis dropped (p_c = eps/2 = {a}): m={m}, eps*m={float(eps * m):.0f}:"
              f" Pr[T>=1] = {pT:.3e} (small only through the exponent m*kl(eps||p_c)={m * (0.1 * math.log(2) + 0.9 * math.log(0.9 / 0.95)):.2f})")


def part4():
    print("(4) item 6(b), exact")
    rnd = random.Random(11)
    worst = 0.0
    viol = ncase = 0
    for trial in range(400):
        nx = 4
        F = list(itertools.product((0, 1), repeat=nx))
        b = rnd.choice([1, 2, 3])
        H = rnd.sample(F, 2 ** b)
        f = rnd.choice(H)
        m = rnd.randint(1, 12)
        z = [rnd.randrange(nx) for _ in range(m)]
        eps = rnd.choice([Fr(1, 2), Fr(1, 3), Fr(1, 4), Fr(1, 5), Fr(1, 10)])
        dpp = rnd.choice([0.5, 0.2, 0.05])
        q = math.ceil((b * math.log(2) + math.log(1 / dpp)) / float(eps))
        badc = [c for c in H if sum(c[z[j]] != f[z[j]] for j in range(m)) > eps * m]
        agree = [set(j for j in range(m) if c[z[j]] == f[z[j]]) for c in badc]
        pr = 0.0
        for k in range(1, len(badc) + 1):
            for S in itertools.combinations(range(len(badc)), k):
                inter = set(range(m))
                for i in S:
                    inter &= agree[i]
                pr += (-1) ** (k + 1) * (len(inter) / m) ** q
        ncase += 1
        viol += pr >= dpp
        worst = max(worst, pr / dpp)
    print(f"    cases {ncase}; Pr[some member wrong at > eps*m batch inputs survives] >= delta'' in {viol};"
          f" largest ratio to delta'': {worst:.4f}")


def part5():
    print("(5) Corollary 7.7")
    for b, delta in ((10, 0.1), (100, 0.01), (1, 0.5)):
        A = 2 * b * math.log(2) + math.log(1 / delta)
        for eps, epsp in ((0.1, 0.1), (0.05, 0.2), (1.0, 0.01)):
            n = A / (eps * epsp)
            gamma = A / n
            assert gamma / eps <= epsp * (1 + 1e-12)
        nmin_bal = A  # eps = sqrt(gamma) <= 1 needs n >= A
        print(f"    b={b} delta={delta}: gamma/eps <= eps' holds at n = (2b ln2 + ln 1/delta)/(eps eps');"
              f" the balanced eps = sqrt(gamma) is in (0,1] only if n >= {nmin_bal:.2f}")


def part6():
    print("(6) Example 7.9")
    # (a) thresholds 1[x <= i], i = 0..N, on {1..N}; questions from {1..N/2}; human threshold > N/2.
    N = 10
    X = list(range(1, N + 1))
    H = [tuple(1 if x <= i else 0 for x in X) for i in range(N + 1)]
    cases = refused_all = contains = nsamp = 0
    for i_h in range(N // 2 + 1, N + 1):
        f = H[i_h]
        for n in range(0, 5):
            for A in itertools.product(range(1, N // 2 + 1), repeat=n):
                V = [c for c in H if all(c[x - 1] == f[x - 1] for x in A)]
                nsamp += 1
                contains += all(H[i] in V for i in range(N // 2, N + 1))
                for zz in range(N // 2 + 1, N + 1):
                    for m in (1, 3, 7):
                        cnt = [0] * N
                        cnt[zz - 1] = m
                        for eps in EPS_GRID[1:]:
                            rem, ch = bat_counts(V, V[0], cnt, eps)
                            cases += 1
                            refused_all += (len(rem) == 0)
    print(f"    (a) N={N}: V contains all thresholds N/2..N for {contains} of {nsamp} (human, sample) pairs;"
          f" batches of copies of z > N/2 refused entirely in {refused_all} of {cases} cases (eps < 1)")
    # (b) blocks
    rnd = random.Random(23)
    Nb, L, n, eps = 300, 10, 60, 0.1
    refused_one = 0
    trials = 1000
    unasked_frac = 0.0
    for t in range(trials):
        asked = set(rnd.randrange(Nb) for _ in range(n))  # block of each question (P uniform on X)
        unasked_frac += (Nb - len(asked)) / Nb
        blk = rnd.randrange(Nb)
        # batch = one run: L calls in block blk; c_blk in V iff blk unasked; it differs from h at all L > eps*L
        refused_one += blk not in asked
    print(f"    (b) {Nb} blocks, L={L}, n={n}: one-run batches refused entirely in {refused_one}/{trials}"
          f" (mean fraction of unasked blocks {unasked_frac / trials:.3f})")
    r = 400
    asked = set(rnd.randrange(Nb) for _ in range(n))
    runs = [rnd.randrange(Nb) for _ in range(r)]
    mult = {}
    for x in runs:
        mult[x] = mult.get(x, 0) + 1
    T_any = any(mult[x] * L > eps * r * L for x in mult if x not in asked)
    worst_wrong = max(mult[x] * L for x in mult if x not in asked)
    print(f"    (b) batch of {r} runs: largest multiplicity of a block {max(mult.values())} <= eps*r = {eps * r:.0f};"
          f" a step is made: {T_any}; worst wrong answers if the human were c_i: {worst_wrong} <= eps*m = {eps * r * L:.0f}")
    # (c) exact construction
    rnd = random.Random(99)
    Nc, n, m, eps = 1000, 100, 2000, Fr(1, 20)
    k0 = int(eps * m)
    asked = set(rnd.randrange(1, Nc + 1) for _ in range(n))
    draws = [rnd.randrange(1, Nc + 1) for _ in range(m - k0)]
    stream = [0] * k0 + draws
    Vc = [i for i in range(1, Nc + 1) if i not in asked]  # c_i in V, Delta(c_i) = {0, i}
    count = {i: 0 for i in Vc}
    Vset = set(Vc)
    answered = refused = 0
    zero_reached = False
    for x in stream:
        disputers = list(Vset) if x == 0 else ([x] if x in Vset else [])
        if any(count[i] >= int(eps * m) for i in disputers):
            refused += 1
        else:
            answered += 1
            for i in disputers:
                count[i] += 1
    ref_draws = sum(1 for x in draws if x in Vset)
    # batch rule on the same multiset, with the first such member in the order i = 1..N
    occ = {}
    for x in draws:
        occ[x] = occ.get(x, 0) + 1
    rem0, steps, refused_batch = k0, 0, 0
    chosen = None
    for i in sorted(Vc):
        if rem0 + occ.get(i, 0) > eps * m:
            chosen = i
            break
    if chosen is not None:
        steps = 1
        refused_batch = k0 + occ.get(chosen, 0)
        # after removing 0 and `chosen`, no other c_j exceeds eps*m (hypothesis: occurrences <= eps*m)
        assert all(occ.get(j, 0) <= eps * m for j in Vc if j != chosen)
    print(f"    (c) N={Nc}, n={n}, m={m}, eps={float(eps)}: input-by-input rule answered {answered}, refused {refused};"
          f" refused draws {ref_draws} of {m - k0} (all unasked ones; P-mass of unasked inputs {len(Vc) / Nc:.3f});"
          f" batch rule: T={steps}, refused {refused_batch} (= {k0} copies of 0 + {refused_batch - k0})")
    # soundness of the input-by-input rule, exhaustive on ordered streams
    viol = cases = 0
    F = list(itertools.product((0, 1), repeat=3))
    for H3 in itertools.combinations(F, 3):
        for f in H3:
            for A in ((), (0,), (1, 2)):
                V = [c for c in H3 if all(c[x] == f[x] for x in A)]
                h = V[0]
                for mm in range(1, 6):
                    for z in itertools.product(range(3), repeat=mm):
                        for e in (Fr(1, 2), Fr(1, 3), Fr(1, 5), Fr(1)):
                            budget = int(e * mm)
                            cnt = {c: 0 for c in V}
                            wrong = 0
                            for x in z:
                                disp = [c for c in V if c[x] != h[x]]
                                if any(cnt[c] >= budget for c in disp):
                                    continue
                                for c in disp:
                                    cnt[c] += 1
                                wrong += h[x] != f[x]
                            cases += 1
                            viol += wrong > budget
    print(f"    (c) input-by-input rule, exhaustive ordered streams: {cases} cases, more than floor(eps*m) wrong in {viol}")


def part7():
    print("(7) Remark 7.10(a): runs whose inputs do not depend on the answers")
    rnd = random.Random(5)
    # scaffold: z uniform on {0..9}; the run has len = 1 + (z mod 4) calls at inputs (z + j) mod 12, j < len
    L = 4
    nX = 12
    PPi = [0.0] * nX
    for z in range(10):
        for j in range(1 + z % 4):
            PPi[(z + j) % nX] += 1 / (10 * L)
    tot = sum(PPi)
    rounds = 200000
    emp = [0] * nX
    none = 0
    for t in range(rounds):
        z = rnd.randrange(10)
        J = rnd.randrange(1, L + 1)
        ln = 1 + z % 4
        if J <= ln:
            emp[(z + J - 1) % nX] += 1
        else:
            none += 1
    dev = max(abs(emp[x] / rounds - PPi[x]) for x in range(nX))
    print(f"    law of the asked call: total mass of P_Pi {tot:.4f}, empirical no-question frequency {none / rounds:.4f};"
          f" largest |empirical - P_Pi| over inputs {dev:.4f}")
    # batch of r runs, each of exactly L calls, all in one block: item 4 with m = r*L calls is not enough
    b = 1
    dprime = 0.01
    pblock = 0.002          # P_Pi(Delta(c)) = gamma, allowed on E
    eps = math.e ** 2 * pblock
    Lr = 20
    r = int(1 / (2 * eps))  # eps*r < 1
    m = r * Lr
    pr_refuse = 1 - (1 - pblock) ** r
    print(f"    one member c with P_Pi(Delta(c)) = {pblock} (= gamma), eps = e^2*gamma = {eps:.4f}, runs of L = {Lr} calls"
          f" entirely in Delta(c) or outside it, r = {r} runs:")
    print(f"      eps*m = {eps * m:.1f} >= b ln2 + ln(1/delta') = {b * math.log(2) + math.log(1 / dprime):.2f},"
          f" yet Pr[something refused] = {pr_refuse:.4f} > delta' = {dprime}")
    rr = math.ceil((b * math.log(2) + math.log(1 / dprime)) / eps)
    pr2 = sum(math.comb(rr, k) * pblock ** k * (1 - pblock) ** (rr - k) for k in range(rr + 1) if k > eps * rr)
    print(f"      with r = {rr} runs (eps*r >= b ln2 + ln(1/delta')): Pr[something refused] = {pr2:.2e} <= delta'")


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
    part5()
    part6()
    part7()
