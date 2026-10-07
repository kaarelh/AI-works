# Track "cases", Part 1(c): a model of Robinson's Q in which Ax(0+x=x) fails, although Q proves every
# closed instance 0+n=n.  Domain N u {a, b}; S a = a, S b = b; standard on N.
#   +:  n+m standard; n+a = b, n+b = b; a+n = a, b+n = b; a+a = a, a+b = a, b+a = b, b+b = b
#   *:  n*m standard; a*0 = b*0 = 0, a*n = b*n = b (n>=1); 0*a = 0*b = 0, n*a = n*b = a (n>=1);
#       a*a = a*b = b*a = b*b = a
# The proof that this is a model is by cases (notes.md, Q1(c)); here we check every axiom on all tuples
# from {0..K} u {a, b} (Q3's witness inside the domain), and that 0+a != a.
K = 40
A, B = 'a', 'b'
def S(x): return x + 1 if isinstance(x, int) else x
def add(x, y):
    if isinstance(x, int) and isinstance(y, int): return x + y
    if isinstance(y, int): return x                      # a+n = a, b+n = b  (forced by Q4, Q5)
    if isinstance(x, int): return B                      # n+a = n+b = b
    return {(A, A): A, (A, B): A, (B, A): B, (B, B): B}[(x, y)]
def mul(x, y):
    if isinstance(x, int) and isinstance(y, int): return x * y
    if isinstance(y, int): return 0 if y == 0 else B     # a*n = b*n = b for n >= 1
    if isinstance(x, int): return 0 if x == 0 else A     # 0*a = 0, n*a = a
    return A
D = list(range(K + 1)) + [A, B]
viol = []
for x in D:
    if S(x) == 0: viol.append(('Q1', x))
    if x != 0 and not any(S(y) == x for y in D): viol.append(('Q3', x))
    if add(x, 0) != x: viol.append(('Q4', x))
    if mul(x, 0) != 0: viol.append(('Q6', x))
    for y in D:
        if S(x) == S(y) and x != y: viol.append(('Q2', x, y))
        if add(x, S(y)) != S(add(x, y)): viol.append(('Q5', x, y))
        if mul(x, S(y)) != add(mul(x, y), x): viol.append(('Q7', x, y))
print('domain {0..%d} u {a,b}: %d elements; axiom violations found: %d' % (K, len(D), len(viol)), viol[:5])
print('0+a =', add(0, A), '  so  0+a != a :', add(0, A) != A)
print('closed instances 0+n=n hold for n <= %d:' % K, all(add(0, n) == n for n in range(K + 1)))
