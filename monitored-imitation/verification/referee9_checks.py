"""Referee 9: checks for the paper paper/verified-slack-imitation.tex.

Run from monitored-imitation/:  python3 -B verification/referee9_checks.py > verification/referee9_checks.out
Reads only saved outputs (results/*.json, research/*.out|json, verification/referee8_e7_default.out).
Writes nothing else. Fixed seeds; runs in a few seconds.

Parts
  A  the schedule constants of Lemma 4.4 / Theorem 4.7(d) (S,U,S,H against U,H,S,S and H,U,S,S)
  B  Lemma 4.4's bound, by simulation on random rejected runs
  C  Proposition 4.10 (safety net for any learner): a simulation with adversarial learners,
     with and without route (i), the "nothing bizarre" check and audits
  D  Theorem 6.2(b): which reference gives B_T <= log2 C(T+K', K')
  E  numbers quoted in the paper, recomputed from the saved outputs and the thread estimates
"""
import json
import math
import os
import random
import re
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def hdr(s):
    print()
    print("=" * 78)
    print(s)
    print("=" * 78)


# ----------------------------------------------------------------------------- A
def schedule_positions(pattern, nqueries, list_len=10**9):
    """Return dict stream -> list of query indices (1-based) at which it is served.
    When the list H is exhausted its turn goes to S (as the paper's protocol says)."""
    pos = {"S": [], "U": [], "H": []}
    q = 0
    h_used = 0
    while q < nqueries:
        for s in pattern:
            q += 1
            if q > nqueries:
                break
            if s == "H":
                if h_used < list_len:
                    h_used += 1
                    pos["H"].append(q)
                else:
                    pos["S"].append(q)
            else:
                pos[s].append(q)
    return pos


def part_a():
    hdr("A. Schedule constants (Lemma 4.4, Theorem 4.7(d), 'Why the order S, U, S, H')")
    p = schedule_positions("SUSH", 64)
    okS = all(p["S"][j - 1] == 2 * j - 1 for j in range(1, 20))
    okU = all(p["U"][k - 1] == 4 * k - 2 for k in range(1, 10))
    okH = all(p["H"][i - 1] == 4 * i for i in range(1, 10))
    print(f"S,U,S,H: scan's j-th step is query 2j-1: {okS}; U's k-th draw is 4k-2: {okU}; H's i-th entry is 4i: {okH}")
    # prefix property used in Proposition 4.10(b)
    seq = "SUSH" * 50
    ok_prefix = all(seq[:t].count("S") >= t - seq[:t].count("S") for t in range(1, len(seq) + 1))
    print(f"S,U,S,H: in every prefix, non-scan queries <= scan queries: {ok_prefix}")
    for pat in ["SUSH", "UHSS", "HUSS"]:
        worst = []
        for n0 in [8, 9, 32, 33]:
            pp = schedule_positions(pat, 8 * n0, list_len=10**9)
            worst.append((n0, pp["S"][n0 - 1]))  # scan's n0-th step = first mistake at step n0-1
        print(f"{pat}: query index of the scan's n0-th step (worst case, nonempty list): "
              + ", ".join(f"n0={a}: {b} (2n0-1={2*a-1})" for a, b in worst))
    # with an empty list, every schedule gives the scan more turns
    for pat in ["SUSH", "UHSS"]:
        pp = schedule_positions(pat, 200, list_len=0)
        print(f"{pat} with an empty list: scan's 8th step at query {pp['S'][7]}")


# ----------------------------------------------------------------------------- B
def search_cost(n, M, lst, rng, pattern="SUSH"):
    """One search on a fixed run of n committed steps with mistake set M (set of step indices)."""
    scan = 0
    hidx = 0
    q = 0
    while True:
        for s in pattern:
            if s == "H" and hidx >= len(lst):
                s = "S"
            q += 1
            if s == "S":
                k = scan
                scan += 1
                if k >= n:
                    return None  # exhausted (cannot happen when M is nonempty)
            elif s == "U":
                k = rng.randrange(n)
            else:
                k = lst[hidx]
                hidx += 1
            if k in M:
                return q


