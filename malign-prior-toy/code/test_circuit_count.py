"""Checks of the dynamic programme of circuit_count.py against direct enumeration, and hand-checkable values.

Run:  python3 test_circuit_count.py      (about 10 seconds)
"""
from fractions import Fraction

import circuit_count as cc


def test_dp_matches_direct():
    for k, smax in ((2, 3), (3, 3), (4, 2)):
        dp = cc.counts_by_function(k, smax)
        for s in range(1, smax + 1):
            assert cc.counts_direct(k, s) == dp[s - 1], (k, s)
    print("OK  dynamic programme == direct enumeration for k=2 s<=3, k=3 s<=3, k=4 s<=2")


def test_sums():
    for k, smax in ((2, 5), (3, 4), (4, 3)):
        dp = cc.counts_by_function(k, smax)
        for s in range(1, smax + 1):
            assert sum(dp[s - 1].values()) == cc.N(k, s), (k, s)
    assert cc.N(3, 1) == 144 and cc.N(3, 2) == 144 * 256 and cc.N(4, 2) == 256 * 400
    print("OK  counts for each s sum to N_s = prod 16 (k+i-1)^2 (k=2 s<=5, k=3 s<=4, k=4 s<=3)")


def test_hand_values():
    k = 3
    T = cc.counts_by_function(k, 2)
    data = cc.mask_of([(a, b, 0) for a in (0, 1) for b in (0, 1)])
    q = cc.idx((1, 1, 1))
    # x1 AND x2: at s=1 only AND on (x1,x2) and on (x2,x1) fit; both answer 1 at 111.
    t_and = cc.table_of(k, lambda u: u[0] & u[1])
    share, dev, fit = cc.deviation_mass(T[0], t_and, data, q, 1)
    assert (share, dev, fit) == (0, 0, 2)
    # target x1: 14 one-gate circuits fit (4 tables on (x1,x1), first projection on (x1,x2),
    # second on (x2,x1), 4 tables each on (x1,x3) and (x3,x1)); 4 of them answer 0 at 111.
    t_x1 = cc.table_of(k, lambda u: u[0])
    share, dev, fit = cc.deviation_mass(T[0], t_x1, data, q, 1)
    assert (dev, fit) == (4, 14) and share == Fraction(2, 7)
    # x1 AND x2 at s=2: deviation mass 1/11 (Computation 22: 0.0909)
    share, dev, fit = cc.deviation_mass(T[1], t_and, data, q, 1)
    assert share == Fraction(1, 11), share
    # constant 0 at s=1: on the 6 pairs of distinct inputs only the table 0000; on the 3 pairs (x,x)
    # every table with f(0,0)=f(1,1)=0, i.e. 4 tables: 6 + 12 = 18; likewise constant 1
    assert T[0][0] == 18 and T[0][cc.full_mask(k)] == 18
    print("OK  hand values: x1 AND x2 deviation 0 (2 fitting) at s=1 and 1/11 at s=2; x1 deviation 4/14 at s=1; constants 18 each")


def test_index_reading():
    # k=4: b_0 AND b_1 prints 0001 0001 0001 0001
    t = cc.table_of(4, lambda b: b[0] & b[1])
    tt = "".join(str(cc.bit(t, u)) for u in range(16))
    assert tt == "0001" * 4
    t = cc.table_of(4, lambda b: (b[0] & b[1]) ^ b[3])
    assert "".join(str(cc.bit(t, u)) for u in range(16)) == "0001" * 2 + "1110" * 2
    print("OK  index reading: tt(b0 AND b1) = (0001)^4, tt((b0 AND b1) XOR b3) = (0001)^2 (1110)^2")


if __name__ == "__main__":
    test_dp_matches_direct()
    test_sums()
    test_hand_values()
    test_index_reading()
    print("ok")
