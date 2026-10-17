"""rb2_independence_density.py -- referee B, thread `sfi`.  Independent finite checks of notes.md
Prop 6.5(b) (one-tape: an observed "independent" label) and Props 6.3/6.4 (coin-free), exact.

Finite world: propositional, 4 atoms (16 valuations), background B a set of 6 valuations; 40
sentences (truth masks), with Ind := sentences B decides neither way.  Three-valued labels
{1, 0, i}.  A three-valued labelling lab is *consistent* if B + Gamma (from the 1/0 labels) is
satisfiable and decides none of the i-labelled sentences (notes section 6.2).

One-tape part (Prop 6.5(b)).  Random three-valued function machines on tapes of length L = 9
(512 tapes); per sentence a stopping tree.  Three machine families:
  (R) random machines whose 1/0 labels mostly follow a model of B;
  (P) "parity-scattered" machines: consistency of a tape is forced to depend on the parity of
      all its bits (an inconsistent label pair is emitted on odd-parity tapes at the last bit), so
      no proper prefix has density of consistency > 1/2 and dense prefixes are full tapes only;
  (S) "sparse" machines: consistent only on a cylinder [u] of measure 2^-|u|, |u| in 1..4, with
      iota labels on non-independent sentences outside [u] (where the tape is inconsistent anyway).
For eps in {1/4, 1/8, 1/32}: C := consistent tapes; W := minimal prefixes w with
U(C & [w]) > (1-eps) 2^-|w| (here W covers C, since a consistent full tape has density 1);
J_w := {sigma : U([w] & {f(sigma) = i}) > eps 2^-|w|}.  Checked, exactly (Fractions):
  (e1) J_w subset of Ind (the step that uses density);
  (e2) for every sigma outside the union of the J_w:  nu^{3,cons}(sigma, i) <= eps * sum_W 2^-|w| + U(C minus union [w])
       <= 2 eps  (the displayed inequality of the proof);
  (e3) the union of [w], w in W, covers C (finite analogue of "almost every point of C");
  (e4) the bound is not vacuous: max over sigma outside the J's of nu^{3,cons}(sigma, i) / eps, and
       the number of sentences with positive consistent iota-mass outside the J's.
Coin-free part (Props 6.3(b), 6.4).  Random three-valued labellers with lengths; the finite
diagonal sigma_n := first sentence of Ind outside I_n (I_n := iota-sets of consistent labellers of
length <= n); check W^{3,cons}({(sigma_n,i)}) <= sum of weights of lengths >= n+1 and the bracket
2^-n(sigma) <= W^{3,cons}({(sigma,i)}) <= tail(n(sigma)) of Prop 6.4(b) for every sigma in Ind.
Seed 20261016.  Output: rb2_independence_density.out
"""
import itertools
import random
from fractions import Fraction as Fr

