"""Second round of the editor of the part hellinger-runs (16 November 2026).

Independent tests of the statements that the second check (verification/hellinger-runs-second.md)
examined, written by the editor in order to decide its findings.  The script imports no other
script of the project.  Needs numpy only.  Every quantity is an exact finite sum evaluated in
floating point, except part (S1), which is exact rational arithmetic.

(S1) the algebraic identities in the proofs of Lemma 2.10 and Theorem 3.1(b), exactly;
(S2) Corollary 2.11 and Corollary 2.3 on random scaffolds with a random top-level input, runs of
     variable length (STOP), and answerers that see the top-level input and the history;
     k independent runs of two samplers;
(S3) Protocol R computed exactly (all data sets): R1, Theorem 3.1(a)-(d), Remark 3.2(iii) with two
     runs, and the variant of Appendix A in which no round is wasted;
(S4) Theorem 5.7: the inequalities of Steps 1 to 3 on every data set, and the two bounds in
     expectation, with ties, zeros, and a human outside the class; Theorem 4.2(a), (b), with the
     bound for runs that the human system never produces;
(S5) Example 4.6: the expected divergence of the averaged law (the thresholds quoted in the text),
     its minimum over the data, and the bound for each single round;
(S6) arithmetic used in the decisions on the findings N5, N7 and N9.
"""
import itertools
import math
import random
from fractions import Fraction as F

import numpy as np

rng = random.Random(1611202602)
nrng = np.random.default_rng(1611202602)
LN2 = math.log(2.0)


def phi(u):
    return min(1.0, u + math.sqrt(u * u + 2.0 * u))


# --------------------------------------------------------------------------------------------
print("(S1) exact identities (rational arithmetic)")
cnt = 0
for _ in range(2000):
    x = F(rng.randint(0, 400), 100)
    eta = F(rng.randint(1, 500), 50)
    m = 1 + F(rng.randint(1, 500), 100)
    # (a): U(x) - (1 - (1+eta) x^2) = (1 - (1+eta) x)^2 / eta for x <= 1, U(x) = ((1+eta)/eta)(1-x)^2
    if x <= 1:
        lhs = (1 + eta) / eta * (1 - x) ** 2 - (1 - (1 + eta) * x * x)
        assert lhs == (1 - (1 + eta) * x) ** 2 / eta
        # (c): U(x) - (1 - x^2) = (1 - m x)^2 / (m^2 - 1), U(x) = (m - x)^2 / (m^2 - 1)
        lhs = (m - x) ** 2 / (m * m - 1) - (1 - x * x)
        assert lhs == (1 - m * x) ** 2 / (m * m - 1)
    # U(1) + gamma m^2 sigma with gamma = 2/(m^2-1) equals [v^2 + 2 sigma (1+v)^2]/(v(v+2)), v = m-1
    sig = F(rng.randint(1, 300), 100)
    v = m - 1
    assert (m - 1) / (m + 1) + 2 * m * m * sig / (m * m - 1) == (v * v + 2 * sig * (1 + v) ** 2) / (v * (v + 2))
    # at v^2 = 2 sigma (1+v) the bound equals v; and this v is the stationary point of the bound in v
    sig_v = v * v / (2 * (1 + v))
    assert (v * v + 2 * sig_v * (1 + v) ** 2) / (v * (v + 2)) == v
    Nn = v * v + 2 * sig * (1 + v) ** 2
    Dd = v * v + 2 * v
    dN = 2 * v + 4 * sig * (1 + v)
    dD = 2 * v + 2
    assert dN * Dd - Nn * dD == 2 * (v * v - 2 * sig * (1 + v))
    # Theorem 3.1(b): u = eps^2/(2(1+eps)) solves u + sqrt(u^2+2u) = eps
    eps = F(rng.randint(1, 100), 100)
    u = eps * eps / (2 * (1 + eps))
    assert u * u + 2 * u == (eps - u) ** 2 and eps - u >= 0
    cnt += 1
