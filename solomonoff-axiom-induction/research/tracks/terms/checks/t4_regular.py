#!/usr/bin/env python3
"""t4_regular.py -- finite theories about the named objects: regular languages, residuals, and a binary observable.

Record: notes.md, Theorem 5.1 (regularity via Ehrenfeucht-Fraisse composition), Theorem 5.3 (signature
theories), Proposition 9.3 (a binary observable relation breaks Theorem 5.1).

Residuals.  For X a set of words and v a word, X_v := {u : uv in X}; in the term model R(t_{uv}) = R(s_u t_v),
so X_v is what the subtree below t_v sees.  X is regular iff it has finitely many residuals.

Part A (Thm 5.3, two further regular languages, independent of scout S's s3 Part C):
  XA := {w : w contains 010 as a factor},  XB := {w : the third letter of w (from the outside) is 1}.
  Residual classes are computed exactly from a DFA for the reversed language (Myhill-Nerode), n := their number;
  sig(v) := X_v restricted to {0,1}^{<n}.  The theory (curried, one conclusion per literal):
      L(e) for every literal L of S_{sig(e)}(e),
      forall x (S_sigma(x) -> L(s_a x))   for every realised sigma, a in {0,1}, and literal L of S_{sigma_a},
  written as nested implications.  Checks: every sentence is true in (T, X) on all x with |x| <= 9; Hilbert
  derivations (A4, MP) of all data with |w| <= 9 are valid and end in R(t_w)^{[w in X]}; derivation sizes.
Part B (non-regular languages): the number of distinct windowed residuals among |v| <= d grows without bound
  for EQ' := {0^n 1^n}, PAL (palindromes) and EQ (#0 = #1); for XA and XB it stabilises at n.
Part C (Prop 9.3, binary observable E; called J in notes.md): language {e, s0, s1, R, E}, E observable with E(t_u, t_v) iff
  #0(u) = #1(v), and R := {w : E(t_w, t_w)} = EQ (non-regular).  A finite theory of 15 sentences in this
  observational language, true in the term model, derives every E- and R-literal; checked for all |u|, |v| <= 5
  (E) and |w| <= 9 (R).  Residual count of E.
Deterministic.  Writes t4_regular.out next to itself.
"""
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hilbert_check as HC  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "t4_regular.out")
LOG = []


def log(s=""):
    print(s)
    LOG.append(s)


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


