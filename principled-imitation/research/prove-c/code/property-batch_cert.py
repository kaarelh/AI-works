# Checks for Section 6 of research/prove-c/property-batch.md (the validation certificate; what single answers cannot certify).
# Pure Python.  Run:  python3 property-batch_cert.py > property-batch_cert.out
import random, math, itertools
from fractions import Fraction as Fr
from math import log, sqrt
random.seed(9)

def kl(p, q):
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return float('inf')
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s

# ================================================================ (1) Theorem 6.1 on a toy scaffold with runs of variable length
NX, NY, L = 6, 3, 3                                   # inputs 0..5, answers 0..2, horizon 3; the run stops after an answer 2
def rand_kernel():
    rows = [[random.gammavariate(0.7, 1) for _ in range(NY)] for _ in range(NX)]
    return [[v/sum(r) for v in r] for r in rows]
def next_input(z, j, x_prev, y_prev):                 # scaffold: first input from z; then a function of the previous pair
    return z % NX if j == 0 else (2*x_prev + y_prev + 1) % NX
def run(A):
    z = random.randrange(10); calls = []; x = next_input(z, 0, None, None)
    for j in range(L):
        y = random.choices(range(NY), weights=A[x])[0]; calls.append((x, y))
        if y == 2: break
        if j + 1 < L: x = next_input(z, j+1, x, y)
    return calls
def exact_freqs(A, P):
    """a(B), h(B) for the singleton tests B = {(x,y)}: expected number of calls of a run of A with (input, A's answer) = (x,y),
    resp. sum over calls with input x of P(y|x), both divided by L."""
    a = [[0.0]*NY for _ in range(NX)]; h = [[0.0]*NY for _ in range(NX)]
    def rec(j, x, pr):
        for y in range(NY):
            a[x][y] += pr*A[x][y]/L; h[x][y] += pr*P[x][y]/L
        for y in range(NY):
            if y != 2 and j + 1 < L: rec(j+1, (2*x + y + 1) % NX, pr*A[x][y])
    for z in range(10): rec(0, z % NX, 0.1)
    return a, h
delta = 0.1; pi_ = 1.0/(NX*NY)
for m in (50, 400, 3000):
    T = 2000; fail_kl = 0; fail_pair = 0; fail_never = 0
    for _ in range(T):
        A = rand_kernel(); P = rand_kernel()
        if random.random() < 0.5:
            for x in range(NX): P[x] = [P[x][0] + P[x][2], P[x][1], 0.0]          # a human who never answers 2
        a, h = exact_freqs(A, P)
        ca = [[0]*NY for _ in range(NX)]; ch = [[0]*NY for _ in range(NX)]
        for _i in range(m):
            calls = run(A); J = random.randrange(L)
            if J < len(calls):
                x, ya = calls[J]; yh = random.choices(range(NY), weights=P[x])[0]
                ca[x][ya] += 1; ch[x][yh] += 1
        bad_kl = bad_pair = bad_never = False
        for x in range(NX):
            for y in range(NY):
                if kl(ch[x][y]/m, h[x][y]) > log(2/(pi_*delta))/m: bad_kl = True
                if abs((a[x][y] - h[x][y]) - (ca[x][y] - ch[x][y])/m) > sqrt(2*log(2/(pi_*delta))/m): bad_pair = True
                if ch[x][y] == 0 and h[x][y] > log(2/(pi_*delta))/m: bad_never = True
        fail_kl += bad_kl; fail_pair += bad_pair; fail_never += bad_never
    print(f"(1) Theorem 6.1, m={m:5d}, 18 singleton tests, {T} random (imitator, human) pairs: failures of (b) divergence form {fail_kl}, of (a) paired form {fail_pair}, of 'never seen => h(B) <= ln(2/(pi delta))/m' {fail_never} (allowed {delta:.0%} = {int(delta*T)})")

