"""Exact Walsh-transform checks for ../../subcube-parity.md, Sections 3-5:
f* (chain coefficients, the greedy set G, the two-head margin, 1/m1^2, low-degree weight, distance to parity),
the address-bit variant T2, the selector-free variant g_lambda, and the inequality |f^(S)| <= 2 dist(f, chi_A)."""
import numpy as np, math, itertools
def wht(v):
    v = v.astype(np.float64).copy(); h = 1; n = len(v)
    while h < n:
        v = v.reshape(-1, 2*h); a = v[:, :h].copy(); b = v[:, h:].copy()
        v[:, :h] = a + b; v[:, h:] = a - b; v = v.reshape(-1); h *= 2
    return v / n
def cube(D):
    idx = np.arange(2**D); return 1 - 2*((idx[:, None] >> np.arange(D)) & 1)  # bit i = coordinate i, -1 if set
def mask(S): return sum(1 << i for i in S)
# --- f* spectrum, chain, Odd, margin, W^{<cd} ---
for d in [7, 9, 11, 13]:
    D = d + 1; X = cube(D); x = X[:, :d]; z = X[:, d]
    Y = np.cumprod(x, axis=1); f1 = np.sign(Y.sum(1)); fs = np.where(z > 0, f1, Y[:, -1])
    c = wht(fs)  # c[mask] = E[f chi_mask], since chi_S(x)=prod x_i = (-1)^{popcount(idx & S)}
    m1 = math.comb(d-1, (d-1)//2) / 2**(d-1)
    ok_chain = all(abs(c[mask(range(t))] - (m1/2 + (t == d)/2)) < 1e-12 and abs(c[mask(range(t)) | (1 << d)] - (m1/2 - (t == d)/2)) < 1e-12 for t in range(1, d+1))
    Odd = mask(range(0, d, 2))
    G = sorted({S & ((1 << d) - 1) for S in range(2**D) if abs(c[S]) > m1/8 + 1e-12})
    expected = sorted({mask(range(t)) for t in range(1, d+1)} | {Odd})
    # margin of a*, b*
    val = 0.5*(1+z)*Y[:, :-1].sum(1) + Y[:, -1]
    marg = (val*fs).min()
    # 1/m1^2 vs 2(d-1)
    # exact low-degree weight for c=1/2 with cd = (d+1)/2
    deg = np.array([bin(S).count('1') for S in range(2**D)])
    k = (d+1)//2
    Wlow = (c[deg < k]**2).sum(); boundclaim = (k-1)*m1**2/2; boundmine = (2*k-3)*m1**2/4
    print(f"d={d}: chain coefs ok {ok_chain}; G==chain+Odd {G==expected}; margin {marg}; 1/m1^2={1/m1**2:.3f} <= 2(d-1)={2*(d-1)}; W^<{k}={Wlow:.4f}, claim>=(cd-1)m1^2/2={boundclaim:.4f}, (2cd-3)m1^2/4={boundmine:.4f}; dist(f*,chi)={np.mean(fs!=Y[:,-1]):.4f} vs (1-m1)/4={(1-m1)/4:.4f}")
    # check lower bound restricted to chain sets only (which is what the claim's argument counts)
    chainlow = sum(c[mask(range(t))]**2 for t in range(1, k)) + sum(c[mask(range(t)) | (1 << d)]**2 for t in range(0, k-1))
    print(f"      chain-only low weight (|S|<{k}) = {chainlow:.4f}")
# --- T2 ---
for k in [2, 3]:
    d = 2**k; D = d + k + 1; X = cube(D); x = X[:, :d]; w = X[:, d:d+k]; z = X[:, d+k]
    a = (((w < 0).astype(int)) * (1 << np.arange(k))).sum(1) + 1  # a(w) in [d]
    Y = np.cumprod(x, axis=1)
    T2 = np.where(z > 0, Y[np.arange(len(X)), a-1], Y[:, -1]*np.prod(w, axis=1))
    c = wht(T2); supp = [S for S in range(2**D) if abs(c[S]) > 1e-12]
    mags = [abs(c[S]) for S in supp]
    def stair(S):
        if bin(S).count('1') <= 1: return True
        return any((S & ~(1 << i)) in sset for i in range(D) if S >> i & 1)
    sset = set(supp)
    print(f"T2 d={d}: sparsity {len(supp)} (2d^2={2*d*d}); min {min(mags):.4f} (1/(2d)={1/(2*d):.4f}) max {max(mags):.4f}; staircase {all(stair(S) for S in supp)}; parseval {sum(m*m for m in mags):.4f}")
# --- g_lambda coefficient formula ---
for d, cc in [(11, 3), (11, 5), (15, 5)]:
    X = cube(d); Y = np.cumprod(X, axis=1); g = np.sign(Y[:, :-1].sum(1) + cc*Y[:, -1])
    c = wht(g); q = math.comb(d-2, (d-2+cc)//2)/2**(d-2)
    W = Y[:, :-1].sum(1)
    print(f"g d={d} c={cc}: chain coefs {[round(c[mask(range(t))],4) for t in (1, d//2, d-1)]} q={q:.4f}; top {c[mask(range(d))]:.4f} vs P(|W|<c)={np.mean(np.abs(W)<cc):.4f}; P(g!=chi)={np.mean(g!=Y[:,-1]):.4f} vs P(|W|>c)/2={np.mean(np.abs(W)>cc)/2:.4f}")
# --- tension (a): max_{S != A} |f^(S)| <= 2 dist(f, chi_A) on random functions near parity ---
rng = np.random.default_rng(1); D = 10; X = cube(D); chi = np.prod(X, 1); worst = 0
for _ in range(200):
    f = chi.copy(); flip = rng.random(2**D) < rng.random()*0.2; f[flip] *= -1
    c = wht(f); A = 2**D - 1; others = np.abs(np.delete(c, A)).max(); worst = max(worst, others/(2*np.mean(flip)) if flip.any() else 0)
print("tension (a): max ratio |f^(S)|/(2 dist) over trials =", round(worst, 4))
# 1/m1^2 <= 2(d-1) analytic check via C(2m,m)/4^m >= 1/(2 sqrt m) for m up to 5000
print("C(2m,m)^2*4m >= 16^m for m<=1500:", all(math.comb(2*m, m)**2 * 4*m >= 16**m for m in range(1, 1501)))
