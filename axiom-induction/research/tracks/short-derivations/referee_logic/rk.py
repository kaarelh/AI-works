"""rk: an independent implementation of Mendelson's calculus K (paper's de Bruijn/parameter syntax) for the referee
checks of short-derivations/notes.md. It does NOT import the notes' checks/kcore.py; recognisers and the A4 test
use different algorithms (A4 here: read the substituted term off the first occurrence, substitute, compare).

Terms     ('c', name, args)  function symbol or constant;  ('i', k) de Bruijn index;  ('p', j) parameter p_j
Formulas  ('R', name, args), ('=', s, t), ('~', A), ('>', A, B), ('A', A)
Size: one per node (paper app-time.tex convention).
"""


def sz(x):
    t = x[0]
    if t in ('i', 'p'):
        return 1
    if t in ('c', 'R'):
        return 1 + sum(sz(a) for a in x[2])
    if t == '=':
        return 1 + sz(x[1]) + sz(x[2])
    if t in ('~', 'A'):
        return 1 + sz(x[1])
    if t == '>':
        return 1 + sz(x[1]) + sz(x[2])
    raise ValueError(x)


def isform(x):
    return x[0] in ('R', '=', '~', '>', 'A')


def kids(x):
    t = x[0]
    if t in ('c', 'R'):
        return list(x[2])
    if t == '=':
        return [x[1], x[2]]
    if t in ('~', 'A'):
        return [x[1]]
    if t == '>':
        return [x[1], x[2]]
    return []


def dangling(x, d=0):
    """Set of (k - d) over index nodes #k at binder depth d with k >= d (pointing above the root of x)."""
    t = x[0]
    if t == 'i':
        return {x[1] - d} if x[1] >= d else set()
    if t == 'p':
        return set()
    if t == 'A':
        return dangling(x[1], d + 1)
    s = set()
    for c in kids(x):
        s |= dangling(c, d)
    return s


def is_line(x):
    return isform(x) and not dangling(x)


def pars(x):
    if x[0] == 'p':
        return {x[1]}
    s = set()
    for c in kids(x):
        s |= pars(c)
    return s


def has_index(t):
    if t[0] == 'i':
        return True
    return any(has_index(c) for c in kids(t))


def rebuild(x, new_kids):
    t = x[0]
    if t in ('c', 'R'):
        return (t, x[1], tuple(new_kids))
    if t in ('=', '>'):
        return (t, new_kids[0], new_kids[1])
    if t in ('~', 'A'):
        return (t, new_kids[0])
    return x


def abst(x, p, d=0):
    """abs_p: parameter p at binder depth d becomes index d."""
    if x[0] == 'p':
        return ('i', d) if x[1] == p else x
    if x[0] == 'i':
        return x
    nd = d + 1 if x[0] == 'A' else d
    return rebuild(x, [abst(c, p, nd) for c in kids(x)])


def gen(x, p):
    return ('A', abst(x, p))


def subst_top(body, t, d=0):
    """B[t] for the body of a top-level quantifier: index d at depth d becomes t (t index-free)."""
    if x_is(body, 'i'):
        return t if body[1] == d else body
    if body[0] == 'p':
        return body
    nd = d + 1 if body[0] == 'A' else d
    return rebuild(body, [subst_top(c, t, nd) for c in kids(body)])


def x_is(x, tag):
    return x[0] == tag


def find_bound(body, other, d=0):
    """Walk body and other in parallel; at the first occurrence of the index pointing to the removed binder
    return the corresponding subterm of other. None if no occurrence or shapes diverge before one is found."""
    if body[0] == 'i' and body[1] == d:
        return other
    if body[0] != other[0]:
        return None
    kb, ko = kids(body), kids(other)
    if len(kb) != len(ko):
        return None
    nd = d + 1 if body[0] == 'A' else d
    for a, b in zip(kb, ko):
        r = find_bound(a, b, nd)
        if r is not None:
            return r
    return None


