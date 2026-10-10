"""c3: reading (a1) of Hänni's proposal, every axiom instance short (notes §4: Lemma 4.1, Theorem 4.2, Prop 4.3).

Part A (Lemma 4.1, Theorem 4.2): the canonical closure that decides "derivable with all lines of size <= H".
  Language: a 0-ary relation symbol a, a unary relation symbol P, a constant c, equality. Nonlogical axioms NL
  (closed, parameter-free). The closure is computed over all canonical formulas (parameters renamed by first
  occurrence) of size <= H, H = 9, starting from the axiom instances (independent recognisers of kcore) and closing
  under MP and Gen on canonical forms.
  * Soundness: for every member, an explicit K-derivation is rebuilt from the recorded justifications, using
    bijective renamings of parameters (Lemma 4.1(a)), and validated by kcore.check_derivation; every line must have
    size <= H and the last line must be the member itself.
  * Completeness: random derivations with all lines of size <= H (built independently, by forward chaining) are
    validated, and the canonical form of each of their lines must be in the closure.
  * Size of the search space: the number of canonical formulas of size <= H against the bound (|Sigma| + 2H + 4)^(H+1)
    used in Theorem 4.2.
Part B (Prop 4.3, deterministic case): a k-bit counter as ground axioms C(t_v) -> C(t_{v+1}); the derivation of
  C(t_{1^k}) from C(t_{0^k}) has 2^k - 1 MP steps, every axiom instance has size 2k + 5.
Part C (Prop 4.3, alternating case): QBF evaluation by ground axioms (existential nodes: one premise; universal
  nodes: two premises; the dual predicate C' for false). Derivations are validated, their verdict is compared with
  direct evaluation, and line counts (exponential in n) are compared with instance sizes (linear in n).
"""
import itertools
import random
import sys
from functools import lru_cache

import kcore as K

sys.setrecursionlimit(100000)
SEED = 4711
rng = random.Random(SEED)
out = []

H = 9
ATOM = ('rel', 'a', ())
CONST = ('fn', 'c', ())


def P(t):
    return ('rel', 'P', (t,))


# ---------------------------------------------------------------- Part A: canonical formulas of size <= H

@lru_cache(None)
def terms(depth, nxt):
    res = [(CONST, nxt)]
    res += [(('idx', i), nxt) for i in range(depth)]
    res += [(('par', j), nxt) for j in range(nxt)] + [(('par', nxt), nxt + 1)]
    return tuple(res)


@lru_cache(None)
def forms(n, depth, nxt):
    """Canonical formulas of size exactly n at binder depth `depth` whose new parameters start at nxt."""
    res = []
    if n == 1:
        res.append((ATOM, nxt))
    if n == 2:
        for t, k in terms(depth, nxt):
            res.append((P(t), k))
    if n == 3:
        for t1, k1 in terms(depth, nxt):
            for t2, k2 in terms(depth, k1):
                res.append((('eq', t1, t2), k2))
    if n >= 2:
        for f, k in forms(n - 1, depth, nxt):
            res.append((('not', f), k))
        for f, k in forms(n - 1, depth + 1, nxt):
            res.append((('all', f), k))
    for a in range(1, n - 1):
        for f1, k1 in forms(a, depth, nxt):
            for f2, k2 in forms(n - 1 - a, depth, k1):
                res.append((('imp', f1, f2), k2))
    return tuple(res)


def all_canonical(Hmax):
    res = []
    for n in range(1, Hmax + 1):
        res += [f for f, _ in forms(n, 0, 0)]
    return res


