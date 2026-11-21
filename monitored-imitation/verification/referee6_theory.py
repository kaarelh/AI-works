"""Referee 6: exact-Bayes toy checks of Theorem 5 and Theorem 6 of verified-slack.md.

The class (small enough for exact posteriors).
* Problems p = 0..m-1.  A notebook is (p, string over {0,1,2}).  Each step appends one symbol.
* A hypothesis for problem p is (w, J): w in {0,1}^n0 is the problem's target word, and
  J in {none, 0, ..., n0-1} is a "junk state".  The human's state at notebook y is
  st(y) = progress of y towards w:
    - SUBSEQ humans: the length of the longest prefix of w that is a subsequence of y
      (a wrong symbol is ignored: setback 0, i.e. (B_D) with D = 0);
    - SUBSTR humans: the KMP state, the longest suffix of y that is a prefix of w
      (a wrong symbol can reset progress: setback up to n0, unbounded relative to slack).
  P_(w,J)(y) = 2 if st(y) == J, else w[st(y)] (or 0 once w is complete).
  The true human has J = none, so it never writes 2: symbol 2 is the "invalid entry" that a
  local check L flags, and (L1) holds.  Junk hypotheses make the decoder sometimes write 2.
* Success S(y): y contains w (as a subsequence / as a substring).  S is preserved by
  appending and tau(x0) = n0 exactly, so (A2) holds.  V = S exactly, so (A3), (A4) hold,
  except in the unsound-verifier run (Theorem 5(e)).
* Prior: w_i i.i.d. with Pr[0] = 0.75; J = none w.p. 0.6, else uniform; independent across
  problems.  So the posterior factorizes over problems and W, Phi are exact.

Protocol VSI(alpha, beta): asks, verification, route (i) on invalid entries (if L used),
search with streams U (uniform committed, with replacement), S (scan of committed steps from
step 0) and H (a list fixed at the start; three variants: adversarial = all committed
non-mistakes first; good = a mistake first; empty).

Checks (pathwise unless stated):
 L1   every rejected run has a committed mistake below n0;
 B1   every hit (search, route (i) and audits) lowers Phi by >= b_alpha when the round's data
      are listed as: asks before the hit's step, the hit, the rest;
 B2   #rejections + #audit hits <= K / b_alpha and #asks <= K / log2(1/(1-alpha)) on every path;
 C1   every search takes <= 3 n0 queries (<= 2 n0 with H empty);
 C2   mean over searches of (queries) <= mean of 3 min{n/|M|, j_S, j_H} (expectation check);
 E1   with an unsound verifier: mean #failed outputs <= K/(b_alpha beta gamma), gamma = 1/n.
Theorem 6: an imitated verifier on a product class; mean false acceptances vs (1-beta)K_V/beta.
"""
import itertools
import math
import random
import sys

N0 = 4
SIGMA = 3
N = N0 + SIGMA
M_PROBLEMS = 4
WORDS = list(itertools.product([0, 1], repeat=N0))
CONFIGS = {
    # A: confident commitments (P0 = 0.9), junk rarely written: exercises b_alpha > 1.
    "A": dict(P0=0.9, PJ_NONE=0.6, JS=[None] + list(range(N0))),
    # B: junk written early (J in {0, 1}, Pr[none] = 0.1): exercises route (i).
    "B": dict(P0=0.75, PJ_NONE=0.1, JS=[None, 0, 1]),
}
P0 = PJ_NONE = JS = HYPS = PRIOR = None


def set_config(name):
    global P0, PJ_NONE, JS, HYPS, PRIOR
    c = CONFIGS[name]
    P0, PJ_NONE, JS = c["P0"], c["PJ_NONE"], c["JS"]
    HYPS = [(w, J) for w in WORDS for J in JS]
    PRIOR = {h: prior_w(h[0]) * prior_J(h[1]) for h in HYPS}


def prior_w(w):
    pr = 1.0
    for c in w:
        pr *= P0 if c == 0 else 1 - P0
    return pr


def prior_J(J):
    return PJ_NONE if J is None else (1 - PJ_NONE) / (len(JS) - 1)


def state(y, w, kind):
    if kind == "SUBSEQ":
        i = 0
        for c in y:
            if i < len(w) and c == w[i]:
                i += 1
        return i
    # SUBSTR: longest suffix of y that is a prefix of w, but once w occurs, report len(w)
    best = 0
    s = tuple(y)
    for L in range(len(w), 0, -1):
        for start in range(0, len(s) - L + 1):
            if s[start:start + L] == w[:L] and L == len(w):
                return len(w)
    for L in range(min(len(w) - 1, len(s)), 0, -1):
        if s[len(s) - L:] == w[:L]:
            best = L
            break
    return best


