"""rb6 (referee B): exact arithmetic for two numerical claims, and a code-length bug in the prover's scripts.
Deterministic (exact rationals and exact integer binomials; no randomness).

(A) Notes Remark 3.4: Paper 2's class (mu uniform on {0..9}; nu = Bern(1/64), l = 5; e_j = nu except e_j(1|j) = 1,
    l = 9; lambda = 1.2).  Per query, e_j is a lambda-MAP iff every query at j so far returned 1 and there was at
    least one (6k > 4.8 for k >= 1).  The notes give the union bound 10((9/10 + 1/640)^n - (9/10)^n).  We compute
    P_n[some e_j is a lambda-MAP] EXACTLY by inclusion-exclusion over the cells, with Python fractions, and the
    exact probability that some e_j is a MAP at some time up to 400 (the prover's simulated 0.1465).
(B) The prover's r2, r3, r4 compute ceil(log2 C(N, t)) as ceil of a floating-point lgamma difference.  When C(N, t)
    is a power of two (t = 1 or t = N - 1 with N a power of two) the float exceeds the integer by ~1e-12 and the
    ceiling is one too large.  We list the affected code lengths for the prover's N, and recompute r4(B)'s exact
    selection table (16 cells, |S| = 2, p = 1/8) with exact integer code lengths, to measure the effect.
"""
from fractions import Fraction as F
from math import comb, lgamma, log, log2, ceil, floor, factorial
import itertools
import numpy as np

print("(A) Remark 3.4, exact")
q = F(1, 64)


def p_some_alive(n):
    tot = F(0)
    for k in range(1, 11):
        inter = F(0)
        for i in range(0, k + 1):
            base = F(10 - k, 10) + F(k - i, 10) * q          # P(one query avoids the k cells, or hits a
            inter += (-1) ** i * comb(k, i) * base ** n         #   non-excluded one of them with label 1)
        tot += (-1) ** (k + 1) * comb(10, k) * inter
    return tot


for n in (10, 50, 100, 200, 400):
    ex = p_some_alive(n)
    ub = 10 * ((F(9, 10) + F(1, 640)) ** n - F(9, 10) ** n)
    print(f"  n = {n:3d}: exact P[some e_j is a lambda-MAP] = {float(ex):.6e};  union bound = {float(ub):.6e};"
          f"  ratio = {float(ex / ub):.6f}")
# 'some e_j is a MAP at some time <= 400' = 'for some j, the first query at j (if any by time 400) returned 1'
pv = 1 - F(9, 10) ** 400                                          # P(cell j visited by time 400)
p_ever = 1 - (1 - pv * q) ** 10
print(f"  P[some e_j is a MAP at some time <= 400] = {float(p_ever):.6f} exactly (frozen value"
      f" 1 - (63/64)^10 = {float(1 - (1 - q) ** 10):.6f}); the prover simulated 0.1465 (20000 runs, s.e. 0.0025)")

print("\n(B) ceil(log2 C(N,t)) computed by the prover (float lgamma) against exact integers")
LN2 = log(2.0)


