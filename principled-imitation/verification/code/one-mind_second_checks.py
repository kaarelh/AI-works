"""Second checker's numerical tests for part one-mind (proofs/one-mind.md).

Independent code (written without reading the editor's or the verifiers' scripts).
Parts:
  S1  Theorem 3.8, Step 4 (and the use of Corollary 2.3 of hellinger-runs) on random
      instances with exact run laws, including semimeasures and inputs that depend on answers.
  S2  Theorem 3.8 (a), (b), (c): Monte Carlo of the mixture-driven rehearsal with h_t, kappa_t
      computed exactly in every round.
  S3  Theorem 3.8 (a) and Remark 3.9 exactly on a class of two coins (L = 1).
  S4  Proposition 3.5: enumeration of F'_z (R = 2) for (i)-(iv); a direct simulation of the
      actual rehearsal (per-input posteriors tracked exactly) for the lifetimes of F';
      the arithmetic of the bound 0.07.
  S5  Example 3.6: random codebooks.
  S6  Proposition 4.6: exact probabilities against (9/32) L/n on a grid; the mixture's per-call bound.
  S7  Proposition 5.7: posterior-draw-driven rehearsal on random classes of functions, exact
      u-bar_t, d'_t, u(g); frequencies of failure of (a), (b), (c).
  S8  Arithmetic: constants of Theorem 3.8 and Remark 3.9; S(3,1) of Proposition 2.5;
      the constant 0.57 of Corollary 4.4(b); Corollary 4.4(a)'s (4e/n)^(L/4).
Run: python3 one-mind_second_checks.py  (about a few minutes)
"""
import itertools, math, random
import numpy as np

LN2 = math.log(2)

# ---------------------------------------------------------------- generic scaffold
class Scaffold:
    """z uniform on range(nz); next_j(z, y_<j) given by a random table into range(nx) or STOP (-1)."""
    def __init__(self, rng, nz, nx, ny, L, stop_p=0.2):
        self.nz, self.nx, self.ny, self.L = nz, nx, ny, L
        self.table = {}
        self.rng = rng
        self.stop_p = stop_p
    def nxt(self, z, ys):
        key = (z, tuple(ys))
        if len(ys) >= self.L:
            return -1
        if key not in self.table:
            if len(ys) > 0 and self.rng.random() < self.stop_p:
                self.table[key] = -1
            else:
                self.table[key] = self.rng.randrange(self.nx)
        return self.table[key]

def run_law(sc, A, nyA):
    """A: function (x) -> prob vector over answers (length nyA). Returns dict run->prob and
    list of (run prefix prob, inputs) for expectations. Runs enumerated exactly."""
    out = {}
    def rec(z, ys, p):
        x = sc.nxt(z, ys)
        if x < 0:
            out[(z, tuple(ys))] = out.get((z, tuple(ys)), 0.0) + p
            return
        pv = A(x)
        for y in range(nyA):
            if pv[y] > 0:
                rec(z, ys + [y], p * pv[y])
    for z in range(sc.nz):
        rec(z, [], 1.0 / sc.nz)
    return out

def exp_sum_along(sc, A, nyA, g):
    """E_{Q_A} sum_j g(x_j)."""
    tot = 0.0
    def rec(z, ys, p):
        nonlocal tot
        x = sc.nxt(z, ys)
        if x < 0:
            return
        tot += p * g(x)
        pv = A(x)
        for y in range(nyA):
            if pv[y] > 0:
                rec(z, ys + [y], p * pv[y])
    for z in range(sc.nz):
        rec(z, [], 1.0 / sc.nz)
    return tot

def H2(p, q):
    return 1.0 - float(np.sum(np.sqrt(np.asarray(p) * np.asarray(q))))

def H2_laws(a, b):
    keys = set(a) | set(b)
    return 1.0 - sum(math.sqrt(a.get(k, 0.0) * b.get(k, 0.0)) for k in keys)

def TV_laws(a, b):
    keys = set(a) | set(b)
    return 0.5 * sum(abs(a.get(k, 0.0) - b.get(k, 0.0)) for k in keys)

def rand_kernel(rng_np, nx, ny, kind):
    """kind: 'sampler', 'semi' (missing mass to the last answer = bottom), 'func', 'tilt'."""
    K = np.zeros((nx, ny + 1))
    for x in range(nx):
        if kind == 'func':
            K[x, rng_np.integers(ny)] = 1.0
        else:
            v = rng_np.dirichlet(np.ones(ny) * 0.7)
            if kind == 'semi':
                miss = rng_np.uniform(0, 0.4)
                K[x, :ny] = v * (1 - miss); K[x, ny] = miss
            else:
                K[x, :ny] = v
    return K