print("     %d random rational points: the two pointwise identities of Lemma 2.10(a), (c), the form of the bound in v = m - 1," % cnt)
print("     its value v at v^2 = 2 sigma (1+v), the derivative identity N'D - ND' = 2(v^2 - 2 sigma(1+v)), and u = eps^2/(2(1+eps)): all exact")

# --------------------------------------------------------------------------------------------
print("(S2) Corollaries 2.3 and 2.11 on random scaffolds (top-level input, STOP, answerers that see the history)")
CSTAR = 2.9641471573076780


def rand_kernel(b):
    conc = rng.choice([0.2, 0.6, 1.0, 4.0])
    v = nrng.dirichlet([conc] * b)
    if rng.random() < 0.3:
        v[rng.randrange(b)] = 0.0
        if v.sum() <= 0:
            v[rng.randrange(b)] = 1.0
        v = v / v.sum()
    return v


def near_kernel(p, scale):
    q = p * np.exp(scale * nrng.standard_normal(len(p)))
    if rng.random() < 0.2:
        q[rng.randrange(len(p))] = 0.0
    if rng.random() < 0.1:
        q = q + 1e-3
    if q.sum() <= 0:
        q = np.ones(len(p))
    return q / q.sum()


def build_instance(samplers):
    """A scaffold and two answerers.  Returns leaf laws pA, pB and sigma_A = E_{Q_A} sum_j h_j."""
    W = rng.choice([1, 2, 3])
    mu0 = nrng.dirichlet([1.0] * W)
    b = rng.choice([2, 2, 3])
    L = rng.choice([1, 2, 3, 4])
    nX = rng.choice([1, 2, 3, 5])
    pstop = rng.choice([0.0, 0.15, 0.35])
    scale = math.exp(rng.uniform(-6, 1))
    nxt = {}      # (w, history) -> input or None (STOP)
    kerA = {}
    kerB = {}

    def next_input(w, hist):
        key = (w, hist)
        if key not in nxt:
            nxt[key] = None if (len(hist) >= L or rng.random() < pstop) else rng.randrange(nX)
        return nxt[key]

    def kernels(w, hist, x):
        key = x if samplers else (w, hist)
        if key not in kerA:
            a = rand_kernel(b)
            kerA[key] = a
            kerB[key] = near_kernel(a, scale) if rng.random() < 0.8 else rand_kernel(b)
        return kerA[key], kerB[key]

    leavesA = []
    leavesB = []
    sigma = 0.0
    stack = [(w, (), mu0[w], mu0[w]) for w in range(W)]
    while stack:
        w, hist, pa, pb = stack.pop()
        x = next_input(w, hist)
        if x is None:
            leavesA.append(pa)
            leavesB.append(pb)
            continue
        a, bb = kernels(w, hist, x)
        sigma += pa * (1.0 - float(np.sum(np.sqrt(a * bb))))
        for y in range(b):
            if pa * a[y] > 0 or pb * bb[y] > 0:
                stack.append((w, hist + (y,), pa * a[y], pb * bb[y]))
    return np.array(leavesA), np.array(leavesB), sigma


ETAS = [0.05, 0.25, 1.0, 4.0, 50.0]
worst = {"H4": 0.0, "Hc": 0.0, "TV": 0.0, "TVnt": 0.0, "null": 0.0, "k2": 0.0, "k3": 0.0}
worst.update({("ev", e): 0.0 for e in ETAS})
ninst = 0
for it in range(12000):
    samplers = (it % 2 == 0)
    pA, pB, sig = build_instance(samplers)
    assert abs(pA.sum() - 1) < 1e-9 and abs(pB.sum() - 1) < 1e-9
    if sig < 1e-13:
        continue
    ninst += 1
    h2 = 1.0 - float(np.sum(np.sqrt(pA * pB)))
    tv = 0.5 * float(np.abs(pA - pB).sum())
    worst["H4"] = max(worst["H4"], h2 / (4 * sig))
    worst["Hc"] = max(worst["Hc"], h2 / (CSTAR * sig))
    worst["TV"] = max(worst["TV"], tv / phi(sig))
    if phi(sig) < 1:
        worst["TVnt"] = max(worst["TVnt"], tv / phi(sig))
    worst["null"] = max(worst["null"], float(pA[pB == 0].sum()) / (2 * sig))
    for e in ETAS:
        worst[("ev", e)] = max(worst[("ev", e)], float(np.maximum(pA - (1 + e) * pB, 0).sum()) / (2 * (1 + 1 / e) * sig))
    if samplers and len(pA) <= 40:
        qa, qb = pA, pB
        for k in (2, 3):
            qa = np.outer(qa, pA).ravel()
            qb = np.outer(qb, pB).ravel()
            if len(qa) > 70000:
                break
            worst["k%d" % k] = max(worst["k%d" % k], 0.5 * float(np.abs(qa - qb).sum()) / phi(k * sig))