def closure(NL, Hmax):
    universe = all_canonical(Hmax)
    for f in universe:
        assert K.canon(f)[0] == f
    S = {}
    for f in universe:
        if K.is_logical(f) or f in NL:
            S[f] = ('ax',)
    changed = True
    rounds = 0
    while changed:
        changed = False
        rounds += 1
        for X in list(S):
            if X[0] == 'imp':
                A, B = X[1], X[2]
                if K.canon(A)[0] in S:
                    cB = K.canon(B)[0]
                    if cB not in S:
                        S[cB] = ('mp', X)
                        changed = True
            ps = K.params(X)
            fresh = max(ps) + 1 if ps else 0
            for p in ps + [fresh]:
                g = K.gen(X, p)
                if K.size(g) <= Hmax:
                    cg = K.canon(g)[0]
                    if cg not in S:
                        S[cg] = ('gen', X, p)
                        changed = True
    return S, len(universe), rounds


def all_params_in(lines):
    """Parameters of the lines and of the Gen justifications (a vacuous Gen names a parameter no line contains)."""
    ps = set()
    for f, j in lines:
        ps |= set(K.params(f))
        if j[0] == 'gen':
            ps.add(j[2])
    return ps


def rename_derivation(lines, rho):
    """Apply a parameter map (must be injective on the parameters of the derivation)."""
    res = []
    for f, j in lines:
        if j[0] == 'gen':
            j = ('gen', j[1], rho.get(j[2], j[2]))
        res.append((K.rename(f, rho), j))
    return res


def extend_bijection(rho, used, avoid):
    """Extend rho (partial injective map) to all of `used`, mapping the rest to fresh numbers not in avoid/range."""
    rho = dict(rho)
    taken = set(rho.values()) | set(avoid)
    nxt = max(list(taken) + list(used) + [0]) + 1
    for p in sorted(used):
        if p not in rho:
            while nxt in taken:
                nxt += 1
            rho[p] = nxt
            taken.add(nxt)
    return rho


def shift(lines, off):
    res = []
    for f, j in lines:
        if j[0] == 'mp':
            j = ('mp', j[1] + off, j[2] + off)
        elif j[0] == 'gen':
            j = ('gen', j[1] + off, j[2])
        res.append((f, j))
    return res


def rebuild(Y, S, memo):
    """An explicit derivation whose last line is the canonical formula Y."""
    if Y in memo:
        return memo[Y]
    j = S[Y]
    if j[0] == 'ax':
        d = [(Y, ('ax',))]
    elif j[0] == 'mp':
        X = j[1]
        dX = rebuild(X, S, memo)
        A, B = X[1], X[2]
        cA, rhoA = K.canon(A)            # rhoA: params of A -> canonical numbers
        dA = rebuild(cA, S, memo)
        inv = {v: k for k, v in rhoA.items()}  # canonical numbers -> params of A
        rho = extend_bijection(inv, all_params_in(dA), all_params_in(dX))
        dA = rename_derivation(dA, rho)
        assert dA[-1][0] == A
        d = dX + shift(dA, len(dX))
        d.append((B, ('mp', len(d) - 1, len(dX) - 1)))
    else:
        X, p = j[1], j[2]
        dX = rebuild(X, S, memo)
        d = dX + [(K.gen(X, p), ('gen', len(dX) - 1, p))]
    last = d[-1][0]
    cl, rho = K.canon(last)
    assert cl == Y
    rho = extend_bijection(rho, all_params_in(d), [])
    d = rename_derivation(d, rho)
    assert d[-1][0] == Y
    memo[Y] = d
    return d