# ---------------------------------------------------------------- S1
def S1(trials=1500, seed=1):
    print("S1  Theorem 3.8, Step 4: H2(Q_nu,Q_P) <= 16 L h + 24 kappa, and Corollary 2.3 for (M, nu)")
    rng = random.Random(seed); rnp = np.random.default_rng(seed)
    worst = 0.0; worst_c23 = 0.0; worst_c23b = 0.0; nviol = 0
    for tr in range(trials):
        L = rng.choice([1, 2, 3])
        nx, ny, nz = rng.choice([2, 3, 5]), rng.choice([2, 3]), rng.choice([1, 2, 3])
        sc = Scaffold(rng, nz, nx, ny, L)
        P = rand_kernel(rnp, nx, ny, 'sampler')
        if rng.random() < 0.5:   # make P close to deterministic sometimes
            P = 0.9 * P + 0.1 * rand_kernel(rnp, nx, ny, 'func')
        nh = rng.choice([2, 4, 6])
        hyps = [P] + [rand_kernel(rnp, nx, ny, rng.choice(['sampler', 'semi', 'func', 'tilt']))
                      for _ in range(nh)]
        # tilted / perturbed humans, to get small distances
        for i in range(1, len(hyps)):
            if rng.random() < 0.5:
                lam = rng.uniform(0.0, 0.3)
                hyps[i] = (1 - lam) * P + lam * hyps[i]
        wts = rnp.dirichlet(np.ones(len(hyps)))
        if rng.random() < 0.5:
            wts[0] = max(wts[0], rng.uniform(0.3, 0.95)); wts /= wts.sum()
        M = np.tensordot(wts, np.array(hyps), axes=1)
        nyA = ny + 1
        QM = run_law(sc, lambda x: M[x], nyA)
        QP = run_law(sc, lambda x: P[x], nyA)
        kappa = exp_sum_along(sc, lambda x: M[x], nyA, lambda x: H2(P[x], M[x]))
        for nu in hyps[1:]:
            Qn = run_law(sc, lambda x: nu[x], nyA)
            h = exp_sum_along(sc, lambda x: M[x], nyA, lambda x: H2(nu[x], P[x])) / L
            lhs = H2_laws(Qn, QP)
            rhs = 16 * L * h + 24 * kappa
            if rhs > 1e-12:
                worst = max(worst, lhs / rhs)
            elif lhs > 1e-9:
                nviol += 1
            sMn = exp_sum_along(sc, lambda x: M[x], nyA, lambda x: H2(nu[x], M[x]))
            if sMn > 1e-12:
                worst_c23 = max(worst_c23, H2_laws(QM, Qn) / (4 * sMn))
        if kappa > 1e-12:
            worst_c23b = max(worst_c23b, H2_laws(QM, QP) / (4 * kappa))
    print(f"    {trials} instances: largest ratio H2(Q_nu,Q_P)/(16Lh+24kappa) = {worst:.4f};"
          f" largest ratio H2(Q_M,Q_nu)/(4 E_QM sum H2(nu,M)) = {worst_c23:.4f};"
          f" H2(Q_M,Q_P)/(4 kappa) = {worst_c23b:.4f}; cases with rhs=0 and lhs>0: {nviol}")
    assert worst <= 1 + 1e-9 and worst_c23 <= 1 + 1e-9 and worst_c23b <= 1 + 1e-9 and nviol == 0

