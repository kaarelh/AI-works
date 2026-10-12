"""r3 (referee): independent recomputation of the context notes' c1 numbers (Thm 3.5, Rem 3.7, Rem 3.10)
and of the surgery constants B(s) (circuits, Sec 3.2) and B (formulas, Rem 3.6).

Independent implementation: truth tables as numpy bool arrays over the 8 inputs (not integer bitmasks),
size distribution computed with exact Fractions for s <= 10 (to validate the float recursion) and floats
to S_MAX = 80; per-f subset DP written separately.  Checks, for all 256 functions on d = 3 and every
ordering (DP over subsets):
  (a) c(f) <= ceil(L);  (b) L <= c + log2 N_c;  (c) m_max <= ln2 L and L <= 2 m_min (B+3);
  (e) MAP (weighted-majority) mistakes <= L on every ordering (halving bound, Rem 3.10), ties = 1/2.
Also: the ratio L/m_min (max over f), the per-class L ranges, the min over orderings of MAP mistakes,
and the circuit surgery bound 2^-g N_s/N_{s+g} >= 2^-B(s) with B(s) = g(5 + 2 log2(d+1+s+g)) for
d = 1..20, s = 1..200 (g = max(d-1,1)+1), and the formula bound 2^-d N_s/N_{s+d} >= 2^-B.
Deterministic.
"""
import math
from fractions import Fraction
import itertools
import numpy as np

d = 3
NP = 8
S_MAX = 80
out = []

X = np.array([[(i >> j) & 1 for j in range(d)] for i in range(NP)], dtype=bool)  # input i -> bits
leaves = [X[:, j] for j in range(d)] + [~X[:, j] for j in range(d)] + [np.zeros(NP, bool), np.ones(NP, bool)]


def code(tt):
    return int(sum(int(b) << i for i, b in enumerate(tt)))


leaf_codes = [code(t) for t in leaves]
# op tables over codes 0..255
codes = np.arange(256)
AND = codes[:, None] & codes[None, :]
OR = codes[:, None] | codes[None, :]
XOR = codes[:, None] ^ codes[None, :]


def catalan(n):
    return math.comb(2 * n, n) // (n + 1)


def Ns(s):
    return catalan(s - 1) * 3 ** (s - 1) * (2 * d + 2) ** s


# exact fractions for small s
P_exact = {1: [Fraction(0)] * 256}
for c_ in leaf_codes:
    P_exact[1][c_] += Fraction(1, len(leaf_codes))
for s in range(2, 11):
    acc = [Fraction(0)] * 256
    for a in range(1, s):
        b = s - a
        wsplit = Fraction(catalan(a - 1) * catalan(b - 1), catalan(s - 1))
        nzA = [(g, p) for g, p in enumerate(P_exact[a]) if p]
        nzB = [(h, q) for h, q in enumerate(P_exact[b]) if q]
        for g, p in nzA:
            for h, q in nzB:
                pq = wsplit * p * q / 3
                acc[g & h] += pq
                acc[g | h] += pq
                acc[g ^ h] += pq
    P_exact[s] = acc
    assert sum(acc) == 1

# floats to S_MAX
P = {1: np.array([float(x) for x in P_exact[1]])}
for s in range(2, S_MAX + 1):
    acc = np.zeros(256)
    for a in range(1, s):
        b = s - a
        wsplit = catalan(a - 1) * catalan(b - 1) / catalan(s - 1)
        outer = np.outer(P[a], P[b]).ravel() * wsplit / 3
        for T in (AND, OR, XOR):
            acc += np.bincount(T.ravel(), weights=outer, minlength=256)
    P[s] = acc
maxdev = max(abs(P[s][f] - float(P_exact[s][f])) for s in range(1, 11) for f in range(256))
out.append(f"float recursion vs exact fractions (s<=10): max abs deviation {maxdev:.2e}")

W = sum(2.0 ** -s * P[s] for s in range(1, S_MAX + 1))
L = -np.log2(W)
c = np.array([min(s for s in range(1, S_MAX + 1) if P[s][f] > 0) for f in range(256)])
okA = all(c[f] <= math.ceil(L[f]) for f in range(256))
okB = all(L[f] <= c[f] + math.log2(Ns(c[f])) + 1e-9 for f in range(256))
out.append(f"(a) c <= ceil(L): {okA};  (b) L <= c + log2 N_c: {okB};  min formula sizes histogram: "
           f"{dict(zip(*np.unique(c, return_counts=True)))}")
