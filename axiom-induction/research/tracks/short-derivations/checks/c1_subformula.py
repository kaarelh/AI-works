"""c1: the subformula lemma for K (notes §2: Lemma 2.1, Lemma 2.2, Corollary 2.3, Proposition 2.4), on random
derivations in the paper's representation (de Bruijn indices, parameters, Gen abstracting a parameter).

Procedure.
  * A random forward-chaining generator builds K-derivations from a random set NL of closed nonlogical axioms, with
    instances of A1-A5, reflexivity and substitutivity built from existing lines so that MP and Gen apply often,
    including Gen chains whose last line is the minor premise of an MP (through A4, A5 and A1). The generator's
    labels are not trusted: every derivation is re-validated by kcore.check_derivation, whose axiom recognisers are
    independent of the generator (A4 by matching).
  * Lemma 2.1 (no hypothesis): on every raw derivation, every line justified as an axiom or by MP is a literal
    subformula of a line justified as an axiom (checked by an exhaustive subformula search, not by the chase).
  * For six conclusions phi per derivation (the three lines with the most ancestors and three random lines) the
    derivation is normalised (kcore.normalise: de-duplicate, cut at phi, keep the ancestors), and on the normal
    derivation we check Lemma 2.2:
      (L1) the occurrence map o of the proof: every axiom/MP line equals the subformula of I + {phi} at o(line);
      (L2) every Gen line, abstracted along its chosen forward Gen chain, equals the subformula at o(line);
      (L2') independently of o: every line "sits" at some formula node of some member of I + {phi}, i.e. equals it
            after replacing some parameters by the dangling indices of that node (a consistent injective map);
      (L3) o is injective;
      (L4) #lines <= sum N(alpha) <= M + |phi| and size <= sum F(alpha) <= (M + |phi|)^2, alpha in I + {phi};
      (L5) M <= size; normalisation does not enlarge I and does not increase the size.
  * Necessity of the hypotheses: Gen lines of raw derivations that sit nowhere in I + {last line}; normal derivations
    are checked to be normal (distinct lines, every non-last line used).
  * Tightness (Prop 2.4): a, a -> (a -> ... (a -> b)), then k MP steps; size / sum F -> 1 and
    size / (M + |phi|)^2 -> 1 / (2(|a| + 1)).
"""
import random
import sys

import kcore as K

sys.setrecursionlimit(20000)
SEED = 20261010
rng = random.Random(SEED)
out = []
MAXSIZE = 70
NPARAM = 4


def T0():
    return ('fn', '0', ())


def rterm(d, depth, allow_par=True):
    r = rng.random()
    if d <= 0 or r < 0.45:
        opts = ['0']
        if allow_par:
            opts += ['par', 'par']
        if depth > 0:
            opts += ['idx', 'idx']
        c = rng.choice(opts)
        if c == '0':
            return T0()
        if c == 'par':
            return ('par', rng.randrange(NPARAM))
        return ('idx', rng.randrange(depth))
    if r < 0.75:
        return ('fn', 'S', (rterm(d - 1, depth, allow_par),))
    return ('fn', '+', (rterm(d - 1, depth, allow_par), rterm(d - 1, depth, allow_par)))


def rform(d, depth=0, allow_par=True):
    r = rng.random()
    if d <= 0 or r < 0.35:
        a = rng.random()
        if a < 0.4:
            return ('rel', 'P', (rterm(1, depth, allow_par),))
        if a < 0.7:
            return ('rel', 'Q', (rterm(1, depth, allow_par), rterm(1, depth, allow_par)))
        return ('eq', rterm(1, depth, allow_par), rterm(1, depth, allow_par))
    if r < 0.5:
        return ('not', rform(d - 1, depth, allow_par))
    if r < 0.82:
        return ('imp', rform(d - 1, depth, allow_par), rform(d - 1, depth, allow_par))
    return ('all', rform(d - 1, depth + 1, allow_par))


def closed_sentence(d):
    """A random closed parameter-free sentence with at least one quantifier, for NL."""
    body = rform(d, 1, allow_par=False)
    return ('all', body)


