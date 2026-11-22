"""Thread AA (noisy blueprints): simulation for research/threadAA-noisy-blueprints.md.

numpy only.  Usage: python3 -B threadAA_noisy_trees.py > threadAA_noisy_trees.out   (about 2 minutes)

The toy is thread Y's (threadY_trees.py, whose tree generator is imported unchanged), with a noisy
human: model (ii) of thread Z at the granularity of a round.
* The human's core C is thread Y's deterministic human: it writes v_k at an insight round of type k,
  and a routine label '.' elsewhere.  Calls, isolation, records and corruption are as in thread Y.
* The noisy human P: at every task query, with probability 1 - delta it writes C's label; with
  probability delta it writes a symbol drawn uniformly from the V + 1 symbols (V values and '.'),
  freshly at every query, even at a transcript asked before (memoryless re-asks, (M)).
* The learner: exact Bayes over the stochastic product class (one value per type, uniform prior,
  delta known), K = m log2 V bits.  Its posterior for type k depends only on the counts of the
  values answered at rounds of type k, and its mode is the most frequent value; ties are broken
  against the truth (worst case).  Answers at routine rounds carry no information (every hypothesis
  predicts them alike).  With delta = 0 this is thread Y's learner.
* The imitator: the posterior mode (a deterministic decoder, fixed during a run and its search).
  A round of type k is a mistake iff the decoder's value for k is wrong.

Protocols (each on its own learning trajectory; the same problems for every protocol and delta):
* det      : thread Y's search (S_cert order: scan rounds, descend into non-good lemmas) with one
             answer per round, a hit at the first answer that differs from the run's label, and a
             deterministic learner.  A deviation contradicts the deterministic class: the learner
             crashes and every later problem is abstained.
* firstdiff: the same search and stopping rule, with the Bayes learner (only the hit's answer is
             added).
* askall   : Theorem AA1.  On a rejection, compute the record-path scan set S from the run's records
             alone (at a path call, rounds 1..j of the first round j that poses a non-proved lemma,
             then that lemma, if j <= p and depth < d; otherwise rounds 1..min(j, r0, end) and stop);
             ask once at every round of S; add all answers; rerun.
* askcert  : the abandonment version of askall: ask once at each of the first B positions of the
             S_cert order (B = 3 (p d + r0)); add all answers.
* seqZ     : Theorems AA2 / AA3 (thread Z's Z4' on the tree): walk the S_cert order (uncapped);
             at each round ask until the answers equal to the run's label lead by 1 (pass) or trail
             by 3 (alarm); stop at the first alarm; discard the detection answers and add one fresh
             answer at the alarm round.
* seqAll   : the practical variant (conjectured): r = 2, all detection answers added.
* chain    : thread Z's Z4 on the linearized run (depth-first order), n0 = N*_r: ask once at each of
             the first N*_r positions, add all answers.

Checks, on every rejection:
* askall: S contains a mistake (Lemma S) and |S| <= p d + r0 (Theorem AA1(c)); in the abandonment
  configs, the share of record-path sets with no mistake is reported (Lemma S needs (A2-m)).
* k* (the position of the first mistake in the S_cert order) <= sum_l pi_l + t*(u_L) + A, with
  thread Y's bookkeeping (A = rounds spent certifying the core's abandoned lemmas).
* seqZ: the per-rejection expected-cost bound of Theorem AA2,
  (k* - 1 + r + rho ((N_ord - k*) + (r - 1) m_after))/(1 - 2 delta) + 1, averaged against the realized costs
  (N_ord: length of the S_cert order; m_after: mistakes after k* in it).
* rejections per seed against K/(1 - h(delta)) (askall, chain) and K/((1 - h(delta))(1 - B rho^r - rho))
  (seqZ), with k*max the largest k* seen.
"""

import math
import random
import sys
import time

import numpy as np

from threadY_trees import gen_call, make_problem, shape_stats  # noqa: F401  (thread Y's generator)

V = 64                 # values per insight type
DOT = V                # the routine symbol
NSYM = V + 1
M_TYPES = 40
K_BITS = M_TYPES * math.log2(V)
RMAX = 40              # reruns of one problem before abstaining (a loop guard; the theorems' protocols never reach it)


def h2(p):
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# ------------------------------------------------------------------ the imitator's run


class Run:
    __slots__ = ("ref", "rounds", "rec", "term")

    def __init__(self, ref):
        # rounds: list of (typ, mis, kids); typ is the insight type of an on-track-shaped round of a
        # clean call (None for routine rounds and for every round of a corrupted call)
        self.ref, self.rounds, self.rec, self.term = ref, [], "fail", None


