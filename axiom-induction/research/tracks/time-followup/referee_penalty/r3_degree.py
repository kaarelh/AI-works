"""r3: weight arithmetic behind the degree asymmetry of Cor 4.3(e) in time-followup notes.md.

FIcons_poly mixes pairs (f, k), clock (m+2)^k, weight w(f) 2^-(2 ceil(log2(k+1)) + 1); AI[poly, poly] mixes pairs (p, j),
weight 2^-(|p| + 2 ceil(log2(j+1)) + 1), and does NOT charge the degree of p's membership time.

Part A: the total FIcons_poly weight of all hypotheses with clock exponent k >= K is at most
        T(K) := sum_{k >= K} 2^-(2 ceil(log2(k+1)) + 1)   (since sum_f w(f) <= 1);
        for K = 2^e - 1 it is 2^-(2e+1) + 2^-(e+2).  So -log2 T(K) = log2(K+1) + 2 - o(1).
Part B: the illustration.  For N = 2^(2^r) let X_N be a hierarchy language in DTIME(m^N) outside DTIME(q((m+2)^k)) for
        all k < N/b (b the polynomial simulation overhead exponent; deterministic time hierarchy), described by a
        program of length c0 + |delta(r)|.  On D^{X_N}: AI[poly, poly] has the hypothesis (p, j = 1) (p decides the
        literals {+-R(w)} in time m^(N+1); every datum is itself an axiom), so its loss is at most c0 + |delta(r)| + 3
        for every n; every FIcons_poly hypothesis that fits all of D^{X_N} has k >= N/b, so the FIcons_poly loss tends
        to at least -log2 T(N/b).  The printed regret lower bound grows like 2^r: FIcons_poly does not dominate
        AI[poly, poly], unconditionally, whatever P vs NP.  (c0 = 300 bits and b = 4 are placeholders; any constants
        give the same growth.)
"""
import math

out = []


def T(K):
    """sum_{k >= K} 2^-(2 ceil(log2(k+1)) + 1), exactly, as a float."""
    tot = 0.0
    k = K
    # finish the current dyadic block, then add whole blocks: block i = {k : 2^(i-1) < k+1 <= 2^i}, mass 2^-(i+2)
    i = math.ceil(math.log2(k + 1)) if k > 0 else 0
    if k == 0:
        tot += 2.0 ** -1
        k = 1
        i = 1
    last = 2 ** i - 1                     # largest k in block i
    tot += (last - k + 1) * 2.0 ** -(2 * i + 1)
    for ii in range(i + 1, i + 200):
        tot += 2.0 ** -(ii + 2)
    return tot


out.append("Part A: -log2 of the FIcons_poly weight with clock exponent >= K")
out.append(f"{'K':>14} {'-log2 T(K)':>11} {'log2 K':>8}")
for e in [1, 2, 4, 8, 16, 32, 48]:
    K = 2 ** e - 1
    out.append(f"{K:>14} {-math.log2(T(K)):>11.3f} {math.log2(K):>8.3f}")
out.append("")


def delta_len(n):
    N = n.bit_length() - 1
    return N + 2 * ((N + 1).bit_length() - 1) + 1


out.append("Part B: regret lower bound of FIcons_poly against AI[poly, poly] on D^{X_N}, N = 2^(2^r)")
c0, b = 300, 4
out.append(f"{'r':>3} {'log2 N':>8} {'AI loss <=':>11} {'FI loss ->>=':>13} {'regret >=':>10}")
for r in range(1, 13):
    log2N = 2 ** r
    ai = c0 + delta_len(r) + 3
    fi = log2N - math.log2(b) + 2        # -log2 T(N/b) = log2(N/b) + 2 - o(1)  (Part A)
    out.append(f"{r:>3} {log2N:>8} {ai:>11} {fi:>13.1f} {fi - ai:>10.1f}")
out.append("  -> the bound is negative for small r and grows like 2^r: sup over sequences of the regret is infinite.")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
