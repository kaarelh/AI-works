"""r1: independent check of the subformula lemma (notes Lemmas 1.1, 2.1, 2.2, Cor 2.3, Prop 2.4, Rem 2.5).

Uses rk.py (independent of the notes' kcore.py). Random raw derivations are generated with a bias towards the
cases the proof has to handle: Gen chains (Gen on Gen lines, vacuous Gens, several parameters), Gen lines used as
MP minor premises (A1 and A4 instances whose antecedent is a Gen line), Gen lines used both as Gen premise and as
minor premise, A2/A3/A5/substitutivity instances, nonlogical axioms with parameters.

For every normal derivation (normalised at a random line):
  (a) Lemma 2.2's map o is built exactly as in the proof, and each line is checked to sit at o(line) with the
      claimed number of abstractions by a direct implementation of the definition (rk.sits); o must be injective;
  (b) INDEPENDENTLY of the proof's construction: the bipartite graph line -> formula nodes of J at which the line
      sits (any k) is built by exhaustive search and a maximum matching is computed; Lemma 2.2's existence claim
      holds iff the matching saturates the lines;
  (c) the bounds (i)-(iii) and Cor 2.3's (M + |phi|)^2.
Raw derivations: Lemma 2.1 (every axiom/MP line is a literal subformula of an axiom line at or before it).
Prop 2.4: closed-form sizes of the tightness family, recomputed.
Seeded; writes r1_subformula_independent.out next to itself.
"""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rk  # noqa: E402

SEED = 8675309
rng = random.Random(SEED)
OUT = []

A_ = ('c', 'a', ())
B_ = ('c', 'b', ())


def fterm(t):
    return ('c', 'f', (t,))


def P(t):
    return ('R', 'P', (t,))


def Q(s, t):
    return ('R', 'Q', (s, t))


r0 = ('R', 'r', ())


def par(j):
    return ('p', j)


NL = [Q(par(0), par(1)), rk.imp(P(par(0)), Q(par(0), A_)), ('A', rk.imp(P(('i', 0)), r0)),
      ('A', ('A', rk.imp(Q(('i', 1), ('i', 0)), Q(('i', 0), ('i', 1))))), P(fterm(par(2))), rk.neg(r0)]
NLSET = set(NL)


def member(f):
    return f in NLSET


def rterm(depth=0):
    u = rng.random()
    if depth > 1 or u < 0.55:
        return par(rng.randrange(4))
    if u < 0.8:
        return rng.choice([A_, B_])
    return fterm(rterm(depth + 1))


def ratom():
    u = rng.random()
    if u < 0.4:
        return P(rterm())
    if u < 0.8:
        return Q(rterm(), rterm())
    if u < 0.9:
        return r0
    return ('=', rterm(), rterm())


def rform(d=0):
    u = rng.random()
    if d > 1 or u < 0.5:
        return ratom()
    if u < 0.7:
        return rk.neg(rform(d + 1))
    return rk.imp(rform(d + 1), rform(d + 1))


