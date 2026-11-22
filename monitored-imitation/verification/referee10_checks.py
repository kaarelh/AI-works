"""Referee 10 checks for paper/verified-slack-imitation.tex (Section 5, Proposition 4.10, numbers).

Usage: python3 referee10_checks.py   (standard library only; under 10 s)

Part A. A general stress test of Theorem 5.1 (blueprint search), beyond thread Y's toy.
  The human P is a deterministic function of a call's transcript: on its own tree T* it follows a
  script (lemmas posed in rounds <= p, several per round allowed, a kernel-valid proof citing them at
  round t* <= r0); off T* it acts by a hash of the transcript (random entries, random lemmas, random
  ABANDON / proof / disproof attempts, which the "kernel" checks).  The imitator equals P except, with
  probability eps per transcript, a mistake of one of six kinds (other entries, a corrupted lemma, an
  extra lemma, ABANDON, a proof attempt with another token, a random label).  Lemma truth: lemmas of
  T* are true; other lemmas are true with probability 1/2; only true statements can be proved, only
  false ones disproved.  Records (proved / disproved / open) are all a parent sees.  The imitator
  learns each hit transcript.  The paper's search (scan rounds; after a correct round that posed a
  lemma whose record is not "proved", descend into the first such lemma) is run on every rejection.
  Checked on every rejection whose root record is not "proved": the search hits; every path call is
  the human's own lemma (certified), posed at the human's round after a mistake-free prefix; cost <=
  sum pi_l + t*(u_L) <= p d + r0.

Part B. The final whole-development check (the paper's "Output" bullet: "a failure of this check is a
  rejection").  Mistakes may write a "dirty" proof (accepted by the node kernel, rejected by the final
  hardened check: a non-whitelisted axiom, native_decide, or a bug of one kernel).  Then a rejection can
  have every record "proved"; the paper's search then ends with no hit, the decoder is unchanged, and
  the rerun repeats the rejection.  Two fixes are tested: (1) node records use the hardened check;
  (2) on a final-check failure, scan the run depth-first (cost <= N*_r).

Part C. Proposition 4.10(b), the new clause "without (A3'), at most 2n" (cache-first decoding, S,U,S,H
  with the scan skipping cached notebooks without using up its turn, adversarial learners).

Part D. Numbers quoted in Section 5 and Section 4.
"""

import hashlib
import random
from collections import Counter


def H(*a):
    return int.from_bytes(hashlib.blake2b(repr(a).encode(), digest_size=8).digest(), "big")


# ============================================================== Part A/B: blueprint trees


