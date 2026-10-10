"""c6: parameter indices without the renaming hypothesis (F1) (short-derivations/notes-final.md, §7: Lemma 7.2
(truncation), Lemma 7.3 (class closure), Prop 7.1 (the channel)). Written for the revision after referee-logic M1 and
referee-complexity M3.

Conventions (notes-final §1.1, §2.4). A formula is written as a string of cells: its preorder tokens, one cell each,
except that a parameter p_N is the cell 'p', then the bits of bin(N + 1) (leading 1), one cell each, then ';'
(indices #k likewise with '#'). Node size |chi| counts a parameter as one node whatever N is. A decider "with read
bound K" is any function of the first K cells of the string; a machine that halts within K steps is one (its input
head moves at most one cell per step).

Part A (Lemma 7.2, truncation). A decider Dec_K that reads only the first K cells and accepts some formulas of the
  shapes P(p_N) and P(p_N) -> B. Random K-derivations using such axioms with long parameter indices (up to 40 bits),
  A1, A4 (with long parameters substituted), substitutivity, MP and Gen (vacuous Gens included). The truncation
  renaming rho keeps every index with at most K bits and maps a longer one to (its first K bits) 1 (serial, w bits).
  Checked: rho is injective; on every nonlogical axiom line the first K cells are unchanged; rho(pi) is a valid
  K-derivation for the same decider; every index of rho(pi) has at most K + 1 + w bits. Control: the naive renaming to
  p_0, p_1, ... (canonical form) changes membership of some axiom lines.
Part B (Lemma 7.3, class closure). Index classes: an index with at most k0 bits is "short" and forms its own class;
  a longer one is in the class of its first k0 bits. can~ keeps short parameters and renames long ones, in order of
  first occurrence, to (class prefix) 1 (serial). Ax := {chi : can~(chi) in NL} for a fixed set NL of class-canonical
  formulas: closed under class-preserving injective renamings, not under all permutations. The closure of Lemma 7.3
  (axioms, MP and Gen on class-canonical forms of size <= H) is computed and checked for soundness (every member gets
  an explicit derivation, rebuilt with class-preserving renamings and validated by kcore with all lines <= H) and
  completeness (every line of random derivations with long indices has its class-canonical form in the closure).
  Control: plain canonicalisation (Lemma 4.1) does not preserve membership in this Ax.
"""
import random
import sys
from functools import lru_cache

import kcore as K

sys.setrecursionlimit(100000)
SEED = 6061
rng = random.Random(SEED)
out = []

ATOM = ('rel', 'a', ())
CONST = ('fn', 'c', ())


def P(t):
    return ('rel', 'P', (t,))


# ---------------------------------------------------------------- the cell encoding

def bits(n):
    return bin(n + 1)[2:]


def enc(x):
    k = x[0]
    if k == 'par':
        return ['p'] + list(bits(x[1])) + [';']
    if k == 'idx':
        return ['#'] + list(bits(x[1])) + [';']
    if k in ('fn', 'rel'):
        res = [x[1]]
        for a in x[2]:
            res += enc(a)
        return res
    if k == 'eq':
        return ['='] + enc(x[1]) + enc(x[2])
    if k in ('not', 'all'):
        return [k] + enc(x[1])
    if k == 'imp':
        return ['imp'] + enc(x[1]) + enc(x[2])
    raise ValueError(x)


def num_from_bits(s):
    return int(s, 2) - 1


# ---------------------------------------------------------------- Part A: truncation

KA = 6  # read bound of the decider in Part A


def dec_A(f, K_=KA):
    """Reads only the first K_ cells: accepts P(p_N) and P(p_N) -> B when a hash of the visible prefix is even."""
    s = tuple(enc(f)[:K_])
    if s[:2] == ('P', 'p') or s[:3] == ('imp', 'P', 'p'):
        h = 0
        for c in s:
            h = (h * 131 + sum(map(ord, c))) % 1000003
        return h % 2 == 0
    return False


def rand_long_index(lo=8, hi=40):
    L = rng.randint(lo, hi)
    b = '1' + ''.join(rng.choice('01') for _ in range(L - 1))
    return num_from_bits(b)


def rand_index():
    return rng.choice([rng.randrange(6), rand_long_index(), rand_long_index(3, 7)])


