#!/usr/bin/env python3
"""t3_alternating.py -- reading (a1): ground pairing translation of alternating axioms, and finite alternating
two-stack theories (relation version and observational version).

Record: notes.md, Proposition 4.3 (ground pairing translation A^O_M of SD Prop 4.3, fresh machine) and
Proposition 4.7 (finite theories under (a1): alternating two-stack programs; relation and theta_2 versions).

Part A (fresh alternating machine, ground axioms).  The interval game on a word w of length n >= 1:
  configuration (i, j), 0 <= i <= j < n, coded as the word bin_m(i) bin_m(j), m = bit length of n;
  the player to move is existential iff the number of moves made, (n-1)-(j-i), is even; a move deletes the
  leftmost or the rightmost letter; at i = j the configuration halts and accepts iff w_i = 1.
  X := {w : the existential player wins from (0, n-1)}; the empty word is rejected (a table literal).
  A_M: C(t_w,t_c) for accepting halting c, C'(t_w,t_c) for rejecting halting c; existential c: C(c_k) -> C(c)
  for each successor and C'(c_1) -> (C'(c_2) -> C'(c)); universal c: C(c_1) -> (C(c_2) -> C(c)) and
  C'(c_k) -> C'(c); output: C(init) -> R(t_w), C'(init) -> ~R(t_w).
  A^O_M: C(a,b) := theta_2(a, s0 b), C'(a,b) := theta_2(a, s1 b).
  Checks: (A1) MP derivations of every datum with 1 <= |w| <= 10, axioms recognised by an independent parsing
  decider, last line right, sizes; (A2) every member of A^O_M with 1 <= |w| <= 7 is true in U (R(t_w) := [w in X],
  R(P(t_w, t_{0c})) := [c accepting], R(P(t_w, t_{1c})) := [c rejecting]); (A3) negative controls: a wrong
  output axiom is rejected by the decider and false in U; a corrupted derivation is rejected.

Part B (finite theory, alternating).  An alternating one-tape machine for Y := {w : every 1 has a 0 somewhere
  to its right} (universal scan; existential/deterministic search), compiled into an alternating two-stack
  program (backward rules; a universal rule has two premises), with the conversion phase for the raw input.
  Relation version {e,s0,s1,R,C} and theta_2/Std version {e,s0,s1,R}.  Checks: pattern disjointness across
  distinct (state, symbol) pairs, the alternating acceptance of start(x) equals the specification for all
  |x| <= 9, Hilbert derivations of every datum with |x| <= 7 for both versions, and the largest line size
  (the (a1) budget) against |x|.

Deterministic.  Writes t3_alternating.out next to itself.
"""
import functools
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hilbert_check as HC  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "t3_alternating.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


def theta2(a, b):
    return f"A w I Q 11.w .w I Q 0.w {a} I Q 01.w {b} R .w"


# ======================================================================================== Part A
def game(w):
    n = len(w)
    m = max(1, n.bit_length())

    def code(i, j):
        return format(i, "0%db" % m) + format(j, "0%db" % m)

    @functools.lru_cache(maxsize=None)
    def wins(i, j):  # True iff existential wins
        if i == j:
            return w[i] == "1"
        ex = ((n - 1) - (j - i)) % 2 == 0
        a, b = wins(i + 1, j), wins(i, j - 1)
        return (a or b) if ex else (a and b)

    return n, m, code, wins


def in_X(w):
    if not w:
        return False
    n, m, code, wins = game(w)
    return wins(0, n - 1)


def CA(w, c):   # the translation of C(t_w, t_c)
    return theta2(f"{w}.e", f"0{c}.e")


def CR(w, c):   # the translation of C'(t_w, t_c)
    return theta2(f"{w}.e", f"1{c}.e")


