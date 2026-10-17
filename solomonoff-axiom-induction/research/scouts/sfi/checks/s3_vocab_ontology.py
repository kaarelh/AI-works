#!/usr/bin/env python3
"""s3_vocab_ontology.py -- vocabulary versus ontology (scout S, notes.md section 3.6: Lemma 3.9, Prop 3.10, Rem 3.11, Thm 3.12).

Observational language L_O = {e, s0, s1, R} with equality.  Word terms t_w := s_{w1}(...s_{wk}(e)...),
so s_a(t_v) = t_{av}.  Data are the literals R(t_w)^{[w in X]}.

Part A (Prop 3.10(a), ground pairing translation; reading (a1)).
  An alternating "game" machine on input w with configurations coded as words.  The ground axioms of
  short-derivations Prop 4.3 use a theoretical binary relation C (and C'); here every atom C(t_w, t_c) is
  replaced by the observational formula theta(t_w, s0 t_c) (C' by theta(t_w, s1 t_c)), where
      theta(s, t) := forall z ((s1 s1 z = z & s0 z = s & s0 s1 z = t) -> R(z)).
  Checks: (A1) every derivation (MP only) is valid, with axioms recognised by an independent decider that
  parses the formula; the last line is the right literal; line counts and the largest line;
  (A2) the pairing lemma on a finite fragment of the model U (words plus pair elements P(a,b) with
  s0 P(a,b) = a, s1 P(a,b) = P(b,a)): the premise of theta(s,t) holds at z iff z = P(s,t);
  (A3) every axiom (all words w with |w| <= N_A, all configurations) is true in U, where
  R(t_w) := [w in X] and R(P(t_w, s_tag t_c)) := [c accepting / rejecting]: so A^O u Gamma_{f_X} is
  consistent (on this finite part).

Part B (Prop 3.10(b), a finite observational theory; readings (a2), (b2), and (a1)/(b) sizes).
  A deterministic two-stack machine deciding the non-regular set EQ := {w : #0(w) = #1(w)}.  Configurations
  are 5-tuples (x, q, l, r, a); the 5-ary atom is coded by nested pair elements, theta_5, and every template
  variable is relativised to Std(y) := ~(s1 s1 y = y), with Std(e) and Std(y) -> Std(s_a y) as axioms.
  A finite theory of 13 sentences.  Checks: (B1) Hilbert-style derivations (theory axioms, A4 instances
  forall v B -> B[t/v] with t closed, MP) of every datum with |w| <= N_B, all valid, last line right;
  sizes; (B2) determinism: on every reachable tuple at most one template applies, and halting templates
  give the literal [w in EQ]; (B3) every template instance with variables ranging over the words of length
  <= 3 is true in U (theta_5 evaluated by the unique-witness lemma, the lemma checked on a fragment).
  Variant (B4): the same theory with a 5-ary theoretical relation symbol C in place of theta_5 and no
  relativisation, in the free term model W (domain = observed objects only).

Part C (Thm 3.12, regular languages and finite theories over an observable domain).
  For regular X (X3 := #1 divisible by 3; X11 := contains 11), the finite theory
      S_{sig(e)}(e),   forall x (S_sigma(x) -> S_{sigma_a}(s_a x))   (sigma a realised signature, a in {0,1}),
  S_sigma(x) := AND_{|u| < n} R(s_u x)^{sigma(u)}.  Checks: (C1) every sentence true in the free term model
  (W, X) on all x with |x| <= N_C; (C2) valid derivations of every datum (A4, MP, and one propositional
  tautology for conjunction elimination, checked by truth table).  (C3) For the non-regular EQ, the number
  of distinct residual signatures grows with the depth: the construction has no finite analogue there.

Seed 20261015 (only for the random sample in A2/B3).  Writes s3_vocab_ontology.out next to itself.
"""
import itertools
import os
import random

SEED = 20261015
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "s3_vocab_ontology.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


# ---------------------------------------------------------------- syntax
E = ('e',)


def S0(t):
    return ('s0', t)


def S1(t):
    return ('s1', t)


def V(n):
    return ('v', n)


def tw(w):
    """t_w = s_{w1}(... s_{wk}(e))"""
    t = E
    for ch in reversed(w):
        t = S0(t) if ch == '0' else S1(t)
    return t


def term_word(t):
    """inverse of tw on closed word terms; None if not a closed word term"""
    out = []
    while t != E:
        if not isinstance(t, tuple) or t[0] not in ('s0', 's1'):
            return None
        out.append('0' if t[0] == 's0' else '1')
        t = t[1]
    return ''.join(out)


def Eq(a, b):
    return ('eq', a, b)


def Not(a):
    return ('not', a)


def Imp(a, b):
    return ('imp', a, b)


def And(a, b):
    return ('and', a, b)


def All(n, a):
    return ('all', n, a)


def Rr(t):
    return ('R', t)


def ands(xs):
    out = xs[-1]
    for x in reversed(xs[:-1]):
        out = And(x, out)
    return out


def size(f):
    if f == E:
        return 1
    k = f[0]
    if k == 'v':
        return 1
    if k in ('s0', 's1', 'R', 'not'):
        return 1 + size(f[1])
    if k in ('eq', 'imp', 'and'):
        return 1 + size(f[1]) + size(f[2])
    if k == 'all':
        return 1 + size(f[2])
    raise ValueError(f)