# ================================================================ (2) Theorem 6.2: exact indistinguishability at non-repeating inputs
# X = {0..u-1}, answers {0,1}.  Human P0: fair coin.  Human P_f: a function f.  A procedure asks m inputs adaptively
# (a decision tree: the next input depends on the answers so far) and then accepts according to a table.
def random_procedure(u, m, repeat_ok):
    tree = {}                                         # answers-so-far (tuple) -> input asked next
    def build(ans, asked):
        if len(ans) == m: return
        cand = list(range(u)) if repeat_ok else [x for x in range(u) if x not in asked]
        x = random.choice(cand); tree[ans] = x
        for y in (0, 1): build(ans + (y,), asked + [x])
    build((), [])
    accept = {}
    def leaves(ans):
        if len(ans) == m: accept[ans] = Fr(random.randrange(0, 5), 4); return      # acceptance probability at the leaf
        for y in (0, 1): leaves(ans + (y,))
    leaves(())
    return tree, accept
def acc_coin(tree, accept, m):
    return sum(Fr(1, 2**m)*accept[ans] for ans in itertools.product((0, 1), repeat=m))
def acc_function(tree, accept, m, f):
    ans = ()
    for _ in range(m): ans = ans + (f[tree[ans]],)
    return accept[ans]
def repeat_prob_coin(tree, m):
    pr = Fr(0)
    for ans in itertools.product((0, 1), repeat=m):
        asked = [tree[ans[:i]] for i in range(m)]
        if len(set(asked)) < m: pr += Fr(1, 2**m)
    return pr
u, m = 6, 4
ok_exact = True; ok_bound = True; worst_gap = Fr(0)
for t in range(200):
    rep = (t % 2 == 1)
    tree, accept = random_procedure(u, m, rep)
    a0 = acc_coin(tree, accept, m)
    avg = sum(acc_function(tree, accept, m, f) for f in itertools.product((0, 1), repeat=u))/Fr(2**u)
    if not rep: ok_exact &= (avg == a0)
    else:
        gap = abs(avg - a0); worst_gap = max(worst_gap, gap); ok_bound &= gap <= repeat_prob_coin(tree, m)
print(f"(2) Theorem 6.2(c), u={u}, m={m}, exact rationals, 100 random adaptive procedures without repeated questions:")
print(f"    average over all 2^u functions f of Pr_f[accept] equals Pr_coin[accept]: {ok_exact}")
print(f"    100 procedures that may repeat questions: |average - coin| <= Pr_coin[some question repeated]: {ok_bound} (largest gap {float(worst_gap):.4f})")

# i.i.d. inputs from the uniform law on u points: |E_f Pr_f[accept] - Pr_coin[accept]| <= C(m,2)/u, by simulation of one fixed test
def accept_rule(xs, ys):                              # an arbitrary fixed rule of the m labelled samples
    return (sum(ys) + sum(x*y for x, y in zip(xs, ys))) % 3 == 0
for (uu, mm) in ((50, 5), (2000, 5), (2000, 30)):
    T = 200000; acc0 = 0; accf = 0
    for _ in range(T):
        xs = [random.randrange(uu) for _ in range(mm)]
        acc0 += accept_rule(xs, [random.getrandbits(1) for _ in range(mm)])
        memo = {}; ys = []
        for x in xs:
            if x not in memo: memo[x] = random.getrandbits(1)      # a fresh random function, drawn lazily
            ys.append(memo[x])
        accf += accept_rule(xs, ys)
    print(f"    i.i.d. inputs, u={uu}, m={mm}: Pr_coin[accept] = {acc0/T:.4f}, E_f Pr_f[accept] = {accf/T:.4f}, collision bound C(m,2)/u = {math.comb(mm,2)/uu:.4f}")

# ================================================================ (3) Example 6.3: parity has exactly the coin's frequency on every test that does not read all input bits
d = 5; u2 = 2**d; ok = True
par = [bin(x).count('1') % 2 for x in range(u2)]
for _ in range(500):
    skip = random.randrange(d)                        # the test does not read bit `skip`
    table = {}
    def R(x, y):
        key = (x & ~(1 << skip), y)
        if key not in table: table[key] = random.getrandbits(1)
        return table[key]
    fq_par = Fr(sum(R(x, par[x]) for x in range(u2)), u2)
    fq_coin = Fr(sum(R(x, 0) + R(x, 1) for x in range(u2)), 2*u2)
    ok &= (fq_par == fq_coin)
print(f"(3) Example 6.3, d={d}: for 500 random tests that ignore one input bit, the parity function and the fair coin have exactly equal frequencies: {ok}")