# ---------------------------------------------------------------- S2
def S2(reps=200, n=400, seed=2, deltas=(0.5, 0.2)):
    print("S2  Theorem 3.8 (a),(b),(c): mixture-driven rehearsal, exact h_t and kappa_t each round")
    rng = random.Random(seed); rnp = np.random.default_rng(seed)
    for inst in range(3):
        L = [2, 3, 3][inst]
        nx, ny, nz = 4, 2, 2
        sc = Scaffold(rng, nz, nx, ny, L, stop_p=0.15)
        P = np.zeros((nx, ny + 1)); P[:, :ny] = rnp.dirichlet(np.ones(ny) * 2, size=nx)
        hyps = [P]
        # fill-ins (functions), patched human, tilted humans, random samplers, semimeasure
        for _ in range(6):
            hyps.append(rand_kernel(rnp, nx, ny, 'func'))
        for lam in (0.05, 0.15, 0.3):
            hyps.append((1 - lam) * P + lam * rand_kernel(rnp, nx, ny, 'func'))
        for _ in range(3):
            hyps.append(rand_kernel(rnp, nx, ny, 'sampler'))
        hyps.append(rand_kernel(rnp, nx, ny, 'semi'))
        hyps = np.array(hyps)
        H = len(hyps)
        w = rnp.dirichlet(np.ones(H)) * 0.95
        w[0] = 0.12; w = w / w.sum() * 0.95
        K = math.log2(1 / w[0])
        nyA = ny + 1
        QP = run_law(sc, lambda x: P[x], nyA)
        Qh = [run_law(sc, lambda x, k=k: hyps[k][x], nyA) for k in range(H)]
        H2run = np.array([H2_laws(Qh[k], QP) for k in range(H)])
        H2call = np.array([[H2(hyps[k][x], P[x]) for x in range(nx)] for k in range(H)])
        fails = {d: [0, 0, 0, 0] for d in deltas}   # (a) max, (a) draw, (b), (c)
        maxH2 = 0.0
        for r in range(reps):
            logw = np.log(w).copy()
            sum_h = np.zeros(H); sum_k = 0.0
            for t in range(n):
                post = np.exp(logw - logw.max()); post /= post.sum()
                M = np.tensordot(post, hyps, axes=1)
                # visit measure of M: expected number of visits per input
                vis = np.zeros(nx)
                def g(x):
                    vis[x] += 0  # placeholder
                    return 0.0
                # compute expected visits exactly
                visits = np.array([exp_sum_along(sc, lambda xx: M[xx], nyA,
                                                 lambda xx, x0=x0: 1.0 if xx == x0 else 0.0)
                                   for x0 in range(nx)])
                sum_h += (H2call @ visits) / L
                sum_k += float(sum(visits[x] * H2(P[x], M[x]) for x in range(nx)))
                # sample a run of M, choose J, ask
                z = rng.randrange(nz); ys = []; xs = []
                while True:
                    x = sc.nxt(z, ys)
                    if x < 0: break
                    y = rnp.choice(nyA, p=M[x] / M[x].sum())
                    xs.append(x); ys.append(int(y))
                J = rng.randrange(1, L + 1)
                if J <= len(xs):
                    x = xs[J - 1]
                    y = rnp.choice(nyA, p=P[x])
                    with np.errstate(divide='ignore'):
                        logw = logw + np.log(hyps[:, x, y])
            ll = logw - np.log(w)   # log-likelihoods
            score2 = 2 * np.log(w) + ll
            nuhat = int(np.argmax(score2))
            p2 = np.exp(score2 - score2.max()); p2 /= p2.sum()
            nudraw = rnp.choice(H, p=p2)
            maxH2 = max(maxH2, H2run[nuhat])
            for d in deltas:
                a = K * LN2 + math.log(1 / d)
                if sum_h[nuhat] >= a: fails[d][0] += 1
                if sum_h[nudraw] >= a: fails[d][1] += 1
                if sum_k >= L * (0.5 * K * LN2 + math.log(1 / d)): fails[d][2] += 1
                if H2run[nuhat] >= L * (28 * K * LN2 + 40 * math.log(1 / d)) / n: fails[d][3] += 1
        bnd = {d: L * (28 * K * LN2 + 40 * math.log(1 / d)) / n for d in deltas}
        print(f"    instance {inst}: L={L}, |H|={H}, K={K:.2f} bits, n={n}, {reps} rehearsals;"
              f" largest H2(Q_nuhat,Q_P) = {maxH2:.2e} (bound of (c): " +
              ", ".join(f"{bnd[d]:.2f} at delta={d}" for d in deltas) + ")")
        for d in deltas:
            fa, fd, fb, fc = fails[d]
            print(f"      delta={d}: failure frequency (a) maximiser {fa/reps:.3f}, (a) draw {fd/reps:.3f},"
                  f" (b) {fb/reps:.3f}, (c) {fc/reps:.3f}   [allowed: delta, delta, delta, 2 delta]")
            assert fa / reps <= d + 3 * math.sqrt(d / reps) and fb / reps <= d + 3 * math.sqrt(d / reps)
            assert fc == 0

