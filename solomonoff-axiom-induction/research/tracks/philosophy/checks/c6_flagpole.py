"""c6_flagpole.py -- the flagpole tie on a small explicit pool (thread `philosophy`, T3, notes.md 3.2).

Deterministic (seed 20261015 for the random data sets).  Writes c6_flagpole.out next to itself.

Setting (notes.md Prop 3.1).  Poles p_1..p_N with heights a_i; t = tan(elevation) is written as a
numeral, so the law is linear:  Lambda_h := forall p forall t>0 ( s(p,t) * t = h(p) ), with
s(p,t) the shadow length when tan(elevation) = t.  (Revision 2026-10-16: the development docstring said
"cot(elevation)"; the law s*t = h makes t the tangent, as in the record (referee B, issue 13).  Docstring only;
the output is unchanged.)
Equivalent formulation  Lambda_s := forall p forall t>0 ( s(p,t)*t = s(p,1) )  and  forall p h(p) = s(p,1).
Theories (each a law plus N initial conditions):
  T_H  = Lambda_h + { h(p_i) = a_i }          T_S  = Lambda_h + { s(p_i,1) = a_i }
  T_H' = Lambda_s + { h(p_i) = a_i }          T_S' = Lambda_s + { s(p_i,1) = a_i }
Causal extensions (intervention vocabulary s_H(p,t,v): shadow after the height of p is set to v;
h_S(p,v): height after the shadow s(p,1) is set to v by an intervention on the shadow):
  C_H = T_H + { s_H(p,t,v)*t = v ,  h_S(p,v) = h(p) }      (height exogenous)
  C_S = T_S + { s_H(p,t,v)*t = s(p,1)*t ... i.e. s_H(p,t,v) = s(p,t),  h_S(p,v) = v }   (shadow exogenous)

What is checked, by exact rational linear algebra on ground instances:
  (1) on 500 random data sets of shadow and height equations (true and false ones), the four
      theories T_H, T_S, T_H', T_S' prove, refute and leave open exactly the same data
      (they are deductively equivalent: Prop 3.1(a));
  (2) the least number of law instances in a derivation of each kind of datum, under the two
      formulations (Prop 3.1(b)): the theory whose initial conditions sit at the hub of the law's
      formulation needs one instance per shadow datum, the other needs two;
  (3) token lengths of the four theories (the code-length tie up to a constant independent of N);
  (4) one interventional datum separates C_H from C_S (Prop 3.1(c)), while their observational
      consequences coincide.
"""
from fractions import Fraction as Fr
from itertools import combinations
import random
import sys

SEED = 20261015
OUT = []


