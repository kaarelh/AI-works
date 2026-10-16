"""rb1_onetape_exact.py -- referee B, thread `sfi`.  Independent exact finite analogue of
notes.md Lemma 1.2, Lemma 1.3 (maps PS, EM, CR), Thm 3.1 (a), (b) with the stated constants
INCLUDING the program-less tape mass (1 - Omega_V) and the empty data set, Cor 3.2 (three-way
weights against closed labellers, mixture level), Prop 6.1 (a), (b), and Prop 6.8(c) (global-schedule
filter), with exact rational arithmetic.  Written without reading the developer's c1 code beyond
its docstring; it differs from c1 in: syntax trees instead of masks (so the Craig decider parses
real padded conjunctions), halting *steps* separate from tape prefixes, families closed under the
maps to depth 2 (so the theorem's inequalities are tested between "universal" mixtures, not only
between a family and its image), the program-less mass, and the Craig map CR / M_A^dec.

World.  3 atoms (8 valuations).  Sentences are ASTs: ('v',i), ('n',A), ('a',A,B), ('o',A,B),
('i',A,B).  The data language S: 10 base formulas and their syntactic negations (20 sentences).
Theory machines may emit any sentence of a larger pool (S, conjunctions of S-members, a tautology,
a contradiction).  "Closed" and "decides" are relative to S (the finite analogue of Sent).
Tapes: all 2^L strings, L = 5, uniform.  Exact Fractions.

Machines.
  * Function machine F: for each sentence index i a prefix-free dict  w -> (label, step), step >= |w|
    (the run reads at most `step` bits); tapes with no halting prefix: undefined.
  * Theory machine G: dict  w -> list of emitted ASTs (emitted on every tape extending w).
Maps (notes Lemma 1.3), with code-length overheads c_ps, c_em, c_cr:
  * PS(G): label of phi fixed at the shortest tape prefix w at which B + A(w) proves phi (1, tested
    first) or not-phi (0); step = |w|.
  * EM(F): emit phi^y under the halting prefix of phi.
  * CR(F): random decider on ASTs: chi -> candidates (chi,1) and (left(chi), m) with
    size(chi) = m*size(psi) + (m-1); if psi == phi_i (resp. psi == ('n',phi_i)) accept iff F halts on
    phi_i with label 1 (resp. 0) at step exactly m-1.  Read as a theory machine (emit accepted chi).
"Universal" families: T_0 = base theory machines + the empty theory machine (length c_0);
F_0 = base function machines + the deterministic proof-search labeller of B (length c_B);
T_{k+1} = T_k + EM(F_k) + CR(F_k);  F_{k+1} = F_k + PS(T_k).  Program-less mass 1 - Omega with
Omega := 1/2 >= the Kraft sum of every family used (asserted).
  M_A^(k)(D)      := sum_{G in T_k} 2^-l U{theory consistent, proves psi_D} + (1-Omega)[B |- psi_D]
  M_F^cons,(k)(D) := sum_{F in F_k} 2^-l U{f extends D, consistent}   + (1-Omega)[D empty]
  M_A^dec,(k)(D)  := same as M_A over the random deciders in T_k (CR images, empty decider), no
                     program-less term.
Checks (both backgrounds):
  (1) tape-wise inclusions of PS, EM, CR (Lemma 1.3 / Thm 3.1(c)); PS closed on consistent tapes;
      CR: decider determinism (answer is a function of the bits it reads), "at most two
      decompositions" by brute-force parsing, Cn(B + Craig set) = Cn(B + Gamma_f) on every tape;
  (2) Thm 3.1(a): M_A^(k) <= (2^c_ps + 2^c_B) M_F^cons,(k+1) and M_F^cons,(k) <= 2^c_em M_A^(k+1) on
      D != empty; for D = empty both lie in [1-Omega, 1];
  (3) Thm 3.1(b): M_A^dec,(k) <= M_A^(k); M_A^dec,(k+1)(D) >= 2^-c_cr M_F^cons,(k)(D) (D != empty);
  (4) Cor 3.2: three-way weights, M_A^(k)(D;phi->o) <= (2^c_ps + 2^c_B) M_F^cl,(k+1)(D;phi->o) and
      M_F^cl,(k)(D;phi->o) <= (2^c_em + 1) M_A^(k+1)(D;phi->o), all D with |dom D| <= 1, all phi, o;
  (5) Prop 6.1(a),(b): entailed chi: every compatible theory proves chi; consistent SOI gives
      P(0) = 0 and M_F^cons,(2)(D+(chi,1)) >= M_F^cons,(0)(D) 2^-c_em / (2^c_ps + 2^c_B);
  (6) Prop 6.8(c): global-schedule filter F' (events ordered by stage = start index + step, then
      index; F' answers at prefix omega_{1:stage}): F' is a valid function machine (answer determined
      by the prefix it stops at), consistent on every tape, equal to F on F's consistent tapes,
      outputs form an initial segment of the event order, nu_F'(D) >= nu^cons_F(D) for all D;
  (7) Lemma 1.2 bracket: whether the empty labeller is closed (relative to S).
Seed 20261016.  Output: rb1_onetape_exact.out
"""
import itertools
import random
from fractions import Fraction as Fr

