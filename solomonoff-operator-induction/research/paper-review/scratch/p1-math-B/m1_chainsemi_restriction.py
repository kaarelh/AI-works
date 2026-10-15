"""Reviewer check m1 (Paper 1, app-examples): are lem:ex:chainsemi and eq:ex:depth true as printed?

lem:ex:chainsemi (paper) : for every law nu of a random partial function F and every x,
    sum_z nu(D(x,z)) <= 1, "over the z for which D(x,z) is a data set",
    D(x,z) = {(x,z_1),(z_1,z_2),...,(z_{i-1},z_i),(z_i,0^{|x|})}.
The source (examples notes-final Lemma 2.2) restricts z to strings DIFFERENT FROM 0^{|x|}.

eq:ex:depth (paper): sum_{x,z} nu(D(x,z)) = E|A_k(F)| <= N-k, "summing over nonzero d-bit x
and |z| = k-1".  The source restricts z to (nonzero d-bit strings)^{k-1}.

We exhibit a deterministic F (a point-mass law) on d-bit strings for which
 (1) the unrestricted chain sum over z is >= 2 (indeed unbounded as the maximum length grows);
 (2) the unrestricted depth sum exceeds N-k,
while both restricted sums obey the bounds.  Deterministic; no seed.
"""
import itertools

d = 2
N = 2 ** d
ZERO = 0
STR = list(range(N))          # d-bit strings as integers, 0 = 0^d


def contains(F, D):
    return all(F.get(a) == b for a, b in D)


def is_data_set(pairs):
    m = {}
    for a, b in pairs:
        if a in m and m[a] != b:
            return False
        m[a] = b
    return True


def D_of(x, z):
    pairs = []
    prev = x
    for zi in z:
        pairs.append((prev, zi))
        prev = zi
    pairs.append((prev, ZERO))
    return pairs


# F: every string goes to 0^d, including 0^d itself (a total function, point-mass law).
F = {s: ZERO for s in STR}
x = 1
for maxlen in (1, 2, 3, 4, 6):
    unrestricted = 0
    restricted = 0
    for L in range(0, maxlen + 1):
        for z in itertools.product(STR, repeat=L):
            pairs = D_of(x, z)
            if not is_data_set(pairs):
                continue
            if contains(F, pairs):
                unrestricted += 1
                if all(zi != ZERO for zi in z):
                    restricted += 1
    print(f"chain sum, F = const 0^d, x = {x}, |z| <= {maxlen}: unrestricted = {unrestricted}, "
          f"restricted (z_i != 0^d) = {restricted}")

# Depth count with unrestricted z: #{(x,z): x nonzero, |z| = k-1, F >= D(x,z)} vs N-k.
for k in range(1, N):
    unres = 0
    res = 0
    for xx in STR:
        if xx == ZERO:
            continue
        for z in itertools.product(STR, repeat=k - 1):
            pairs = D_of(xx, z)
            if is_data_set(pairs) and contains(F, pairs):
                unres += 1
                if all(zi != ZERO for zi in z):
                    res += 1
    print(f"depth sum, F = const 0^d, d = {d}, k = {k}: unrestricted = {unres}, restricted = {res}, N-k = {N - k}")

# Exhaustive: maximum restricted depth sum over all total F on d = 2 equals N-k (sanity).
worst = {k: 0 for k in range(1, N)}
for vals in itertools.product(STR, repeat=N):
    G = dict(zip(STR, vals))
    for k in range(1, N):
        cnt = 0
        for xx in STR[1:]:
            for z in itertools.permutations(STR[1:], k - 1):
                if xx in z:
                    continue
                pairs = D_of(xx, z)
                if contains(G, pairs):
                    cnt += 1
        worst[k] = max(worst[k], cnt)
print("max over all total F (d=2) of the restricted depth sum (z distinct nonzero, != x):", worst,
      "bound N-k:", {k: N - k for k in range(1, N)})
