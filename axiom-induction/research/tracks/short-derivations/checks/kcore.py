"""kcore: Mendelson's calculus K in the paper's representation, shared by the checks of short-derivations/notes.md.

Representation (paper, model.tex Def "Background calculus"; app-time.tex size convention):
  terms     ('fn', name, (args...))   function symbol or constant (args = ())
            ('idx', k)                 de Bruijn index (k counts binders between the occurrence and its binder)
            ('par', j)                 parameter p_j (a free name, read under universal closure)
  formulas  ('rel', name, (args...)), ('eq', t1, t2), ('not', A), ('imp', A, B), ('all', A)
Size: every node counts one (a quantifier, a connective, a function or relation symbol, '=', a constant, an index
and a parameter each count one).

K: logical axioms A1-A3 (propositional), A4  all B -> B[t] (t index-free, so always free for the variable),
A5  all (B -> C) -> (B -> all C) with B closed (the variable is not free in B), reflexivity  all (0 = 0),
substitutivity  p = q -> (B -> B') with B' from B by replacing some occurrences of the parameter p by q.
Rules: MP (from A and A -> B infer B) and Gen (from F infer all F[x/p], i.e. ('all', abstract(F, p))).
A derivation is a list of (formula, justification) with justification ('ax',), ('mp', i, j) where line j is
(line i -> this line), or ('gen', i, p).
"""

# ---------------------------------------------------------------- syntax


def size(x):
    k = x[0]
    if k in ('idx', 'par'):
        return 1
    if k in ('fn', 'rel'):
        return 1 + sum(size(a) for a in x[2])
    if k == 'eq':
        return 1 + size(x[1]) + size(x[2])
    if k in ('not', 'all'):
        return 1 + size(x[1])
    if k == 'imp':
        return 1 + size(x[1]) + size(x[2])
    raise ValueError(x)


def is_formula(x):
    return x[0] in ('rel', 'eq', 'not', 'imp', 'all')


def children(x):
    """(position, child) pairs; positions are small integers."""
    k = x[0]
    if k in ('fn', 'rel'):
        return list(enumerate(x[2]))
    if k == 'eq':
        return [(0, x[1]), (1, x[2])]
    if k in ('not', 'all'):
        return [(0, x[1])]
    if k == 'imp':
        return [(0, x[1]), (1, x[2])]
    return []


def child(x, pos):
    for p, c in children(x):
        if p == pos:
            return c
    raise KeyError((x[0], pos))


def subtree(x, path):
    for pos in path:
        x = child(x, pos)
    return x


def formula_nodes(x, path=()):
    """All (path, subformula) pairs of formula nodes of x, x included (preorder)."""
    res = [(path, x)]
    k = x[0]
    if k in ('not', 'all'):
        res += formula_nodes(x[1], path + (0,))
    elif k == 'imp':
        res += formula_nodes(x[1], path + (0,)) + formula_nodes(x[2], path + (1,))
    return res


def N_nodes(x):
    return len(formula_nodes(x))


def F_sum(x):
    """F(x) := sum over formula nodes v of x of |x_v|."""
    return sum(size(s) for _, s in formula_nodes(x))


def max_dangling(x, depth=0):
    """Largest k - depth over indices k at binder depth `depth` (negative if none dangle)."""
    k = x[0]
    if k == 'idx':
        return x[1] - depth
    if k == 'par':
        return -1
    if k == 'all':
        return max_dangling(x[1], depth + 1)
    return max([max_dangling(c, depth) for _, c in children(x)] + [-1])


def closed(x):
    return max_dangling(x) < 0


def params(x, acc=None):
    if acc is None:
        acc = []
    if x[0] == 'par':
        if x[1] not in acc:
            acc.append(x[1])
    else:
        for _, c in children(x):
            params(c, acc)
    return acc


