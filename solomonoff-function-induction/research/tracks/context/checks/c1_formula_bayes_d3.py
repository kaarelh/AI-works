"""c1: formula Bayes on d = 3 Boolean inputs (notes.md, section 3.3, Theorem 3.5 and Remark 3.7).

Hypothesis language: Boolean formulas = ordered binary trees.
  leaves (2d+2 = 8): x1,x2,x3, not x1, not x2, not x3, 0, 1
  internal nodes: AND, OR, XOR
  size s = number of leaves (s >= 1).
Prior: P(size = s) = 2^{-s}, then uniform over the N_s formulas of size s.
  N_s = Cat(s-1) * 3^{s-1} * 8^s.
W(f) = sum_s 2^{-s} * #{formulas of size s computing f} / N_s, truncated at S_MAX
(the neglected mass is at most 2^{-S_MAX}; reported relative to the smallest W(f)).

Checks (all claims are about every one of the 256 functions f and every ordering of the 8 inputs):
  (a) c(f) <= ceil(L(f)), where c(f) = min formula size and L(f) = -log2 W(f)          [Thm 3.5(a)]
  (b) L(f) <= c(f) + log2 N_{c(f)}                                                       [Thm 3.5(a)]
  (c) for every ordering s: m_s <= ln2 * L(f), and L(f) <= 2 m_s (B + 3),
      with B = d(1 + log2(12(2d+2))) the exception-surgery cost for formulas              [Thm 3.5(b), Rem 3.6]
      (checked via min and max over orderings, computed exactly by dynamic programming over subsets)
  (d) order independence: L(f) = sum_i -log2(1 - P_i) for every ordering (checked on random orderings)
Also reports, per complexity class, the worst-case (adversarial-order) number of mistakes of
  Occam learning (simplest consistent function; ties by truth-table index) and of the Bayes posterior-majority
  (weighted-majority) predictor.  (Earlier versions called it "MAP"; MAP usually means the maximum-a-posteriori
  hypothesis, which under this prior is the Occam learner.)
Deterministic (no randomness except the seeded random orderings in (d)).
"""
import math
import numpy as np

SEED = 0
D = 3
NPTS = 2 ** D            # 8 inputs
NF = 2 ** NPTS           # 256 functions
S_MAX = 80

rng = np.random.default_rng(SEED)

# truth tables: bit i of the integer is the value at input i; input i has bits (x1,x2,x3) = bits of i
def var_tt(j):
    return sum(1 << i for i in range(NPTS) if (i >> j) & 1)

leaves = []
for j in range(D):
    t = var_tt(j)
    leaves += [t, (NF - 1) ^ t]
leaves += [0, NF - 1]
assert len(leaves) == 2 * D + 2

g = np.arange(NF)
OPS = [np.bitwise_and.outer(g, g), np.bitwise_or.outer(g, g), np.bitwise_xor.outer(g, g)]

def catalan(n):
    return math.comb(2 * n, n) // (n + 1)

N = {s: catalan(s - 1) * 3 ** (s - 1) * (2 * D + 2) ** s for s in range(1, S_MAX + 1)}

# Dist[s][f] = fraction of size-s formulas computing f
Dist = {}
d1 = np.zeros(NF)
for t in leaves:
    d1[t] += 1.0 / len(leaves)
Dist[1] = d1
for s in range(2, S_MAX + 1):
    acc = np.zeros(NF)
    for a in range(1, s):
        b = s - a
        # fraction of size-s trees whose root splits a|b: 3 N_a N_b / N_s
        frac = 3 * N[a] * N[b] / N[s]
        outer = np.outer(Dist[a], Dist[b]).ravel()
        for T in OPS:
            acc += frac / 3.0 * np.bincount(T.ravel(), weights=outer, minlength=NF)
    Dist[s] = acc
    assert abs(acc.sum() - 1) < 1e-9

W = np.zeros(NF)
for s in range(1, S_MAX + 1):
    W += 2.0 ** (-s) * Dist[s]
tail = 2.0 ** (-S_MAX)
L = -np.log2(W)
c = np.array([min(s for s in range(1, S_MAX + 1) if Dist[s][f] > 0) for f in range(NF)])

out = []
out.append(f"S_MAX = {S_MAX}; neglected prior mass <= 2^-{S_MAX} = {tail:.3e}; min W(f) = {W.min():.3e}; "
           f"relative truncation error <= {tail / W.min():.3e}")
out.append(f"sum_f W(f) = {W.sum():.12f} (should be 1 - 2^-S_MAX)")

# (a), (b)
ok_a = all(c[f] <= math.ceil(L[f]) for f in range(NF))
ok_b = all(L[f] <= c[f] + math.log2(N[c[f]]) + 1e-9 for f in range(NF))
out.append(f"(a) c(f) <= ceil(L(f)) for all f: {ok_a}")
out.append(f"(b) L(f) <= c(f) + log2 N_c(f) for all f: {ok_b}")

