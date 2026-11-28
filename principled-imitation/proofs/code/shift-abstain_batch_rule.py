"""Checks for Theorem 7.6 of proofs/shift-abstain.md (the batch rule Bat_eps, statement Ab5 of the note).

Setting.  A finite class H_b of functions X -> Y, the human f in H_b, n training inputs drawn
independently from a law P on X.  V is the set of members that agree with f on the training inputs,
h the first member of V.  Given a batch z_1..z_m and eps in (0, 1], Bat_eps repeats: while some c in V
differs from h at more than eps*m batch inputs that are not yet refused, refuse all batch inputs at
which c and h differ.  Then it answers h at the others.

What is checked.
 (A) exact, on random instances and batches of several kinds (from P, uniform, heavy repetition of a
     disputed input, the set where h is wrong, unasked inputs only): item 1 (at most eps*m wrong
     answers), item 2 (T < 1/eps, T <= m, T <= |V| - 1), the description of the refused batch inputs as
     those in the union of T disagreement sets, and, for eps*m < 1, that the rule is the unanimity rule.
 (B) item 3: the probability of the bad event "two members that agree on the sample differ on a set of
     P-mass above gamma" is computed exactly for small instances (all samples enumerated) and compared
     with delta/2; on the good event P(R(z)) <= T*gamma is checked for the batches tried.
 (B2) the same event by simulation for a class of 16 functions on 200 inputs, where gamma < 1.
 (C) item 4: for batches drawn from P, the frequency of "something is refused".
 (D) Example 7.9(c): the rule that works input by input (refuse an input when some member that disputes
     it has no budget left) is as sound and is led to refuse every later unasked input.
 (E) Example 7.9(b): a batch that is one run with related calls is refused entirely; a batch of many
     runs is not.

Run:  python3 shift-abstain_batch_rule.py        (fixed seed; about one minute)
"""
import itertools
import math
import numpy as np

rng = np.random.default_rng(20261116)


def version_space(H, f, sample):
    """Indices (in the order of H) of the members that agree with f on the sample."""
    if len(sample) == 0:
        return np.arange(len(H))
    s = np.asarray(sample)
    return np.nonzero((H[:, s] == f[s]).all(axis=1))[0]


def bat(H, V, batch, eps):
    """The batch rule.  Returns (accepted mask over the batch, list of chosen members, index of h)."""
    z = np.asarray(batch)
    m = len(z)
    h = V[0]
    dis = H[V][:, z] != H[h][z]          # |V| x m: member c disputes batch input j
    acc = np.ones(m, dtype=bool)
    chosen = []
    while True:
        counts = (dis & acc).sum(axis=1)
        over = np.nonzero(counts > eps * m)[0]
        if len(over) == 0:
            break
        c = over[0]                      # the first such member in the order of H
        acc &= ~dis[c]
        chosen.append(int(V[c]))
    return acc, chosen, int(h)


