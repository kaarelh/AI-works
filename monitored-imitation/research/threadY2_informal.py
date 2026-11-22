"""Thread Y2 (informal blueprints): simulation for research/threadY2-informal-blueprints.md.

numpy only.  Usage: python3 threadY2_informal.py   (about one to two minutes)

Extends thread Y's toy (threadY_trees.py) with a fallible node verifier N.

The toy.
* The human's own tree T*_N, built with the same N.  Internal calls pose b lemmas over their first
  p rounds and submit a proof in a final assembly round; leaves work 3..r0 rounds and submit in their
  last work round.  With probability e_h a call's first submission is a slip (an invalid proof).
  N judges every submission: a valid claim fails with probability f (false fail), an invalid one
  passes with probability f (false pass).  On a fail the call revises in one more round (D = 1) and
  submits a new, valid claim.  So T*_N contains the human's slips that N passed, and the extra rounds
  that N's false fails cost the human.
* Hidden insights (Poisson(1) per problem, 40 types) at uniformly random rounds of T*_N.  Exact Bayes
  over the product class: one hit per type, so at most 40 hits.
* The imitator's run.  A round needing an unlearned type is a mistake.  A call is on track while its
  transcript is the human's: every round correct, every lemma's record equal to the human's.  Lemmas
  posed at or after a deviation are corrupted (false statements; no mistakes inside, as in thread Y).
  A deviated or corrupted call submits up to k_dev = 2 invalid claims, each passing N with
  probability f; if none passes its record is "open".  Proof irrelevance: a parent sees only records,
  so a false pass on a child keeps the parent on track.
* N's verdicts.  'cached': a fixed function of the canonical claim (a hash), i.e. drawn once per
  claim; this makes T*_N well defined.  'fresh': drawn afresh at every submission (randomized, no
  cache); then T*_N is only a nominal tree, and a run can differ from it without a mistake.
* The root verifier V: sound and complete on each node claim, and located (it names the first
  invalid claim of the assembled cone, in depth-first order).  A run is rejected if its root is
  "open" or V names a node.  Correctness is V's; here we measure cost only.

Searches compared on every rejected run (separate learning trajectories per method):
* chain      : the paper's S, U, S, S cycle on the run's depth-first order.  With located V it may stop
               once its scan passes the named node's last round (the named claim is then the human's).
* loc        : this thread's S_loc: walk to V's named node (or the root if the root is open), scanning
               each path call's rounds up to the round that posed the next path call; at every round,
               descend (thread Y's S_own) into a lemma whose record is not "proved"; at the target,
               scan to its terminal round.  CERT (no hit) at a named node certifies that the named
               claim is the human's own: repair N's cached verdict on it (a second judge upholds V's
               objection), so the human now revises it, and rerun.
* loc+dfs    : loc interleaved with a depth-first scan (cached answers), stopping at the first hit.
* unloc+dfs  : V says only "rejected".  Thread Y's S_own from the root, interleaved with a depth-first
               scan.  A run with no mistake at all (the human's own slip passed by N) cannot be
               repaired without a location: the problem is abstained.
* fresh      : loc+dfs with fresh (randomized) verdicts, stopping at any CERT as VSI-R would (nothing can
               be repaired, since nothing is cached).  A rejection without a hit is uninformative; the
               problem is rerun (at most 10 such rejections, then abstained).
Also reported, on the loc trajectory's rejections: how often thread Y's S_own from the root alone
(target = root, no location) stalls, i.e. ends without a hit.

Checks (asserted on every rejection of the cached methods):
* loc: cost <= sum_l pi_l + t*_N(u_L) (Theorem Y2-1's bound, with the human's rounds in T*_N), every
  path call is the human's own lemma posed after a mistake-free prefix, and cost <= p_max d + t_max;
  a CERT happens only at a named claim that is the human's own slip passed by N;
* chain: when the run has a mistake, the first one in depth-first order is before N*_r (the number
  of rounds of T*_N);
* loc+dfs: cost <= 2 min{loc cost, first depth-first mistake + 1}.
"""

import time
import numpy as np

M64 = 0xFFFFFFFFFFFFFFFF
KH, KD, KC = 1, 2, 3  # claim kinds: the human's claim, a deviated call's claim, a corrupted call's claim