def generate(steps, NL):
    lines = []
    index = {}

    def add(f, j):
        if K.size(f) > MAXSIZE or not K.closed(f):
            return None
        lines.append((f, j))
        index.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    def pick():
        if rng.random() < 0.75:
            return rng.randrange(max(0, len(lines) - 8), len(lines))
        return rng.randrange(len(lines))

    def mp(i, k):
        if i is None or k is None:
            return None
        A, AB = lines[i][0], lines[k][0]
        if AB[0] == 'imp' and AB[1] == A:
            return add(AB[2], ('mp', i, k))
        return None

    def a4_on(i):
        B = lines[i][0][1]
        t = rterm(2, 0)
        k = add(K.imp(lines[i][0], K.instantiate(B, t)), ('ax',))
        return mp(i, k)

    for _ in range(steps):
        r = rng.random()
        if not lines or r < 0.07:
            add(rng.choice(NL), ('ax',))
        elif r < 0.09:
            add(K.REFL, ('ax',))
        elif r < 0.25:  # A1 then MP
            i = pick()
            B = lines[i][0]
            if rng.random() < 0.6:
                C = rform(1)
            else:
                cands = [s for _, s in K.formula_nodes(lines[pick()][0]) if K.closed(s)]
                C = rng.choice(cands)
            k = add(K.imp(B, K.imp(C, B)), ('ax',))
            mp(i, k)
        elif r < 0.35:  # A2
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'imp' and f[2][0] == 'imp']
            if cand:
                i = max(cand) if rng.random() < 0.6 else rng.choice(cand)
                B, C, D = lines[i][0][1], lines[i][0][2][1], lines[i][0][2][2]
                k = add(K.imp(lines[i][0], K.imp(K.imp(B, C), K.imp(B, D))), ('ax',))
                m = mp(i, k)
                if m is not None and K.imp(B, C) in index:
                    mp(index[K.imp(B, C)], m)
        elif r < 0.41:  # A3
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'imp' and f[1][0] == 'not' and f[2][0] == 'not']
            if cand:
                i = rng.choice(cand)
                C, B = lines[i][0][1][1], lines[i][0][2][1]
                k = add(K.imp(lines[i][0], K.imp(K.imp(K.neg(C), B), C)), ('ax',))
                m = mp(i, k)
                if m is not None and K.imp(K.neg(C), B) in index:
                    mp(index[K.imp(K.neg(C), B)], m)
        elif r < 0.56:  # A4 on a universal line, then MP (often right after a Gen: Gen line as minor premise)
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'all']
            if cand:
                i = max(cand) if rng.random() < 0.6 else rng.choice(cand)
                a4_on(i)
        elif r < 0.62:  # A5 on all (B -> C) with B closed
            cand = [n for n, (f, _) in enumerate(lines)
                    if f[0] == 'all' and f[1][0] == 'imp' and K.closed(f[1][1])]
            if cand:
                i = max(cand) if rng.random() < 0.6 else rng.choice(cand)
                B, C = lines[i][0][1][1], lines[i][0][1][2]
                k = add(K.imp(lines[i][0], K.imp(B, ('all', C))), ('ax',))
                m = mp(i, k)
                if m is not None and B in index:
                    mp(index[B], m)
        elif r < 0.66:  # substitutivity p = q -> (B -> B'), then MP if p = q is available
            i = pick()
            B = lines[i][0]
            ps = K.params(B)
            if ps:
                p = rng.choice(ps)
                q = rng.randrange(NPARAM)

                def rep(x):
                    if x == ('par', p) and rng.random() < 0.5:
                        return ('par', q)
                    if x[0] in ('idx', 'par'):
                        return x
                    if x[0] in ('fn', 'rel'):
                        return (x[0], x[1], tuple(rep(a) for a in x[2]))
                    if x[0] == 'eq':
                        return ('eq', rep(x[1]), rep(x[2]))
                    if x[0] in ('not', 'all'):
                        return (x[0], rep(x[1]))
                    return ('imp', rep(x[1]), rep(x[2]))
                eq = ('eq', ('par', p), ('par', q))
                k = add(K.imp(eq, K.imp(B, rep(B))), ('ax',))
                if k is not None and eq in index:
                    m = mp(index[eq], k)
                    mp(i, m)
        elif r < 0.84:  # Gen, sometimes a chain of two, often followed by A4 or A1
            i = pick()
            f = lines[i][0]
            ps = K.params(f)
            p = rng.choice(ps) if ps and rng.random() < 0.85 else rng.randrange(NPARAM)
            g = add(K.gen(f, p), ('gen', i, p))
            if g is not None and rng.random() < 0.3:
                ps2 = K.params(lines[g][0])
                p2 = rng.choice(ps2) if ps2 else rng.randrange(NPARAM)
                g2 = add(K.gen(lines[g][0], p2), ('gen', g, p2))
                if g2 is not None:
                    g = g2
            if g is not None:
                s = rng.random()
                if s < 0.5:
                    a4_on(g)
                elif s < 0.7:
                    C = rform(1)
                    k = add(K.imp(lines[g][0], K.imp(C, lines[g][0])), ('ax',))
                    mp(g, k)
        else:  # any available MP
            pairs = [(index[f[1]], n) for n, (f, _) in enumerate(lines)
                     if f[0] == 'imp' and f[1] in index and f[2] not in index]
            if pairs:
                mp(*rng.choice(pairs))
    return lines