def run_call(c, clean, L, r):
    u = Run(c)
    if not clean:  # a corrupted (false) lemma: same shape, routine rounds only, fails at the budget
        for rd in c.rounds:
            u.rounds.append((None, False, [run_call(k, False, L, r) for k in rd[1]]))
        u.rounds += [(None, False, [])] * max(0, r - len(c.rounds))
        return u
    ontrack = True
    for rd in c.rounds:
        typ = rd[0]
        mis = typ is not None and typ not in L
        kids, dev = [], False
        for k in rd[1]:
            if ontrack and not mis:
                kr = run_call(k, True, L, r)
                if kr.rec != k.rec:
                    dev = True
            else:
                kr = run_call(k, False, L, r)
            kids.append(kr)
        u.rounds.append((typ, mis, kids))
        if mis or dev:
            ontrack = False
    if ontrack:
        u.rec, u.term = c.rec, len(c.rounds) - 1
    else:
        u.rounds += [(None, False, [])] * max(0, r - len(c.rounds))
    return u


# ------------------------------------------------------------------ scan orders


def cert_order(u, good, out, cap):
    """Thread Y's S_cert order with no hits: rounds in order, each non-good lemma's order right after
    the round that posed it, stopping at the call's terminal round.  Truncated at cap positions."""
    for j, (typ, mis, kids) in enumerate(u.rounds):
        if len(out) >= cap:
            return True
        out.append((u, j))
        for k in kids:
            if k.rec not in good:
                if cert_order(k, good, out, cap):
                    return True
        if u.term == j:
            break
    return len(out) >= cap


def own_search_bound(root, good):
    """Thread Y's S_cert with the run's own mistakes: returns (k*, bound) where k* is the position of
    the first mistake in the S_cert order and bound = sum_l pi_l + t_L + A (A: positions spent in
    lemmas that returned CERT)."""
    seq = []
    state = {"cert": 0}

    def search(u, path):
        start = len(seq)
        for j, (typ, mis, kids) in enumerate(u.rounds):
            seq.append((u, j))
            if mis:
                return path + [(u, j + 1)]
            for k in kids:
                if k.rec not in good:
                    res = search(k, path + [(u, j + 1)])
                    if res is not None:
                        return res
            if u.term == j:
                break
        state["cert"] += len(seq) - start
        return None

    path = search(root, [])
    assert path is not None, "no mistake in the S_cert order: (A2-tree-ab-C) or (No-lucky) violated"
    bound = sum(js for (_, js) in path[:-1]) + len(path[-1][0].ref.rounds) + state["cert"]
    return len(seq), bound


def record_path_S(root, good, p, d, r0):
    """Theorem AA1's scan set, computed from the run's records alone."""
    S, u, depth = [], root, 0
    while True:
        jl, nxt = None, None
        for j, (typ, mis, kids) in enumerate(u.rounds):
            for k in kids:
                if k.rec not in good:
                    jl, nxt = j, k
                    break
            if jl is not None:
                break
        if jl is not None and jl + 1 <= p and depth < d:
            S += [(u, j) for j in range(jl + 1)]
            u, depth = nxt, depth + 1
            continue
        end = (u.term + 1) if u.term is not None else len(u.rounds)
        lim = min(jl + 1 if jl is not None else 10 ** 9, r0, end)
        S += [(u, j) for j in range(lim)]
        return S


def linearize(u, out):
    for j, (typ, mis, kids) in enumerate(u.rounds):
        out.append((u, j))
        for k in kids:
            linearize(k, out)
    return out


# ------------------------------------------------------------------ learners and the noisy human


class Bayes:
    """Exact Bayes over the stochastic product class; the true value of every type is 0 (wlog)."""

    def __init__(self):
        self.c0 = [0] * M_TYPES
        self.wrong = [dict() for _ in range(M_TYPES)]
        self.mw = [0] * M_TYPES
        self.gw = [1] * M_TYPES      # the decoder's wrong value when it is wrong
        self.crashed = False

    def learned(self):
        return {k for k in range(M_TYPES) if self.c0[k] > self.mw[k]}

    def label(self, typ, mis):
        if typ is None:
            return DOT
        return self.gw[typ] if mis else 0

    def add(self, typ, a):
        if typ is None or a == DOT:
            return  # uninformative: every hypothesis predicts it alike
        if a == 0:
            self.c0[typ] += 1
        else:
            w = self.wrong[typ]
            w[a] = w.get(a, 0) + 1
            if w[a] > self.mw[typ]:
                self.mw[typ], self.gw[typ] = w[a], a


