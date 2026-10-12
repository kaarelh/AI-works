"""c11: the conjunction ladder under many tie rules and two adversaries (notes-final.md, Theorem 3.11 and
Remark 3.11b; referee M1).

Target f = AND of all d variables on {0,1}^d.  Occam = least size, ties broken by a tie rule.

Tie rules (7): truth-table index ascending; descending; 5 seeded pseudo-random orders
rank(t) = ((t * A) XOR B) mod 2^64 with A odd (a bijection of 64-bit integers), A, B from SEED.

Adversary L (Theorem 3.11): 1^d, then 0^d, then the inputs of weight 1, 2, ..., d-1 level by level; inside a
  level, an input on which the current Occam hypothesis errs if there is one (else the next level input).
  Reported: mistakes per level k, total, and whether every input of weight k is a mistake for the levels the
  theorem covers (formulas: k = 1..d-1; circuits: k = 2..d-1).
Adversary R (the referee's R1): 1^d first; then, while the current Occam hypothesis h has size < c(f)
  (formulas: < d; circuits: < d-1), reveal 1_{V_h}, the point with ones exactly on the variables h depends on.
  When no enumerated function is consistent, Occam's hypothesis has size >= c(f) and the phase ends.
  Reported: mistakes in the phase and whether every input of weight 2..d-1 was revealed as a mistake.

Languages: formulas (leaves x_j, not x_j, 0, 1; AND, OR, XOR; size = leaves; enumerated to size d) and the
circuits of Section 3.2 (16 gates; size = gates; enumerated to size d-2).  d = 3, 4, 5.
Seeded (SEED = 11); the enumerations are deterministic.
"""
import numpy as np

SEED = 11
out = []


def P(s):
    print(s)
    out.append(s)


def var_tt(d, j):
    return sum(1 << i for i in range(1 << d) if (i >> j) & 1)


def weight(i):
    return bin(i).count("1")


