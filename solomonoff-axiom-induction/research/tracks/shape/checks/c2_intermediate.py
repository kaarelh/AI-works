"""c2: intermediate concepts (auxiliary variables) for linear laws (thread `shape`, target T3).

Seed 20261016.  Writes c2_intermediate.out next to itself.

A  chain encoding of one parity law is propagation complete on ALL variables (base and auxiliary), for every
   partial assignment, inconsistent ones included (conflict iff inconsistent); m = 3..7, exhaustive.
B  the library Circ_aux (chain encodings of all circuits, private auxiliaries) is UP-usable (Prop 3.2);
   the GK-style library over all nonzero derived equations as well; sizes.
C  systems: the core written directly and the core chain-encoded (private auxiliaries) derive exactly the same
   base literals on every partial assignment (Prop 3.3); fraction of sampled questions the core answers on
   sparse random systems.
D  the monotone-circuit reduction (Lemma 3.5): from a UP-usable theory F of the "hidden linear structure" law
   of an XOR-SAT span program, build the monotone circuit that simulates UP and check that it computes
   XOR-unsatisfiability exactly; gate count against the bound.
"""
import random, sys, time
from itertools import product, combinations
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from shapelib import *

SEED = 20261016
rng = random.Random(SEED)
out_lines = []


def P(*a):
    s = " ".join(str(x) for x in a)
    out_lines.append(s)
    print(s, flush=True)


t0 = time.time()
P(f"# c2_intermediate.py  seed={SEED}  python={sys.version.split()[0]}")

# ------------------------------------------------------------------ A
P("== A: chain encoding of x_0 + ... + x_{m-1} = c: propagation completeness on all variables, all partial assignments")
for m in range(3, 8):
    for c in (0, 1):
        F, naux = chain_encoding(list(range(m)), c, m)
        N = m + naux
        # full solutions over all N variables (aux determined as partial sums)
        sols = []
        for x in range(1 << m):
            if popcount(x) % 2 != c:
                continue
            full = [(x >> v) & 1 for v in range(m)]
            if naux:
                y = full[0] ^ full[1]
                full.append(y)
                for i in range(2, m - 1):
                    y = y ^ full[i]
                    full.append(y)
            sols.append(full)
        assert all(up(F, N, {v: s[v] for v in range(N)}) is not None for s in sols)
        n_cons = n_incons = bad = 0
        for vals in product((-1, 0, 1), repeat=N):
            alpha = {v: s for v, s in enumerate(vals) if s != -1}
            ext = [s for s in sols if all(s[v] == b for v, b in alpha.items())]
            a = up(F, N, alpha)
            if not ext:
                n_incons += 1
                bad += (a is not None)
                continue
            n_cons += 1
            if a is None:
                bad += 1
                continue
            for v in range(N):
                if v in alpha:
                    continue
                vs = {s[v] for s in ext}
                if len(vs) == 1 and a[v] != next(iter(vs)):
                    bad += 1
                    break
                if len(vs) == 2 and a[v] != -1:
                    bad += 1
                    break
        if c == 0:
            P(f"  m={m} c={c}: clauses={len(F)} (4m-6={4*m-6 if m>3 else 4}) aux={naux}; partial assignments: "
              f"{n_cons} consistent, {n_incons} inconsistent; failures={bad}")
        else:
            P(f"  m={m} c={c}: clauses={len(F)} aux={naux}; {n_cons} consistent, {n_incons} inconsistent; failures={bad}")

# ------------------------------------------------------------------ B
P("== B: the library of chain encodings of all circuits (Prop 3.2) and of all nonzero derived equations")


def library(law, which):
    F = []
    nxt = law.m
    vecs = law.circuits() if which == 'circuits' else law.codewords
    for u in vecs:
        vs = [v for v in range(law.m) if u >> v & 1]
        if len(vs) <= 3:
            cls = xor_clauses(vs, law.const[u])
            F += cls
        else:
            cls, na = chain_encoding(vs, law.const[u], nxt)
            nxt += na
            F += cls
    return F, nxt


for trial in range(6):
    m, k = [(8, 3), (8, 4), (9, 4), (10, 4), (10, 5), (11, 5)][trial]
    law = AffineLaw(m, random_system(rng, m, k))
    res = []
    for which in ('circuits', 'all'):
        F, N = library(law, which)
        ok, nq, fail = usable(F, N, m, law.sols)
        res.append((len(F), N - m, ok, nq))
    P(f"  m={m} k={k} d*={law.dmin()} circuits={len(law.circuits())}: circuit library {res[0][0]} clauses, "
      f"{res[0][1]} aux, usable={res[0][2]} ({res[0][3]} entailed literals); all-equations library {res[1][0]} clauses "
      f"(<= (2^k-1)(4m-6) = {(2**k-1)*(4*m-6)}), usable={res[1][2]}")

# ------------------------------------------------------------------ C
P("== C: systems: core written directly vs core chain-encoded (private aux): same base literals (Prop 3.3)")


def core_direct(law):
    F = []
    for r, c in law.eqs:
        F += xor_clauses([v for v in range(law.m) if r >> v & 1], c)
    return F