def u01(*key):
    """A deterministic uniform number for a canonical claim (splitmix64 of Python's int-tuple hash)."""
    x = (hash(key) + 0x9E3779B97F4A7C15) & M64
    x = ((x ^ (x >> 30)) * 0xBF58476D1CE4E5B9) & M64
    x = ((x ^ (x >> 27)) * 0x94D049BB133111EB) & M64
    x ^= x >> 31
    return x / 2.0 ** 64


class Ver:
    """Node verifier N with false-pass rate fp and false-fail rate ff."""

    def __init__(self, fp, ff, mode, salt, rng):
        self.fp, self.ff, self.mode, self.salt, self.rng = fp, ff, mode, salt, rng
        self.override = {}  # repairs: claim -> verdict

    def table(self, kind, cid, idx, valid):
        key = (kind, cid, idx)
        if key in self.override:
            return self.override[key]
        x = u01(self.salt, kind, cid, idx)
        return x >= self.ff if valid else x < self.fp

    def run(self, kind, cid, idx, valid):
        if self.mode == "cached":
            return self.table(kind, cid, idx, valid)
        x = self.rng.random()
        return x >= self.ff if valid else x < self.fp


# ------------------------------------------------------------------ the human's own tree T*_N


class HCall:
    __slots__ = ("id", "h", "work", "slip", "rev_ins", "nrev", "rec")


def gen_call(rng, h, P, ctr):
    c = HCall()
    c.id, c.h = ctr[0], h
    ctr[0] += 1
    if h == 0:
        c.work = [[None, []] for _ in range(int(rng.integers(P["r0min"], P["r0"] + 1)))]
    else:
        pose, last = {}, 0
        for _ in range(P["b"]):
            j = int(rng.integers(0, P["p"]))
            pose.setdefault(j, []).append(gen_call(rng, h - 1, P, ctr))
            last = max(last, j)
        c.work = [[None, pose.get(j, [])] for j in range(last + 2)]
    c.slip = bool(rng.random() < P["eh"])
    c.rev_ins = {}
    return c


def human_phase(c, ver, r):
    """The human's submissions: claim i in round W-1+i (one revision round per failed claim)."""
    W, i = len(c.work), 0
    while W - 1 + i < r:
        if ver.table(KH, c.id, i, not (i == 0 and c.slip)):
            return i, "proved"
        i += 1
    return r - W, "open"  # out of budget: (A2-tree-N) fails at this call


def finalize(c, ver, P):
    for rd in c.work:
        for k in rd[1]:
            finalize(k, ver, P)
    c.nrev, c.rec = human_phase(c, ver, P["r0"] + P["s"])


def human_rounds(c, out):
    for j in range(len(c.work) + c.nrev):
        out.append((c, j))
        if j < len(c.work):
            for k in c.work[j][1]:
                human_rounds(k, out)
    return out


def human_stats(c, acc):
    """acc = [p_max, t_max, timeouts, slips passed by N, false fails, calls]."""
    acc[1] = max(acc[1], len(c.work) + c.nrev)
    acc[2] += c.rec != "proved"
    acc[3] += c.slip and c.nrev == 0 and c.rec == "proved"
    acc[4] += c.nrev - (1 if (c.slip and c.nrev >= 1) else 0)
    acc[5] += 1
    for j, rd in enumerate(c.work):
        if rd[1]:
            acc[0] = max(acc[0], j + 1)
        for k in rd[1]:
            human_stats(k, acc)
    return acc


def make_problem(rng, P, ver, ctr):
    root = gen_call(rng, P["d"], P, ctr)
    finalize(root, ver, P)
    rds = human_rounds(root, [])
    for _ in range(rng.poisson(P["lam"])):
        c, j = rds[int(rng.integers(len(rds)))]
        typ = int(rng.integers(P["m"]))
        if j < len(c.work):
            c.work[j][0] = typ
        else:
            c.rev_ins[j - len(c.work) + 1] = typ
    return root, len(rds)


# ------------------------------------------------------------------ the imitator's run


class RCall:
    __slots__ = ("ref", "rounds", "rec", "term", "fvalid", "ontrack", "fidx")