def subst(f, n, t):
    if f == E:
        return f
    k = f[0]
    if k == 'v':
        return t if f[1] == n else f
    if k in ('s0', 's1', 'R', 'not'):
        return (k, subst(f[1], n, t))
    if k in ('eq', 'imp', 'and'):
        return (k, subst(f[1], n, t), subst(f[2], n, t))
    if k == 'all':
        return f if f[1] == n else ('all', f[1], subst(f[2], n, t))
    raise ValueError(f)


def closed_term(t):
    if t == E:
        return True
    if t[0] == 'v':
        return False
    return t[0] in ('s0', 's1') and closed_term(t[1])


def find_witness(B, C, n):
    """a term t with B[t/n] == C, found by walking B and C in parallel (None if no occurrence decides it)"""
    if B == ('v', n):
        return C
    if not isinstance(B, tuple) or not isinstance(C, tuple) or B == E or C == E:
        return None
    if B[0] != C[0]:
        return None
    k = B[0]
    if k in ('s0', 's1', 'R', 'not'):
        return find_witness(B[1], C[1], n)
    if k in ('eq', 'imp', 'and'):
        r = find_witness(B[1], C[1], n)
        return r if r is not None else find_witness(B[2], C[2], n)
    if k == 'all':
        if B[1] == n:
            return None
        return find_witness(B[2], C[2], n)
    return None


def is_A4(f):
    """forall n B -> B[t/n], t closed"""
    if f[0] != 'imp' or f[1][0] != 'all':
        return False
    n, B, C = f[1][1], f[1][2], f[2]
    t = find_witness(B, C, n)
    if t is None:                      # vacuous quantifier: C must equal B
        return B == C
    return closed_term(t) and subst(B, n, t) == C


def prop_atoms(f, acc):
    if f[0] in ('not',):
        prop_atoms(f[1], acc)
    elif f[0] in ('imp', 'and'):
        prop_atoms(f[1], acc)
        prop_atoms(f[2], acc)
    else:
        acc.add(f)


def prop_eval(f, val):
    k = f[0]
    if k == 'not':
        return not prop_eval(f[1], val)
    if k == 'imp':
        return (not prop_eval(f[1], val)) or prop_eval(f[2], val)
    if k == 'and':
        return prop_eval(f[1], val) and prop_eval(f[2], val)
    return val[f]


def is_taut(f):
    atoms = set()
    prop_atoms(f, atoms)
    atoms = sorted(atoms, key=repr)
    if len(atoms) > 16:
        return False
    for bits in itertools.product([False, True], repeat=len(atoms)):
        if not prop_eval(f, dict(zip(atoms, bits))):
            return False
    return True


def check_derivation(lines, is_axiom, goal):
    """lines: list of (formula, just); just in ('ax',), ('A4',), ('MP', i, j) [line j = line i -> this],
    ('TAUT',).  Returns (ok, message, stats)."""
    seen = []
    nl_inst = 0
    lg_inst = 0
    maxline = 0
    total = 0
    for idx, (f, j) in enumerate(lines):
        s = size(f)
        maxline = max(maxline, s)
        total += s
        if j[0] == 'ax':
            if not is_axiom(f):
                return False, "line %d not an axiom" % idx, None
            nl_inst = max(nl_inst, s)
        elif j[0] == 'A4':
            if not is_A4(f):
                return False, "line %d not an A4 instance" % idx, None
            lg_inst = max(lg_inst, s)
        elif j[0] == 'TAUT':
            if not is_taut(f):
                return False, "line %d not a tautology" % idx, None
            lg_inst = max(lg_inst, s)
        elif j[0] == 'MP':
            i1, i2 = j[1], j[2]
            if not (i1 < idx and i2 < idx and seen[i2] == Imp(seen[i1], f)):
                return False, "line %d bad MP" % idx, None
        else:
            return False, "bad justification", None
        seen.append(f)
    if seen[-1] != goal:
        return False, "wrong last line", None
    return True, "ok", dict(lines=len(lines), maxline=maxline, total=total, nl_inst=nl_inst, lg_inst=lg_inst)


# ---------------------------------------------------------------- the model U (pairing)
def P(a, b):
    return ('P', a, b)


def u_s0(z):
    return '0' + z if isinstance(z, str) else z[1]


def u_s1(z):
    return '1' + z if isinstance(z, str) else P(z[2], z[1])


def pair_premise_U(z, a, b):
    """s1 s1 z = z  &  s0 z = a  &  s0 s1 z = b, evaluated in U"""
    return u_s1(u_s1(z)) == z and u_s0(z) == a and u_s0(u_s1(z)) == b


def std_U(z):
    return u_s1(u_s1(z)) != z


def pair_formula(z, a, b):
    return ands([Eq(S1(S1(z)), z), Eq(S0(z), a), Eq(S0(S1(z)), b)])


def theta(args, tag):
    """theta_k(a_1..a_k): nested pair elements; variables named tag+'z1'..; returns the formula"""
    k = len(args)
    prem = []
    zs = [V(tag + 'z%d' % i) for i in range(1, k)]
    prem.append(pair_formula(zs[0], args[k - 2], args[k - 1]))
    for j in range(1, k - 1):
        prem.append(pair_formula(zs[j], args[k - 2 - j], zs[j - 1]))
    f = Imp(ands(prem), Rr(zs[-1]))
    for z in reversed(zs):
        f = All(z[1], f)
    return f


