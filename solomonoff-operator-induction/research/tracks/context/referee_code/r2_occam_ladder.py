"""r2 (referee): the "conjunction ladder" (Vaintrob-Hanni slides, Appendix K) against the context notes'
Remark 3.10 / open problem 5, which say that a super-polynomial worst-case mistake bound for Occam
(simplest-consistent) learning in a *natural* circuit language is open.

Languages (both as in the context notes):
  * formulas: leaves x_j, not x_j, 0, 1; binary nodes AND, OR, XOR; size = number of leaves (notes Rem 3.6, c1);
  * circuits: gate lists over all 16 two-input gates, size = number of gates (notes Sec 3.2).
Occam = the consistent function of least size, ties broken by truth-table index (as in c1).
Target f = AND of all d variables (formula size d, circuit size d-1).
Ordering (adaptive adversary, "ladder"): all-ones, then all-zeros, then the inputs by ascending Hamming
weight; inside a level the adversary picks an input on which the current Occam hypothesis errs, if any.
We count Occam's mistakes and compare with 2^d and with the target's description length.
Also checks the ladder lemma: when the data are "h(1..1)=1 and h(x)=0 for |x|<k", the least-size
consistent functions are exactly the k-variable conjunctions (formulas: size k; circuits: size k-1, k>=2).
Deterministic.
"""
import math
import numpy as np

out = []


def tt_var(d, j):
    NP = 1 << d
    return sum(1 << i for i in range(NP) if (i >> j) & 1)


def formula_min_sizes(d, smax):
    """dict truth-table -> min formula size, for all functions of size <= smax."""
    NP = 1 << d
    FULL = (1 << NP) - 1
    leaves = set()
    for j in range(d):
        t = tt_var(d, j)
        leaves |= {t, FULL ^ t}
    leaves |= {0, FULL}
    dt = np.uint64 if NP == 64 else (np.uint32 if NP == 32 else np.uint16 if NP == 16 else np.uint8)
    F = {1: np.array(sorted(leaves), dtype=dt)}
    best = {int(t): 1 for t in F[1]}
    for s in range(2, smax + 1):
        new = []
        for a in range(1, s):
            b = s - a
            if a > b:
                break  # AND, OR, XOR are commutative
            A, B = F[a], F[b]
            for i0 in range(0, len(A), 2048):
                Ac = A[i0:i0 + 2048][:, None]
                for op in (np.bitwise_and, np.bitwise_or, np.bitwise_xor):
                    new.append(np.unique(op(Ac, B[None, :]).ravel()))
        allnew = np.unique(np.concatenate(new))
        fresh = [int(t) for t in allnew if int(t) not in best]
        for t in fresh:
            best[t] = s
        F[s] = allnew  # all functions computable at size exactly s (used for further combination)
    return best


def circuit_min_sizes(d, smax):
    """dict truth-table -> min circuit size (gate count, all 16 gates), for size <= smax (smax <= 3)."""
    NP = 1 << d
    FULL = (1 << NP) - 1
    base = [tt_var(d, j) for j in range(d)] + [0, FULL]

    def gate_all(u, v):
        # all 16 two-input functions of u, v (as truth tables)
        res = set()
        for g in range(16):
            # g's truth table bits: g(a,b) = (g >> (2a+b)) & 1
            t = 0
            for a in (0, 1):
                for b in (0, 1):
                    if (g >> (2 * a + b)) & 1:
                        ua = u if a else FULL ^ u
                        vb = v if b else FULL ^ v
                        t |= ua & vb
            res.add(t)
        return res

    best = {}
    # size 1
    lvl1 = set()
    for u in base:
        for v in base:
            lvl1 |= gate_all(u, v)
    for t in lvl1:
        best.setdefault(t, 1)
    if smax == 1:
        return best
    # size 2: prefixes (h1), last gate on base + {h1}
    pairs = set()
    for h1 in lvl1:
        avail = base + [h1]
        for u in avail:
            for v in avail:
                for t in gate_all(u, v):
                    best.setdefault(t, 2)
                    if smax >= 3:
                        pairs.add((h1, t) if h1 <= t else (t, h1))
    if smax == 2:
        return best
    # size 3: last gate on base + {h1, h2}
    for (h1, h2) in pairs:
        avail = base + [h1, h2]
        for u in avail:
            for v in avail:
                for t in gate_all(u, v):
                    best.setdefault(t, 3)
    return best


