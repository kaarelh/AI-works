#!/usr/bin/env python3
"""rb1_two_stack.py -- referee B: independent re-implementation of Def 4.4, Lemma 4.5, Thm 4.6 and Prop 4.7.

Written from the TEXT of notes.md (not from checks/t4_two_stack.py or checks/t3_alternating.py), with referee B's
own syntax and derivation checker (rb_logic.py), on machines not used by the developer:
  ANBN  a deterministic one-tape decider for {0^n 1^n} (crossing-off; uses left moves);
  V11   a verifier with certificates: acc iff 1 <= |z| <= |x|-1 and x_|z| = x_|z|+1 = 1 (a pointer in unary);
        rej iff z is empty and x has no factor 11; bot otherwise.  It reads the written blank symbol B, so the
        normal-form clause "B is treated exactly as the blank" is exercised.
Parts
  A  compilation per Lemma 4.5(3): linearity, pairwise disjointness of current patterns (symbolically and by
     brute force on all pairs of short words), no rule at halting states, semantics of Lemma 4.5(ii) on all
     (x, z) in a box.
  B  T^C (relation version) and T^O (theta_2/Std version): derivations of every datum in a box, checked by
     rb_logic.check; line counts and sizes; the relation-version members evaluated in (T, C^T, X_acc).
  C  Prop 4.7 (alternating, reading (a1)), compiled exactly as the text says ("as in Lemma 4.5 with phases 2 and
     3 only") and with the developer's corrected start rule; output rule with the variable z (as in Def 4.4)
     and with the exact start prefix.  Machines: E11 (existential, left moves), U10 (universal), and EVENJ, a
     deterministic machine for even length whose start state accepts when it does not read '#' (legal: Prop
     4.7 constrains the machine only on start tapes '#x').
  D  negative controls for the checker.
Deterministic (no randomness).  Writes rb1_two_stack.out next to itself.
"""
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rb_logic as L  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb1_two_stack.out")
LOG = []


def log(x=""):
    print(x)
    LOG.append(x)


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


# ------------------------------------------------------------------ machines (one tape, normal form)
def normalise(G, delta):
    """Normal form of Lemma 4.5(1): B is treated exactly as the blank."""
    d = dict(delta)
    for (q, a), v in list(delta.items()):
        if a is None and (q, "B") not in d:
            d[(q, "B")] = v
    return d