def tuple_element(words):
    """the nested pair element <a_1,...,a_k> in U"""
    k = len(words)
    z = P(words[k - 2], words[k - 1])
    for j in range(k - 3, -1, -1):
        z = P(words[j], z)
    return z


# ================================================================= Part A
def game_conf(i, b):
    return '1' * i + '0' + str(b)


def game_decode(c):
    i = 0
    while i < len(c) and c[i] == '1':
        i += 1
    if c[i:i + 1] != '0' or len(c) != i + 2 or c[-1] not in '01':
        return None
    return i, int(c[-1])


def game_type(w, i):
    n = len(w)
    if i == n:
        return 'halt'
    return 'E' if i % 2 == 0 else 'A'


def game_succ(w, i, b):
    bit = int(w[i])
    if i % 2 == 0:                       # existential
        return [(i + 1, b), (i + 1, b ^ bit)]
    return [(i + 1, b), (i + 1, b | bit)]  # universal


def game_value(w, i, b, memo):
    key = (i, b)
    if key in memo:
        return memo[key]
    if i == len(w):
        v = (b == 1)
    else:
        vs = [game_value(w, i2, b2, memo) for i2, b2 in game_succ(w, i, b)]
        v = any(vs) if i % 2 == 0 else all(vs)
    memo[key] = v
    return v


def in_XA(w):
    return game_value(w, 0, 0, {})


def thA(w, tag, c):
    return theta([tw(w), (S0 if tag == 0 else S1)(tw(c))], 'A')


def parse_thA(f):
    """theta(t_w, s_tag t_c) -> (w, tag, c) or None"""
    g = f
    if not (isinstance(g, tuple) and g[0] == 'all' and g[1] == 'Az1'):
        return None
    body = g[2]
    if body[0] != 'imp' or body[2] != Rr(V('Az1')):
        return None
    p = body[1]
    try:
        s = p[2][1][2]
        t = p[2][2][2]
    except (IndexError, TypeError):
        return None
    w = term_word(s)
    if w is None or not isinstance(t, tuple) or t[0] not in ('s0', 's1'):
        return None
    c = term_word(t[1])
    if c is None:
        return None
    tag = 0 if t[0] == 's0' else 1
    if thA(w, tag, c) != f:
        return None
    return w, tag, c


def is_axiom_A(f):
    """independent decider for the translated set A^O: parse and check the shape against the machine"""
    # atoms
    r = parse_thA(f)
    if r is not None:
        w, tag, c = r
        d = game_decode(c)
        if d is None or d[0] > len(w):
            return False
        i, b = d
        return game_type(w, i) == 'halt' and ((tag == 0 and b == 1) or (tag == 1 and b == 0))
    if f[0] != 'imp':
        return False
    lhs, rhs = f[1], f[2]
    # output axioms
    if rhs[0] in ('R', 'not'):
        lit = rhs if rhs[0] == 'R' else rhs[1]
        r = parse_thA(lhs)
        if r is None or lit[0] != 'R':
            return False
        w, tag, c = r
        if tw(w) != lit[1] or c != game_conf(0, 0):
            return False
        return (tag == 0 and rhs[0] == 'R') or (tag == 1 and rhs[0] == 'not')
    r1 = parse_thA(lhs)
    if r1 is None:
        return False
    w, tag, c1 = r1
    r2 = parse_thA(rhs)
    if r2 is not None:                  # one premise: C(c') -> C(c)
        w2, tag2, c = r2
        if (w2, tag2) != (w, tag):
            return False
        d, d1 = game_decode(c), game_decode(c1)
        if d is None or d1 is None or d[0] >= len(w):
            return False
        i, b = d
        kind = game_type(w, i)
        if d1 not in game_succ(w, i, b):
            return False
        # existential accepts via one successor; universal rejects via one successor
        return (tag == 0 and kind == 'E') or (tag == 1 and kind == 'A')
    if rhs[0] != 'imp':
        return False
    r2 = parse_thA(rhs[1])
    r3 = parse_thA(rhs[2])
    if r2 is None or r3 is None:
        return False
    (w2, tag2, c2), (w3, tag3, c) = r2, r3
    if not ((w2, tag2) == (w3, tag3) == (w, tag)):
        return False
    d, d1, d2 = game_decode(c), game_decode(c1), game_decode(c2)
    if None in (d, d1, d2) or d[0] >= len(w):
        return False
    i, b = d
    kind = game_type(w, i)
    succ = game_succ(w, i, b)
    if [d1, d2] != succ:
        return False
    return (tag == 0 and kind == 'A') or (tag == 1 and kind == 'E')