# ---------------------------------------------------------------- S3
def S3():
    print("S3  Theorem 3.8(a) and Remark 3.9 exactly: two coins, L = 1, one input")
    from math import comb, log, sqrt
    worst_mass = 0.0; worst_beat = 0.0; worst_mass39 = 0.0; worst_beat39 = 0.0; cases = 0
    worst_half = 0.0
    for p in (0.3, 0.5, 0.7, 0.9, 0.99):
        for q in (0.2, 0.4, 0.6, 0.8, 0.95, 1.0):
            if abs(p - q) < 1e-9: continue
            h = 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))
            for wP in (0.5, 0.1, 0.01, 0.001):
                wq = 1 - wP
                K = log(1 / wP, 2)
                for d in (0.5, 0.1, 0.01):
                    for variant in ('sq', 'plain', 'half'):
                        if variant == 'sq':
                            a = K * LN2 + log(1 / d)
                        elif variant == 'half':
                            a = 0.5 * (K * LN2 + log(1 / d))
                        else:
                            S = sqrt(wP) + sqrt(wq)
                            a = 0.5 * K * LN2 + log(S / d)
                        n = max(1, math.ceil(a / h))   # first n with q in A
                        if n > 4000: continue
                        mass = 0.0; beat = 0.0
                        e = 2 if variant in ('sq', 'half') else 1
                        for k in range(n + 1):
                            lpk = (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)
                                   + (k * math.log(p) if k else 0.0) + ((n - k) * math.log(1 - p) if n - k else 0.0))
                            pk = math.exp(lpk)
                            if pk == 0: continue
                            if q == 1.0 and k < n:
                                continue          # q refuted: contributes nothing to mass or beat
                            lq = (k * math.log(q) if k else 0.0) + ((n - k) * math.log(1 - q) if n - k else 0.0)
                            lp = (k * math.log(p) if k else 0.0) + ((n - k) * math.log(1 - p) if n - k else 0.0)
                            a1 = e * math.log(wq) + lq; a2 = e * math.log(wP) + lp
                            mass += pk / (1 + math.exp(min(700, a2 - a1)))
                            if a1 >= a2: beat += pk
                        if variant == 'sq':
                            worst_mass = max(worst_mass, mass / d); worst_beat = max(worst_beat, beat / d); cases += 1
                        elif variant == 'half':
                            worst_half = max(worst_half, mass / d)
                        else:
                            worst_mass39 = max(worst_mass39, mass / d); worst_beat39 = max(worst_beat39, beat / d)
    print(f"    {cases} cases. Weights squared, threshold of (a): max E[Pi2(A)]/delta = {worst_mass:.3f},"
          f" max Pr[q beats P]/delta = {worst_beat:.3f}.")
    print(f"    Remark 3.9 (plain weights, threshold 1/2 K ln2 + ln(S/delta)): max E[post(A)]/delta = {worst_mass39:.3f},"
          f" max Pr[q beats P]/delta = {worst_beat39:.3f}.")
    print(f"    Control: weights squared with half the threshold: max E[Pi2(A)]/delta = {worst_half:.3f}"
          f" (exceeds 1, so the test can see an error of a factor 2).")
    assert worst_mass <= 1 and worst_beat <= 1 and worst_mass39 <= 1 and worst_beat39 <= 1

# ---------------------------------------------------------------- S4
def F_members(R):
    """F_z of Proposition 3.2 for one z: dict with keys 'r','b2','b3' (bits at (r,2),(r,3) for r in R)."""
    mem = []
    for rstar in range(R):
        for c in (0, 1):
            others = [r for r in range(R) if r != rstar]
            for bits in itertools.product((0, 1), repeat=2 * len(others)):
                b2 = {rstar: c}; b3 = {rstar: c}
                for i, r in enumerate(others):
                    b2[r] = bits[2 * i]; b3[r] = bits[2 * i + 1]
                mem.append((rstar, b2, b3))
    return mem

def Fprime_members(R):
    """F'_z: F_z plus free bits at (r, b, b, 4) for r in R, b in {0,1}; star (=2) at (r,b,b',4), b!=b'."""
    out = []
    for (rs, b2, b3) in F_members(R):
        for bits in itertools.product((0, 1), repeat=2 * R):
            f4 = {}
            for i, (r, b) in enumerate(itertools.product(range(R), (0, 1))):
                f4[(r, b)] = bits[i]
            out.append((rs, b2, b3, f4))
    return out

def fp_answer(m, call, hist):
    rs, b2, b3, f4 = m
    if call == 1: return rs
    if call == 2: return b2[hist[0]]
    if call == 3: return b3[hist[0]]
    r, b, bb = hist
    return f4[(r, b)] if b == bb else 2   # 2 = star

