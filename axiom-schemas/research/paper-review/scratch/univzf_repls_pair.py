# Check: for ReplS in the named encoding with textbook names, the non-anchor pair (both bodies with root 'in')
#   ReplS(x in y), ReplS(y in A)
# has a first-order lgg (Plotkin, names as constants) with term metavariables only at the slots, and the sentence
#   forall A ( forall x (x in A -> exists y (Y in y & forall u (u in u -> u = y)))
#              -> exists Y forall x (x in A -> exists y (y in Y & Y in y)) )
# (Y free in the antecedent = parameter) is an instance of that lgg. Under a guard family with freshness guards only
# on FORMULA metavariables (cases record, Phi = {fresh(v,A): A a formula metavariable}) no guard applies to it.
# The sentence is false in V (Foundation): at A = {0}, Y = 0 the antecedent holds (y = {0}; no u in u) and the
# consequent needs y in Y' and Y' in y.

def A(v, b): return ('all', v, b)
def E(v, b): return ('ex', v, b)
def AND(f, g): return ('and', f, g)
def IMP(f, g): return ('imp', f, g)
def IN(a, b): return ('in', a, b)
def EQ(a, b): return ('eq', a, b)

def ReplS(body):  # body: function (x,y,A) -> formula, applied textually with textbook names
    return A('A', IMP(A('x', IMP(IN('x', 'A'), E('y', AND(body('x', 'y', 'A'), A('u', IMP(body('x', 'u', 'A'), EQ('u', 'y'))))))),
                      E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), body('x', 'y', 'A'))))))))

d1 = ReplS(lambda x, y, a: IN(x, y))
d2 = ReplS(lambda x, y, a: IN(y, a))

def lgg(s, t, table):
    if s == t:
        return s
    if isinstance(s, tuple) and isinstance(t, tuple) and s[0] == t[0] and len(s) == len(t):
        return (s[0],) + tuple(lgg(a, b, table) for a, b in zip(s[1:], t[1:]))
    key = (s, t)
    if key not in table:
        table[key] = '?V%d' % len(table)
    return table[key]

table = {}
L = lgg(d1, d2, table)
print('lgg =', L)
print('metavariables:', table)

def match(pat, s, sub):
    if isinstance(pat, str) and pat.startswith('?'):
        if pat in sub:
            return sub[pat] == s
        sub[pat] = s
        return True
    if isinstance(pat, tuple) and isinstance(s, tuple) and pat[0] == s[0] and len(pat) == len(s):
        return all(match(a, b, sub) for a, b in zip(pat[1:], s[1:]))
    return pat == s

cand = A('A', IMP(A('x', IMP(IN('x', 'A'), E('y', AND(IN('Y', 'y'), A('u', IMP(IN('u', 'u'), EQ('u', 'y'))))))),
                  E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), IN('Y', 'y'))))))))
sub = {}
print('candidate is an instance of the lgg:', match(L, cand, sub), sub)
