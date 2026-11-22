"""Thread Y (formal blueprint trees): simulation for research/threadY-formal-trees.md.

numpy only.  Usage: python3 threadY_trees.py   (well under a minute)

The toy.
* A human's own isolated tree T*(problem): calls with fuel h.  An internal call (h > 0) poses
  b lemmas over its first p "planning" rounds (each lemma at a uniformly random round in 1..p)
  and writes its Lean proof in a final assembly round.  A leaf (h = 0) works for a random
  number of rounds in [r0_min, r0] and then writes its proof.  Calls return as soon as their
  terminal entry is written (proof, ABANDON, or disproof); the run budget per call is r = r0 + s.
* Abandoned lemmas (optional).  Each planned lemma is, with probability q_ab, first posed as a
  false variant (a "trial").  The trial call does its own work (an internal trial poses true
  sublemmas, which succeed) and then gives up: ABANDON (record "not proved") in the too-hard
  mode, or a kernel-checked disproof (record "disproved") in the disproof mode.  The parent then
  re-poses the corrected lemma in a later round (which may itself be a trial, geometrically).
* Hidden insights.  Each problem has Poisson(lam) insights at uniformly random rounds of T*
  (planning, assembly, leaf, and abandoned-trial rounds alike), each of a type drawn uniformly
  from m types.  The human writes the type's value there.
* The learner.  Exact Bayes over the product class (one value in [V] per type, uniform prior,
  K = m log2 V bits).  Its plurality label for an unlearned type is wrong (worst case), and one
  hit at a round needing type k teaches v_k.  So rejections <= m.
* The imitator's run.  A round needing an unlearned type is a mistake.  Lemmas posed in or after
  a mistaken round, or after a record that differs from the human's, are corrupted (false): the
  calls on them fail, and there is no mistake below them (the human would fail there too, so
  thread N's (Budget) fails exactly here).  A parent whose transcript has deviated is stuck
  (no recovery: no (B-sub)).  So there are no lucky proofs in this toy.
* Correctness.  An output is a root whose record is "proved": a kernel-checked proof by
  construction.  Node verdicts are the records the scaffold already computed (proof irrelevance).

Searches compared on every rejected run (separate learning trajectories per method):
* chain : the linearized run (depth-first execution order), the paper's S, U, S, H cycle with
          H empty (S, U, S, S); first mistake before position N*_r (the human's own tree size).
* T6    : thread N's Proposition T6 search (descend to a failing call whose children all pass,
          query the round that posed it, then uniform rounds of that call).  It assumes (Budget);
          when that fails it can stall (no mistake in that call): after 20 r draws it falls back
          to the chain search, and the cost of both is counted.
* own   : Theorem Y1/Y3's top-down search with certification (this thread).  At a call, scan its
          rounds in order; at each round, recursively search every child whose record is not
          good; stop at the first mistake; a child search that reaches the child's terminal entry
          certifies the child as the human's own.  Good = "proved" (too-hard mode) or
          "proved or disproved" (disproof mode).

Checks (asserted on every rejection):
* own: cost - A <= sum_l pi_l + t_L, where pi_l is the human's posing round of the l-th lemma on
         the search path, t_L the human's terminal round of the last call on it (<= r0 under
         (A2-tree)), and A the rounds spent certifying abandoned subtrees (A = 0 without
         abandonment or with disproofs); each path lemma is the human's own lemma, posed at the
         human's round pi_l after a mistake-free prefix; and cost <= p_max d + t_max when A = 0
         (p_max, t_max: the largest posing round and terminal round in the human's tree);
* chain: first mistake (depth-first) is before position N*_r, and cost <= 2 N*_r.
"""

import math
import numpy as np

# ------------------------------------------------------------------ the human's own tree


class Call:
    __slots__ = ("h", "rounds", "term", "rec", "lucky")

    def __init__(self, h):
        self.h, self.rounds, self.term, self.rec, self.lucky = h, [], "proof", "proved", False


