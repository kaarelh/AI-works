"""c = 1, lambda = 1: the "Numbers" paragraph of Corollary 5.2 (depth-two.md, section 4).

For the accuracy choices a = 1/n and a = 1/d, on the worst case of the event of Lemma 1.3, with
th = 1/(18 d + 1) and eps_d = gamma(1) th^2 / 3, over 1 <= d <= 1000:
  - the first d at which the bound max(Psi_tri, Psi_cor) is positive, the largest Psi_tri, and the largest
    value of the bound with its location;
  - the d with Psi_cor >= 2 eps_d, reported as the first such d and the exceptions after it;
  - the minimum of the ratio Psi_cor / (gamma th^2) from that first d up to 1000;
  - whether the ratio is nondecreasing on [31, 1000] (informational; the note does not use monotonicity).
mpmath runs at 200 digits. For a = 1/n the ratio differs from 1 by about 3e-100 at d = 1000. At the 80 digits
of an earlier version, rounding noise showed up as 68 spurious decreases at d >= 806 (second-round computation
referee, who found none at 200 digits).
"""
import sys
sys.path.insert(0, '.')
import mpmath as mp
from bounds_t51 import event_box, t51, gam
mp.mp.dps = 200

D_MAX, D_MONO = 1000, 30
g1 = gam(1)
res = {'1/n': [], '1/d': []}
for d in range(1, D_MAX + 1):
    B = event_box(d, 1.0)
    for label, a in (('1/n', 1 / B['n']), ('1/d', mp.mpf(1) / d)):
        tri, cor, th = t51(d, 1, a, 1.0, B)
        res[label].append((d, cor / (g1 * th ** 2), cor >= 2 * g1 * th ** 2 / 3, max(tri, cor), tri))

for label in ('1/n', '1/d'):
    rows = res[label]
    first_pos = next(d for d, r, ok, b, tri in rows if b > 0)
    max_tri = max(tri for d, r, ok, b, tri in rows)
    dmax, bmax = max(((d, b) for d, r, ok, b, tri in rows), key=lambda t: t[1])
    first = next(d for d, r, ok, b, tri in rows if ok)
    after = [(d, r, ok) for d, r, ok, b, tri in rows if d >= first]
    bad = [d for d, r, ok in after if not ok]
    dmin, rmin = min(((d, r) for d, r, ok in after), key=lambda t: t[1])
    mono = [(d, r) for d, r, ok, b, tri in rows if d >= D_MONO]
    dec = [mono[i][0] for i in range(1, len(mono)) if mono[i][1] < mono[i - 1][1]]
    print("a = %s:" % label)
    print("  first d >= 1 with a positive bound: %d; largest Psi_tri over 1 <= d <= %d: %s" % (
        first_pos, D_MAX, mp.nstr(max_tri, 3)))
    print("  largest bound over 1 <= d <= %d: %s at d = %d" % (D_MAX, mp.nstr(bmax, 5), dmax))
    print("  first d >= 1 with Psi_cor >= 2 eps_d: %d; exceptions in [%d, %d]: %s" % (first, first, D_MAX, bad))
    print("  min ratio Psi_cor/(gamma th^2) over [%d, %d]: d = %d, %s (2/3 needed)" % (first, D_MAX, dmin, mp.nstr(rmin, 6)))
    print("  d in [%d, %d] where the ratio decreases: %s (count %d); 1 - ratio at d = %d: %s" % (
        D_MONO + 1, D_MAX, dec[:10], len(dec), D_MAX, mp.nstr(1 - rows[-1][1], 4)))
