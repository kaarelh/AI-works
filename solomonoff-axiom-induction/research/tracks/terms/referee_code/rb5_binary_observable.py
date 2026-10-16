#!/usr/bin/env python3
"""rb5_binary_observable.py -- referee B: Proposition 9.3 (one binary observable relation breaks Thm 5.1).

The 15 sentences of notes.md Prop 9.3 are written here from the text, in referee B's syntax (rb_logic), with
the world J := {(t_u, t_v) : #0(u) = #1(v)}, R := EQ = {w : #0 w = #1 w}.
  A  truth of every sentence at all values |x|, |y| <= 7;
  B  derivations (members, A4, MP) of every J-literal with |u|, |v| <= 5 and every R-literal with |w| <= 8,
     built by following the record's seven-case reduction and checked by rb_logic.check;
  C  redundancy: a sentence is reported redundant if it is an instance of another (checked syntactically);
  D  negative control: change the world to J' (#0(u) = #1(v) + 1) and count the sentences that become false.
Deterministic.  Writes rb5_binary_observable.out next to itself.
"""
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rb_logic as L  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb5_binary_observable.out")
LOG = []


def log(x=""):
    print(x)
    LOG.append(x)


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


X, Y = ("v", "x"), ("v", "y")
e = L.E


def s(a, t):
    return L.s(a, t)


def J(a, b):
    return ("at", "J", (a, b))


def Rr(a):
    return ("at", "R", (a,))


def neg(f):
    return ("not", f)


def imp(a, b):
    return ("imp", a, b)


def A(v, f):
    return ("all", v, f)


def theory():
    T = {}
    T["J(e,e)"] = J(e, e)
    T["~J(e,s1y)"] = A("y", neg(J(e, s("1", Y))))
    T["~J(s0x,e)"] = A("x", neg(J(s("0", X), e)))
    pairs = {
        "e,y->e,s0y": (("y",), J(e, Y), J(e, s("0", Y))),
        "x,e->s1x,e": (("x",), J(X, e), J(s("1", X), e)),
        "x,y->s0x,s1y": (("x", "y"), J(X, Y), J(s("0", X), s("1", Y))),
        "s0x,y->s0x,s0y": (("x", "y"), J(s("0", X), Y), J(s("0", X), s("0", Y))),
        "x,y->s1x,y": (("x", "y"), J(X, Y), J(s("1", X), Y)),
    }
    for name, (vs, p, c) in pairs.items():
        for pol in ("+", "-"):
            body = imp(p, c) if pol == "+" else imp(neg(p), neg(c))
            for v in reversed(vs):
                body = A(v, body)
            T[name + pol] = body
    T["J(x,x)->R(x)"] = A("x", imp(J(X, X), Rr(X)))
    T["~J(x,x)->~R(x)"] = A("x", imp(neg(J(X, X)), neg(Rr(X))))
    return T


def world_J(u, v, shift=0):
    return u.count("0") == v.count("1") + shift


def EQ(w):
    return w.count("0") == w.count("1")


def evaluate(F, asg, shift=0):
    k = F[0]
    if k == "at":
        ws = []
        for t in F[2]:
            for var, val in asg.items():
                t = L.subst_t(t, var, L.word_term(val))
            ws.append(L.term_word(t))
        if F[1] == "J":
            return world_J(ws[0], ws[1], shift)
        return EQ(ws[0])
    if k == "not":
        return not evaluate(F[1], asg, shift)
    if k == "imp":
        return (not evaluate(F[1], asg, shift)) or evaluate(F[2], asg, shift)
    raise ValueError(F)


def strip(F):
    vs = []
    while F[0] == "all":
        vs.append(F[1])
        F = F[2]
    return vs, F


def false_instances(T, maxlen, shift=0):
    bad = 0
    for name, F in T.items():
        vs, body = strip(F)
        for vals in itertools.product(list(words(0, maxlen)), repeat=len(vs)):
            if not evaluate(body, dict(zip(vs, vals)), shift):
                bad += 1
    return bad