def random_small_derivation(NL, steps, Hmax):
    lines = []
    index = {}

    def add(f, j):
        if K.size(f) > Hmax or not K.closed(f):
            return None
        lines.append((f, j))
        index.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    def small_formula(n_max, depth=0):
        cands = [f for n in range(1, n_max + 1) for f, _ in forms(n, depth, 0)]
        f = rng.choice(cands)
        # random parameter renaming, so that derivations are not all canonical
        ps = K.params(f)
        rho = {p: rng.randrange(5) for p in ps}
        if len(set(rho.values())) < len(rho):
            rho = {p: i for i, p in enumerate(ps)}
        return K.rename(f, rho)

    for _ in range(steps):
        r = rng.random()
        if not lines or r < 0.12:
            add(rng.choice(sorted(NL)), ('ax',))
        elif r < 0.17:
            add(K.REFL, ('ax',))
        elif r < 0.37:  # A1 with a short existing line or a random one
            B = lines[rng.randrange(len(lines))][0] if rng.random() < 0.5 else small_formula(3)
            C = small_formula(max(1, Hmax - 2 - 2 * K.size(B)))
            k = add(K.imp(B, K.imp(C, B)), ('ax',))
            if k is not None and B in index:
                add(K.imp(C, B), ('mp', index[B], k))
        elif r < 0.5:  # A4
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all']
            if cand:
                i = rng.choice(cand)
                t = rng.choice([CONST, ('par', rng.randrange(5))])
                k = add(K.imp(lines[i][0], K.instantiate(lines[i][0][1], t)), ('ax',))
                if k is not None:
                    add(lines[k][0][2], ('mp', i, k))
        elif r < 0.58:  # A5
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all' and f[1][0] == 'imp' and K.closed(f[1][1])]
            if cand:
                i = rng.choice(cand)
                B, C = lines[i][0][1][1], lines[i][0][1][2]
                k = add(K.imp(lines[i][0], K.imp(B, ('all', C))), ('ax',))
                if k is not None:
                    add(lines[k][0][2], ('mp', i, k))
        elif r < 0.62:  # substitutivity with p = p (from A4 on reflexivity)
            p = rng.randrange(5)
            eq = ('eq', ('par', p), ('par', p))
            B = small_formula(2)
            add(K.imp(eq, K.imp(B, B)), ('ax',))
        elif r < 0.82:  # Gen
            i = rng.randrange(len(lines))
            f = lines[i][0]
            ps = K.params(f)
            p = rng.choice(ps) if ps and rng.random() < 0.8 else rng.randrange(5)
            add(K.gen(f, p), ('gen', i, p))
        else:  # MP on any available pair
            pairs = [(index[f[1]], n) for n, (f, _) in enumerate(lines) if f[0] == 'imp' and f[1] in index]
            if pairs:
                i, k = rng.choice(pairs)
                add(lines[k][0][2], ('mp', i, k))
    return lines


def part_A():
    out.append(f"Part A: canonical closure, language {{a/0, P/1, c, =}}, H = {H}")
    NL = {P(CONST), K.imp(ATOM, ('all', P(('idx', 0))))}
    S, nuni, rounds = closure(NL, H)
    bound = (4 + 2 * H + 4) ** (H + 1)
    out.append(f"  canonical formulas of size <= H: {nuni} (bound (|Sigma| + 2H + 4)^(H+1) = {bound:.3e})")
    out.append(f"  closure: {len(S)} members after {rounds} rounds "
               f"({sum(1 for v in S.values() if v[0] == 'ax')} axiom instances, "
               f"{sum(1 for v in S.values() if v[0] == 'mp')} by MP, {sum(1 for v in S.values() if v[0] == 'gen')} by Gen)")
    # soundness
    memo = {}
    bad = 0
    maxlen = 0
    for Y in S:
        d = rebuild(Y, S, memo)
        ok, _ = K.check_derivation(d, lambda f: f in NL)
        if not ok or d[-1][0] != Y or max(K.size(f) for f, _ in d) > H:
            bad += 1
        maxlen = max(maxlen, len(d))
    out.append(f"  soundness: rebuilt derivations failing validation / size <= H / last line: {bad} of {len(S)} "
               f"(longest rebuilt derivation: {maxlen} lines)")
    # completeness against random derivations
    nder, nlines, missing = 400, 0, 0
    for _ in range(nder):
        d = random_small_derivation(NL, 40, H)
        ok, b = K.check_derivation(d, lambda f: f in NL)
        assert ok, b
        for f, _ in d:
            nlines += 1
            if K.canon(f)[0] not in S:
                missing += 1
    out.append(f"  completeness: {nder} random derivations with all lines <= H, {nlines} lines; "
               f"canonical form missing from the closure: {missing}")
    # renaming invariance on the random derivations
    inv_bad = 0
    for _ in range(100):
        d = random_small_derivation(NL, 30, H)
        ps = sorted(all_params_in(d))
        perm = ps[:]
        rng.shuffle(perm)
        rho = {p: q + 100 for p, q in zip(ps, perm)}
        d2 = rename_derivation(d, rho)
        ok, _ = K.check_derivation(d2, lambda f: f in NL)
        inv_bad += 0 if ok else 1
    out.append(f"  bijective renaming of 100 random derivations: invalid after renaming: {inv_bad}")
    # a non-injective renaming can break Gen
    f0 = ('eq', ('par', 0), ('par', 1))
    lines = [(K.imp(ATOM, K.imp(f0, ATOM)), ('ax',))]
    g = K.gen(lines[0][0], 0)
    lines.append((g, ('gen', 0, 0)))
    d2 = rename_derivation(lines, {1: 0})
    ok2, _ = K.check_derivation(d2, lambda f: False)
    out.append(f"  non-injective renaming p1 -> p0 of a Gen step on p0 (premise with p0, p1): valid afterwards = {ok2}"
               f" (expected False)")
    return bad == 0 and missing == 0 and inv_bad == 0 and not ok2


