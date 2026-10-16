"""Referee A check: does a form outside the hand-picked pool beat the pool in syntax S1?  Seeded (20261016);
writes ra2_series.out.

Form "series2": the equation-of-centre series truncated at second order,
    theta = Lt + 2 e sin M + (5/4) e^2 sin 2M,   Lt = L + n t,  M = Lt - w      (4 elements e, w, L, n),
and "series3" (third order: + e^3 ((13/12) sin 3M - (1/4) sin M)).  Their S1 texts are written as s-expressions in
c4's S1 alphabet (numerals 0, 1, 2 only, so 5/4 = (2+2+1)/(2+2) etc.) and counted with c4's own token rule
(brackets counted) and without brackets.  Minimax error against the c4 data (plan94 Mars, 1580-1600 daily) by
c4's own fitting routine (multi-start LM, L_p refinement, sequential-LP polish).
"""
import sys, os, math, time
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "checks"))
import c4_mars_pool as c4  # noqa: E402

SEED = 20261016
rng = np.random.default_rng(SEED)
out = []


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s)
    out.append(s)


T0 = time.time()
orig_lon = c4.lon


def lon2(form, Pm, tt):
    Pm = np.atleast_2d(Pm)
    if form in ("series2", "series3"):
        e, w, L, n = (Pm[:, i:i + 1] for i in range(4))
        Lt = L + n * tt
        M = Lt - w
        th = Lt + 2 * e * np.sin(M) + 1.25 * e ** 2 * np.sin(2 * M)
        if form == "series3":
            th = th + e ** 3 * ((13.0 / 12.0) * np.sin(3 * M) - 0.25 * np.sin(M))
        return th
    return orig_lon(form, Pm, tt)


c4.lon = lon2
c4.NAMES["series2"] = ["e", "w", "L", "n"]
c4.NAMES["series3"] = ["e", "w", "L", "n"]

el, Lt, Mt = c4.el, c4.Lt, c4.Mt
five = ["+", "2", ["+", "2", "1"]]
four = ["+", "2", "2"]
twelve = ["*", ["+", "2", "1"], four]
thirteen = ["+", twelve, "1"]
e2 = ["*", el("e"), el("e")]
e3 = ["*", el("e"), e2]
t1 = ["*", ["*", "2", el("e")], ["sin", Mt]]
t2 = ["*", ["*", ["/", five, four], e2], ["sin", ["*", "2", Mt]]]
s2 = c4.pre(["+", Lt, ["+", t1, t2]])
t3 = ["*", e3, ["-", ["*", ["/", thirteen, twelve], ["sin", ["*", ["+", "2", "1"], Mt]]], ["*", ["/", "1", four], ["sin", Mt]]]]
s3 = c4.pre(["+", Lt, ["+", t1, ["+", t2, t3]]])


def nobr(x):
    return 1 if isinstance(x, str) else sum(nobr(y) for y in x)


for name, x in (("series2", s2), ("series3", s3)):
    assert c4.atoms(x) <= set(c4.ALPHABET["S1"]), c4.atoms(x) - set(c4.ALPHABET["S1"])
    P("%-8s S1 tokens (brackets) %d = %d bits;  Polish %d tokens = %d bits   [ellipse: 545 / 245 bits]"
      % (name, c4.tokens(x), c4.tokens(x) * 5, nobr(x), nobr(x) * 5))

t = np.arange((1580.0 - 2000.0) * c4.YEAR, (1600.0 - 2000.0) * c4.YEAR + 1e-9, 1.0)
N = len(t)
tt = t - 0.5 * (t[0] + t[-1])
theta, r, incl, node, oop = c4.mars_helio_plane(t)
n0 = c4.TWO_PI / 686.98
w0 = theta[np.argmin(r)] % c4.TWO_PI
L0 = theta[N // 2] % c4.TWO_PI
e0 = (r.max() - r.min()) / (r.max() + r.min())
for form in ("series2", "series3"):
    st = []
    for j in range(8):
        jit = rng.normal(size=4)
        st.append(np.array([abs(e0 * (1 + 0.3 * jit[0])), w0 + 0.2 * jit[1], L0 + 0.05 * jit[2], n0 * (1 + 1e-4 * jit[3])]))
    x, mx = c4.fit_minimax(form, tt, theta, st)
    P("%-8s minimax error vs plan94 %.3f'  (elements e=%.5f)" % (form, mx / c4.ARCMIN, x[0]))
P("# done in %.0f s" % (time.time() - T0))
with open(os.path.join(HERE, "ra2_series.out"), "w") as fh:
    fh.write("\n".join(out) + "\n")