def gen_call(rng, h, P, trial=False):
    c = Call(h)
    if h == 0:
        t = int(rng.integers(P["r0min"], P["r0"] + 1))
        if trial:
            t = int(rng.integers(1, P["r0"] + 1))
        c.rounds = [[None, []] for _ in range(t)]
    else:
        pose = {}  # round index -> list of child calls
        last = 0
        for _ in range(P["b"]):
            j = int(rng.integers(0, P["p"]))
            # trials before the corrected lemma (only in the human's own work, not inside trials)
            while (not trial) and rng.random() < P["qab"]:
                pose.setdefault(j, []).append(gen_call(rng, h - 1, P, trial=True))
                j += 1  # the parent re-poses the corrected lemma in the next round
            pose.setdefault(j, []).append(gen_call(rng, h - 1, P))
            last = max(last, j)
        n = last + 2  # planning rounds 0..last, then the assembly round
        c.rounds = [[None, pose.get(j, [])] for j in range(n)]
    if trial:
        c.term = P["abandon"]  # "abandon" or "disproof"
        c.rec = "fail" if c.term == "abandon" else "disproved"
        # a too-hard (true) abandoned lemma that a deviating imitator would nonetheless prove
        c.lucky = c.term == "abandon" and rng.random() < P.get("qlucky", 0.0)
    return c


def all_rounds(c, out):
    for rd in c.rounds:
        out.append(rd)
        for k in rd[1]:
            all_rounds(k, out)
    return out


def make_problem(rng, P):
    root = gen_call(rng, P["d"], P)
    rds = all_rounds(root, [])
    for _ in range(rng.poisson(P["lam"])):
        rds[int(rng.integers(len(rds)))][0] = int(rng.integers(P["m"]))
    return root, len(rds)


# ------------------------------------------------------------------ the imitator's run


class Run:
    __slots__ = ("ref", "rounds", "rec", "term")

    def __init__(self, ref):
        self.ref, self.rounds, self.rec, self.term = ref, [], "fail", None


def run_call(c, clean, L, r):
    u = Run(c)
    if not clean:  # a corrupted (false) lemma: same shape, no mistakes, fails at the budget
        for rd in c.rounds:
            u.rounds.append((False, [run_call(k, False, L, r) for k in rd[1]]))
        u.rounds += [(False, [])] * max(0, r - len(c.rounds))
        return u
    ontrack = True
    for rd in c.rounds:
        mis = rd[0] is not None and rd[0] not in L
        kids, dev = [], False
        for k in rd[1]:
            if ontrack and not mis:
                kr = run_call(k, True, L, r)
                if kr.rec != k.rec:
                    dev = True
            else:
                kr = run_call(k, False, L, r)
            kids.append(kr)
        u.rounds.append((mis, kids))
        if mis or dev:
            ontrack = False
    if ontrack:
        u.rec, u.term = c.rec, len(c.rounds) - 1
    elif c.lucky:  # a lucky proof: the run deviated inside a lemma the human abandons, and proved it
        u.rec, u.term = "proved", len(u.rounds) - 1
    else:
        u.rounds += [(False, [])] * max(0, r - len(c.rounds))
    return u


def first_mistake_type(u_round_owner, j):
    return u_round_owner.ref.rounds[j][0] if j < len(u_round_owner.ref.rounds) else None


# ------------------------------------------------------------------ searches


def linearize(u, out):
    for j, (mis, kids) in enumerate(u.rounds):
        out.append((u, j, mis))
        for k in kids:
            linearize(k, out)
    return out


def chain_search(root, rng):
    seq = linearize(root, [])
    N = len(seq)
    first = next(i for i, x in enumerate(seq) if x[2])
    s_ptr, q = 0, 0
    cycle = "SUSS"
    while True:
        kind = cycle[q % 4]
        q += 1
        if kind == "S" and s_ptr < N:
            u, j, mis = seq[s_ptr]
            s_ptr += 1
        else:
            u, j, mis = seq[int(rng.integers(N))]
        if mis:
            return q, (u, j), first


def t6_search(root, rng, good, r):
    u, parent = root, None
    while True:
        nxt = None
        for j, (mis, kids) in enumerate(u.rounds):
            for k in kids:
                if k.rec not in good:
                    nxt = (j, k)
                    break
            if nxt:
                break
        if nxt is None:
            break
        parent = (u, nxt[0])
        u = nxt[1]
    cost = 0
    if parent is not None:
        cost += 1
        pu, pj = parent
        if pu.rounds[pj][0]:
            return cost, (pu, pj), False
    for _ in range(20 * r):
        j = int(rng.integers(len(u.rounds)))
        cost += 1
        if u.rounds[j][0]:
            return cost, (u, j), False
    c2, hit, _ = chain_search(root, rng)
    return cost + c2, hit, True


