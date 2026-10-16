"""Shared helpers for the `shape` thread checks (independent of scout N2's code).

Conventions
* Base variables are 0..m-1; auxiliary variables are m..N-1.
* A literal is a pair (v, s): variable v, sign s in {0,1}; (v,1) means x_v = 1, (v,0) means x_v = 0.
* A clause is a tuple of literals (a disjunction); a theory is a list of clauses.
* An assignment is a list a[0..N-1] with values -1 (unassigned), 0, 1.
* Vectors over GF(2) are Python ints used as bit masks (bit i = coordinate i).
* up(F, N, alpha, rounds) is parallel unit propagation: in each round every clause whose literals are all
  falsified except one unassigned literal derives that literal; returns None on a conflict.
"""
from itertools import product, combinations

CONFLICT = None


def popcount(x):
    return bin(x).count("1")


def up(F, N, alpha, rounds=None):
    """Parallel unit propagation. alpha: dict var->value. Returns the assignment list or None (conflict)."""
    a = [-1] * N
    for v, s in alpha.items():
        a[v] = s
    t = 0
    while rounds is None or t < rounds:
        new = {}
        for C in F:
            unas = None
            nun = 0
            sat = False
            for (v, s) in C:
                av = a[v]
                if av == -1:
                    nun += 1
                    unas = (v, s)
                    if nun > 1:
                        break
                elif av == s:
                    sat = True
                    break
            if sat or nun > 1:
                continue
            if nun == 0:
                return None
            v, s = unas
            if v in new and new[v] != s:
                return None
            new[v] = s
        if not new:
            break
        for v, s in new.items():
            a[v] = s
        t += 1
    return a


# ---------------------------------------------------------------- GF(2) linear algebra

def rref_rows(rows):
    """Row-reduce a list of int bit-vectors; return a list of independent rows (echelon basis)."""
    basis = []  # list of (pivot_bit, row)
    for r in rows:
        for p, b in basis:
            if r >> p & 1:
                r ^= b
        if r:
            p = r.bit_length() - 1
            # reduce existing rows by the new one
            basis = [(q, (b ^ r) if (b >> p & 1) else b) for q, b in basis]
            basis.append((p, r))
    return basis


def in_span(vec, basis):
    for p, b in basis:
        if vec >> p & 1:
            vec ^= b
    return vec == 0


def span_all(rows):
    """All vectors in the span of rows (rows assumed independent or not)."""
    basis = [b for _, b in rref_rows(rows)]
    out = [0]
    for b in basis:
        out = out + [x ^ b for x in out]
    return out


class AffineLaw:
    """The law S = {x in GF(2)^m : A x = b}; A given as list of (row_mask, b_bit)."""

    def __init__(self, m, eqs):
        self.m = m
        self.eqs = list(eqs)
        # augmented rows: bit m is the constant
        aug = [r | (c << m) for r, c in eqs]
        self.aug_basis = rref_rows(aug)
        if any(b == (1 << m) for _, b in self.aug_basis):
            raise ValueError("inconsistent system")
        self.k = len(self.aug_basis)
        # codewords with their constants: u -> c_u
        allaug = span_all(aug)
        self.const = {}
        for v in allaug:
            u = v & ((1 << m) - 1)
            self.const[u] = v >> m
        self.codewords = [u for u in self.const if u]
        self.sols = [x for x in range(1 << m) if all(popcount(x & r) % 2 == c for r, c in eqs)]
        self.solset = set(self.sols)

    def dmin(self):
        return min(popcount(u) for u in self.codewords) if self.codewords else None

    def circuits(self):
        cw = self.codewords
        out = []
        for u in cw:
            if not any((v != u) and (v & u) == v for v in cw):
                out.append(u)
        return out

    def consistent(self, alpha):
        return any(all((x >> v & 1) == s for v, s in alpha.items()) for x in self.sols)

    def implied(self, alpha):
        """Set of base literals implied by S and alpha (alpha consistent)."""
        ext = [x for x in self.sols if all((x >> v & 1) == s for v, s in alpha.items())]
        out = set()
        for v in range(self.m):
            if v in alpha:
                continue
            vals = {x >> v & 1 for x in ext}
            if len(vals) == 1:
                out.add((v, vals.pop()))
        return out


def law_implied(sols, m, alpha):
    ext = [x for x in sols if all((x >> v & 1) == s for v, s in alpha.items())]
    if not ext:
        return None
    out = set()
    for v in range(m):
        if v in alpha:
            continue
        vals = {x >> v & 1 for x in ext}
        if len(vals) == 1:
            out.add((v, vals.pop()))
    return out