print("     %d instances (half with samplers, half with answerers that see the top-level input and the history)." % ninst)
print("     largest ratio of the left side to the right side (every ratio must be <= 1):")
print("       L4(a)  H^2/(4 sigma) = %.4f ;  H^2/(c* sigma) = %.4f" % (worst["H4"], worst["Hc"]))
print("       L4(b)  TV/phi(sigma) = %.10f ;  among the instances with phi(sigma) < 1: %.6f" % (worst["TV"], worst["TVnt"]))
print("       L4(c)  sup_G [Q_A(G) - (1+eta) Q_B(G)] / (2(1+1/eta) sigma): " + ", ".join("eta=%g: %.4f" % (e, worst[("ev", e)]) for e in ETAS))
print("       L4(c)  Q_A(runs of Q_B-probability zero)/(2 sigma) = %.6f" % worst["null"])
print("       Corollary 2.11, k runs of two samplers: TV(Q_S^k, Q_S'^k)/phi(k sigma_S): k=2: %.10f, k=3: %.10f" % (worst["k2"], worst["k3"]))
assert max(v for v in worst.values()) <= 1 + 1e-9

# one call: the constants of (a), (b) and the factor sqrt(2) of (c) are approached (Remark 2.12(i))
a = 1e-7
row = []
for e in (0.25, 1.0, 4.0):
    p = np.array([1 - a, a])
    q = np.array([1 - a / (1 + e) ** 2, a / (1 + e) ** 2])
    h = 1 - float(np.sum(np.sqrt(p * q)))
    row.append("eta=%g: %.4f of %.4f" % (e, (p[1] - (1 + e) * q[1]) / h, 2 * (1 + 1 / e)))
print("     one call, a = 1e-7: [P(G) - (1+eta)Q(G)]/h -> " + "; ".join(row) + ";  P(G)/h with Q(G) = 0: %.4f of 2" % (a / (1 - math.sqrt(1 - a))))
t = 1e-3
h = 1 - math.sqrt(1 - 4 * t * t)
print("     one call, p = (1/2+t, 1/2-t), q = (1/2-t, 1/2+t), t = 1e-3: TV/phi(h) = %.6f, TV/sqrt(2h) = %.6f" % (2 * t / phi(h), 2 * t / math.sqrt(2 * h)))

# --------------------------------------------------------------------------------------------
print("(S3) Protocol R, exact expectation over all data sets and T")


