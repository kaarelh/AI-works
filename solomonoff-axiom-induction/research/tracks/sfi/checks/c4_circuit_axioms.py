"""c4_circuit_axioms.py -- thread `sfi`, T10: brute-force check of the translation of a
nondeterministic verifier circuit into a finite axiom set over a FIXED finite language (notes Thm 10.1(i)).

Language: constant e, unary function symbols s0, s1, binary relation Bit, ternary relation Gate,
unary relation R (and =).  Word terms t_w := s_{w_1}(...s_{w_n}(e)...).  Index terms n_i and gate
terms g_j are word terms t_{beta(i)}, beta(i) := binary expansion of i+1 without its leading 1, so
|n_i| = O(log i) and the language does not grow with the circuit.

A verifier circuit V on inputs x (d bits) and certificate z (k bits) has two output gates a, r
with: never a(x,c) = 1 and r(x,c') = 1 for the same x (consistency).  f(x) = 1 if some c has
a(x,c) = 1, f(x) = 0 if some c has r(x,c) = 1, undefined otherwise.

Axioms T_V (all universally closed; <-> abbreviates not((A->B)->not(B->A)), primitive not, ->, forall):
  Bit0:  forall y Bit(n_0, s1 y);   forall y not Bit(n_0, s0 y)
  BitS:  forall y (Bit(n_{i+1}, s_a y) <-> Bit(n_i, y)),   i < max(d,k)-1, a in {0,1}
  In:    forall x forall z (Gate(g_j, x, z) <-> Bit(n_i, x))   [or Bit(n_i, z) for certificate bits]
  Op:    forall x forall z (Gate(g_j, x, z) <-> op(Gate(g_a, x, z), Gate(g_b, x, z)))
  Out:   forall x forall z (Gate(g_acc, x, z) -> R(x));  forall x forall z (Gate(g_rej, x, z) -> not R(x))

Checks, for random consistent verifier circuits with d in {2,3}, k in {1,2}:
  (i)  truth in the intended model on a finite fragment of the term algebra (all words of length
       <= max(d,k)+2 together with all index and gate terms): every ground instance of every axiom
       is true when Bit, Gate, R are interpreted by evaluating V on the bits read off the terms and
       R(x) := exists c a(bits(x), c); R agrees with f on dom f (so T_V + Gamma_f is satisfied);
  (ii) derivability: from the ground instances (x := t_x, z := t_c) forward propagation through the
       biconditionals derives R(t_x) if f(x) = 1 and not R(t_x) if f(x) = 0, using a certificate c
       for x; the nonlogical material (total size of the distinct ground instances used) is reported;
  (iii) negative control: corrupting one gate's operation yields a theory that either derives a
       wrong label on dom f or is not satisfied by the corrupted circuit's intended model together
       with Gamma_f (detected), unless the corruption does not change f (reported separately);
  (iv) sizes: total symbol size of T_V against (s+d) log2(s+d) for circuits up to s = 400.
Seed 20261015.  Output: c4_circuit_axioms.out
"""
import itertools
import math
import random

SEED = 20261015
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def beta(i):
    return bin(i + 1)[3:]


def term_size(w):
    return len(w) + 1  # s-symbols plus e


# ------------------------------------------------------------- circuits
OPS = {
    'AND': lambda a, b: a & b, 'OR': lambda a, b: a | b, 'XOR': lambda a, b: a ^ b,
    'NAND': lambda a, b: 1 - (a & b), 'NOR': lambda a, b: 1 - (a | b), 'NOT': lambda a, b: 1 - a,
}


def random_verifier(rng, d, k, n_u, n_h):
    """gates: list of (kind, args).  kinds: ('x', i), ('z', j), ('op', name, a, b).
    Returns gates, acc index, rej index."""
    gates = []
    for i in range(d):
        gates.append(('x', i))
    for j in range(k):
        gates.append(('z', j))

    def add_random(pool, n):
        idx = list(pool)
        for _ in range(n):
            op = rng.choice(list(OPS))
            a, b = rng.choice(idx), rng.choice(idx)
            gates.append(('op', op, a, b))
            idx.append(len(gates) - 1)
        return len(gates) - 1

    u = add_random(range(d), n_u)                    # u(x)
    h1 = add_random(range(d + k), n_h)               # h1(x,z)
    h0 = add_random(range(d + k), n_h)               # h0(x,z)
    gates.append(('op', 'NOT', u, u)); nu = len(gates) - 1
    gates.append(('op', 'AND', h1, u)); acc = len(gates) - 1
    gates.append(('op', 'AND', h0, nu)); rej = len(gates) - 1
    return gates, acc, rej


