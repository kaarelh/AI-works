"""Extension of realizability.py with a SUPPOSITIONAL context (T3 Thm 2.4(a), SUP-collapse form; numbered Thm 2.3 in an earlier draft).
Context 0 = root (single world), 1 = IDL child of 0 (free semantic value, possibly empty),
2 = SUP child of 0 or of 1 with assumption A: its value is forced, M_2 = M_parent ∩ ||A||.
Claim: realizable  <=>  the anchored criterion holds after collapsing context 2 into its parent
(each judgment (2, Gamma, phi) becomes (parent, Gamma + [A], phi)).  Reductio immunity is the special
case phi = bot: it only adds the parent judgment  A -> bot."""
import itertools, random
import realizability as R
def random_instance(rng):
    par2 = rng.choice([0, 1]); A = rng.choice(R.NAMES)
    J, bridges = [], []
    for _ in range(rng.randint(1, 6)):
        c = rng.choice([0, 1, 2, 2]); G = rng.sample(R.NAMES, rng.choice([0, 0, 1])); J.append((c, tuple(G), rng.choice(R.NAMES)))
    if rng.random() < 0.6:
        a = rng.randint(0, 2); s = rng.choice(["top", "p", "~p"])
        bridges.append((1, a, s)); J += [(1, (), f"Q={a}"), (0, (), s), (0, (), f"Q={a}")]
    certC = {1} if rng.random() < 0.25 else set()
    return par2, A, J, bridges, certC
def brute(par2, A, J, bridges, certC):
    subsets = [frozenset(x) for r in range(len(R.VALS)+1) for x in itertools.combinations(R.VALS, r)]
    for w in R.VALS:
        for M1 in subsets:
            M = {0: [w], 1: list(M1)}
            M[2] = [v for v in M[par2] if R.ATOMS[A](v)]
            if not all(R.holds(M[c], G, f) for (c, G, f) in J): continue
            if any(R.holds(M[1], (), f"Q={a2}") and R.holds(M[0], (), s) and not R.holds(M[0], (), f"Q={a2}")
                   for (c, a, s) in bridges for a2 in range(3)): continue
            if 1 in certC and len(M[1]) == 0: continue
            return True
    return False
def criterion(par2, A, J, bridges, certC):
    Jc = [((par2 if c == 2 else c), (G + (A,) if c == 2 else G), f) for (c, G, f) in J]
    parent = {1: 0, 2: par2}
    return R.criterion(parent, Jc, bridges, certC, [])
rng = random.Random(3); mism = 0; real = 0; n = 3000
for _ in range(n):
    inst = random_instance(rng); b = brute(*inst); real += b
    if b != criterion(*inst):
        mism += 1; print("MISMATCH", inst, b)
print(f"SUP-collapse criterion: instances {n}, realizable {real}, mismatches {mism}")