def small_body():
    r = rng.random()
    if r < 0.3:
        return ATOM
    if r < 0.6:
        return P(rng.choice([CONST, ('par', rand_index())]))
    if r < 0.8:
        return ('eq', ('par', rand_index()), rng.choice([CONST, ('par', rand_index())]))
    return K.imp(ATOM, P(('par', rand_index())))


def accepted_axiom():
    for _ in range(1000):
        N = rand_index()
        f = P(('par', N)) if rng.random() < 0.5 else K.imp(P(('par', N)), small_body())
        if dec_A(f):
            return f
    return None


def random_derivation_A(steps):
    lines, index = [], {}

    def add(f, j):
        if not K.closed(f) or K.size(f) > 30:
            return None
        lines.append((f, j))
        index.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    for _ in range(steps):
        r = rng.random()
        if not lines or r < 0.25:
            f = accepted_axiom()
            if f is not None:
                add(f, ('ax',))
        elif r < 0.35:  # A1 with an existing line
            B = lines[rng.randrange(len(lines))][0]
            C = small_body()
            k = add(K.imp(B, K.imp(C, B)), ('ax',))
            if k is not None:
                add(K.imp(C, B), ('mp', index[B], k))
        elif r < 0.5:  # A4 with a parameter term (long or short)
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all']
            if cand:
                i = rng.choice(cand)
                t = ('par', rand_index())
                k = add(K.imp(lines[i][0], K.instantiate(lines[i][0][1], t)), ('ax',))
                if k is not None:
                    add(lines[k][0][2], ('mp', i, k))
        elif r < 0.58:  # substitutivity
            p, q = rand_index(), rand_index()
            B = P(('par', p))
            add(K.imp(('eq', ('par', p), ('par', q)), K.imp(B, P(('par', q)))), ('ax',))
        elif r < 0.8:  # Gen, sometimes vacuous with a long parameter
            i = rng.randrange(len(lines))
            f = lines[i][0]
            ps = K.params(f)
            p = rng.choice(ps) if ps and rng.random() < 0.75 else rand_index()
            add(K.gen(f, p), ('gen', i, p))
        else:  # MP
            pairs = [(index[f[1]], n) for n, (f, _) in enumerate(lines) if f[0] == 'imp' and f[1] in index]
            if pairs:
                i, k = rng.choice(pairs)
                add(lines[k][0][2], ('mp', i, k))
    return lines


def all_params_in(lines):
    ps = set()
    for f, j in lines:
        ps |= set(K.params(f))
        if j[0] == 'gen':
            ps.add(j[2])
    return ps


def rename_derivation(lines, rho):
    res = []
    for f, j in lines:
        if j[0] == 'gen':
            j = ('gen', j[1], rho.get(j[2], j[2]))
        res.append((K.rename(f, rho), j))
    return res


def truncation(lines, Kb):
    """The renaming of Lemma 7.2: indices with more than Kb bits -> first Kb bits, '1', serial in w bits."""
    ps = sorted(all_params_in(lines))
    longs = [p for p in ps if len(bits(p)) > Kb]
    w = max(1, (len(longs)).bit_length())
    rho = {}
    for j, p in enumerate(longs):
        rho[p] = num_from_bits(bits(p)[:Kb] + '1' + format(j, f'0{w}b'))
    return rho, w