def evaluate(gates, x, z):
    val = []
    for g in gates:
        if g[0] == 'x':
            val.append(x[g[1]])
        elif g[0] == 'z':
            val.append(z[g[1]])
        else:
            val.append(OPS[g[1]](val[g[2]], val[g[3]]))
    return val


def label_fn(gates, acc, rej, d, k):
    f = {}
    consistent = True
    for x in itertools.product([0, 1], repeat=d):
        A = any(evaluate(gates, x, z)[acc] for z in itertools.product([0, 1], repeat=k))
        Rj = any(evaluate(gates, x, z)[rej] for z in itertools.product([0, 1], repeat=k))
        if A and Rj:
            consistent = False
        if A:
            f[x] = 1
        elif Rj:
            f[x] = 0
    return f, consistent


# ------------------------------------------------------------- axioms as syntax trees
# formulas: ('Bit', it, y) ('Gate', gt, x, z) ('R', x) ('not', F) ('imp', F, G) ('all', v, F)
# terms: ('w', word) closed word term, or ('var', name), or ('s', a, term)
def T_word(w):
    return ('w', w)


def iff(A, B):
    return ('not', ('imp', ('imp', A, B), ('not', ('imp', B, A))))


def op_formula(op, A, B):
    if op == 'AND':
        return ('not', ('imp', A, ('not', B)))
    if op == 'OR':
        return ('imp', ('not', A), B)
    if op == 'XOR':
        return ('not', iff(A, B))
    if op == 'NAND':
        return ('imp', A, ('not', B))
    if op == 'NOR':
        return ('not', ('imp', ('not', A), B))
    if op == 'NOT':
        return ('not', A)
    raise ValueError(op)


def tsize(t):
    if t[0] == 'w':
        return term_size(t[1])
    if t[0] == 'var':
        return 1
    if t[0] == 's':
        return 1 + tsize(t[2])
    raise ValueError(t)


def fsize(F):
    h = F[0]
    if h == 'Bit':
        return 1 + tsize(F[1]) + tsize(F[2])
    if h == 'Gate':
        return 1 + tsize(F[1]) + tsize(F[2]) + tsize(F[3])
    if h == 'R':
        return 1 + tsize(F[1])
    if h == 'not':
        return 1 + fsize(F[1])
    if h == 'imp':
        return 1 + fsize(F[1]) + fsize(F[2])
    if h == 'all':
        return 1 + fsize(F[2])   # bound variable counted at its occurrences (de Bruijn style)
    raise ValueError(h)


def axioms(gates, acc, rej, d, k):
    D = max(d, k)
    Y, X, Z = ('var', 'y'), ('var', 'x'), ('var', 'z')
    n = lambda i: T_word(beta(i))
    g = lambda j: T_word(beta(j))
    ax = []
    ax.append(('Bit0', ('all', 'y', ('Bit', n(0), ('s', '1', Y)))))
    ax.append(('Bit0n', ('all', 'y', ('not', ('Bit', n(0), ('s', '0', Y))))))
    for i in range(D - 1):
        for a in '01':
            ax.append(('BitS', ('all', 'y', iff(('Bit', n(i + 1), ('s', a, Y)), ('Bit', n(i), Y)))))
    G = lambda j: ('Gate', g(j), X, Z)
    for j, gt in enumerate(gates):
        if gt[0] == 'x':
            body = iff(G(j), ('Bit', n(gt[1]), X))
        elif gt[0] == 'z':
            body = iff(G(j), ('Bit', n(gt[1]), Z))
        else:
            body = iff(G(j), op_formula(gt[1], G(gt[2]), G(gt[3])))
        ax.append(('gate%d' % j, ('all', 'x', ('all', 'z', body))))
    ax.append(('OutAcc', ('all', 'x', ('all', 'z', ('imp', G(acc), ('R', X))))))
    ax.append(('OutRej', ('all', 'x', ('all', 'z', ('imp', G(rej), ('not', ('R', X)))))))
    return ax


