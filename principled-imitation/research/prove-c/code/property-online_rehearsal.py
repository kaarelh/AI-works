"""The rehearsal corollary on the tree of additions, with exact per-rule discrepancies
(property-online.md, Section 6 and Section 7.3).

Closed system (as in code/toy_property.py of the lead): 8 leaves with values in {0, 1}; a call
adds two numbers mod 8; depth 3, so L = 7 calls in a run. The human adds correctly with
probability 0.9 and adds 1 more with probability 0.1, independently at every call. The 805
tests and their weights are those of the lead's toy.

Rehearsal: in round t the rule a_t (a table question -> answer) answers every call of a run on
fresh leaves; one uniformly chosen call is put to the human; the books are updated.

For a rule a and a test B the script computes, by enumeration of the 256 leaf vectors,
    n_B(a) = expected number of calls of a run of a whose answer lies in B,
    m_B(a) = expected number of those calls at which the human's answer would lie in B,
    d_B(a) = n_B(a) - m_B(a),
and Delta_n(B) = (1/n) sum_t d_B(a_t): the discrepancy of the deployed imitator (the rule of a
uniformly chosen round, drawn afresh for each run), given the rehearsal.

Checked:
 (1) Theorem 6.3: |Delta_n(B)| <= (L/n) (|S_n(B)| + sqrt(2 n ln(2/(pi(B) delta)))) for all B at
     once (delta = 0.05): the largest ratio left/right over the tests, which should be <= 1.
 (2) Theorem 6.2(c): for the tests that the human never satisfies, the count N_n(B) against
     K(B) + 2 (rule NH), and (1/n) sum_t n_B(a_t) against L (K(B) + 2) / n is reported for
     comparison (the theorem bounds the expectation of the latter).
 (3) Example 6.5 / Remark: single rules. For the test "the answer is the exact sum plus 1"
     (per-run rate of the human: 0.7 calls), the spread of n_B(a_t) over the rounds.
 (4) Proposition 7.3: the probability that the root of a deployed run is the exact sum, against
     the human system's 0.9^7.

Usage: python3 property-online_rehearsal.py
"""
import itertools
import math

import numpy as np

M, SMALL, NOISE, L = 8, 2, 0.1, 7


def build_tests():
    x = np.arange(M * M)
    a, b = np.divmod(x, M)
    A, B, Y = a[:, None], b[:, None], np.arange(M)[None, :]
    base = {}
    for c in range(M):
        base[f"y={c}"] = (Y == c) & (A >= 0), 4
        base[f"y-a-b={c}"] = ((Y - A - B) % M == c), 5
        base[f"y-a={c}"] = ((Y - A) % M == c), 5
        base[f"y-b={c}"] = ((Y - B) % M == c), 5
    base["y even"] = (Y % 2 == 0) & (A >= 0), 3
    base["y>=a"] = (Y >= A), 4
    base["y=max(a,b)"] = (Y == np.maximum(A, B)), 5
    conds = {"all": (a >= 0, 0), "a<4": (a < 4, 2), "b<4": (b < 4, 2), "a>=4": (a >= 4, 2),
             "b>=4": (b >= 4, 2), "a=b": (a == b, 2), "a+b>=M": (a + b >= M, 3)}
    for u in range(M):
        conds[f"a={u}"] = (a == u, 5)
        conds[f"b={u}"] = (b == u, 5)
    names, lengths, tests = [], [], []
    for bn, (bset, bl) in base.items():
        for cn, (cset, cl) in conds.items():
            names.append(f"[{cn}] {bn}")
            lengths.append(bl + cl)
            tests.append(bset & cset[:, None])
    w = 2.0 ** (-np.array(lengths, dtype=float))
    return names, w / w.sum(), np.stack(tests).astype(float)