def run_call(c, clean, L, ver, P):
    r = P["r0"] + P["s"]
    u = RCall()
    u.ref, u.rounds, u.rec, u.term, u.fvalid, u.ontrack, u.fidx = c, [], "open", None, None, False, None
    W = len(c.work)
    if not clean:  # a corrupted (false) lemma: no mistakes inside; k_dev invalid submissions
        for rd in c.work:
            u.rounds.append((False, [run_call(k, False, L, ver, P) for k in rd[1]]))
        for a in range(P["kdev"]):
            t = W - 1 + a
            if t >= r:
                break
            if a > 0:
                u.rounds.append((False, []))
            if ver.run(KC, c.id, a, False):
                u.rec, u.term, u.fvalid = "proved", t, False
                return u
        u.rounds += [(False, [])] * (r - len(u.rounds))
        return u
    ontrack, j0 = True, -1
    for j, rd in enumerate(c.work):
        mis = rd[0] is not None and rd[0] not in L
        kids, devc = [], False
        for k in rd[1]:
            if ontrack and not mis:
                kr = run_call(k, True, L, ver, P)
                devc |= kr.rec != k.rec
            else:
                kr = run_call(k, False, L, ver, P)
            kids.append(kr)
        u.rounds.append((mis, kids))
        if ontrack and (mis or devc):
            ontrack, j0 = False, j
    t, i, att = W - 1, 0, 0
    while True:
        if ontrack:
            valid = not (i == 0 and c.slip)
            ok = ver.run(KH, c.id, i, valid)
        else:
            valid = False
            ok = ver.run(KD, c.id, 64 * j0 + att, False)
            att += 1
        if ok:
            u.rec, u.term, u.fvalid, u.ontrack, u.fidx = "proved", t, valid, ontrack, (i if ontrack else None)
            return u
        if (not ontrack and att >= P["kdev"]) or t + 1 >= r:
            break
        t += 1
        if ontrack:
            i += 1
            ins = c.rev_ins.get(i)
            mis = ins is not None and ins not in L
            u.rounds.append((mis, []))
            if mis:
                ontrack, j0 = False, t
        else:
            u.rounds.append((False, []))
    u.rounds += [(False, [])] * (r - len(u.rounds))
    return u


def v_flag(u, path):
    """V, located: the path to the first invalid claim of the cone of a proved call (pre-order)."""
    path = path + [u]
    if not u.fvalid:
        return path
    for rd in u.rounds[: u.term + 1]:
        for k in rd[1]:
            if k.rec == "proved":
                res = v_flag(k, path)
                if res:
                    return res
    return None


# ------------------------------------------------------------------ searches


def linearize(u, out):
    for j, (mis, kids) in enumerate(u.rounds):
        out.append((u, j, mis))
        for k in kids:
            linearize(k, out)
    return out


def s_own(u, seq, stack):
    """Thread Y's search at a failing call (S_cert-style: a CERT'd child returns to the parent)."""
    for j, (mis, kids) in enumerate(u.rounds):
        seq.append((u, j, mis))
        if mis:
            return True, stack + [(u, j + 1)]
        for k in kids:
            if k.rec != "proved":
                hit, st = s_own(k, seq, stack + [(u, j + 1)])
                if hit:
                    return True, st
        if u.term == j:
            break
    return False, stack + [(u, None)]


def s_loc(path, seq):
    """This thread's S_loc: walk to the target (V's named node, or the root), then scan it."""
    stack = []
    for idx, u in enumerate(path):
        nxt = path[idx + 1] if idx + 1 < len(path) else None
        for j, (mis, kids) in enumerate(u.rounds):
            seq.append((u, j, mis))
            if mis:
                return True, stack + [(u, j + 1)]
            for k in kids:
                if k.rec != "proved":
                    hit, st = s_own(k, seq, stack + [(u, j + 1)])
                    if hit:
                        return True, st
            if nxt is not None and any(k is nxt for k in kids):
                stack = stack + [(u, j + 1)]
                break
            if u.term == j:
                break
    return False, stack + [(path[-1], None)]