def derive_game(w):
    n, m, code, wins = game(w)
    lines, idx = [], {}

    def add(s, j):
        lines.append((s, j))
        return len(lines) - 1

    def mp(i, j):
        s = lines[j][0]
        a = lines[i][0]
        assert s.startswith("I " + a + " ")
        return add(s[len(a) + 3:], ("MP", i, j))

    memo = {}

    def der(i, j, good):  # derive C (good) or C' (not good) for (i, j); requires wins(i,j) == good
        key = (i, j, good)
        if key in memo:
            return memo[key]
        c = code(i, j)
        atom = CA(w, c) if good else CR(w, c)
        if i == j:
            k = add(atom, ("ax",))
        else:
            ex = ((n - 1) - (j - i)) % 2 == 0
            succ = [(i + 1, j), (i, j - 1)]
            one_suffices = ex if good else (not ex)
            if one_suffices:
                s = next(s for s in succ if wins(*s) == good)
                prem = der(*s, good)
                a1 = CA(w, code(*s)) if good else CR(w, code(*s))
                imp = add(f"I {a1} {atom}", ("ax",))
                k = mp(prem, imp)
            else:
                p1 = der(*succ[0], good)
                p2 = der(*succ[1], good)
                a1 = CA(w, code(*succ[0])) if good else CR(w, code(*succ[0]))
                a2 = CA(w, code(*succ[1])) if good else CR(w, code(*succ[1]))
                imp = add(f"I {a1} I {a2} {atom}", ("ax",))
                k = mp(p2, mp(p1, imp))
        memo[key] = k
        return k

    good = wins(0, n - 1)
    top = der(0, n - 1, good)
    c0 = code(0, n - 1)
    out = add(f"I {CA(w, c0)} R {w}.e" if good else f"I {CR(w, c0)} N R {w}.e", ("ax",))
    mp(top, out)
    return lines


# ---- the independent decider for A^O_M: parse, decode, check the game relation
def decode_theta(f):
    """theta_2(a, b) as a parsed formula -> (a_word, b_word) or None."""
    try:
        if f[0] != "A":
            return None
        v = f[1]
        g = f[2]
        assert g[0] == "I" and g[1] == ("Q", ("11", v), ("", v))
        g = g[2]
        assert g[0] == "I" and g[1][0] == "Q" and g[1][1] == ("0", v)
        a = g[1][2]
        g = g[2]
        assert g[0] == "I" and g[1][0] == "Q" and g[1][1] == ("01", v)
        b = g[1][2]
        assert g[2] == ("R", ("", v))
        assert a[1] == "e" and b[1] == "e"
        return a[0], b[0]
    except (AssertionError, IndexError, TypeError):
        return None


def member_AO(s, f):
    # split an implication chain into premises and conclusion
    prem = []
    g = f
    while g[0] == "I":
        prem.append(g[1])
        g = g[2]
    concl = g
    atoms = []
    for p in prem:
        d = decode_theta(p)
        if d is None:
            return False
        atoms.append(d)
    if concl[0] == "R" or (concl[0] == "N" and concl[1][0] == "R"):
        lit = concl if concl[0] == "R" else concl[1]
        if lit[1][1] != "e":
            return False
        w = lit[1][0]
        pos = concl[0] == "R"
        if len(atoms) != 1 or not w:
            return False
        a, b = atoms[0]
        n, m, code, wins = game(w)
        return a == w and b == ("0" if pos else "1") + code(0, n - 1)
    d = decode_theta(concl)
    if d is None:
        return False
    w, bc = d
    if not w or any(a != w for a, _ in atoms):
        return False
    n, m, code, wins = game(w)
    decode = {code(i, j): (i, j) for i in range(n) for j in range(i, n)}
    tag, c = bc[0], bc[1:]
    if c not in decode or any(b[0] != tag or b[1:] not in decode for _, b in atoms):
        return False
    good = tag == "0"
    i, j = decode[c]
    ps = [decode[b[1:]] for _, b in atoms]
    if i == j:
        return not ps and wins(i, j) == good
    ex = ((n - 1) - (j - i)) % 2 == 0
    succ = [(i + 1, j), (i, j - 1)]
    one_suffices = ex if good else (not ex)
    if one_suffices:
        return len(ps) == 1 and ps[0] in succ
    return ps == succ


def table_member(s, f):
    return s == "N R .e"