def S4(seed=4):
    print("S4  Proposition 3.5")
    R = 2
    mem = Fprime_members(R)
    print(f"    |F'_z| for R=2: {len(mem)}")
    # (i): single-answer marginals under the uniform law on F'_z
    ok = True
    for r in range(R):
        for call, hist in [(1, ()), (2, (r,)), (3, (r,))]:
            vals = [fp_answer(m, call, hist) for m in mem]
            if call == 1:
                ok &= all(abs(vals.count(v) / len(vals) - 1 / R) < 1e-12 for v in range(R))
            else:
                ok &= abs(vals.count(1) / len(vals) - 0.5) < 1e-12
        for b in (0, 1):
            vals = [fp_answer(m, 4, (r, b, b)) for m in mem]
            ok &= abs(vals.count(1) / len(vals) - 0.5) < 1e-12
            vals = [fp_answer(m, 4, (r, b, 1 - b)) for m in mem]
            ok &= all(v == 2 for v in vals)
    # (iii): runs of members have y2 = y3
    ok3 = all(fp_answer(m, 2, (fp_answer(m, 1, ()),)) == fp_answer(m, 3, (fp_answer(m, 1, ()),)) for m in mem)
    print(f"    (i) single answers at x1,x2,x3 and at x4 with y2=y3 have the human's law; x4 with y2!=y3 is star: {ok}")
    print(f"    (iii) every member's run has y2 = y3: {ok3}")
    assert ok and ok3
    # (iv): exact run laws at a fresh z of the per-call mixture with mass wF on uniform F'_z
    def human_p(call, hist, y):
        if call == 1: return 1 / R
        return 0.5 if y in (0, 1) else 0.0
    def mem_p(call, hist, y):
        vals = [fp_answer(m, call, hist) for m in mem]
        return vals.count(y) / len(vals)
    for wF in (0.1, 0.5, 0.9, 1 - 2 ** -6):
        QP = {}; QM = {}
        for r in range(R):
            for y2 in (0, 1):
                for y3 in (0, 1):
                    for y4 in (0, 1, 2):
                        hists = [(), (r,), (r,), (r, y2, y3)]
                        ys = [r, y2, y3, y4]
                        pp = 1.0; pm = 1.0
                        for c in range(4):
                            hp = human_p(c + 1, hists[c], ys[c])
                            pp *= hp
                            pm *= (1 - wF) * hp + wF * mem_p(c + 1, hists[c], ys[c])
                        QP[tuple(ys)] = pp; QM[tuple(ys)] = pm
        tv = TV_laws(QP, QM)
        kl = sum(QP[k] * math.log(QP[k] / QM[k]) for k in QP if QP[k] > 0)
        print(f"    (iv) wF={wF:.4f}: TV = {tv:.6f} (formula {wF/2:.6f}), KL = {kl:.6f} (formula {0.5*math.log(1/(1-wF)):.6f})")
        assert abs(tv - wF / 2) < 1e-12 and abs(kl - 0.5 * math.log(1 / (1 - wF))) < 1e-12
    # direct simulation of the actual rehearsal: lifetime of F'
    rng = random.Random(seed)
    nm = len(mem)
    def simulate(K, driver, Nz=10 ** 9, tmax=10 ** 6):
        wP0 = 2.0 ** -K
        logodds = math.log((1 - wP0) / wP0)   # odds of F' against P (members uniform)
        alive = True
        posts = {}   # z -> list of consistent member indices
        for t in range(1, tmax + 1):
            z = rng.randrange(Nz)
            cons = posts.get(z)
            if cons is None:
                cons = list(range(nm))
            wF = 1 / (1 + math.exp(-logodds)) if alive else 0.0
            # produce a run
            ys = []
            if driver == 'draw':
                if rng.random() < wF:
                    m = mem[rng.choice(cons)]
                    for c in range(4):
                        hist = [(), (ys[0],) if ys else None, (ys[0],) if ys else None, tuple(ys[:3])][c]
                        ys.append(fp_answer(m, c + 1, hist))
                else:
                    ys = [rng.randrange(R), rng.randrange(2), rng.randrange(2), rng.randrange(2)]
            else:
                for c in range(4):
                    hist = [(), (ys[0],) if ys else None, (ys[0],) if ys else None, tuple(ys[:3])][c]
                    if rng.random() < wF:
                        ys.append(fp_answer(mem[rng.choice(cons)], c + 1, hist))
                    else:
                        ys.append(rng.randrange(R) if c == 0 else rng.randrange(2))
            J = rng.randrange(1, 5)
            hist = [(), (ys[0],), (ys[0],), tuple(ys[:3])][J - 1]
            yh = rng.randrange(R) if J == 1 else rng.randrange(2)
            # Bayes update of the odds: likelihood under uniform consistent members vs P
            likeF = sum(1 for i in cons if fp_answer(mem[i], J, hist) == yh) / len(cons)
            likeP = 1 / R if J == 1 else 0.5
            newcons = [i for i in cons if fp_answer(mem[i], J, hist) == yh]
            if likeF == 0:
                return t
            logodds += math.log(likeF / likeP)
            posts[z] = newcons
        return tmax
    for K in (1, 2, 3):
        for driver, expected in (('draw', 8 * 2 ** K), ('mix', 8)):
            reps = 3000 if driver == 'mix' else 1500
            life = [simulate(K, driver) for _ in range(reps)]
            mean = sum(life) / reps
            se = (sum((l - mean) ** 2 for l in life) / reps) ** 0.5 / reps ** 0.5
            print(f"    actual rehearsal, K={K}, driver={driver:4s}: mean round of removal of F' = {mean:7.2f} +- {se:.2f}"
                  f" (expected {expected})")
            assert abs(mean - expected) < 4 * se + 0.05 * expected
    # arithmetic of the 0.07
    worst = 1.0
    for K in range(1, 25):
        n = 5 * 2 ** K; Nz = 10 * n * n
        for t in (1, 5 * 2 ** K + 1):
            val = 0.5 * (1 - 2 ** -K) * (1 - n / Nz) * ((1 - 2 ** -K / 8) ** (t - 1) - n * n / (2 * Nz))
            worst = min(worst, val)
    print(f"    the bound of Proposition 3.5(b) at t-1 = 5*2^K, N_z = 10 n^2, n = 5*2^K, K = 1..24: smallest value {worst:.4f} (claimed >= 0.07)")
    assert worst >= 0.07