def interleave(own, dfs, stop_when_own_done):
    asked, q, i, k = set(), 0, 0, 0
    while True:
        if stop_when_own_done and i >= len(own):
            return q, None
        moved = False
        for src in (0, 1):
            if src == 0:
                if i >= len(own):
                    continue
                u, j, mis = own[i]
                i += 1
            else:
                if k >= len(dfs):
                    continue
                u, j, mis = dfs[k]
                k += 1
            moved = True
            key = (id(u), j)
            if key in asked:
                continue
            asked.add(key)
            q += 1
            if mis:
                return q, (u, j)
        if not moved:
            return q, None


def chain_search(dfs, rng, stop_pos):
    """S, U, S, S on the depth-first order; stops at a hit, or when the scan has passed stop_pos."""
    N, s, q = len(dfs), 0, 0
    while True:
        kind = "SUSS"[q % 4]
        q += 1
        if kind == "S":
            u, j, mis = dfs[s]
            s += 1
        else:
            u, j, mis = dfs[int(rng.integers(N))]
        if mis:
            return q, (u, j)
        if s > stop_pos:
            return q, None


def hit_type(hit):
    u, j = hit
    c = u.ref
    return c.work[j][0] if j < len(c.work) else c.rev_ins.get(j - len(c.work) + 1)


def is_human_slip(u):
    """The named claim is the human's own first claim, a slip that N passed (ground truth)."""
    return u.ontrack and u.rec == "proved" and not u.fvalid and u.fidx == 0 and u.ref.slip


def own_bound(stack):
    """sum of posing rounds over the path calls but the last, plus the human's rounds in the last call."""
    last = stack[-1][0].ref
    return sum(js for (_, js) in stack[:-1]) + len(last.work) + last.nrev


def path_ok(stack):
    for (u1, js), (u2, _) in zip(stack[:-1], stack[1:]):
        if js - 1 >= len(u1.ref.work) or not any(k is u2.ref for k in u1.ref.work[js - 1][1]):
            return False
        if any(u1.rounds[j][0] for j in range(js)):
            return False
    return True


# ------------------------------------------------------------------ experiment


def experiment(P, T, seed, meth, f):
    mode = "fresh" if meth == "fresh" else "cached"
    rng = np.random.default_rng(seed)
    srng = np.random.default_rng(seed + 7919)
    ver = Ver(f, f, mode, seed * 1000003 + int(round(f * 1000)), np.random.default_rng(seed + 31337))
    L, ctr = set(), [0]
    R = dict(hit=[], rep=[], unin=[], abstain=0, ok=True, nstar=[], y1stall=0, y1n=0, rootproved=0,
             accepted=0, timeouts=0, slips=0, ff=0, calls=0, total=0, cert_bad=0, unin_slip=0)
    for _ in range(T):
        root, nstar = make_problem(rng, P, ver, ctr)
        acc = human_stats(root, [0, 0, 0, 0, 0, 0])
        R["timeouts"] += acc[2]
        R["slips"] += acc[3]
        R["ff"] += acc[4]
        R["calls"] += acc[5]
        R["nstar"].append(nstar)
        unin = 0
        while True:
            ru = run_call(root, True, L, ver, P)
            path = None
            if ru.rec == "proved":
                path = v_flag(ru, [])
                if path is None:
                    R["accepted"] += 1
                    break
                R["rootproved"] += 1
            else:
                path = [ru]
            dfs = linearize(ru, [])
            first = next((i for i, x in enumerate(dfs) if x[2]), None)
            pmax, tmax = human_stats(root, [0, 0, 0, 0, 0, 0])[:2]
            nstar_now = len(human_rounds(root, []))
            if first is not None and mode == "cached" and first >= nstar_now:
                R["ok"] = False
            target = path[-1]
            hit = None
            if meth == "chain":
                stop = len(dfs) - 1
                if target is not ru or ru.rec == "proved":
                    stop = next(i for i, x in enumerate(dfs) if x[0] is target and x[1] == target.term)
                cost, hit = chain_search(dfs, srng, stop)
            elif meth == "loc":
                seq = []
                h_, st = s_loc(path, seq)
                cost = len(seq)
                if h_:
                    hit = (st[-1][0], st[-1][1] - 1)
                    if cost > own_bound(st) or not path_ok(st) or cost > pmax * P["d"] + tmax:
                        R["ok"] = False
                else:
                    last = st[-1][0].ref
                    if cost > sum(js for (_, js) in st[:-1]) + len(last.work) + last.nrev:
                        R["ok"] = False
                # thread Y's S_own from the root alone (no location): does it stall?
                y1seq = []
                R["y1n"] += 1
                R["y1stall"] += not s_own(ru, y1seq, [])[0]
            elif meth in ("loc+dfs", "fresh"):
                seq = []
                h_, st = s_loc(path, seq)
                # stop at a CERT: with cached verdicts only at a certified human slip (Theorem Y2-2);
                # with fresh verdicts at any CERT, as VSI-R would, and rerun
                stop = (not h_) and (is_human_slip(target) if mode == "cached" else True)
                cost, hit = interleave(seq, dfs, stop_when_own_done=stop)
                if mode == "cached" and first is not None and hit is not None and h_:
                    if cost > 2 * min(len(seq), first + 1):
                        R["ok"] = False
            elif meth == "unloc+dfs":
                seq = []
                s_own(ru, seq, [])
                cost, hit = interleave(seq, dfs, stop_when_own_done=False)
            R["total"] += cost
            if hit is not None:
                k = hit_type(hit)
                assert k is not None and k not in L
                L.add(k)
                R["hit"].append(cost)
                continue
            # no hit
            if mode == "cached" and meth != "unloc+dfs" and is_human_slip(target):
                ver.override[(KH, target.ref.id, 0)] = False  # repair: the human now sees V's objection
                finalize(root, ver, P)
                R["rep"].append(cost)
                continue
            if mode == "cached" and meth != "unloc+dfs":
                R["cert_bad"] += 1  # a CERT that is not at a human slip: an assumption failed
            R["unin"].append(cost)
            R["unin_slip"] += is_human_slip(target)
            unin += 1
            if mode == "cached" or unin >= 10:
                R["abstain"] += 1
                break
    return R