class World:
    def __init__(self, seed, d, r0, s, pmax, maxlem, eps, dirty=0.0, hardened=False):
        self.rng = random.Random(seed)
        self.seed, self.d, self.r0, self.s, self.pmax, self.maxlem = seed, d, r0, s, pmax, maxlem
        self.eps, self.dirty, self.hardened = eps, dirty, hardened
        self.plan = {}
        self.by_h = {}
        self.nid = 0
        self.known = set()

    # ---- the human's own tree
    def new_root(self):
        q = ("Q", self.fresh(), self.d)
        self.gen(q)
        return q

    def fresh(self):
        self.nid += 1
        return self.nid

    def gen(self, q):
        rng, h = self.rng, q[2]
        t = rng.randint(1, self.r0)
        lem = {}
        if h > 0 and t >= 2 and rng.random() < 0.85:
            for _ in range(rng.randint(1, self.maxlem)):
                j = rng.randint(1, min(self.pmax, t - 1))
                q2 = ("Q", self.fresh(), h - 1)
                lem.setdefault(j, []).append(q2)
                self.by_h.setdefault(h - 1, []).append(q2)
                self.gen(q2)
        cite = tuple(x for j in sorted(lem) for x in lem[j])
        labels = []
        for j in range(1, t + 1):
            term = ("proof", self.tok(q), cite) if j == t else ("none",)
            labels.append((rng.randrange(10**6), tuple(lem.get(j, [])), term))
        self.plan[q] = labels

    def truth(self, q):
        return q[0] == "Q" or H("truth", q) % 2 == 0

    def toks(self, q):
        t = {x for x in range(8) if H("tok", q, x) % 3 == 0}
        return t or {0}

    def tok(self, q):
        return min(self.toks(q))

    def node_valid(self, q, term, S):
        if term[0] == "proof":
            tok, cite = term[1], term[2]
            if tok >= 100 and self.hardened:
                return False
            return self.truth(q) and (tok % 100) in self.toks(q) and set(cite) <= S
        if term[0] == "disproof":
            return (not self.truth(q)) and (term[1] % 100) in self.toks(q)
        return False

    # ---- P and G
    def rand_label(self, seed, q):
        r, h = random.Random(seed), q[2]
        posed = ()
        if h > 0 and r.random() < 0.3:
            ps = []
            for _ in range(r.randint(1, 2)):
                pool = self.by_h.get(h - 1, [])
                ps.append(r.choice(pool) if (pool and r.random() < 0.3) else ("R", r.randrange(10**9), h - 1))
            posed = tuple(ps)
        x = r.random()
        if x < 0.08:
            term = ("abandon",)
        elif x < 0.25:
            term = ("proof", r.randrange(8), ())
        elif x < 0.30:
            term = ("disproof", r.randrange(8))
        else:
            term = ("none",)
        return (r.randrange(10**6), posed, term)

    def P(self, q, tr, j, on):
        if on and j < len(self.plan[q]):
            return self.plan[q][j]
        return self.rand_label(H("P", tr), q)

    def G(self, q, tr, j, on):
        lab = self.P(q, tr, j, on)
        if tr in self.known or H("G", self.seed, tr) % 10**6 >= self.eps * 10**6:
            return lab
        r, h = random.Random(H("M", self.seed, tr)), q[2]
        e, posed, term = lab
        k = r.randrange(6)
        if k == 0:
            e = r.randrange(10**6)
        elif k == 1 and posed:
            i = r.randrange(len(posed))
            posed = tuple(("R", r.randrange(10**9), h - 1) if a == i else x for a, x in enumerate(posed))
        elif k == 2:
            term = ("abandon",)
        elif k == 3:
            term = ("proof", r.randrange(8), ())
        elif k == 4 and h > 0:
            posed = posed + (("R", r.randrange(10**9), h - 1),)
        elif k == 5:
            return self.rand_label(H("MR", self.seed, tr), q)
        else:
            e = r.randrange(10**6)
        if self.dirty and r.random() < self.dirty:
            term = ("proof", 100 + self.tok(q), ())
        return (e, posed, term)

    # ---- runs
    def run(self, q, dec):
        tr, on, S, rounds = H("start", q), q in self.plan, set(), []
        for j in range(self.r0 + self.s):
            lab = dec(q, tr, j, on)
            kids = [self.run(q2, dec) for q2 in lab[1]] if q[2] > 0 else []
            recs = tuple(k["rec"] for k in kids)
            rounds.append((tr, j, on, lab, kids))
            term = lab[2]
            if term[0] == "abandon":
                return dict(q=q, rounds=rounds, rec="open", term=j)
            if term[0] in ("proof", "disproof") and self.node_valid(q, term, S):
                return dict(q=q, rounds=rounds, rec="proved" if term[0] == "proof" else "disproved", term=j)
            for q2, rc in zip(lab[1], recs):
                if rc == "proved":
                    S.add(q2)
            on = on and j < len(self.plan[q]) and lab == self.plan[q][j] and all(rc == "proved" for rc in recs)
            tr = H(tr, lab, recs)
        return dict(q=q, rounds=rounds, rec="open", term=None)

    def final_check(self, cr):
        """Assemble the proof cone of an accepted root; fail on any dirty token (hardened pipeline)."""
        tok, cite = cr["rounds"][cr["term"]][3][2][1:3]
        if tok >= 100:
            return False
        for qd in cite:
            child = next(k for (_, _, _, lab, kids) in cr["rounds"][: cr["term"]] for k in kids
                         if k["q"] == qd and k["rec"] == "proved")
            if not self.final_check(child):
                return False
        return True

    def shape(self, q, depth=0, acc=None):
        acc = acc or dict(N=0, p=0, r0=0, d=0)
        L = self.plan[q]
        acc["N"] += len(L)
        acc["r0"] = max(acc["r0"], len(L))
        acc["d"] = max(acc["d"], depth)
        for j, lab in enumerate(L):
            if lab[1]:
                acc["p"] = max(acc["p"], j + 1)
            for q2 in lab[1]:
                self.shape(q2, depth + 1, acc)
        return acc


