"""Thread Z (stochastic humans): simulation for research/threadZ-stochastic-human.md.

numpy only.  Usage: python3 -B threadZ_stochastic.py > threadZ_stochastic.out   (about 30 s)

The toy (model (ii) of the thread: a deterministic core with memoryless random deviations).
* M insight types.  Type t has a hidden value v_t in [q] and a hidden step j_t in [n0].
  A problem is a type drawn uniformly; a notebook is (type, list of entries); entries are values
  in [q] or a routine entry '.', so the alphabet has q + 1 symbols.
* The human's core C (deterministic):
    silent   : write v_t at step j_t exactly, '.' elsewhere (a missed insight is never recovered);
    noticing : write v_t at the first step k >= j_t at which v_t is not yet in the notebook.
  The human P: with probability 1 - delta write C(y); with probability delta write a symbol drawn
  uniformly from the q + 1 symbols (independently at every query: memoryless).
* The verifier V (sound, machine-like): accepts a final notebook iff it contains v_t.
  The core's own chain writes v_t at j_t < n0, so (A2-C) and (A3'-C) hold for every problem; the
  human's own chain fails when a deviation hits the insight step (silent human).
* The learner: exact Bayes over the stochastic class {(v_t, j_t)_t} x {known delta, uniform Q},
  uniform prior, so K = M log2(q n0) bits.  Its posterior factorizes over types.
* The imitator's horizon is n = n0 + sigma steps.

Protocols (each run on its own learning trajectory, same problems and truth per seed):
* CI         : chained imitation without a verifier: mode decoder, output the run, then one task
               query at a uniform step of the run (added to the data).
* D-VSI(det) : the paper's minimal VSI with a learner that assumes the human is deterministic
               (exact elimination); scan from step 0, stop at the first answer that differs from
               the run's label, add the answers, rerun.  With delta > 0 a deviation can refute the
               true program; when a type's consistent set becomes empty the learner has crashed,
               and every later problem of that type is abstained (counted).
* D-VSI(Bayes): the same search (stop at the first differing answer) with the stochastic learner.
* VSI-full   : Theorem Z4: mode decoder; on a rejection ask once at each of the run's first n0
               notebooks, add all answers, rerun.
* VSI-sprt   : early stopping: scan from step 0; at each step ask until the answers that agree with
               the run's label lead by one (pass) or trail by r = 2 (alarm); rerun at the first
               alarm; all answers added (the practical version).
* VSI-split  : Theorem Z4' exactly: as VSI-sprt (r = 3) but the detection answers are discarded and
               one fresh answer at the alarm step is added.
* Sampler    : Theorem Z8: posterior sampling (draw (v,j) from the posterior, run that stochastic
               program); rerun up to m times; if all m runs are rejected the human demonstrates
               (its own chain from the start, until V accepts or n steps), all of whose steps are
               added; the human's chain is output if accepted, else the problem is abstained.

Measured: task queries per problem, rejections, output correctness (fraction of outputs that are
correct; V is sound, so 1.0 for every verified protocol), abstentions, imitator runs per problem,
and the theorems' bounds: E[rejections] <= K / (1 - h(delta)) for VSI-full, and
E[demos] <= min over theta of T exp(-m theta s) + (ln 2 / 2) K / ((1 - theta)^2 s^2) for the sampler,
and E[rejections] <= K / ((1 - h(delta))(1 - n0 rho^3 - rho)), rho = delta/(1-delta), for VSI-split.

A second experiment, 'the coin', is the obstruction of Proposition Z10: the human picks one of two
approaches at random and only the problem's own (hidden) one succeeds, so the human has no mode
that succeeds.  A deterministic imitator built from the human's data loops (or abstains); a
sampling imitator succeeds after about 2 runs and no task queries.
"""

import math
import time

import numpy as np

# ------------------------------------------------------------------ parameters

M = 6            # insight types
Q = 256          # values per insight (large, so that blind reruns cannot find v_t)
N0 = 12          # human's horizon
SIGMA = 6        # slack
N = N0 + SIGMA   # imitator's horizon
T = 60           # problems per seed
SEEDS = list(range(1, 31))
DELTAS = [0.0, 0.05, 0.1, 0.2]
KINDS = ["silent", "noticing"]
R_MAX = 60       # cap on reruns of one problem (then abstain)
M_RUNS = 30      # sampler: runs before calling the human
DOT = Q          # index of the routine symbol
NSYM = Q + 1
K_BITS = M * math.log2(Q * N0)

VV, JJ = np.meshgrid(np.arange(Q), np.arange(N0), indexing="ij")   # (Q, N0) grids


