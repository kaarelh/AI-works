# e14 (revision): the refutation test of DTRC step 2 is NP-complete (Thm H.5).
# D = {d1, d2}, d1 = Ax /\_j (x = a_j), d2 = Ax /\_j (a_j = a_j) (a_j distinct parameters).
# Min(D) = {T_A : A subset of [n]}, T_A = Ax /\_j (f_j(x) = (a_j if j not in A else f_j(a_j))).
# For a clause C the refuted sentence n_C has conjunct j:
#   (x = a_j) if j not in C;  (Sx = a_j) if x_j occurs positively;  (Sx = S a_j) if x_j occurs negatively.
# Claim: n_C in inst(T_A) iff A (read as "x_j true iff j in A") falsifies C.  Hence
#   "some minimal covering template has no instance in R = {n_C}"  iff  the CNF is satisfiable.
# Checks: |Min(D)| = 2^n (from Sat(D), Thm B) and = the T_A; random 3-CNFs: test == satisfiability;
# and the same answer when "minimal" is replaced by "saturated covering" (all of Sat(D)).
# usage: python3 e14_dtrc_step2.py SEED NMAX TRIALS
import sys, random, itertools, time
from dtcore import *
from dtfeat import Prefix

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 1
NMAX = int(sys.argv[2]) if len(sys.argv) > 2 else 4
TR = int(sys.argv[3]) if len(sys.argv) > 3 else 40
rng = random.Random(SEED)


def a(j):
    return ('a%d' % j,)


def conj(fs):
    f = fs[-1]
    for g in reversed(fs[:-1]):
        f = AND(g, f)
    return f


def data(n):
    d1 = ALL(conj([eq(V(0), a(j)) for j in range(n)]))
    d2 = ALL(conj([eq(a(j), a(j)) for j in range(n)]))
    return [d1, d2]


def T_A(n, A):
    return ALL(conj([eq(M('f%d' % j, V(0)), M('f%d' % j, a(j)) if j in A else a(j)) for j in range(n)]))


def neg(n, clause):
    """clause: dict j -> True (positive literal) / False (negative literal)"""
    cs = []
    for j in range(n):
        if j not in clause:
            cs.append(eq(V(0), a(j)))
        elif clause[j]:
            cs.append(eq(S(V(0)), a(j)))
        else:
            cs.append(eq(S(V(0)), S(a(j))))
    return ALL(conj(cs))


t0 = time.time()
for n in range(1, NMAX + 1):
    D = data(n)
    P = Prefix(D)
    mins, reps = P.minimal()
    TAs = [T_A(n, set(A)) for r in range(n + 1) for A in itertools.combinations(range(n), r)]
    same = (len(mins) == 2 ** n and all(any(equivalent(T, U) for U in mins) for T in TAs)
            and all(covers_all(T, D) and is_DT0(T) for T in TAs))
    print('n=%d: |Sat(D)| = %d, |Min(D)| = %d, Min(D) = {T_A}: %s' % (n, len(reps), len(mins), same))
    # literal semantics, exhaustively for single clauses of size <= 3
    sem_ok = True
    for r in range(1, min(3, n) + 1):
        for vars_ in itertools.combinations(range(n), r):
            for signs in itertools.product([True, False], repeat=r):
                C = dict(zip(vars_, signs))
                s = neg(n, C)
                for A in itertools.product([False, True], repeat=n):
                    falsified = all(A[j] != sgn for j, sgn in C.items())
                    TA = T_A(n, {j for j in range(n) if A[j]})
                    if (det_match(TA, s) is not None) != falsified:
                        sem_ok = False
    print('      n_C in inst(T_A) iff A falsifies C (all clauses of size <= 3, all A): %s' % sem_ok)
    # random CNFs
    agree = 0
    nsat = 0
    for t in range(TR):
        m = rng.randint(1, 3 * n + 1)
        cnf = []
        for _ in range(m):
            r = rng.randint(1, min(3, n))
            vs = rng.sample(range(n), r)
            cnf.append({v: rng.random() < 0.5 for v in vs})
        R = [neg(n, C) for C in cnf]
        sat = any(all(any(A[j] == sgn for j, sgn in C.items()) for C in cnf)
                  for A in itertools.product([False, True], repeat=n))
        test_min = any(all(not covers(T, s) for s in R) for T in mins)
        test_sat = any(all(not covers(T, s) for s in R) for T in reps)
        nsat += sat
        agree += (test_min == sat == test_sat)
    print('      %d random CNFs (%d satisfiable): test(Min) = test(Sat) = satisfiable in %d/%d'
          % (TR, nsat, agree, TR))
print('time %.1fs' % (time.time() - t0))
