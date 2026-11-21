"""Referee 8: theory checks for verified-slack.md (final pass).

Part 1. Lemma 3's periodic-schedule claim. Every periodic schedule of period 4 with frequencies
        (S, U, H) = (1/2, 1/4, 1/4); one of period 8. For each: the latest position of each
        stream's k-th service against k/w (what the displayed bound needs) and (k+1)/w (what the
        proof asserts), the scan's sure bound 2 n0 - 1, and E[queries] for a single mistake at
        scan position 0 with an adversarial list.
Part 2. (A4') stated on notebooks versus the output rule "first passing claim": a one-hypothesis
        class where notebook-level (A4') holds and every output is wrong.
Part 3. The formalizer inside V: a formalizer that fails on the human's own blueprint (an (A2)
        violation) turns the problem into an abstention, at a cost of a full scan. Exact-Bayes
        toy with thread R's E6 humans (M1 noticing, M3 silent), VSI with S, U, S, H, §2.3's list
        (empty for E6), the abstain rule, with and without cached answers.
Part 4. Effort arithmetic: abstentions (rate phi, cost c n0 each) against the one-fifth bar and
        the human-does-it baseline; thread T's statement-writing cap; thread T's products.

Usage: python3 -B referee8_theory.py > referee8_theory.out
"""

import itertools
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "research"))

import numpy as np  # noqa: E402

W = {"S": 0.5, "U": 0.25, "H": 0.25}


# ---------------------------------------------------------------------------------------------
def positions(pattern, stream, upto):
    """1-based query positions of `stream`'s services in the periodic schedule."""
    out, t = [], 0
    while len(out) < upto:
        if pattern[t % len(pattern)] == stream:
            out.append(t + 1)
        t += 1
    return out


def exp_queries_first_step_mistake(pattern, n):
    """E[queries] when the only mistake is at scan position 0, the list is adversarial (never a
    mistake) and each uniform draw hits with probability 1/n. Exact."""
    p_alive, e, t = 1.0, 0.0, 0
    while p_alive > 1e-15:
        s = pattern[t % len(pattern)]
        t += 1
        if s == "S":                           # the first scan service is step 0: a hit
            return e + p_alive * t
        if s == "U":
            e += p_alive * (1 / n) * t
            p_alive *= 1 - 1 / n
    return e


def part1():
    print("## Part 1. Lemma 3: which periodic schedules with frequencies (1/2, 1/4, 1/4) satisfy it")
    print()
    print("lag_k = position of the stream's k-th service minus k/w. The displayed bound "
          "(position j_i reached by (j_i+1)/w_i, j_i counted from 0) needs lag <= 0 for every k; "
          "the proof's sentence ('j-th time by (j+1)/w_i') needs lag <= 1/w_i.")
    print()
    print("| schedule | max lag S (1/w=2) | max lag U (1/w=4) | max lag H (1/w=4) | displayed bound | "
          "proof's sentence | scan sure bound 2n0-1 (n0=8,9) | E[q], one mistake at step 0, n=64 |")
    print("|---|---|---|---|---|---|---|---|")
    pats = sorted(set(itertools.permutations("SSUH")))
    pats.append(tuple("UUHHSSSS"))
    for pat in pats:
        lags = {}
        for s in "SUH":
            pos = positions(pat, s, 40)
            lags[s] = max(p - k / W[s] for k, p in enumerate(pos, 1))
        disp = all(lags[s] <= 1e-12 for s in "SUH")
        proof = all(lags[s] <= 1 / W[s] + 1e-12 for s in "SUH")
        sure = all(positions(pat, "S", n0)[n0 - 1] <= 2 * n0 - 1 for n0 in (8, 9))
        eq = exp_queries_first_step_mistake(pat, 64)
        print(f"| {', '.join(pat)} | {lags['S']:+.0f} | {lags['U']:+.0f} | {lags['H']:+.0f} | "
              f"{'holds' if disp else 'FAILS'} | {'holds' if proof else 'FAILS'} | "
              f"{'holds' if sure else 'FAILS'} | {eq:.3f} (bound (0+1)/w_S = 2) |")
    print()
    print("Reading: only schedules whose every stream has lag <= 0 (each stream served k times by "
          "position k/w, i.e. discrepancy below one from the start) satisfy the displayed bound. "
          "S, U, S, H is one. 'Bounded discrepancy' alone gives k/w + O(period).")
    print()


