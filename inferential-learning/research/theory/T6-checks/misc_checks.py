"""T6 check 5: (a) Nullstellensatz instances (coherence = 1 not in ideal; points only over the closure);
(b) single-conclusion Galois-closed sets of valuations = families closed under intersections (incl. top)."""
import itertools
import sympy as sp

x, y = sp.symbols("x y")
for F in [[x**2 - 2], [x**2 + 1], [x*y - 1, x], [x**2 - 2*y**2, y - 1]]:
    G = sp.groebner(F, x, y, order="lex", domain="QQ")
    incoherent = (list(G.exprs) == [1])
    sols_Q = [s for s in sp.solve(F, [x, y], dict=True)
              if all(v.is_rational for v in s.values())] if not incoherent else []
    sols_C = sp.solve(F, [x, y], dict=True)
    print("(a) %-22s incoherent(1 in ideal)=%-5s  rational points=%s  complex points=%s"
          % (F, incoherent, sols_Q, sols_C))

# (b) n = 3 'formulas'; single-conclusion sequents (G, phi); Th1(V), Mod(Th1(V)) == intersection-closure of V u {top}
n = 3
def th1(V):
    return set((G, f) for G in range(1 << n) for f in range(n)
               if all(not ((G & v) == G and not (v >> f & 1)) for v in V))
def mod1(S):
    return [v for v in range(1 << n) if all(not ((G & v) == G and not (v >> f & 1)) for (G, f) in S)]
def icl(V):
    out = set(V) | {(1 << n) - 1}
    changed = True
    while changed:
        changed = False
        for a, b in itertools.combinations(list(out), 2):
            if a & b not in out:
                out.add(a & b); changed = True
    return sorted(out)
for mask in range(1 << (1 << n)):
    V = [v for v in range(1 << n) if mask >> v & 1]
    assert sorted(mod1(th1(V))) == icl(V)
print("(b) single-conclusion closure of every V (n=3) is its intersection-closure with top: OK")