def paper_search(W, root):
    """The paper's search; returns (hit or None, cost, path [(call, rounds scanned)], cover)."""
    u, cost, path, cover = root, 0, [], Counter()
    while True:
        nxt = None
        for (tr, j, on, lab, kids) in u["rounds"]:
            cost += 1
            if lab != W.P(u["q"], tr, j, on):
                if u["q"] in W.plan and j == len(W.plan[u["q"]]) - 1:
                    cover["hit at the round that writes the human's proof"] += 1
                if path:
                    cover["hit inside a child call"] += 1
                return (u, j, tr), cost, path + [(u, j + 1)], cover
            bad = [k for k in kids if k["rec"] != "proved"]
            if bad:
                if len(kids) >= 2:
                    cover["descent from a round that posed >= 2 lemmas"] += 1
                if bad[0] is not kids[0]:
                    cover["descent into a lemma that is not the round's first"] += 1
                nxt = (j, bad[0])
                break
        if nxt is None:
            return None, cost, path + [(u, len(u["rounds"]))], cover
        path.append((u, nxt[0] + 1))
        u = nxt[1]


def dfs_seq(cr, out):
    for (tr, j, on, lab, kids) in cr["rounds"]:
        out.append((cr["q"], tr, j, on, lab))
        for k in kids:
            dfs_seq(k, out)
    return out


def tree_experiment(name, cfg, problems, out, fix=None):
    W = World(**cfg)
    st = Counter()
    cover = Counter()
    worst = 0.0
    for _ in range(problems):
        root_q = W.new_root()
        sh = W.shape(root_q)
        tstar = W.run(root_q, lambda q, tr, j, on: W.P(q, tr, j, on))
        assert tstar["rec"] == "proved" and W.final_check(tstar), "(A2-tree) violated by construction"
        for _rerun in range(2000):
            ru = W.run(root_q, W.G)
            if len(ru["rounds"]) > len(W.plan[root_q]):
                st["runs whose root used rounds after the human's t*"] += 1
            if ru["rec"] == "proved" and W.final_check(ru):
                st["outputs"] += 1
                break
            st["rejections"] += 1
            kind = "root record not proved" if ru["rec"] != "proved" else "root proved, final check failed"
            st[kind] += 1
            hit, cost, path, cv = paper_search(W, ru)
            cover.update(cv)
            if hit is None and kind == "root proved, final check failed" and fix == "dfs":
                seq = dfs_seq(ru, [])
                f = next((i for i, x in enumerate(seq) if x[4] != W.P(x[0], x[1], x[2], x[3])), None)
                if f is not None and f + 1 <= sh["N"]:
                    st["dfs fallback hits within N*_r"] += 1
                    cost += f + 1
                    hit = (None, None, seq[f][1])
                else:
                    st["dfs fallback FAILED"] += 1
            if hit is None:
                st["search ended without a hit (" + kind + ")"] += 1
                ru2 = W.run(root_q, W.G)  # nothing was learned: the rerun is the same run
                if [x[1] for x in dfs_seq(ru2, [])] == [x[1] for x in dfs_seq(ru, [])]:
                    st["  ...and the rerun repeats the same rejection"] += 1
                st["problems abandoned (would loop forever)"] += 1
                break
            W.known.add(hit[2])
            if hit[0] is None:
                continue
            # checks of Theorem 5.1 (c)
            ok = True
            for (u1, js), (u2, _) in zip(path[:-1], path[1:]):
                if u1["q"] not in W.plan or js > len(W.plan[u1["q"]]) or u2["q"] not in W.plan[u1["q"]][js - 1][1]:
                    ok = False  # path lemma not the human's own, or not posed at the human's round
                if any(lab != W.P(u1["q"], tr, j, on) for (tr, j, on, lab, _) in u1["rounds"][:js]):
                    ok = False  # scanned prefix not mistake-free
            uL = path[-1][0]
            bound = sum(js for (_, js) in path[:-1]) + (len(W.plan[uL["q"]]) if uL["q"] in W.plan else 10**9)
            if uL["q"] not in W.plan:
                ok = False
            st["certification held"] += ok
            st["certification FAILED"] += (not ok)
            st["cost <= sum pi + t*(u_L)"] += cost <= bound
            st["cost > sum pi + t*(u_L)"] += cost > bound
            st["cost <= p d + r0"] += cost <= sh["p"] * sh["d"] + sh["r0"]
            st["cost > p d + r0"] += cost > sh["p"] * sh["d"] + sh["r0"]
            worst = max(worst, cost / max(1, sh["p"] * sh["d"] + sh["r0"]))
            st["sum of costs"] += cost
            st["sum of N*_r at rejections"] += sh["N"]
    out.append(f"--- {name}: {problems} problems, cfg {cfg}" + (f", fix = {fix}" if fix else ""))
    for k in sorted(st):
        if not k.startswith("sum"):
            out.append(f"    {k}: {st[k]}")
    nh = st["certification held"] + st["certification FAILED"]
    if nh:
        out.append(f"    mean cost per hit {st['sum of costs']/nh:.1f}; mean N*_r at those rejections "
                   f"{st['sum of N*_r at rejections']/nh:.1f}; largest cost/(p d + r0) {worst:.2f}")
    for k in sorted(cover):
        out.append(f"    coverage: {k}: {cover[k]}")
    return st


