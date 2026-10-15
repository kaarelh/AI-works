"""c1_toy.py -- finite propositional checks for the fundamentals scout (notes.md, Sections 3-5).

Seeded. Run as  python3 -I c1_toy.py > c1_toy.out  (the output is saved next to this script).

A finite propositional stand-in for the one-tape definitions.
* k atoms, valuations V = {0,1}^k, a proposition is a bit mask over V (a set of valuations),
  so sentences are taken up to logical equivalence.
* A "theory" is its set of models (a mask); mask 0 is the inconsistent theory.
* A prior pi is a finite list of (theory mask, weight); weights sum to 1, and some weight may sit
  on mask 0 (inconsistent theories), as for the universal theory machine.
* A |- phi  iff  Mod(A) is a subset of phi.

Part A checks the identities of notes.md Section 4 on random instances:
  (A1) proof-requiring (PR) weight M(D) = Bel0(psi_D), semimeasure inequality, defect = Indep;
  (A2) PR posterior trichotomy = geometric conditioning of Bel0;
  (A3) consistency-requiring (CR) posterior trichotomy (theory A u D) = Dempster conditioning of Bel0;
  (A4) the CR weight M_C = Pl0 is not a semimeasure (sum over labels >= M_C(D));
  (A5) three-valued weight M3 is additive over {true,false,indep};
  (A6) PR cumulative loss is order independent; the CR sub-probability loss is not.
Part B: the stream R_1, R_2, ... all labelled true, prior = {empty theory, "all atoms true",
  fair-coin complete theory, three-way random partial theory, inconsistent}; PR loss stays bounded,
  CR (Dempster) loss grows linearly.  Closed forms are cross-checked by brute force for small k.
Part C: incomplete truth T* with two models; two-valued complete presentation leaves the
  posterior on the consistent extensions of T* (trichotomy of an independent sentence = prior
  shares), three-valued presentation identifies [T*].
"""
import itertools
import math
import random

SEED = 20261015
random.seed(SEED)

LOG2 = lambda x: math.log(x, 2)


def subset(a, b):
    return a & ~b == 0


# ---------------------------------------------------------------- Part A
def make_prior(nv, n_theories, inc_weight):
    full = (1 << nv) - 1
    thy = []
    for _ in range(n_theories):
        m = random.randint(1, full)          # nonempty set of models
        thy.append(m)
    thy.append(full)                          # the empty theory (pure logic)
    w = [random.random() for _ in thy]
    s = sum(w)
    w = [x * (1 - inc_weight) / s for x in w]
    thy.append(0)                             # inconsistent theory
    w.append(inc_weight)
    return list(zip(thy, w))


def lit(phi, b, full):
    return phi if b == 1 else (full & ~phi)


def psi_of(D, full):
    p = full
    for (phi, b) in D:
        p &= lit(phi, b, full)
    return p


def bel0(prior, psi):
    return sum(w for (A, w) in prior if A != 0 and subset(A, psi))


def M_PR(prior, D, full):
    return bel0(prior, psi_of(D, full))


def M_CR(prior, D, full):
    psi = psi_of(D, full)
    return sum(w for (A, w) in prior if A & psi != 0)


def PR_tri(prior, D, phi, full):
    psi = psi_of(D, full)
    Z = sum(w for (A, w) in prior if A != 0 and subset(A, psi))
    bel = sum(w for (A, w) in prior if A != 0 and subset(A, psi) and subset(A, phi)) / Z
    dis = sum(w for (A, w) in prior if A != 0 and subset(A, psi) and subset(A, full & ~phi)) / Z
    return bel, dis, 1 - bel - dis


def CR_tri(prior, D, phi, full):
    psi = psi_of(D, full)
    Z = sum(w for (A, w) in prior if A & psi != 0)
    bel = sum(w for (A, w) in prior if A & psi != 0 and subset(A & psi, phi)) / Z
    dis = sum(w for (A, w) in prior if A & psi != 0 and subset(A & psi, full & ~phi)) / Z
    return bel, dis, 1 - bel - dis


