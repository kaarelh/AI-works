"""Referee 11 checks for research/threadGA-generic-trolls.md and research/threadGB-generic-location.md.

numpy only.  Usage (from this directory):  python3 -B referee11_checks.py > referee11_checks.out

A. Theorem GB2 (threshold Bayesian search), pathwise, on random structured finite classes with exact Bayes:
   every human in a sample (heaviest, prior-random, lightest), chain-equality verifier (n = n0),
   phase-1 choice greedy (largest doubt) or adversarial (smallest doubt >= gamma), phase-2 order
   step order or adversarial (true mistakes last).  Two learners: 'plain' (doubt from labelled data,
   as in the note) and 'cond' (the learner also keeps each rejection as the constraint "h disagrees
   with the run below n0", which P satisfies by Lemma early; doubt and potential both include it).
   Checked per search: cost <= n0; T_s >= max(1, m_s c) (phase-1 searches); T_s >= m_s c + log2(1/gamma)
   (diffuse searches); and in total: Q <= (1 + 1/c) K + n0 R, R <= K / log2(1/gamma).
B. GB2's worst-case factor at the paper's scale, and two analytic instances (tightness; the scan's n0 K).
C. Theorem GB3(a) pathwise on the note's own M1 model (imported, unchanged): every search query
   reveals a new entry, and total Bayesian queries <= |E| for adversarial and prior codes.
D. GB4(b): the exclusion probability.
E. GB7: cost per exercised bit, with the per-rule overhead bits (log2 d + log2 q) included.
F. GA: nested-chain masses, GA5's ratio, GA6(c)'s numbers, GA11's gains.
"""
import math
import os
import sys
import time

import numpy as np

T0 = time.time()
M64 = (1 << 64) - 1


def mix(x):
    x = (x + 0x9E3779B97F4A7C15) & M64
    x = ((x ^ (x >> 30)) * 0xBF58476D1CE4E5B9) & M64
    x = ((x ^ (x >> 27)) * 0x94D049BB133111EB) & M64
    return x ^ (x >> 31)


def log2(x):
    return math.log(x, 2)


# ------------------------------------------------------------------------------------------- A
class FiniteClass:
    """M hypotheses = tables over F notebook features, labels in [L]; each is a mutation of one of
    nbase base tables (shared structure, so data generalize across problems; mutations are rare
    branches).  Weights: base choice + mutation count + mutation contents, with noise."""

    def __init__(self, rng, M=3000, F=256, L=3, nbase=24, mut_max=12):
        base = []
        for _ in range(nbase):
            dens = rng.uniform(0.02, 0.35)
            base.append(np.where(rng.random(F) < dens, rng.integers(1, L, F), 0))
        self.tab = np.zeros((M, F), np.int8)
        lw = np.zeros(M)
        for h in range(M):
            i = int(rng.integers(nbase))
            t = base[i].copy()
            nm = int(rng.integers(0, mut_max + 1))
            pos = rng.choice(F, nm, replace=False)
            t[pos] = rng.integers(0, L, nm)
            self.tab[h] = t
            lw[h] = -(log2(nbase) + 2 * log2(nm + 1) + 1 + nm * (log2(F) + log2(L))) + rng.normal(0, 1.0)
        w = 2.0 ** (lw - lw.max())
        self.w = w / w.sum()
        self.F, self.L, self.M = F, L, M

    def feat(self, s):
        return mix(s) % self.F

    @staticmethod
    def nxt(s, lab):
        return mix(s ^ mix(lab + 7))


class Learner:
    """Exact Bayes over a finite class: the consistent set as a mask."""

    def __init__(self, C):
        self.C = C
        self.mask = np.ones(C.M, bool)

    def logW(self):
        return log2(float(self.C.w[self.mask].sum()))

    def decode(self, f):
        m = np.bincount(self.C.tab[self.mask, f], weights=self.C.w[self.mask], minlength=self.C.L)
        return int(np.argmax(m))

    def add(self, f, lab):
        self.mask &= (self.C.tab[:, f] == lab)

    def add_rejection(self, fs, labs, n0):
        self.mask &= np.any(self.C.tab[:, fs[:n0]] != np.array(labs[:n0])[None, :], axis=1)

    def doubts(self, fs, labs):
        sub = self.C.tab[self.mask][:, fs]
        wm = self.C.w[self.mask]
        dis = (sub != np.array(labs)[None, :])
        return (wm @ dis) / wm.sum()