def minimal_counterexample(out):
    """Root R poses lemma A in round 1 and proves R from A in round 2; A is a leaf the human proves in
    round 1 with a clean proof.  The imitator writes a dirty proof of A (node kernel accepts; the final
    hardened check rejects).  All records are 'proved'; the search scans R's two rounds and stops."""
    W = World(seed=0, d=1, r0=2, s=2, pmax=1, maxlem=1, eps=0.0)
    R, A = ("Q", 1, 1), ("Q", 2, 0)
    W.plan = {A: [(7, (), ("proof", W.tok(A), ()))],
              R: [(5, (A,), ("none",)), (6, (), ("proof", W.tok(R), (A,)))]}
    W.by_h = {0: [A]}

    def G(q, tr, j, on):
        lab = W.P(q, tr, j, on)
        if q == A and j == 0 and tr not in W.known:
            return (7, (), ("proof", 100 + W.tok(A), ()))
        return lab

    ru = W.run(R, G)
    hit, cost, path, _ = paper_search(W, ru)
    seq = dfs_seq(ru, [])
    f = next(i for i, x in enumerate(seq) if x[4] != W.P(x[0], x[1], x[2], x[3]))
    out.append("--- minimal counterexample (root R -> lemma A; dirty proof of A)")
    out.append(f"    root record: {ru['rec']}; A's record: {ru['rounds'][0][4][0]['rec']}; final check passes: {W.final_check(ru)}")
    out.append(f"    paper's search: hit = {hit is not None}, task queries = {cost} (scans R's rounds 1-2, never descends)")
    out.append(f"    depth-first scan: first mistake at position {f + 1} (A's round 1), N*_r = 3")


# ============================================================== Part C: Proposition 4.10(b) without (A3')


def prop410(n0, n, mode, learner, problems, seed, beta=1.0):
    rng = random.Random(seed)
    worst, outcomes = 0, Counter()
    for pr in range(problems):
        P = lambda y: H("P", pr, y) % 3
        chain = [()]
        for i in range(n + 5):
            chain.append(chain[-1] + (P(chain[-1]),))
        if mode == "A3'":
            V = lambda y: y[: n0] == chain[n0][: n0]           # accepts every extension of c_{n0}
        elif mode == "never":
            V = lambda y: False                                 # (A3') fails: the human's chain never verifies
        else:
            m = (n0 + n) // 2 + 1
            V = lambda y: y[:m] == chain[m][:m]                 # human finishes at m in (n0, n]: (A3') fails
        cache, queries, rerun = {}, 0, 0
        while True:
            rerun += 1
            y = ()
            for k in range(n):
                if y in cache:
                    lab = cache[y]
                else:
                    lab = learner(y, rerun, chain, P, rng)
                y = y + (lab,)
            run = [y[:k] for k in range(n)]
            if V(y):
                if rng.random() < beta:
                    yk = run[rng.randrange(n)]
                    if yk not in cache:
                        cache[yk] = P(yk)
                        queries += 1
                outcomes["output"] += 1
                break
            mis = [y[k] != P(run[k]) for k in range(n)]
            s_ptr, q, hit, exhausted = 0, 0, False, False
            cyc = "SUSH"
            while not hit:
                kind = cyc[q % 4]
                q += 1
                if kind in "SH":  # H empty: its turn goes to S
                    while s_ptr < n and run[s_ptr] in cache:
                        s_ptr += 1  # skip cached notebooks without using up the turn
                    if s_ptr >= n:
                        exhausted = not any(mis)
                        if exhausted:
                            break
                        continue
                    k = s_ptr
                    s_ptr += 1
                else:
                    k = rng.randrange(n)
                    if run[k] in cache:
                        continue
                cache[run[k]] = P(run[k])
                queries += 1
                hit = mis[k]
            if exhausted:
                outcomes["abstain"] += 1
                break
        worst = max(worst, queries)
    return worst, outcomes


def L_wrong(y, rerun, chain, P, rng):
    return (P(y) + 1) % 3


