"""rb1_lottery_models.py -- referee B (thread `logic`): the Win-lottery in a decidable finite
fragment, checked by brute-force model search, and an exact finite mixture for Thm 2.2 / Cor 2.6'.
Written from the statements in notes.md, not from the developer's code.

Seed 20261016 (Part B only).  Output: rb1_lottery_models.out (stdout).  Runtime: about a minute.

Part A (model search; B = empty theory; language {0, S, Win}).
  Blocks S_0 (N_0 = 1: tickets 0,1) and S_1 (N_1 = 3: tickets 0..3); each block has
  Lot_k := Ex Win(k,x) & Ax (Win(k,x) -> x=0 v ... v x=N_k) and the literals Win(k,j), ~Win(k,j).
  14 sentences, 2^14 = 16384 subsets X.  Every structure with domain {0..n-1}, n <= 5, every
  interpretation of S (all n^n functions; 0 is interpreted as element 0 w.l.o.g.) and every
  Win-row of the elements denoting 0 and 1 is enumerated (the sentences mention no other row).
  A set X is "satisfiable here" iff some such structure satisfies all of X.
  Claim tested (notes.md 2.6, instance (1), and the existence of j*_e in Thm 2.2):
    X consistent  <=>  no block contains a complementary pair, and no block contains Lot_k
                       together with all N_k + 1 negative literals of lottery k;
  and (i) of Prop 2.7: X consistent <=> each X & S_k consistent.
  "<=" is a real test (a model is found); for "=>" the search only confirms that no model with at
  most 5 elements exists (the hand proof covers all models; adding an element with no Win-edges
  and S(new) = new preserves every sentence here, so 5 elements cover all smaller domains).

Part B (exact mixture; Fractions).  K lotteries (N_k = 2^(k+1) - 1), K = 6.  Prior:
  * the random lottery machine G_lot, weight 1/4;
  * a list of L = K consistent deterministic theories W_0..W_{K-1}, weight 2^-(e+2) each,
    built adversarially: W_e's own lottery entry has a random shape (but asserts Lot_e and leaves
    a ticket open), and at every other lottery k it refutes every ticket but one ticket != j*_k, so
    W_e can fail only at its own lottery (the hardest case for the diagonal);
  * the prefix theories A^{G_lot}_u (u = the first b blocks of a tape, b = 1..K), weight
    2^-|u| * 2^-(2 log2(b+1)) / 4, a stand-in for 2^-K(u) (Prop 2.6's e(G,u)).
  The diagonal j*_e is computed against W_e.  For n = 0..2K: M(D_n) (all three parts),
  W(D_n) (deterministic parts only: list + prefix theories), the listed theories still
  compatible, the posterior mass of deterministic theories, and the record's bounds:
  M(D_n) >= (1/4) prod (1-2^-(k+1)); listed theories all dead at n = 2K; -log2 W(D_n) grows
  like the prefix-weight term (Cor 2.6': coin-free loss governed by the horizon, not by n).
"""
import itertools
import random
from fractions import Fraction
from math import log2, ceil

SEED = 20261016
rng = random.Random(SEED)

# ---------------------------------------------------------------- Part A
NS = [1, 3]
SENTS = []
for k, N in enumerate(NS):
    SENTS.append(("Lot", k))
    for j in range(N + 1):
        SENTS.append(("pos", k, j))
        SENTS.append(("neg", k, j))
IDX = {s: i for i, s in enumerate(SENTS)}
BLOCK = [[i for i, s in enumerate(SENTS) if s[1] == k] for k in range(len(NS))]


def criterion(X):
    """The record's combinatorial consistency criterion, per block."""
    for k, N in enumerate(NS):
        pos = {s[2] for s in X if s[0] == "pos" and s[1] == k}
        neg = {s[2] for s in X if s[0] == "neg" and s[1] == k}
        if pos & neg:
            return False
        if ("Lot", k) in X and len(neg) == N + 1:
            return False
    return True