SEED = 20261016
NV = 16
FULL = (1 << NV) - 1
L = 9
TAPES = [''.join(b) for b in itertools.product('01', repeat=L)]
NT = len(TAPES)
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def main():
    rng = random.Random(SEED)
    out('rb2_independence_density.py  seed %d' % SEED)
    models = rng.sample(range(NV), 6)
    B = sum(1 << v for v in models)
    NEG = lambda m: FULL & ~m
    S = []
    seen = set()
    while len(S) < 40:
        k = len(S) % 5
        m = rng.getrandbits(NV)
        if k == 3:
            m |= B          # entailed by B
        elif k == 4:
            m &= NEG(B)     # refuted by B
        if m not in seen and m not in (0, FULL):
            seen.add(m)
            S.append(m)
    NS = len(S)
    ind = [bool(B & S[i]) and bool(B & NEG(S[i])) for i in range(NS)]
    out('B has %d models; %d sentences, %d independent of B' % (len(models), NS, sum(ind)))

    def consistent(lab):
        tm = B
        for i, y in lab.items():
            if y == 1:
                tm &= S[i]
            elif y == 0:
                tm &= NEG(S[i])
        if tm == 0:
            return False
        for i, y in lab.items():
            if y == 'i' and ((tm & NEG(S[i])) == 0 or (tm & S[i]) == 0):
                return False
        return True

    # ---------------------------------------------------------------- machines
    def tree_labels(rng, label_fn, p_stop=0.35):
        d = {}
        stack = ['']
        while stack:
            w = stack.pop()
            if len(w) == L or rng.random() < p_stop:
                y = label_fn(w)
                if y is not None:
                    d[w] = y
            else:
                stack += [w + '0', w + '1']
        return d

    def machine_R(rng):
        """mostly consistent: 1/0 labels follow a model v of B; rare iota on independent
        sentences (so their consistent iota-mass is small); rare bad leaves (iota on a decided
        sentence, or a wrong label) that make the tape inconsistent."""
        v = rng.choice(models)
        act = set(rng.sample(range(NS), 12))
        p_iota = rng.choice([0.03, 0.06, 0.12])
        p_bad = rng.choice([0.01, 0.03, 0.06])
        F = []
        for i in range(NS):
            if i not in act:
                F.append({})
                continue
            truth = (S[i] >> v) & 1

            def lf(w, truth=truth, i=i):
                r = rng.random()
                if r < 0.1:
                    return None
                if ind[i]:
                    return 'i' if rng.random() < p_iota else None
                if rng.random() < p_bad:
                    return rng.choice(['i', 1 - truth])
                return truth
            F.append(tree_labels(rng, lf))
        return F

    def machine_P(rng):
        F = machine_R(rng)
        # sentence 0 and its "partner": on odd-parity full tapes, label two contradictory things
        a = next(i for i in range(NS) if not ind[i] and (S[i] & B) == B)   # entailed by B
        F[a] = {w: (0 if w.count('1') % 2 else 1) for w in TAPES}          # false on odd parity -> inconsistent
        return F

    def machine_S(rng):
        F = machine_R(rng)
        u = ''.join(rng.choice('01') for _ in range(rng.randint(1, 4)))
        a = next(i for i in range(NS) if not ind[i] and (S[i] & B) == B)
        F[a] = {w: (1 if w.startswith(u) else 0) for w in TAPES}
        # iota on decided sentences outside [u]: those tapes are inconsistent already
        for i in range(NS):
            if not ind[i] and i != a:
                old = F[i]
                new = {}
                for w in TAPES:   # re-express on full tapes, then overwrite outside [u]
                    y = next((old[w[:n]] for n in range(L + 1) if w[:n] in old), None)
                    if not w.startswith(u):
                        y = 'i'
                    if y is not None:
                        new[w] = y
                F[i] = new
        return F

    def labels(F, om):
        lab = {}
        for i in range(NS):
            for n in range(L + 1):
                y = F[i].get(om[:n])
                if y is not None:
                    lab[i] = y
                    break
        return lab

    tot = {'e1': 0, 'e2': 0, 'e3': 0, 'cases': 0, 'W': 0}
    worst = Fr(0)
    pos_outside = 0
    fam_stats = []
    for fam, maker, cnt in (('R', machine_R, 20), ('P', machine_P, 10), ('S', machine_S, 10)):
        nmach = 0
        for _ in range(cnt):
            F = maker(rng)
            labs = [labels(F, om) for om in TAPES]
            C = [consistent(lab) for lab in labs]
            if not any(C):
                continue
            nmach += 1
            for eps in (Fr(1, 4), Fr(1, 8), Fr(1, 32)):
                tot['cases'] += 1
                # minimal dense prefixes
                W = []
                for n in range(L + 1):
                    for w in (''.join(b) for b in itertools.product('01', repeat=n)):
                        if any(w.startswith(x) for x in W):
                            continue
                        ext = [t for t, om in enumerate(TAPES) if om.startswith(w)]
                        cw = Fr(sum(1 for t in ext if C[t]), NT)
                        if cw > (1 - eps) * Fr(len(ext), NT):
                            W.append(w)
                tot['W'] += len(W)
                cov = set(t for t, om in enumerate(TAPES) if any(om.startswith(w) for w in W))
                if any(C[t] and t not in cov for t in range(NT)):
                    tot['e3'] += 1
                J = set()
                for w in W:
                    ext = [t for t, om in enumerate(TAPES) if om.startswith(w)]
                    for s in range(NS):
                        im = Fr(sum(1 for t in ext if labs[t].get(s) == 'i'), NT)
                        if im > eps * Fr(len(ext), NT):
                            J.add(s)
                            if not ind[s]:
                                tot['e1'] += 1
                sumW = sum(Fr(1, 2 ** len(w)) for w in W)
                outside_C = Fr(sum(1 for t in range(NT) if C[t] and t not in cov), NT)
                bound = eps * sumW + outside_C
                for s in range(NS):
                    if s in J:
                        continue
                    nu = Fr(sum(1 for t in range(NT) if C[t] and labs[t].get(s) == 'i'), NT)
                    if nu > bound or nu > 2 * eps:
                        tot['e2'] += 1
                    if nu > 0:
                        pos_outside += 1
                        worst = max(worst, nu / eps)
        fam_stats.append((fam, nmach))
    out('one tape, density lemma: machines with a consistent tape per family %s; %d (machine, eps) cases, '
        '%d dense prefixes in all' % (fam_stats, tot['cases'], tot['W']))
    out('  (e1) J_w not inside Ind: %d;  (e2) nu^{3,cons}(sigma,i) above eps*sum_W 2^-|w| + U(C minus cover) or above 2 eps: %d;'
        % (tot['e1'], tot['e2']))
    out('  (e3) consistent tapes not covered by dense prefixes: %d;  (e4) sentences outside the J\'s with positive '
        'consistent iota-mass: %d, largest nu/eps = %.4f (<= 2 required)' % (tot['e3'], pos_outside, float(worst)))

    # ---------------------------------------------------------------- coin-free diagonal
    labellers = []
    for idx in range(240):
        l = 3 + idx // 12
        dom = rng.sample(range(NS), rng.randint(1, 6))
        lab = {i: rng.choice([1, 0, 'i', 'i', 'i']) for i in dom}
        labellers.append((l, lab))
    for s in range(NS):                         # lookup labellers "i on s"
        labellers.append((8 + s.bit_length(), {s: 'i'}))
    cons = [consistent(lab) for _, lab in labellers]
    lengths = sorted(set(l for l, _ in labellers))

    def W3(s):
        return sum(Fr(1, 2 ** l) for (l, lab), c in zip(labellers, cons) if c and lab.get(s) == 'i')

    def tail(n):
        return sum(Fr(1, 2 ** l) for l, _ in labellers if l >= n)

    bad_b = bad_bracket = rows = 0
    for n in lengths:
        In = set(s for (l, lab), c in zip(labellers, cons) if c and l <= n for s, y in lab.items() if y == 'i')
        if not all(ind[s] for s in In):
            bad_b += 1
        rest = [s for s in range(NS) if ind[s] and s not in In]
        if not rest:
            out('coin-free diagonal: Ind exhausted at n = %d (finite end of productivity)' % n)
            break
        rows += 1
        if W3(rest[0]) > tail(n + 1):
            bad_b += 1
    for s in range(NS):
        if not ind[s]:
            continue
        ns = min(l for (l, lab), c in zip(labellers, cons) if c and lab.get(s) == 'i')
        w = W3(s)
        if not (Fr(1, 2 ** ns) <= w <= tail(ns)):
            bad_bracket += 1
    out('coin-free: %d diagonal rows; violations of I_n subset Ind or W3(sigma_n) <= tail(n+1): %d; '
        'violations of 2^-n(sigma) <= W3 <= tail(n(sigma)) over %d independent sentences: %d'
        % (rows, bad_b, sum(ind), bad_bracket))
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
