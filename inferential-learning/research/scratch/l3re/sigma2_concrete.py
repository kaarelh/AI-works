"""Independent re-check of Thm D'(c) Sigma2 construction with CONCRETE x_t computation
(least x<=t unrefuted by y<=t, else t+1), ASYMMETRIC ordered I_t (proof of ~(s&s') and of
~(s'&s) found at different stages), dummy-variable Sigma1/Pi1/Delta0 sentences, and
PA-refutable (self-incompatible) sentences incompatible with many others.
Sentence model: refutation time ref(x) in N∪{inf}: x is refuted by stage t iff ref(x)<=t.
 - Sigma2 true: some x* with ref=inf (others finite)
 - Sigma2 false: all ref finite
 - Pi1 'Ay R(y)' (dummy x): every x refuted at the same stage y0 (false) or never (true)
 - Sigma1 'Ex R(x)' (dummy y): ref(x)=inf if R(x) else 0  (refuted immediately at y=0)
"""
import random
from fractions import Fraction as F
INF = float('inf')

def make_sent(rng, kind, idx):
    if kind == 'S2true':
        xs = rng.randint(0, 30)
        refs = {}
        def ref(x, xs=xs, seed=rng.random()):
            if x == xs: return INF
            r = random.Random(hash((seed, x)))
            return x + r.randint(0, 400) if x < xs else (x + r.randint(0, 50) if r.random() < .7 else INF)
        return dict(true=True, idx=idx, ref=ref, kind=kind)
    if kind == 'S2false':
        g = rng.choice([1.3, 1.6, 2.0, 2.5])
        seed = rng.random()
        def ref(x, g=g, seed=seed):
            r = random.Random(hash((seed, x)))
            # long stable runs: x refuted at roughly g^x scale
            return int(min(10**9, (x + 2) ** g * r.uniform(1, 3)))
        return dict(true=False, idx=idx, ref=ref, kind=kind)
    if kind == 'Pi1true':
        return dict(true=True, idx=idx, ref=lambda x: INF, kind=kind)
    if kind == 'Pi1false':
        y0 = rng.randint(0, 3000)
        return dict(true=False, idx=idx, ref=lambda x, y0=y0: y0, kind=kind)
    if kind == 'S1true':
        w = rng.randint(0, 200)
        return dict(true=True, idx=idx, ref=lambda x, w=w: INF if x == w else 0, kind=kind)
    if kind == 'S1false':
        return dict(true=False, idx=idx, ref=lambda x: 0, kind=kind)

def xt(s, t):
    for x in range(0, t + 1):
        if not (s['ref'](x) <= t):
            return x
    return t + 1

def run(seed, N=60, T=4000):
    rng = random.Random(seed)
    kinds = ['S2true', 'S2false', 'Pi1true', 'Pi1false', 'S1true', 'S1false']
    w = [3, 5, 1, 1, 1, 1]
    sents = [make_sent(rng, rng.choices(kinds, w)[0], rng.randint(0, 200)) for _ in range(N)]
    # PA-refutable sentences: some false ones are self-incompatible and incompatible with everything
    refutable = set(i for i in range(N) if not sents[i]['true'] and rng.random() < .15)
    od = {}  # ordered pair -> discovery stage
    for i in range(N):
        for j in range(N):
            if i in refutable or j in refutable:
                pass
            elif i == j or (sents[i]['true'] and sents[j]['true']) or rng.random() > .1:
                continue
            if (j, i) in od and rng.random() < .5:
                od[(i, j)] = od[(j, i)] + rng.randint(0, 600)
            else:
                od[(i, j)] = max(sents[i]['idx'], sents[j]['idx']) + rng.randint(0, 1500)
    # sanity: no ordered pair of two trues
    assert all(not (sents[i]['true'] and sents[j]['true']) for (i, j) in od)
    prevx = [None] * N; last = [-1] * N
    stage_viol_both = 0; stage_viol_one = 0; false_change_nonzero = 0
    falsezero_count = [0] * N
    hist = [[] for _ in range(N)]
    out = {i: [] for i in range(N)}
    for (i, j), d in od.items(): out[i].append((j, d))
    for t in range(T):
        a = [None] * N
        for i, s in enumerate(sents):
            x = xt(s, t)
            if t > 0 and prevx[i] is not None and x != prevx[i]:
                last[i] = t
            prevx[i] = x
            if t >= s['idx']:
                a[i] = t - max(s['idx'], last[i])
        P = [F(0)] * N
        for i in range(N):
            if a[i] is None: continue
            v = 1 - F(1, 2 ** min(a[i], 200))
            for (j, d) in out[i]:
                if d <= t and a[j] is not None and a[j] >= a[i]:
                    v = min(v, F(1, 2 ** min(a[j], 200)))
            P[i] = v
            hist[i].append(float(P[i]))
        for (i, j), d in od.items():
            if d <= t and i <= j:
                both = (j, i) in od and od[(j, i)] <= t
                if P[i] + P[j] > 1:
                    if both: stage_viol_both += 1
                    else: stage_viol_one += 1
        for i, s in enumerate(sents):
            if not s['true'] and last[i] == t and t >= s['idx']:
                if P[i] != 0: false_change_nonzero += 1
                falsezero_count[i] += 1
    tr = [i for i in range(N) if sents[i]['true']]
    fa = [i for i in range(N) if not sents[i]['true']]
    true_final = sorted(round(hist[i][-1], 6) for i in tr)
    false_zero_hits = sorted(falsezero_count[i] for i in fa)
    return dict(seed=seed, n_true=len(tr), n_false=len(fa), n_refutable=len(refutable), n_ordered_edges=len(od),
                viol_when_both_orders_found=stage_viol_both, viol_when_one_order_only=stage_viol_one,
                false_change_with_P_nonzero=false_change_nonzero,
                min_true_final=min(true_final) if tr else None,
                n_true_final_below_0p99=sum(1 for v in true_final if v < .99),
                min_false_zero_hits=min(false_zero_hits) if fa else None)

if __name__ == '__main__':
    for sd in range(3):
        print(run(sd))
