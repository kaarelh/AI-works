"""c6: the conjunction ladder (notes-final.md, Theorem 3.11; referee M1; Vaintrob-Hanni slides, Appendix K).

Target f = AND of all d variables on {0,1}^d.  Ladder ordering: 1^d, then 0^d, then the inputs of
Hamming weight 1, 2, ..., d-1; inside a level the adversary shows an input on which the current
Occam hypothesis errs, if there is one (otherwise the remaining level inputs in index order).

Parts
  (a) Moebius lemma, exhaustively for d = 2, 3, 4 and every k: every h with h(1^d)=1 and h(x)=0 for
      |x|<k has only ANF monomials of degree >= k, depends on >= k variables, and if it depends on
      exactly k variables it is a k-variable conjunction.
  (b) Formula language of c1 / Remark 3.6: leaves x_j, not x_j, 0, 1; nodes AND, OR, XOR;
      size = number of leaves.  For d = 3, 4, 5: the least-size functions consistent with the data at
      the start of stage k (k = 1..d-1) are exactly the k-variable conjunctions (size k); Occam
      (least size, ties by truth-table index) is simulated on the ladder and its mistakes counted.
  (c) Circuit language of Section 3.2: all 16 two-input gates, sources x_1..x_d, 0, 1 and earlier gates,
      size = number of gates (dead gates allowed).  For d = 3, 4, 5: for k >= 2 the least-size consistent
      functions at the start of stage k are exactly the k-variable conjunctions (size k-1); for k = 1
      the lemma fails (x_i AND x_j has size 1); Occam mistakes on the ladder.  Also the number of functions
      with at most d-1 gates for d = 3, 4 (a cross-check against the referee's r2 counts).
  (d) Description lengths l(AND_d) (unary size code + uniform choice within the size, as in Section 3.2/3.3)
      against the mistake lower bounds 2^d - 2 (formulas) and 2^d - d - 2 (circuits), d = 3..40.
  (e) Same prior, other selection rule: Bayes posterior-majority (weighted majority) predictor for the
      formula prior P(size=s)=2^-s, uniform within size, on AND_d, d = 3, 4: mistakes on the Occam ladder,
      worst case over ALL orderings (dynamic programming over subsets), and the halving bound
      log2(W(empty)/W(AND_d)) of Remark 3.10.  W is computed by subset/superset zeta transforms and the
      Walsh-Hadamard transform over truth tables; at d = 3 it is cross-checked against direct counting.
Deterministic (no random numbers are used).
"""
import math
from itertools import combinations
import numpy as np

out = []


def P(s):
    print(s)
    out.append(s)


def var_tt(d, j):
    return sum(1 << i for i in range(1 << d) if (i >> j) & 1)


def weight(i):
    return bin(i).count("1")


def conj_tt(d, S):
    """truth table of AND_{j in S}: 1 exactly at inputs whose support contains S"""
    m = sum(1 << j for j in S)
    return sum(1 << i for i in range(1 << d) if (i & m) == m)


def stage_mask(d, k):
    """(mask of inputs with known labels, required values) at the start of stage k:
    h(1^d)=1 and h(x)=0 for |x|<k"""
    NP = 1 << d
    known = 1 << (NP - 1)
    val = 1 << (NP - 1)
    for i in range(NP):
        if weight(i) < k:
            known |= 1 << i
    return known, val