NAMES, PI, TESTS = build_tests()                      # TESTS[k, x, y]
K_TESTS = len(PI)
XS = np.arange(M * M)
SUM = (XS // M + XS % M) % M
# human kernel P[x, y]
PH = np.zeros((M * M, M))
PH[XS, SUM] = 1 - NOISE
PH[XS, (SUM + 1) % M] += NOISE
HUMAN_RATE = np.einsum("kxy,xy->kx", TESTS, PH)       # (P b_B)(x)
NEVER = HUMAN_RATE.max(axis=1) == 0                   # tests the human never satisfies
LEAVES = np.array(list(itertools.product(range(SMALL), repeat=8)))   # 256 x 8


def G(v, s):
    return (v + 1.0) ** -0.5 * np.exp(s * s / (2.0 * (v + 1.0)))


def slopes(rule, S, V, pure, eta):
    if rule == "lead":
        return np.sinh(eta * S)
    cN = 0.5 * (G(V + 1, S + 1.0) - G(V + 1, S - 1.0))
    cH = np.where((V >= 1) & pure, np.sign(S) * 2.0 ** np.minimum(V - 1, 1000), 0.0)
    return 0.5 * cN + 0.5 * cH


def runs_of(rule_table):
    """All 256 runs of a rule: returns the questions (256 x 7) and the roots (256)."""
    vals = LEAVES.copy()
    qs = []
    while vals.shape[1] > 1:
        x = vals[:, 0::2] * M + vals[:, 1::2]
        qs.append(x)
        vals = rule_table[x]
    return np.concatenate(qs, axis=1), vals[:, 0]


def exact_stats(rule_table):
    qs, roots = runs_of(rule_table)
    visits = np.bincount(qs.ravel(), minlength=M * M) / len(LEAVES)       # expected visits per run
    nB = TESTS[:, XS, rule_table] @ visits
    mB = HUMAN_RATE @ visits
    root_ok = np.mean(roots == LEAVES.sum(axis=1) % M)
    return nB, mB, root_ok


def rehearse(rule, n, rng, delta=0.05):
    eta = 1 / math.sqrt(n)
    S = np.zeros(K_TESTS)
    V = np.zeros(K_TESTS)
    pure = np.ones(K_TESTS, dtype=bool)
    sum_n = np.zeros(K_TESTS)
    sum_m = np.zeros(K_TESTS)
    k_plus1 = NAMES.index("[all] y-a-b=1")
    track, roots = [], []
    for t in range(n):
        c = slopes(rule, S, V, pure, eta)
        score = np.tensordot(PI * c, TESTS, axes=1)                 # [x, y]
        table = score.argmin(axis=1)
        nB, mB, root_ok = exact_stats(table)
        sum_n += nB
        sum_m += mB
        track.append(nB[k_plus1])
        roots.append(root_ok)
        leaves = rng.integers(0, SMALL, size=8)
        vals, qs = leaves, []
        while len(vals) > 1:
            x = vals[0::2] * M + vals[1::2]
            qs.append(x)
            vals = table[x]
        x = int(np.concatenate(qs)[rng.integers(L)])
        ya = int(table[x])
        yh = int(rng.choice(M, p=PH[x]))
        g = TESTS[:, x, ya] - TESTS[:, x, yh]
        newS = S + g
        pure &= ~((g != 0) & (np.abs(newS) < V + 1))
        S, V = newS, V + (g != 0)
    Delta = (sum_n - sum_m) / n
    rhs = (L / n) * (np.abs(S) + np.sqrt(2 * n * np.log(2 / (PI * delta))))
    out = {
        "max ratio (1)": float(np.max(np.abs(Delta) / rhs)),
        "max |Delta|": float(np.max(np.abs(Delta))),
        "max (L/n)|S|": float(np.max(L * np.abs(S) / n)),
        "never: max N_n(B) - (K(B)+2)": float(np.max((S - (np.log2(1 / PI) + 2))[NEVER])),
        "never: max N_n(B)": float(np.max(S[NEVER])),
        "never: max ratio of mean n_B to L(K+2)/n": float(np.max((sum_n / n / (L * (np.log2(1 / PI) + 2) / n))[NEVER])),
        "y=sum+1: mean, min, max of n_B(a_t)": (float(np.mean(track)), float(np.min(track)), float(np.max(track))),
        "y=sum+1: share of rounds with |d_B(a_t)| > 0.35": float(np.mean(np.abs(np.array(track) - 0.7) > 0.35)),
        "root exact, deployed": float(np.mean(roots)),
    }
    return out


if __name__ == "__main__":
    rng = np.random.default_rng(7)
    print(f"{K_TESTS} tests, {int(NEVER.sum())} of them never satisfied by the human; L = {L}; "
          f"human system: root exact with probability {0.9 ** 7:.4f}; human's rate of 'sum + 1': 0.7 calls per run\n")
    for n in (1000, 8000):
        for rule in ("lead", "NH"):
            out = rehearse(rule, n, rng)
            print(f"n = {n}, rule {rule}")
            for k, v in out.items():
                if isinstance(v, tuple):
                    print(f"    {k}: " + ", ".join(f"{u:.4f}" for u in v))
                else:
                    print(f"    {k}: {v:.4f}")
            print()