# ---------------------------------------------------------------- Lemma 2.1 and 2.2 machinery

def literal_subformula_of(x, alphas):
    for a in alphas:
        for _, s in K.formula_nodes(a):
            if s == x:
                return True
    return False


def sits(line, node, depth=0, pmap=None, inv=None):
    """Does `line` equal `node` after replacing some of its parameters by dangling indices of `node`?
    pmap: parameter -> ('keep',) or ('lev', level); inv: level -> parameter (injective)."""
    if pmap is None:
        pmap, inv = {}, {}
    k1, k2 = line[0], node[0]
    if k1 == 'par':
        p = line[1]
        if k2 == 'par' and node[1] == p:
            want = ('keep',)
        elif k2 == 'idx' and node[1] >= depth:
            lev = node[1] - depth
            want = ('lev', lev)
            if inv.get(lev, p) != p:
                return False
            inv[lev] = p
        else:
            return False
        if pmap.get(p, want) != want:
            return False
        pmap[p] = want
        return True
    if k2 == 'par':
        # node keeps a parameter the line does not have at this position
        if pmap.get(node[1], ('keep',)) != ('keep',):
            return False
        return False
    if k1 != k2:
        return False
    if k1 == 'idx':
        return line == node
    if k1 in ('fn', 'rel'):
        return line[1] == node[1] and len(line[2]) == len(node[2]) and \
            all(sits(a, b, depth, pmap, inv) for a, b in zip(line[2], node[2]))
    if k1 == 'eq':
        return sits(line[1], node[1], depth, pmap, inv) and sits(line[2], node[2], depth, pmap, inv)
    if k1 == 'not':
        return sits(line[1], node[1], depth, pmap, inv)
    if k1 == 'imp':
        return sits(line[1], node[1], depth, pmap, inv) and sits(line[2], node[2], depth, pmap, inv)
    if k1 == 'all':
        return sits(line[1], node[1], depth + 1, pmap, inv)
    return False


def sits_somewhere(line, alphas):
    for a in alphas:
        for _, s in K.formula_nodes(a):
            if K.size(s) == K.size(line) and sits(line, s):
                # a parameter mapped to a level must not survive elsewhere in the node
                return True
    return False


def occurrence_map(lines):
    """The map o of the proof of Lemma 2.2. Returns dict line -> (alpha, path, kind, params of the chain)."""
    n = len(lines)
    last = n - 1
    phi = lines[-1][0]
    uses_minor, uses_gen = {}, {}
    for m, (f, j) in enumerate(lines):
        if j[0] == 'mp':
            uses_minor.setdefault(j[1], []).append(m)
        elif j[0] == 'gen':
            uses_gen.setdefault(j[1], []).append(m)
    o = {}
    for m, (f, j) in enumerate(lines):
        if j[0] == 'ax':
            o[m] = (f, (), 'lit', [])
        elif j[0] == 'mp':
            maj = j[2]
            assert lines[maj][1][0] != 'gen', "a Gen conclusion used as a major premise"
            a, path, _, _ = o[maj]
            o[m] = (a, path + (1,), 'lit', [])
    chains = {}
    for m, (f, j) in enumerate(lines):
        if j[0] != 'gen':
            continue
        cur, ps = m, []
        while True:
            if cur in uses_minor:
                mpl = uses_minor[cur][0]
                maj = lines[mpl][1][2]
                a, path, _, _ = o[maj]
                base = (a, path + (0,))
                break
            if cur == last:
                base = (phi, ())
                break
            nxt = uses_gen[cur][0]
            ps.append(lines[nxt][1][2])
            cur = nxt
        o[m] = (base[0], base[1] + (0,) * len(ps), 'gen', ps)
        chains[m] = len(ps)
    return o, chains