# ---------------------------------------------------------------------------------------------
def part2():
    print("## Part 2. Notebook-level (A4') with the output rule 'first passing claim'")
    print()
    # class {P}: K = 0. P writes c1 (wrong; V passes it) at step 0, then c2 (correct; V passes) at
    # step 1. n0 = 2, n = 4. S_V(x) = 'some claim in x passes V'; S*(x) = 'x holds a correct claim'.
    V_pass = {"c1": True, "c2": True, "-": False}
    correct = {"c1": False, "c2": True, "-": False}
    chain = ["c1", "c2", "-", "-"]
    T = 10
    outputs_wrong, a4_holds, sstar_fail = 0, True, 0
    for _ in range(T):
        run = chain[:]                       # the imitator is P (K = 0): no mistakes ever
        S_V = any(V_pass[c] for c in run)
        S_star = any(correct[c] for c in run)
        a4_holds &= (not S_V) or S_star
        out = next(c for c in run if V_pass[c])
        outputs_wrong += not correct[out]
        sstar_fail += S_V and not S_star
    print(f"T = {T} problems, class {{P}} (K = 0). Notebook-level (A4') holds on every final "
          f"notebook: {a4_holds}. S_V holds and S* holds on every run.")
    print(f"Outputs (first passing claim) that are wrong: {outputs_wrong} of {T}. "
          f"Accepted runs failing S*: {sstar_fail}.")
    print("So Theorem 5(a) ('under (A4') every output satisfies S*') fails for the output artifact, "
          "and 5(f)'s 'failed outputs are exactly the accepted runs that fail S*' is false: 10 wrong "
          "outputs against a bound of 0. With (A4') stated per claim ('every claim V passes in the "
          "imitator's final notebooks is a solution'), c1 violates (A4'), as it should.")
    print()


# ---------------------------------------------------------------------------------------------
def search_abstain(A, rng, n, cache):
    """S, U, S, H over committed steps, with §2.3's H (empty for E6, so its turn goes to S).
    Returns (cost, hit). Abstains when the scan exhausts the committed steps."""
    committed = [j for j in range(n) if not A.asked(j)]
    order = "SUSH"
    pos, turn, cost = 0, 0, 0
    queried, answers = set(), []
    while True:
        s = order[turn % 4]
        turn += 1
        if s == "H":
            s = "S"                            # empty list: its turn goes to S
        if s == "U":
            j = committed[int(rng.integers(len(committed)))]
        else:
            while pos < len(committed) and committed[pos] in queried:
                pos += 1
            if pos >= len(committed):
                for (jj, aa) in answers:
                    A.add(jj, aa)
                return cost, False             # scan exhausted: the run is the human's chain
            j = committed[pos]
            pos += 1
        new = j not in queried
        cost += 1 if (new or not cache) else 0
        queried.add(j)
        ans = A.human(j)
        answers.append((j, ans))
        if ans != A.code(j):
            hit = answers.pop()
            for (jj, aa) in [hit] + answers:
                A.add(jj, aa)
            return cost, True


def vsi_with_formalizer(mech, n, s, phi, cache):
    import threadR_compose as R
    As, nr, n0, _, sd = R.humans(mech, n, s, True, None)
    frng = np.random.default_rng(10**6 + 1000 * n + s)        # formalizer failures, per problem
    ffail = frng.random(len(As)) < phi
    rng = np.random.default_rng(sd + 2 * 10**8 + 7)
    total = on_fail = abst = wrong = 0
    abst_costs, max_search = [], 0
    for p, A in enumerate(As):
        A.build(None)
        while True:
            accepted = (not A.failed()) and not ffail[p]
            if accepted:
                break
            c, hit = search_abstain(A, rng, nr, cache)
            total += c
            max_search = max(max_search, c)
            if ffail[p]:
                on_fail += c
            if not hit:
                abst += 1
                abst_costs.append(c)
                break
            A.build(None)
        # an accepted run is correct here: V = success oracle and the formalizer only rejects
    return dict(total=total, on_fail=on_fail, abst=abst, nfail=int(ffail.sum()),
                abst_cost=float(np.mean(abst_costs)) if abst_costs else 0.0, n=nr, n0=n0,
                max_search=max_search, wrong=wrong)