def part_A():
    out.append(f"Part A (Lemma 7.2, truncation): decider with read bound K = {KA} cells; long indices up to 40 bits")
    nder, nlines, nax_nl, bad_valid, bad_inj, bad_prefix, bad_valid_after, max_bits_after, bound_bad = \
        300, 0, 0, 0, 0, 0, 0, 0, 0
    naive_changed, naive_total, max_bits_before = 0, 0, 0
    for _ in range(nder):
        d = random_derivation_A(45)
        ok, _ = K.check_derivation(d, dec_A)
        bad_valid += 0 if ok else 1
        nlines += len(d)
        rho, w = truncation(d, KA)
        ps = all_params_in(d)
        img = [rho.get(p, p) for p in ps]
        bad_inj += 0 if len(set(img)) == len(img) else 1
        max_bits_before = max([max_bits_before] + [len(bits(p)) for p in ps])
        for f, j in d:
            if j[0] == 'ax' and not K.is_logical(f):
                nax_nl += 1
                if enc(f)[:KA] != enc(K.rename(f, rho))[:KA]:
                    bad_prefix += 1
        d2 = rename_derivation(d, rho)
        ok2, _ = K.check_derivation(d2, dec_A)
        bad_valid_after += 0 if ok2 else 1
        mb = max([0] + [len(bits(p)) for p in all_params_in(d2)])
        max_bits_after = max(max_bits_after, mb)
        bound_bad += 0 if mb <= max(KA + 1 + w, KA) else 1
        # control: naive canonical renaming to small indices
        ren = {p: i for i, p in enumerate(sorted(ps))}
        for f, j in d:
            if j[0] == 'ax' and not K.is_logical(f):
                naive_total += 1
                naive_changed += dec_A(K.rename(f, ren)) != dec_A(f)
    out.append(f"  {nder} random derivations, {nlines} lines, {nax_nl} nonlogical axiom lines; "
               f"invalid before renaming: {bad_valid}")
    out.append(f"  truncation renaming: not injective: {bad_inj}; first K cells changed on a nonlogical axiom line: "
               f"{bad_prefix}; invalid after renaming: {bad_valid_after}; index bound K + 1 + w violated: {bound_bad}")
    out.append(f"  largest index length (bits): before {max_bits_before}, after {max_bits_after}")
    out.append(f"  control, naive renaming to p_0, p_1, ...: membership changed on {naive_changed} of {naive_total} "
               f"nonlogical axiom lines")
    return bad_valid == 0 and bad_inj == 0 and bad_prefix == 0 and bad_valid_after == 0 and bound_bad == 0 \
        and naive_changed > 0


# ---------------------------------------------------------------- Part B: class closure

H = 8
K0 = 2           # an index with at most K0 bits is short
SHORT = [n for n in range(2 ** (K0 + 1)) if len(bits(n)) <= K0]   # 0, 1, 2
CLASSES = ['10', '11']
W = max(1, (H - 1).bit_length())


def is_short(n):
    return len(bits(n)) <= K0


def cls(n):
    return None if is_short(n) else bits(n)[:K0]


def long_name(c, j):
    return num_from_bits(c + '1' + format(j, f'0{W}b'))


def canon_cls(x):
    """can~: short parameters fixed; long parameters renamed in order of first occurrence to (class, serial)."""
    ps = K.params(x)
    rho, j = {}, 0
    for p in ps:
        if not is_short(p):
            rho[p] = long_name(cls(p), j)
            j += 1
    return K.rename(x, rho), rho


@lru_cache(None)
def terms(depth, longs):
    """Class-canonical terms; `longs` = tuple of the classes of the long parameters introduced so far."""
    res = [(CONST, longs)]
    res += [(('idx', i), longs) for i in range(depth)]
    res += [(('par', n), longs) for n in SHORT]
    res += [(('par', long_name(c, j)), longs) for j, c in enumerate(longs)]
    res += [(('par', long_name(c, len(longs))), longs + (c,)) for c in CLASSES]
    return tuple(res)


@lru_cache(None)
def forms(n, depth, longs):
    res = []
    if n == 1:
        res.append((ATOM, longs))
    if n == 2:
        for t, k in terms(depth, longs):
            res.append((P(t), k))
    if n == 3:
        for t1, k1 in terms(depth, longs):
            for t2, k2 in terms(depth, k1):
                res.append((('eq', t1, t2), k2))
    if n >= 2:
        for f, k in forms(n - 1, depth, longs):
            res.append((('not', f), k))
        for f, k in forms(n - 1, depth + 1, longs):
            res.append((('all', f), k))
    for a in range(1, n - 1):
        for f1, k1 in forms(a, depth, longs):
            for f2, k2 in forms(n - 1 - a, depth, k1):
                res.append((('imp', f1, f2), k2))
    return tuple(res)


L10_0 = ('par', long_name('10', 0))
L11_0 = ('par', long_name('11', 0))
L10_1 = ('par', long_name('10', 1))
NL = {
    P(('par', 1)),                                   # P(p_1): p_1 is short; P(p_0) is not an axiom
    P(L10_0),                                        # P(long index of class 10); class 11 is not an axiom
    K.imp(P(L11_0), ATOM),                           # P(p) -> a for class 11 only
    K.imp(ATOM, ('all', P(('idx', 0)))),
    K.imp(P(L10_0), P(L10_1)),                       # two distinct long parameters of class 10
}


def ax_B(f):
    return canon_cls(f)[0] in NL


