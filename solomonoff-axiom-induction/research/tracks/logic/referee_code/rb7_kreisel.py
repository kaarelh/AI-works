"""rb7_kreisel.py -- referee B (thread `logic`): the line-budget example of notes.md 5.5, checked
with a small Hilbert-proof checker and finite countermodels; and a NON-degenerate variant in
which the instances are not logically valid (referee A, m13(b), asked for one).

No randomness.  Output: rb7_kreisel.out (stdout).

Calculus (the schemas the record's derivation uses, standard in Hilbert calculi):
  (Eq)   t = t
  (ExI)  chi(t) -> Ex y chi(y)         (t substitutable for y in chi)
  (OrR)  beta -> alpha v beta          (OrL) alpha -> alpha v beta
  (AllE) Ax x chi(x) -> chi(t)
  (MP)   from A and A -> B infer B;    (Hyp) the hypothesis psi.
Part 1 (the record's Example; B = empty).  phi(x) := x = 0 v Ey x = Sy.  For n = 0..60 a
  derivation of phi(S^n 0) is built and CHECKED line by line; its length is 5 for n >= 1 and 3 for
  n = 0.  Countermodel to Ax phi: domain {0,1,2,a}, S(0)=1, S(1)=2, S(2)=2, S(a)=0.  Every
  instance phi(S^n 0) is LOGICALLY VALID here, so the data are old evidence (Prop 4.6): this is
  referee A's point m13(b).
Part 2 (non-degenerate; B = empty, a fresh unary predicate R).  Data R(S^n 0) (not valid: the
  structure with R empty refutes them).  psi_1 := Ax (phi(x) -> R(x)) derives every R(S^n 0) in
  9 lines (7 for n = 0), checked; psi_2 := Ax R(x) derives each in 3 lines.  The countermodel of
  Part 1 with R = {0,1,2} satisfies psi_1 and every R(S^n 0) but not Ax R(x).  So with line budget
  l = 9 both psi_1 and psi_2 stay compatible with every finite part of the data, psi_1 does not
  prove Ax R(x), and under any full-support prior the limit belief in Ax R(x) lies strictly
  between 0 and 1: the Kreisel property of Prop 5.4 fails with non-valid instances.
"""


# ------------------------------------------------------------------ syntax
def Z():
    return ("0",)


def S(t):
    return ("S", t)


def num(n):
    t = Z()
    for _ in range(n):
        t = S(t)
    return t


def Var(v):
    return ("var", v)


def Eq(a, b):
    return ("=", a, b)


def Or(a, b):
    return ("or", a, b)


def Imp(a, b):
    return ("imp", a, b)


def Ex(v, f):
    return ("ex", v, f)


def All(v, f):
    return ("all", v, f)


def Rp(t):
    return ("R", t)


def subst(f, v, t):
    """Substitute term t for free variable v (t closed here, so no capture)."""
    tag = f[0]
    if tag == "var":
        return t if f[1] == v else f
    if tag == "0":
        return f
    if tag == "S":
        return ("S", subst(f[1], v, t))
    if tag in ("=",):
        return (tag, subst(f[1], v, t), subst(f[2], v, t))
    if tag == "R":
        return ("R", subst(f[1], v, t))
    if tag in ("or", "imp"):
        return (tag, subst(f[1], v, t), subst(f[2], v, t))
    if tag in ("ex", "all"):
        return f if f[1] == v else (tag, f[1], subst(f[2], v, t))
    raise ValueError(tag)


def closed_term(t):
    return t[0] == "0" or (t[0] == "S" and closed_term(t[1]))


# ------------------------------------------------------------------ checker
def check(lines, hyps=()):
    """lines: list of (formula, rule, info).  Returns True iff every line is justified."""
    for i, (f, rule, info) in enumerate(lines):
        if rule == "Hyp":
            ok = f in hyps
        elif rule == "Eq":
            ok = f[0] == "=" and f[1] == f[2]
        elif rule == "ExI":                       # info = (y, chi, t)
            y, chi, t = info
            ok = closed_term(t) and f == Imp(subst(chi, y, t), Ex(y, chi))
        elif rule == "OrR":
            ok = f[0] == "imp" and f[2][0] == "or" and f[2][2] == f[1]
        elif rule == "OrL":
            ok = f[0] == "imp" and f[2][0] == "or" and f[2][1] == f[1]
        elif rule == "AllE":                      # info = t
            ok = (f[0] == "imp" and f[1][0] == "all" and closed_term(info)
                  and f[2] == subst(f[1][2], f[1][1], info))
        elif rule == "MP":                        # info = (j, k): line j is A, line k is A -> f
            j, k = info
            ok = j < i and k < i and lines[k][0] == Imp(lines[j][0], f)
        else:
            ok = False
        if not ok:
            return False
    return True


x, y = "x", "y"
phi = Or(Eq(Var(x), Z()), Ex(y, Eq(Var(x), S(Var(y)))))


