# Compute de Bruijn indices of P's arguments and of frame atoms in the ZF templates of tab:zf:forms,
# to check tab:zf:classify, app:zf:enc and the uniqueness claim in the proof of thm:zf:nounion(iii).
# Formulas: ('all',v,body) ('ex',v,body) ('ex1',v,body) ('not',f) ('and',f,g) ('imp',f,g) ('iff',f,g)
#           ('in',a,b) ('eq',a,b) ('P', args...)

def A(v, b): return ('all', v, b)
def E(v, b): return ('ex', v, b)
def E1(v, b): return ('ex1', v, b)
def N(f): return ('not', f)
def AND(f, g): return ('and', f, g)
def IMP(f, g): return ('imp', f, g)
def IFF(f, g): return ('iff', f, g)
def IN(a, b): return ('in', a, b)
def EQ(a, b): return ('eq', a, b)
def P(*a): return ('P',) + a

T = {
 'Sep': A('z', E('y', A('x', IFF(IN('x', 'y'), AND(IN('x', 'z'), P('x', 'z')))))),
 'SepJ': A('X', E('Y', A('u', IFF(IN('u', 'Y'), AND(IN('u', 'X'), P('u')))))),
 'EInd': IMP(A('x', IMP(A('y', IMP(IN('y', 'x'), P('y'))), P('x'))), A('x', P('x'))),
 'Coll': A('A', IMP(A('x', IMP(IN('x', 'A'), E('y', P('x', 'y', 'A')))),
                    E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), P('x', 'y', 'A')))))))),
 'ReplU': A('A', IMP(A('x', IMP(IN('x', 'A'), E1('y', P('x', 'y', 'A')))),
                    E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), P('x', 'y', 'A')))))))),
 'ReplS': A('A', IMP(A('x', IMP(IN('x', 'A'), E('y', AND(P('x', 'y', 'A'), A('u', IMP(P('x', 'u', 'A'), EQ('u', 'y'))))))),
                    E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), P('x', 'y', 'A')))))))),
 'ReplJ': IMP(A('x', A('y', A('u', IMP(AND(P('x', 'y'), P('x', 'u')), EQ('y', 'u'))))),
              A('X', E('Y', A('y', IFF(IN('y', 'Y'), E('x', AND(IN('x', 'X'), P('x', 'y')))))))),
 'Coll2': A('A', IMP(A('x', IMP(IN('x', 'A'), E('y', P('x', 'y')))),
                    E('Y', A('x', IMP(IN('x', 'A'), E('y', AND(IN('y', 'Y'), P('x', 'y')))))))),
}

def walk(f, env, out):
    t = f[0]
    if t in ('all', 'ex', 'ex1'):
        walk(f[2], [f[1]] + env, out)
    elif t == 'not':
        walk(f[1], env, out)
    elif t in ('and', 'imp', 'iff'):
        walk(f[1], env, out); walk(f[2], env, out)
    elif t in ('in', 'eq'):
        out.append(('atom', t, tuple('#%d' % env.index(v) for v in f[1:]), len(env)))
    elif t == 'P':
        out.append(('P', tuple('#%d' % env.index(v) for v in f[1:]), len(env), tuple(env)))

for k, f in T.items():
    out = []
    walk(f, [], out)
    print(k)
    for o in out:
        print('   ', o)
