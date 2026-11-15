"""Referee's machine check of the lemma inside Proposition 6 of equational.md: under squaring,
two different words over {S, f} applied to a variable denote different polynomials.

Every word of at most MAXLEN letters is evaluated at x = 0, 1, 2, 3 with exact integers; if the
four values of two words agree the words are reported.  Distinct values at some point imply
distinct polynomials, so "no collision" confirms the lemma for these words.  (The proof in the
note covers all lengths; this is only a check that nothing is wrong with it for short words.)

Also: among all unary identities with sides of at most 8 symbols, which are true of squaring at
all assignments with values 0..6?  The lemma predicts: only identities with identical sides and
true ground identities.

Usage: python3 eq_square.py
"""
import itertools

MAXLEN = 15


def run(word, v):
    for ch in reversed(word):              # the last letter is applied first
        v = v + 1 if ch == "S" else v * v
    return v


seen = {}
collisions = []
count = 0
for n in range(0, MAXLEN + 1):
    for w in itertools.product("Sf", repeat=n):
        w = "".join(w)
        # skip words whose value at 3 would have more than about 2^17 bits
        if w.count("f") > 15:
            continue
        key = tuple(run(w, v) for v in (0, 1, 2, 3))
        count += 1
        if key in seen:
            collisions.append((seen[key], w))
        else:
            seen[key] = w
print(f"words of at most {MAXLEN} letters evaluated: {count}; pairs of different words with equal values at 0, 1, 2, 3: {len(collisions)}")
for c in collisions[:5]:
    print("   ", c)

# all unary identities with sides of at most 8 symbols
M = 8
terms = [(w, leaf) for n in range(0, M) for w in map("".join, itertools.product("Sf", repeat=n)) for leaf in "0xy"]
vals = {}
for w, leaf in terms:
    vals[(w, leaf)] = [run(w, 0)] if leaf == "0" else [run(w, v) for v in range(7)]
true_ground = true_same = true_other = 0
examples = []
for i, (w1, l1) in enumerate(terms):
    a = vals[(w1, l1)]
    for (w2, l2) in terms[i + 1:]:
        b = vals[(w2, l2)]
        if l1 == "0" and l2 == "0":
            ok = a[0] == b[0]
        elif l1 == l2:
            ok = a == b
        else:                               # independent leaves (a variable against 0 or against the other variable)
            ok = len(set(a)) == 1 and len(set(b)) == 1 and a[0] == b[0]
        if ok:
            if l1 == "0" and l2 == "0":
                true_ground += 1
            elif w1 == w2 and l1 == l2:
                true_same += 1
            else:
                true_other += 1
                examples.append((w1 + l1, w2 + l2))
print(f"unary identities with sides of at most {M} symbols, distinct sides, true of squaring on 0..6:")
print(f"   ground: {true_ground};  with a variable: {true_other}  {examples[:5]}")