class MixClass:
    """Mixture of products: a base table B_i (i uniform over nbase), then each feature independently
    keeps the base label w.p. 1 - rho, else takes a uniform label in [L].  Exact Bayes is a mixture
    over i of product posteriors (non-product overall).  Humans are drawn from this prior."""

    def __init__(self, rng, F=2048, L=3, nbase=16, rho=0.05):
        self.B = np.where(rng.random((nbase, F)) < rng.uniform(0.05, 0.4, (nbase, 1)), rng.integers(1, L, (nbase, F)), 0)
        self.F, self.L, self.nb, self.rho = F, L, nbase, rho

    def draw_human(self, rng):
        i = int(rng.integers(self.nb))
        t = self.B[i].copy()
        m = rng.random(self.F) < self.rho
        t[m] = rng.integers(0, self.L, int(m.sum()))
        return t

    def pl(self, f, lab):
        """P_i(label at f = lab), vector over bases."""
        return (1 - self.rho) * (self.B[:, f] == lab) + self.rho / self.L

    def logw_behaviour(self, t):
        ll = np.zeros(self.nb)
        for f in range(self.F):
            ll += np.log2(self.pl(f, int(t[f])))
        ll -= log2(self.nb)
        mx = ll.max()
        return mx + log2(float(np.sum(2.0 ** (ll - mx))))

    def feat(self, s):
        return mix(s) % self.F

    @staticmethod
    def nxt(s, lab):
        return mix(s ^ mix(lab + 7))


class MixLearner:
    def __init__(self, C):
        self.C = C
        self.ll = np.zeros(C.nb) - log2(C.nb)       # log2 of prior x likelihood, per base
        self.obs = {}

    def logW(self):
        mx = self.ll.max()
        return mx + log2(float(np.sum(2.0 ** (self.ll - mx))))

    def post(self):
        p = 2.0 ** (self.ll - self.ll.max())
        return p / p.sum()

    def pred(self, f):
        if f in self.obs:
            v = np.zeros(self.C.L)
            v[self.obs[f]] = 1.0
            return v
        pi = self.post()
        return np.array([float(pi @ self.C.pl(f, l)) for l in range(self.C.L)])

    def decode(self, f):
        return int(np.argmax(self.pred(f)))

    def add(self, f, lab):
        if f in self.obs:
            assert self.obs[f] == lab
            return
        self.obs[f] = lab
        self.ll += np.log2(self.C.pl(f, lab))

    def doubts(self, fs, labs):
        return np.array([1.0 - self.pred(f)[l] for f, l in zip(fs, labs)])


