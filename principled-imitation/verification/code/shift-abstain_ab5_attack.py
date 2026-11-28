#!/usr/bin/env python3
"""Adversarial checks of Theorem 7.6 (Ab5) of proofs/shift-abstain.md.

Written independently of proofs/code/shift-abstain_batch_rule.py (not read).
Parts:
  A  items 1, 2 (and 6(a)) by exhaustive search at the level of disagreement masks:
     every ordered list V of up to 4 members on 4 inputs (first member h), every
     human f in V, every batch of length <= 6 (as multiplicities), every threshold
     k = floor(eps*m) in 0..m (this covers every eps in (0,1]).
  A2 independent index-level implementation on real functions (2 or 3 answers),
     real classes, samples, ordered batch sequences and an exact eps grid
     (Fractions, including 1, eps*m integer, eps < 1/m); compared with part A.
  B  item 3: exact probability of the complement of E on small instances
     (probability and sub-probability P, duplicated members), and P(R(z)) <= T*gamma.
  B2 a joint count (tuples instead of pairs) that removes the factor 1/eps from ln(1/delta).
  C  item 4: exact binomial tails at p = eps/e^2; one multinomial instance.
  D  item 6(b): exact failure probability by enumeration of the index draws; and
     whether re-running Bat_eps after the audit still refuses.
  E  fresh input versus the inputs of the batch (point functions).
  F  Example 7.9 (a), (b), (c) recomputed; a better input-by-input rule for (c).
  G  Remark 7.10(a): law of the asked call in Protocol R for a scaffold whose inputs do
     not depend on the answers, runs of different lengths; and an abstaining driver.
  H  Remark 7.10(b): stages; per-run consequence; the rock in rate form (patches).
"""
import itertools, math, random
from fractions import Fraction as Fr

random.seed(20261128)
E2 = math.e ** 2


def bat_mask(V, msum, k):
    """Rule Bat at mask level. V: list of disagreement masks (w.r.t. h=V[0]); msum[mask]
    = number of batch indices with input in mask; k = floor(eps*m): a step needs count > k.
    Returns (Sset, taken list of indices into V)."""
    full = (1 << 4) - 1
    S = full
    taken = []
    while True:
        found = -1
        for i, c in enumerate(V):
            if msum[c & S] > k:
                found = i
                break
        if found < 0:
            return S, taken
        S &= ~V[found]
        taken.append(found)


def part_A():
    print("== A: items 1, 2, 6(a) exhaustively at mask level (4 inputs, |V|<=4, m<=6, all k) ==")
    nX = 4
    batches = []
    for m in range(1, 7):
        for comp in itertools.product(range(m + 1), repeat=nX):
            if sum(comp) == m:
                batches.append(comp)
    msums = []
    for comp in batches:
        ms = [0] * 16
        for mask in range(16):
            ms[mask] = sum(comp[x] for x in range(nX) if mask >> x & 1)
        msums.append(ms)
    viol = {"item1": 0, "T<1/eps": 0, "T<=m": 0, "T<=|V|-1": 0, "T<=distinct": 0,
            "eps*m<1 unanimity": 0, "c taken twice": 0}
    cases = 0
    attained = 0
    maxratio = 0.0
    for LV in range(1, 5):
        for rest in itertools.product(range(16), repeat=LV - 1):
            V = [0] + list(rest)
            distinct = len(set(c for c in V if c))
            union = 0
            for c in V:
                union |= c
            for comp, ms in zip(batches, msums):
                m = sum(comp)
                support = sum(1 << x for x in range(nX) if comp[x])
                for k in range(0, m + 1):
                    S, taken = bat_mask(V, ms, k)
                    T = len(taken)
                    cases += 1
                    for fmask in set(V):
                        wrong = ms[fmask & S]
                        if wrong > k:
                            viol["item1"] += 1
                        if k > 0:
                            r = wrong / k
                            if r > maxratio:
                                maxratio = r
                            if wrong == k:
                                attained += 1
                    # T < 1/eps for every eps with floor(eps m) = k, i.e. eps < (k+1)/m
                    if T * (k + 1) > m:
                        viol["T<1/eps"] += 1
                    if T > m:
                        viol["T<=m"] += 1
                    if T > LV - 1:
                        viol["T<=|V|-1"] += 1
                    if T > distinct:
                        viol["T<=distinct"] += 1
                    if len(set(V[i] for i in taken)) < T:
                        viol["c taken twice"] += 1
                    if k == 0:
                        if (S & support) != (support & ~union):
                            viol["eps*m<1 unanimity"] += 1
    print(f"  (V, batch, k) cases: {cases}; violations: {viol}")
    print(f"  largest ratio wrong/floor(eps m) over k>0: {maxratio:.4f}; cases with equality: {attained}")