def raw_derivation(steps):
    lines = []
    idx = {}

    def add(f, j):
        assert rk.is_line(f), f
        lines.append((f, j))
        idx.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    for _ in range(steps):
        u = rng.random()
        if not lines or u < 0.10:
            add(rng.choice(NL), ('ax',))
        elif u < 0.14:
            add(rk.REFL, ('ax',))
        elif u < 0.26:  # A1 with antecedent an existing line, then MP (Gen lines become minor premises)
            i = rng.randrange(len(lines))
            X = lines[i][0]
            C = rform()
            k = add(rk.imp(X, rk.imp(C, X)), ('ax',))
            add(rk.imp(C, X), ('mp', i, k))
        elif u < 0.40:  # A4 on an existing universal line, then MP
            alls = [n for n, (f, _) in enumerate(lines) if f[0] == 'A']
            if not alls:
                continue
            i = rng.choice(alls)
            body = lines[i][0][1]
            t = rterm()
            inst = rk.subst_top(body, t)
            k = add(rk.imp(lines[i][0], inst), ('ax',))
            add(inst, ('mp', i, k))
        elif u < 0.62:  # Gen, often on Gen lines, sometimes vacuous
            gens = [n for n, (f, j) in enumerate(lines) if j[0] == 'gen']
            if gens and rng.random() < 0.5:
                i = rng.choice(gens)
            else:
                i = rng.randrange(len(lines))
            ps = sorted(rk.pars(lines[i][0]))
            p = rng.choice(ps) if ps and rng.random() < 0.85 else rng.randrange(6)
            g = rk.gen(lines[i][0], p)
            if rk.sz(g) <= 40:
                add(g, ('gen', i, p))
        elif u < 0.70:  # A2 on an existing line of shape B > (C > D), then MP
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == '>' and f[2][0] == '>']
            if not cand:
                continue
            i = rng.choice(cand)
            Bf, Cf, Df = lines[i][0][1], lines[i][0][2][1], lines[i][0][2][2]
            k = add(rk.imp(lines[i][0], rk.imp(rk.imp(Bf, Cf), rk.imp(Bf, Df))), ('ax',))
            add(rk.imp(rk.imp(Bf, Cf), rk.imp(Bf, Df)), ('mp', i, k))
        elif u < 0.74:  # A3 instance alone
            Cf, Bf = rform(), rform()
            add(rk.imp(rk.imp(rk.neg(Cf), rk.neg(Bf)), rk.imp(rk.imp(rk.neg(Cf), Bf), Cf)), ('ax',))
        elif u < 0.78:  # A5 on a universal implication with closed antecedent, then MP
            cand = [n for n, (f, _) in enumerate(lines)
                    if f[0] == 'A' and f[1][0] == '>' and not rk.dangling(f[1][1])]
            if not cand:
                continue
            i = rng.choice(cand)
            Bf, Cf = lines[i][0][1][1], lines[i][0][1][2]
            k = add(rk.imp(lines[i][0], rk.imp(Bf, ('A', Cf))), ('ax',))
            add(rk.imp(Bf, ('A', Cf)), ('mp', i, k))
        elif u < 0.81:  # substitutivity instance
            p, q = rng.randrange(3), rng.randrange(3)
            Bf = rform()

            def repl(x):
                if x == par(p) and rng.random() < 0.5:
                    return par(q)
                if x[0] in ('i', 'p'):
                    return x
                return rk.rebuild(x, [repl(c) for c in rk.kids(x)])
            add(rk.imp(('=', par(p), par(q)), rk.imp(Bf, repl(Bf))), ('ax',))
        else:  # MP on any matching pair
            imps = [n for n, (f, _) in enumerate(lines) if f[0] == '>' and f[1] in idx]
            if not imps:
                continue
            k = rng.choice(imps)
            add(lines[k][0][2], ('mp', idx[lines[k][0][1]], k))
    return lines


def lemma21_raw(lines):
    """Every axiom/MP line is a literal subformula of an axiom line at or before it."""
    bad = 0
    for n, (f, j) in enumerate(lines):
        if j[0] not in ('ax', 'mp'):
            continue
        ok = any(jj[0] == 'ax' and any(s == f for _, s in rk.fnodes(g)) for g, jj in lines[:n + 1])
        bad += not ok
    return bad


def o_map(lines):
    """Lemma 2.2's construction. Returns {line: (member, path, k)} or raises."""
    phi = lines[-1][0]
    J = rk.instances(lines)
    if phi not in J:
        J = J + [phi]
    o = {}
    for n, (f, j) in enumerate(lines):
        if j[0] == 'ax':
            o[n] = (J.index(f), (), 0)
        elif j[0] == 'mp':
            m, path, k = o[j[2]]
            assert k == 0
            o[n] = (m, path + (1,), 0)
    users = {}
    for n, (f, j) in enumerate(lines):
        if j[0] == 'mp':
            users.setdefault(j[1], []).append(('minor', n))
        elif j[0] == 'gen':
            users.setdefault(j[1], []).append(('gen', n))
    for n, (f, j) in enumerate(lines):
        if j[0] != 'gen':
            continue
        cur, k = n, 0
        while True:
            us = users.get(cur, [])
            minors = [u for u in us if u[0] == 'minor']
            if minors:
                mpl = minors[rng.randrange(len(minors))][1]
                major = lines[mpl][1][2]
                m, path, kk = o[major]
                oe = (m, path + (0,))
                break
            if cur == len(lines) - 1:
                oe = (J.index(lines[cur][0]), ())
                break
            gens = [u for u in us if u[0] == 'gen']
            assert gens, "a non-last line is unused: derivation not normal"
            cur = gens[rng.randrange(len(gens))][1]
            k += 1
        o[n] = (oe[0], oe[1] + (0,) * k, k)
    return J, o


def max_matching(adj, nright):
    match_r = [-1] * nright

    def aug(u, seen):
        for v in adj[u]:
            if v in seen:
                continue
            seen.add(v)
            if match_r[v] < 0 or aug(match_r[v], seen):
                match_r[v] = u
                return True
        return False
    return sum(aug(u, set()) for u in range(len(adj)))


