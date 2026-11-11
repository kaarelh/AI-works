"""Monte Carlo sanity check of the progressive-mixture oracle inequality
    E L_D(fbar_n) <= min_j L_D(f_j) + log(M) / (eta (n+1)),   eta = 1/8,
for squared loss with predictions and labels in [-1,1], uniform prior on a finite
dictionary {f_1..f_M}, fbar_n = (1/(n+1)) sum_{t=0}^n (posterior mean after t samples).
Also reports the plain posterior mean after n samples (no progressive averaging)
and the Gibbs (random draw) risk, for comparison only.
"""
import numpy as np

rng = np.random.default_rng(1)
m, M, eta = 12, 40, 1.0 / 8
px = np.full(m, 1.0 / m)                       # uniform inputs on a finite domain
regf = rng.uniform(-0.6, 0.6, size=m)           # eta(x) = E[y|x]
F = rng.uniform(-1, 1, size=(M, m))             # dictionary values in [-1,1]

def label(x):                                   # y in {-1,1} with mean regf[x]
    return np.where(rng.random(x.shape) < (1 + regf[x]) / 2, 1.0, -1.0)

def risk(fvals):                                # exact L_D for f with values in [-1,1]
    # E (f(x)-y)^2 = E[(f-eta)^2] + E Var(y|x), Var = 1 - eta^2 for +-1 labels
    return np.sum(px * ((fvals - regf) ** 2 + 1 - regf ** 2), axis=-1)

LF = risk(F)
best = LF.min()
for n in [5, 20, 60, 200]:
    reps = 4000
    acc_prog = acc_plain = acc_gibbs = 0.0
    for _ in range(reps):
        x = rng.integers(0, m, size=n)
        yv = label(x)
        cum = np.zeros(M)
        prog = np.zeros(m)
        for t in range(n + 1):
            w = np.exp(-eta * (cum - cum.min())); w /= w.sum()
            prog += w @ F
            if t < n:
                cum += (F[:, x[t]] - yv[t]) ** 2
        prog /= (n + 1)
        acc_prog += risk(prog)
        acc_plain += risk(w @ F)
        acc_gibbs += w @ LF
    bound = best + np.log(M) / (eta * (n + 1))
    print(f"n={n:4d}: E L(prog)={acc_prog/reps:.4f}  E L(plain mean)={acc_plain/reps:.4f}"
          f"  E Gibbs={acc_gibbs/reps:.4f}  min_j L={best:.4f}  bound={bound:.4f}"
          f"  holds={acc_prog/reps <= bound}")