def deriv_phi(n, offset=0):
    """Derivation of phi(S^n 0); line indices shifted by offset."""
    t = num(n)
    if n == 0:
        return [
            (Eq(t, t), "Eq", None),
            (Imp(Eq(t, t), subst(phi, x, t)), "OrL", None),
            (subst(phi, x, t), "MP", (offset + 0, offset + 1)),
        ]
    chi = Eq(t, S(Var(y)))
    tm = num(n - 1)
    return [
        (Eq(t, t), "Eq", None),
        (Imp(subst(chi, y, tm), Ex(y, chi)), "ExI", (y, chi, tm)),
        (Ex(y, chi), "MP", (offset + 0, offset + 1)),
        (Imp(Ex(y, chi), subst(phi, x, t)), "OrR", None),
        (subst(phi, x, t), "MP", (offset + 2, offset + 3)),
    ]


psi1 = All(x, Imp(phi, Rp(Var(x))))
psi2 = All(x, Rp(Var(x)))


def deriv_R_from_psi1(n):
    t = num(n)
    head = [
        (psi1, "Hyp", None),
        (Imp(psi1, Imp(subst(phi, x, t), Rp(t))), "AllE", t),
        (Imp(subst(phi, x, t), Rp(t)), "MP", (0, 1)),
    ]
    body = deriv_phi(n, offset=3)
    last = len(head) + len(body) - 1
    return head + body + [(Rp(t), "MP", (last, 2))]


def deriv_R_from_psi2(n):
    t = num(n)
    return [
        (psi2, "Hyp", None),
        (Imp(psi2, Rp(t)), "AllE", t),
        (Rp(t), "MP", (0, 1)),
    ]


# ------------------------------------------------------------------ semantics on a finite structure
def ev_term(t, M, env):
    if t[0] == "0":
        return M["zero"]
    if t[0] == "S":
        return M["S"][ev_term(t[1], M, env)]
    if t[0] == "var":
        return env[t[1]]
    raise ValueError(t)


def ev(f, M, env):
    tag = f[0]
    if tag == "=":
        return ev_term(f[1], M, env) == ev_term(f[2], M, env)
    if tag == "R":
        return ev_term(f[1], M, env) in M["R"]
    if tag == "or":
        return ev(f[1], M, env) or ev(f[2], M, env)
    if tag == "imp":
        return (not ev(f[1], M, env)) or ev(f[2], M, env)
    if tag == "ex":
        return any(ev(f[2], M, {**env, f[1]: d}) for d in M["dom"])
    if tag == "all":
        return all(ev(f[2], M, {**env, f[1]: d}) for d in M["dom"])
    raise ValueError(tag)


def main():
    print("== Part 1: the record's Example (B = empty) ==")
    lens = {}
    ok = True
    for n in range(0, 61):
        d = deriv_phi(n)
        ok &= check(d) and d[-1][0] == subst(phi, x, num(n))
        lens[len(d)] = lens.get(len(d), 0) + 1
    print(f"  derivations of phi(S^n 0), n = 0..60, all checked: {ok}; line counts {lens}")
    M = {"dom": [0, 1, 2, "a"], "zero": 0, "S": {0: 1, 1: 2, 2: 2, "a": 0}, "R": {0, 1, 2}}
    inst = all(ev(subst(phi, x, num(n)), M, {}) for n in range(0, 61))
    univ = ev(All(x, phi), M, {})
    print(f"  countermodel {{0,1,2,a}}: all instances n<=60 true: {inst}; Ax phi true: {univ}")
    # validity of the instances: a derivation from no hypotheses exists (checked above) => valid
    print("  every instance has a hypothesis-free derivation, so it is logically valid (old evidence)")
    print("== Part 2: non-degenerate variant (fresh predicate R) ==")
    ok1 = ok2 = True
    l1, l2 = {}, {}
    for n in range(0, 61):
        d1 = deriv_R_from_psi1(n)
        d2 = deriv_R_from_psi2(n)
        ok1 &= check(d1, hyps=(psi1,)) and d1[-1][0] == Rp(num(n))
        ok2 &= check(d2, hyps=(psi2,)) and d2[-1][0] == Rp(num(n))
        l1[len(d1)] = l1.get(len(d1), 0) + 1
        l2[len(d2)] = l2.get(len(d2), 0) + 1
    print(f"  psi_1 = Ax(phi(x) -> R(x)) derives R(S^n 0), n=0..60, checked: {ok1}; line counts {l1}")
    print(f"  psi_2 = Ax R(x) derives R(S^n 0), n=0..60, checked: {ok2}; line counts {l2}")
    Mempty = {"dom": [0], "zero": 0, "S": {0: 0}, "R": set()}
    print(f"  data not valid: the one-point structure with R empty refutes R(0): {not ev(Rp(num(0)), Mempty, {})}")
    print(f"  countermodel {{0,1,2,a}} with R = {{0,1,2}}: psi_1 true: {ev(psi1, M, {})}; "
          f"all R(S^n 0) (n<=60) true: {all(ev(Rp(num(n)), M, {}) for n in range(61))}; "
          f"Ax R(x) true: {ev(psi2, M, {})}")
    print("  => with line budget 9, psi_1 (not proving Ax R) and psi_2 (proving it) both stay compatible;")
    print("     the limit belief in Ax R(x) is strictly between 0 and 1 under any full-support prior.")
    assert ok and inst and not univ and ok1 and ok2 and ev(psi1, M, {}) and not ev(psi2, M, {})
    print("all assertions passed")


if __name__ == "__main__":
    main()