# ---------------------------------------------------------------- S5
def S5(seed=5, reps=4000):
    print("S5  Example 3.6 (codebook class)")
    rng = random.Random(seed)
    for (K, n) in ((3, 6), (4, 6), (4, 9), (5, 7)):
        m = n + K - 2
        cnt = 0; cnt_sq = 0
        for _ in range(reps):
            # distinct inputs (N_z large): data bits, codebook values at the asked inputs
            y = rng.getrandbits(n)
            consistent = any(rng.getrandbits(n) == y for _ in range(2 ** m))
            # largest posterior weight: function iff some consistent (weights as in the example)
            wfun = (1 - 2 ** -K) * 2 ** -m; wP = 2 ** -K * 2 ** -n
            if consistent and wfun > wP: cnt += 1
            if consistent and wfun ** 2 > (2 ** -K) ** 2 * 2 ** -n: cnt_sq += 1
        pred = 1 - (1 - 2 ** -n) ** (2 ** m)
        print(f"    K={K}, n={n}: frequency of a function as the member of largest posterior weight {cnt/reps:.4f}"
              f" (exact {pred:.4f}; claimed lower bound 1-exp(-2^(K-2)) = {1-math.exp(-2**(K-2)):.4f});"
              f" with weights squared: {cnt_sq}")
        assert abs(cnt / reps - pred) < 4 * math.sqrt(pred * (1 - pred) / reps) + 1e-3
        if n >= 5: assert cnt_sq == 0

# ---------------------------------------------------------------- S6
def S6():
    print("S6  Proposition 4.6")
    worst = 10.0; arg = None
    for n in range(1, 401):
        N = 2 * n
        for L in range(1, n + 1):
            c = math.ceil(L / 4); m0 = L - c + 1
            pr = 1 - (1 - 1 / N) ** m0
            r = pr / (9 / 32 * L / n)
            if r < worst: worst, arg = r, (n, L)
    print(f"    exact Pr[deployed trap has >= L/4 answers 1] / ((9/32) L/n), n = 1..400, L = 1..n: smallest ratio {worst:.4f} at (n, L) = {arg}")
    assert worst >= 1
    # mixture per-call bound: (1+iota)/(k(1+iota)+1) < 1/k <= 1/n for k >= n
    ok = all((1 + io) / (k * (1 + io) + 1) < 1 / k for io in (1e-6, 0.1, 1, 10) for k in range(1, 500))
    print(f"    per-call mass of a surviving trap < 1/k: {ok}")
    # direct simulation of a protocol: mixture-driven rehearsal then highest-weight consistent member
    rng = random.Random(6)
    n, L, iota = 30, 12, 0.01
    N = 2 * n
    reps = 4000; bad = 0
    for _ in range(reps):
        alive = set(range(1, N + 1))
        for t in range(n):
            k = len(alive)
            Z = 1 + k * (1 + iota)   # unnormalised posterior: g0 weight 1, traps 1+iota
            z = [rng.randrange(1, N + 1) for _ in range(L)]
            flag = 0; xs = []
            for j in range(L):
                x = (z[j], flag); xs.append(x)
                # fresh draw from the posterior
                u = rng.random() * Z
                if u < 1: ans = 0
                else:
                    a = rng.choice(sorted(alive)) if alive else None
                    ans = 1 if (a is not None and ((flag == 0 and z[j] == a) or flag == a)) else 0
                if flag == 0 and ans == 1: flag = z[j]
            J = rng.randrange(L)
            b, s = xs[J]
            alive.discard(b if s == 0 else s)
        a = min(alive)   # tie-break by index: independent of the deployed run's input
        z = [rng.randrange(1, N + 1) for _ in range(L)]
        ones = 0; flag = 0
        for j in range(L):
            ans = 1 if ((flag == 0 and z[j] == a) or flag == a) else 0
            if flag == 0 and ans: flag = z[j]
            ones += ans
        if ones >= L / 4: bad += 1
    c = math.ceil(L / 4); m0 = L - c + 1
    print(f"    simulation n={n}, L={L}: highest-weight consistent member has >= L/4 answers 1 with frequency {bad/reps:.4f}"
          f" (exact {1-(1-1/N)**m0:.4f}; bound (9/32)L/n = {9/32*L/n:.4f})")