def derive_A(w):
    """MP-only derivation of R(t_w)^{[w in X_A]} from A^O"""
    memo = {}
    val = game_value(w, 0, 0, memo)
    tag = 0 if val else 1
    lines = []
    where = {}

    def get(i, b):
        """derive theta(t_w, s_tag t_c) for c = (i, b), which has value == val; returns line index"""
        if (i, b) in where:
            return where[(i, b)]
        c = game_conf(i, b)
        goal = thA(w, tag, c)
        if i == len(w):
            lines.append((goal, ('ax',)))
        else:
            kind = game_type(w, i)
            succ = game_succ(w, i, b)
            one_needed = (kind == 'E') if tag == 0 else (kind == 'A')
            if one_needed:
                s = next(s for s in succ if memo[s] == val)
                k1 = get(*s)
                ax = Imp(thA(w, tag, game_conf(*s)), goal)
                lines.append((ax, ('ax',)))
                lines.append((goal, ('MP', k1, len(lines) - 1)))
            else:
                k1 = get(*succ[0])
                k2 = get(*succ[1])
                ax = Imp(thA(w, tag, game_conf(*succ[0])), Imp(thA(w, tag, game_conf(*succ[1])), goal))
                lines.append((ax, ('ax',)))
                lines.append((Imp(thA(w, tag, game_conf(*succ[1])), goal), ('MP', k1, len(lines) - 1)))
                lines.append((goal, ('MP', k2, len(lines) - 1)))
        where[(i, b)] = len(lines) - 1
        return where[(i, b)]

    k = get(0, 0)
    lit = Rr(tw(w)) if val else Not(Rr(tw(w)))
    lines.append((Imp(thA(w, tag, game_conf(0, 0)), lit), ('ax',)))
    lines.append((lit, ('MP', k, len(lines) - 1)))
    return lines, lit


def axioms_A_for(w):
    """all members of A^O whose input word is w"""
    out = []
    n = len(w)
    for i in range(n + 1):
        for b in (0, 1):
            c = game_conf(i, b)
            if i == n:
                out.append(thA(w, 0 if b == 1 else 1, c))
                continue
            kind = game_type(w, i)
            succ = game_succ(w, i, b)
            for tag in (0, 1):
                one = (kind == 'E') if tag == 0 else (kind == 'A')
                if one:
                    for s in succ:
                        out.append(Imp(thA(w, tag, game_conf(*s)), thA(w, tag, c)))
                else:
                    out.append(Imp(thA(w, tag, game_conf(*succ[0])),
                                   Imp(thA(w, tag, game_conf(*succ[1])), thA(w, tag, c))))
    out.append(Imp(thA(w, 0, game_conf(0, 0)), Rr(tw(w))))
    out.append(Imp(thA(w, 1, game_conf(0, 0)), Not(Rr(tw(w)))))
    return out


def eval_U_A(f, R):
    """evaluate a Boolean combination of theta-atoms and R-literals over word terms in U"""
    r = parse_thA(f)
    if r is not None:
        w, tag, c = r
        return R(P(w, ('0' if tag == 0 else '1') + c))
    k = f[0]
    if k == 'R':
        return R(term_word(f[1]))
    if k == 'not':
        return not eval_U_A(f[1], R)
    if k == 'imp':
        return (not eval_U_A(f[1], R)) or eval_U_A(f[2], R)
    raise ValueError(f)


def words_upto(n):
    out = ['']
    for L in range(1, n + 1):
        out += [''.join(p) for p in itertools.product('01', repeat=L)]
    return out


def part_A(rng):
    log("=== Part A: ground pairing translation of an alternating machine (Prop 3.10(a)) ===")
    N_A = 10
    nwords = 0
    nder = 0
    bad = 0
    mx_lines = 0
    ratio = 0.0
    nlit_true = 0
    for w in words_upto(N_A):
        nwords += 1
        lines, lit = derive_A(w)
        ok, msg, st = check_derivation(lines, is_axiom_A, lit)
        nder += 1
        if not ok:
            bad += 1
            log("  FAIL %r: %s" % (w, msg))
            continue
        mx_lines = max(mx_lines, st['lines'])
        ratio = max(ratio, st['maxline'] / (len(w) + 1))
        nlit_true += (lit[0] == 'R')
    log("(A1) derivations checked: %d words |w| <= %d, invalid: %d; datum true for %d words;" %
        (nder, N_A, bad, nlit_true))
    log("     only MP and members of A^O (recognised by the parsing decider); max lines %d; "
        "max line size / (|w|+1) = %.2f" % (mx_lines, ratio))
    # A2: pairing lemma on a fragment
    W3 = words_upto(3)
    frag = list(W3) + [P(a, b) for a in W3[:7] for b in W3[:7]] + \
        [P(a, P(b, c)) for a in W3[:3] for b in W3[:3] for c in W3[:3]]
    comps = list(W3[:7]) + [P(a, b) for a in W3[:3] for b in W3[:3]]
    viol = 0
    checks = 0
    for z in frag:
        for a in comps:
            for b in comps:
                checks += 1
                if pair_premise_U(z, a, b) != (z == P(a, b)):
                    viol += 1
    std_viol = sum(1 for z in frag if std_U(z) != isinstance(z, str))
    log("(A2) pairing lemma on a fragment of U: %d (z, a, b) triples, violations %d; "
        "Std(z) <-> z is a word: violations %d" % (checks, viol, std_viol))

    # A3: model check
    def R(el):
        if isinstance(el, str):
            return in_XA(el)
        if el[0] == 'P' and isinstance(el[1], str) and isinstance(el[2], str):
            w, tc = el[1], el[2]
            if tc == '':
                return False
            tag, c = tc[0], tc[1:]
            d = game_decode(c)
            if d is None or d[0] > len(w):
                return False
            v = game_value(w, d[0], d[1], {})
            return v if tag == '0' else (not v)
        return False
    nax = 0
    false_ax = 0
    for w in words_upto(8):
        for ax in axioms_A_for(w):
            nax += 1
            if not is_axiom_A(ax):
                false_ax += 1
                log("  decider rejects generated axiom for %r" % w)
            elif not eval_U_A(ax, R):
                false_ax += 1
                log("  axiom false in U for %r" % w)
    # the data literals
    lit_bad = sum(1 for w in words_upto(8) if R(w) != in_XA(w))
    log("(A3) all %d axioms of A^O for |w| <= 8 recognised by the decider and true in U: failures %d; "
        "Gamma_{f_X} true in U: failures %d" % (nax, false_ax, lit_bad))
    # negative control: a corrupted axiom (wrong output) must be rejected
    w = '0110'
    wrong = Imp(thA(w, 0, game_conf(0, 0)), Not(Rr(tw(w))))
    log("     negative control: wrong-output axiom accepted by decider: %s" % is_axiom_A(wrong))
    log("")


