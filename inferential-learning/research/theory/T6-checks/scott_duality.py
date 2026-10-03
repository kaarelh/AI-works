"""T6 check 1: bilateral (Scott / Shoesmith-Smiley) completeness on a finite language.
Formulas are treated as n independent symbols; a sequent is (G, D) with G, D subsets of range(n),
encoded as bitmasks. Syntactic closure: overlap + weakening + cut.  Semantic closure: Th(Mod(S)).
Also checks: closed sets of valuations <-> Scott relations is a bijection (n=3, exhaustive)."""
import itertools, random

def scott_closure(S, n):
    full = (1 << n) - 1
    R = set()
    for G in range(1 << n):
        for D in range(1 << n):
            if G & D:
                R.add((G, D))
    R |= set(S)
    changed = True
    while changed:
        changed = False
        # weakening
        new = set()
        for (G, D) in R:
            for G2 in range(1 << n):
                if G2 & G == G:
                    for D2 in range(1 << n):
                        if D2 & D == D and (G2, D2) not in R:
                            new.add((G2, D2))
        if new:
            R |= new; changed = True
        # cut on each formula i
        new = set()
        for i in range(n):
            b = 1 << i
            left = [(G, D) for (G, D) in R if G & b]       # G, phi |> D
            right = set((G, D) for (G, D) in R if D & b)   # G |> phi, D
            for (G1, D1) in left:
                G = G1 & ~b; D = D1
                # by weakening already applied, it suffices to look for (G, D|b) in R
                if (G, D | b) in R and (G, D) not in R:
                    new.add((G, D))
        if new:
            R |= new; changed = True
    return R

def models(S, n):
    out = []
    for v in range(1 << n):
        if all(not ((G & v) == G and (D & v) == 0) for (G, D) in S):
            out.append(v)
    return out

def th(V, n):
    return set((G, D) for G in range(1 << n) for D in range(1 << n)
               if all(not ((G & v) == G and (D & v) == 0) for v in V))

random.seed(1)
n = 4
for trial in range(300):
    k = random.randint(0, 6)
    S = set((random.randrange(1 << n), random.randrange(1 << n)) for _ in range(k))
    syn = scott_closure(S, n)
    sem = th(models(S, n), n)
    assert syn == sem, (S,)
print("bilateral completeness: syntactic Scott closure == Th(Mod(S)) on 300 random sets, n=4: OK")

# exhaustive duality for n=3: every set of valuations is closed (finite space) and
# V -> Th(V) is injective, with Mod(Th(V)) = V.
n = 3
seen = {}
for mask in range(1 << (1 << n)):
    V = [v for v in range(1 << n) if mask >> v & 1]
    T = frozenset(th(V, n))
    assert sorted(models(T, n)) == V
    assert T not in seen
    seen[T] = mask
print("duality n=3: all", len(seen), "sets of valuations are Galois-closed and Th is injective: OK")
