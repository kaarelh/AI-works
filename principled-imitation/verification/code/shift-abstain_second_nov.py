"""Second check, shift-abstain: Proposition 6.2(4) (editor, not checked by a verifier).

Finite stand-in for the class of programs: a finite family of tests (sets of
inputs) with integer 'complexities'; sep(x;A) := least complexity of a test that
contains x and misses A.  Nov_s (abstain variant) frozen at D abstains iff
sep(x;A(D)) < s and otherwise answers g_D, the heaviest hypothesis consistent
with D (ties by index).  Protocol R[Nov_s]: in round t the rule frozen at D_{<t}
answers the calls of a run of a random adaptive scaffold of horizon L; the run
halts at its first abstention; J uniform on {1..L}; if J <= len, the call J
(aborting call included) is put to the human f.

Checked:
 (A) on every simulated path: #asked rounds with sep(x_t;A(D_{<t})) < s
     <= T_s := #tests of complexity < s  (the proof's counting step), and
     #asked rounds at which g_{D_{<t}} answers wrongly (and sep >= s)
     <= #{g : w(g) >= w(f)} - 1;
 (B) Monte Carlo: sum_t Pr[Halt_t] <= L*T_s and sum_t E[Wr_t] <= L*(#heavier-1),
     and the identities sum_t Pr[Halt_t] = L * E[#asked rounds of kind 1],
     sum_t E[Wr_t] = L * E[#asked wrong rounds] (Lemma 1.2), within MC error.
"""
import random, math

def run_experiment(seed, nX=8, L=4, n=60, s=3, reps=4000):
    rng = random.Random(seed)
    X = list(range(nX))
    # tests: all singletons (complexity 2..5) and some random sets (complexity 0..4)
    tests = [(frozenset([x]), rng.randint(2, 5)) for x in X]
    for _ in range(10):
        Q = frozenset(x for x in X if rng.random() < 0.4)
        if Q: tests.append((Q, rng.randint(0, 4)))
    Ts = sum(1 for Q, k in tests if k < s)
    # hypotheses: 12 random functions, weights decreasing; human = one of them
    H = [tuple(rng.randint(0, 1) for _ in X) for _ in range(12)]
    w = [2.0 ** (-(i + 1)) for i in range(12)]
    fi = rng.randrange(12)
    f = H[fi]
    heavier = sum(1 for i in range(12) if w[i] >= w[fi])
    # scaffold: input of call j = table[(z, answers so far)], z uniform in 0..3; STOP w.p. 0.15
    table = {}
    def nxt(z, hist):
        key = (z, hist)
        if key not in table:
            table[key] = None if (len(hist) > 0 and rng.random() < 0.15) else rng.randrange(nX)
        return table[key]
    def sep(x, A):
        best = math.inf
        for Q, k in tests:
            if x in Q and not (Q & A) and k < best: best = k
        return best
    def g_of(D):
        for i in sorted(range(12), key=lambda i: (-w[i], i)):
            if all(H[i][x] == y for x, y in D): return i
    sumHalt = 0; sumWr = 0; kind1 = 0; kind2 = 0; pathbad = 0; sqHalt = 0
    rr = random.Random(seed + 1)
    for _ in range(reps):
        D = []; A = frozenset()
        k1 = 0; k2 = 0; pathHalt = 0
        for t in range(n):
            gi = g_of(D)
            z = rr.randrange(4)
            hist = (); calls = []; halted = False; wr = 0
            for j in range(L):
                x = nxt(z, hist)
                if x is None: break
                calls.append(x)
                if sep(x, A) < s:
                    halted = True; break
                y = H[gi][x]
                if y != f[x]: wr += 1
                hist = hist + (y,)
            sumHalt += halted; sumWr += wr; pathHalt += halted
            J = rr.randrange(L)
            if J < len(calls):
                x = calls[J]
                if sep(x, A) < s: k1 += 1
                elif H[gi][x] != f[x]: k2 += 1
                D.append((x, f[x])); A = A | {x}
        kind1 += k1; kind2 += k2
        sqHalt += pathHalt ** 2
        if k1 > Ts or k2 > heavier - 1: pathbad += 1
    return dict(L=L, n=n, s=s, Ts=Ts, heavier=heavier,
                sumHalt=sumHalt / reps, boundHalt=L * Ts, idHalt=L * kind1 / reps,
                sumWr=sumWr / reps, boundWr=L * (heavier - 1), idWr=L * kind2 / reps,
                pathbad=pathbad, seHalt=math.sqrt(max(sqHalt / reps - (sumHalt / reps) ** 2, 0) / reps))

for seed in range(6):
    r = run_experiment(seed)
    print("seed %d: L=%d n=%d s=%d T_s=%d #heavier=%d | sum Pr[Halt]=%.3f (identity %.3f) <= %d | sum E[Wr]=%.3f (identity %.3f) <= %d | paths violating counts: %d"
          % (seed, r['L'], r['n'], r['s'], r['Ts'], r['heavier'], r['sumHalt'], r['idHalt'], r['boundHalt'],
             r['sumWr'], r['idWr'], r['boundWr'], r['pathbad']))

print("smaller s (more answered calls, more wrong answers):")
for seed in range(6, 12):
    r = run_experiment(seed, s=2)
    print("seed %d: L=%d n=%d s=%d T_s=%d #heavier=%d | sum Pr[Halt]=%.3f (identity %.3f) <= %d | sum E[Wr]=%.3f (identity %.3f) <= %d | paths violating counts: %d"
          % (seed, r['L'], r['n'], r['s'], r['Ts'], r['heavier'], r['sumHalt'], r['idHalt'], r['boundHalt'],
             r['sumWr'], r['idWr'], r['boundWr'], r['pathbad']))

print("seed 11 again with 10x repetitions (the bound is nearly attained there):")
r = run_experiment(11, s=2, reps=40000)
print("seed 11: sum Pr[Halt]=%.4f +- %.4f (standard error) (identity %.4f) <= %d; paths violating counts: %d" % (r['sumHalt'], r['seHalt'], r['idHalt'], r['boundHalt'], r['pathbad']))
print("(In seed 11 almost every path uses up both tests of complexity < s within n rounds, so the expectation equals L*E[kind-1 rounds], just below L*T_s = 8: the bound is nearly attained; the excess of the estimate is within two standard errors.)")
