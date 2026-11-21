"""Referee 7: checks of the changed mathematics of verified-slack.md (version 3).

Parts
 1. Lemma 3 with weights and Theorem 5(d) with the default weights (1/2, 1/4, 1/4):
    deterministic schedule S,U,S,H versus a random schedule; another deterministic order;
    general weights and the proof's "served once in every ceil(1/w_i) queries".
 2. Theorem 5(b) with asks at the final-answer slot only: the hit value b_alpha fails.
    (a) a two-step product class (closed form, exact Bayes by enumeration);
    (b) an exact-Bayes toy VSI with asks at the claim-writing slot only (referee 6's class).
 3. Theorem 5(b)-(c): the "nothing bizarre" check without (M2) loops forever.
 4. Theorem 5(f): needs the human's own chain to reach S* (tau*), not only S_V.
 5. Section 6 heavy tails: (A2) failure rate versus abstention rate (thread S, Part E).
 6. Section 7 effort with the default weights, audits at beta = 1 and verifications.
 7. Proposition 7 / Theorem F4: the uniform-query hit rate c_r/(3n) with the retry rule.

Run: python3 referee7_theory.py > referee7_theory.out
"""
import itertools
import math
import random

random.seed(7)


def hr(title):
    print("\n" + "=" * 100 + "\n" + title + "\n" + "=" * 100)


# --------------------------------------------------------------------------------------------
# Part 1. Search schedules.
# --------------------------------------------------------------------------------------------
def search(nc, M, Hlist, sched, rng, weights=(0.5, 0.25, 0.25)):
    """Queries until a stream lands in M (a set of committed positions 0..nc-1), or None if the
    scan exhausts the run first (abstain). sched: a string over {S,U,H} cycled, or 'rand'."""
    iS = iH = 0
    q = 0
    turn = 0
    while True:
        if sched == "rand":
            live = ["S", "U"] + (["H"] if iH < len(Hlist) else [])
            w = {"S": weights[0], "U": weights[1], "H": weights[2]}
            tot = sum(w[s] for s in live)
            r = rng.random() * tot
            for s in live:
                r -= w[s]
                if r <= 0:
                    break
        else:
            s = sched[turn % len(sched)]
            turn += 1
            if s == "H" and iH >= len(Hlist):
                continue  # exhausted or empty list: skipped at no cost
        if s == "S":
            if iS >= nc:
                return None
            k = iS
            iS += 1
        elif s == "U":
            k = rng.randrange(nc)
        else:
            k = Hlist[iH]
            iH += 1
        q += 1
        if k in M:
            return q