def U_truth(s):
    """Truth in U of a member of A^O_M, with theta_2(a,b) read as R(P(a,b)) (pairing lemma)."""
    f = HC.parse(s)

    def val(g):
        d = decode_theta(g)
        if d is not None:
            w, bc = d
            n, m, code, wins = game(w)
            decode = {code(i, j): (i, j) for i in range(n) for j in range(i, n)}
            c = bc[1:]
            if bc[0] not in "01" or c not in decode:
                return False
            return wins(*decode[c]) == (bc[0] == "0")
        if g[0] == "R":
            return in_X(g[1][0])
        if g[0] == "N":
            return not val(g[1])
        if g[0] == "I":
            return (not val(g[1])) or val(g[2])
        raise ValueError

    return val(f)


def all_members(w):
    n, m, code, wins = game(w)
    out = []
    for i in range(n):
        for j in range(i, n):
            c = code(i, j)
            if i == j:
                out.append(CA(w, c) if wins(i, j) else CR(w, c))
                continue
            ex = ((n - 1) - (j - i)) % 2 == 0
            s1, s2 = (i + 1, j), (i, j - 1)
            for good in (True, False):
                A = CA if good else CR
                if ex == good:
                    for s in (s1, s2):
                        out.append(f"I {A(w, code(*s))} {A(w, c)}")
                else:
                    out.append(f"I {A(w, code(*s1))} I {A(w, code(*s2))} {A(w, c)}")
    c0 = code(0, n - 1)
    out.append(f"I {CA(w, c0)} R {w}.e")
    out.append(f"I {CR(w, c0)} N R {w}.e")
    return out


def part_a():
    log("== Part A: ground pairing translation A^O_M of a fresh alternating machine (interval game) ==")
    ok = True
    bad = 0
    maxline = {}
    nlines = 0
    for w in words(1, 10):
        lines = derive_game(w)
        res, msg, parsed = HC.check(lines, member_AO)
        want = HC.parse(f"R {w}.e" if in_X(w) else f"N R {w}.e")
        if not res or parsed[-1] != want or any(j[0] not in ("ax", "MP") for _, j in lines):
            bad += 1
        nlines = max(nlines, len(lines))
        maxline[len(w)] = max(maxline.get(len(w), 0), max(HC.size(g) for g in parsed))
    log(f"  MP-only derivations of all {2 ** 11 - 2} data with 1 <= |w| <= 10, checked against the parsing decider: "
        f"invalid {bad}; max lines {nlines}")
    log("  largest line by |w|: " + ", ".join(f"{k}:{v}" for k, v in sorted(maxline.items())))
    ok &= bad == 0
    # the empty word: a table literal
    res, msg, parsed = HC.check([("N R .e", ("ax",))], table_member)
    ok &= res
    nm = nf = 0
    for w in words(1, 7):
        for s in all_members(w):
            nm += 1
            if not member_AO(s, HC.parse(s)):
                nf += 1
            if not U_truth(s):
                nf += 1
    log(f"  members of A^O_M with 1 <= |w| <= 7: {nm}; rejected by the decider or false in U: {nf}")
    ok &= nf == 0
    # negative controls
    w = next(w for w in words(3, 6) if in_X(w))
    n, m, code, wins = game(w)
    wrong = f"I {CA(w, code(0, n - 1))} N R {w}.e"
    rej = not member_AO(wrong, HC.parse(wrong))
    false = not U_truth(wrong)
    lines = derive_game(w)
    k = max(i for i, (s, j) in enumerate(lines) if j[0] == "ax" and s.startswith("I "))
    toks = lines[k][0].split(" ")
    j = next(j for j, t in enumerate(toks) if t.startswith("0") and t.endswith(".e") and len(t) > 3 and j > 10)
    toks[j] = toks[j][:-3] + ("1" if toks[j][-3] == "0" else "0") + ".e"
    bad_lines = list(lines)
    bad_lines[k] = (" ".join(toks), lines[k][1])
    r2, msg2, _ = HC.check(bad_lines, member_AO)
    log(f"  wrong output axiom (w = {w} in X, C(init) -> ~R): rejected by the decider {rej}, false in U {false}; "
        f"derivation with a corrupted axiom rejected: {not r2} ({msg2})")
    ok &= rej and false and (not r2)
    return ok