def masks_for(n):
    """Set of 14-bit masks (sentences true) over all structures with domain size n."""
    out = set()
    D = range(n)
    for Sf in itertools.product(D, repeat=n):
        num = [0]
        for _ in range(3):
            num.append(Sf[num[-1]])
        # rows: row of num[0] (lottery 0) and row of num[1] (lottery 1); maybe the same element
        same = num[0] == num[1]
        rowmasks = {}
        for k, N in enumerate(NS):
            allowed = {num[j] for j in range(N + 1)}
            for row in range(1 << n):
                members = {x for x in D if row >> x & 1}
                m = 0
                if members and members <= allowed:
                    m |= 1 << IDX[("Lot", k)]
                for j in range(N + 1):
                    if num[j] in members:
                        m |= 1 << IDX[("pos", k, j)]
                    else:
                        m |= 1 << IDX[("neg", k, j)]
                rowmasks[(k, row)] = m
        for r0 in range(1 << n):
            if same:
                out.add(rowmasks[(0, r0)] | rowmasks[(1, r0)])
            else:
                for r1 in range(1 << n):
                    out.add(rowmasks[(0, r0)] | rowmasks[(1, r1)])
    return out


def part_a():
    print("== A: block consistency criterion vs model search (B = empty) ==")
    masks = set()
    for n in range(1, 6):
        mk = masks_for(n)
        masks |= mk
        print(f"  domain size {n}: {len(mk)} distinct truth patterns of the 14 sentences")
    maximal = [m for m in masks if not any((m | o) == o and o != m for o in masks)]
    nS = len(SENTS)
    agree = disagree = 0
    sat_count = 0
    blockwise_fail = 0
    ex = []
    for Xm in range(1 << nS):
        X = {SENTS[i] for i in range(nS) if Xm >> i & 1}
        sat = any((Xm & m) == Xm for m in maximal)
        sat_count += sat
        crit = criterion(X)
        if sat == crit:
            agree += 1
        else:
            disagree += 1
            if len(ex) < 5:
                ex.append((sorted(X), sat, crit))
        # blockwise (i): sat(X) <=> sat(X & S_k) for each k
        parts_sat = all(any(((Xm & sum(1 << i for i in BLOCK[k])) & m) == (Xm & sum(1 << i for i in BLOCK[k]))
                            for m in maximal) for k in range(len(NS)))
        if parts_sat != sat:
            blockwise_fail += 1
    print(f"  subsets X: {1 << nS}; satisfiable in some structure with <= 5 elements: {sat_count}")
    print(f"  criterion agrees with model search on {agree}; disagrees on {disagree}; examples {ex}")
    print(f"  blockwise property (i) of Prop 2.7 fails on {blockwise_fail} subsets")
    # the j* argument: Lot_k with an unrefuted ticket is consistent; with all refuted it is not
    for k, N in enumerate(NS):
        allneg = {("Lot", k)} | {("neg", k, j) for j in range(N + 1)}
        Xm = sum(1 << IDX[s] for s in allneg)
        print(f"  lottery {k}: Lot_k + all {N + 1} refutations satisfiable: {any((Xm & m) == Xm for m in maximal)}; "
              f"dropping any one refutation satisfiable: "
              f"{all(any(((Xm & ~(1 << IDX[('neg', k, j)])) & m) == (Xm & ~(1 << IDX[('neg', k, j)])) for m in maximal) for j in range(N + 1))}")


