"""c4: the interval-allocation construction of Thm 4.2 (every lower-semicomputable chronological
semimeasure rho is generated exactly by a history-oracle function machine) on finite instances.

Finite setting: inputs X = {0,1}, labels Y = {0,1,2}, depth n = 3.  rho is a random chronological
semimeasure with dyadic values.  rho is presented only through an increasing sequence of dyadic
lower approximations rho_t (t = 1..T, rho_T = rho), with independent random schedules per node,
so that at intermediate stages children may be ahead of their parent.

The construction (exactly as in the proof):
  S(root) = [0,1).  At each stage t, for nodes in order of depth, the node z = (x_{1:k}, y_{1:k})
  with parent p and family F = {siblings with the same x_k} receives
      add = min( rho_t(z) - lambda(S(z)),  lambda(S(p) minus union of S(F)) )
  carved from that free space.  S only grows.
Machine: T^omega(x_{1:k}) = y_k iff omega in S(x_{1:k}, y_{1:k}) with y_{<k} computed recursively.

Checks: (1) lambda(S(z)) = rho(z) exactly for every node at the end; (2) siblings in a family are
disjoint and each S(z) is inside S(parent); (3) S_t grows with t; (4) Monte Carlo: simulate the
machine on random omega and random input sequences; empirical frequencies match rho.
Seed 11.  Output saved to c4_chrono_representation.out.
"""
import itertools, random
from fractions import Fraction as Fr

SEED = 11
random.seed(SEED)
X = (0, 1); Y = (0, 1, 2); n = 3; T = 6; GRID = 2 ** 16

def dyadic_split(total):
    """random dyadic parts p_y >= 0 with sum <= total (total dyadic)"""
    parts = []
    rem = total
    for y in Y:
        q = Fr(random.randint(0, 8), 8)  # dyadic fraction of the remainder
        p = rem * q
        parts.append(p)
        rem -= p
    return parts

# nodes: tuples ((x1,y1),...,(xk,yk)); rho on nodes
rho = {(): Fr(1)}
nodes_by_depth = {0: [()]}
for k in range(n):
    nodes_by_depth[k + 1] = []
    for z in nodes_by_depth[k]:
        for x in X:
            parts = dyadic_split(rho[z])
            for y, p in zip(Y, parts):
                c = z + ((x, y),)
                rho[c] = p
                nodes_by_depth[k + 1].append(c)

# lower approximations with random schedules: rho_t(z) = floor(GRID * rho(z) * s_t(z)) / GRID, s_T = 1
sched = {}
for z in rho:
    s = sorted(random.random() for _ in range(T - 1)) + [1.0]
    sched[z] = s
def rho_t(z, t):
    if t >= T:
        return rho[z]
    v = Fr(int(GRID * float(rho[z]) * sched[z][t - 1]), GRID)
    return min(v, rho[z])

# monotonicity of approximations
for z in rho:
    vals = [rho_t(z, t) for t in range(1, T + 1)]
    assert all(a <= b for a, b in zip(vals, vals[1:])) and vals[-1] == rho[z]

# count stages where some child's approximation exceeds the parent's approximation (exercise free-space logic)
ahead = 0
for k in range(1, n + 1):
    for z in nodes_by_depth[k]:
        for t in range(1, T):
            fam = [c for c in nodes_by_depth[k] if c[:-1] == z[:-1] and c[-1][0] == z[-1][0]]
            if sum(rho_t(c, t) for c in fam) > rho_t(z[:-1], t) and k > 1:
                ahead += 1

def measure(iv):
    return sum(b - a for a, b in iv)

def subtract(A, B):
    """A minus B, both lists of disjoint intervals"""
    out = []
    for a, b in A:
        pieces = [(a, b)]
        for c, d in B:
            new = []
            for u, v in pieces:
                if d <= u or c >= v:
                    new.append((u, v))
                else:
                    if u < c:
                        new.append((u, c))
                    if d < v:
                        new.append((d, v))
            pieces = new
        out.extend(pieces)
    return sorted(out)

def carve(free, amount):
    """take a sub-union of measure `amount` from free (sorted intervals)"""
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

S = {z: [] for z in rho}
S[()] = [(Fr(0), Fr(1))]
history = []
for t in range(1, T + 1):
    for k in range(1, n + 1):
        for z in nodes_by_depth[k]:
            p = z[:-1]
            fam = [c for c in nodes_by_depth[k] if c[:-1] == p and c[-1][0] == z[-1][0]]
            used = []
            for c in fam:
                used.extend(S[c])
            free = subtract(S[p], sorted(used))
            want = rho_t(z, t) - measure(S[z])
            add = min(want, measure(free))
            if add > 0:
                S[z] = sorted(S[z] + carve(free, add))
    history.append({z: list(S[z]) for z in S})

# (1) exactness
bad = [z for z in rho if measure(S[z]) != rho[z]]
print(f"nodes: {len(rho)}; stage-node pairs with children ahead of parent: {ahead}")
print(f"(1) nodes with lambda(S(z)) != rho(z): {len(bad)}")
# (2) disjointness and nesting
def inside(A, B):
    return measure(subtract(A, B)) == 0
viol2 = 0
for k in range(1, n + 1):
    for z in nodes_by_depth[k]:
        if not inside(S[z], S[z[:-1]]):
            viol2 += 1
        fam = [c for c in nodes_by_depth[k] if c[:-1] == z[:-1] and c[-1][0] == z[-1][0] and c != z]
        for c in fam:
            inter = measure(S[z]) - measure(subtract(S[z], S[c]))
            if inter != 0:
                viol2 += 1
print(f"(2) nesting/disjointness violations: {viol2}")
# (3) growth
viol3 = 0
for a, b in zip(history, history[1:]):
    for z in rho:
        if not inside(a[z], b[z]):
            viol3 += 1
print(f"(3) growth violations: {viol3}")

# (4) Monte Carlo machine simulation
def machine(omega, xs):
    """labels output by T^omega on input list xs (None if undefined)"""
    z = ()
    out = []
    for x in xs:
        nxt = None
        for y in Y:
            c = z + ((x, y),)
            if any(a <= omega < b for a, b in S[c]):
                nxt = y
                break
        if nxt is None:
            return out
        out.append(nxt)
        z = z + ((x, nxt),)
    return out

N = 200000
rng = random.Random(SEED + 1)
maxdev = 0.0
for xs in itertools.product(X, repeat=n):
    counts = {}
    for _ in range(N // 8):
        om = Fr(rng.getrandbits(40), 2 ** 40)
        ys = tuple(machine(om, xs))
        if len(ys) == n:
            counts[ys] = counts.get(ys, 0) + 1
    for ys in itertools.product(Y, repeat=n):
        z = tuple(zip(xs, ys))
        emp = counts.get(ys, 0) / (N // 8)
        maxdev = max(maxdev, abs(emp - float(rho[z])))
print(f"(4) Monte Carlo ({N // 8} omegas per input sequence): max |empirical - rho| = {maxdev:.4f}")
assert not bad and viol2 == 0 and viol3 == 0 and maxdev < 0.01
print("ALL CHECKS PASSED")
