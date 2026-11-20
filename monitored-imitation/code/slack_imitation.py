"""E6: slack imitation on four kinds of human (exact Bayes, small class).

The class (PROJECT). There are m problems. Problem p has an idea of value k_p in {1, 2}:
1 is "the obvious idea" (probability PI), 2 is a problem-specific one. The idea becomes available
to the human at a step t_p, uniform on {0, ..., n0 - 1}, where n0 = n - sigma is the human's
own horizon and sigma the slack. A draft is (a, u): the value the notebook currently builds on
(0 = none) and the number u of units of dependent work built on it. One step of the human, at
the draft (a, u) at step j:

  a = 0          writes k_p if the idea is available (j >= t_p; a *silent* human only at
                 j = t_p), else nothing;
  a = k_p        adds one unit of work, u + 1;
  a = other      (a value the human would not have written) builds on it, u + 1, unless the
                 idea is available and u >= D, in which case it writes the correction k_p and
                 restarts the dependent work (u = 0). D = 0: notices at once; D = inf: never
                 (fooled).

The human's own run writes k_p at step t_p and has n0 - t_p - 1 units at step n0. A run of
n = n0 + sigma steps *succeeds* if its final draft builds on k_p with at least that many units.

Every hypothesis knows the human's kind; the unknowns are (t_p, k_p), with the prior above.
The imitator is the majority decoder of the exact posterior (ties continue the current notebook,
then go to "write nothing", then to the value 1). One task query per round: a uniformly
random problem, a step chosen by the protocol, and the human's answer at the decoder's draft
there. We stop the first time the fraction of failing problems is at most EPS (an oracle
stopping rule that measures cost) or at a cap.

Bounded setback (slack-imitation.md): the human's remaining time to success rises by at most D
when a wrong value is appended, and by 0 when a step is left out, for the persistent kinds.
The silent and fooled kinds have unbounded setback.

Usage: python3 slack_imitation.py OUTDIR [--quick] [--mix] [--table] [--verifier] [--abc] [--same]
  default: CI without slack, CI with slack n/2 (slack imitation) and LAST with slack n/2;
  --mix:   MIX (last step with probability 1/2, else uniform) with slack n/2;
  --table: write results/slack_imitation_table.md from the saved summaries;
  --verifier: Protocol SI-V of Proposition 4 (rerun each problem until it succeeds), slack n/2;
  --abc:   SI-V with ask-before-committing at alpha = 0.1 and 0.3 (Proposition 5), slack n/2;
  --same:  chained imitation without slack on the same humans as the slack cells (n = n0 = n/2).
"""

import json
import os
import sys
import time
from multiprocessing import Pool

import numpy as np

EPS = 0.02
PI = 0.9
M = 100
INF = 10**9

NOTHING, SET1, SET2, INC = 0, 1, 2, 3

KINDS = {
    "noticing": (True, 0),
    "misled-2": (True, 2),
    "misled-8": (True, 8),
    "fooled": (True, INF),
    "silent": (False, INF),
}