# ------------------------------------------------------------- semantics
def word_of(t, env):
    if t[0] == 'w':
        return t[1]
    if t[0] == 'var':
        return env[t[1]]
    if t[0] == 's':
        return t[1] + word_of(t[2], env)


def make_model(gates, acc, rej, d, k):
    D = max(d, k)
    idx = {beta(i): i for i in range(D)}
    gidx = {beta(j): j for j in range(len(gates))}

    def bit(tw, yw):
        if tw not in idx:
            return False
        i = idx[tw]
        return len(yw) > i and yw[i] == '1'

    def bits(w, m):
        return tuple(1 if len(w) > i and w[i] == '1' else 0 for i in range(m))

    def gate(tw, xw, zw):
        if tw not in gidx:
            return False
        return bool(evaluate(gates, bits(xw, d), bits(zw, k))[gidx[tw]])

    Rcache = {}

    def R(xw):
        bx = bits(xw, d)
        if bx not in Rcache:
            Rcache[bx] = any(evaluate(gates, bx, z)[acc] for z in itertools.product([0, 1], repeat=k))
        return Rcache[bx]

    return bit, gate, R


def holds(F, env, model, dom):
    bit, gate, R = model
    h = F[0]
    if h == 'Bit':
        return bit(word_of(F[1], env), word_of(F[2], env))
    if h == 'Gate':
        return gate(word_of(F[1], env), word_of(F[2], env), word_of(F[3], env))
    if h == 'R':
        return R(word_of(F[1], env))
    if h == 'not':
        return not holds(F[1], env, model, dom)
    if h == 'imp':
        return (not holds(F[1], env, model, dom)) or holds(F[2], env, model, dom)
    if h == 'all':
        return all(holds(F[2], dict(env, **{F[1]: w}), model, dom) for w in dom)
    raise ValueError(h)


# ------------------------------------------------------------- forward propagation (derivability)
def derive_label(gates, acc, rej, d, k, x, c):
    """Ground instances with x := t_x, z := t_c.  Propagate Bit facts along the BitS chain from
    Bit0, then gates in order through their biconditionals, then the output axioms.  Returns the
    derived literal for R(t_x) (1, 0 or None) and the nonlogical material used."""
    D = max(d, k)
    xw = ''.join(map(str, x))
    zw = ''.join(map(str, c))
    material = 0
    used = set()

    def use(key, size):
        nonlocal material
        if key not in used:
            used.add(key)
            material += size

    known = {}  # (i, word) -> bool

    def bitval(i, w):
        # derive Bit(n_i, t_w) for |w| > i: Bit0 instance at w[i:], then i BitS instances
        if (i, w) in known:
            return known[(i, w)]
        tail = w[i:]
        v = tail[0] == '1'
        y = tail[1:]
        use(('Bit0', tail[0], y), 1 + term_size(beta(0)) + 1 + term_size(y) + (1 if tail[0] == '0' else 0))
        for j in range(1, i + 1):
            a = w[i - j]
            y2 = w[i - j + 1:]
            # instance Bit(n_j, s_a t_{y2}) <-> Bit(n_{j-1}, t_{y2})
            A = 1 + term_size(beta(j)) + 1 + term_size(y2)
            B = 1 + term_size(beta(j - 1)) + term_size(y2)
            use(('BitS', j, a, y2), 5 + 2 * A + 2 * B)
        known[(i, w)] = v
        return v

    val = []
    Gg = lambda j: ('Gate', ('w', beta(j)), ('w', xw), ('w', zw))
    gsz = lambda j: fsize(Gg(j))
    for j, gt in enumerate(gates):
        if gt[0] == 'x':
            v = bitval(gt[1], xw)
            use(('gate', j), fsize(iff(Gg(j), ('Bit', ('w', beta(gt[1])), ('w', xw)))))
        elif gt[0] == 'z':
            v = bitval(gt[1], zw)
            use(('gate', j), fsize(iff(Gg(j), ('Bit', ('w', beta(gt[1])), ('w', zw)))))
        else:
            v = bool(OPS[gt[1]](int(val[gt[2]]), int(val[gt[3]])))
            use(('gate', j), fsize(iff(Gg(j), op_formula(gt[1], Gg(gt[2]), Gg(gt[3])))))
        val.append(v)
    lab = None
    if val[acc]:
        use(('outacc',), 2 + gsz(acc) + 1 + term_size(xw))
        lab = 1
    if val[rej]:
        use(('outrej',), 3 + gsz(rej) + 1 + term_size(xw))
        lab = 0 if lab is None else 'both'
    return lab, material


