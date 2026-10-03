"""Product of k single-culprit blocks of size b: |H| = b^k.  Compare M_bag^(r) with the
upper bound ln|H| / ln(1+1/r) (Thm 4.6) and with k*min(r, b-1)."""
import itertools, math
from bag_vs_object_game import solve
def product_class(b, k):
    m = b * k; H = []
    for culprits in itertools.product(range(b), repeat=k):
        h = (1 << m) - 1
        for blk, c in enumerate(culprits): h &= ~(1 << (blk * b + c))
        H.append(h)
    return H, m
for (b, k) in [(2, 2), (3, 2), (2, 3)]:
    H, m = product_class(b, k)
    mo = solve(H, m, 'obj')
    for r in range(1, m + 1):
        mb = solve(H, m, 'bag', r)
        ub = math.log(len(H)) / math.log(1 + 1 / r)
        print(f"blocks b={b} k={k} |H|={len(H)} r={r}: M_obj={mo} M_bag={mb} bound={ub:.2f} k*min(r,b-1)={k*min(r,b-1)}")
