#!/usr/bin/env python3
"""n1: reasoner-relative theory size for linear (XOR) laws.

Scout N2 (novel-science), push P1.  Seed 20261015.  Writes n1_xor_usability.out next to itself.

Setting.  A "law" is an affine subspace V = {x in GF(2)^n : A x = b} (k independent equations).  A
"conditional literal question" is (alpha, l): alpha a partial assignment of base variables consistent
with V, l a base literal; the question is answered "yes" iff V and alpha entail l.  A theory is a finite
CNF (possibly with auxiliary variables, "theoretical terms"); the reasoner UP (unit propagation) answers
(alpha, l) iff UP(F + alpha) derives l.  F is "UP-usable" (propagation complete on base variables) if UP
answers every entailed question.

Parts.
  E1  linear-algebra determination agrees with brute-force entailment (small n, exhaustive).
  E2  Claim A: every implicate of V has width >= d (d = dual distance), so any no-aux CNF has
      >= (1 - 2^-k) 2^d clauses.  Claim C: every UP-usable no-aux CNF contains all 2^(d-1) full
      clauses on each minimum-weight dual codeword (d >= 3).  Checked: min width of prime implicates = d;
      the set of all prime implicates is UP-usable; deleting any single minimum-weight clause from it
      breaks usability (a failing question is exhibited).
  E3  the two-equation example: x1+x2+x3=0, x2+x3+x4=0; UP from x1=1 does not derive x4=1.
  E4  one equation, chain (Tseitin) encoding with n-2 auxiliary variables: UP-usable for base variables
      and propagation complete for all variables (n = 3..7, exhaustive over all 3^(#vars) partial
      assignments, inconsistent ones included).
  E5  sparse random systems: core CNF (each equation encoded directly), UP-usability of the core on
      sampled questions, the usability-size curve when prime-implicate lemmas of dual weight <= w are
      added, and the lower bounds.
  E6  dense random systems, k = n/2: d, A_d (number of minimum-weight dual codewords), the no-aux lower
      bounds, the number of prime implicates, and the sizes of the cores (equations as numbers; chain
      encoding with auxiliary variables).
"""
import itertools
import random
import sys
import time
from math import comb

import numpy as np

SEED = 20261015
OUT_LINES = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT_LINES.append(s)
    print(s)


def popcount(v):
    return bin(v).count("1")


def parity(v):
    return popcount(v) & 1


# ---------------------------------------------------------------- GF(2) linear algebra (bitmasks)
class Basis:
    """Row-echelon basis of a GF(2) subspace; vectors are int bitmasks (bit i = variable i)."""

    def __init__(self, vecs=()):
        self.piv = {}
        self.order = []
        for v in vecs:
            self.add(v)

    def reduce(self, v):
        for p in self.order:
            if (v >> p) & 1:
                v ^= self.piv[p]
        return v

    def add(self, v):
        v = self.reduce(v)
        if v:
            p = v.bit_length() - 1
            self.piv[p] = v
            self.order = sorted(self.piv, reverse=True)
            return True
        return False

    def copy(self):
        b = Basis()
        b.piv = dict(self.piv)
        b.order = list(self.order)
        return b

    def rank(self):
        return len(self.piv)


def random_system(n, k, rng, row_weight=None):
    """Random k x n full-rank system A (rows as bitmasks) and a random solution x*; b := A x*."""
    while True:
        rows = []
        for _ in range(k):
            if row_weight is None:
                r = rng.getrandbits(n)
            else:
                w = rng.choice(row_weight) if isinstance(row_weight, (list, tuple)) else row_weight
                r = 0
                for i in rng.sample(range(n), w):
                    r |= 1 << i
            rows.append(r)
        if Basis(rows).rank() == k and all(rows):
            break
    xstar = rng.getrandbits(n)
    consts = [parity(r & xstar) for r in rows]
    return rows, consts, xstar


def codewords(rows):
    """All nonzero codewords of the row space (dual code C-perp), each with its constant (on V)."""
    k = len(rows)
    words = []
    for mask in range(1, 1 << k):
        v = 0
        for i in range(k):
            if (mask >> i) & 1:
                v ^= rows[i]
        words.append(v)
    return words