# ---------------------------------------------------------------- Part B
def part_b(K=6):
    print("== B: exact finite mixture for Thm 2.2 and Cor 2.6' ==")
    Ns = [2 ** (k + 1) - 1 for k in range(K)]
    # deterministic listed theories: per lottery (asserts_Lot, refuted set); consistent iff no
    # lottery has Lot asserted and all tickets refuted
    theories = []
    for e in range(K):
        th = []
        shape = rng.choice(["hedge", "strong", "random", "weak"])
        for k in range(K):
            N = Ns[k]
            if shape == "hedge":           # keep only a few tickets open
                keep = set(rng.sample(range(N + 1), min(N + 1, rng.randint(1, 3))))
                th.append((True, set(range(N + 1)) - keep))
            elif shape == "strong":
                keep = rng.randrange(N + 1)
                th.append((True, set(range(N + 1)) - {keep}))
            elif shape == "random":
                R = {j for j in range(N + 1) if rng.random() < 0.7}
                if len(R) == N + 1:
                    R.discard(rng.randrange(N + 1))
                th.append((rng.random() < 0.9, R))
            else:
                th.append((True, set()))
        theories.append((shape, th))

    def consistent(th):
        return all(not (a and len(R) == Ns[k] + 1) for k, (a, R) in enumerate(th))

    # adversarial listed theories: W_e asserts Lot_e and leaves at least one ticket of lottery e
    # open (so it is consistent there); at every lottery k != e it asserts Lot_k and refutes every
    # ticket except one ticket different from j*_k.  j*_k depends only on W_k's own entry once all
    # theories are consistent, so it is computed first; theory e can then fail only at lottery e.
    for e in range(K):
        th = theories[e][1]
        if not (th[e][0] and len(th[e][1]) <= Ns[e]):
            th[e] = (True, set(range(Ns[e] + 1)) - {rng.randrange(Ns[e] + 1)})
    jstar = [min(set(range(Ns[e] + 1)) - theories[e][1][e][1]) for e in range(K)]
    for e in range(K):
        th = theories[e][1]
        for k in range(K):
            if k != e:
                keep = rng.choice([j for j in range(Ns[k] + 1) if j != jstar[k]])
                th[k] = (True, set(range(Ns[k] + 1)) - {keep})
    jcheck = []
    for e in range(K):
        a, R = theories[e][1][e]
        jcheck.append(min(set(range(Ns[e] + 1)) - R) if consistent(theories[e][1]) and a else 0)
    assert jcheck == jstar and all(consistent(t) for _, t in theories)
    stream = []
    for k in range(K):
        stream.append(("Lot", k))
        stream.append(("neg", k, jstar[k]))

    def proves(th, D):
        for s in D:
            a, R = th[s[1]]
            if s[0] == "Lot" and not a:
                return False
            if s[0] == "neg" and s[2] not in R:
                return False
        return True

    surv_bound = Fraction(1)
    for k in range(K):
        surv_bound *= 1 - Fraction(1, 2 ** (k + 1))
    print(f"  K={K}; listed theory shapes {[s for s, _ in theories]}; j* = {jstar}")
    print(f"  {'n':>2} {'M(D_n)':>10} {'W(D_n)':>10} {'-log2 W':>8} {'list alive':>10} "
          f"{'P(det|D_n)':>10} {'P(list|D_n)':>11}")
    ok = True
    for n in range(0, 2 * K + 1):
        D = stream[:n]
        Kn = len({s[1] for s in D})           # lotteries touched
        # random machine: survives iff J_k != j*_k for every touched lottery with a refutation datum
        p_rand = Fraction(1)
        for k in range(Kn):
            if ("neg", k, jstar[k]) in D:
                p_rand *= 1 - Fraction(1, Ns[k] + 1)
        m_rand = Fraction(1, 4) * p_rand
        # listed theories
        alive = [e for e in range(K) if consistent(theories[e][1]) and proves(theories[e][1], D)]
        w_list = sum((Fraction(1, 2 ** (e + 2)) for e in alive), Fraction(0))
        # prefix theories with b blocks: prove D iff b >= Kn and the drawn winners avoid j*
        w_pref = Fraction(0)
        for b in range(1, K + 1):
            if b < Kn:
                continue
            wb = Fraction(1, 4) * Fraction(1, 2 ** ceil(2 * log2(b + 1)))
            w_pref += wb * p_rand          # sum over u of 2^-|u| [winners avoid j*] = p_rand
        # brute-force check of the prefix sum for small b
        if Kn <= 3:
            b = max(Kn, 1)
            tot = Fraction(0)
            for J in itertools.product(*[range(Ns[k] + 1) for k in range(b)]):
                th = [(True, set(range(Ns[k] + 1)) - {J[k]}) for k in range(b)] + [(False, set())] * (K - b)
                if proves(th, D):
                    tot += Fraction(1, 2 ** sum(k + 1 for k in range(b)))
            if tot != p_rand:
                ok = False
        W = w_list + w_pref
        M = W + m_rand
        if M < Fraction(1, 4) * surv_bound:
            ok = False
        pdet = W / M
        plist = w_list / M
        mlogW = -log2(W) if W > 0 else float("inf")
        print(f"  {n:>2} {float(M):>10.6f} {float(W):>10.6f} {mlogW:>8.3f} {len(alive):>10} "
              f"{float(pdet):>10.6f} {float(plist):>11.6f}")
    print(f"  M(D_n) >= (1/4) prod(1-2^-(k+1)) = {float(Fraction(1, 4) * surv_bound):.6f} for all n, "
          f"and prefix sums equal the survival product (brute force, <= 3 lotteries): {ok}")
    print("  (listed theories are all dead at n = 2K; the coin-free weight that remains is carried by the\n"
          "   prefix theories, whose weight falls only through the horizon term, as in Prop 2.6.)")


if __name__ == "__main__":
    print(f"seed {SEED}")
    part_a()
    part_b()
    print("done")
