"""Independent check of Corollary 3 of RT-width.fixed.md.

(1) Exact Exc of (5.1) <= simplified bound (5.2): random + adversarial (Nelder-Mead on log-ratio) search,
    H up to 40, n from 2 to 1e300, alpha in [0, 1/2), Bbar in [1, n^0.9], d in [1, n^alpha], N in [1, 2 n^alpha],
    delta in (1e-12, 0.999).
(2) Each step of the proof of (5.2) separately (steps 1-5), with the worst slack.
(3) Lambda_N <= (H+5) ln(2n); the intermediate bound (3+3H/2) ln 2 + (2H+9)/4 ln n.
(4) Slopes of each term in case (i); threshold alpha = 1/8 for the Hoeffding form; 1/4 for the Bernstein form.
(5) The corrected clause vs exact Exc at moderate n (how loose is it).
"""
import math, random
import mpmath as mp
mp.mp.dps = 50
rng = random.Random(7)

def Lam(n, N, d, H, c=1):
    K = mp.mpf(n)/c + 1
    return mp.log(2 + 2*n*mp.sqrt(K*N)*H*(d+N+1)*(K+1)**(mp.mpf(H)/2))

def P(N, d, H):
    return N*(d+1) + (H-1)*N**2 + N

def Dev(n, N, d, H, delta, c=1):
    return 4*mp.sqrt((P(N, d, H)*Lam(n, N, d, H, c) + mp.log(4/mp.mpf(delta)))/(2*n))

def Exc(n, N, d, H, Bb, delta, c=1, form='B'):
    L = H+1; l = mp.log(4/mp.mpf(delta))
    E = d*(d+1)*Bb**2 + 2*(L-1)*N**2*Bb**2
    U1 = N*Bb + 1
    base = c*(E+1)/n + mp.mpf(4)/n + Dev(n, N, d, H, delta, c)
    if form == 'B':
        return base + U1*mp.sqrt(2*l/n) + 2*U1**2*l/(3*n)
    return base + U1**2*mp.sqrt(l/(2*n))

def simple(n, a, H, Bb, delta):
    L = H+1; l = mp.log(4/mp.mpf(delta)); a = mp.mpf(a)
    return (5*mp.sqrt(2)*Bb*n**(a-mp.mpf(1)/2)*mp.sqrt(l)
            + 4*mp.sqrt((2*H+1)*(H+5))*n**(a-mp.mpf(1)/2)*mp.sqrt(mp.log(2*n))
            + (8*L-1)*(1+l)*Bb**2*n**(2*a-1))

def sample():
    logn = rng.choice([math.log(2), math.log(3), rng.uniform(math.log(2), math.log(1e6)), rng.uniform(math.log(2), 690.0)])
    n = mp.e**mp.mpf(logn)
    n = mp.mpf(max(2, int(mp.nint(n)))) if logn < 40 else n
    a = rng.choice([0.0, rng.uniform(0, 0.5 - 1e-9), 0.5 - 10**rng.uniform(-9, -1)])
    H = rng.choice([1, 2, 3, rng.randint(1, 40)])
    nu = n**mp.mpf(a)
    N = rng.choice([1, int(mp.floor(nu)), int(mp.ceil(nu)), int(mp.floor(2*nu)), max(1, int(mp.floor(rng.uniform(1, float(min(2*nu, 1e300))))))])
    N = max(1, min(N, int(mp.floor(2*nu))))
    d = rng.choice([1, int(mp.floor(nu)), max(1, int(mp.floor(rng.uniform(1, float(min(nu, 1e300))))))])
    d = max(1, min(d, int(mp.floor(nu))))
    Bb = rng.choice([mp.mpf(1), nu, n**mp.mpf(rng.uniform(0, 0.9)), mp.mpf(10)**rng.uniform(0, 6)])
    delta = rng.choice([1e-12, 0.999, 10**rng.uniform(-12, -0.0005)])
    return n, a, H, N, d, Bb, delta

