#!/usr/bin/env python3
"""t6_revision.py -- checks written for the revision of the `terms` record (notes-final.md).

Each part answers a referee point (referee-A.md: M1, m11; referee-B.md: B1, B3, B4, B5, B6, B7) or checks a
statement added in the revision.

Part A (Prop 4.7 as restated in notes-final.md; referee A M1, referee B B1, B7(b)).
  Alternating two-stack compile with the start rule (Z; c(s)Y) => (Z; c(s2) blk(#) Y) and the EXACT output rules
  forall x (C(x, 0 st(s)) -> R(x)), forall x (C(x, 1 st(s)) -> ~R(x)) (with Std(x) in the theta_2 version).
  The compiler, the least-fixed-point evaluator and the theory builder are imported unchanged from
  t3_alternating.py (whose construction is the one notes-final.md writes out); the machines are new:
    NO11U  universal, with a successor that moves LEFT:   X = {w : w has no factor 11};
    C11E   existential, with a successor that moves LEFT: X = {w : w has a factor 11};
    EVENB  deterministic, writes B at the end and READS it back:  X = {w : |w| even}.
  Every machine also has two JUNK transitions out of its start state on the letters 0 and 1, which are
  unreachable from a start tape (cell 0 of a start tape holds '#').  Checks: disjointness of distinct current
  patterns; least-fixed-point membership of the exact start pairs against the specification (|x| <= 8, both
  tags); Hilbert derivations of all data |x| <= 6 in the relation version and the theta_2/Std version (checked
  by hilbert_check.py), with the largest line by |x| (the (a1) budget).  Negative control: with the free-z
  output rules of Def 4.4 the junk transitions put C(x, eta st(s) blk(a)) into the least fixed point for every
  x, and checked derivations of both R(t_x) and ~R(t_x) exist: that theory is inconsistent.

Part B (Lemma 4.5 / Thm 4.6 with a machine that reads B; referee B B7(a)).  A deterministic one-tape decider
  (even length) that skips the certificate, writes B at the end and reads it back, compiled by t4_two_stack's
  compiler (imported unchanged): static checks, semantics on all (x, z) with |x| <= 8, |z| <= 3, derivations of
  all data |x| <= 6 (z = empty and z = 01) in both versions; every accepting/rejecting run reads B.

Part C (Prop 7.2(b), (d); referee B B3).  Exhaustive search, in increasing size, over sets of atom-to-atom
  implications U -> V (U != V) over {A_1..A_n, B_1..B_m} (without X) and over {A_i, B_j, X} (with X) whose
  {A,B}-consequences equal those of T_dir = {A_i -> B_j}.  Equality of consequences is decided exactly:
  every such theory is "every element's type lies in P" for a set P of types, the {A,B}-reducts of its models
  are the structures whose element types lie in the projection of P, and two such classes are equal iff the
  projected type sets are equal (one-element structures separate them).  Expected minima: nm without X,
  min(nm, n+m) with X.

Part D (Example 3.4; referee B B5).  The columns of scout S's s2_craig_blowup.out from closed forms: words
  regenerated from s2's seed; N = 4(2^{n+1}-1), L* = n+2, d_T = sum_{j<=n}(j+2) + (n+2) + [#_1 w odd],
  log10 k >= log10 sum_{L<L*} N^L (exact k for n <= 4 from s2's own counting search, imported; s2's main() is
  not run), Craig axiom >= (k+1)|phi^b|, certificate |c|+15+|phi^b| with |c| = L*(2+ceil(log2 N)), fast-labeller
  Craig axiom (n+3)|phi^b|.  Compared with the saved s2 table (no rerun of s2, which needs > 12 GB).

Part E (Prop 9.3 with 13 sentences; referee B B4).  The two sentences forall x (J(x,e) -> J(s1 x, e)) and its
  negated form are dropped; every J-literal with |u|, |v| <= 5 and every R-literal with |w| <= 9 is derived from
  the remaining 13 (A4 and MP only), checked; the 13 are true in (T, R, J) on |x|, |y| <= 6.

Part F (Thm 5.3's window; referee A m11, referee B B6).  For random DFAs, the residuals X_v = {u : uv in X}
  are computed exactly (X_v is determined by F_v intersected with the reachable states, F_v = {q : delta(q,v) in
  F}); the least W such that the windows {0,1}^{<W} separate the residuals is compared with max(n-1, 1).

Part G (Prop 6.3(d), bit-length version).  Lower bound min_k [log2 k! + max(1, ceil(n / 2^k))] for consistent
  monadic sentences proving Inf_n, under a symbol-wise prefix code with predicate indices in a prefix-free code;
  upper bound: the carry counter Cnt'_k, k = ceil(log2 n), with Elias-gamma predicate codes.  Both divided by
  log2 n * log2 log2 n.

Seed 20261016 for the random parts; everything else deterministic.  Writes t6_revision.out next to itself.
"""
import itertools
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hilbert_check as HC  # noqa: E402
import t3_alternating as T3  # noqa: E402  (main() guarded)
import t4_two_stack as T4  # noqa: E402  (main() guarded)