# ---------- index-level implementation on real functions ----------

def bat_index(Vf, z, eps):
    """Vf: list of functions (tuples), Vf[0]=h. z: sequence of inputs. eps: Fraction.
    Returns S (set of indices answered), list of taken members, R as a set of inputs."""
    m = len(z)
    h = Vf[0]
    S = set(range(m))
    taken = []
    while True:
        found = None
        for c in Vf:
            cnt = sum(1 for j in S if c[z[j]] != h[z[j]])
            if cnt > eps * m:
                found = c
                break
        if found is None:
            break
        S = {j for j in S if found[z[j]] == h[z[j]]}
        taken.append(found)
    R = set()
    for c in taken:
        R |= {x for x in range(len(h)) if c[x] != h[x]}
    return S, taken, R


def part_A2():
    print("== A2: index-level implementation, real classes, exact eps grid, vs mask level ==")
    grid = sorted(set([Fr(j, 60) for j in range(1, 61)] + [Fr(1, 1)]))
    nviol = 0
    ncases = 0
    mismatch = 0
    for trial in range(1200):
        nX = random.choice([2, 3, 4])
        nY = random.choice([2, 3])
        size = random.randint(1, 4)
        allf = list(itertools.product(range(nY), repeat=nX))
        cls = [random.choice(allf) for _ in range(size)]
        if size >= 2 and random.random() < 0.3:
            cls[random.randrange(size)] = cls[0]  # duplicate members
        f = random.choice(cls)
        asked = [x for x in range(nX) if random.random() < 0.4]
        Vf = [c for c in cls if all(c[x] == f[x] for x in asked)]
        h = Vf[0]
        masks = [sum(1 << x for x in range(nX) if c[x] != h[x]) for c in Vf]
        for _ in range(12):
            m = random.randint(1, 6)
            z = [random.randrange(nX) for _ in range(m)]
            eps_list = grid + [Fr(1, m) - Fr(1, 1000), Fr(1, m)] + [Fr(i, m) for i in range(1, m + 1)]
            ms = [0] * 16
            for mask in range(16):
                ms[mask] = sum(1 for x in z if mask >> x & 1)
            for eps in eps_list:
                if eps <= 0 or eps > 1:
                    continue
                ncases += 1
                S, taken, R = bat_index(Vf, z, eps)
                wrong = sum(1 for j in S if h[z[j]] != f[z[j]])
                T = len(taken)
                bad = False
                if wrong > eps * m:
                    bad = True
                if not (T * eps < 1 and T <= m and T <= len(Vf) - 1):
                    bad = True
                if set(range(m)) - S != {j for j in range(m) if z[j] in R}:
                    bad = True
                if eps * m < 1:
                    unan = {j for j in range(m) if all(c[z[j]] == h[z[j]] for c in Vf)}
                    if S != unan:
                        bad = True
                if T == 0 and wrong > eps * m:
                    bad = True
                nviol += bad
                # compare with mask level
                k = math.floor(eps * m)
                Smask, tk = bat_mask(masks + [], ms, k) if nX <= 4 else (None, None)
                ans_mask = {j for j in range(m) if Smask >> z[j] & 1}
                if ans_mask != S or len(tk) != T:
                    mismatch += 1
    print(f"  cases (instance, batch, eps): {ncases}; violations of items 1, 2, R-description, eps*m<1: {nviol}; "
          f"disagreements with mask level: {mismatch}")


