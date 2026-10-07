"""Sanity checks for Sections 6 (robust core / supervaluation) and 7 (steeper simplicity penalty) of T4."""
import itertools, random
from fractions import Fraction


# ---------------------------------------------------------------- Section 6: sorites = majority-valid steps do not chain
def sorites(n):
    # sentences heap(k), k = 0..n ; sharpening c in {1..n}: heap(k) true iff k >= c
    sharpenings = range(1, n + 1)
    val = lambda c, k: k >= c
    steps = [(k, k - 1) for k in range(1, n + 1)]          # heap(k) => heap(k-1)
    frac_valid = [Fraction(sum(1 for c in sharpenings if (not val(c, a)) or val(c, b)), n) for a, b in steps]
    chain_valid_under = [c for c in sharpenings if (not val(c, n)) or val(c, 0)]
    return frac_valid, chain_valid_under


def union_bound_check(trials=2000, seed=1):
    """Random finite 'sharpening' models: if each step of a chain is valid w.p. >= 1-eps over sharpenings,
    the chain is valid w.p. >= 1 - n*eps.  (Exact check on random instances.)"""
    rng = random.Random(seed)
    for _ in range(trials):
        n_sent, n_sharp, L = 6, rng.randint(2, 8), rng.randint(1, 5)
        # each sharpening is a valuation of sentences 0..n_sent-1 that must make every 'base' step it accepts sound;
        vals = [[rng.random() < 0.5 for _ in range(n_sent)] for _ in range(n_sharp)]
        chain = [rng.randrange(n_sent) for _ in range(L + 1)]
        step_ok = lambda v, a, b: (not v[a]) or v[b]
        eps = max(1 - sum(step_ok(v, chain[i], chain[i + 1]) for v in vals) / n_sharp for i in range(L))
        # a chain is valid under v iff premise true => conclusion true; it is implied by all steps valid under v
        all_steps = sum(all(step_ok(v, chain[i], chain[i + 1]) for i in range(L)) for v in vals) / n_sharp
        assert all_steps >= 1 - L * eps - 1e-12
    return True


# ---------------------------------------------------------------- Section 7: steeper simplicity penalty
RULES = {  # name: (description length l, frequency pi, per-datum compression gain g, valid?)
    'A_common_valid': (10, 0.50, 8, True),
    'B_rare_long_valid': (40, 0.01, 8, True),
    'F_freshman_dream': (8, 0.05, 8, False),
}


def J(Rset, lam, N):
    # additive two-part code: lam * sum l(r) + N * sum_{r not in R} pi_r * g_r  (+ constant)
    return lam * sum(RULES[r][0] for r in Rset) + N * sum(RULES[r][1] * RULES[r][2] for r in RULES if r not in Rset)


def map_sets(N=1000):
    out = []
    names = list(RULES)
    lams = [N * k for k in [1e-4, 1e-3, 3e-3, 1e-2, 3e-2, 0.1, 0.3, 0.5, 1.0]]
    for lam in lams:
        best = min((frozenset(s) for k in range(len(names) + 1) for s in itertools.combinations(names, k)),
                   key=lambda s: J(s, lam, N))
        out.append((lam / N, sorted(best)))
    truth = frozenset(r for r in RULES if RULES[r][3])
    selectable = any(frozenset(b) == truth for _, b in out)
    # lower-convex-hull test: is (l(R*), NLL(R*)) a vertex for some lam > 0?  scan lam finely
    hit = False
    for i in range(1, 20001):
        lam = N * i * 1e-5
        best = min((frozenset(s) for k in range(len(names) + 1) for s in itertools.combinations(names, k)),
                   key=lambda s: J(s, lam, N))
        if best == truth:
            hit = True; break
    return out, selectable, hit


if __name__ == '__main__':
    for n in [3, 5, 10]:
        fv, cv = sorites(n)
        print(f"sorites n={n}: each step valid under fraction {[str(f) for f in fv]} of sharpenings; "
              f"chain heap({n}) => heap(0) valid under sharpenings {cv}")
    print("union bound check on random sharpening models:", union_bound_check())
    out, sel, hit = map_sets()
    print("steeper-penalty MAP rule sets by kappa = lambda/N:")
    for k, b in out:
        print(f"   kappa={k:<7} MAP={b}")
    print("true rule set {A,B} selected for some kappa in scan:", hit)
    for r, (l, p, g, v) in RULES.items():
        print(f"   {r}: compression rate pi*g/l = {p*g/l:.4f} (valid={v})")