def human(h, y, kind):
    w, J = h
    st = state(y, w, kind)
    if J is not None and st == J:
        return 2
    if st >= len(w):
        return 0
    return w[st]


def success(y, w, kind):
    return state(y, w, kind) >= len(w)


class Learner:
    """Exact Bayes over HYPS for each problem; data are (problem, notebook) -> label."""

    def __init__(self, kind):
        self.kind = kind
        self.data = {p: {} for p in range(M_PROBLEMS)}
        self.cons = {p: set(HYPS) for p in range(M_PROBLEMS)}

    def W(self, p, extra=()):
        cons = self.cons[p]
        if extra:
            cons = {h for h in cons if all(human(h, y, self.kind) == a for (y, a) in extra)}
        return sum(PRIOR[h] for h in cons)

    def label_masses(self, p, y, extra=()):
        cons = self.cons[p]
        if extra:
            cons = {h for h in cons if all(human(h, y2, self.kind) == a for (y2, a) in extra)}
        tot = sum(PRIOR[h] for h in cons)
        masses = {}
        for h in cons:
            a = human(h, y, self.kind)
            masses[a] = masses.get(a, 0.0) + PRIOR[h]
        return {a: v / tot for a, v in masses.items()}

    def decode(self, p, y):
        ms = self.label_masses(p, y)
        # ties: smallest label (fixed order)
        best = max(sorted(ms), key=lambda a: ms[a])
        return best, ms[best]

    def add(self, p, y, a):
        self.data[p][tuple(y)] = a
        self.cons[p] = {h for h in self.cons[p] if human(h, y, self.kind) == a}


def phi(learner, true_h):
    return sum(math.log2(learner.W(p) / PRIOR[true_h[p]]) for p in range(M_PROBLEMS))