def abstract(x, p, base=0, depth=0):
    """Replace the parameter p at binder depth d by the index d + base."""
    k = x[0]
    if k == 'par':
        return ('idx', depth + base) if x[1] == p else x
    if k == 'idx':
        return x
    if k in ('fn', 'rel'):
        return (k, x[1], tuple(abstract(a, p, base, depth) for a in x[2]))
    if k == 'eq':
        return ('eq', abstract(x[1], p, base, depth), abstract(x[2], p, base, depth))
    if k == 'not':
        return ('not', abstract(x[1], p, base, depth))
    if k == 'imp':
        return ('imp', abstract(x[1], p, base, depth), abstract(x[2], p, base, depth))
    if k == 'all':
        return ('all', abstract(x[1], p, base, depth + 1))
    raise ValueError(x)


def gen(x, p):
    return ('all', abstract(x, p))


def instantiate(body, t, depth=0):
    """B[t]: replace the indices that point to the (removed) outer binder by the index-free term t."""
    k = body[0]
    if k == 'idx':
        return t if body[1] == depth else body
    if k == 'par':
        return body
    if k in ('fn', 'rel'):
        return (k, body[1], tuple(instantiate(a, t, depth) for a in body[2]))
    if k == 'eq':
        return ('eq', instantiate(body[1], t, depth), instantiate(body[2], t, depth))
    if k == 'not':
        return ('not', instantiate(body[1], t, depth))
    if k == 'imp':
        return ('imp', instantiate(body[1], t, depth), instantiate(body[2], t, depth))
    if k == 'all':
        return ('all', instantiate(body[1], t, depth + 1))
    raise ValueError(body)


def rename(x, rho):
    """Apply a map on parameter numbers (dict; missing keys fixed)."""
    k = x[0]
    if k == 'par':
        return ('par', rho.get(x[1], x[1]))
    if k == 'idx':
        return x
    if k in ('fn', 'rel'):
        return (k, x[1], tuple(rename(a, rho) for a in x[2]))
    if k == 'eq':
        return ('eq', rename(x[1], rho), rename(x[2], rho))
    if k in ('not', 'all'):
        return (k, rename(x[1], rho))
    if k == 'imp':
        return ('imp', rename(x[1], rho), rename(x[2], rho))
    raise ValueError(x)


def canon(x):
    """Rename parameters to 0, 1, ... in order of first occurrence (preorder). Returns (canonical, map)."""
    ps = params(x)
    rho = {p: i for i, p in enumerate(ps)}
    return rename(x, rho), rho


def show(x):
    k = x[0]
    if k == 'idx':
        return f"#{x[1]}"
    if k == 'par':
        return f"p{x[1]}"
    if k == 'fn':
        return x[1] if not x[2] else f"{x[1]}({','.join(show(a) for a in x[2])})"
    if k == 'rel':
        return x[1] if not x[2] else f"{x[1]}({','.join(show(a) for a in x[2])})"
    if k == 'eq':
        return f"{show(x[1])}={show(x[2])}"
    if k == 'not':
        return f"~{show(x[1])}"
    if k == 'imp':
        return f"({show(x[1])} > {show(x[2])})"
    if k == 'all':
        return f"A.{show(x[1])}"
    raise ValueError(x)


def imp(a, b):
    return ('imp', a, b)


def neg(a):
    return ('not', a)


# ---------------------------------------------------------------- independent axiom recognisers


def is_A1(f):
    return f[0] == 'imp' and f[2][0] == 'imp' and f[2][2] == f[1]


def is_A2(f):
    if f[0] != 'imp' or f[1][0] != 'imp' or f[1][2][0] != 'imp':
        return False
    B, C, D = f[1][1], f[1][2][1], f[1][2][2]
    return f[2] == imp(imp(B, C), imp(B, D))


def is_A3(f):
    if f[0] != 'imp' or f[1][0] != 'imp' or f[1][1][0] != 'not' or f[1][2][0] != 'not':
        return False
    C, B = f[1][1][1], f[1][2][1]
    return f[2] == imp(imp(neg(C), B), C)


