#!/usr/bin/env python3
"""rb8_craig_arith.py -- referee B: Example 3.4's numbers recomputed from first principles (no code from s2).

Scout S's s2_craig_blowup.py (Example 3.4) could not be rerun here: the container killed it twice for memory
(peak resident size above 12 GB while other jobs ran).  The rows marked '+' in its output are closed-form lower
bounds that do not depend on its search order, so they can be recomputed independently:
  * candidate lines for |w| = n: the atoms E(t_u), O(t_u), R(t_u) and the negated R(t_u), |u| <= n:
    N = 4 (2^(n+1) - 1);
  * a shortest derivation of the datum has L* = n + 2 lines (E(e), the parity atom of every proper suffix of w
    and of w, then the R-literal); no shorter derivation exists, because every line needs its premise earlier;
  * its symbol size d_T = sum_{j=0..n} (j + 2) + (n + 2) + [w has an odd number of 1s];
  * canonical search tests every sequence of fewer than L* lines first: k >= sum_{L=1}^{L*-1} N^L;
  * Craig's axiom (phi^b)^{&(k+1)} has at least (k+1)|phi^b| symbols, |phi^b| = n + 2 + [b = 0].
The words are regenerated with s2's seed and call sequence (random.Random(20261015), rng.choice("01") per letter,
lengths 1..12, 16, 20, 24) and compared with the truncated samples printed in s2_craig_blowup.out.
Deterministic.  Writes rb8_craig_arith.out next to itself.
"""
import math
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb8_craig_arith.out")
LOG = []


def log(x=""):
    print(x)
    LOG.append(x)


# rows of the saved s2_craig_blowup.out: |w|, sample prefix, N_cand, L*, d_T, log10(k), log10 Craig axiom
SAVED = [
    (1, "0", 12, 3, 8, 2.25, 2.73), (2, "01", 28, 4, 14, 4.48, 5.18), (3, "100", 60, 5, 20, 7.13, 7.91),
    (4, "0011", 124, 6, 26, 10.57, 11.35), (5, "10100", 252, 7, 34, 14.41, 15.26),
    (6, "001010", 508, 8, 43, 18.94, 19.84), (7, "1100001", 1020, 9, 54, 24.07, 25.07),
    (8, "10011000", 2044, 10, 65, 29.79, 30.84), (9, "001010101", 4092, 11, 76, 36.12, 37.16),
    (10, "0100010011", 8188, 12, 89, 43.05, 44.12), (11, "01110100100", 16380, 13, 104, 50.57, 51.72),
    (12, "111100101011", 32764, 14, 118, 58.70, 59.85), (16, "0001110000000111", 524284, 18, 188, 97.23, 98.49),
    (20, "00010111110011100000", 8388604, 22, 275, 145.40, 146.76),
    (24, "10000011100001101101", 134217724, 26, 376, 203.20, 204.61)]


def log10_sum_pow(N, top):
    """log10 of sum_{L=1}^{top} N^L, computed stably."""
    return top * math.log10(N) + math.log10(sum(N ** (L - top) for L in range(1, top + 1)))


def main():
    log("rb8_craig_arith.py -- referee B: Example 3.4 recomputed in closed form")
    rng = random.Random(20261015)
    ok = True
    log("  |w|  N_cand  L*  d_T  log10 k (lower bound)  log10 Craig axiom (lower bound)   saved row agrees")
    for n in list(range(1, 13)) + [16, 20, 24]:
        w = "".join(rng.choice("01") for _ in range(n))
        N = 4 * (2 ** (n + 1) - 1)
        Lstar = n + 2
        odd = w.count("1") % 2
        dT = sum(j + 2 for j in range(n + 1)) + (n + 2) + odd
        lk = log10_sum_pow(N, Lstar - 1)
        phi = n + 2 + odd
        lc = math.log10(10 ** (lk - math.floor(lk)) + 10 ** (-math.floor(lk))) + math.floor(lk) + math.log10(phi)
        row = next(r for r in SAVED if r[0] == n)
        agree = (w.startswith(row[1]) and N == row[2] and Lstar == row[3] and dT == row[4]
                 and (n <= 4 or (abs(lk - row[5]) < 0.006 and abs(lc - row[6]) < 0.006)))
        log(f"  {n:3d} {N:9d} {Lstar:3d} {dT:4d}  {lk:10.2f}  {lc:10.2f}   {agree}")
        ok &= agree
    log("  (rows |w| <= 4 are exact counts in s2, depending on its search order; only N, L*, d_T compared there)")
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