def clause_on(T_mask, beta, m):
    """Clause over support T (mask) falsified exactly by beta (dict var->value): literals (v, 1-beta[v])."""
    return tuple((v, 1 - beta[v]) for v in range(m) if T_mask >> v & 1)


def parity_clauses(T_mask, c, m):
    """All 2^{|T|-1} clauses on T forbidding assignments beta with parity(beta on T) != c."""
    vs = [v for v in range(m) if T_mask >> v & 1]
    out = []
    for bits in product((0, 1), repeat=len(vs)):
        if sum(bits) % 2 != c:
            beta = dict(zip(vs, bits))
            out.append(tuple((v, 1 - beta[v]) for v in vs))
    return out


def prime_implicates_bruteforce(sols, m):
    """All prime implicates of the set sols (ints) over m vars, by brute force over all clauses."""
    solset = set(sols)
    # projection test: beta on T not extendable to any solution
    impl = []
    for T in range(1, 1 << m):
        vs = [v for v in range(m) if T >> v & 1]
        projT = {tuple((x >> v) & 1 for v in vs) for x in sols}
        for bits in product((0, 1), repeat=len(vs)):
            if bits not in projT:
                impl.append((T, bits, vs))
    implset = {(T, bits) for T, bits, vs in impl}
    primes = []
    for T, bits, vs in impl:
        prime = True
        # proper sub-clause: drop at least one literal
        for i in range(len(vs)):
            T2 = T & ~(1 << vs[i])
            if T2 == 0:
                continue
            bits2 = tuple(b for j, b in enumerate(bits) if j != i)
            if (T2, bits2) in implset:
                prime = False
                break
        if prime:
            primes.append(tuple((v, 1 - b) for v, b in zip(vs, bits)))
    return primes


def all_partial_assignments(m, vars_=None):
    vars_ = list(range(m)) if vars_ is None else vars_
    for vals in product((-1, 0, 1), repeat=len(vars_)):
        yield {v: s for v, s in zip(vars_, vals) if s != -1}


def usable(F, N, m, sols, rounds=None, alphas=None, check_conflict=True):
    """Check UP(-k) usability of F for the law with solution set sols (over base vars 0..m-1).
    Returns (ok, n_questions_checked, first_failure)."""
    nq = 0
    it = alphas if alphas is not None else all_partial_assignments(m)
    for alpha in it:
        imp = law_implied(sols, m, alpha)
        if imp is None:
            if check_conflict:
                a = up(F, N, alpha, rounds)
                if a is not None:
                    pass  # conflict detection is not part of usability; recorded elsewhere
            continue
        if not imp:
            continue
        a = up(F, N, alpha, rounds)
        nq += len(imp)
        if a is None:
            return False, nq, ("conflict", alpha)
        for v, s in imp:
            if a[v] != s:
                return False, nq, ("missing", alpha, (v, s))
    return True, nq, None


def chain_encoding(T_vars, c, aux_start):
    """Chain encoding of XOR over variables T_vars (list) = c with fresh aux vars from aux_start.
    Returns (clauses, n_aux). Width-3 XOR constraints written with 4 clauses, the last with 2."""
    w = len(T_vars)
    if w == 1:
        return [((T_vars[0], c),)], 0
    if w == 2:
        a, b = T_vars
        # a xor b = c
        return [cl for cl in xor_clauses([a, b], c)], 0
    if w == 3:
        return xor_clauses(T_vars, c), 0
    cls = []
    y = aux_start
    # y0 = x0 xor x1  <=> x0 xor x1 xor y0 = 0
    cls += xor_clauses([T_vars[0], T_vars[1], y], 0)
    for i in range(2, w - 1):
        y_new = y + 1
        cls += xor_clauses([y, T_vars[i], y_new], 0)
        y = y_new
    cls += xor_clauses([y, T_vars[w - 1]], c)
    return cls, y - aux_start + 1


def xor_clauses(vs, c):
    out = []
    for bits in product((0, 1), repeat=len(vs)):
        if sum(bits) % 2 != c:
            out.append(tuple((v, 1 - b) for v, b in zip(vs, bits)))
    return out


def random_system(rng, m, k, row_weights=None):
    """Random consistent system of k independent equations over m vars (rows as masks)."""
    while True:
        rows = []
        for _ in range(k):
            if row_weights is None:
                r = rng.randrange(1, 1 << m)
            else:
                w = rng.choice(row_weights)
                r = 0
                for v in rng.sample(range(m), w):
                    r |= 1 << v
            rows.append(r)
        if len(rref_rows(rows)) == k:
            x0 = rng.randrange(1 << m)
            eqs = [(r, popcount(r & x0) % 2) for r in rows]
            return eqs