def circuits(words):
    """Nonzero codewords with minimal support (no other nonzero codeword's support strictly inside)."""
    W = np.array(words, dtype=np.uint64)
    res = []
    for idx, u in enumerate(words):
        uu = np.uint64(u)
        inside = (W & ~uu) == 0  # supports contained in supp(u)
        inside[idx] = False
        if not inside.any():
            res.append(u)
    return res


def solutions(rows, consts, n):
    sols = []
    for x in range(1 << n):
        if all(parity(r & x) == c for r, c in zip(rows, consts)):
            sols.append(x)
    return sols


# ---------------------------------------------------------------- CNF utilities (DIMACS-style literals)
def xor_clauses(vars_, c):
    """Direct CNF of XOR(vars_) = c: one clause per falsifying assignment (2^(w-1) clauses)."""
    w = len(vars_)
    cls = []
    for bits in range(1 << w):
        if parity(bits) != c:
            # clause falsified exactly by assignment bits: literal x_v if bit=0 else -x_v
            cls.append(tuple((v if not (bits >> j) & 1 else -v) for j, v in enumerate(vars_)))
    return cls


def chain_clauses(vars_, c, next_aux):
    """Chain (Tseitin) encoding of XOR(vars_) = c with auxiliary variables; returns clauses, next_aux."""
    w = len(vars_)
    if w <= 3:
        return xor_clauses(vars_, c), next_aux
    cls = []
    prev = vars_[0]
    for j in range(1, w - 1):
        y = next_aux
        next_aux += 1
        cls += xor_clauses((prev, vars_[j], y), 0)  # y = prev xor x_j
        prev = y
    cls += xor_clauses((prev, vars_[-1]), c)
    return cls, next_aux


def bitvars(v):
    return [i for i in range(v.bit_length()) if (v >> i) & 1]


class CNF:
    def __init__(self, clauses):
        self.clauses = [tuple(c) for c in clauses]
        self.occ = {}
        for ci, cl in enumerate(self.clauses):
            for lit in cl:
                self.occ.setdefault(abs(lit), []).append(ci)

    def size(self):
        return len(self.clauses), sum(len(c) for c in self.clauses)

    def up(self, init):
        """Unit propagation from the partial assignment init (dict var->bool). Returns dict or None (conflict)."""
        val = dict(init)
        queue = list(init)
        # clauses that are unit or empty from the start
        for ci, cl in enumerate(self.clauses):
            if len(cl) == 1:
                lit = cl[0]
                var = abs(lit)
                if var in val:
                    if val[var] != (lit > 0):
                        return None
                else:
                    val[var] = lit > 0
                    queue.append(var)
        while queue:
            v = queue.pop()
            for ci in self.occ.get(v, ()):
                cl = self.clauses[ci]
                nun = 0
                last = None
                sat = False
                for lit in cl:
                    var = abs(lit)
                    if var in val:
                        if val[var] == (lit > 0):
                            sat = True
                            break
                    else:
                        nun += 1
                        last = lit
                if sat or nun > 1:
                    continue
                if nun == 0:
                    return None
                var = abs(last)
                val[var] = last > 0
                queue.append(var)
        return val


def to_cnf_var(i):
    return i + 1  # base variable i (0-based) -> CNF variable i+1


def determined(rows_basis, S_mask, n):
    """Base variables outside S whose value is a function of x_S on V."""
    b = rows_basis.copy()
    for i in bitvars(S_mask):
        b.add(1 << i)
    return [j for j in range(n) if not (S_mask >> j) & 1 and b.reduce(1 << j) == 0]


def up_answers(cnf, x, S_mask, n):
    init = {to_cnf_var(i): bool((x >> i) & 1) for i in bitvars(S_mask)}
    val = cnf.up(init)
    return val


# ---------------------------------------------------------------- E1
def e1(rng):
    out("== E1: linear-algebra determination = brute-force entailment (exhaustive over S, small n)")
    for trial in range(3):
        n, k = 8, 4
        rows, consts, xstar = random_system(n, k, rng, row_weight=(3, 4))
        sols = solutions(rows, consts, n)
        B = Basis(rows)
        bad = 0
        checked = 0
        for S in range(1 << n):
            for x in sols[:8]:
                xs = x & S
                comp = [y for y in sols if y & S == xs]
                det_bf = [j for j in range(n) if not (S >> j) & 1 and len({(y >> j) & 1 for y in comp}) == 1]
                det_la = determined(B, S, n)
                checked += 1
                if det_bf != det_la:
                    bad += 1
        out(f"  trial {trial}: n={n} k={k} |V|={len(sols)} (S, x) pairs checked={checked} mismatches={bad}")


