"""c16: robustness under a derivation likelihood (referee question Q1, minor issue m16; notes-final Example 3.6).

Question.  Example 3.4 shows that under L0 (axiom citation) human data "t = 0", t a closed {0,+}-term, drive the posterior
to the unsound escape template T_esc = {z = 0}, because the human's axioms have L0-likelihood 0 on such data.  Under a
derivation likelihood the human's axioms generate every true closed equation.  Which theory then wins?

Model (exact, finite).  An equational derivation grammar ("L1-eq"), a derivation likelihood of the brief's kind for the
closed equational fragment.  Terms: closed terms over 0, S, + of size <= N (universe U_N).  Each node independently:
  ax  (alpha_ax): cite a template of T (weights w), metavariables i.i.d. from Q;
  refl(alpha_rf): t ~ Q, conclude t = t;
  sym (alpha_sy): from s = t infer t = s;
  trans(alpha_tr): from s = u and u' = t infer s = t, valid iff u = u';
  congS(alpha_cS): from s = t infer Ss = St;
  cong+(alpha_cp): from s = t and a side term u ~ Q (side L or R w.p. 1/2) infer s+u = t+u or u+s = u+t.
A tree is valid iff all its steps are valid and every term in it lies in U_N.  mu_T(e) = Pr[valid, conclusion e],
Z_T = sum_e mu_T(e), P_T = mu_T / Z_T: a proper generator with a data-independent normaliser.  mu_T is the least
fixpoint of the grammar's equation, computed by monotone iteration (mean premises m < 1).  Q: root law (0 .55, S .2,
+ .25).  Rules (refl, sym, trans, congruence, instantiation) are complete for closed equational consequences [known:
Birkhoff 1935], so supp P_T = closed equational theorems of T inside U_N.
Grammar 3 makes '+' rare under Q (root law 0 .8995, S .1, + .0005): the escape template then pays heavily to
instantiate z with a '+'-term, and the sound theories win.
Theories: T_Q = {z+0=z, z1+Sz2=S(z1+z2)} (Q4, Q5; sound; the human's axioms for +), T_Q0 = T_Q + {0+z=z} (sound),
T_esc = {z = 0} (unsound: proves S0 = 0), T_mix = T_Q + {z = 0} (unsound).  Uniform weights.
Human data: t = 0 with t a {0,+}-term drawn from a PCFG (0: 1-h, +: h) conditioned on size <= N.
Output: the cross-entropy CE(T) = -E_H ln P_T(t = 0) for each theory (for a finite class the posterior concentrates on
the minimiser, Theorem 3.1; the log posterior odds drift by the CE difference per datum), and ln P_T(t = 0) by term.
Sanity check: the fixpoint is compared with Monte Carlo simulation of the grammar (N = 7).
"""
import math
import random
import numpy as np

out = []


def build_terms(N):
    by = {1: [('0',)]}
    for n in range(2, N + 1):
        ts = [('S', t) for t in by[n - 1]]
        for k in range(1, n - 1):
            ts += [('+', a, b) for a in by[k] for b in by[n - 1 - k]]
        by[n] = ts
    terms = [t for n in range(1, N + 1) for t in by[n]]
    return terms


def size(t):
    return 1 + sum(size(c) for c in t[1:])


QP = {'0': 0.55, 'S': 0.2, '+': 0.25}


def qprob(t, qp=None):
    qp = QP if qp is None else qp
    r = qp[t[0]]
    for c in t[1:]:
        r *= qprob(c, qp)
    return r