def run_deploy(C, P, T, n0, gamma, variant, p1, p2, seed=0, verdict_data=False, human=None, logwP=None):
    """C: FiniteClass (human = hypothesis index P) or MixClass (human = table, logwP given).
    variant in {'plain','cond','scan'}; p1 in {'greedy','adv'}; p2 in {'step','adv'}."""
    if isinstance(C, MixClass):
        L = MixLearner(C)
        tab = human
    else:
        L = Learner(C)
        tab = C.tab[P]
        logwP = log2(C.w[P])
    c = log2(1 / (1 - gamma))
    lg = log2(1 / gamma)
    phi = lambda: L.logW() - logwP
    tot, R, maxcost, viol, nsearch = 0, 0, 0, [], 0
    phi_start = phi()
    for p in range(T):
        s0 = mix(10007 + 7919 * p + seed)
        while True:
            fs, labs, tru = [], [], []
            s = s0
            for _ in range(n0):
                f = C.feat(s)
                lab = L.decode(f)
                fs.append(f)
                labs.append(lab)
                tru.append(int(tab[f]))
                s = C.nxt(s, lab)
            s = s0
            chain = []
            for _ in range(n0):
                f = C.feat(s)
                lab = int(tab[f])
                chain.append(lab)
                s = C.nxt(s, lab)
            if labs == chain:
                if verdict_data:
                    for f, lab in zip(fs, labs):
                        L.add(f, lab)
                break
            nsearch += 1
            phi0 = phi()
            done = np.zeros(n0, bool)
            cost, misses, diffuse = 0, 0, False
            if variant == 'scan':
                for k in range(n0):
                    cost += 1
                    L.add(fs[k], tru[k])
                    if tru[k] != labs[k]:
                        break
            else:
                if variant == 'cond':
                    L.add_rejection(fs, labs, n0)
                hit = False
                while True:
                    mu = L.doubts(fs, labs)
                    mu[done] = -1.0
                    cand = np.flatnonzero(mu >= gamma)
                    if cand.size == 0:
                        break
                    k = int(cand[np.argmax(mu[cand])]) if p1 == 'greedy' else int(cand[np.argmin(mu[cand])])
                    done[k] = True
                    cost += 1
                    L.add(fs[k], tru[k])
                    if tru[k] != labs[k]:
                        hit = True
                        break
                    misses += 1
                if not hit:
                    diffuse = True
                    rest = [k for k in range(n0) if not done[k]]
                    if p2 == 'adv':
                        rest = [k for k in rest if tru[k] == labs[k]] + [k for k in rest if tru[k] != labs[k]]
                    for k in rest:
                        cost += 1
                        done[k] = True
                        L.add(fs[k], tru[k])
                        if tru[k] != labs[k]:
                            hit = True
                            break
                    assert hit, 'search exhausted: Lemma early violated?'
            if isinstance(L, Learner):
                assert L.mask[P], 'human excluded: a datum it does not satisfy'
            Ts = phi0 - phi()
            maxcost = max(maxcost, cost)
            if cost > n0:
                viol.append(('cost>n0', cost))
            if variant != 'scan':
                if not diffuse and Ts < max(1.0, misses * c) - 1e-9:
                    viol.append(('phase1 T_s', Ts, misses))
                if diffuse:
                    R += 1
                    if Ts < misses * c + lg - 1e-9:
                        viol.append(('diffuse T_s', Ts, misses))
            tot += cost
    K = -logwP
    used = phi_start - phi()
    return dict(Q=tot, R=R, K=K, used=used, maxcost=maxcost, viol=viol, nsearch=nsearch,
                bound=(1 + 1 / c) * K + n0 * R if variant != 'scan' else None,
                bound_used=(1 + 1 / c) * used + n0 * R if variant != 'scan' else None,
                Rbound=K / lg, Rbound_used=used / lg)


def _report(rows, label):
    nviol = sum(len(r[-1]['viol']) for r in rows)
    print('   %s: runs %d; searches %d; diffuse searches %d; violations of any checked inequality: %d'
          % (label, len(rows), sum(r[-1]['nsearch'] for r in rows), sum(r[-1]['R'] for r in rows), nviol))
    if nviol:
        print('   first violations:', [r[-1]['viol'][:2] for r in rows if r[-1]['viol']][:3])
    print('   | gamma | learner | phase choices | searches | diffuse | max cost/search | max Q/bound(K) | max Q/bound(dPhi) | max R/(dPhi/log2(1/gamma)) | mean Q/dPhi |')
    print('   |---|---|---|---|---|---|---|---|---|---|')
    keys = sorted(set((r[0], r[1], r[2], r[3]) for r in rows if r[1] != 'scan'), key=lambda x: (x[0], x[1], x[2]))
    for g, v, p1, p2 in keys:
        sel = [r[-1] for r in rows if (r[0], r[1], r[2], r[3]) == (g, v, p1, p2)]
        sel_u = [o for o in sel if o['used'] > 0]
        print('   | %.3f | %s | %s/%s | %d | %d | %d | %.3f | %.3f | %.3f | %.2f |' % (
            g, v, p1, p2, sum(o['nsearch'] for o in sel), sum(o['R'] for o in sel), max(o['maxcost'] for o in sel),
            max(o['Q'] / o['bound'] for o in sel), max((o['Q'] / o['bound_used'] for o in sel_u), default=0),
            max((o['R'] / o['Rbound_used'] for o in sel_u), default=0),
            sum(o['Q'] for o in sel_u) / max(1e-9, sum(o['used'] for o in sel_u))))
    sel = [r[-1] for r in rows if r[1] == 'scan']
    sel_u = [o for o in sel if o['used'] > 0]
    print('   | - | scan | - | %d | - | %d | - | - | - | %.2f |' % (sum(o['nsearch'] for o in sel), max(o['maxcost'] for o in sel),
                                                              sum(o['Q'] for o in sel_u) / max(1e-9, sum(o['used'] for o in sel_u))))