def check_normal(lines, NLset):
    """Checks (L1)-(L5) on a normal derivation. Returns a dict of counters and failure flags."""
    res = {}
    ok, bad = K.check_derivation(lines, lambda f: f in NLset)
    res['valid'] = ok
    res['normal'] = K.is_normal(lines)
    phi = lines[-1][0]
    I = K.axiom_instances(lines)
    alphas = I + ([phi] if phi not in I else [])
    M = sum(K.size(a) for a in I)
    S = K.derivation_size(lines)
    o, chains = occurrence_map(lines)
    L1 = L2 = True
    for m, (f, j) in enumerate(lines):
        a, path, kind, ps = o[m]
        node = K.subtree(a, path)
        if kind == 'lit':
            L1 &= (node == f)
        else:
            x = f
            for i, p in enumerate(ps):
                x = K.abstract(x, p, base=i)
            L2 &= (node == x) and all(K.subtree(a, path[:len(path) - i - 1])[0] == 'all' for i in range(len(ps)))
    res['L1'], res['L2'] = L1, L2
    res['L2p'] = all(sits_somewhere(f, alphas) for f, _ in lines)
    keys = [(o[m][0], o[m][1]) for m in range(len(lines))]
    res['L3'] = len(set(keys)) == len(keys)
    sumN = sum(K.N_nodes(a) for a in alphas)
    sumF = sum(K.F_sum(a) for a in alphas)
    Mphi = M + (K.size(phi) if phi not in I else 0)
    res['L4'] = len(lines) <= sumN <= Mphi and S <= sumF <= Mphi ** 2
    res['L5'] = M <= S
    res.update(lines=len(lines), size=S, M=M, Mphi=Mphi, sumF=sumF, sumN=sumN,
               maxchain=max(chains.values()) if chains else 0,
               ngen=sum(1 for _, j in lines if j[0] == 'gen'),
               gen_minor=sum(1 for m, (f, j) in enumerate(lines) if j[0] == 'gen' and o[m][1] and m != len(lines) - 1
                             and chains[m] == 0),
               a4=sum(1 for f, j in lines if j[0] == 'ax' and K.is_A4(f)))
    return res