def protocol_R(variant):
    """Random small instance.  Returns the ratios of the two sides of R1 and of Theorem 3.1."""
    W = rng.choice([1, 2])
    mu0 = nrng.dirichlet([1.0] * W)
    L = rng.choice([1, 2, 3])
    nX = rng.choice([2, 3])
    n = rng.choice([1, 2, 3, 4])
    M = rng.choice([2, 3, 4])
    adaptive = rng.random() < 0.7
    pstop = rng.choice([0.0, 0.25])
    # hypotheses: theta[nu][x] = probability of the answer 1
    theta = np.zeros((M, nX))
    for nu in range(M):
        for x in range(nX):
            u = rng.random()
            theta[nu, x] = 0.0 if u < 0.12 else (1.0 if u < 0.24 else rng.random())
    wts = nrng.dirichlet([rng.choice([0.3, 1.0, 3.0])] * M) * rng.choice([1.0, 0.7])
    wts = np.maximum(wts, 1e-6)
    K = math.log2(1.0 / wts[0])          # the human is hypothesis 0
    P = theta[0]
    nxt = {}

    def next_input(w, hist):
        key = (w, hist) if adaptive else (w, len(hist))
        if key not in nxt:
            nxt[key] = None if (len(hist) >= L or (len(hist) >= 1 and rng.random() < pstop)) else rng.randrange(nX)
        return nxt[key]

    def runs(sampler):
        """All runs as (probability, inputs) for the sampler given by its vector of P(1|x); and the
        probability of each run keyed by (w, answers)."""
        out = {}
        stack = [(w, (), mu0[w], ()) for w in range(W)]
        while stack:
            w, hist, pr, xs = stack.pop()
            x = next_input(w, hist)
            if x is None:
                out[(w, hist)] = (pr, xs)
                continue
            for y in (0, 1):
                py = sampler[x] if y == 1 else 1 - sampler[x]
                stack.append((w, hist + (y,), pr * py, xs + (x,)))
        return out

    runsP = runs(P)
    keys = sorted(runsP)
    qP = np.array([runsP[k][0] for k in keys])
    xs_of = {k: runsP[k][1] for k in keys}

    def bern_h2(a, b):
        return 1 - math.sqrt(a * b) - math.sqrt((1 - a) * (1 - b))

    def bern_kl(p, m):
        s = 0.0
        if p > 0:
            s += p * math.log(p / m)
        if p < 1:
            s += (1 - p) * math.log((1 - p) / (1 - m))
        return s

    def mixture(D):
        lik = np.ones(M)
        for (x, y) in D:
            lik *= theta[:, x] if y == 1 else 1 - theta[:, x]
        post = wts * lik
        post = post / post.sum()
        return post @ theta

    states = {(): 1.0}
    acc = {"kl": 0.0, "sig": 0.0, "h2": 0.0, "tv": 0.0, "null": 0.0, "tv2": 0.0, "klrun": 0.0}
    accev = {e: 0.0 for e in ETAS}
    accrev = {e: 0.0 for e in ETAS}
    for t in range(1, n + 1):
        new = {}
        for D, prD in states.items():
            Mx = mixture(D)
            rM = runs(Mx)
            qM = np.array([rM[k][0] for k in keys])
            klsum = sum(rM[k][0] * sum(bern_kl(P[x], Mx[x]) for x in xs_of[k]) for k in keys)
            sig = sum(rM[k][0] * sum(bern_h2(P[x], Mx[x]) for x in xs_of[k]) for k in keys)
            acc["kl"] += prD * klsum
            acc["sig"] += prD * sig
            acc["h2"] += prD * (1 - float(np.sum(np.sqrt(qM * qP))))
            acc["tv"] += prD * 0.5 * float(np.abs(qM - qP).sum())
            acc["null"] += prD * float(qM[qP == 0].sum())
            acc["tv2"] += prD * 0.5 * float(np.abs(np.outer(qM, qM) - np.outer(qP, qP)).sum())
            mk = qP > 0
            acc["klrun"] += prD * float(np.sum(qP[mk] * np.log(qP[mk] / qM[mk])))
            for e in ETAS:
                accev[e] += prD * float(np.maximum(qM - (1 + e) * qP, 0).sum())
                accrev[e] += prD * float(np.maximum(qP - (1 + e) * qM, 0).sum())
            # the question of round t
            for k in keys:
                pr_run = rM[k][0]
                if pr_run == 0:
                    continue
                xs = xs_of[k]
                ln = len(xs)
                if variant:                       # J uniform on the calls that the run made
                    choices = [(1.0 / ln, j) for j in range(ln)] if ln else [(1.0, None)]
                else:                             # J uniform on {1, ..., L}
                    choices = [(1.0 / L, j) for j in range(ln)] + ([((L - ln) / L, None)] if ln < L else [])
                for pj, j in choices:
                    if j is None:
                        new[D] = new.get(D, 0.0) + prD * pr_run * pj
                        continue
                    x = xs[j]
                    for y in (0, 1):
                        py = P[x] if y == 1 else 1 - P[x]
                        if py > 0:
                            D2 = tuple(sorted(D + ((x, y),)))
                            new[D2] = new.get(D2, 0.0) + prD * pr_run * pj * py
        states = new
        assert abs(sum(states.values()) - 1) < 1e-9
    s = L * K * LN2 / (2 * n)
    res = {
        "R1": acc["kl"] / (L * K * LN2),
        "sigma": (acc["sig"] / n) / s,
        "a": (acc["h2"] / n) / (4 * s),
        "b": (acc["tv"] / n) / phi(s),
        "b_small": (acc["tv"] / n) / phi(s) if s <= 0.125 else 0.0,
        "null": (acc["null"] / n) / (2 * s),
        "two": (acc["tv2"] / n) / phi(2 * s),
    }
    for e in ETAS:
        res[("ev", e)] = (accev[e] / n) / (2 * (1 + 1 / e) * s)
        res[("rev", e)] = (accrev[e] / n) / (8 * (1 + 1 / e) * s)
    if not adaptive:
        res["d_kl"] = (acc["klrun"] / n) / (2 * s)
        res["d_tv"] = (acc["tv"] / n) / math.sqrt(s)
        res["d_h2"] = (acc["h2"] / n) / s
        for e in ETAS:
            res[("drev", e)] = (accrev[e] / n) / (2 * (1 + 1 / e) * s)
    return res


