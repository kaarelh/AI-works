"""a5 (review, math A): Section sound:tri, checked independently on propositional atoms.
A consistent theory = nonempty set of valuations Mod(T); a sentence = a set of valuations (every set is a sentence).
Bel(s) = sum pi(T) [Mod T subset s]; Dis(s) = Bel(complement s); Ind = 1 - Bel - Dis; Pl = 1 - Dis; H = Bel + Ind/2.
Checks: k-monotonicity (k = 2, 3, 4) of Bel; bracketing Bel <= P <= Pl for a mixture of completions;
Prop sound:fiftyfifty (H additive on valuations iff every positive-mass theory has <= 2 models);
Examples sound:renorm and sound:fifty.  Seeded; writes a5_trichotomy.out."""
import itertools, math
import numpy as np

out = []
def p(s):
    print(s); out.append(s)

def run(natoms, trials, rng):
    V = 2 ** natoms
    full = (1 << V) - 1
    subsets = list(range(1 << V))
    viol = {2: 0, 3: 0, 4: 0}; brk = 0; agree = 0; disagree = 0
    for _ in range(trials):
        m = int(rng.integers(1, 4))
        th = rng.choice(np.arange(1, 1 << V), size=m, replace=False)
        w = rng.dirichlet(np.ones(m))
        def bel(s): return sum(wi for t, wi in zip(th, w) if (int(t) & ~s & full) == 0)
        def pl(s): return 1 - bel(full & ~s)
        B = np.array([bel(s) for s in subsets])
        # k-monotonicity: Bel(union) >= sum_{nonempty I} (-1)^{|I|+1} Bel(intersection)
        for k in (2, 3, 4):
            for _ in range(200):
                ss = [int(x) for x in rng.integers(0, 1 << V, size=k)]
                lhs = B[np.bitwise_or.reduce(ss)]
                rhs = 0.0
                for r in range(1, k + 1):
                    for I in itertools.combinations(ss, r):
                        inter = full
                        for x in I: inter &= x
                        rhs += (-1) ** (r + 1) * B[inter]
                if lhs < rhs - 1e-12: viol[k] += 1
        # bracketing with a random completion (a random model) of each theory
        comp = []
        for t in th:
            models = [v for v in range(V) if (int(t) >> v) & 1]
            comp.append(int(rng.choice(models)))
        for s in subsets:
            P = sum(wi for c, wi in zip(comp, w) if (s >> c) & 1)
            if not (B[s] - 1e-12 <= P <= pl(s) + 1e-12): brk += 1
        # 50/50 rule: additive on valuations?
        H = np.array([B[s] + 0.5 * (1 - B[s] - B[full & ~s]) for s in subsets])
        point = np.array([H[1 << v] for v in range(V)])
        additive = abs(point.sum() - 1) < 1e-9 and all(abs(H[s] - sum(point[v] for v in range(V) if (s >> v) & 1)) < 1e-9 for s in subsets)
        crit = all(bin(int(t)).count("1") <= 2 for t in th)
        if additive == crit: agree += 1
        else: disagree += 1
    return viol, brk, agree, disagree

rng = np.random.default_rng(7)
for natoms, trials in ((2, 1500), (3, 300)):
    viol, brk, ag, dis = run(natoms, trials, rng)
    p(f"{natoms} atoms, {trials} random posteriors (1-3 theories): monotonicity violations k=2,3,4: {viol[2]}, {viol[3]}, {viol[4]}; "
      f"bracketing failures: {brk}; 50/50 criterion agrees {ag}, disagrees {dis}")

# Example sound:renorm: atoms a, b; valuations indexed by (a, b) bits; theories {a}, {b}, {not(a and b)}, 1/3 each
vals = [(a, b) for a in (0, 1) for b in (0, 1)]
def S(pred): return sum(1 << i for i, v in enumerate(vals) if pred(*v))
full = 15
th = [S(lambda a, b: a), S(lambda a, b: b), S(lambda a, b: not (a and b))]
def bel(s): return sum(1/3 for t in th if t & ~s & full == 0)
def R(s): return bel(s) / (bel(s) + bel(full & ~s))
p(f"Ex renorm: R(a)={R(S(lambda a,b:a)):.3f}, R(b)={R(S(lambda a,b:b)):.3f}, R(a&b)={R(S(lambda a,b:a and b)):.3f}")
# Example sound:fifty: empty theory over b, c
th = [full]
def bel1(s): return 1.0 if full & ~s == 0 else 0.0
def H1(s): return bel1(s) + 0.5 * (1 - bel1(s) - bel1(full & ~s))
p(f"Ex fifty: H(b)={H1(S(lambda b,c:b))}, H(b&c)={H1(S(lambda b,c:b and c))}, H(b&~c)={H1(S(lambda b,c:b and not c))}")

open(__file__.replace('.py', '.out'), 'w').write("\n".join(out) + "\n")
