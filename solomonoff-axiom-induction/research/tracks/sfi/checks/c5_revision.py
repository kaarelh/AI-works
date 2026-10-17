"""c5_revision.py -- thread `sfi`, revision round (2026-10-16).  Finite checks prompted by the referees.

(A) Prop 6.5(b), the one-tape independent-label separation: the density step and the summed bound,
    on a family of MOSTLY CONSISTENT three-valued random labellers (referee B, issue 6: the
    development-round check c2 used machines consistent on ~5% of tapes, so its density check was
    nearly vacuous).  Written independently of referee B's rb2 (not read before this script ran;
    the results are compared in notes-final.md).
    Setting: 4 propositional atoms, background B = {a -> b}; 36 random B-independent formulas and
    12 B-decided ones; a three-valued
    labelling f_w on each tape w in {0,1}^L (L = 10), produced by a machine that reads a prefix of
    the tape for each sentence.  f is *consistent* on a tape if B + Gamma_f has a model and decides no
    iota-labelled sentence.  C = consistent tapes.  For eps in {1/4, 1/8, 1/16}:
      * dense prefixes: U(C cap [w]) > (1 - eps) 2^-|w|; W = the minimal ones (a prefix-free cover of C);
      * W' = W minus the smallest cylinders, removed while their total measure stays <= eps;
      * J_w = { sigma : U([w] cap {f(sigma) = iota}) > eps 2^-|w| }  (ALL tapes of [w] counted);
      (e1) J_w subset Ind_B for every w in W';
      (e3) for sigma outside I := union of the J_w (w in W'):
           nu3cons(sigma) := U(C cap {f(sigma)=iota})
                          <= sum_{w in W'} U([w] cap {f(sigma)=iota}) + sum_{w in W - W'} 2^-|w| + U(C - union W)
                          <= 2 eps.
    Non-vacuity counters: tapes on which f is inconsistent and labels a B-decided sentence iota
    (so "some tape labels sigma iota" would not imply independence); (w, sigma) pairs with sigma
    not in Ind_B and positive iota-mass in [w]; sigma outside I with positive consistent iota-mass.
    Then the finite form of the diagonal: machines p with lengths |p| in {2..7}; for each n the set
    I_n = union over |p| <= n of their I's, sigma_n := first independent sentence outside I_n,
    and the bound sum_{|p|<=n} 2^-|p| nu3cons_p(sigma_n) <= 2 eps sum_{|p|<=n} 2^-|p|.
(B) Lemma 1.3 (CR), referee A m12: Craig's padded set must be decoded with BOTH readings of a
    candidate psi = not phi' (F labels not phi' with 1, or F labels phi' with 0).  Propositional
    sentences as syntax trees; random partial labellers on a set that contains some sentences and
    their negations, with halting steps; the padded set is decided by the parsing decoder; we check
    Cn(B + decoded set) = Cn(B + Gamma_f) (same models) for the two-reading decoder and count the
    failures of a one-reading decoder.
Seed 20261016.  Output: c5_revision.out
"""
import os
import random
import itertools

SEED = 20261016
HERE = os.path.dirname(os.path.abspath(__file__))
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


NATOMS = 4
VALS = list(itertools.product([0, 1], repeat=NATOMS))     # 16 valuations
FULL = (1 << len(VALS)) - 1


def tt_atom(i):
    m = 0
    for j, v in enumerate(VALS):
        if v[i]:
            m |= 1 << j
    return m


ATOM_TT = [tt_atom(i) for i in range(NATOMS)]
B_TT = (~ATOM_TT[0] | ATOM_TT[1]) & FULL                   # a -> b


def rand_formula(rng, depth):
    """random formula as a truth table (16-bit mask)."""
    if depth == 0 or rng.random() < 0.3:
        t = ATOM_TT[rng.randrange(NATOMS)]
        return t if rng.random() < 0.5 else (~t) & FULL
    op = rng.choice(['and', 'or', 'imp'])
    x, y = rand_formula(rng, depth - 1), rand_formula(rng, depth - 1)
    if op == 'and':
        return x & y
    if op == 'or':
        return x | y
    return ((~x) | y) & FULL