class Problem:
    """Exact posterior for one problem: hypotheses (t, k), t in [0, n0), k in {1, 2}."""

    def __init__(self, n, n0, persistent, D):
        self.n, self.n0, self.persistent, self.D = n, n0, persistent, D
        self.t = np.concatenate([np.arange(n0), np.arange(n0)])
        self.k = np.concatenate([np.ones(n0, dtype=int), 2 * np.ones(n0, dtype=int)])
        self.w = np.concatenate([np.full(n0, PI / n0), np.full(n0, (1 - PI) / n0)])
        self.alive = np.ones(2 * n0, dtype=bool)
        self.recompute()

    def outputs(self, j, a, u, t, k):
        """Output code of humans (t, k) (arrays) at the draft (a, u) at step j."""
        if a == 0:
            avail = (j >= t) if self.persistent else (j == t)
            return np.where(avail, k, NOTHING)
        correct = (k != a) & (j >= t) & (u >= self.D)
        return np.where(k == a, INC, np.where(correct, k, INC))

    def recompute(self):
        n = self.n
        t, k, w = self.t[self.alive], self.k[self.alive], self.w[self.alive]
        tol = 1e-12 * w.sum()
        a, u = 0, 0
        run, codes = [(0, 0)], []
        for j in range(n):
            out = self.outputs(j, a, u, t, k)
            mass = np.array([w[out == c].sum() for c in range(4)])
            # ties: continue the current notebook (INC if a != 0, NOTHING if a == 0), then NOTHING, then 1
            order = [INC, NOTHING, SET1, SET2] if a != 0 else [NOTHING, SET1, SET2, INC]
            best = order[0]
            for c in order[1:]:
                if mass[c] > mass[best] + tol:
                    best = c
            if best == INC:
                u += 1
            elif best in (SET1, SET2):
                a, u = best, 0
            run.append((a, u))
            codes.append(best)
        self.run, self.codes = run, codes

    def human_step(self, j, tp, kp):
        a, u = self.run[j]
        return int(self.outputs(j, a, u, np.array([tp]), np.array([kp]))[0])

    def decoder_step(self, j):
        return self.codes[j]

    def query(self, j, tp, kp):
        """Task query at the decoder's draft at step j. Returns True on a mistake."""
        a, u = self.run[j]
        hum = self.human_step(j, tp, kp)
        mistake = hum != self.decoder_step(j)
        idx = np.flatnonzero(self.alive)
        out = self.outputs(j, a, u, self.t[idx], self.k[idx])
        kill = idx[out != hum]
        if len(kill):
            self.alive[kill] = False
            self.recompute()
        return mistake

    def success(self, tp, kp):
        a, u = self.run[-1]
        return a == kp and u >= self.n0 - tp - 1


def pick_step(proto, n, rng):
    if proto == "CI":
        return int(rng.integers(n))
    if proto == "LAST":
        return n - 1
    if proto == "MIX":
        return n - 1 if rng.random() < 0.5 else int(rng.integers(n))
    raise ValueError(proto)


def one_human(args):
    kind, n, sigma, proto, seed, cap = args
    persistent, D = KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    probs = [Problem(n, n0, persistent, D) for _ in range(M)]
    ok = np.array([probs[p].success(tp[p], kp[p]) for p in range(M)])
    rng2 = np.random.default_rng(seed + 10**8)
    hits = 0
    for r in range(cap + 1):
        if (M - ok.sum()) / M <= EPS:
            return r, float((M - ok.sum()) / M), hits
        if r == cap:
            break
        p = int(rng2.integers(M))
        j = pick_step(proto, n, rng2)
        hits += probs[p].query(j, tp[p], kp[p])
        ok[p] = probs[p].success(tp[p], kp[p])
    return cap, float((M - ok.sum()) / M), hits


def one_human_verifier(args):
    """Protocol SI-V (Proposition 4): each problem is rerun until its final notebook succeeds;
    after each rejection, uniform task queries on the fixed run until one lands on a mistake.
    Returns (task queries, rejected runs, maximum queries spent on one rejected run)."""
    kind, n, sigma, seed = args
    persistent, D = KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    rng2 = np.random.default_rng(seed + 2 * 10**8)
    queries = rejected = worst = 0
    for p in range(M):
        pr = Problem(n, n0, persistent, D)
        while not pr.success(tp[p], kp[p]):
            rejected += 1
            held, spent = [], 0
            while True:
                j = int(rng2.integers(n))
                spent += 1
                a, u = pr.run[j]
                hum = pr.human_step(j, tp[p], kp[p])
                if hum != pr.decoder_step(j):
                    break
                held.append((j, a, u, hum))
            queries += spent
            worst = max(worst, spent)
            # the hit's answer first, then the held answers (all at states of the fixed run)
            for (jj, aa, uu, hh) in [(j, a, u, hum)] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            pr.recompute()
    return queries, rejected, worst


