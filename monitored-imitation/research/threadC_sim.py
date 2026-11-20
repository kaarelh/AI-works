"""Thread C: persistence conditions on the human alone. Two small exact experiments.

Both use m problems, each with an insight (content k_p) at a uniformly random step t_p with
probability eta, else none (t_p = n). Posteriors are exact under the class prior; problems
are independent. A query is one task step at a state of the decoder's own run. After every
run we compute exactly the fraction of problems on which the decoder's run fails, and stop
the first time it is at most EPS (an oracle stopping rule that measures cost).

CHAIN   (lateness).  Drafts are sets of items. The human is *persistent*: on a draft that
        lacks k_p at a step j >= t_p it writes k_p ("uses what it knows whenever it becomes
        relevant"); on a draft that contains k_p it writes the next unit of a chain of
        dependent work, one unit per step (the content of the chain is known to every
        hypothesis). Success = the final draft contains the human's draft from sigma steps
        before the end (slack sigma). A decoder that knows k_p but not t_p writes k_p at the
        posterior median w; if w > t_p + sigma the chain is too short: a failure whose
        mistakes are the steps [t_p, w), none at the end. The decoder never writes an
        unconfirmed k_p (Lemma 5 of without-a-check.md, eta = 1/2).

COMMIT  (plausible commissions). k_p is 1 ("the obvious idea") with probability PI and 2
        otherwise; eta is large, so the majority decoder writes the unconfirmed value 1 once
        it is confident enough that something is due. Two humans:
          noticing  on a draft carrying a value a != k_p at a step j >= t_p, it writes k_p
                    (corrects the guess);
          fooled    it keeps whatever value the draft carries (accepts the substitute).
        Success = t_p = n (nothing to find; extra content is harmless) or the final draft
        carries k_p.

Protocols (one task query per run): CI uniform step; EW end-weighted (without-a-check.md);
LAST last step; MIX last step with prob. 1/2, else uniform; BIS = LAST, and on a last-step
mistake, binary search with task queries on the same (fixed) run for the first step at which
the human writes k_p (CHAIN only).

Usage: python3 threadC_sim.py OUTDIR
"""

import json
import os
import sys
import time

import numpy as np

EPS = 0.02


def end_weights_cdf(n):
    h = 1.0 / np.arange(1, n + 1)
    w = h[::-1] / h.sum()  # weight of step j is proportional to 1/(n - j)
    return np.cumsum(w)


def pick_step(proto, n, rng, cdf):
    if proto in ("LAST", "BIS"):
        return n - 1
    if proto == "CI":
        return int(rng.integers(n))
    if proto == "MIX":
        return n - 1 if rng.random() < 0.5 else int(rng.integers(n))
    if proto == "EW":
        if rng.random() < 0.5:
            return int(rng.integers(n))
        return min(n - 1, int(np.searchsorted(cdf, rng.random(), side="right")))
    raise ValueError(proto)


# ---------------------------------------------------------------- CHAIN class

class Chain:
    """Exact posterior for one problem of the CHAIN class.

    Data only ever say t > lo, or (once an answer contains k_p) t <= hi; t is uniform on
    (lo, hi] given the insight. Until k_p is known the decoder writes nothing (an unknown
    value has mass <= Pr[t <= j]/q, below Pr[t > j], for eta = 1/2)."""

    def __init__(self, n):
        self.n = n
        self.k_known = False
        self.lo = -1
        self.hi = n

    def write_step(self):
        if not self.k_known:
            return None
        return (self.lo + self.hi) // 2 + 1  # first j with Pr[t <= j] > Pr[t > j]

    def query(self, t, j):
        """Task query at the decoder's state at step j. Returns True on a mistake."""
        w = self.write_step()
        if w is not None and j > w:
            return False  # the draft carries k_p: human and decoder both extend the chain
        human_writes = j >= t
        decoder_writes = (w == j)
        if human_writes:
            self.k_known = True
            self.hi = min(self.hi, j)
        else:
            self.lo = max(self.lo, j)
        return human_writes != decoder_writes

    def ok(self, t, sigma):
        """(success, run exactly the human's)."""
        n = self.n
        w = self.write_step()
        if t >= n:
            return True, w is None
        success = (t >= n - sigma) or (w is not None and w <= t + sigma)
        return success, w == t