def geometric(prior, psi, phi, full):
    return bel0(prior, psi & phi) / bel0(prior, psi)


def dempster(prior, psi, phi, full):
    cons = sum(w for (A, w) in prior if A != 0)
    B = lambda x: bel0(prior, x) / cons
    notpsi = full & ~psi
    return (B(phi | notpsi) - B(notpsi)) / (1 - B(notpsi))


def M3(prior, D3, full):
    """three-valued labels: b in {1, 0, 'i'}"""
    tot = 0.0
    for (A, w) in prior:
        if A == 0:
            continue
        ok = True
        for (phi, b) in D3:
            if b == 1 and not subset(A, phi):
                ok = False
            elif b == 0 and not subset(A, full & ~phi):
                ok = False
            elif b == 'i' and (subset(A, phi) or subset(A, full & ~phi)):
                ok = False
        if ok:
            tot += w
    return tot


def partA():
    print("=== Part A: identities on random finite instances (k=3 atoms, 8 valuations) ===")
    k = 3
    nv = 2 ** k
    full = (1 << nv) - 1
    worst = dict(semi=-1e9, defect=0.0, geom=0.0, demp=0.0, m3=0.0, crsum_min=1e9, pr_order=0.0)
    cr_order_max = 0.0
    cr_order_example = None
    n_trials = 400
    n_cr_strict = 0
    for trial in range(n_trials):
        prior = make_prior(nv, n_theories=random.randint(3, 25), inc_weight=random.choice([0.0, 0.05, 0.3]))
        # a consistent labelled data set: labels of random sentences by a random valuation
        v = random.randrange(nv)
        D = []
        for _ in range(random.randint(0, 3)):
            phi = random.randint(1, full - 1)
            D.append((phi, 1 if (phi >> v) & 1 else 0))
        phi = random.randint(1, full - 1)
        mD = M_PR(prior, D, full)
        if mD <= 0:
            continue
        m1 = M_PR(prior, D + [(phi, 1)], full)
        m0 = M_PR(prior, D + [(phi, 0)], full)
        worst['semi'] = max(worst['semi'], m1 + m0 - mD)                       # must be <= 0
        bel, dis, ind = PR_tri(prior, D, phi, full)
        worst['defect'] = max(worst['defect'], abs((mD - m1 - m0) / mD - ind))  # defect = Indep
        psi = psi_of(D, full)
        worst['geom'] = max(worst['geom'], abs(geometric(prior, psi, phi, full) - bel))
        cbel, cdis, cind = CR_tri(prior, D, phi, full)
        worst['demp'] = max(worst['demp'], abs(dempster(prior, psi, phi, full) - cbel))
        # M3 additivity: true + false + indep = M(D) (D two-valued here)
        s3 = M3(prior, D + [(phi, 1)], full) + M3(prior, D + [(phi, 0)], full) + M3(prior, D + [(phi, 'i')], full)
        worst['m3'] = max(worst['m3'], abs(s3 - M3(prior, D, full)))
        # CR weight (plausibility) is not a semimeasure
        c = M_CR(prior, D, full)
        cs = M_CR(prior, D + [(phi, 1)], full) + M_CR(prior, D + [(phi, 0)], full)
        worst['crsum_min'] = min(worst['crsum_min'], cs - c)                   # must be >= 0
        if cs - c > 1e-12:
            n_cr_strict += 1
        # order (in)dependence on the full sequence D + (phi, label by v)
        seq = D + [(phi, 1 if (phi >> v) & 1 else 0)]
        if M_PR(prior, seq, full) > 0:
            target = -LOG2(M_PR(prior, seq, full)) + LOG2(M_PR(prior, [], full))
            cr_losses = []
            for perm in itertools.permutations(seq):
                L = 0.0
                Lcr = 0.0
                for t in range(len(perm)):
                    prev = list(perm[:t])
                    L += -LOG2(M_PR(prior, prev + [perm[t]], full) / M_PR(prior, prev, full))
                    pb, pd, pi_ = CR_tri(prior, prev, perm[t][0], full)
                    q = pb if perm[t][1] == 1 else pd
                    Lcr += -LOG2(q) if q > 0 else float('inf')
                worst['pr_order'] = max(worst['pr_order'], abs(L - target))
                cr_losses.append(Lcr)
            finite = [x for x in cr_losses if x < float('inf')]
            if len(finite) == len(cr_losses) and len(finite) > 1:
                spread = max(finite) - min(finite)
                if spread > cr_order_max:
                    cr_order_max = spread
                    cr_order_example = (trial, len(seq), [round(x, 4) for x in sorted(set(round(y, 6) for y in finite))])
    print(f"trials: {n_trials}")
    print(f"(A1) max of M(D+(phi,1)) + M(D+(phi,0)) - M(D)   [must be <= 0]: {worst['semi']:.3e}")
    print(f"(A1) max |defect/M(D) - Indep_D(phi)|            [must be 0]   : {worst['defect']:.3e}")
    print(f"(A2) max |geometric conditioning - PR Bel|       [must be 0]   : {worst['geom']:.3e}")
    print(f"(A3) max |Dempster conditioning - CR Bel|        [must be 0]   : {worst['demp']:.3e}")
    print(f"(A5) max |M3(true)+M3(false)+M3(indep) - M3(D)|  [must be 0]   : {worst['m3']:.3e}")
    print(f"(A4) min of M_C(D+(phi,1)) + M_C(D+(phi,0)) - M_C(D) [must be >= 0]: {worst['crsum_min']:.3e};"
          f" strictly > 0 in {n_cr_strict} trials")
    print(f"(A6) max |PR cumulative loss over a permutation - (-log M(D_n) + log M(empty))| [must be 0]: {worst['pr_order']:.3e}")
    print(f"(A6) largest spread of the CR (Dempster) cumulative loss over permutations of one sequence: "
          f"{cr_order_max:.4f} bits; example (trial, length, distinct losses): {cr_order_example}")


