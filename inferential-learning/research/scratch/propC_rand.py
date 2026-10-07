import itertools, random
from fractions import Fraction as F
random.seed(3)
nv = 8  # valuations of 3 atoms
SENT = [frozenset(s) for r in range(nv+1) for s in itertools.combinations(range(nv), r)]
bad_mix = bad_bel = 0; r1_coh = r2_coh = 0; trials = 400
for _ in range(trials):
    k = random.randint(1, 4)
    hyps = []
    for _ in range(k):
        M = frozenset(random.sample(range(nv), random.randint(1, nv)))
        lam = {v: F(random.randint(1, 5)) for v in M}; s = sum(lam.values())
        lam = {v: w/s for v, w in lam.items()}
        hyps.append((M, F(random.randint(1, 5)), lam))
    Z = sum(w for _, w, _ in hyps); hyps = [(M, w/Z, l) for M, w, l in hyps]
    atoms = [sum(w*l.get(v, 0) for M, w, l in hyps) for v in range(nv)]
    for phi in SENT:
        bel = sum(w for M, w, _ in hyps if M <= phi)
        pl = 1 - sum(w for M, w, _ in hyps if not (M & phi))
        P = sum(atoms[v] for v in phi)
        if not (bel <= P <= pl): bad_mix += 1
    # Moebius inverse of Bel must equal mass on Mod(A) and be >= 0
    def bel(phi): return sum(w for M, w, _ in hyps if M <= phi)
    for phi in SENT:
        m = sum((-1)**(len(phi)-len(B))*bel(B) for B in SENT if B <= phi)
        if m < 0: bad_bel += 1
    # are R1/R2 coherent here?
    def ro(phi):
        pT = sum(w for M, w, _ in hyps if M <= phi); pF = sum(w for M, w, _ in hyps if not (M & phi))
        return pT, pF
    at1 = []; ok1 = True; ok2 = True
    vals1 = {}; vals2 = {}
    for phi in SENT:
        pT, pF = ro(phi)
        vals1[phi] = pT/(pT+pF) if pT+pF else None
        vals2[phi] = pT + (1-pT-pF)/2
    def coh(vals):
        a = [vals[frozenset({i})] for i in range(nv)]
        if any(x is None for x in a): return False
        return all(v is None or v == sum(a[i] for i in phi) for phi, v in vals.items()) and sum(a) == 1
    r1_coh += coh(vals1); r2_coh += coh(vals2)
print("Bel<=P<=Pl violations:", bad_mix, "| negative Moebius masses:", bad_bel)
print(f"R1 coherent in {r1_coh}/{trials} random cases, R2 coherent in {r2_coh}/{trials}")
# inconsistent hypothesis edge case
hyps = [(frozenset(), F(1,2)), (frozenset(range(nv)), F(1,2))]
phi = frozenset({0}); pT = sum(w for M, w in hyps if M <= phi); pF = sum(w for M, w in hyps if not (M & phi))
print("with an inconsistent A of weight 1/2: pT+pF on a contingent phi =", pT+pF, "; Bel(bottom) =", sum(w for M, w in hyps if M <= frozenset()))