def run_path(seed, kind, alpha, beta, use_L, hmode, verifier="exact", n_rounds=30):
    rng = random.Random(seed)
    # true human: J = none for every problem
    true_h = {}
    for p in range(M_PROBLEMS):
        w = tuple(1 if rng.random() > P0 else 0 for _ in range(N0))
        true_h[p] = (w, None)
    K = sum(math.log2(1 / PRIOR[true_h[p]]) for p in range(M_PROBLEMS))
    b_alpha = max(1.0, math.log2(1 / alpha)) if alpha < 1 else 1.0
    ask_bits = math.log2(1 / (1 - alpha)) if alpha < 1 else float("inf")
    L = Learner(kind)
    stats = dict(K=K, asks=0, rejections=0, audit_hits=0, hits_bad_bits=0, early_fail=0,
                 search_over=0, searches=0, q_sum=0.0, bound_sum=0.0, route_i=0,
                 failed_outputs=0, outputs=0, loops=0, minbits=float("inf"))

    for t in range(n_rounds):
        p = rng.randrange(M_PROBLEMS)
        P = true_h[p]
        guard = 0
        while True:
            guard += 1
            if guard > 200:
                stats["loops"] += 1
                break
            # 1. run
            y = []
            asks = []  # (step, notebook, answer), added at once
            committed = []
            labels = []
            for k in range(N):
                a_dec, mu = L.decode(p, y)
                if alpha < 1 and mu < 1 - alpha:
                    a = human(P, y, kind)
                    asks.append((k, tuple(y), a))
                    L.add(p, y, a)
                    stats["asks"] += 1
                    labels.append(a)
                    y = y + [a]
                else:
                    committed.append(k)
                    labels.append(a_dec)
                    y = y + [a_dec]
            notebooks = [tuple(y[:k]) for k in range(N)]
            mistakes = [k for k in committed if labels[k] != human(P, notebooks[k], kind)]
            ok_true = success(y, P[0], kind)
            if verifier == "exact":
                accept = ok_true
            else:  # unsound: also accepts if y contains w with its last symbol flipped
                w2 = P[0][:-1] + (1 - P[0][-1],)
                accept = ok_true or success(y, w2, kind)

            def hit_bits(k, ans):
                # Phi drop of the hit, listing asks before step k first (they are already in
                # L, so remove those at steps >= k and recompute W).
                later = [(nb, a) for (kk, nb, a) in asks if kk >= k]
                later_set = set(later)
                base = {h for h in HYPS if all(human(h, list(yy), kind) == aa
                                               for yy, aa in L.data[p].items()
                                               if (yy, aa) not in later_set)}
                w0 = sum(PRIOR[h] for h in base)
                w1 = sum(PRIOR[h] for h in base if human(h, list(notebooks[k]), kind) == ans)
                return math.log2(w0 / w1)

            if accept:
                stats["outputs"] += 1
                if not ok_true:
                    stats["failed_outputs"] += 1
                if committed and rng.random() < beta:
                    k = rng.choice(committed)
                    ans = human(P, list(notebooks[k]), kind)
                    if k in mistakes:
                        bits = hit_bits(k, ans)
                        stats["minbits"] = min(stats["minbits"], bits)
                        if bits < b_alpha - 1e-9:
                            stats["hits_bad_bits"] += 1
                        stats["audit_hits"] += 1
                    L.add(p, list(notebooks[k]), ans)
                break
            # 4. rejected
            stats["rejections"] += 1
            if not mistakes or min(mistakes) >= N0:
                stats["early_fail"] += 1
            if not mistakes:
                stats["loops"] += 1
                break
            invalid = [k for k in committed if labels[k] == 2]
            if use_L and invalid:
                k = invalid[0]
                ans = human(P, list(notebooks[k]), kind)
                assert k in mistakes, "Lemma 2 violated"
                bits = hit_bits(k, ans)
                stats["minbits"] = min(stats["minbits"], bits)
                if bits < b_alpha - 1e-9:
                    stats["hits_bad_bits"] += 1
                stats["route_i"] += 1
                L.add(p, list(notebooks[k]), ans)
                continue
            # search
            if hmode == "adversarial":
                Hlist = [k for k in committed if k not in mistakes] + sorted(mistakes, reverse=True)
            elif hmode == "good":
                Hlist = [rng.choice(mistakes)] + [k for k in committed]
            else:
                Hlist = []
            Slist = list(committed)
            streams = ["U", "S", "H"] if Hlist else ["U", "S"]
            iS = iH = 0
            queried = []
            hit = None
            qcount = 0
            si = 0
            while hit is None:
                s = streams[si % len(streams)]
                si += 1
                if s == "U":
                    k = rng.choice(committed)
                elif s == "S":
                    k = Slist[iS]
                    iS += 1
                else:
                    if iH >= len(Hlist):
                        continue
                    k = Hlist[iH]
                    iH += 1
                qcount += 1
                queried.append(k)
                if k in mistakes:
                    hit = k
            # bound 3 min{n/|M|, j_S, j_H}
            jS = 1 + [i for i, k in enumerate(Slist) if k in mistakes][0]
            jH = (1 + [i for i, k in enumerate(Hlist) if k in mistakes][0]) if Hlist else float("inf")
            r = len(streams)
            bound = r * min(len(committed) / len(mistakes), jS, jH)
            stats["q_sum"] += qcount
            stats["bound_sum"] += bound
            stats["searches"] += 1
            if qcount > r * N0:
                stats["search_over"] += 1
            ans = human(P, list(notebooks[hit]), kind)
            bits = hit_bits(hit, ans)
            stats["minbits"] = min(stats["minbits"], bits)
            if bits < b_alpha - 1e-9:
                stats["hits_bad_bits"] += 1
            L.add(p, list(notebooks[hit]), ans)
            for k in queried:
                L.add(p, list(notebooks[k]), human(P, list(notebooks[k]), kind))
    return stats


def main():
    for cfg in ["A", "B"]:
        set_config(cfg)
        print(f"Config {cfg}: {CONFIGS[cfg]}")
        print(f"Toy class: n0 = {N0}, sigma = {SIGMA}, n = {N}, m = {M_PROBLEMS} problems, "
              f"{len(HYPS)} hypotheses per problem; 30 problem instances per path.")
        table()
    set_config("A")
    tail()


