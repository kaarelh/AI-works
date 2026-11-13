"""Explicit identity sets for some targets, with their sizes, checked by machine.

For each set T and target g the script checks, on a finite range:
  * truth: every identity of T holds for g (so T has g as a model and proves no false value);
  * coverage: forward chaining from T (eqlib.forward_chain, valid equational inferences only)
    derives g(x) for every x in a test box.
The size of T is then an upper bound on the law complexity of g, as far as the range shows.

Usage: python3 theories.py
"""
from eqlib import D, F, S, V, Z, forward_chain, holds, num, show_id, tsize

x, y, z = V(0), V(1), V(2)


def check(name, T, interp, box, rng, background=None, arity=2, show=False):
    bad = [(show_id(e), holds(e, interp, rng)) for e in T if holds(e, interp, rng) is not None]
    table, conflict = forward_chain(T, rng, background)
    g = interp["f"]
    pts = [(a, b) for a in box for b in box] if arity == 2 else [(a,) for a in box]
    missing = [p for p in pts if table.get(("f", p)) != g(*p)]
    ok = not bad and conflict is None and not missing
    print(f"{name:44s} size {tsize(T):5d}  identities {len(T):4d}  "
          f"true on range: {not bad}  derives the box: {not missing and conflict is None}")
    if show:
        for e in T:
            print("      " + show_id(e))
    if not ok:
        print("   PROBLEM", bad[:2], conflict, missing[:3])
    return ok


def plus_theory():
    return [(F(x, Z), x), (F(x, S(y)), S(F(x, y)))]


def quus_theory(N):
    """x + y if x, y < N, else 5."""
    T = [(F(S(x, N), y), num(5)), (F(x, S(y, N)), num(5))]
    T += [(F(num(a), num(b)), num(a + b)) for a in range(N) for b in range(N)]
    return T


def patch_theory(a, b, v):
    """x + y, except that the value at (a, b) is v. Needs a >= 1."""
    T = [(F(Z, S(y, b + 1)), S(y, b + 1)), (F(S(x), S(y, b + 1)), S(F(x, S(y, b + 1))))]      # rows above b
    for j in range(b):                                                                   # rows below b
        T += [(F(Z, num(j)), num(j)), (F(S(x), num(j)), S(F(x, num(j))))]
    T += [(F(num(i), num(b)), num(i + b)) for i in range(a)]                             # row b, left of a
    T += [(F(num(a), num(b)), num(v))]                                                   # the patch
    T += [(F(num(a + 1), num(b)), num(a + b + 1)),                                       # row b, right of a
          (F(S(x, a + 2), num(b)), S(F(S(x, a + 1), num(b))))]
    return T


def quus_aux_theory(j):
    """x + y if x, y < 2^j, else 5, with auxiliary symbols h (plus), d (doubling), l (less
    than), c (conditional)."""
    N = D(num(1), j)
    lt = lambda s, t: ("l", s, t)
    cond = lambda b, s, t: ("c", b, s, t)
    return [
        (("h", x, Z), x), (("h", x, S(y)), S(("h", x, y))),
        (("d", Z), Z), (("d", S(x)), S(S(("d", x)))),
        (lt(x, Z), Z), (lt(Z, S(y)), num(1)), (lt(S(x), S(y)), lt(x, y)),
        (cond(Z, y, z), z), (cond(S(x), y, z), y),
        (F(x, y), cond(lt(x, N), cond(lt(y, N), ("h", x, y), num(5)), num(5))),
    ]


def doubling_patch_theory(j):
    """x + y, except 0 at (2^j, 0), over the signature with a background doubling symbol d."""
    T = [(F(x, num(1)), S(x)), (F(x, S(S(y))), S(F(x, S(y)))), (F(Z, Z), Z)]
    for i in range(j):                      # first argument 2^i * odd, i < j
        t = D(S(D(x)), i)
        T.append((F(t, Z), t))
    t = D(S(S(x)), j)                       # first argument 2^j * m, m >= 2
    T.append((F(t, Z), t))
    T.append((F(D(num(1), j), Z), Z))       # the patch
    return T


