"""Referee 5: the steps of Proposition 5's proof, checked on the runs SI-V-ABC actually makes in E6.

one_human_verifier_abc of code/slack_imitation.py is replayed with the same seeds, and every
run built by run_abc is instrumented. For each human (100 problems) it checks:

  (i)    each committed step has top mass mu >= 1 - alpha under the data D u A_<k it used;
  (ii)   each ask has xi(P(x)) < 1 - alpha, so it pays more than log2(1/(1-alpha)) bits;
  (iii)  each committed mistake has xi(P(x)) <= alpha under D u A_<k;
  (iv)   the bits a round pays (run + search), log2 W(D_t)/W(D_t u A u answers), are at least
         [bits of A_<k] + log2(1/alpha) when the round ends with a hit at step k (the reordering
         in the proof: A_<k, then the hit, then the rest);
  (v)    per human: asks <= K / log2(1/(1-alpha)) and rejections <= K / log2(1/alpha), with
         K = sum_p log2(1/w(t_p, k_p));
  (vi)   setbacks at committed mistakes, with the visible-step remaining time of Remark 4
         (as in referee4_setback_e6.py): <= 0 for omissions, <= D for commissions; (T1) at asked
         steps; Lemma S on rejected runs, counting asked steps as correct;
  (vii)  which problems are rejected (k_p), the number of committed mistakes per rejected run,
         and the mean search length against n / |M|.

The replay is also compared with one_human_verifier_abc itself (queries, asks, rejections).
Usage: python3 referee5_abc_checks.py
"""

import os
import sys
import time
from collections import defaultdict
from math import log2
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402

NOTHING, SET1, SET2, INC = si.NOTHING, si.SET1, si.SET2, si.INC
INF = float("inf")
TINY = 1e-9


def human(kind, j, a, u, tp, kp):
    persistent, D = si.KINDS[kind]
    if a == 0:
        avail = (j >= tp) if persistent else (j == tp)
        return kp if avail else NOTHING
    if kp == a:
        return INC
    return kp if (j >= tp and u >= D) else INC


def step(a, u, c):
    if c == INC:
        return a, u + 1
    if c in (SET1, SET2):
        return c, 0
    return a, u


def tau(kind, a, u, j, tp, kp, n0, n):
    target = n0 - tp - 1
    for m in range(6 * n + 50):
        if a == kp and u >= target:
            return m
        a, u = step(a, u, human(kind, j, a, u, tp, kp))
        j += 1
    return INF


def run_abc_logged(pr, tp, kp, alpha, kind, st):
    """run_abc of slack_imitation.py, line for line, with the checks (i)-(iii) and a log."""
    asked = 0
    a, u = 0, 0
    run, codes, flags = [(0, 0)], [], []
    ask_bits = []          # (step, bits) of each ask, in order
    commit_xi = {}         # step -> (xi(P), W, mass of P) for committed mistakes
    for j in range(pr.n):
        idx = np.flatnonzero(pr.alive)
        t, k, w = pr.t[idx], pr.k[idx], pr.w[idx]
        out = pr.outputs(j, a, u, t, k)
        mass = np.array([w[out == c].sum() for c in range(4)])
        W = w.sum()
        tol = 1e-12 * W
        order = [INC, NOTHING, SET1, SET2] if a != 0 else [NOTHING, SET1, SET2, INC]
        best = order[0]
        for c in order[1:]:
            if mass[c] > mass[best] + tol:
                best = c
        hum = int(pr.outputs(j, a, u, np.array([tp]), np.array([kp]))[0])
        assert hum == human(kind, j, a, u, tp, kp)
        if abs(mass[best] - mass.max()) > 1e-9 * W:
            st["decoder's label not of largest mass"] += 1
        mu = mass[best] / W
        xi = mass[hum] / W
        if mass[best] < (1 - alpha) * W - tol:
            asked += 1
            b = log2(W / mass[hum])
            ask_bits.append((j, b))
            st["asks"] += 1
            if not xi < 1 - alpha + TINY:
                st["(ii) ask with xi(P) >= 1 - alpha"] += 1
            st["min ask bits / log2(1/(1-alpha))"] = min(
                st.get("min ask bits / log2(1/(1-alpha))", INF), b / log2(1 / (1 - alpha)))
            pr.alive[idx[out != hum]] = False
            best = hum
            flags.append(True)
        else:
            st["committed steps"] += 1
            if mu < 1 - alpha - TINY:
                st["(i) committed step with mu < 1 - alpha"] += 1
            if best != hum:
                commit_xi[j] = (xi, W, mass[hum])
                st["committed mistakes"] += 1
                if xi > alpha + TINY:
                    st["(iii) committed mistake with xi(P) > alpha"] += 1
                st["max xi(P) at a committed mistake / alpha"] = max(
                    st.get("max xi(P) at a committed mistake / alpha", 0.0), xi / alpha)
            flags.append(False)
        if best == INC:
            u += 1
        elif best in (SET1, SET2):
            a, u = best, 0
        run.append((a, u))
        codes.append(best)
    pr.run, pr.codes, pr.asked = run, codes, flags
    return asked, ask_bits, commit_xi


