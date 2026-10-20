import numpy as np
from math import comb
from t_kernel import kraw
rng = np.random.default_rng(7)
def hadamard_chars(d):
    xs = ((np.arange(2**d)[:,None] >> np.arange(d)) & 1)  # bits
    X = 1-2*xs
    return X
for d in [10, 12]:
    lam = np.load(f"lam_d{d}.npy"); Kr = kraw(d)
    for r in [1, 3, 5]:
        lamt = np.array([lam[q] if q > r else 0.0 for q in range(d+1)])
        Qk = np.array([sum(comb(d,q)*lamt[q]*Kr[q,k]/comb(d,k) for q in range(d+1)) for k in range(d+1)])
        # Q(k) = sum_q lam_q * sum_{|U|=q} chi_U(x)chi_U(y), dist k -> K_k(q)... use symmetric relation
        Qk = np.array([sum(lamt[q]*sum((-1)**j*comb(k,j)*comb(d-k,q-j) for j in range(0,min(k,q)+1) if q-j<=d-k) for q in range(d+1)) for k in range(d+1)])
        tau = Qk[0]; tau2 = sum(comb(d,q)*lamt[q] for q in range(d+1))
        # exact E y_i y_j Q(X_i,X_j), i != j: (1/M) sum_k C(d,k) (-1)^k Q(k)
        Eyy = sum(comb(d,k)*(-1)**k*Qk[k] for k in range(d+1))/2**d
        print(f"d={d} r={r}: tau={tau:.6e} (check {tau2:.6e}); E yyQ offdiag={Eyy:.6e}, lambda_d={lam[d]:.6e}, rel={Eyy/lam[d]-1:.1e}; tau/(2^(d-1) lam_d)={tau/(2**(d-1)*lam[d]):.3e}")
        # Prop 4 adversarial: random & structured samples, plus greedy local search minimizing ratio
        def ratio(S):
            Xs = S
            H = np.bitwise_count(Xs[:,None]^Xs[None,:]).astype(int)
            ev = np.linalg.eigvalsh(Qk[H])[-1]
            return ev/max(len(S)*lam[r+1], tau)
        worst = np.inf
        for n in [2, 5, 20, 100, 400, 1000]:
            for trial in range(5):
                S = rng.integers(0, 2**d, size=n, dtype=np.int64)
                worst = min(worst, ratio(S))
            # structured: subcube with first k coords free, Hamming ball, distinct-all
            for k in range(1, d+1):
                if 2**k >= n:
                    S = rng.choice(2**k, size=n, replace=(2**k < n)).astype(np.int64)
                    worst = min(worst, ratio(S)); break
        # greedy local search n=30
        for n in [8, 30, 120]:
            S = rng.integers(0, 2**d, size=n, dtype=np.int64); cur = ratio(S)
            for it in range(1500):
                i = rng.integers(n); old = S[i]; S[i] = rng.integers(2**d)
                new = ratio(S)
                if new <= cur: cur = new
                else: S[i] = old
            worst = min(worst, cur)
        print(f"     Prop4 min ratio lambda_max/max(n lam_(r+1),tau) = {worst:.4f}")