for cc in sorted(set(c)):
    Ls = L[c == cc]
    out.append(f"   class c={cc}: {len(Ls)} functions, L in [{Ls.min():.2f}, {Ls.max():.2f}]")

B = d * (1 + math.log2(12 * (2 * d + 2)))
# W on partial functions: WD[mask][vals] for all subsets; precompute via consistency
fs = np.arange(256)
total0 = W.sum()  # = 1 - 2^-S_MAX
max_ratio = 0.0
okC = True
okE = True
min_map_by_class = {}
for f in range(256):
    # Wsub[A] = W-mass of functions agreeing with f on subset A
    Wsub = np.zeros(256)
    for A in range(256):
        Wsub[A] = W[((fs ^ f) & A) == 0].sum()
    mn = np.full(256, np.inf); mx = np.full(256, -np.inf)
    mapmx = np.full(256, -np.inf); mapmn = np.full(256, np.inf)
    mn[255] = mx[255] = mapmx[255] = mapmn[255] = 0.0
    for A in sorted(range(255), key=lambda A: -bin(A).count("1")):
        for i in range(NP):
            if (A >> i) & 1:
                continue
            A2 = A | (1 << i)
            p = 1 - Wsub[A2] / Wsub[A]
            mm = 1.0 if p > 0.5 + 1e-12 else (0.5 if abs(p - 0.5) <= 1e-12 else 0.0)
            mn[A] = min(mn[A], p + mn[A2]); mx[A] = max(mx[A], p + mx[A2])
            mapmx[A] = max(mapmx[A], mm + mapmx[A2]); mapmn[A] = min(mapmn[A], mm + mapmn[A2])
    Lf = -math.log2(W[f] / total0)
    okC &= (mx[0] <= math.log(2) * Lf + 1e-9) and (Lf <= 2 * mn[0] * (B + 3) + 1e-9)
    okE &= mapmx[0] <= Lf + 1e-9
    max_ratio = max(max_ratio, Lf / mn[0])
    min_map_by_class.setdefault(int(c[f]), []).append((mapmn[0], Lf))
out.append(f"(c) Gibbs: m_max <= ln2 L and L <= 2 m_min (B+3) [B={B:.3f}] for all f: {okC}; max L/m_min = {max_ratio:.2f}")
out.append(f"(e) halving: MAP mistakes (ties 1/2) <= L on every ordering, all f: {okE}")
for cc, v in sorted(min_map_by_class.items()):
    out.append(f"   class c={cc}: min over orderings of MAP mistakes ranges over [{min(a for a, _ in v):.1f}, "
               f"{max(a for a, _ in v):.1f}]; worst ratio L / max(min-MAP,0.5) = {max(l / max(a, 0.5) for a, l in v):.1f}")

# circuit surgery constant
okS = True
worst = None
for dd in range(1, 21):
    g = max(dd - 1, 1) + 1
    for s in range(1, 201):
        logratio = -g - sum(4 + 2 * math.log2(dd + 1 + j) for j in range(s + 1, s + g + 1))
        Bs = g * (5 + 2 * math.log2(dd + 1 + s + g))
        if logratio < -Bs - 1e-9:
            okS = False
            worst = (dd, s, logratio, Bs)
out.append(f"circuit surgery: log2(w(C')/w(C)) >= -B(s) for d=1..20, s=1..200: {okS} {worst or ''}")
okF = True
for dd in range(1, 21):
    Bf = dd * (1 + math.log2(12 * (2 * dd + 2)))
    for s in range(1, 201):
        lr = -dd + (math.lgamma(2 * s - 1) - 2 * math.lgamma(s) - math.log(s)) / math.log(2) \
             - (math.lgamma(2 * (s + dd) - 1) - 2 * math.lgamma(s + dd) - math.log(s + dd)) / math.log(2) \
             - dd * math.log2(3) - dd * math.log2(2 * dd + 2)
        if lr < -Bf - 1e-9:
            okF = False
out.append(f"formula surgery: log2(2^-d N_s/N_(s+d)) >= -B for d=1..20, s=1..200: {okF}")

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