def part_b():
    hdr("B. Lemma 4.4: E[queries] <= min{4n/|M|, 2 j_S + 1, 4(j_H + 1)} (simulation)")
    rng = random.Random(9)
    worst_ratio = 0.0
    sure_viol = 0
    cases = 0
    for trial in range(400):
        n = rng.choice([16, 40, 64])
        m = rng.randint(1, n // 2)
        M = set(rng.sample(range(n), m))
        L = [rng.randrange(n) for _ in range(rng.randint(0, 8))]
        jS = min(M)
        jH = next((i for i, k in enumerate(L) if k in M), None)
        reps = 300
        costs = [search_cost(n, M, L, rng) for _ in range(reps)]
        mean = sum(costs) / reps
        bound = min(4 * n / m, 2 * jS + 1, 4 * (jH + 1) if jH is not None else float("inf"))
        sure = min(2 * jS + 1, 4 * (jH + 1) if jH is not None else float("inf"))
        sure_viol += sum(c > sure for c in costs)
        worst_ratio = max(worst_ratio, mean / bound)
        cases += 1
    print(f"{cases} random rejected runs, 300 searches each: largest mean/bound = {worst_ratio:.3f}; "
          f"searches above the sure bound min(2j_S+1, 4(j_H+1)): {sure_viol}")


# ----------------------------------------------------------------------------- C
class Toy:
    """One problem.  Notebooks are tuples; the human P is deterministic.
    The human's own chain writes 'SOL' at step n0-1; V accepts iff 'SOL' is in the notebook,
    so (A3') holds (every extension of c_{n0} contains SOL)."""

    def __init__(self, n0, sigma, pid=0):
        self.n0, self.n = n0, n0 + sigma
        self.x0 = ("x0", pid)
        self.chain = [self.x0]
        for k in range(self.n0 + sigma):
            y = self.chain[-1]
            self.chain.append(y + ("SOL" if k == self.n0 - 1 else self.f(y),))
        self.sol_nb = self.chain[self.n0 - 1]

    @staticmethod
    def f(y):
        return "h%d" % (zlib.crc32(repr(y).encode()) % 97)

    def P(self, y):
        # deterministic, a function of the notebook alone; SOL only at the chain notebook c_{n0-1}
        return "SOL" if y == self.sol_nb else self.f(y)

    def V(self, y):
        return "SOL" in y


def make_learner(kind, rng):
    """Arbitrary learners. They see the cache only through cache-first decoding (enforced outside)."""
    state = {"rerun": 0, "target": None}

    def learner(toy, y, step, cache):
        r = state["rerun"]
        on_chain = step < len(toy.chain) and y == toy.chain[step]
        truth = toy.P(y)
        if kind == "random":
            if rng.random() < 0.6 and truth != "SOL":
                return truth
            return "w%d" % rng.randrange(5)
        if kind == "early":           # wrong at the first uncached chain notebook
            return "w%d" % r if on_chain else ("w%d" % rng.randrange(3))
        if kind == "late":            # correct along the chain up to the last uncached chain notebook below n0
            if on_chain:
                unc = [i for i in range(toy.n0) if toy.chain[i] not in cache]
                if unc and step == max(unc):
                    return "w%d" % r
                return truth if truth != "SOL" else "w%d" % r
            return "w%d" % rng.randrange(3)
        if kind == "offchain-many":   # one chain mistake, then many off-chain mistakes for U to hit
            if on_chain:
                unc = [i for i in range(toy.n0) if toy.chain[i] not in cache]
                if unc and step == rng.choice(unc):
                    return "w%d" % r
                return truth if truth != "SOL" else "w%d" % r
            return "z%d" % rng.randrange(1000)
        raise ValueError(kind)

    learner.state = state
    return learner


def run_vsi_problem(toy, learner, rng, cache, use_L=False, use_bizarre=False, beta=0.0,
                    adv_learner_L=False, max_reruns=400, hlist="random", scan_skips_free=True):
    """VSI on one problem with cache-first decoding and cached answers; no asks.
    Returns (task queries, rejections, outcome)."""
    queries = 0
    rejections = 0
    for rerun in range(max_reruns):
        learner.state["rerun"] = rerun
        # build the run
        y = toy.x0
        nbs, labels = [], []
        for k in range(toy.n):
            nbs.append(y)
            if y in cache:
                lab = cache[y]
            elif adv_learner_L or use_bizarre:
                # counterexample learners for route (i) / the bizarre check:
                # a fresh wrong valid entry at c_0, then an invalid (or bizarre) entry at step 1,
                # then SOL so that V accepts when the bizarre check is the point
                if k == 0:
                    lab = "fresh%d" % rerun
                elif k == 1:
                    lab = "BAD" if adv_learner_L else "WEIRD"
                elif k == 2 and use_bizarre:
                    lab = "SOL"
                else:
                    lab = "w0"
            else:
                lab = learner(toy, y, k, cache)
            labels.append(lab)
            y = y + (lab,)
        final = y
        mist = {k for k in range(toy.n) if nbs[k] not in cache and labels[k] != toy.P(nbs[k])}

        def ask(k):
            nonlocal queries
            if nbs[k] in cache:
                return cache[nbs[k]] != labels[k]  # never a mistake under cache-first decoding
            queries += 1
            cache[nbs[k]] = toy.P(nbs[k])
            return k in mist

        if toy.V(final):
            if use_bizarre and "WEIRD" in final:
                # bisect to the flip (checker's work, not task queries), task-query it, rerun
                flip = labels.index("WEIRD")
                assert ask(flip)
                rejections += 1
                continue
            if beta > 0 and rng.random() < beta:
                ask(rng.randrange(toy.n))
            return queries, rejections, "output"
        rejections += 1
        # route (i)
        if use_L:
            flagged = [k for k in range(toy.n) if labels[k] == "BAD"]
            hit = False
            for k in flagged:
                if ask(k):
                    hit = True
                    break
            if hit:
                continue
        # route (ii): S,U,S,H over committed steps, the scan skipping cached notebooks within its turn
        L = [rng.randrange(toy.n) for _ in range(6)] if hlist == "random" else []
        scan, hidx, found = 0, 0, False
        while not found:
            for s in "SUSH":
                if s == "H" and hidx >= len(L):
                    s = "S"
                if s == "S":
                    if scan_skips_free:
                        while scan < toy.n and nbs[scan] in cache:
                            scan += 1
                    if scan >= toy.n:
                        return queries, rejections, "abstain"
                    k = scan
                    scan += 1
                elif s == "U":
                    k = rng.randrange(toy.n)
                else:
                    k = L[hidx]
                    hidx += 1
                if ask(k):
                    found = True
                    break
    return queries, rejections, "cap"


def part_c():
    hdr("C. Proposition 4.10 (safety net for any learner): per-problem task queries, cache-first decoding")
    rng = random.Random(4)
    for n0 in [4, 8, 16]:
        worst = 0
        outcomes = {}
        for kind in ["random", "early", "late", "offchain-many"]:
            for trial in range(150):
                toy = Toy(n0, n0, pid=trial)
                cache = {}
                q, r, out = run_vsi_problem(toy, make_learner(kind, rng), rng, cache)
                worst = max(worst, q)
                outcomes[out] = outcomes.get(out, 0) + 1
        print(f"n0={n0:3d}: search only (no L, no bizarre check, beta=0), 600 problems, 4 adversarial learners: "
              f"max task queries per problem = {worst} (2n0 = {2*n0}); outcomes {outcomes}")
    # audits
    for n0 in [4, 8]:
        worst = 0
        for kind in ["random", "late", "offchain-many"]:
            for trial in range(300):
                toy = Toy(n0, n0, pid=trial)
                q, r, out = run_vsi_problem(toy, make_learner(kind, rng), rng, {}, beta=1.0)
                worst = max(worst, q)
        print(f"n0={n0:3d}: with audits at beta=1: max task queries per problem = {worst} (2n0 = {2*n0}). "
              "Searches alone never exceed 2n0-1 (a search ending in a scan hit has one fewer non-scan query, and "
              "c_{n0-1} can be scanned only as a mistake), so one audit still fits within 2n0.")
    # perfect learner, audits: (c)'s 'at most 2 n0 M in all' with M = 0
    class Perfect:
        state = {"rerun": 0}
        def __call__(self, toy, y, step, cache):
            return toy.P(y)
    tot, rej = 0, 0
    for trial in range(50):
        toy = Toy(8, 8, pid=trial)
        q, r, out = run_vsi_problem(toy, Perfect(), rng, {}, beta=1.0)
        tot += q
        rej += r
    print(f"perfect learner (M = 0), beta = 1, 50 problems: {rej} rejections, {tot} task queries (all audits); "
          "(c)'s 'at most 2 n0 M task queries in all' omits the audits.")
    # the scan must skip cached notebooks within its own turn
    worst = 0
    for kind in ["late", "offchain-many"]:
        for trial in range(300):
            toy = Toy(16, 16, pid=trial)
            q, r, out = run_vsi_problem(toy, make_learner(kind, rng), rng, {}, scan_skips_free=False)
            worst = max(worst, q)
    print(f"n0= 16: if a cached scan step uses up the S turn (no query, but the turn passes to U), "
          f"max task queries per problem = {worst} (2n0 = 32): the proof needs the scan to skip cached notebooks "
          "within its turn.")
    # route (i) counterexample
    toy = Toy(8, 8, pid=999)
    q, r, out = run_vsi_problem(toy, make_learner("early", rng), rng, {}, use_L=True, adv_learner_L=True,
                                max_reruns=200)
    print(f"n0=  8: with route (i) (L flags 'BAD'; (L0)-(L1) hold), a learner that writes a fresh wrong valid entry "
          f"at c_0 and 'BAD' at step 1: {q} task queries, {r} rejections in 200 reruns, outcome '{out}' "
          f"(2n0 = 16). c_0 is never queried, so it is never cached.")
    toy = Toy(8, 8, pid=998)
    q, r, out = run_vsi_problem(toy, make_learner("early", rng), rng, {}, use_bizarre=True, max_reruns=200)
    print(f"n0=  8: with the 'nothing bizarre' check ((M1)-(M2) hold), a learner that writes a fresh wrong entry at c_0, "
          f"'WEIRD' at step 1 and SOL at step 2: {q} task queries, {r} failed checks in 200 reruns, outcome '{out}'.")
    print("So (b) holds for route (ii) searches, with or without audits, when the scan skips cached notebooks within")
    print("its turn; with route (i) or the bizarre check it fails for an arbitrary learner.")
    print("(c)'s count of rejections still holds in all cases (each rejection or failed check ends at a told notebook")
    print("where the learner was wrong); its total of task queries needs the audits added.")


# ----------------------------------------------------------------------------- D
def part_d():
    hdr("D. Theorem 6.2(b): B_T against log2 C(T+K', K')")
    print("thread V Theorem 2(b): against VSI[coin_q], q = K'/(K'+T), the exponent is "
          "B_coin = T log2(1+K'/T) + K' log2(1+T/K');")
    print("against the uniform mixture of content-blind verdict scripts it is exactly log2 C(T+K', K').")
    print(f"{'K_':>4} {'T':>6} {'log2 C':>10} {'B_coin':>10} {'Klog2e+Klog2(1+T/K)':>22}  B_coin <= log2 C ?")
    for Kp, T in [(1, 4), (4, 6), (10, 10), (10, 100), (20, 1000), (50, 10**4)]:
        lc = (math.lgamma(T + Kp + 1) - math.lgamma(T + 1) - math.lgamma(Kp + 1)) / math.log(2)
        bc = T * math.log2(1 + Kp / T) + Kp * math.log2(1 + T / Kp)
        up = Kp * math.log2(math.e) + Kp * math.log2(1 + T / Kp)
        print(f"{Kp:>4} {T:>6} {lc:>10.2f} {bc:>10.2f} {up:>22.2f}  {bc <= lc + 1e-9}")
    print("So 'B_T <= log2 C(T+K',K')' (paper) is true only for the script-mixture reference; for the coin reference "
          "B_T exceeds log2 C. Both are below K' log2 e + K' log2(1+T/K').")


# ----------------------------------------------------------------------------- E
def part_e():
    hdr("E. Numbers")
    R = lambda *p: os.path.join(ROOT, *p)
    same = json.load(open(R("results", "slack_imitation_same.json")))
    summ = json.load(open(R("results", "slack_imitation_summary.json")))
    ver = json.load(open(R("results", "slack_imitation_verifier.json")))
    ns = [16, 64, 256]
    ci = [same[f"noticing_n{n}_same_CI_n0"]["task_mean"] for n in ns]
    si = [summ[f"noticing_n{n}_sigma{n//2}_CI"]["task_mean"] for n in ns]
    print("E6 chained imitation (noticing, same humans):", [round(x) for x in ci], " paper: 2,915 -> 12,724 -> 51,365")
    print("E6 slack imitation (noticing):", [round(x) for x in si], " paper: 160 -> 204 -> 204")
    sil_si = [summ[f"silent_n{n}_sigma{n//2}_CI"]["task_mean"] for n in ns]
    sil_ci = [same[f"silent_n{n}_same_CI_n0"]["task_mean"] for n in ns]
    print("Fig. 2(a) 'slack doubles the cost of silent ones': SI/CI on silent humans =",
          [round(a / b, 2) for a, b in zip(sil_si, sil_ci)],
          "; silent SI / the plotted CI line (noticing) =", [round(a / b, 2) for a, b in zip(sil_si, ci)])

    # referee 8's default-schedule rerun
    rows = {}
    for line in open(R("verification", "referee8_e7_default.out")):
        m = re.match(r"\| (M\d'?) \| (\d+) \| ([\d,\.]+) ±[^|]*\| ([\d,\.]+) ±[^|]*\| ([\d,\.]+) ±", line)
        if m:
            f = lambda s: float(s.replace(",", ""))
            rows[(m.group(1), int(m.group(2)))] = (f(m.group(3)), f(m.group(4)), f(m.group(5)))
    paper_vsi = {"M1": (26, 32), "M2": (89, 1442), "M3": (559, 8238), "M4": (158, 187), "M5": (355, 5316),
                 "M6": (34, 41), "M7": (10, 10), "M8": (51, 2350)}
    paper_siv = {"M1": (13, 14), "M2": (181, 2636), "M3": (1610, 26091), "M4": (221, 338), "M5": (1029, 16127),
                 "M6": (76, 1439), "M7": (136, 2868), "M8": (136, 2868)}
    rj = json.load(open(R("research", "threadR_compose.json")))
    bad = []
    for mech, (a, b) in paper_vsi.items():
        lo, hi = (10, 160) if mech in ("M4", "M5") else (8, 128)
        got = (rows[(mech, lo)][2], rows[(mech, hi)][2])
        if (round(got[0] + 1e-9), round(got[1] + 1e-9)) != (a, b) and not (abs(got[0] - a) <= 0.5 and abs(got[1] - b) <= 0.5):
            bad.append((mech, "VSI", got, (a, b)))
    # SI-V from thread R's json
    def rkey(mech, proto, n0):
        for k in rj:
            parts = k.split("|")
            if parts[0] == mech and parts[1] == proto and (f"n₀={n0}" in parts[2] and ("N=" not in parts[2] or mech in ("M4", "M5"))):
                return rj[k]
        return None
    for mech, (a, b) in paper_siv.items():
        lo, hi = (10, 160) if mech in ("M4", "M5") else (8, 128)
        g = [rkey(mech, "SI-V", lo), rkey(mech, "SI-V", hi)]
        got = tuple(x["queries_mean"] if isinstance(x, dict) and "queries_mean" in x else None for x in g)
        if None in got or (round(got[0]), round(got[1])) != (a, b):
            bad.append((mech, "SI-V", got, (a, b)))
    print("Table 2 (E7): cells that do not match (rounded) =", bad if bad else "none")
    m2_usl = [rows[("M2", n)][0] for n in (8, 32, 128)]
    m8_usl = [rows[("M8", n)][0] for n in (8, 32, 128)]
    m2_susl = [rows[("M2", n)][1] for n in (8, 32, 128)]
    m8_susl = [rows[("M8", n)][1] for n in (8, 32, 128)]
    print("Table 2 caption '40-55 and 31-34 with a post-mortem': equal weights (USL): M2", m2_usl, "M8", m8_usl)
    print("   the table's own default schedule with the same post-mortem (SUSL): M2", m2_susl, "M8", m8_susl)
    m1 = [rows[("M1", n)][2] for n in (8, 32, 128)]
    m3 = [rows[("M3", n)][2] for n in (8, 32, 128)]
    siv3 = [ver[f"silent_n{n}_sigma{n//2}_SIV"]["task_mean"] for n in ns]
    print("Fig. 2(b) 'about 30' (M1, S,U,S,H):", m1, "; 'about threefold' (silent SI-V / VSI):",
          [round(a / b, 2) for a, b in zip(siv3, m3)])

    # asking on top of VSI
    ratios = []
    for mech in ("M1", "M2", "M7", "M8"):
        for n0 in (8, 32, 128):
            a = rkey(mech, "VSI+ABC", n0)
            b = rkey(mech, "VSI", n0)
            if a and b:
                ratios.append((mech, n0, round(a["queries_mean"] / b["queries_mean"], 1)))
    print("Remark 4.9 'asking multiplied VSI's cost 5-35-fold' (VSI+ABC / VSI, thread R, equal weights):", ratios)

    # Section 9 thresholds and output failure
    p, rbar = 0.3, 1.3
    wU = {"theory": 0.45, "software": 0.55, "empirical": 0.75, "judgment": 0.825}
    wW = {"theory": 0.6, "software": 0.6, "empirical": 0.85, "judgment": 0.9}
    fV = {"theory": 0.15, "software": 0.07, "empirical": 0.27, "judgment": 0.21}
    print("Section 9 thresholds f* = 0.05/(p w rbar), p = 0.3, rbar = 1.3:")
    for d in wU:
        print(f"   {d:9s}: with thread U's w = {wU[d]:.3f}: f* = {0.05/(p*wU[d]*rbar):.3f};  "
              f"with thread W's w = {wW[d]:.2f} (the paper's): f* = {0.05/(p*wW[d]*rbar):.3f};  "
              f"output failure p w rbar f_V = {100*p*wW[d]*rbar*fV[d]:.1f}%")
    print("   paper: thresholds 0.29, 0.23, 0.17, 0.16 (thread U's w); failures 3.5%, 1.6%, 9%, 7% (thread W's w)")

    # arithmetic
    n0 = 24
    D, rho = 1, 0.5
    n = round(n0 / (1 - rho))
    sigma = n - n0
    Lam = min(n, (D + 1) * n / (sigma + 1))
    print(f"Section 10: 2n0 = {2*n0}; 4*Lambda = {4*Lam:.2f} (4(D+1)/rho = {4*(D+1)/rho:.0f}); 20 n0 = {20*n0}")
    print("Corollary 4.13: 2*iota*n0*K < (1/5)*20*n0*K  <=>  iota < 2:", all((2 * i < 4) == (i < 2) for i in [1, 1.5, 1.99, 2, 2.5]))
    ok = all(1 / math.log2(1 / (1 - a)) <= math.log(2) / a for a in [i / 1000 for i in range(1, 1000)])
    print("Appendix A: K/log2(1/(1-alpha)) <= (ln 2) K/alpha for alpha in (0,1):", ok)
    beta, nn = 0.25, 40
    q = beta / (nn + beta)
    print("Theorem 6.2(c): log2(1/q) = log2(1+n/beta):", abs(math.log2(1 / q) - math.log2(1 + nn / beta)) < 1e-12,
          "; log2(1/(1-q)) <= (beta/n) log2 e:", math.log2(1 / (1 - q)) <= beta / nn * math.log2(math.e))


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
