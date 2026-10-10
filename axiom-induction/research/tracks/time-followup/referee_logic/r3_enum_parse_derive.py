"""r3 (referee, logic): Remark 2.6 (enumerating the unpadded Craig set), and the syntax and derivation steps of
Theorem 4.2(b) and Corollary 4.3(a), checked in Mendelson's primitive syntax.

Part A (Rem 2.6, cumulative form).  The notes' example: f decides the s-th sentence within |phi_s| steps when s is a
power of 2 and loops otherwise.  Cost model as in c2 (one simulated step = 1, generating sentence s costs |phi_s|,
writing an axiom costs its length).  We compare
  * the generic dovetailing enumerator of A^C_f (the one the map f -> wrapper + f gives), and
  * a specialised enumerator of the same set A^C_f: for j = 0, 1, ...: generate sentence 2^j directly, run f on it,
    write (+-phi)^(k+1).
  The notes claim "the paper's A^C_f is not cheap to enumerate" (H-a row, Rem 2.6).  If the specialised enumerator
  meets the cumulative form, the claim holds only for the generic enumerator, not for the set.
Part B (Rem 2.6, strict form).  f decides every sentence in exactly |phi| steps.  Any enumerator writing a_1, a_2, ...
has e_i >= |a_1| + ... + |a_i| >= i, so the strict form e_i <= C |a_i|^p forces #{axioms of length <= L} <= C L^p.
We count the axioms of A^C_f of length <= L and find, for several (C, p), an L where the count exceeds C L^p: no
enumerator of A^C_f meets the strict form (a stronger statement than the notes' dovetailing argument).
Part C (Thm 4.2(b), parsing).  Primitive syntax: connectives N (not) and I (implies), conjunction B & C := N I B N C,
Polish notation.  tau_0 := Ax(x=x), tau_1 := N N tau_0, tau_E := I tau_0 tau_0, theta_eps := tau_E,
theta_{b c} := tau_b & theta_c.  Check: (psi & theta_c) parses back to (psi, c) uniquely, on random psi including
adversarial ones built from tau and theta pieces; |theta_c| <= 10|c| + 11 tokens (8 per bit 0, 10 per bit 1).
Part D (Thm 4.2(b), Cor 4.3(a), derivation).  Build, with the deduction-theorem algorithm, a K-derivation of
(P & Q) -> P from A1-A3 and MP; check it with an independent checker; substitute random formulas B, C for P, Q;
re-check; and measure the derivation's total symbol size against |B| + |C|.  The notes state "linear in |B| + |C|".
"""
import random
import sys

sys.setrecursionlimit(20000)
SEED = 2718
rng = random.Random(SEED)
out = [f"r3_enum_parse_derive  (seed {SEED})"]


# ================================================================================================================
# Part A
def word(s):
    return bin(s + 1)[3:]


def sent_len(s):
    return len(word(s)) + 3          # R(w)


def is_pow2(s):
    return s & (s - 1) == 0


def axiom_len(L, k):                 # psi^(k+1), |psi| = L or L + 1 (negation): take L + 1 (worst)
    m = k + 1
    return m * (L + 1) + 3 * (m - 1)


J = 18
# generic dovetailing: stage s starts run s (cost |phi_s|) then advances all active runs by one step
cost = 0
n_active = 0                          # number of unfinished runs (the looping ones never finish)
pending = {}                          # power-of-2 runs: s -> remaining steps
completions = []                      # (s, completion cost, cumulative axiom length)
cum_len = 0
s = 0
while len(completions) < J + 1:
    s += 1
    L = sent_len(s)
    cost += L
    n_active += 1
    if is_pow2(s):
        pending[s] = L
    cost += n_active                  # advance every unfinished run by one step
    done = []
    for r in list(pending):
        pending[r] -= 1
        if pending[r] == 0:
            done.append(r)
    for r in done:
        del pending[r]
        n_active -= 1
        a = axiom_len(sent_len(r), sent_len(r))
        cost += a
        cum_len += a
        completions.append((r, cost, cum_len))
gen_ratio = [(r, c / cl) for r, c, cl in completions]
# specialised enumerator
cost2 = 0
cum2 = 0
spec_ratio = []
for j in range(J + 1):
    r = 2 ** j
    L = sent_len(r)
    cost2 += L + L                    # generate sentence 2^j directly (O(|phi|)), run f for |phi| steps
    a = axiom_len(L, L)
    cost2 += a
    cum2 += a
    spec_ratio.append((r, cost2 / cum2))