def decided_by(mod, s):
    """is s constant on the model set mod (nonempty)?  returns 1 (true on all), 0 (false on all) or None."""
    if mod & s == mod:
        return 1
    if mod & s == 0:
        return 0
    return None


# ---------------------------------------------------------------- (A)
L = 10
NT = 1 << L


def consistent3(labels, sents):
    mod = B_TT
    for i, y in labels.items():
        if y == 1:
            mod &= sents[i]
        elif y == 0:
            mod &= (~sents[i]) & FULL
    if mod == 0:
        return False
    for i, y in labels.items():
        if y == 'i' and decided_by(mod, sents[i]) is not None:
            return False
    return True


def make_machine(rng, sents, ind):
    """A three-valued random labeller.  Bits 0..2 choose a model v of B (among B's models); each
    sentence is either committed (labelled by its value at v), iota-candidate (labelled iota if a
    tape bit says so and it is independent of the committed literals at v), or silent; deep bits
    add noise on 1/8 or 1/16 of the tapes (a flipped committed label, or iota on a B-decided
    sentence).  The label of sentence
    i depends only on the first r_i tape bits."""
    models = [j for j in range(len(VALS)) if (B_TT >> j) & 1]
    ns = len(sents)
    role = []
    for i in range(ns):
        u = rng.random()
        role.append('commit' if u < 0.12 else ('iota' if u < 0.55 else 'silent'))
    r = [rng.randint(3, L) for _ in range(ns)]
    coinbit = [rng.randrange(3, L) for _ in range(ns)]
    noise_rate = rng.choice([0.02, 0.05, 0.1])
    noise_pat = {}
    for i in range(ns):
        if rng.random() < noise_rate * 8:
            # noise fires on the tapes whose bits at 3 or 4 random deep positions match a pattern
            pos = rng.sample(range(3, L), rng.choice([3, 4]))
            noise_pat[i] = (pos, [rng.randrange(2) for _ in pos], rng.choice(['flip', 'fakeiota']))

    def labels_on(tape):
        bits = [(tape >> (L - 1 - j)) & 1 for j in range(L)]
        v = models[(bits[0] * 4 + bits[1] * 2 + bits[2]) % len(models)]
        lab = {}
        for i in range(ns):
            if role[i] == 'commit':
                lab[i] = (sents[i] >> v) & 1
        mod = B_TT
        for i, y in lab.items():
            mod &= sents[i] if y == 1 else (~sents[i]) & FULL
        for i in range(ns):
            if role[i] == 'iota' and bits[coinbit[i]] == 1 and decided_by(mod, sents[i]) is None:
                lab[i] = 'i'
        for i, (pos, pat, kind) in noise_pat.items():
            if all(bits[q] == b for q, b in zip(pos, pat)) and max(pos) < r[i]:
                if kind == 'flip' and i in lab and lab[i] != 'i':
                    lab[i] = 1 - lab[i]
                elif kind == 'fakeiota' and not ind[i]:
                    lab[i] = 'i'
        return lab
    return labels_on


