"""T3 Thm 2.4(b),(c) and Prop 2.7 (added after verification): realizability in the FRAME semantics of Def 1.3.

Thm 2.4(a) characterizes 'frame-free' realizability (Def 2.3, R2: a DEF context's value is arbitrary).
In the frame semantics of Def 1.1/1.3 one frame serves all contexts, undeformed parameters are rigid,
and identically declared deformations give identical filters.  This script brute-forces frame
realizability on a toy and compares it with
  * the Thm 2.4 criterion (claimed: necessary, Thm 2.4(b); not sufficient, Thm 2.4(c));
  * the limit-semantics characterization of Prop 2.7 (claimed: exact).

Toy: parameters (p1, p2) with Lambda = {0,1}^2; a structure at point x is (x1, x2, Q), Q in {0,1,2};
a frame is a partial map Lambda -> Q-value (dom = where it is defined); root principal at lam* in dom.
Contexts: root 0, DEF contexts 1..nd (limit semantics, D a nonempty subset of {1,2}, ideal values in
{0,1}^D, parent any earlier non-SUP context), SUP contexts after them (parent any earlier context).
Bridges: informative value exports (c, (eps, sigma), t) with judgments (c, Q=t), (pi c, sigma), (pi c, eps(t)).
"""
import itertools, random, sys

LAM = [(a, b) for a in (0, 1) for b in (0, 1)]
QN = 3
ATOMS = {"top": lambda s: True, "bot": lambda s: False,
         "p1=0": lambda s: s[0] == 0, "p1=1": lambda s: s[0] == 1,
         "p2=0": lambda s: s[1] == 0, "p2=1": lambda s: s[1] == 1}
for v in range(QN):
    ATOMS[f"Q={v}"] = (lambda v: lambda s: s[2] == v)(v)
    ATOMS[f"Q!={v}"] = (lambda v: lambda s: s[2] != v)(v)
    ATOMS[f"Q~{v}"] = (lambda v: lambda s: abs(s[2] - v) <= 1)(v)
JN = [n for n in ATOMS if "~" not in n]
STRUCTS = [(a, b, q) for a in (0, 1) for b in (0, 1) for q in range(QN)]
BK = [("Q=", "top"), ("Q=", "p1=1"), ("Q=", "p2=0"), ("Q~", "Q!=1"), ("Q~", "top")]


def informative(k):
    e, s = k
    return not any(ATOMS[s](x) and all(ATOMS[f"{e}{v}"](x) for v in range(QN)) for x in STRUCTS)


def rand_inst(rng):
    nd = rng.randint(1, 3); ns = rng.randint(0, 2)
    kind = {0: "ROOT"}; parent = {}; decl = {}
    for i in range(1, nd + 1):
        kind[i] = "DEF"; parent[i] = rng.randrange(0, i)
        D = rng.choice([(0,), (1,), (0, 1)])
        decl[i] = {d: rng.randint(0, 1) for d in D}
    for j in range(nd + 1, nd + 1 + ns):
        kind[j] = "SUP"; parent[j] = rng.randrange(0, j)
    asm = {j: rng.choice(JN) for j in kind if kind[j] == "SUP"}
    J = []
    for _ in range(rng.randint(1, 6)):
        c = rng.choice(list(kind))
        G = tuple(rng.sample(JN, rng.choice([0, 0, 1])))
        J.append((c, G, rng.choice(JN)))
    U = []
    for c in range(1, nd + 1):
        for _ in range(rng.choice([0, 0, 1, 1, 2])):
            k = rng.choice([b for b in BK if informative(b)])
            t = rng.randrange(QN); p = parent[c]
            U.append((c, k, t)); J += [(c, (), f"Q={t}"), (p, (), k[1]), (p, (), f"{k[0]}{t}")]
    C = {c for c in range(1, nd + 1) if rng.random() < 0.3}
    return kind, parent, decl, asm, J, U, C


def nonsup_base(kind, parent, asm, c):
    A = []
    while kind[c] == "SUP":
        A.append(asm[c]); c = parent[c]
    return c, tuple(A)


def collapse(inst):
    kind, parent, decl, asm, J, U, C = inst
    out = []
    for (c, G, f) in J:
        b, A = nonsup_base(kind, parent, asm, c); out.append((b, G + A, f))
    return out


def holds_at(s, G, f):
    return (not all(ATOMS[g](s) for g in G)) or ATOMS[f](s)


def points(inst, lam):
    kind, parent, decl = inst[0], inst[1], inst[2]
    pt = {0: lam}
    for c in sorted(kind):
        if kind[c] == "DEF":
            x = list(pt[parent[c]])
            for d, val in decl[c].items():
                x[d] = val
            pt[c] = tuple(x)
    return pt


