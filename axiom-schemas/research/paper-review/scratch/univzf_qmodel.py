# Independent check of the model of Q in app-universal (Ex. univ:q), written from the paper's text.
# Domain: 0..B plus 'a','b'.
B = 60
dom = list(range(B + 1)) + ['a', 'b']
nonstd = ('a', 'b')

def S(x):
    if x in nonstd:
        return x
    return x + 1  # may exceed B; we only test where results are representable

def add(x, y):
    if x not in nonstd and y not in nonstd:
        return x + y
    if x not in nonstd and y in nonstd:   # n+a = n+b = b
        return 'b'
    if x in nonstd and y not in nonstd:   # a+n=a, b+n=b
        return x
    # both nonstandard
    if x == 'a':                          # a+a = a+b = a
        return 'a'
    return 'b'                            # b+a = b+b = b

def mul(x, y):
    if y == 0:
        return 0
    if x not in nonstd and y not in nonstd:
        return x * y
    if x in nonstd and y not in nonstd:   # a*n = b*n = b (n>=1)
        return 'b'
    if x not in nonstd and y in nonstd:   # n*a = n*b = a (n>=1); 0*a = 0*b = 0
        return 0 if x == 0 else 'a'
    return 'a'                            # a*a=a*b=b*a=b*b=a

def inrange(v):
    return v in nonstd or (isinstance(v, int) and v <= B)

bad = []
# Q1: Sx != 0 ; Q2: Sx = Sy -> x = y ; Q3: x != 0 -> exists y x = Sy
for x in dom:
    if S(x) == 0:
        bad.append(('Q1', x))
for x in dom:
    for y in dom:
        if S(x) == S(y) and x != y:
            bad.append(('Q2', x, y))
for x in dom:
    if x != 0 and not any(S(y) == x for y in dom):
        bad.append(('Q3', x))
for x in dom:
    if add(x, 0) != x:
        bad.append(('Q4', x))
    if mul(x, 0) != 0:
        bad.append(('Q6', x))
for x in dom:
    for y in dom:
        lhs = add(x, S(y)); rhs = S(add(x, y))
        if inrange(lhs) and inrange(rhs) and lhs != rhs:
            bad.append(('Q5', x, y, lhs, rhs))
        lhs = mul(x, S(y)); rhs = add(mul(x, y), x)
        if inrange(lhs) and inrange(rhs) and lhs != rhs:
            bad.append(('Q7', x, y, lhs, rhs))
print('violations:', bad[:10], len(bad))
print('0+a =', add(0, 'a'))
print('closed instances 0+n=n for n<=B:', all(add(0, n) == n for n in range(B + 1)))
print('S a =', S('a'), '; so forall y not(y=Sy) fails at a:', S('a') == 'a')
