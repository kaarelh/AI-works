"""c4: exact finite-class sanity check of the dominance / merging identities (notes.md Thm 6.1, 6.5).

A finite Bayes mixture M = sum_i w_i nu_i of random-function laws on X = {0,1,2,3}, Y = {0,1}
stands in for M_F (the universal case has the same algebra with w_nu = 2^{-K(nu)}).
Class: two deterministic functions, two product (private-randomness) laws, two shared-
randomness laws, the uniform law.  For every true law nu_i we check exactly:
  (1) pathwise: max_D log2 nu_i(D)/M(D) <= -log2 w_i            (dominance, Thm 6.1);
  (2) -log2 M(D_n) is the same for all 24 reveal orders of every total function (order
      independence of the semimeasure loss, Prop 5.2);
  (3) for every horizon n <= 4, the maximum over ALL adaptive input-selection strategies
      (dynamic programming over histories) of E_nu sum_t KL(nu(.|D,x) || M(.|D,x)) in bits
      is <= -log2 w_i (merging bound, Thm 6.5), and for n = 4 it equals E log2 nu(F)/M(F).

Deterministic.  Output: c4_finite_mixture_merging.out.txt
"""
import itertools
import math

X = (0, 1, 2, 3)
FUNCS = list(itertools.product((0, 1), repeat=len(X)))  # total functions as tuples


def law_det(f):
    return {g: (1.0 if g == f else 0.0) for g in FUNCS}


def law_prod(p):
    out = {}
    for g in FUNCS:
        pr = 1.0
        for x in X:
            pr *= p[x] if g[x] == 1 else 1 - p[x]
        out[g] = pr
    return out


def law_shared_const():
    return {g: (0.5 if len(set(g)) == 1 else 0.0) for g in FUNCS}


def law_shared_parity_bits():
    # F(x) = omega_{x mod 2}
    return {g: (0.25 if (g[0] == g[2] and g[1] == g[3]) else 0.0) for g in FUNCS}


def law_uniform():
    return {g: 1.0 / len(FUNCS) for g in FUNCS}


CLASS = [
    ("det zeros", law_det((0, 0, 0, 0)), 1 / 4),
    ("det x mod 2", law_det((0, 1, 0, 1)), 1 / 8),
    ("prod Bern(.3)", law_prod({x: 0.3 for x in X}), 1 / 8),
    ("prod p=(x+1)/5", law_prod({x: (x + 1) / 5 for x in X}), 1 / 8),
    ("shared constant bit", law_shared_const(), 1 / 8),
    ("shared omega_{x mod 2}", law_shared_parity_bits(), 1 / 8),
    ("uniform", law_uniform(), 1 / 8),
]


def cont(law, D):
    return sum(p for g, p in law.items() if all(g[x] == y for x, y in D))


MIX = {g: sum(w * law[g] for _, law, w in CLASS) for g in FUNCS}


def all_partial():
    for vals in itertools.product((None, 0, 1), repeat=len(X)):
        yield tuple((x, v) for x, v in zip(X, vals) if v is not None)


def kl_bits(p, q):
    return sum(pi * math.log2(pi / qi) for pi, qi in zip(p, q) if pi > 0)


def best_adaptive(law, D, n):
    """max over adaptive strategies of E sum KL over the next n queries, from history D."""
    if n == 0:
        return 0.0
    dom = {x for x, _ in D}
    best = 0.0
    nuD = cont(law, D)
    mD = cont(MIX, D)
    for x in X:
        if x in dom:
            continue
        val = 0.0
        p = [cont(law, D + ((x, y),)) / nuD for y in (0, 1)]
        q = [cont(MIX, D + ((x, y),)) / mD for y in (0, 1)]
        val += kl_bits(p, q)
        for y in (0, 1):
            if p[y] > 0:
                val += p[y] * best_adaptive(law, D + ((x, y),), n - 1)
        best = max(best, val)
    return best


def main():
    lines = []
    # (2) order independence of -log2 M over reveal orders
    max_spread = 0.0
    for g in FUNCS:
        losses = []
        for order in itertools.permutations(X):
            D = ()
            loss = 0.0
            for x in order:
                loss -= math.log2(cont(MIX, D + ((x, g[x]),)) / cont(MIX, D))
                D = D + ((x, g[x]),)
            losses.append(loss)
        max_spread = max(max_spread, max(losses) - min(losses))
    lines.append(f"(2) max over functions of (max-min) cumulative loss across 24 orders: {max_spread:.2e}")
    for name, law, w in CLASS:
        bound = -math.log2(w)
        path = max(math.log2(cont(law, D) / cont(MIX, D)) for D in all_partial() if cont(law, D) > 0)
        lines.append(f"law '{name}', w={w}, bound -log2 w = {bound:.4f}")
        lines.append(f"   (1) pathwise max log2 nu(D)/M(D) = {path:.4f}  <= bound: {path <= bound + 1e-12}")
        full = sum(p * math.log2(p / MIX[g]) for g, p in law.items() if p > 0)
        for n in range(1, len(X) + 1):
            v = best_adaptive(law, (), n)
            extra = f", E log2 nu(F)/M(F) = {full:.4f}" if n == len(X) else ""
            lines.append(f"   (3) horizon {n}: max over adaptive strategies of E sum KL = {v:.4f}"
                         f"  <= bound: {v <= bound + 1e-12}{extra}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
