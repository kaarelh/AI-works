"""Claim C, Proposition C.4 and Appendix C.B (standard fan-in prior; Section C.8 item 5): the reference distribution q_t of
NNG/works-in-progress/slt-finite-sample/README.md Section 3.

Prior pi_N: W^1 ~ N(0,1/D) (D=d+1), W^l ~ N(0,1/N), v ~ N(0,1/N).  q_t: product Gaussian centred at the zero-padded
teacher; variance multiplied by t on (incoming weights of the first m neurons of every hidden layer) and (all readout weights).
Checks: (1) KL(q_t||pi_N) computed coordinatewise equals E_N + (Q/2)(t-1-log t);
        (2) Monte Carlo: max over test inputs of E_{q_t}|z_w(x)-g(x)|^2 <= A t,  A = sum_{j<L} (m^2 B^2)^j.
"""
import numpy as np
rng = np.random.default_rng(4)

def kl_gauss(m1, v1, v0):  # KL(N(m1,v1) || N(0,v0)) per coordinate
    return 0.5 * (v1 / v0 + m1 ** 2 / v0 - 1 - np.log(v1 / v0))

for (d, m, B, L, N, t) in [(3, 2, 1.0, 2, 20, 0.01), (3, 2, 1.0, 3, 20, 0.01), (2, 3, 1.5, 4, 30, 1e-3), (4, 1, 2.0, 3, 50, 0.05)]:
    D = d + 1
    T = [rng.uniform(-B, B, (m, D))] + [rng.uniform(-B, B, (m, m)) for _ in range(L - 2)]
    u = rng.uniform(-B, B, m)
    # zero-padded teacher
    M1 = np.zeros((N, D)); M1[:m] = T[0]
    Ml = []
    for Tl in T[1:]:
        A_ = np.zeros((N, N)); A_[:m, :m] = Tl; Ml.append(A_)
    mv = np.zeros(N); mv[:m] = u
    # prior variances and q_t variances
    V1 = np.full((N, D), 1 / D); Q1 = V1.copy(); Q1[:m] *= t
    Vl = [np.full((N, N), 1 / N) for _ in Ml]; Ql = [V.copy() for V in Vl]
    for Qm in Ql: Qm[:m] *= t
    Vv = np.full(N, 1 / N); Qv = Vv * t
    KL = kl_gauss(M1, Q1, V1).sum() + sum(kl_gauss(Mm, Qm, Vm).sum() for Mm, Qm, Vm in zip(Ml, Ql, Vl)) + kl_gauss(mv, Qv, Vv).sum()
    EN = 0.5 * (D * np.sum(T[0] ** 2) + N * sum(np.sum(Tl ** 2) for Tl in T[1:]) + N * np.sum(u ** 2))
    Qc = m * D + (L - 2) * m * N + N
    KLf = EN + Qc / 2 * (t - 1 - np.log(t))
    # Monte Carlo of the expected squared error
    X = rng.uniform(-1, 1, (d, 30)); X[:, :min(30, 2 ** d)] = np.sign(X[:, :min(30, 2 ** d)])
    Xb = np.vstack([np.ones(X.shape[1]), X])
    def fwd(W1, Ws, v):
        h = np.tanh(W1 @ Xb)
        for W in Ws: h = np.tanh(W @ h)
        return v @ h
    g = fwd(T[0], T[1:], u)
    R = 4000
    err = np.zeros(X.shape[1])
    for _ in range(R):
        W1 = M1 + rng.standard_normal((N, D)) * np.sqrt(Q1)
        Ws = [Mm + rng.standard_normal((N, N)) * np.sqrt(Qm) for Mm, Qm in zip(Ml, Ql)]
        v = mv + rng.standard_normal(N) * np.sqrt(Qv)
        err += (fwd(W1, Ws, v) - g) ** 2
    err /= R
    A = sum((m * m * B * B) ** j for j in range(L))
    print(f"d={d} m={m} B={B} L={L} N={N} t={t}: KL coordinatewise={KL:.6f} formula={KLf:.6f} | max_x E|z-g|^2={err.max():.3e} <= A t={A*t:.3e}: {err.max() <= A*t}")
