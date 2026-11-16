# Attack on one-mind.md, Example 3.1: which member does a deterministic (MAP) selection pick?
# Exact Bayes over H = {P} u F, F = all functions [N_z] -> {0,1}, w(P)=1/2, w(s)=1/2 prod_z P(s(z)|z).
import itertools, random
import numpy as np
Nz, eps = 10, 0.1
F = np.array(list(itertools.product([0,1], repeat=Nz)))          # 1024 x 10
pz = lambda y: (1-eps) if y==1 else eps
wF = 0.5*np.prod(np.where(F==1, 1-eps, eps), axis=1)
rng = random.Random(1)
trials, maxq = 2000, 8
count_map_P = np.zeros(maxq+1); count = np.zeros(maxq+1)
post_P = np.zeros(maxq+1); tv_map = np.zeros(maxq+1)
for tr in range(trials):
    zs = rng.sample(range(Nz), maxq)                               # distinct questions
    ys = [1 if rng.random() < 1-eps else 0 for _ in zs]
    for q in range(maxq+1):
        likP = np.prod([pz(y) for y in ys[:q]]) if q else 1.0
        mask = np.ones(len(F), bool)
        for z,y in zip(zs[:q], ys[:q]): mask &= (F[:,z]==y)
        aP = 0.5*likP; aF = wF*mask
        best_s = aF.max()
        count[q] += 1; count_map_P[q] += (aP > best_s)
        post_P[q] += aP/(aP+aF.sum())
print("Nz=%d eps=%.2f trials=%d (distinct questions)"%(Nz,eps,trials))
print(" q   frac(MAP member = P)   mean posterior of P")
for q in range(maxq+1):
    print("%2d   %.4f                %.6f"%(q, count_map_P[q]/count[q], post_P[q]/count[q]))
# run law of P itself is Q_P, TV 0; a member s has TV = mean_z (1 - P(s(z)|z)^3)
