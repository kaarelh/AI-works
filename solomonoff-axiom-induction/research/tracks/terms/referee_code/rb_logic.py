"""rb_logic.py -- referee B's own first-order syntax and derivation checker (independent of checks/).

Representation (nested tuples, hashable):
  terms     ('v', name)              variable
            ('c', name)              constant (e)
            ('f', name, (t1, ...))   function application (s0, s1, p)
  formulas  ('at', pred, (t1, ...))  atomic, pred in {R, C, J, ...}
            ('eq', t1, t2)
            ('not', F)
            ('imp', F, G)
            ('all', var, F)
Derivation lines: (formula, justification) with justification one of
  ('ax',)            the formula is a member of the theory (membership test supplied by caller)
  ('A4', term)       the formula is  all v F -> F[term/v]  (term closed, so always free for v)
  ('A1',)            the formula is  a -> (b -> a)
  ('MP', i, j)       line j is  line_i -> formula
The checker re-derives everything from the formula itself; it trusts nothing the generator says except the
line numbers it cites.
"""

E = ('c', 'e')


def s(a, t):
    return ('f', 's' + a, (t,))


def word_term(u, base=E):
    """t_u over base: the word lists function letters from the outside in."""
    t = base
    for a in reversed(u):
        t = s(a, t)
    return t


def term_word(t):
    """Inverse of word_term for closed words over e; None if t is not of that form."""
    out = []
    while t[0] == 'f' and t[1] in ('s0', 's1'):
        out.append(t[1][1])
        t = t[2][0]
    if t == E:
        return ''.join(out)
    return None


def subst_t(t, v, r):
    if t[0] == 'v':
        return r if t[1] == v else t
    if t[0] == 'c':
        return t
    return ('f', t[1], tuple(subst_t(a, v, r) for a in t[2]))


def subst(F, v, r):
    """Substitute closed term r for free occurrences of variable v."""
    k = F[0]
    if k == 'at':
        return ('at', F[1], tuple(subst_t(a, v, r) for a in F[2]))
    if k == 'eq':
        return ('eq', subst_t(F[1], v, r), subst_t(F[2], v, r))
    if k == 'not':
        return ('not', subst(F[1], v, r))
    if k == 'imp':
        return ('imp', subst(F[1], v, r), subst(F[2], v, r))
    if k == 'all':
        if F[1] == v:
            return F
        return ('all', F[1], subst(F[2], v, r))
    raise ValueError(F)


def closed_term(t):
    if t[0] == 'v':
        return False
    if t[0] == 'c':
        return True
    return all(closed_term(a) for a in t[2])


def tsize(t):
    if t[0] in ('v', 'c'):
        return 1
    return 1 + sum(tsize(a) for a in t[2])


def size(F):
    """Symbols: predicate/=/connective/quantifier 1 each, quantified variable 1, terms by tsize."""
    k = F[0]
    if k == 'at':
        return 1 + sum(tsize(a) for a in F[2])
    if k == 'eq':
        return 1 + tsize(F[1]) + tsize(F[2])
    if k == 'not':
        return 1 + size(F[1])
    if k == 'imp':
        return 1 + size(F[1]) + size(F[2])
    if k == 'all':
        return 2 + size(F[2])
    raise ValueError(F)


def check(lines, is_member):
    """Return (ok, message).  lines: list of (formula, justification)."""
    for n, (F, j) in enumerate(lines):
        tag = j[0]
        if tag == 'ax':
            if not is_member(F):
                return False, f"line {n}: not a member"
        elif tag == 'A4':
            r = j[1]
            if not closed_term(r):
                return False, f"line {n}: A4 term not closed"
            if F[0] != 'imp' or F[1][0] != 'all':
                return False, f"line {n}: not of A4 shape"
            v, body = F[1][1], F[1][2]
            if subst(body, v, r) != F[2]:
                return False, f"line {n}: bad A4 instance"
        elif tag == 'A1':
            if not (F[0] == 'imp' and F[2][0] == 'imp' and F[2][2] == F[1]):
                return False, f"line {n}: not an A1 instance"
        elif tag == 'MP':
            i, k = j[1], j[2]
            if not (0 <= i < n and 0 <= k < n):
                return False, f"line {n}: MP cites a later line"
            maj = lines[k][0]
            if maj != ('imp', lines[i][0], F):
                return False, f"line {n}: MP mismatch"
        else:
            return False, f"line {n}: unknown justification"
    return True, "ok"


class Builder:
    """Accumulates a derivation; memoises repeated lines."""

    def __init__(self):
        self.lines = []
        self.index = {}

    def add(self, F, j):
        key = (F, j[0]) if j[0] != 'MP' else None
        if key is not None and key in self.index:
            return self.index[key]
        self.lines.append((F, j))
        n = len(self.lines) - 1
        if key is not None:
            self.index[key] = n
        return n

    def ax(self, F):
        return self.add(F, ('ax',))

    def mp(self, i, k):
        maj = self.lines[k][0]
        assert maj[0] == 'imp' and maj[1] == self.lines[i][0], "builder MP mismatch"
        return self.add(maj[2], ('MP', i, k))

    def inst(self, i, r):
        """From line i = all v F, derive F[r/v] by A4 and MP."""
        F = self.lines[i][0]
        assert F[0] == 'all'
        a4 = self.add(('imp', F, subst(F[2], F[1], r)), ('A4', r))
        return self.mp(i, a4)