def check_run(pr, kind, tp, kp, n0, sigma, st, rej_rows):
    """(vi): setbacks at committed mistakes, (T1) at asked steps, Lemma S on failed runs."""
    persistent, D = si.KINDS[kind]
    n = pr.n
    taus = [tau(kind, a, u, j, tp, kp, n0, n) for j, (a, u) in enumerate(pr.run)]
    if taus[0] != n0:
        st["tau(x0) != n0"] += 1
    mistakes = 0
    for j in range(n):
        a, u = pr.run[j]
        h = human(kind, j, a, u, tp, kp)
        c = pr.codes[j]
        if pr.asked[j]:
            if c != h:
                st["asked step that is not the human's"] += 1
            if taus[j] != INF and taus[j] >= 1 and taus[j + 1] != taus[j] - 1:
                st["(T1) violated at an asked step"] += 1
            continue
        if c == h:
            continue
        mistakes += 1
        if a == kp and c in (SET1, SET2):
            st["overwrites of a correct value"] += 1
        omission = (c == NOTHING)
        if taus[j] == INF:
            st["committed mistakes at tau = inf"] += 1
            continue
        s = taus[j + 1] - taus[j]
        key = "omission" if omission else "commission"
        st[f"max setback at a committed {key}"] = max(st.get(f"max setback at a committed {key}", -INF), s)
        bound = 0 if omission else (INF if D >= si.INF else D)
        if s > bound:
            st[f"(B_D) violated at a committed {key}"] += 1
    ok = [(a == kp and u >= n0 - tp - 1) for (a, u) in pr.run]
    if any(ok) and not ok[-1]:
        st["runs that reach S and lose it"] += 1
    st["runs"] += 1
    if not ok[-1]:
        st["failed runs"] += 1
        if persistent and D < si.INF:
            need = max(1, (sigma + 1) / (D + 1))
            if mistakes < need:
                st["Lemma S violated (bounded-setback kinds)"] += 1
        if mistakes == 0:
            st["failed run with no committed mistake"] += 1
        rej_rows.append(mistakes)
    return mistakes


