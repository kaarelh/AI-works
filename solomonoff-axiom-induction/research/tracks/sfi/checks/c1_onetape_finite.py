"""c1_onetape_finite.py -- thread `sfi`, finite analogue of the one-tape equivalence (notes Thm 3.1),
of logical closure and the trichotomy (Prop 6.1, Rem 6.2), of the closed-labeller three-way agreement
(Cor 3.2), of the abstention bound P_cons(bot) >= 2^{-K(chi)-c} (Prop 6.1(c)), and of the
decidable-consistency filter for machine-wise versus pathwise consistency (Prop 6.8(c)).

Written independently of scout S's s1_onetape_toy.py (not read); outputs are compared in notes.md.

World.
  * Propositional language over 4 atoms (16 valuations).  A sentence is identified with its
    truth set (a 16-bit mask) and a name; the language has 12 base formulas and their 12
    syntactic negations (24 sentences; labelling phi and its negation are separate questions).
  * Background B: a mask (two choices: B = all valuations, B = (p0 -> p1) & (p2 | p3)).
  * Consistency of a set Gamma with B: B & AND(Gamma) != 0.  Gamma |- phi: B & AND(Gamma) <= phi.
  * Tapes: all 2^L strings of length L = 6, uniform; prefixes of length 0..L.
  * Theory machine G: for every prefix w a set of emitted sentences (masks; any sentence of the
    language or the negation of one).  A_G(omega) = union over prefixes w of omega.
  * Function machine F: for every sentence a prefix-free set of halting prefixes (random stopping
    tree) with labels in {1, 0, None}; f_omega(phi) = label at the halting prefix of omega.
    Halting prefix length = "time"; consistency of the triple set holds by prefix-freeness.

Maps (as in the proofs):
  * G -> F_G : proof search; f(phi) is fixed at the shortest prefix w at which
    A(w) := union_{v <= w} G(v) proves phi or not-phi (phi tested first: label 1 on a tie).
  * F -> G_F : at the halting prefix w of phi with label y, emit phi^y.
  * F -> F'  : (Rem 2.14, decidable consistency) global schedule: order the certification events of
    F on omega by (prefix length, sentence index); F' keeps the label of an event iff the labels
    certified up to and including it are consistent with B.

Items.
  (1) tape-wise inclusion {G consistent, proves D} subset of {F_G extends D, consistent};
  (2) tape-wise inclusion {F extends D, consistent} subset of {G_F consistent, proves D};
  (3a) M_A[Gs] <= 2^{c_ps} M_F^cons[F(Gs)] and (3b) M_F^cons[Fs] <= 2^{c_em} M_A[G(Fs)] on every D
      (the two inequalities of the proof of Thm 3.1, against the image families); the ratio of the
      mixtures over the union families is printed for information only (that family is not closed
      under the maps, so no inequality is claimed for it);
  (4) Prop 6.1: entailed chi: SAI gives (1,0,0); consistent SOI gives P(0)=0, P(1)>0, and, with
      abstention variants of weight 2^{-k} per chi, bot-mass >= 2^{-k} x (weight of the base machines
      extending D consistently);
  (5a) on tapes where G's theory is consistent, F_G is closed, consistent and decides as the theory;
  (5b) on tapes where a labeller is closed and consistent, its emission machine decides as it does
      (Cor 3.2); tapes with G inconsistent but F_G closed (finite-language artefact) are counted;
  (6) trichotomy identity M_A(D+(phi,1)) + M_A(D+(phi,0)) + M_A^3(D+(phi,iota)) = M_A(D);
  (7) Prop 6.8(c): F' consistent on every tape, F' = F on F's consistent tapes,
      nu_{F'}(D) >= nu^cons_F(D) for every D; ratio M_F^cons / M_F^C over the filtered family.
Data sets: all D with |dom D| <= 2 (labels in {0,1}).  Seed 20261015.  Output: c1_onetape_finite.out
"""
import itertools
import math
import random
import sys

SEED = 20261015
NATOMS = 4
NV = 1 << NATOMS
FULL = (1 << NV) - 1
L = 6
TAPES = [''.join(b) for b in itertools.product('01', repeat=L)]
PREFIXES = [''.join(b) for n in range(L + 1) for b in itertools.product('01', repeat=n)]