# ================================================================= Part B
# configuration tuple (x, q, l, r, a); POS = t_'0', NEG = t_'1'
POS, NEG = tw('0'), tw('1')


def templates_B():
    """list of (name, vars, pattern tuple, result) ; result is a tuple or ('lit', sign)"""
    x, l, r, a, a2 = V('x'), V('l'), V('r'), V('a'), V('b')
    return [
        ('T1', ['x', 'l', 'r', 'a'], (x, POS, l, S1(r), a), (x, POS, S1(l), r, S1(a))),
        ('T2', ['x', 'l', 'r'], (x, POS, l, S0(r), E), (x, NEG, S0(l), r, S1(E))),
        ('T3', ['x', 'l', 'r', 'a'], (x, POS, l, S0(r), S1(a)), (x, POS, S0(l), r, a)),
        ('T4', ['x', 'l', 'r', 'a'], (x, NEG, l, S0(r), a), (x, NEG, S0(l), r, S1(a))),
        ('T5', ['x', 'l', 'r'], (x, NEG, l, S1(r), S1(E)), (x, POS, S1(l), r, E)),
        ('T6', ['x', 'l', 'r', 'b'], (x, NEG, l, S1(r), S1(S1(a2))), (x, NEG, S1(l), r, S1(a2))),
        ('Acc', ['x', 'l'], (x, POS, l, E, E), ('lit', 1)),
        ('Rej1', ['x', 'l', 'a'], (x, POS, l, E, S1(a)), ('lit', 0)),
        ('Rej2', ['x', 'l', 'a'], (x, NEG, l, E, a), ('lit', 0)),
    ]


def Std(t):
    return Not(Eq(S1(S1(t)), t))


def atom_B(args, mode):
    return theta(list(args), 'B') if mode == 'O' else ('C5',) + tuple(args)


def template_formula(tpl, mode):
    name, vs, pat, res = tpl
    if res[0] == 'lit':
        concl = Rr(V('x')) if res[1] == 1 else Not(Rr(V('x')))
    else:
        concl = atom_B(res, mode)
    f = Imp(atom_B(pat, mode), concl)
    if mode == 'O':
        for v in reversed(vs):
            f = Imp(Std(V(v)), f)
    for v in reversed(vs):
        f = All(v, f)
    return f


def start_formula(mode):
    f = atom_B((V('x'), POS, E, V('x'), E), mode)
    if mode == 'O':
        f = Imp(Std(V('x')), f)
    return All('x', f)


def theory_B(mode):
    th = [start_formula(mode)] + [template_formula(t, mode) for t in templates_B()]
    if mode == 'O':
        th += [Std(E), All('y', Imp(Std(V('y')), Std(S0(V('y'))))), All('y', Imp(Std(V('y')), Std(S1(V('y')))))]
    return th


# extend size/subst to the predicate atom C5 (mode P)
_size = size
_subst = subst


def size(f):  # noqa: F811
    if isinstance(f, tuple) and f and f[0] == 'C5':
        return 1 + sum(_size(t) for t in f[1:])
    if isinstance(f, tuple) and f and f[0] in ('not', 'imp', 'and', 'all'):
        if f[0] == 'not':
            return 1 + size(f[1])
        if f[0] in ('imp', 'and'):
            return 1 + size(f[1]) + size(f[2])
        return 1 + size(f[2])
    return _size(f)


def subst(f, n, t):  # noqa: F811
    if isinstance(f, tuple) and f and f[0] == 'C5':
        return ('C5',) + tuple(_subst(a, n, t) for a in f[1:])
    if isinstance(f, tuple) and f and f[0] in ('not', 'imp', 'and', 'all'):
        if f[0] == 'not':
            return ('not', subst(f[1], n, t))
        if f[0] in ('imp', 'and'):
            return (f[0], subst(f[1], n, t), subst(f[2], n, t))
        return f if f[1] == n else ('all', f[1], subst(f[2], n, t))
    return _subst(f, n, t)


_find = find_witness


def find_witness(B, C, n):  # noqa: F811
    if isinstance(B, tuple) and B and B[0] == 'C5':
        if not (isinstance(C, tuple) and C and C[0] == 'C5'):
            return None
        for b1, c1 in zip(B[1:], C[1:]):
            r = _find(b1, c1, n)
            if r is not None:
                return r
        return None
    if isinstance(B, tuple) and B and B[0] in ('not', 'imp', 'and', 'all'):
        if not (isinstance(C, tuple) and C and C[0] == B[0]):
            return None
        if B[0] == 'not':
            return find_witness(B[1], C[1], n)
        if B[0] in ('imp', 'and'):
            r = find_witness(B[1], C[1], n)
            return r if r is not None else find_witness(B[2], C[2], n)
        if B[1] == n:
            return None
        return find_witness(B[2], C[2], n)
    return _find(B, C, n)


