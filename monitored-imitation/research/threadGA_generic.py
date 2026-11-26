"""Thread GA (generic humans and trolls): simulation for research/threadGA-generic-trolls.md.

numpy only.  Usage: python3 -B threadGA_generic.py > threadGA_generic.out   (about 35 seconds)

The toy.  A notebook state is z in {0,1}^4 (16 states).  A human, and every hypothesis, is a Boolean
function g on the 16 states: the class H is all 2^16 functions, held as truth tables.  The learner is
exact Bayes over H with a prior w; the imitator is the majority decoder with asks at every step whose
top label has mass below 1 - alpha (asks are added to the data at once, so the decoder at every step
conditions on every answer received so far: assumption (U) of the note).
* A problem is a start state z0; a run is n steps z_{t+1} = F(z_t, label_t), with F a rotation of the
  4 bits and the label XORed into bit 0.
* After each run every committed step is scanned in order (cached states are skipped) until the
  first one whose label differs from the human's (a HIT).  A hit at a committed step is a BACKSTAB:
  a confident mistake, found.  After a hit the problem is rerun; otherwise the next problem comes.
  This is VSI's scan with a perfect "does the run have a mistake" verdict, made by scanning.  Every
  selection (problem order, scan order, stopping) is a function of the history, so the calibration
  lemma of the note applies when the human is drawn from w.
* Counted per human: hits (backstabs), asks, committed steps, committed mistakes (found or not), the
  compensator A = sum over committed steps of (1 - top mass), the information of all answers, and
  K_F = log2(1/w(g)) (the human's behaviour weight under the normalized prior).

Priors (the learner's own; "generic" humans are drawn from them):
* DT   : a decision-tree description prior over the 2^16 functions (prefix code: leaf = 2 bits,
         internal node = 3 bits, tests only on variables not yet tested on the path); w(g) is the sum
         over all trees computing g.  A "natural program" prior.
* RARE : independent rare bits: w(g) = prod_z p^{g(z)} (1-p)^{1-g(z)}, one problem per state, n = 1.
         The silent-human structure: information sits in rare, independent surprises.
* CHAIN: a nested troll chain: h_j = ones on states 0..j-1 (j = 0..16), w(h_j) ~ (alpha/3)^j, and 0
         elsewhere; one problem per state in order, n = 1.

Constructed humans.  An adversary answers the protocol's queries lazily, keeping at least one
consistent hypothesis: it answers asks with the majority label, and on each scan it chooses, among
the committed steps at which the minority label is still consistent with all its earlier answers,
the one with the largest minority mass u (optionally only if u >= u_min), answers the decoder's label
before it and the minority label there.  At the end the human is the heaviest consistent function;
re-running the protocol on that function reproduces the transcript exactly (checked).  The adversary
is a fixed program given the protocol, so K(g | protocol) = O(1) and its deficiency is K_F - O(1).
"""
import math
import time

import numpy as np

T0 = time.time()
NS = 16                      # states
NF = 1 << NS                 # functions
TABLE = ((np.arange(NF, dtype=np.int64)[:, None] >> np.arange(NS)[None, :]) & 1).astype(np.uint8)


def log2(x):
    return math.log(x, 2)


def h2(u):
    if u <= 0 or u >= 1:
        return 0.0
    return -u * log2(u) - (1 - u) * log2(1 - u)


def renyi(u, a):
    """Renyi entropy of order a of Bernoulli(u), in bits."""
    return math.log(u ** a + (1 - u) ** a, 2) / (1 - a)