# ---------------------------------------------------------------- E2
def prime_implicates(rows, consts, xstar):
    words = codewords(rows)
    circ = circuits(words)
    cls = []
    for u in circ:
        cu = parity(u & xstar)
        vs = [to_cnf_var(i) for i in bitvars(u)]
        cls += xor_clauses(vs, cu)
    return words, circ, cls


def usable_report(cnf, rows, consts, xstar, n, queries):
    """queries: list of (x, S). Returns (#pairs, #derived, #queries fully answered, #queries)."""
    B = Basis(rows)
    pairs = derived = full = 0
    fail_example = None
    for x, S in queries:
        det = determined(B, S, n)
        if not det:
            continue
        val = up_answers(cnf, x, S, n)
        assert val is not None, "UP conflict on a consistent assignment (unsound?)"
        ok_all = True
        for j in det:
            pairs += 1
            v = to_cnf_var(j)
            if v in val and val[v] == bool((x >> j) & 1):
                derived += 1
            else:
                ok_all = False
                if fail_example is None:
                    fail_example = (x, S, j)
        full += ok_all
    nq = sum(1 for x, S in queries if determined(B, S, n))
    return pairs, derived, full, nq, fail_example


def all_queries(sols, n, per_S=None, rng=None):
    qs = []
    for S in range(1 << n):
        xs_seen = set()
        for x in sols:
            key = x & S
            if key in xs_seen:
                continue
            xs_seen.add(key)
            qs.append((x, S))
    return qs


def e2(rng):
    out("== E2: Claim A (implicate width >= d) and Claim C (min-weight clauses are needed for UP-usability)")
    for trial in range(4):
        n, k = 9, 4
        rows, consts, xstar = random_system(n, k, rng)  # dense rows
        words, circ, pi = prime_implicates(rows, consts, xstar)
        d = min(popcount(w) for w in words)
        Ad = sum(1 for w in words if popcount(w) == d)
        minwidth = min(len(c) for c in pi)
        sols = solutions(rows, consts, n)
        qs = all_queries(sols, n)
        F = CNF(pi)
        pairs, derived, full, nq, _ = usable_report(F, rows, consts, xstar, n, qs)
        out(f"  trial {trial}: n={n} k={k} d={d} A_d={Ad} circuits={len(circ)} prime implicates={len(pi)} "
            f"min width={minwidth} (=d: {minwidth == d}); all-PI theory: {derived}/{pairs} entailed literals derived, "
            f"{full}/{nq} questions fully answered")
        if d >= 3:
            # delete each minimum-weight clause in turn; usability must fail
            minw = [c for c in pi if len(c) == d]
            fails = 0
            for cdel in minw:
                F2 = CNF([c for c in pi if c != cdel])
                p2, d2, f2, nq2, ex = usable_report(F2, rows, consts, xstar, n, qs)
                if d2 < p2:
                    fails += 1
            out(f"           deleting one min-weight clause ({len(minw)} = A_d * 2^(d-1) = {Ad * 2 ** (d - 1)} cases): "
                f"usability fails in {fails}/{len(minw)} cases")
            # CNF lower bound (any equivalent no-aux CNF)
            out(f"           no-aux CNF lower bound (1-2^-k)2^d = {(1 - 2 ** -k) * 2 ** d:.2f}; "
                f"no-aux UP-usable lower bound A_d 2^(d-1) = {Ad * 2 ** (d - 1)}")


# ---------------------------------------------------------------- E3
def e3():
    out("== E3: two equations x1+x2+x3=0, x2+x3+x4=0 (direct encoding); question: x1=1 entails x4=1?")
    cls = xor_clauses((1, 2, 3), 0) + xor_clauses((2, 3, 4), 0)
    F = CNF(cls)
    val = F.up({1: True})
    out(f"  UP from x1=1 assigns: {sorted((v, int(b)) for v, b in val.items())}; x4 derived: {4 in val}")
    F2 = CNF(cls + xor_clauses((1, 4), 0))
    val2 = F2.up({1: True})
    out(f"  with the lemma x1+x4=0 (2 clauses) added: x4 derived = {val2.get(4)}")