class Det:
    """Exact elimination over the deterministic product class (thread Y's learner)."""

    def __init__(self):
        self.v = {}
        self.crashed = False

    def learned(self):
        return {k for k, a in self.v.items() if a == 0}

    def label(self, typ, mis):
        if typ is None:
            return DOT
        if not mis:
            return 0
        return self.v.get(typ, 1)

    def add(self, typ, a):
        if typ is None or a == DOT or typ in self.v:
            self.crashed = True  # the answer contradicts every remaining hypothesis
            return
        self.v[typ] = a


def answer(arng, delta, typ):
    if delta > 0 and arng.random() < delta:
        return arng.randrange(NSYM)
    return DOT if typ is None else 0


def sprt(arng, delta, typ, lab, rthr):
    """Ask until answers equal to lab lead by 1 (pass) or trail by rthr (alarm)."""
    lead, ans = 0, []
    while -rthr < lead < 1:
        a = answer(arng, delta, typ)
        ans.append(a)
        lead += 1 if a == lab else -1
    return lead == -rthr, ans


# ------------------------------------------------------------------ experiment


def experiment(P, T, seed, delta, meth):
    good = {"proved"} if P["abandon"] == "abandon" else {"proved", "disproved"}
    r = P["r0"] + P["s"]
    pdr = P["p"] * P["d"] + P["r0"]
    B = 3 * pdr
    rho = delta / (1 - delta) if delta > 0 else 0.0
    rng = np.random.default_rng(seed)
    arng = random.Random(1000003 * seed + int(1000 * delta) + 7)
    lrn = Det() if meth == "det" else Bayes()
    st = dict(rej=0, q=0, costs=[], abst=0, outs=0, S_nomis=0, S_over=0, kstar_ok=True,
              seq_bound=[], seq_cost=[], human_fail=0.0, loops=0, nstar=[], kmax=0)
    for t in range(T):
        root, nstar = make_problem(rng, P)
        # the noisy human's own tree fails iff some insight round deviates to a wrong symbol
        n_ins = sum(1 for _ in _insight_rounds(root))
        st["human_fail"] += 1 - (1 - delta * V / (V + 1)) ** n_ins
        st["nstar"].append(nstar)
        if lrn.crashed:
            st["abst"] += 1
            continue
        nrej = 0
        while True:
            L = lrn.learned()
            ru = run_call(root, True, L, r)
            if ru.rec == "proved":
                st["outs"] += 1  # a kernel-checked proof of the root statement, by construction
                break
            nrej += 1
            if nrej > RMAX:
                st["abst"] += 1
                st["loops"] += 1
                break
            st["rej"] += 1
            kstar, kb = own_search_bound(ru, good)
            if kstar > kb:
                st["kstar_ok"] = False
            cost = 0
            if meth in ("det", "firstdiff"):
                order = []
                cert_order(ru, good, order, 10 ** 9)
                for (u, j) in order:
                    typ, mis, _ = u.rounds[j]
                    a = answer(arng, delta, typ)
                    cost += 1
                    if a != lrn.label(typ, mis):
                        lrn.add(typ, a)
                        break
            elif meth == "askall":
                S = record_path_S(ru, good, P["p"], P["d"], P["r0"])
                if not any(u.rounds[j][1] for (u, j) in S):
                    st["S_nomis"] += 1
                if len(S) > pdr:
                    st["S_over"] += 1
                for (u, j) in S:
                    typ = u.rounds[j][0]
                    if typ is not None:  # answers at routine rounds carry no information
                        lrn.add(typ, answer(arng, delta, typ))
                cost = len(S)
            elif meth == "askcert":
                order = []
                cert_order(ru, good, order, B)
                if not any(u.rounds[j][1] for (u, j) in order):
                    st["S_nomis"] += 1
                for (u, j) in order:
                    typ = u.rounds[j][0]
                    if typ is not None:
                        lrn.add(typ, answer(arng, delta, typ))
                cost = len(order)
            elif meth in ("seqZ", "seqAll"):
                rthr = 3 if meth == "seqZ" else 2
                order = []
                cert_order(ru, good, order, 10 ** 9)  # uncapped: Theorems AA2/AA3 need no parameter
                st["kmax"] = max(st["kmax"], kstar)
                for (u, j) in order:
                    typ, mis, _ = u.rounds[j]
                    lab = lrn.label(typ, mis)
                    alarm, ans = sprt(arng, delta, typ, lab, rthr)
                    cost += len(ans)
                    if meth == "seqAll":
                        for a in ans:
                            lrn.add(typ, a)
                    if alarm:
                        if meth == "seqZ":
                            lrn.add(typ, answer(arng, delta, typ))
                            cost += 1
                        break
                if meth == "seqZ":
                    # Theorem AA2(c): positions before k* are correct (<= 1/(1-2 delta) each), k* costs
                    # <= r/(1-2 delta), later positions are reached with probability <= rho and cost
                    # <= 1/(1-2 delta) (correct) or r/(1-2 delta) (mistake); +1 for the fresh answer
                    n_ord = len(order)
                    m_after = sum(1 for (u, j) in order[kstar:] if u.rounds[j][1])
                    st["seq_cost"].append(cost)
                    st["seq_bound"].append((kstar - 1 + rthr + rho * ((n_ord - kstar) + (rthr - 1) * m_after))
                                           / (1 - 2 * delta) + 1)
            elif meth == "chain":
                seq = linearize(ru, [])[:nstar]
                for (u, j) in seq:
                    typ = u.rounds[j][0]
                    if typ is not None:
                        lrn.add(typ, answer(arng, delta, typ))
                cost = len(seq)
            st["q"] += cost
            st["costs"].append(cost)
            if lrn.crashed:
                break
        if lrn.crashed and ru.rec != "proved":
            st["abst"] += 1
    st["human_fail"] /= T
    return st