def core_chain(law):
    F = []
    nxt = law.m
    for r, c in law.eqs:
        vs = [v for v in range(law.m) if r >> v & 1]
        cls, na = chain_encoding(vs, c, nxt) if len(vs) > 3 else (xor_clauses(vs, c), 0)
        nxt += na
        F += cls
    return F, nxt


for trial in range(4):
    m = [8, 9, 10, 10][trial]
    k = m // 2
    law = AffineLaw(m, random_system(rng, m, k, row_weights=[4, 5]))
    Fd = core_direct(law)
    Fc, Nc = core_chain(law)
    diff = 0
    tot = 0
    for alpha in all_partial_assignments(m):
        a = up(Fd, m, alpha)
        b = up(Fc, Nc, alpha)
        tot += 1
        if (a is None) != (b is None):
            diff += 1
        elif a is not None and a[:m] != b[:m]:
            diff += 1
    P(f"  m={m} k={k} (row weights 4-5): {tot} partial assignments; base-literal results differ in {diff}")

P("   sparse random systems (row weights 3-4, k=m/2), 3000 sampled questions (alpha on a random S, all entailed literals):")
for m in (12, 16, 20):
    k = m // 2
    law = AffineLaw(m, random_system(rng, m, k, row_weights=[3, 4]))
    Fd = core_direct(law)
    Fc, Nc = core_chain(law)
    Fl, Nl = library(law, 'circuits')
    stats = {'core': [0, 0, 0], 'chain': [0, 0, 0], 'lib': [0, 0, 0]}
    nq = 0
    while nq < 3000:
        x = rng.choice(law.sols)
        S = [v for v in range(m) if rng.random() < rng.choice([0.3, 0.5, 0.7])]
        alpha = {v: (x >> v) & 1 for v in S}
        imp = law_implied(law.sols, m, alpha)
        if not imp:
            continue
        nq += 1
        for name, F, N in (('core', Fd, m), ('chain', Fc, Nc), ('lib', Fl, Nl)):
            a = up(F, N, alpha)
            got = sum(1 for v, s in imp if a[v] == s)
            stats[name][0] += got
            stats[name][1] += len(imp)
            stats[name][2] += (got == len(imp))
    P(f"  m={m} k={k}: core {len(Fd)} clauses answers {stats['core'][2]/nq:.3f} of questions fully "
      f"({stats['core'][0]/stats['core'][1]:.3f} of entailed literals); chain-encoded core {len(Fc)} clauses: "
      f"{stats['chain'][2]/nq:.3f}; circuit library {len(Fl)} clauses: {stats['lib'][2]/nq:.3f}")

# ------------------------------------------------------------------ D
P("== D: monotone-circuit reduction on the XOR-SAT law (Lemma 3.5, Thm 3.6)")


def xorsat_law(nh):
    """Rows g_e = (u_e, c_e) for all weight-3 u_e over nh hidden variables and c_e in {0,1}; target t=(0..0,1).
    Base variables: one per row, then the target. The law is {(z.g_e)_e, z.t) : z in GF(2)^(nh+1)}."""
    rows = []
    for tri in combinations(range(nh), 3):
        u = sum(1 << i for i in tri)
        for c in (0, 1):
            rows.append(u | (c << nh))
    t = 1 << nh
    cols = rows + [t]
    mm = len(cols)
    sols = set()
    for z in range(1 << (nh + 1)):
        x = 0
        for idx, g in enumerate(cols):
            if popcount(z & g) % 2:
                x |= 1 << idx
        sols.add(x)
    return rows, t, mm, sorted(sols)


def build_mono_circuit(F, N, inputs):
    """Monotone circuit (fan-in-2 AND/OR gates) simulating parallel UP on F from antecedents given by input
    gates 'inputs' (literal -> input index).  Returns (gate list, output map literal->gate after R rounds).
    Gate = ('in', i) | ('const', 0) | ('and', g1, g2) | ('or', g1, g2)."""
    gates = []

    def new(g):
        gates.append(g)
        return len(gates) - 1

    zero = new(('const', 0))
    one = new(('const', 1))
    lits = [(v, s) for v in range(N) for s in (0, 1)]
    cur = {}
    for L in lits:
        cur[L] = new(('in', inputs[L])) if L in inputs else zero
    R = 2 * N + 1
    for _ in range(R):
        nxt = dict(cur)
        contrib = {L: [] for L in lits}
        for C in F:
            w = len(C)
            neg = [cur[(v, 1 - s)] for (v, s) in C]  # gate "literal of C is falsified"
            # prefix/suffix ANDs: and of all neg except position i
            pre = [None] * (w + 1)
            suf = [None] * (w + 1)
            for i in range(w):
                pre[i + 1] = neg[i] if pre[i] is None else new(('and', pre[i], neg[i]))
            for i in range(w - 1, -1, -1):
                suf[i] = neg[i] if suf[i + 1] is None else new(('and', neg[i], suf[i + 1]))
            for i in range(w):
                a, b = pre[i], suf[i + 1]
                if a is None and b is None:
                    g = None  # unit clause: fires always
                elif a is None:
                    g = b
                elif b is None:
                    g = a
                else:
                    g = new(('and', a, b))
                contrib[C[i]].append(g)
        for L in lits:
            g = cur[L]
            for h in contrib[L]:
                if h is None:  # unit clause: the literal is derived unconditionally
                    h = one
                g = new(('or', g, h))
            nxt[L] = g
        cur = nxt
    return gates, cur