for variant in (False, True):
    best = {}
    cnt = 0
    for _ in range(700):
        res = protocol_R(variant)
        cnt += 1
        for k, v in res.items():
            best[k] = max(best.get(k, 0.0), v)
    name = "J uniform on the calls that the run made (Appendix A, variant)" if variant else "J uniform on {1, ..., L} (Protocol R)"
    print("     %s: %d instances (n <= 4 rounds, L <= 3, 2 to 4 hypotheses with zeros, 70%% adaptive scaffolds)" % (name, cnt))
    print("       R1: sum_t E[E sum_j KL]/(L K ln2) <= %.6f ;  E sigma_T / s <= %.6f" % (best["R1"], best["sigma"]))
    print("       3.1(a): E H^2/(2 L K ln2/n) <= %.4f ;  3.1(b): E TV/phi(s) <= %.6f (instances with s <= 1/8: %.4f)" % (best["a"], best["b"], best["b_small"]))
    print("       3.1(c): E sup_G[Q_M(G) - (1+eta) Q_P(G)] / ((1+1/eta) L K ln2/n): " + ", ".join("eta=%g: %.4f" % (e, best[("ev", e)]) for e in ETAS))
    print("       3.1(c): E Q_M(runs of Q_P-probability zero)/(L K ln2/n) <= %.6f" % best["null"])
    print("       3.1(c), other direction: E sup_G[Q_P(G) - (1+eta) Q_M(G)] / ((1+1/eta) 4 L K ln2/n): " + ", ".join("eta=%g: %.4f" % (e, best[("rev", e)]) for e in ETAS))
    print("       3.2(iii): E TV(two runs of M^(T), two runs of P)/phi(2s) <= %.6f" % best["two"])
    print("       3.1(d), scaffolds whose inputs do not depend on the answers: E KL(Q_P||Q_M)/(L K ln2/n) <= %.6f ; E TV/sqrt(L K ln2/(2n)) <= %.6f ;" % (best["d_kl"], best["d_tv"]))
    print("               E H^2/(L K ln2/(2n)) <= %.4f ; other direction of (c) with L K ln2/n: " % best["d_h2"] + ", ".join("eta=%g: %.4f" % (e, best[("drev", e)]) for e in ETAS))
    assert max(best.values()) <= 1 + 1e-9

# --------------------------------------------------------------------------------------------
print("(S4) Theorem 5.7: Steps 1 to 3 on every data set, and the bounds in expectation")


