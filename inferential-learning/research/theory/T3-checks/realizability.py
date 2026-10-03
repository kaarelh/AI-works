"""Brute-force check of the Realizability Theorem (T3, Thm 2.4(a): frame-free realizability, Def 2.3) on random small context skeletons.
(Docstring updated after verification: earlier drafts numbered this Thm 2.3 and the criterion R1-R3.)
Each context has valuations (p, Q) with p in {0,1}, Q in {0,1,2}. Root semantic value is a single
world w; a non-root context's value M_c is an arbitrary set of valuations (possibly empty).
Judgments (c, Gamma, phi) hold iff every v in M_c satisfying Gamma satisfies phi.
Bridge uses (c, a, sigma) export 'Q_c = a' to 'Q_parent = a' (eps = 0: informative) under side
condition sigma; schema soundness quantifies over all a'. Certified contexts/positions must be
nonempty. Claim: brute-force realizability == the anchored criterion of Thm 2.4(a).
NOTE: 'certified positions' (certP) are an extension not covered by Thm 2.4 as stated; instances using them
test a slightly more general statement."""
import itertools, random
VALS = [(p, q) for p in (0, 1) for q in (0, 1, 2)]
ATOMS = {"p": lambda v: v[0] == 1, "~p": lambda v: v[0] == 0, "bot": lambda v: False, "top": lambda v: True}
for a in range(3):
    ATOMS[f"Q={a}"] = (lambda a: lambda v: v[1] == a)(a)
    ATOMS[f"Q!={a}"] = (lambda a: lambda v: v[1] != a)(a)
NAMES = list(ATOMS)
def holds(M, gamma, phi):
    return all(ATOMS[phi](v) for v in M if all(ATOMS[g](v) for g in gamma))
def sat(fs):
    return any(all(ATOMS[f](v) for f in fs) for v in VALS)
def th_ok(J, c, extra=()):
    # Th_J(c) ∪ extra satisfiable, where (Gamma, phi) is read as  /\Gamma -> phi
    return any(all((not all(ATOMS[g](v) for g in G)) or ATOMS[f](v) for (cc, G, f) in J if cc == c)
               and all(ATOMS[e](v) for e in extra) for v in VALS)
def random_instance(rng):
    # contexts: 0 = root; 1 child of 0; 2 child of 1 or 0
    parent = {1: 0, 2: rng.choice([0, 1])}
    J, bridges = [], []
    for _ in range(rng.randint(1, 5)):
        c = rng.choice([0, 1, 2]); G = rng.sample(NAMES, rng.choice([0, 0, 1])); J.append((c, tuple(G), rng.choice(NAMES)))
    for c in (1, 2):
        if rng.random() < 0.5:
            a = rng.randint(0, 2); s = rng.choice(["top", "p", "~p"]); p = parent[c]
            bridges.append((c, a, s)); J += [(c, (), f"Q={a}"), (p, (), s), (p, (), f"Q={a}")]
    certC = {c for c in (1, 2) if rng.random() < 0.25}
    certP = [(c, (rng.choice(NAMES),)) for c in (0, 1, 2) if rng.random() < 0.2]
    return parent, J, bridges, certC, certP
def brute(parent, J, bridges, certC, certP):
    subsets = [frozenset(s) for r in range(len(VALS)+1) for s in itertools.combinations(VALS, r)]
    for w in VALS:
        for M1 in subsets:
            for M2 in subsets:
                M = {0: [w], 1: M1, 2: M2}
                if not all(holds(M[c], G, f) for (c, G, f) in J): continue
                ok = True
                for (c, a, s) in bridges:
                    p = parent[c]
                    for a2 in range(3):
                        if holds(M[c], (), f"Q={a2}") and holds(M[p], (), s) and not holds(M[p], (), f"Q={a2}"):
                            ok = False
                if not ok: continue
                if any(len(M[c]) == 0 for c in certC): continue
                if any(not any(all(ATOMS[g](v) for g in G) for v in M[c]) for (c, G) in certP): continue
                return True
    return False
def criterion(parent, J, bridges, certC, certP):
    anc = {0} | set(certC) | {c for (c, G) in certP}
    changed = True
    while changed:
        changed = False
        for (c, a, s) in bridges:
            if parent[c] in anc and c not in anc: anc.add(c); changed = True
    rootextra = [g for (c, G) in certP if c == 0 for g in G]
    if not th_ok(J, 0, rootextra): return False
    for c in anc - {0}:
        if not th_ok(J, c): return False
    for (c, G) in certP:
        if c != 0 and not th_ok(J, c, G): return False
    return True
if __name__ == "__main__":
    rng = random.Random(1); n = 0; mism = 0; real = 0
    for _ in range(1500):
        inst = random_instance(rng); b = brute(*inst); cr = criterion(*inst); n += 1; real += b
        if b != cr:
            mism += 1; print("MISMATCH", inst, b, cr)
            if mism > 5: break
    print(f"instances {n}, realizable {real}, mismatches {mism}")