def frame_realizable(inst):
    kind, parent, decl, asm, J, U, C = inst
    Js = collapse(inst)
    for assign in itertools.product([None] + list(range(QN)), repeat=len(LAM)):
        F = {lam: q for lam, q in zip(LAM, assign) if q is not None}
        for lam in F:
            pt = points(inst, lam)
            proper = {0: True}
            for c in sorted(kind):
                if kind[c] == "DEF":
                    proper[c] = proper[parent[c]] and pt[c] in F
            struct = {c: (pt[c][0], pt[c][1], F[pt[c]]) for c in proper if proper[c]}
            if any(not proper[c] for c in C):
                continue
            # judgments (collapsed: exact by Prop 1.5); improper contexts satisfy everything
            if not all(holds_at(struct[b], G, f) for (b, G, f) in Js if proper[b]):
                continue
            ok = True
            for (c, (e, s), t) in U:
                p = parent[c]
                if not proper[p]:
                    continue
                vs = [struct[c][2]] if proper[c] else range(QN)  # c |= Q=v exactly for these v
                if not all(holds_at(struct[p], (s,), f"{e}{v}") for v in vs):
                    ok = False; break
            if ok:
                return True
    return False


def anchored(inst):
    kind, parent, decl, asm, J, U, C = inst
    anc = {0} | set(C); ch = True
    while ch:
        ch = False
        for (c, k, t) in U:
            if informative(k) and parent[c] in anc and c not in anc:
                anc.add(c); ch = True
    return anc


def thm24_criterion(inst):
    Js = collapse(inst)
    return all(any(all(holds_at(s, G, f) for (b, G, f) in Js if b == c) for s in STRUCTS) for c in anchored(inst))


def prop27_criterion(inst):
    kind, parent, decl, asm, J, U, C = inst
    Js = collapse(inst)
    nonsup = [c for c in kind if kind[c] != "SUP"]
    for lam in LAM:
        pt = points(inst, lam)
        S = {0} | set(C); ch = True
        while ch:
            ch = False
            for c in list(S):                                   # (i) parents
                if c != 0 and parent[c] not in S:
                    S.add(parent[c]); ch = True
            for (c, k, t) in U:                                 # (ii) informative bridges
                if informative(k) and parent[c] in S and c not in S:
                    S.add(c); ch = True
            pts = {pt[c] for c in S}
            for c in nonsup:                                    # (iii) coincidence
                if c != 0 and c not in S and parent[c] in S and pt[c] in pts:
                    S.add(c); ch = True
        good = True
        for x in {pt[c] for c in S}:
            if x not in LAM:
                good = False; break
            cs = [c for c in S if pt[c] == x]
            if not any(all(holds_at((x[0], x[1], q), G, f) for (b, G, f) in Js if b in cs) for q in range(QN)):
                good = False; break
        if good:
            return True
    return False


if __name__ == "__main__":
    # the two counterexamples of Thm 2.4(c)
    ce1 = ({0: "ROOT", 1: "DEF"}, {1: 0}, {1: {1: 0}}, {}, [(0, (), "p1=1"), (1, (), "p1=0")], [], {1})
    ce2 = ({0: "ROOT", 1: "DEF", 2: "DEF"}, {1: 0, 2: 0}, {1: {1: 0}, 2: {1: 0}}, {},
           [(1, (), "Q=1"), (2, (), "Q=2")], [], {1, 2})
    for name, inst in [("CE1 silent change of an undeformed parameter", ce1),
                       ("CE2 identically declared certified siblings disagree", ce2)]:
        print(f"{name}: Thm 2.4 criterion {thm24_criterion(inst)}, Prop 2.7 criterion {prop27_criterion(inst)}, "
              f"frame-realizable (brute force) {frame_realizable(inst)}")
    rng = random.Random(int(sys.argv[1]) if len(sys.argv) > 1 else 7)
    N = int(sys.argv[2]) if len(sys.argv) > 2 else 3000
    real = nec_viol = m27 = gap = 0
    for i in range(N):
        inst = rand_inst(rng)
        fr = frame_realizable(inst); c24 = thm24_criterion(inst); c27 = prop27_criterion(inst)
        real += fr
        if fr and not c24:
            nec_viol += 1; print("NECESSITY VIOLATION", inst)
        if fr != c27:
            m27 += 1; print("PROP 2.7 MISMATCH", inst, fr, c27)
        if c24 and not fr:
            gap += 1
    print(f"N={N}: frame-realizable {real}; Thm 2.4 necessity violations {nec_viol}; "
          f"Prop 2.7 mismatches {m27}; criterion true but not frame-realizable (non-sufficiency) {gap}")