if __name__ == "__main__":
    plus = lambda a, b: a + b
    print("== targets with short identity sets (no auxiliary symbols) ==")
    R = range(8)
    check("plus", plus_theory(), {"f": plus}, range(7), R, show=True)
    check("successor (unary)", [(F(x), S(x))], {"f": lambda a: a + 1}, range(7), R, arity=1, show=True)
    check("max", [(F(Z, y), y), (F(x, Z), x), (F(S(x), S(y)), S(F(x, y)))], {"f": max}, range(7), R, show=True)
    check("min", [(F(Z, y), Z), (F(x, Z), Z), (F(S(x), S(y)), S(F(x, y)))], {"f": min}, range(7), R)
    check("monus", [(F(x, Z), x), (F(Z, y), Z), (F(S(x), S(y)), F(x, y))], {"f": lambda a, b: max(a - b, 0)}, range(7), R)
    check("[x = y]", [(F(Z, Z), num(1)), (F(S(x), Z), Z), (F(Z, S(y)), Z), (F(S(x), S(y)), F(x, y))],
          {"f": lambda a, b: int(a == b)}, range(7), R)
    check("double (unary)", [(F(Z), Z), (F(S(x)), S(S(F(x))))], {"f": lambda a: 2 * a}, range(7), R, arity=1)

    print("\n== quus_N (x + y if x, y < N, else 5), no auxiliary symbols: lower bound N + 2 ==")
    for N in (3, 4, 5, 6, 8):
        q = lambda a, b, N=N: a + b if a < N and b < N else 5
        check(f"quus_{N}", quus_theory(N), {"f": q}, range(N + 3), range(N + 4))

    print("\n== plus with the value at (a, b) changed to 0, no auxiliary symbols: lower bound max(a, b) + 2 ==")
    for a, b in ((1, 1), (2, 3), (4, 2), (5, 5), (8, 3)):
        g = lambda p, q, a=a, b=b: 0 if (p, q) == (a, b) else p + q
        check(f"plus, but 0 at ({a},{b})", patch_theory(a, b, 0), {"f": g}, range(max(a, b) + 4), range(max(a, b) + 5))

    print("\n== plus with the value at (n, 0) changed to 0: n^2 + 8n + 36 symbols ==")
    for n in (2, 4, 6, 10):
        g = lambda p, q, n=n: 0 if (p, q) == (n, 0) else p + q
        T = patch_theory(n, 0, 0)
        assert tsize(T) == n * n + 8 * n + 36
        check(f"plus, but 0 at ({n},0)", T, {"f": g}, range(n + 4), range(n + 5))

    print("\n== quus_N for N = 2^j WITH auxiliary symbols (h, d, l, c) ==")
    for j in (1, 2, 3):
        N = 2 ** j
        interp = {"f": lambda a, b, N=N: a + b if a < N and b < N else 5, "h": plus, "d": lambda a: 2 * a,
                  "l": lambda a, b: int(a < b), "c": lambda a, b, c: b if a else c}
        # the range must contain every value passed to c, up to (N + 1) + (N + 1)
        check(f"quus_{N} with auxiliary symbols", quus_aux_theory(j), interp, range(N + 2), range(2 * N + 4), show=(j == 1))

    print("\n== plus with the value at (2^j, 0) changed to 0, with doubling as a background symbol ==")
    for j in (1, 2, 3, 4):
        N = 2 ** j
        g = lambda p, q, N=N: 0 if (p, q) == (N, 0) else p + q
        check(f"plus, but 0 at ({N},0), background doubling", doubling_patch_theory(j), {"f": g, "d": lambda a: 2 * a},
              range(N + 4), range(N + 5), background={"d": lambda a: 2 * a}, show=(j == 2))
