"""
L3, Theorem D' (c) (revised after verification): sanity check of the construction of
computable, weakly coherent credences that gradually verify the Sigma_2 sentences.

Abstract model (faithful to what the construction reads off the sentences):
  * each Sigma_2 sentence s = Ex Ay R(x,y) has an index (stage at which it is enumerated)
    and a set of "witness-change" stages, i.e. stages t with x_t(s) != x_{t-1}(s).
    True s: finitely many changes.  False s: infinitely many (x_t(s) is unbounded).
  * PA-incompatibility edges {s, s'} (PA |- ~(s & s')) exist only between pairs that are
    not both true (PA is sound); self-loops only on false sentences. Each edge is
    discovered (a proof with code <= t appears) at some finite stage.
Credence:  a_t(s) = t - max(index(s), last change <= t)
           P_t(s)  = min(1 - 2^-a(s), min{2^-a(s') : {s,s'} discovered by t, a(s') >= a(s)}).
Checks:
  (1) at every stage, every discovered incompatible pair has P_t(s) + P_t(s') <= 1 (exact);
  (2) every false sentence has P_t = 0 at each of its change stages (so liminf = 0);
  (3) every true sentence ends with credence 1 - 2^-a_T(s) (no competitor left in the min),
      i.e. tends to 1.
The adversary gives false sentences early indices and super-exponentially long stable runs,
and gives true sentences late stabilisation, to stress the 'competitor is older' case.
Exponents are capped at CAP for speed; the cap is monotone, so check (1) is unaffected.
"""
import random
from fractions import Fraction as F

CAP = 120
HMAX = 10 ** 6  # false sentences: change stages generated up to HMAX (far beyond any T used)


def run(seed, N=70, T=2500, p_true=0.4, p_edge=0.12):
    rng = random.Random(seed)
    sents = []
    for _ in range(N):
        true = rng.random() < p_true
        idx = rng.randint(0, 150)
        if true:
            k = rng.randint(0, 6)
            ch = sorted(rng.sample(range(idx, idx + 900), k))
        else:
            c = idx + rng.randint(1, 40)
            g = rng.choice([1.2, 1.5, 2.0, 3.0])
            ch = []
            while c < HMAX:  # instance independent of the horizon T
                ch.append(int(c))
                c = c * g + rng.randint(1, 20)
        sents.append(dict(true=true, idx=idx, ch=ch, chset=set(ch)))
    edges = []
    for i in range(N):
        for j in range(i, N):
            if sents[i]['true'] and sents[j]['true']:
                continue
            if i == j and rng.random() > 0.2:
                continue
            if rng.random() < p_edge or i == j:
                d = rng.randint(max(sents[i]['idx'], sents[j]['idx']), 1200)
                edges.append((i, j, d))
    nbrs = {i: [] for i in range(N)}
    for (i, j, d) in edges:
        nbrs[i].append((j, d))
        if i != j:
            nbrs[j].append((i, d))
    last = [-1] * N
    viol = 0
    false_change_nonzero = 0
    P = [F(0)] * N
    a = [None] * N
    for t in range(T):
        for i, s in enumerate(sents):
            if t in s['chset']:
                last[i] = t
            a[i] = None if t < s['idx'] else t - max(s['idx'], last[i])
        for i in range(N):
            if a[i] is None:
                P[i] = F(0)
                continue
            v = 1 - F(1, 2 ** min(a[i], CAP))
            for (j, d) in nbrs[i]:
                if d <= t and a[j] is not None and a[j] >= a[i]:
                    v = min(v, F(1, 2 ** min(a[j], CAP)))
            P[i] = v
        for (i, j, d) in edges:
            if d <= t and P[i] + P[j] > 1:
                viol += 1
        for i, s in enumerate(sents):
            if not s['true'] and t in s['chset'] and P[i] != 0:
                false_change_nonzero += 1
    tr = [i for i in range(N) if sents[i]['true']]
    fa = [i for i in range(N) if not sents[i]['true']]
    blocked = [i for i in tr if P[i] != 1 - F(1, 2 ** min(a[i], CAP))]
    unblocked = len(tr) - len(blocked)
    # proof of (c): a true s can be blocked at T only by a FALSE competitor whose index and
    # last change are <= T0(s) and whose next change is still in the future (> T)
    explained = 0
    for i in blocked:
        T0 = T - 1 - a[i]
        blockers = [j for (j, d) in nbrs[i] if d <= T - 1 and a[j] is not None and a[j] >= a[i]]
        if blockers and all((not sents[j]['true']) and min(c for c in sents[j]['ch'] if c > T - 1) > T - 1
                            and max(sents[j]['idx'], last[j]) <= T0 for j in blockers):
            explained += 1
    min_true = min((float(P[i]) for i in tr), default=None)
    min_age = min((a[i] for i in tr), default=None)
    return dict(seed=seed, n_true=len(tr), n_false=len(fa), n_edges=len(edges),
                pair_violations=viol, false_change_stage_with_P_nonzero=false_change_nonzero,
                true_unblocked_at_T=f"{unblocked}/{len(tr)}",
                blocked_explained_by_pending_false_competitor=f"{explained}/{len(blocked)}", min_true_P_at_T=min_true,
                min_true_age_at_T=min_age)


if __name__ == "__main__":
    for seed in range(4):
        print(run(seed))
    # same seed-3 instance with a longer horizon: sentences blocked at T=2500 (if any) must unblock
    print(run(3, T=9000))