def fmt(xs):
    return f"{np.mean(xs):.1f} ({max(xs)})" if xs else "-"


def main():
    t0 = time.time()
    base = dict(d=3, b=3, p=1, r0=10, r0min=3, s=10, m=40, lam=1.0, eh=0.1, kdev=2)
    shapes = [("plan-first (p=1), d=3", dict()), ("p=4, d=3", dict(p=4))]
    rates = [0.0, 0.05, 0.15, 0.30]
    methods = ["chain", "loc", "loc+dfs", "unloc+dfs", "fresh"]
    T, seeds = 300, [1, 2, 3, 4, 5]
    ns = len(seeds)
    print("== Thread Y2: task queries per rejection with a fallible node verifier N ==")
    print(f"   T = {T} problems per seed, seeds {seeds}; 40 insight types, Poisson(1) per problem; b = 3 lemmas per")
    print(f"   internal call (40 calls per tree at d = 3); human slip rate e_h per call; N's false-pass and false-fail")
    print(f"   rates both = f; deviated calls submit k_dev = {base['kdev']} claims; r0 = 10, s = 10.")
    print("   Costs: mean (max) task queries per search.  'hit' = searches ending in a hit (at most 40 per seed);")
    print("   'rep' = searches ending in a certified human slip, then a repair of N's verdict (no bit learned).")
    print()
    summary = {}

    def block(P, sname, meths, full):
        print(f"-- shape: {sname}, e_h = {P['eh']}; own-tree worst case p*d + r0 = {P['p'] * P['d'] + P['r0']} "
              f"(plus revision rounds) --")
        if full:
            print("   | f | N*_r | T*_N: slips passed by N per call, false fails per call | chain: hit | chain: rep "
                  "| loc: hit | loc: rep | loc: hits, reps per seed | loc+dfs: hit | loc+dfs: rep "
                  "| unloc+dfs: hit; abstain % | fresh: hit; uninformative per seed (at a human slip %); abstain % "
                  "| S_own from root stalls % | bounds hold |")
        else:
            print("   | f | N*_r | chain: hit | loc: hit | unloc+dfs: hit | rejections with root 'proved' % "
                  "| S_own from root stalls % | bounds hold |")
        for f in rates:
            agg = {m: [experiment(P, T, sd, m, f) for sd in seeds] for m in meths}

            def cat(m, key):
                return [x for R in agg[m] for x in R[key]]

            def tot(m, key):
                return sum(R[key] for R in agg[m])

            lo = agg["loc"]
            calls = sum(R["calls"] for R in lo)
            chk = [m for m in ("chain", "loc", "loc+dfs") if m in meths]
            ok = all(R["ok"] for m in chk for R in agg[m])
            bad = sum(R["cert_bad"] for m in chk for R in agg[m])
            y1 = 100 * tot("loc", "y1stall") / max(1, tot("loc", "y1n"))
            rp = 100 * tot("loc", "rootproved") / max(1, tot("loc", "y1n"))
            okstr = "yes" if ok and bad == 0 else "NO"
            if full:
                unl_ab = 100 * tot("unloc+dfs", "abstain") / (T * ns)
                fr_ab = 100 * tot("fresh", "abstain") / (T * ns)
                nun = len(cat("fresh", "unin"))
                fr_sl = 100 * tot("fresh", "unin_slip") / max(1, nun)
                print(f"   | {f:.2f} | {np.mean(cat('loc', 'nstar')):.0f} "
                      f"| {tot('loc', 'slips') / max(1, calls):.3f}, {tot('loc', 'ff') / max(1, calls):.3f} "
                      f"| {fmt(cat('chain', 'hit'))} | {fmt(cat('chain', 'rep'))} "
                      f"| {fmt(cat('loc', 'hit'))} | {fmt(cat('loc', 'rep'))} "
                      f"| {len(cat('loc', 'hit')) / ns:.1f}, {len(cat('loc', 'rep')) / ns:.1f} "
                      f"| {fmt(cat('loc+dfs', 'hit'))} | {fmt(cat('loc+dfs', 'rep'))} "
                      f"| {fmt(cat('unloc+dfs', 'hit'))}; {unl_ab:.0f}% "
                      f"| {fmt(cat('fresh', 'hit'))}; {nun / ns:.0f} ({fr_sl:.0f}%); {fr_ab:.0f}% "
                      f"| {y1:.0f}% | {okstr} |")
            else:
                print(f"   | {f:.2f} | {np.mean(cat('loc', 'nstar')):.0f} | {fmt(cat('chain', 'hit'))} "
                      f"| {fmt(cat('loc', 'hit'))} | {fmt(cat('unloc+dfs', 'hit'))} | {rp:.0f}% | {y1:.0f}% | {okstr} |")
            summary[(sname, P["eh"], f)] = {m: tot(m, "total") / ns for m in meths}
        print()

    for sname, upd in shapes:
        P = dict(base)
        P.update(upd)
        block(P, sname, methods, True)
    P = dict(base)
    P["eh"] = 0.0
    block(P, shapes[0][0], ["chain", "loc", "unloc+dfs"], False)

    print("== Total task queries per seed (all searches, repairs and uninformative rejections included) ==")
    print("   | shape | e_h | f | chain | loc | loc+dfs | unloc+dfs | fresh | 3 (p d + r0) x 40 |")
    for (sname, eh, f), s in summary.items():
        P = dict(base)
        P.update(dict(shapes)[sname])
        row = " | ".join(f"{s[m]:.0f}" if m in s else "-" for m in methods)
        print(f"   | {sname} | {eh} | {f:.2f} | {row} | {3 * (P['p'] * P['d'] + P['r0']) * 40} |")
    print()
    print("   Reading.  'bounds hold' checks, on every rejection of chain, loc and loc+dfs: loc's cost <= sum pi_l +")
    print("   t*_N(u_L), with path calls the human's own and cost <= p_max d + t_max; every CERT is at the human's own")
    print("   slip; the first depth-first mistake is before N*_r; loc+dfs <= 2 min{loc, first + 1}.  unloc+dfs abstains")
    print("   when the run has no mistake (the human's own slip, passed by N, is all V objects to): without a location")
    print("   nothing can be repaired.  'fresh' reruns a problem after an uninformative rejection (at most 10, then")
    print("   abstains); '(at a human slip %)' is the share of those rejections caused by a human slip that this run's")
    print("   fresh verdict passed; the rest are runs that left the human's nominal tree without a mistake.")
    print()
    counterexamples()
    print(f"(runtime {time.time() - t0:.0f} s)")