def section_A():
    print('== A. Theorem GB2, pathwise (exact Bayes, chain-equality verdicts, n = n0 = 16, no verdict data) ==')
    print('   bound(K) = (1 + 1/c) K + n0 R; bound(dPhi) = the same with K replaced by the potential actually used.')
    n0 = 16
    gammas = (0.05, math.log2(n0) / n0, 0.5)
    # A1: finite structured classes; 'cond' keeps each rejection as a constraint
    rows = []
    for cs in (1, 2, 3):
        C = FiniteClass(np.random.default_rng(100 + cs), F=1024, mut_max=30)
        order = np.argsort(-C.w)
        rng = np.random.default_rng(200 + cs)
        humans = list(order[:4]) + list(rng.choice(C.M, 4, p=C.w)) + list(order[-4:])
        for P in humans:
            for g in gammas:
                for v in ('plain', 'cond'):
                    for p1, p2 in (('greedy', 'step'), ('adv', 'adv')):
                        rows.append((g, v, p1, p2, run_deploy(C, int(P), 300, n0, g, v, p1, p2, seed=cs)))
            rows.append((None, 'scan', '-', '-', run_deploy(C, int(P), 300, n0, 0.5, 'scan', '-', '-', seed=cs)))
    _report(rows, 'A1 finite classes (3 classes x 12 humans: heaviest, prior draws, lightest; M = 3000)')
    sys.stdout.flush()
    # A2: mixture of products, humans drawn from the prior
    rows = []
    for rho in (0.01, 0.05, 0.2):
        for cs in (1, 2):
            C = MixClass(np.random.default_rng(300 + cs), rho=rho)
            rng = np.random.default_rng(400 + cs)
            for hh in range(4):
                t = C.draw_human(rng)
                lw = C.logw_behaviour(t)
                for g in gammas:
                    for p1, p2 in (('greedy', 'step'), ('adv', 'adv')):
                        rows.append((g, 'plain', p1, p2, run_deploy(C, None, 300, n0, g, 'plain', p1, p2, seed=cs, human=t, logwP=lw)))
                rows.append((None, 'scan', '-', '-', run_deploy(C, None, 300, n0, 0.5, 'scan', '-', '-', seed=cs, human=t, logwP=lw)))
    _report(rows, 'A2 mixture of products (rho = 0.01, 0.05, 0.2; 2 classes x 4 prior humans each; F = 2048)')
    sys.stdout.flush()