SEED = 20261016
NAT = 3
NV = 1 << NAT
FULL = (1 << NV) - 1
L = 5
TAPES = [''.join(b) for b in itertools.product('01', repeat=L)]
NT = len(TAPES)
PREF = [''.join(b) for n in range(L + 1) for b in itertools.product('01', repeat=n)]
C_PS, C_EM, C_CR, C_B, C_0 = 2, 2, 2, 3, 3
OMEGA = Fr(1, 2)

out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def V(i):
    return ('v', i)


def N(a):
    return ('n', a)


def A(a, b):
    return ('a', a, b)


def O(a, b):
    return ('o', a, b)


def I(a, b):
    return ('i', a, b)


_mask_cache = {}


def mask(f):
    r = _mask_cache.get(f)
    if r is not None:
        return r
    t = f[0]
    if t == 'v':
        r = sum(1 << v for v in range(NV) if (v >> f[1]) & 1)
    elif t == 'n':
        r = FULL & ~mask(f[1])
    elif t == 'a':
        r = mask(f[1]) & mask(f[2])
    elif t == 'o':
        r = mask(f[1]) | mask(f[2])
    else:
        r = (FULL & ~mask(f[1])) | mask(f[2])
    _mask_cache[f] = r
    return r


_size_cache = {}


def size(f):
    r = _size_cache.get(f)
    if r is None:
        r = 1 + sum(size(g) for g in f[1:] if isinstance(g, tuple)) if f[0] != 'v' else 1
        _size_cache[f] = r
    return r


def pad(psi, m):
    """right-nested m-fold conjunction psi ^ (psi ^ (... ^ psi))."""
    r = psi
    for _ in range(m - 1):
        r = A(psi, r)
    return r


BASE = [V(0), V(1), V(2), A(V(0), V(1)), O(V(1), V(2)), I(V(0), V(2)), A(V(2), N(V(1))),
        O(A(V(0), V(1)), V(2)), I(V(1), A(V(0), V(2))), N(O(V(0), V(2)))]
S = BASE + [N(f) for f in BASE]
NS = len(S)
IDX = {f: i for i, f in enumerate(S)}
POOL = S + [A(S[i], S[j]) for i, j in [(0, 1), (3, 12), (5, 14), (2, 17), (8, 9)]] + \
       [O(V(0), N(V(0))), A(V(1), N(V(1)))]

BACKGROUNDS = [('B=T', FULL), ('B=(p0->p1)&(p1|p2)', mask(I(V(0), V(1))) & mask(O(V(1), V(2))))]


def lit(i, y):
    return S[i] if y == 1 else N(S[i])


def lmask(i, y):
    return mask(lit(i, y))


def proves(tm, m):
    return (tm & ~m) & FULL == 0


def decide(tm, i):
    if proves(tm, mask(S[i])):
        return 1
    if proves(tm, FULL & ~mask(S[i])):
        return 0
    return None


# ------------------------------------------------------------------ random machines
def rand_fm(rng):
    F = []
    p_h = rng.choice([0.3, 0.45, 0.6])
    p_div = rng.choice([0.1, 0.3])
    truth_bias = rng.random() < 0.5
    v = rng.randrange(NV)
    for i in range(NS):
        d = {}
        stack = ['']
        while stack:
            w = stack.pop()
            if len(w) == L or rng.random() < p_h:
                if rng.random() < p_div:
                    continue  # diverges below w
                if truth_bias and rng.random() < 0.8:
                    y = (mask(S[i]) >> v) & 1
                else:
                    y = rng.randint(0, 1)
                d[w] = (y, len(w) + rng.randint(0, 2))
            else:
                stack += [w + '0', w + '1']
        F.append(d)
    return F


