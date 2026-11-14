"""Numbers of Section 7 (paper/sec7-circuits.tex) that are marked as computed and are not in
results/circuits.json.  Model and notation: Definition "Circuits" of the section
(research/circuits-final.md, Section 1.1); counts by function from code/circuit_count.py.

Items (each written to results/circuits_extra.json; ratios as exact fraction strings and floats):

1. Price of one more active gate under the length prior (sentence after thm:c-core).
   Core weight beta_s(a) = p_s e_{a-1}(p_1..p_{s-1}), p_i = 1/(16 (k+i-1)^2), and
   beta_q(a) = sum_{s>=a} 2^-s beta_s(a) for the length prior w_s = 2^-s.  The price of the
   (a+1)-st active gate is log2(beta_q(a)/beta_q(a+1)), at k=20, a=1 and a=8.  beta_q is an
   infinite series; it is summed exactly (Fractions) for s <= S=200, and the tail s > S is bounded
   by 2^-S p_1 E^(a-1)/(a-1)! with E = 1/(16(k-1)) >= sum_i p_i, so the ratio is enclosed in a
   rigorous interval [lower, upper] with rational endpoints (written as decimal strings rounded
   outward).  Also the proved lower bounds log2(16 a (k-1)) of thm:c-core(b).

2. Floor against exact values (paragraph after thm:c-floor).  k=3, world b0 AND b1, index reading,
   cuts n = 3..7, sizes s = 4, 5, prior mu_s.  Floor for wrappers of a gates: (number of size-(s-a)
   circuits that print the context) / (number of size-s circuits that print it), a = 1, 2, 3.
   Exact share: posterior probability under mu_s of the flipped next bit (bit n+1 differing from
   the world's).  The one-gate wrapper exists only at the dyadic cut n = 4 (index wire b2).

3. Separably triggered cores (after thm:c-ceiling).
   (a) Target x1 AND x2, k=3, data = inputs with x3 = 0, query 111 (target answer 1).  Among the
       size-s circuits (s = 2, 3) that fit and answer 0 at 111, those whose core is separably
       triggered (definition in thm:c-ceiling: last gate a mux tau(h, r) in one of 6 types x 2
       pointer orders, h a gate, cones of h and r disjoint, the cone of r in Theta).  Theta for
       g = 0 is {x3} (the only input that is 0 on the data); for g = 1, all one-gate circuits that
       are 0 on the data.  At s <= 3 a core has at most 3 gates and a >= s_D + g + 1 = g + 2, so
       g <= 1 and the count is complete.  Counted by enumerating all prefixes of s-1 gates and the
       last pointer pair, with the 16 truth tables of the last gate handled together.
   (b) R_g, the number of reduced circuits of g gates at k = 20, from
       sum_{b<=a} R_b N_a beta_a(b) = N_a (checked against direct enumeration of pointer
       structures for k=2 g<=5, k=3 g<=4, k=20 g<=2); and the ceiling
       12 |Theta| / (g! s_D (16(k-1))^(g+1)) at k=20, s_D=1000 with |Theta| = 1 (g = 0),
       |Theta| = k = 20 (g = 0, all inputs), |Theta| = R_g (g >= 1), and with N_g in place of R_g
       (the figures of the source); single-g values, sums, and first g at which they exceed 1.

4. Capture, first example (thm:c-capture(d)).  k=4, world b0 AND b1 (tt = (0001)^4), context 000
   (n = 3), true next bit 1: share of bit 1 under mu_s, s = 1..4.  Also the second example
   there: k=4 AND family, data = inputs with at most one 0, s = 3: number of minimum-size fitting
   circuits and the share answering 1 at an input with three 0s.

5. Exception of thm:c-minimum for s_D = 1: target x1, data = inputs with the last input v
   frozen at 0; number of fitting one-gate circuits and of those deviating at each query with
   v = 1, for k = 3..7 (formula in the section: 4 of 2k+8).

6. Active part of a random circuit (sentence after thm:c-core: "mean about 3 at k=s=1000"):
   seeded Monte Carlo (random.Random(20261114)), 20000 uniform gate lists at k = s = 1000; the
   number of active gates depends only on the pointers.  This is the only random quantity.

Run:  python3 run_circuits_extra.py
Measured: 23 s in total (wall clock) on the machine that wrote results/circuits_extra.json.
Deterministic: every value is exact except item 6, which is seeded and reproducible.
"""
import json
import math
import os
import random
import sys
import time
from collections import defaultdict
from fractions import Fraction as F
from itertools import product
from math import comb, factorial, log2

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))
import circuit_count as cc  # noqa: E402