def anbn():
    G = ["#", "0", "1", "Z0", "Z1", "B", "X", "Y"]
    d = {("q0", "Z0"): ("q0", "Z0", "R"), ("q0", "Z1"): ("q0", "Z1", "R"), ("q0", "#"): ("a", "#", "R"),
         ("a", "0"): ("b", "X", "R"), ("a", "Y"): ("c", "Y", "R"), ("a", None): ("ACC", "B", "S"),
         ("a", "1"): ("REJ", "1", "S"),
         ("b", "0"): ("b", "0", "R"), ("b", "Y"): ("b", "Y", "R"), ("b", "1"): ("bk", "Y", "L"),
         ("b", None): ("REJ", "B", "S"),
         ("bk", "0"): ("bk", "0", "L"), ("bk", "Y"): ("bk", "Y", "L"), ("bk", "X"): ("a", "X", "R"),
         ("c", "Y"): ("c", "Y", "R"), ("c", None): ("ACC", "B", "S"), ("c", "0"): ("REJ", "0", "S"),
         ("c", "1"): ("REJ", "1", "S")}
    spec = lambda x, z: "acc" if (len(x) % 2 == 0 and x == "0" * (len(x) // 2) + "1" * (len(x) // 2)) else "rej"  # noqa
    return "ANBN", G, normalise(G, d), ["q0", "a", "b", "bk", "c", "ACC", "REJ", "BOT"], spec


def v11():
    G = ["#", "0", "1", "Z0", "Z1", "B", "ZM", "A0", "A1"]
    d = {("q0", "#"): ("scan", "#", "R"), ("q0", "Z0"): ("tox", "ZM", "R"), ("q0", "Z1"): ("tox", "ZM", "R")}
    for a in ("Z0", "Z1", "ZM", "#", "A0", "A1"):
        d[("tox", a)] = ("tox", a, "R")
    d[("tox", "0")] = ("back", "A0", "L")
    d[("tox", "1")] = ("back", "A1", "L")
    d[("tox", None)] = ("BOT", "B", "S")
    for a in ("A0", "A1", "#", "Z0", "Z1"):
        d[("back", a)] = ("back", a, "L")
    d[("back", "ZM")] = ("mk", "ZM", "R")
    d[("mk", "Z0")] = ("tox", "ZM", "R")
    d[("mk", "Z1")] = ("tox", "ZM", "R")
    d[("mk", "#")] = ("fin", "#", "R")
    d[("fin", "A0")] = ("fin", "A0", "R")
    d[("fin", "A1")] = ("fin", "A1", "R")
    d[("fin", "0")] = ("chk", "0", "L")
    d[("fin", "1")] = ("chk", "1", "L")
    d[("fin", None)] = ("chk", "B", "L")
    d[("chk", "A1")] = ("chk2", "A1", "R")
    d[("chk", "A0")] = ("BOT", "A0", "S")
    d[("chk2", "1")] = ("ACC", "1", "S")
    d[("chk2", "0")] = ("BOT", "0", "S")
    d[("chk2", None)] = ("BOT", "B", "S")
    d[("scan", "0")] = ("scan", "0", "R")
    d[("scan", "1")] = ("scan1", "1", "R")
    d[("scan", None)] = ("REJ", "B", "S")
    d[("scan1", "0")] = ("scan", "0", "R")
    d[("scan1", "1")] = ("BOT", "1", "S")
    d[("scan1", None)] = ("REJ", "B", "S")

    def spec(x, z):
        m = len(z)
        if m == 0:
            return "rej" if "11" not in x else "bot"
        if m + 1 <= len(x) and x[m - 1] == "1" and x[m] == "1":
            return "acc"
        return "bot"
    states = ["q0", "scan", "scan1", "tox", "back", "mk", "fin", "chk", "chk2", "ACC", "REJ", "BOT"]
    return "V11", G, normalise(G, d), states, spec


# ------------------------------------------------------------------ Lemma 4.5 compiler (from the text)
def codes(items):
    k = max(1, (len(items) - 1).bit_length())
    return {q: format(i, "0%db" % k) for i, q in enumerate(items)}


def compile_det(G, delta, mstates):
    st = codes(["s", "s0", "s1", "s2", "s3"] + mstates)
    blk = codes(G)
    rules = []   # (cur, nxt, label); pattern = (rp, rvar, lp, lvar)
    for eta in "01":
        c = lambda q: eta + st[q]  # noqa: E731
        rules.append((("", 1, c("s"), 1), (blk["#"], 1, c("s0"), 1), "start"))
        for a in "01":
            rules.append((("", 1, c("s0") + a, 1), (blk["Z" + a], 1, c("s0"), 1), "p0"))
        rules.append((("", 1, c("s0"), 0), ("", 1, c("s1"), 0), "p0end"))
        for a in "01":
            rules.append(((blk["Z" + a], 1, c("s1"), 1), ("", 1, c("s1") + blk["Z" + a], 1), "p1"))
        rules.append(((blk["#"], 1, c("s1"), 1), ("", 1, c("s2") + blk["#"], 1), "p1end"))
        for a in "01":
            rules.append(((a, 1, c("s2"), 1), ("", 1, c("s2") + blk[a], 1), "p2"))
        rules.append((("", 0, c("s2"), 1), ("", 0, c("s3"), 1), "p2end"))
        for dd in ("Z0", "Z1", "#", "0", "1"):
            rules.append((("", 1, c("s3") + blk[dd], 1), (blk[dd], 1, c("s3"), 1), "p3"))
        rules.append((("", 1, c("s3"), 0), ("", 1, c("q0"), 0), "p3end"))
        for (q, a), (q2, b, mv) in delta.items():
            rp, rv = (blk[a], 1) if a is not None else ("", 0)
            if mv == "R":
                rules.append(((rp, rv, c(q), 1), ("", rv, c(q2) + blk[b], 1), "M"))
            elif mv == "S":
                rules.append(((rp, rv, c(q), 1), (blk[b], rv, c(q2), 1), "M"))
            else:
                for e in G:
                    rules.append(((rp, rv, c(q) + blk[e], 1), (blk[e] + blk[b], rv, c(q2), 1), "M"))
                rules.append(((rp, rv, c(q), 0), (blk[b], rv, c(q2), 0), "M"))
    return dict(rules=rules, st=st, blk=blk)


def overlap(p, q):
    """Can one pair of words match both patterns?"""
    def comp(a, av, b, bv):
        if av and bv:
            return a.startswith(b) or b.startswith(a)
        if av:
            return b.startswith(a)
        if bv:
            return a.startswith(b)
        return a == b
    return comp(p[0], p[1], q[0], q[1]) and comp(p[2], p[3], q[2], q[3])


def match(p, cfg):
    r, l = cfg
    if p[1]:
        if not r.startswith(p[0]):
            return None
        Z = r[len(p[0]):]
    else:
        if r != p[0]:
            return None
        Z = None
    if p[3]:
        if not l.startswith(p[2]):
            return None
        Y = l[len(p[2]):]
    else:
        if l != p[2]:
            return None
        Y = None
    return Z, Y


def build(p, Z, Y):
    return (p[0] + (Z if p[1] else ""), p[2] + (Y if p[3] else ""))


def index(prog):
    """Rules indexed by the tag-and-state prefix of l (every current pattern's l begins with it)."""
    if "idx" not in prog:
        k = 1 + len(next(iter(prog["st"].values())))
        idx = {}
        for i, rule in enumerate(prog["rules"]):
            assert len(rule[0][2]) >= k
            idx.setdefault(rule[0][2][:k], []).append(i)
        prog["idx"], prog["k"] = idx, k
    return prog["idx"], prog["k"]


def candidates(prog, cfg):
    idx, k = index(prog)
    return idx.get(cfg[1][:k], [])


def run(prog, cfg, goal_prefixes, maxsteps=100000):
    """Deterministic run; returns (halting prefix reached or None, list of configs, rule indices)."""
    path, used = [cfg], []
    for _ in range(maxsteps):
        for g in goal_prefixes:
            if cfg[1].startswith(g):
                return g, path, used
        hits = [(i, m) for i in candidates(prog, cfg) if (m := match(prog["rules"][i][0], cfg)) is not None]
        if len(hits) > 1:
            raise RuntimeError("non-deterministic at %r" % (cfg,))
        if not hits:
            return None, path, used
        i, (Z, Y) = hits[0]
        cfg = build(prog["rules"][i][1], Z, Y)
        path.append(cfg)
        used.append((i, Z, Y))
    return "TIMEOUT", path, used


def part_a(m):
    name, G, delta, mstates, spec = m
    prog = compile_det(G, delta, mstates)
    R = prog["rules"]
    nonlin = sum(1 for cur, nxt, _ in R if (cur[1], cur[3]) != (nxt[1], nxt[3]))
    sym_ov = sum(1 for i in range(len(R)) for j in range(i + 1, len(R)) if overlap(R[i][0], R[j][0]))
    st = prog["st"]
    halting = [e + st[h] for e in "01" for h in ("ACC", "REJ", "BOT")]
    at_halt = sum(1 for cur, _, _ in R if any(cur[2].startswith(h) or h.startswith(cur[2]) and cur[3] for h in halting))
    # brute force: every pair (r, l) with l = (tag, state code) + a word of length <= 2 kB + 1 and
    # |r| <= kB + 2 matches at most one current pattern (longer words cannot create new overlaps)
    brute = npairs = 0
    kb = len(next(iter(prog["blk"].values())))
    for eta in "01":
        for q, code in st.items():
            for w in words(0, 2 * kb + 1):
                l = eta + code + w
                for r in words(0, kb + 2):
                    npairs += 1
                    if sum(1 for i in candidates(prog, (r, l)) if match(R[i][0], (r, l)) is not None) > 1:
                        brute += 1
    log(f"  {name}: {len(R)} rules; non-linear 0? {nonlin == 0}; symbolic overlaps {sym_ov}; brute force on "
        f"{npairs} pairs: pairs matching two rules {brute}; rules whose current pattern can begin with a halting "
        f"prefix {at_halt}")
    ok = nonlin == 0 and sym_ov == 0 and brute == 0 and at_halt == 0
    hacc, hrej = "0" + st["ACC"], "1" + st["REJ"]
    bad = n = longest = 0
    xmax, zmax = (8, 3) if name == "ANBN" else (6, 6)
    for x in words(0, xmax):
        for z in words(0, zmax):
            n += 1
            g0, p0, _ = run(prog, (x, "0" + st["s"] + z), [hacc, "0" + st["REJ"], "0" + st["BOT"]])
            g1, p1, _ = run(prog, (x, "1" + st["s"] + z), [hrej, "1" + st["ACC"], "1" + st["BOT"]])
            longest = max(longest, len(p0), len(p1))
            v = spec(x, z)
            if (g0 == hacc) != (v == "acc") or (g1 == hrej) != (v == "rej") or "TIMEOUT" in (g0, g1) \
                    or g0 is None or g1 is None:
                bad += 1
    log(f"  {name}: semantics of Lemma 4.5(ii) on {n} (x, z) pairs (|x| <= {xmax}, |z| <= {zmax}): mismatches or "
        f"stuck runs {bad}; longest run {longest} configurations")
    ok &= bad == 0
    return ok, prog


# ------------------------------------------------------------------ theories T^C and T^O
def V(n):
    return ("v", n)


def C(a, b):
    return ("at", "C", (a, b))


def Rat(t):
    return ("at", "R", (t,))


def imp(a, b):
    return ("imp", a, b)


def Pair(t):
    return ("eq", L.s("1", L.s("1", t)), t)


def Std(t):
    return ("not", Pair(t))


def theta2(a, b, bound="w"):
    z = V(bound)
    return ("all", bound, imp(Pair(z), imp(("eq", L.s("0", z), a), imp(("eq", L.s("0", L.s("1", z)), b), Rat(z)))))


def pterm(prefix, var):
    return L.word_term(prefix, V(var) if var else L.E)


def make_theory(prog, observational, rules_override=None, out_with_z=True, bound="w"):
    """Def 4.4: backward rules, halting axioms, output rules; and the observational translation."""
    st = prog["st"]
    atom = (lambda a, b: theta2(a, b, bound)) if observational else C

    def close(vs, body):
        if observational:
            for v in reversed(vs):
                body = imp(Std(V(v)), body)
        for v in reversed(vs):
            body = ("all", v, body)
        return body

    def pat_atom(p):
        return atom(pterm(p[0], "Z" if p[1] else None), pterm(p[2], "Y" if p[3] else None))

    rule_sent = []
    for cur, nxts, _ in (rules_override if rules_override is not None else
                         [(c, [n], lab) for c, n, lab in prog["rules"]]):
        body = pat_atom(cur)
        for nx in reversed(nxts):
            body = imp(pat_atom(nx), body)
        vs = [v for v, has in (("Z", cur[1]), ("Y", cur[3])) if has]
        rule_sent.append(close(vs, body))
    halt = {"0": close(["Z", "Y"], atom(V("Z"), pterm("0" + st["ACC"], "Y"))),
            "1": close(["Z", "Y"], atom(V("Z"), pterm("1" + st["REJ"], "Y")))}
    out = {}
    for eta, concl in (("0", Rat(V("x"))), ("1", ("not", Rat(V("x"))))):
        if out_with_z:
            out[eta] = close(["x", "z"], imp(atom(V("x"), pterm(eta + st["s"], "z")), concl))
        else:
            out[eta] = close(["x"], imp(atom(V("x"), pterm(eta + st["s"], None)), concl))
    std_ax = []
    if observational:
        std_ax = [Std(L.E)] + [("all", "y", imp(Std(V("y")), Std(L.s(a, V("y"))))) for a in "01"]
    members = set(rule_sent) | set(halt.values()) | set(out.values()) | set(std_ax)
    return dict(rules=rule_sent, halt=halt, out=out, std=std_ax, obs=observational, members=members,
                out_with_z=out_with_z)


class Deriver:
    def __init__(self, th):
        self.th = th
        self.B = L.Builder()
        self.stdline = {}

    def std(self, u):
        if u not in self.stdline:
            if u == "":
                self.stdline[u] = self.B.ax(self.th["std"][0])
            else:
                prev = self.std(u[1:])
                ax = self.B.ax(self.th["std"][0 + (1 if u[0] == "0" else 2)])
                k = self.B.inst(ax, L.word_term(u[1:]))
                self.stdline[u] = self.B.mp(prev, k)
        return self.stdline[u]

    def use(self, sent, vals):
        k = self.B.ax(sent)
        for v in vals:
            k = self.B.inst(k, L.word_term(v))
        if self.th["obs"]:
            for v in vals:
                k = self.B.mp(self.std(v), k)
        return k


def derive_det(prog, th, x, z, eta):
    st = prog["st"]
    goal = eta + (st["ACC"] if eta == "0" else st["REJ"])
    g, path, used = run(prog, (x, eta + st["s"] + z), [goal])
    assert g == goal
    D = Deriver(th)
    r, l = path[-1]
    k = D.use(th["halt"][eta], [r, l[len(goal):]])
    rule_by_index = th["rules"]
    for (i, Z, Y) in reversed(used):
        vals = [v for v in (Z, Y) if v is not None]
        rk = D.use(rule_by_index[i], vals)
        k = D.B.mp(k, rk)
    o = D.use(th["out"][eta], [x, z] if th["out_with_z"] else [x])
    D.B.mp(k, o)
    return D.B.lines


def check_box(prog, th, cases, label):
    bad = maxlines = maxsize = 0
    for x, z, eta in cases:
        lines = derive_det(prog, th, x, z, eta)
        ok, msg = L.check(lines, lambda F: F in th["members"])
        want = Rat(L.word_term(x)) if eta == "0" else ("not", Rat(L.word_term(x)))
        if not ok or lines[-1][0] != want:
            bad += 1
        maxlines = max(maxlines, len(lines))
        maxsize = max(maxsize, max(L.size(F) for F, _ in lines))
    biggest = max(L.size(F) for F in th["members"])
    log(f"  {label}: {len(th['members'])} members (largest {biggest} symbols); {len(cases)} data derived; invalid or "
        f"wrong {bad}; max lines {maxlines}; max line size {maxsize}")
    return bad == 0


def part_b(m, prog):
    name, G, delta, mstates, spec = m
    cases = []
    if name == "ANBN":
        for x in words(0, 8):
            cases.append((x, "", "0" if spec(x, "") == "acc" else "1"))
    else:
        for x in words(0, 6):
            if "11" in x:
                i = x.index("11") + 1
                cases.append((x, "1" * i, "0"))
            else:
                cases.append((x, "", "1"))
    ok = True
    for obs in (False, True):
        th = make_theory(prog, obs)
        sub = cases if not obs or name == "ANBN" else [c for c in cases if len(c[0]) <= 5]
        ok &= check_box(prog, th, sub, f"{name} {'T^O (theta_2/Std)' if obs else 'T^C (relation)'}")
    # relation-version members in (T, C^T, R := X_acc), Z, Y over short words (C^T = pairs whose run halts)
    st = prog["st"]
    goals = ["0" + st["ACC"], "1" + st["REJ"]]
    memo = {}

    def inC(cfg):
        """C^T membership = the deterministic run reaches a halting prefix.  Results are memoised along the
        whole path; a repeated configuration means the run never halts (not in C); 'T' = undetermined."""
        if cfg in memo:
            return memo[cfg]
        path, seen, u, res = [], set(), cfg, None
        for _ in range(3000):
            if u in memo:
                res = memo[u]
                break
            if any(u[1].startswith(g) for g in goals):
                res = True
                break
            if u in seen:
                res = False
                break
            seen.add(u)
            path.append(u)
            hits = [(i, m) for i in candidates(prog, u) if (m := match(prog["rules"][i][0], u)) is not None]
            if not hits:
                res = False
                break
            i, (Z, Y) = hits[0]
            u = build(prog["rules"][i][1], Z, Y)
        if res is None:
            res = "T"
        for v in path:
            memo[v] = res
        memo[cfg] = res
        return res
    false = timeouts = inst = 0
    for cur, nxt, _ in prog["rules"]:
        for Z in (words(0, 5 if name == "ANBN" else 4) if cur[1] else [None]):
            for Y in (words(0, 6 if name == "ANBN" else 5) if cur[3] else [None]):
                a, b = inC(build(nxt, Z or "", Y or "")), inC(build(cur, Z or "", Y or ""))
                inst += 1
                if "T" in (a, b):
                    timeouts += 1
                elif a and not b:
                    false += 1
    for x in words(0, 6):
        for z in words(0, 4):
            for eta in "01":
                v = inC((x, eta + st["s"] + z))
                inst += 1
                if v == "T":
                    timeouts += 1
                elif v and spec(x, z) != ("acc" if eta == "0" else "rej"):
                    false += 1
    log(f"  {name}: relation-version rule and output instances evaluated in (T, C^T): {inst}, false {false}, "
        f"undetermined (run longer than 3000 steps without repeating) {timeouts}")
    return ok and false == 0


# ------------------------------------------------------------------ Part C: Prop 4.7 (alternating)
def alt_e11():
    G = ["#", "0", "1", "B"]
    d = {("q0", "#"): [("e", "#", "R")],
         ("e", "0"): [("t0", "0", "S"), ("e", "0", "R")], ("e", "1"): [("t1", "1", "S"), ("e", "1", "R")],
         ("e", None): [("REJ", "B", "S")],
         ("t0", "0"): [("REJ", "0", "S")], ("t1", "1"): [("p", "1", "L")],
         ("p", "1"): [("ACC", "1", "S")], ("p", "0"): [("REJ", "0", "S")], ("p", "#"): [("REJ", "#", "S")]}
    kind = {"e": "E"}
    return "E11", G, normalise(G, d), kind, ["q0", "e", "t0", "t1", "p", "ACC", "REJ"], (lambda x: "11" in x)


def alt_u10():
    G = ["#", "0", "1", "B"]
    d = {("q0", "#"): [("u", "#", "R")],
         ("u", "0"): [("ok", "0", "S"), ("u", "0", "R")], ("u", "1"): [("c1", "1", "R"), ("u", "1", "R")],
         ("u", None): [("ACC", "B", "S")],
         ("ok", "0"): [("ACC", "0", "S")],
         ("c1", "0"): [("ACC", "0", "S")], ("c1", "1"): [("REJ", "1", "S")], ("c1", None): [("REJ", "B", "S")]}
    kind = {"u": "U"}
    spec = lambda x: all(x[i + 1:i + 2] == "0" for i, a in enumerate(x) if a == "1")  # noqa: E731
    return "U10", G, normalise(G, d), kind, ["q0", "u", "ok", "c1", "ACC", "REJ"], spec


def alt_evenj():
    G = ["#", "0", "1", "B"]
    d = {("q0", "#"): [("ev", "#", "R")], ("q0", "0"): [("ACC", "0", "S")], ("q0", "1"): [("ACC", "1", "S")],
         ("ev", "0"): [("od", "0", "R")], ("ev", "1"): [("od", "1", "R")], ("ev", None): [("ACC", "B", "S")],
         ("od", "0"): [("ev", "0", "R")], ("od", "1"): [("ev", "1", "R")], ("od", None): [("REJ", "B", "S")]}
    return "EVENJ", G, normalise(G, d), {}, ["q0", "ev", "od", "ACC", "REJ"], (lambda x: len(x) % 2 == 0)


def compile_alt(G, delta, kind, mstates, start_variant):
    """Prop 4.7: phases 2 and 3 only; start_variant 'text' = Lemma 4.5's start rule (separator pushed on r),
    'fixed' = separator pushed on l (the developer's script)."""
    st = codes(["s", "s2", "s3"] + mstates)
    blk = codes(G)
    rules = []   # (cur, [nexts], label)
    for eta in "01":
        c = lambda q: eta + st[q]  # noqa: E731
        if start_variant == "text":
            rules.append((("", 1, c("s"), 1), [(blk["#"], 1, c("s2"), 1)], "start"))
        else:
            rules.append((("", 1, c("s"), 1), [("", 1, c("s2") + blk["#"], 1)], "start"))
        for a in "01":
            rules.append(((a, 1, c("s2"), 1), [("", 1, c("s2") + blk[a], 1)], "p2"))
        rules.append((("", 0, c("s2"), 1), [("", 0, c("s3"), 1)], "p2end"))
        for dd in ("#", "0", "1"):
            rules.append((("", 1, c("s3") + blk[dd], 1), [(blk[dd], 1, c("s3"), 1)], "p3"))
        rules.append((("", 1, c("s3"), 0), [("", 1, c("q0"), 0)], "p3end"))
        for (q, a), succs in delta.items():
            rp, rv = (blk[a], 1) if a is not None else ("", 0)
            needs_all = (kind.get(q) == "U") if eta == "0" else (kind.get(q) == "E")
            left = any(mv == "L" for _, _, mv in succs)
            cases = [(blk[e], 1) for e in G] + [("", 0)] if left else [("", 1)]
            for nb, lv in cases:
                cur = (rp, rv, c(q) + nb, lv)
                nxts = []
                for q2, b, mv in succs:
                    if mv == "R":
                        nxts.append(("", rv, c(q2) + blk[b] + nb, lv))
                    elif mv == "S":
                        nxts.append((blk[b], rv, c(q2) + nb, lv))
                    else:   # L: the neighbour nb moves to r above b (at the left end nb is empty)
                        nxts.append((nb + blk[b], rv, c(q2), lv))
                if needs_all or len(nxts) == 1:
                    rules.append((cur, nxts, "M"))
                else:
                    for nx in nxts:
                        rules.append((cur, [nx], "M"))
    return dict(rules=rules, st=st, blk=blk)


def lfp_member(prog, cfg, eta, cache, limit=20000):
    """Least fixed point by iteration over the configurations reachable backwards-rule-wise from cfg."""
    goal = eta + (prog["st"]["ACC"] if eta == "0" else prog["st"]["REJ"])
    if (cfg, eta) in cache:
        return cache[(cfg, eta)]
    seen, order, stack, succ = {cfg}, [], [cfg], {}
    while stack:
        u = stack.pop()
        order.append(u)
        if len(order) > limit:
            raise RuntimeError("exploration limit")
        succ[u] = []
        if u[1].startswith(goal):
            continue
        for ri in candidates(prog, u):
            cur, nxts, _ = prog["rules"][ri]
            mm = match(cur, u)
            if mm is None:
                continue
            ns = [build(nx, *mm) for nx in nxts]
            succ[u].append(ns)
            for v in ns:
                if v not in seen:
                    seen.add(v)
                    stack.append(v)
    inC = {u: u[1].startswith(goal) for u in order}
    changed = True
    while changed:
        changed = False
        for u in order:
            if not inC[u] and any(all(inC[v] for v in ns) for ns in succ[u]):
                inC[u] = True
                changed = True
    cache[(cfg, eta)] = inC[cfg]
    return inC[cfg], inC, succ


def derive_alt(prog, th, x, eta, zjunk=None):
    """Derive the datum literal for x with tag eta along a computation tree (relation or obs version)."""
    st = prog["st"]
    start = (x, eta + st["s"] + (zjunk or ""))
    res = lfp_member(prog, start, eta, {})
    ok, inC, succ = res
    assert ok
    goal = eta + (st["ACC"] if eta == "0" else st["REJ"])
    D = Deriver(th)
    done = {}
    rules = th["rules"]

    def der(u):
        if u in done:
            return done[u]
        if u[1].startswith(goal):
            k = D.use(th["halt"][eta], [u[0], u[1][len(goal):]])
        else:
            for ri, (cur, nxts, _) in enumerate(prog["rules"]):
                mm = match(cur, u)
                if mm is None:
                    continue
                ns = [build(nx, *mm) for nx in nxts]
                if all(inC.get(v) for v in ns):
                    prem = [der(v) for v in ns]
                    k = D.use(rules[ri], [v for v in mm if v is not None])
                    for p in prem:
                        k = D.B.mp(p, k)
                    break
            else:
                raise RuntimeError("no rule")
        done[u] = k
        return k
    top = der(start)
    if th["out_with_z"]:
        o = D.use(th["out"][eta], [x, zjunk or ""])
    else:
        o = D.use(th["out"][eta], [x])
    D.B.mp(top, o)
    return D.B.lines


def part_c():
    ok = True
    for mk in (alt_e11, alt_u10, alt_evenj):
        name, G, delta, kind, mstates, spec = mk()
        for variant in ("text", "fixed"):
            prog = compile_alt(G, delta, kind, mstates, variant)
            R = prog["rules"]
            curs = sorted({r[0] for r in R})
            ov = sum(1 for i in range(len(curs)) for j in range(i + 1, len(curs)) if overlap(curs[i], curs[j]))
            st = prog["st"]
            mism = 0
            for x in words(0, 8):
                a0 = lfp_member(prog, (x, "0" + st["s"]), "0", {})[0]
                a1 = lfp_member(prog, (x, "1" + st["s"]), "1", {})[0]
                if a0 != spec(x) or a1 != (not spec(x)):
                    mism += 1
            log(f"  {name}, start rule '{variant}': {len(R)} rules, overlapping distinct current patterns {ov}; "
                f"start pairs (x, eta st(s)) with |x| <= 8 whose least-fixed-point membership differs from the "
                f"specification: {mism} of 511")
            if variant == "fixed":
                ok &= mism == 0 and ov == 0
                # derivations with the exact output rule (the developer's script), both versions
                for obs in (False, True):
                    th = make_theory(prog, obs, rules_override=R, out_with_z=False)
                    bad = 0
                    growth = {}
                    for x in words(0, 6):
                        eta = "0" if spec(x) else "1"
                        lines = derive_alt(prog, th, x, eta)
                        good, _ = L.check(lines, lambda F: F in th["members"])
                        want = Rat(L.word_term(x)) if eta == "0" else ("not", Rat(L.word_term(x)))
                        bad += (not good) or lines[-1][0] != want
                        growth[len(x)] = max(growth.get(len(x), 0), max(L.size(F) for F, _ in lines))
                    log(f"    {'T^O' if obs else 'T^C'}, exact output rule: derivations of all 127 data |x| <= 6 "
                        f"invalid {bad}; largest line by |x|: " + ", ".join(f"{k}:{v}" for k, v in sorted(growth.items())))
                    ok &= bad == 0
                # the output rule WITH the variable z, as T^C_P of Def 4.4 has it
                th = make_theory(prog, False, rules_override=R, out_with_z=True)
                junk_hits = []
                for x in words(0, 4):
                    for zj in [prog["blk"][a] for a in ("#", "0", "1")]:
                        for eta in "01":
                            if lfp_member(prog, (x, eta + st["s"] + zj), eta, {})[0] and \
                                    (spec(x) != (eta == "0")):
                                junk_hits.append((x, zj, eta))
                log(f"    output rule with z (Def 4.4 form): start pairs (x, eta st(s) z) with |x| <= 4, z one block, "
                    f"in C^T although the literal for eta is false: {len(junk_hits)}")
                if junk_hits and name == "EVENJ":
                    x = next(h[0] for h in junk_hits if not spec(h[0]))
                    zj = next(h[1] for h in junk_hits if h[0] == x and h[2] == "0")
                    pos = derive_alt(prog, th, x, "0", zjunk=zj)
                    neg = derive_alt(prog, th, x, "1")
                    g1, _ = L.check(pos, lambda F: F in th["members"])
                    g2, _ = L.check(neg, lambda F: F in th["members"])
                    log(f"    EVENJ with the z-output rule: checked derivations of R(t_{x}) ({len(pos)} lines, junk "
                        f"z = {zj}) and of ~R(t_{x}) ({len(neg)} lines): valid {g1 and g2}; conclusions "
                        f"{pos[-1][0] == Rat(L.word_term(x))} / {neg[-1][0] == ('not', Rat(L.word_term(x)))} "
                        f"-> the theory is INCONSISTENT")
            else:
                ok &= mism > 0   # the text's start rule must fail (this is what the referee reports)
    return ok


def part_d(prog):
    th = make_theory(prog, True)
    lines = derive_det(prog, th, "0011", "", "0")
    ok0, _ = L.check(lines, lambda F: F in th["members"])
    # corrupt an A4 term
    i = next(n for n, (F, j) in enumerate(lines) if j[0] == "A4")
    F, j = lines[i]
    bad1 = list(lines)
    bad1[i] = (F, ("A4", L.word_term("1")))
    r1, _ = L.check(bad1, lambda F: F in th["members"])
    # corrupt an MP conclusion
    i = next(n for n, (F, j) in enumerate(lines) if j[0] == "MP" and F[0] == "at")
    bad2 = list(lines)
    bad2[i] = (Rat(L.word_term("0")), lines[i][1])
    r2, _ = L.check(bad2, lambda F: F in th["members"])
    # non-member
    bad3 = [(("all", "x", Rat(V("x"))), ("ax",))] + lines
    r3, _ = L.check(bad3, lambda F: F in th["members"])
    log(f"  control: genuine derivation accepted {ok0}; corrupted A4 term rejected {not r1}; corrupted MP "
        f"conclusion rejected {not r2}; non-member axiom rejected {not r3}")
    # capture: theta_2 with bound variable z, as notes.md writes it, inside the output rule forall x forall z
    th_z = make_theory(prog, True, bound="z")
    try:
        derive_det(prog, th_z, "0011", "", "0")
        cap = "derivation went through"
    except AssertionError as e:
        cap = "derivation breaks (" + str(e) + ")"
    out0 = th_z["out"]["0"]
    log(f"  bound-variable clash: with theta_2's bound variable named z (as in notes.md) the output rule's z is "
        f"captured; the generator's attempt to derive R(t_0011): {cap}")
    return ok0 and not r1 and not r2 and not r3


def main():
    log("rb1_two_stack.py -- referee B: two-stack programs from the text of notes.md, fresh machines")
    ok = True
    progs = {}
    log("== Part A: Lemma 4.5 compilation and semantics ==")
    for m in (anbn(), v11()):
        good, prog = part_a(m)
        ok &= good
        progs[m[0]] = (m, prog)
    log("== Part B: Thm 4.6 (i)-(iii): derivations in both versions ==")
    for k in ("ANBN", "V11"):
        m, prog = progs[k]
        ok &= part_b(m, prog)
    log("== Part C: Prop 4.7 (alternating) as written vs as implemented ==")
    ok &= part_c()
    log("== Part D: controls ==")
    ok &= part_d(progs["ANBN"][1])
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