def lc_float(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / LN2


def clog(n, k):
    c = comb(n, k)
    return (c - 1).bit_length() if c > 1 else 0


for (N, tmax, where) in ((16, 16, "r4(B), r6"), (256, 256, "r2(A) m=8"), (1024, 1024, "r2(A,B,C), r3"),
                         (4096, 1024, "r2(A) m=12, r2(C)"), (16384, 1024, "r2(A) m=14"), (65536, 4096, "r2(A) m=16")):
    bad = [t for t in range(1, tmax + 1) if ceil(lc_float(N, t)) != clog(N, t)]
    print(f"  N = {N:6d} ({where}): t with a wrong ceiling among 1..{tmax}: {bad[:8]}{' ...' if len(bad) > 8 else ''}"
          f"  (float ceil {[ceil(lc_float(N, t)) for t in bad[:3]]} vs exact {[clog(N, t) for t in bad[:3]]})")

# r4(B) recomputed with exact lengths
NC, SN = 16, 2
QB = [j / 8 for j in range(8)]
p = SN / NC


def gam(t):
    return 2 * floor(log2(t + 1)) + 1


def table(LENA, c_list, n_list):
    out = {}
    QQ = np.array(QB)
    for c in c_list:
        for n in n_list:
            K = np.array([cc[::-1] for cc in itertools.combinations_with_replacement(range(n + 1), SN) if sum(cc) <= n],
                         np.int64)
            mult = np.array([factorial(SN) // np.prod([factorial(list(r).count(v)) for v in set(r)]) for r in K], float)
            sk = K.sum(axis=1)
            rest = n - sk
            lg = np.vectorize(lgamma)
            prob = mult * np.exp(lgamma(n + 1) - lg(K + 1).sum(axis=1) - lg(rest + 1) + sk * log(1 / NC)
                                 + rest * log((NC - SN) / NC))
            cum = np.concatenate([np.zeros((len(K), 1), np.int64), np.cumsum(K, axis=1)], axis=1)
            nhit = (K > 0).sum(axis=1)
            lam = c * n
            bestJ = np.full(len(K), 2 * lam + float(n))
            lab = np.full(len(K), "coin", dtype=object)
            for t in range(SN + 1):
                D = (sk - cum[:, t])[:, None]
                with np.errstate(divide="ignore", invalid="ignore"):
                    v = D * (-np.log2(QQ))[None, :] + rest[:, None] * (-np.log2(1 - QQ))[None, :]
                v = np.where(np.isnan(v), 0.0, v)
                j = np.argmin(v, axis=1)
                J = lam * LENA[t] + v[np.arange(len(K)), j]
                better = (nhit >= t) & (J < bestJ - 1e-9)
                bestJ = np.where(better, J, bestJ)
                lb = np.where(QQ[j] == p, "human", "H(other q)") if t == 0 else np.full(len(K), f"alien t={t}", object)
                lab = np.where(better, lb, lab)
            out[(c, n)] = {k: float(prob[lab == k].sum()) for k in np.unique(lab)}
    return out


LEN_float = [5] + [5 + gam(t) + ceil(lc_float(NC, t)) for t in range(1, SN + 1)]
LEN_exact = [5] + [5 + gam(t) + clog(NC, t) for t in range(1, SN + 1)]
print(f"  r4(B) lengths: prover {LEN_float}, exact {LEN_exact}")
RH = -p * log2(p) - (1 - p) * log2(1 - p)
QQs = [qq for qq in QB if qq > 0]
pr1 = (SN - 1) / (NC - 1)
R1 = (1 - 1 / NC) * min(-pr1 * log2(qq) - (1 - pr1) * log2(1 - qq) for qq in QQs)
sp = max((RH - R1) / (LEN_float[1] - 5), RH / (LEN_float[2] - 5))    # as in r4(B): attained by t = 2
sm = (1 - RH) / (5 - 2)
cl = [0.03, sp * 1.05, (sp * sm) ** 0.5]                           # the c values of r4(B)
nl = [16, 64, 256, 1024]
A = table(LEN_float, cl, nl)
B = table(LEN_exact, cl, nl)
print(f"  window (s_+, s_-) = ({sp:.4f}, {sm:.4f}) with either lengths (s_+ is attained by t = 2);"
      " the 'prover lengths' rows reproduce r4(B)'s printed table")
for key in A:
    ka = ", ".join(f"{k} {v:.4f}" for k, v in sorted(A[key].items(), key=lambda kv: -kv[1]) if v > 5e-5)
    kb = ", ".join(f"{k} {v:.4f}" for k, v in sorted(B[key].items(), key=lambda kv: -kv[1]) if v > 5e-5)
    flag = "" if ka == kb else "   <-- differs"
    print(f"  c={key[0]:.4f} n={key[1]:3d}: prover lengths: {ka}\n                     exact lengths:  {kb}{flag}")
