"""rb5_circuit_sat.py -- referee B, thread `sfi`.  Independent check of notes.md Thm 10.1(i) (the
translation T_V of a consistent verifier circuit into a finite axiom set over the fixed language
{e, s0, s1, Bit, Gate, R}), by propositional satisfiability of ground instances instead of c4's
forward propagation.

Entailment.  For x in dom f_V and a certificate c for its label, let G(x,c) be the ground instances
(x := t_x, z := t_c, y := suffixes) of the axioms the derivation of Thm 10.1(i) uses.  Every member
of G(x,c) is a consequence of T_V, so if G(x,c) + {not label} is propositionally UNSAT then
T_V |- label.  Checked with a small DPLL solver (unit propagation + branching) on the CNF of the
ground instances (Tseitin-free: each "A <-> op(B,C)" becomes 4 clauses by its truth table).
Controls.
  (c1) with a non-witness certificate c', G(x,c') + {not label} is SAT (the certificate matters);
  (c2) for INCONSISTENT verifiers (some x with an accepting and a rejecting certificate),
       G(x,c_acc) + G(x,c_rej) is UNSAT: T_V is then inconsistent, so the hypothesis "V consistent"
       of Thm 10.1(i) is needed;
  (c3) consistency evidence: the ground fragment over all x in {0,1}^d, all certificates, all
       Bit instances on words of length <= max(d,k), together with Gamma_{f_V}, is SAT (the proof
       uses an explicit infinite model; a finite fragment is only evidence);
  (c4) undefined points stay open: for x outside dom f_V, the fragment + Gamma_{f_V} is SAT with
       R(t_x) and with not R(t_x).
Sizes.  |T_V| (symbol count with the stated abbreviation of <->) against (s+d+k) log2(s+d+k+2), and
the nonlogical material of G(x,c) against s(log2(s+2)+d+k) + (d+k)^3, for s up to ~1000.
Seed 20261016.  Output: rb5_circuit_sat.out
"""
import itertools
import math
import random
import sys

sys.setrecursionlimit(100000)
SEED = 20261016
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


OPS = {i: (lambda i: (lambda a, b: (i >> (2 * a + b)) & 1))(i) for i in range(16)}
AND, NOTA_B = 0b1000, 0b0010


def beta(i):
    return bin(i + 1)[3:]


# ----------------------------------------------------------------------------- circuits
def eval_v(gates, d, k, x, z):
    vals = list(x) + list(z) + [0, 1]
    for op, a, b in gates:
        vals.append(OPS[op](vals[a], vals[b]))
    return vals


def f_of(gates, d, k):
    f, wit, ok = {}, {}, True
    for x in itertools.product((0, 1), repeat=d):
        acc = [z for z in itertools.product((0, 1), repeat=k) if eval_v(gates, d, k, x, z)[-2]]
        rej = [z for z in itertools.product((0, 1), repeat=k) if eval_v(gates, d, k, x, z)[-1]]
        if acc and rej:
            ok = False
        if acc:
            f[x], wit[x] = 1, (acc, rej)
        elif rej:
            f[x], wit[x] = 0, (acc, rej)
        else:
            f[x], wit[x] = None, (acc, rej)
    return f, wit, ok


def rand_verifier(rng, d, k, s, want_consistent=True):
    for _ in range(10000):
        base = d + k + 2
        gates = [(rng.randrange(16), rng.randrange(base + j), rng.randrange(base + j)) for j in range(s - 2)]
        nb = base + len(gates)
        u = rng.randrange(d) if want_consistent else rng.randrange(nb)    # u depends on x only -> consistent
        h1, h2 = rng.randrange(nb), rng.randrange(nb)
        gates.append((AND, h1, u))
        gates.append((NOTA_B, u, h2))
        f, wit, ok = f_of(gates, d, k)
        if ok == want_consistent and any(v is not None for v in f.values()):
            return gates, f, wit
    return None


# ----------------------------------------------------------------------------- ground atoms
class Atoms:
    def __init__(self):
        self.ix = {}

    def __call__(self, key):
        if key not in self.ix:
            self.ix[key] = len(self.ix) + 1
        return self.ix[key]


def word(bits):
    return ''.join(str(b) for b in bits)


def bit_instances(A, w, nmax):
    """ground Bit axioms needed to fix Bit(n_i, t_w) for i < nmax (and the suffixes)."""
    cl = []
    for i in range(nmax):
        if i >= len(w):
            break
        # Bit(n_i, t_w) <-> Bit(n_{i-1}, t_{w[1:]}) ... down to Bit(n_0, t_{w[i:]})
        for j in range(i, 0, -1):
            a = A(('Bit', j, w[i - j:]))
            b = A(('Bit', j - 1, w[i - j + 1:]))
            cl += [[-a, b], [a, -b]]
        base = A(('Bit', 0, w[i:]))
        cl.append([base] if w[i] == '1' else [-base])
    return cl


