"""c9: finite exact proxy for Prop. 2.4 (normalised SFI on the chain and the skipped strings).

Track "history", notes-final.md, Prop. 2.4.  Deterministic (exhaustive enumeration and closed forms;
no randomness); seed recorded as 0.  Output saved to c9_normalised_lower_bounds.out.

Prop. 2.4 bounds the per-step loss of the *normalised* predictor
    Pbar(y | D, x) = nu(D + (x,y)) / S,   S = sum_y nu(D + (x,y)),
from below via the exact identity  lbar_t = -log nu(D_t) + log S_t  and two facts:
  (1) an order-free lower bound on -log nu(D_t)   (Prop. 2.3(c): E[-log nu(D_t)] >= L_{t-1}), and
  (2) S_t >= w_B * nu_B(D_{t-1}) for one TOTAL component B (a "broom" B_{t-2} for the chain; the machine
      T_l = "guess s_j for j < l, answer 0 at lengths >= l" for the skipped strings).
The script builds exact finite mixtures nu of random-partial-function laws that contain such total
components AND heavy PARTIAL components (which lower the normaliser), and checks:
  (A0) chain, block lengths 1,2,3,4, all 1024 chains, by enumeration of every component's outcomes:
       closed-form component masses = enumerated masses; telescoping of raw losses; S_t >= w_B 2^{-L_{t-2}}
       (exact rationals); E[-log nu(D_t)] >= L_{t-1}; pathwise lbar_t >= -log nu(D_t) - L_{t-2} - log(1/w_B).
  (A1) chain, block lengths l_i = i, t <= 40, closed forms: the lower bound l_{t-1} - log(1/w_{B_{t-2}})
       becomes positive and grows; normalised vs raw cumulative losses.
  (B)  skipped strings, lengths 1,2,3, all 64 tuples, by enumeration: S >= w_{T_l} 2^{-l(l-1)/2} at the last
       step of block l (exact); E[-log nu(D^(l))] >= l(l+1)/2; pathwise lbar >= -log nu(D^(l)) - l(l-1)/2
       - log(1/w_{T_l}).
The finite mixtures are NOT M_F.  The script checks the algebra and the inequalities of the proof on
concrete mixtures that include partial laws; it proves nothing about M_F.
"""
from fractions import Fraction as Fr
from itertools import product
from math import log2

OUT = []


def say(s=""):
    OUT.append(s)
    print(s)


def bits(n):
    return [''.join(p) for p in product('01', repeat=n)]


class Enumerated:
    """Law of a random partial function: a finite list of (prob, f), f a dict (missing key = undefined)."""

    def __init__(self, name, outcomes):
        self.name = name
        self.outcomes = outcomes
        self.cm = {}
        self.cd = {}

    def mass(self, D):
        if D not in self.cm:
            self.cm[D] = sum((p for p, f in self.outcomes if all(f.get(x) == y for x, y in D)), Fr(0))
        return self.cm[D]

    def defined_mass(self, D, x):
        k = (D, x)
        if k not in self.cd:
            self.cd[k] = sum((p for p, f in self.outcomes
                              if x in f and all(f.get(a) == b for a, b in D)), Fr(0))
        return self.cd[k]


class Product:
    """Product law; total when q(.|x) sums to 1."""

    def __init__(self, name, q):
        self.name = name
        self.q = q

    def mass(self, D):
        s = Fr(1)
        for x, y in D:
            s *= self.q(y, x)
        return s

    def defined_mass(self, D, x):
        return self.mass(D)


def mix_mass(comps, D):
    return sum(w * c.mass(D) for w, c in comps)


def mix_S(comps, D, x):
    return sum(w * c.defined_mass(D, x) for w, c in comps)