worst = (0, None); worst_lam = (0, None); worst_int = (0, None)
steps_worst = [0]*6
for it in range(60000):
    n, a, H, N, d, Bb, delta = sample()
    nu = n**mp.mpf(a)
    if not (1 <= N <= 2*nu and 1 <= d <= nu and Bb >= 1 and n >= 2):
        continue
    e = Exc(n, N, d, H, Bb, delta); s = simple(n, a, H, Bb, delta)
    r = e/s
    if r > worst[0]:
        worst = (r, (float(mp.log10(n)), a, H, N if N < 1e12 else float(N), d if d < 1e12 else float(d), float(Bb), delta))
    lr = Lam(n, N, d, H)/((H+5)*mp.log(2*n))
    if lr > worst_lam[0]: worst_lam = (lr, (float(mp.log10(n)), a, H, N if N<1e12 else float(N), d if d<1e12 else float(d)))
    li = Lam(n, N, d, H)/((3+mp.mpf(3)*H/2)*mp.log(2) + (mp.mpf(2*H+9)/4)*mp.log(n))
    if li > worst_int[0]: worst_int = (li, (float(mp.log10(n)), a, H))
    # steps of the proof (c=1)
    L = H+1; l = mp.log(4/mp.mpf(delta))
    E = d*(d+1)*Bb**2 + 2*(L-1)*N**2*Bb**2
    s1 = ((E+1)/n + mp.mpf(4)/n)/((8*L-1)*Bb**2*n**(2*mp.mpf(a)-1))
    s2a = (N*Bb+1)*mp.sqrt(2*l/n)/(3*mp.sqrt(2)*Bb*n**(mp.mpf(a)-mp.mpf(1)/2)*mp.sqrt(l))
    s2b = (2*(N*Bb+1)**2*l/(3*n))/(6*Bb**2*n**(2*mp.mpf(a)-1)*l)
    s3 = P(N, d, H)/((4*H+2)*nu**2)
    s4 = (2*n*mp.sqrt((n+1)*N)*H*(d+N+1)*(n+2)**(mp.mpf(H)/2))/(8*mp.sqrt(3)*H*2**(mp.mpf(H)/2)*n**(mp.mpf(2*H+9)/4))
    s5 = Dev(n, N, d, H, delta)/(4*mp.sqrt((2*H+1)*(H+5)*mp.log(2*n))*n**(mp.mpf(a)-mp.mpf(1)/2) + 2*mp.sqrt(2)*mp.sqrt(l/n))
    for i, v in enumerate([s1, s2a, s2b, s3, s4, s5]):
        steps_worst[i] = max(steps_worst[i], float(v))
print("(1) random search: max Exc/(5.2) = %.6f at (log10 n, alpha, H, N, d, Bbar, delta) = %s" % (float(worst[0]), worst[1]))
print("(2) max ratio LHS/RHS of each proof step (must be <= 1):")
for name, v in zip(["step1 (E*+1)/n+4/n <= (8L-1)B^2 n^(2a-1)", "step2a (U+1)sqrt(2l/n) <= 3sqrt2 B n^(a-1/2) sqrt l",
                    "step2b 2(U+1)^2 l/(3n) <= 6 B^2 n^(2a-1) l", "step3 P_N <= (4H+2) nu^2",
                    "step4 log argument (minus the 2) <= 8 sqrt3 H 2^(H/2) n^((2H+9)/4)", "step5 Dev <= ..."], steps_worst):
    print("    %-70s %.6f" % (name, v))
print("(3) max Lambda_N/((H+5)ln 2n) = %.6f at %s; max Lambda_N / intermediate bound = %.6f at %s" % (
    float(worst_lam[0]), worst_lam[1], float(worst_int[0]), worst_int[1]))