def run_A(rng):
    out('(A) Prop 6.5(b): density step and summed bound, mostly consistent three-valued labellers')
    sents = []
    while len(sents) < 36:
        s = rand_formula(rng, 3)
        if s not in sents and decided_by(B_TT, s) is None:
            sents.append(s)
    while len(sents) < 48:
        # B-decided sentences (every 16-bit mask is the truth table of some formula over 4 atoms)
        m = rng.randrange(1 << 16)
        s = (m | B_TT) & FULL if len(sents) % 2 == 0 else (m & ~B_TT) & FULL
        if s not in sents:
            sents.append(s)
    ind = [decided_by(B_TT, s) is None for s in sents]
    out('    %d sentences, %d independent of B, %d decided by B' % (len(sents), sum(ind), len(sents) - sum(ind)))
    machines = []
    tries = 0
    while len(machines) < 30 and tries < 2000:
        tries += 1
        lab_fn = make_machine(rng, sents, ind)
        labs = [lab_fn(t) for t in range(NT)]
        cons = [consistent3(lb, sents) for lb in labs]
        frac = sum(cons) / NT
        if 0.5 <= frac <= 0.98:
            machines.append((labs, cons, frac))
    fr = sorted(m[2] for m in machines)
    out('    %d machines kept (of %d generated) with consistent fraction in [0.5, 0.98]; median %.3f, min %.3f, max %.3f'
        % (len(machines), tries, fr[len(fr) // 2], fr[0], fr[-1]))
    viol_e1 = viol_e3a = viol_e3b = 0
    nv_fake = nv_pairs = nv_outside = 0
    max_ratio = 0.0
    n_dense = n_dense_full = 0
    cases = 0
    for eps in (0.25, 0.125, 0.0625):
        for (labs, cons, frac) in machines:
            cases += 1
            # measure helpers over prefixes: tapes in [w] are an interval of tape indices
            def cyl(w, lw):
                lo = w << (L - lw)
                return range(lo, lo + (1 << (L - lw)))
            W = []
            covered = [False] * NT
            for lw in range(0, L + 1):
                for w in range(1 << lw):
                    rg = cyl(w, lw)
                    if any(covered[t] for t in rg):
                        continue            # a proper prefix is already dense (minimality)
                    cmass = sum(cons[t] for t in rg)
                    if cmass > (1 - eps) * len(rg):
                        W.append((w, lw))
                        for t in rg:
                            covered[t] = True
            n_dense += len(W)
            n_dense_full += sum(1 for (_, lw) in W if lw == L)
            # W' : drop smallest cylinders while removed mass <= eps
            Ws = sorted(W, key=lambda x: -x[1])
            removed, Wp, Wrem = 0.0, [], []
            for (w, lw) in Ws:
                if removed + 2.0 ** (-lw) <= eps:
                    removed += 2.0 ** (-lw)
                    Wrem.append((w, lw))
                else:
                    Wp.append((w, lw))
            uncovered_C = sum(1 for t in range(NT) if cons[t] and not covered[t]) / NT
            I = set()
            for (w, lw) in Wp:
                rg = cyl(w, lw)
                for i in range(len(sents)):
                    imass = sum(1 for t in rg if labs[t].get(i) == 'i') / NT
                    if imass > 0 and not ind[i]:
                        nv_pairs += 1
                    if imass > eps * 2.0 ** (-lw):
                        if not ind[i]:
                            viol_e1 += 1
                        I.add(i)
            for t in range(NT):
                if not cons[t] and any(y == 'i' and not ind[i] for i, y in labs[t].items()):
                    nv_fake += 1
                    break
            for i in range(len(sents)):
                if i in I:
                    continue
                nu = sum(1 for t in range(NT) if cons[t] and labs[t].get(i) == 'i') / NT
                if nu > 0:
                    nv_outside += 1
                first = sum(sum(1 for t in cyl(w, lw) if labs[t].get(i) == 'i') / NT for (w, lw) in Wp)
                rhs = first + sum(2.0 ** (-lw) for (_, lw) in Wrem) + uncovered_C
                if nu > rhs + 1e-12:
                    viol_e3a += 1
                if rhs > 2 * eps + 1e-12:
                    viol_e3b += 1
                max_ratio = max(max_ratio, nu / eps)
    out('    %d (machine, eps) cases, eps in {1/4, 1/8, 1/16}; %d dense prefixes, of which %d full tapes'
        % (cases, n_dense, n_dense_full))
    out('    (e1) J_w subset Ind_B: %d violations' % viol_e1)
    out('    (e3) nu3cons <= summed bound: %d violations; summed bound <= 2 eps: %d violations'
        % (viol_e3a, viol_e3b))
    out('    non-vacuity: machines with an inconsistent tape labelling a B-decided sentence iota: %d of %d cases;'
        % (nv_fake, cases))
    out('                 (w in W\', sigma not in Ind_B) pairs with positive iota-mass in [w]: %d;' % nv_pairs)
    out('                 sigma outside I with positive consistent iota-mass: %d; largest nu3cons/eps: %.3f (bound 2)'
        % (nv_outside, max_ratio))
    # the diagonal over machines of several lengths
    out('    finite diagonal: machine p_j has length |p_j| = 2 + (j mod 6); I_n = union of I over |p| <= n')
    eps = 0.125
    lengths = [2 + (j % 6) for j in range(len(machines))]
    Is, nus = [], []
    for (labs, cons, frac) in machines:
        def cyl(w, lw):
            lo = w << (L - lw)
            return range(lo, lo + (1 << (L - lw)))
        W, covered = [], [False] * NT
        for lw in range(0, L + 1):
            for w in range(1 << lw):
                rg = cyl(w, lw)
                if any(covered[t] for t in rg):
                    continue
                if sum(cons[t] for t in rg) > (1 - eps) * len(rg):
                    W.append((w, lw))
                    for t in rg:
                        covered[t] = True
        Ws = sorted(W, key=lambda x: -x[1])
        removed, Wp = 0.0, []
        for (w, lw) in Ws:
            if removed + 2.0 ** (-lw) <= eps:
                removed += 2.0 ** (-lw)
            else:
                Wp.append((w, lw))
        I = set()
        for (w, lw) in Wp:
            rg = cyl(w, lw)
            for i in range(len(sents)):
                if sum(1 for t in rg if labs[t].get(i) == 'i') / NT > eps * 2.0 ** (-lw):
                    I.add(i)
        Is.append(I)
        nus.append([sum(1 for t in range(NT) if cons[t] and labs[t].get(i) == 'i') / NT for i in range(len(sents))])
    viol_diag = 0
    for n in range(2, 8):
        In = set()
        for j, I in enumerate(Is):
            if lengths[j] <= n:
                In |= I
        cand = [i for i in range(len(sents)) if ind[i] and i not in In]
        if not cand:
            out('      n=%d: |I_n| = %d; Ind_B exhausted (the finite end of productivity)' % (n, len(In)))
            continue
        s = cand[0]
        mix = sum(2.0 ** (-lengths[j]) * nus[j][s] for j in range(len(Is)) if lengths[j] <= n)
        bound = 2 * eps * sum(2.0 ** (-lengths[j]) for j in range(len(Is)) if lengths[j] <= n)
        ok = mix <= bound + 1e-12
        viol_diag += (not ok)
        out('      n=%d: |I_n| = %2d, sigma_n = sentence %2d, sum 2^-|p| nu3cons_p(sigma_n) = %.4f <= %.4f: %s'
            % (n, len(In), s, mix, bound, ok))
    out('    diagonal bound violations: %d' % viol_diag)
    return viol_e1 + viol_e3a + viol_e3b + viol_diag


# ---------------------------------------------------------------- (B)
def tt_of(node):
    k = node[0]
    if k == 'atom':
        return ATOM_TT[node[1]]
    if k == 'not':
        return (~tt_of(node[1])) & FULL
    return tt_of(node[1]) & tt_of(node[2])


def neg(x):
    return ('not', x)


def conj(x, y):
    return ('and', x, y)


def power(psi, m):
    """psi^{wedge m}, right-nested: psi^{1} = psi, psi^{m+1} = psi and psi^{m}."""
    r = psi
    for _ in range(m - 1):
        r = conj(psi, r)
    return r


def decompositions(chi):
    """all (psi, m) with chi = psi^{wedge m}: (chi, 1), and if chi = psi and rest, the stripping reading."""
    res = [(chi, 1)]
    if chi[0] == 'and':
        psi = chi[1]
        cur, m = chi, 1
        while cur[0] == 'and' and cur[1] == psi:
            cur, m = cur[2], m + 1
        if cur == psi:
            res.append((psi, m))
    return res


def rand_tree(rng, depth):
    if depth == 0 or rng.random() < 0.35:
        return ('atom', rng.randrange(NATOMS))
    u = rng.random()
    if u < 0.4:
        return neg(rand_tree(rng, depth - 1))
    return conj(rand_tree(rng, depth - 1), rand_tree(rng, depth - 1))


def run_B(rng):
    out('(B) Lemma 1.3 (CR): decoding the padded Craig set with both readings of psi = not phi\'')
    fail_two = fail_one = cases = parse_bad = 0
    example = None
    for trial in range(400):
        base = []
        while len(base) < 6:
            t = rand_tree(rng, 2)
            if t not in base:
                base.append(t)
        S = list(base) + [neg(t) for t in base[:3]]       # some sentences together with their negations
        # random partial labeller: label (1/0) and halting step k, kept consistent with B = {a -> b}
        f = {}
        for s in S:
            if rng.random() < 0.6:
                f[s] = (rng.randrange(2), rng.randrange(0, 4))
        mod = B_TT
        for s, (y, _) in f.items():
            mod &= tt_of(s) if y == 1 else (~tt_of(s)) & FULL
        if mod == 0:
            continue
        cases += 1
        gamma_mod = mod
        # the intended padded set
        craig = set()
        for s, (y, k) in f.items():
            craig.add(power(s if y == 1 else neg(s), k + 1))
        # candidate sentences: all powers of all sentences of S and their negations, m <= 6
        cands = set()
        for s in S:
            for m in range(1, 7):
                cands.add(power(s, m))
                cands.add(power(neg(s), m))

        def decide(chi, both):
            for psi, m in decompositions(chi):
                if psi in f and f[psi] == (1, m - 1):
                    return True
                if psi[0] == 'not' and psi[1] in f and f[psi[1]] == (0, m - 1):
                    return True
                if not both:
                    continue
            return False

        def decide_one(chi):
            # one reading only: a candidate psi = not phi' is tested only as "phi' labelled 0"
            for psi, m in decompositions(chi):
                if psi[0] == 'not':
                    if psi[1] in f and f[psi[1]] == (0, m - 1):
                        return True
                elif psi in f and f[psi] == (1, m - 1):
                    return True
            return False

        for chi in cands:
            if len(decompositions(chi)) > 2:
                parse_bad += 1
        acc2 = {chi for chi in cands if decide(chi, True)}
        acc1 = {chi for chi in cands if decide_one(chi)}
        if acc2 != (craig & cands) or not craig <= cands:
            fail_two += 1
        m2, m1 = B_TT, B_TT
        for chi in acc2:
            m2 &= tt_of(chi)
        for chi in acc1:
            m1 &= tt_of(chi)
        if m2 != gamma_mod:
            fail_two += 1
        if m1 != gamma_mod:
            fail_one += 1
            if example is None:
                lost = [s for s, (y, k) in f.items() if s[0] == 'not' and y == 1]
                example = lost[0] if lost else None
    out('    %d consistent random labellers (sentences with some of their negations; halting steps 0..3)' % cases)
    out('    candidates with more than two decompositions: %d' % parse_bad)
    out('    two-reading decoder: accepted set = padded Craig set and Cn(B + set) = Cn(B + Gamma_f): %d failures' % fail_two)
    out('    one-reading decoder: Cn(B + accepted set) != Cn(B + Gamma_f) in %d of %d cases' % (fail_one, cases))
    if example is not None:
        out('      (example of a lost member: a sentence of the form not phi\' labelled 1, whose padded copy')
        out('       (not phi\')^{wedge(k+1)} the one-reading decoder rejects)')
    return fail_two + parse_bad


def main():
    rng = random.Random(SEED)
    out('c5_revision.py (seed %d)' % SEED)
    out('')
    bad = run_A(rng)
    out('')
    bad += run_B(rng)
    out('')
    out('total violations of the claims checked: %d' % bad)
    with open(os.path.join(HERE, 'c5_revision.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