def run_chain(proto, t, n, sigma, rng, max_runs):
    m = len(t)
    probs = [Chain(n) for _ in range(m)]
    cdf = end_weights_cdf(n)
    ok = np.array([probs[p].ok(t[p], sigma)[0] for p in range(m)])
    bad = int(m - ok.sum())
    task = 0
    for r in range(1, max_runs + 1):
        if bad / m <= EPS:
            return task, bad / m, r - 1
        p = int(rng.integers(m))
        pr = probs[p]
        j = pick_step(proto, n, rng, cdf)
        task += 1
        mistake = pr.query(t[p], j)
        if proto == "BIS" and mistake and j == n - 1:
            # the fixed run never wrote k_p, so its states are (j, no k_p) for every j, and
            # "the human writes k_p here" is monotone in j: binary search for the first one
            while pr.hi - pr.lo > 1:
                mid = (pr.lo + pr.hi) // 2
                task += 1
                if mid >= t[p]:
                    pr.hi = mid
                else:
                    pr.lo = mid
        new = pr.ok(t[p], sigma)[0]
        bad += int(ok[p]) - int(new)
        ok[p] = new
    return task, bad / m, max_runs


# ---------------------------------------------------------------- COMMIT class

class Commit:
    """Exact posterior over (t, k), t in {0..n-1} or n (no insight), k in {1, 2}.
    w[t, k-1] are the unnormalised weights of the consistent hypotheses."""

    def __init__(self, n, eta, pi, human):
        self.n = n
        self.human = human
        self.w = np.zeros((n + 1, 2))
        self.w[:n, 0] = eta * pi / n
        self.w[:n, 1] = eta * (1 - pi) / n
        self.w[n, 0] = 1 - eta
        self.run = None
        self.recompute()

    def recompute(self):
        """The majority decoder's run: a[j] = value carried by the draft at step j (0 = none).
        Ties go to keeping the current draft, then to the value 1."""
        n, w = self.n, self.w
        c1 = np.cumsum(w[:n, 0])
        c2 = np.cumsum(w[:n, 1])
        bot = w.sum() - c1 - c2  # mass of hypotheses with t > j
        tol = 1e-9 * w.sum()  # exact ties (symmetric weights) must not be broken by rounding
        a = np.zeros(n + 1, dtype=int)
        j, cur = 0, 0
        while j < n:
            if cur == 0:
                w1 = (c1[j:] > bot[j:] + tol) & (c1[j:] >= c2[j:] - tol)
                w2 = (c2[j:] > bot[j:] + tol) & (c2[j:] > c1[j:] + tol)
                hit = np.flatnonzero(w1 | w2)
                if len(hit) == 0:
                    break
                jj = j + int(hit[0])
                cur = 1 if w1[hit[0]] else 2
            else:
                if self.human == "fooled":
                    a[j:] = cur
                    break
                ca, cb = (c1, c2) if cur == 1 else (c2, c1)
                hit = np.flatnonzero(cb[j:] > bot[j:] + ca[j:] + tol)
                a[j:] = cur
                if len(hit) == 0:
                    break
                jj = j + int(hit[0])
                cur = 3 - cur
            a[jj + 1:] = cur
            j = jj + 1
        self.run = a

    def responses(self, j, a):
        """Every hypothesis' next value at the draft (j, a): array of shape (n+1, 2)."""
        n = self.n
        tt = np.arange(n + 1)[:, None]
        kk = np.array([[1, 2]])
        due = tt <= j  # t = n never is
        if a == 0 or self.human == "noticing":
            return np.where(due, kk, a)
        return np.full((n + 1, 2), a)

    def human_response(self, t, k, j, a):
        if a == 0 or self.human == "noticing":
            return k if j >= t else a
        return a

    def query(self, t, k, j):
        a = int(self.run[j])
        dec = int(self.run[j + 1])
        hum = self.human_response(t, k, j, a)
        resp = self.responses(j, a)
        killed = (resp != hum) & (self.w > 0)
        if killed.any():
            self.w[killed] = 0.0
            self.recompute()
        return dec != hum

    def ok(self, t, k):
        if t >= self.n:
            return True, int(self.run[-1]) == 0
        fin = int(self.run[-1]) == k
        return fin, None