def thm57_instance():
    Y = rng.choice([2, 3, 4])
    M = rng.choice([2, 3, 5, 8])
    N = rng.choice([1, 2, 3, 4, 5, 6])
    while Y ** N > 1500:
        N -= 1
    lam = rng.choice([1.01, 1.2, 1.5, 2.0, 3.0, 10.0])
    al = 1.0 / lam
    hyps = [rand_kernel(Y) for _ in range(M)]
    if rng.random() < 0.3:                       # exact ties: a duplicated hypothesis
        hyps[-1] = hyps[0].copy()
    if rng.random() < 0.5:                       # geometric weights (a truncated code)
        wts = np.array([2.0 ** (-(i + 1)) for i in range(M)])
    else:
        wts = nrng.dirichlet([1.0] * M) * rng.choice([1.0, 0.5])
        wts = np.maximum(wts, 1e-9)
    if rng.random() < 0.3 and M >= 2:
        wts[-1] = wts[0]                         # two hypotheses of equal weight
    if wts.sum() > 1:                            # the theorem assumes that the weights sum to at most 1
        wts = wts / wts.sum()
    inside = rng.random() < 0.45
    qs = hyps[rng.randrange(M)].copy() if inside else rand_kernel(Y)
    sup = qs > 0

    def kl(i):
        if np.any(hyps[i][sup] == 0):
            return math.inf
        return float(np.sum(qs[sup] * np.log(qs[sup] / hyps[i][sup])))

    kls = [kl(i) for i in range(M)]
    fin = [i for i in range(M) if math.isfinite(kls[i])]
    if not fin:
        return None
    A = np.array([float(np.sum(qs[sup] ** (1 - al) * hyps[i][sup] ** al)) for i in range(M)])
    H2 = np.array([1 - float(np.sum(np.sqrt(qs * hyps[i]))) for i in range(M)])
    live = A > 0
    negA = np.where(live, -np.log(np.where(live, A, 1.0)), np.inf)
    rhs = min(math.log(1 / wts[i]) / N + kls[i] / lam for i in fin)
    EPhi = 0.0
    ElnPhi = 0.0
    Epost = 0.0
    Emap = 0.0
    Epost_h = 0.0
    Emap_h = 0.0
    viol = -math.inf
    for data in itertools.product(range(Y), repeat=N):
        pr = 1.0
        for y in data:
            pr *= qs[y]
        if pr == 0:
            continue
        r = np.ones(M)
        for y in data:
            r *= np.array([hyps[i][y] for i in range(M)]) / qs[y]
        u = wts * r ** al
        Phi = float(np.sum(wts[live] * r[live] ** al / A[live] ** N))
        EPhi += pr * Phi
        ElnPhi += pr * math.log(Phi)
        ulam = u ** lam
        post = ulam / ulam.sum()
        pos = post > 0
        lhs_post = N * float(np.sum(post[pos] * negA[pos]))
        step1 = math.log(Phi) + float(np.sum(post[pos] * np.log(post[pos] / u[pos])))
        umax = float(u.max())
        step2 = math.log(Phi) - math.log(umax)
        step3 = min(math.log(Phi) + math.log(1 / wts[i]) - al * math.log(r[i]) for i in fin)
        viol = max(viol, lhs_post - step1, step1 - step2, step2 - step3)
        maps = [i for i in range(M) if u[i] >= umax * (1 - 1e-12)]
        lhs_map = N * max(negA[i] for i in maps)
        viol = max(viol, lhs_map - step2)
        Epost += pr * lhs_post / N
        Emap += pr * lhs_map / N
        Epost_h += pr * float(np.sum(post * H2))
        Emap_h += pr * max(H2[i] for i in maps)
    den = 2 * min(al, 1 - al)
    return {"viol": viol, "EPhi": EPhi - float(wts[live].sum()), "ElnPhi": ElnPhi,
            "post": Epost / rhs, "map": Emap / rhs, "post_h": Epost_h / (rhs / den), "map_h": Emap_h / (rhs / den)}


agg = {"viol": -math.inf, "EPhi": 0.0, "ElnPhi": -math.inf, "post": 0.0, "map": 0.0, "post_h": 0.0, "map_h": 0.0}
cnt = 0
for _ in range(3000):
    res = thm57_instance()
    if res is None:
        continue
    cnt += 1
    agg["viol"] = max(agg["viol"], res["viol"])
    agg["EPhi"] = max(agg["EPhi"], abs(res["EPhi"]))
    agg["ElnPhi"] = max(agg["ElnPhi"], res["ElnPhi"])
    for k in ("post", "map", "post_h", "map_h"):
        agg[k] = max(agg[k], res[k])