class World:
    def __init__(self, N, alpha, qp=None):
        self.N = N
        self.terms = build_terms(N)
        self.idx = {t: i for i, t in enumerate(self.terms)}
        n = len(self.terms)
        self.n = n
        self.q = np.array([qprob(t, qp) for t in self.terms])
        self.S = np.array([self.idx.get(('S', t), -1) for t in self.terms])
        self.plus = np.full((n, n), -1)
        for i, a in enumerate(self.terms):
            for j, b in enumerate(self.terms):
                k = self.idx.get(('+', a, b))
                if k is not None:
                    self.plus[i, j] = k
        self.al = alpha
        self.zero = self.idx[('0',)]

    def cite(self, templates):
        """templates: list of (weight, name).  Returns the citation matrix C[s, t]."""
        C = np.zeros((self.n, self.n))
        Z0 = self.zero
        for w, name in templates:
            if name == 'z+0=z':
                for i, t in enumerate(self.terms):
                    k = self.plus[i, Z0]
                    if k >= 0:
                        C[k, i] += w * self.q[i]
            elif name == '0+z=z':
                for i, t in enumerate(self.terms):
                    k = self.plus[Z0, i]
                    if k >= 0:
                        C[k, i] += w * self.q[i]
            elif name == 'z1+Sz2=S(z1+z2)':
                for i in range(self.n):
                    for j in range(self.n):
                        sj = self.S[j]
                        if sj < 0:
                            continue
                        lhs = self.plus[i, sj]
                        pij = self.plus[i, j]
                        if lhs < 0 or pij < 0 or self.S[pij] < 0:
                            continue
                        C[lhs, self.S[pij]] += w * self.q[i] * self.q[j]
            elif name == 'z=0':
                for i in range(self.n):
                    C[i, Z0] += w * self.q[i]
            else:
                raise ValueError(name)
        return C

    def fixpoint(self, C, tol=1e-16, maxit=2000):
        a = self.al
        M = np.zeros((self.n, self.n))
        base = a['ax'] * C + a['rf'] * np.diag(self.q)
        vS = self.S >= 0
        for it in range(maxit):
            new = base + a['sy'] * M.T + a['tr'] * (M @ M)
            new[np.ix_(self.S[vS], self.S[vS])] += a['cS'] * M[np.ix_(vS, vS)]
            for u in range(self.n):
                cu = 0.5 * a['cp'] * self.q[u]
                R = self.plus[:, u]
                v = R >= 0
                if v.any():
                    new[np.ix_(R[v], R[v])] += cu * M[np.ix_(v, v)]
                L = self.plus[u, :]
                v = L >= 0
                if v.any():
                    new[np.ix_(L[v], L[v])] += cu * M[np.ix_(v, v)]
            diff = np.abs(new - M).max()
            M = new
            if diff < tol:
                return M, it
        raise RuntimeError('no convergence')


ALPHA = {'ax': 0.35, 'rf': 0.15, 'sy': 0.1, 'tr': 0.15, 'cS': 0.1, 'cp': 0.15}
m = ALPHA['sy'] + 2 * ALPHA['tr'] + ALPHA['cS'] + ALPHA['cp']
out.append(f"grammar: alpha = {ALPHA}, mean premises m = {m:.2f}; Q root law {QP}")

THEORIES = {
    'T_Q (Q4,Q5; sound)': [(0.5, 'z+0=z'), (0.5, 'z1+Sz2=S(z1+z2)')],
    'T_Q0 (+0+z=z; sound)': [(1 / 3, 'z+0=z'), (1 / 3, 'z1+Sz2=S(z1+z2)'), (1 / 3, '0+z=z')],
    'T_esc = {z=0} (unsound)': [(1.0, 'z=0')],
    'T_mix = T_Q + {z=0} (unsound)': [(1 / 3, 'z+0=z'), (1 / 3, 'z1+Sz2=S(z1+z2)'), (1 / 3, 'z=0')],
}


def zplus_terms(world):
    return [t for t in world.terms if all(s in ('0', '+') for s in flat(t))]


def flat(t):
    yield t[0]
    for c in t[1:]:
        yield from flat(c)


def human_law(world, h):
    ts = zplus_terms(world)
    w = np.array([(1 - h) ** (sum(1 for s in flat(t) if s == '0')) * h ** (sum(1 for s in flat(t) if s == '+'))
                  for t in ts])
    return ts, w / w.sum()


# ---------------- sanity check against Monte Carlo (N = 7, T_Q) ----------------
W7 = World(7, ALPHA)
C7 = W7.cite(THEORIES['T_Q (Q4,Q5; sound)'])
M7, it7 = W7.fixpoint(C7)
P7 = M7 / M7.sum()
rng = random.Random(1616)


def sample_q(rng):
    r = rng.random()
    if r < QP['0']:
        return ('0',)
    if r < QP['0'] + QP['S']:
        return ('S', sample_q(rng))
    return ('+', sample_q(rng), sample_q(rng))


class Invalid(Exception):
    pass