def rand_tm(rng):
    p = rng.choice([0.03, 0.06, 0.1])
    G = {}
    for w in PREF:
        em = []
        for f in POOL:
            if rng.random() < p * (0.5 if len(w) == 0 else 1):
                em.append(f if rng.random() < 0.75 else N(f))
        G[w] = em
    return G


# ------------------------------------------------------------------ evaluation per tape
def eval_tm(G, B):
    """tape -> model mask of B + A_G(omega)."""
    res = []
    for om in TAPES:
        m = B
        for n in range(L + 1):
            for f in G.get(om[:n], ()):
                m &= mask(f)
        res.append(m)
    return res


def eval_fm(F):
    """tape -> tuple of labels (None if undefined)."""
    res = []
    for om in TAPES:
        lab = []
        for i in range(NS):
            y = None
            for n in range(L + 1):
                e = F[i].get(om[:n])
                if e is not None:
                    y = e[0]
                    break
            lab.append(y)
        res.append(tuple(lab))
    return res


def lab_mask(B, lab):
    m = B
    for i, y in enumerate(lab):
        if y is not None:
            m &= lmask(i, y)
    return m


def is_closed(B, lab):
    m = lab_mask(B, lab)
    if m == 0:
        return False
    return all(lab[i] == decide(m, i) for i in range(NS))


# ------------------------------------------------------------------ maps
def PS(G, B):
    F = []
    for i in range(NS):
        d = {}
        stack = ['']
        while stack:
            w = stack.pop()
            m = B
            for n in range(len(w) + 1):
                for f in G.get(w[:n], ()):
                    m &= mask(f)
            y = decide(m, i)
            if y is not None:
                d[w] = (y, len(w))
            elif len(w) < L:
                stack += [w + '0', w + '1']
        F.append(d)
    return F


def EM(F):
    G = {w: [] for w in PREF}
    for i in range(NS):
        for w, (y, _) in F[i].items():
            G[w].append(lit(i, y))
    return G


MAXSTEP = L + 2
U_PAD = [pad(lit(i, y), m) for i in range(NS) for y in (1, 0) for m in range(1, MAXSTEP + 3)]


def make_universe(rng):
    extra = []
    for _ in range(60):  # distractors: padded powers of non-literals, wrong nesting, random ASTs
        r = rng.random()
        f = rng.choice(POOL)
        m = rng.randint(2, 5)
        if r < 0.4:
            extra.append(pad(f, m))
        elif r < 0.7:
            g = pad(f, m)
            extra.append(A(g, f))          # left-nested variant
        else:
            extra.append(A(rng.choice(S), rng.choice(S)))
    return list(dict.fromkeys(U_PAD + extra))


_dec_cache = {}


def decompositions(chi):
    """the decider's candidates: (chi,1) and (left(chi), m) if chi == pad(left, m)."""
    if chi in _dec_cache:
        return _dec_cache[chi]
    c = [(chi, 1)]
    if chi[0] == 'a':
        psi = chi[1]
        num, den = size(chi) + 1, size(psi) + 1
        if num % den == 0:
            m = num // den
            if m >= 2 and pad(psi, m) == chi:
                c.append((psi, m))
    _dec_cache[chi] = c
    return c


def brute_decompositions(chi):
    """all (psi, m) with pad(psi, m) == chi, psi ranging over all sub-ASTs."""
    subs = set()

    def walk(f):
        subs.add(f)
        for g in f[1:]:
            if isinstance(g, tuple):
                walk(g)
    walk(chi)
    res = []
    for psi in subs:
        for m in range(1, size(chi) + 1):
            if size(psi) * m + (m - 1) > size(chi):
                break
            if pad(psi, m) == chi:
                res.append((psi, m))
    return sorted(res, key=lambda t: t[1])


def CR_answer(F, chi, om):
    """the Craig decider's answer on chi and tape om, and the number of tape bits it read."""
    acc = 0
    read = 0
    for psi, m in decompositions(chi):
        for y, target in ((1, psi), (0, None)):
            if y == 1:
                i = IDX.get(psi)
            else:
                i = IDX.get(psi[1]) if psi[0] == 'n' else None
            if i is None:
                continue
            # run F on phi_i for exactly m-1 steps
            k = m - 1
            read = max(read, min(k, L))
            for n in range(L + 1):
                e = F[i].get(om[:n])
                if e is not None:
                    if e[0] == y and e[1] == k:
                        acc = 1
                    break
    return acc, read