out.append("Part A: completion time / cumulative output length for the axiom of sentence s = 2^j")
out.append(f"  {'s':>8} {'generic dovetail':>17} {'specialised':>12}")
for (r, g), (_, sp) in zip(gen_ratio, spec_ratio):
    if r in (1, 16, 256, 4096, 2 ** 15, 2 ** 18):
        out.append(f"  {r:>8} {g:>17.2f} {sp:>12.3f}")
okA = gen_ratio[-1][1] > 10 * gen_ratio[4][1] and max(x for _, x in spec_ratio) <= 2.0
out.append(f"  generic ratio grows ({gen_ratio[-1][1]:.1f} at s = 2^{J}); specialised ratio stays <= "
           f"{max(x for _, x in spec_ratio):.3f}: {'confirmed' if okA else 'NOT confirmed'}")
out.append("  => the same set A^C_f has an enumerator meeting the cumulative form; only the generic wrapper fails.")

# ================================================================================================================
# Part B
# sentences R(w), w nonempty binary: 2^m sentences of word length m, sentence length m + 3, f takes m + 3 steps;
# axiom length for (+-phi)^(k+1) with k = m + 3: at most axiom_len(m + 3, m + 3).
def count_upto(Lmax):
    tot = 0
    m = 1
    while axiom_len(m + 3, m + 3) <= Lmax:
        tot += 2 ** m
        m += 1
    return tot


out.append("Part B: #axioms of A^C_f with length <= L, against C L^p (strict form needs count <= C L^p)")
okB = True
for C, p in [(10 ** 3, 3), (10 ** 6, 4), (10 ** 9, 6)]:
    L = 10
    while count_upto(L) <= C * L ** p and L < 10 ** 7:
        L = int(L * 1.1) + 1
    hit = count_upto(L) > C * L ** p
    okB &= hit
    out.append(f"  C = {C:.0e}, p = {p}: count exceeds C L^p at L = {L} (count {count_upto(L):.3e} > "
               f"{C * L ** p:.3e}): {hit}")
out.append(f"  => no enumerator of A^C_f meets the strict form for these (C, p): {okB}")

# ================================================================================================================
# Part C: formulas as nested tuples; Polish serialisation
TAU0 = ('A', 'x', ('E', 'x', 'x'))
TAU1 = ('N', ('N', TAU0))
TAUE = ('I', TAU0, TAU0)


def AND(b, c):
    return ('N', ('I', b, ('N', c)))


def theta(c):
    t = TAUE
    for bit in reversed(c):
        t = AND(TAU0 if bit == '0' else TAU1, t)
    return t


def size(f):
    if isinstance(f, str):
        return 1
    return 1 + sum(size(g) for g in f[1:])


def parse_axiom(chi):
    """Return (psi, c) if chi = psi & theta_c, else None.  Deterministic: unique readability of the tuple tree."""
    if not (isinstance(chi, tuple) and chi[0] == 'N' and isinstance(chi[1], tuple) and chi[1][0] == 'I'):
        return None
    psi, rest = chi[1][1], chi[1][2]
    if not (isinstance(rest, tuple) and rest[0] == 'N'):
        return None
    th, bits = rest[1], []
    while True:
        if th == TAUE:
            return psi, ''.join(bits)
        if (isinstance(th, tuple) and th[0] == 'N' and isinstance(th[1], tuple) and th[1][0] == 'I'
                and th[1][1] in (TAU0, TAU1) and isinstance(th[1][2], tuple) and th[1][2][0] == 'N'):
            bits.append('0' if th[1][1] == TAU0 else '1')
            th = th[1][2][1]
            continue
        return None


def polish(f):
    if isinstance(f, str):
        return [f]
    r = [f[0]]
    for g in f[1:]:
        r += polish(g)
    return r


ARITY = {'N': 1, 'I': 2, 'E': 2, 'A': 2, 'R': 1}


def unpolish(toks):
    def go(i):
        t = toks[i]
        if t not in ARITY:
            return t, i + 1
        args, j = [], i + 1
        for _ in range(ARITY[t]):
            a, j = go(j)
            args.append(a)
        return (t, *args), j
    f, j = go(0)
    assert j == len(toks)
    return f


