"""e3: Haenni's cyclic-permutation example (track notes §2).

(a) Exact constants: log2((2^n - 1)!), its Stirling form (n - log2 e) 2^n - n/2 + log2(2 pi)/2,
    the per-pair average, and the k-step quantities log2((N-1)_k) and the lower-bound
    term log2((N-1)_k) - log2(N-1)   (Thms 2.1, 2.2).
(b) Proxies on random cyclic permutations (n = 2..12): order-free x-only mixture
    (SFI proxy), history-aware mixture (SFI^hist proxy), and an SI-like mixture of
    joint models of the interleaved sequence (blocks of n bits as symbols).
(c) Exhaustive check for n = 2, 3 of the counting facts used in the proofs:
    the map (ordering of nonzero strings) -> cyclic permutation is a bijection, and the
    uniform cyclic-permutation law gives P(f extends D_k) = 1/(N-1)_k (k <= N-1).

Seed 20261011; output in e3_cyclic.out.txt.
"""
import itertools
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..", "..", "..", "code")))
import sfi_examples as se  # noqa: E402

OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def main():
    say("e3_cyclic.py  seed=20261011")
    LOG2E = math.log2(math.e)
    say("")
    say("(a) exact constants, N = 2^n")
    say("   n |  log2((N-1)!)        Stirling            diff      | per pair (/N)  n - log2 e | log2(N-1)")
    for n in list(range(1, 21)) + [24, 32, 40, 64]:
        N = 2 ** n
        exact = math.lgamma(N) / math.log(2)          # log2((N-1)!)
        stir = (n - LOG2E) * N - n / 2 + 0.5 * math.log2(2 * math.pi)
        say(f"{n:4d} | {exact:18.6f} {stir:18.6f} {exact - stir:12.3e} | {exact / N:12.6f}  {n - LOG2E:9.6f} | {math.log2(N-1):9.4f}")
    say("   (the Stirling error is 1/(12 N ln 2) + O(N^-3) - log2 correction of (N-1)! vs N!/N, i.e. O(1/N))")
    say("")
    say("    k-step quantities for n = 10 (N = 1024): upper bound log2((N-1)_k) + c, "
        "lower bound log2((N-1)_k) - log2(N-1) - m - c")
    n = 10
    N = 2 ** n
    for k in [1, 2, 4, 16, 64, 256, 512, 1000, 1023]:
        fk = se.log2_falling(N - 1, k)
        say(f"    k={k:5d}: log2((N-1)_k) = {fk:12.3f}   minus log2(N-1) = {fk - math.log2(N-1):12.3f}   "
            f"k*n = {k*n:6d}   log2(k!) = {math.lgamma(k+1)/math.log(2):10.3f}")

    # (b) proxies
    say("")
    say("(b) proxies on random cyclic permutations (3 seeds each); cumulative losses in bits")
    say("   n     N |  k=1: SFIprx  hist  SIlab | k=N/2: SFIprx  cyc-alone  hist  SIlab | "
        "k=N: SFIprx   log2((N-1)!)  hist  SIlab")
    rng = np.random.default_rng(20261011)
    for n in range(2, 13):
        N = 2 ** n
        for rep in range(3):
            out = se.cyclic_example_losses(n, rng, checkpoints=sorted(set([1, max(1, N // 2), N])))
            k1, kh, kN = 1, max(1, N // 2), N
            say(f"{n:4d} {N:5d} | {out['sfi'][k1]:9.3f} {out['hist'][k1]:6.3f} {out['si_label'][k1]:6.3f} | "
                f"{out['sfi'][kh]:12.3f} {out['cyc_alone'][kh]:10.3f} {out['hist'][kh]:6.3f} {out['si_label'][kh]:6.3f} | "
                f"{out['sfi'][kN]:11.3f} {math.lgamma(N)/math.log(2):13.3f} {out['hist'][kN]:6.3f} {out['si_label'][kN]:6.3f}")
    say("   SFIprx = -log2 of the x-only mixture (1/6 each: cyclic, permutation, function laws;")
    say("            zero, identity, successor maps); hist = history-aware mixture (1/3 each: copy-previous-input,")
    say("            uniform, uniform-over-unused-labels); SIlab = label loss of the joint-model mixture")
    say("            (1/3 each: true process; true inputs + uniform labels; all uniform).")

    # (c) exhaustive checks
    say("")
    say("(c) exhaustive counting checks")
    for n in [2, 3]:
        N = 2 ** n
        nonzero = list(range(1, N))
        cyc = set()
        for order in itertools.permutations(nonzero):
            f = {order[0]: 0}
            for i in range(1, N - 1):
                f[order[i]] = order[i - 1]
            f[0] = order[-1]
            # check single N-cycle
            x, seen = 0, set()
            for _ in range(N):
                seen.add(x)
                x = f[x]
            assert x == 0 and len(seen) == N
            cyc.add(tuple(f[i] for i in range(N)))
        # count all cyclic permutations directly
        allcyc = 0
        for perm in itertools.permutations(range(N)):
            x, L = 0, 0
            while True:
                x = perm[x]
                L += 1
                if x == 0:
                    break
            allcyc += (L == N)
        say(f"    n={n}: orderings -> {len(cyc)} distinct cyclic permutations; total cyclic permutations = {allcyc}; (N-1)! = {math.factorial(N-1)}")
        # P(f extends D_k) under the uniform cyclic law, for one fixed ordering, all k
        order = nonzero[::-1]
        cycl = [list(c) for c in cyc]
        for k in range(1, N):
            D = [(order[0], 0)] + [(order[i], order[i - 1]) for i in range(1, k)]
            cnt = sum(all(c[x] == y for x, y in D) for c in cycl)
            assert cnt * math.prod(range(N - k, N)) == len(cycl), (n, k, cnt)
        say(f"    n={n}: P(cyclic f extends D_k) = 1/(N-1)_k verified for k = 1..{N-1}")

    with open(os.path.join(HERE, "e3_cyclic.out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