def sample_tree(rng, world, templates, depth=0):
    if depth > 200:
        raise Invalid
    a = ALPHA
    r = rng.random()
    acc = 0.0
    for rule in ('ax', 'rf', 'sy', 'tr', 'cS', 'cp'):
        acc += a[rule]
        if r < acc:
            break
    inU = lambda t: size(t) <= world.N
    if rule == 'ax':
        ws = [w for w, _ in templates]
        name = rng.choices([nm for _, nm in templates], ws)[0]
        if name == 'z+0=z':
            t = sample_q(rng); e = (('+', t, ('0',)), t)
        elif name == 'z1+Sz2=S(z1+z2)':
            t1, t2 = sample_q(rng), sample_q(rng); e = (('+', t1, ('S', t2)), ('S', ('+', t1, t2)))
        else:
            raise ValueError
    elif rule == 'rf':
        t = sample_q(rng); e = (t, t)
    elif rule == 'sy':
        s, t = sample_tree(rng, world, templates, depth + 1); e = (t, s)
    elif rule == 'tr':
        s, u = sample_tree(rng, world, templates, depth + 1)
        u2, t = sample_tree(rng, world, templates, depth + 1)
        if u != u2:
            raise Invalid
        e = (s, t)
    elif rule == 'cS':
        s, t = sample_tree(rng, world, templates, depth + 1); e = (('S', s), ('S', t))
    else:
        s, t = sample_tree(rng, world, templates, depth + 1); u = sample_q(rng)
        e = (('+', s, u), ('+', t, u)) if rng.random() < 0.5 else (('+', u, s), ('+', u, t))
    if not (inU(e[0]) and inU(e[1])):
        raise Invalid
    return e


R = 300_000
counts = {}
valid = 0
for _ in range(R):
    try:
        e = sample_tree(rng, W7, THEORIES['T_Q (Q4,Q5; sound)'])
    except (Invalid, RecursionError):
        continue
    valid += 1
    counts[e] = counts.get(e, 0) + 1
top = sorted(counts, key=lambda e: -counts[e])[:6]
probe = top + [(('+', ('0',), ('+', ('0',), ('0',))), ('0',)), (('+', ('+', ('0',), ('0',)), ('0',)), ('0',))]
zs = []
for e in probe:
    i, j = W7.idx[e[0]], W7.idx[e[1]]
    mc = counts.get(e, 0) / valid
    se = math.sqrt(max(mc * (1 - mc), 1e-12) / valid)
    zs.append(abs(mc - P7[i, j]) / se if counts.get(e, 0) > 0 else float('nan'))
out.append(f"sanity (N = 7, T_Q): fixpoint converged in {it7} iterations; Z = {M7.sum():.5f} vs Monte Carlo valid "
           f"fraction {valid / R:.5f} (s.e. {math.sqrt(valid / R * (1 - valid / R) / R):.5f}); "
           f"|z| of 8 conclusion frequencies: " + ", ".join(f"{z:.2f}" for z in zs))

# ---------------- main comparison ----------------
QP_RARE = {'0': 0.8995, 'S': 0.1, '+': 0.0005}
GRAMMARS = [(ALPHA, QP), ({'ax': 0.5, 'rf': 0.1, 'sy': 0.05, 'tr': 0.2, 'cS': 0.05, 'cp': 0.1}, QP), (ALPHA, QP_RARE)]
for gi, (alpha, qp) in enumerate(GRAMMARS):
    mm = alpha['sy'] + 2 * alpha['tr'] + alpha['cS'] + alpha['cp']
    out.append(f"grammar {gi + 1}: alpha = {alpha}, m = {mm:.2f}; Q root law {qp}")
    for N in (7, 9):
        W = World(N, alpha, qp)
        Ps = {}
        for name, th in THEORIES.items():
            M, it = W.fixpoint(W.cite(th))
            Ps[name] = M / M.sum()
        tsall = zplus_terms(W)
        out.append(f"  N = {N}: |U_N| = {W.n} terms; {len(tsall)} closed {{0,+}}-terms t (data 't = 0')")
        bysize = {}
        for t in tsall:
            bysize.setdefault(size(t), []).append(t)
        for sz in sorted(bysize):
            vals = {nm.split(' ')[0]: np.mean([math.log(Ps[nm][W.idx[t], W.zero]) for t in bysize[sz]])
                    for nm in THEORIES}
            out.append(f"    size {sz} ({len(bysize[sz])} terms): mean ln P_T(t = 0): "
                       + ", ".join(f"{k} {v:.2f}" for k, v in vals.items()))
        for h in (0.3, 0.45):
            for excl0 in (False, True):
                ts, ph = human_law(W, h)
                if excl0:
                    keep = [i for i, t in enumerate(ts) if t != ('0',)]
                    ts = [ts[i] for i in keep]
                    ph = ph[keep] / ph[keep].sum()
                ce = {nm: -float(sum(p * math.log(Ps[nm][W.idx[t], W.zero]) for t, p in zip(ts, ph)))
                      for nm in THEORIES}
                msize = float(sum(p * size(t) for t, p in zip(ts, ph)))
                best = min(ce, key=ce.get)
                out.append(f"    human law h = {h}{', t != 0' if excl0 else ''} (mean size {msize:.2f}): CE = "
                           + ", ".join(f"{k.split(' ')[0]} {v:.3f}" for k, v in ce.items()) + f"  -> minimiser: {best}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