# ---------------------------------------------------------------- Part B
def partB_closed(t_max, w):
    """w = dict(empty, all, coin, three, inc).  Stream: R_1..R_t all true."""
    cons = w['empty'] + w['all'] + w['coin'] + w['three']
    rows = []
    Lpr = 0.0
    Lcr = 0.0
    for t in range(1, t_max + 1):
        # PR: M(D_t) = w_all + w_coin 2^-t + w_three 3^-t   (consistent theories proving R_1..R_t)
        Mt = w['all'] + w['coin'] * 2.0 ** (-t) + w['three'] * 3.0 ** (-t)
        Lpr_total = -LOG2(Mt) + LOG2(cons)
        # CR (Dempster) predictive for R_t given R_1..R_{t-1}
        num = w['all'] + w['coin'] * 2.0 ** (-(t - 1)) * 0.5 + w['three'] * (2.0 / 3.0) ** (t - 1) * (1.0 / 3.0)
        den = w['empty'] + w['all'] + w['coin'] * 2.0 ** (-(t - 1)) + w['three'] * (2.0 / 3.0) ** (t - 1)
        Lcr += -LOG2(num / den)
        # CR plausibility weight M_C(D_t) (Haenni's 0/1 'does not contradict' score)
        Mc = w['empty'] + w['all'] + w['coin'] * 2.0 ** (-t) + w['three'] * (2.0 / 3.0) ** t
        rows.append((t, Lpr_total, Lcr, -LOG2(Mc) + LOG2(cons)))
    return rows