# ======================================================================================== Part B
# Alternating one-tape machine for Y = {w : every 1 has a 0 to its right}.  Layout '#' x, head on '#'.
# delta[(q, a)] = list of successor moves (q2, b, d); kind[q] in {'E', 'U'}.
def alt_machine():
    G = ["#", "0", "1", "B"]
    d = {}
    kind = {}
    d[("q0", "#")] = [("scan", "#", "R")]
    kind["q0"] = "E"
    for a in ("0", "1"):
        d[("scan", a)] = [("chk" + a, a, "S"), ("scan", a, "R")]   # universal branching
    d[("scan", None)] = [("ACC", "B", "S")]
    kind["scan"] = "U"
    d[("chk0", "0")] = [("ACC", "0", "S")]
    d[("chk1", "1")] = [("srch", "1", "R")]
    kind["chk0"] = kind["chk1"] = "E"
    d[("srch", "0")] = [("ACC", "0", "S")]
    d[("srch", "1")] = [("srch", "1", "R")]
    d[("srch", None)] = [("REJ", "B", "S")]
    kind["srch"] = "E"
    states = ["q0", "scan", "chk0", "chk1", "srch", "ACC", "REJ"]
    return G, states, d, kind


def spec_Y(x):
    return all("0" in x[i + 1:] for i, a in enumerate(x) if a == "1")


def compile_alt(G, states, d, kind):
    allst = ["s", "s2", "s3"] + states
    kq = max(1, (len(allst) - 1).bit_length())
    code = {q: format(i, "0%db" % kq) for i, q in enumerate(allst)}
    kb = max(1, (len(G) - 1).bit_length())
    beta = {a: format(i, "0%db" % kb) for i, a in enumerate(G)}
    rules = []   # (cur_pattern, [next_patterns], conj)  conj=True: all premises needed
    for tag in "01":
        c = lambda q: tag + code[q]  # noqa: E731
        rules.append((("", True, c("s"), True), [("", True, c("s2") + beta["#"], True)], True))
        for a in "01":
            rules.append(((a, True, c("s2"), True), [("", True, c("s2") + beta[a], True)], True))
        rules.append((("", False, c("s2"), True), [("", False, c("s3"), True)], True))
        for a in ("#", "0", "1"):
            rules.append((("", True, c("s3") + beta[a], True), [(beta[a], True, c("s3"), True)], True))
        rules.append((("", True, c("s3"), False), [("", True, c("q0"), False)], True))
        for (q, a), succs in d.items():
            rp, rv = ("", False) if a is None else (beta[a], True)
            # existential: one premise suffices for acceptance; universal: all.  Dual for rejection.
            conj_acc = kind[q] == "U"
            conj = conj_acc if tag == "0" else (not conj_acc)
            left = any(dd == "L" for _, _, dd in succs)
            nbs = [(beta[cc], True) for cc in G] + [("", False)] if left else [("", True)]
            for nb, lv in nbs:
                cur = (rp, rv, c(q) + nb, lv)
                nxts = []
                for q2, b, dd in succs:
                    if dd == "R":
                        nxts.append(("", rv, c(q2) + beta[b] + nb, lv))
                    elif dd == "S":
                        nxts.append((beta[b], rv, c(q2) + nb, lv))
                    else:
                        nxts.append(((nb + beta[b]) if lv else beta[b], rv, c(q2), lv))
                if conj or len(nxts) == 1:
                    rules.append((cur, nxts, True))
                else:
                    for nx in nxts:
                        rules.append((cur, [nx], True))
    return dict(rules=rules, code=code, beta=beta, kq=kq)


def compat(p1, v1, p2, v2):
    if v1 and v2:
        return p1.startswith(p2) or p2.startswith(p1)
    if v1:
        return p2.startswith(p1)
    if v2:
        return p1.startswith(p2)
    return p1 == p2