# ------------------------------------------------------------------------------------------- B
def section_B():
    print()
    print('== B. GB2 worst-case factor F = total/K, and analytic instances ==')
    print('   F_sum = 1 + 1/c + n0/log2(1/gamma) (the note), F_max = max(1 + 1/c, n0/log2(1/gamma)) (also valid);')
    print('   at gamma = log2(n0)/n0 and at the gamma minimizing F_max; the scan pays n0 per bit, S,U,S,H 2 n0.')
    print('   | n0 | F_sum(note gamma) | F_max(note gamma) | phase-1 part 1+1/c | best gamma | F_max(best) | n0 | 2 n0 |')
    print('   |---|---|---|---|---|---|---|---|')
    for n0 in (16, 20, 30, 40, 64, 1024):
        g = math.log2(n0) / n0
        c = log2(1 / (1 - g))
        Fs = 1 + 1 / c + n0 / log2(1 / g)
        Fm = max(1 + 1 / c, n0 / log2(1 / g))
        gs = np.linspace(1e-4, 0.9, 20000)
        cs = -np.log2(1 - gs)
        fm = np.maximum(1 + 1 / cs, n0 / -np.log2(gs))
        i = int(np.argmin(fm))
        print('   | %d | %.2f | %.2f | %.2f | %.3f | %.2f | %d | %d |' % (n0, Fs, Fm, 1 + 1 / c, gs[i], fm[i], n0, 2 * n0))
    print('   Tightness (silent class with known insight value, eta = 1/2, adversarial phase-2 order, human with an')
    print('   insight in every problem): cost n0 per insight, K = log2(2 n0) bits per insight:')
    for n0 in (16, 64, 1024):
        g = math.log2(n0) / n0
        c = log2(1 / (1 - g))
        Fs = 1 + 1 / c + n0 / log2(1 / g)
        Fm = max(1 + 1 / c, n0 / log2(1 / g))
        actual = n0 / log2(2 * n0)
        print('     n0 = %d: actual Q/K = %.2f; GB2 bound F_sum = %.2f (ratio %.2f), F_max = %.2f (ratio %.2f)' % (
            n0, actual, Fs, actual / Fs, Fm, actual / Fm))
    print('   The scan\'s n0 K is attained: one fair coin per problem at step n0-1, human never the tie-break:')
    print('     scan Q = n0 per bit; B_gamma (gamma <= 1/2) Q = 1 per bit.  So GB2 does improve the worst case.')
    sys.stdout.flush()


# ------------------------------------------------------------------------------------------- C
def section_C():
    print()
    print('== C. Theorem GB3(a) pathwise on the note\'s M1 model (imported from research/threadGB_location.py) ==')
    here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, os.path.join(here, '..', 'research'))
    import threadGB_location as GB
    orig = GB.query
    stat = dict(q=0, stale=0)

    def wq(model, learner, h):
        before = int(learner.known.sum())
        a = orig(model, learner, h)
        stat['q'] += 1
        if int(learner.known.sum()) == before:
            stat['stale'] += 1
        return a

    GB.query = wq
    for adv in (True, False):
        for proto in ('bayes', 'thr'):
            stat['q'] = stat['stale'] = 0
            Qs = []
            for s in range(1, 25):
                m = GB.M1Model(np.random.default_rng(1000 * s + 99), adversarial=adv)
                o = GB.deploy(m, GB.M1Learner(m), proto, 64, 300, np.random.default_rng(s))
                Qs.append(o['queries'])
            print('   M1 %s, %s, n = 64, T = 300, 24 humans: max total queries %d (|E| = 48); search queries revealing no new entry: %d of %d'
                  % ('adversarial' if adv else 'prior', proto, max(Qs), stat['stale'], stat['q']))
    GB.query = orig
    sys.stdout.flush()


# ------------------------------------------------------------------------------------------- D
def section_D():
    print()
    print('== D. GB4(b): exclusion probability of a fresh value w != v after m non-firing contexts ==')
    for j in (8, 10, 12):
        for m in (2 ** (j - 2), 2 ** j, 2 ** (j + 1)):
            a = (1 - 2.0 ** -j) ** m
            b = (1 - 1.0 / (2 ** j - 1)) ** m
            print('   j = %d, m = %d: note (1-2^-j)^m = %.5f; exact (1-1/(2^j-1))^m = %.5f; ratio %.5f' % (j, m, a, b, b / a))
    sys.stdout.flush()