# ---------------------------------------------------------------- E4
def e4():
    out("== E4: one equation x1+...+xn=0, chain encoding with n-2 auxiliary variables (n>=4)")
    for n in range(3, 8):
        vs = list(range(1, n + 1))
        cls, nxt = chain_clauses(vs, 0, n + 1)
        F = CNF(cls)
        nvars = nxt - 1
        # all models over all variables (base + aux)
        models = []
        for x in range(1 << n):
            if parity(x) != 0:
                continue
            # aux values forced by the chain
            val = {i + 1: bool((x >> i) & 1) for i in range(n)}
            prev = val[1]
            a = n + 1
            for j in range(2, n):
                if a > nvars:
                    break
                prev = prev ^ val[j]
                val[a] = prev
                a += 1
            models.append(val)
        # PC over all variables: every partial assignment consistent with some model; implied literals derived
        ok_base = ok_all = True
        cnt_all = 0
        allvars = list(range(1, nvars + 1))
        for assign in itertools.product((None, False, True), repeat=nvars):
            alpha = {v: b for v, b in zip(allvars, assign) if b is not None}
            comp = [m for m in models if all(m[v] == b for v, b in alpha.items())]
            if not comp:
                val = F.up(alpha)
                if val is not None:  # PC also requires refutation of inconsistent assignments
                    ok_all = False
                    if all(v <= n for v in alpha):
                        ok_base = False
                continue
            cnt_all += 1
            val = F.up(alpha)
            implied = [v for v in allvars if v not in alpha and len({m[v] for m in comp}) == 1]
            for v in implied:
                if val is None or val.get(v) != comp[0][v]:
                    ok_all = False
                    if all(u <= n for u in alpha) and v <= n:
                        ok_base = False
        out(f"  n={n}: clauses={len(cls)} (direct CNF needs {2 ** (n - 1)}), aux vars={nvars - n}, "
            f"UP-usable on base vars={ok_base}, propagation complete on all vars={ok_all} "
            f"(consistent partial assignments checked: {cnt_all})")


# ---------------------------------------------------------------- E5
def sample_queries(rows, consts, xstar, n, rng, nq):
    sols_basis = None
    qs = []
    # random solutions: xstar + random element of the kernel; sample by rejection on small n, else by kernel basis
    ker = kernel_basis(rows, n)
    for _ in range(nq):
        x = xstar
        for kv in ker:
            if rng.getrandbits(1):
                x ^= kv
        # random S: each variable with probability p, p uniform in (0.2, 0.8)
        p = rng.uniform(0.2, 0.8)
        S = 0
        for i in range(n):
            if rng.random() < p:
                S |= 1 << i
        qs.append((x, S))
    return qs


def kernel_basis(rows, n):
    """Basis of {x : A x = 0} over GF(2)."""
    # Gaussian elimination on the k x n matrix, column-pivoted
    m = [r for r in rows]
    pivcols = []
    r = 0
    for col in range(n):
        sel = None
        for i in range(r, len(m)):
            if (m[i] >> col) & 1:
                sel = i
                break
        if sel is None:
            continue
        m[r], m[sel] = m[sel], m[r]
        for i in range(len(m)):
            if i != r and (m[i] >> col) & 1:
                m[i] ^= m[r]
        pivcols.append(col)
        r += 1
        if r == len(m):
            break
    free = [c for c in range(n) if c not in pivcols]
    ker = []
    for f in free:
        v = 1 << f
        for i, pc in enumerate(pivcols):
            if (m[i] >> f) & 1:
                v |= 1 << pc
        ker.append(v)
    for v in ker:
        assert all(parity(rw & v) == 0 for rw in rows)
    return ker