def matches(pat, cfg):
    rp, rv, lp, lv = pat
    r, l = cfg
    if (rv and not r.startswith(rp)) or (not rv and r != rp):
        return None
    if (lv and not l.startswith(lp)) or (not lv and l != lp):
        return None
    return (r[len(rp):] if rv else None), (l[len(lp):] if lv else None)


def build(pat, Z, Y):
    return (pat[0] + (Z if pat[1] else ""), pat[2] + (Y if pat[3] else ""))


def accepts(prog, cfg, tag, memo):
    """Least fixed point: cfg is in C iff it is halting with the right state, or some rule with this cur
    pattern has all its premises in C."""
    goal = tag + prog["code"]["ACC" if tag == "0" else "REJ"]
    if cfg in memo:
        return memo[cfg]
    memo[cfg] = None  # cycle guard (the machines here are acyclic on valid configurations)
    if cfg[1].startswith(goal):
        memo[cfg] = (True, None)
        return memo[cfg]
    res = (False, None)
    for i, (cur, nxts, _) in enumerate(prog["rules"]):
        m = matches(cur, cfg)
        if m is None:
            continue
        subs = [build(nx, *m) for nx in nxts]
        if all(accepts(prog, s, tag, memo) and accepts(prog, s, tag, memo)[0] for s in subs):
            res = (True, (i, m, subs))
            break
    memo[cfg] = res
    return res


def pattern_terms(pat):
    return f"{pat[0]}.{'Z' if pat[1] else 'e'}", f"{pat[2]}.{'Y' if pat[3] else 'e'}"


def make_theory(prog, obs):
    def atom(r, l):
        return theta2(r, l) if obs else f"C {r} {l}"

    def stdf(t):
        return f"N Q 11{t} {t}"

    def wrap(vs, body):
        if obs:
            for v in reversed(vs):
                body = f"I {stdf('.' + v)} {body}"
        for v in reversed(vs):
            body = f"A {v} {body}"
        return body

    sent = []
    for cur, nxts, _ in prog["rules"]:
        vs = [v for v, has in (("Z", cur[1]), ("Y", cur[3])) if has]
        body = atom(*pattern_terms(cur))
        for nx in reversed(nxts):
            body = f"I {atom(*pattern_terms(nx))} {body}"
        sent.append(wrap(vs, body))
    code = prog["code"]
    halt = {t: wrap(["Z", "Y"], atom(".Z", f"{t}{code['ACC' if t == '0' else 'REJ']}.Y")) for t in "01"}
    out = {}
    for t, concl in (("0", "R .x"), ("1", "N R .x")):
        body = f"I {atom('.x', t + code['s'] + '.e')} {concl}"
        if obs:
            body = f"I {stdf('.x')} {body}"
        out[t] = f"A x {body}"
    stdax = [stdf(".e"), f"A y I {stdf('.y')} {stdf('0.y')}", f"A y I {stdf('.y')} {stdf('1.y')}"] if obs else []
    return dict(sent=sent, halt=halt, out=out, std=stdax, obs=obs,
                members=set(sent) | set(halt.values()) | set(out.values()) | set(stdax))


def gsub(s, v, word):
    return " ".join((t.split(".")[0] + word + ".e") if ("." in t and t.split(".")[1] == v) else t
                    for t in s.split(" "))


