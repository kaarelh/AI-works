"""Brute-force check of the proposition on missing pairs (Proposition 4a of equational.md).

Data: plus on [0, n)^2 except a set U of holes. For every identity with sides of at most m
symbols (three variables) that is false of plus, search for an assignment with values 0..K at
which both sides can be evaluated from the data and differ (K = (m-1)*|U| + 1, as in the
proof). The proposition says: if none exists, a side contains a ground term f(r1, r2) whose
arguments have values (a, b) in U.

Usage: python3 holes_check.py
"""
import itertools

from eqlib import Stuck, ev, show_id, size, terms_by_size, variables


def ground_value(t):
    """plus-value of a ground term, or None if it has a variable."""
    if variables(t):
        return None
    return ev(t, {}, {"f": lambda a, b: a + b})[0]


def names_hole(t, U):
    if t[0] == "f":
        a, b = ground_value(t[1]), ground_value(t[2])
        if a is not None and b is not None and (a, b) in U:
            return True
    return any(names_hole(c, U) for c in t[1:] if isinstance(c, tuple))


def run(m, n, U):
    U = set(U)
    K = (m - 1) * len(U) + 1
    assert n >= m * m * (len(U) + 1)

    def data(a, b):
        if a < n and b < n and (a, b) not in U:
            return a + b
        raise Stuck

    plus = {"f": lambda a, b: a + b}
    terms = [t for s in range(1, m + 1) for t in terms_by_size(m, 2, 3)[s]]
    grid = list(itertools.product(range(K + 1), repeat=3))
    # value vectors under plus (for falsity) and under the data (None where not evaluable)
    pv, dv = [], []
    for t in terms:
        p, d = [], []
        for u in grid:
            env = dict(enumerate(u))
            p.append(ev(t, env, plus)[0])
            try:
                d.append(ev(t, env, {"f": data})[0])
            except Stuck:
                d.append(None)
        pv.append(p)
        dv.append(d)
    false = unrefuted = bad = 0
    examples = []
    for i in range(len(terms)):
        for j in range(i + 1, len(terms)):
            if pv[i] == pv[j]:
                continue                      # true of plus on the grid, hence everywhere (linear forms)
            false += 1
            if any(a is not None and b is not None and a != b for a, b in zip(dv[i], dv[j])):
                continue                      # refuted by the data
            unrefuted += 1
            if names_hole(terms[i], U) or names_hole(terms[j], U):
                if len(examples) < 3:
                    examples.append(show_id((terms[i], terms[j])))
            else:
                bad += 1
                print("   COUNTEREXAMPLE", show_id((terms[i], terms[j])))
    print(f"m = {m}, n = {n}, holes {sorted(U)}: {false} false identities, {unrefuted} not refuted, "
          f"{bad} of these name no hole; e.g. {examples}")


if __name__ == "__main__":
    run(4, 32, [(0, 0)])
    run(5, 50, [(1, 1)])
    run(5, 75, [(1, 0), (0, 2)])
    run(5, 50, [(2, 2)])          # a + b + 3 = 7 > m: no side can name the hole
    run(6, 72, [(1, 1)])