# ---------------------------------------------------------------- priors
def dt_prior():
    """Decision-tree prior over 4-variable Boolean functions, by dynamic programming."""
    zs = np.arange(NS)
    restr = {}
    for i in range(4):
        for b in range(2):
            idx = (zs | (1 << i)) if b else (zs & ~(1 << i))
            restr[(i, b)] = idx

    def tab_restrict(f, i, b):
        idx = restr[(i, b)]
        bits = (f >> idx) & 1
        return int((bits << zs).sum())

    memo = {}

    def w(f, V):
        key = (f, V)
        if key in memo:
            return memo[key]
        tot = 0.25 if f in (0, NF - 1) else 0.0
        for i in range(4):
            if V >> i & 1:
                tot += 0.125 * w(tab_restrict(f, i, 0), V & ~(1 << i)) * w(tab_restrict(f, i, 1), V & ~(1 << i))
        memo[key] = tot
        return tot

    # top level vectorized: restrictions of all functions at once
    pw = (1 << zs)
    wt = np.zeros(NF)
    wt[0] += 0.25
    wt[NF - 1] += 0.25
    for i in range(4):
        f0 = (TABLE[:, restr[(i, 0)]].astype(np.int64) * pw).sum(1)
        f1 = (TABLE[:, restr[(i, 1)]].astype(np.int64) * pw).sum(1)
        V = 15 & ~(1 << i)
        u0, inv0 = np.unique(f0, return_inverse=True)
        u1, inv1 = np.unique(f1, return_inverse=True)
        w0 = np.array([w(int(f), V) for f in u0])
        w1 = np.array([w(int(f), V) for f in u1])
        wt += 0.125 * w0[inv0] * w1[inv1]
    return wt


def rare_prior(p):
    k = TABLE.sum(1)
    return (p ** k) * ((1 - p) ** (NS - k))


def chain_prior(alpha):
    wt = np.zeros(NF)
    for j in range(NS + 1):
        wt[(1 << j) - 1] = (alpha / 3) ** j
    return wt


# ---------------------------------------------------------------- dynamics
def F_rot(z, lab):
    return (((z << 1) | (z >> 3)) & 15) ^ lab


# ---------------------------------------------------------------- the protocol
class Learner:
    def __init__(self, wbar):
        self.w = wbar
        self.cons = np.flatnonzero(wbar > 0)
        self.known = {}
        self.info = 0.0

    def mass1(self, z):
        wc = self.w[self.cons]
        t = TABLE[self.cons, z]
        tot = wc.sum()
        return float(wc[t == 1].sum() / tot)

    def add(self, z, lab):
        p1 = self.mass1(z)
        pl = p1 if lab == 1 else 1 - p1
        self.info += -log2(pl)
        self.cons = self.cons[TABLE[self.cons, z] == lab]
        self.known[z] = lab
        assert len(self.cons) > 0


def protocol(wbar, problems, n, alpha, F, human=None, adversary=None):
    """Run the protocol.  Exactly one of human (a function index) or adversary (a dict) is given."""
    L = Learner(wbar)
    st = dict(asks=0, hits=0, committed=0, comm_mist=0, comp=0.0, ask_H=0.0, ask_R=0.0, runs=0,
              cache_hits=0, hit_u=[])

    def truth(z):
        return int(TABLE[human, z])

    for x0 in problems:
        while True:
            st['runs'] += 1
            z = x0
            committed = []
            for _ in range(n):
                if z in L.known:
                    lab = L.known[z]
                else:
                    p1 = L.mass1(z)
                    top = max(p1, 1 - p1)
                    dec = 1 if p1 > 0.5 else 0
                    if top < 1 - alpha:
                        lab = truth(z) if human is not None else dec   # adversary: majority label
                        u = 1 - top
                        st['ask_H'] += h2(p1)
                        st['ask_R'] += renyi(p1, 1.25)
                        L.add(z, lab)
                        st['asks'] += 1
                    else:
                        lab = dec
                        u = 1 - top
                        committed.append((z, dec, u))
                        st['committed'] += 1
                        st['comp'] += u
                        if human is not None and truth(z) != dec:
                            st['comm_mist'] += 1
                z = F(z, lab) if F is not None else z
            # scan the committed steps in order
            hit = False
            if human is not None:
                for (zc, dec, u) in committed:
                    if zc in L.known:
                        if L.known[zc] != dec:
                            st['cache_hits'] += 1
                            hit = True
                            break
                        continue
                    lab = truth(zc)
                    L.add(zc, lab)
                    if lab != dec:
                        st['hits'] += 1
                        st['hit_u'].append(u)
                        hit = True
                        break
            else:
                # adversary: choose the target committed step
                umin = adversary.get('umin', 0.0)
                best, best_u = None, -1.0
                prefix_mask = np.ones(len(L.cons), dtype=bool)
                for idx, (zc, dec, u) in enumerate(committed):
                    if zc in L.known:
                        if L.known[zc] != dec:
                            best = ('cache', idx)
                            break
                        continue
                    t = TABLE[L.cons, zc]
                    feas = prefix_mask & (t != dec)
                    if feas.any() and u >= umin and u > best_u:
                        best, best_u = ('hit', idx), u
                    prefix_mask &= (t == dec)
                for idx, (zc, dec, u) in enumerate(committed):
                    if zc in L.known:
                        if L.known[zc] != dec:
                            st['cache_hits'] += 1
                            hit = True
                            break
                        continue
                    if best is not None and best[0] == 'hit' and idx == best[1]:
                        L.add(zc, 1 - dec)
                        st['hits'] += 1
                        st['hit_u'].append(u)
                        hit = True
                        break
                    L.add(zc, dec)
            if not hit:
                break
    st['info'] = L.info
    st['final_cons'] = L.cons
    return st