def partB_brute(k, w):
    """explicit theories over k atoms: partial assignments in {1,0,None}^k with weights."""
    theories = []
    theories.append((tuple([None] * k), w['empty']))
    theories.append((tuple([1] * k), w['all']))
    for bits in itertools.product([0, 1], repeat=k):
        theories.append((bits, w['coin'] * 2.0 ** (-k)))
    for tri in itertools.product([0, 1, None], repeat=k):
        theories.append((tri, w['three'] * 3.0 ** (-k)))
    cons = sum(x for (_, x) in theories)

    def proves_true(A, i):
        return A[i] == 1

    Lpr = []
    Lcr = 0.0
    out = []
    for t in range(1, k + 1):
        Mt = sum(x for (A, x) in theories if all(A[i] == 1 for i in range(t)))
        Lpr_t = -LOG2(Mt) + LOG2(cons)
        # CR: theory A u D_{t-1}; consistent iff no A[i] == 0 for i < t-1
        den = sum(x for (A, x) in theories if all(A[i] != 0 for i in range(t - 1)))
        num = sum(x for (A, x) in theories if all(A[i] != 0 for i in range(t - 1)) and A[t - 1] == 1)
        Lcr += -LOG2(num / den)
        out.append((t, Lpr_t, Lcr))
    return out


def partB():
    print()
    print("=== Part B: stream R_1, R_2, ... all labelled true (truth: 'all atoms true') ===")
    w = dict(empty=0.25, all=0.25, coin=0.2, three=0.2, inc=0.1)
    print(f"prior weights: {w}  (losses in bits, semimeasure convention, normalised by the consistent mass)")
    rows = partB_closed(40, w)
    print(" t   PR loss   CR(Dempster) loss   -log M_C (0/1 score, not a predictor)")
    for (t, a, b, c) in rows:
        if t in (1, 2, 3, 5, 10, 20, 30, 40):
            print(f"{t:3d}  {a:8.4f}   {b:10.4f}          {c:8.4f}")
    lim_pr = -LOG2(w['all']) + LOG2(w['empty'] + w['all'] + w['coin'] + w['three'])
    lim_rate = LOG2((w['empty'] + w['all']) / w['all'])
    print(f"PR limit -log(w_all/cons) = {lim_pr:.4f} bits; CR asymptotic rate log((w_empty+w_all)/w_all) = {lim_rate:.4f} bits/step")
    print(f"CR slope between t=20 and t=40: {(rows[39][2] - rows[19][2]) / 20:.4f} bits/step")
    # brute-force cross-check
    maxdiff = 0.0
    for k in range(1, 8):
        br = partB_brute(k, w)
        cl = partB_closed(k, w)
        for (t, a, b), (t2, a2, b2, _) in zip(br, cl):
            maxdiff = max(maxdiff, abs(a - a2), abs(b - b2))
    print(f"brute force (k <= 7 atoms, 2^k + 3^k + 2 explicit theories) vs closed form: max |difference| = {maxdiff:.2e}")


# ---------------------------------------------------------------- Part C
def partC():
    print()
    print("=== Part C: incomplete truth T* (two models); two-valued vs three-valued presentation ===")
    k = 3
    nv = 8
    full = (1 << nv) - 1
    Tstar = (1 << 0) | (1 << 1)          # models v0, v1
    # prior: all 255 consistent theories (model sets) with weight 2^-(|model set| ... ) style code, plus inconsistent
    raw = []
    for A in range(1, full + 1):
        size = bin(A).count('1')
        raw.append((A, 2.0 ** (-(nv - size)) * (1.0 + 0.1 * (A % 7))))   # an arbitrary positive prior
    s = sum(x for (_, x) in raw)
    prior = [(A, 0.9 * x / s) for (A, x) in raw] + [(0, 0.1)]
    # two-valued complete presentation: every sentence T* decides, with its label
    D2 = []
    D3 = []
    for phi in range(0, full + 1):
        if subset(Tstar, phi):
            D2.append((phi, 1)); D3.append((phi, 1))
        elif subset(Tstar, full & ~phi):
            D2.append((phi, 0)); D3.append((phi, 0))
        else:
            D3.append((phi, 'i'))
    psi = psi_of(D2, full)
    support2 = [A for (A, w) in prior if A != 0 and subset(A, psi)]
    print(f"two-valued: psi_D = T* ? {psi == Tstar};  consistent theories proving all data: "
          f"{sorted(bin(A) for A in support2)}  (T* and its two completions)")
    ind = 1 << 0                          # the sentence true exactly at v0: independent of T*
    b, d, i = PR_tri(prior, D2, ind, full)
    print(f"two-valued limit trichotomy of an independent sentence (true at v0 only): "
          f"Bel={b:.4f} Dis={d:.4f} Indep={i:.4f}  (all three positive: prior shares)")
    support3 = [A for (A, w) in prior if A != 0 and M3([(A, w)], D3, full) > 0]
    print(f"three-valued: theories compatible with all data: {[bin(A) for A in support3]}  (only [T*])")