# ---------- item 3 ----------

def part_B():
    print("== B: item 3, exact over all samples ==")
    worst = 0.0
    nchecks = 0
    viol_prob = 0
    viol_mass = 0
    for inst in range(260):
        nX = random.choice([2, 3, 4])
        nY = random.choice([2, 3])
        size = random.choice([2, 3, 4])
        allf = list(itertools.product(range(nY), repeat=nX))
        cls = [random.choice(allf) for _ in range(size)]
        if random.random() < 0.3:
            cls[-1] = cls[0]
        b = math.log2(size)  # uniform weights 1/size
        w = [random.random() for _ in range(nX)]
        sub = random.choice([1.0, 1.0, 0.7, 0.4])  # total mass of P
        P = [sub * wi / sum(w) for wi in w]
        n = random.choice([2, 3, 4, 5, 6])
        outcomes = list(range(nX)) + [None]
        probs = P + [1 - sum(P)]
        # law of the asked set
        law = {}
        for seq in itertools.product(range(nX + 1), repeat=n):
            p = 1.0
            for o in seq:
                p *= probs[o]
            if p == 0:
                continue
            A = frozenset(o for o in seq if o < nX)
            law[A] = law.get(A, 0) + p
        pairs = [(i, j) for i in range(size) for j in range(i + 1, size)]
        dmass = {(i, j): sum(P[x] for x in range(nX) if cls[i][x] != cls[j][x]) for (i, j) in pairs}
        for delta in [0.9, 0.5, 0.2, 0.05]:
            gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
            bad = [pr for pr in pairs if dmass[pr] > gamma]
            pfail = sum(p for A, p in law.items()
                        if any(all(cls[i][x] == cls[j][x] for x in A) for (i, j) in bad))
            nchecks += 1
            if pfail >= delta / 2 and pfail > 0:
                viol_prob += 1
            worst = max(worst, pfail / (delta / 2))
            # on E (for delta = 0.5 only): each human, batch (multiplicities m<=3), k: P(R) <= T gamma
            if delta != 0.5:
                continue
            for A, p in law.items():
                if any(all(cls[i][x] == cls[j][x] for x in A) for (i, j) in bad):
                    continue
                for f in set(cls):
                    Vf = [c for c in cls if all(c[x] == f[x] for x in A)]
                    h = Vf[0]
                    for m in range(1, 4):
                        for z in itertools.combinations_with_replacement(range(nX), m):
                            for kk in range(m + 1):
                                eps = Fr(kk, m) if kk > 0 else Fr(1, 2 * m)
                                S, taken, R = bat_index(Vf, list(z), eps)
                                PR = sum(P[x] for x in R)
                                if PR > len(taken) * gamma + 1e-12 or (PR >= gamma / float(eps) and PR > 0):
                                    viol_mass += 1
    print(f"  instances x delta: {nchecks}; cases with Pr[not E] >= delta/2: {viol_prob}; "
          f"largest Pr[not E]/(delta/2): {worst:.4f}; violations of P(R) <= T*gamma < gamma/eps on E: {viol_mass}")


