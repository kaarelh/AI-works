"""v4: independent checks of teacher/notes-final.md Prop 3.7 (frozen noise: FR versus FQ) and of Lemma 3.0 in
the form Prop 3.7(c) uses.

Written for research/tracks/split/verify-teacher.md; no code shared with teacher/checks/ or referee_code/.
Seeded: numpy default_rng(3707). Deterministic given the seed.

Instance. X = {0,...,11} with a non-uniform input law mu (weights 12, 11, ..., 1); a sampler nu with
nu(1|x) in {1/4, 1/8, 3/8}; the table F(x) ~ nu(.|x), drawn once per run. A finite class C with Kraft sum < 1:
  pi_0 = nu (length k = 4); four wrong samplers (length 6);
  memorisers pi_{A,b} for |A| in {1, 2} and every b in {0,1}^A: nu off A, deterministic b on A (lengths 12, 16);
  all 4096 deterministic fill-in tables (length 16), handled in closed form.
(A) FR (Paper 2's data-set likelihood, one term per distinct input): Ville's tail Pr[delta* >= j] <= 2^-j for the
    deficiency delta* = sup log2(xi_C(D)/nu(D)) over the distinct-input process, by Monte Carlo (20,000 runs, 400
    queries each); the right line (1, k + delta*) and the length bound k + (k + delta*)/(lambda - 1) of every
    FR lambda-MAP for lambda in {1.5, 2, 4} at every n; the bounded gain of every memoriser of the true labels.
(B) FQ (every query counted): the identity L(pi_0) - L(pi_A) = sum_{x in A} N_n(x) log2(1/nu(F(x)|x)) exactly at
    every n; and that a fixed lambda (2, 8) or lambda_n = sqrt(n) eventually rejects pi_0 under FQ, while FR keeps
    a nu-program at fixed lambda (one long run, n up to 2^22).
(C) Prop 3.7(c) / Lemma 3.0: with uniform mu on X and every input queried nbar times, the FQ lambda-MAPs are the
    (lambda/nbar)-MAPs of the full table (exact, nbar in {2, 5, 17}).
"""
import itertools
import math
import numpy as np

rng = np.random.default_rng(3707)
K = 12
mu = np.arange(K, 0, -1, dtype=float)
mu /= mu.sum()
rates = np.array([1 / 4, 1 / 8, 3 / 8] * 4)


def build_class(rates):
    """explicit programs: list of (name, length, kind, data); fill-ins handled separately."""
    progs = [("nu", 4, "sampler", rates.copy())]
    for w, alt in enumerate((rates[::-1], np.full(K, 0.5), np.clip(rates * 2, 0, 0.9), rates / 2)):
        progs.append((f"wrong{w}", 6, "sampler", np.array(alt)))
    for size, L in ((1, 12), (2, 16)):
        for A in itertools.combinations(range(K), size):
            for b in itertools.product((0, 1), repeat=size):
                progs.append((f"mem{A}{b}", L, "mem", (A, b)))
    return progs


def loglik_matrix(progs, rates, Fv):
    """log2 nu_pi(F(x) | x) for every explicit program and input."""
    M = np.empty((len(progs), K))
    for i, (_, _, kind, data) in enumerate(progs):
        if kind == "sampler":
            q = data
            M[i] = np.log2(np.where(Fv == 1, q, 1 - q))
        else:
            A, b = data
            row = np.log2(np.where(Fv == 1, rates, 1 - rates))
            for x, bx in zip(A, b):
                row[x] = 0.0 if bx == Fv[x] else -np.inf
            M[i] = row
    return M


PROGS = build_class(rates)
LENS = np.array([p[1] for p in PROGS], dtype=float)
FILL_LEN = 16
kraft = float(np.sum(2.0 ** -LENS) + 2 ** K * 2.0 ** -FILL_LEN)
k = 4


def partA(runs=20000, nq=400):
    assert kraft < 1
    js = [0.5, 1, 2, 3, 4, 6]
    hits = np.zeros(len(js))
    nlen = nline = ngain = 0
    for _ in range(runs):
        Fv = (rng.random(K) < rates).astype(int)
        LL = loglik_matrix(PROGS, rates, Fv)
        xs = rng.choice(K, size=nq, p=mu)
        seen = np.zeros(K, dtype=bool)
        cum = np.zeros(len(PROGS))     # sum over distinct inputs of log2 nu_pi(F(x)|x)
        nd = 0
        dstar = -np.inf
        lognu = 0.0
        for x in xs:
            if seen[x]:
                continue
            seen[x] = True
            nd += 1
            cum += LL[:, x]
            lognu = cum[0]
            # xi_C(D) = sum_pi 2^-l nu_pi(D) + fill-ins 2^-FILL_LEN * 2^(K - nd)
            with np.errstate(divide="ignore"):
                terms = -LENS + cum
            mx = max(np.max(terms), -FILL_LEN + (K - nd))
            xi = mx + math.log2(np.sum(2.0 ** (terms - mx)) + 2.0 ** (-FILL_LEN + K - nd - mx))
            dstar = max(dstar, xi - lognu)
        dstar = max(dstar, 0.0) if nd == 0 else dstar
        hits += np.array([dstar >= j for j in js])
        # re-run the process for the line, the MAP length bound and the bounded gain, with the final delta*
        seen[:] = False
        cum[:] = 0.0
        nd = 0
        for x in xs:
            if seen[x]:
                continue
            seen[x] = True
            nd += 1
            cum += LL[:, x]
            fits = -cum                          # FR fits in bits
            F0 = fits[0]
            # right line (1, k + delta*) on every explicit program and on the fill-ins (fit 0, length 16)
            assert np.all(fits >= F0 - (k + dstar) - (LENS - k) - 1e-9)
            assert 0.0 >= F0 - FILL_LEN - dstar - 1e-9
            nline += 1
            for lam in (1.5, 2.0, 4.0):
                J = lam * LENS + fits
                Jfill = lam * FILL_LEN
                best = min(np.min(J), Jfill)
                lens_map = list(LENS[J <= best + 1e-9]) + ([FILL_LEN] if Jfill <= best + 1e-9 else [])
                assert max(lens_map) <= k + (k + dstar) / (lam - 1) + 1e-9
                nlen += 1
            # bounded gain of memorisers of the true labels
            for i, (_, _, kind, data) in enumerate(PROGS):
                if kind == "mem":
                    A, b = data
                    if all(Fv[a] == ba for a, ba in zip(A, b)):
                        bound = sum(-math.log2(rates[a] if Fv[a] == 1 else 1 - rates[a]) for a in A)
                        assert F0 - fits[i] <= bound + 1e-9
                        ngain += 1
    print("=" * 96)
    print(f"(A) FR, Kraft sum of the class = {kraft:.4f}; {runs} runs of {nq} queries (repeats allowed)")
    for j, h in zip(js, hits):
        print(f"    Pr[delta* >= {j:>3}] = {h / runs:.4f}   (Ville bound 2^-j = {2.0 ** -j:.4f})")
        assert h / runs <= 2.0 ** -j + 3 * math.sqrt(2.0 ** -j / runs)
    print(f"    right line (1, k + delta*) checked at {nline} (run, n) pairs; MAP length bound at {nlen}; "
          f"bounded memoriser gain at {ngain}; all assertions passed")