# ---------------------------------------------------------------- (a) Moebius lemma
P("(a) Moebius lemma (exhaustive)")
for d in (2, 3, 4):
    NP = 1 << d
    NF = 1 << NP
    tts = np.arange(NF, dtype=np.int64)
    # ANF coefficients: c_S = XOR_{T subset S} h(1_T); bit layout: input index i = support bitmask
    bits = ((tts[:, None] >> np.arange(NP)[None, :]) & 1).astype(np.uint8)  # (NF, NP)
    anf = bits.copy()
    for j in range(d):
        step = 1 << j
        for i in range(NP):
            if i & step:
                anf[:, i] ^= anf[:, i ^ step]
    deg = np.array([weight(i) for i in range(NP)])
    ess = np.zeros(NF, dtype=np.int64)  # bitmask of essential variables = union of ANF monomial supports
    for i in range(NP):
        ess |= np.where(anf[:, i] == 1, i, 0)
    ness = np.array([weight(int(e)) for e in ess])
    ok = True
    for k in range(1, d + 1):
        known, val = stage_mask(d, k)
        cons = ((tts & known) == val)
        mindeg_ok = all((anf[cons][:, deg < k] == 0).all(axis=1))
        ess_ok = bool((ness[cons] >= k).all())
        exact = set(int(t) for t in tts[cons & (ness == k)])
        conjs = set(conj_tt(d, S) for S in combinations(range(d), k))
        ok_k = mindeg_ok and ess_ok and exact == conjs
        ok &= ok_k
        P(f"  d={d} k={k}: #consistent h = {int(cons.sum())}; all ANF degrees >= k: {mindeg_ok}; "
          f"all depend on >= k variables: {ess_ok}; those depending on exactly k variables = the {len(conjs)} "
          f"k-conjunctions: {exact == conjs}")
    P(f"  d={d}: lemma holds for all k: {ok}")


# ---------------------------------------------------------------- helpers for both languages
def ladder_occam(d, size_of, f_tt):
    """Occam = least size, ties by truth-table index, over the functions in size_of (dict tt -> least size).
    Returns (#mistakes, sequence of (input, hypothesis size, mistake))."""
    NP = 1 << d
    items = sorted(size_of.items(), key=lambda kv: (kv[1], kv[0]))
    tt_arr = np.array([t for t, _ in items], dtype=np.uint64)
    sz_arr = np.array([s for _, s in items])
    known = 0
    mistakes = 0
    log = []

    def hyp():
        mask = np.uint64(known)
        cons = (tt_arr & mask) == (np.uint64(f_tt) & mask)
        idx = int(np.argmax(cons))
        assert cons[idx], "Occam hypothesis outside the enumerated sizes"
        return int(tt_arr[idx]), int(sz_arr[idx])

    def show(i):
        nonlocal known, mistakes
        h, s = hyp()
        mis = ((h >> i) & 1) != ((f_tt >> i) & 1)
        mistakes += int(mis)
        log.append((i, s, mis))
        known |= 1 << i

    show(NP - 1)
    show(0)
    for k in range(1, d):
        level = [i for i in range(NP) if weight(i) == k]
        while level:
            h, _ = hyp()
            bad = [i for i in level if ((h >> i) & 1) != ((f_tt >> i) & 1)]
            i = bad[0] if bad else level[0]
            level.remove(i)
            show(i)
    return mistakes, log


def check_ladder_lemma(d, size_of, kmin, size_at):
    """for k >= kmin: least size among functions consistent at the start of stage k equals size_at(k),
    and the consistent functions of that size are exactly the k-conjunctions"""
    res = True
    for k in range(kmin, d):
        known, val = stage_mask(d, k)
        cons = [(t, s) for t, s in size_of.items() if (t & known) == val]
        smin = min(s for _, s in cons)
        best = set(t for t, s in cons if s == smin)
        conjs = set(conj_tt(d, S) for S in combinations(range(d), k))
        res &= (smin == size_at(k)) and best == conjs
    return res