def h2(p):
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# ------------------------------------------------------------------ the human


def core(kind, v, j, k, present):
    """The deterministic core's entry at step k (present = set of values already written)."""
    if kind == "silent":
        return v if k == j else DOT
    return v if (k >= j and v not in present) else DOT


def human_answer(rng, kind, v, j, k, present, delta):
    if delta > 0 and rng.random() < delta:
        return int(rng.integers(NSYM))
    return core(kind, v, j, k, present)


# ------------------------------------------------------------------ the learner


class Learner:
    """Exact Bayes over (v_t, j_t) per type, with deviation rate delta_l (0: elimination)."""

    def __init__(self, kind, delta_l):
        self.kind = kind
        self.dl = delta_l
        self.W = np.full((M, Q, N0), 1.0 / (Q * N0))
        self.dead = [False] * M

    def match_mask(self, k, present, a):
        """Boolean (Q, N0): hypotheses whose core writes a at (k, present)."""
        if self.kind == "silent":
            writes_v = (JJ == k)
        else:
            pres = np.zeros(Q, dtype=bool)
            for u in present:
                pres[u] = True
            writes_v = (JJ <= k) & (~pres[VV])
        if a == DOT:
            return ~writes_v
        return writes_v & (VV == a)

    def update(self, t, k, present, a):
        if self.dead[t]:
            return
        m = self.match_mask(k, present, a)
        base = self.dl / NSYM
        f = np.where(m, (1.0 - self.dl) + base, base)
        w = self.W[t] * f
        s = w.sum()
        if s <= 0.0:
            self.dead[t] = True
            return
        self.W[t] = w / s

    def masses(self, t, k, present):
        """Posterior mass of 'the core writes a' for each symbol a (mode of the predictive)."""
        Wt = self.W[t]
        out = np.zeros(NSYM)
        if self.kind == "silent":
            col = Wt[:, k] if k < N0 else np.zeros(Q)
            out[:Q] = col
        else:
            kk = min(k, N0 - 1)
            cum = Wt[:, : kk + 1].sum(axis=1)
            for u in present:
                cum[u] = 0.0
            out[:Q] = cum
        out[DOT] = 1.0 - out[:Q].sum()
        return out

    def decode(self, t, k, present):
        """Argmax of the posterior predictive; ties go to '.' then to the smallest value.
        The predictive is (1-dl)*mass + dl/NSYM, so its argmax is the argmax of the mass."""
        ms = self.masses(t, k, present)
        best = ms.max()
        if ms[DOT] >= best - 1e-15:
            return DOT
        return int(np.argmax(ms))

    def sample_hyp(self, rng, t):
        flat = self.W[t].ravel()
        idx = rng.choice(flat.size, p=flat / flat.sum())
        return int(idx // N0), int(idx % N0)


# ------------------------------------------------------------------ runs


def decoder_run(L, t):
    entries, present = [], set()
    for k in range(N):
        a = L.decode(t, k, present)
        entries.append(a)
        if a != DOT:
            present.add(a)
    return entries


def prefixes(entries):
    """(k, present-before-step-k) for k = 0..len-1."""
    out, present = [], set()
    for k, a in enumerate(entries):
        out.append((k, frozenset(present)))
        if a != DOT:
            present.add(a)
    return out


def accepted(entries, vt):
    return vt in entries


def sampled_run(rng, kind, v, j, delta):
    entries, present = [], set()
    for k in range(N):
        a = human_answer(rng, kind, v, j, k, present, delta)
        entries.append(a)
        if a != DOT:
            present.add(a)
    return entries


# ------------------------------------------------------------------ protocols
# Each returns a dict of totals for one seed.


def new_stats():
    return dict(queries=0, rejections=0, outputs=0, correct=0, abstain=0, runs=0,
                demos=0, crashed=0)


def proto_ci(rng, kind, delta, truth, probs):
    L = Learner(kind, delta)
    st = new_stats()
    for t in probs:
        vt, jt = truth[t]
        run = decoder_run(L, t)
        st["runs"] += 1
        st["outputs"] += 1
        st["correct"] += int(accepted(run, vt))
        if not accepted(run, vt):
            st["rejections"] += 1           # here: failed outputs (no verifier)
        k = int(rng.integers(N))
        k_, pres = prefixes(run)[k]
        a = human_answer(rng, kind, vt, jt, k_, pres, delta)
        L.update(t, k_, pres, a)
        st["queries"] += 1
    return st


def proto_dvsi(rng, kind, delta, truth, probs, learner_delta):
    L = Learner(kind, learner_delta)
    st = new_stats()
    for t in probs:
        vt, jt = truth[t]
        if L.dead[t]:
            st["abstain"] += 1
            continue
        done = False
        for _ in range(R_MAX):
            run = decoder_run(L, t)
            st["runs"] += 1
            if accepted(run, vt):
                st["outputs"] += 1
                st["correct"] += 1
                done = True
                break
            st["rejections"] += 1
            hit = False
            for k, pres in prefixes(run):
                a = human_answer(rng, kind, vt, jt, k, pres, delta)
                st["queries"] += 1
                L.update(t, k, pres, a)
                if a != run[k]:
                    hit = True
                    break
            if L.dead[t]:
                st["crashed"] += 1
                break
            if not hit:
                break                         # scan exhausted: abstain
        if not done:
            st["abstain"] += 1
    return st


def proto_full(rng, kind, delta, truth, probs):
    L = Learner(kind, delta)
    st = new_stats()
    for t in probs:
        vt, jt = truth[t]
        done = False
        for _ in range(R_MAX):
            run = decoder_run(L, t)
            st["runs"] += 1
            if accepted(run, vt):
                st["outputs"] += 1
                st["correct"] += 1
                done = True
                break
            st["rejections"] += 1
            for k, pres in prefixes(run)[:N0]:
                a = human_answer(rng, kind, vt, jt, k, pres, delta)
                st["queries"] += 1
                L.update(t, k, pres, a)
        if not done:
            st["abstain"] += 1
    return st


def proto_sprt(rng, kind, delta, truth, probs, r, split):
    L = Learner(kind, delta)
    st = new_stats()
    for t in probs:
        vt, jt = truth[t]
        done = False
        for _ in range(R_MAX):
            run = decoder_run(L, t)
            st["runs"] += 1
            if accepted(run, vt):
                st["outputs"] += 1
                st["correct"] += 1
                done = True
                break
            st["rejections"] += 1
            for k, pres in prefixes(run):
                walk = 0
                while -r < walk < 1:
                    a = human_answer(rng, kind, vt, jt, k, pres, delta)
                    st["queries"] += 1
                    if not split:
                        L.update(t, k, pres, a)
                    walk += 1 if a == run[k] else -1
                if walk <= -r:                # alarm
                    if split:
                        a = human_answer(rng, kind, vt, jt, k, pres, delta)
                        st["queries"] += 1
                        L.update(t, k, pres, a)
                    break
        if not done:
            st["abstain"] += 1
    return st


def proto_sampler(rng, kind, delta, truth, probs):
    L = Learner(kind, delta)
    st = new_stats()
    for t in probs:
        vt, jt = truth[t]
        done = False
        for _ in range(M_RUNS):
            v, j = L.sample_hyp(rng, t)
            run = sampled_run(rng, kind, v, j, delta)
            st["runs"] += 1
            if accepted(run, vt):
                st["outputs"] += 1
                st["correct"] += 1
                done = True
                break
            st["rejections"] += 1
        if done:
            continue
        st["demos"] += 1                      # the human demonstrates on its own chain
        present, entries = set(), []
        for k in range(N):
            a = human_answer(rng, kind, vt, jt, k, present, delta)
            st["queries"] += 1
            L.update(t, k, frozenset(present), a)
            entries.append(a)
            if a != DOT:
                present.add(a)
            if accepted(entries, vt):
                break
        if accepted(entries, vt):
            st["outputs"] += 1
            st["correct"] += 1
        else:
            st["abstain"] += 1
    return st


PROTOCOLS = [
    ("CI (no verifier)", lambda rng, kd, d, tr, pr: proto_ci(rng, kd, d, tr, pr)),
    ("D-VSI(det)", lambda rng, kd, d, tr, pr: proto_dvsi(rng, kd, d, tr, pr, 0.0)),
    ("D-VSI(Bayes)", lambda rng, kd, d, tr, pr: proto_dvsi(rng, kd, d, tr, pr, d)),
    ("VSI-full (Z4)", lambda rng, kd, d, tr, pr: proto_full(rng, kd, d, tr, pr)),
    ("VSI-sprt r=2", lambda rng, kd, d, tr, pr: proto_sprt(rng, kd, d, tr, pr, 2, False)),
    ("VSI-split r=3 (Z4')", lambda rng, kd, d, tr, pr: proto_sprt(rng, kd, d, tr, pr, 3, True)),
    ("Sampler+demos (Z8)", lambda rng, kd, d, tr, pr: proto_sampler(rng, kd, d, tr, pr)),
]


def human_success(rng, kind, delta, trials=4000):
    """Monte Carlo estimate of s: the human's own n-step chain is accepted."""
    ok = 0
    for _ in range(trials):
        v, j = int(rng.integers(Q)), int(rng.integers(N0))
        ok += accepted(sampled_run(rng, kind, v, j, delta), v)
    return ok / trials


# ------------------------------------------------------------------ the coin (Proposition Z10)


def coin_experiment(T_coin=2000, seed=7):
    """One decision with two approaches A=0, B=1; the human picks uniformly; V accepts iff the pick
    equals the problem's hidden lam (uniform).  The human's data never reveal lam."""
    rng = np.random.default_rng(seed)
    lam = rng.integers(2, size=T_coin)
    out = {}
    # deterministic imitator (tie-break A), minimal VSI: scan the one step, stop at a differing
    # answer, add it (H = {P}: no learning), rerun; the rerun is identical.
    q_det, ab_det = 0, 0
    for t in range(T_coin):
        if lam[t] == 0:
            continue                          # accepted at once
        for _ in range(R_MAX):
            q_det += 1
            if rng.integers(2) == 0:          # the answer equals the run's label: scan exhausted
                break
            # otherwise a 'hit' that teaches nothing (H = {P}); the rerun is identical
        ab_det += 1
    out["det_decoder"] = (q_det / T_coin, ab_det / T_coin, 0.0)
    # cache-first deterministic imitator (Proposition any-learner): ask once, adopt the human's
    # answer; abstain if the human's own pick fails.
    q_c, ab_c = 0, 0
    for t in range(T_coin):
        if lam[t] == 0:
            continue
        q_c += 1
        if rng.integers(2) != lam[t]:
            ab_c += 1
    out["cache_first"] = (q_c / T_coin, ab_c / T_coin, 0.0)
    # sampler: rerun until accepted, no queries
    runs = 0
    for t in range(T_coin):
        while True:
            runs += 1
            if rng.integers(2) == lam[t]:
                break
    out["sampler"] = (0.0, 0.0, runs / T_coin)
    return out


# ------------------------------------------------------------------ main


def run_cell(pi, fn, kd, d, T_):
    tot = new_stats()
    rej_list, dem_list = [], []
    for seed in SEEDS:
        rng = np.random.default_rng(1000 * seed + 17)
        truth = [(int(rng.integers(Q)), int(rng.integers(N0))) for _ in range(M)]
        probs = [int(x) for x in rng.integers(M, size=T_)]
        st = fn(np.random.default_rng(seed * 7919 + int(d * 1000) * 13 + pi * 101 + T_), kd, d, truth, probs)
        for key in tot:
            tot[key] += st[key]
        rej_list.append(st["rejections"])
        dem_list.append(st["demos"])
    ns = len(SEEDS)
    return dict(q=tot["queries"] / (ns * T_), rej=tot["rejections"] / ns,
                corr=tot["correct"] / max(1, tot["outputs"]), abst=100.0 * tot["abstain"] / (ns * T_),
                rpp=tot["runs"] / (ns * T_), crashed=tot["crashed"] / ns, demos=tot["demos"] / ns,
                rej_max=max(rej_list), dem_max=max(dem_list),
                qpr=tot["queries"] / max(1, tot["rejections"]))


def z8_bound(s, T_):
    """min over theta of T exp(-m theta s) + (ln 2 / 2) K / ((1 - theta)^2 s^2)."""
    best = float("inf")
    for th in np.linspace(0.01, 0.99, 99):
        b = T_ * math.exp(-M_RUNS * th * s) + (math.log(2) / 2) * K_BITS / ((1 - th) ** 2 * s ** 2)
        best = min(best, b)
    return best


def main():
    t0 = time.time()
    print("== Thread Z: VSI with a stochastic human (model (ii): deterministic core + memoryless deviations) ==")
    print(f"   M = {M} insight types, q = {Q} values, n0 = {N0}, slack {SIGMA} (n = {N}); T = {T} problems per seed;")
    print(f"   seeds {SEEDS[0]}..{SEEDS[-1]} ({len(SEEDS)}); K = M log2(q n0) = {K_BITS:.1f} bits; rerun cap {R_MAX};")
    print(f"   sampler: m = {M_RUNS} runs before a demonstration.  Numbers are means over seeds.")
    print("   'rejections' counts rejected runs (for CI: failed outputs, since CI has no verifier);")
    print("   'q/rej' is task queries per rejection (for the sampler: per demonstration, see 'demos').")
    print()
    rng_s = np.random.default_rng(12345)
    s_hat = {(kd, d): human_success(rng_s, kd, d) for kd in KINDS for d in DELTAS}
    summary = {}
    for kd in KINDS:
        print(f"== Human kind: {kd} ==")
        print("   s = P(the human's own n-step chain is accepted): " +
              ", ".join(f"delta={d}: {s_hat[(kd, d)]:.3f}" for d in DELTAS))
        print("   | protocol | delta | queries/problem | rejections/seed | q/rej | output correct | abstain % | runs/problem | demos/seed | crashed types/seed |")
        for pi, (name, fn) in enumerate(PROTOCOLS):
            for d in DELTAS:
                r = run_cell(pi, fn, kd, d, T)
                summary[(kd, name, d)] = r
                qpr = f"{r['q'] * T * len(SEEDS) / max(1e-9, r['demos'] * len(SEEDS)):.1f}" if name.startswith("Sampler") and r["demos"] > 0 else (
                    "-" if name.startswith("Sampler") else f"{r['qpr']:.1f}")
                print(f"   | {name} | {d} | {r['q']:.2f} | {r['rej']:.1f} | {qpr} | {r['corr']:.3f} | {r['abst']:.1f} | "
                      f"{r['rpp']:.2f} | {r['demos']:.2f} | {r['crashed']:.2f} |")
        print()
        print("   Theorem checks (means over seeds; max over seeds in brackets):")
        for d in DELTAS:
            bnd = K_BITS / (1 - h2(d))
            r = summary[(kd, "VSI-full (Z4)", d)]
            print(f"   * Z4 (VSI-full), delta={d}: rejections/seed {r['rej']:.1f} ({r['rej_max']}) <= K/(1-h(delta)) = {bnd:.1f}; "
                  f"queries/seed {r['q'] * T:.0f} <= n0 K/(1-h(delta)) = {N0 * bnd:.0f}")
        for d in DELTAS:
            if d >= 0.5:
                continue
            rho = d / (1 - d)
            pi_lb = 1 - N0 * rho ** 3 - rho
            bnd = K_BITS / ((1 - h2(d)) * pi_lb)
            r = summary[(kd, "VSI-split r=3 (Z4')", d)]
            print(f"   * Z4' (VSI-split), delta={d}: rejections/seed {r['rej']:.1f} ({r['rej_max']}) <= K/((1-h(delta))(1-n0 rho^3-rho)) = {bnd:.1f}")
        for d in DELTAS:
            s = s_hat[(kd, d)]
            r = summary[(kd, "Sampler+demos (Z8)", d)]
            print(f"   * Z8 (sampler), delta={d}: demos/seed {r['demos']:.2f} ({r['dem_max']}) <= min_theta [T e^(-m theta s) + (ln2/2) K/((1-theta)^2 s^2)] = {z8_bound(s, T):.1f}")
        print()

    print("== No term in T: totals per seed as the number of problems grows (silent human) ==")
    print("   | protocol | delta | T=30 | T=60 | T=120 | T=240 |  (rejections/seed for VSI-full; demos/seed and runs/problem for the sampler)")
    for pi, (name, fn) in enumerate(PROTOCOLS):
        if name not in ("VSI-full (Z4)", "Sampler+demos (Z8)"):
            continue
        for d in (0.0, 0.1, 0.2):
            cells = []
            for T_ in (30, 60, 120, 240):
                r = run_cell(pi, fn, "silent", d, T_)
                cells.append(f"{r['rej']:.1f}" if name.startswith("VSI") else f"{r['demos']:.2f} / {r['rpp']:.2f}")
            print(f"   | {name} | {d} | " + " | ".join(cells) + " |")
    print()

    print("== Model (iii) obstruction: the coin (Proposition Z10) ==")
    co = coin_experiment()
    print("   One decision, two approaches; the human picks uniformly (s = 1/2, no successful mode); K = 0.")
    print("   | imitator | task queries/problem | abstain % | imitator runs/problem |")
    print(f"   | deterministic decoder, minimal VSI (cap {R_MAX} reruns) | {co['det_decoder'][0]:.2f} | {100 * co['det_decoder'][1]:.1f} | - |")
    print(f"   | deterministic, cache-first (adopt the human's answer) | {co['cache_first'][0]:.2f} | {100 * co['cache_first'][1]:.1f} | - |")
    print(f"   | sampler, rerun until accepted | {co['sampler'][0]:.2f} | {100 * co['sampler'][1]:.1f} | {co['sampler'][2]:.2f} |")
    print()
    print(f"runtime {time.time() - t0:.1f} s")


if __name__ == "__main__":
    main()