def own_search(root, good, strict=True):
    """Theorem Y1/Y3 search.  Returns (seq, hit, cert_cost, path): seq is the list of queried
    (call, round, mistake) in order; path lists (call, rounds scanned) for the calls on the stack
    at the hit.  Without a hit (only possible with lucky proofs, or if (A2-tree) fails), hit is None."""
    seq = []
    state = {"cert": 0}

    def search(u, path):
        start = len(seq)
        for j, (mis, kids) in enumerate(u.rounds):
            seq.append((u, j, mis))
            if mis:
                return ("HIT", (u, j), path + [(u, j + 1)])
            for k in kids:
                if k.rec not in good:
                    res = search(k, path + [(u, j + 1)])
                    if res[0] == "HIT":
                        return res
            if u.term == j:
                break
        state["cert"] += len(seq) - start
        return ("CERT", None, None)

    res = search(root, [])
    if strict:
        assert res[0] == "HIT", "own-tree search ended without a hit: (A2-tree) or no-lucky violated"
    return seq, res[1], state["cert"], res[2]


def own_dfs_interleaved(root, good):
    """Alternate the own-tree search with a plain depth-first scan (each query cached); stop at the
    first hit of either.  Cost <= 2 min{own cost, first depth-first mistake + 1}, whatever happens."""
    seq, hit, _, _ = own_search(root, good, strict=False)
    dfs = linearize(root, [])
    asked, q, i, k = set(), 0, 0, 0
    stalled = hit is None
    while True:
        for src_ in ("own", "dfs"):
            if src_ == "own":
                if i >= len(seq):
                    continue
                u, j, mis = seq[i]
                i += 1
            else:
                u, j, mis = dfs[k]
                k += 1
            if (id(u), j) in asked:
                continue
            asked.add((id(u), j))
            q += 1
            if mis:
                return q, (u, j), stalled


def own_bound(path):
    """sum over path calls but the last of the human's posing round of the path lemma, plus the
    human's terminal round of the last path call (at most r0 under (A2-tree))."""
    return sum(js for (_, js) in path[:-1]) + len(path[-1][0].ref.rounds)


def shape_stats(c, acc):
    """acc = [max posing round, max terminal round] over the human's tree."""
    acc[1] = max(acc[1], len(c.rounds))
    for j, rd in enumerate(c.rounds):
        if rd[1]:
            acc[0] = max(acc[0], j + 1)
        for k in rd[1]:
            shape_stats(k, acc)
    return acc


# ------------------------------------------------------------------ experiment


def experiment(P, T, seed, methods=("chain", "T6", "own")):
    good = {"proved"} if P["abandon"] == "abandon" else {"proved", "disproved"}
    r = P["r0"] + P["s"]
    out = {}
    for meth in methods:
        rng = np.random.default_rng(seed)
        srng = np.random.default_rng(seed + 7919)
        L = set()
        costs, stalls, certs, sizes, bounds_ok, outputs_ok = [], 0, [], [], True, True
        for t in range(T):
            root, nstar = make_problem(rng, P)
            while True:
                ru = run_call(root, True, L, r)
                if ru.rec == "proved":
                    break  # output: a kernel-checked proof of the root statement
                if meth == "chain":
                    cost, hit, first = chain_search(ru, srng)
                    if first >= nstar or cost > 2 * nstar:
                        bounds_ok = False
                elif meth == "T6":
                    cost, hit, st = t6_search(ru, srng, good, r)
                    stalls += st
                elif meth == "own":
                    seq, hit, cert, path = own_search(ru, good)
                    cost = len(seq)
                    certs.append(cert)
                    if cost - cert > own_bound(path):
                        bounds_ok = False
                    # independent check: each path lemma is the human's own lemma, posed at the
                    # human's round pi_l, and the scanned prefix of each path call has no mistake
                    for (u1, js), (u2, _) in zip(path[:-1], path[1:]):
                        if not any(k is u2.ref for k in u1.ref.rounds[js - 1][1]):
                            bounds_ok = False
                        if any(u1.rounds[j][0] for j in range(js)):
                            bounds_ok = False
                    pmax, tmax = shape_stats(root, [0, 0])
                    if (P["qab"] == 0 or P["abandon"] == "disproof") and cost > pmax * P["d"] + tmax:
                        bounds_ok = False
                else:  # "own+dfs": the interleaved search, safe against lucky proofs
                    cost, hit, st = own_dfs_interleaved(ru, good)
                    stalls += st
                    first = next(i for i, x in enumerate(linearize(ru, [])) if x[2])
                    if cost > 2 * (first + 1) or first >= nstar:
                        bounds_ok = False
                u, j = hit
                k = u.ref.rounds[j][0]
                assert k is not None and k not in L
                L.add(k)
                costs.append(cost)
                sizes.append(nstar)
        out[meth] = dict(rej=len(costs), costs=costs, stalls=stalls, certs=certs, nstar=sizes,
                         ok=bounds_ok, learned=len(L))
    return out


