"""r5 (referee, independent of checks/c4): the interval-allocation proof of Thm 4.2, implemented LITERALLY.

Differences from c4:
 * stage t processes only z_1, ..., z_t of a random enumeration in which every node follows its parent
   (c4 processed all nodes at every stage, in depth order);
 * adversarial lower approximations: a parent's approximation stays 0 until a late random stage while
   its children's approximations are already exact (children far "ahead" of the parent);
 * X = {0,1,2}, Y = {0,1}, depth 3, rho a strict chronological semimeasure (deficits at every node);
 * the generated semimeasure is computed EXACTLY: the event {T^omega outputs y_1..y_k on x_1..x_k} is
   the intersection over i of S(x_{1:i}, y_{1:i}) (the machine outputs y_i iff omega lies in that set,
   by (I2)), and its Lebesgue measure is computed with exact interval arithmetic, not Monte Carlo.
Checks: exactness lambda(event) = rho(z) for every node; (I1) nesting; (I2) family disjointness;
(I3) lambda(S_t(z)) <= rho_t(z) at every stage.  Seed 55.  Output: r5_chrono_literal.out.
"""
import itertools, random
from fractions import Fraction as Fr

SEED = 55
rng = random.Random(SEED)
X = (0, 1, 2); Y = (0, 1); DEPTH = 3

# random strict chronological semimeasure with dyadic values
rho = {(): Fr(1)}
nodes = [()]
for k in range(DEPTH):
    for z in [z for z in nodes if len(z) == k]:
        for x in X:
            rem = rho[z]
            for y in Y:
                v = rem * Fr(rng.randint(0, 6), 8)
                rho[z + ((x, y),)] = v
                rem -= v
                nodes.append(z + ((x, y),))
nonroot = [z for z in nodes if z]

# random enumeration with parents first
order = []
placed = {()}
pool = list(nonroot)
while pool:
    avail = [z for z in pool if z[:-1] in placed]
    z = rng.choice(avail)
    order.append(z); placed.add(z); pool.remove(z)

T_STAGES = len(order) + 40
release = {z: rng.randint(1, T_STAGES - 5) for z in nonroot}
for z in nonroot:  # make parents late relative to children (adversarial)
    if len(z) >= 2:
        release[z[:-1]] = max(release[z[:-1]], release[z] + rng.randint(0, 20))
for z in nonroot:
    release[z] = min(release[z], T_STAGES - 1)


def rho_t(z, t):
    if t >= release[z]:
        return rho[z]
    # a poor dyadic lower approximation before release
    return rho[z] * Fr(rng_t[(z, t)], 4)


rng_t = {}
for z in nonroot:
    last = 0
    for t in range(1, T_STAGES + 1):
        last = max(last, (3 * t) // release[z] if t < release[z] else 4)  # 0, 1/4, 2/4 of rho, then rho
        rng_t[(z, t)] = min(last, 4)


def meas(iv):
    return sum(b - a for a, b in iv)


def subtract(A, B):
    out = []
    for a, b in A:
        pieces = [(a, b)]
        for c, d in B:
            nxt = []
            for u, v in pieces:
                if d <= u or c >= v:
                    nxt.append((u, v))
                else:
                    if u < c:
                        nxt.append((u, c))
                    if d < v:
                        nxt.append((d, v))
            pieces = nxt
        out.extend(pieces)
    return sorted(out)


def intersect(A, B):
    out = []
    for a, b in A:
        for c, d in B:
            lo, hi = max(a, c), min(b, d)
            if lo < hi:
                out.append((lo, hi))
    return sorted(out)


def carve(free, amount):
    taken = []
    for a, b in free:
        if amount <= 0:
            break
        L = b - a
        if L <= amount:
            taken.append((a, b)); amount -= L
        else:
            taken.append((a, a + amount)); amount = 0
    assert amount == 0
    return taken


FAM = {}
for c in nonroot:
    FAM.setdefault((c[:-1], c[-1][0]), []).append(c)


def family(z):
    return FAM[(z[:-1], z[-1][0])]


S = {z: [] for z in nodes}
S[()] = [(Fr(0), Fr(1))]
viol_I3 = 0
ahead = 0
for t in range(1, T_STAGES + 1):
    for z in order[:t]:
        p = z[:-1]
        used = [iv for c in family(z) for iv in S[c]]
        free = subtract(S[p], sorted(used))
        want = rho_t(z, t) - meas(S[z])
        add = min(want, meas(free))
        if add > 0:
            S[z] = sorted(S[z] + carve(free, add))
        if meas(S[z]) > rho_t(z, t):
            viol_I3 += 1
    for z in order[:t]:
        if len(z) >= 2 and rho_t(z, t) > rho_t(z[:-1], t):
            ahead += 1

viol_I1 = sum(1 for z in nonroot if meas(subtract(S[z], S[z[:-1]])) != 0)
viol_I2 = 0
for z in nonroot:
    for c in family(z):
        if c != z and meas(intersect(S[z], S[c])) != 0:
            viol_I2 += 1
# exact generated semimeasure
bad = 0
for z in nonroot:
    ev = [(Fr(0), Fr(1))]
    for i in range(1, len(z) + 1):
        ev = intersect(ev, S[z[:i]])
    if meas(ev) != rho[z]:
        bad += 1
print(f"nodes: {len(nonroot)} non-root; stages: {T_STAGES}; (stage, node) pairs with child approximation above "
      f"the parent's: {ahead}")
print(f"(I1) nesting violations: {viol_I1}; (I2) family-overlap violations: {viol_I2}; (I3) violations: {viol_I3}")
print(f"nodes whose exactly computed generated probability differs from rho: {bad} (claim: 0)")
assert viol_I1 == viol_I2 == viol_I3 == bad == 0
print("ALL CHECKS PASSED")