print("     %d instances (2 to 4 outcomes of a run, 2 to 8 hypotheses with zeros and exact ties, N <= 6, lambda from 1.01 to 10, the human inside the class in 45%%)" % cnt)
print("     on every data set: N*sum rho(-ln A) <= ln Phi + sum rho ln(rho/u) <= ln Phi - ln u_max <= ln Phi + ln(1/w) + alpha ln(L*/L_nu), and the MAP form;")
print("       largest violation of any of these inequalities: %.3e (must be <= 0 up to rounding)" % agg["viol"])
print("     max |E Phi - sum of the weights with A > 0| = %.2e ;  max E ln Phi = %.3e (must be <= 0)" % (agg["EPhi"], agg["ElnPhi"]))
print("     largest ratio to the right side: E[posterior mean of -ln A_(1/lambda)]: %.4f ; E[-ln A_(1/lambda) of the worst lambda-MAP]: %.4f" % (agg["post"], agg["map"]))
print("       in H^2 (right side divided by 2 min(1/lambda, 1 - 1/lambda)): posterior %.4f ; lambda-MAP %.4f   (all must be <= 1)" % (agg["post_h"], agg["map_h"]))
assert agg["viol"] <= 1e-9 and agg["ElnPhi"] <= 1e-12 and max(agg["post"], agg["map"], agg["post_h"], agg["map_h"]) <= 1 + 1e-9

# Theorem 4.2(a), (b): one posterior draw per run, t uniform; runs are outcomes in a finite set
def thm42_instance():
    Y = rng.choice([2, 3, 4])
    M = rng.choice([2, 3, 5])
    N = rng.choice([1, 2, 3, 4, 5])
    while Y ** (N - 1) > 300:
        N -= 1
    hyps = np.array([rand_kernel(Y) for _ in range(M)])
    wts = nrng.dirichlet([1.0] * M) * rng.choice([1.0, 0.6])
    wts = np.maximum(wts, 1e-9)
    if wts.sum() > 1:
        wts = wts / wts.sum()
    qs = hyps[rng.randrange(M)].copy() if rng.random() < 0.5 else rand_kernel(Y)
    sup = qs > 0
    kls = []
    for i in range(M):
        kls.append(math.inf if np.any(hyps[i][sup] == 0) else float(np.sum(qs[sup] * np.log(qs[sup] / hyps[i][sup]))))
    if not any(math.isfinite(k) for k in kls):
        return None
    res_n = min(math.log(1 / wts[i]) / N + kls[i] for i in range(M) if math.isfinite(kls[i]))
    sum_kl = 0.0          # sum_t E KL(Q* || Qhat_t)
    e_null = 0.0          # E Qhat({q* = 0})
    e_tv = 0.0            # E TV(Qhat, Q*), Qhat the average over t
    for data in itertools.product(range(Y), repeat=N - 1):
        pr = 1.0
        for y in data:
            pr *= qs[y]
        if pr == 0:
            continue
        qbar = np.zeros(Y)
        for t in range(1, N + 1):
            lik = np.ones(M)
            for y in data[:t - 1]:
                lik = lik * hyps[:, y]
            post = wts * lik
            post = post / post.sum()
            qhat = post @ hyps
            qbar += qhat / N
            # E KL(Q*||Qhat_t) depends on the first t-1 runs only; weight by the probability of the full sequence
            sum_kl += pr * float(np.sum(qs[sup] * np.log(qs[sup] / qhat[sup])))
        e_null += pr * float(qbar[~sup].sum())
        e_tv += pr * 0.5 * float(np.abs(qbar - qs).sum())
    return {"a": sum_kl / (N * res_n), "null": e_null / res_n, "tv": e_tv / math.sqrt(res_n / 2)}


best42 = {"a": 0.0, "null": 0.0, "tv": 0.0}
cnt = 0
for _ in range(2500):
    res = thm42_instance()
    if res is None:
        continue
    cnt += 1
    for k in best42:
        best42[k] = max(best42[k], res[k])