def e5(rng):
    out("== E5: sparse random systems (row weights 3-4), core = equations encoded directly (no aux)")
    out("   usability-size curve: theory_w = core + all prime implicates on dual circuits of weight <= w")
    for (n, k) in [(12, 6), (16, 8), (20, 10)]:
        rows, consts, xstar = random_system(n, k, rng, row_weight=(3, 4))
        core = []
        for r, c in zip(rows, consts):
            core += xor_clauses([to_cnf_var(i) for i in bitvars(r)], c)
        words = codewords(rows)
        d = min(popcount(w) for w in words)
        Ad = sum(1 for w in words if popcount(w) == d)
        circ = circuits(words)
        wmax = max(popcount(u) for u in circ)
        qs = sample_queries(rows, consts, xstar, n, rng, 3000)
        out(f"  n={n} k={k}: d={d} A_d={Ad} circuits={len(circ)} (max circuit weight {wmax}); "
            f"GE core = {k} equations = {k * (n + 1)} bits")
        lb_cnf = (1 - 2 ** -k) * 2 ** d
        lb_pc = Ad * 2 ** (d - 1) if d >= 3 else None
        out(f"    no-aux lower bounds: any CNF >= {lb_cnf:.1f} clauses; UP-usable >= {lb_pc} clauses (d>=3 needed)")
        Fc = CNF(core)
        p, dv, full, nq, ex = usable_report(Fc, rows, consts, xstar, n, qs)
        cl, lits = Fc.size()
        out(f"    w=core : clauses={cl:6d} literal occ={lits:7d} | entailed literals derived {dv}/{p} = {dv / max(p, 1):.3f};"
            f" questions fully answered {full}/{nq} = {full / max(nq, 1):.3f}")
        for w in range(d, wmax + 1):
            th = list(core)
            for u in circ:
                if popcount(u) <= w:
                    th += xor_clauses([to_cnf_var(i) for i in bitvars(u)], parity(u & xstar))
            F = CNF(list(dict.fromkeys(th)))
            p, dv, full, nq, ex = usable_report(F, rows, consts, xstar, n, qs)
            cl, lits = F.size()
            out(f"    w={w:4d} : clauses={cl:6d} literal occ={lits:7d} | entailed literals derived {dv}/{p} = {dv / max(p, 1):.3f};"
                f" questions fully answered {full}/{nq} = {full / max(nq, 1):.3f}")
            if dv == p:
                break
        # chain encoding with aux variables of the same core: identical here (rows of weight <= 4 use 4-var chain)
        auxcore = []
        nxt = n + 1
        for r, c in zip(rows, consts):
            cls, nxt = chain_clauses([to_cnf_var(i) for i in bitvars(r)], c, nxt)
            auxcore += cls
        Fa = CNF(auxcore)
        p, dv, full, nq, ex = usable_report(Fa, rows, consts, xstar, n, qs)
        cl, lits = Fa.size()
        out(f"    chain core (aux vars {nxt - n - 1}): clauses={cl} literal occ={lits} | derived {dv}/{p} = {dv / max(p, 1):.3f};"
            f" fully answered {full}/{nq} = {full / max(nq, 1):.3f}")


# ---------------------------------------------------------------- E6
def e6(rng):
    out("== E6: dense random systems, k = n/2 (3 systems per n): growth of the no-aux bounds")
    out("   columns: n k | d A_d | no-aux CNF lb (1-2^-k)2^d | no-aux UP-usable lb A_d 2^(d-1) | #prime implicate clauses |"
        " GE core bits k(n+1) | chain core clauses (aux vars)")
    for n in (8, 12, 16, 20, 24):
        k = n // 2
        for rep in range(3):
            rows, consts, xstar = random_system(n, k, rng)
            words = codewords(rows)
            d = min(popcount(w) for w in words)
            Ad = sum(1 for w in words if popcount(w) == d)
            circ = circuits(words)
            npi = sum(2 ** (popcount(u) - 1) for u in circ)
            lb_cnf = (1 - 2 ** -k) * 2 ** d
            lb_pc = Ad * 2 ** (d - 1) if d >= 3 else float("nan")
            chain = 0
            aux = 0
            for r in rows:
                w = popcount(r)
                if w <= 3:
                    chain += 2 ** (w - 1)
                else:
                    chain += 4 * (w - 2) + 2
                    aux += w - 2
            out(f"   n={n:2d} k={k:2d} | d={d} A_d={Ad:3d} | {lb_cnf:9.1f} | {lb_pc:9} | {npi:12d} | {k * (n + 1):4d} | {chain} ({aux})")


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    out(f"# n1_xor_usability.py  seed={SEED}  python={sys.version.split()[0]} numpy={np.__version__}")
    e1(rng)
    e2(rng)
    e3()
    e4()
    e5(rng)
    e6(rng)
    out(f"# done in {time.time() - t0:.1f}s")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT_LINES) + "\n")


if __name__ == "__main__":
    main()