def _insight_rounds(c):
    for rd in c.rounds:
        if rd[0] is not None:
            yield rd
        for k in rd[1]:
            yield from _insight_rounds(k)


# ------------------------------------------------------------------ main


def main():
    t0 = time.time()
    base = dict(d=3, b=3, p=1, r0=10, r0min=3, s=10, m=M_TYPES, lam=1.0, qab=0.0, abandon="abandon")
    configs = [
        ("plan-first (p=1), d=3", dict(), ["det", "firstdiff", "askall", "seqZ", "seqAll", "chain"]),
        ("p=4, d=3", dict(p=4), ["det", "firstdiff", "askall", "seqZ", "seqAll", "chain"]),
        ("lemmas posed late (p=9), d=3", dict(p=9), ["firstdiff", "askall", "seqZ", "seqAll"]),
        ("p=1, d=3, 20% ABANDON (core abandons)", dict(qab=0.2), ["firstdiff", "askall", "askcert", "seqZ", "seqAll"]),
        ("p=4, d=3, 30% ABANDON (core abandons)", dict(p=4, qab=0.3), ["firstdiff", "askcert", "seqZ", "seqAll"]),
    ]
    deltas = [0.0, 0.05, 0.1]
    T, seeds = 300, list(range(1, 11))
    names = dict(det="det: thread Y search, 1 answer/round, deterministic learner",
                 firstdiff="firstdiff: same search, stop at first differing answer, Bayes",
                 askall="askall (Theorem AA1): record-path set S, ask once each, add all",
                 askcert="askcert: first B = 3(pd+r0) positions of the S_cert order, ask once each",
                 seqZ="seqZ (Theorems AA2/AA3): sequential test r=3, add one fresh answer",
                 seqAll="seqAll (practical, [C]): sequential test r=2, add all answers",
                 chain="chain (Z4 on the linearized run, n0 = N*_r)")
    print("== Thread AA: noisy blueprints (thread Y's toy, a human with memoryless deviations at rate delta per round) ==")
    print(f"   T = {T} problems per seed, seeds {seeds}; m = {M_TYPES} insight types, V = {V} values, "
          f"K = m log2 V = {K_BITS:.0f} bits;")
    print("   Poisson(1) insights per problem; leaves take 3..10 rounds (r0 = 10), slack s = 10; b = 3 lemmas per call.")
    print(f"   Loop guard: a problem rerun more than {RMAX} times is abstained ('abstained %').")
    print(f"   Protocols:")
    for k, v in names.items():
        print(f"     {v}")
    print("   Every output is a kernel-checked root proof by construction, so output correctness is 100% for all protocols.")
    print()
    summary = []
    for cname, upd, meths in configs:
        P = dict(base)
        P.update(upd)
        pdr = P["p"] * P["d"] + P["r0"]
        print(f"== {cname}:  p d + r0 = {pdr} ==")
        print("   | protocol | delta | rejections/seed | task queries per rejection: mean (max) | task queries/seed "
              "| abstained % | noisy human's own tree fails % |")
        for meth in meths:
            for delta in deltas:
                agg = dict(rej=0, q=0, costs=[], abst=0, S_nomis=0, S_over=0, kstar_ok=True, seq_bound=[],
                           seq_cost=[], hf=0.0, loops=0, nstar=[], kmax=0)
                for sd in seeds:
                    s = experiment(P, T, sd, delta, meth)
                    for key in ("rej", "q", "abst", "S_nomis", "S_over", "loops"):
                        agg[key] += s[key]
                    agg["costs"] += s["costs"]
                    agg["seq_bound"] += s["seq_bound"]
                    agg["seq_cost"] += s["seq_cost"]
                    agg["kstar_ok"] &= s["kstar_ok"]
                    agg["kmax"] = max(agg["kmax"], s["kmax"])
                    agg["hf"] += s["human_fail"]
                    agg["nstar"] += s["nstar"]
                ns = len(seeds)
                mc = np.mean(agg["costs"]) if agg["costs"] else 0.0
                mx = max(agg["costs"]) if agg["costs"] else 0
                print(f"   | {meth} | {delta} | {agg['rej']/ns:.1f} | {mc:.1f} ({mx}) | {agg['q']/ns:,.0f} | "
                      f"{100*agg['abst']/(ns*T):.1f} | {100*agg['hf']/ns:.1f} |")
                summary.append((cname, P, meth, delta, agg))
            sys.stdout.flush()
        print()

    print("== Theorem checks ==")
    for cname, P, meth, delta, agg in summary:
        ns = len(seeds)
        pdr = P["p"] * P["d"] + P["r0"]
        B = 3 * pdr
        b = 1 - h2(delta)
        rho = delta / (1 - delta) if delta > 0 else 0.0
        line = f"   * {cname}, {meth}, delta={delta}: "
        if meth == "askall":
            line += (f"rejections/seed {agg['rej']/ns:.1f} vs K/(1-h) = {K_BITS/b:.0f}; queries/seed {agg['q']/ns:,.0f} vs "
                     f"(pd+r0)K/(1-h) = {pdr*K_BITS/b:,.0f}; |S| > pd+r0 on {agg['S_over']} rejections; "
                     f"S without a mistake on {agg['S_nomis']} of {agg['rej']} rejections; loops {agg['loops']}")
        elif meth == "askcert":
            line += (f"rejections/seed {agg['rej']/ns:.1f} vs K/(1-h) = {K_BITS/b:.0f}; first B positions without a "
                     f"mistake on {agg['S_nomis']} of {agg['rej']} rejections; loops {agg['loops']}")
        elif meth == "seqZ":
            pis = 1 - (agg["kmax"] - 1) * rho ** 3 - rho
            line += (f"rejections/seed {agg['rej']/ns:.1f} vs K/((1-h)(1-(k*max-1) rho^3-rho)) = {K_BITS/(b*pis):.0f} "
                     f"(k*max = {agg['kmax']}); mean cost per rejection {np.mean(agg['seq_cost']):.1f} vs mean bound "
                     f"{np.mean(agg['seq_bound']):.1f}; loops {agg['loops']}")
        elif meth == "chain":
            line += (f"rejections/seed {agg['rej']/ns:.1f} vs K/(1-h) = {K_BITS/b:.0f}; mean N*_r = {np.mean(agg['nstar']):.0f}")
        else:
            line += f"rejections/seed {agg['rej']/ns:.1f}; abstained {100*agg['abst']/(ns*T):.1f}%; loops {agg['loops']}"
        line += f"; k* <= sum pi + t* + A on every rejection: {'yes' if agg['kstar_ok'] else 'NO'}"
        print(line)
    print()
    print("== Noise factor: rejections at delta relative to delta = 0, against 1/(1-h(delta)) ==")
    base_rej = {}
    for cname, P, meth, delta, agg in summary:
        if delta == 0.0:
            base_rej[(cname, meth)] = agg["rej"]
    for cname, P, meth, delta, agg in summary:
        if delta > 0 and meth in ("askall", "askcert", "seqZ", "seqAll", "chain"):
            br = base_rej[(cname, meth)]
            print(f"   * {cname}, {meth}, delta={delta}: {agg['rej']/max(1,br):.2f} (1/(1-h) = {1/(1-h2(delta)):.2f})")
    print()
    print(f"   runtime {time.time()-t0:.0f} s")


if __name__ == "__main__":
    main()