def eval_circuit(gates, inp):
    val = [0] * len(gates)
    for i, g in enumerate(gates):
        if g[0] == 'in':
            val[i] = inp[g[1]]
        elif g[0] == 'const':
            val[i] = g[1]
        elif g[0] == 'and':
            val[i] = val[g[1]] & val[g[2]]
        else:
            val[i] = val[g[1]] | val[g[2]]
    return val


# (i) the XOR-SAT law with 4 hidden variables, gate-level circuit, all 2^8 inputs
for nh in (4,):
    rows, t, mm, sols = xorsat_law(nh)
    m = mm
    gen = [sum(((popcount(z & g) % 2) << idx) for idx, g in enumerate(rows + [t])) for z in [1 << i for i in range(nh + 1)]]
    basis = rref_rows(gen)
    piv = {p for p, _ in basis}
    dual = []
    for f in [i for i in range(m) if i not in piv]:
        u = 1 << f
        for p, b in basis:
            if b >> f & 1:
                u |= 1 << p
        dual.append(u)
    assert all(all(popcount(x & u) % 2 == 0 for u in dual) for x in sols)
    target = m - 1
    span = span_all(dual)
    circ_t = [u for u in span if (u >> target & 1) and not any(v and v != u and (v & u) == v for v in span)]
    F = []
    nxt = m
    for u in circ_t:
        vs = [v for v in range(m) if u >> v & 1]
        if len(vs) <= 3:
            F += xor_clauses(vs, 0)
        else:
            cls, na = chain_encoding(vs, 0, nxt)
            nxt += na
            F += cls
    N = nxt
    inputs = {(i, 0): i for i in range(m - 1)}  # input i: "x_i = 0 is assigned"
    gates, outmap = build_mono_circuit(F, N, inputs)
    og = outmap[(target, 0)]
    nrows = m - 1
    agree_det = agree_up = cnt = 0
    for Smask in range(1 << nrows):
        inp = [(Smask >> i) & 1 for i in range(nrows)]
        val = eval_circuit(gates, inp)
        sel = [rows[i] for i in range(nrows) if Smask >> i & 1]
        unsat = in_span(t, rref_rows(sel))
        a = up(F, N, {i: 0 for i in range(nrows) if Smask >> i & 1})
        upd = (a is not None and a[target] == 0)
        agree_det += (val[og] == unsat)
        agree_up += (val[og] == upd)
        cnt += 1
    normF = sum(len(C) for C in F)
    P(f"  XOR-SAT law, {nh} hidden vars: {nrows} rows, {m} base vars, dimension {nh+1}; theory = chain encodings of the "
      f"{len(circ_t)} circuits through the target: {len(F)} clauses, ||F||={normF}, {N-m} aux; monotone circuit: "
      f"{len(gates)} fan-in-2 gates (N(||F||+N)={N*(normF+N)}, rounds 2N+1={2*N+1}); "
      f"all {cnt} inputs: circuit == XOR-unsat in {agree_det}, circuit == UP in {agree_up}")

# (ii) random laws, random usable theories, random sets of input literals: circuit == UP on every input
mism = runs = 0
for trial in range(25):
    m = rng.choice([5, 6, 7])
    k = rng.choice([2, 3])
    law = AffineLaw(m, random_system(rng, m, k))
    F, N = library(law, 'circuits')
    if N > 20:
        continue
    lits_in = rng.sample([(v, s) for v in range(m) for s in (0, 1)], rng.randint(2, min(8, 2 * m)))
    inputs = {L: i for i, L in enumerate(lits_in)}
    gates, outmap = build_mono_circuit(F, N, inputs)
    for Smask in range(1 << len(lits_in)):
        alpha = {}
        okc = True
        for i, (v, s) in enumerate(lits_in):
            if Smask >> i & 1:
                if v in alpha and alpha[v] != s:
                    okc = False
                alpha[v] = s
        if not okc or not law.consistent(alpha):
            continue
        val = eval_circuit(gates, [(Smask >> i) & 1 for i in range(len(lits_in))])
        a = up(F, N, alpha)
        runs += 1
        for v in range(N):
            for s in (0, 1):
                cv = val[outmap[(v, s)]]
                uv = int(a[v] == s) if a is not None else None
                if cv != uv:
                    mism += 1
P(f"  random laws (m=5..7) with circuit libraries: {runs} consistent inputs; circuit vs UP mismatches (all literals) = {mism}")

P(f"# done in {time.time() - t0:.1f}s")
open(__file__.replace('.py', '.out'), 'w').write("\n".join(out_lines) + "\n")