# ---------------------------------------------------------------- S7
def S7(seed=7, reps=400, n=150, deltas=(0.5, 0.2)):
    print("S7  Proposition 5.7: posterior-draw-driven rehearsal, classes of functions")
    rng = random.Random(seed)
    for inst in range(4):
        L = [2, 3, 4, 3][inst]
        nx, nz = 6, 3
        sc = Scaffold(rng, nz, nx, 2, L, stop_p=0.1)
        f = [rng.randrange(2) for _ in range(nx)]
        if inst == 3:
            # chain class of Example 5.2 type on the path scaffold
            L = 3; nz = 1
            class Path: pass
            sc = Scaffold(rng, 1, L + 1, 2, L)
            sc.table = {}
            for j in range(L + 1):
                for ys in itertools.product((0, 1), repeat=j):
                    sc.table[(0, ys)] = -1 if j == L else (j if all(v == 0 for v in ys) else L)
            nx = L + 1
            f = [0] * nx
            funcs = [tuple(f)] + [tuple(1 if x == i else 0 for x in range(nx)) for i in range(L)]
            w = np.array([1.0] * len(funcs)); w /= w.sum()
        else:
            funcs = [tuple(f)]
            while len(funcs) < 40:
                g = tuple(f[x] if rng.random() < 0.75 else 1 - f[x] for x in range(nx))
                if g not in funcs: funcs.append(g)
            w = np.array([rng.random() ** 2 + 0.01 for _ in funcs]); w /= w.sum()
            w *= 0.97
        G = len(funcs)
        K = math.log2(1 / w[0])
        # precompute: for each g, for each z, the run of g, whether unfaithful, and inputs
        def run_of(g, z):
            ys = []; xs = []
            while True:
                x = sc.nxt(z, ys)
                if x < 0: break
                xs.append(x); ys.append(g[x])
            return xs, tuple(ys)
        runs = [[run_of(g, z) for z in range(nz)] for g in funcs]
        unf = np.array([[runs[i][z][1] != runs[0][z][1] for z in range(nz)] for i in range(G)], dtype=float)
        u = unf.mean(axis=1)
        wrongcount = np.zeros((G, G, nz))   # wrongcount[d, g, z]: # calls of d's run at which g is wrong
        for d in range(G):
            for z in range(nz):
                for x in runs[d][z][0]:
                    for g in range(G):
                        if funcs[g][x] != f[x]: wrongcount[d, g, z] += 1
        fails = {dl: [0, 0, 0] for dl in deltas}
        maxratio = 0.0
        for r in range(reps):
            alive = np.ones(G, dtype=bool)
            sum_ubar = 0.0; sum_d = np.zeros(G)
            for t in range(n):
                post = w * alive; post = post / post.sum()
                sum_ubar += float(post @ u)
                sum_d += np.einsum('d,dgz->g', post, wrongcount) / nz
                dv = rng.choices(range(G), weights=post)[0]
                z = rng.randrange(nz)
                xs = runs[dv][z][0]
                J = rng.randrange(1, L + 1)
                if J <= len(xs):
                    x = xs[J - 1]
                    for g in range(G):
                        if funcs[g][x] != f[x]: alive[g] = False
            post = w * alive; post /= post.sum()
            gdraw = rng.choices(range(G), weights=post)[0]
            for dl in deltas:
                c = K * LN2 + math.log(1 / dl)
                if sum_ubar >= 2 * L * L / (L + 1) * c: fails[dl][0] += 1
                badb = False
                for g in range(G):
                    if alive[g]:
                        bd = (L * (math.log(1 / w[g]) + math.log(1 / dl)) + 2 * L * L / (L + 1) * c) / n
                        if u[g] >= bd: badb = True
                        maxratio = max(maxratio, u[g] / bd)
                if badb: fails[dl][1] += 1
                if u[gdraw] >= 3 * L * c / n: fails[dl][2] += 1
        print(f"    instance {inst}: L={L}, |H|={G}, K={K:.2f} bits, n={n}, {reps} rehearsals; largest ratio u(g)/bound(b) = {maxratio:.3f}")
        for dl in deltas:
            fa, fb, fc = fails[dl]
            print(f"      delta={dl}: failure frequency (a) {fa/reps:.3f} [<= delta], (b) {fb/reps:.3f} [<= 2 delta], (c) {fc/reps:.3f} [<= 2 delta]")
            assert fa / reps <= dl + 3 * math.sqrt(dl / reps)