def _tmatch(s, s2, depth, acc):
    """s is a subterm of the body B at binder depth `depth` below the A4 quantifier; s2 the corresponding part of
    the consequent. Occurrences of the index pointing to the A4 binder must all map to one index-free term."""
    if s[0] == 'idx' and s[1] == depth:
        if max_dangling(s2) >= 0 or _has_idx(s2):
            return False
        if acc[0] is None:
            acc[0] = s2
            return True
        return acc[0] == s2
    if s[0] != s2[0]:
        return False
    if s[0] in ('idx', 'par'):
        return s == s2
    if s[0] == 'fn':
        return s[1] == s2[1] and len(s[2]) == len(s2[2]) and \
            all(_tmatch(a, b, depth, acc) for a, b in zip(s[2], s2[2]))
    return False


def _has_idx(t):
    if t[0] == 'idx':
        return True
    return any(_has_idx(c) for _, c in children(t))


def _fmatch(f, f2, depth, acc):
    if f[0] != f2[0]:
        return False
    k = f[0]
    if k == 'rel':
        return f[1] == f2[1] and len(f[2]) == len(f2[2]) and \
            all(_tmatch(a, b, depth, acc) for a, b in zip(f[2], f2[2]))
    if k == 'eq':
        return _tmatch(f[1], f2[1], depth, acc) and _tmatch(f[2], f2[2], depth, acc)
    if k == 'not':
        return _fmatch(f[1], f2[1], depth, acc)
    if k == 'imp':
        return _fmatch(f[1], f2[1], depth, acc) and _fmatch(f[2], f2[2], depth, acc)
    if k == 'all':
        return _fmatch(f[1], f2[1], depth + 1, acc)
    return False


def is_A4(f):
    if f[0] != 'imp' or f[1][0] != 'all':
        return False
    B, B2 = f[1][1], f[2]
    acc = [None]
    if not _fmatch(B, B2, 0, acc):
        return False
    if acc[0] is None:  # vacuous quantifier: B has no occurrence of the bound index, B2 must be B itself
        return B == B2 and closed(B2)
    return True


def is_A5(f):
    if f[0] != 'imp' or f[1][0] != 'all' or f[1][1][0] != 'imp' or f[2][0] != 'imp' or f[2][2][0] != 'all':
        return False
    B, C = f[1][1][1], f[1][1][2]
    return closed(B) and f[2][1] == B and f[2][2][1] == C


REFL = ('all', ('eq', ('idx', 0), ('idx', 0)))


def is_refl(f):
    return f == REFL


def _replace_some(x, y, p, q):
    """True iff y arises from x by replacing some occurrences of the parameter p by the parameter q."""
    if x == y:
        return True
    if x == ('par', p) and y == ('par', q):
        return True
    if x[0] != y[0] or x[0] in ('idx', 'par'):
        return False
    if x[0] in ('fn', 'rel'):
        return x[1] == y[1] and len(x[2]) == len(y[2]) and all(_replace_some(a, b, p, q) for a, b in zip(x[2], y[2]))
    cx, cy = children(x), children(y)
    return len(cx) == len(cy) and all(_replace_some(a, b, p, q) for (_, a), (_, b) in zip(cx, cy))


def is_subst(f):
    if f[0] != 'imp' or f[1][0] != 'eq' or f[1][1][0] != 'par' or f[1][2][0] != 'par' or f[2][0] != 'imp':
        return False
    p, q = f[1][1][1], f[1][2][1]
    return _replace_some(f[2][1], f[2][2], p, q)


LOGICAL = (is_A1, is_A2, is_A3, is_A4, is_A5, is_refl, is_subst)


def is_logical(f):
    return any(r(f) for r in LOGICAL)