def K_F(wbar, g):
    return -log2(wbar[g])


def construct(wbar, problems, n, alpha, F, umins):
    """Best constructed human over a few adversary thresholds; returns (g, stats)."""
    best = None
    for um in umins:
        st = protocol(wbar, problems, n, alpha, F, adversary={'umin': um})
        cons = st['final_cons']
        g = int(cons[np.argmax(wbar[cons])])
        st2 = protocol(wbar, problems, n, alpha, F, human=g)
        assert st2['hits'] == st['hits'] and st2['asks'] == st['asks'], 'replay mismatch'
        if best is None or st2['hits'] > best[1]['hits']:
            best = (g, st2, um)
    return best


def summarize(name, wbar, humans, problems, n, alpha, F, show_tail=True):
    b = log2(1 / alpha)
    rows = [protocol(wbar, problems, n, alpha, F, human=int(g)) for g in humans]
    hits = np.array([r['hits'] for r in rows])
    asks = np.array([r['asks'] for r in rows])
    kf = np.array([K_F(wbar, int(g)) for g in humans])
    comm = np.array([r['committed'] for r in rows])
    cm = np.array([r['comm_mist'] for r in rows])
    comp = np.array([r['comp'] for r in rows])
    info = np.array([r['info'] for r in rows])
    askH = np.array([r['ask_H'] for r in rows])
    assert np.all(hits <= kf / b + 1e-9), 'hit bound K_F/b violated'
    assert np.all(info <= kf + 1e-9)
    print(f'  {name}: {len(humans)} humans, alpha={alpha}, b=log2(1/alpha)={b:.2f}')
    print(f'    mean K_F = {kf.mean():.2f} bits (min {kf.min():.1f}, max {kf.max():.1f});  mean info of all answers = {info.mean():.2f}')
    print(f'    backstabs (hits): mean {hits.mean():.3f}, max {hits.max()},  mean K_F/b = {(kf / b).mean():.3f}')
    with np.errstate(invalid='ignore', divide='ignore'):
        ratio = np.where(kf > 0, hits * b / kf, 0.0)
    print(f'    backstabs per bound: E[hits]*b/E[K_F] = {hits.mean() * b / kf.mean():.3f}; per human hits*b/K_F mean {ratio.mean():.3f}, max {ratio.max():.3f}')
    print(f'    calibration: committed mistakes mean {cm.mean():.3f} vs compensator mean {comp.mean():.3f} '
          f'(committed steps mean {comm.mean():.1f})')
    print(f'    asks: mean {asks.mean():.2f};  mean sum of ask entropies {askH.mean():.2f} <= E[K_F] {kf.mean():.2f};'
          f'  E[asks]*h(alpha) = {asks.mean() * h2(alpha):.2f};  worst-case bound mean K_F/log2(1/(1-alpha)) = '
          f'{(kf / -log2(1 - alpha)).mean():.1f}')
    if show_tail:
        tail = ', '.join(f'>={j}: {np.mean(hits >= j):.4f}' for j in range(1, int(hits.max()) + 2))
        print(f'    fraction of humans with >= j backstabs: {tail}')
    return dict(hits=hits, kf=kf, asks=asks, ratio=ratio)


