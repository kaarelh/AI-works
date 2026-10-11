"""r2 (referee): executable test of the interval construction in Lemma 3.1 of the foundations notes.

Lemma 3.1 is marked [proved] but was not computed by the track.  Here the construction is run
literally, with exact rationals, on random lower-semicomputable semimeasures on A^{<=3},
A = {0,1,2} (letters revealed one per stage, as in the proof):
  mu_t      : dyadic lower approximations, nondecreasing in t, rounded down to multiples of 2^-t,
              zero unless |s| <= t and s uses only the first t letters;
  mu'_t     : leaves-up closure  mu'_t(s) = max{ mu_t(s), sum_a mu'_t(sa) };
  I_t(s)    : top-down allocation of disjoint pieces inside the "room" of the parent.
Checked at every stage t and every node s:
  mu'_t <= mu ;  mu'_t nondecreasing in t ;  mu'_t(s) >= sum_a mu'_t(sa) ;
  lambda(I_t(s)) = mu'_t(s) ;  I_{t-1}(s) subset I_t(s) ;  I_t(sa) subset I_t(s) ;
  siblings disjoint ;  all endpoints are multiples of 2^-t (finite unions of dyadic intervals);
and at the end lambda(I(s)) = mu(s) for every s.

Seed 20261011.  Output: r2_lemma31_intervals_output.txt
"""
import itertools
import random
from fractions import Fraction as Fr

A = (0, 1, 2)
DEPTH = 3
T_END = 14


def strings(depth, letters):
    out = [()]
    for d in range(1, depth + 1):
        out += list(itertools.product(letters, repeat=d))
    return out


ALL = strings(DEPTH, A)


def random_semimeasure(rng):
    mu = {(): Fr(rng.randrange(128, 257), 256)}
    for s in ALL:
        if len(s) == DEPTH:
            continue
        # split a random fraction of mu(s) among children, multiples of 2^-8
        budget = int(mu[s] * 256)
        cuts = sorted(rng.randrange(0, budget + 1) for _ in range(len(A)))
        prev = 0
        for a, c in zip(A, cuts):
            mu[s + (a,)] = Fr(c - prev, 256)
            prev = c
    return mu


def approximations(mu, rng):
    """mu_t(s), nondecreasing in t, reaching mu by T_END-4."""
    sched = {s: sorted(rng.random() for _ in range(T_END)) for s in ALL}
    approx = {}
    for t in range(1, T_END + 1):
        for s in ALL:
            if len(s) > t or any(a >= t for a in s):
                approx[t, s] = Fr(0)
                continue
            g = 1.0 if t >= T_END - 4 else sched[s][t - 1]
            target = mu[s] * Fr(g).limit_denominator(1 << 20)
            v = Fr(int(target * 2 ** t), 2 ** t)  # round down to multiple of 2^-t
            approx[t, s] = v
        # enforce monotonicity in t (as the proof assumes): take max with previous
        if t > 1:
            for s in ALL:
                approx[t, s] = max(approx[t, s], approx[t - 1, s])
    return approx


def measure(iv):
    return sum(b - a for a, b in iv)


def subtract(iv, cut):
    """iv minus union of cut, both lists of disjoint half-open intervals."""
    out = []
    for a, b in iv:
        pieces = [(a, b)]
        for c, d in cut:
            new = []
            for x, y in pieces:
                if d <= x or c >= y:
                    new.append((x, y))
                else:
                    if x < c:
                        new.append((x, c))
                    if d < y:
                        new.append((d, y))
            pieces = new
        out += pieces
    return sorted(out)


def carve(room, amount):
    """take `amount` from the left of room; return (piece, remaining room)."""
    piece, rest = [], []
    need = amount
    for a, b in room:
        if need <= 0:
            rest.append((a, b))
        elif b - a <= need:
            piece.append((a, b))
            need -= b - a
        else:
            piece.append((a, a + need))
            rest.append((a + need, b))
            need = 0
    assert need == 0, "room too small"
    return piece, rest


def subset(iv1, iv2):
    return measure(subtract(iv1, iv2)) == 0


def disjoint(iv1, iv2):
    return measure(iv1) + measure(iv2) == measure(subtract(iv1, []) + []) + measure(iv2) and \
        measure(subtract(iv1, iv2)) == measure(iv1)


def run(rng):
    mu = random_semimeasure(rng)
    approx = approximations(mu, rng)
    mup_prev = {s: Fr(0) for s in ALL}
    I_prev = {s: [] for s in ALL}
    fails = []
    for t in range(1, T_END + 1):
        mup = {}
        for s in sorted(ALL, key=len, reverse=True):
            kids = sum(mup.get(s + (a,), Fr(0)) for a in A) if len(s) < DEPTH else Fr(0)
            mup[s] = max(approx[t, s], kids)
        I = {(): [(Fr(0), mup[()])]}
        for s in sorted(ALL, key=len):
            if len(s) == DEPTH:
                continue
            room = subtract(I[s], [iv for a in A for iv in I_prev[s + (a,)]])
            for a in A:
                delta = mup[s + (a,)] - mup_prev[s + (a,)]
                piece, room = carve(room, delta) if delta > 0 else ([], room)
                I[s + (a,)] = sorted(I_prev[s + (a,)] + piece)
        # checks
        for s in ALL:
            if mup[s] > mu[s]:
                fails.append(("mu' > mu", t, s))
            if mup[s] < mup_prev[s]:
                fails.append(("mu' decreased", t, s))
            if len(s) < DEPTH and mup[s] < sum(mup[s + (a,)] for a in A):
                fails.append(("mu' not semimeasure", t, s))
            if measure(I[s]) != mup[s]:
                fails.append(("measure", t, s))
            if not subset(I_prev[s], I[s]):
                fails.append(("not growing", t, s))
            if any((x * 2 ** t).denominator != 1 or (y * 2 ** t).denominator != 1 for x, y in I[s]):
                fails.append(("non-dyadic endpoint", t, s))
            if len(s) < DEPTH:
                for a in A:
                    if not subset(I[s + (a,)], I[s]):
                        fails.append(("child not inside", t, s, a))
                for a, b in itertools.combinations(A, 2):
                    if measure(subtract(I[s + (a,)], I[s + (b,)])) != measure(I[s + (a,)]):
                        fails.append(("siblings overlap", t, s, a, b))
        mup_prev, I_prev = mup, I
    final = all(measure(I_prev[s]) == mu[s] for s in ALL)
    return fails, final


def main():
    rng = random.Random(20261011)
    lines = []
    nfail = 0
    nfinal = 0
    trials = 60
    for _ in range(trials):
        fails, final = run(rng)
        nfail += len(fails)
        nfinal += final
        if fails:
            lines.append(f"failure example: {fails[:3]}")
    lines.append(f"random semimeasures on A^<=3, A={{0,1,2}}, {T_END} stages: {trials} trials, "
                 f"invariant violations = {nfail}, final lambda(I(s)) = mu(s) for all s in {nfinal}/{trials} trials")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()