def CR_as_tm(F, Ucands):
    """random decider read as a theory machine: emit accepted chi under the prefix it read."""
    G = {w: [] for w in PREF}
    seen = set()
    for chi in Ucands:
        for om in TAPES:
            a, r = CR_answer(F, chi, om)
            if a:
                key = (om[:r], chi)
                if key not in seen:
                    seen.add(key)
                    G[om[:r]].append(chi)
    return G


def det_B_labeller(B):
    F = []
    for i in range(NS):
        y = decide(B, i)
        F.append({'': (y, 0)} if y is not None else {})
    return F


def global_filter(F, B):
    """Prop 6.8(c): events (stage = i + step, i); F' answers at omega_{1:min(stage,L)}."""
    F2 = []
    for i in range(NS):
        d = {}
        for w, (y, k) in F[i].items():
            st = i + k
            # the bits read by F' when phi_i's event occurs: omega_{1:min(st, L)}; enumerate them
            ext = [om for om in TAPES if om.startswith(w)]
            for om in ext:
                v = om[:min(st, L)]
                if v in d:
                    continue
                # labels certified by stage st (ties by index) on any tape through v
                labs = {}
                for j in range(NS):
                    for n in range(L + 1):
                        e = F[j].get(om[:n])
                        if e is not None:
                            if (j + e[1], j) <= (st, i):
                                assert n <= len(v), 'event visible only beyond the bits read'
                                labs[j] = e[0]
                            break
                mm = B
                for j, yy in labs.items():
                    mm &= lmask(j, yy)
                if mm != 0:
                    d[v] = (y, max(k, len(v)))
        F2.append(d)
    return F2


def valid_fm(F):
    """each sentence's halting prefixes are pairwise incomparable."""
    for d in F:
        ks = sorted(d, key=len)
        for a, b in itertools.combinations(ks, 2):
            if b.startswith(a):
                return False
    return True


# ------------------------------------------------------------------ data sets
def all_data(maxk):
    Ds = [()]
    for k in range(1, maxk + 1):
        for dom in itertools.combinations(range(NS), k):
            for ys in itertools.product((1, 0), repeat=k):
                Ds.append(tuple(zip(dom, ys)))
    return Ds