def part_B2():
    print("== B2: joint count over tuples (h, c_1..c_T), T < 1/eps ==")
    # Pr[some tuple of <= Tmax+1 consistent members with union of disagreement mass > rho] <= delta
    # with rho = ((Tmax+1)*b*ln2 + ln(2/delta))/n  (|H_b|>=2). Exact check on small instances.
    worst = 0.0
    nchk = 0
    for inst in range(150):
        nX = random.choice([3, 4])
        size = random.choice([3, 4])
        allf = list(itertools.product(range(2), repeat=nX))
        cls = [random.choice(allf) for _ in range(size)]
        b = math.log2(size)
        w = [random.random() for _ in range(nX)]
        P = [wi / sum(w) for wi in w]
        n = random.choice([4, 5, 6])
        law = {}
        for seq in itertools.product(range(nX), repeat=n):
            p = 1.0
            for o in seq:
                p *= P[o]
            A = frozenset(seq)
            law[A] = law.get(A, 0) + p
        for eps in [Fr(1, 2), Fr(1, 3)]:
            Tmax = math.ceil(1 / eps) - 1
            for delta in [0.9, 0.5]:
                rho = ((Tmax + 1) * b * math.log(2) + math.log(2 / delta)) / n
                pfail = 0.0
                for A, p in law.items():
                    # any tuple of members that agree with each other on A (they all agree with f)
                    # failure if exists h' and c's in one agreement class with union mass > rho
                    fail = False
                    for hi in range(size):
                        agree = [c for c in cls if all(c[x] == cls[hi][x] for x in A)]
                        for T in range(1, Tmax + 1):
                            for tup in itertools.combinations(agree, T):
                                U = {x for c in tup for x in range(nX) if c[x] != cls[hi][x]}
                                if sum(P[x] for x in U) > rho:
                                    fail = True
                    if fail:
                        pfail += p
                nchk += 1
                worst = max(worst, pfail / delta)
    print(f"  checks: {nchk}; largest Pr[failure]/delta: {worst:.4f} (must be < 1)")
    print("  price comparison, b = 30, delta = 0.05, eps' = 0.01: n(lead) = (2b ln2 + ln(1/d))/(eps eps'),"
          " n(joint) = ((1/eps+1) b ln2 + ln(2/d))/eps'")
    b, d, e2 = 30, 0.05, 0.01
    for eps in [1.0, 0.5, 0.1, 0.01]:
        Tm1 = math.ceil(1 / eps)
        nl = (2 * b * math.log(2) + math.log(1 / d)) / (eps * e2)
        nj = (Tm1 * b * math.log(2) + math.log(2 / d)) / e2
        print(f"    eps={eps:<5} n(lead)={nl:12.0f}  n(joint)={nj:12.0f}  ratio={nl/nj:.3f}")


# ---------- item 4 ----------

def binom_tail_gt(m, p, t):
    """Pr[Bin(m,p) > t]"""
    s = 0.0
    for j in range(math.floor(t) + 1, m + 1):
        s += math.comb(m, j) * p ** j * (1 - p) ** (m - j)
    return s


def part_C():
    print("== C: item 4, exact binomial tails at p = eps/e^2 ==")
    worst = 0.0
    for m in list(range(1, 200)) + [300, 400]:
        for eps in [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 0.9, 0.99]:
            p = eps / E2
            tail = binom_tail_gt(m, p, eps * m)
            worst = max(worst, tail / math.exp(-eps * m))
    print(f"  largest Pr[N_c > eps m] / exp(-eps m): {worst:.4f} (must be <= 1)")
    print(f"  e^2 = {E2:.4f}; the note's 7.4 >= e^2: {7.4 >= E2}")
    # a multinomial instance: V = h + 3 members with disjoint Delta of mass eps/e^2 each
    eps, b, dp = 0.2, 2.0, 0.3
    m = math.ceil((b * math.log(2) + math.log(1 / dp)) / eps)
    p = eps / E2
    probs = [p, p, p, 1 - 3 * p]
    tot = 0.0
    for a in range(m + 1):
        for bb in range(m + 1 - a):
            for c in range(m + 1 - a - bb):
                d = m - a - bb - c
                pr = math.factorial(m) / (math.factorial(a) * math.factorial(bb) * math.factorial(c) * math.factorial(d))
                pr *= probs[0] ** a * probs[1] ** bb * probs[2] ** c * probs[3] ** d
                if max(a, bb, c) > eps * m:
                    tot += pr
    print(f"  multinomial: eps={eps}, b={b}, delta'={dp}, m={m}: Pr[T>0] = {tot:.5f} < delta' = {dp}: {tot < dp}")


