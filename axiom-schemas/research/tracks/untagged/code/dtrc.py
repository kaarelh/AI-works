# dtrc.py -- Determinate Templates with Refutation Clustering (DTRC), plus template refutation search.
# v2 (after referee): global negative cache in World (monotone refutation), decision log, audit against the
# final negative set, run_fixpoint, |Min(X)| statistics.  v1 is kept in v1_outputs/dtrc_v1.py.txt.
import itertools, random
from dtlib import *
import refuters as R

# ------------------------------------------------------------------ instance pools for refutation search
def body_pool(sort, arity, lang):
    hs = [('h', j) for j in range(arity)]
    q1, q2 = ('p', 'q1'), ('p', 'q2')
    if lang == 'arith':
        if sort == 'T':
            return [Z, S(Z), q1] + hs + [S(h) for h in hs] + [add(h, S(Z)) for h in hs]
        atoms = [eq(Z, Z), eq(Z, S(Z)), eq(q1, Z), eq(q1, S(Z)), NOT(eq(q1, q1)), eq(q1, q2)]
        for h in hs:
            atoms += [eq(h, Z), eq(h, S(Z)), eq(S(h), h), NOT(eq(h, Z)), eq(h, q1), eq(add(h, h), h)]
        for a, b in itertools.combinations(hs, 2):
            atoms += [eq(a, b), NOT(eq(a, b))]
        return atoms
    else:
        if sort == 'T':
            return [q1, q2] + hs
        atoms = [eq(q1, q1), NOT(eq(q1, q1)), mem(q1, q2), mem(q1, q1)]
        for h in hs:
            atoms += [mem(h, h), NOT(mem(h, h)), mem(h, q1), NOT(mem(h, q1)), mem(q1, h), eq(h, q1), NOT(eq(h, h))]
        for a, b in itertools.permutations(hs, 2):
            atoms += [mem(a, b), NOT(mem(a, b)), eq(a, b)]
        return atoms

def meta_sig(T):
    """name -> (sort, arity)"""
    sig = {}
    def walk(t):
        if t[0] == 'M':
            sig[t[1]] = ('F' if t[1][0] == 'F' else 'T', len(t) - 2)
        for k in kids(t): walk(k)
    walk(T)
    return sig

class World:
    def __init__(self, lang, designated=(), B=3, hf=3, budget=4000, seed=0, logic=True, global_neg=True):
        self.lang, self.designated, self.B, self.hf, self.budget = lang, list(designated), B, hf, budget
        self.seed, self.logic = seed, logic
        self.logic_size, self.logic_budget = 45, 60
        self.cache = {}          # canon(T) -> result of T's own pool search (or a cached-negative hit)
        self.calls = 0
        # v2 (referee U5/3.5): global set N of refuted sentences.  T is reported refuted iff it covers some n in N
        # or its own budgeted pool search finds a refuted instance (which is then added to N).  So the implemented
        # refutation is monotone in the instance order for templates tested after the negative was found, and a
        # finished run can be audited against the FIXED finite oracle Ref := N_final (see DTRC.audit).
        self.global_neg = global_neg
        self.neg = []            # list of (sentence, method), in order of discovery
        self.negset = set()
        self.checked = {}        # canon(T) -> number of negatives already checked against T
    def refute_sentence(self, s, try_logic=True):
        """return a method string if s (closure) is refuted, else None"""
        if self.lang == 'arith':
            w = R.refute_arith(s, B=self.B)
            if w is not None: return 'D0+forallE %s' % (w,)
        else:
            w = R.refute_hf(s, n=self.hf)
            if w is not None: return 'HF-counterexample %s' % (w,)
        if self.logic and try_logic and size(s) <= self.logic_size:
            try:
                if R.logic_unsat([s]): return 'logic'
                if self.designated and R.logic_unsat([s] + self.designated): return 'coherence(designated)'
            except RecursionError:
                pass
        return None
    def add_negative(self, s, m):
        if s not in self.negset:
            self.negset.add(s); self.neg.append((s, m))
    def covered_negative(self, T, start=0):
        """first globally known refuted sentence covered by T (checking negatives from index `start` on)"""
        for n, m in self.neg[start:]:
            if covers(T, n): return (n, 'cached:' + m)
        return None
    def refute_template(self, T):
        """budgeted search for a refuted instance; returns (instance, method) or None"""
        key = canon(T)
        if key in self.cache and self.cache[key] is not None: return self.cache[key]
        if self.global_neg:
            r = self.covered_negative(T, self.checked.get(key, 0))
            self.checked[key] = len(self.neg)
            if r is not None:
                self.cache[key] = r; return r
        if key in self.cache: return None
        self.calls += 1
        sig = meta_sig(T)
        names = sorted(sig)
        if not names:
            m = self.refute_sentence(T)
            res = (T, m) if m else None
            if res: self.add_negative(*res)
            self.cache[key] = res; return res
        pools = [body_pool(sig[n][0], sig[n][1], self.lang) for n in names]
        total = 1
        for p in pools: total *= len(p)
        rng = random.Random(self.seed)
        if total <= self.budget:
            combos = itertools.product(*pools)
        else:
            def gen():
                # small systematic part: all-equal-index choices, then random sampling
                for i in range(max(len(p) for p in pools)):
                    yield tuple(p[min(i, len(p) - 1)] for p in pools)
                for _ in range(self.budget):
                    yield tuple(rng.choice(p) for p in pools)
            combos = gen()
        res = None
        seen = set()
        nlog = 0
        for combo in combos:
            theta = dict(zip(names, combo))
            s = instantiate(T, theta)
            if s in seen: continue
            seen.add(s)
            m = self.refute_sentence(s, try_logic=nlog < self.logic_budget)
            nlog += 1
            if m:
                res = (s, m); break
        if res: self.add_negative(*res)
        self.cache[key] = res
        return res

