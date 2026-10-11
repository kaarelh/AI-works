"""r4 (referee): exact Walsh eigenvalues of dot-product kernels on {-1,1}^d via Krawtchouk sums
(context notes Thm 4.6(a), Rem 4.8), for large d, with and without bias.

For k(x,x') = kappa(rho), rho = <x,x'>/d, the eigenvalue on chi_S with |S| = j is
    lambda_j = 2^-d * sum_{w=0}^{d} kappa((d-2w)/d) * K(j,w),   K(j,w) = sum_i (-1)^i C(j,i) C(d-j, w-i),
because sum_{z: #(-1 entries)=w} chi_S(z) = K(j,w) (i = number of -1 entries inside S).
(An independent route from c2, which diagonalised the 2^d x 2^d matrix for d = 10.)  mpmath, 60 digits.
Sanity check of the routine: kappa(rho) = rho^j0 must give lambda_j != 0 iff j <= j0 and j = j0 mod 2.
With a bias input (constant coordinate appended, as for nets with biases), rho = (<x,x'> + 1)/(d + 1).
Kernels: 2-layer ReLU NNGP kappa1, 2-layer ReLU NTK kappa1 + rho*kappa0, 3-layer ReLU NNGP kappa1(kappa1).
Claims checked: bias-free 2-layer NNGP/NTK eigenvalues vanish exactly for odd j >= 3; they do not vanish
with a bias; the 3-layer kernel has nonzero odd eigenvalues; the degree-1 eigenvalue is nonzero.
Also the elementary symmetry fact behind Rem 4.8: kappa(rho) = a*rho + (even function of rho), with
a = 1/2 for the 2-layer NNGP and a = 1 for the 2-layer NTK.
Deterministic.
"""
import mpmath as mp

mp.mp.dps = 60
out = []


def k1(r):
    r = mp.mpf(r)
    r = max(min(r, 1), -1)
    return (mp.sqrt(1 - r * r) + r * (mp.pi - mp.acos(r))) / mp.pi


def k0(r):
    r = mp.mpf(r)
    r = max(min(r, 1), -1)
    return (mp.pi - mp.acos(r)) / mp.pi


kernels = {
    "NNGP2": lambda r: k1(r),
    "NTK2": lambda r: k1(r) + r * k0(r),
    "NNGP3": lambda r: k1(k1(r)),
}


def kraw(d, j, w):
    # sum over z with w entries equal to -1 of chi_S(z), |S| = j: i = number of -1 entries inside S
    return sum((-1) ** i * mp.binomial(j, i) * mp.binomial(d - j, w - i) for i in range(0, min(j, w) + 1))


def eig(kappa, d, j, bias):
    tot = mp.mpf(0)
    for w in range(d + 1):
        rho = mp.mpf(d - 2 * w + (1 if bias else 0)) / (d + (1 if bias else 0))
        tot += kappa(rho) * kraw(d, j, w)
    return tot / mp.mpf(2) ** d


for d in [10, 20, 40]:
    for bias in [False, True]:
        for name, kap in kernels.items():
            lam = [eig(kap, d, j, bias) for j in range(0, min(d, 9) + 1)]
            odd = [abs(lam[j]) for j in range(3, len(lam), 2)]
            out.append(f"d={d:2d} bias={str(bias):5s} {name:5s}: lambda_1={mp.nstr(lam[1], 4)}; "
                       f"max |lambda_j| over odd j=3..{len(lam) - 1}: {mp.nstr(max(odd), 4)}; "
                       f"min |lambda_j| over even j=2..{len(lam) - 1}: {mp.nstr(min(abs(lam[j]) for j in range(2, len(lam), 2)), 4)}")

# symmetry: kappa(r) = a*r + (even function) for the 2-layer kernels, i.e. kappa(r) - kappa(-r) = 2 a r
for n, a in [("NNGP2", mp.mpf(1) / 2), ("NTK2", mp.mpf(1))]:
    sym = max(abs(kernels[n](r) - kernels[n](-r) - 2 * a * r) for r in [mp.mpf(i) / 37 for i in range(38)])
    out.append(f"{n}: max |kappa(r) - kappa(-r) - 2*{a}*r| over r in [0,1]: {mp.nstr(sym, 5)} (odd part is exactly linear)")
# sanity check of the Krawtchouk routine on monomials
bad = 0
for d in [7, 10]:
    for j0 in range(0, 6):
        for j in range(0, d + 1):
            lam = eig(lambda r: r ** j0, d, j, False)
            should_vanish = not (j <= j0 and (j - j0) % 2 == 0)
            if should_vanish and abs(lam) > mp.mpf(10) ** -40:
                bad += 1
            if not should_vanish and abs(lam) < mp.mpf(10) ** -40:
                bad += 1
out.append(f"sanity check (monomial kernels rho^j0, d=7,10): violations of 'nonzero iff j<=j0, j=j0 mod 2': {bad}")
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
