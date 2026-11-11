"""Check Lemma 2.1(2) of redteam.md (depth two, H = 1) on small cubes.

1. Exact mixture: r = sum_S rhat(S) chi_S with chi_S = c_{k,a_d}^{-1} E_u[(prod u) tanh(a_d(sum_{j in S} u_j x_j - b_k))],
   chi_empty = tanh(xbar_0)/tanh(1). Check total weight <= A_0 = 3 sqrt(d) ||r||_2, row norms <= F_d,
   and that the signed mixture reproduces r exactly on the cube.
2. Hoeffding sampling with m_0 = ceil(8 A_0^2 ln(2M)/a^2) + 1 features: sup |g - r| <= a/2.
3. Width-N network (N >= m_0, balanced groups), readout t A_0/(m_0 k_j): output = t g exactly and
   kappa_N = (d/N)||W1||_F^2 + N ||v||^2 <= d F_d + 2 t^2 A_0^2.
"""
import itertools, math
import numpy as np

rng = np.random.default_rng(7)

def cube(d):
    return np.array(list(itertools.product([-1.0, 1.0], repeat=d)))

def coeff(k, a):
    bk = 0 if k % 2 == 1 else 1
    xs = np.array(list(itertools.product([-1.0, 1.0], repeat=k)))
    return float(np.mean(np.prod(xs, axis=1)*np.tanh(a*(xs.sum(axis=1)-bk))))

def build_mixture(d, r):
    X = cube(d); M = len(X)
    Xbar = np.hstack([np.ones((M, 1)), X])
    ad = max(1.0, 0.5*math.log(4*math.sqrt(2*d)))
    FD = 1 + (d+1)*(d+2)**2
    rows, wts = [], []
    for k in range(0, d+1):
        for S in itertools.combinations(range(d), k):
            chi = np.prod(X[:, list(S)], axis=1) if k > 0 else np.ones(M)
            rh = float(np.mean(r*chi))
            if abs(rh) < 1e-15:
                continue
            if k == 0:
                w = abs(rh)/math.tanh(1.0); s = math.copysign(1.0, rh)
                om = np.zeros(d+1); om[0] = s
                rows.append(om); wts.append(w)
                continue
            bk = 0 if k % 2 == 1 else 1
            ck = coeff(k, ad)
            for u in itertools.product([-1.0, 1.0], repeat=k):
                sgn = math.copysign(1.0, rh/ck*np.prod(u))
                om = np.zeros(d+1); om[0] = -ad*bk
                for j, uj in zip(S, u):
                    om[1+j] = ad*uj
                rows.append(sgn*om); wts.append(abs(rh/ck)/2**k)
    rows = np.array(rows); wts = np.array(wts)
    recon = (np.tanh(Xbar @ rows.T)) @ wts
    return X, Xbar, rows, wts, recon, FD

for d in [4, 5, 6]:
    X = cube(d); M = len(X)
    # r = ybar 1_T from a cube sample with n = M
    n = M
    idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
    k = np.bincount(idx, minlength=M).astype(float); Ssum = np.bincount(idx, weights=y, minlength=M)
    T = k > 0; r = np.zeros(M); r[T] = Ssum[T]/k[T]
    Q = float(np.sum(r**2))
    A0 = 3*math.sqrt(d)*math.sqrt(Q)
    X, Xbar, rows, wts, recon, FD = build_mixture(d, r)
    assert np.allclose(recon, r, atol=1e-10), np.max(np.abs(recon-r))
    tot = wts.sum()
    rownorm = np.max(np.sum(rows**2, axis=1))
    print(f"d={d}: exact mixture ok; total weight {tot:.3f} <= A0 {A0:.3f}: {tot <= A0+1e-12}; "
          f"max row norm^2 {rownorm:.2f} <= F_d {FD}: {rownorm <= FD}")
    # probability law pi: weights/A0 on rows, leftover on zero row
    p = np.append(wts/A0, 1 - tot/A0); allrows = np.vstack([rows, np.zeros(d+1)])
    for a in [1.0, 0.5]:
        m0 = math.ceil(8*A0**2*math.log(2*M)/a**2) + 1
        ok = 0; trials = 5; last = None
        for trial in range(trials):
            pick = rng.choice(len(p), size=m0, p=p)
            feats = np.tanh(Xbar @ allrows[pick].T)          # M x m0
            g = A0*feats.mean(axis=1)
            err = np.max(np.abs(g - r))
            ok += err <= a/2
            last = (pick, g, err)
        pick, g, err = last
        # width-N network, N >= m0 with uneven groups
        for N in [m0, int(2.5*m0)+3]:
            sizes = np.full(m0, N//m0); sizes[:N % m0] += 1
            assert sizes.sum() == N and sizes.min() >= N/(2*m0)
            W1 = np.repeat(allrows[pick], sizes, axis=0)
            for t in [1.0, 0.37, 0.05]:
                v = np.repeat(t*A0/(m0*sizes), sizes)
                z = np.tanh(Xbar @ W1.T) @ v
                kappa = (d/N)*np.sum(W1**2) + N*np.sum(v**2)
                bound = d*FD + 2*t**2*A0**2
                assert np.allclose(z, t*g)
                assert kappa <= bound + 1e-9, (kappa, bound)
        print(f"   a={a}: m0={m0}, sup|g-r| <= a/2 in {ok}/{trials} draws (last err {err:.3f}, a/2={a/2}); "
              f"network output = t g exactly; kappa <= dF_d + 2t^2A0^2 at N in {{m0, 2.5 m0+3}}, t in {{1,.37,.05}}")