# ------------------------------------------------------------------------------------------- E
def section_E():
    print()
    print('== E. GB7: queries per exercised bit, with per-rule overhead bits included (q = 3) ==')
    print('   single-use rules cost n/4 (with deferral); rare exercised rules (2^j > n) cost n/4 (without deferral).')
    print('   bits of a rule = log2(1/P(j)) + j + log2 q.  "note" = the note\'s formula with J = log2(nT).')
    print('   | prior | n | T | with deferral (exact) | note | without deferral (exact) | note |')
    print('   |---|---|---|---|---|---|---|')
    q = 3
    for n, T in ((64, 300), (30, 300), (30, 3000), (1024, 10 ** 5)):
        J = log2(n * T)
        for name in ('log-uniform d=40', 'log-uniform d=J+6', 'universal-type'):
            if name.startswith('log-uniform'):
                d = 40 if 'd=40' in name else int(math.ceil(J + 6))
                js = np.arange(1, d + 1)
                P = np.ones(d) / d
                note_with, note_without = 0.72 * n / J ** 2, n * log2(T) / (2 * J ** 2)
            else:
                js = np.arange(1, 401)
                P = 1.0 / js ** 2
                P /= P.sum()
                note_with, note_without = 0.04 * n / J ** 2, float('nan')
            pj = 1 - (1 - 2.0 ** -js.astype(float)) ** n
            ex = 1 - (1 - pj) ** T
            single = T * pj * (1 - pj) ** (T - 1)
            rare = ex * (2.0 ** js > n)
            bits = -np.log2(P) + js + log2(q)
            Bex = float(P @ (ex * bits))
            w = (n / 4) * float(P @ single) / Bex
            wo = (n / 4) * float(P @ rare) / Bex
            print('   | %s | %d | %d | %.4f | %.4f | %.4f | %s |' % (name, n, T, w, note_with, wo,
                                                                   ('%.4f' % note_without) if note_without == note_without else '-'))
    sys.stdout.flush()


# ------------------------------------------------------------------------------------------- F
def h2(u):
    return 0.0 if u <= 0 or u >= 1 else -u * log2(u) - (1 - u) * log2(1 - u)


def section_F():
    print()
    print('== F. GA numerics ==')
    r = 0.05 / 3
    Z = sum(r ** i for i in range(17))
    for j in (1, 2, 8, 16):
        exact = sum(r ** i for i in range(j, 17)) / Z
        print('   nested chain: mass(>= %2d backstabs) = %.4e; (alpha/3)^j = %.4e; ratio %.4f' % (j, exact, r ** j, exact / r ** j))
    for a in (0.05, 0.01):
        b = log2(1 / a)
        print('   GA5 at p = alpha = %.2f: b p/h(p) = %.4f; b/(b + log2 e) = %.4f' % (a, b * a / h2(a), b / (b + math.log2(math.e))))
    kl = 0.5 * log2(0.5 / 0.01) + 0.5 * log2(0.5 / 0.99)
    s = log2(1e6) + 2 * log2(log2(1e6))
    print('   GA6(c): K = 1e6: log2 K + 2 log2 log2 K = %.2f; kl(1/2||0.01) = %.4f bits; s/kl = %.2f; K/b = %.0f'
          % (s, kl, s / kl, 1e6 / log2(100)))
    for a in (0.2, 0.05, 0.01, 1 / 600):
        print('   GA11: alpha = %.5f: h(alpha)/log2(1/(1-alpha)) = %.2f; 1/h(alpha) = %.1f' % (a, h2(a) / -log2(1 - a), 1 / h2(a)))
    print('   GA11(c): n/(eps log2(n/eps)) at n = 30, eps = 0.05: %.1f;  K n/(eps log2 e) factor: %.1f'
          % (600 / log2(600), 30 / (0.05 * math.log2(math.e))))
    sys.stdout.flush()


if __name__ == '__main__':
    print('Referee 11 checks (python3 -B referee11_checks.py)')
    print()
    section_A()
    section_B()
    section_C()
    section_D()
    section_E()
    section_F()
    print()
    print('runtime %.0f s' % (time.time() - T0))