def L_late(y, rerun, chain, P, rng):
    # right on the human's chain except at a position that moves right with every rerun
    k = len(y)
    return P(y) if (y == chain[k] and k != rerun - 1) else (P(y) + 1) % 3


def L_random(y, rerun, chain, P, rng):
    return rng.randrange(3)


def L_offchain(y, rerun, chain, P, rng):
    # right on the chain prefix it has been taught, then one wrong step, then right off the chain
    k = len(y)
    return (P(y) + 1) % 3 if (y == chain[k] and H("x", rerun, k) % 4 == 0) else P(y)


# ============================================================== main


def main():
    out = []
    out.append("=" * 78)
    out.append("A. Theorem 5.1 under general deviations (no dirty proofs)")
    out.append("=" * 78)
    cfgs = [
        ("d=2, r0=6, s=4, p<=3, <=3 lemmas/call, eps=0.05", dict(seed=1, d=2, r0=6, s=4, pmax=3, maxlem=3, eps=0.05)),
        ("d=3, r0=8, s=6, p<=4, <=3 lemmas/call, eps=0.03", dict(seed=2, d=3, r0=8, s=6, pmax=4, maxlem=3, eps=0.03)),
        ("d=3, r0=5, s=0 (no slack), p<=4, eps=0.08", dict(seed=3, d=3, r0=5, s=0, pmax=4, maxlem=2, eps=0.08)),
        ("d=4, r0=4, s=3, p<=3, eps=0.04", dict(seed=4, d=4, r0=4, s=3, pmax=3, maxlem=2, eps=0.04)),
    ]
    for name, cfg in cfgs:
        tree_experiment(name, cfg, 600, out)
    out.append("")
    out.append("=" * 78)
    out.append("B. The final whole-development check: rejections with every record 'proved'")
    out.append("=" * 78)
    minimal_counterexample(out)
    base = dict(seed=5, d=3, r0=6, s=4, pmax=3, maxlem=3, eps=0.05, dirty=0.15)
    tree_experiment("dirty proofs, node kernel only (the paper's model)", base, 600, out)
    tree_experiment("fix 1: node records use the hardened check", dict(base, hardened=True), 600, out)
    tree_experiment("fix 2: depth-first scan after a final-check failure", base, 600, out, fix="dfs")
    out.append("")
    out.append("=" * 78)
    out.append("C. Proposition 4.10(b): per-problem task queries, cache-first decoding, S,U,S,H, beta = 1")
    out.append("=" * 78)
    for n0, n in [(4, 8), (8, 12), (16, 24)]:
        for mode in ["A3'", "never", "late"]:
            for lname, L in [("always wrong", L_wrong), ("late mistake", L_late), ("random", L_random),
                             ("off-chain", L_offchain)]:
                w, oc = prop410(n0, n, mode, L, 60, seed=n0 * 7 + len(mode))
                a3 = mode == "A3'"
                cap, capname = (2 * n0, "2n0") if a3 else (2 * n, "2n")
                out.append(f"    n0={n0:2d} n={n:2d} V:{mode:6s} learner {lname:12s}: max task queries/problem {w:3d} "
                           f"(cap {capname} = {cap}) {'ok' if w <= cap else 'EXCEEDED'}; {dict(oc)}")
    out.append("")
    out.append("=" * 78)
    out.append("D. Numbers")
    out.append("=" * 78)
    out.append(f"    p d + r0 over p in [2,10], d in [2,3], r0 in [3,15]: {2*2+3} .. {10*3+15}  (paper: 7-45)")
    f1 = 0.95 * 0.75 * 0.85 * 0.90
    f2 = 0.95 * 0.55 * 0.70 * 0.85
    out.append(f"    thread Y products: formalization {f1:.3f}, research {f2:.3f}; mean with 31%: {(f1+f2)/2:.3f}; "
               f"mean with 35%: {(f1+0.35)/2:.3f}  (paper: 55%, 35%, about 45%)")
    c = 0.6 * 0.43 / (1 - 0.6 * 0.43)
    out.append(f"    c = wf/(1-wf) at w=0.6, f=0.43: {c:.3f} (paper: about 0.35); 20(c+1) = {20*(c+1):.1f} (paper: 'about 25')")
    out.append(f"    any-claim rule, k claims: (1-f)^-k - 1 = (1-(1-f)^k)/(1-f)^k at f=0.2, k=2: {(0.8**-2)-1:.4f} vs {(1-0.8**2)/0.8**2:.4f}")
    print("\n".join(out))


if __name__ == "__main__":
    main()