def main():
    out.append(f"c1_subformula  (seed {SEED})")
    NDER, STEPS = 300, 140
    totals = {k: 0 for k in ('valid', 'normal', 'L1', 'L2', 'L2p', 'L3', 'L4', 'L5')}
    nproofs = 0
    raw_lemma21_fail = 0
    raw_ax_mp_lines = 0
    raw_gen_nowhere = 0
    raw_gen_lines = 0
    worst = {'size/sumF': 0.0, 'size/Mphi2': 0.0, 'lines/sumN': 0.0, 'lines/Mphi': 0.0}
    stats = {'lines': [], 'size': [], 'M': [], 'maxchain': 0, 'gen_minor': 0, 'chain>=2': 0, 'a4': 0, 'ngen': 0}
    norm_shrinks = True
    for _ in range(NDER):
        NL = [closed_sentence(2) for _ in range(4)]
        NLset = set(NL)
        lines = generate(STEPS, NL)
        ok, bad = K.check_derivation(lines, lambda f: f in NLset)
        assert ok, f"generator produced an invalid line {bad}"
        # Lemma 2.1 on the raw derivation
        I_raw = K.axiom_instances(lines)
        for f, j in lines:
            if j[0] in ('ax', 'mp'):
                raw_ax_mp_lines += 1
                if not literal_subformula_of(f, I_raw):
                    raw_lemma21_fail += 1
        # necessity of pruning: raw Gen lines that sit nowhere in I + {last line}
        alphas_raw = I_raw + [lines[-1][0]]
        for f, j in lines:
            if j[0] == 'gen':
                raw_gen_lines += 1
                if not sits_somewhere(f, alphas_raw):
                    raw_gen_nowhere += 1
        # targets
        anc = []
        for n in range(len(lines)):
            anc.append((len(K.extract(lines, n)), n))
        anc.sort(reverse=True)
        targets = [n for _, n in anc[:3]] + rng.sample(range(len(lines)), 3)
        for t in targets:
            pref = lines[:t + 1]
            pi = K.normalise(pref)
            nproofs += 1
            I0 = set(K.axiom_instances(pref))
            norm_shrinks &= set(K.axiom_instances(pi)) <= I0 and K.derivation_size(pi) <= K.derivation_size(pref)
            r = check_normal(pi, NLset)
            for k in totals:
                totals[k] += 0 if r[k] else 1
            stats['lines'].append(r['lines'])
            stats['size'].append(r['size'])
            stats['M'].append(r['M'])
            stats['maxchain'] = max(stats['maxchain'], r['maxchain'])
            stats['gen_minor'] += r['gen_minor']
            stats['chain>=2'] += 1 if r['maxchain'] >= 2 else 0
            stats['a4'] += r['a4']
            stats['ngen'] += r['ngen']
            worst['size/sumF'] = max(worst['size/sumF'], r['size'] / r['sumF'])
            worst['size/Mphi2'] = max(worst['size/Mphi2'], r['size'] / r['Mphi'] ** 2)
            worst['lines/sumN'] = max(worst['lines/sumN'], r['lines'] / r['sumN'])
            worst['lines/Mphi'] = max(worst['lines/Mphi'], r['lines'] / r['Mphi'])

    def med(v):
        v = sorted(v)
        return v[len(v) // 2]
    out.append(f"raw derivations: {NDER} x {STEPS} generator steps; normal derivations checked: {nproofs}")
    out.append(f"  lines per normal derivation: min {min(stats['lines'])}, median {med(stats['lines'])}, "
               f"max {max(stats['lines'])}")
    out.append(f"  size: min {min(stats['size'])}, median {med(stats['size'])}, max {max(stats['size'])};"
               f"  M: median {med(stats['M'])}, max {max(stats['M'])}")
    out.append(f"  Gen lines: {stats['ngen']}; Gen lines whose chosen chain ends at once as an MP minor premise: "
               f"{stats['gen_minor']}; derivations with a Gen chain of length >= 2: {stats['chain>=2']} "
               f"(longest {stats['maxchain']}); A4 lines: {stats['a4']}")
    out.append("")
    out.append("Lemma 2.1 on the raw derivations (no normality):")
    out.append(f"  axiom and MP lines: {raw_ax_mp_lines}; not a literal subformula of an axiom line: {raw_lemma21_fail}")
    out.append("Lemma 2.2 on the normal derivations (failures):")
    for k in ('valid', 'normal', 'L1', 'L2', 'L2p', 'L3', 'L4', 'L5'):
        out.append(f"  {k:>6}: {totals[k]}")
    out.append(f"  normalisation never enlarges I nor increases the size: {norm_shrinks}")
    out.append(f"  max size / sum F = {worst['size/sumF']:.4f} (claim <= 1);  max size / (M + |phi|)^2 = "
               f"{worst['size/Mphi2']:.4f} (claim <= 1)")
    out.append(f"  max #lines / sum N = {worst['lines/sumN']:.4f} (claim <= 1);  max #lines / (M + |phi|) = "
               f"{worst['lines/Mphi']:.4f}")
    out.append("")
    out.append("necessity of normality: Gen lines of raw derivations that sit nowhere in I + {last line}: "
               f"{raw_gen_nowhere} of {raw_gen_lines}")
    # repeated lines: a derivation that cites the same axiom many times is valid but not normal
    a = ('rel', 'P', (T0(),))
    rep = [(a, ('ax',)) for _ in range(40)] + [(K.gen(a, 0), ('gen', 39, 0))]
    okr, _ = K.check_derivation(rep, lambda f: f == a)
    out.append(f"repeated lines: P(0) cited 40 times, then (vacuous) Gen: valid={okr}, lines={len(rep)}, "
               f"sum N(I + phi) = {K.N_nodes(a) + K.N_nodes(rep[-1][0])}; normalised: {len(K.normalise(rep))} lines")
    out.append("")
    # tightness
    out.append("tightness (Prop 2.4): a, alpha_k = a > (a > ... (a > b)), then k MP steps; a = P(0), b = Q(0,0); "
               "J = {a, alpha_k, b}")
    out.append(f"{'k':>6} {'size':>10} {'M':>7} {'sum F':>10} {'size/sumF':>10} {'size/(M+|phi|)^2':>17} "
               f"{'1/(2(|a|+1))':>13} {'valid':>6} {'normal':>6}")
    b = ('rel', 'Q', (T0(), T0()))
    for k in (1, 10, 100, 1000):
        alph = [b]
        for _ in range(k):
            alph.append(K.imp(a, alph[-1]))
        lines = [(a, ('ax',)), (alph[k], ('ax',))]
        for j in range(k - 1, -1, -1):
            lines.append((alph[j], ('mp', 0, len(lines) - 1)))
        okt, _ = K.check_derivation(lines, lambda f: f in (a, alph[k]))
        S = K.derivation_size(lines)
        M = K.size(a) + K.size(alph[k])
        sumF = K.F_sum(a) + K.F_sum(alph[k]) + K.F_sum(b)
        out.append(f"{k:>6} {S:>10} {M:>7} {sumF:>10} {S / sumF:>10.4f} {S / (M + K.size(b)) ** 2:>17.4f} "
                   f"{1 / (2 * (K.size(a) + 1)):>13.4f} {str(okt):>6} {str(K.is_normal(lines)):>6}")
    allok = raw_lemma21_fail == 0 and all(v == 0 for v in totals.values()) and norm_shrinks
    out.append("")
    out.append(f"verdict: {'all claims hold' if allok else 'FAILURE'}")


if __name__ == '__main__':
    main()
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