def derive_J(T, B, u, v, memo):
    """Line deriving J(t_u, t_v) or its negation (whichever is true), by the seven-case reduction."""
    if (u, v) in memo:
        return memo[(u, v)]
    tu, tv = L.word_term(u), L.word_term(v)
    val = world_J(u, v)

    def use(name, vals, prem_line=None):
        k = B.ax(T[name])
        for w in vals:
            k = B.inst(k, L.word_term(w))
        if prem_line is not None:
            k = B.mp(prem_line, k)
        return k
    if u == "" and v == "":
        k = B.ax(T["J(e,e)"])
    elif u == "" and v[0] == "1":
        k = use("~J(e,s1y)", [v[1:]])
    elif u == "" and v[0] == "0":
        k = use("e,y->e,s0y" + ("+" if val else "-"), [v[1:]], derive_J(T, B, "", v[1:], memo))
    elif u[0] == "1":
        if v == "":
            k = use("x,y->s1x,y" + ("+" if val else "-"), [u[1:], ""], derive_J(T, B, u[1:], "", memo))
        else:
            k = use("x,y->s1x,y" + ("+" if val else "-"), [u[1:], v], derive_J(T, B, u[1:], v, memo))
    elif v == "":
        k = use("~J(s0x,e)", [u[1:]])
    elif v[0] == "1":
        k = use("x,y->s0x,s1y" + ("+" if val else "-"), [u[1:], v[1:]], derive_J(T, B, u[1:], v[1:], memo))
    else:
        k = use("s0x,y->s0x,s0y" + ("+" if val else "-"), [u[1:], v[1:]], derive_J(T, B, u, v[1:], memo))
    memo[(u, v)] = k
    return k


def main():
    log("rb5_binary_observable.py -- referee B: Prop 9.3 (a binary observable J)")
    T = theory()
    members = set(T.values())
    ok = True
    log(f"  {len(T)} sentences, all in the observational language {{e, s0, s1, R, J}}")
    bad = false_instances(T, 7)
    log(f"== Part A: false instances in (T, R = EQ, J) at |x|, |y| <= 7: {bad}")
    ok &= bad == 0 and len(T) == 15
    nbad = maxlines = 0
    cnt = 0
    for u in words(0, 5):
        for v in words(0, 5):
            B = L.Builder()
            k = derive_J(T, B, u, v, {})
            good, _ = L.check(B.lines, lambda F: F in members)
            want = J(L.word_term(u), L.word_term(v))
            want = want if world_J(u, v) else neg(want)
            nbad += (not good) or B.lines[k][0] != want
            maxlines = max(maxlines, len(B.lines))
            cnt += 1
    rbad = 0
    rmax = 0
    for w in words(0, 8):
        B = L.Builder()
        k = derive_J(T, B, w, w, {})
        name = "J(x,x)->R(x)" if EQ(w) else "~J(x,x)->~R(x)"
        k2 = B.inst(B.ax(T[name]), L.word_term(w))
        k3 = B.mp(k, k2)
        good, _ = L.check(B.lines, lambda F: F in members)
        want = Rr(L.word_term(w)) if EQ(w) else neg(Rr(L.word_term(w)))
        rbad += (not good) or B.lines[k3][0] != want
        rmax = max(rmax, len(B.lines))
    log(f"== Part B: derivations of {cnt} J-literals (|u|,|v| <= 5): invalid or wrong {nbad}, max lines {maxlines}; "
        f"of 511 R-literals (|w| <= 8): invalid or wrong {rbad}, max lines {rmax}")
    ok &= nbad == 0 and rbad == 0
    # redundancy by instantiation: forall x (J(x,e) -> J(s1x,e)) is forall x forall y (J(x,y) -> J(s1x,y)) at y := e
    red = []
    for pol in "+-":
        gen = T["x,y->s1x,y" + pol]
        spec = T["x,e->s1x,e" + pol]
        inner = ("all", "x", L.subst(gen[2][2], "y", e))
        if inner == spec:
            red.append("x,e->s1x,e" + pol)
    log(f"== Part C: sentences that are instances of another member (redundant): {red}")
    bad_shift = false_instances(T, 5, shift=1)
    log(f"== Part D: control world J' (#0 u = #1 v + 1): false instances {bad_shift} (> 0 expected)")
    ok &= bad_shift > 0
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