out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def atom(i):
    return sum(1 << v for v in range(NV) if (v >> i) & 1)


A = [atom(i) for i in range(NATOMS)]
NEG = lambda m: FULL & ~m

# 12 base formulas (name, mask), fixed by hand
BASE = [
    ('p0', A[0]), ('p1', A[1]), ('p2', A[2]), ('p3', A[3]),
    ('p0&p1', A[0] & A[1]), ('p0|p2', A[0] | A[2]), ('p1->p3', NEG(A[1]) | A[3]),
    ('p2&~p3', A[2] & NEG(A[3])), ('(p0&p1)|p3', (A[0] & A[1]) | A[3]),
    ('p0<->p2', FULL & ~(A[0] ^ A[2])), ('p1^p2', A[1] ^ A[2]), ('p0->(p1|p2)', NEG(A[0]) | A[1] | A[2]),
]
SENT = [(n, m) for n, m in BASE] + [('~(' + n + ')', NEG(m)) for n, m in BASE]
NS = len(SENT)
MASK = [m for _, m in SENT]
NEGIDX = {i: (i + 12) % 24 for i in range(NS)}  # syntactic negation partner (not needed for logic)

BACKGROUNDS = [('B=all', FULL), ('B=(p0->p1)&(p2|p3)', (NEG(A[0]) | A[1]) & (A[2] | A[3]))]


def lit(i, b):
    """mask of phi_i^b (b=1: phi_i, b=0: not phi_i)."""
    return MASK[i] if b == 1 else NEG(MASK[i])


def theory_mask(B, masks):
    t = B
    for m in masks:
        t &= m
    return t


def proves(tm, m):
    """theory with model-set tm (already intersected with B) proves sentence with mask m."""
    return (tm & ~m) & FULL == 0


# ---------------------------------------------------------------- random machines
def random_theory_machine(rng, p_emit):
    G = {}
    for w in PREFIXES:
        em = []
        for i in range(NS):
            if rng.random() < p_emit:
                em.append(lit(i, rng.choice([1, 1, 0])))
        G[w] = em
    return G


def random_function_machine(rng, p_halt, p_none):
    """F[i] = dict halting_prefix -> label in {1,0,None}; prefix-free per sentence."""
    F = []
    for i in range(NS):
        halts = {}
        stack = ['']
        while stack:
            w = stack.pop()
            if len(w) == L or rng.random() < p_halt:
                r = rng.random()
                halts[w] = None if r < p_none else (1 if r < p_none + (1 - p_none) / 2 else 0)
            else:
                stack.extend([w + '0', w + '1'])
        F.append(halts)
    return F


def deterministic_fm(labels):
    """labels: dict i -> label; halts at the empty prefix."""
    return [{'': labels.get(i)} for i in range(NS)]


# ---------------------------------------------------------------- evaluation
def tm_eval(G, B):
    """per tape: model-set of B union A_G(omega)."""
    res = {}
    for om in TAPES:
        ms = []
        for n in range(L + 1):
            ms.extend(G[om[:n]])
        res[om] = theory_mask(B, ms)
    return res


def fm_eval(F):
    """per tape: (labels dict i->label or None, halting length dict i->len)."""
    res = {}
    for om in TAPES:
        lab, tim = {}, {}
        for i in range(NS):
            for n in range(L + 1):
                w = om[:n]
                if w in F[i]:
                    lab[i] = F[i][w]
                    tim[i] = n
                    break
        res[om] = (lab, tim)
    return res


def labels_consistent(B, lab):
    return theory_mask(B, [lit(i, y) for i, y in lab.items() if y is not None]) != 0


def proof_search_fm(G, B):
    """F_G: label fixed at the shortest prefix whose cumulative axioms decide phi; tie -> 1."""
    F = []
    for i in range(NS):
        halts = {}
        stack = ['']
        while stack:
            w = stack.pop()
            ms = []
            for n in range(len(w) + 1):
                ms.extend(G[w[:n]])
            tm = theory_mask(B, ms)
            if proves(tm, MASK[i]):
                halts[w] = 1
            elif proves(tm, NEG(MASK[i])):
                halts[w] = 0
            elif len(w) == L:
                halts[w] = None
            else:
                stack.extend([w + '0', w + '1'])
        F.append(halts)
    return F