def closure_B():
    universe = []
    for n in range(1, H + 1):
        universe += [f for f, _ in forms(n, 0, ())]
    for f in universe:
        assert canon_cls(f)[0] == f
    S = {}
    for f in universe:
        if K.is_logical(f) or f in NL:
            S[f] = ('ax',)
    changed, rounds = True, 0
    while changed:
        changed, rounds = False, rounds + 1
        for X in list(S):
            if X[0] == 'imp':
                A, B = X[1], X[2]
                if canon_cls(A)[0] in S:
                    cB = canon_cls(B)[0]
                    if cB not in S:
                        S[cB] = ('mp', X)
                        changed = True
            ps = K.params(X)
            for p in ps + ['fresh']:
                g = K.gen(X, p if p != 'fresh' else 10 ** 6)
                if K.size(g) <= H:
                    cg = canon_cls(g)[0]
                    if cg not in S:
                        S[cg] = ('gen', X, p if p != 'fresh' else 10 ** 6)
                        changed = True
    return S, len(universe), rounds


def fresh_long_like(c, taken):
    while True:
        n = num_from_bits(c + format(rng.getrandbits(12), '012b') + '1')
        if n not in taken:
            return n


def class_bijection(partial, used, taken):
    """Extend a class-preserving partial injective map to `used`: short -> itself, long -> fresh long, same class."""
    rho = dict(partial)
    taken = set(taken) | set(rho.values())
    for p in sorted(used):
        if p in rho:
            continue
        if is_short(p):
            rho[p] = p
        else:
            q = fresh_long_like(cls(p), taken)
            rho[p] = q
            taken.add(q)
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
    if Y in memo:
        return memo[Y]
    j = S[Y]
    if j[0] == 'ax':
        d = [(Y, ('ax',))]
    elif j[0] == 'mp':
        X = j[1]
        dX = rebuild(X, S, memo)
        A, B = X[1], X[2]
        cA, rhoA = canon_cls(A)
        dA = rebuild(cA, S, memo)
        inv = {v: k for k, v in rhoA.items()}
        for p in K.params(cA):
            inv.setdefault(p, p)          # short parameters are fixed
        rho = class_bijection(inv, all_params_in(dA), set(inv.values()) | all_params_in(dX))
        dA = rename_derivation(dA, rho)
        assert dA[-1][0] == A
        d = dX + shift(dA, len(dX))
        d.append((B, ('mp', len(d) - 1, len(dX) - 1)))
    else:
        X, p = j[1], j[2]
        dX = rebuild(X, S, memo)
        d = dX + [(K.gen(X, p), ('gen', len(dX) - 1, p))]
    last = d[-1][0]
    cl, rho = canon_cls(last)
    assert cl == Y
    for p in K.params(last):
        rho.setdefault(p, p)
    rho = class_bijection(rho, all_params_in(d), set(rho.values()))
    d = rename_derivation(d, rho)
    assert d[-1][0] == Y
    memo[Y] = d
    return d


def rand_param_B():
    r = rng.random()
    if r < 0.4:
        return rng.choice(SHORT)
    return fresh_long_like(rng.choice(CLASSES), set())


def raw_from(f):
    """A random class-preserving injective renaming of f (long parameters get random long indices)."""
    rho = class_bijection({}, K.params(f), set())
    return K.rename(f, rho)