def val(x):
    if x is None:
        return None
    x = F(x)
    return {"exact": str(x), "float": float(x)}


def dec(x, digits, up):
    """Decimal string of the Fraction x with `digits` decimals, rounded up (up=True) or down."""
    sc = 10 ** digits
    n = x.numerator * sc
    q = -((-n) // x.denominator) if up else n // x.denominator
    s = str(abs(q)).rjust(digits + 1, "0")
    return ("-" if q < 0 else "") + s[:-digits] + "." + s[-digits:]


def log2F(x):
    """log2 of a positive Fraction, as a float, without overflow."""
    return (math.log2(x.numerator) if x.numerator < 2 ** 1000 else _biglog2(x.numerator)) - \
           (math.log2(x.denominator) if x.denominator < 2 ** 1000 else _biglog2(x.denominator))


def _biglog2(n):
    sh = n.bit_length() - 64
    return math.log2(n >> sh) + sh


# ---------------------------------------------------------------- core weights

def p(k, i):
    return F(1, 16 * (k + i - 1) ** 2)


def beta_s(k, s, amax):
    """[None, beta_s(1), ..., beta_s(amax)], exact."""
    e = [F(1)] + [F(0)] * amax
    for i in range(1, s):
        pi = p(k, i)
        for d in range(amax, 0, -1):
            e[d] += e[d - 1] * pi
    return [None] + [p(k, s) * e[a - 1] if a <= s else F(0) for a in range(1, amax + 1)]


def item1(k=20, amax=9, S=200):
    """beta_q(a) for the length prior, enclosed: partial sum over s <= S, plus tail bound."""
    part = [F(0)] * (amax + 1)
    e = [F(1)] + [F(0)] * amax                 # e_d(p_1..p_{s-1})
    for s in range(1, S + 1):
        ps = p(k, s)
        w = F(1, 2 ** s)
        for a in range(1, amax + 1):
            part[a] += w * ps * e[a - 1]
        for d in range(amax, 0, -1):
            e[d] += e[d - 1] * ps
    E = F(1, 16 * (k - 1))
    tail = [None] + [F(1, 2 ** S) * p(k, 1) * E ** (a - 1) / factorial(a - 1) for a in range(1, amax + 1)]
    out = {"k": k, "series_terms_summed": S, "tail_bound": "2^-S p_1 (1/(16(k-1)))^(a-1)/(a-1)!", "prices": {}}
    for a in (1, 8):
        lo = part[a] / (part[a + 1] + tail[a + 1])
        hi = (part[a] + tail[a]) / part[a + 1]
        out["prices"]["a=%d" % a] = {
            "ratio_beta_q(a)/beta_q(a+1)": {"lower": dec(lo, 12, False), "upper": dec(hi, 12, True),
                                            "float": float(part[a] / part[a + 1])},
            "price_bits": {"lower": log2F(lo), "upper": log2F(hi)},
            "lower_bound_log2(16a(k-1))": log2(16 * a * (k - 1)),
        }
    # monotonicity check of the claim beta(a+1) <= beta(a)/(16a(k-1)) for the length prior
    for a in range(1, amax):
        assert (part[a + 1] + tail[a + 1]) <= part[a] / (16 * a * (k - 1))
    return out


# ---------------------------------------------------------------- item 2

def item2(T3):
    k = 3
    w = cc.table_of(k, lambda b: b[0] & b[1])
    rows = []
    for s in (4, 5):
        for n in range(3, 8):
            dmask = cc.prefix_mask(n)
            own = cc.bit(w, n)
            fit = [None] + [sum(cc.fitting(T3[t - 1], w, dmask).values()) for t in range(1, 6)]
            share, dev, tot = cc.deviation_mass(T3[s - 1], w, dmask, n, own)
            assert tot == fit[s]
            floors = {}
            for a in (1, 2, 3):
                floors["a=%d" % a] = val(F(fit[s - a], fit[s]))
            rows.append({"s": s, "n": n, "context": "".join(str(cc.bit(w, u)) for u in range(n)),
                         "flipped_bit_share": val(share), "fitting": {str(t): fit[t] for t in range(1, s + 1)},
                         "floor": floors, "one_gate_wrapper_exists": n == 4})
    a3 = [F(r["floor"]["a=3"]["exact"]) for r in rows]
    fl = [F(r["flipped_bit_share"]["exact"]) for r in rows]
    summary = {"max_floor_a=3": val(max(a3)), "min_flipped": val(min(fl)), "max_flipped": val(max(fl)),
               "n=4,s=4": {"floor_a=1": next(r["floor"]["a=1"] for r in rows if r["n"] == 4 and r["s"] == 4),
                           "flipped": next(r["flipped_bit_share"] for r in rows if r["n"] == 4 and r["s"] == 4)}}
    return {"world": "b0 AND b1", "k": 3, "rows": rows, "summary": summary}


# ---------------------------------------------------------------- item 3(a)

def mux_types():
    """Tables tt (bit 2*vh+vr) of a gate tau(h, r) that are muxes: tau(., 0) id or negation, tau(., 1) != tau(., 0)."""
    res = []
    for tt in range(16):
        f = lambda vh, vr: (tt >> (2 * vh + vr)) & 1
        z = (f(0, 0), f(1, 0))
        o = (f(0, 1), f(1, 1))
        if z in ((0, 1), (1, 0)) and o != z:
            res.append(tt)
    return res


def swap_args(tt):
    return (tt & 1) | (((tt >> 1) & 1) << 2) | (((tt >> 2) & 1) << 1) | (tt & 8)


def item3a(smax=3):
    k = 3
    mask = cc.full_mask(k)
    inp = cc.input_tables(k)
    target = cc.table_of(k, lambda u: u[0] & u[1])
    dmask = cc.mask_of([(a, b, 0) for a in (0, 1) for b in (0, 1)])
    q = cc.idx((1, 1, 1))
    MT = set(mux_types())
    assert len(MT) == 6
    MT_sw = {swap_args(t) for t in MT}
    frozen = 2                                    # wire index of x3

    out = {}
    for s in range(2, smax + 1):
        tot = dict(fit=0, dev=0, sep=0, sep_g0=0, sep_g1=0, sep_both=0)

        def cone(gates, wi):
            c = set()
            st = [wi] if wi >= k else []
            while st:
                w_ = st.pop()
                if w_ in c:
                    continue
                c.add(w_)
                for pp in gates[w_ - k][1:]:
                    if pp >= k:
                        st.append(pp)
            return c

        def rec(gates, vals):
            i = len(gates)
            n = k + i
            if i < s - 1:
                for a in range(n):
                    for b in range(n):
                        for tt in range(16):
                            gates.append((tt, a, b))
                            vals.append(cc.gate(tt, vals[a], vals[b], mask))
                            rec(gates, vals)
                            gates.pop()
                            vals.pop()
                return
            for a in range(n):
                for b in range(n):
                    fa, fb = vals[a], vals[b]
                    ca = cone(gates, a)
                    cb = cone(gates, b)
                    # possible separable roles: (h, r) = (a, b) with tables in MT, (b, a) with MT_sw
                    roles = []
                    for h, r, ch, cr, types in ((a, b, ca, cb, MT), (b, a, cb, ca, MT_sw)):
                        if h < k or (ch & cr):
                            continue
                        if r < k:
                            g = 0 if r == frozen else None
                        else:
                            g = 1 if (len(cr) == 1 and vals[r] & dmask == 0) else None
                            # larger triggers impossible at s <= 3 (see docstring); guard:
                            if len(cr) > 1 and vals[r] & dmask == 0:
                                assert s >= 4
                        if g is not None:
                            roles.append((g, types))
                    for tt in range(16):
                        f = cc.gate(tt, fa, fb, mask)
                        if (f ^ target) & dmask:
                            continue
                        tot["fit"] += 1
                        if (f >> q) & 1:
                            continue
                        tot["dev"] += 1
                        gs = {g for g, types in roles if tt in types}
                        if gs:
                            tot["sep"] += 1
                            if gs == {0}:
                                tot["sep_g0"] += 1
                            elif gs == {1}:
                                tot["sep_g1"] += 1
                            else:
                                tot["sep_both"] += 1

        rec([], list(inp))
        out["s=%d" % s] = dict(tot, share_of_deviating=val(F(tot["sep"], tot["dev"])))
    return out


# ---------------------------------------------------------------- item 3(b)

def reduced_counts(k, gmax):
    R = [None]
    for a in range(1, gmax + 1):
        b = beta_s(k, a, a)
        rest = F(1) - sum(R[bb] * b[bb] for bb in range(1, a))
        Ra = rest / b[a]
        assert Ra.denominator == 1
        R.append(Ra.numerator)
    return R


def reduced_direct(k, g):
    """Number of reduced circuits of g gates by enumerating pointer structures (x 16^g tables)."""
    cnt = 0
    ranges = [range(k + i) for i in range(g)]
    pairs = [list(product(r, r)) for r in ranges]
    for ptrs in product(*pairs):
        act = [False] * g
        act[g - 1] = True
        for i in range(g - 1, -1, -1):
            if act[i]:
                for pp in ptrs[i]:
                    if pp >= k:
                        act[pp - k] = True
        cnt += all(act)
    return cnt * 16 ** g


def item3b(k=20, sD=1000, gmax=30):
    for kk, gg in ((2, 5), (3, 4), (20, 2)):
        R = reduced_counts(kk, gg)
        for g in range(1, gg + 1):
            assert R[g] == reduced_direct(kk, g), (kk, g)
    R = reduced_counts(k, gmax)

    def bound(g, theta):
        return F(12 * theta, factorial(g) * sD * (16 * (k - 1)) ** (g + 1))

    single = bound(0, 1)
    per_g = {}
    cum_with_inputs = bound(0, k)
    cum_from1 = F(0)
    first_single_gt1 = first_cum_gt1 = first_cum_from1_gt1 = None
    for g in range(1, gmax + 1):
        b = bound(g, R[g])
        cum_with_inputs += b
        cum_from1 += b
        if b > 1 and first_single_gt1 is None:
            first_single_gt1 = g
        if cum_with_inputs > 1 and first_cum_gt1 is None:
            first_cum_gt1 = g
        if cum_from1 > 1 and first_cum_from1_gt1 is None:
            first_cum_from1_gt1 = g
        per_g[str(g)] = {"R_g": str(R[g]), "bound_reduced": val(b),
                         "cum_sum_g0_all_inputs_to_g": val(cum_with_inputs),
                         "cum_sum_1_to_g": val(cum_from1),
                         "bound_with_N_g": val(bound(g, cc.N(k, g)))}
    # monotone after the first crossing (so "from g on" is meaningful)
    for g in range(first_single_gt1, gmax + 1):
        assert F(per_g[str(g)]["bound_reduced"]["exact"]) > 1
    return {"k": k, "s_D": sD,
            "R_check": "recursion == direct enumeration for k=2 g<=5, k=3 g<=4, k=20 g<=2",
            "single_input_trigger_g0": dict(val(single), log2=log2F(single)),
            "all_inputs_g0_Theta=k": val(bound(0, k)),
            "per_g": per_g,
            "sum_g0_to_19": val(F(per_g["19"]["cum_sum_g0_all_inputs_to_g"]["exact"])),
            "sum_g1_to_19": val(F(per_g["19"]["cum_sum_1_to_g"]["exact"])),
            "first_g_single_exceeds_1": first_single_gt1,
            "first_g_cum_sum_g0_to_g_exceeds_1": first_cum_gt1,
            "first_g_cum_sum_1_to_g_exceeds_1": first_cum_from1_gt1}


# ---------------------------------------------------------------- item 4

def item4(T4):
    k = 4
    w = cc.table_of(k, lambda b: b[0] & b[1])
    n = 3
    dmask = cc.prefix_mask(n)
    by = {}
    for s in range(1, 5):
        share, num, tot = cc.answer_share(T4[s - 1], w, dmask, n, cc.bit(w, n))
        by[str(s)] = {"true_bit_count": num, "fitting": tot, "share": val(share)}
    # second example: AND family k=4, s=3
    t = cc.table_of(k, lambda u: int(all(u)))
    dm = cc.mask_of([u for u in product((0, 1), repeat=k) if sum(u) >= k - 1])
    sD = cc.least_fitting_size(T4, t, dm)
    shares = set()
    for u in product((0, 1), repeat=k):
        if k - sum(u) == 3:
            sh, num, tot = cc.answer_share(T4[sD - 1], t, dm, cc.idx(u), 1)
            shares.add((sh, num, tot))
    assert len(shares) == 1
    sh, num, tot = shares.pop()
    return {"first_example": {"world": "b0 AND b1", "k": 4, "context": "000", "next_bit": cc.bit(w, n),
                              "by_size": by},
            "second_example_and_family_k4": {"s_D": sD, "minimum_fitting": tot,
                                             "answering_1_at_three_zeros": num, "share": val(sh)}}


# ---------------------------------------------------------------- item 5

def item5(kmax=7):
    out = {}
    for k in range(3, kmax + 1):
        T1 = cc.counts_by_function(k, 1)[0]
        t = cc.table_of(k, lambda u: u[0])
        dmask = cc.mask_of([u for u in product((0, 1), repeat=k) if u[-1] == 0])
        devs = set()
        for u in product((0, 1), repeat=k):
            if u[-1] == 1:
                share, dev, fit = cc.deviation_mass(T1, t, dmask, cc.idx(u), u[0])
                devs.add((dev, fit))
        assert len(devs) == 1
        dev, fit = devs.pop()
        assert fit == 2 * k + 8 and dev == 4
        out["k=%d" % k] = {"fitting_one_gate": fit, "deviating_each_query_v=1": dev, "share": val(F(dev, fit))}
    return out


# ---------------------------------------------------------------- item 6

def item6(k=1000, s=1000, reps=20000, seed=20261114):
    rng = random.Random(seed)
    tot = tot2 = 0
    for _ in range(reps):
        act = bytearray(s + 1)
        act[s] = 1
        c = 0
        for i in range(s, 0, -1):
            if act[i]:
                c += 1
                for _ in range(2):
                    pp = rng.randrange(1, k + i)      # wire 1..k+i-1
                    if pp > k:
                        act[pp - k] = 1
        tot += c
        tot2 += c * c
    m = tot / reps
    sd = math.sqrt(tot2 / reps - m * m)
    return {"k": k, "s": s, "reps": reps, "seed": seed, "mean_active_gates": m, "std_error": sd / math.sqrt(reps)}


def main():
    t0 = time.time()
    T3 = cc.counts_by_function(3, 5)
    T4 = cc.counts_by_function(4, 4)
    for k, T in ((3, T3), (4, T4)):
        for s, c in enumerate(T, start=1):
            assert sum(c.values()) == cc.N(k, s)
    res = {"model": "circuits of research/circuits-final.md Section 1.1 (Definition c-circuit of Section 7)",
           "item1_length_prior_gate_price": item1(),
           "item2_floor_vs_exact": item2(T3),
           "item3a_separably_triggered_x1_AND_x2": item3a(),
           "item3b_ceiling_sums_k20": item3b(),
           "item4_capture": item4(T4),
           "item5_minimum_exception": item5(),
           "item6_active_part_monte_carlo": item6()}
    # consistency with results/circuits.json counts (x1 AND x2 query form)
    tgt = cc.table_of(3, lambda u: u[0] & u[1])
    dm = cc.mask_of([(a, b, 0) for a in (0, 1) for b in (0, 1)])
    for s in (2, 3):
        sh, dev, fit = cc.deviation_mass(T3[s - 1], tgt, dm, cc.idx((1, 1, 1)), 1)
        r = res["item3a_separably_triggered_x1_AND_x2"]["s=%d" % s]
        assert (r["fit"], r["dev"]) == (fit, dev), (s, r, fit, dev)
    res["runtime_seconds"] = round(time.time() - t0, 1)
    os.makedirs(os.path.join(HERE, "results"), exist_ok=True)
    with open(os.path.join(HERE, "results", "circuits_extra.json"), "w") as fh:
        json.dump(res, fh, indent=1)
    print("wrote results/circuits_extra.json in %.1f s" % (time.time() - t0))


if __name__ == "__main__":
    main()