def emit_tm(F):
    """G_F: emit phi^y at the halting prefix of phi with label y."""
    G = {w: [] for w in PREFIXES}
    for i in range(NS):
        for w, y in F[i].items():
            if y is not None:
                G[w].append(lit(i, y))
    return G


def abstain_variant(F, chi):
    F2 = [dict(h) for h in F]
    F2[chi] = {'': None}
    return F2


def global_schedule_filter(F, B):
    """F' of Rem 2.14 (decidable consistency)."""
    F2 = [dict() for _ in range(NS)]
    for i in range(NS):
        for w, y in F[i].items():
            if y is None:
                F2[i][w] = None
                continue
            # events up to (len(w), i) along any tape through w are determined by w
            lab = {}
            for j in range(NS):
                for n in range(len(w) + 1):
                    v = w[:n]
                    if v in F[j]:
                        if (n, j) <= (len(w), i) and F[j][v] is not None:
                            lab[j] = F[j][v]
                        break
            F2[i][w] = y if labels_consistent(B, lab) else None
    return F2


# ---------------------------------------------------------------- data sets
def all_data(maxsize=2):
    Ds = [()]
    for k in range(1, maxsize + 1):
        for dom in itertools.combinations(range(NS), k):
            for labs in itertools.product([1, 0], repeat=k):
                Ds.append(tuple(zip(dom, labs)))
    return Ds


def D_mask(B, D):
    return theory_mask(B, [lit(i, b) for i, b in D])