def main():
    out = OUT
    out.append(f"r1_subformula_independent  (seed {SEED}); independent implementation rk.py, not kcore.py")
    stats = dict(raw=0, raw_lines=0, raw_axmp=0, l21_bad=0, normal=0, invalid=0, notnormal=0, lines=0, gen=0,
                 genchain2=0, o_bad_sits=0, o_noninj=0, unmatched=0, sits_nowhere=0, b_i=0, b_ii=0, b_iii=0,
                 b_sq=0, gen_minor_and_genprem=0, raw_gen=0, raw_gen_nowhere=0, maxchain=0)
    worst = dict(sizeF=0.0, linesN=0.0, sq=0.0)
    for trial in range(400):
        raw = raw_derivation(rng.randrange(20, 120))
        ok, bad = rk.check(raw, member)
        assert ok, (bad, raw[bad])
        stats['raw'] += 1
        stats['raw_lines'] += len(raw)
        stats['raw_axmp'] += sum(1 for _, j in raw if j[0] in ('ax', 'mp'))
        stats['l21_bad'] += lemma21_raw(raw)
        # necessity of normality: raw Gen lines that sit nowhere in I + {last}
        Jr = rk.instances(raw) + ([raw[-1][0]] if raw[-1][0] not in rk.instances(raw) else [])
        for f, j in raw:
            if j[0] == 'gen':
                stats['raw_gen'] += 1
                if not any(rk.sits(f, a, path, k) for a in Jr for path, _ in rk.fnodes(a)
                           for k in range(len(path) + 1)):
                    stats['raw_gen_nowhere'] += 1
        for _ in range(6):
            tgt = raw[rng.randrange(len(raw))][0]
            nd = rk.normalise(raw, tgt)
            ok, _ = rk.check(nd, member)
            stats['invalid'] += not ok
            stats['notnormal'] += not rk.is_normal(nd)
            if not ok or not rk.is_normal(nd):
                continue
            assert set(rk.instances(nd)) <= set(rk.instances(raw)) and rk.dsize(nd) <= rk.dsize(raw)
            stats['normal'] += 1
            stats['lines'] += len(nd)
            gl = [n for n, (_, j) in enumerate(nd) if j[0] == 'gen']
            stats['gen'] += len(gl)
            # Gen lines used both as a Gen premise and as a minor premise
            for n in gl:
                um = any(j[0] == 'mp' and j[1] == n for _, j in nd)
                ug = any(j[0] == 'gen' and j[1] == n for _, j in nd)
                stats['gen_minor_and_genprem'] += um and ug
            J, o = o_map(nd)
            ks = [o[n][2] for n in gl]
            if ks and max(ks) >= 2:
                stats['genchain2'] += 1
            stats['maxchain'] = max([stats['maxchain']] + ks)
            # (a) the proof's map
            for n, (f, j) in enumerate(nd):
                m, path, k = o[n]
                if j[0] != 'gen' and k != 0:
                    stats['o_bad_sits'] += 1
                if not rk.sits(f, J[m], path, k):
                    stats['o_bad_sits'] += 1
            vals = [(o[n][0], o[n][1]) for n in range(len(nd))]
            stats['o_noninj'] += len(vals) - len(set(vals))
            # (b) independent: exhaustive sits search + maximum matching
            nodes = [(mi, path) for mi, a in enumerate(J) for path, _ in rk.fnodes(a)]
            adj = []
            for f, _ in nd:
                adj.append([vi for vi, (mi, path) in enumerate(nodes)
                            if any(rk.sits(f, J[mi], path, k) for k in range(len(path) + 1))])
            stats['sits_nowhere'] += sum(1 for a in adj if not a)
            stats['unmatched'] += len(nd) - max_matching(adj, len(nodes))
            # (c) bounds
            phi = nd[-1][0]
            M = sum(rk.sz(a) for a in rk.instances(nd))
            S = rk.dsize(nd)
            stats['b_i'] += max(rk.sz(f) for f, _ in nd) > max(rk.sz(a) for a in J)
            stats['b_ii'] += len(nd) > sum(rk.N(a) for a in J)
            stats['b_iii'] += S > sum(rk.F(a) for a in J)
            stats['b_sq'] += S > (M + rk.sz(phi)) ** 2
            worst['sizeF'] = max(worst['sizeF'], S / sum(rk.F(a) for a in J))
            worst['linesN'] = max(worst['linesN'], len(nd) / sum(rk.N(a) for a in J))
            worst['sq'] = max(worst['sq'], S / (M + rk.sz(phi)) ** 2)
    out.append(f"raw derivations: {stats['raw']} ({stats['raw_lines']} lines, {stats['raw_axmp']} axiom/MP lines)")
    out.append(f"  Lemma 2.1 on raw derivations: axiom/MP lines that are not a literal subformula of an earlier-or-same "
               f"axiom line: {stats['l21_bad']}")
    out.append(f"  raw Gen lines sitting nowhere in I + {{last}} (shows normality is needed): "
               f"{stats['raw_gen_nowhere']} of {stats['raw_gen']}")
    out.append(f"normal derivations: {stats['normal']} (invalid after normalisation: {stats['invalid']}, "
               f"not normal: {stats['notnormal']}); lines {stats['lines']}, Gen lines {stats['gen']}, "
               f"derivations with a Gen chain of length >= 2: {stats['genchain2']} (longest {stats['maxchain']}); "
               f"Gen lines used both as Gen premise and minor premise: {stats['gen_minor_and_genprem']}")
    out.append(f"  (a) proof's map o: lines not sitting at o(line) as claimed: {stats['o_bad_sits']}; "
               f"collisions (non-injectivity): {stats['o_noninj']}")
    out.append(f"  (b) independent exhaustive search: lines sitting at no node of J: {stats['sits_nowhere']}; "
               f"lines left unmatched by a maximum matching: {stats['unmatched']}")
    out.append(f"  (c) bound violations: (i) {stats['b_i']}, (ii) {stats['b_ii']}, (iii) {stats['b_iii']}, "
               f"(M+|phi|)^2: {stats['b_sq']}")
    out.append(f"      worst ratios: size/sumF = {worst['sizeF']:.4f}, #lines/sumN = {worst['linesN']:.4f}, "
               f"size/(M+|phi|)^2 = {worst['sq']:.4f}")

    # Remark 2.5's example: Q(p0,p1) |- A.Q(#0,p1) |- A.A.Q(#0,#1), last used as an MP minor premise
    ex = [(Q(par(0), par(1)), ('ax',))]
    ex.append((rk.gen(ex[0][0], 0), ('gen', 0, 0)))
    ex.append((rk.gen(ex[1][0], 1), ('gen', 1, 1)))
    a4 = rk.imp(ex[2][0], rk.subst_top(ex[2][0][1], A_))
    ex.append((a4, ('ax',)))
    ex.append((a4[2], ('mp', 2, 3)))
    ok, _ = rk.check(ex, member)
    mid = ex[1][0]
    J = rk.instances(ex) + [ex[-1][0]]
    lit = any(s == mid for a in J for _, s in rk.fnodes(a))
    sit = [(J.index(a), path, k) for a in J for path, _ in rk.fnodes(a) for k in range(len(path) + 1)
           if rk.sits(mid, a, path, k)]
    out.append(f"Rem 2.5 example: valid={ok}, normal={rk.is_normal(ex)}; middle line {mid} literal subformula of "
               f"I+phi: {lit}; sits at (member, path, k): {sit}")

    # Targeted: a Gen line gamma used BOTH as a Gen premise (gamma2 := Gen gamma) and as an MP minor premise
    # (A4 on gamma), with both uses surviving normalisation (they meet again through A5):
    #   base, gamma = Gen_p0 base, gamma2 = Gen_p1 gamma, A4: gamma > L1, L1, A1: L1 > (gamma2 > L1), gamma2 > L1,
    #   L4 = Gen_q(gamma2 > L1), A5: L4 > (gamma2 > A.C), gamma2 > A.C, A.C  (target)
    tstats = dict(n=0, bad=0, both=0)
    bases = [Q(par(0), par(1)), rk.imp(P(par(0)), Q(par(0), par(1))), rk.neg(Q(par(1), fterm(par(0))))]
    for base in bases:
        if base not in NLSET:
            NLSET.add(base)
        for t in (A_, B_, fterm(A_), par(3)):
            L = [(base, ('ax',))]
            L.append((rk.gen(base, 0), ('gen', 0, 0)))                 # 1 gamma
            L.append((rk.gen(L[1][0], 1), ('gen', 1, 1)))              # 2 gamma2 (closed)
            a4 = rk.imp(L[1][0], rk.subst_top(L[1][0][1], t))
            L.append((a4, ('ax',)))                                     # 3
            L.append((a4[2], ('mp', 1, 3)))                             # 4 L1 (contains p1)
            g2 = L[2][0]
            a1 = rk.imp(L[4][0], rk.imp(g2, L[4][0]))
            L.append((a1, ('ax',)))                                     # 5
            L.append((a1[2], ('mp', 4, 5)))                             # 6 gamma2 > L1
            L.append((rk.gen(L[6][0], 1), ('gen', 6, 1)))              # 7 A.(gamma2 > C)
            Cb = L[7][0][1][2]
            a5 = rk.imp(L[7][0], rk.imp(g2, ('A', Cb)))
            L.append((a5, ('ax',)))                                     # 8
            L.append((a5[2], ('mp', 7, 8)))                             # 9 gamma2 > A.C
            L.append((('A', Cb), ('mp', 2, 9)))                         # 10 A.C
            ok, badl = rk.check(L, member)
            nd = rk.normalise(L)
            ok2, _ = rk.check(nd, member)
            if not (ok and ok2 and rk.is_normal(nd)):
                tstats['bad'] += 1
                continue
            tstats['n'] += 1
            gidx = [n for n, (_, j) in enumerate(nd) if j[0] == 'gen']
            for n in gidx:
                um = any(j[0] == 'mp' and j[1] == n for _, j in nd)
                ug = any(j[0] == 'gen' and j[1] == n for _, j in nd)
                tstats['both'] += um and ug
            for rep in range(8):  # the proof's map with random chain choices, several times
                J, o = o_map(nd)
                vals = [(o[n][0], o[n][1]) for n in range(len(nd))]
                tstats['bad'] += len(vals) - len(set(vals))
                tstats['bad'] += sum(not rk.sits(f, J[o[n][0]], o[n][1], o[n][2]) for n, (f, _) in enumerate(nd))
            S = rk.dsize(nd)
            tstats['bad'] += S > sum(rk.F(a) for a in J)
    out.append(f"targeted Gen-line-with-two-uses derivations: {tstats['n']} (Gen lines used both ways: "
               f"{tstats['both']}); failures of o (sits/injectivity over 8 random chain choices each) or of "
               f"size <= sumF: {tstats['bad']}")
    stats['l21_bad'] += tstats['bad']

    # Prop 2.4 tightness family, closed forms
    a, b = P(A_), Q(A_, A_)
    rows, okall = [], True
    for k in (1, 2, 5, 10, 50, 200):
        alpha = b
        alphas = [b]
        for _ in range(k):
            alpha = rk.imp(a, alpha)
            alphas.append(alpha)
        lines = [(a, ('ax',)), (alphas[k], ('ax',))]
        for j in range(k - 1, -1, -1):
            lines.append((alphas[j], ('mp', 0, len(lines) - 1)))
        ok, _ = rk.check(lines, lambda f: f in (a, alphas[k]))
        S = rk.dsize(lines)
        M = rk.sz(a) + rk.sz(alphas[k])
        J = [a, alphas[k], b]
        sf = sum(rk.F(x) for x in J)
        cf = rk.sz(a) + (rk.sz(a) + 1) * k * (k + 1) // 2 + (k + 1) * rk.sz(b)
        cm = rk.sz(a) + k * (rk.sz(a) + 1) + rk.sz(b)
        okall &= ok and rk.is_normal(lines) and S == cf and M == cm and S <= sf
        rows.append(f"    k={k:4d} size={S:7d} (closed form {cf}) M={M:5d} (closed form {cm}) sumF={sf:7d} "
                    f"size/sumF={S / sf:.4f} size/(M+|b|)^2={S / (M + rk.sz(b)) ** 2:.4f} valid={ok}")
    out.append("Prop 2.4 family (a = P(a), b = Q(a,a)); 1/(2(|a|+1)) = 0.1667:")
    out += rows
    out.append(f"  closed forms of Prop 2.4 reproduced: {okall}")
    allok = (stats['l21_bad'] == 0 and stats['invalid'] == 0 and stats['notnormal'] == 0 and stats['o_bad_sits'] == 0
             and stats['o_noninj'] == 0 and stats['unmatched'] == 0 and stats['sits_nowhere'] == 0
             and stats['b_i'] + stats['b_ii'] + stats['b_iii'] + stats['b_sq'] == 0 and okall)
    out.append(f"verdict: {'all claims of Lemmas 1.1, 2.1, 2.2, Cor 2.3, Prop 2.4 hold on these cases' if allok else 'FAILURE'}")
    with open(os.path.splitext(os.path.abspath(__file__))[0] + '.out', 'w') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out))


if __name__ == '__main__':
    main()
