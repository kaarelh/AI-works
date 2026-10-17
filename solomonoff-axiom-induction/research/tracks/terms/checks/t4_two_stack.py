#!/usr/bin/env python3
"""t4_two_stack.py -- one binary theoretical relation over the named objects, and its observational translation.

Record: notes.md, Section 4 (Definition 4.4, Lemma 4.5 (compilation), Theorem 4.6(i) (one binary relation),
Theorem 4.6(ii) (observational translation via theta_2), Lemma 4.2 (pairing), Remark 4.8 (relativisation)).

Words are strings over {0,1}; the closed term t_w is the word w read from the outside in.
A configuration of a two-stack program is a pair (r, l) of words; l starts with a tag letter (0 = acceptance
run, 1 = rejection run) and a fixed-length state code; tape cells are fixed-length blocks.  Rules are
prefix rewritings current -> next; the theory states them BACKWARDS:  forall Z forall Y (C(next) -> C(current)).
Halting axioms: forall Z forall Y C(Z, 0 code(acc) Y) and forall Z forall Y C(Z, 1 code(rej) Y).
Output axioms:  forall x forall z (C(x, 0 code(s) z) -> R(x)),  forall x forall z (C(x, 1 code(s) z) -> ~R(x)).

Parts.
  A. Compile two one-tape machines: EQ (decider for #0 = #1, crossing-out algorithm) and VER (a verifier with
     certificates: accept iff 1 <= |z| <= |x| and x has a 1 at position |z|-1; reject iff z is empty and x is
     in 0*).  Check: linearity of the rules (the same variables on both sides), pairwise disjointness of the
     current-patterns (symbolically, which is determinism on ALL pairs of words), no rule applies in a halting
     state.  Check the semantics: from start(x, z) the forward run reaches 0-tagged acc / 1-tagged rej exactly as
     the specification says (EQ: all |x| <= 10, |z| <= 3; VER: all |x| <= 6, |z| <= 5).
  B. Relation version (language {e,s0,s1,R,C}): Hilbert derivations (theory axioms, A4, MP) of every datum
     R(t_w)^{[w in X]} with |w| <= 8 for EQ and |w| <= 6 for VER (certificate chosen by the generator),
     checked by the independent checker hilbert_check.py.  Sizes.
  C. Observational version (language {e,s0,s1,R}): C(a,b) replaced by
        theta_2(a,b) := forall w (s1 s1 w = w -> (s0 w = a -> (s0 s1 w = b -> R(w)))),
     every rule variable relativised to Std(y) := ~(s1 s1 y = y), plus Std(e) and Std(y) -> Std(s_a y).
     Derivations of every datum with |w| <= 8 (EQ) and |w| <= 5 (VER), checked.  Pairing lemma on a fragment of
     the model U (words plus formal pairs, s0 P(a,b) = a, s1 P(a,b) = P(b,a)).
  D. Negative controls: corrupted derivations are rejected; a corrupted machine (one transition redirected to
     acc) is caught by the semantic check; without relativisation some rule instance with pair-element values
     is false in U (so Std is needed), while with Std no counterexample exists among the same instances.

Deterministic (no randomness).  Writes t4_two_stack.out next to itself.
"""
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hilbert_check as HC  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "t4_two_stack.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


