"""rb2_law_texts.py -- referee B for thread `philosophy`: are the written-down law texts of c4 (notes.md
section 4.4, "The written-down syntax") faithful to the law forms whose fits and Occam factors are
computed?  Seed 20261016.  Writes rb2_law_texts.out next to itself.

Method (independent of c4's numerical model code):
  * the five law forms are implemented here from their geometric definitions:
      circle     theta = L + n t
      eccentric  uniform motion on the unit circle about the centre C = -e u(w)    (u(x) = (cos x, sin x))
      equant     (bisected) centre C = -e u(w), equant Q = -2e u(w); the planet is on the unit circle
                 about C, on the ray from Q at angle L + n t
      vicarious  centre C = -e1 u(w), equant Q = -(e1+e2) u(w)  (the parametrisation of c4's S2 text
                 and of c4's numerical model, as its docstring states)
      ellipse    theta = w + true anomaly, Kepler's equation E - e sin E = L + n t - w
    (w is the longitude of perihelion: the point of the circle nearest the Sun is in direction w);
  * c4's law texts (the s-expressions in TEXTS, imported from ../checks/c4_mars_pool.py; nothing else of
    c4 is used) are evaluated by a generic s-expression interpreter written here; existential
    quantifiers are solved numerically (all roots in a wide bracket, filtered by the side conditions);
  * the two are compared at random elements and times;
  * tokens are recounted with an own counter, and a corrected S1 equant text is counted.
"""
import math
import os
import sys

import numpy as np
from scipy.optimize import brentq

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "checks"))
import c4_mars_pool as c4  # noqa: E402  (only TEXTS, K3, ALPHABET are used)

SEED = 20261016
rng = np.random.default_rng(SEED)
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


def u(x):
    return np.array([math.cos(x), math.sin(x)])


def ray_circle(Q, C, ang):
    """point Q + s u(ang), s > 0, on the unit circle about C (unique when |Q - C| < 1)."""
    d = Q - C
    v = u(ang)
    b = float(d @ v)
    disc = b * b - (float(d @ d) - 1.0)
    s = -b + math.sqrt(disc)
    return Q + s * v


def kepler(M, e):
    E = M
    for _ in range(100):
        E = E - (E - e * math.sin(E) - M) / (1 - e * math.cos(E))
    return E


def geo(form, el, t):
    if form == "circle":
        L, n = el
        return L + n * t
    if form == "ellipse":
        e, w, L, n = el
        M = L + n * t - w
        E = kepler(M, e)
        nu = math.atan2(math.sqrt(1 - e * e) * math.sin(E), math.cos(E) - e)
        return w + nu
    if form == "eccentric":
        e, w, L, n = el
        P = -e * u(w) + u(L + n * t)
        return math.atan2(P[1], P[0])
    if form == "equant":
        e, w, L, n = el
        P = ray_circle(-2 * e * u(w), -e * u(w), L + n * t)
        return math.atan2(P[1], P[0])
    if form == "vicarious":
        e1, e2, w, L, n = el
        P = ray_circle(-(e1 + e2) * u(w), -e1 * u(w), L + n * t)
        return math.atan2(P[1], P[0])
    raise ValueError(form)


# ------------------------------------------------------------------ s-expression interpreter
NUM = {"0": 0.0, "1": 1.0, "2": 2.0}


def ev(x, env):
    if isinstance(x, str):
        if x in NUM:
            return NUM[x]
        return env[x]
    op = x[0]
    if len(x) == 2 and x[1] == "b" and op in ("L", "n", "w", "e", "e1", "e2", "a"):
        return env["el:" + op]
    if op == "theta":
        raise RuntimeError("theta evaluated")
    a = [ev(y, env) for y in x[1:]]
    if op == "+":
        return a[0] + a[1]
    if op == "-":
        return -a[0] if len(a) == 1 else a[0] - a[1]
    if op == "*":
        return a[0] * a[1]
    if op == "/":
        return a[0] / a[1]
    if op == "sin":
        return math.sin(a[0])
    if op == "cos":
        return math.cos(a[0])
    if op == "sqrt":
        return math.sqrt(a[0])
    if op == "atan2":
        return math.atan2(a[0], a[1])
    if op == "uc":
        return u(a[0])
    if op == "dir":
        return math.atan2(a[0][1], a[0][0])
    if op == "rc":
        return ray_circle(a[0], a[1], a[2])
    if op == "kep":
        e, M = a
        E = kepler(M, e)
        return math.atan2(math.sqrt(1 - e * e) * math.sin(E), math.cos(E) - e)
    raise ValueError(op)