def part3():
    print("## Part 3. A formalizer that fails on the human's own blueprint: an abstention, at the "
          "cost of a full scan")
    print()
    print("Exact Bayes on thread R's E6 humans (20 per cell), VSI with S, U, S, H, §2.3's list "
          "(empty for E6), abstain when the scan exhausts. Each problem's formalizer fails on the "
          "human's blueprint with probability phi (deterministically: every rerun is rejected).")
    print()
    print("| human | n0 | phi | cache | total task queries (100 problems) | of which on "
          "formalizer-failed problems | abstentions | mean cost per abstaining search | "
          "per abstention, in n0 | largest search vs 2n0-1 | wrong outputs |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for mech, label in (("M1", "noticing"), ("M3", "silent")):
        for n in (16, 64, 256):
            for phi in (0.0, 0.1, 0.3):
                for cache in (False, True):
                    if phi == 0.0 and cache:
                        continue
                    rs = [vsi_with_formalizer(mech, n, s, phi, cache) for s in range(20)]
                    n0 = rs[0]["n0"]
                    tot = np.mean([r["total"] for r in rs])
                    onf = np.mean([r["on_fail"] for r in rs])
                    ab = np.mean([r["abst"] for r in rs])
                    nf = np.mean([r["nfail"] for r in rs])
                    ac = np.mean([r["abst_cost"] for r in rs if r["abst"]]) if ab else 0.0
                    ms = max(r["max_search"] for r in rs)
                    print(f"| {label} | {n0} | {phi} | {'yes' if cache else 'no'} | {tot:,.1f} | "
                          f"{onf:,.1f} | {ab:.1f} (failed: {nf:.1f}) | {ac:.1f} | "
                          f"{ac / n0:.2f} | {ms} vs {2 * n0 - 1} | {sum(r['wrong'] for r in rs)} |")
    print()
    print("Reading: no formalizer failure becomes a wrong output; each becomes an abstention whose "
          "final search must scan the whole run, n = 2 n0 distinct task queries with caching "
          "(about 8n0/3 without). These searches exceed Theorem 5(d)'s 2n0 - 1, as its (A2) "
          "clause allows. The cost grows with the number of problems, not with K.")
    print()


# ---------------------------------------------------------------------------------------------
def part4():
    print("## Part 4. Effort arithmetic")
    print()
    print("Worst case, search queries only, V-machine, beta = 0: VSI 2 n0 K. Bar: a fifth of "
          "chained imitation's 20 n0 K, i.e. 4 n0 K. Abstentions at rate phi, each costing c n0 "
          "task queries. Bar: 2K + c phi T <= 4K, so T <= 2K/(c phi). Human-does-it baseline "
          "(n0 T): T > 2K/(1 - c phi). A window exists iff phi < 1/(2c).")
    print()
    print("| phi | c = 2 (cached scan): T_max/K | baseline T_min/K | c = 8/3 (uncached): T_max/K | "
          "T_min/K | c = 3 (cached, then the human does it): T_max/K | T_min/K |")
    print("|---|---|---|---|---|---|---|")
    for phi in (0.05, 0.1, 0.2, 0.3):
        cells = []
        for c in (2, 8 / 3, 3):
            tmax = 2 / (c * phi)
            tmin = 2 / (1 - c * phi) if c * phi < 1 else float("inf")
            cells += [f"{tmax:.1f}", f"{tmin:.1f}" + (" (no window)" if tmin >= tmax else "")]
        print(f"| {phi} | " + " | ".join(cells) + " |")
    print()
    print("Thread T §5.3(6): statement-writing cost s per problem caps T at (4 - 2 iota) n0 K / s.")
    for s_steps, lab in ((0.05, "a few days per statement (AI drafting plus review)"),
                         (0.5, "AnnalsChallenge pace, ~1.4 person-months per statement")):
        for iota in (1.0, 1.5):
            print(f"  s = {s_steps} three-month steps ({lab}), iota = {iota}, n0 = 30: "
                  f"T <= {(4 - 2 * iota) * 30 / s_steps:,.0f} K")
    print()
    print("Thread T §5.2 products:")
    rows = [("as specified", 0.80, 0.97, 0.76), ("protocol + hardened", 0.96, 0.995, 0.76),
            ("formalizer in V", 0.95, 0.99, 0.82)]
    for lab, a, c, e in rows:
        print(f"  {lab:<22} {a} x {c} x {e} = {a * c * e:.3f}")
    for lab, p2, p3 in (("formalizer at chain end", 0.80, 0.90), ("formalizer in V", 0.93, 0.97)):
        e1 = p2 * 0.87 + 0.5 * (p3 - p2) + 0.15 * (1 - p3)
        e2 = 0.87 * (p2 + 0.5 * (p3 - p2) + 0.15 * (1 - p3))
        print(f"  effort factor, {lab}: {e1:.3f} (0.87 on the first term only), "
              f"{e2:.3f} (0.87 on all terms)")
    print("  Note §6: f_mis for the formalizer in V (thread T §1.3): 0.7–1.3% with the protocol, "
          "5–9% unreviewed with new definitions; the note quotes only the in-chain 0.5–1% and 'up to 5%'.")
    print()


if __name__ == "__main__":
    part1()
    part2()
    part3()
    part4()
