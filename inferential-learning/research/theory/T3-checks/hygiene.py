"""T3 Thm 1.4(c): local essential use does not certify a reductio.
K = {A->q, ~A->q, ~q} is inconsistent; the reductio of A uses {A->q, ~q} (satisfiable without A),
the reductio of ~A uses {~A->q, ~q} (satisfiable without ~A). Both pass the local test.
Also: the 100 = 99.9 example under exact vs interval reading."""
import itertools
imp = lambda a, b: (not a) or b
def sat(fs):
    return any(all(f(A, q) for f in fs) for A, q in itertools.product([0, 1], repeat=2))
K = [lambda A, q: imp(A, q), lambda A, q: imp(not A, q), lambda A, q: not q]
print("K satisfiable:", sat(K))
used_A = [K[0], K[2]]; used_nA = [K[1], K[2]]
print("reductio of A: used premises satisfiable:", sat(used_A), "; with A:", sat(used_A + [lambda A, q: A]))
print("reductio of ~A: used premises satisfiable:", sat(used_nA), "; with ~A:", sat(used_nA + [lambda A, q: not A]))
# 100 = 99.9: lengths from two models with tolerances; exact reading derives 0 = 0.1, interval reading does not
flat, sph, tol = (100.0, 0.2), (99.9, 0.2), None
lo = max(flat[0]-flat[1], sph[0]-sph[1]); hi = min(flat[0]+flat[1], sph[0]+sph[1])
print("exact reading: 100 = x = 99.9 -> 0.1 = 0 (bot);  interval reading: x in [%.1f, %.1f], nonempty: %s" % (lo, hi, lo <= hi))