def formula_sizes(d, smax):
    NP = 1 << d
    FULL = (1 << NP) - 1
    leaves = set()
    for j in range(d):
        t = var_tt(d, j)
        leaves |= {t, FULL ^ t}
    leaves |= {0, FULL}
    best = {t: 1 for t in leaves}
    G = {1: np.array(sorted(leaves), dtype=np.uint64)}
    for s in range(2, smax + 1):
        new = set()
        for a in range(1, s // 2 + 1):
            A, B = G[a], G[s - a]
            for op in (np.bitwise_and, np.bitwise_or, np.bitwise_xor):
                new |= set(op.outer(A, B).ravel().tolist())
        for t in new:
            if t not in best:
                best[t] = s
        G[s] = np.array(sorted(best.keys()), dtype=np.uint64)
    return best


def circuit_sizes(d, smax):
    NP = 1 << d
    FULL = np.uint64((1 << NP) - 1)
    src = [np.uint64(var_tt(d, j)) for j in range(d)] + [np.uint64(0), FULL]
    best = {}
    states = {frozenset()}
    for s in range(1, smax + 1):
        nstates = set()
        for st in states:
            avail = np.array(src + sorted(st), dtype=np.uint64)
            u = avail[:, None]
            v = avail[None, :]
            nu, nv = ~u & FULL, ~v & FULL
            parts = [nu & nv, nu & v, u & nv, u & v]
            vals = set()
            for op in range(16):
                r = np.zeros((len(avail), len(avail)), dtype=np.uint64)
                for b in range(4):
                    if (op >> b) & 1:
                        r |= parts[b]
                vals |= set(r.ravel().tolist())
            for g in vals:
                if g not in best:
                    best[g] = s
                if s < smax:
                    nstates.add(st | {g})
        states = nstates
    return best


def essential_vars(d, t):
    NP = 1 << d
    V = set()
    for j in range(d):
        for i in range(NP):
            if not (i >> j) & 1:
                if ((t >> i) & 1) != ((t >> (i | (1 << j))) & 1):
                    V.add(j)
                    break
    return V


rng = np.random.default_rng(SEED)
MASK64 = (1 << 64) - 1
tie_rules = [("index ascending", lambda t: t), ("index descending", lambda t: -t)]
for r in range(5):
    A = int(rng.integers(1, 2 ** 62)) * 2 + 1
    B = int(rng.integers(0, 2 ** 62))
    tie_rules.append((f"random #{r+1}", (lambda A, B: (lambda t: ((t * A) & MASK64) ^ B))(A, B)))


class Occam:
    def __init__(self, sizes, rank):
        items = sorted(sizes.items(), key=lambda kv: (kv[1], rank(kv[0])))
        self.tt = np.array([t for t, _ in items], dtype=np.uint64)
        self.sz = np.array([s for _, s in items])

    def hyp(self, known, f_tt):
        mask = np.uint64(known)
        cons = (self.tt & mask) == (np.uint64(f_tt) & mask)
        if not cons.any():
            return None, None
        idx = int(np.argmax(cons))
        return int(self.tt[idx]), int(self.sz[idx])


def run_L(d, occ, f_tt):
    NP = 1 << d
    known = 0
    per_level = {}
    every = {}

    def show(i):
        nonlocal known
        h, s = occ.hyp(known, f_tt)
        assert h is not None, "hypothesis outside the enumerated sizes"
        mis = ((h >> i) & 1) != ((f_tt >> i) & 1)
        known |= 1 << i
        return mis

    total = int(show(NP - 1)) + int(show(0))
    for k in range(1, d):
        level = [i for i in range(NP) if weight(i) == k]
        cnt = 0
        while level:
            h, _ = occ.hyp(known, f_tt)
            bad = [i for i in level if ((h >> i) & 1) != ((f_tt >> i) & 1)]
            i = bad[0] if bad else level[0]
            level.remove(i)
            cnt += int(show(i))
        per_level[k] = cnt
        every[k] = cnt == sum(1 for i in range(NP) if weight(i) == k)
        total += cnt
    return total, per_level, every


def run_R(d, occ, f_tt, cf):
    NP = 1 << d
    known = 1 << (NP - 1)  # 1^d revealed first (label 1; Occam's first guess may or may not be wrong)
    mistakes_by_weight = {}
    phase_mistakes = 0
    while True:
        h, s = occ.hyp(known, f_tt)
        if h is None or s >= cf:
            break
        V = essential_vars(d, h)
        x = sum(1 << j for j in V)
        assert not (known >> x) & 1, "1_{V_h} already revealed: h would be inconsistent"
        mis = ((h >> x) & 1) != ((f_tt >> x) & 1)
        assert mis
        phase_mistakes += 1
        mistakes_by_weight[weight(x)] = mistakes_by_weight.get(weight(x), 0) + 1
        known |= 1 << x
    all_mid = all(mistakes_by_weight.get(k, 0) == sum(1 for i in range(NP) if weight(i) == k)
                  for k in range(2, d))
    return phase_mistakes, mistakes_by_weight, all_mid


P("(a) adversary L (Theorem 3.11): mistakes per level k = 1..d-1, under 7 tie rules")
for lang in ("formulas", "circuits"):
    for d in (3, 4, 5):
        NP = 1 << d
        f_tt = 1 << (NP - 1)
        sizes = formula_sizes(d, d) if lang == "formulas" else circuit_sizes(d, d - 2)
        kmin = 1 if lang == "formulas" else 2
        bound = NP - 2 if lang == "formulas" else NP - d - 2
        rows = []
        ok_all = True
        for name, rank in tie_rules:
            occ = Occam(sizes, rank)
            total, per_level, every = run_L(d, occ, f_tt)
            ok = all(every[k] for k in range(kmin, d)) and total >= bound
            ok_all &= ok
            rows.append(f"      {name:17s} total {total:2d}; per level " +
                        " ".join(f"k={k}:{per_level[k]}" for k in range(1, d)) +
                        f"; every input of weight {kmin}..{d-1} a mistake: {all(every[k] for k in range(kmin, d))}")
        P(f"  {lang}, d={d} (lower bound {bound}): all tie rules satisfy the theorem: {ok_all}")
        for r in rows:
            P(r)

P("")
P("(b) adversary R (referee's R1): 1^d, then 1_{V_h} while c(h) < c(f); mistakes in the phase")
for lang in ("formulas", "circuits"):
    for d in (3, 4, 5):
        NP = 1 << d
        f_tt = 1 << (NP - 1)
        if lang == "formulas":
            sizes, cf = formula_sizes(d, d - 1), d
        else:
            sizes, cf = circuit_sizes(d, d - 2), d - 1
        res = []
        for name, rank in tie_rules:
            occ = Occam(sizes, rank)
            pm, byw, all_mid = run_R(d, occ, f_tt, cf)
            res.append((name, pm, byw, all_mid))
        P(f"  {lang}, d={d}: phase mistakes over tie rules: {sorted(set(r[1] for r in res))}; "
          f"every input of weight 2..{d-1} revealed as a mistake under every rule: {all(r[3] for r in res)} "
          f"(2^d-d-2 = {NP-d-2})")
        for name, pm, byw, all_mid in res:
            P(f"      {name:17s} {pm:2d} mistakes; by weight " +
              " ".join(f"{w}:{byw[w]}" for w in sorted(byw)))

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
