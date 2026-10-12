"""c9: finite checks for the tape-length bound, the exact constant (2/3)^k, and the swap data
(notes-final.md Prop 4.4, Thm 3.5 remark, Example 6.4; referee items M2, m3, m2).

 (a) Prop 4.4 (tape-length bound), finite analogue.  A random shared-tape function machine T on
     inputs {0,..,4} with labels {0,1,2} is a consistent set of triples (x, w, y), |w| <= 7,
     including early certificates on prefixes.  For a stored tape prefix w of length L,
     phi_{T,w}(x) := y if some (x, w', y) in T has w' a prefix of w.  Checked: phi_{T,w} is well
     defined (no two labels); nu^(L)(D) := Pr_w[phi_{T,w} contains D] (w uniform on {0,1}^L) is
     nondecreasing in L and equals nu(D) at L = 7, for all 4^5 data sets (labels or undefined),
     over 30 random machines.  Also the lookup machine F(x) = omega_{j(x)} on {0,1}^{<=n}:
     Pr_w[phi_w contains D] = 2^{-|D|} for every binary-labelled D, n <= 2, L = 2^{n+1}-1.
 (b) m3: the uniform law on the three total functions (a,b,c) = (0,1,0), (1,0,1), (1,0,0)
     satisfies P(F contains D) >= (2/3) tau(D) for every D (tau of Example 2.4), and its k-fold
     product attains min_D P/tau^{(x)k} = (2/3)^k over the support of tau^{(x)k}, for k = 1..4,
     while sum_i P(F contains E_i) = 1 (so the counting upper bound is met).  Exact rationals.
 (c) m2: the machine F(x) = x XOR omega_{1:|x|} gives the swap data {(x1,x2),(x2,x1)} probability
     exactly 2^{-n} for all ordered pairs of distinct n-bit strings, n = 1..7.

Seeded (20261012).  Output: c9_tape_tau_swap.out.txt
"""
import itertools
import random
from fractions import Fraction as Fr

SEED = 20261012
rng = random.Random(SEED)
out = []

# (a) tape-length bound, finite analogue
X = list(range(5))
Y = (0, 1, 2)
DEPTH = 7
BOT = None


def random_machine():
    global LAB
    LAB = {}
    """For each input: a random depth L_x in 1..DEPTH; a label (or none) for each w of length L_x
    chosen as a function of a random subset of tape positions (shared positions induce
    correlations); then add early certificates: if all extensions of a prefix u of length < L_x
    carry the same label y (not none), also add (x, u, y)."""
    T = {}
    for x in X:
        L = rng.randint(1, DEPTH)
        S = sorted(rng.sample(range(L), rng.randint(0, min(L, 3))))
        table = {}
        for key in itertools.product((0, 1), repeat=len(S)):
            table[key] = rng.choice(list(Y) + [BOT])
        lab = {}
        for w in itertools.product((0, 1), repeat=L):
            lab[w] = table[tuple(w[i] for i in S)]
        trip = {}
        for w, y in lab.items():
            if y is not BOT:
                trip[w] = y
        for l in range(L):
            for u in itertools.product((0, 1), repeat=l):
                ys = {lab[u + v] for v in itertools.product((0, 1), repeat=L - l)}
                if len(ys) == 1 and BOT not in ys and rng.random() < 0.7:
                    trip[u] = ys.pop()
        T[x] = trip
        LAB[x] = (L, lab)
    return T, LAB


def phi(T, w):
    """partial function certified within the stored prefix w; raises on conflict"""
    f = {}
    for x, trip in T.items():
        labs = {y for u, y in trip.items() if len(u) <= len(w) and tuple(w[:len(u)]) == u}
        if len(labs) > 1:
            raise ValueError("inconsistent")
        if labs:
            f[x] = labs.pop()
    return f


viol_mono = 0
viol_limit = 0
viol_cons = 0
ndata = 0
for trial in range(30):
    T, LABS = random_machine()
    # nu computed directly from the label tables (independent of the certificates)
    nu_tab = {}
    for w in itertools.product((0, 1), repeat=DEPTH):
        key = tuple(LABS[x][1][tuple(w[:LABS[x][0]])] for x in X)
        nu_tab[key] = nu_tab.get(key, 0) + Fr(1, 2 ** DEPTH)
    tabs = {}
    for L in range(DEPTH + 1):
        cnt = {}
        for w in itertools.product((0, 1), repeat=L):
            try:
                f = phi(T, w)
            except ValueError:
                viol_cons += 1
                continue
            key = tuple(f.get(x, BOT) for x in X)
            cnt[key] = cnt.get(key, 0) + 1
        tabs[L] = {k: Fr(v, 2 ** L) for k, v in cnt.items()}
    # nu^(L)(D) for every data set D (each x: a label or not in domain)
    for D in itertools.product(list(Y) + [BOT], repeat=len(X)):
        ndata += 1
        vals = []
        for L in range(DEPTH + 1):
            s = Fr(0)
            for key, p in tabs[L].items():
                if all(d is BOT or key[i] == d for i, d in enumerate(D)):
                    s += p
            vals.append(s)
        if any(vals[i] > vals[i + 1] for i in range(DEPTH)):
            viol_mono += 1
        nuD = sum((p for key, p in nu_tab.items()
                   if all(d is BOT or key[i] == d for i, d in enumerate(D))), Fr(0))
        if vals[DEPTH] != nuD:
            viol_limit += 1