print("     Theorem 4.2, %d instances (the human inside the class in half of them), all data sets: largest ratio to the right side" % cnt)
print("       (a) sum_t E KL(Q*||Qhat_t) / (N Res_N): %.6f ; (b) E TV(Qhat, Q*)/sqrt(Res_N/2): %.4f ; E Qhat(runs of Q*-probability zero)/Res_N: %.4f" % (best42["a"], best42["tv"], best42["null"]))
assert max(best42.values()) <= 1 + 1e-9

# --------------------------------------------------------------------------------------------
print("(S5) Example 4.6 with B = 2N: the per-call mixture, the law averaged over t")
print("     N  L | E KL(Q_f||Qbar_M)  min over data   ln2/N   L/(8N) | min over t and data of KL(Q_f||Q_{M_t}) | (1-(1-w)^L)/w <= L")
for N in (1, 2, 3, 4, 5):
    B = 2 * N
    for L in (1, 2, 3, 4, 6):
        tot = 0.0
        mn = math.inf
        mn_t = math.inf
        cnt = 0
        for zs in itertools.product(range(B), repeat=N - 1):
            pz = np.zeros(B)
            for t in range(1, N + 1):
                vis = set(zs[:t - 1])
                om = 1.0 / (2 * B - len(vis))
                for z in range(B):
                    pz[z] += (1.0 if z in vis else (1 - om) ** L) / N
                mn_t = min(mn_t, (B - len(vis)) / B * L * math.log(1 / (1 - om)))
            klv = float(np.mean(np.log(1 / pz)))
            tot += klv
            mn = min(mn, klv)
            cnt += 1
        om = 1.0 / (2 * B)
        flag = "E KL > ln2/N" if tot / cnt > LN2 / N else ""
        print("     %d %2d | %.5f  %.5f  %.5f  %.5f | %.5f | %.3f  %s" % (N, L, tot / cnt, mn, LN2 / N, L / (8 * N), mn_t, (1 - (1 - om) ** L) / om, flag))
        assert mn >= L / (8 * N) and mn_t >= L / (8 * N)

# --------------------------------------------------------------------------------------------
print("(S6) arithmetic used in the decisions")
print("     8 ln 2 = %.4f, so L/(8N) > ln2/N exactly when L >= 6" % (8 * LN2))
print("     Proposition 3.4: (1/7)(1/2) sqrt(3/64) = sqrt(3)/112 = %.6f > 1/65 = %.6f;  7/(8*16*4225) = %.4e >= 1/(8e4) = %.4e" % (math.sqrt(3) / 112, 1 / 65, 7 / (8 * 16 * 4225), 1 / 8e4))
print("     Proposition 3.5: 128/0.7 = %.2f <= 183; 183/740 = %.4f < 1/4; at L = 1, eps = 1/12: 4a^2 = %.3f (the proof needs L >= 3: 128/(144*3) = %.3f <= 0.3)" % (128 / 0.7, 183 / 740, 128 / 144, 128 / 432))
for x in (1e-4, 1e-2, 0.1):
    # x = K ln2/(2N): H1 has sqrt(x); R2 with n = N L has phi(x) <= 2 sqrt(x)
    print("     s = K ln2/(2N) = %g: bound of H1 sqrt(s) = %.5f; bound of R2(b) with n = N L rounds phi(s) = %.5f (ratio %.3f); 2 sqrt(s) = %.5f" % (x, math.sqrt(x), phi(x), phi(x) / math.sqrt(x), 2 * math.sqrt(x)))
print("     answers for expected total variation eps: H1 needs N L = L K ln2/(2 eps^2); R2(b) asks for (1+eps) L K ln2/eps^2: the ratio is 2(1+eps), between 2 and 4")
print("     Remark 3.3(i): [L sqrt(K ln2/(2n))] / sqrt(2 L K ln2/n) = sqrt(L)/2: at L = 9, K = 3, n = 50: %.6f = %.6f" % (9 * math.sqrt(3 * LN2 / 100) / math.sqrt(2 * 9 * 3 * LN2 / 50), 1.5))
print("done")
