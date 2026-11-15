"""Referee, second pass: Proposition 10, Proposition 8(2) and Proposition 5(4) of the revised
equational.md, checked from the text of the note (not from the first-pass scripts).

Part A.  Proposition 10: the set Q_j as printed, for j = 0..10: the size formula; each step of
         the four parts of the proof; and for small j the verdict of `eq_unary ... check`, if a
         compiled binary is given as the first argument.
Part B.  Proposition 8(2): the search equation sigma(x, y) = c(t(x, y), sigma(x, S(y)), y) with
         the convention c(0, u, v) = v, c(S(b), u, v) = u, read with sigma(x, y) = the least
         witness at or above y if there is one and 0 otherwise.
Part C.  Proposition 5(4): the set described in the proof, for n = 1..12.

Usage: python3 eq2_props.py [path to a compiled eq_unary]
"""
import itertools
import random
import subprocess
import sys

sys.dont_write_bytecode = True
from eq_check_sets import Rewriter, true_on_range, tsize  # noqa: E402

# ------------------------------------------------------------------ Part A
print("== Part A: Proposition 10 ==")


def Q(j):
    """Q_j as (left word, right word, leaf); a word is read outermost letter first"""
    out = [("f", "", "0")]
    for i in range(j):
        out.append(("f" + "f" * i + "Sf", "SS" + "f" + "Sf" * i + "f", "z"))      # f(f^i(S(f(z)))) = S(S(f((Sf)^i(f(z)))))
    out.append(("f" + "f" * j + "S", "", "0"))                                       # f(f^j(S(0))) = 0
    return out


def apply_word(word, v, g, trace=None):
    for ch in reversed(word):
        if ch == "S":
            v += 1
        else:
            if trace is not None:
                trace.append(v)
            v = g(v)
            if v is None:
                return None
    return v


for j in range(0, 11):
    n = 2 ** j
    ids = Q(j)
    size = sum(len(l) + len(r) + 2 for l, r, _ in ids)
    sizes_ok = (len(ids[0][0]) + len(ids[0][1]) + 2 == 3 and len(ids[-1][0]) + len(ids[-1][1]) + 2 == j + 4
                and all(len(ids[1 + i][0]) + len(ids[1 + i][1]) + 2 == 3 * i + 9 for i in range(j)))
    dbl = lambda x: 2 * x
    g = lambda x: 2 * (x % n)
    # part 1 of the proof: under doubling the left argument is p = 2^i (2z+1), the right inner term is p - 1
    readings = all(apply_word(ids[1 + i][0][1:], z, dbl) == 2 ** i * (2 * z + 1) and apply_word(ids[1 + i][1][3:], z, dbl) == 2 ** i * (2 * z + 1) - 1
                   and apply_word(ids[1 + i][0], z, dbl) == apply_word(ids[1 + i][1], z, dbl)
                   for i in range(j) for z in range(0, 3 * n + 3))
    # part 2: induction on p < n; f may be applied only below p
    known = {0: 0}
    induction = True
    for p in range(1, n):
        i = (p & -p).bit_length() - 1
        z = (p >> i) // 2
        l, r, _ = ids[1 + i]
        tl, tr = [], []
        look = lambda v: known.get(v)
        arg = apply_word(l[1:], z, look, tl)
        val = apply_word(r, z, look, tr)
        induction &= arg == p and val == 2 * p and all(v < p for v in tl + tr) and max(tr) == p - 1
        known[p] = val
    # part 3: f^j(1) applies f at 1, 2, ..., 2^(j-1) and equals n
    tr = []
    part3 = apply_word(ids[-1][0][1:], 0, lambda v: known.get(v), tr) == n and tr == [2 ** t for t in range(j)]
    # part 4: the model 2 (x mod n), with the modular bookkeeping of the proof
    model = True
    for i in range(j):
        l, r, _ = ids[1 + i]
        for z in range(0, 6 * n + 5):
            rr = z % n
            A = apply_word(l[1:], z, g)                      # argument of the outer f on the left
            B = apply_word(r[3:], z, g)                      # (Sf)^i (f(z))
            P = (2 ** i * (2 * rr + 1)) % n
            model &= (A - 2 ** i * (2 * rr + 1)) % (2 * n) == 0 and (B - (2 ** i * (2 * rr + 1) - 1)) % (2 * n) == 0
            model &= P != 0 and apply_word(l, z, g) == 2 * P and apply_word(r, z, g) == 2 + 2 * (P - 1)
    model &= g(0) == 0 and apply_word(ids[-1][0], 0, g) == 0 and (j == 0 or (g(2 ** (j - 1)) == n and g(n) == 0))
    print(f"j={j:2d} n={n:5d}: size {size} = 1.5j^2+8.5j+7: {size == 1.5 * j * j + 8.5 * j + 7}; sizes 3, 3i+9, j+4: {sizes_ok}; "
          f"readings under doubling: {readings}; induction below n: {induction}; f^j(1) = n: {part3}; model 2(x mod n): {model}")