# W(f|A) for all f, A
popc = np.array([bin(A).count("1") for A in range(NF)])
WA = np.zeros((NF, NF))  # WA[f, A]
for A in range(NF):
    T = np.bincount(g & A, weights=W, minlength=NF)
    WA[:, A] = T[g & A]
WA[:, 0] = W.sum()  # empty data: total prior mass (semimeasure convention; = 1 - tail)

# Occam hypothesis at state (f, A): the simplest function consistent with f on A (ties by index)
order_key = c * NF + g  # lexicographic (complexity, index)

B_formula = D * (1 + math.log2(12 * (2 * D + 2)))
out.append(f"surgery cost B for formulas, d = {D}: {B_formula:.3f} bits")

states_by_pop = [[A for A in range(NF) if popc[A] == k] for k in range(NPTS + 1)]

rows = []
all_ok_c = True
order_indep_err = 0.0
for f in range(NF):
    Wf = WA[f]
    # costs
    def P_wrong(A, i):
        return 1.0 - Wf[A | (1 << i)] / Wf[A]
    # Occam prediction per state
    occ = {}
    for A in range(NF):
        cons = np.nonzero(((g ^ f) & A) == 0)[0]
        occ[A] = cons[np.argmin(order_key[cons])]
    mx = {NF - 1: 0.0}; mn = {NF - 1: 0.0}; ex = {NF - 1: 0.0}
    occ_mx = {NF - 1: 0}; map_mx = {NF - 1: 0.0}
    for k in range(NPTS - 1, -1, -1):
        for A in states_by_pop[k]:
            free = [i for i in range(NPTS) if not (A >> i) & 1]
            vals = [P_wrong(A, i) + mx[A | (1 << i)] for i in free]
            mx[A] = max(vals)
            mn[A] = min(P_wrong(A, i) + mn[A | (1 << i)] for i in free)
            ex[A] = sum(P_wrong(A, i) + ex[A | (1 << i)] for i in free) / len(free)
            occ_mx[A] = max(int(((occ[A] >> i) & 1) != ((f >> i) & 1)) + occ_mx[A | (1 << i)] for i in free)
            def map_mistake(A, i):
                p = P_wrong(A, i)
                return 1.0 if p > 0.5 + 1e-12 else (0.5 if abs(p - 0.5) <= 1e-12 else 0.0)
            map_mx[A] = max(map_mistake(A, i) + map_mx[A | (1 << i)] for i in free)
    Lf = L[f] + math.log2(WA[f, 0])  # loss in the semimeasure convention: -log2 (W(f)/W(empty))
    m_min, m_max = mn[0], mx[0]
    ok = (m_max <= math.log(2) * Lf + 1e-9) and (Lf <= 2 * m_min * (B_formula + 3) + 1e-9)
    all_ok_c &= ok
    # (d) order independence on 5 random orderings
    for _ in range(5):
        perm = rng.permutation(NPTS)
        A = 0; tot = 0.0
        for i in perm:
            tot += -math.log2(1 - P_wrong(A, int(i)))
            A |= 1 << int(i)
        order_indep_err = max(order_indep_err, abs(tot - Lf))
    rows.append((f, c[f], Lf, m_min, ex[0], m_max, occ_mx[0], map_mx[0]))

out.append(f"(c) for all f and all orderings: m <= ln2 L and L <= 2 m_min (B+3): {all_ok_c}")
out.append(f"(d) max |sum_i -log2(1-P_i) - L(f)| over 5 random orderings x 256 f: {order_indep_err:.2e}")

out.append("")
out.append("per formula-size class c: #functions, L range, Gibbs mistakes m (min / mean over uniform random order / max over orders),")
out.append("  worst-case Occam mistakes, worst-case posterior-majority mistakes (ties count 1/2), max ratio L / m_min")
for cc in sorted(set(c)):
    R = [r for r in rows if r[1] == cc]
    Ls = [r[2] for r in R]
    out.append(f"c={cc:2d}: n={len(R):3d}  L in [{min(Ls):6.2f},{max(Ls):6.2f}]  "
               f"m_min max={max(r[3] for r in R):5.2f}  m_mean max={max(r[4] for r in R):5.2f}  "
               f"m_max max={max(r[5] for r in R):5.2f}  Occam worst={max(r[6] for r in R)}  "
               f"majority worst={max(r[7] for r in R):.1f}  max L/m_min={max(r[2] / r[3] for r in R if r[3] > 0):6.2f}")
nsmaller = {int(cc): int((c <= cc).sum()) for cc in sorted(set(c))}
out.append("")
out.append("#functions with formula size <= c (trivial upper bound on adversarial Occam mistakes + 1): " + str(nsmaller))

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