def check_derivation(lines, nonlogical):
    """nonlogical: a predicate on formulas. Returns (ok, index of the first bad line or None)."""
    for n, (f, j) in enumerate(lines):
        if not is_formula(f) or not closed(f):
            return False, n
        if j[0] == 'ax':
            if not (is_logical(f) or nonlogical(f)):
                return False, n
        elif j[0] == 'mp':
            i, k = j[1], j[2]
            if not (0 <= i < n and 0 <= k < n and lines[k][0] == imp(lines[i][0], f)):
                return False, n
        elif j[0] == 'gen':
            i, p = j[1], j[2]
            if not (0 <= i < n and f == gen(lines[i][0], p)):
                return False, n
        else:
            return False, n
    return True, None


def derivation_size(lines):
    return sum(size(f) for f, _ in lines)


def axiom_instances(lines):
    """I(pi): the distinct formulas of the lines justified as axioms."""
    seen = []
    for f, j in lines:
        if j[0] == 'ax' and f not in seen:
            seen.append(f)
    return seen


# ---------------------------------------------------------------- normalisation (Lemma 1.1 of the notes)


def extract(lines, r):
    need, stack = set(), [r]
    while stack:
        n = stack.pop()
        if n in need:
            continue
        need.add(n)
        j = lines[n][1]
        if j[0] == 'mp':
            stack += [j[1], j[2]]
        elif j[0] == 'gen':
            stack.append(j[1])
    order = sorted(need)
    pos = {o: k for k, o in enumerate(order)}
    res = []
    for o in order:
        f, j = lines[o]
        if j[0] == 'mp':
            j = ('mp', pos[j[1]], pos[j[2]])
        elif j[0] == 'gen':
            j = ('gen', pos[j[1]], j[2])
        res.append((f, j))
    return res


def dedup(lines):
    first, remap, res = {}, {}, []
    for n, (f, j) in enumerate(lines):
        if f in first:
            remap[n] = first[f]
            continue
        if j[0] == 'mp':
            j = ('mp', remap[j[1]], remap[j[2]])
        elif j[0] == 'gen':
            j = ('gen', remap[j[1]], j[2])
        first[f] = len(res)
        remap[n] = len(res)
        res.append((f, j))
    return res


def normalise(lines, phi=None):
    """De-duplicate, cut at the first occurrence of phi (default: the last line's formula), keep its ancestors."""
    if phi is None:
        phi = lines[-1][0]
    d = dedup(lines)
    q = next(n for n, (f, _) in enumerate(d) if f == phi)
    return extract(d, q)


def is_normal(lines):
    fs = [f for f, _ in lines]
    if len(set(fs)) != len(fs):
        return False
    used = set()
    for f, j in lines:
        if j[0] == 'mp':
            used |= {j[1], j[2]}
        elif j[0] == 'gen':
            used.add(j[1])
    return all(n in used for n in range(len(lines) - 1))


# ---------------------------------------------------------------- the prefix code for derivations (notes §5)


def gamma_len(n):
    """Length of the Elias-gamma code of n >= 1."""
    return 2 * (n.bit_length()) - 1


def formula_bits(x, bs):
    """|x|_bit: preorder tokens at bs bits each; IDX/PAR escapes followed by gamma(value + 1)."""
    k = x[0]
    if k in ('idx', 'par'):
        return bs + gamma_len(x[1] + 1)
    return bs + sum(formula_bits(c, bs) for _, c in children(x))


def code_length(lines, bs):
    """|Code(pi)|: per line a 2-bit tag, the justification (gamma codes of the premise line numbers + 1 and, for Gen,
    of the parameter number + 1), the formula; then a 2-bit end tag."""
    total = 0
    for f, j in lines:
        total += 2
        if j[0] == 'mp':
            total += gamma_len(j[1] + 1) + gamma_len(j[2] + 1)
        elif j[0] == 'gen':
            total += gamma_len(j[1] + 1) + gamma_len(j[2] + 1)
        total += formula_bits(f, bs)
    return total + 2
