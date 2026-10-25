"""C1: exact / upper log-cardinalities of the three certificate classes for d = 30 (Propositions C1.2-C1.4).
Also brute-force checks for small d: (a) the circuit-count bound (Prop C1.3) against the exact number of functions of
circuit size <= T over B_2 for d = 2, 3; (b) the exact junta count (Prop C1.4) for d = 3, 4 by enumeration;
(c) the Fourier-sign count against brute force for d = 3."""
import math, itertools, sys
import numpy as np
sys.dont_write_bytecode = True
import c_common as cc

d = 30


def lnF(k, T, d=d):
    Dk = sum(math.comb(d, i) for i in range(1, k + 1))
    return cc.log_binom(Dk, T) + cc.log_Phi(2 ** min(T, d), T)


def lnC(T, d=d):
    terms = [s * math.log(16 * (d + s) ** 2) + math.log(d + s) - math.lgamma(s + 1) for s in range(T + 1)]
    return cc.logsumexp(terms)


def N_ess(j):
    return sum((-1) ** (j - i) * math.comb(j, i) * 2 ** (2 ** i) for i in range(j + 1))


def J_exact(k, d=d):
    return sum(math.comb(d, j) * N_ess(j) for j in range(k + 1))


def brute_circuits(dd, Tmax):
    """exact number of functions {-1,1}^dd -> {-1,1} with B_2-circuit size <= T (output = any wire)."""
    pts = list(itertools.product([0, 1], repeat=dd))
    N = len(pts)
    full = (1 << N) - 1
    inputs = set()
    for i in range(dd):
        v = 0
        for p_idx, p in enumerate(pts):
            if p[i]:
                v |= 1 << p_idx
        inputs.add(v)
    ops = []
    for tt in range(16):  # truth table of a binary op on bits (a,b)
        ops.append(tt)

    def apply(tt, a, b):
        out = 0
        for (ba, bb) in [(0, 0), (0, 1), (1, 0), (1, 1)]:
            if (tt >> (2 * ba + bb)) & 1:
                ma = a if ba else (~a & full)
                mb = b if bb else (~b & full)
                out |= ma & mb
        return out
    # BFS over sets of computed wires (small sizes only)
    frontier = {frozenset(inputs)}
    reach = {0: set(inputs)}
    seen_all = set(inputs)
    for T in range(1, Tmax + 1):
        new_frontier = set()
        for W in frontier:
            Wl = list(W)
            for a in Wl:
                for b in Wl:
                    for tt in ops:
                        v = apply(tt, a, b)
                        if v not in W:
                            new_frontier.add(W | {v})
        frontier = new_frontier
        cur = set()
        for W in frontier:
            cur |= W
        seen_all |= cur
        reach[T] = set(seen_all)
    return {T: len(reach[T]) for T in reach}


def brute_juntas(dd, k):
    pts = np.array(list(itertools.product([-1, 1], repeat=dd)))
    funcs = set()
    for j in range(k + 1):
        for R in itertools.combinations(range(dd), j):
            for tab in itertools.product([-1, 1], repeat=2 ** j):
                keys = ((pts[:, list(R)] > 0).astype(int) * (2 ** np.arange(j))).sum(1) if j else np.zeros(len(pts), int)
                funcs.add(tuple(np.array(tab)[keys]))
    return len(funcs)


def brute_fourier(dd, k, T, trials=200000, seed=0):
    """lower estimate of |F_{k,T}| on {-1,1}^dd by random weights (exhaustive enumeration of thresholds is hard);
    reported only as a sanity check that the upper bound is not violated."""
    rng = np.random.default_rng(seed)
    pts = np.array(list(itertools.product([-1, 1], repeat=dd)))
    sets = [S for j in range(1, k + 1) for S in itertools.combinations(range(dd), j)]
    chi = np.ones((len(pts), len(sets)))
    for c, S in enumerate(sets):
        for i in S:
            chi[:, c] *= pts[:, i]
    found = set()
    for supp in itertools.combinations(range(len(sets)), T):
        Z = chi[:, list(supp)]
        W = rng.standard_normal((trials // 20, T + 1)) * np.array([3.0] + [1.0] * T)
        vals = W[:, :1] + W[:, 1:] @ Z.T
        for row in np.where(vals >= 0, 1, -1):
            found.add(tuple(row))
    return len(found)


if __name__ == "__main__":
    print("Prop C1.2  log|F_{k,T}| (nats), d=30:  log C(D_k,T) + log Phi(2^min(T,d), T)")
    for k in (1, 2, 3, 4):
        print(f"  k={k}: " + "  ".join(f"T={T}:{lnF(k, T):.1f}" for T in (1, 2, 3, 4, 6, 8, 9, 10, 12, 16, 20)))
    print("Prop C1.3  log|C_{<=T}| (nats), d=30, B_2 circuits:")
    print("  " + "  ".join(f"T={T}:{lnC(T):.1f}" for T in range(0, 13)))
    print("  (without the 1/s! saving: " + "  ".join(
        f"T={T}:{cc.logsumexp([s * math.log(16 * (d + s) ** 2) + math.log(d + s) for s in range(T + 1)]):.1f}"
        for T in (2, 4, 8, 12)) + ")")
    print("Prop C1.4  |J_{<=k}| exact, d=30:")
    for k in range(0, 7):
        J = J_exact(k)
        print(f"  k={k}: N_k(essential)={N_ess(k)}  |J_<=k|={J}  ln={math.log(J):.2f}  "
              f"(simple bound ln[C(30,k) 2^(2^k)] = {cc.log_binom(30, k) + 2 ** k * math.log(2):.2f})")
    print("Brute-force checks:")
    for dd in (2, 3):
        ex = brute_circuits(dd, 3 if dd == 2 else 2)
        for T, v in ex.items():
            print(f"  d={dd} T={T}: exact #functions with B_2-circuit size <= T = {v};  Prop C1.3 bound = "
                  f"{math.exp(lnC(T, dd)):.0f}")
    for dd, k in ((3, 2), (4, 2), (4, 3)):
        print(f"  d={dd} k={k}: juntas by enumeration = {brute_juntas(dd, k)}; formula = {J_exact(k, dd)}")
    for dd, k, T in ((3, 1, 2), (3, 2, 2), (3, 1, 3)):
        lo = brute_fourier(dd, k, T)
        print(f"  d={dd} k={k} T={T}: Fourier-sign functions found by random search >= {lo};  Prop C1.2 bound = "
              f"{math.exp(lnF(k, T, dd)):.0f}")