# ---------------------------------------------------------------- Part D
def nu_half(A, D, full):
    """graded consistency-requiring weight of one consistent theory A (mask), grade 1/2 per datum A leaves open"""
    if A == 0:
        return 0.0
    psi = psi_of(D, full)
    if A & psi == 0:
        return 0.0
    f = 1.0
    for (phi, b) in D:
        if subset(A, lit(phi, b, full)):
            continue
        if subset(A, lit(phi, 1 - b, full)):
            return 0.0
        f *= 0.5
    return f


def M_half(prior, D, full):
    return sum(w * nu_half(A, D, full) for (A, w) in prior if A != 0)


def partD():
    print()
    print("=== Part D: graded consistency-requiring weight with grade 1/2 (notes.md Section 2.4) ===")
    k = 3
    nv = 8
    full = (1 << nv) - 1
    worst_semi = -1e9
    worst_dom = 1e9
    n_entailed_cost = 0
    n_trials = 400
    for trial in range(n_trials):
        prior = make_prior(nv, n_theories=random.randint(3, 25), inc_weight=random.choice([0.0, 0.05, 0.3]))
        v = random.randrange(nv)
        D = []
        for _ in range(random.randint(0, 3)):
            phi = random.randint(1, full - 1)
            D.append((phi, 1 if (phi >> v) & 1 else 0))
        phi = random.randint(1, full - 1)
        mh = M_half(prior, D, full)
        s = M_half(prior, D + [(phi, 1)], full) + M_half(prior, D + [(phi, 0)], full)
        worst_semi = max(worst_semi, s - mh)                                   # must be <= 0
        worst_dom = min(worst_dom, mh - M_PR(prior, D, full))                  # must be >= 0
        # an entailed datum: phi' := a sentence implied by psi_D; does it cost under M_half?
        psi = psi_of(D, full)
        if D and psi != 0:
            weaker = psi | random.randint(0, full)                             # psi |- weaker
            if weaker != full:
                c_half = M_half(prior, D + [(weaker, 1)], full)
                c_pr = M_PR(prior, D + [(weaker, 1)], full)
                if mh > 0 and c_half < mh - 1e-12:
                    n_entailed_cost += 1
                assert abs(c_pr - M_PR(prior, D, full)) < 1e-12               # PR: entailed data cost 0
    print(f"trials: {n_trials}")
    print(f"max of M_half(D+(phi,1)) + M_half(D+(phi,0)) - M_half(D)  [must be <= 0]: {worst_semi:.3e}")
    print(f"min of M_half(D) - M_PR(D)                                 [must be >= 0]: {worst_dom:.3e}")
    print(f"entailed datum: PR weight unchanged in every trial (asserted); M_half strictly smaller in "
          f"{n_entailed_cost} trials (it charges for entailed data)")


if __name__ == "__main__":
    print(f"seed {SEED}")
    partA()
    partB()
    partC()
    partD()
