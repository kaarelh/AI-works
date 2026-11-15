"""Referee: a positive answer to open question 2 of equational.md (fast-growing targets).

For unary f and n = 2^j there is a consistent identity set Q_j in the bare vocabulary {0, S, f},
of 1.5 j^2 + 8.5 j + 7 symbols, that proves f(p) = 2p for every p < 2^j and proves the wrong
value f(2^j) = 0:

    f(0) = 0,
    f(f^i(S(f(z)))) = S(S(f((Sf)^i(f(z)))))        for i = 0, ..., j-1,
    f(f^j(S(0))) = 0.

Reading under doubling: the argument f^i(S(f(z))) is p = 2^i (2z+1), the term (Sf)^i(f(z)) is
p - 1, and the identity says f(p) = 2 + f(p - 1).  All the middle identities are true of
doubling.  The whole set is true of g(x) = 2 (x mod 2^j), which is a standard model; so the set
is consistent.  (The note knows only sets of about n^2 symbols.)

This script checks, for j = 1..7:
  * the size formula;
  * that g(x) = 2 (x mod 2^j) satisfies every identity at every z < 8 * 2^j;
  * that every middle identity is true of doubling for z < 8 * 2^j, and the last one is false;
  * a derivation of f(p) = 2p for all p < 2^j and of f(2^j) = 0, by strong induction on p: an
    instance of an identity is used only when every application of f inside it, other than the
    outermost one on the left, is at a number whose value has already been derived.
For j = 2 the set is also written in the input format of code/eq_unary.c ("check" mode).

Usage: python3 eq_doubling_patch.py
"""


def word_value(word, v, g, known=None):
    """apply a word over {S, f} (outermost letter first) to the number v.
    With `known` (a dict) f may only be applied where its value has been derived: returns None otherwise."""
    for ch in reversed(word):
        if ch == "S":
            v += 1
        else:
            if known is not None:
                if v not in known:
                    return None
                v = known[v]
            else:
                v = g(v)
    return v


def Q(j):
    """the set, as triples (left word, right word, leaf) with leaf 'z' or '0'"""
    ids = [("f", "", "0")]
    for i in range(j):
        ids.append(("f" + "f" * i + "Sf", "SSf" + "Sf" * i + "f", "z"))
    ids.append(("f" + "f" * j + "S", "", "0"))
    return ids


def size(ids):
    return sum(len(l) + 1 + len(r) + 1 for l, r, _ in ids)


for j in range(1, 8):
    N = 2 ** j
    ids = Q(j)
    sz = size(ids)
    g = lambda x: 2 * (x % N)
    dbl = lambda x: 2 * x
    model = all(word_value(l, z, g) == word_value(r, z, g) for l, r, leaf in ids for z in (range(8 * N) if leaf == "z" else [0]))
    mid_true = all(word_value(l, z, dbl) == word_value(r, z, dbl) for l, r, leaf in ids[:-1] for z in (range(8 * N) if leaf == "z" else [0]))
    last_false = word_value(ids[-1][0], 0, dbl) != word_value(ids[-1][1], 0, dbl)
    # derivation by strong induction
    known = {0: 0}                                   # f(0) = 0 is an identity of the set
    for p in range(1, N):
        i = (p & -p).bit_length() - 1
        z = (p >> i) // 2
        l, r, _ = ids[1 + i]
        arg = word_value(l[1:], z, None, known)      # the argument of the outermost f on the left
        val = word_value(r, z, None, known)
        assert arg == p and val is not None, (j, p)
        known[p] = val
    derived = all(known[p] == 2 * p for p in range(N))
    l, r, _ = ids[-1]
    wrong = word_value(l[1:], 0, None, known) == N and word_value(r, 0, None, known) == 0
    print(f"j={j} n={N:4d}: size {sz:4d} (formula {1.5 * j * j + 8.5 * j + 7:6.1f}); 2(x mod n) is a model: {model}; middle identities true of doubling: "
          f"{mid_true}; last false of doubling: {last_false}; derives 2p for all p < n: {derived}; derives f(n) = 0: {wrong}; "
          f"ground-identity set for the same job: {sum(3 * p + 3 for p in range(N)) + N + 3} symbols")

print("\nQ_2 in the input format of eq_unary check mode (terms as words, outermost letter first):")
print("   " + " ".join(f"{l}{leaf if leaf != 'z' else 'x'}={r}{leaf if leaf != 'z' else 'x'}" for l, r, leaf in Q(2)))
print("Q_3:")
print("   " + " ".join(f"{l}{leaf if leaf != 'z' else 'x'}={r}{leaf if leaf != 'z' else 'x'}" for l, r, leaf in Q(3)))