def partB():
    Fv = (rng.random(K) < rates).astype(int)
    LL = loglik_matrix(PROGS, rates, Fv)
    nq = 2 ** 22
    xs = rng.choice(K, size=nq, p=mu)
    checkpoints = [2 ** e for e in range(4, 23)]
    print("=" * 96)
    print("(B) FQ against FR on one long run (n up to 2^22)")
    counts = np.zeros(K, dtype=np.int64)
    pos = 0
    nid = 0
    rows = []
    for n in checkpoints:
        np.add.at(counts, xs[pos:n], 1)
        pos = n
        with np.errstate(invalid="ignore"):
            fq = -np.where(counts[None, :] > 0, LL * counts[None, :], 0.0).sum(axis=1)
        fq = np.where(np.any(~np.isfinite(LL) & (counts[None, :] > 0), axis=1), np.inf, fq)
        seen = counts > 0
        fr = -np.where(seen[None, :], LL, 0.0).sum(axis=1)
        # identity of (b) for every memoriser of the true labels
        for i, (_, _, kind, data) in enumerate(PROGS):
            if kind == "mem":
                A, b = data
                if all(Fv[a] == ba for a, ba in zip(A, b)):
                    pred = sum(counts[a] * -math.log2(rates[a] if Fv[a] == 1 else 1 - rates[a]) for a in A)
                    assert abs((fq[0] - fq[i]) - pred) <= 1e-6 * max(1.0, pred)
                    nid += 1
        res = []
        for lam_name, lam in (("2", 2.0), ("8", 8.0), ("sqrt n", math.sqrt(n))):
            for obj, fit, fillfit in (("FQ", fq, 0.0), ("FR", fr, 0.0)):
                J = lam * LENS + fit
                Jfill = lam * FILL_LEN + fillfit
                best = min(np.min(J), Jfill)
                names = [PROGS[i][0] for i in np.flatnonzero(J <= best + 1e-9)]
                if Jfill <= best + 1e-9:
                    names.append("fill-in")
                res.append(f"{obj} lam={lam_name}: {'nu' if names == ['nu'] else ('fill-in' if names == ['fill-in'] else ('mem' if all(nm.startswith('mem') for nm in names) else '/'.join(names)))}")
        rows.append((n, res))
    for n, res in rows:
        print(f"    n = 2^{int(math.log2(n)):2d}: " + "; ".join(res))
    last = dict(r.split(": ") for r in rows[-1][1])
    assert last["FQ lam=2"] != "nu" and last["FQ lam=8"] != "nu" and last["FQ lam=sqrt n"] != "nu"
    assert last["FR lam=2"] == "nu" and last["FR lam=8"] == "nu"
    print(f"    identity (b) checked exactly for {nid} (n, memoriser) pairs; FQ rejects pi_0 at lambda = 2, 8 and")
    print("    sqrt(n) by n = 2^22; FR keeps pi_0 at lambda = 2 and 8 (its fit saturates once every input is seen)")


def partC():
    n = 0
    for nbar in (2, 5, 17):
        for _ in range(200):
            Fv = (rng.random(K) < rates).astype(int)
            LL = loglik_matrix(PROGS, rates, Fv)
            with np.errstate(invalid="ignore"):
                full = -LL.sum(axis=1)
            fq = nbar * full
            for lam in rng.uniform(0.2, 60.0, size=5):
                J1 = lam * LENS + fq
                J0 = (lam / nbar) * LENS + full
                b1 = min(np.min(J1), lam * FILL_LEN)
                b0 = min(np.min(J0), (lam / nbar) * FILL_LEN)
                s1 = set(np.flatnonzero(np.isclose(J1, b1, rtol=0, atol=1e-9)))
                s0 = set(np.flatnonzero(np.isclose(J0, b0, rtol=0, atol=1e-9)))
                assert s1 == s0
                assert np.isclose(lam * FILL_LEN <= b1 + 1e-9, (lam / nbar) * FILL_LEN <= b0 + 1e-9)
                n += 1
    print("=" * 96)
    print(f"(C) Prop 3.7(c): FQ with every input queried nbar times = full table at lambda/nbar: {n} cases; all equal")


if __name__ == "__main__":
    partA()
    partB()
    partC()
