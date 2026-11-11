# Re-run the Lemma C search and report the worst instance's parameters (sanity probe).
import numpy as np, runpy, io, contextlib
src = open('check_lemmas_AC.py').read().split('# Lemma A:')[0]
src = src.replace("worst_sharp = max(worst_sharp, best / bs); worst_closed = max(worst_closed, best / bc)",
                  "worst_sharp = max(worst_sharp, best / bs); worst_closed = max(worst_closed, best / bc)\n    rec.append((best/bs, H, d, N, K, eta, best, bs))")
src = "rec=[]\n" + src
g = {}
exec(compile(src, 'probe', 'exec'), g)
rec = sorted(g['rec'], reverse=True)[:5]
for r in rec:
    print("ratio=%.3f H=%d d=%d N=%d K=%.1f eta=%g |dz|=%.4g sharp=%.4g" % r)