def main():
    rng = np.random.default_rng(20261126)
    print('Thread GA: generic versus constructed humans, exact Bayes over all 2^16 functions on 16 states')
    print()

    # ------------------------------------------------------------ RARE
    print('[RARE] independent rare bits: one problem per state, n = 1')
    for alpha, p in [(0.05, 0.045), (0.01, 0.009)]:
        wbar = rare_prior(p)
        wbar = wbar / wbar.sum()
        problems = list(range(NS))
        b = log2(1 / alpha)
        humans = rng.choice(NF, size=1500, p=wbar)
        res = summarize(f'RARE p={p}', wbar, humans, problems, 1, alpha, None)
        ex_hits = NS * p
        ex_K = NS * h2(p)
        print(f'    exact: E[backstabs] = 16p = {ex_hits:.3f};  E[K_F] = 16 h(p) = {ex_K:.3f};  '
              f'E[backstabs] / (E[K_F]/b) = {ex_hits * b / ex_K:.3f};  b/(b + log2 e) = {b / (b + math.log2(math.e)):.3f}')
        g, st, um = construct(wbar, problems, 1, alpha, None, [0.0])
        print(f'    constructed human: backstabs {st["hits"]}, K_F {K_F(wbar, g):.1f}, '
              f'backstabs*b/K_F = {st["hits"] * b / K_F(wbar, g):.3f}')
        print()

    # ------------------------------------------------------------ CHAIN
    print('[CHAIN] nested troll chain: h_j = ones on states 0..j-1, w(h_j) ~ (alpha/3)^j; one problem per state, n = 1')
    alpha = 0.05
    wbar = chain_prior(alpha)
    wbar = wbar / wbar.sum()
    problems = list(range(NS))
    b = log2(1 / alpha)
    support = np.flatnonzero(wbar > 0)
    rows = []
    for g in support:
        st = protocol(wbar, problems, 1, alpha, None, human=int(g))
        rows.append((int(g), st['hits'], K_F(wbar, int(g)), wbar[g]))
    exp_hits = sum(r[1] * r[3] for r in rows)
    print(f'  exact over the 17 humans: E[backstabs] = {exp_hits:.4f};  E[K_F] = {sum(r[2] * r[3] for r in rows):.4f}')
    for j in [1, 2, 4, 8, 16]:
        mass = sum(r[3] for r in rows if r[1] >= j)
        print(f'    prior mass with >= {j:2d} backstabs: {mass:.3e}   ((alpha/3)^j = {(alpha / 3) ** j:.3e})')
    top = rows[-1]
    print(f'  h_16: backstabs {top[1]}, K_F {top[2]:.1f}, K_F/b {top[2] / b:.2f}, backstabs*b/K_F = {top[1] * b / top[2]:.3f}')
    g, st, um = construct(wbar, problems, 1, alpha, None, [0.0])
    print(f'  constructed (adversary) human: g = h_{bin(g).count("1")}, backstabs {st["hits"]}')
    print()

    # ------------------------------------------------------------ DT
    print('[DT] decision-tree prior over all 2^16 functions; n = 4 steps, rotation dynamics, 24 random problems')
    t = time.time()
    wdt = dt_prior()
    print(f'  prior computed in {time.time() - t:.1f}s; total tree mass {wdt.sum():.4f}')
    wbar = wdt / wdt.sum()
    kf_all = -np.log2(wbar)
    H = float((wbar * kf_all).sum())
    print(f'  entropy H(w) = {H:.2f} bits; K_F ranges {kf_all.min():.1f}..{kf_all.max():.1f}')
    problems = [int(x) for x in rng.integers(0, NS, size=24)]
    n = 4
    for alpha in [0.05, 0.2]:
        b = log2(1 / alpha)
        print(f' alpha = {alpha}')
        humans = rng.choice(NF, size=1500, p=wbar)
        summarize('DT, humans from the prior (G1)', wbar, humans, problems, n, alpha, F_rot)
        bands = [(6, 12), (12, 18), (18, 24), (24, 32), (32, 45)]
        for lo, hi in bands:
            sel = np.flatnonzero((kf_all >= lo) & (kf_all < hi))
            if len(sel) == 0:
                continue
            pw = wbar[sel] / wbar[sel].sum()
            hs = rng.choice(sel, size=300, p=pw)
            res = summarize(f'DT band K_F in [{lo},{hi}) (G1 restricted to S)', wbar, hs, problems, n, alpha, F_rot,
                            show_tail=True)
        g, st, um = construct(wbar, problems, n, alpha, F_rot, [0.0, alpha / 4, alpha / 2])
        kfg = K_F(wbar, g)
        sel = np.flatnonzero(np.abs(kf_all - kfg) < 2.0)
        pw = wbar[sel] / wbar[sel].sum()
        hs = rng.choice(sel, size=300, p=pw)
        rows = [protocol(wbar, problems, n, alpha, F_rot, human=int(x))['hits'] for x in hs]
        rows = np.array(rows)
        print(f'  constructed human (adversary, u_min = {um:.3f}): backstabs {st["hits"]}, K_F {kfg:.1f}, '
              f'K_F/b {kfg / b:.2f}, backstabs*b/K_F = {st["hits"] * b / kfg:.3f}, asks {st["asks"]}, '
              f'committed mistakes {st["comm_mist"]} vs compensator {st["comp"]:.3f}')
        print(f'    generic humans with K_F within 2 bits of it (300 from the prior restricted): backstabs mean '
              f'{rows.mean():.3f}, max {rows.max()}, fraction >= constructed {np.mean(rows >= st["hits"]):.4f}')
        print()

        # the same band humans, three learners: Occam (full prior), the band's own prior, a prior flat over bands
        print(f'  [DT-LEARNERS] alpha = {alpha}: humans drawn from a complexity band; which prior does the learner use?')
        edges = np.arange(0, 74, 6)
        band_id = np.digitize(kf_all, edges) - 1
        nb = len(np.unique(band_id))
        bmass = np.bincount(band_id, weights=wbar, minlength=band_id.max() + 1)
        wflat = wbar / bmass[band_id] / nb
        for lo, hi in [(12, 18), (24, 30), (36, 42)]:
            sel = np.flatnonzero((kf_all >= lo) & (kf_all < hi))
            pw = wbar[sel] / wbar[sel].sum()
            hs = rng.choice(sel, size=200, p=pw)
            wband = np.zeros(NF)
            wband[sel] = pw
            print(f'   band K_F in [{lo},{hi}): {len(sel)} functions, prior mass of the band under w: {wbar[sel].sum():.2e} '
                  f'({-log2(wbar[sel].sum()):.1f} bits)')
            for lname, wl in [('Occam (full prior)', wbar), ("band's own prior", wband), ('flat over 6-bit bands', wflat)]:
                rows = [protocol(wl, problems, n, alpha, F_rot, human=int(x)) for x in hs]
                hits = np.array([r['hits'] for r in rows])
                kl = np.array([-log2(wl[int(x)]) for x in hs])
                cm = np.mean([r['comm_mist'] for r in rows])
                comp = np.mean([r['comp'] for r in rows])
                asks = np.mean([r['asks'] for r in rows])
                assert np.all(hits <= kl / b + 1e-9)
                print(f'     {lname:22s}: backstabs mean {hits.mean():.3f} (max {hits.max()}), learner K mean {kl.mean():5.2f}, '
                      f'E[backstabs]*b/E[K] {hits.mean() * b / kl.mean():.3f}; committed mistakes {cm:.3f} vs compensator '
                      f'{comp:.3f}; asks {asks:.2f} (E[K]/h(alpha) = {kl.mean() / h2(alpha):.1f})')
            g, st, um = construct(wband, problems, n, alpha, F_rot, [0.0, alpha / 4, alpha / 2])
            kb = -log2(wband[g])
            print(f"     constructed human against the band's own prior: backstabs {st['hits']}, its K {kb:.2f}, "
                  f"backstabs*b/K {st['hits'] * b / kb:.3f}")
        print()

    # ------------------------------------------------------------ asks under calibration
    print('[ASKS] information per ask: worst case log2(1/(1-alpha)) against h(alpha) and the Renyi order 1+lambda value')
    for alpha in [0.2, 0.1, 0.05, 0.01, 1 / 600, 0.001]:
        wc = -log2(1 - alpha)
        print(f'  alpha={alpha:.5f}: worst {wc:.5f}, h(alpha) {h2(alpha):.5f} (gain {h2(alpha) / wc:.2f}x), '
              + ', '.join(f'H_{1 + lam:.2f}(alpha) {renyi(alpha, 1 + lam):.5f} (gain {renyi(alpha, 1 + lam) / wc:.2f}x)'
                          for lam in [0.25, 1 / max(1.0, log2(1 / alpha))]))
    print()
    print(f'total time {time.time() - T0:.1f}s')


if __name__ == '__main__':
    main()