def random_derivation_B(steps):
    lines, index = [], {}

    def add(f, j):
        if K.size(f) > H or not K.closed(f):
            return None
        lines.append((f, j))
        index.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    def small(nmax, depth=0):
        cands = [f for n in range(1, nmax + 1) for f, _ in forms(n, depth, ())]
        return raw_from(rng.choice(cands))

    for _ in range(steps):
        r = rng.random()
        if not lines or r < 0.15:
            add(raw_from(rng.choice(sorted(NL))), ('ax',))
        elif r < 0.2:
            add(K.REFL, ('ax',))
        elif r < 0.38:
            B = lines[rng.randrange(len(lines))][0] if rng.random() < 0.5 else small(3)
            C = small(max(1, H - 2 - 2 * K.size(B)))
            k = add(K.imp(B, K.imp(C, B)), ('ax',))
            if k is not None and B in index:
                add(K.imp(C, B), ('mp', index[B], k))
        elif r < 0.5:
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all']
            if cand:
                i = rng.choice(cand)
                t = rng.choice([CONST, ('par', rand_param_B())])
                k = add(K.imp(lines[i][0], K.instantiate(lines[i][0][1], t)), ('ax',))
                if k is not None:
                    add(lines[k][0][2], ('mp', i, k))
        elif r < 0.57:
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all' and f[1][0] == 'imp' and K.closed(f[1][1])]
            if cand:
                i = rng.choice(cand)
                B, C = lines[i][0][1][1], lines[i][0][1][2]
                k = add(K.imp(lines[i][0], K.imp(B, ('all', C))), ('ax',))
                if k is not None:
                    add(lines[k][0][2], ('mp', i, k))
        elif r < 0.62:
            p = rand_param_B()
            q = rand_param_B()
            add(K.imp(('eq', ('par', p), ('par', q)), K.imp(P(('par', p)), P(('par', q)))), ('ax',))
        elif r < 0.82:
            i = rng.randrange(len(lines))
            f = lines[i][0]
            ps = K.params(f)
            p = rng.choice(ps) if ps and rng.random() < 0.8 else rand_param_B()
            add(K.gen(f, p), ('gen', i, p))
        else:
            pairs = [(index[f[1]], n) for n, (f, _) in enumerate(lines) if f[0] == 'imp' and f[1] in index]
            if pairs:
                i, k = rng.choice(pairs)
                add(lines[k][0][2], ('mp', i, k))
    return lines


def part_B():
    out.append(f"Part B (Lemma 7.3, class closure): language {{a/0, P/1, c, =}}, H = {H}, short indices: at most "
               f"{K0} bits ({SHORT}), long classes {CLASSES}")
    S, nuni, rounds = closure_B()
    tokens = 4 + 2 * H + len(SHORT) + len(CLASSES) * H
    out.append(f"  class-canonical formulas of size <= H: {nuni} (count bound (tokens)^(H+1) with tokens = |Sigma| + 2H"
               f" + #short + #classes*H = {tokens}: {tokens ** (H + 1):.3e})")
    out.append(f"  closure: {len(S)} members after {rounds} rounds "
               f"({sum(1 for v in S.values() if v[0] == 'ax')} axiom instances, "
               f"{sum(1 for v in S.values() if v[0] == 'mp')} by MP, {sum(1 for v in S.values() if v[0] == 'gen')} by Gen)")
    memo, bad, maxlen = {}, 0, 0
    for Y in S:
        d = rebuild(Y, S, memo)
        ok, _ = K.check_derivation(d, ax_B)
        if not ok or d[-1][0] != Y or max(K.size(f) for f, _ in d) > H:
            bad += 1
        maxlen = max(maxlen, len(d))
    out.append(f"  soundness: rebuilt derivations (class-preserving renamings) failing validation, size <= H or last "
               f"line: {bad} of {len(S)} (longest: {maxlen} lines)")
    nder, nlines, missing, invalid = 400, 0, 0, 0
    maxbits = 0
    for _ in range(nder):
        d = random_derivation_B(40)
        ok, _ = K.check_derivation(d, ax_B)
        invalid += 0 if ok else 1
        for f, _ in d:
            nlines += 1
            maxbits = max([maxbits] + [len(bits(p)) for p in K.params(f)])
            if canon_cls(f)[0] not in S:
                missing += 1
    out.append(f"  completeness: {nder} random derivations (raw long indices up to {maxbits} bits), {nlines} lines, "
               f"invalid: {invalid}; class-canonical form missing from the closure: {missing}")
    # control: plain canonical forms do not preserve membership in this Ax
    tests, changed = 0, 0
    for f in NL:
        for _ in range(50):
            g = raw_from(f)
            tests += 1
            changed += ax_B(K.canon(g)[0]) != ax_B(g)
    out.append(f"  control: membership of chi and of its plain canonical form (Lemma 4.1) differ on {changed} of "
               f"{tests} renamed axioms (Ax is not closed under all permutations)")
    return bad == 0 and missing == 0 and invalid == 0 and changed > 0


def main():
    out.append(f"c6_parameters  (seed {SEED})")
    okA = part_A()
    out.append("")
    okB = part_B()
    out.append("")
    out.append("verdict: " + ("all checks pass" if okA and okB else "FAILURE"))
    with open(__file__[:-3] + '.out', 'w') as fh:
        fh.write("\n".join(out) + "\n")
    print("\n".join(out))


if __name__ == '__main__':
    main()