def rand_formula(d):
    r = rng.random()
    if d == 0 or r < 0.2:
        return rng.choice([('R', 'x'), ('R', 'y'), TAU0, TAU1, TAUE, ('E', 'x', 'y')])
    if r < 0.4:
        return ('N', rand_formula(d - 1))
    if r < 0.6:
        return ('I', rand_formula(d - 1), rand_formula(d - 1))
    if r < 0.75:
        return AND(rand_formula(d - 1), rand_formula(d - 1))
    if r < 0.9:
        return theta(''.join(rng.choice('01') for _ in range(rng.randint(0, 4))))
    return AND(rand_formula(d - 1), theta(''.join(rng.choice('01') for _ in range(rng.randint(0, 3)))))


okC = True
maxratio = 0.0
for _ in range(4000):
    psi = rand_formula(rng.randint(0, 5))
    c = ''.join(rng.choice('01') for _ in range(rng.randint(0, 40)))
    chi = AND(psi, theta(c))
    if parse_axiom(chi) != (psi, c):
        okC = False
    if unpolish(polish(chi)) != chi:          # Polish strings read back to the same tree
        okC = False
    if size(theta(c)) > 10 * len(c) + 11:
        okC = False
    maxratio = max(maxratio, (size(theta(c)) - 11) / max(1, len(c)))
# non-axioms: theta-like strings with a wrong tau are rejected
bad = AND(('R', 'x'), AND(('N', TAU0), TAUE))
okC &= parse_axiom(bad) is None
out.append(f"Part C: unique parsing of psi & theta_c in primitive Polish syntax on 4000 random cases: {okC};"
           f" |theta_c| <= 10|c| + 11 (max (|theta_c| - 11)/|c| = {maxratio:.1f})")


# ================================================================================================================
# Part D: Hilbert system K (propositional part): A1 B>(C>B); A2 (B>(C>D))>((B>C)>(B>D)); A3 (~C>~B)>((~C>B)>C); MP.
def I(a, b):
    return ('I', a, b)


def Nn(a):
    return ('N', a)


def is_A1(f):
    return f[0] == 'I' and isinstance(f[2], tuple) and f[2][0] == 'I' and f[2][2] == f[1]


def is_A2(f):
    try:
        (_, (i1, B, (i2, C, D)), (i3, (i4, B2, C2), (i5, B3, D2))) = f
        return (i1, i2, i3, i4, i5) == ('I',) * 5 and f[0] == 'I' and B == B2 == B3 and C == C2 and D == D2
    except (ValueError, TypeError):
        return False


def is_A3(f):
    try:
        (i0, (i1, (n1, C), (n2, B)), (i2, (i3, (n3, C2), B2), C3)) = f
        return (i0, i1, i2, i3) == ('I',) * 4 and (n1, n2, n3) == ('N',) * 3 and C == C2 == C3 and B == B2
    except (ValueError, TypeError):
        return False


def check(lines, hyps=()):
    seen = set()
    for f, why in lines:
        if why == 'ax':
            assert is_A1(f) or is_A2(f) or is_A3(f), f
        elif why == 'hyp':
            assert f in hyps
        else:
            _, i, j = why
            assert lines[i][0] in seen and lines[j][0] == I(lines[i][0], f) and lines[j][0] in seen
        seen.add(f)
    return True


def mp_line(lines, a, b):
    """Append MP conclusion from formulas a and a > b (both must already be lines)."""
    ia = next(k for k, (f, _) in enumerate(lines) if f == a)
    ib = next(k for k, (f, _) in enumerate(lines) if f == I(a, b))
    lines.append((b, ('mp', ia, ib)))


def deduction(lines, A, hyps):
    """Mendelson Prop 1.9: from a derivation of the last line from hyps + {A}, a derivation of A > last from hyps."""
    new = []

    def add(f, why):
        new.append((f, why))

    for f, why in lines:
        if f == A:
            # |- A > A
            add(I(I(A, I(I(A, A), A)), I(I(A, I(A, A)), I(A, A))), 'ax')
            add(I(A, I(I(A, A), A)), 'ax')
            mp_line(new, I(A, I(I(A, A), A)), I(I(A, I(A, A)), I(A, A)))
            add(I(A, I(A, A)), 'ax')
            mp_line(new, I(A, I(A, A)), I(A, A))
        elif why in ('ax', 'hyp'):
            add(f, why)
            add(I(f, I(A, f)), 'ax')
            mp_line(new, f, I(A, f))
        else:
            _, i, j = why
            Dj = lines[i][0]
            add(I(I(A, I(Dj, f)), I(I(A, Dj), I(A, f))), 'ax')
            mp_line(new, I(A, I(Dj, f)), I(I(A, Dj), I(A, f)))
            mp_line(new, I(A, Dj), I(A, f))
    return new


