"""c3_presburger_constants.py -- thread `sfi`, T9: from which sentence length m on do the
contradictions in the Presburger separations bite, for illustrative constants?

Fischer and Rabin (1974): there is c > 0 such that every (nondeterministic) decision procedure for
Th(N,0,1,+) runs more than 2^(2^(c m)) steps on some sentence of length m, for all large m.
The overhead polynomial q (TF Convention 1.5) is taken as q(x) = x^k, and C is the hypothesis'
constant.  All quantities are compared in log2 form; nothing is asserted about the true c.

(A) coin-free clocked consistent SOI (notes Prop 9.1), clock tau(m) = 2^(2^(c' m)):
    the decision time q(C tau(m) + m) must stay below 2^(2^(c m)):
    k * log2(C 2^(2^(c'm)) + m) < 2^(c m).
(B) one-tape clocked SOI, exponential clock tau(m) = 2^(c' m) (notes Prop 9.2): derandomising by
    enumerating the tau(m) tape bits costs a factor 2^tau(m):
    2^(c'm) + k * log2(C 2^(c'm) + m) < 2^(c m).
(C) one-tape, doubly exponential clock, conditional route (notes Prop 9.3): the bounded-error
    algorithm runs in time T = q(C tau(m) + m), tau = 2^(2^(c'm)); a Sigma_2 simulation in time
    about T^3 (log T)^2 must stay below an alternating lower bound 2^(2^(c_B m)):
    3 log2 T + 2 log2 log2 T < 2^(c_B m).
Upper estimates used throughout (conservative): log2(C 2^a + m) <= a + log2(C) + 1.
For each parameter set the table gives m0 := the least m such that the inequality holds for every
m in [m0, 3000] (or 'none' if it fails at m = 3000).  Deterministic; output c3_presburger_constants.out
"""
import math

out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def condA(m, c, cp, C, k):
    # k * log2(C 2^X + m) < 2^(c m), X = 2^(c' m); compare log2 of both sides
    # conservative: log2(C 2^X + m) <= X + log2(C) + 1 whenever m <= C 2^X
    X = 2.0 ** (cp * m) if cp * m < 1000 else float('inf')
    lhs = math.log2(k) + (math.log2(X + math.log2(C) + 1) if X != float('inf') else cp * m)
    return lhs < c * m


def condB(m, c, cp, C, k):
    # 2^(c'm) + k log2(C 2^(c'm) + m) < 2^(c m)
    a = cp * m
    lhs_log = a + math.log2(1 + k * (a + math.log2(C) + 1) / 2.0 ** a) if a < 1000 else a
    return lhs_log < c * m


def condC(m, cB, cp, C, k):
    # 3 log2 T + 2 log2 log2 T < 2^(c_B m), log2 T = k (2^(c'm) + log2 C)
    a = cp * m
    if a < 1000:
        lT = k * (2.0 ** a + math.log2(C) + 1)
        lhs_log = math.log2(3 * lT + 2 * math.log2(max(lT, 2.0)))
    else:
        lhs_log = math.log2(3 * k) + a
    return lhs_log < cB * m


def threshold(cond, *args, M=3000):
    last_fail = None
    for m in range(1, M + 1):
        try:
            ok = cond(m, *args)
        except OverflowError:
            ok = False
        if not ok:
            last_fail = m
    if last_fail == M:
        return 'none'
    return 1 if last_fail is None else last_fail + 1


def main():
    out('c3_presburger_constants.py (deterministic)')
    for name, cond, cname in (('(A) coin-free, tau = 2^(2^(c\'m))', condA, 'c'),
                              ('(B) one tape, tau = 2^(c\'m)', condB, 'c'),
                              ('(C) one tape, tau = 2^(2^(c\'m)), Sigma_2 route', condC, 'c_B')):
        out('')
        out(name)
        out('   %-4s  %-6s  %-9s  %-3s  m0' % (cname, "c'", 'C', 'k'))
        for c in (1.0, 0.5, 0.2, 0.05):
            for frac in (0.9, 0.5, 0.25):
                cp = frac * c
                for C in (10.0, 1e6):
                    for k in (2, 6):
                        out('   %-4g  %-6g  %-9g  %-3d  %s' % (c, cp, C, k, threshold(cond, c, cp, C, k)))
    out('')
    out('Reading: in every row the inequality holds from some m0 on (for c\' < c it holds once')
    out("2^((c-c')m) exceeds k times a constant), as the proofs need; m0 grows as")
    out("c' approaches c and as c shrinks.  The separations are asymptotic: below m0 a clocked hypothesis")
    out('may label every short sentence correctly.')
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