def run_abc(pr, tp, kp, alpha):
    """Ask before committing (thread E's SI-ABC): build the run step by step; wherever the top
    output's posterior mass is below 1 - alpha, ask the human for that step, add the answer to
    the data at once, and append the human's step. Returns the number of such queries; the run
    is stored in pr.run / pr.codes, and pr.asked marks the asked steps."""
    asked = 0
    a, u = 0, 0
    run, codes, flags = [(0, 0)], [], []
    for j in range(pr.n):
        idx = np.flatnonzero(pr.alive)
        t, k, w = pr.t[idx], pr.k[idx], pr.w[idx]
        out = pr.outputs(j, a, u, t, k)
        mass = np.array([w[out == c].sum() for c in range(4)])
        tol = 1e-12 * w.sum()
        order = [INC, NOTHING, SET1, SET2] if a != 0 else [NOTHING, SET1, SET2, INC]
        best = order[0]
        for c in order[1:]:
            if mass[c] > mass[best] + tol:
                best = c
        if mass[best] < (1 - alpha) * w.sum() - tol:
            hum = int(pr.outputs(j, a, u, np.array([tp]), np.array([kp]))[0])
            pr.alive[idx[out != hum]] = False
            best = hum
            asked += 1
            flags.append(True)
        else:
            flags.append(False)
        if best == INC:
            u += 1
        elif best in (SET1, SET2):
            a, u = best, 0
        run.append((a, u))
        codes.append(best)
    pr.run, pr.codes, pr.asked = run, codes, flags
    return asked


def one_human_verifier_abc(args):
    """Protocol SI-V with ask-before-committing: as one_human_verifier, but every run is built
    by run_abc. Returns (all task queries, of which asked during runs, rejected runs)."""
    kind, n, sigma, seed, alpha = args
    persistent, D = KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    rng2 = np.random.default_rng(seed + 3 * 10**8)
    queries = asked = rejected = 0
    for p in range(M):
        pr = Problem(n, n0, persistent, D)
        q = run_abc(pr, tp[p], kp[p], alpha)
        queries += q
        asked += q
        while not pr.success(tp[p], kp[p]):
            rejected += 1
            held = []
            while True:
                j = int(rng2.integers(n))
                queries += 1
                a, u = pr.run[j]
                hum = pr.human_step(j, tp[p], kp[p])
                if hum != pr.decoder_step(j):
                    break
                held.append((j, a, u, hum))
            for (jj, aa, uu, hh) in [(j, a, u, hum)] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            q = run_abc(pr, tp[p], kp[p], alpha)
            queries += q
            asked += q
    return queries, asked, rejected


def summarise(rows):
    q = np.array([r[0] for r in rows], dtype=float)
    f = np.array([r[1] for r in rows], dtype=float)
    h = np.array([r[2] for r in rows], dtype=float)
    return {
        "humans": len(rows),
        "reached": int((f <= EPS).sum()),
        "task_mean": float(q.mean()),
        "task_sem": float(q.std(ddof=1) / np.sqrt(len(q))) if len(q) > 1 else 0.0,
        "task_median": float(np.median(q)),
        "final_failure_mean": float(f.mean()),
        "mistake_hits_mean": float(h.mean()),
    }