SEED = 20261016
OUT = os.path.join(HERE, "t6_revision.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


T4.log = log  # route t4's reporting helpers into this log


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


# ======================================================================================== Part A
def machine_no11u():
    G = ["#", "0", "1", "B"]
    d, kind = {}, {}
    d[("q0", "#")] = [("scan", "#", "R")]
    d[("q0", "0")] = [("ACC", "0", "S")]          # junk: unreachable from a start tape
    d[("q0", "1")] = [("REJ", "1", "S")]          # junk
    kind["q0"] = "E"
    d[("scan", "0")] = [("scan", "0", "R")]
    d[("scan", "1")] = [("scan", "1", "R"), ("chkp", "1", "L")]   # universal, one successor moves left
    d[("scan", None)] = [("ACC", "B", "S")]
    kind["scan"] = "U"
    d[("chkp", "0")] = [("ACC", "0", "S")]
    d[("chkp", "#")] = [("ACC", "#", "S")]
    d[("chkp", "1")] = [("REJ", "1", "S")]
    kind["chkp"] = "E"
    states = ["q0", "scan", "chkp", "ACC", "REJ"]
    return G, states, d, kind, (lambda x: "11" not in x), ("0", "1")


def machine_c11e():
    G = ["#", "0", "1", "B"]
    d, kind = {}, {}
    d[("q0", "#")] = [("scan", "#", "R")]
    d[("q0", "1")] = [("ACC", "1", "S")]          # junk
    d[("q0", "0")] = [("REJ", "0", "S")]          # junk
    kind["q0"] = "E"
    d[("scan", "0")] = [("scan", "0", "R")]
    d[("scan", "1")] = [("scan", "1", "R"), ("chkp", "1", "L")]   # existential guess
    d[("scan", None)] = [("REJ", "B", "S")]
    kind["scan"] = "E"
    d[("chkp", "1")] = [("ACC", "1", "S")]
    d[("chkp", "0")] = [("REJ", "0", "S")]
    d[("chkp", "#")] = [("REJ", "#", "S")]
    kind["chkp"] = "E"
    states = ["q0", "scan", "chkp", "ACC", "REJ"]
    return G, states, d, kind, (lambda x: "11" in x), ("1", "0")


def machine_evenb():
    G = ["#", "0", "1", "B"]
    d, kind = {}, {}
    d[("q0", "#")] = [("p0", "#", "R")]
    d[("q0", "0")] = [("ACC", "0", "S")]          # junk
    d[("q0", "1")] = [("REJ", "1", "S")]          # junk
    for a in "01":
        d[("p0", a)] = [("p1", a, "R")]
        d[("p1", a)] = [("p0", a, "R")]
    d[("p0", None)] = [("f0", "B", "L")]
    d[("p1", None)] = [("f1", "B", "L")]
    for a in ("#", "0", "1"):
        d[("f0", a)] = [("g0", a, "R")]
        d[("f1", a)] = [("g1", a, "R")]
    d[("g0", "B")] = [("ACC", "B", "S")]          # reads B
    d[("g1", "B")] = [("REJ", "B", "S")]          # reads B
    states = ["q0", "p0", "p1", "f0", "f1", "g0", "g1", "ACC", "REJ"]
    for q in states:
        kind[q] = "E"
    return G, states, d, kind, (lambda x: len(x) % 2 == 0), ("0", "1")


def free_z_theory(prog, th_exact, obs):
    """The theory with Def 4.4's free-z output rules in place of the exact ones."""
    code = prog["code"]

    def atom(r, l):
        return T3.theta2(r, l) if obs else f"C {r} {l}"

    def stdf(t):
        return f"N Q 11{t} {t}"

    out = {}
    for t, concl in (("0", "R .x"), ("1", "N R .x")):
        body = f"I {atom('.x', t + code['s'] + '.z')} {concl}"
        if obs:
            body = f"I {stdf('.x')} I {stdf('.z')} {body}"
        out[t] = f"A x A z {body}"
    th = dict(th_exact)
    th["out"] = out
    th["members"] = set(th_exact["sent"]) | set(th_exact["halt"].values()) | set(out.values()) | set(th_exact["std"])
    return th


def derive_general(prog, th, start, tag, out_sent, out_vals):
    """Backward derivation of C(start) along a least-fixed-point witness, then the output sentence."""
    memo = {}
    ok, _ = T3.accepts(prog, start, tag, memo)
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
        return mp(i, add(f"I {s} {T3.gsub(body, v, word)}", ("A4",)))

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
            Z, Y = T3.matches(hp, cfg)
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
    o = use(out_sent, out_vals)
    mp(top, o)
    return lines


def part_a():
    log("== Part A: Prop 4.7 as restated (start rule onto l, exact output rules); junk-accepting machines ==")
    ok = True
    for name, mk in (("NO11U", machine_no11u), ("C11E", machine_c11e), ("EVENB", machine_evenb)):
        G, S, d, kind, spec, junk = mk()
        prog = T3.compile_alt(G, S, d, kind)
        code = prog["code"]
        curs = sorted({r[0] for r in prog["rules"]})
        overl = sum(1 for i in range(len(curs)) for j in range(i + 1, len(curs))
                    if T3.compat(curs[i][0], curs[i][1], curs[j][0], curs[j][1])
                    and T3.compat(curs[i][2], curs[i][3], curs[j][2], curs[j][3]))
        bad = 0
        for x in words(0, 8):
            a0 = T3.accepts(prog, (x, "0" + code["s"]), "0", {})[0]
            a1 = T3.accepts(prog, (x, "1" + code["s"]), "1", {})[0]
            if a0 != spec(x) or a1 != (not spec(x)):
                bad += 1
        log(f"  {name}: {len(prog['rules'])} rules, {len(curs)} distinct current patterns, overlapping {overl}; "
            f"exact start pairs |x| <= 8 (511 words, both tags) against the specification: mismatches {bad}")
        ok &= overl == 0 and bad == 0
        for obs in (False, True):
            th = T3.make_theory(prog, obs)
            nbad, nl, maxl = 0, 0, {}
            for x in words(0, 6):
                tag = "0" if spec(x) else "1"
                lines = derive_general(prog, th, (x, tag + code["s"]), tag, th["out"][tag], [x])
                res, msg, parsed = HC.check(lines, lambda s, f: s in th["members"])
                want = HC.parse(f"R {x}.e" if tag == "0" else f"N R {x}.e")
                if not res or parsed[-1] != want:
                    nbad += 1
                    if nbad <= 2:
                        log(f"    FAIL {name} x={x}: {msg}")
                nl = max(nl, len(lines))
                maxl[len(x)] = max(maxl.get(len(x), 0), max(HC.size(f) for f in parsed))
            ver = "theta_2/Std version" if obs else "relation version"
            diffs = [maxl[k + 1] - maxl[k] for k in range(1, 6)]
            log(f"    {ver}: {len(th['members'])} sentences; derivations of all 127 data |x| <= 6: invalid {nbad}; "
                f"max lines {nl}; largest line by |x|: " + ", ".join(f"{k}:{v}" for k, v in sorted(maxl.items()))
                + f" (increments for |x| >= 1: {sorted(set(diffs))})")
            ok &= nbad == 0 and max(diffs) <= 40
        # negative control: free-z output rules
        zacc = prog["beta"][junk[0]]   # tag 0: the junk letter leading to ACC
        zrej = prog["beta"][junk[1]]   # tag 1: the junk letter leading to REJ
        allacc = all(T3.accepts(prog, (x, "0" + code["s"] + zacc), "0", {})[0] for x in words(0, 6))
        allrej = all(T3.accepts(prog, (x, "1" + code["s"] + zrej), "1", {})[0] for x in words(0, 6))
        log(f"    free-z control: C(x, 0 st(s) blk({junk[0]})) in the least fixed point for all |x| <= 6: {allacc}; "
            f"C(x, 1 st(s) blk({junk[1]})) for all |x| <= 6: {allrej}")
        ok &= allacc and allrej
        for obs in (False, True):
            thx = T3.make_theory(prog, obs)
            thz = free_z_theory(prog, thx, obs)
            x = "0110"
            l0 = derive_general(prog, thz, (x, "0" + code["s"] + zacc), "0", thz["out"]["0"], [x, zacc])
            l1 = derive_general(prog, thz, (x, "1" + code["s"] + zrej), "1", thz["out"]["1"], [x, zrej])
            r0, m0, p0 = HC.check(l0, lambda s, f: s in thz["members"])
            r1, m1, p1 = HC.check(l1, lambda s, f: s in thz["members"])
            both = r0 and r1 and p0[-1] == HC.parse(f"R {x}.e") and p1[-1] == HC.parse(f"N R {x}.e")
            ver = "theta_2/Std" if obs else "relation"
            log(f"    free-z control ({ver} version): checked derivations of R(t_{x}) ({len(l0)} lines) and of "
                f"~R(t_{x}) ({len(l1)} lines): both valid {both} -> the free-z theory is inconsistent")
            ok &= both
    return ok


# ======================================================================================== Part B
def machine_evenb_det():
    G = ["#", "0", "1", "B", "Z0", "Z1"]
    d = {}
    for a in ("Z0", "Z1"):
        d[("q0", a)] = ("q0", a, "R")             # skip the certificate
    d[("q0", "#")] = ("p0", "#", "R")
    for a in "01":
        d[("p0", a)] = ("p1", a, "R")
        d[("p1", a)] = ("p0", a, "R")
    d[("p0", None)] = ("f0", "B", "L")
    d[("p1", None)] = ("f1", "B", "L")
    for a in ("#", "0", "1"):
        d[("f0", a)] = ("g0", a, "R")
        d[("f1", a)] = ("g1", a, "R")
    d[("g0", "B")] = ("ACC", "B", "S")
    d[("g1", "B")] = ("REJ", "B", "S")
    states = ["q0", "p0", "p1", "f0", "f1", "g0", "g1", "ACC", "REJ"]
    return G, states, d


def part_b():
    log("== Part B: Lemma 4.5 / Thm 4.6 with a machine that writes and reads B ==")
    G, S, d = machine_evenb_det()
    prog = T4.compile_machine(G, S, d)
    ok = T4.static_checks(prog, "EVENB-det")
    spec = lambda x, z: "acc" if len(x) % 2 == 0 else "rej"  # noqa: E731
    ok &= T4.semantic_check(prog, spec, 8, 3, "EVENB-det") == 0
    # every halting run reads B (state g0/g1 with the block of B on top of r)
    reads = 0
    tot = 0
    for x in words(0, 6):
        tag = "0" if len(x) % 2 == 0 else "1"
        res, trace, used = T4.run(prog, x, "", tag)
        tot += 1
        g = tag + prog["code"]["g0" if tag == "0" else "g1"]
        if any(l.startswith(g) and r.startswith(prog["beta"]["B"]) for r, l in trace):
            reads += 1
    log(f"  runs (z empty, |x| <= 6) that read the symbol B before halting: {reads} of {tot}")
    ok &= reads == tot
    for obs in (False, True):
        th = T4.Theory(prog, obs)
        cases = [(x, z, "0" if len(x) % 2 == 0 else "1") for x in words(0, 6) for z in ("", "01")]
        nm = "EVENB-det " + ("theta_2/Std version" if obs else "relation version")
        ok &= T4.check_derivations(th, cases, nm) == 0
    return ok


# ======================================================================================== Part C
def factoring_min(n, m, with_x):
    nodes = [f"A{i}" for i in range(n)] + [f"B{j}" for j in range(m)] + (["X"] if with_x else [])
    k = len(nodes)
    L = n + m                                   # the A, B nodes are bits 0..L-1; X is bit L
    ntypes = 1 << k
    edges = [(u, v) for u in range(k) for v in range(k) if u != v]
    viol = []
    for (u, v) in edges:
        mask = 0
        for t in range(ntypes):
            if (t >> u) & 1 and not (t >> v) & 1:
                mask |= 1 << t
        viol.append(mask)
    full = (1 << ntypes) - 1
    # target: allowed {A,B}-types of T_dir (a type with some A_i must contain every B_j)
    allB = sum(1 << (n + j) for j in range(m))
    target = 0
    for t in range(1 << L):
        if (t & ((1 << n) - 1)) == 0 or (t & allB) == allB:
            target |= 1 << t
    low = (1 << (1 << L)) - 1

    def proj(allowed):
        if not with_x:
            return allowed
        return (allowed & low) | (allowed >> (1 << L))

    for size in range(0, len(edges) + 1):
        for S in itertools.combinations(range(len(edges)), size):
            v = 0
            for e in S:
                v |= viol[e]
            if proj(full & ~v) == target:
                return size, [f"{nodes[edges[e][0]]}->{nodes[edges[e][1]]}" for e in S]
    return None, None


def part_c():
    log("== Part C: atom-to-atom theories equivalent over {A,B} to T_dir (Prop 7.2(b), (d)) ==")
    ok = True
    for (n, m) in [(1, 1), (1, 2), (2, 1), (2, 2), (1, 3), (3, 1), (2, 3), (3, 2), (1, 4), (3, 3)]:
        if n * m <= 6:
            s0, _ = factoring_min(n, m, False)
        else:
            s0 = None
        s1, ex = factoring_min(n, m, True)
        want1 = min(n * m, n + m)
        good = (s0 is None or s0 == n * m) and s1 == want1
        log(f"  (n, m) = ({n}, {m}): least size without X {s0 if s0 is not None else '(not searched)'} "
            f"(nm = {n * m}); with X {s1} (min(nm, n+m) = {want1}); X saves {n * m - s1}; "
            f"an optimum with X: {ex}; {'ok' if good else 'MISMATCH'}")
        ok &= good
    return ok


# ======================================================================================== Part D
S2_ROWS = [  # |w|, N_cand, L*, d_T, log10(k), lower-bound flag, log10 Craig, certificate, fast-labeller (s2's .out)
    (1, 12, 3, 8, 2.25, False, 2.73, 36, 12), (2, 28, 4, 14, 4.48, False, 5.18, 48, 25),
    (3, 60, 5, 20, 7.13, False, 7.91, 61, 36), (4, 124, 6, 26, 10.57, False, 11.35, 75, 42),
    (5, 252, 7, 34, 14.41, True, 15.26, 92, 56), (6, 508, 8, 43, 18.94, True, 19.84, 111, 72),
    (7, 1020, 9, 54, 24.07, True, 25.07, 133, 100), (8, 2044, 10, 65, 29.79, True, 30.84, 156, 121),
    (9, 4092, 11, 76, 36.12, True, 37.16, 180, 132), (10, 8188, 12, 89, 43.05, True, 44.12, 207, 156),
    (11, 16380, 13, 104, 50.57, True, 51.72, 237, 196), (12, 32764, 14, 118, 58.70, True, 59.85, 267, 210),
    (16, 524284, 18, 188, 97.23, True, 98.49, 411, 342), (20, 8388604, 22, 275, 145.40, True, 146.76, 588, 529),
    (24, 134217724, 26, 376, 203.20, True, 204.61, 795, 702),
]


def log10_sum_powers(N, top):
    """log10 of sum_{L=1}^{top} N^L, computed stably."""
    lg = math.log10(N)
    m = top * lg
    return m + math.log10(sum(10 ** (L * lg - m) for L in range(1, top + 1)))


def part_d():
    log("== Part D: Example 3.4 from closed forms (scout S's s2 is not rerun; it needs > 12 GB) ==")
    s2dir = os.path.join(HERE, "..", "..", "..", "scouts", "sfi", "checks")
    sys.path.insert(0, s2dir)
    import s2_craig_blowup as S2  # noqa: E402  (main() guarded; only the small counting search is used)
    rng = random.Random(20261015)               # s2's seed and drawing order
    ok = True
    worst = 0.0
    for (n, N0, L0, d0, lk0, lb0, lc0, ce0, fa0) in S2_ROWS:
        w = "".join(rng.choice("01") for _ in range(n))
        N = 4 * (2 ** (n + 1) - 1)
        Ls = n + 2
        odd = w.count("1") % 2
        dT = sum(j + 2 for j in range(n + 1)) + (n + 2) + odd
        phi = n + 2 + odd                       # |phi^b|: the literal, negated iff the number of 1s is odd
        if n <= 4:
            k, L, _ = S2.canonical_rank(w, S2.atoms_for(n), start_L=(1 if n <= 2 else Ls))
            assert L == Ls
            lk = math.log10(k)
            lc = math.log10(k + 1) + math.log10(phi)
        else:
            lk = log10_sum_powers(N, Ls - 1)
            lc = lk + math.log10(phi)           # log10((k+1)|phi^b|) with k >= 10^14: the +1 is invisible
        cert = Ls * (2 + math.ceil(math.log2(N))) + 15 + phi
        fast = (n + 3) * phi
        row_ok = (N, Ls, dT, cert, fast) == (N0, L0, d0, ce0, fa0) and abs(lk - lk0) < 0.006 \
            and abs(lc - lc0) < 0.006
        worst = max(worst, abs(lk - lk0), abs(lc - lc0))
        ok &= row_ok
        log(f"  |w| = {n:2d}: N = {N}, L* = {Ls}, d_T = {dT}, log10 k {'>=' if n > 4 else '='} {lk:.3f}, "
            f"log10 Craig axiom {'>=' if n > 4 else '='} {lc:.3f}, certificate {cert}, fast labeller {fast}: "
            f"{'matches s2' if row_ok else 'DIFFERS from s2'}")
    log(f"  largest difference from s2's printed logarithms (2 decimals): {worst:.4f}")
    return ok


# ======================================================================================== Part E
def part_e():
    log("== Part E: Prop 9.3 with 13 sentences ==")
    Jtrue = lambda u, v: u.count("0") == v.count("1")  # noqa: E731
    sents = [
        "E .e .e",
        "A y N E .e 1.y",
        "A x N E 0.x .e",
        "A y I E .e .y E .e 0.y",
        "A y I N E .e .y N E .e 0.y",
        "A x A y I E .x .y E 0.x 1.y",
        "A x A y I N E .x .y N E 0.x 1.y",
        "A x A y I E 0.x .y E 0.x 0.y",
        "A x A y I N E 0.x .y N E 0.x 0.y",
        "A x A y I E .x .y E 1.x .y",
        "A x A y I N E .x .y N E 1.x .y",
        "A x I E .x .x R .x",
        "A x I N E .x .x N R .x",
    ]
    members = set(sents)

    def val(g, env, xmax):
        k = g[0]
        if k in ("E", "R"):
            ts = [t[0] + (env[t[1]] if t[1] != "e" else "") for t in g[1:]]
            return Jtrue(ts[0], ts[-1])
        if k == "N":
            return not val(g[1], env, xmax)
        if k == "I":
            return (not val(g[1], env, xmax)) or val(g[2], env, xmax)
        return all(val(g[2], dict(env, **{g[1]: x}), xmax) for x in words(0, xmax))

    nfalse = sum(1 for s in sents if not val(HC.parse(s), {}, 6))

    def derive(u, v, lines, memo):
        def add(s, j):
            lines.append((s, j))
            return len(lines) - 1

        def mp(i, j):
            s, a = lines[j][0], lines[i][0]
            assert s.startswith("I " + a + " ")
            return add(s[len(a) + 3:], ("MP", i, j))

        def inst(i, word):
            s = lines[i][0]
            _, var, body = s.split(" ", 2)
            body2 = " ".join((t.split(".")[0] + word + ".e") if ("." in t and t.split(".")[1] == var) else t
                             for t in body.split(" "))
            return mp(i, add(f"I {s} {body2}", ("A4",)))

        def use(s, vals):
            i = add(s, ("ax",))
            for w in vals:
                i = inst(i, w)
            return i

        if (u, v) in memo:
            return memo[(u, v)]
        neg = "" if Jtrue(u, v) else "N "
        if u == "" and v == "":
            k = add("E .e .e", ("ax",))
        elif u == "" and v[0] == "1":
            k = use("A y N E .e 1.y", [v[1:]])
        elif u == "" and v[0] == "0":
            p = derive("", v[1:], lines, memo)
            k = mp(p, use(f"A y I {neg}E .e .y {neg}E .e 0.y", [v[1:]]))
        elif u[0] == "0" and v == "":
            k = use("A x N E 0.x .e", [u[1:]])
        elif u[0] == "1":                       # (1u', v), v possibly empty: the binary sentence at y := v
            p = derive(u[1:], v, lines, memo)
            k = mp(p, use(f"A x A y I {neg}E .x .y {neg}E 1.x .y", [u[1:], v]))
        elif v[0] == "1":
            p = derive(u[1:], v[1:], lines, memo)
            k = mp(p, use(f"A x A y I {neg}E .x .y {neg}E 0.x 1.y", [u[1:], v[1:]]))
        else:
            p = derive(u, v[1:], lines, memo)
            k = mp(p, use(f"A x A y I {neg}E 0.x .y {neg}E 0.x 0.y", [u[1:], v[1:]]))
        memo[(u, v)] = k
        return k

    badJ, maxJ = 0, 0
    for u in words(0, 5):
        for v in words(0, 5):
            lines = []
            derive(u, v, lines, {})
            res, msg, parsed = HC.check(lines, lambda s, f: s in members)
            if not res or parsed[-1] != HC.parse(f"{'' if Jtrue(u, v) else 'N '}E {u}.e {v}.e"):
                badJ += 1
            maxJ = max(maxJ, len(lines))
    badR, maxR = 0, 0
    for w in words(0, 9):
        lines = []
        k = derive(w, w, lines, {})
        neg = "" if Jtrue(w, w) else "N "
        lines.append((f"A x I {neg}E .x .x {neg}R .x", ("ax",)))
        a = len(lines) - 1
        lines.append((f"I A x I {neg}E .x .x {neg}R .x I {neg}E {w}.e {w}.e {neg}R {w}.e", ("A4",)))
        lines.append((f"I {neg}E {w}.e {w}.e {neg}R {w}.e", ("MP", a, len(lines) - 1)))
        lines.append((f"{neg}R {w}.e", ("MP", k, len(lines) - 1)))
        res, msg, parsed = HC.check(lines, lambda s, f: s in members)
        if not res or parsed[-1] != HC.parse(f"{neg}R {w}.e"):
            badR += 1
        maxR = max(maxR, len(lines))
    log(f"  13 sentences (E = J in the record), false in (T, R, J) on |x|, |y| <= 6: {nfalse}")
    log(f"  derivations of all 3969 J-literals with |u|, |v| <= 5: invalid {badJ} (max {maxJ} lines); of all 1023 "
        f"R-literals with |w| <= 9: invalid {badR} (max {maxR} lines)")
    return nfalse == 0 and badJ == 0 and badR == 0


# ======================================================================================== Part F
def part_f():
    log("== Part F: Thm 5.3's window, W = max(n-1, 1), on random DFAs ==")
    rng = random.Random(SEED)
    over = 0
    attained = 0
    tot = 0
    hist = {}
    for _ in range(1500):
        q = rng.randint(1, 8)
        delta = {(s, a): rng.randrange(q) for s in range(q) for a in "01"}
        F = frozenset(s for s in range(q) if rng.random() < 0.5)
        reach = {0}
        frontier = [0]
        while frontier:
            s = frontier.pop()
            for a in "01":
                t = delta[(s, a)]
                if t not in reach:
                    reach.add(t)
                    frontier.append(t)
        reach = frozenset(reach)
        # residual X_v = {u : delta(0, u) in F_v}, F_v = {s : delta(s, v) in F}; F_{av} = {s : delta(s, a) in F_v}
        seen = {F & reach: F}
        stack = [F]
        allF = {F}
        while stack:
            Fv = stack.pop()
            for a in "01":
                Fav = frozenset(s for s in range(q) if delta[(s, a)] in Fv)
                if Fav not in allF:
                    allF.add(Fav)
                    stack.append(Fav)
                    seen.setdefault(Fav & reach, Fav)
        classes = list(seen.keys())
        n = len(classes)

        def in_class(cls, u):
            s = 0
            for a in u:
                s = delta[(s, a)]
            return s in cls

        W = 1
        while True:
            us = list(words(0, W - 1))
            sigs = {tuple(in_class(c, u) for u in us) for c in classes}
            if len(sigs) == n:
                break
            W += 1
        bound = max(n - 1, 1)
        tot += 1
        hist[n] = hist.get(n, 0) + 1
        if W > bound:
            over += 1
        if n >= 3 and W == n - 1:
            attained += 1
    log(f"  {tot} random DFAs (1-8 states), residual counts n from {min(hist)} to {max(hist)}; least separating "
        f"window above max(n-1, 1): {over}; equal to n-1 with n >= 3: {attained}")
    return over == 0 and attained > 0


# ======================================================================================== Part G
def gamma_len(i):
    """Elias gamma code length of i >= 1."""
    return 2 * int(math.floor(math.log2(i))) + 1


def part_g():
    log("== Part G: Prop 6.3(d), bit lengths of monadic sentences proving Inf_n ==")
    rows = []
    for j in (8, 16, 32, 64, 128, 256, 512, 1024):
        n = 2 ** j
        # lower bound: k predicates (log2 k! bits at least), rank q >= max(1, n / 2^k) quantifier symbols
        def cost(k):
            q = max(1, -(-n // 2 ** k))         # the rank needed: n <= 2^k max(q, 1)
            return float("inf") if q.bit_length() > 60 else math.lgamma(k + 1) / math.log(2) + q
        lb = min(cost(k) for k in range(0, j + 2))
        k = j                                   # Cnt'_k with k = ceil(log2 n) = j proves Inf_{2^k}
        # 64k+13 symbols (scout N1's convention); predicate letters P_0..P_{k-1}, Q_0..Q_k get the indices
        # 1..2k+1 and cost 1 + gamma bits; every other symbol (a fixed alphabet of fewer than 16) 1 + 4 bits
        ub = (64 * k + 13) * max(5, 1 + gamma_len(2 * k + 1))
        scale = j * math.log2(j)
        rows.append((j, lb, ub, lb / scale, ub / scale))
    for j, lb, ub, rl, ru in rows:
        log(f"  n = 2^{j}: lower bound {lb:.1f} bits, Cnt' upper bound {ub} bits; divided by log n log log n: "
            f"{rl:.3f} and {ru:.3f}")
    # Theta(log n log log n): the lower ratio stays above a positive constant, the upper ratio is bounded
    # (it decreases along the rows, towards about 128 = 2 * 64 per counter bit)
    ratios_ok = all(r[3] > 0.25 for r in rows) and all(rows[i + 1][4] <= rows[i][4] for i in range(len(rows) - 1))
    log("  lower ratios bounded below by 0.25 and upper ratios non-increasing: " + str(ratios_ok))
    return ratios_ok


def main():
    log("t6_revision.py -- checks for the revision of the terms record (notes-final.md)")
    results = {}
    for name, fn in (("A", part_a), ("B", part_b), ("C", part_c), ("D", part_d), ("E", part_e), ("F", part_f),
                     ("G", part_g)):
        results[name] = fn()
        log(f"  Part {name}: {'passed' if results[name] else 'FAILED'}")
        log("")
    log("all checks passed" if all(results.values()) else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