def random_class(nx, ny, size):
    """`size` distinct functions on nx inputs with ny answers; each is a base function changed on a
    random set, so that disagreement sets overlap.  Returned in random order."""
    base = rng.integers(0, ny, size=nx)
    seen = {tuple(base)}
    rows = [base]
    while len(rows) < size:
        g = base.copy()
        # mostly small changes; sometimes any number of inputs, so that every function can occur
        k = int(rng.integers(1, max(2, nx // 2))) if rng.random() < 0.8 else int(rng.integers(1, nx + 1))
        idx = rng.choice(nx, size=k, replace=False)
        g[idx] = rng.integers(0, ny, size=k)
        if tuple(g) not in seen:
            seen.add(tuple(g))
            rows.append(g)
    H = np.array(rows)
    return H[rng.permutation(size)]


def part_A():
    print("(A) items 1 and 2, exact, on random instances")
    n_inst = n_pairs = viol = unanim_checked = 0
    worst_ratio = 0.0
    most_steps = 0
    for trial in range(1500):
        nx = int(rng.integers(6, 15))
        ny = int(rng.integers(2, 4))
        size = int(rng.integers(2, 33))
        H = random_class(nx, ny, size)
        f = H[int(rng.integers(0, size))]
        support = rng.choice(nx, size=int(rng.integers(2, nx + 1)), replace=False)
        p = np.zeros(nx)
        p[support] = rng.dirichlet(np.ones(len(support)))
        n = int(rng.integers(0, 9))
        sample = rng.choice(nx, size=n, p=p) if n else np.array([], dtype=int)
        V = version_space(H, f, sample)
        assert (H[V] == f).all(axis=1).any()          # the human is in V
        h = V[0]
        n_inst += 1
        disputes_per_input = (H[V] != H[h]).sum(axis=0)
        wrong_set = np.nonzero(H[h] != f)[0]
        unasked = np.setdiff1d(np.arange(nx), sample)
        unanimous = disputes_per_input == 0
        for kind in range(5):
            m = int(rng.integers(1, 41))
            if kind == 0:      # from P
                batch = rng.choice(nx, size=m, p=p)
            elif kind == 1:    # uniform on all inputs, off the support too
                batch = rng.integers(0, nx, size=m)
            elif kind == 2:    # heavy repetition of the most disputed input
                batch = np.where(rng.random(m) < 0.6, int(np.argmax(disputes_per_input)),
                                 rng.integers(0, nx, size=m))
            elif kind == 3:    # the set where h is wrong, mixed with other inputs
                D = wrong_set if len(wrong_set) else np.array([0])
                batch = np.where(rng.random(m) < 0.5, rng.choice(D, size=m), rng.integers(0, nx, size=m))
            else:              # unasked inputs only
                rest = unasked if len(unasked) else np.array([0])
                batch = rng.choice(rest, size=m)
            for eps in (1.0, 0.5, 0.3, 0.2, 0.1, 0.05, 1.0 / (m + 1)):
                acc, chosen, _ = bat(H, V, batch, eps)
                wrong = int(((H[h][batch] != f[batch]) & acc).sum())
                T = len(chosen)
                ok = wrong <= eps * m + 1e-12 and T < 1.0 / eps + 1e-12 and T <= m and T <= len(V) - 1
                R = np.zeros(nx, dtype=bool)
                for c in chosen:
                    R |= H[c] != H[h]
                ok = ok and np.array_equal(~acc, R[batch])
                if eps * m < 1:                      # the unanimity rule
                    ok = ok and np.array_equal(acc, unanimous[batch]) and wrong == 0
                    unanim_checked += 1
                viol += 0 if ok else 1
                worst_ratio = max(worst_ratio, wrong / (eps * m))
                most_steps = max(most_steps, T)
                n_pairs += 1
    print(f"    instances {n_inst}; (batch, eps) pairs {n_pairs}, of them with eps*m < 1: {unanim_checked}")
    print(f"    violations of items 1, 2 or of the description of the refused set: {viol}")
    print(f"    largest (wrong answers)/(eps*m) observed: {worst_ratio:.4f} (item 1: at most 1);"
          f" largest number of steps T: {most_steps}")


def part_B():
    print("(B) item 3: the bad event, exact for small instances")
    worst = 0.0
    viol_event = viol_mass = 0
    n_good_batches = 0
    rows = []
    for trial in range(40):
        nx = int(rng.integers(4, 6))
        b = int(rng.integers(1, 3))
        H = random_class(nx, 2, 2 ** b)
        k = len(H)
        f = H[int(rng.integers(0, k))]
        p = rng.dirichlet(np.ones(nx))
        n = int(rng.integers(5, 8))
        delta = float(rng.choice([0.9, 0.5, 0.25]))
        gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
        eq = H[:, None, :] == H[None, :, :]                       # k x k x nx
        mass = ((~eq) * p).sum(axis=2)                            # P-mass of the disagreement sets
        heavy = np.triu(mass > gamma, 1)
        bad_prob = 0.0
        for sample in itertools.product(range(nx), repeat=n):
            s = np.array(sample)
            agree = eq[:, :, s].all(axis=2)
            if (agree & heavy).any():
                bad_prob += float(np.prod(p[s]))
            else:
                V = version_space(H, f, s)
                m = int(rng.integers(1, 21))
                batch = rng.integers(0, nx, size=m)
                eps = float(rng.choice([0.5, 0.25, 0.1]))
                acc, chosen, h = bat(H, V, batch, eps)
                R = np.zeros(nx, dtype=bool)
                for c in chosen:
                    R |= H[c] != H[h]
                n_good_batches += 1
                if p[R].sum() > len(chosen) * gamma + 1e-12:
                    viol_mass += 1
        viol_event += 1 if bad_prob > delta / 2 + 1e-12 else 0
        worst = max(worst, bad_prob / delta)
        rows.append((nx, b, n, delta, gamma, bad_prob))
    print(f"    instances 40, all samples enumerated; Pr[bad event] > delta/2 in {viol_event} of them")
    print(f"    largest Pr[bad event]/delta: {worst:.4f} (the proof gives less than 1/2)")
    print(f"    batches on the good event: {n_good_batches}; violations of P(R(z)) <= T*gamma: {viol_mass}")
    print(f"    instances with gamma < 1: {sum(1 for r in rows if r[4] < 1)}; with Pr[bad event] > 0:"
          f" {sum(1 for r in rows if r[5] > 0)}")
    for r in sorted(rows, key=lambda r: -r[5] / r[3])[:4]:
        print("    largest ratios: |X|=%d b=%d n=%d delta=%.2f gamma=%.3f Pr[bad]=%.5f" % r)


def part_B2():
    print("(B2) item 3 where gamma < 1: 16 functions on 200 inputs, P uniform, by simulation")
    nx = 200
    b = 4
    delta = 0.1
    for n in (40, 80, 160):
        gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
        bad = 0
        trials = 3000
        largest = 0.0
        for _ in range(trials):
            base = rng.integers(0, 2, size=nx)
            H = np.tile(base, (16, 1))
            for i in range(1, 16):
                idx = rng.choice(nx, size=int(rng.integers(1, 40)), replace=False)
                H[i, idx] = 1 - H[i, idx]
            s = rng.integers(0, nx, size=n)
            Hs = H[:, s]
            agree = (Hs[:, None, :] == Hs[None, :, :]).all(axis=2)
            mass = (H[:, None, :] != H[None, :, :]).mean(axis=2)
            w = float((mass * agree).max())
            largest = max(largest, w)
            bad += 1 if w > gamma else 0
        print(f"    n={n:4d} gamma={gamma:.4f}: bad event in {bad} of {trials} samples (delta/2 = {delta / 2});"
              f" largest mass of a pair that agrees on the sample: {largest:.4f}")


def part_C():
    print("(C) item 4: batches drawn from P, eps = e^2*gamma, eps*m >= b ln 2 + ln(1/delta')")
    nx = 400
    b = 4
    n = 4000
    delta = 0.1
    dprime = 0.1
    gamma = (2 * b * math.log(2) + math.log(1 / delta)) / n
    eps = math.e ** 2 * gamma
    m = math.ceil((b * math.log(2) + math.log(1 / dprime)) / eps)
    trials = 1500
    good = refused_any = 0
    for _ in range(trials):
        base = rng.integers(0, 2, size=nx)
        H = np.tile(base, (16, 1))
        for i in range(1, 16):
            idx = rng.choice(nx, size=int(rng.integers(1, 6)), replace=False)
            H[i, idx] = 1 - H[i, idx]
        f = H[int(rng.integers(0, 16))]
        s = rng.integers(0, nx, size=n)
        Hs = H[:, s]
        agree = (Hs[:, None, :] == Hs[None, :, :]).all(axis=2)
        mass = (H[:, None, :] != H[None, :, :]).mean(axis=2)
        if float((mass * agree).max()) > gamma:
            continue
        good += 1
        V = version_space(H, f, s)
        batch = rng.integers(0, nx, size=m)
        acc, chosen, _ = bat(H, V, batch, eps)
        refused_any += 0 if acc.all() else 1
    print(f"    gamma={gamma:.5f} eps={eps:.5f} m={m}: the event of item 3 held in {good} of {trials} samples;"
          f" there something was refused in {refused_any} batches (item 4: a fraction below {dprime})")
    # the same with members that differ from the base on many inputs, so that V keeps several members
    n2 = 60
    gamma2 = (2 * b * math.log(2) + math.log(1 / delta)) / n2
    eps2 = min(1.0, math.e ** 2 * gamma2)
    print(f"    (with n={n2}: gamma={gamma2:.3f}, e^2*gamma={math.e ** 2 * gamma2:.2f} >= 1: item 4 is empty there)")


def part_D():
    print("(D) Example 7.9(c): the rule that works input by input")
    N = 1000          # inputs 1..N carry the law P (uniform); input 0 is off the law
    n = 100
    m = 2000
    eps = 0.05
    budget = math.floor(eps * m)
    sample = rng.integers(1, N + 1, size=n)
    asked = set(int(x) for x in sample)
    # members: h = 0 everywhere; c_i = 1 at 0 and at i (i = 1..N).  The human is h.  V = {h} + {c_i : i unasked}.
    unasked = [i for i in range(1, N + 1) if i not in asked]
    batch = [0] * budget + [int(x) for x in rng.integers(1, N + 1, size=m - budget)]
    # input by input: answer h(z) = 0 unless a member that disputes z has no budget left
    count = {i: 0 for i in unasked}      # answered inputs in the disagreement set of c_i
    answered = refused = refused_from_P = 0
    for z in batch:
        disputing = unasked if z == 0 else ([z] if z in count else [])
        if any(count[i] >= budget for i in disputing):
            refused += 1
            refused_from_P += 1 if z != 0 else 0
        else:
            answered += 1
            for i in disputing:
                count[i] += 1
    print(f"    input by input: answered {answered}, refused {refused}; of the {m - budget} draws from P it"
          f" refused {refused_from_P}, namely all unasked ones (P-mass of the unasked inputs {len(unasked) / N:.3f});"
          f" no answer is wrong (the human is h)")
    nx = N + 1
    H = np.zeros((1 + len(unasked), nx), dtype=int)
    for r, i in enumerate(unasked, start=1):
        H[r, 0] = 1
        H[r, i] = 1
    V = np.arange(len(H))
    acc, chosen, _ = bat(H, V, batch, eps)
    z = np.array(batch)
    print(f"    batch rule, same batch: steps T = {len(chosen)}; refused {int(((~acc) & (z == 0)).sum())} copies"
          f" of 0 and {int(((~acc) & (z != 0)).sum())} of the {m - budget} draws from P"
          f" (the copies of the one input at which the chosen member differs from h)")
    batch3 = [0] * (budget // 2) + [int(x) for x in rng.integers(1, N + 1, size=m - budget // 2)]
    acc3, chosen3, _ = bat(H, V, batch3, eps)
    print(f"    batch rule with {budget // 2} copies of 0 and {m - budget // 2} draws from P:"
          f" steps T = {len(chosen3)}, refused {int((~acc3).sum())} inputs")


def part_E():
    print("(E) Example 7.9(b): one run with related calls, and many runs")
    N = 500           # blocks; a run makes L calls, all in one uniformly chosen block
    L = 20
    n = 100
    eps = 0.1
    nx = N * L
    block = np.repeat(np.arange(N), L)
    sample = rng.integers(0, nx, size=n)       # a uniformly chosen call of a run is a uniform input
    asked_blocks = sorted(set(int(block[x]) for x in sample))
    free = [i for i in range(N) if i not in set(asked_blocks)]
    H = np.zeros((1 + len(free), nx), dtype=int)      # h = 0; c_i = 1 on block i, for the unasked blocks
    for r, i in enumerate(free, start=1):
        H[r, block == i] = 1
    V = np.arange(len(H))
    runs_refused = 0
    trials = 2000
    for _ in range(trials):
        i = int(rng.integers(0, N))
        batch = np.arange(i * L, (i + 1) * L)
        acc, chosen, _ = bat(H, V, batch, eps)
        runs_refused += 0 if acc.any() else 1
    print(f"    batch = one run: {runs_refused} of {trials} runs refused entirely"
          f" (fraction of unasked blocks {len(free) / N:.3f})")
    blocks = rng.integers(0, N, size=400)
    batch = np.concatenate([np.arange(i * L, (i + 1) * L) for i in blocks])
    acc, chosen, _ = bat(H, V, batch, eps)
    most = int(np.bincount(blocks, minlength=N).max()) * L
    print(f"    batch = 400 runs ({len(batch)} calls): refused {int((~acc).sum())} calls, steps T = {len(chosen)};"
          f" a member of one unasked block as the human would make at most {most} answers wrong"
          f" (eps*m = {eps * len(batch):.0f})")


if __name__ == "__main__":
    part_A()
    part_B()
    part_B2()
    part_C()
    part_D()
    part_E()