def gate_instances(A, gates, d, k, xw, zw):
    cl = []
    base = d + k + 2
    for j, (op, a, b) in enumerate(gates):
        g = A(('Gate', j, xw, zw))

        def src(idx):
            if idx < d:
                return A(('Bit', idx, xw))
            if idx < d + k:
                return A(('Bit', idx - d, zw))
            if idx < d + k + 2:
                return ('const', idx - d - k)
            return A(('Gate', idx - base, xw, zw))
        sa, sb = src(a), src(b)
        for va in (0, 1):
            for vb in (0, 1):
                if isinstance(sa, tuple) and sa[1] != va:
                    continue
                if isinstance(sb, tuple) and sb[1] != vb:
                    continue
                y = OPS[op](va, vb)
                c = []
                if not isinstance(sa, tuple):
                    c.append(-sa if va else sa)
                if not isinstance(sb, tuple):
                    c.append(-sb if vb else sb)
                c.append(g if y else -g)
                cl.append(c)
    nA, nR = len(gates) - 2, len(gates) - 1
    r = A(('R', xw))
    cl.append([-A(('Gate', nA, xw, zw)), r])
    cl.append([-A(('Gate', nR, xw, zw)), -r])
    return cl


def ground(A, gates, d, k, x, z):
    xw, zw = word(x), word(z)
    return bit_instances(A, xw, d) + bit_instances(A, zw, k) + gate_instances(A, gates, d, k, xw, zw)


# ----------------------------------------------------------------------------- DPLL
def dpll(clauses):
    assign = {}

    def unit_prop(cls, asg):
        cls = [list(c) for c in cls]
        changed = True
        while changed:
            changed = False
            new = []
            for c in cls:
                if any(asg.get(abs(l)) == (l > 0) for l in c):
                    continue
                rest = [l for l in c if abs(l) not in asg]
                if not rest:
                    return None, asg
                if len(rest) == 1:
                    l = rest[0]
                    asg[abs(l)] = l > 0
                    changed = True
                new.append(rest)
            cls = new
        return cls, asg

    def solve(cls, asg):
        cls, asg = unit_prop(cls, dict(asg))
        if cls is None:
            return False
        cls = [c for c in cls if not any(asg.get(abs(l)) == (l > 0) for l in c)]
        if not cls:
            return True
        v = abs(cls[0][0])
        for val in (True, False):
            a2 = dict(asg)
            a2[v] = val
            if solve(cls, a2):
                return True
        return False
    return solve(clauses, assign)


# ----------------------------------------------------------------------------- sizes
def tsize(w):
    return len(w) + 1


def axiom_sizes(gates, d, k):
    """symbol counts with <-> := not((A->B)->not(B->A)): |A<->B| = 2|A| + 2|B| + 4."""
    iff = lambda a, b: 2 * a + 2 * b + 4
    nmax = max(d, k)
    total = 0
    # Bit0: forall y Bit(n_0, s1 y) ; forall y not Bit(n_0, s0 y)
    total += (2 + 1 + tsize(beta(0)) + 2) + (2 + 1 + 1 + tsize(beta(0)) + 2)
    for i in range(nmax - 1):
        for a in (0, 1):
            total += 2 + iff(1 + tsize(beta(i + 1)) + 2, 1 + tsize(beta(i)) + 1)
    base = d + k + 2
    gate_atom = lambda j: 1 + tsize(beta(j)) + 2
    for j in range(d + k):   # input gates of the translation
        total += 4 + iff(gate_atom(j), 1 + tsize(beta(j if j < d else j - d)) + 1)
    for j, (op, a, b) in enumerate(gates):
        jj = d + k + j
        def ref(idx):
            if idx < d + k:
                return gate_atom(idx)
            if idx < d + k + 2:
                return 1
            return gate_atom(idx - 2)
        opsize = 2 * (ref(a) + ref(b)) + 6     # an op of two formulas written with not, ->: at most this
        total += 4 + iff(gate_atom(jj), opsize)
    total += 2 * (4 + gate_atom(d + k + len(gates)) + 1 + 2 + 2)
    return total


def material(cls_inst_sizes):
    return sum(cls_inst_sizes)


def instance_material(gates, d, k):
    """nonlogical material of the ground instances used for one datum: gate instances with
    x := t_x, z := t_c (|t_x| = d+1, |t_c| = k+1) and the Bit chains."""
    iff = lambda a, b: 2 * a + 2 * b + 4
    gate_atom = lambda j: 1 + tsize(beta(j)) + (d + 1) + (k + 1)
    m = 0
    for j, (op, a, b) in enumerate(gates):
        m += iff(gate_atom(j), 2 * (gate_atom(a) + gate_atom(b)) + 6)
    for L, n in ((d, d), (k, k)):
        for i in range(n):
            for j in range(i, 0, -1):
                m += iff(1 + tsize(beta(j)) + (L - (i - j)) + 1, 1 + tsize(beta(j - 1)) + (L - (i - j) - 1) + 1)
            m += 1 + tsize(beta(0)) + (L - i) + 1
    m += 2 * (gate_atom(len(gates)) + 1 + d + 2)
    return m


