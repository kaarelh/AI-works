"""Check: R(n, m) = min over count vectors c (sum n, m parts) of DirMult_{1/2}(c) / prod_i (c_i/n)^{c_i}.

Used in notes Prop X8(b): for a mixture T* with fixed weights w, M_{T*}(D)/P_{T*,w}(D) >= R(n, m), so off the Ville
event pi(T*|D_n) > pi(T*) delta' R(n, m).  Prints log2 R and the slope of log2 R against log2 n (expected about
-(m-1)/2).  Exhaustive over count vectors for m = 2, 3, 4.  Command: python3 kt_regret.py
"""
import itertools
import math


def ldm(c, a=0.5):
    n, m = sum(c), len(c)
    return math.lgamma(m * a) - math.lgamma(m * a + n) + sum(math.lgamma(a + x) - math.lgamma(a) for x in c)


def lml(c):
    n = sum(c)
    return sum(x * math.log(x / n) for x in c if x > 0)


def comps(n, m):
    if m == 1:
        yield (n,)
        return
    for i in range(n + 1):
        for rest in comps(n - i, m - 1):
            yield (i,) + rest


for m in (2, 3, 4):
    prev = None
    out = []
    for n in (10, 40, 160, 640):
        if m == 4 and n > 160:
            continue
        r = min(ldm(c) - lml(c) for c in comps(n, m)) / math.log(2)
        out.append((n, round(r, 3)))
    slopes = [round((out[i + 1][1] - out[i][1]) / math.log2(out[i + 1][0] / out[i][0]), 3) for i in range(len(out) - 1)]
    print('m=%d  log2 R(n,m): %s  slopes vs log2 n: %s  (-(m-1)/2 = %.1f)' % (m, out, slopes, -(m - 1) / 2))