XA = lambda w: "010" in w  # noqa: E731
XB = lambda w: len(w) >= 3 and w[2] == "1"  # noqa: E731
EQ = lambda w: w.count("0") == w.count("1")  # noqa: E731
EQP = lambda w: w == "0" * (len(w) // 2) + "1" * (len(w) // 2)  # noqa: E731
PAL = lambda w: w == w[::-1]  # noqa: E731


def residual_classes(X, vmax, umax):
    """Windowed residuals: v -> tuple of [uv in X] for |u| <= umax."""
    us = list(words(0, umax))
    sig = {}
    for v in words(0, vmax):
        sig[v] = tuple(X(u + v) for u in us)
    return sig


def exact_classes(X, depth=8, window=10):
    """Number of residual classes, computed with a large window (exact for the regular languages here: the
    count is stable when the window and the depth grow, which is checked)."""
    a = len(set(residual_classes(X, depth, window).values()))
    b = len(set(residual_classes(X, depth + 1, window + 1).values()))
    return a, b


def signature_theory(X):
    n, n2 = exact_classes(X)
    assert n == n2
    # the least window {0,1}^{<W} that separates the n residual classes (W <= n by the proof; usually smaller)
    W = next(W for W in range(1, n + 1) if len(set(residual_classes(X, 8, W - 1).values())) == n)
    us = list(words(0, W - 1))
    sig = lambda v: tuple(X(u + v) for u in us)  # noqa: E731
    realised = {}
    for v in words(0, 8):
        realised.setdefault(sig(v), v)
    # transition sigma -> sigma_a (well defined: check on all realisations)
    trans = {}
    for v in words(0, 7):
        for a in "01":
            key = (sig(v), a)
            val = sig(a + v)
            assert trans.setdefault(key, val) == val, "signature does not determine the next one"

    def lit(u, x, val):
        t = f"{u}.{x}"
        return f"R {t}" if val else f"N R {t}"

    def S(sigma, x):
        return [lit(u, x, val) for u, val in zip(us, sigma)]

    sentences = []
    for L in S(sig(""), "e"):
        sentences.append(L)
    for sigma in realised:
        for a in "01":
            prem = S(sigma, "x")
            for L in S(trans[(sigma, a)], "x"):
                # conclusion about s_a x: R(s_u(s_a x)), the term with word u followed by a
                parts = L.split(" ")
                parts[-1] = parts[-1][:-2] + a + ".x"
                body = " ".join(parts)
                for P in reversed(prem):
                    body = f"I {P} {body}"
                sentences.append(f"A x {body}")
    return n, us, sig, trans, sentences


def window(us):
    return max(len(u) for u in us) + 1


def truth(s, X, xmax=9):
    """Truth of a sentence of the signature theory in the term model (T, X), quantifier over |x| <= xmax."""
    f = HC.parse(s)

    def val(g, env):
        k = g[0]
        if k == "R":
            word, base = g[1]
            w = word + (env[base] if base != "e" else "")
            return X(w)
        if k == "N":
            return not val(g[1], env)
        if k == "I":
            return (not val(g[1], env)) or val(g[2], env)
        if k == "A":
            return all(val(g[2], dict(env, **{g[1]: x})) for x in words(0, xmax))
        raise ValueError(k)

    return val(f, {})


def derive_signature(n, us, sig, trans, sentences, w):
    lines, idx = [], {}

    def add(s, j):
        lines.append((s, j))
        return len(lines) - 1

    def ax(s):
        if s not in idx:
            idx[s] = add(s, ("ax",))
        return idx[s]

    def mp(i, j):
        s, a = lines[j][0], lines[i][0]
        assert s.startswith("I " + a + " ")
        return add(s[len(a) + 3:], ("MP", i, j))

    def lit(u, v, val):
        t = f"{u}{v}.e"
        return f"R {t}" if val else f"N R {t}"

    # current literals S_{sig(v)}(t_v), v = suffix of w
    v = ""
    cur = {u: ax(lit(u, "", val)) for u, val in zip(us, sig(""))}
    for a in reversed(w):
        sigma = sig(v)
        new = {}
        for u, val in zip(us, trans[(sigma, a)]):
            # the sentence with conclusion L(s_u s_a x) for this u (membership is checked by the checker)
            prem = [(f"R {uu}.x" if vv else f"N R {uu}.x") for uu, vv in zip(us, sigma)]
            concl = f"R {u}{a}.x" if val else f"N R {u}{a}.x"
            body = concl
            for P in reversed(prem):
                body = f"I {P} {body}"
            sent = f"A x {body}"
            i = ax(sent)
            a4 = add(f"I {sent} " + " ".join((t.split('.')[0] + v + ".e") if t.endswith(".x") else t
                                             for t in body.split(" ")), ("A4",))
            k = mp(i, a4)
            for uu in us:
                k = mp(cur[uu], k)
            new[u] = k
        cur = new
        v = a + v
    return lines, cur[""]


def part_a():
    log("== Part A: signature theories for two regular languages ==")
    ok = True
    for name, X in (("XA (contains 010)", XA), ("XB (third letter is 1)", XB)):
        n, us, sig, trans, sentences = signature_theory(X)
        realised = len({sig(v) for v in words(0, 8)})
        members = set(sentences)
        nfalse = sum(1 for s in sentences if not truth(s, X))
        bad = 0
        maxlines = maxline = 0
        for w in words(0, 9):
            lines, last = derive_signature(n, us, sig, trans, sentences, w)
            res, msg, parsed = HC.check(lines, lambda s, f: s in members)
            want = HC.parse(f"R {w}.e" if X(w) else f"N R {w}.e")
            if not res or parsed[last] != want:
                bad += 1
            maxlines = max(maxlines, len(lines))
            maxline = max(maxline, max(HC.size(f) for f in parsed))
        log(f"  {name}: residual classes n = {n} (realised signatures {realised}, separating window |u| < "
            f"{window(us)}); theory of {len(sentences)} "
            f"sentences, false in (T, X) on |x| <= 9: {nfalse}; derivations of all 1023 data with |w| <= 9: "
            f"invalid {bad}; max lines {maxlines}; max line size {maxline}")
        ok &= nfalse == 0 and bad == 0
    return ok


def part_b():
    log("== Part B: windowed residual counts (|v| <= d, window |u| <= d) ==")
    ok = True
    rows = []
    for name, X in (("XA", XA), ("XB", XB), ("EQ' = 0^n1^n", EQP), ("PAL", PAL), ("EQ", EQ)):
        counts = [len(set(residual_classes(X, d, d).values())) for d in (2, 4, 6, 8)]
        rows.append((name, counts))
        log(f"  {name}: d = 2, 4, 6, 8 -> {counts}")
    ok &= rows[0][1][-1] == rows[0][1][-2] and rows[1][1][-1] == rows[1][1][-2]
    ok &= all(r[1][0] < r[1][1] < r[1][2] < r[1][3] for r in rows[2:])
    return ok


def part_c():
    log("== Part C: a binary observable relation E (notes.md: J; Prop 9.3) ==")
    Etrue = lambda u, v: u.count("0") == v.count("1")  # noqa: E731
    sents = [
        "E .e .e",
        "A y N E .e 1.y",
        "A y I E .e .y E .e 0.y",
        "A y I N E .e .y N E .e 0.y",
        "A x N E 0.x .e",
        "A x I E .x .e E 1.x .e",
        "A x I N E .x .e N E 1.x .e",
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

    def truth(s, xmax=6):
        f = HC.parse(s)

        def tv(t, env):
            return t[0] + (env[t[1]] if t[1] != "e" else "")

        def val(g, env):
            k = g[0]
            if k == "E":
                return Etrue(tv(g[1], env), tv(g[2], env))
            if k == "R":
                w = tv(g[1], env)
                return Etrue(w, w)
            if k == "N":
                return not val(g[1], env)
            if k == "I":
                return (not val(g[1], env)) or val(g[2], env)
            return all(val(g[2], dict(env, **{g[1]: x})) for x in words(0, xmax))

        return val(f, {})

    nfalse = sum(1 for s in sents if not truth(s))

    # derivations of E(t_u, t_v)^{[#0(u) = #1(v)]} by recursion on (u, v)
    def derive_E(u, v, lines, memo):
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

        key = (u, v)
        if key in memo:
            return memo[key]
        val = Etrue(u, v)
        neg = "" if val else "N "
        if u == "" and v == "":
            k = add("E .e .e", ("ax",))
        elif u == "" and v[0] == "1":
            k = use("A y N E .e 1.y", [v[1:]])
        elif u == "" and v[0] == "0":
            p = derive_E("", v[1:], lines, memo)
            k = mp(p, use(f"A y I {neg}E .e .y {neg}E .e 0.y", [v[1:]]))
        elif u[0] == "0" and v == "":
            k = use("A x N E 0.x .e", [u[1:]])
        elif u[0] == "1":
            p = derive_E(u[1:], v, lines, memo)
            if v == "":
                k = mp(p, use(f"A x I {neg}E .x .e {neg}E 1.x .e", [u[1:]]))
            else:
                k = mp(p, use(f"A x A y I {neg}E .x .y {neg}E 1.x .y", [u[1:], v]))
        elif v[0] == "1":   # u = 0u'
            p = derive_E(u[1:], v[1:], lines, memo)
            k = mp(p, use(f"A x A y I {neg}E .x .y {neg}E 0.x 1.y", [u[1:], v[1:]]))
        else:               # u = 0u', v = 0v'
            p = derive_E(u, v[1:], lines, memo)
            k = mp(p, use(f"A x A y I {neg}E 0.x .y {neg}E 0.x 0.y", [u[1:], v[1:]]))
        memo[key] = k
        return k

    badE = 0
    for u in words(0, 5):
        for v in words(0, 5):
            lines = []
            derive_E(u, v, lines, {})
            res, msg, parsed = HC.check(lines, lambda s, f: s in members)
            want = HC.parse(f"E {u}.e {v}.e" if Etrue(u, v) else f"N E {u}.e {v}.e")
            if not res or parsed[-1] != want:
                badE += 1
    badR = 0
    for w in words(0, 9):
        lines = []
        k = derive_E(w, w, lines, {})
        neg = "" if EQ(w) else "N "
        lines.append((f"A x I {neg}E .x .x {neg}R .x", ("ax",)))
        a = len(lines) - 1
        lines.append((f"I A x I {neg}E .x .x {neg}R .x I {neg}E {w}.e {w}.e {neg}R {w}.e", ("A4",)))
        lines.append((f"I {neg}E {w}.e {w}.e {neg}R {w}.e", ("MP", a, len(lines) - 1)))
        lines.append((f"{neg}R {w}.e", ("MP", k, len(lines) - 1)))
        res, msg, parsed = HC.check(lines, lambda s, f: s in members)
        if not res or parsed[-1] != HC.parse(f"{neg}R {w}.e"):
            badR += 1
    # residuals of E: E_{(v, v')} := {(u, u') : E(uv, u'v')}; count distinct windowed residuals
    counts = []
    for dep in (2, 3, 4):
        us = list(words(0, dep))
        res = {(v, v2): tuple(Etrue(a + v, b + v2) for a in us for b in us)
               for v in words(0, dep) for v2 in words(0, dep)}
        counts.append(len(set(res.values())))
    log(f"  {len(sents)} sentences in the observational language {{e, s0, s1, R, E}}, false in the term model "
        f"(quantifiers over |x|, |y| <= 6): {nfalse}")
    log(f"  derivations of all E-literals with |u|, |v| <= 5: invalid {badE}; of all R-literals (R = EQ) with "
        f"|w| <= 9: invalid {badR}")
    log(f"  distinct windowed residuals E_(v,v') (window |u|, |u'| <= d) over |v|, |v'| <= d, d = 2, 3, 4: {counts}")
    return nfalse == 0 and badE == 0 and badR == 0 and counts[0] < counts[1] < counts[2]


def main():
    log("t4_regular.py -- regular languages, residuals, and a binary observable")
    ok = part_a()
    ok &= part_b()
    ok &= part_c()
    log("")
    log("all checks passed" if ok else "SOME CHECK FAILED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
