"""c6: the counting lemma behind Prop 4.5(iii) (SFI^set cannot track the order).

A deterministic set-hypothesis g maps (T, x), with T a finite set of previous inputs and x the
current input, to a label.  Fix a set S of n inputs.  An order sigma = (x_1, ..., x_n) of S is
consistent with g for the labelling 'y_1 = empty, y_i = x_{i-1}' iff
    g(emptyset, x_1) = empty   and   g({x_1..x_{i-1}}, x_i) = x_{i-1}  for i = 2..n.
Lemma (proved in notes.md by backward reconstruction): at most n orders are consistent with any
single g.  Here we compute, for n = 2..5, the maximum number of orders that can be simultaneously
consistent with one g: the maximum clique of the graph on the n! orders in which two orders are
adjacent iff they never require different values of g on the same argument (T, x).
Deterministic (no randomness); seed recorded as 0.  Output saved to c6_set_order_lemma.out.
"""
import itertools

SEED = 0

def constraints(order):
    c = {(frozenset(), order[0]): None}
    for i in range(1, len(order)):
        c[(frozenset(order[:i]), order[i])] = order[i - 1]
    return c

def compatible(c1, c2):
    for k, v in c1.items():
        if k in c2 and c2[k] != v:
            return False
    return True

def max_clique(adj, nverts):
    best = []
    def bk(R, P, X):
        nonlocal best
        if not P and not X:
            if len(R) > len(best):
                best = list(R)
            return
        if len(R) + len(P) <= len(best):
            return
        u = max(P | X, key=lambda v: len(adj[v] & P))
        for v in list(P - adj[u]):
            bk(R + [v], P & adj[v], X & adj[v])
            P = P - {v}
            X = X | {v}
    bk([], set(range(nverts)), set())
    return best

for n in range(2, 6):  # n = 6 (720 orders) is too slow for this simple clique search
    orders = list(itertools.permutations(range(n)))
    cons = [constraints(o) for o in orders]
    adj = [set() for _ in orders]
    for i in range(len(orders)):
        for j in range(i + 1, len(orders)):
            if compatible(cons[i], cons[j]):
                adj[i].add(j); adj[j].add(i)
    cl = max_clique(adj, len(orders))
    lasts = sorted(orders[i][-1] for i in cl)
    print(f"n={n}: {len(orders)} orders; max number simultaneously consistent with one g = {len(cl)} "
          f"(lemma bound n = {n}); last elements of a maximum family: {lasts}")
    assert len(cl) <= n
print("ALL CHECKS PASSED")