def words(maxlen):
    for n in range(maxlen + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


# ----------------------------------------------------------------------------------------------------------
# One-tape machines (normal form: never write a blank; moving left at cell 0 stays).
# delta[(q, a)] = (q2, b, d) with a a tape symbol or None (blank), b a tape symbol, d in 'LSR'.
# ----------------------------------------------------------------------------------------------------------

def eq_machine():
    G = ["#", "0", "1", "X", "B", "Z0", "Z1"]
    d = {}
    for a in ("Z0", "Z1"):
        d[("q0", a)] = ("q0", a, "R")
    d[("q0", "#")] = ("qscan", "#", "R")
    d[("qscan", "0")] = ("qf1", "X", "R")
    d[("qscan", "1")] = ("qf0", "X", "R")
    d[("qscan", "X")] = ("qscan", "X", "R")
    d[("qscan", None)] = ("ACC", "B", "S")
    for a in ("0", "X"):
        d[("qf1", a)] = ("qf1", a, "R")
    d[("qf1", "1")] = ("qback", "X", "L")
    d[("qf1", None)] = ("REJ", "B", "S")
    for a in ("1", "X"):
        d[("qf0", a)] = ("qf0", a, "R")
    d[("qf0", "0")] = ("qback", "X", "L")
    d[("qf0", None)] = ("REJ", "B", "S")
    for a in ("0", "1", "X"):
        d[("qback", a)] = ("qback", a, "L")
    d[("qback", "#")] = ("qscan", "#", "R")
    states = ["q0", "qscan", "qf1", "qf0", "qback", "ACC", "REJ"]
    return G, states, d


def eq_spec(x, z):
    return "acc" if x.count("0") == x.count("1") else "rej"


def ver_machine():
    """Layout z_m ... z_1 # x_1 ... x_n (certificate reversed), head at cell 0."""
    G = ["#", "0", "1", "B", "Z0", "Z1", "ZM", "XM0", "XM1"]
    d = {}
    d[("q0", "#")] = ("e1", "#", "R")          # empty certificate: rejection mode
    for a in ("Z0", "Z1"):
        d[("q0", a)] = ("tox", "ZM", "R")      # mark the first certificate cell
    d[("e1", "0")] = ("e1", "0", "R")
    d[("e1", "1")] = ("BOT", "1", "S")
    d[("e1", None)] = ("REJ", "B", "S")
    # tox: move right to '#', then to the first unmarked input cell
    for a in ("Z0", "Z1", "ZM"):
        d[("tox", a)] = ("tox", a, "R")
    d[("tox", "#")] = ("fx", "#", "R")
    for a in ("XM0", "XM1"):
        d[("fx", a)] = ("fx", a, "R")
    d[("fx", "0")] = ("back", "XM0", "L")
    d[("fx", "1")] = ("back", "XM1", "L")
    d[("fx", None)] = ("BOT", "B", "S")
    # back: move left to the last marked certificate cell, then one step right
    for a in ("XM0", "XM1", "#", "Z0", "Z1"):
        d[("back", a)] = ("back", a, "L")
    d[("back", "ZM")] = ("mk", "ZM", "R")
    # mk: next certificate cell, or '#' when all are marked
    for a in ("Z0", "Z1"):
        d[("mk", a)] = ("tox", "ZM", "R")
    d[("mk", "#")] = ("ck", "#", "R")
    for a in ("XM0", "XM1"):
        d[("ck", a)] = ("ck", a, "R")
    for a in ("0", "1"):
        d[("ck", a)] = ("ck2", a, "L")
    d[("ck", None)] = ("ck2", "B", "L")
    d[("ck2", "XM1")] = ("ACC", "XM1", "S")
    d[("ck2", "XM0")] = ("BOT", "XM0", "S")
    states = ["q0", "e1", "tox", "fx", "back", "mk", "ck", "ck2", "ACC", "REJ", "BOT"]
    return G, states, d


def ver_spec(x, z):
    if len(z) == 0:
        return "rej" if set(x) <= {"0"} else "bot"
    if len(z) <= len(x) and x[len(z) - 1] == "1":
        return "acc"
    return "bot"


# ----------------------------------------------------------------------------------------------------------
# Compilation into a two-stack program (Lemma 4.5).
# A pattern is (r_prefix, r_has_var, l_prefix, l_has_var); a rule is (current_pattern, next_pattern).
# ----------------------------------------------------------------------------------------------------------

def bits(i, k):
    return format(i, "0%db" % k)


def compile_machine(G, states, delta):
    phase = ["s", "s0", "s1", "s2", "s3"]
    allstates = phase + states
    kq = max(1, (len(allstates) - 1).bit_length())
    code = {q: bits(i, kq) for i, q in enumerate(allstates)}
    kb = max(1, (len(G) - 1).bit_length())
    beta = {a: bits(i, kb) for i, a in enumerate(G)}
    rules = []
    for tag in "01":
        c = lambda q: tag + code[q]  # noqa: E731
        # start: push '#' on r
        rules.append((("", True, c("s"), True), (beta["#"], True, c("s0"), True), "start"))
        # phase 0: certificate letters (raw, on l below the state) -> blocks on r
        for a in "01":
            rules.append((("", True, c("s0") + a, True), (beta["Z" + a], True, c("s0"), True), "p0"))
        rules.append((("", True, c("s0"), False), ("", True, c("s1"), False), "p0end"))
        # phase 1: move right over the certificate blocks to '#'
        for a in ("Z0", "Z1"):
            rules.append(((beta[a], True, c("s1"), True), ("", True, c("s1") + beta[a], True), "p1"))
        rules.append(((beta["#"], True, c("s1"), True), ("", True, c("s2") + beta["#"], True), "p1end"))
        # phase 2: convert the raw input letters
        for a in "01":
            rules.append(((a, True, c("s2"), True), ("", True, c("s2") + beta[a], True), "p2"))
        rules.append((("", False, c("s2"), True), ("", False, c("s3"), True), "p2end"))
        # phase 3: rewind to the left end
        for a in ("Z0", "Z1", "#", "0", "1"):
            rules.append((("", True, c("s3") + beta[a], True), (beta[a], True, c("s3"), True), "p3"))
        rules.append((("", True, c("s3"), False), ("", True, c("q0"), False), "p3end"))
        # the machine
        for (q, a), (q2, b, d) in delta.items():
            if a is None:
                rp, rv = "", False
            else:
                rp, rv = beta[a], True
            if d == "R":
                rules.append(((rp, rv, c(q), True), ("", rv, c(q2) + beta[b], True), "M"))
            elif d == "S":
                rules.append(((rp, rv, c(q), True), (beta[b], rv, c(q2), True), "M"))
            else:
                for cc in G:
                    rules.append(((rp, rv, c(q) + beta[cc], True), (beta[cc] + beta[b], rv, c(q2), True), "M"))
                rules.append(((rp, rv, c(q), False), (beta[b], rv, c(q2), False), "M"))
    return dict(rules=rules, code=code, beta=beta, kq=kq, kb=kb)


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
    if rv:
        if not r.startswith(rp):
            return None
        Z = r[len(rp):]
    else:
        if r != rp:
            return None
        Z = None
    if lv:
        if not l.startswith(lp):
            return None
        Y = l[len(lp):]
    else:
        if l != lp:
            return None
        Y = None
    return Z, Y


def build(pat, Z, Y):
    rp, rv, lp, lv = pat
    return (rp + (Z if rv else ""), lp + (Y if lv else ""))


def rule_index(prog):
    if "index" not in prog:
        idx = {}
        k = 1 + prog["kq"]
        for i, (cur, _, _) in enumerate(prog["rules"]):
            assert len(cur[2]) >= k
            idx.setdefault(cur[2][:k], []).append(i)
        prog["index"] = idx
    return prog["index"]


def step(prog, cfg):
    cand = rule_index(prog).get(cfg[1][:1 + prog["kq"]], [])
    hits = [(i, m) for i in cand for m in [matches(prog["rules"][i][0], cfg)] if m is not None]
    if len(hits) > 1:
        raise RuntimeError("nondeterminism")
    if not hits:
        return None, None
    i, (Z, Y) = hits[0]
    return i, build(prog["rules"][i][1], Z, Y)


def run(prog, x, z, tag, maxsteps=200000):
    return run_from(prog, (x, tag + prog["code"]["s"] + z), tag, maxsteps)


def run_from(prog, cfg, tag, maxsteps=200000):
    trace = [cfg]
    used = []
    goal = tag + prog["code"]["ACC" if tag == "0" else "REJ"]
    for _ in range(maxsteps):
        if cfg[1].startswith(goal):
            return "halt", trace, used
        i, nxt = step(prog, cfg)
        if nxt is None:
            return "stuck", trace, used
        used.append(i)
        cfg = nxt
        trace.append(cfg)
    return "timeout", trace, used


def static_checks(prog, name):
    R = prog["rules"]
    nonlinear = sum(1 for cur, nxt, _ in R if (cur[1], cur[3]) != (nxt[1], nxt[3]))
    overlaps = 0
    for i in range(len(R)):
        for j in range(i + 1, len(R)):
            a, b = R[i][0], R[j][0]
            if compat(a[0], a[1], b[0], b[1]) and compat(a[2], a[3], b[2], b[3]):
                overlaps += 1
    halting_hits = 0
    for tag, h in (("0", "ACC"), ("1", "REJ"), ("0", "REJ"), ("1", "ACC")):
        hp = tag + prog["code"][h]
        for cur, _, _ in R:
            if compat(cur[2], cur[3], hp, True):
                halting_hits += 1
    log(f"  {name}: {len(R)} rules (both tags), state code length {prog['kq']}, block length {prog['kb']}; "
        f"non-linear rules {nonlinear}; overlapping current-patterns {overlaps}; rules applicable in a halting state "
        f"{halting_hits}")
    return nonlinear == 0 and overlaps == 0 and halting_hits == 0


def semantic_check(prog, spec, xmax, zmax, name):
    bad = 0
    total = 0
    maxsteps = 0
    for x in words(xmax):
        for z in words(zmax):
            want = spec(x, z)
            r0, tr0, _ = run(prog, x, z, "0")
            r1, tr1, _ = run(prog, x, z, "1")
            maxsteps = max(maxsteps, len(tr0), len(tr1))
            got_acc = r0 == "halt"
            got_rej = r1 == "halt"
            if got_acc != (want == "acc") or got_rej != (want == "rej") or "timeout" in (r0, r1):
                bad += 1
            total += 1
    log(f"  {name}: {total} (x, z) pairs with |x| <= {xmax}, |z| <= {zmax}; acc-run reaches ACC iff spec = acc and "
        f"rej-run reaches REJ iff spec = rej: mismatches {bad}; longest run {maxsteps} configurations")
    return bad


# ----------------------------------------------------------------------------------------------------------
# Theories and derivations.  Formulas as strings in hilbert_check's prefix syntax.
# ----------------------------------------------------------------------------------------------------------

def T(word, base):
    return f"{word}.{base}"


def theta2(a, b):
    return f"A w I Q 11.w .w I Q 0.w {a} I Q 01.w {b} R .w"


def std_term(word, base):
    # Std(s_word(base)) := ~(s1 s1 s_word(base) = s_word(base))
    return f"N Q 11{word}.{base} {word}.{base}"


class Theory:
    def __init__(self, prog, observational):
        self.prog = prog
        self.obs = observational
        self.rule_sent = []
        for cur, nxt, _ in prog["rules"]:
            self.rule_sent.append(self._rule(cur, nxt))
        code = prog["code"]
        self.halt0 = self._fact(("", True, "0" + code["ACC"], True))
        self.halt1 = self._fact(("", True, "1" + code["REJ"], True))
        self.out0 = self._out("0" + code["s"], "R .x")
        self.out1 = self._out("1" + code["s"], "N R .x")
        self.std_ax = []
        if observational:
            self.std_ax = [std_term("", "e"),
                           "A y I " + std_term("", "y") + " " + std_term("0", "y"),
                           "A y I " + std_term("", "y") + " " + std_term("1", "y")]
        self.members = set(self.rule_sent + [self.halt0, self.halt1, self.out0, self.out1] + self.std_ax)

    def atom(self, rterm, lterm):
        return theta2(rterm, lterm) if self.obs else f"C {rterm} {lterm}"

    def _vars(self, pat):
        vs = []
        if pat[1]:
            vs.append("Z")
        if pat[3]:
            vs.append("Y")
        return vs

    def _pt(self, pat):
        rt = T(pat[0], "Z" if pat[1] else "e")
        lt = T(pat[2], "Y" if pat[3] else "e")
        return rt, lt

    def _wrap(self, vs, body):
        if self.obs:
            for v in reversed(vs):
                body = "I " + std_term("", v) + " " + body
        for v in reversed(vs):
            body = f"A {v} " + body
        return body

    def _rule(self, cur, nxt):
        vs = self._vars(cur)
        a = self.atom(*self._pt(nxt))
        b = self.atom(*self._pt(cur))
        return self._wrap(vs, f"I {a} {b}")

    def _fact(self, pat):
        return self._wrap(self._vars(pat), self.atom(*self._pt(pat)))

    def _out(self, lprefix, concl):
        body = f"I {self.atom('.x', T(lprefix, 'z'))} {concl}"
        if self.obs:
            body = "I " + std_term("", "x") + " I " + std_term("", "z") + " " + body
        return "A x A z " + body


def strip_all(s):
    """'A v F' -> (v, F) on strings (the generator's own helper)."""
    assert s.startswith("A ")
    _, v, rest = s.split(" ", 2)
    return v, rest


def gsubst(s, v, word):
    """Generator-side substitution of t_word for the free variable v (variables here are never rebound)."""
    toks = s.split(" ")
    out = []
    for t in toks:
        if "." in t:
            w, b = t.split(".")
            if b == v:
                t = f"{w}{word}.e"
        out.append(t)
    return " ".join(out)


class Deriver:
    def __init__(self, th):
        self.th = th
        self.lines = []
        self.index = {}
        self.std_done = {}

    def add(self, s, just):
        self.lines.append((s, just))
        return len(self.lines) - 1

    def ax(self, s):
        if s in self.index:
            return self.index[s]
        i = self.add(s, ("ax",))
        self.index[s] = i
        return i

    def mp(self, i, j):
        s_imp = self.lines[j][0]
        assert s_imp.startswith("I ")
        # the consequent: strip "I " + antecedent + " "
        ante = self.lines[i][0]
        assert s_imp[2:2 + len(ante)] == ante and s_imp[2 + len(ante)] == " "
        return self.add(s_imp[3 + len(ante):], ("MP", i, j))

    def inst(self, i, word):
        """From line i = 'A v F', derive F[t_word/v] by A4 and MP."""
        v, body = strip_all(self.lines[i][0])
        a4 = self.add(f"I {self.lines[i][0]} {gsubst(body, v, word)}", ("A4",))
        return self.mp(i, a4)

    def std(self, word):
        if word in self.std_done:
            return self.std_done[word]
        if word == "":
            k = self.ax(self.th.std_ax[0])
        else:
            prev = self.std(word[1:])
            prop = self.ax(self.th.std_ax[1 if word[0] == "0" else 2])
            imp = self.inst(prop, word[1:])
            k = self.mp(prev, imp)
        self.std_done[word] = k
        return k

    def use(self, sent, values):
        """Instantiate the sentence's leading quantifiers by `values` (and discharge Std premises)."""
        i = self.ax(sent)
        for w in values:
            i = self.inst(i, w)
        if self.th.obs:
            for w in values:
                i = self.mp(self.std(w), i)
        return i


def derive_datum(th, x, z, tag):
    prog = th.prog
    res, trace, used = run(prog, x, z, tag)
    assert res == "halt"
    D = Deriver(th)
    # the halting fact at the last configuration
    r_last, l_last = trace[-1]
    hp = ("", True, tag + prog["code"]["ACC" if tag == "0" else "REJ"], True)
    Z, Y = matches(hp, trace[-1])
    cur = D.use(th.halt0 if tag == "0" else th.halt1, [Z, Y])
    for k in range(len(used) - 1, -1, -1):
        ri = used[k]
        cpat = prog["rules"][ri][0]
        Z, Y = matches(cpat, trace[k])
        vals = [v for v in (Z, Y) if v is not None]
        imp = D.use(th.rule_sent[ri], vals)
        cur = D.mp(cur, imp)
    out = D.use(th.out0 if tag == "0" else th.out1, [x, z])
    last = D.mp(cur, out)
    return D.lines, last


def check_derivations(th, cases, name):
    members = th.members
    bad = 0
    maxlines = maxline = maxmat_nl = maxmat = 0
    for x, z, tag in cases:
        lines, last = derive_datum(th, x, z, tag)
        ok, msg, parsed = HC.check(lines, lambda s, f: s in members)
        want = HC.parse(f"R {x}.e" if tag == "0" else f"N R {x}.e")
        if not ok or parsed[-1] != want:
            bad += 1
            if bad <= 3:
                log(f"    FAIL {name} x={x} z={z}: {msg}")
            continue
        maxlines = max(maxlines, len(lines))
        maxline = max(maxline, max(HC.size(f) for f in parsed))
        inst = {lines[i][0] for i in range(len(lines)) if lines[i][1][0] in ("ax", "A4")}
        maxmat = max(maxmat, sum(HC.size(HC.parse(s)) for s in inst))
        nl = {lines[i][0] for i in range(len(lines)) if lines[i][1][0] == "ax"}
        maxmat_nl = max(maxmat_nl, sum(HC.size(HC.parse(s)) for s in nl))
    log(f"  {name}: {len(cases)} data, invalid or wrong-literal derivations {bad}; max lines {maxlines}, "
        f"max line size {maxline}, max material {maxmat}, max nonlogical material {maxmat_nl}")
    return bad


def theory_stats(th, name):
    sizes = [HC.size(HC.parse(s)) for s in th.members]
    log(f"  {name}: {len(th.members)} sentences, largest {max(sizes)} symbols, total {sum(sizes)} symbols; "
        f"every sentence parses: yes")


# ----------------------------------------------------------------------------------------------------------
# The model U (words and formal pairs) for the pairing lemma and the relativisation control.
# ----------------------------------------------------------------------------------------------------------

def U_s(a, x):
    if isinstance(x, str):
        return a + x
    return x[0] if a == "0" else (x[1], x[0])


def U_apply(word, x):
    for a in reversed(word):
        x = U_s(a, x)
    return x


def U_pair(x):
    return U_apply("11", x) == x


def pairing_lemma_check():
    base = list(words(3))
    frag = list(base)
    pairs1 = [(a, b) for a in base for b in base]
    frag += pairs1
    frag += [(a, p) for a in base[:7] for p in pairs1[:40]] + [(p, a) for a in base[:7] for p in pairs1[:40]]
    bad_pair = sum(1 for z in frag if U_pair(z) != isinstance(z, tuple))
    bad_eq = 0
    n = 0
    small = base[:7] + pairs1[:20]
    for a in small:
        for b in small:
            for z in frag:
                prem = U_pair(z) and U_s("0", z) == a and U_apply("01", z) == b
                if prem != (z == (a, b)):
                    bad_eq += 1
                n += 1
    log(f"  pairing lemma on a fragment of U ({len(frag)} elements): Pair holds exactly on pairs: violations "
        f"{bad_pair}; <z = (a,b)> iff z = P(a,b): {n} triples, violations {bad_eq}")
    return bad_pair + bad_eq


def relativisation_control(prog):
    """Evaluate the tag-0 rules and the tag-0 halting axiom in U, with R(P(u, v)) := [(u, v) in C^T] for words
    u, v (C^T = tuples whose forward run reaches a 0-tagged ACC configuration) and R false on other pairs.
    Values of Z, Y: words of length <= 2 (relativised instances) and pairs of words of length <= 1 (instances
    that Std excludes).  Count false instances of each kind."""
    cache = {}
    acc = "0" + prog["code"]["ACC"]
    timeouts = [0]

    def inC(r, l):
        if not (isinstance(r, str) and isinstance(l, str)):
            return False
        key = (r, l)
        if key in cache:
            return cache[key]
        cfg, seen, res = key, set(), False
        for _ in range(20000):
            if cfg[1].startswith(acc):
                res = True
                break
            if cfg in seen:
                break
            seen.add(cfg)
            _, nxt = step(prog, cfg)
            if nxt is None:
                break
            cfg = nxt
        else:
            timeouts[0] += 1
        cache[key] = res
        return res

    def ev(pat, Z, Y):
        r = U_apply(pat[0], Z) if pat[1] else pat[0]
        l = U_apply(pat[2], Y) if pat[3] else pat[2]
        return r, l

    wv = list(words(2))
    pv = [(a, b) for a in words(1) for b in words(1)]
    false_rel = false_unrel = n_rel = n_unrel = 0
    example = None
    items = [(cur, nxt) for cur, nxt, _ in prog["rules"] if cur[2][0] == "0"]
    items.append((None, ("", True, acc, True)))  # the halting axiom: forall Z Y C(Z, acc Y)
    for cur, nxt in items:
        pat = nxt
        Zs = (wv + pv) if pat[1] else [None]
        Ys = (wv + pv) if pat[3] else [None]
        for Z in Zs:
            for Y in Ys:
                if cur is None:
                    true = inC(*ev(nxt, Z, Y))
                else:
                    true = (not inC(*ev(nxt, Z, Y))) or inC(*ev(cur, Z, Y))
                rel = not isinstance(Z, tuple) and not isinstance(Y, tuple)
                if rel:
                    n_rel += 1
                    false_rel += (not true)
                else:
                    n_unrel += 1
                    if not true:
                        false_unrel += 1
                        if example is None:
                            example = ("halting axiom" if cur is None else "rule", Z, Y)
    log(f"  relativisation control (tag-0 rules and halting axiom evaluated in U): relativised instances "
        f"{n_rel}, false {false_rel}; instances with pair values {n_unrel}, false {false_unrel}"
        + (f" (first: {example[0]}, Z = {example[1]!r}, Y = {example[2]!r})" if example else "")
        + f"; run timeouts {timeouts[0]}")
    return false_rel == 0 and false_unrel > 0


def main():
    log("t4_two_stack.py -- one binary theoretical relation suffices; observational translation via theta_2")
    ok = True
    log("== Part A: compilation and semantics ==")
    G, S, d = eq_machine()
    eq = compile_machine(G, S, d)
    ok &= static_checks(eq, "EQ")
    ok &= semantic_check(eq, eq_spec, 10, 3, "EQ") == 0
    G2, S2, d2 = ver_machine()
    ver = compile_machine(G2, S2, d2)
    ok &= static_checks(ver, "VER")
    ok &= semantic_check(ver, ver_spec, 6, 5, "VER") == 0

    log("== Part B: relation version, language {e, s0, s1, R, C} ==")
    thC = Theory(eq, observational=False)
    theory_stats(thC, "T^C(EQ)")
    cases = [(x, "", "0" if eq_spec(x, "") == "acc" else "1") for x in words(8)]
    ok &= check_derivations(thC, cases, "T^C(EQ), all |w| <= 8") == 0
    thCv = Theory(ver, observational=False)
    theory_stats(thCv, "T^C(VER)")
    vcases = []
    for x in words(6):
        if "1" in x:
            i = x.index("1")
            vcases.append((x, "1" * (i + 1), "0"))
        else:
            vcases.append((x, "", "1"))
    ok &= check_derivations(thCv, vcases, "T^C(VER), all |w| <= 6") == 0

    log("== Part C: observational version, language {e, s0, s1, R} ==")
    thO = Theory(eq, observational=True)
    theory_stats(thO, "T^O(EQ)")
    ok &= check_derivations(thO, cases, "T^O(EQ), all |w| <= 8") == 0
    thOv = Theory(ver, observational=True)
    theory_stats(thOv, "T^O(VER)")
    ok &= check_derivations(thOv, [c for c in vcases if len(c[0]) <= 5], "T^O(VER), all |w| <= 5") == 0
    ok &= pairing_lemma_check() == 0

    log("== Part D: negative controls ==")
    lines, _ = derive_datum(thO, "0101", "", "0")
    # (1) change the instantiated term of the first A4 line
    i = next(k for k, (s, j) in enumerate(lines) if j[0] == "A4")
    bad = list(lines)
    toks = bad[i][0].split(" ")
    j = max(j for j, t in enumerate(toks) if t.endswith(".e") and len(t) > 2)
    toks[j] = ("1" if toks[j][0] == "0" else "0") + toks[j][1:]
    bad[i] = (" ".join(toks), bad[i][1])
    r1, msg1, _ = HC.check(bad, lambda s, f: s in thO.members)
    # (2) replace an MP conclusion by a different atom
    k = max(k for k, (s, j) in enumerate(lines) if j[0] == "MP" and k < len(lines) - 1)
    bad2 = list(lines)
    bad2[k] = ("R 1.e", bad2[k][1])
    r2, msg2, _ = HC.check(bad2, lambda s, f: s in thO.members)
    # (3) cite a sentence that is not in the theory
    bad3 = [("A x R .x", ("ax",))] + list(lines)
    r3, msg3, _ = HC.check(bad3, lambda s, f: s in thO.members)
    log(f"  corrupted A4 term rejected: {not r1} ({msg1}); corrupted MP line rejected: {not r2} ({msg2}); "
        f"non-member axiom rejected: {not r3} ({msg3})")
    ok &= (not r1) and (not r2) and (not r3)
    # (4) corrupted machine: qf1 at the blank goes to ACC instead of REJ
    d_bad = dict(d)
    d_bad[("qf1", None)] = ("ACC", "B", "S")
    eq_bad = compile_machine(G, S, d_bad)
    log("  corrupted machine (one transition redirected to ACC):")
    nb = semantic_check(eq_bad, eq_spec, 6, 0, "EQ-corrupted")
    ok &= nb > 0
    # (5) relativisation is needed
    ok &= relativisation_control(eq)

    log("")
    log("all checks passed" if ok else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