def main():
    rng = random.Random(SEED)
    out('rb5_circuit_sat.py  seed %d' % SEED)
    ent_bad = ent_n = c1_bad = c1_n = c3_bad = c4_bad = c4_n = 0
    ncirc = 0
    for d in (2, 3, 4):
        for k in (1, 2, 3):
            for _ in range(6):
                r = rand_verifier(rng, d, k, rng.randint(8, 16))
                if r is None:
                    continue
                gates, f, wit = r
                ncirc += 1
                for x, y in f.items():
                    if y is None:
                        continue
                    acc, rej = wit[x]
                    c = (acc if y == 1 else rej)[0]
                    A = Atoms()
                    cl = ground(A, gates, d, k, x, c)
                    rlit = A(('R', word(x)))
                    ent_n += 1
                    if dpll(cl + [[-rlit] if y == 1 else [rlit]]):
                        ent_bad += 1
                    # (c1) a non-witness certificate
                    non = [z for z in itertools.product((0, 1), repeat=k) if z not in (acc if y == 1 else rej)]
                    if non:
                        A2 = Atoms()
                        cl2 = ground(A2, gates, d, k, x, non[0])
                        r2 = A2(('R', word(x)))
                        c1_n += 1
                        if not dpll(cl2 + [[-r2] if y == 1 else [r2]]):
                            c1_bad += 1
                # (c3), (c4): whole finite fragment
                A = Atoms()
                cl = []
                for x in itertools.product((0, 1), repeat=d):
                    for z in itertools.product((0, 1), repeat=k):
                        cl += ground(A, gates, d, k, x, z)
                gam = []
                for x, y in f.items():
                    if y is not None:
                        rl = A(('R', word(x)))
                        gam.append([rl] if y == 1 else [-rl])
                if not dpll(cl + gam):
                    c3_bad += 1
                for x, y in f.items():
                    if y is None:
                        rl = A(('R', word(x)))
                        c4_n += 1
                        if not (dpll(cl + gam + [[rl]]) and dpll(cl + gam + [[-rl]])):
                            c4_bad += 1
    out('consistent verifiers: %d (d in 2..4, k in 1..3, 8..16 gates)' % ncirc)
    out('  entailment: G(x,c) + {not label} SAT (T_V fails to derive the label) in %d of %d data' % (ent_bad, ent_n))
    out('  (c1) non-witness certificate already entails the label: %d of %d' % (c1_bad, c1_n))
    out('  (c3) ground fragment + Gamma_f UNSAT: %d of %d circuits' % (c3_bad, ncirc))
    out('  (c4) an undefined point decided by the fragment + Gamma_f: %d of %d' % (c4_bad, c4_n))
    # (c2) inconsistent verifiers
    inc_n = inc_bad = 0
    for d in (2, 3):
        for k in (1, 2):
            for _ in range(8):
                r = rand_verifier(rng, d, k, rng.randint(8, 14), want_consistent=False)
                if r is None:
                    continue
                gates, f, wit = r
                for x in f:
                    acc, rej = wit[x]
                    if acc and rej:
                        A = Atoms()
                        cl = ground(A, gates, d, k, x, acc[0]) + ground(A, gates, d, k, x, rej[0])
                        inc_n += 1
                        if dpll(cl):
                            inc_bad += 1
                        break
    out('  (c2) inconsistent verifiers: ground instances for an accepting and a rejecting certificate SAT '
        '(T_V not shown inconsistent): %d of %d' % (inc_bad, inc_n))
    # sizes
    out('sizes (symbol counts; <-> expanded):')
    out('    d    k     s     |T_V|    |T_V|/((s+d+k)log2(s+d+k+2))   material   material/(s(log2(s+2)+d+k)+(d+k)^3)')
    for d, k, s in ((2, 1, 10), (4, 4, 40), (8, 8, 120), (16, 16, 260), (32, 32, 540), (32, 64, 1100), (64, 64, 1100)):
        gates = []
        base = d + k + 2
        for j in range(s - 2):
            gates.append((rng.randrange(16), rng.randrange(base + j), rng.randrange(base + j)))
        gates += [(AND, base, 0), (NOTA_B, 0, base + 1)]
        T = axiom_sizes(gates, d, k)
        M = instance_material(gates, d, k)
        r1 = T / ((s + d + k) * math.log2(s + d + k + 2))
        r2 = M / (s * (math.log2(s + 2) + d + k) + (d + k) ** 3)
        out('   %3d  %3d  %5d  %8d   %6.2f                          %8d   %6.3f' % (d, k, s, T, r1, M, r2))
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