# ---------------------------------------------------------------- (b) formulas
def formula_sizes(d, smax):
    NP = 1 << d
    FULL = (1 << NP) - 1
    leaves = set()
    for j in range(d):
        t = var_tt(d, j)
        leaves |= {t, FULL ^ t}
    leaves |= {0, FULL}
    best = {t: 1 for t in leaves}
    G = {1: np.array(sorted(leaves), dtype=np.uint64)}  # G[s] = functions of least size <= s
    for s in range(2, smax + 1):
        new = set()
        for a in range(1, s // 2 + 1):
            A, B = G[a], G[s - a]
            for op in (np.bitwise_and, np.bitwise_or, np.bitwise_xor):
                new |= set(op.outer(A, B).ravel().tolist())
        for t in new:
            if t not in best:
                best[t] = s
        G[s] = np.array(sorted(best.keys()), dtype=np.uint64)
    return best


P("")
P("(b) formula language (size = #leaves)")
for d in (3, 4, 5):
    NP = 1 << d
    sizes = formula_sizes(d, d)
    f_tt = 1 << (NP - 1)
    assert sizes[f_tt] == d
    lem = check_ladder_lemma(d, sizes, 1, lambda k: k)
    no_smaller = all(s >= 1 for s in sizes.values())
    mis, log = ladder_occam(d, sizes, f_tt)
    P(f"  d={d}: #functions of least size <= {d}: {len(sizes)}; ladder lemma for k=1..{d-1}: {lem}; "
      f"Occam mistakes on the ladder: {mis} of {NP} inputs (lower bound 2^d-2 = {NP-2})")


# ---------------------------------------------------------------- (c) circuits
def circuit_sizes(d, smax):
    """least gate count (<= smax) of every function computable with <= smax gates, Section 3.2 language"""
    NP = 1 << d
    FULL = np.uint64((1 << NP) - 1)
    src = [np.uint64(var_tt(d, j)) for j in range(d)] + [np.uint64(0), FULL]
    best = {}
    states = {frozenset()}
    for s in range(1, smax + 1):
        nstates = set()
        for st in states:
            avail = np.array(src + sorted(st), dtype=np.uint64)
            u = avail[:, None]
            v = avail[None, :]
            nu, nv = ~u & FULL, ~v & FULL
            parts = [nu & nv, nu & v, u & nv, u & v]
            vals = set()
            for op in range(16):
                r = np.zeros((len(avail), len(avail)), dtype=np.uint64)
                for b in range(4):
                    if (op >> b) & 1:
                        r |= parts[b]
                vals |= set(r.ravel().tolist())
            for g in vals:
                if g not in best:
                    best[g] = s
                if s < smax:
                    nstates.add(st | {g})
        states = nstates
    return best


P("")
P("(c) circuit language of Section 3.2 (size = #gates)")
for d in (3, 4, 5):
    NP = 1 << d
    smax = d - 2
    sizes = circuit_sizes(d, smax)
    f_tt = 1 << (NP - 1)
    lem = check_ladder_lemma(d, sizes, 2, lambda k: k - 1)
    known1, val1 = stage_mask(d, 1)
    s1 = sorted(t for t, s in sizes.items() if s == 1 and (t & known1) == val1)
    has_pair_and = conj_tt(d, (0, 1)) in s1
    mis, log = ladder_occam(d, sizes, f_tt)
    P(f"  d={d}: #functions of least size <= {smax}: {len(sizes)}; ladder lemma for k=2..{d-1}: {lem}; "
      f"k=1: size-1 consistent functions include x1 AND x2: {has_pair_and} (so the lemma fails at k=1); "
      f"Occam mistakes on the ladder: {mis} of {NP} (lower bound 2^d-d-2 = {NP-d-2})")


P("  cross-check at one size more (d-1 gates): #functions of least circuit size <= d-1: "
  + ", ".join(f"d={d}: {len(circuit_sizes(d, d - 1))}" for d in (3, 4))
  + " (equal to the formula counts of size <= d in (b); an observation, not used)")


# ---------------------------------------------------------------- (d) description lengths
def catalan(n):
    return math.comb(2 * n, n) // (n + 1)


P("")
P("(d) description length l(AND_d) vs the mistake lower bounds")
P("  d   l_formula  log2(2^d-2)/l  log2(2^d-2)/(l/log2 l)   l_circuit  log2(2^d-d-2)/l  .../(l/log2 l)")
for d in (3, 4, 5, 8, 10, 15, 20, 30, 40):
    lf = d + math.log2(catalan(d - 1) * 3 ** (d - 1) * (2 * d + 2) ** d)
    lc = (d - 1) + sum(math.log2(16 * (d + 1 + j) ** 2) for j in range(1, d))
    mf = math.log2(2 ** d - 2)
    mc = math.log2(2 ** d - d - 2)
    P(f"  {d:2d}  {lf:9.1f}  {mf/lf:13.3f}  {mf/(lf/math.log2(lf)):22.3f}   {lc:9.1f}  {mc/lc:15.3f}  {mc/(lc/math.log2(lc)):13.3f}")


# ---------------------------------------------------------------- (e) Bayes majority, formula prior
def zeta_sup(a, nb):
    a = a.copy()
    for i in range(nb):
        v = a.reshape(-1, 2, 1 << i)
        v[:, 0, :] += v[:, 1, :]
    return a


def moeb_sup(a, nb):
    a = a.copy()
    for i in range(nb):
        v = a.reshape(-1, 2, 1 << i)
        v[:, 0, :] -= v[:, 1, :]
    return a


def zeta_sub(a, nb):
    a = a.copy()
    for i in range(nb):
        v = a.reshape(-1, 2, 1 << i)
        v[:, 1, :] += v[:, 0, :]
    return a


def moeb_sub(a, nb):
    a = a.copy()
    for i in range(nb):
        v = a.reshape(-1, 2, 1 << i)
        v[:, 1, :] -= v[:, 0, :]
    return a


def wht(a, nb):
    a = a.copy()
    for i in range(nb):
        v = a.reshape(-1, 2, 1 << i)
        x, y = v[:, 0, :].copy(), v[:, 1, :].copy()
        v[:, 0, :] = x + y
        v[:, 1, :] = x - y
    return a


def formula_prior_W(d, smax):
    """W[f] = sum_s 2^-s * (fraction of size-s formulas computing f), s <= smax"""
    NP = 1 << d
    NF = 1 << NP
    FULL = NF - 1
    leaves = []
    for j in range(d):
        t = var_tt(d, j)
        leaves += [t, FULL ^ t]
    leaves += [0, FULL]
    N = {s: catalan(s - 1) * 3 ** (s - 1) * (2 * d + 2) ** s for s in range(1, smax + 1)}
    p = {}
    p1 = np.zeros(NF)
    for t in leaves:
        p1[t] += 1.0 / len(leaves)
    p[1] = p1
    tr = {1: (zeta_sup(p1, NP), zeta_sub(p1, NP), wht(p1, NP))}
    W = 0.5 * p1
    for s in range(2, smax + 1):
        acc_and = np.zeros(NF); acc_or = np.zeros(NF); acc_xor = np.zeros(NF)
        for a in range(1, s):
            b = s - a
            w = N[a] * N[b] / N[s]  # = (3 N_a N_b / N_s) * (1/3): weight of split (a,b) and one op
            A, B = tr[a], tr[b]
            acc_and += w * A[0] * B[0]
            acc_or += w * A[1] * B[1]
            acc_xor += w * A[2] * B[2]
        ps = moeb_sup(acc_and, NP) + moeb_sub(acc_or, NP) + wht(acc_xor, NP) / NF
        assert ps.min() > -1e-12 and abs(ps.sum() - 1) < 1e-9, (s, ps.min(), ps.sum())
        ps = np.clip(ps, 0, None)
        p[s] = ps
        tr[s] = (zeta_sup(ps, NP), zeta_sub(ps, NP), wht(ps, NP))
        W += 2.0 ** (-s) * ps
    return W, p


def formula_prior_W_direct(d, smax):
    """direct counting as in c1 (only feasible for d = 3)"""
    NP = 1 << d
    NF = 1 << NP
    FULL = NF - 1
    leaves = []
    for j in range(d):
        t = var_tt(d, j)
        leaves += [t, FULL ^ t]
    leaves += [0, FULL]
    N = {s: catalan(s - 1) * 3 ** (s - 1) * (2 * d + 2) ** s for s in range(1, smax + 1)}
    g = np.arange(NF)
    OPS = [np.bitwise_and.outer(g, g), np.bitwise_or.outer(g, g), np.bitwise_xor.outer(g, g)]
    Dist = {1: np.bincount(leaves, minlength=NF) / len(leaves)}
    for s in range(2, smax + 1):
        acc = np.zeros(NF)
        for a in range(1, s):
            outer = np.outer(Dist[a], Dist[s - a]).ravel()
            for T in OPS:
                acc += N[a] * N[s - a] / N[s] * np.bincount(T.ravel(), weights=outer, minlength=NF)
        Dist[s] = acc
    return sum(2.0 ** (-s) * Dist[s] for s in range(1, smax + 1))


def majority_analysis(d, W, ladder_inputs):
    NP = 1 << d
    NF = 1 << NP
    f = 1 << (NP - 1)
    # WA[A] = W-mass of functions agreeing with f on the input set A (bitmask)
    u = np.zeros(NF)
    u[np.arange(NF) ^ f] = W           # u[Delta] = W(f xor Delta)
    Z = zeta_sub(u, NP)                 # Z[T] = sum_{Delta subset T} u[Delta]
    WA = Z[(NF - 1) ^ np.arange(NF)]    # agree on A  <=>  Delta inside complement of A
    tot = W.sum()

    def pwrong(A, i):
        return 1.0 - WA[A | (1 << i)] / WA[A]

    def mmis(p):
        return 1.0 if p > 0.5 + 1e-12 else (0.5 if abs(p - 0.5) <= 1e-12 else 0.0)

    # mistakes on the given ladder order
    A = 0; lad = 0.0; gibbs = 0.0
    for i in ladder_inputs:
        p = pwrong(A, i)
        lad += mmis(p); gibbs += p
        A |= 1 << i
    # worst case over all orderings: DP over subsets
    worst = np.zeros(NF)
    gworst = np.zeros(NF)
    pop = np.array([weight(A) for A in range(NF)])
    for k in range(NP - 1, -1, -1):
        for A in np.nonzero(pop == k)[0]:
            A = int(A)
            best = -1.0; gbest = -1.0
            for i in range(NP):
                if not (A >> i) & 1:
                    p = pwrong(A, i)
                    best = max(best, mmis(p) + worst[A | (1 << i)])
                    gbest = max(gbest, p + gworst[A | (1 << i)])
            worst[A] = best; gworst[A] = gbest
    halving = math.log2(tot / W[f])
    return lad, gibbs, worst[0], gworst[0], halving


P("")
P("(e) Bayes posterior-majority predictor (same formula prior, truncated at size S_MAX) on AND_d")
S_MAX = 60
W3 = formula_prior_W(3, S_MAX)[0]
W3d = formula_prior_W_direct(3, S_MAX)
P(f"  d=3: transform method vs direct counting, max relative difference of W: {np.max(np.abs(W3 - W3d) / W3d):.2e}")
for d, Wd in ((3, W3), (4, formula_prior_W(4, S_MAX)[0])):
    NP = 1 << d
    sizes = formula_sizes(d, d)
    mis, log = ladder_occam(d, sizes, 1 << (NP - 1))
    order = [i for i, _, _ in log]
    lad, gibbs, worst, gworst, halving = majority_analysis(d, Wd, order)
    P(f"  d={d}: truncation mass 2^-{S_MAX}; min W(f) = {Wd.min():.3e}; halving bound log2(W(empty)/W(AND_d)) = {halving:.2f}")
    P(f"        on the Occam ladder: Occam mistakes {mis}, majority mistakes {lad:.1f}, Gibbs expected mistakes {gibbs:.2f}")
    P(f"        worst case over all {math.factorial(NP) if NP <= 8 else '16!'} orderings: majority {worst:.1f}, Gibbs {gworst:.2f} "
      f"(<= halving bound: {worst <= halving + 1e-9}; Gibbs <= ln2 * halving: {gworst <= math.log(2) * halving + 1e-9})")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