# ---------------------------------------------------------------- Part B: counter

def word(bits):
    t = ('fn', 'e', ())
    for b in reversed(bits):
        t = ('fn', 's' + str(b), (t,))
    return t


def Cw(bits):
    return ('rel', 'C', (word(bits),))


def part_B():
    out.append("Part B: k-bit counter, ground axioms C(t_v) -> C(t_{v+1}), start C(t_0...0)")
    out.append(f"{'k':>4} {'lines':>8} {'MP steps':>9} {'max instance':>13} {'2k+5':>6} {'size':>10} {'valid':>6}")
    allok = True
    for k in (2, 4, 6, 8, 10):
        def member(f):
            if f == Cw([0] * k):
                return True
            if f[0] != 'imp' or f[1][0] != 'rel' or f[2][0] != 'rel':
                return False
            u, v = decode(f[1]), decode(f[2])
            return u is not None and v is not None and len(u) == len(v) == k and \
                int(''.join(map(str, v)), 2) == int(''.join(map(str, u)), 2) + 1

        def decode(atom):
            if atom[1] != 'C':
                return None
            t, bits = atom[2][0], []
            while t[1] != 'e':
                bits.append(int(t[1][1]))
                t = t[2][0]
            return bits
        lines = [(Cw([0] * k), ('ax',))]
        cur = 0
        maxinst = K.size(lines[0][0])
        for v in range(2 ** k - 1):
            u = [int(x) for x in format(v, f'0{k}b')]
            w = [int(x) for x in format(v + 1, f'0{k}b')]
            ax = K.imp(Cw(u), Cw(w))
            maxinst = max(maxinst, K.size(ax))
            lines.append((ax, ('ax',)))
            lines.append((Cw(w), ('mp', cur, len(lines) - 1)))
            cur = len(lines) - 1
        ok, _ = K.check_derivation(lines, member)
        allok &= ok and lines[-1][0] == Cw([1] * k) and maxinst == 2 * k + 5
        out.append(f"{k:>4} {len(lines):>8} {2 ** k - 1:>9} {maxinst:>13} {2 * k + 5:>6} "
                   f"{K.derivation_size(lines):>10} {str(ok):>6}")
    return allok


# ---------------------------------------------------------------- Part C: QBF by alternating ground axioms