def ladder(d, best, label):
    NP = 1 << d
    FULL = (1 << NP) - 1
    f = 1 << (NP - 1)  # AND_d: only the all-ones input (index NP-1) is 1
    funcs = np.array(sorted(best), dtype=object)
    keys = sorted(best, key=lambda t: (best[t], t))
    order_rank = {t: r for r, t in enumerate(keys)}
    keys_arr = keys
    seen_mask = 0
    seen_vals = 0
    mistakes = 0
    steps = 0

    def occam():
        for t in keys_arr:
            if (t ^ seen_vals) & seen_mask == 0:
                return t
        return None

    levels = [[NP - 1], [0]] + [[i for i in range(NP) if bin(i).count("1") == w and i != NP - 1]
                                for w in range(1, d)]
    for lvl in levels:
        remaining = list(lvl)
        while remaining:
            h = occam()
            pick = None
            for i in remaining:
                if ((h >> i) & 1) != ((f >> i) & 1):
                    pick = i
                    break
            if pick is None:
                pick = remaining[0]
            if ((h >> pick) & 1) != ((f >> pick) & 1):
                mistakes += 1
            steps += 1
            remaining.remove(pick)
            seen_mask |= 1 << pick
            if (f >> pick) & 1:
                seen_vals |= 1 << pick
    # ladder lemma: least-size consistent with "h(1..1)=1, h(x)=0 for |x|<k" are exactly k-conjunctions
    lemma_ok = True
    for k in range(1, d + 1):
        mask = (1 << (NP - 1)) | sum(1 << i for i in range(NP) if bin(i).count("1") < k)
        vals = 1 << (NP - 1)
        cons = [t for t in best if (t ^ vals) & mask == 0]
        m = min(best[t] for t in cons)
        mins = sorted(t for t in cons if best[t] == m)
        conj = sorted(sum(1 << i for i in range(NP) if (i & S) == S)
                      for S in range(NP) if bin(S).count("1") == k)
        expect_size_ok = True
        if label == "formula":
            expect_size_ok = (m == k)
            ok = expect_size_ok and mins == conj
        else:
            ok = (k == 1) or ((m == k - 1) and mins == conj)
        lemma_ok &= ok
    return mistakes, steps, lemma_ok


for d in [3, 4, 5]:
    best = formula_min_sizes(d, d)
    mis, steps, lemma = ladder(d, best, "formula")
    desc = math.log2(math.comb(2 * (d - 1), d - 1) // d) + (d - 1) * math.log2(3) + d * math.log2(2 * d + 2) + d
    out.append(f"formulas d={d}: #functions of size<=d: {len(best)}; Occam mistakes on the ladder for AND_d: "
               f"{mis} of {steps} inputs (2^d = {1 << d}); ladder lemma holds for all k: {lemma}; "
               f"description length of AND_d in the c1 code (unary size + uniform tree) ~ {desc:.1f} bits")

for d in [3, 4]:
    best = circuit_min_sizes(d, d - 1)
    mis, steps, lemma = ladder(d, best, "circuit")
    out.append(f"circuits d={d}: #functions of size<=d-1: {len(best)}; Occam mistakes on the ladder for AND_d: "
               f"{mis} of {steps} inputs (2^d = {1 << d}); ladder lemma (k>=2) holds: {lemma}")

out.append("Asymptotics (proof in the slides, Appendix K, checked here for small d): mistakes >= sum_{k<d} C(d,k) "
           "= 2^d - 1 - ... while the description length of AND_d is Theta(d log d); so worst-case Occam mistakes "
           "are 2^{Omega(l/log l)} in these natural languages.")
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