def p(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


# A ground linear equation is a dict {var: coeff} with a constant: sum coeff*var = const.
def solve_status(eqs, target):
    """does the linear system eqs entail target (sum c v = k)?  returns 'proves', 'refutes', 'open',
    or 'inconsistent'.  Exact Gaussian elimination over Q."""
    vars_ = sorted({v for e, _ in eqs for v in e} | set(target[0]))
    idx = {v: i for i, v in enumerate(vars_)}
    rows = []
    for e, k in eqs:
        r = [Fr(0)] * (len(vars_) + 1)
        for v, c in e.items():
            r[idx[v]] += Fr(c)
        r[-1] = Fr(k)
        rows.append(r)
    # row reduce
    m, n = len(rows), len(vars_)
    piv = []
    rr = 0
    for col in range(n):
        pr = next((i for i in range(rr, m) if rows[i][col] != 0), None)
        if pr is None:
            continue
        rows[rr], rows[pr] = rows[pr], rows[rr]
        inv = 1 / rows[rr][col]
        rows[rr] = [x * inv for x in rows[rr]]
        for i in range(m):
            if i != rr and rows[i][col] != 0:
                f = rows[i][col]
                rows[i] = [a - f * b for a, b in zip(rows[i], rows[rr])]
        piv.append(col)
        rr += 1
    for i in range(rr, m):
        if rows[i][-1] != 0:
            return "inconsistent"
    # reduce the target
    t = [Fr(0)] * (n + 1)
    for v, c in target[0].items():
        t[idx[v]] += Fr(c)
    t[-1] = Fr(target[1])
    for i, col in enumerate(piv):
        if t[col] != 0:
            f = t[col]
            t = [a - f * b for a, b in zip(t, rows[i])]
    if all(x == 0 for x in t[:-1]):
        return "proves" if t[-1] == 0 else "refutes"
    return "open"


def law_h(pole, t):            # s(p,t)*t - h(p) = 0
    return ({("s", pole, t): Fr(t), ("h", pole): Fr(-1)}, 0)


def law_s1(pole, t):           # s(p,t)*t - s(p,1) = 0
    return ({("s", pole, t): Fr(t), ("s", pole, 1): Fr(-1)}, 0) if t != 1 else None


def law_s2(pole):              # h(p) - s(p,1) = 0
    return ({("h", pole): Fr(1), ("s", pole, 1): Fr(-1)}, 0)


def instances(form, poles, ts):
    out = []
    for q in poles:
        for t in ts:
            if form == "h":
                out.append((("L", q, t), law_h(q, t)))
            else:
                e = law_s1(q, t)
                if e is not None:
                    out.append((("L1", q, t), e))
        if form == "s":
            out.append((("L2", q), law_s2(q)))
    return out


def ics(kind, a):
    if kind == "H":
        return [({("h", i): 1}, a[i]) for i in a]
    return [({("s", i, 1): 1}, a[i]) for i in a]


def status_all(form, kind, a, poles, ts, datum):
    eqs = ics(kind, a) + [e for _, e in instances(form, poles, ts)]
    return solve_status(eqs, datum)


def min_instances(form, kind, a, poles, ts, datum, kmax=3):
    inst = instances(form, poles, ts)
    base = ics(kind, a)
    for k in range(kmax + 1):
        for sub in combinations(inst, k):
            if solve_status(base + [e for _, e in sub], datum) == "proves":
                return k
    return None


def main():
    p("# c6_flagpole.py  seed=%d  python %s" % (SEED, sys.version.split()[0]))
    rng = random.Random(SEED)
    # (1) equivalence on random data sets
    agree, total = 0, 0
    counts = {"proves": 0, "refutes": 0, "open": 0}
    for trial in range(500):
        N = rng.randint(1, 4)
        poles = list(range(N))
        a = {i: Fr(rng.randint(1, 20), rng.randint(1, 4)) for i in poles}
        ts = sorted({Fr(1)} | {Fr(rng.randint(1, 9), rng.randint(1, 5)) for _ in range(3)})
        # data: shadows at the ts, heights, true or perturbed, and some about an unnamed elevation
        for _ in range(4):
            i = rng.choice(poles)
            t = rng.choice(ts)
            kind = rng.random()
            if kind < 0.45:
                val = a[i] / t + (0 if rng.random() < 0.5 else Fr(1, 7))
                datum = ({("s", i, t): 1}, val)
            elif kind < 0.9:
                val = a[i] + (0 if rng.random() < 0.5 else Fr(1, 3))
                datum = ({("h", i): 1}, val)
            else:
                datum = ({("s", i, Fr(13, 11)): 1}, a[i] * Fr(11, 13))   # an elevation not instantiated
            st = [status_all(f, k, a, poles, ts, datum) for f, k in (("h", "H"), ("h", "S"), ("s", "H"), ("s", "S"))]
            total += 1
            agree += len(set(st)) == 1
            counts[st[0]] += 1
    p("(1) T_H, T_S, T_H', T_S' on 2000 random data (500 data sets x 4): identical status in %d/%d;"
      " proves/refutes/open = %d/%d/%d" % (agree, total, counts["proves"], counts["refutes"], counts["open"]))
    p("    ('open' = a datum at an elevation whose law instance is not in the finite pool; with the instance")
    p("     added, all four prove it: the theories are deductively equivalent, notes.md Prop 3.1(a).)")

    # (2) least number of law instances per datum
    poles = [0]
    a = {0: Fr(6)}
    ts = [Fr(1), Fr(2), Fr(3)]
    data = {"shadow s(p,2) = 3": ({("s", 0, Fr(2)): 1}, Fr(3)),
            "shadow s(p,1) = 6 (reference)": ({("s", 0, Fr(1)): 1}, Fr(6)),
            "height h(p) = 6": ({("h", 0): 1}, Fr(6))}
    p("(2) least number of law instances in a derivation (exhaustive over subsets of the instance pool)")
    p("    %-32s %8s %8s %8s %8s" % ("datum", "T_H", "T_S", "T_H'", "T_S'"))
    for name, d in data.items():
        row = [min_instances(f, k, a, poles, ts, d) for f, k in (("h", "H"), ("h", "S"), ("s", "H"), ("s", "S"))]
        p("    %-32s %8s %8s %8s %8s" % tuple([name] + [str(x) for x in row]))
    p("    law formulation Lambda_h: heights are the hub (T_H needs 1 per shadow datum, T_S needs 2);")
    p("    law formulation Lambda_s: reference shadows are the hub (T_S' needs 1, T_H' needs 2).")

    # (3) token lengths (prefix serialisation: atoms + brackets), N poles
    def toks(x):
        return 1 if isinstance(x, str) else 2 + sum(toks(y) for y in x)
    Lh = ["forall", "p", ["forall", "t", ["->", [">", "t", "0"], ["=", ["*", ["s", "p", "t"], "t"], ["h", "p"]]]]]
    Ls = ["and", ["forall", "p", ["forall", "t", ["->", [">", "t", "0"], ["=", ["*", ["s", "p", "t"], "t"], ["s", "p", "1"]]]]],
          ["forall", "p", ["=", ["h", "p"], ["s", "p", "1"]]]]
    icH = lambda i: ["=", ["h", "c%d" % i], "num"]            # noqa: E731
    icS = lambda i: ["=", ["s", "c%d" % i, "1"], "num"]       # noqa: E731
    p("(3) token counts (numerals counted as one token 'num'): N = 1, 10, 100 poles")
    for N in (1, 10, 100):
        TH = toks(Lh) + sum(toks(icH(i)) for i in range(N))
        TS = toks(Lh) + sum(toks(icS(i)) for i in range(N))
        THp = toks(Ls) + sum(toks(icH(i)) for i in range(N))
        TSp = toks(Ls) + sum(toks(icS(i)) for i in range(N))
        p("    N=%3d  T_H %5d  T_S %5d  T_H' %5d  T_S' %5d   (T_S - T_H = %d tokens: 1 per pole in this literal"
          " syntax; under the universal prior |K(T_S) - K(T_H)| <= c, a fixed translation)" % (N, TH, TS, THp, TSp, TS - TH))
    p("    hub theories T_H and T_S' differ by %d tokens, independently of N (the law texts)."
      % (toks(Ls) - toks(Lh)))

    # (4) interventions
    a1 = Fr(6)
    # C_H: s_H(p,t,v)*t = v ; h_S(p,v) = h(p).   C_S: s_H(p,t,v) = s(p,t) ; h_S(p,v) = v.
    v = 2 * a1
    def CH():
        return [({("h", 0): 1}, a1), law_h(0, Fr(1)),
                ({("sH", 0, Fr(1), v): Fr(1)}, v), ({("hS", 0, v): 1, ("h", 0): -1}, 0)]
    def CS():
        return [({("s", 0, Fr(1)): 1}, a1), law_h(0, Fr(1)),
                ({("sH", 0, Fr(1), v): 1, ("s", 0, Fr(1)): -1}, 0), ({("hS", 0, v): 1}, v)]
    d1 = ({("sH", 0, Fr(1), v): 1}, v)        # doubling the height doubles the reference shadow
    d2 = ({("hS", 0, v): 1}, a1)               # changing the shadow leaves the height unchanged
    obs = [({("h", 0): 1}, a1), ({("s", 0, Fr(1)): 1}, a1)]
    p("(4) interventional data (pole height 6, intervention value v = 12)")
    p("    datum 'do(h := 12): s(p,1) = 12'      C_H %-8s C_S %s" % (solve_status(CH(), d1), solve_status(CS(), d1)))
    p("    datum 'do(s(p,1) := 12): h(p) = 6'    C_H %-8s C_S %s" % (solve_status(CH(), d2), solve_status(CS(), d2)))
    p("    observational data h(p)=6, s(p,1)=6:  C_H %s/%s  C_S %s/%s" % tuple(
        solve_status(T, d) for T in (CH(), CS()) for d in obs))
    p("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