# ------------------------------------------------------------------ DTRC
class DTRC:
    def __init__(self, world, mincov_fn=mincov):
        self.world = world
        self.mincov = mincov_fn
        self.tests = 0
        self.mcache = {}
        self.log = []            # (frozenset X, witness template or None) for every coherence decision
        self.minsizes = []       # |Min(X)| for every coherence test
    def minc(self, X):
        key = frozenset(X)
        if key not in self.mcache:
            self.mcache[key] = self.mincov(list(key))
        return self.mcache[key]
    def coherent(self, X):
        """some minimal covering template with no refuted instance found (budgeted)"""
        self.tests += 1
        Ms = self.minc(X)
        self.minsizes.append(len(Ms))
        for T in Ms:
            if self.world.refute_template(T) is None:
                self.log.append((frozenset(X), T))
                return T
        self.log.append((frozenset(X), None))
        return None
    def audit(self):
        """Check every decision of the finished run against the FIXED oracle Ref := N_final (the final global set
        of refuted sentences).  'incoherent' decisions are automatically consistent (each refuted minimal template
        covers its refuting sentence, which is in N_final).  A 'coherent' decision is consistent iff some minimal
        template of X covers no sentence of N_final.  Also every asserted (unrefuted minimal) template of a final
        cluster must avoid N_final.  Returns the list of inconsistent decisions / clusters."""
        N = [n for n, _ in self.world.neg]
        bad = []
        for X, T in self.log:
            if T is None: continue
            if not any(not any(covers(U, n) for n in N) for U in self.minc(X)):
                bad.append(X)
        # the asserted templates must avoid N_final too (then they are exactly Min^+(C) for the oracle N_final)
        for C, Ts in zip(getattr(self, 'clusters', []), getattr(self, 'templates', [])):
            for U in Ts:
                if any(covers(U, n) for n in N): bad.append(frozenset(C))
        return bad
    def run_fixpoint(self, D, max_rounds=10):
        """run DTRC; if the audit finds a decision inconsistent with the final negative set, re-run with the
        negatives retained (the world keeps N), until the run is consistent with a fixed oracle."""
        for r in range(1, max_rounds + 1):
            self.log = []; self.minsizes = []; self.tests = 0
            self.run_once(D)
            bad = self.audit()
            if not bad:
                self.rounds = r
                return self.clusters
        raise RuntimeError('no fixpoint after %d rounds' % max_rounds)
    def unrefuted_min(self, X):
        return [T for T in self.minc(X) if self.world.refute_template(T) is None]
    def run(self, D, order='online', rng=None):
        """v2: the single pass below, repeated (negatives retained) until it is consistent with the fixed oracle
        Ref := N_final (audit).  self.rounds = number of passes."""
        return self.run_fixpoint(D)
    def run_once(self, D, order='online', rng=None):
        """online agglomeration (each datum tries existing clusters in order), then pairwise cluster merging
        until no coherent merge remains."""
        D = list(D)
        clusters = []
        for d in D:
            placed = False
            for C in clusters:
                if d in C:
                    placed = True; break
            if placed: continue
            for C in clusters:
                if self.coherent(C | {d}) is not None:
                    C.add(d); placed = True; break
            if not placed: clusters.append({d})
        changed = True
        while changed:
            changed = False
            for i, j in itertools.combinations(range(len(clusters)), 2):
                if self.coherent(clusters[i] | clusters[j]) is not None:
                    clusters[i] |= clusters[j]; del clusters[j]; changed = True; break
        self.clusters = clusters
        self.templates = [self.unrefuted_min(C) for C in clusters]
        return clusters
    def accepts(self, q):
        for C, Ts in zip(self.clusters, self.templates):
            if Ts and all(covers(T, q) for T in Ts): return True
        return False


def separation_check(world, lab, mincov_fn=mincov):
    """RS_d(D) for the implemented oracle: lab maps each distinct datum to its set of hidden labels.  For every cross
    pair (a, b) (no common label) every minimal covering template must be refuted.  Uses (and extends) the world's
    global negative set.  Returns (number of cross pairs, number of templates tested, list of unrefuted (a, b, T))."""
    data = list(lab)
    pairs = ntempl = 0
    unref = []
    for i in range(len(data)):
        for j in range(i + 1, len(data)):
            a, b = data[i], data[j]
            if lab[a] & lab[b]: continue
            pairs += 1
            for T in mincov_fn([a, b]):
                ntempl += 1
                if world.refute_template(T) is None: unref.append((a, b, T))
    return pairs, ntempl, unref