# adversarial: maximize log ratio over continuous params with Nelder-Mead (scipy) on a coarse parametrization
from scipy.optimize import minimize
import numpy as np
def neg_ratio(p, H, delta):
    logn, a, fN, fd, bexp = p
    if logn < math.log(2) or logn > 690 or not (0 <= a < 0.5) or not (0 <= fN <= 1) or not (0 <= fd <= 1) or not (0 <= bexp <= 0.9):
        return 0.0
    n = mp.e**mp.mpf(logn)
    if logn < 30: n = mp.mpf(max(2, int(mp.nint(n))))
    nu = n**mp.mpf(a)
    N = max(1, int(mp.floor(1 + fN*(2*nu - 1))))
    d = max(1, int(mp.floor(1 + fd*(nu - 1))))
    Bb = n**mp.mpf(bexp)
    if Bb < 1: Bb = mp.mpf(1)
    return -float(Exc(n, N, d, H, Bb, delta)/simple(n, a, H, Bb, delta))
best = 0; bestp = None
for H in [1, 2, 3, 5, 10, 30]:
    for delta in [1e-12, 0.5, 0.999]:
        for start in range(6):
            x0 = [rng.uniform(0.7, 60), rng.uniform(0, 0.49), rng.random(), rng.random(), rng.uniform(0, 0.5)]
            res = minimize(neg_ratio, x0, args=(H, delta), method='Nelder-Mead', options={'maxiter': 400, 'xatol': 1e-6, 'fatol': 1e-9})
            if -res.fun > best:
                best, bestp = -res.fun, (H, delta, [round(v, 4) for v in res.x])
print("(1b) Nelder-Mead adversarial search: max Exc/(5.2) = %.6f at (H, delta, [ln n, alpha, fN, fd, beta]) = %s" % (best, bestp))

# (4) slopes, case (i): N = ceil(n^a), d = floor(n^a), Bbar = n^a, H=2, delta=0.05
print("(4) slopes between n=1e150 and 1e300 (case (i), H=2, delta=0.05):")
H = 2; delta = 0.05
for a in [0.05, 0.1, 0.124, 0.125, 0.126, 0.2, 0.24, 0.249, 0.25, 0.26]:
    vals = {}
    for n in [mp.mpf(10)**150, mp.mpf(10)**300]:
        nu = n**mp.mpf(a); N = int(mp.ceil(nu)); d = int(mp.floor(nu)); Bb = nu
        L = H+1; l = mp.log(4/mp.mpf(delta))
        E = d*(d+1)*Bb**2 + 2*(L-1)*N**2*Bb**2
        terms = {'clone': (E+1)/n, 'dev': Dev(n, N, d, H, delta), 'bern': (N*Bb+1)*mp.sqrt(2*l/n) + 2*(N*Bb+1)**2*l/(3*n),
                 'hoeff': (N*Bb+1)**2*mp.sqrt(l/(2*n)), 'ExcB': Exc(n, N, d, H, Bb, delta), 'ExcH': Exc(n, N, d, H, Bb, delta, form='H')}
        for k, v in terms.items(): vals.setdefault(k, []).append(v)
    sl = {k: float((mp.log(v[1]) - mp.log(v[0]))/(150*mp.log(10))) for k, v in vals.items()}
    print("    a=%.3f clone %+.4f (4a-1=%+.3f) dev %+.4f (a-1/2=%+.3f) Bern %+.4f (2a-1/2=%+.3f) Hoeff %+.4f (4a-1/2=%+.3f) | ExcB %+.4f ExcH %+.4f" % (
        a, sl['clone'], 4*a-1, sl['dev'], a-0.5, sl['bern'], 2*a-0.5, sl['hoeff'], 4*a-0.5, sl['ExcB'], sl['ExcH']))

# (5) the clause at moderate n: values of exact Exc and of the clause bound
print("(5) clause bound vs exact Exc, case (i), H=2, delta=0.05:")
for a in [0.1, 0.2, 0.24]:
    for e10 in [6, 12, 24, 48, 96]:
        n = mp.mpf(10)**e10; nu = n**mp.mpf(a); N = int(mp.ceil(nu)); d = int(mp.floor(nu))
        print("    a=%.2f n=1e%-3d exact Exc=%-10s clause=%-10s ratio=%.3f" % (a, e10, mp.nstr(Exc(n, N, d, 2, nu, 0.05), 4),
              mp.nstr(simple(n, a, 2, nu, 0.05), 4), float(Exc(n, N, d, 2, nu, 0.05)/simple(n, a, 2, nu, 0.05))))
