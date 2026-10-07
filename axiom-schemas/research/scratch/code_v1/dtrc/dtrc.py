"""DTRC: Determinate Templates with Refutation Clustering.

  1. normalise data (closure-normal form, de Bruijn; parameters renamed canonically); discard data the
     world oracle refutes (known-false mistakes);
  2. agglomerative clustering from singletons; candidate merges are tried in order of decreasing size of
     the common rigid prefix of the merged set; a merge A+B is accepted iff Min(A u B) (minimal covering
     DT° templates) contains a template none of whose searched instances is refuted.  A failed pair stays
     failed for all super-clusters (monotone: covering templates of a superset are covering templates of
     the subset, and refutation is upward closed);
  3. per cluster, the cautious DT° verifier: accept q iff q is an instance of every unrefuted minimal
     covering template of the cluster;
  4. assert the union.
"""
import heapq
import time
from .syntax import BINDERS, LEAVES, kids, rebuild, canon_params, pp
from .templates import match, geq, canon, rigid_size
from .mincover import MinCover


def _key(c):
    h = c[0]
    if h in LEAVES:
        return c
    if h in ('M', 'C'):
        return (h, c[1], len(c[2]))
    return (h, len(c) - 1)


HOLE = ('?',)


def prefix_of(s):
    return s


def prefix_meet(a, b):
    """common prefix of two prefix-trees (HOLE marks disagreement)"""
    if a is HOLE or b is HOLE or a[0] == '?' or b[0] == '?':
        return HOLE
    if _key(a) != _key(b):
        return HOLE
    if a[0] in LEAVES:
        return a
    return rebuild(a, [prefix_meet(x, y) for x, y in zip(kids(a), kids(b))])


def prefix_size(a):
    if a[0] == '?':
        return 0
    if a[0] in LEAVES:
        return 1
    return 1 + sum(prefix_size(k) for k in kids(a))


class Cluster:
    __slots__ = ('id', 'data', 'prefix', 'mins', 'acc', 'truncated')

    def __init__(self, cid, data, prefix):
        self.id, self.data, self.prefix = cid, data, prefix
        self.mins, self.acc, self.truncated = None, None, False


class DTRC:
    def __init__(self, refuter, min_kw=None, verbose=False, use_refutation=True, k_stop=None,
                 min_score=0):
        self.R = refuter
        self.min_kw = min_kw or {}
        self.verbose = verbose
        self.use_refutation = use_refutation      # False: skeleton clustering (needs k_stop)
        self.k_stop = k_stop
        self.min_score = min_score
        self.stats = {}

    # ------------------------------------------------------------------ merge test
    def _mins(self, data):
        mc = MinCover(data, **self.min_kw)
        mins = mc.minimal()
        return mins, mc.truncated

    def _merge_ok(self, data):
        mins, trunc = self._mins(data)
        self.stats['min_calls'] += 1
        self.stats['min_truncated'] += int(trunc)
        if not self.use_refutation:
            return True, mins
        for T in sorted(mins, key=lambda T: -rigid_size(T)):
            if not self.R.refuted(T, data):
                return True, mins
        return False, mins

    # ------------------------------------------------------------------ fit
    def fit(self, data):
        t0 = time.time()
        self.stats = {'min_calls': 0, 'min_truncated': 0, 'merge_tests': 0, 'merges': 0, 'failed_merges': 0}
        data = list(dict.fromkeys(canon_params(d) for d in data))
        self.discarded = []
        kept = []
        for d in data:
            if self.use_refutation and self.R.oracle.refutes(d):
                self.discarded.append(d)
            else:
                kept.append(d)
        clusters = {}
        for i, d in enumerate(kept):
            clusters[i] = Cluster(i, [d], d)
        next_id = len(kept)
        failed = set()
        heap = []
        ids = sorted(clusters)
        for a in range(len(ids)):
            for b in range(a + 1, len(ids)):
                ca, cb = clusters[ids[a]], clusters[ids[b]]
                sc = prefix_size(prefix_meet(ca.prefix, cb.prefix))
                if sc >= self.min_score:
                    heapq.heappush(heap, (-sc, ca.id, cb.id))
        while heap:
            if self.k_stop is not None and len(clusters) <= self.k_stop:
                break
            negsc, a, b = heapq.heappop(heap)
            if a not in clusters or b not in clusters:
                continue
            if (a, b) in failed or (b, a) in failed:
                continue
            ca, cb = clusters[a], clusters[b]
            merged = ca.data + cb.data
            self.stats['merge_tests'] += 1
            ok, mins = self._merge_ok(merged)
            if not ok:
                failed.add((a, b))
                self.stats['failed_merges'] += 1
                continue
            self.stats['merges'] += 1
            c = Cluster(next_id, merged, prefix_meet(ca.prefix, cb.prefix))
            next_id += 1
            del clusters[a], clusters[b]
            for x in list(clusters):
                if (a, x) in failed or (x, a) in failed or (b, x) in failed or (x, b) in failed:
                    failed.add((c.id, x))
            clusters[c.id] = c
            for x, cx in clusters.items():
                if x == c.id or (c.id, x) in failed:
                    continue
                sc = prefix_size(prefix_meet(c.prefix, cx.prefix))
                if sc >= self.min_score:
                    heapq.heappush(heap, (-sc, min(c.id, x), max(c.id, x)))
            if self.verbose:
                print('merge -> %d clusters (score %d)' % (len(clusters), -negsc))
        self.clusters = list(clusters.values())
        # per-cluster cautious verifier
        for c in self.clusters:
            c.mins, c.truncated = self._mins(c.data)
            if self.use_refutation:
                c.acc = [T for T in c.mins if not self.R.refuted(T, c.data)]
            else:
                c.acc = list(c.mins)
            if not c.acc:
                c.acc = None   # accept exactly the data
        self.stats['time'] = round(time.time() - t0, 2)
        self.stats['clusters'] = len(self.clusters)
        self.stats['discarded'] = len(self.discarded)
        self.stats.update(self.R.stats() if self.use_refutation else {})
        return self

    # ------------------------------------------------------------------ verifier
    def cluster_accepts(self, c, q):
        if c.acc is None:
            return q in c.data
        return all(match(T, q) is not None for T in c.acc)

    def accepts(self, q):
        q = canon_params(q)
        return any(self.cluster_accepts(c, q) for c in self.clusters)

    def accepting_clusters(self, q):
        q = canon_params(q)
        return [c for c in self.clusters if self.cluster_accepts(c, q)]

    def labels_for(self, data):
        """cluster index for each datum (by membership in the cluster's data; -1 if discarded)"""
        idx = {}
        for i, c in enumerate(self.clusters):
            for d in c.data:
                idx[d] = i
        return [idx.get(canon_params(d), -1) for d in data]


def tagged_learner(data_by_tag, refuter=None, min_kw=None):
    """the tagged DT° cautious verifier (optionally with refutation filtering of minimal templates)"""
    out = {}
    for tag, D in data_by_tag.items():
        D = list(dict.fromkeys(canon_params(d) for d in D))
        mc = MinCover(D, **(min_kw or {}))
        mins = mc.minimal()
        if refuter is not None:
            acc = [T for T in mins if not refuter.refuted(T, D)]
        else:
            acc = mins
        out[tag] = {'mins': mins, 'acc': acc, 'truncated': mc.truncated, 'data': D}
    return out