def imp(a, b):
    return ('>', a, b)


def neg(a):
    return ('~', a)


REFL = ('A', ('=', ('i', 0), ('i', 0)))


def ax1(f):
    return f[0] == '>' and f[2][0] == '>' and f[2][2] == f[1]


def ax2(f):
    try:
        (_, (_, B, (_, C, D)), rhs) = f
        return f[0] == '>' and f[1][0] == '>' and f[1][2][0] == '>' and rhs == imp(imp(B, C), imp(B, D))
    except (ValueError, TypeError, IndexError):
        return False


def ax3(f):
    if f[0] != '>' or f[1][0] != '>' or f[1][1][0] != '~' or f[1][2][0] != '~':
        return False
    C, B = f[1][1][1], f[1][2][1]
    return f[2] == imp(imp(neg(C), B), C)


def ax4(f):
    if f[0] != '>' or f[1][0] != 'A':
        return False
    body, rhs = f[1][1], f[2]
    t = find_bound(body, rhs)
    if t is None:
        return body == rhs and not dangling(body)
    if not (t[0] in ('c', 'p')) or has_index(t):
        return False
    return subst_top(body, t) == rhs


def ax5(f):
    if f[0] != '>' or f[1][0] != 'A' or f[1][1][0] != '>' or f[2][0] != '>' or f[2][2][0] != 'A':
        return False
    B, C = f[1][1][1], f[1][1][2]
    return not dangling(B) and f[2][1] == B and f[2][2][1] == C


def some_replaced(x, y, p, q):
    if x == y:
        return True
    if x == ('p', p) and y == ('p', q):
        return True
    if x[0] != y[0] or x[0] in ('i', 'p'):
        return False
    if x[0] in ('c', 'R') and x[1] != y[1]:
        return False
    kx, ky = kids(x), kids(y)
    return len(kx) == len(ky) and all(some_replaced(a, b, p, q) for a, b in zip(kx, ky))


def ax_subst(f):
    if f[0] != '>' or f[1][0] != '=' or f[1][1][0] != 'p' or f[1][2][0] != 'p' or f[2][0] != '>':
        return False
    return some_replaced(f[2][1], f[2][2], f[1][1][1], f[1][2][1])


def logical(f):
    return f == REFL or ax1(f) or ax2(f) or ax3(f) or ax4(f) or ax5(f) or ax_subst(f)


def check(lines, member):
    """lines: list of (formula, just); just = ('ax',) | ('mp', i, j) [line j = line i -> this] | ('gen', i, p)."""
    for n, (f, j) in enumerate(lines):
        if not is_line(f):
            return False, n
        if j[0] == 'ax':
            if not (logical(f) or member(f)):
                return False, n
        elif j[0] == 'mp':
            i, k = j[1], j[2]
            if not (i < n and k < n and lines[k][0] == imp(lines[i][0], f)):
                return False, n
        elif j[0] == 'gen':
            if not (j[1] < n and f == gen(lines[j[1]][0], j[2])):
                return False, n
        else:
            return False, n
    return True, None


def dsize(lines):
    return sum(sz(f) for f, _ in lines)


def instances(lines):
    seen = []
    for f, j in lines:
        if j[0] == 'ax' and f not in seen:
            seen.append(f)
    return seen


