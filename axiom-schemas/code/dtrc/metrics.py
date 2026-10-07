"""Evaluation metrics: clustering agreement, per-target exactness, soundness probes."""
import random
from collections import Counter
from math import comb
from .syntax import canon_params
from .templates import match, geq, equiv, instantiate, metas, meta_sort
from .refute import body_pool


def adjusted_rand(labels_true, labels_pred):
    n = len(labels_true)
    if n < 2:
        return 1.0
    cont = Counter(zip(labels_true, labels_pred))
    a = Counter(labels_true)
    b = Counter(labels_pred)
    sum_comb = sum(comb(v, 2) for v in cont.values())
    sa = sum(comb(v, 2) for v in a.values())
    sb = sum(comb(v, 2) for v in b.values())
    total = comb(n, 2)
    expected = sa * sb / total
    maxv = (sa + sb) / 2
    if maxv == expected:
        return 1.0
    return (sum_comb - expected) / (maxv - expected)


def purity(labels_true, labels_pred):
    clusters = {}
    for t, p in zip(labels_true, labels_pred):
        clusters.setdefault(p, []).append(t)
    return sum(Counter(v).most_common(1)[0][1] for v in clusters.values()) / max(1, len(labels_true))


def exact_for(acc_templates, T):
    """the cautious acceptance set  cap inst(acc)  equals inst(T)  (sufficient syntactic test: some
    member is equivalent to T and every member is >= T)"""
    if not acc_templates:
        return False
    return all(geq(A, T) for A in acc_templates) and any(geq(T, A) for A in acc_templates)


def complete_for(acc_templates, T):
    return bool(acc_templates) and all(geq(A, T) for A in acc_templates)


def targets_of(s, targets):
    s = canon_params(s)
    return [k for k, T in targets.items() if match(T, s) is not None]


def sample_instances(T, lang, rng, n, data=None):
    """random instances of a DT° template: bodies from the refuter pools, plus cross-filled data bodies"""
    ms = metas(T)
    names = sorted(ms)
    if not names:
        return [T]
    pools = {m: body_pool(lang, meta_sort(m), ms[m]) for m in names}
    thetas = []
    if data:
        for d in data:
            th = match(T, d)
            if th is not None:
                thetas.append(th)
    out = []
    for i in range(n):
        th = {}
        for m in names:
            if thetas and rng.random() < 0.5:
                th[m] = rng.choice(thetas)[m]
            else:
                th[m] = rng.choice(pools[m])
        out.append(canon_params(instantiate(T, th)))
    return out