def fmt(x):
    return f"{x:,.1f}" if x < 1e4 else f"{x:,.0f}"


def main():
    base = dict(d=3, b=3, p=1, r0=10, r0min=3, s=10, m=40, lam=1.0, qab=0.0, abandon="abandon")
    configs = [
        ("plan-first, d=3, b=3, no abandonment", dict()),
        ("plan-first, d=4, b=3, no abandonment", dict(d=4)),
        ("lemmas posed over 4 rounds (p=4), d=3", dict(p=4)),
        ("lemmas posed late (p=9), d=3", dict(p=9)),
        ("plan-first, d=3, abandonment 20%, ABANDON (too hard)", dict(qab=0.2)),
        ("plan-first, d=3, abandonment 20%, disproofs", dict(qab=0.2, abandon="disproof")),
        ("p=4, d=3, abandonment 30%, ABANDON (too hard)", dict(p=4, qab=0.3)),
        ("p=4, d=3, abandonment 30%, disproofs", dict(p=4, qab=0.3, abandon="disproof")),
        ("plan-first, d=4, b=3, abandonment 20%, ABANDON", dict(d=4, qab=0.2)),
    ]
    T, seeds = 300, [1, 2, 3, 4, 5]
    print("== Task queries per rejection: chain VSI vs thread N's T6 search vs the own-tree search ==")
    print(f"   T = {T} problems per run, seeds {seeds}; m = 40 insight types, Poisson(1) insights per problem;")
    print("   leaves take 3..10 rounds (r0 = 10), slack s = 10; numbers are means over all rejections of all seeds.")
    print("   | config | N*_r (human tree rounds) | rejections/seed | chain: mean (max) | T6: mean (max), stall % "
          "| own: mean (max) | own: share certifying abandoned work | chain/own | bounds hold |")
    for name, upd in configs:
        P = dict(base)
        P.update(upd)
        agg = {m: dict(costs=[], stalls=0, certs=[], nstar=[], rej=0, ok=True) for m in ("chain", "T6", "own")}
        for sd in seeds:
            res = experiment(P, T, sd)
            for m in agg:
                agg[m]["costs"] += res[m]["costs"]
                agg[m]["stalls"] += res[m]["stalls"]
                agg[m]["certs"] += res[m]["certs"]
                agg[m]["nstar"] += res[m]["nstar"]
                agg[m]["rej"] += res[m]["rej"]
                agg[m]["ok"] &= res[m]["ok"]
        c, t6, o = agg["chain"], agg["T6"], agg["own"]
        mc, mt, mo = np.mean(c["costs"]), np.mean(t6["costs"]), np.mean(o["costs"])
        share = np.sum(o["certs"]) / max(1, np.sum(o["costs"]))
        print(f"   | {name} | {fmt(np.mean(c['nstar']))} | {c['rej']/len(seeds):.1f} / {t6['rej']/len(seeds):.1f} / "
              f"{o['rej']/len(seeds):.1f} | {fmt(mc)} ({max(c['costs'])}) | {fmt(mt)} ({max(t6['costs'])}), "
              f"{100*t6['stalls']/max(1,t6['rej']):.0f}% | {fmt(mo)} ({max(o['costs'])}) | {100*share:.0f}% | "
              f"{mc/mo:.1f}x | {'yes' if (c['ok'] and o['ok']) else 'NO'} |")
    print()
    print("   Reading: 'rejections/seed' is chain / T6 / own (each <= m = 40 by the bit-per-hit argument).")
    print("   'bounds hold': chain cost <= 2 N*_r with first mistake before N*_r; own cost - A <= sum pi_l + t_L, path lemmas")
    print("   are the human's own, and own cost <= p_max d + t_max when A = 0; checked on every rejection.")
    print("   T6's cost includes its fallback to the chain search after a stall (a call with no mistake, because")
    print("   its lemma was corrupted higher up: thread N's (Budget) fails there).")
    print()

    # lucky proofs: the imitator proves a lemma the human abandons as too hard
    print("== Lucky proofs (too-hard abandonment; a deviating run proves the abandoned lemma) ==")
    print("   | config | chain: mean (max) | own alone: stall % | own + depth-first, interleaved: mean (max) | 2 N*_r (mean) "
          "| interleaved cost <= 2 (first depth-first mistake + 1) |")
    for name, upd in [("plan-first, d=3, abandonment 20%, lucky 50%", dict(qab=0.2, qlucky=0.5)),
                      ("p=4, d=3, abandonment 30%, lucky 100%", dict(p=4, qab=0.3, qlucky=1.0))]:
        P = dict(base)
        P.update(upd)
        cc, oc, st, ns, rj, okk = [], [], 0, [], 0, True
        for sd in seeds:
            res = experiment(P, T, sd, methods=("chain", "own+dfs"))
            cc += res["chain"]["costs"]
            oc += res["own+dfs"]["costs"]
            st += res["own+dfs"]["stalls"]
            rj += res["own+dfs"]["rej"]
            ns += res["own+dfs"]["nstar"]
            okk &= res["own+dfs"]["ok"] and res["chain"]["ok"]
        print(f"   | {name} | {fmt(np.mean(cc))} ({max(cc)}) | {100*st/max(1,rj):.0f}% | {fmt(np.mean(oc))} ({max(oc)}) | "
              f"{fmt(2*np.mean(ns))} | {'yes' if okk else 'NO'} |")
    print("   The own-tree search alone can end without a hit after a lucky proof (it trusts 'proved' records);")
    print("   interleaving it with a depth-first scan keeps the cost below twice the cheaper of the two.")
    print()

    # theoretical worst cases for the same shapes
    print("== The bounds for these shapes (per rejection) ==")
    for name, upd in configs[:4]:
        P = dict(base)
        P.update(upd)
        print(f"   {name}: own-tree worst case p*d + r0 = {P['p']*P['d'] + P['r0']}; T6 under (Budget): 1 + r0 = {1 + P['r0']}; "
              f"chain: 2 N*_r (about {2*int(np.mean([make_problem(np.random.default_rng(i), P)[1] for i in range(200)]))})")
    print()

    # adversarial placement: the single insight in the root's last planning round, everything else learned
    print("== Adversarial placement (one insight, at the last planning round of each level in turn) ==")
    P = dict(base)
    P.update(dict(p=4, d=3, m=1, lam=0.0))
    rng = np.random.default_rng(11)
    root, nstar = make_problem(rng, P)
    rows = []
    path_calls = [root]
    while path_calls[-1].h > 0:
        c = path_calls[-1]
        # follow the lemma posed last in the planning rounds
        js = [j for j, rd in enumerate(c.rounds) if rd[1]]
        path_calls.append(c.rounds[js[-1]][1][-1])
    for lvl, c in enumerate(path_calls):
        js = [j for j, rd in enumerate(c.rounds) if rd[1]]
        j = js[-1] if js else len(c.rounds) - 1
        for rd in all_rounds(root, []):
            rd[0] = None
        c.rounds[j][0] = 0
        ru = run_call(root, True, set(), P["r0"] + P["s"])
        oc = len(own_search(ru, {"proved"})[0])
        t6c, _, st = t6_search(ru, np.random.default_rng(5), {"proved"}, P["r0"] + P["s"])
        chc, _, _ = chain_search(ru, np.random.default_rng(5))
        rows.append((lvl, j + 1, oc, t6c, st, chc))
    print(f"   human tree: {nstar} rounds; p = 4, d = 3, r0 = 10")
    for lvl, j, oc, t6c, st, chc in rows:
        print(f"   insight at depth {lvl}, round {j}: own {oc}, T6 {t6c}{' (stalled, then chain)' if st else ''}, chain {chc}")


if __name__ == "__main__":
    main()