# ---------- item 6(b) ----------

def part_D():
    print("== D: item 6(b), exact over the index draws ==")
    worst = 0.0
    nchk = 0
    rerun_refuses = None
    for inst in range(150):
        nX = 4
        nY = random.choice([2, 3])
        allf = list(itertools.product(range(nY), repeat=nX))
        size = 4
        cls = [random.choice(allf) for _ in range(size)]
        f = random.choice(cls)
        b = 2.0
        m = random.randint(2, 6)
        z = [random.randrange(nX) for _ in range(m)]
        for eps in [Fr(1, 6), Fr(1, 3), Fr(1, 2)]:
            for q in [1, 2, 3, 4]:
                if m ** q > 50000:
                    continue
                dpp = 2 ** b * math.exp(-float(eps) * q)  # delta'' with q = (b ln2 + ln 1/delta'')/eps
                fail = 0
                for idx in itertools.product(range(m), repeat=q):
                    newA = {z[j] for j in idx}
                    cons = [c for c in cls if all(c[x] == f[x] for x in newA)]
                    if any(sum(1 for x in z if c[x] != f[x]) > eps * m for c in cons):
                        fail += 1
                    # after the audit: re-run Bat_eps with the new data
                    if rerun_refuses is None and not any(sum(1 for x in z if c[x] != f[x]) > eps * m for c in cons):
                        S, taken, R = bat_index(cons, z, eps)
                        if taken:
                            rerun_refuses = (cls, f, z, eps, sorted(newA), len(S))
                pf = fail / m ** q
                nchk += 1
                if dpp < 1:
                    worst = max(worst, pf / dpp)
    print(f"  checks: {nchk}; largest Pr[failure]/delta'' (delta''<1): {worst:.4f} (must be < 1)")
    if rerun_refuses:
        cls, f, z, eps, A, s = rerun_refuses
        print(f"  after a successful audit, Bat_eps re-run on the new data can still refuse: class={cls}, f={f}, "
              f"batch={z}, eps={eps}, audited inputs={A}, answered after re-run={s}/{len(z)}")


def part_D2():
    print("== D2: item 6(b) needs indices drawn uniformly from 1..m, not distinct inputs ==")
    # batch: input 0 fifty times, inputs 1..50 once each; f = 0 everywhere; c = 1 at input 0 only
    m, eps, b, delta = 100, 0.1, 2.0, 0.1
    q = math.ceil((b * math.log(2) + math.log(1 / delta)) / eps)
    p_idx = (1 - 50 / m) ** q          # c survives q index draws
    p_dst = (1 - 1 / 51) ** q          # c survives q draws among the 51 distinct inputs
    print(f"  m={m}, eps={eps}, b={b}, delta={delta}, q={q}: c differs from f at 50 > eps*m indices; "
          f"Pr[c survives] with index draws {p_idx:.2e}, with draws of distinct inputs {p_dst:.3f} (> delta)")


# ---------- fresh input versus batch inputs ----------

def part_E():
    print("== E: refused mass for a fresh input versus refused share of a batch drawn from P ==")
    b = 20
    N = 2 ** b - 1  # point functions c_i = 1[x=i], plus h = 0 (the human); 2^b members
    n, delta = 10000, 0.1
    gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
    print(f"  N={N}, n={n}, delta={delta}: gamma={gamma:.5f}; every pair differs on mass <= 2/N, so E holds surely")
    for trial in range(2):
        asked = set(random.randrange(N) for _ in range(n))
        for (m, eps) in [(1, 0.5), (10, 0.05), (1000, 0.01)]:
            reps = 200
            ref = 0
            freshref = 0.0
            for _ in range(reps):
                z = [random.randrange(N) for _ in range(m)]
                cnt = {}
                for x in z:
                    cnt[x] = cnt.get(x, 0) + 1
                # c_x in V iff x unasked; c_x differs from h exactly at x; step iff cnt[x] > eps m
                refused = [x for x in cnt if x not in asked and cnt[x] > eps * m]
                ref += sum(cnt[x] for x in refused)
                freshref += len(refused) / N
            print(f"    m={m:<5} eps={eps:<5} share of batch refused={ref/(reps*m):.4f}  "
                  f"P(R(z)) on average={freshref/reps:.2e}  bound gamma/eps={gamma/eps:.4f}")