def conjuncts(x):
    if isinstance(x, list) and x[0] == "and":
        return conjuncts(x[1]) + conjuncts(x[2])
    return [x]


def is_theta(x):
    return isinstance(x, list) and x[0] == "theta"


def predict(text, el_env, t):
    """theta predicted by a text 'forall b forall t BODY' at time t; returns the list of values
    (one per witness of the existential quantifier, if any)."""
    assert text[0] == "forall" and text[2][0] == "forall"
    body = text[2][2]
    env = dict(el_env)
    env["t"] = t
    if body[0] == "=" and is_theta(body[1]):
        return [ev(body[2], env)]
    assert body[0] == "exists"
    var = body[1]
    cs = conjuncts(body[2])
    th_eq = [c for c in cs if c[0] == "=" and is_theta(c[1])]
    eqs = [c for c in cs if c[0] == "=" and not is_theta(c[1])]
    gts = [c for c in cs if c[0] == ">"]
    assert len(th_eq) == 1 and len(eqs) == 1

    def f(v):
        env[var] = v
        return ev(eqs[0][1], env) - ev(eqs[0][2], env)
    M_guess = env["el:L"] + env["el:n"] * t
    lo, hi = (M_guess - 20.0, M_guess + 20.0) if var == "E" else (-20.0, 20.0)
    grid = np.linspace(lo, hi, 40001)
    vals = [f(v) for v in grid]
    roots = []
    for i in range(len(grid) - 1):
        if vals[i] == 0:
            roots.append(grid[i])
        elif vals[i] * vals[i + 1] < 0:
            roots.append(brentq(f, grid[i], grid[i + 1], xtol=1e-14))
    res = []
    for r in roots:
        env[var] = r
        if all(ev(g[1], env) > ev(g[2], env) for g in gts):
            res.append(ev(th_eq[0][2], env))
    return res


def wrapd(x):
    return (x + math.pi) % (2 * math.pi) - math.pi


def tokens(x):
    return 1 if isinstance(x, str) else 2 + sum(tokens(y) for y in x)


def atoms(x, acc):
    if isinstance(x, str):
        acc.add(x)
    else:
        for y in x:
            atoms(y, acc)
    return acc


NAMES = {"circle": ["L", "n"], "eccentric": ["e", "w", "L", "n"], "equant": ["e", "w", "L", "n"],
         "vicarious": ["e1", "e2", "w", "L", "n"], "ellipse": ["e", "w", "L", "n"]}


def random_el(form):
    d = {"e": rng.uniform(0.0, 0.3), "e1": rng.uniform(0.0, 0.3), "e2": rng.uniform(0.0, 0.3),
         "w": rng.uniform(0, 2 * math.pi), "L": rng.uniform(0, 2 * math.pi), "n": rng.uniform(0.005, 0.02)}
    return [d[k] for k in NAMES[form]]


