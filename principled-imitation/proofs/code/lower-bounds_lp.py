#!/usr/bin/env python3
"""Exact minimax values, by linear programming, for the small cases of
lower-bounds.md: Theorem 2.1 (needle class, questions before the run),
Proposition 2.5 (questions during the run) and Theorem 4.1 (N disjoint shifts).

A randomised protocol is a mixture of deterministic ones, and a deterministic
protocol for these classes is determined by (i) the set S of cells asked while
all answers are 0 and (ii) the outcome g it deploys after that all-zero
transcript, as a function of the set U of cells that the run visits (once a 1
has been seen the target is known and the error is 0).  The LP minimises the
largest failure probability over the members of the class.
"""
import itertools
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog


def law_of_visited_set(N0, L):
    """Law of set(z) for z uniform on [N0]^L, as {frozenset: probability}."""
    law = {}
    for z in itertools.product(range(N0), repeat=L):
        U = frozenset(z)
        law[U] = law.get(U, 0) + Fraction(1, N0 ** L)
    return law


def minimax_before(N0, L, n):
    """Theorem 2.1: at most n questions, all asked before z is drawn."""
    law = law_of_visited_set(N0, L)
    Us = list(law)
    cols = []
    for S in itertools.combinations(range(N0), n):
        Sset = set(S)
        for g in itertools.product((0, 1), repeat=len(Us)):
            err = [float(sum(law[U] for U, gv in zip(Us, g) if gv == 1))]  # f_0
            for i in range(N0):
                if i in Sset:
                    err.append(0.0)
                else:
                    err.append(float(sum(law[U] for U, gv in zip(Us, g)
                                         if gv != (1 if i in U else 0))))
            cols.append(err)
    A = np.array(cols).T                      # (N0+1) x (#pure protocols)
    k = A.shape[1]
    c = np.zeros(k + 1); c[-1] = 1.0          # minimise v
    A_ub = np.hstack([A, -np.ones((A.shape[0], 1))])
    res = linprog(c, A_ub=A_ub, b_ub=np.zeros(A.shape[0]),
                  A_eq=np.hstack([np.ones((1, k)), np.zeros((1, 1))]), b_eq=[1.0],
                  bounds=[(0, None)] * k + [(None, None)], method="highs")
    return res.fun


def minimax_during(N0, L, n):
    """Proposition 2.5: z is seen first, then at most n questions are asked."""
    law = law_of_visited_set(N0, L)
    cols, blocks = [], []                     # one block of columns per U
    for U in law:
        start = len(cols)
        if len(U) <= n:                       # ask all visited cells: no error
            cols.append([0.0] * (N0 + 1))
        else:
            for S in itertools.combinations(sorted(U), n):
                for g in (0, 1):
                    err = [float(law[U]) * (g == 1)]
                    for i in range(N0):
                        if i in S:
                            err.append(0.0)
                        else:
                            err.append(float(law[U]) * (g != (1 if i in U else 0)))
                    cols.append(err)
        blocks.append((start, len(cols)))
    A = np.array(cols).T
    k = A.shape[1]
    c = np.zeros(k + 1); c[-1] = 1.0
    A_ub = np.hstack([A, -np.ones((A.shape[0], 1))])
    A_eq = np.zeros((len(blocks), k + 1))
    for b, (s, e) in enumerate(blocks):
        A_eq[b, s:e] = 1.0
    res = linprog(c, A_ub=A_ub, b_ub=np.zeros(A.shape[0]), A_eq=A_eq,
                  b_eq=np.ones(len(blocks)),
                  bounds=[(0, None)] * k + [(None, None)], method="highs")
    return res.fun


def maximin_shifts(N, n):
    """Theorem 4.1: largest eta such that every member is answered correctly
    with probability >= 1/2 + eta under every one of the N deployment laws."""
    cols = []
    for I in itertools.combinations(range(N), n):
        for b in itertools.product((0, 1), repeat=N):   # answer on Q_i after zeros
            succ = []
            for i in range(N):                           # deployment law D_i
                succ.append(1.0 - b[i])                  # member f_0
                for j in range(N):                       # member f_j
                    if j in I:
                        succ.append(1.0)
                    else:
                        succ.append(float(b[i]) if i == j else 1.0 - b[i])
            cols.append(succ)
    A = np.array(cols).T
    k = A.shape[1]
    c = np.zeros(k + 1); c[-1] = -1.0                    # maximise s
    A_ub = np.hstack([-A, np.ones((A.shape[0], 1))])     # s <= success
    res = linprog(c, A_ub=A_ub, b_ub=np.zeros(A.shape[0]),
                  A_eq=np.hstack([np.ones((1, k)), np.zeros((1, 1))]), b_eq=[1.0],
                  bounds=[(0, None)] * k + [(None, None)], method="highs")
    return -res.fun - 0.5


if __name__ == "__main__":
    print("Theorem 2.1: lower bound (N0-n)p/(N0+L) <= minimax <= (N0-n)p/N0")
    print(" N0  L  n   lower      minimax(LP)  upper")
    for N0, L in ((3, 2), (4, 2), (5, 2), (4, 3)):
        p = 1 - (1 - 1 / N0) ** L
        for n in range(0, N0):
            v = minimax_before(N0, L, n)
            lo, up = (N0 - n) * p / (N0 + L), (N0 - n) * p / N0
            assert lo <= v + 1e-9 and v <= up + 1e-9
            print(f"{N0:3d} {L:2d} {n:2d}   {lo:.6f}   {v:.6f}     {up:.6f}")
    print()
    print("Proposition 2.5: lower bound (N0*p-n)/(N0+L) <= minimax (questions during the run)")
    print(" N0  L  n   lower      minimax(LP)")
    for N0, L in ((4, 2), (5, 3), (6, 3), (8, 4)):
        p = 1 - (1 - 1 / N0) ** L
        for n in range(0, L + 1):
            v = minimax_during(N0, L, n)
            lo = max(0.0, (N0 * p - n) / (N0 + L))
            assert lo <= v + 1e-9
            print(f"{N0:3d} {L:2d} {n:2d}   {lo:.6f}   {v:.6f}")
    print()
    print("Theorem 4.1: best advantage eta over 1/2 with n questions and N shifts; claim eta = n/(2N)")
    print("  N  n   eta(LP)    n/(2N)")
    for N in (2, 3, 4, 5):
        for n in range(0, N + 1):
            eta = maximin_shifts(N, n)
            assert abs(eta - n / (2 * N)) < 1e-7
            print(f"{N:3d} {n:2d}   {eta:.6f}   {n / (2 * N):.6f}")