if len(sys.argv) > 1:
    for j in (1, 2, 3):
        text = " ".join(f"{l}{'x' if leaf == 'z' else '0'}={r}{'x' if leaf == 'z' else '0'}" for l, r, leaf in Q(j))
        for L in (12, 16):
            out = subprocess.run([sys.argv[1], "0", str(L), "check"], input=text + "\n", capture_output=True, text=True).stdout.strip()
            print(f"   eq_unary check, Q_{j} = [{text}], L = {L}: {out}")

# ------------------------------------------------------------------ Part B
print("\n== Part B: the search equation of Proposition 8(2) ==")
c = lambda b, u, v: v if b == 0 else u                       # c(0, u, v) = v, c(S(b), u, v) = u
random.seed(1)
ok_eq = ok_unfold = True
wrong_orientation_fails = False
for trial in range(300):
    X, Y = 6, 12
    # t(x, y) = 0 exactly at the witnesses; no witness from Y on; some x have several witnesses, x = 0 has none
    tab = {(x, y): (0 if (x > 0 and random.random() < 0.25) else random.randint(1, 3)) for x in range(X) for y in range(Y)}
    t = lambda x, y: tab.get((x, y), 1)

    def sigma(x, y):
        for w in range(y, Y):
            if t(x, w) == 0:
                return w
        return 0

    for x in range(X):
        for y in range(Y + 4):
            ok_eq &= sigma(x, y) == c(t(x, y), sigma(x, y + 1), y)
            if sigma(x, y) != c(t(x, y), y, sigma(x, y + 1)):
                wrong_orientation_fails = True
        # unfolding sigma(x, 0) by the equation and the two equations of c reaches the least witness, when there is one
        if any(t(x, w) == 0 for w in range(Y)):
            y = 0
            while t(x, y) != 0:
                y += 1                                       # sigma(x, y) = c(S(b), sigma(x, S(y)), y) = sigma(x, S(y))
            ok_unfold &= y == sigma(x, 0)                    # sigma(x, y) = c(0, ..., y) = y
print(f"sigma(x,y) = c(t(x,y), sigma(x,S(y)), y) holds for the reading 'least witness at or above y, else 0' in 300 random cases: {ok_eq}")
print(f"unfolding from sigma(x, 0) ends at the least witness: {ok_unfold}")
print(f"with the arguments of c exchanged, c(t, y, sigma(x,S(y))), the equation fails under this convention: {wrong_orientation_fails}")

# ------------------------------------------------------------------ Part C
print("\n== Part C: the set of Proposition 5(4) ==")
V = lambda i: ("v", i)
Z = ("0",)


def S(t, k=1):
    for _ in range(k):
        t = ("S", t)
    return t


F = lambda a, b: ("f", a, b)
x, y = V(0), V(1)
allok = True
for n in range(1, 13):
    T = [(F(Z, S(y)), S(y)), (F(S(x), S(y)), S(F(x, S(y))))]                       # the rows above 0
    T += [(F(S(Z, i), Z), S(Z, i)) for i in range(n)]                              # f(i, 0) = i for i < n
    T += [(F(S(Z, n), Z), Z)]                                                      # the changed value
    T += [(F(S(Z, n + 1), Z), S(Z, n + 1)), (F(S(x, n + 2), Z), S(F(S(x, n + 1), Z)))]   # the rest of row 0
    g = lambda p, q, n=n: 0 if (p, q) == (n, 0) else p + q
    size = sum(tsize(s) + tsize(t) for s, t in T)
    parts = (tsize(T[0][0]) + tsize(T[0][1]) + tsize(T[1][0]) + tsize(T[1][1]), sum(tsize(s) + tsize(t) for s, t in T[2:2 + n]),
             tsize(T[2 + n][0]) + tsize(T[2 + n][1]), tsize(T[3 + n][0]) + tsize(T[3 + n][1]), tsize(T[4 + n][0]) + tsize(T[4 + n][1]))
    true = true_on_range(T, {"f": g}, n + 6)[0]
    rw = Rewriter(T)
    derived = all(rw.apply("f", (p, q)) == g(p, q) for p in range(n + 6) for q in range(n + 6))
    ok = size == n * n + 8 * n + 36 and parts == (16, n * n + 3 * n, n + 4, 2 * n + 6, 2 * n + 10) and true and derived
    allok &= ok
    if n in (1, 2, 5, 12):
        print(f"   n={n:2d}: size {size} = n^2+8n+36: {size == n * n + 8 * n + 36}; parts {parts}; true of the changed function: {true}; derives all values on the box: {derived}")
print(f"all of n = 1..12: {allok}")
