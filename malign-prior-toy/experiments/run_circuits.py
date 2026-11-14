"""Exact values of Computation 22 of research/circuits-final.md (small circuits, fixed-size prior mu_s).

All values are shares of circuits under mu_s, the uniform distribution on the
circuits of size s (research/circuits-final.md, Section 1.1), computed as exact
fractions from the counts of code/circuit_count.py.

(i)   Query form.  Data D = all inputs with the frozen input v (= x_3 for k=3,
      x_4 for k=4) equal to 0, labelled by the target; query u = the input with
      all other inputs 1 and v = 1.  Deviation mass = 1 - pi(d | u, D), where d is
      the world's own answer at u: the share, among the size-s circuits that agree
      with the target on D, of those whose value at u differs from d.  For the
      first four rows the world is the target itself; for the last row the data
      are those of x1 AND x2 and the world is (x1 AND x2) XOR v, so d = 0.
(ii)  Shares at s=5, among the circuits fitting the data of x1 AND x2 (k=3,
      v = x3 frozen at 0), of those computing exactly target XOR v, target OR v,
      target AND NOT v.
(iii) AND family (Theorem 11(b)): target x1 AND ... AND xk, data = the k+1 inputs
      with at most one 0; deviation mass at an input with two 0s (and three 0s for
      k=4), which by the symmetry of the prior under permuting the inputs is the
      same for every such input (checked); and the share of the fitting circuits
      that compute the target everywhere.
(iv)  Sequence form, k=4, index reading: positions t = 1..16, inputs b_0..b_3 =
      binary digits of t-1.  Context = the first n bits of the world's truth table;
      off-truth mass at the next bit = the share, among the size-s circuits whose
      truth table begins with the context, of those whose bit n+1 differs from the
      world's.

Run:  python3 run_circuits.py      (measured: about 19 s on the machine that produced
      results/circuits.json, of which 15 s are the k=3 counts up to s=5)
Writes results/circuits.json.
"""
import json
import os
import sys
import time
from fractions import Fraction
from itertools import product

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))
import circuit_count as cc  # noqa: E402


def val(x):
    if x is None:
        return None
    return {"exact": str(x), "float": float(x)}


def query_rows(T3, T4):
    k3_data = [(a, b, 0) for a in (0, 1) for b in (0, 1)]
    k4_data = [(a, b, c, 0) for a in (0, 1) for b in (0, 1) for c in (0, 1)]
    specs = [
        ("x1 AND x2", 3, lambda u: u[0] & u[1], lambda u: u[0] & u[1], k3_data, (1, 1, 1), T3),
        ("x1 XOR x2", 3, lambda u: u[0] ^ u[1], lambda u: u[0] ^ u[1], k3_data, (1, 1, 1), T3),
        ("x1", 3, lambda u: u[0], lambda u: u[0], k3_data, (1, 1, 1), T3),
        ("(x1 AND x2) XOR x3", 4, lambda u: (u[0] & u[1]) ^ u[2], lambda u: (u[0] & u[1]) ^ u[2],
         k4_data, (1, 1, 1, 1), T4),
        ("(x1 AND x2) XOR v", 3, lambda u: u[0] & u[1], lambda u: (u[0] & u[1]) ^ u[2], k3_data, (1, 1, 1), T3),
    ]
    rows = []
    for name, k, target, world, data, query, T in specs:
        t = cc.table_of(k, target)
        w = cc.table_of(k, world)
        dmask = cc.mask_of(data)
        assert (t ^ w) & dmask == 0
        q = cc.idx(query)
        own = cc.bit(w, q)
        sD = cc.least_fitting_size(T, t, dmask)
        by = {}
        for s in range(sD, len(T) + 1):
            share, dev, fit = cc.deviation_mass(T[s - 1], t, dmask, q, own)
            by[str(s)] = {"fitting": fit, "deviating": dev, "deviation_mass": val(share)}
        rows.append({"world": name, "k": k, "data": ["".join(map(str, u)) for u in data],
                     "query": "".join(map(str, query)), "own_answer": own, "s_D": sD, "by_size": by})
    return rows