# ------------------------------------------------------------------ chain: closed forms
def closed_forms(t, ell, j_list):
    """Masses on the chain data D_t (t >= 1) and defined masses S-components at step t (query x_t given D_{t-1}).
    L[k] = l_1 + ... + l_k.  Returns dicts keyed by component name."""
    L = [0]
    for e in ell:
        L.append(L[-1] + e)

    def broom_mass(j, t):
        if j == 0:
            return Fr(1) if t == 1 else Fr(0)
        if t <= j:
            return Fr(1, 2 ** L[t])
        if t == j + 1:
            return Fr(1, 2 ** L[j])
        return Fr(0)

    m = {}
    d = {}
    for j in j_list:
        m['B%d' % j] = broom_mass(j, t)
        d['B%d' % j] = broom_mass(j, t - 1) if t >= 2 else Fr(1)      # total: S-part = mass(D_{t-1})
    m['C'] = Fr(1) if t == 1 else Fr(1, 2 ** L[t])
    d['C'] = Fr(1) if t <= 2 else Fr(1, 2 ** L[t - 1])
    m['Cp'] = Fr(1, 2 ** L[t])
    d['Cp'] = Fr(1, 2 ** L[t])                                        # defined at x_t iff x_t = c_t
    m['U'] = Fr(1, 2 ** L[t - 1])
    d['U'] = Fr(1, 2 ** L[t - 2]) if t >= 2 else Fr(1)
    m['K'] = Fr(1) if t == 1 else Fr(0)
    d['K'] = Fr(1) if t <= 2 else Fr(0)
    return m, d, L


def part_A0():
    say("(A0) chain, block lengths 1,2,3,4; all 1024 chains; enumeration")
    ell = [1, 2, 3, 4]
    universe = [s for k in range(1, 5) for s in bits(k)]

    def broom(j):
        outs = []
        p = Fr(1, 2 ** sum(ell[:j]))
        for v in (product(*[bits(ell[i]) for i in range(j)]) if j > 0 else [()]):
            f = {}
            for x in universe:
                if j == 0 or x == v[0]:
                    f[x] = ''
                elif x in v[1:]:
                    f[x] = v[v.index(x) - 1]
                else:
                    f[x] = v[j - 1]
            outs.append((p, f))
        return Enumerated('B%d' % j, outs)

    def chain_law(partial):
        outs = []
        p = Fr(1, 2 ** sum(ell))
        for c in product(*[bits(e) for e in ell]):
            f = {} if partial else {x: '' for x in universe}
            f[c[0]] = ''
            for i in range(1, 4):
                f[c[i]] = c[i - 1]
            outs.append((p, f))
        return Enumerated('Cp' if partial else 'C', outs)

    U = Product('U', lambda y, x: Fr(1, 2 ** (len(x) - 1)) if len(y) == len(x) - 1 else Fr(0))
    K = Product('K', lambda y, x: Fr(1) if y == '' else Fr(0))
    named = {'B%d' % j: broom(j) for j in range(4)}
    named['C'] = chain_law(False)
    named['Cp'] = chain_law(True)
    named['U'] = U
    named['K'] = K
    w = {'B0': Fr(1, 16), 'B1': Fr(1, 16), 'B2': Fr(1, 16), 'B3': Fr(1, 16),
         'C': Fr(1, 8), 'Cp': Fr(1, 2), 'U': Fr(1, 16), 'K': Fr(1, 16)}
    assert sum(w.values()) == 1
    comps = [(w[k], named[k]) for k in w]
    say("  mixture: brooms B_0..B_3 1/16 each, randomized chain C 1/8, PARTIAL chain Cp 1/2, uniform product U 1/16, constant K 1/16")
    L = [0, 1, 3, 6, 10]
    ok_cf = ok_tel = ok_S = ok_path = True
    E = [0.0] * 5
    El = [0.0] * 5
    for x in product(*[bits(e) for e in ell]):
        D = ()
        prev = Fr(1)
        raw_sum = 0.0
        for t in range(1, 5):
            lab = '' if t == 1 else x[t - 2]
            for name, c in named.items():                       # closed forms vs enumeration
                mcf, dcf, _ = closed_forms(t, ell, range(4))
                if c.defined_mass(D, x[t - 1]) != dcf[name] or c.mass(D + ((x[t - 1], lab),)) != mcf[name]:
                    ok_cf = False
            S = mix_S(comps, D, x[t - 1])
            D = D + ((x[t - 1], lab),)
            m = mix_mass(comps, D)
            raw_sum += -log2(m / prev)
            prev = m
            lbar = -log2(m) + log2(S)
            E[t] += -log2(m)
            El[t] += lbar
            if t >= 2:
                if not S >= w['B%d' % (t - 2)] * Fr(1, 2 ** L[t - 2]):
                    ok_S = False
                if lbar < -log2(m) - L[t - 2] - log2(1 / w['B%d' % (t - 2)]) - 1e-12:
                    ok_path = False
        if abs(raw_sum + log2(prev)) > 1e-9:
            ok_tel = False
    N = 1024
    ok_E = all(E[t] / N >= L[t - 1] - 1e-12 for t in range(1, 5))
    say("  closed-form component masses = enumerated masses (all components, chains, steps): %s" % ok_cf)
    say("  raw per-step losses telescope to -log nu(D_4): %s" % ok_tel)
    say("  S_t >= w_{B_{t-2}} 2^{-L_{t-2}} on every path (exact): %s" % ok_S)
    say("  E[-log nu(D_t)] >= L_{t-1} for t = 1..4: %s   (values %s)"
        % (ok_E, ', '.join('%.4f' % (E[t] / N) for t in range(1, 5))))
    say("  pathwise lbar_t >= -log nu(D_t) - L_{t-2} - log(1/w_B), t >= 2: %s" % ok_path)
    say("  E[normalised cumulative] = %.4f bits < E[raw cumulative] = %.4f bits (partial component at work); L_3 = 6"
        % (sum(El[1:]) / N, E[4] / N))
    return ok_cf and ok_tel and ok_S and ok_E and ok_path