def one(args):
    kind, n, sigma, seed, alpha = args
    persistent, D = si.KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=si.M)
    kp = np.where(rng.random(si.M) < si.PI, 1, 2)
    rng2 = np.random.default_rng(seed + 3 * 10**8)
    st = defaultdict(int)
    queries = asked = rejected = 0
    K = 0.0
    rej_kp = defaultdict(int)
    search = []            # (length, committed mistakes) per rejection
    rej_rows = []
    for p in range(si.M):
        pr = si.Problem(n, n0, persistent, D)
        t_true, k_true = int(tp[p]), int(kp[p])
        w_true = pr.w[(pr.t == t_true) & (pr.k == k_true)][0]
        K_p = log2(1 / w_true)
        K += K_p
        W_problem_start = pr.w[pr.alive].sum()
        asks_p = rejections_p = 0
        while True:
            W_round_start = pr.w[pr.alive].sum()
            q, ask_bits, commit_xi = run_abc_logged(pr, t_true, k_true, alpha, kind, st)
            queries += q
            asked += q
            asks_p += q
            m = check_run(pr, kind, t_true, k_true, n0, sigma, st, rej_rows)
            if pr.success(t_true, k_true):
                break
            rejected += 1
            rejections_p += 1
            rej_kp[k_true] += 1
            held = []
            length = 0
            while True:
                j = int(rng2.integers(n))
                queries += 1
                length += 1
                a, u = pr.run[j]
                hum = pr.human_step(j, t_true, k_true)
                if hum != pr.decoder_step(j):
                    break
                held.append((j, a, u, hum))
            search.append((length, m))
            if pr.asked[j]:
                st["hit on an asked step"] += 1
            if j not in commit_xi:
                st["hit not at a logged committed mistake"] += 1
            else:
                xi, W, mP = commit_xi[j]
                b_hit = log2(1 / xi)
                if b_hit < log2(1 / alpha) - TINY:
                    st["(iv) hit worth < log2(1/alpha) bits"] += 1
            for (jj, aa, uu, hh) in [(j, a, u, hum)] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            W_round_end = pr.w[pr.alive].sum()
            round_bits = log2(W_round_start / W_round_end)
            lower = sum(b for (jj, b) in ask_bits if jj < j) + log2(1 / alpha)
            if round_bits < lower - 1e-9:
                st["(iv) round pays fewer bits than A_<k + log2(1/alpha)"] += 1
            st["min (round bits) / (bits of A_<k + log2(1/alpha))"] = min(
                st.get("min (round bits) / (bits of A_<k + log2(1/alpha))", INF), round_bits / lower)
        W_problem_end = pr.w[pr.alive].sum()
        bits_p = log2(W_problem_start / W_problem_end)
        if bits_p > K_p + 1e-9:
            st["problem pays more than K_p bits"] += 1
        if asks_p * log2(1 / (1 - alpha)) > bits_p + 1e-9:
            st["(a) per problem: asks * log2(1/(1-alpha)) > bits paid"] += 1
        if rejections_p * log2(1 / alpha) > bits_p + 1e-9:
            st["(c) per problem: rejections * log2(1/alpha) > bits paid"] += 1
    ref = si.one_human_verifier_abc(args)
    st["replay differs from one_human_verifier_abc"] += int(ref != (queries, asked, rejected))
    return dict(kind=kind, n=n, alpha=alpha, seed=seed, K=K, queries=queries, asked=asked,
                rejected=rejected, rej_kp=dict(rej_kp), search=search, st=dict(st))


def report(cells):
    for (kind, n, alpha), rows in cells.items():
        st = defaultdict(int)
        for r in rows:
            for k, v in r["st"].items():
                if k.startswith("min "):
                    st[k] = min(st.get(k, INF), v)
                elif k.startswith("max "):
                    st[k] = max(st.get(k, -INF), v)
                else:
                    st[k] += v
        K = np.array([r["K"] for r in rows])
        asked = np.array([r["asked"] for r in rows])
        rej = np.array([r["rejected"] for r in rows])
        ask_bound = K / log2(1 / (1 - alpha))
        rej_bound = K / log2(1 / alpha)
        rk = defaultdict(int)
        for r in rows:
            for k, v in r["rej_kp"].items():
                rk[k] += v
        srch = [s for r in rows for s in r["search"]]
        L = np.array([s[0] for s in srch], dtype=float)
        Mm = np.array([s[1] for s in srch], dtype=float)
        print(f"\n{kind} n={n} alpha={alpha}: {len(rows)} humans, K per human "
              f"{K.min():.0f}-{K.max():.0f}")
        print(f"  asks per human {asked.mean():.1f} (max {asked.max()}); bound K/log2(1/(1-a)) "
              f"min {ask_bound.min():.0f}; max ratio asks/bound {np.max(asked / ask_bound):.3f}")
        print(f"  rejections per human {rej.mean():.3f} (max {rej.max()}); bound K/log2(1/a) "
              f"min {rej_bound.min():.0f}; rejected problems by k_p: {dict(rk)}")
        if len(srch):
            print(f"  rejected runs: {len(srch)}; committed mistakes per rejected run: mean "
                  f"{Mm.mean():.2f}, min {Mm.min():.0f}, max {Mm.max():.0f}; mean search length "
                  f"{L.mean():.1f} vs mean n/|M| {np.mean(n / Mm):.1f}")
        keys = sorted(st)
        print("  " + "; ".join(f"{k} {st[k]:.4g}" if isinstance(st[k], float) else f"{k} {st[k]}"
                              for k in keys))


def main():
    t0 = time.time()
    plan = []
    for alpha in (0.1, 0.3):
        for n, H in ((16, 40), (32, 40), (64, 20)):
            for kind in si.KINDS:
                plan += [(kind, n, n // 2, 1000 * n + s, alpha) for s in range(H)]
    with Pool(4) as pool:
        res = pool.map(one, plan, chunksize=4)
    cells = defaultdict(list)
    for r in res:
        cells[(r["kind"], r["n"], r["alpha"])].append(r)
    report(cells)
    print(f"\n[{time.time() - t0:.0f} s]")


if __name__ == "__main__":
    main()