out.append(f"(a) 30 random shared-tape machines, {ndata} (machine, data set) pairs: phi_(T,w) conflicts = {viol_cons}; "
           f"nu^(L) nondecreasing in L: violations = {viol_mono}; nu^(7) != nu (from the label tables): {viol_limit}")

lookup_bad = 0
lookup_cnt = 0
for n in (1, 2):
    inputs = [s for l in range(n + 1) for s in itertools.product((0, 1), repeat=l)]
    j = {x: i for i, x in enumerate(inputs)}
    L = len(inputs)
    for dom_size in range(0, L + 1):
        for dom in itertools.combinations(inputs, dom_size):
            for labs in itertools.product((0, 1), repeat=dom_size):
                lookup_cnt += 1
                hits = sum(1 for w in itertools.product((0, 1), repeat=L)
                           if all(w[j[x]] == y for x, y in zip(dom, labs)))
                if Fr(hits, 2 ** L) != Fr(1, 2 ** dom_size):
                    lookup_bad += 1
out.append(f"    lookup machine on {{0,1}}^<=n, n=1,2: {lookup_cnt} binary-labelled data sets; Pr_w[phi_w contains D] != 2^-|D| in {lookup_bad}")

# (b) tau and the three-function law
a, b, c = 0, 1, 2
E = [frozenset({(a, 0), (b, 1)}), frozenset({(b, 0), (c, 1)}), frozenset({(c, 0), (a, 1)})]
supp = {frozenset(): Fr(1)}
for x in (a, b, c):
    for y in (0, 1):
        supp[frozenset({(x, y)})] = Fr(1, 2)
for e in E:
    supp[e] = Fr(1, 2)
funcs = [(0, 1, 0), (1, 0, 1), (1, 0, 0)]


def P1(D):
    return Fr(sum(1 for f in funcs if all(f[x] == y for x, y in D)), 3)


ratios1 = {D: P1(D) / t for D, t in supp.items()}
out.append(f"(b) k=1: min over supp(tau) of P/tau = {min(ratios1.values())}; sum_i P(F contains E_i) = {sum(P1(e) for e in E)}")
for k in range(1, 5):
    mn = None
    for combo in itertools.product(list(supp.keys()), repeat=k):
        t = Fr(1)
        p = Fr(1)
        for blk in combo:
            t *= supp[blk]
            p *= P1(blk)
        r = p / t
        mn = r if mn is None or r < mn else mn
    tot = sum(P1(e) for e in E) ** k
    out.append(f"    k={k}: min over supp(tau^(x)k) ({len(supp)**k} data sets) of P^(x)k/tau^(x)k = {mn}  (= (2/3)^k: {mn == Fr(2, 3) ** k}); "
               f"sum over the 3^k sets E_i of P^(x)k = {tot}")

# (c) swap data under F(x) = x XOR omega_{1:|x|}
swap_ok = True
for n in range(1, 8):
    strings = list(itertools.product((0, 1), repeat=n))
    for x1 in strings:
        for x2 in strings:
            if x1 == x2:
                continue
            # event: x1 xor z = x2 and x2 xor z = x1, z uniform on {0,1}^n
            z = tuple(p ^ q for p, q in zip(x1, x2))
            # count z' satisfying both; must be exactly one (z' = z)
            # (checked by the algebra: both equations are z' = x1 xor x2)
            ok1 = tuple(p ^ q for p, q in zip(x1, z)) == x2
            ok2 = tuple(p ^ q for p, q in zip(x2, z)) == x1
            if not (ok1 and ok2):
                swap_ok = False
    # brute force count for n <= 4
    if n <= 4:
        for x1 in strings:
            for x2 in strings:
                if x1 == x2:
                    continue
                cntz = sum(1 for zz in strings
                           if tuple(p ^ q for p, q in zip(x1, zz)) == x2 and tuple(p ^ q for p, q in zip(x2, zz)) == x1)
                if cntz != 1:
                    swap_ok = False
out.append(f"(c) swap data {{(x1,x2),(x2,x1)}} under F(x) = x XOR omega_(1:|x|) has probability exactly 2^-n (n=1..7, brute force for n<=4): {swap_ok}")

text = "\n".join(out) + "\n"
print(text, end="")
with open(__file__.replace(".py", ".out.txt"), "w") as f:
    f.write(text)