def part_A1():
    say("")
    say("(A1) chain, l_i = i, closed forms (valid by A0's cross-check of the formulas), t <= 40")
    T = 40
    ell = list(range(1, T + 1))
    J = list(range(0, T + 1))
    wB = {j: Fr(1, 4 * (j + 1) * (j + 2)) for j in J}           # sum over all j >= 0 is 1/4
    tail = Fr(1, 4) - sum(wB.values())                            # weight of brooms beyond T: unused
    w = {'C': Fr(1, 8), 'Cp': Fr(1, 2), 'U': Fr(1, 16), 'K': Fr(1, 16)}
    assert sum(w.values()) + sum(wB.values()) + tail == 1
    say("  mixture: brooms B_j with weight 1/(4(j+1)(j+2)), C 1/8, PARTIAL chain Cp 1/2, U 1/16, K 1/16")
    say("   t | -log nu(D_t) | L_{t-1} |  lbar_t | bound l_{t-1}-log(1/w_{B_{t-2}}) | raw cum. | norm. cum. | L_{t-1}")
    ok = True
    rawcum = normcum = 0.0
    prev = Fr(1)
    for t in range(1, T + 1):
        m_, d_, L = closed_forms(t, ell, J)
        m = sum(wB[j] * m_['B%d' % j] for j in J) + sum(w[k] * m_[k] for k in w)
        S = sum(wB[j] * d_['B%d' % j] for j in J) + sum(w[k] * d_[k] for k in w)
        lbar = -log2(m) + log2(S)
        rawcum += -log2(m / prev)
        prev = m
        normcum += lbar
        bound = (ell[t - 2] - log2(1 / wB[t - 2])) if t >= 2 else 0.0
        ok = ok and lbar >= bound - 1e-9 and -log2(m) >= L[t - 1] - 1e-9
        if t in (1, 2, 3, 5, 8, 10, 15, 20, 30, 40):
            say("  %2d | %12.3f | %7d | %7.3f | %32.3f | %8.2f | %10.2f | %d"
                % (t, -log2(m), L[t - 1], lbar, bound, rawcum, normcum, L[t - 1]))
    say("  bound holds at every t <= 40 and -log nu(D_t) >= L_{t-1}: %s" % ok)
    return ok