# ---------- Example 7.9 ----------

def part_F():
    print("== F: Example 7.9 ==")
    # (a) thresholds on {1..N}, questions on {1..N/2}
    N = 8
    ths = list(range(0, N + 1))
    funcs = [tuple(1 if x <= i else 0 for x in range(1, N + 1)) for i in ths]
    ok = True
    for fi in range(N // 2 + 1, N + 1):
        f = funcs[fi]
        for A in itertools.chain.from_iterable(itertools.combinations(range(N // 2), r) for r in range(N // 2 + 1)):
            Vf = [c for c in funcs if all(c[x] == f[x] for x in A)]
            if not all(funcs[i] in Vf for i in range(N // 2, N + 1)):
                ok = False
            for zz in range(N // 2, N):
                for m in range(1, 5):
                    for eps in [Fr(1, 10), Fr(1, 2), Fr(9, 10)]:
                        S, t, R = bat_index(Vf, [zz] * m, eps)
                        if S:
                            ok = False
    print(f"  (a) N=8: V contains thresholds N/2..N and every batch of copies of z>N/2 is refused (eps<1): {ok}")
    # (b)
    Nb, L, n, eps = 500, 20, 100, 0.1
    for seed in [1, 2]:
        rnd = random.Random(seed)
        asked_blocks = set(rnd.randrange(Nb * L) // L for _ in range(n))
        refused_one = sum(1 for _ in range(2000) if rnd.randrange(Nb) not in asked_blocks)
        r = 400
        cnt = {}
        for _ in range(r):
            blk = rnd.randrange(Nb)
            cnt[blk] = cnt.get(blk, 0) + 1
        refused_many = any(c * L > eps * r * L for blk, c in cnt.items() if blk not in asked_blocks)
        print(f"  (b) seed {seed}: blocks without a question {1-len(asked_blocks)/Nb:.3f}; one-run batches refused "
              f"{refused_one}/2000; batch of 400 runs refused at all: {refused_many} (max runs in a block {max(cnt.values())})")
    # (c)
    N, n, m, eps = 1000, 100, 2000, Fr(1, 20)
    k = int(eps * m)
    for seed in [1, 2, 3]:
        rnd = random.Random(seed)
        asked = set(rnd.randrange(1, N + 1) for _ in range(n))
        for zeros in [k, k // 2]:
            draws = [rnd.randrange(1, N + 1) for _ in range(m - zeros)]
            stream = [0] * zeros + draws
            # obvious rule
            cntc = {}
            ref_obv = 0
            for x in stream:
                # members c_i in V with x in Delta(c_i): x=0 -> all unasked i; x=i -> c_i if unasked
                if x == 0:
                    reached = len(asked) < N and cntc.get('zero', 0) >= k
                    if reached:
                        ref_obv += 1
                    else:
                        cntc['zero'] = cntc.get('zero', 0) + 1
                else:
                    if x in asked:
                        continue
                    used = cntc.get('zero', 0) + cntc.get(x, 0)
                    if used >= k:
                        ref_obv += 1
                    else:
                        cntc[x] = cntc.get(x, 0) + 1
            ref_obv_draws = ref_obv  # zeros never refused here
            # Bat on the batch
            cnt = {}
            for x in stream:
                cnt[x] = cnt.get(x, 0) + 1
            S0 = cnt.get(0, 0)
            steps = 0
            refused = 0
            removed0 = False
            for i in range(1, N + 1):  # order: h first, then c_1, c_2, ...
                if i in asked:
                    continue
                c = (0 if removed0 else S0) + cnt.get(i, 0)
                if c > k:
                    steps += 1
                    refused += (0 if removed0 else S0) + cnt.get(i, 0)
                    removed0 = True
            # better input-by-input rule: refuse x when >= 2 members of V disagree with h at x;
            # otherwise answer while the count of the single disputing member is below k
            cnt2 = {}
            ref_better_draws = 0
            ref_better_zero = 0
            for x in stream:
                if x == 0:
                    ref_better_zero += 1
                    continue
                if x in asked:
                    continue
                if cnt2.get(x, 0) >= k:
                    ref_better_draws += 1
                else:
                    cnt2[x] = cnt2.get(x, 0) + 1
            print(f"  (c) seed {seed}, {zeros} zeros: obvious rule refuses {ref_obv_draws}/{m-zeros} draws; "
                  f"Bat: {steps} step(s), refuses {refused} indices ({min(S0, refused)} zeros); "
                  f"better online rule refuses {ref_better_zero} zeros and {ref_better_draws} draws")
    # (c) 'at most one step', exhaustive small: N=4, streams with first k zeros, any multiset after
    viol = 0
    Ns = 4
    funcs = [tuple(0 for _ in range(Ns + 1))] + [tuple(1 if x in (0, i) else 0 for x in range(Ns + 1)) for i in range(1, Ns + 1)]
    for asked in itertools.chain.from_iterable(itertools.combinations(range(1, Ns + 1), r) for r in range(Ns + 1)):
        Vf = [c for c in funcs if all(c[x] == 0 for x in asked)]
        for m in range(1, 7):
            for z in itertools.combinations_with_replacement(range(Ns + 1), m):
                for kk in range(1, m + 1):
                    eps = Fr(kk, m)
                    if any(z.count(x) > kk for x in range(1, Ns + 1)):
                        continue
                    S, t, R = bat_index(Vf, list(z), eps)
                    if len(t) > 1:
                        viol += 1
    print(f"  (c) at most one step (N=4, all batches m<=6, eps*m integer, no other input more than eps*m times): violations {viol}")


# ---------- Remark 7.10 ----------

def part_G():
    print("== G: Remark 7.10(a), law of the asked call ==")
    # scaffold: z in {0,1,2} uniform; run inputs fixed by z, lengths 1, 2, 3; L = 3
    L = 3
    runs = {0: ['a'], 1: ['a', 'b'], 2: ['c', 'b', 'b']}
    # P_Pi(B) = (1/L) E #{j: x_j in B}
    PPi = {}
    for zz, xs in runs.items():
        for x in xs:
            PPi[x] = PPi.get(x, 0) + Fr(1, 3) * Fr(1, L)
    # law of the asked call (non-abstaining driver): enumerate z and J
    law = {}
    for zz, xs in runs.items():
        for J in range(1, L + 1):
            key = xs[J - 1] if J <= len(xs) else None
            law[key] = law.get(key, 0) + Fr(1, 3) * Fr(1, L)
    print(f"  P_Pi = {dict(sorted(PPi.items()))}, total mass {sum(PPi.values())}")
    print(f"  asked-call law = { {k: v for k, v in law.items()} }; equal on inputs: {all(law.get(x, 0) == PPi[x] for x in PPi)}")
    # abstaining driver: abstains at input 'b' in round 1 only (e.g. a threshold rule before data)
    law2 = {}
    for zz, xs in runs.items():
        ell = len(xs)
        for j, x in enumerate(xs):
            if x == 'b':
                ell = j + 1  # aborted at this call (the call itself can be asked)
                break
        for J in range(1, L + 1):
            key = xs[J - 1] if J <= ell else None
            law2[key] = law2.get(key, 0) + Fr(1, 3) * Fr(1, L)
    print(f"  driver that abstains at 'b': asked-call law = {law2}; differs from P_Pi: {law2.get('b',0) != PPi['b']}")


def part_H():
    print("== H: Remark 7.10(b) stages; per-run count; rock in rate form ==")
    # stages: two stages; stage-2 inputs depend on the rule's answers at stage 1
    viol = 0
    nX = 4
    allf = list(itertools.product(range(2), repeat=nX))
    for trial in range(3000):
        cls = [random.choice(allf) for _ in range(4)]
        f = random.choice(cls)
        Vf = cls[:]  # no data
        Vf = [c for c in cls]
        h = Vf[0]
        if f not in Vf:
            continue
        eps = random.choice([Fr(1, 4), Fr(1, 3), Fr(1, 2)])
        z1 = [random.randrange(nX) for _ in range(random.randint(1, 5))]
        S1, t1, _ = bat_index(Vf, z1, eps)
        ans = tuple(h[z1[j]] if j in S1 else -1 for j in range(len(z1)))
        rnd = random.Random(hash(ans) & 0xffff)
        z2 = [rnd.randrange(nX) for _ in range(rnd.randint(1, 5))]
        S2, t2, _ = bat_index(Vf, z2, eps)
        w = sum(1 for j in S1 if h[z1[j]] != f[z1[j]]) + sum(1 for j in S2 if h[z2[j]] != f[z2[j]])
        if w > math.floor(eps * len(z1)) + math.floor(eps * len(z2)):
            viol += 1
    print(f"  stages: violations of sum_i floor(eps m_i): {viol}")
    # per-run consequence: batch of r runs, each of L calls; fraction of runs with a wrong answer <= eps*L
    viol = 0
    worst = 0.0
    for trial in range(3000):
        Lr, r = random.randint(1, 3), random.randint(1, 4)
        cls = [random.choice(allf) for _ in range(4)]
        f = random.choice(cls)
        Vf = cls
        h = Vf[0]
        runs = [[random.randrange(nX) for _ in range(Lr)] for _ in range(r)]
        z = [x for run in runs for x in run]
        for eps in [Fr(1, 12), Fr(1, 6), Fr(1, 3)]:
            S, t, _ = bat_index(Vf, z, eps)
            bad_runs = sum(1 for i in range(r) if any((i * Lr + j) in S and h[z[i * Lr + j]] != f[z[i * Lr + j]] for j in range(Lr)))
            if bad_runs > eps * Lr * r:
                viol += 1
            worst = max(worst, bad_runs / (eps * Lr * r))
    print(f"  runs of a batch that contain a wrong answer <= eps*L*r: violations {viol}; largest ratio {worst:.3f}")
    # rock in rate form: class closed under patches on sets Q (two answer values)
    viol = 0
    worstq = 0.0
    nX = 5
    for trial in range(400):
        h = tuple(random.randrange(2) for _ in range(nX))
        A = [x for x in range(nX) if random.random() < 0.3]
        fam = [Q for r in range(1, 4) for Q in itertools.combinations([x for x in range(nX) if x not in A], r)]
        if not fam:
            continue
        patches = []
        for Q in fam:
            for y in (0, 1):
                g = tuple(y if x in Q else h[x] for x in range(nX))
                patches.append((Q, g))
        Vf = [h] + [g for Q, g in patches]
        for _ in range(10):
            m = random.randint(2, 7)
            z = [random.randrange(nX) for _ in range(m)]
            for eps in [Fr(1, 7), Fr(1, 4), Fr(1, 3)]:
                S, t, _ = bat_index(Vf, z, eps)
                for Q in fam:
                    inQ = sum(1 for j in S if z[j] in Q)
                    if inQ > 2 * math.floor(eps * m):
                        viol += 1
    print(f"  patch-closed class: answered batch inputs inside any patch set Q <= 2*floor(eps m): violations {viol}")


if __name__ == "__main__":
    part_A()
    part_A2()
    part_B()
    part_B2()
    part_C()
    part_D()
    part_D2()
    part_E()
    part_F()
    part_G()
    part_H()
    print("done")