# ---------------------------------------------------------------- S8
def S8():
    print("S8  Arithmetic")
    # Theorem 3.8(c): 16L(K ln2 + l) + 24L(K ln2/2 + l)
    c4 = (16 + 12, 16 + 24)
    cstar = 2.964147
    cst = (7 * cstar, 10 * cstar)
    print(f"    Theorem 3.8(c): constants with 4: {c4} (claimed 28, 40); with c*=2.964147: ({cst[0]:.2f}, {cst[1]:.2f}) (claimed 21, 30)")
    assert c4 == (28, 40)
    # Remark 3.9: 16L(K ln2/2 + ln S + l) + 24L(K ln2/2 + l) -> 20, 16, 40; equal weights 1/B: K ln2 = ln B, ln S = ln B/2
    print("    Remark 3.9: 16*(1/2)+24*(1/2) = %g (claimed 20), 16 ln S (claimed 16), 16+24 = 40; equal weights: 20 + 16/2 = %g (claimed 28)" % (8 + 12, 20 + 8))
    # S(3,1) of Proposition 2.5 and the upper bound (2L^2/(L+1)) K ln2
    def S(L, K):
        tot = 0.0; k = 0
        while True:
            Rk = (2 ** K - 1) * (1 - 1 / L) ** k
            uk = Rk / (1 + Rk)
            term = uk / (1 - uk * (L - 1) / (2 * L))
            tot += term; k += 1
            if term < 1e-15: break
        return tot
    print(f"    Proposition 2.5: S(3,1) = {S(3,1):.4f} (claimed 2.202); (2L^2/(L+1)) K ln2 at L=3, K=1: {2*9/4*LN2:.4f} (claimed 3.119);"
          f" S(100,100) = {S(100,100):.2f} (claimed 13523.32)")
    # lower bound chain of Proposition 2.5 on a grid
    worst = 10
    for L in range(2, 60):
        for K in (1.01, 1.5, 2, 3, 5, 10, 30, 80):
            s = S(L, K)
            lb1 = (2 * L / (L + 1)) * math.log(1 + (L + 1) * (2 ** K - 1) / (2 * L)) / math.log(L / (L - 1))
            lb2 = (2 * L * (L - 1) / (L + 1)) * (K - 1) * LN2
            assert s >= lb1 - 1e-9 and lb1 >= lb2 - 1e-9
            assert s <= 2 * L * L / (L + 1) * K * LN2 + 1e-9
    print("    Proposition 2.5: S >= first lower bound >= second lower bound, and S <= (2L^2/(L+1)) K ln2, on a grid of 464 pairs: True")
    print(f"    Corollary 4.4(b): (3/2)^3/3! = {1.5**3/6:.4f} (claimed <= 0.57)")
    ok = True
    for n in range(100, 2000, 7):
        for L in range(1, int(math.sqrt(n)) + 1):
            c = math.ceil(L / 4)
            ok &= (L / n) ** c / math.factorial(c) <= (4 * math.e / n) ** (L / 4) * (1 + 1e-12)
    print(f"    Corollary 4.4(a): (L/n)^ceil(L/4)/ceil(L/4)! <= (4e/n)^(L/4) for n >= 100, L <= sqrt(n): {ok}")
    assert ok
    # Proposition 5.7(b): L + 2L^2/(L+1) < 3L
    print(f"    Proposition 5.7(b): L + 2L^2/(L+1) < 3L for L = 1..1000: {all(L + 2*L*L/(L+1) < 3*L for L in range(1, 1001))}")
    # Example 3.1(b): TV of the half mixture
    for eps in (0.1, 0.25, 0.5):
        iid = {t: np.prod([1 - eps if b else eps for b in t]) for t in itertools.product((0, 1), repeat=3)}
        ccc = {t: (1 - eps if t == (1, 1, 1) else eps if t == (0, 0, 0) else 0.0) for t in iid}
        mix = {t: 0.5 * iid[t] + 0.5 * ccc[t] for t in iid}
        tv = TV_laws(mix, iid)
        assert abs(tv - 1.5 * eps * (1 - eps)) < 1e-12
    print("    Example 3.1(b): TV = (3/2) eps (1-eps) for eps in {0.1, 0.25, 0.5}: True")

if __name__ == '__main__':
    S8()
    S1()
    S3()
    S6()
    S5()
    S4()
    S7()
    S2()
    print("all assertions passed")