def main():
    rng = random.Random(SEED)
    out('c4_circuit_axioms.py  seed %d' % SEED)
    out('')
    out('(i)-(iii): random consistent verifier circuits')
    out('  d k  gates  axioms  T_V size  |dom f|  model-ok  R=f  derive-ok  max material  corrupt: detected/changed-f')
    tot_bad = 0
    for d, k in [(2, 1), (2, 2), (3, 1), (3, 2)]:
        for trial in range(6):
            gates, acc, rej = random_verifier(rng, d, k, rng.randint(2, 5), rng.randint(2, 5))
            f, cons = label_fn(gates, acc, rej, d, k)
            assert cons
            AX = axioms(gates, acc, rej, d, k)
            size = sum(fsize(F) for _, F in AX)
            model = make_model(gates, acc, rej, d, k)
            Dm = max(d, k)
            words = [''.join(b) for n in range(Dm + 3) for b in itertools.product('01', repeat=n)]
            dom = sorted(set(words) | {beta(i) for i in range(Dm)} | {beta(j) for j in range(len(gates))})
            model_ok = all(holds(F, {}, model, dom) for _, F in AX)
            bit, gate, R = model
            Rf = all(R(''.join(map(str, x))) == (f[x] == 1) for x in f)
            deriv_ok = True
            maxmat = 0
            for x, y in f.items():
                cs = [c for c in itertools.product([0, 1], repeat=k)
                      if evaluate(gates, x, c)[acc if y == 1 else rej]]
                lab, mat = derive_label(gates, acc, rej, d, k, x, cs[0])
                maxmat = max(maxmat, mat)
                if lab != y:
                    deriv_ok = False
            # negative control: change the op of one internal gate
            det = chg = 0
            ops_idx = [j for j, gt in enumerate(gates) if gt[0] == 'op']
            for _ in range(10):
                j = rng.choice(ops_idx)
                g2 = list(gates)
                newop = rng.choice([o for o in OPS if o != gates[j][1]])
                g2[j] = ('op', newop, gates[j][2], gates[j][3])
                f2, cons2 = label_fn(g2, acc, rej, d, k)
                if f2 == f and cons2:
                    continue
                chg += 1
                # detection: corrupted theory derives a wrong label on dom f, or its intended model
                # violates Gamma_f, or the corrupted verifier is inconsistent
                wrong = False
                for x, y in f.items():
                    for c in itertools.product([0, 1], repeat=k):
                        lab, _ = derive_label(g2, acc, rej, d, k, x, c)
                        if lab is not None and lab != y:
                            wrong = True
                if not cons2:
                    wrong = True
                m2 = make_model(g2, acc, rej, d, k)
                if any(m2[2](''.join(map(str, x))) != (y == 1) for x, y in f.items()):
                    wrong = True
                if wrong or set(f2) != set(f):
                    det += 1
            ok = model_ok and Rf and deriv_ok
            tot_bad += 0 if ok else 1
            out('  %d %d  %5d  %6d  %8d  %7d  %-8s  %-4s %-9s  %12d  %d/%d'
                % (d, k, len(gates), len(AX), size, len(f), model_ok, Rf, deriv_ok, maxmat, det, chg))
    out('  rows with a failed check: %d' % tot_bad)
    out('')
    out('(iv) sizes: total symbol size of T_V against (s+d) log2(s+d)')
    out('  d   k    s(gates)  |T_V|    (s+d)log2(s+d)   ratio')
    for d, k, nh in [(3, 2, 10), (8, 8, 40), (16, 16, 90), (32, 32, 190), (32, 64, 400)]:
        gates, acc, rej = random_verifier(rng, d, k, nh // 2, nh)
        AX = axioms(gates, acc, rej, d, k)
        size = sum(fsize(F) for _, F in AX)
        s = len(gates)
        ref = (s + d) * math.log2(s + d)
        out('  %-3d %-4d %-9d %-8d %-16.1f %.2f' % (d, k, s, size, ref, size / ref))
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