def part_C():
    out.append("Part C: QBF evaluation by ground axioms (universal nodes: two premises), dual predicate C' for false")
    out.append(f"{'n':>3} {'#QBF':>5} {'agree':>6} {'max lines':>10} {'max instance':>13} {'valid':>6}")
    allok = True
    for n in (2, 4, 6, 8):
        agree, maxlines, maxinst, valid = 0, 0, 0, True
        NQ = 20
        for _ in range(NQ):
            quants = [rng.choice('EA') for _ in range(n)]
            clauses = [[(rng.randrange(n), rng.random() < 0.5) for _ in range(3)] for _ in range(n + 1)]

            def psi(u):
                return all(any(u[v] == (1 if pos else 0) for v, pos in cl) for cl in clauses)

            def value(u):
                if len(u) == n:
                    return psi(u)
                a, b = value(u + [0]), value(u + [1])
                return (a or b) if quants[len(u)] == 'E' else (a and b)

            def A(u, pos):
                return ('rel', 'C' if pos else "C'", (word(u),))

            def member(f):
                # leaf facts
                if f[0] == 'rel':
                    u = dec(f[2][0])
                    return u is not None and len(u) == n and psi(u) == (f[1] == 'C')
                if f[0] != 'imp':
                    return False
                prem = [f[1]]
                g = f[2]
                if g[0] == 'imp':
                    prem.append(g[1])
                    g = g[2]
                if g[0] != 'rel' or any(x[0] != 'rel' or x[1] != g[1] for x in prem):
                    return False
                u = dec(g[2][0])
                if u is None or len(u) >= n:
                    return False
                kids = [dec(x[2][0]) for x in prem]
                pos = (g[1] == 'C')
                one_needed = (quants[len(u)] == 'E') == pos
                if one_needed:
                    return len(kids) == 1 and kids[0] in (u + [0], u + [1])
                return len(kids) == 2 and kids == [u + [0], u + [1]]

            def dec(t):
                bits = []
                while t[1] != 'e':
                    if t[1] not in ('s0', 's1'):
                        return None
                    bits.append(int(t[1][1]))
                    t = t[2][0]
                return bits

            lines = []

            def derive(u):
                """Derive C(t_u) or C'(t_u), whichever holds; returns the line index."""
                val = value(u)
                if len(u) == n:
                    lines.append((A(u, val), ('ax',)))
                    return len(lines) - 1
                one_needed = (quants[len(u)] == 'E') == val
                if one_needed:
                    kid = u + [0] if value(u + [0]) == val else u + [1]
                    i = derive(kid)
                    lines.append((K.imp(A(kid, val), A(u, val)), ('ax',)))
                    lines.append((A(u, val), ('mp', i, len(lines) - 1)))
                    return len(lines) - 1
                i0 = derive(u + [0])
                i1 = derive(u + [1])
                ax = K.imp(A(u + [0], val), K.imp(A(u + [1], val), A(u, val)))
                lines.append((ax, ('ax',)))
                lines.append((ax[2], ('mp', i0, len(lines) - 1)))
                lines.append((A(u, val), ('mp', i1, len(lines) - 1)))
                return len(lines) - 1
            derive([])
            ok, _ = K.check_derivation(lines, member)
            valid &= ok
            agree += 1 if lines[-1][0] == A([], value([])) else 0
            maxlines = max(maxlines, len(lines))
            maxinst = max(maxinst, max(K.size(f) for f, j in lines if j[0] == 'ax'))
        allok &= valid and agree == NQ
        out.append(f"{n:>3} {NQ:>5} {agree:>6} {maxlines:>10} {maxinst:>13} {str(valid):>6}")
    return allok


if __name__ == '__main__':
    out.append(f"c3_short_axioms  (seed {SEED})")
    okA = part_A()
    out.append("")
    okB = part_B()
    out.append("")
    okC = part_C()
    out.append("")
    out.append(f"verdict: {'all checks pass' if okA and okB and okC else 'FAILURE'}")
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