def main():
    out("# rb2_law_texts.py  seed=%d  python %s  numpy %s" % (SEED, sys.version.split()[0], np.__version__))
    out("== (1) faithfulness: c4's law text against the geometric form, 40 random (elements, t) per cell")
    out("   form        syntax  max |theta_text - theta_form| (deg)   witnesses per point")
    worst = {}
    for form in ["circle", "eccentric", "equant", "vicarious", "ellipse"]:
        for S in ["S1", "S2", "S3"]:
            text = c4.TEXTS[S][form]
            md = 0.0
            nw = set()
            for _ in range(40):
                el = random_el(form)
                t = rng.uniform(-3650, 3650)
                env = {"el:" + k: v for k, v in zip(NAMES[form], el)}
                preds = predict(text, env, t)
                nw.add(len(preds))
                g = geo(form, el, t)
                md = max(md, max(abs(wrapd(p - g)) for p in preds))
            worst[(form, S)] = md
            out("   %-10s  %s     %12.3e                         %s" % (form, S, math.degrees(md), sorted(nw)))
    out("== (2) the S1 (= S3) equant and vicarious texts: which geometric model do they describe?")
    out("   S1 text eqv_S1(X, Y) puts the equant at distance X + Y and the centre at distance X from the Sun.")
    md_eq3 = md_vic = 0.0
    for _ in range(40):
        e = rng.uniform(0.0, 0.3)
        w, L, n = rng.uniform(0, 2 * math.pi), rng.uniform(0, 2 * math.pi), rng.uniform(0.005, 0.02)
        t = rng.uniform(-3650, 3650)
        env = {"el:e": e, "el:w": w, "el:L": L, "el:n": n}
        p = predict(c4.TEXTS["S1"]["equant"], env, t)[0]
        g = geo("vicarious", [2 * e, e, w, L, n], t)            # centre 2e, equant 3e
        md_eq3 = max(md_eq3, abs(wrapd(p - g)))
        e1, e2 = rng.uniform(0.0, 0.3), rng.uniform(0.0, 0.3)
        env = {"el:e1": e1, "el:e2": e2, "el:w": w, "el:L": L, "el:n": n}
        p = predict(c4.TEXTS["S1"]["vicarious"], env, t)[0]
        g = geo("vicarious", [e1 + e2, e2, w, L, n], t)         # centre e1+e2, equant e1+2e2
        md_vic = max(md_vic, abs(wrapd(p - g)))
    out("   S1 equant text with element e  ==  vicarious form with centre 2e, equant 3e:  max diff %.3e deg" % math.degrees(md_eq3))
    out("   S1 vicarious text with (e1,e2) ==  vicarious form with centre e1+e2, equant e1+2e2: max diff %.3e deg" % math.degrees(md_vic))
    # size of the discrepancy at Mars-like elements
    e = 0.0934
    diffs = []
    for M in np.linspace(0, 2 * math.pi, 721):
        env = {"el:e": e, "el:w": 0.0, "el:L": M, "el:n": 0.0}
        p = predict(c4.TEXTS["S1"]["equant"], env, 0.0)[0]
        g = geo("equant", [e, 0.0, M, 0.0], 0.0)
        diffs.append(abs(wrapd(p - g)))
    out("   at e = 0.0934 (Mars), the S1 equant text and the bisected equant differ by up to %.1f arcmin "
        "for the same elements" % (math.degrees(max(diffs)) * 60))
    out("== (3) token counts (own counter; atoms + 2 brackets per compound) and alphabets")
    for S in ["S1", "S2", "S3"]:
        A = len(c4.ALPHABET[S])
        bpt = math.ceil(math.log2(A))
        row = []
        for form in ["circle", "eccentric", "equant", "vicarious", "ellipse"]:
            tx = c4.TEXTS[S][form]
            assert atoms(tx, set()) <= set(c4.ALPHABET[S])
            row.append("%s %d tok/%d bits" % (form, tokens(tx), tokens(tx) * bpt))
        row.append("K3 %d tok/%d bits" % (tokens(c4.K3), tokens(c4.K3) * bpt))
        out("   %s (alphabet %d, %d bits/token): %s" % (S, A, bpt, "; ".join(row)))
    # corrected S1 equant texts
    eb = c4.el("e")
    corr_a = c4.eqv_S1(eb, eb)                             # equant at e + e, centre at e
    env = {"el:e": 0.0934, "el:w": 1.0, "el:L": 2.0, "el:n": 0.01}
    ok_a = abs(wrapd(predict(corr_a, env, 100.0)[0] - geo("equant", [0.0934, 1.0, 2.0, 0.01], 100.0)))
    # variant writing the equant distance as (* 2 (e b)) directly: rebuild the body by hand
    Mt, Lt = c4.Mt, c4.Lt
    ee, ec = ["*", "2", eb], eb
    body = ["and", [">", "s", "0"],
            ["and", ["=", ["+", ["-", ["*", "s", "s"], ["*", "2", ["*", ec, ["*", "s", ["cos", Mt]]]]], ["*", ec, ec]], "1"],
             ["=", ["theta", "b", "t"],
              ["atan2", ["+", ["-", ["*", ee, ["sin", c4.el("w")]]], ["*", "s", ["sin", Lt]]],
                        ["+", ["-", ["*", ee, ["cos", c4.el("w")]]], ["*", "s", ["cos", Lt]]]]]]]
    corr_b = ["forall", "b", ["forall", "t", ["exists", "s", body]]]
    ok_b = abs(wrapd(predict(corr_b, env, 100.0)[0] - geo("equant", [0.0934, 1.0, 2.0, 0.01], 100.0)))
    out("   corrected S1 equant text eqv_S1(e, e): %d tokens = %d bits (S1, S3); check vs geometry %.1e rad"
        % (tokens(corr_a), 5 * tokens(corr_a), ok_a))
    out("   corrected S1 equant text with equant distance (* 2 (e b)): %d tokens = %d bits; check %.1e rad"
        % (tokens(corr_b), 5 * tokens(corr_b), ok_b))
    out("   (c4 / notes.md table: S1 equant 206 tokens = 1030 bits)")
    out("# done")


if __name__ == "__main__":
    main()
    with open(os.path.join(HERE, "rb2_law_texts.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