def part1():
    hr("Part 1. Lemma 3 with weights; Theorem 5(d) with the default weights (1/2, 1/4, 1/4)")
    rng = random.Random(1)
    trials = 20000
    print("\n(a) The scan bound '2 n0, surely'. One committed mistake at scan position j_S = n0 (the worst")
    print("    case allowed by Lemma 1); H is a list of non-mistakes (it uses its quarter and never hits).")
    print("    n0   sched   max queries   mean queries   Pr[queries > 2 n0]   (2 n0)")
    for n0 in (8, 9, 32, 128):
        n = 2 * n0
        M = {n0 - 1}
        H = [k for k in range(n) if k not in M]
        for sched in ("SUSH", "UHSS", "rand"):
            qs = [search(n, M, H, sched, rng) for _ in range(trials)]
            over = sum(q > 2 * n0 for q in qs) / trials
            print(f"   {n0:4d}  {sched:5s}  {max(qs):10d}   {sum(qs) / trials:12.2f}   {over:16.4f}       ({2 * n0})")
    print("    -> S,U,S,H meets 2 n0 surely; the random schedule meets it only in expectation;")
    print("       the deterministic order U,H,S,S (same frequencies) gives 2 n0 + 1 when n0 is odd.")

    print("\n(b) The uniform bound 4 n/|M| (= 4 Lambda when |M| = (sigma+1)/(D+1)): mistakes placed at the end of")
    print("    the run so that the scan cannot help; H empty. Mean queries against 4 n/|M|.")
    print("    n     |M|   sched   mean queries   4n/|M|")
    for n in (16, 64, 256):
        for m in sorted({1, 4, n // 4}):
            M = set(range(n - m, n))
            for sched in ("SUSH", "rand"):
                qs = [search(n, M, [], sched, rng) for _ in range(trials)]
                qs = [q for q in qs if q is not None]
                # with H empty the S,U,S,H schedule becomes S,U,S,S,U,S...: U gets 1/3 > 1/4
                print(f"   {n:4d}  {m:4d}  {sched:5s}  {sum(qs) / len(qs):12.2f}   {4 * n / m:8.2f}")
    print("    (With H empty its weight goes to S and U, so U's share rises from 1/4 to 1/3 and the mean is below 4n/|M|.)")
    print("    With H a list of non-mistakes, U keeps exactly 1/4:")
    for n in (16, 64, 256):
        for m in sorted({1, 4, n // 4}):
            M = set(range(n - m, n))
            H = [k for k in range(n) if k not in M]
            for sched in ("SUSH", "rand"):
                qs = [search(n, M, H, sched, rng) for _ in range(trials)]
                qs = [q for q in qs if q is not None]
                print(f"   {n:4d}  {m:4d}  {sched:5s}  {sum(qs) / len(qs):12.2f}   {4 * n / m:8.2f}   "
                      f"(scan alone would need {2 * (n - m + 1)})")

    print("\n(c) The list bounds 4 j_H: ripe (j_H = 1), hedge with d decisions (j_H = 1 + d), i-th post-mortem")
    print("    entry (j_H = 1 + d + i). Single mistake late in the run, so S and U rarely help.")
    print("    j_H   sched   max queries   mean   Pr[queries > 4 j_H]   (4 j_H)")
    n = 64
    for jH in (1, 4, 9):
        M = {n - 1}
        H = [k for k in range(n - jH, n - 1)] + [n - 1]
        assert len(H) == jH and H[-1] == n - 1
        for sched in ("SUSH", "rand"):
            qs = [search(n, M, H, sched, rng) for _ in range(trials)]
            over = sum(q > 4 * jH for q in qs) / trials
            print(f"   {jH:3d}  {sched:5s}  {max(qs):10d}   {sum(qs) / trials:6.2f}   {over:10.4f}          ({4 * jH})")

    print("\n(d) Lemma 3's proof: 'stream i is served at least once in every ceil(1/w_i) queries, up to rounding,")
    print("    so a list stream reaches its first mistake within about j_i/w_i queries.' For weights that are not")
    print("    reciprocals of integers, 'once in every ceil(1/w_i)' gives j*ceil(1/w_i), not j/w_i + O(1).")
    print("    A proportional (largest-deficit) schedule for w = (0.4, 0.3, 0.3):")
    w = (0.4, 0.3, 0.3)
    cnt = [0, 0, 0]
    pos = [[], [], []]
    for t in range(1, 2001):
        deficit = [w[i] * t - cnt[i] for i in range(3)]
        i = max(range(3), key=lambda i: (deficit[i], -i))
        cnt[i] += 1
        pos[i].append(t)
    for i, name in enumerate("SUH"):
        excess = max(p - (j + 1) / w[i] for j, p in enumerate(pos[i]))
        gaps = max(b - a for a, b in zip([0] + pos[i], pos[i]))
        print(f"    stream {name}: w = {w[i]}, max over j of (position of j-th service - j/w) = "
              f"{max(p - (j + 1) / w[i] for j, p in enumerate(pos[i])) + 1 / w[i]:.2f}  "
              f"(<= 1/w = {1 / w[i]:.2f}); largest gap {gaps} vs ceil(1/w) = {math.ceil(1 / w[i])}")
    print("    -> here the gaps stay within ceil(1/w_i), but that premise only yields j*ceil(1/w_i) (3j for w = 0.4,")
    print("       not 2.5j), so the proof's inference does not follow. The conclusion is still true: a proportional")
    print("       schedule has bounded discrepancy, and the j-th service comes by position (j+1)/w_i (excess <= 1/w_i).")
    print("       For the default weights (1/2, 1/4, 1/4) the schedule S,U,S,H has gaps exactly 2, 4, 4 and no rounding.")


# --------------------------------------------------------------------------------------------
# Part 2. Asks at the final-answer slot only: the hit value b_alpha.
# --------------------------------------------------------------------------------------------
def part2a():
    hr("Part 2(a). Theorem 5(b) with final-answer asks only: a two-step product class")
    print("Problems p = 1..m. Step 0 writes a choice in {a, b}; step 1 writes the claimed solution 'claim'")
    print("(the final-answer slot). The human writes a; hypotheses write a or b at step 0 independently per")
    print("problem with prior Pr[a] = 0.4; all write 'claim' at step 1. V accepts iff step 0 is a (S_V is")
    print("preserved by appending; (A2), (A3') hold). Exact Bayes by enumeration over the 2^m hypotheses.")
    alpha = 0.1
    b_alpha = max(1.0, math.log2(1 / alpha))
    for m in (1, 4, 10):
        hyps = list(itertools.product("ab", repeat=m))
        prior = {h: math.prod(0.4 if c == "a" else 0.6 for c in h) for h in hyps}
        true = tuple("a" * m)
        K = math.log2(1 / prior[true])
        for mode in ("final-answer asks only", "asks at every step (SI-ABC)"):
            cons = set(hyps)
            rej = asks = 0
            min_bits = float("inf")
            for p in range(m):
                while True:
                    tot = sum(prior[h] for h in cons)
                    ma = sum(prior[h] for h in cons if h[p] == "a") / tot
                    top, mu = ("a", ma) if ma >= 1 - ma else ("b", 1 - ma)
                    # step 0
                    if mode.startswith("asks at every") and mu < 1 - alpha:
                        asks += 1
                        cons = {h for h in cons if h[p] == "a"}
                        lab0 = "a"
                    else:
                        lab0 = top
                    # step 1: every hypothesis writes 'claim'; top mass 1, no ask in either mode
                    if lab0 == "a":
                        break  # accepted
                    rej += 1
                    w0 = sum(prior[h] for h in cons)
                    w1 = sum(prior[h] for h in cons if h[p] == "a")
                    min_bits = min(min_bits, math.log2(w0 / w1))
                    cons = {h for h in cons if h[p] == "a"}
            print(f"  m = {m:2d}, {mode:28s}: K = {K:6.2f}, rejections = {rej:2d}, asks = {asks:2d}, "
                  f"K/b_alpha = {K / b_alpha:5.2f}, K/log2(1/(1-alpha)) = {K / math.log2(1 / (1 - alpha)):6.2f}, "
                  f"min hit value = {min_bits:.2f} bits vs b_alpha = {b_alpha:.2f}"
                  + ("   <-- VIOLATES 5(b)" if rej > K / b_alpha + 1e-9 else ""))
    print("  -> With asks restricted to the final-answer slot, a hit at a committed step elsewhere is worth only")
    print("     log2(1/0.4) = 1.32 bits, not log2(1/alpha) = 3.32. The count K/b_alpha of Theorem 5(b) and the")
    print("     K/b_alpha factors of 5(e) and 5(f) are false; K (one bit per hit, Lemma 1 of note.md) is right.")


# Referee 6's class (copied and reduced), with asks only at the claim-writing slot.
N0, SIGMA = 4, 3
N = N0 + SIGMA
MP = 4
WORDS = list(itertools.product([0, 1], repeat=N0))
P0, PJ_NONE = 0.9, 0.6
JS = [None] + list(range(N0))
HYPS = [(w, J) for w in WORDS for J in JS]


def prior_h(h):
    w, J = h
    pr = math.prod(P0 if c == 0 else 1 - P0 for c in w)
    return pr * (PJ_NONE if J is None else (1 - PJ_NONE) / (len(JS) - 1))


PRIOR = {h: prior_h(h) for h in HYPS}


def st(y, w):  # SUBSEQ human: bounded setback with D = 0
    i = 0
    for c in y:
        if i < len(w) and c == w[i]:
            i += 1
    return i


def hum(h, y):
    w, J = h
    s = st(y, w)
    if J is not None and s == J:
        return 2
    return 0 if s >= len(w) else w[s]


def masses(cons, y):
    tot = sum(PRIOR[h] for h in cons)
    ms = {}
    for h in cons:
        a = hum(h, y)
        ms[a] = ms.get(a, 0.0) + PRIOR[h]
    return {a: v / tot for a, v in ms.items()}


def claim_slot(cons, y, a_dec):
    """The final-answer slot: the decoder's label would complete the target word of some consistent
    hypothesis whose own label here is a_dec (it 'writes the claimed solution' here)."""
    for h in cons:
        if hum(h, y) == a_dec and st(y, h[0]) == N0 - 1:
            return True
    return False


def toy_path(seed, alpha, beta, sched, final_only):
    rng = random.Random(seed)
    true = {p: (tuple(1 if rng.random() > P0 else 0 for _ in range(N0)), None) for p in range(MP)}
    K = sum(math.log2(1 / PRIOR[true[p]]) for p in range(MP))
    b_alpha = max(1.0, math.log2(1 / alpha)) if alpha < 1 else 1.0
    cons = {p: set(HYPS) for p in range(MP)}
    data = {p: [] for p in range(MP)}
    S = dict(K=K, b=b_alpha, rej=0, audit_hits=0, asks=0, min_bits=float("inf"), low_hits=0,
             max_search=0, over2n0=0, early=0, searches=0)
    for t in range(30):
        p = rng.randrange(MP)
        P = true[p]
        for guard in range(200):
            y, labels, committed, asks_here = [], [], [], []
            for k in range(N):
                ms = masses(cons[p], y)
                a_dec = max(sorted(ms), key=lambda a: ms[a])
                mu = ms[a_dec]
                slot_ok = (not final_only) or claim_slot(cons[p], y, a_dec)
                if alpha < 1 and slot_ok and mu < 1 - alpha:
                    a = hum(P, y)
                    asks_here.append((k, tuple(y), a))
                    data[p].append((tuple(y), a))
                    cons[p] = {h for h in cons[p] if hum(h, y) == a}
                    S["asks"] += 1
                    labels.append(a)
                else:
                    committed.append(k)
                    labels.append(a_dec)
                    a = a_dec
                y = y + [a]
            nbs = [tuple(y[:k]) for k in range(N)]
            mist = [k for k in committed if labels[k] != hum(P, nbs[k])]

            def bits(k, ans):
                later = {(nb, a) for (kk, nb, a) in asks_here if kk >= k}
                base = {h for h in HYPS if all(hum(h, list(yy)) == aa for yy, aa in data[p] if (yy, aa) not in later)}
                w0 = sum(PRIOR[h] for h in base)
                w1 = sum(PRIOR[h] for h in base if hum(h, list(nbs[k])) == ans)
                return math.log2(w0 / w1)

            def record_hit(k):
                ans = hum(P, list(nbs[k]))
                b = bits(k, ans)
                S["min_bits"] = min(S["min_bits"], b)
                if b < b_alpha - 1e-9:
                    S["low_hits"] += 1
                data[p].append((nbs[k], ans))
                cons[p] = {h for h in cons[p] if hum(h, list(nbs[k])) == ans}

            if st(y, P[0]) >= N0:  # V = S exactly
                if committed and rng.random() < beta:
                    k = rng.choice(committed)
                    if k in mist:
                        S["audit_hits"] += 1
                        record_hit(k)
                    else:
                        ans = hum(P, list(nbs[k]))
                        data[p].append((nbs[k], ans))
                        cons[p] = {h for h in cons[p] if hum(h, list(nbs[k])) == ans}
                break
            S["rej"] += 1
            if not mist or min(mist) >= N0:
                S["early"] += 1
            # search: S over committed steps, U uniform committed, H = adversarial list of non-mistakes
            Hl = [k for k in committed if k not in mist]
            iS = iH = q = turn = 0
            hit = None
            queried = []
            while hit is None:
                if sched == "rand":
                    live = ["S", "U"] + (["H"] if iH < len(Hl) else [])
                    wts = {"S": 0.5, "U": 0.25, "H": 0.25}
                    r = rng.random() * sum(wts[s] for s in live)
                    for s in live:
                        r -= wts[s]
                        if r <= 0:
                            break
                else:
                    s = sched[turn % len(sched)]
                    turn += 1
                    if s == "H" and iH >= len(Hl):
                        continue
                if s == "S":
                    k = committed[iS]
                    iS += 1
                elif s == "U":
                    k = rng.choice(committed)
                else:
                    k = Hl[iH]
                    iH += 1
                q += 1
                queried.append(k)
                if k in mist:
                    hit = k
            S["searches"] += 1
            S["max_search"] = max(S["max_search"], q)
            if q > 2 * N0:
                S["over2n0"] += 1
            record_hit(hit)
            for k in queried:
                ans = hum(P, list(nbs[k]))
                data[p].append((nbs[k], ans))
                cons[p] = {h for h in cons[p] if hum(h, list(nbs[k])) == ans}
    return S


TOTAL_REJ = [0]


def part2b():
    hr("Part 2(b). Exact-Bayes toy VSI (referee 6's class, SUBSEQ humans, D = 0), default weights")
    print(f"n0 = {N0}, sigma = {SIGMA}, {MP} problems, 30 rounds per path, H = adversarial list, 100 paths per row.")
    print("Asks either at every step (SI-ABC) or only at the claim-writing slot (section 2.2's option).")
    print("Columns: worst over paths of (rejections + audit hits)/(K/b_alpha); share of hits worth < b_alpha;")
    print("smallest hit value / b_alpha; worst search length vs 2 n0; searches over 2 n0; rejected runs with")
    print("no committed mistake below n0 (Lemma 1).")
    print("  asks        alpha  sched  max (rej+audit)/(K/b)  low-value hits  min bits/b  max search  >2n0  L1-fail")
    for final_only in (False, True):
        for alpha in (0.5, 0.3, 0.15):
            for sched in ("SUSH", "rand"):
                worst = 0.0
                low = hits = 0
                minb = float("inf")
                maxs = over = early = 0
                rejs = 0
                for seed in range(100):
                    S = toy_path(seed, alpha, 1.0, sched, final_only)
                    worst = max(worst, (S["rej"] + S["audit_hits"]) / (S["K"] / S["b"]))
                    low += S["low_hits"]
                    hits += S["rej"] + S["audit_hits"]
                    minb = min(minb, S["min_bits"] / S["b"])
                    maxs = max(maxs, S["max_search"])
                    over += S["over2n0"]
                    early += S["early"]
                    rejs += S["rej"]
                TOTAL_REJ[0] += rejs
                tag = "final slot" if final_only else "every step"
                print(f"  {tag:10s}  {alpha:5.2f}  {sched:5s}  {worst:20.2f}  {low:5d}/{hits:<5d}   {minb:9.2f}  "
                      f"{maxs:9d}   {over:4d}  {early:5d}")
    print(f"  total rejected runs over all rows: {TOTAL_REJ[0]} (Lemma 1 checked on each)")
    print("  -> with asks at every step every hit is worth >= b_alpha. With asks at the claim slot only, 36-82%")
    print("     of hits are worth less than b_alpha (down to 0.37 b_alpha, i.e. about 1 bit), so the per-hit step")
    print("     of Theorem 5(b)'s proof fails; in this small class the total stays below K/b_alpha because K is")
    print("     loose here (Part 2(a) shows the total itself exceeding K/b_alpha).")
    print("     S,U,S,H never exceeds 2 n0 = 8 queries; the random schedule does (11).")


# --------------------------------------------------------------------------------------------
# Part 3. The "nothing bizarre" check without (M2).
# --------------------------------------------------------------------------------------------
def part3():
    hr("Part 3. Theorem 5(b)-(c) use (M1), (M2) for the 'nothing bizarre' check; without (M2) VSI loops")
    print("Class {P} (K = 0). P writes x0 -> 'u' -> 'v' -> 'z' -> ... ; V accepts (S_V holds). The bizarre check")
    print("flags any notebook containing 'z', which P itself writes at step 2: (M2) fails.")
    P = ["u", "v", "z", "w"]
    iters = 0
    queries = 0
    for it in range(1000):
        iters += 1
        run = list(P)  # the only hypothesis is P: the run is P's own chain
        flagged = [k for k in range(len(run) + 1) if "z" in run[:k]]
        if not flagged:
            break
        flip = flagged[0] - 1  # bisection finds the step that made the notebook fail
        queries += 1
        answer = P[flip]
        if answer != run[flip]:
            break  # a hit: would change the data
        # not a mistake: nothing changes; the protocol says 'rerun'
    print(f"  after {iters} reruns: {queries} task queries, no hit, no output, no abstention -> does not terminate.")
    print("  Fix: assume (M1), (M2) (as slack-imitation.md does for its check), or, as note.md Proposition 9")
    print("  does, output the verified artifact marked 'flagged where the human would be' when the flip query")
    print("  shows no mistake.")


# --------------------------------------------------------------------------------------------
# Part 4. Theorem 5(f).
# --------------------------------------------------------------------------------------------
def part4():
    hr("Part 4. Theorem 5(f) needs S* to be reached by the human's own chain (tau*), not only S_V")
    print("Class {P} (K = 0). V accepts P's chain (S_V holds, (A2), (A3') hold) but the chain fails S*:")
    print("(A4') fails on the human's own notebook. Every run is P's chain, has no mistake, and is output.")
    for T in (10, 100, 1000):
        print(f"  T = {T:5d}: failed outputs = {T:5d};  claimed bound K/(b_alpha beta gamma) = 0")
    print("  -> Lemma S must be applied to tau* (remaining time to S*): (f) needs S* preserved by appending,")
    print("     tau*(x0) <= n0, and (B_D) measured in tau*. None of these is assumed.")


# --------------------------------------------------------------------------------------------
# Part 5. Heavy tails.
# --------------------------------------------------------------------------------------------
def Phi(x):
    return 0.5 * (1 + math.erf(x / math.sqrt(2)))


def part5():
    hr("Part 5. Section 6: '(A2) for every problem ... with n0 at the 75th percentile, 6-11% are not finished'")
    print("Thread S Part E computes phi = Pr[tau > n] with n = 2 n0. With n0 at the q-quantile, (A2)")
    print("(tau <= n0) fails on 1 - q of problems; only those with tau > n make VSI abstain.")
    z = {0.5: 0.0, 0.75: 0.6744897501960817, 0.9: 1.2815515655446004}
    print("   q     law                Pr[tau > n0] (A2 fails)   Pr[n0 < tau <= 2n0]   Pr[tau > 2n0] (abstain)")
    for q in (0.75,):
        for s in (0.75, 1.0, 1.25):
            p2 = 1 - Phi(z[q] + math.log(2) / s)
            print(f"  {q:.2f}   lognormal s={s:4.2f}   {1 - q:10.3f}               {1 - q - p2:10.3f}           {p2:10.3f}")
        for a in (1.2, 1.5, 2.0):
            p2 = (1 - q) * 2 ** (-a)
            print(f"  {q:.2f}   Pareto a={a:3.1f}        {1 - q:10.3f}               {1 - q - p2:10.3f}           {p2:10.3f}")
    print("  -> the 6-11% are abstentions; (A2) itself fails on 25%. On the 14-19% with n0 < tau <= 2n0, Lemma 1")
    print("     fails (the first mistake may lie anywhere before n), so each of their rejections may cost up to")
    print("     2n = 4 n0 under S,U,S,H, not 2 n0, and Lemma S guarantees fewer mistakes.")


# --------------------------------------------------------------------------------------------
# Part 6. Effort.
# --------------------------------------------------------------------------------------------
def part6():
    hr("Part 6. Section 7 'worst-case effort': a factor 2 margin, before audits and abstentions")
    print("Budget: a fifth of chained imitation's guarantee at eps = 5%, 4 n0 K. VSI: 2 iota n0 K (search, default")
    print("weights) + beta T (audits; beta = 1 recommended with human verifiers) + c_V (T + K) (verifications,")
    print("c_V task steps each) + phi T 2n (abstentions, n = 2 iota n0). Largest T/K meeting the budget, n0 = 30:")
    n0 = 30
    print("  iota  c_V  beta |  phi=0    phi=0.05  phi=0.10")
    for iota in (1.0, 1.3, 1.6):
        for cV in (0.0, 0.1, 0.5):
            for beta in (0.0, 1.0):
                row = []
                for phi in (0.0, 0.05, 0.10):
                    # 2 iota n0 K + beta T + cV (T + K) + phi T (4 iota n0) <= 4 n0 K
                    num = 4 * n0 - 2 * iota * n0 - cV
                    den = beta + cV + phi * 4 * iota * n0
                    row.append("inf" if den == 0 and num > 0 else ("-" if num <= 0 else f"{num / den:7.1f}"))
                print(f"  {iota:4.1f}  {cV:3.1f}  {beta:4.1f} | " + "  ".join(f"{r:>8s}" for r in row))
    print("  -> under the conditioning (phi = 0) with a machine verifier (c_V = 0, beta = 0) there is no limit;")
    print("     with a human verifier and beta = 1 the bar holds only for T up to about 30-55 K; with heavy tails")
    print("     (phi = 5-10%, outside the conditioning) only up to about 2-8 K. The human-does-it baseline needs T > 2K.")


# --------------------------------------------------------------------------------------------
# Part 7. Proposition 7's guarantee with the retry rule.
# --------------------------------------------------------------------------------------------
def part7():
    hr("Part 7. Proposition 7: the 'other' runs are hit at rate c_r/(3n), c_r = min{(sigma+1)/(D+1), r}")
    print("  n     D   r   c = (sigma+1)/(D+1)   c_r   per-bit charge 3n/c_r   SI-ABC's charge n/c   chained n0")
    for n in (32, 64, 128):
        sigma = n // 2
        for D in (0, 2):
            for r in (2, 3):
                c = max(1, (sigma + 1) / (D + 1))
                cr = min(c, r)
                print(f"  {n:4d}  {D:2d}  {r:2d}   {c:12.1f}          {cr:4.1f}   {3 * n / cr:14.1f}        "
                      f"{n / c:10.2f}         {n - sigma:5d}")
    print("  -> with r = 2-3 the guarantee for 'other' failures is about n per bit, chained imitation's order,")
    print("     not (D+1)/rho. Thread F's F1 shows it: W-trusting failures with r = 3 grow as 77 -> 161 -> 315.")
    print("     The section 7 table's Theorem-H1 guarantee for the Proposition 7 row does not apply with c_r = r.")


if __name__ == "__main__":
    part1()
    part2a()
    part2b()
    part3()
    part4()
    part5()
    part6()
    part7()