def normalise(lines, target=None):
    """Lemma 1.1: keep first occurrences, cut at the target, keep its ancestors."""
    if target is None:
        target = lines[-1][0]
    first, remap, d = {}, {}, []
    for n, (f, j) in enumerate(lines):
        if f in first:
            remap[n] = first[f]
            continue
        if j[0] == 'mp':
            j = ('mp', remap[j[1]], remap[j[2]])
        elif j[0] == 'gen':
            j = ('gen', remap[j[1]], j[2])
        first[f] = len(d)
        remap[n] = len(d)
        d.append((f, j))
    r = first[target]
    keep, st = set(), [r]
    while st:
        n = st.pop()
        if n in keep:
            continue
        keep.add(n)
        j = d[n][1]
        if j[0] == 'mp':
            st += [j[1], j[2]]
        elif j[0] == 'gen':
            st.append(j[1])
    order = sorted(keep)
    pos = {o: k for k, o in enumerate(order)}
    out = []
    for o in order:
        f, j = d[o]
        if j[0] == 'mp':
            j = ('mp', pos[j[1]], pos[j[2]])
        elif j[0] == 'gen':
            j = ('gen', pos[j[1]], j[2])
        out.append((f, j))
    return out


def is_normal(lines):
    fs = [f for f, _ in lines]
    if len(set(fs)) != len(fs):
        return False
    used = set()
    for _, j in lines:
        if j[0] == 'mp':
            used |= {j[1], j[2]}
        elif j[0] == 'gen':
            used.add(j[1])
    return all(n in used for n in range(len(lines) - 1))


def fnodes(x, path=()):
    """(path, subtree) for every formula node; paths index kids()."""
    res = [(path, x)]
    if x[0] in ('~', 'A'):
        res += fnodes(x[1], path + (0,))
    elif x[0] == '>':
        res += fnodes(x[1], path + (0,)) + fnodes(x[2], path + (1,))
    return res


def at(x, path):
    for k in path:
        x = kids(x)[k]
    return x


def sits(lam, alpha, path, k):
    """Definition 'sits at v with k abstractions', checked directly: the k nodes above v are quantifiers and
    lam arises from alpha_v by replacing, for each level j in 1..k, the indices that point j levels above v by one
    parameter q_j that does not occur elsewhere in lam (vacuous levels allowed)."""
    if k > len(path):
        return False
    for m in range(1, k + 1):
        if at(alpha, path[:len(path) - m])[0] != 'A':
            return False
    av = at(alpha, path)
    if dangling(av) - set(range(k)):
        return False
    assign = {}

    def go(a, l, d):
        if a[0] == 'i' and a[1] >= d:
            lvl = a[1] - d
            if l[0] != 'p':
                return False
            if lvl in assign:
                return assign[lvl] == l[1]
            assign[lvl] = l[1]
            return True
        if a[0] != l[0]:
            return False
        if a[0] in ('i', 'p'):
            return a == l
        if a[0] in ('c', 'R') and a[1] != l[1]:
            return False
        ka, kl = kids(a), kids(l)
        if len(ka) != len(kl):
            return False
        nd = d + 1 if a[0] == 'A' else d
        return all(go(u, v, nd) for u, v in zip(ka, kl))

    if not go(av, lam, 0):
        return False
    used = set(assign.values())
    if len(used) != len(assign):
        return False

    # the abstracted parameters must not occur in lam at positions other than the dangling-index positions
    def other_occ(a, l, d):
        if a[0] == 'i' and a[1] >= d:
            return set()
        if l[0] == 'p':
            return {l[1]}
        nd = d + 1 if a[0] == 'A' else d
        s = set()
        for u, v in zip(kids(a), kids(l)):
            s |= other_occ(u, v, nd)
        return s

    return not (other_occ(av, lam, 0) & used)


def N(x):
    return len(fnodes(x))


def F(x):
    return sum(sz(s) for _, s in fnodes(x))


# ------------------------------------------------------------------ prefix code of the notes (Def 5.1), re-implemented

def gam(n):
    return 2 * n.bit_length() - 1


def fbits(x, bs):
    if x[0] in ('i', 'p'):
        return bs + gam(x[1] + 1)
    return bs + sum(fbits(c, bs) for c in kids(x))


def code_len(lines, bs):
    tot = 2
    for f, j in lines:
        tot += 2 + fbits(f, bs)
        if j[0] in ('mp', 'gen'):
            tot += gam(j[1] + 1) + gam(j[2] + 1)
    return tot