def part_B():
    say("")
    say("(B) skipped strings, lengths 1..3; all 64 tuples; enumeration")
    lens = [1, 2, 3]
    universe = [s for k in lens for s in bits(k)]

    def machine(name, guess_lens, rule):
        outs = []
        p = Fr(1, 2 ** sum(guess_lens)) if guess_lens else Fr(1)
        for g in (product(*[bits(k) for k in guess_lens]) if guess_lens else [()]):
            guess = dict(zip(guess_lens, g))
            f = {}
            for x in universe:
                v = rule(x, guess)
                if v is not None:
                    f[x] = v
            outs.append((p, f))
        return Enumerated(name, outs)

    Sk = machine('skip', lens, lambda x, g: '1' if x == g[len(x)] else '0')
    T = {l: machine('T%d' % l, [k for k in lens if k < l],
                    lambda x, g, l=l: '0' if len(x) >= l else ('1' if x == g[len(x)] else '0')) for l in lens}
    # partial laws: correct skip guesses below l, zeros at length l except UNDEFINED at the guess, undefined above l
    Sp = {l: machine('Sp%d' % l, [k for k in lens if k <= l],
                     lambda x, g, l=l: None if len(x) > l else
                     (('1' if x == g[len(x)] else '0') if len(x) < l else (None if x == g[l] else '0'))) for l in lens}
    U = Product('U', lambda y, x: Fr(1, 2) if y in ('0', '1') else Fr(0))
    K0 = Product('K0', lambda y, x: Fr(1) if y == '0' else Fr(0))
    wT = Fr(1, 16)
    comps = [(Fr(1, 8), Sk)] + [(Fr(1, 6), Sp[l]) for l in lens] + [(wT, T[l]) for l in lens] + \
            [(Fr(1, 16), U), (Fr(1, 8), K0)]
    assert sum(w for w, _ in comps) == 1
    say("  mixture: skip machine 1/8, PARTIAL laws Sp_1..Sp_3 1/6 each, T_1..T_3 1/16 each, uniform bit 1/16, constant 0 1/8")
    ok_S = ok_path = True
    Er = {l: 0.0 for l in lens}
    El = {l: 0.0 for l in lens}
    Ecum_norm = 0.0
    for s in product(*[bits(k) for k in lens]):
        D = ()
        cum = 0.0
        for l in lens:
            for x in [z for z in bits(l) if z != s[l - 1]] + [s[l - 1]]:
                y = '1' if x == s[l - 1] else '0'
                S = mix_S(comps, D, x)
                D = D + ((x, y),)
                m = mix_mass(comps, D)
                lbar = -log2(m) + log2(S)
                cum += lbar
                if x == s[l - 1]:
                    if not S >= wT * Fr(1, 2 ** (l * (l - 1) // 2)):
                        ok_S = False
                    if lbar < -log2(m) - l * (l - 1) / 2 - log2(1 / wT) - 1e-12:
                        ok_path = False
                    Er[l] += -log2(m)
                    El[l] += lbar
        Ecum_norm += cum
    N = 64
    ok_E = all(Er[l] / N >= l * (l + 1) / 2 - 1e-12 for l in lens)
    say("  S >= w_{T_l} 2^{-l(l-1)/2} at the last step of every block (exact): %s" % ok_S)
    say("  E[-log nu(D^(l))] >= l(l+1)/2: %s   (values %s against 1, 3, 6)"
        % (ok_E, ', '.join('%.4f' % (Er[l] / N) for l in lens)))
    say("  pathwise lbar(s_l) >= -log nu(D^(l)) - l(l-1)/2 - log(1/w_T): %s" % ok_path)
    say("  E[lbar at s_l] = %s;  E[normalised cumulative after block 3] = %.4f bits, E[raw] = %.4f bits"
        % (', '.join('%.4f' % (El[l] / N) for l in lens), Ecum_norm / N, Er[3] / N))
    return ok_S and ok_E and ok_path


if __name__ == "__main__":
    a0 = part_A0()
    a1 = part_A1()
    b = part_B()
    say("")
    say("ALL CHECKS PASSED" if (a0 and a1 and b) else "SOME CHECK FAILED")
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(OUT) + '\n')