def derive_alt(prog, th, x):
    tag = "0" if spec_Y(x) else "1"
    memo = {}
    start = (x, tag + prog["code"]["s"])
    ok, _ = accepts(prog, start, tag, memo)
    assert ok
    lines, axidx, stdidx, done = [], {}, {}, {}

    def add(s, j):
        lines.append((s, j))
        return len(lines) - 1

    def ax(s):
        if s not in axidx:
            axidx[s] = add(s, ("ax",))
        return axidx[s]

    def mp(i, j):
        s, a = lines[j][0], lines[i][0]
        assert s.startswith("I " + a + " ")
        return add(s[len(a) + 3:], ("MP", i, j))

    def inst(i, word):
        s = lines[i][0]
        _, v, body = s.split(" ", 2)
        return mp(i, add(f"I {s} {gsub(body, v, word)}", ("A4",)))

    def std(word):
        if word not in stdidx:
            if word == "":
                stdidx[word] = ax(th["std"][0])
            else:
                p = std(word[1:])
                stdidx[word] = mp(p, inst(ax(th["std"][1 if word[0] == "0" else 2]), word[1:]))
        return stdidx[word]

    def use(s, vals):
        i = ax(s)
        for v in vals:
            i = inst(i, v)
        if th["obs"]:
            for v in vals:
                i = mp(std(v), i)
        return i

    def der(cfg):
        if cfg in done:
            return done[cfg]
        acc, how = memo[cfg]
        assert acc
        if how is None:
            hp = ("", True, tag + prog["code"]["ACC" if tag == "0" else "REJ"], True)
            Z, Y = matches(hp, cfg)
            k = use(th["halt"][tag], [Z, Y])
        else:
            ri, (Z, Y), subs = how
            prem = [der(s) for s in subs]
            k = use(th["sent"][ri], [v for v in (Z, Y) if v is not None])
            for p in prem:
                k = mp(p, k)
        done[cfg] = k
        return k

    top = der(start)
    o = ax(th["out"][tag])
    o = inst(o, x)
    if th["obs"]:
        o = mp(std(x), o)
    mp(top, o)
    return lines, tag


def part_b():
    log("== Part B: finite alternating two-stack theories (reading (a1)) ==")
    ok = True
    G, S, d, kind = alt_machine()
    prog = compile_alt(G, S, d, kind)
    R = prog["rules"]
    # disjointness across rules that come from different (state, symbol, neighbour) cases
    curs = sorted({r[0] for r in R})
    overl = 0
    for i in range(len(curs)):
        for j in range(i + 1, len(curs)):
            a, b = curs[i], curs[j]
            if compat(a[0], a[1], b[0], b[1]) and compat(a[2], a[3], b[2], b[3]):
                overl += 1
    log(f"  {len(R)} rules, {len(curs)} distinct current patterns, overlapping distinct patterns {overl}")
    ok &= overl == 0
    bad = 0
    for x in words(0, 9):
        a0 = accepts(prog, (x, "0" + prog["code"]["s"]), "0", {})[0]
        a1 = accepts(prog, (x, "1" + prog["code"]["s"]), "1", {})[0]
        if a0 != spec_Y(x) or a1 != (not spec_Y(x)):
            bad += 1
    log(f"  alternating acceptance of start(x) (tag 0) and rejection (tag 1) against the specification, |x| <= 9: "
        f"mismatches {bad}")
    ok &= bad == 0
    for obs in (False, True):
        th = make_theory(prog, obs)
        name = "theta_2/Std version" if obs else "relation version"
        sizes = [HC.size(HC.parse(s)) for s in th["members"]]
        nbad = 0
        maxl = {}
        nl = 0
        for x in words(0, 7):
            lines, tag = derive_alt(prog, th, x)
            res, msg, parsed = HC.check(lines, lambda s, f: s in th["members"])
            want = HC.parse(f"R {x}.e" if tag == "0" else f"N R {x}.e")
            if not res or parsed[-1] != want:
                nbad += 1
                if nbad <= 2:
                    log(f"    FAIL x={x}: {msg}")
            maxl[len(x)] = max(maxl.get(len(x), 0), max(HC.size(f) for f in parsed))
            nl = max(nl, len(lines))
        log(f"  {name}: {len(th['members'])} sentences (largest {max(sizes)}); derivations of all 255 data with "
            f"|x| <= 7 invalid {nbad}; max lines {nl}")
        log("    largest line (every instance, logical included) by |x|: "
            + ", ".join(f"{k}:{v}" for k, v in sorted(maxl.items())))
        ok &= nbad == 0
    return ok


def main():
    log("t3_alternating.py -- reading (a1): ground pairing translation and finite alternating theories")
    ok = part_a()
    ok &= part_b()
    log("")
    log("all checks passed" if ok else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