P, Q = 'P', 'Q'
# Lemma: ~B > (B > C), with B := P, C := ~Q
Bf, Cf = P, Nn(Q)
L = [(Nn(Bf), 'hyp'), (Bf, 'hyp'),
     (I(Bf, I(Nn(Cf), Bf)), 'ax'), (I(Nn(Bf), I(Nn(Cf), Nn(Bf))), 'ax')]
mp_line(L, Bf, I(Nn(Cf), Bf))
mp_line(L, Nn(Bf), I(Nn(Cf), Nn(Bf)))
L.append((I(I(Nn(Cf), Nn(Bf)), I(I(Nn(Cf), Bf), Cf)), 'ax'))
mp_line(L, I(Nn(Cf), Nn(Bf)), I(I(Nn(Cf), Bf), Cf))
mp_line(L, I(Nn(Cf), Bf), Cf)
check(L, hyps=(Nn(Bf), Bf))
L1 = deduction(L, Bf, hyps=(Nn(Bf),))
check(L1, hyps=(Nn(Bf),))
LEM = deduction(L1, Nn(Bf), hyps=())             # |- ~P > (P > ~Q)
check(LEM)
assert LEM[-1][0] == I(Nn(P), I(P, Nn(Q)))
# Main: from H := ~(P > ~Q) derive P, then discharge H
H = AND(P, Q)
M = list(LEM)
M.append((H, 'hyp'))
M.append((I(H, I(Nn(P), H)), 'ax'))
mp_line(M, H, I(Nn(P), H))                        # ~P > H, i.e. ~P > ~(P > ~Q)
M.append((I(I(Nn(P), Nn(I(P, Nn(Q)))), I(I(Nn(P), I(P, Nn(Q))), P)), 'ax'))   # A3 with C := P, B := P > ~Q
mp_line(M, I(Nn(P), Nn(I(P, Nn(Q)))), I(I(Nn(P), I(P, Nn(Q))), P))
mp_line(M, I(Nn(P), I(P, Nn(Q))), P)
check(M, hyps=(H,))
ELIM = deduction(M, H, hyps=())                   # |- (P & Q) > P
check(ELIM)
assert ELIM[-1][0] == I(AND(P, Q), P)


def subst(f, sub):
    if isinstance(f, str):
        return sub.get(f, f)
    return (f[0], *[subst(g, sub) for g in f[1:]])


def instantiate(lines, sub):
    return [(subst(f, sub), why) for f, why in lines]


out.append(f"Part D: K-derivation of (P & Q) > P built and checked: {len(ELIM)} lines, total size "
           f"{sum(size(f) for f, _ in ELIM)} with atomic P, Q")
rows = []
okD = True
for trial in range(60):
    Bfm = rand_formula(rng.randint(0, 6))
    Cfm = theta(''.join(rng.choice('01') for _ in range(rng.randint(0, 120)))) if trial % 2 else rand_formula(6)
    D = instantiate(ELIM, {P: Bfm, Q: Cfm})
    try:
        check(D)
    except AssertionError:
        okD = False
    # the full datum derivation: cite B & C, the derivation of (B & C) > B, then MP
    tot = size(AND(Bfm, Cfm)) + sum(size(f) for f, _ in D) + size(Bfm)
    rows.append((size(Bfm) + size(Cfm), tot))
# fit: tot <= g * (|B| + |C|) + h, with occurrences of P and Q counted per line
occP = sum(polish(f).count('P') for f, _ in ELIM) + 2
occQ = sum(polish(f).count('Q') for f, _ in ELIM) + 1
gam = max(tot / s_ for s_, tot in rows)
out.append(f"  instantiated with 60 random (B, C) (C up to |theta_c| for |c| <= 120): every instance checks: {okD}")
out.append(f"  derivation size = {occP}|B| + {occQ}|C| + const exactly (occurrences of P and Q in the scheme);"
           f" observed max size/(|B|+|C|) = {gam:.1f}")
ok = okA and okB and okC and okD
out.append(f"verdict: {'all checks pass' if ok else 'SOME CHECK FAILS'}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
