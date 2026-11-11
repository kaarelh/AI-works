"""Checker: Remark 2.8 comparison with B, and the small-width statement of E §6 on the cube.
Formulas typed from E (I1), §2 definitions, Remark 2.8, Theorem 2.7 (C1)-(C2), and B Theorem 6.3.
"""
import math, random

def A_L(d, m, B, rho, L):
    Estar = d*(d+1)*B**2 + 2*(L-1)*m**2*B**2
    b0 = 2*math.sqrt(2*(2*math.log(9) + math.log(4*L)))
    A0 = 2 + 3*m*B + b0
    P0 = 1 + 2*m*B*(d+L+1)*A0**(L-2)
    eta = min(0.5, rho/(2*P0))
    return 1 + 0.5*Estar + (d+2+(L-2)*m)*math.log(8/(3*eta)) + math.log(2), Estar

def Dn(d, n, H):
    return math.sqrt(2*(d+1)*math.log(n+1)) + (H-1)/2

print('Remark 2.8: ratio of E capacity term to B capacity term >= (2(U+2)^2)^{H/2}')
random.seed(1)
worst = float('inf')
for _ in range(20000):
    H = random.choice([1, 2, 3, 4, 5]); L = H + 1
    d = random.randint(1, 50); m = random.randint(1, 20); B = random.uniform(1, 10)
    U = m*B; theta = random.uniform(0.01, 0.99/H if H > 1 else 0.99)
    n = 10**random.uniform(1, 30); rho = n**-theta; eps0 = n**-theta
    A, Estar = A_L(d, m, B, rho, L)
    assert 8*A >= 4*Estar - 1e-9 and 2*A >= Estar
    Kbar = 8*A + 4*n**theta*(U+2)**2 + 8*math.log(1/eps0) + 3*(d+H+1)
    E_cap = 8*(Kbar/H)**(H/2)*Dn(d, n, H)/math.sqrt(n)
    B_cap = 8*(2/H)**(H/2)*Dn(d, n, H)*n**(-(1-theta*H)/2)
    B_cap_exact = 8*((n**theta+1)/H)**(H/2)*Dn(d, n, H)/math.sqrt(n)
    assert B_cap_exact <= B_cap*(1+1e-12)
    worst = min(worst, (E_cap/B_cap)/((2*(U+2)**2)**(H/2)))
print(f' min over 20000 random cases of [E_cap/B_cap] / (2(U+2)^2)^(H/2) = {worst:.4f} (must be >= 1)')
print(f' at H=2, U=1: (2(U+2)^2)^(H/2) = {(2*9)**1}')

print('\nRemark 2.8: alpha range (exponent bookkeeping), m=B=n^alpha')
for H in (2, 3, 4, 5):
    # E: need 4a < th and H(th+4a) < 1 ; B Cor 8.1: need 4a < th < 1/H
    best_E = max(a/10000 for a in range(1, 10000) if any(4*a/10000 < th/10000 < 1/H - 4*a/10000 for th in range(1, 10000)))
    best_B = max(a/10000 for a in range(1, 10000) if any(4*a/10000 < th/10000 < 1/H for th in range(1, 10000)))
    print(f' H={H}: E sup alpha ~ {best_E:.4f} (1/(8H)={1/(8*H):.4f}); B sup alpha ~ {best_B:.4f} (1/(4H)={1/(4*H):.4f})')

print('\nSmall-width statement on the noisy cube, g = 0 (m=B=1, U=1), n = 2^d: A/d^2 and first d with (C1),(C2)')
for L in (3, 4):
    for theta in (0.55, 0.75, 0.95):
        for eps, delta in ((0.1, 0.05), (0.01, 0.01)):
            U = 1; rho = eps/(16*(U+1))
            first = None
            for d in range(2, 400):
                A, _ = A_L(d, 1, 1, rho, L)
                n = 2.0**d
                C1 = n >= 512*(U+1)**4*math.log(4/delta)/eps**2
                C2 = n**theta >= 16/eps*(A + math.log(64/eps) + math.log(4/delta) + 1)
                if C1 and C2:
                    first = d; break
            A100, _ = A_L(100, 1, 1, rho, L)
            # check that (C1),(C2) then hold for all larger d up to 400
            ok = all((2.0**d >= 512*16*math.log(4/delta)/eps**2) and
                     (2.0**(d*theta) >= 16/eps*(A_L(d, 1, 1, rho, L)[0] + math.log(64/eps) + math.log(4/delta) + 1))
                     for d in range(first, 400))
            print(f' L={L} theta={theta} eps={eps} delta={delta}: A(d=100)/100^2 = {A100/1e4:.3f}; (C1),(C2) from d={first}, all d up to 399: {ok}')

print('\nSmall widths lie below n: N <= N^gamma <= eps n^{1-theta}/4 < n for eps<1, theta in (0,1)')