# ------------------------------------------------------------------ small counterexamples


def counterexamples():
    """Section 2's counterexamples, built by hand on a root with two leaf lemmas A and B."""
    print("== Counterexamples (hand-built: root poses A in round 1 and B in round 2, assembles in round 3;")
    print("   leaves take 3 rounds; the only unlearned insight is in B's round 2 unless stated) ==")
    P = dict(d=1, b=2, p=2, r0=3, r0min=3, s=3, m=2, lam=0.0, eh=0.0, kdev=2)

    def build(ver):
        ctr = [0]
        root = HCall()
        root.id, root.h, root.slip, root.rev_ins = 100, 1, False, {}
        A, B = HCall(), HCall()
        for c, i in ((A, 101), (B, 102)):
            c.id, c.h, c.slip, c.rev_ins = i, 0, False, {}
            c.work = [[None, []] for _ in range(3)]
        root.work = [[None, [A]], [None, [B]], [None, []]]
        del ctr
        finalize(root, ver, P)
        return root, A, B

    # CE2: located V needed.  A false pass on B's deviated claim keeps the root on track; V rejects.
    ver = Ver(0.0, 0.0, "cached", 7, None)
    root, A, B = build(ver)
    B.work[1][0] = 0
    ver.override[(KD, B.id, 64 * 1 + 0)] = True  # N passes B's first invalid claim
    ru = run_call(root, True, set(), ver, P)
    path = v_flag(ru, [])
    y1 = s_own(ru, [], [])[0]
    seq = []
    hit, st = s_loc(path, seq)
    print(f"   CE2 (false pass in the run, V unlocated): root record {ru.rec}; V names "
          f"{'B' if path[-1].ref is B else '?'}; S_own from the root {'hits' if y1 else 'stalls (no hit)'}; "
          f"S_loc {'hits in B' if hit and st[-1][0].ref is B else 'fails'} after {len(seq)} queries.")
    # CE3: (A3'-tree) fails.  The human's own claim in A is a slip that N passes; the run's only mistake is in B.
    ver = Ver(0.0, 0.0, "cached", 7, None)
    root, A, B = build(ver)
    A.slip = True
    ver.override[(KH, A.id, 0)] = True  # N passes the human's slip in A
    finalize(root, ver, P)
    B.work[1][0] = 0
    ver.override[(KD, B.id, 64 * 1 + 0)] = True  # and passes B's deviated claim
    ru = run_call(root, True, set(), ver, P)
    path = v_flag(ru, [])
    seq = []
    hit, st = s_loc(path, seq)
    print(f"   CE3 (the human's slip passed by N): V names {'A' if path[-1].ref is A else 'B'} (first in depth-first "
          f"order); S_loc {'hits' if hit else 'ends in CERT at A, the human own claim'} after {len(seq)} queries; "
          f"without the repair rule this is a stall although B holds a mistake.")
    # CE1: randomized verdicts.  No unlearned insight at all; A's leaf budget is tight (s = 0), and a
    # fresh false fail on the human's own valid claim in A makes A 'open' in this run.
    P1 = dict(P, s=0)
    ver = Ver(0.0, 0.0, "cached", 7, None)
    root, A, B = build(ver)
    finalize(root, ver, P1)

    class Forced(Ver):
        def run(self, kind, cid, idx, valid):
            return valid and not (kind == KH and cid == A.id)  # this run's draw fails A's (valid) claim

    fver = Forced(0.0, 0.0, "fresh", 7, None)
    ru = run_call(root, True, set(), fver, P1)
    dfs = linearize(ru, [])
    seq = []
    hit, st = s_own(ru, seq, [])
    print(f"   CE1 (fresh verdicts, no mistake anywhere): A's record in this run {ru.rounds[0][1][0].rec}, the root's "
          f"{ru.rec}; mistakes in the run: {sum(x[2] for x in dfs)}; S_own descends into A (the human's own work) and "
          f"{'hits' if hit else 'ends without a hit'}; the full depth-first scan ({len(dfs)} rounds) finds none: an "
          f"uninformative rejection.")
    print()


if __name__ == "__main__":
    main()
