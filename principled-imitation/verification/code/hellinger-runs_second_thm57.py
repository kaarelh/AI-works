"""Second check of proofs/hellinger-runs.md: Theorem 5.7 (weights w^lambda, posterior and
lambda-MAP, human inside or outside the class) by enumeration of all data sets; also Theorem 5.5
for comparison; and Example 4.6 for the averaged law (per-call mixture).
A 'run' is an outcome in a finite set Y (Theorem 5.7 only uses that runs are i.i.d. with law Q*).
Independent implementation."""
import itertools, math, random
import numpy as np

rng = np.random.default_rng(57)
prng = random.Random(57)

def A(qs, qn, a):
    m = qs > 0
    return float(np.sum(qs[m] ** (1 - a) * qn[m] ** a))

def H2(p, q):
    return 1 - float(np.sum(np.sqrt(p * q)))

def KL(p, q):
    m = p > 0
    if np.any(q[m] == 0):
        return math.inf
    return float(np.sum(p[m] * np.log(p[m] / q[m])))

def rand_dist(Y, zero=0.3):
    v = rng.dirichlet([prng.choice([0.3, 1, 3])] * Y)
    if prng.random() < zero:
        v[prng.randrange(Y)] = 0
        if v.sum() == 0:
            v[0] = 1
        v /= v.sum()
    return v

worst_post = 0; worst_map = 0; worst_post_h = 0; worst_map_h = 0; worst_temp = 0
ninst = 0
for inst in range(2500):
    Y = prng.choice([2, 3, 4])
    M = prng.choice([2, 3, 4, 5])
    N = prng.choice([1, 2, 3, 4, 5])
    if Y ** N > 1100:
        N = 3
    lam = prng.choice([1.05, 1.3, 1.5, 2.0, 3.0, 6.0])
    a = 1 / lam
    hyps = [rand_dist(Y) for _ in range(M)]
    w = rng.dirichlet([1] * M) * prng.choice([1.0, 0.8, 0.3])
    w = np.maximum(w, 1e-12)
    inside = prng.random() < 0.4
    if inside:
        qs = hyps[prng.randrange(M)].copy()
    else:
        qs = rand_dist(Y, zero=0.2)
    # rhs: min over nu* with finite KL
    rhs = min((math.log(1 / w[i]) / N + KL(qs, hyps[i]) / lam) for i in range(M))
    if not math.isfinite(rhs):
        continue
    rhs_temp = min((math.log(1 / w[i]) / N + a * KL(qs, hyps[i])) for i in range(M))
    negA = np.array([-math.log(A(qs, h, a)) if A(qs, h, a) > 0 else math.inf for h in hyps])
    hh = np.array([H2(qs, h) for h in hyps])
    Epost = 0; Emap = 0; Epost_h = 0; Emap_h = 0; Etemp = 0
    for data in itertools.product(range(Y), repeat=N):
        pr = float(np.prod([qs[y] for y in data]))
        if pr == 0:
            continue
        lik = np.array([float(np.prod([h[y] for y in data])) for h in hyps])
        sc = w ** lam * lik
        if sc.sum() == 0:
            raise RuntimeError("posterior undefined although some nu* has finite KL")
        post = sc / sc.sum()
        Epost += pr * float(np.sum(post[post > 0] * negA[post > 0]))
        Epost_h += pr * float(np.sum(post * hh))
        mxs = sc.max()
        maps = [i for i in range(M) if sc[i] >= mxs * (1 - 1e-12)]
        Emap += pr * max(negA[i] for i in maps)       # worst maximiser
        Emap_h += pr * max(hh[i] for i in maps)
        sct = w * lik ** a
        pt = sct / sct.sum()
        Etemp += pr * float(np.sum(pt[pt > 0] * np.array([-math.log(A(qs, h, a)) if A(qs, h, a) > 0 else 0 for h in hyps])[pt > 0]))
    ninst += 1
    den = 2 * min(a, 1 - a)
    worst_post = max(worst_post, Epost / rhs)
    worst_map = max(worst_map, Emap / rhs)
    worst_post_h = max(worst_post_h, Epost_h / (rhs / den))
    worst_map_h = max(worst_map_h, Emap_h / (rhs / den))
    worst_temp = max(worst_temp, Etemp / rhs_temp)
print("Theorem 5.7, %d random instances (|Y| <= 4 outcomes per run, up to 5 hypotheses, N <= 5 runs, lambda in {1.05,...,6}, 40%% with the human in the class), all data sets enumerated; largest ratios of the two sides (must be <= 1):" % ninst)
print("  E[posterior mean of -ln A_(1/lam)] / rhs = %.4f ; E[-ln A_(1/lam)(MAP), worst maximiser] / rhs = %.4f" % (worst_post, worst_map))
print("  E[posterior mean of H2] / (rhs/(2 min(1/lam,1-1/lam))) = %.4f ; same for the MAP = %.4f" % (worst_post_h, worst_map_h))
print("  Theorem 5.5 (tempered posterior, alpha = 1/lam): E[posterior mean of -ln A_alpha] / rhs = %.4f" % worst_temp)

# a near-extreme instance for Theorem 5.7: one hypothesis equal to the human, weight w, others far
print("  extreme instances (human in the class with small weight, one far alternative):")
for lam in (1.05, 2.0, 6.0):
    a = 1 / lam
    for wP in (0.5, 0.05, 0.001):
        qs = np.array([0.5, 0.5]); hyps = [qs, np.array([1.0, 0.0])]
        w = np.array([wP, 1 - wP])
        N = 6
        rhs = math.log(1 / wP) / N
        negA = [-math.log(A(qs, h, a)) for h in hyps]
        Epost = 0; Emap = 0
        for data in itertools.product(range(2), repeat=N):
            pr = 0.5 ** N
            lik = np.array([float(np.prod([h[y] for y in data])) for h in hyps])
            sc = w ** lam * lik; post = sc / sc.sum()
            Epost += pr * float(np.sum(post * negA))
            mxs = sc.max(); maps = [i for i in range(2) if sc[i] >= mxs * (1 - 1e-12)]
            Emap += pr * max(negA[i] for i in maps)
        print("    lam=%g w(P)=%g N=6: posterior %.4f, MAP %.4f (ratios to rhs)" % (lam, wP, Epost / rhs, Emap / rhs))

# ---------- Example 4.6 (per-call mixture; averaged law) ----------
print("Example 4.6, exact, averaged law Qbar_M = (1/N) sum_t Q_{M_t}, B = 2N, worst and best over all sequences of top-level inputs:")
for N in (1, 2, 3, 4):
    B = 2 * N
    for L in (1, 3, 6, 12):
        kls = []
        for zs in itertools.product(range(B), repeat=N - 1 if N > 1 else 0):
            # omega_t for t = 1..N: v_t = distinct among first t-1
            Pzero = np.zeros(B)  # Qbar(zeros | z)
            for t in range(1, N + 1):
                visited = set(zs[:t - 1])
                om = 1 / (2 * B - len(visited))
                for z in range(B):
                    Pzero[z] += ((1 - om) ** L if z not in visited else 1.0) / N
            kls.append(float(np.mean(np.log(1 / Pzero))))
        print("    N=%d L=%2d: min over data of KL(Q_f||Qbar_M) = %.5f ; L/(8N) = %.5f ; ln2/N = %.5f" % (N, L, min(kls), L / (8 * N), math.log(2) / N))