def run_background(Bname, B, rng):
    out('=' * 78)
    out('Background %s' % Bname)
    NG, NF = 25, 25
    Gs = [random_theory_machine(rng, rng.choice([0.01, 0.02, 0.04])) for _ in range(NG)]
    Fs = [random_function_machine(rng, rng.choice([0.25, 0.4, 0.6]), rng.choice([0.2, 0.5]))
          for _ in range(NF)]
    # weights: 2^{-l}, l in 3..9
    wG = [2.0 ** -rng.randint(3, 9) for _ in range(NG)]
    wF = [2.0 ** -rng.randint(3, 9) for _ in range(NF)]
    c_ps, c_em = 2, 2
    FG = [proof_search_fm(G, B) for G in Gs]
    GF = [emit_tm(F) for F in Fs]
    TH = Gs + GF                       # theory family
    wTH = wG + [w * 2.0 ** -c_em for w in wF]
    LB = Fs + FG                       # labeller family
    wLB = wF + [w * 2.0 ** -c_ps for w in wG]
    TH_eval = [tm_eval(G, B) for G in TH]
    LB_eval = [fm_eval(F) for F in LB]
    Ds = all_data(2)
    Dm = {D: D_mask(B, D) for D in Ds}
    Dcons = [D for D in Ds if Dm[D] != 0]
    out('sentences %d, tapes %d, data sets with |dom D|<=2: %d (consistent: %d)'
        % (NS, len(TAPES), len(Ds), len(Dcons)))

    def nuG(ev, D):
        m = sum(1 for om in TAPES if ev[om] != 0 and all(proves(ev[om], lit(i, b)) for i, b in D))
        return m / len(TAPES)

    def nuF_cons(ev, D):
        m = 0
        for om in TAPES:
            lab, _ = ev[om]
            if all(lab.get(i) == b for i, b in D) and labels_consistent(B, lab):
                m += 1
        return m / len(TAPES)

    # (1) and (2): tape-wise inclusions
    v1 = v2 = strict1 = strict2 = tot = 0
    for g in range(NG):
        evG, evF = TH_eval[g], fm_eval(FG[g])
        for D in Ds:
            for om in TAPES:
                tot += 1
                a = evG[om] != 0 and all(proves(evG[om], lit(i, b)) for i, b in D)
                lab, _ = evF[om]
                bb = all(lab.get(i) == b for i, b in D) and labels_consistent(B, lab)
                if a and not bb:
                    v1 += 1
                if bb and not a:
                    strict1 += 1
    tot2 = 0
    for f in range(NF):
        evF, evG = LB_eval[f], tm_eval(GF[f], B)
        for D in Ds:
            for om in TAPES:
                tot2 += 1
                lab, _ = evF[om]
                a = all(lab.get(i) == b for i, b in D) and labels_consistent(B, lab)
                bb = evG[om] != 0 and all(proves(evG[om], lit(i, b)) for i, b in D)
                if a and not bb:
                    v2 += 1
                if bb and not a:
                    strict2 += 1
    out('(1) G -> F_G : violations %d of %d (machine,D,tape) triples; F_G strictly larger in %d'
        % (v1, tot, strict1))
    out('(2) F -> G_F : violations %d of %d triples; G_F strictly larger in %d' % (v2, tot2, strict2))

    # (3) mixtures.  The proof's two inequalities, each against the image family:
    #     (3a) M_A[Gs] <= 2^{c_ps} M_F^cons[F(Gs)],  (3b) M_F^cons[Fs] <= 2^{c_em} M_A[G(Fs)];
    #     and, for information only, the ratio of the mixtures over TH = Gs u G(Fs), LB = Fs u F(Gs).
    FGev = LB_eval[NF:]
    GFev = TH_eval[NG:]
    bad_a = bad_b = 0
    for D in Ds:
        lhs = sum(w * nuG(ev, D) for w, ev in zip(wG, TH_eval[:NG]))
        rhs = 2 ** c_ps * sum(w * 2.0 ** -c_ps * nuF_cons(ev, D) for w, ev in zip(wG, FGev))
        if lhs > rhs * (1 + 1e-12) + 1e-15:
            bad_a += 1
        lhs = sum(w * nuF_cons(ev, D) for w, ev in zip(wF, LB_eval[:NF]))
        rhs = 2 ** c_em * sum(w * 2.0 ** -c_em * nuG(ev, D) for w, ev in zip(wF, GFev))
        if lhs > rhs * (1 + 1e-12) + 1e-15:
            bad_b += 1
    out('(3a) M_A[Gs] <= 2^%d M_F^cons[F(Gs)]: violations %d of %d data sets' % (c_ps, bad_a, len(Ds)))
    out('(3b) M_F^cons[Fs] <= 2^%d M_A[G(Fs)]: violations %d of %d data sets' % (c_em, bad_b, len(Ds)))
    MA = {D: sum(w * nuG(ev, D) for w, ev in zip(wTH, TH_eval)) for D in Ds}
    MF = {D: sum(w * nuF_cons(ev, D) for w, ev in zip(wLB, LB_eval)) for D in Ds}
    ratios = [MA[D] / MF[D] for D in Ds if MA[D] > 0 and MF[D] > 0]
    mism = sum(1 for D in Ds if (MA[D] > 0) != (MF[D] > 0))
    out('    (information) mixtures over TH, LB: M_A/M_F^cons in [%.4f, %.4f]; support mismatches %d;'
        ' data sets with M_A = 0: %d (inconsistent: %d)'
        % (min(ratios), max(ratios), mism, sum(1 for D in Ds if MA[D] == 0), len(Ds) - len(Dcons)))

    # (4) Prop 2.11 with abstention variants F_chi (abstain on chi on every tape), weight w_F 2^{-k}
    k = math.ceil(math.log2(NS)) + 1  # code length for chi
    bound = 2.0 ** -k / (1 + NS * 2.0 ** -k)
    # precompute per (machine, tape): labels, consistency, consistency without each sentence
    pre = []
    for ev in LB_eval:
        rows = []
        for om in TAPES:
            lab, _ = ev[om]
            cons = labels_consistent(B, lab)
            wo = [cons or labels_consistent(B, {i: y for i, y in lab.items() if i != c}) for c in range(NS)]
            rows.append((lab, cons, wo))
        pre.append(rows)

    def three_way_SOI(D, chi):
        dd = dict(D)
        tot_ = p1 = p0 = pb = wbase = 0.0
        for w, rows in zip(wLB, pre):
            for lab, cons, wo in rows:
                if not all(lab.get(i) == b for i, b in D):
                    continue
                # the machine itself
                if cons:
                    tot_ += w
                    wbase += w
                    y = lab.get(chi)
                    if y == 1:
                        p1 += w
                    elif y == 0:
                        p0 += w
                    else:
                        pb += w
                # its abstention variants F_c, c not in dom D
                for c in range(NS):
                    if c in dd or not wo[c]:
                        continue
                    ww = w * 2.0 ** -k
                    tot_ += ww
                    y = None if c == chi else lab.get(chi)
                    if y == 1:
                        p1 += ww
                    elif y == 0:
                        p0 += ww
                    else:
                        pb += ww
        return tot_, p1, p0, pb, wbase

    cases = okA = okP0 = okP1 = okBot = 0
    minbot = 1.0
    minratio = float('inf')
    allcases = []
    for D in Dcons:
        for chi in range(NS):
            if chi in dict(D) or not proves(Dm[D], MASK[chi]):
                continue
            allcases.append((D, chi))
    small = [c for c in allcases if len(c[0]) <= 1]
    big = [c for c in allcases if len(c[0]) == 2]
    rng2 = random.Random(SEED + 4)
    sample = small + rng2.sample(big, min(300, len(big)))
    for D, chi in sample:
        cases += 1
        tA = t1 = 0.0
        for w, ev in zip(wTH, TH_eval):
            for om in TAPES:
                tm = ev[om]
                if tm != 0 and all(proves(tm, lit(i, b)) for i, b in D):
                    tA += w
                    if proves(tm, MASK[chi]):
                        t1 += w
        if tA > 0 and abs(t1 / tA - 1.0) < 1e-12:
            okA += 1
        T, p1, p0, pb, wbase = three_way_SOI(D, chi)
        if p0 == 0:
            okP0 += 1
        if p1 > 0:
            okP1 += 1
        if pb >= 2.0 ** -k * wbase * (1 - 1e-12):
            okBot += 1
        minbot = min(minbot, pb / T)
        minratio = min(minratio, pb / (2.0 ** -k * wbase))
    out('(4) Prop 2.11: %d (consistent D, entailed chi not in dom D) cases in all (%d with |D|<=1, all'
        ' checked; %d with |D|=2, %d sampled):' % (len(allcases), len(small), len(big), cases - len(small)))
    out('    SAI predicts (1,0,0) in %d of %d; consistent SOI with abstention variants: P(0)=0 in %d,'
        ' P(1)>0 in %d,' % (okA, cases, okP0, okP1))
    out('    bot-mass >= 2^-%d x (weight of the base machines extending D consistently) in %d;'
        ' smallest ratio %.3f; smallest P(bot) = %.5f (2^-%d = %.5f)'
        % (k, okBot, minratio, minbot, k, 2.0 ** -k))

    # (5) closed labellers and theories decide alike, tape by tape:
    #     (5a) where G's theory is consistent, F_G is closed, consistent, and decides every phi as the theory;
    #     (5b) where a labeller F is closed and consistent, G_F's theory is consistent and decides every phi as F.
    def decision(tm, phi):
        return 1 if proves(tm, MASK[phi]) else (0 if proves(tm, NEG(MASK[phi])) else None)

    va = vb = na = nb = art = 0
    for g in range(NG):
        evG, evF = TH_eval[g], LB_eval[NF + g]
        for om in TAPES:
            lab, _ = evF[om]
            ltm = theory_mask(B, [lit(i, y) for i, y in lab.items() if y is not None])
            closed_cons = ltm != 0 and all(lab.get(j) == decision(ltm, j) for j in range(NS))
            if evG[om] != 0:
                na += 1
                if not (closed_cons and all(lab.get(j) == decision(evG[om], j) for j in range(NS))):
                    va += 1
            elif closed_cons:
                art += 1
    pairs5b = [(LB_eval[f], TH_eval[NG + f]) for f in range(NF)]
    pairs5b += [(LB_eval[NF + g], tm_eval(emit_tm(FG[g]), B)) for g in range(NG)]  # G_{F_G}
    for evF, evG in pairs5b:
        for om in TAPES:
            lab, _ = evF[om]
            ltm = theory_mask(B, [lit(i, y) for i, y in lab.items() if y is not None])
            if ltm != 0 and all(lab.get(j) == decision(ltm, j) for j in range(NS)):
                nb += 1
                if evG[om] == 0 or any(lab.get(j) != decision(evG[om], j) for j in range(NS)):
                    vb += 1
    out('(5a) consistent-theory tapes of G: %d; F_G not closed/consistent or deciding differently: %d'
        % (na, va))
    out('     (finite-language artefact: tapes with G inconsistent but F_G closed and consistent: %d)' % art)
    out('(5b) closed consistent tapes of F (random F and the closed F_G): %d; G_F inconsistent or deciding differently: %d' % (nb, vb))

    # (6) trichotomy identity
    viol = 0
    nid = 0
    for D in Ds:
        if len(D) > 1:
            continue
        for phi in range(NS):
            if phi in dict(D):
                continue
            nid += 1
            base = sum(w * sum(1 for om in TAPES if ev[om] != 0 and all(proves(ev[om], lit(i, b)) for i, b in D))
                       for w, ev in zip(wTH, TH_eval))
            parts = [0.0, 0.0, 0.0]
            for w, ev in zip(wTH, TH_eval):
                for om in TAPES:
                    tm = ev[om]
                    if tm != 0 and all(proves(tm, lit(i, b)) for i, b in D):
                        if proves(tm, MASK[phi]):
                            parts[0] += w
                        elif proves(tm, NEG(MASK[phi])):
                            parts[1] += w
                        else:
                            parts[2] += w
            if abs(sum(parts) - base) > 1e-12:
                viol += 1
    out('(6) trichotomy identity on %d (D,phi) pairs: violations %d' % (nid, viol))

    # (7) Rem 2.14, decidable consistency
    a_viol = b_viol = c_viol = 0
    n_inc_machines = 0
    Fp = [global_schedule_filter(F, B) for F in Fs]
    Fp_eval = [fm_eval(F) for F in Fp]
    for f in range(NF):
        evF, evP = LB_eval[f], Fp_eval[f]
        inc = 0
        for om in TAPES:
            labP, _ = evP[om]
            if not labels_consistent(B, labP):
                a_viol += 1
            lab, _ = evF[om]
            if labels_consistent(B, lab):
                if any(labP.get(i) != lab.get(i) for i in range(NS)):
                    b_viol += 1
            else:
                inc += 1
        if inc:
            n_inc_machines += 1
        for D in Ds:
            if nuF_cons(evP, D) + 1e-15 < nuF_cons(evF, D):
                c_viol += 1
    out('(7) Rem 2.14 filter F\' (global schedule + decidable consistency check), %d random machines,'
        ' %d of them inconsistent on some tape:' % (NF, n_inc_machines))
    out('    (a) F\' inconsistent on some tape: %d cases; (b) F\' != F on a consistent tape of F: %d;'
        ' (c) nu_F\'(D) < nu^cons_F(D): %d of %d' % (a_viol, b_viol, c_viol, NF * len(Ds)))
    # mixture over always-consistent machines: the filtered version of every member of LB
    LBp_eval = Fp_eval + [fm_eval(global_schedule_filter(F, B)) for F in FG]
    ac_all = all(labels_consistent(B, ev[om][0]) for ev in LBp_eval for om in TAPES)
    rmax = 0.0
    rmin = float('inf')
    for D in Dcons:
        mc = sum(w * nuF_cons(ev, D) for w, ev in zip(wLB, LBp_eval))
        mcons = sum(w * nuF_cons(ev, D) for w, ev in zip(wLB, LB_eval))
        if mcons > 0:
            r = mcons / mc if mc > 0 else float('inf')
            rmax = max(rmax, r)
            rmin = min(rmin, r)
    out('    filtered family always consistent: %s; over consistent D, M_F^cons(D)/M_F^C(D) in [%.4f, %.4f]'
        ' (the construction gives <= 1)' % (ac_all, rmin, rmax))
    return


def main():
    rng = random.Random(SEED)
    out('c1_onetape_finite.py  seed %d' % SEED)
    for Bname, B in BACKGROUNDS:
        run_background(Bname, B, rng)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