def main(outdir, quick=False, mix=False):
    os.makedirs(outdir, exist_ok=True)
    H = 8 if quick else 40
    ns = [16, 64] if quick else [16, 64, 256]
    configs = (lambda n: [(n // 2, "MIX")]) if mix else (
        lambda n: [(0, "CI"), (n // 2, "CI"), (n // 2, "LAST")])
    cells = []
    for n in ns:
        for kind in KINDS:
            for sigma, proto in configs(n):
                cells.append((kind, n, sigma, proto))
    out = {}
    t0 = time.time()
    with Pool(4) as pool:
        for kind, n, sigma, proto in cells:
            cap = 400 * M if proto == "LAST" else 40 * M * n
            args = [(kind, n, sigma, proto, 1000 * n + s, cap) for s in range(H)]
            rows = pool.map(one_human, args)
            key = f"{kind}_n{n}_sigma{sigma}_{proto}"
            out[key] = dict(kind=kind, n=n, sigma=sigma, protocol=proto, **summarise(rows))
            print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
            sys.stdout.flush()
    name = "slack_imitation_quick.json" if quick else (
        "slack_imitation_mix.json" if mix else "slack_imitation_summary.json")
    with open(os.path.join(outdir, name), "w") as f:
        json.dump(out, f, indent=1)


def table(outdir):
    """The markdown tables quoted in slack-imitation.md, from the saved summaries."""
    d = {}
    for name in ["slack_imitation_summary.json", "slack_imitation_mix.json",
                 "slack_imitation_same.json", "slack_imitation_verifier.json",
                 "slack_imitation_verifier_abc.json"]:
        path = os.path.join(outdir, name)
        if os.path.exists(path):
            with open(path) as f:
                d.update(json.load(f))

    def cell(e):
        if e is None:
            return "–"
        if e.get("reached", e["humans"]) < e["humans"]:
            return f"stalls at {100 * e['final_failure_mean']:.0f}%"
        return f"{e['task_mean']:,.0f} ± {e['task_sem']:,.0f}"

    rows = [("CI, no slack, same humans (n = n₀)", lambda k, n: f"{k}_n{n}_same_CI_n0"),
            ("SI: CI with slack (n = 2n₀)", lambda k, n: f"{k}_n{n}_sigma{n // 2}_CI"),
            ("MIX with slack", lambda k, n: f"{k}_n{n}_sigma{n // 2}_MIX"),
            ("LAST with slack", lambda k, n: f"{k}_n{n}_sigma{n // 2}_LAST"),
            ("CI, no slack, n₀ = n (different humans)", lambda k, n: f"{k}_n{n}_sigma0_CI")]
    lines = ["| protocol | human | n = 16 | n = 64 | n = 256 |", "|---|---|---|---|---|"]
    for label, key in rows:
        for kind in KINDS:
            cells = [cell(d.get(key(kind, n))) for n in [16, 64, 256]]
            lines.append(f"| {label} | {kind} | " + " | ".join(cells) + " |")
    lines += ["", "| protocol | human | n = 16 | n = 64 | n = 256 |", "|---|---|---|---|---|"]
    vrows = [("SI-V", lambda k, n: f"{k}_n{n}_sigma{n // 2}_SIV")] + [
        (f"SI-V-ABC, α = {al}", (lambda al: lambda k, n: f"{k}_n{n}_sigma{n // 2}_SIV-ABC_alpha{al}")(al))
        for al in (0.3, 0.1)]
    for label, key in vrows:
        for kind in KINDS:
            cells = []
            for n in [16, 64, 256]:
                e = d.get(key(kind, n))
                if e is None:
                    cells.append("–")
                elif "asked_mean" in e:
                    cells.append(f"{e['task_mean']:,.0f} ± {e['task_sem']:,.0f} "
                                 f"({e['asked_mean']:,.0f} asked; {e['rejected_mean']:.2f} rejected)")
                else:
                    cells.append(f"{e['task_mean']:,.0f} ± {e['task_sem']:,.0f} "
                                 f"({e['rejected_mean']:.2f} rejected; "
                                 f"{e['queries_per_rejection']:.0f} per rejection)")
            lines.append(f"| {label} | {kind} | " + " | ".join(cells) + " |")
    text = "\n".join(lines) + "\n"
    with open(os.path.join(outdir, "slack_imitation_table.md"), "w") as f:
        f.write(text)
    print(text)


def main_same(outdir):
    """Chained imitation without slack on the same humans as the slack cells: horizon
    n0 = n/2, the same seeds, run for n0 steps."""
    H = 40
    out = {}
    t0 = time.time()
    with Pool(4) as pool:
        for n in [16, 64, 256]:
            n0 = n // 2
            for kind in KINDS:
                rows = pool.map(one_human, [(kind, n0, 0, "CI", 1000 * n + s, 40 * M * n0)
                                            for s in range(H)])
                key = f"{kind}_n{n}_same_CI_n0"
                out[key] = dict(kind=kind, n=n, n0=n0, sigma=0, protocol="CI at n0, same humans",
                                **summarise(rows))
                print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
                sys.stdout.flush()
    with open(os.path.join(outdir, "slack_imitation_same.json"), "w") as f:
        json.dump(out, f, indent=1)


def main_verifier_abc(outdir, alphas=(0.1, 0.3)):
    H = 40
    out = {}
    t0 = time.time()
    with Pool(4) as pool:
        for alpha, n, kind in [(al, n, kd) for al in alphas for n in [16, 64, 256] for kd in KINDS]:
            if True:
                rows = pool.map(one_human_verifier_abc,
                                [(kind, n, n // 2, 1000 * n + s, alpha) for s in range(H)])
                q = np.array([r[0] for r in rows], dtype=float)
                key = f"{kind}_n{n}_sigma{n // 2}_SIV-ABC_alpha{alpha}"
                out[key] = dict(kind=kind, n=n, sigma=n // 2, protocol="SI-V-ABC", alpha=alpha,
                                humans=H, task_mean=float(q.mean()),
                                task_sem=float(q.std(ddof=1) / np.sqrt(H)),
                                asked_mean=float(np.mean([r[1] for r in rows])),
                                rejected_mean=float(np.mean([r[2] for r in rows])))
                print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
                sys.stdout.flush()
    with open(os.path.join(outdir, "slack_imitation_verifier_abc.json"), "w") as f:
        json.dump(out, f, indent=1)


def main_verifier(outdir):
    H = 40
    out = {}
    t0 = time.time()
    with Pool(4) as pool:
        for n in [16, 64, 256]:
            for kind in KINDS:
                rows = pool.map(one_human_verifier, [(kind, n, n // 2, 1000 * n + s) for s in range(H)])
                q = np.array([r[0] for r in rows], dtype=float)
                rej = np.array([r[1] for r in rows], dtype=float)
                out[f"{kind}_n{n}_sigma{n // 2}_SIV"] = dict(
                    kind=kind, n=n, sigma=n // 2, protocol="SI-V", humans=H,
                    task_mean=float(q.mean()), task_sem=float(q.std(ddof=1) / np.sqrt(H)),
                    rejected_mean=float(rej.mean()),
                    queries_per_rejection=float(q.sum() / max(rej.sum(), 1)),
                    worst_search=int(max(r[2] for r in rows)))
                print(json.dumps(out[f"{kind}_n{n}_sigma{n // 2}_SIV"]), f"[{time.time() - t0:.0f}s]")
                sys.stdout.flush()
    with open(os.path.join(outdir, "slack_imitation_verifier.json"), "w") as f:
        json.dump(out, f, indent=1)


if __name__ == "__main__":
    if "--same" in sys.argv:
        main_same(sys.argv[1] if len(sys.argv) > 1 else ".")
        sys.exit(0)
    if "--abc" in sys.argv:
        main_verifier_abc(sys.argv[1] if len(sys.argv) > 1 else ".")
        sys.exit(0)
    if "--verifier" in sys.argv:
        main_verifier(sys.argv[1] if len(sys.argv) > 1 else ".")
        sys.exit(0)
    if "--table" in sys.argv:
        table(sys.argv[1] if len(sys.argv) > 1 else ".")
        sys.exit(0)
    main(sys.argv[1] if len(sys.argv) > 1 else ".", quick="--quick" in sys.argv,
         mix="--mix" in sys.argv)