def match(pat, word_tuple):
    """match a pattern tuple of terms (with variables) against a tuple of words; returns binding or None"""
    bind = {}

    def m(p, w):
        if p == E:
            return w == ''
        if p[0] == 'v':
            if p[1] in bind:
                return bind[p[1]] == w
            bind[p[1]] = w
            return True
        if p[0] in ('s0', 's1'):
            ch = '0' if p[0] == 's0' else '1'
            return len(w) > 0 and w[0] == ch and m(p[1], w[1:])
        return False
    for p, w in zip(pat, word_tuple):
        if not m(p, w):
            return None
    return bind


def inst_words(t, bind):
    """the word of a pattern term under a binding of its variables to words"""
    if t == E:
        return ''
    if t[0] == 'v':
        return bind[t[1]]
    return ('0' if t[0] == 's0' else '1') + inst_words(t[1], bind)


def run_B(w):
    """the run of the machine: list of word tuples, and the verdict (1 accept / 0 reject)"""
    tup = (w, '0', '', w, '')
    run = [tup]
    tpls = templates_B()
    while True:
        hits = [(t, match(t[2], tup)) for t in tpls]
        hits = [(t, b) for t, b in hits if b is not None]
        if len(hits) != 1:
            return run, None, len(hits)
        t, b = hits[0]
        if t[3][0] == 'lit':
            return run, t[3][1], 1
        tup = tuple(inst_words(x, b) for x in t[3])
        run.append(tup)


def in_EQ(w):
    return w.count('0') == w.count('1')


def derive_B(w, mode, theory):
    """Hilbert derivation of R(t_w)^{[w in EQ]} from the finite theory (mode 'O' or 'P')"""
    lines = []
    std_line = {}

    def add(f, j):
        lines.append((f, j))
        return len(lines) - 1

    def std(word):
        if word in std_line:
            return std_line[word]
        if word == '':
            k = add(Std(E), ('ax',))
        else:
            k0 = std(word[1:])
            ax = theory[-2] if word[0] == '0' else theory[-1]
            ka = add(ax, ('ax',))
            body = ax[2]
            inst = subst(body, 'y', tw(word[1:]))
            k1 = add(Imp(ax, inst), ('A4',))
            k2 = add(inst, ('MP', ka, k1))
            k = add(inst[2], ('MP', k0, k2))
        std_line[word] = k
        return k

    def instantiate(ax, bindings_order, bind):
        """cite ax, instantiate its leading quantifiers with the bound words; returns the line index"""
        k = add(ax, ('ax',))
        f = ax
        for v in bindings_order:
            assert f[0] == 'all' and f[1] == v
            inst = subst(f[2], v, tw(bind[v]))
            k1 = add(Imp(f, inst), ('A4',))
            k = add(inst, ('MP', k, k1))
            f = inst
        return k, f

    def discharge_std(k, f, vs, bind):
        if mode != 'O':
            return k, f
        for v in vs:
            ks = std(bind[v])
            assert f[0] == 'imp' and f[1] == Std(tw(bind[v]))
            k = add(f[2], ('MP', ks, k))
            f = f[2]
        return k, f

    run, verdict, _ = run_B(w)
    # start
    bind = {'x': w}
    k, f = instantiate(theory[0], ['x'], bind)
    k, f = discharge_std(k, f, ['x'], bind)
    cur = k
    tpls = templates_B()
    for step in range(len(run)):
        tup = run[step]
        hit = [(i, t, match(t[2], tup)) for i, t in enumerate(tpls)]
        hit = [(i, t, b) for i, t, b in hit if b is not None]
        i, t, b = hit[0]
        ax = theory[1 + i]
        k, f = instantiate(ax, t[1], b)
        k, f = discharge_std(k, f, t[1], b)
        assert f[0] == 'imp' and f[1] == lines[cur][0], (w, step)
        cur = add(f[2], ('MP', cur, k))
    lit = Rr(tw(w)) if verdict == 1 else Not(Rr(tw(w)))
    return lines, lit, verdict


