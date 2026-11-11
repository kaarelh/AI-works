"""Sanity checks for constants used in redteam.md.
(1) beta(lambda) = E[1/K; K>=1], K ~ Poisson(lambda); binomial version for finite M.
(2) gamma(lambda) = (1-e^{-lambda})^2/(4 lambda) used in the depth-two bound.
(3) parity coefficients c_{k,a} of tanh(a(sum x_j - b_k)) and the bound |c|>=1/(2 sqrt(2k)).
"""
import numpy as np, itertools, math
from scipy import optimize, special, stats

def beta_pois(lam, kmax=200):
    k = np.arange(1, kmax)
    logp = -lam + k*np.log(lam) - special.gammaln(k+1)
    return float(np.sum(np.exp(logp)/k))

def beta_bin(n, M):
    k = np.arange(1, min(n, 200)+1)
    p = stats.binom.pmf(k, n, 1.0/M)
    return float(np.sum(p/k))

for lam in [0.5, 1.0, 1.5, 2.0]:
    print(f"lambda={lam}: beta_pois={beta_pois(lam):.6f}")
res = optimize.minimize_scalar(lambda l: -beta_pois(l), bounds=(0.1, 5), method='bounded')
print(f"argmax beta: lambda*={res.x:.4f}, beta*={-res.fun:.6f}")
# closed form check: e^{-l}(Ei(l)-gamma-ln l)
lam=1.0; print("closed form at 1:", math.exp(-lam)*(special.expi(lam)-np.euler_gamma-math.log(lam)))
for d in [10, 20, 30]:
    M = 2**d
    print(f"d={d}: binomial beta at n=M: {beta_bin(M, M):.6f}")
g = lambda l: (1-math.exp(-l))**2/(4*l)
res2 = optimize.minimize_scalar(lambda l: -g(l), bounds=(0.1, 5), method='bounded')
print(f"gamma(1)={g(1):.5f}; argmax gamma: {res2.x:.4f}, max={-res2.fun:.5f}")

# parity coefficients
def coeff(k, a):
    bk = 0 if k % 2 == 1 else 1
    tot = 0.0
    for x in itertools.product([-1, 1], repeat=k):
        tot += np.prod(x)*np.tanh(a*(sum(x)-bk))
    return tot/2**k
def coeff_sign(k):
    bk = 0 if k % 2 == 1 else 1
    tot = 0.0
    for x in itertools.product([-1, 1], repeat=k):
        tot += np.prod(x)*np.sign(sum(x)-bk)
    return tot/2**k
worst = 1e9
for d in [1, 2, 4, 8, 12, 16]:
    ad = max(1.0, 0.5*math.log(4*math.sqrt(2*d)))
    for k in range(1, min(d, 14)+1):
        c = coeff(k, ad)
        ratio = abs(c)*2*math.sqrt(2*k)
        worst = min(worst, ratio)
        assert ratio >= 1-1e-12, (d, k, c)
print("min over checked (d,k) of |c_{k,a_d}| * 2 sqrt(2k) =", round(worst, 4), "(>=1 required)")
for k in range(1, 9):
    m = (k-1)//2 if k % 2 == 1 else k//2
    print(k, round(coeff_sign(k), 6), "binom formula:", round(math.comb(2*m, m)/4**m, 6))
# identity (4): E_u[(prod u) tanh(a(sum u_j x_j - b))] = c * prod x
k, a = 5, 1.3; bk = 0
c = coeff(k, a)
for x in itertools.product([-1, 1], repeat=k):
    lhs = np.mean([np.prod(u)*np.tanh(a*(np.dot(u, x)-bk)) for u in itertools.product([-1, 1], repeat=k)])
    assert abs(lhs - c*np.prod(x)) < 1e-12
print("identity (4) verified for k=5")