def run_commit(proto, t, k, n, eta, pi, human, rng, max_runs):
    m = len(t)
    probs = [Commit(n, eta, pi, human) for _ in range(m)]
    cdf = end_weights_cdf(n)
    ok = np.array([probs[p].ok(t[p], k[p])[0] for p in range(m)])
    bad = int(m - ok.sum())
    for r in range(1, max_runs + 1):
        if bad / m <= EPS:
            return r - 1, bad / m, r - 1
        p = int(rng.integers(m))
        j = pick_step(proto, n, rng, cdf)
        probs[p].query(t[p], k[p], j)
        new = probs[p].ok(t[p], k[p])[0]
        bad += int(ok[p]) - int(new)
        ok[p] = new
    return max_runs, bad / m, max_runs


def summarise(rows):
    tasks = np.array([r[0] for r in rows], dtype=float)
    fails = np.array([r[1] for r in rows], dtype=float)
    return {
        "humans": len(rows),
        "reached": int((fails <= EPS).sum()),
        "task_mean": float(tasks.mean()),
        "task_sem": float(tasks.std(ddof=1) / np.sqrt(len(tasks))) if len(tasks) > 1 else 0.0,
        "task_median": float(np.median(tasks)),
        "final_failure_mean": float(fails.mean()),
    }


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    m = 100
    out = {}
    t0 = time.time()

    # CHAIN: eta = 1/2, slack 0 and n/8
    eta = 0.5
    for n in [16, 64, 256]:
        for sigma in [0, n // 8]:
            for proto in ["CI", "EW", "LAST", "BIS", "MIX"]:
                rows = []
                H = 100
                for s in range(H):
                    rng = np.random.default_rng(7000 * n + s)
                    trig = rng.random(m) < eta
                    t = np.where(trig, rng.integers(0, n, size=m), n)
                    rng2 = np.random.default_rng(10**7 + 7000 * n + s)
                    cap = 200 * m if proto in ("LAST", "BIS") else 100 * m * n
                    rows.append(run_chain(proto, t, n, sigma, rng2, cap))
                key = f"chain_n{n}_sigma{sigma}_{proto}"
                out[key] = dict(cls="chain", n=n, sigma=sigma, protocol=proto, **summarise(rows))
                print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
                sys.stdout.flush()

    # COMMIT: eta = 0.8, PI = 0.9 (the obvious value 1); noticing vs fooled humans
    eta, pi = 0.8, 0.9
    for n in [16, 64, 256]:
        for human in ["noticing", "fooled"]:
            for proto in ["CI", "EW", "LAST"]:
                rows = []
                H = 40 if n < 256 else 20
                for s in range(H):
                    rng = np.random.default_rng(9000 * n + s)
                    trig = rng.random(m) < eta
                    t = np.where(trig, rng.integers(0, n, size=m), n)
                    k = np.where(rng.random(m) < pi, 1, 2)
                    rng2 = np.random.default_rng(10**8 + 9000 * n + s)
                    cap = 200 * m if proto == "LAST" else 20 * m * n
                    rows.append(run_commit(proto, t, k, n, eta, pi, human, rng2, cap))
                key = f"commit_n{n}_{human}_{proto}"
                out[key] = dict(cls="commit", n=n, human=human, protocol=proto, **summarise(rows))
                print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
                sys.stdout.flush()

    with open(os.path.join(outdir, "threadC_sim_summary.json"), "w") as f:
        json.dump(out, f, indent=1)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ".")