def part_B(rng):
    log("=== Part B: a finite observational theory for EQ = {#0 = #1} (Prop 3.10(b)) ===")
    th = theory_B('O')
    thset = set(th)
    log("theory: %d sentences, sizes %s" % (len(th), sorted(size(s) for s in th)))
    N_B = 10
    bad = 0
    wrong = 0
    mx = dict(lines=0, maxline=0, nl=0, lg=0)
    per = []
    for w in words_upto(N_B):
        lines, lit, verdict = derive_B(w, 'O', th)
        if (verdict == 1) != in_EQ(w):
            wrong += 1
        ok, msg, st = check_derivation(lines, lambda f: f in thset, lit)
        if not ok:
            bad += 1
            log("  FAIL %r: %s" % (w, msg))
            continue
        mx['lines'] = max(mx['lines'], st['lines'])
        mx['maxline'] = max(mx['maxline'], st['maxline'])
        mx['nl'] = max(mx['nl'], st['nl_inst'])
        mx['lg'] = max(mx['lg'], st['lg_inst'])
        if len(w) in (2, 6, 10) and w == '01' * (len(w) // 2):
            per.append((len(w), st['lines'], st['maxline'], st['lg_inst'], st['total']))
    log("(B1) derivations of all %d data with |w| <= %d: invalid %d, verdict != [w in EQ]: %d" %
        (len(words_upto(N_B)), N_B, bad, wrong))
    log("     largest nonlogical instance %d (constant: a member of the finite theory); largest logical (A4) "
        "instance %d; largest line %d; most lines %d" % (mx['nl'], mx['lg'], mx['maxline'], mx['lines']))
    log("     on w = (01)^k: |w|, lines, largest line, largest A4 instance, total size: %s" % per)
    # negative control: corrupt one A4 line (instantiate with a different term) -> the checker must reject
    lines, lit, _ = derive_B('0110', 'O', th)
    k = next(i for i, (f, j) in enumerate(lines) if j[0] == 'A4' and f[1][1] == 'x')
    f = lines[k][0]
    bad_inst = subst(f[1][2], 'x', tw('1'))
    corrupted = list(lines)
    corrupted[k] = (Imp(f[1], subst(f[1][2], 'x', tw('0110'))[0:1] + bad_inst[1:]), ('A4',))
    corrupted[k + 1] = (corrupted[k][0][2], lines[k + 1][1])
    okc, msgc, _ = check_derivation(corrupted, lambda g: g in thset, lit)
    log("     negative controls: derivation with one (valid) A4 line instantiated at t_1 instead of t_0110 "
        "accepted: %s (%s);" % (okc, msgc))
    B = f[1][2]
    nonuniform = Imp(f[1], Imp(B[1][0:1] + (subst(B[1], 'x', tw('1'))[1],), subst(B[2], 'x', tw('0110'))))
    log("     a non-uniform instance (t_1 in Std(x), t_0110 elsewhere) passes the A4 test: %s" % is_A4(nonuniform))
    # B2: determinism and verdicts on reachable tuples
    amb = 0
    reach = 0
    verdict_bad = 0
    for w in words_upto(N_B):
        run, verdict, nh = run_B(w)
        reach += len(run)
        if verdict is None:
            amb += 1
        elif (verdict == 1) != in_EQ(w):
            verdict_bad += 1
    log("(B2) reachable tuples %d: tuples matching 0 or >= 2 templates %d; wrong verdicts %d" %
        (reach, amb, verdict_bad))
    # B3: template instances over small words are true in U (theta_5 via the unique-witness lemma)
    small = words_upto(3)
    C = set()
    for x in small:
        run, _, _ = run_B(x)
        C.update(run)

    def in_C(tup):
        # membership in the least fixed point: the run from x (tuple component 0)
        x = tup[0]
        if len(x) > 3:
            run, _, _ = run_B(x)
            return tup in set(run)
        return tup in C
    false_inst = 0
    ninst = 0
    for name, vs, pat, res in templates_B():
        for vals in itertools.product(small, repeat=len(vs)):
            bind = dict(zip(vs, vals))
            ninst += 1
            ptup = tuple(inst_words(t, bind) for t in pat)
            if not in_C(ptup):
                continue
            if res[0] == 'lit':
                if (res[1] == 1) != in_EQ(bind['x']):
                    false_inst += 1
            else:
                rtup = tuple(inst_words(t, bind) for t in res)
                if not in_C(rtup):
                    false_inst += 1
    # start instances
    for x in small:
        ninst += 1
        if not in_C((x, '0', '', x, '')):
            false_inst += 1
    # sample check of the nested-tuple lemma: theta_5's premise has the unique witness chain
    viol = 0
    for _ in range(300):
        words = [rng.choice(small) for _ in range(5)]
        z1 = P(words[3], words[4])
        z2 = P(words[2], z1)
        z3 = P(words[1], z2)
        z4 = P(words[0], z3)
        if tuple_element(words) != z4:
            viol += 1
        for zz, (aa, bb) in ((z1, (words[3], words[4])), (z2, (words[2], z1)),
                             (z3, (words[1], z2)), (z4, (words[0], z3))):
            if not pair_premise_U(zz, aa, bb):
                viol += 1
            other = P(bb, aa) if aa != bb else P(aa, '0' + aa)
            if pair_premise_U(other, aa, bb) and other != zz:
                viol += 1
    log("(B3) template instances with variables over the %d words of length <= 3: %d, false in U: %d; "
        "nested-witness sample (300 tuples): violations %d" % (len(small), ninst, false_inst, viol))
    # B4: predicate version over the free term model
    thP = theory_B('P')
    thPset = set(thP)
    badP = 0
    mxP = 0
    for w in words_upto(N_B):
        lines, lit, verdict = derive_B(w, 'P', thP)
        ok, msg, st = check_derivation(lines, lambda f: f in thPset, lit)
        if not ok:
            badP += 1
            continue
        mxP = max(mxP, st['maxline'])
    log("(B4) predicate version (5-ary C, no relativisation, model = free term algebra W with C the set of "
        "reachable tuples): %d sentences; derivations invalid %d; largest line %d" % (len(thP), badP, mxP))
    log("")


# ================================================================= Part C
def residual_sig(X, v, n):
    return tuple(X(u + v) for u in words_upto(n - 1))


def regular_theory(X, n, depth):
    """signatures sig(v) over u with |u| < n, transitions sigma -> sigma_a, checked on all v with |v| <= depth"""
    sig = {}
    trans = {}
    for v in words_upto(depth):
        s = residual_sig(X, v, n)
        sig[v] = s
    conflicts = 0
    for v in words_upto(depth - 1):
        for a in '01':
            key = (sig[v], a)
            val = sig[a + v]
            if key in trans and trans[key] != val:
                conflicts += 1
            trans[key] = val
    return sig, trans, conflicts


def S_formula(sigma, t, n):
    us = words_upto(n - 1)
    lits = []
    for u, b in zip(us, sigma):
        at = Rr(tw_on(u, t))
        lits.append(at if b else Not(at))
    return ands(lits)


def tw_on(u, t):
    for ch in reversed(u):
        t = S0(t) if ch == '0' else S1(t)
    return t


def eval_W(f, X):
    """evaluate a quantifier-free formula over closed word terms in the free term model (W, X)"""
    k = f[0]
    if k == 'R':
        return X(term_word(f[1]))
    if k == 'not':
        return not eval_W(f[1], X)
    if k == 'and':
        return eval_W(f[1], X) and eval_W(f[2], X)
    if k == 'imp':
        return (not eval_W(f[1], X)) or eval_W(f[2], X)
    if k == 'eq':
        return term_word(f[1]) == term_word(f[2])
    raise ValueError(f)


def part_C():
    log("=== Part C: finite theories over an observable domain; regular languages (Thm 3.12) ===")
    langs = [("X3  (#1 = 0 mod 3)", lambda w: w.count('1') % 3 == 0, 3),
             ("X11 (contains 11)", lambda w: '11' in w, 3)]
    N_C = 9
    for name, X, n in langs:
        sig, trans, conflicts = regular_theory(X, n, N_C + 1)
        sigs = sorted(set(sig.values()))
        # the theory
        th = [S_formula(sig[''], E, n)]
        for (s, a), s2 in sorted(trans.items()):
            f = All('x', Imp(S_formula(s, V('x'), n), S_formula(s2, (S0 if a == '0' else S1)(V('x')), n)))
            th.append(f)
        thset = set(th)
        # C1 truth in W on all x with |x| <= N_C
        false_ = 0
        for x in words_upto(N_C):
            if not eval_W(th[0], X):
                false_ += 1
            for f in th[1:]:
                inst = subst(f[2], 'x', tw(x))
                if not eval_W(inst, X):
                    false_ += 1
        # C2 derivations
        bad = 0
        mxl = 0
        for w in words_upto(N_C):
            lines = [(th[0], ('ax',))]
            cur = 0
            v = ''
            for ch in reversed(w):
                s = sig[v]
                s2 = trans[(s, ch)]
                ax = All('x', Imp(S_formula(s, V('x'), n), S_formula(s2, (S0 if ch == '0' else S1)(V('x')), n)))
                lines.append((ax, ('ax',)))
                inst = subst(ax[2], 'x', tw(v))
                lines.append((Imp(ax, inst), ('A4',)))
                lines.append((inst, ('MP', len(lines) - 2, len(lines) - 1)))
                lines.append((inst[2], ('MP', cur, len(lines) - 1)))
                cur = len(lines) - 1
                v = ch + v
            lit = Rr(tw(w)) if X(w) else Not(Rr(tw(w)))
            lines.append((Imp(lines[cur][0], lit), ('TAUT',)))
            lines.append((lit, ('MP', cur, len(lines) - 1)))
            ok, msg, st = check_derivation(lines, lambda f: f in thset, lit)
            if not ok:
                bad += 1
                log("  FAIL %r: %s" % (w, msg))
            else:
                mxl = max(mxl, st['maxline'])
        log("%s: %d residual classes (signatures over |u| < %d), transition conflicts %d; theory of %d "
            "sentences; (C1) false instances in (W, X) for |x| <= %d: %d; (C2) invalid derivations of the %d "
            "data with |w| <= %d: %d; largest line %d" %
            (name, len(sigs), n, conflicts, len(th), N_C, false_, len(words_upto(N_C)), N_C, bad, mxl))
    # C3: EQ is not regular -- the number of residual classes realised by short words keeps growing
    row = []
    for depth in (2, 4, 6, 8):
        sigs = set(residual_sig(in_EQ, v, depth + 1) for v in words_upto(depth))
        row.append((depth, len(sigs)))
    log("(C3) EQ: distinct residual signatures (window |u| <= d) among the words of length <= d, for d = "
        "2, 4, 6, 8: %s; = 2d + 1, unbounded, so the signature construction has no finite version for EQ" % row)
    log("")


def main():
    rng = random.Random(SEED)
    log("s3_vocab_ontology.py  seed=%d" % SEED)
    log("")
    part_A(rng)
    part_B(rng)
    part_C()
    log("Reading: (A) and (B) are observational axiom sets (only e, s0, s1, R, =) whose models contain")
    log("unnamed pair elements; they reproduce the alternating-machine and the finite-theory constructions")
    log("that short-derivations Props 4.3 and 4.12 build with theoretical symbols C, C', pr.  (C) shows the")
    log("other side: finite theories true in the free term model (only named objects) fit regular languages,")
    log("by the signature construction; that they fit nothing else is Thm 3.12 (Rabin), not computed here.")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