def run(Bname, B, rng):
    out('=' * 78)
    out('Background %s' % Bname)
    Ucands = make_universe(rng)
    nG, nF = 10, 10
    baseG = [rand_tm(rng) for _ in range(nG)]
    baseF = [rand_fm(rng) for _ in range(nF)]
    lens = [rng.randint(7, 10) for _ in range(nG + nF)]
    # families as lists of (kind, machine, length, tag)
    T0 = [('tm', G, l, 'G%d' % j) for j, (G, l) in enumerate(zip(baseG, lens[:nG]))]
    T0.append(('dec', {w: [] for w in PREF}, C_0 + 7, 'empty'))
    F0 = [('fm', F, l, 'F%d' % j) for j, (F, l) in enumerate(zip(baseF, lens[nG:]))]
    F0.append(('fm', det_B_labeller(B), C_B + 7, 'Bsearch'))
    cB = C_B + 7
    T, Fm = [T0], [F0]
    for k in range(2):
        Tk, Fk = T[-1], Fm[-1]
        Tn = list(Tk)
        for kind, F, l, tag in Fk:
            if ('EM', tag) in [(x[3][:2], x[3][3:]) for x in Tn]:
                pass
        have = set(x[3] for x in Tk)
        for kind, F, l, tag in Fk:
            if 'EM(' + tag + ')' not in have:
                Tn.append(('tm', EM(F), l + C_EM, 'EM(' + tag + ')'))
            if 'CR(' + tag + ')' not in have:
                Tn.append(('dec', CR_as_tm(F, Ucands), l + C_CR, 'CR(' + tag + ')'))
        haveF = set(x[3] for x in Fk)
        Fn = list(Fk)
        for kind, G, l, tag in Tk:
            if 'PS(' + tag + ')' not in haveF:
                Fn.append(('fm', PS(G, B), l + C_PS, 'PS(' + tag + ')'))
        T.append(Tn)
        Fm.append(Fn)
    for k in range(3):
        kt = sum(Fr(1, 2 ** x[2]) for x in T[k])
        kf = sum(Fr(1, 2 ** x[2]) for x in Fm[k])
        assert kt <= OMEGA and kf <= OMEGA, (k, float(kt), float(kf))
    out('families: |T_k| = %s, |F_k| = %s; Kraft sums of T_2, F_2: %.4f, %.4f (<= Omega = 1/2)'
        % ([len(x) for x in T], [len(x) for x in Fm], float(sum(Fr(1, 2 ** x[2]) for x in T[2])),
           float(sum(Fr(1, 2 ** x[2]) for x in Fm[2]))))
    # evaluations (cache by tag)
    tev, fev = {}, {}
    for fam in T:
        for kind, G, l, tag in fam:
            if tag not in tev:
                tev[tag] = eval_tm(G, B)
    for fam in Fm:
        for kind, F, l, tag in fam:
            if tag not in fev:
                assert valid_fm(F), tag
                fev[tag] = eval_fm(F)
    Ds = all_data(2)
    out('sentences |S| = %d, tapes %d, data sets |dom D| <= 2: %d' % (NS, NT, len(Ds)))
    tdec = {tag: [tuple(decide(m, i) for i in range(NS)) if m != 0 else None for m in tv]
            for tag, tv in tev.items()}
    fcons = {tag: [lab_mask(B, lab) != 0 for lab in fv] for tag, fv in fev.items()}
    fclosed = {tag: [is_closed(B, lab) for lab in fv] for tag, fv in fev.items()}

    def okT(tag, t, D):
        d = tdec[tag][t]
        return d is not None and all(d[i] == y for i, y in D)

    def okF(tag, t, D):
        lab = fev[tag][t]
        return fcons[tag][t] and all(lab[i] == y for i, y in D)

    def D_ok_theory(tm, D):
        return tm != 0 and all(proves(tm, lmask(i, y)) for i, y in D)

    def D_ok_lab(lab, D):
        return all(lab[i] == y for i, y in D) and lab_mask(B, lab) != 0

    def DB(D):
        m = B
        for i, y in D:
            m &= lmask(i, y)
        return m

    # ---- (1) tape-wise inclusions and map properties
    v_ps = v_em = v_cr = strict_ps = n_trip = 0
    closed_bad = closed_n = 0
    for kind, G, l, tag in T[1]:
        ps = fev.get('PS(' + tag + ')')
        if ps is None:
            continue
        tv = tev[tag]
        for t in range(NT):
            if tv[t] != 0:
                closed_n += 1
                lab = ps[t]
                if not (is_closed(B, lab) and all(lab[i] == decide(tv[t], i) for i in range(NS))):
                    closed_bad += 1
        for D in Ds:
            for t in range(NT):
                n_trip += 1
                a = okT(tag, t, D)
                b = okF('PS(' + tag + ')', t, D)
                v_ps += a and not b
                strict_ps += b and not a
    for kind, F, l, tag in Fm[1]:
        fv = fev[tag]
        em, cr = tev['EM(' + tag + ')'], tev['CR(' + tag + ')']
        for D in Ds:
            for t in range(NT):
                if okF(tag, t, D):
                    v_em += not okT('EM(' + tag + ')', t, D)
                    v_cr += not okT('CR(' + tag + ')', t, D)
    out('(1) PS: violations %d of %d (machine,D,tape) triples (PS strictly larger in %d); '
        'PS closed and deciding as the theory on all %d consistent tapes: violations %d'
        % (v_ps, n_trip, strict_ps, closed_n, closed_bad))
    out('    EM: violations %d;  CR (as theory machine): violations %d' % (v_em, v_cr))
    # Craig decider: determinism, decompositions, Cn
    det_bad = dec_bad = cn_bad = ntest = maxdec = 0
    for kind, F, l, tag in Fm[1][:8]:
        for chi in Ucands:
            bd = brute_decompositions(chi)
            maxdec = max(maxdec, len(bd))
            if sorted(bd, key=lambda t: t[1]) != sorted(decompositions(chi), key=lambda t: t[1]):
                dec_bad += 1
            groups = {}
            for om in TAPES:
                a, r = CR_answer(F, chi, om)
                ntest += 1
                groups.setdefault(om[:r], set()).add(a)
            det_bad += sum(1 for v in groups.values() if len(v) > 1)
        cr = tev['CR(' + tag + ')']
        fv = fev[tag]
        for t in range(NT):
            if cr[t] != lab_mask(B, fv[t]):
                cn_bad += 1
    out('    CR decider: %d (chi,tape) runs; answer not determined by the bits read: %d; '
        'decider candidates != brute-force decompositions: %d (max #decompositions %d); '
        'Cn(B+Craig set) != Cn(B+Gamma_f): %d tapes' % (ntest, det_bad, dec_bad // max(1, 8), maxdec, cn_bad))

    # ---- mixtures
    memo = {}

    def MA(k, D, deciders_only=False):
        key = ('A', k, D, deciders_only)
        if key in memo:
            return memo[key]
        s = Fr(0)
        for kind, G, l, tag in T[k]:
            if deciders_only and kind != 'dec':
                continue
            c = sum(1 for t in range(NT) if okT(tag, t, D))
            s += Fr(c, NT * 2 ** l)
        if not deciders_only and DB(D) != 0 and proves(B, DB(D)):
            s += 1 - OMEGA
        memo[key] = s
        return s

    def MF(k, D):
        key = ('F', k, D)
        if key in memo:
            return memo[key]
        s = Fr(0)
        for kind, F, l, tag in Fm[k]:
            c = sum(1 for t in range(NT) if okF(tag, t, D))
            s += Fr(c, NT * 2 ** l)
        if not D:
            s += 1 - OMEGA
        memo[key] = s
        return s

    KA = Fr(2 ** C_PS + 2 ** cB)
    bad_a1 = bad_a2 = bad_b1 = bad_b2 = 0
    worst = [Fr(0), Fr(0)]
    for D in Ds[1:]:
        for k in range(2):
            ma, mf1 = MA(k, D), MF(k + 1, D)
            if ma > KA * mf1:
                bad_a1 += 1
            if mf1 > 0:
                worst[0] = max(worst[0], ma / mf1)
            mf, ma1 = MF(k, D), MA(k + 1, D)
            if mf > 2 ** C_EM * ma1:
                bad_a2 += 1
            if ma1 > 0:
                worst[1] = max(worst[1], mf / ma1)
            md = MA(k, D, True)
            if md > MA(k, D):
                bad_b1 += 1
            if MA(k + 1, D, True) < Fr(1, 2 ** C_CR) * MF(k, D):
                bad_b2 += 1
    e = [MA(k, ()) for k in range(3)] + [MF(k, ()) for k in range(3)]
    out('(2) Thm 3.1(a): M_A^(k) > (2^%d+2^%d) M_F^cons,(k+1): %d;  M_F^cons,(k) > 2^%d M_A^(k+1): %d '
        '(k = 0,1; %d nonempty D); largest ratios %.3f (bound %d), %.3f (bound %d)'
        % (C_PS, cB, bad_a1, C_EM, bad_a2, len(Ds) - 1, float(worst[0]), KA, float(worst[1]), 2 ** C_EM))
    out('    D = empty: M_A^(k)(empty) = %s, M_F^cons,(k)(empty) = %s, all in [1-Omega, 1] = [0.5, 1]: %s'
        % (['%.4f' % float(x) for x in e[:3]], ['%.4f' % float(x) for x in e[3:]],
           all(1 - OMEGA <= x <= 1 for x in e)))
    out('(3) Thm 3.1(b): M_A^dec,(k) > M_A^(k): %d;  M_A^dec,(k+1) < 2^-%d M_F^cons,(k): %d'
        % (bad_b1, C_CR, bad_b2))

    # ---- (4) Cor 3.2: three-way weights
    def MA3(k, D, phi, o):
        s = Fr(0)
        for kind, G, l, tag in T[k]:
            c = sum(1 for t in range(NT) if okT(tag, t, D) and tdec[tag][t][phi] == o)
            s += Fr(c, NT * 2 ** l)
        if DB(D) != 0 and proves(B, DB(D)) and decide(B, phi) == o:
            s += 1 - OMEGA
        return s

    empty_closed = is_closed(B, tuple([None] * NS))

    def MFcl3(k, D, phi, o):
        s = Fr(0)
        for kind, F, l, tag in Fm[k]:
            fv = fev[tag]
            c = sum(1 for t in range(NT) if fclosed[tag][t] and okF(tag, t, D) and fv[t][phi] == o)
            s += Fr(c, NT * 2 ** l)
        if not D and empty_closed and o is None:
            s += 1 - OMEGA
        return s

    b1 = b2 = n3 = 0
    for D in Ds:
        if len(D) > 1:
            continue
        for phi in range(NS):
            if phi in dict(D):
                continue
            for o in (1, 0, None):
                for k in range(2):
                    n3 += 1
                    if MA3(k, D, phi, o) > KA * MFcl3(k + 1, D, phi, o):
                        b1 += 1
                    if MFcl3(k, D, phi, o) > (2 ** C_EM + 1) * MA3(k + 1, D, phi, o):
                        b2 += 1
    out('(4) Cor 3.2 three-way weights on %d (k,D,phi,o) cases: M_A > (2^%d+2^%d) M_F^cl: %d;  '
        'M_F^cl > (2^%d+1) M_A: %d' % (n3, C_PS, cB, b1, C_EM, b2))

    # ---- (5) Prop 6.1 (a), (b)
    n5 = a_bad = p0_bad = p1_bad = 0
    minratio = None
    for D in Ds:
        if len(D) > 1:
            continue
        m = DB(D)
        if m == 0:
            continue
        for chi in range(NS):
            if chi in dict(D) or not proves(m, mask(S[chi])):
                continue
            n5 += 1
            if MA3(2, D, chi, 1) != MA(2, D):
                a_bad += 1
            if MF(2, D + ((chi, 0),)) != 0:
                p0_bad += 1
            num, den = MF(2, D + ((chi, 1),)), MF(0, D)
            r = num / den if den else None
            if r is not None:
                minratio = r if minratio is None else min(minratio, r)
                if r < Fr(1, 2 ** C_EM) / KA:
                    p1_bad += 1
    out('(5) Prop 6.1: %d (D, entailed chi) cases; compatible theories not all proving chi: %d; '
        'P_cons(0) != 0: %d; M_F^cons,(2)(D+(chi,1))/M_F^cons,(0)(D) below 2^-%d/(2^%d+2^%d): %d (min ratio %.4f)'
        % (n5, a_bad, p0_bad, C_EM, C_PS, cB, p1_bad, float(minratio) if minratio is not None else -1))

    # ---- (6) Prop 6.8(c) filter
    f_valid = f_inc = f_neq = f_seg = f_nu = n_inc_mach = 0
    for kind, F, l, tag in Fm[1]:
        Fp = global_filter(F, B)
        if not valid_fm(Fp):
            f_valid += 1
            continue
        fv, pv = fev[tag], eval_fm(Fp)
        inc = False
        for t, om in enumerate(TAPES):
            if lab_mask(B, pv[t]) == 0:
                f_inc += 1
            if lab_mask(B, fv[t]) != 0:
                if pv[t] != fv[t]:
                    f_neq += 1
            else:
                inc = True
            # initial segment of the event order on this tape
            ev = []
            for j in range(NS):
                for n in range(L + 1):
                    e = F[j].get(om[:n])
                    if e is not None:
                        ev.append(((j + e[1], j), j))
                        break
            ev.sort()
            kept = [pv[t][j] is not None for _, j in ev]
            if any(kept[a] < kept[a + 1] for a in range(len(kept) - 1)):
                f_seg += 1
        n_inc_mach += inc
        for D in Ds:
            a = sum(1 for t in range(NT) if D_ok_lab(pv[t], D))
            b = sum(1 for t in range(NT) if D_ok_lab(fv[t], D))
            f_nu += a < b
    out('(6) Prop 6.8(c) filter on %d machines (%d inconsistent on some tape): invalid function machine %d; '
        'F\' inconsistent on a tape %d; F\' != F on a consistent tape %d; outputs not an initial segment %d; '
        'nu_F\'(D) < nu^cons_F(D): %d' % (len(Fm[1]), n_inc_mach, f_valid, f_inc, f_neq, f_seg, f_nu))
    out('(7) empty labeller closed relative to S: %s (B decides %d of the %d sentences of S); in the real '
        'setting B proves every tautology, so the bracket of Lemma 1.2 is always 0'
        % (empty_closed, sum(1 for i in range(NS) if decide(B, i) is not None), NS))


def main():
    rng = random.Random(SEED)
    out('rb1_onetape_exact.py  seed %d  (exact Fractions)' % SEED)
    for name, B in BACKGROUNDS:
        run(name, B, rng)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
