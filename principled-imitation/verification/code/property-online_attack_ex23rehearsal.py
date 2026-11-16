"""Does Example 2.3 (sequence game) carry over to rehearsal? L = 1, question parity uniform at random,
human f(x) = 0 for odd x, 2 for even x; tests B = {y = 1} (weight beta = 1/(2n)), D (weight 1/2) as in the file.
Rule of Theorem 2.1, eta = 1/sqrt(n), least minimiser. Deployed rate of answer 1 per call
= (1/n) sum_t n_B(a_t), n_B(a) = Pr_x[a(x) = 1]. Averaged over 20 rehearsals."""
import math, random
def rate(n, seed):
    rng = random.Random(seed); eta = 1/math.sqrt(n); beta, delta = 1/(2*n), 0.5
    SB = SD = 0; tot = 0.0
    for t in range(n):
        def ans(odd):
            sc = [0.0, beta*math.sinh(eta*SB) + (delta*math.sinh(eta*SD) if odd else 0.0), (0.0 if odd else delta*math.sinh(eta*SD))]
            return min(range(3), key=lambda y: (sc[y], y))
        tot += 0.5*(ans(True) == 1) + 0.5*(ans(False) == 1)
        odd = rng.random() < 0.5
        a = ans(odd); f = 0 if odd else 2
        inD = lambda y: (y == 1 and odd) or (y == 2 and not odd)
        SB += (a == 1); SD += inD(a) - inD(f)
    return tot/n
for n in (400, 2500, 10000, 40000):
    r = sum(rate(n, s) for s in range(20))/20
    print(f"n={n:6d}: deployed rate of the never-given answer {r:.5f}; x n = {r*n:8.1f}; 0.5 sqrt(n) ln n = {0.5*math.sqrt(n)*math.log(n):8.1f}; lead bound x n = {math.sqrt(n)*(math.log(4*n)+0.5):8.1f}; NH bound K+2 = {math.log2(2*n)+2:.1f}")