def triggered(T3):
    k = 3
    t = cc.table_of(k, lambda u: u[0] & u[1])
    dmask = cc.mask_of([(a, b, 0) for a in (0, 1) for b in (0, 1)])
    variants = [("target XOR v", lambda u: (u[0] & u[1]) ^ u[2]),
                ("target OR v", lambda u: (u[0] & u[1]) | u[2]),
                ("target AND NOT v", lambda u: (u[0] & u[1]) & (1 - u[2]))]
    out = {}
    for name, g in variants:
        share, num, fit = cc.function_share(T3[4], t, dmask, cc.table_of(k, g))
        out[name] = {"s": 5, "count": num, "fitting": fit, "share": val(share)}
    return out


def and_family(T3, T4):
    out = {}
    for k, T in ((3, T3), (4, T4)):
        t = cc.table_of(k, lambda u: int(all(u)))
        data = [u for u in product((0, 1), repeat=k) if sum(u) >= k - 1]
        dmask = cc.mask_of(data)
        sD = cc.least_fitting_size(T, t, dmask)
        rec = {"k": k, "s_D": sD, "data": ["".join(map(str, u)) for u in data], "by_size": {}}
        for s in range(sD, len(T) + 1):
            e = {}
            for zeros in (2, 3):
                if zeros > k:
                    continue
                qs = [u for u in product((0, 1), repeat=k) if k - sum(u) == zeros]
                shares = set()
                for u in qs:
                    share, dev, fit = cc.deviation_mass(T[s - 1], t, dmask, cc.idx(u), 0)
                    shares.add(share)
                assert len(shares) == 1, (k, s, zeros)   # symmetry of mu_s under permuting inputs
                e["deviation_mass_%d_zeros" % zeros] = val(shares.pop())
            share, num, fit = cc.function_share(T[s - 1], t, dmask, t)
            e["target_everywhere"] = val(share)
            e["fitting"] = fit
            rec["by_size"][str(s)] = e
        out["k=%d" % k] = rec
    return out


def sequence_rows(T4):
    k = 4
    worlds = [("(b0 AND b1) XOR b3", lambda b: (b[0] & b[1]) ^ b[3], (8,)),
              ("(b0 AND b1) XOR b2", lambda b: (b[0] & b[1]) ^ b[2], (8,)),
              ("b0 AND b1", lambda b: b[0] & b[1], (4, 8)),
              ("constant 0", lambda b: 0, (4, 8))]
    rows = []
    for name, f, cuts in worlds:
        w = cc.table_of(k, f)
        tt = "".join(str(cc.bit(w, u)) for u in range(1 << k))
        for n in cuts:
            dmask = cc.prefix_mask(n)
            own = cc.bit(w, n)                      # bit n+1 is input index n
            by = {}
            for s in range(1, len(T4) + 1):
                share, dev, fit = cc.deviation_mass(T4[s - 1], w, dmask, n, own)
                by[str(s)] = {"fitting": fit, "off_truth": dev, "off_truth_mass": val(share)}
            rows.append({"world": name, "truth_table": tt, "n": n, "context": tt[:n], "next_bit": own,
                         "size_of_context": cc.least_fitting_size(T4, w, dmask), "by_size": by})
    return rows


def main():
    t0 = time.time()
    T3 = cc.counts_by_function(3, 5)
    T4 = cc.counts_by_function(4, 4)
    for k, T in ((3, T3), (4, T4)):
        for s, c in enumerate(T, start=1):
            assert sum(c.values()) == cc.N(k, s)
    res = {
        "model": "circuits of research/circuits-final.md Section 1.1; prior mu_s uniform on circuits of size s",
        "query_form": query_rows(T3, T4),
        "triggered_variants_x1_AND_x2": triggered(T3),
        "and_family": and_family(T3, T4),
        "sequence_form_k4": sequence_rows(T4),
    }
    os.makedirs(os.path.join(HERE, "results"), exist_ok=True)
    with open(os.path.join(HERE, "results", "circuits.json"), "w") as fh:
        json.dump(res, fh, indent=1)
    print("wrote results/circuits.json in %.1f s" % (time.time() - t0))


if __name__ == "__main__":
    main()
