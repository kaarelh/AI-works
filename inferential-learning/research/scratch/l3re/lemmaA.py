import sympy as sp, random
a, b = sp.symbols('a b')
for p in [2, 3, 5, 7, 11, 13]:
    f = sp.expand((a + b) ** p - a ** p - b ** p)
    fp = sp.Poly(f, a, b, modulus=p)
    # random evaluation mod p accepts always
    acc = all(((x + y) ** p - x ** p - y ** p) % p == 0 for x in range(p) for y in range(p))
    # over Z with S={0..99}: SZ bound d/|S| = p/100
    S = range(100)
    rate = sum(1 for _ in range(4000) if f.subs({a: random.choice(S), b: random.choice(S)}) == 0) / 4000
    print(p, 'nonzero over Z:', f != 0, ' zero poly mod p:', fp.is_zero, ' all evals mod p accept:', acc,
          ' pass-rate over Z on S^2:', rate, ' SZ bound:', p / 100)
# |S_k| = d 2^k / delta: sum_k d/|S_k| = delta * sum 2^-k
d, delta = 3, 0.01
print('sum from k=0:', sum(d / (d * 2 ** k / delta) for k in range(0, 60)), ' from k=1:', sum(d / (d * 2 ** k / delta) for k in range(1, 60)))
# repeated squaring hides degree: x^(2^k) via k squarings
x = sp.symbols('x'); e = x
for _ in range(10): e = e * e
print('formal degree after 10 squarings:', sp.Poly(e, x).degree())