def table():
    print()
    hdr = (f"{'kind':7s} {'alpha':>5s} {'L':>2s} {'H':>11s} {'paths':>5s} | {'L1 viol':>7s} "
           f"{'B1 viol':>7s} {'minbits/b':>9s} | {'max (rej+audit)/(K/b)':>21s} {'max asks/(K/c)':>14s} | "
           f"{'C1 viol':>7s} {'mean q':>7s} {'mean bnd':>8s} | {'route(i)':>8s}")
    print(hdr)
    print("-" * len(hdr))
    for kind in ["SUBSEQ", "SUBSTR"]:
        for alpha in [1.0, 0.5, 0.3, 0.15]:
            for use_L in [False, True]:
                for hmode in ["adversarial", "good", "empty"]:
                    if use_L and hmode != "adversarial":
                        continue
                    agg = dict(L1=0, B1=0, C1=0, q=0.0, b=0.0, ri=0, maxr=0.0, maxa=0.0,
                               minb=float("inf"), loops=0)
                    paths = 25
                    for seed in range(paths):
                        st = run_path(1000 * seed + 7, kind, alpha, 0.3, use_L, hmode)
                        b_alpha = max(1.0, math.log2(1 / alpha)) if alpha < 1 else 1.0
                        agg["L1"] += st["early_fail"]
                        agg["B1"] += st["hits_bad_bits"]
                        agg["C1"] += st["search_over"]
                        agg["q"] += st["q_sum"]
                        agg["b"] += st["bound_sum"]
                        agg["ri"] += st["route_i"]
                        agg["loops"] += st["loops"]
                        agg["minb"] = min(agg["minb"], st["minbits"] / b_alpha)
                        agg["maxr"] = max(agg["maxr"], (st["rejections"] + st["audit_hits"]) / (st["K"] / b_alpha))
                        if alpha < 1:
                            agg["maxa"] = max(agg["maxa"], st["asks"] / (st["K"] / math.log2(1 / (1 - alpha))))
                    nsearch = max(1, 1)
                    print(f"{kind:7s} {alpha:5.2f} {('y' if use_L else 'n'):>2s} {hmode:>11s} {paths:5d} | "
                          f"{agg['L1']:7d} {agg['B1']:7d} {agg['minb']:9.3f} | {agg['maxr']:21.3f} "
                          f"{agg['maxa']:14.3f} | {agg['C1']:7d} {agg['q']:7.0f} {agg['b']:8.0f} | {agg['ri']:8d}"
                          + (f"  LOOPS {agg['loops']}" if agg['loops'] else ""))
    print()
    print("Columns: L1 viol = rejected runs with no committed mistake below n0 (Lemma 1);")
    print("B1 viol = hits worth < b_alpha bits in the reordered listing; minbits/b = smallest")
    print("hit value divided by b_alpha (>= 1 required); max (rej+audit)/(K/b) and max asks/(K/c)")
    print("over paths (<= 1 required, Theorem 5(b)); C1 viol = searches longer than r n0;")
    print("mean q / mean bnd = summed search queries and summed 3 min{n/|M|, j_S, j_H} (r = 2 if")
    print("H empty); route(i) = rejections settled by an invalid entry in one query.")
    print()


def tail():
    # Theorem 5(e): unsound verifier
    print()
    print("Theorem 5(e), config A, unsound verifier (accepts the target word with its last symbol flipped):")
    for kind in ["SUBSEQ", "SUBSTR"]:
        for beta in [0.2, 0.5, 1.0]:
            fo = []
            bnd = []
            for seed in range(40):
                st = run_path(77 + seed, kind, 1.0, beta, False, "adversarial", verifier="unsound")
                fo.append(st["failed_outputs"])
                bnd.append(st["K"] / (1.0 * beta * (1.0 / N)))
            print(f"  {kind:7s} beta = {beta:3.1f}: mean failed outputs {sum(fo)/len(fo):6.2f}; "
                  f"mean bound K/(b beta gamma) with gamma = 1/n: {sum(bnd)/len(bnd):8.1f}")

    # Theorem 6: imitated verifier on a product class
    print()
    print("Theorem 6, imitated verifier: 30 notebook types, V_H(y) = 1 w.p. 0.8 under the prior;")
    print("an adversary shows the types V_H rejects, round robin, T = 400 notebooks.")
    rng = random.Random(5)
    for beta in [0.05, 0.2, 0.5]:
        fa_list = []
        kv_list = []
        ver_list = []
        for rep in range(200):
            VH = [1 if rng.random() < 0.8 else 0 for _ in range(30)]
            KV = sum(math.log2(1 / (0.8 if v else 0.2)) for v in VH)
            known = {}
            bad = [i for i in range(30) if VH[i] == 0] or [0]
            fa = 0
            verif = 0
            for t in range(400):
                y = bad[t % len(bad)]
                vprime = known.get(y, 1)  # majority decoder: 0.8 > 0.2 for unseen types
                if vprime == 0:
                    verif += 1
                    known[y] = VH[y]
                else:
                    if rng.random() < beta:
                        verif += 1
                        known[y] = VH[y]
                    elif VH[y] == 0:
                        fa += 1
            fa_list.append(fa)
            kv_list.append(KV)
            ver_list.append(verif)
        mfa = sum(fa_list) / len(fa_list)
        mkv = sum(kv_list) / len(kv_list)
        print(f"  beta = {beta:4.2f}: mean unasked false acceptances {mfa:7.2f}; mean (1-beta) K_V/beta "
              f"{(1-beta)*mkv/beta:8.1f}; mean verifications {sum(ver_list)/len(ver_list):6.1f} "
              f"(beta T + R + K_V ~ {beta*400:.0f} + R + {mkv:.0f}, R = all 400 here)")


if __name__ == "__main__":
    main()
