"""E3: what a prover adds. Hidden-trigger circuits R(x_body) AND [T(x_S)],
where T accepts only the point x_S = a but is written so that the Part-1
rules cannot see it:
  * linear-hash triggers [M x_S = M a] (dense GF(2) map): Part 1 sees them
    via Gaussian elimination; resolution proofs grow exponentially;
  * SPN triggers [SPN(x_S) = SPN(a)] (S-boxes + dense linear layers): Part 1
    (unit propagation, probing, Gaussian elimination, small-cone rewriting,
    DFSB) finds nothing; a CDCL solver supplies a DRUP proof that C implies
    x_S = a, and the verifier then samples only R.
Records proof sizes, checking times, sample counts and intervals, against
Monte Carlo's cost. Also E4: surprise accounting on trigger circuits with
partially revealed triggers. Writes results/arguments.json, results/surprise.json.
"""

import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob import Product  # noqa
from rareprob.argument import domination_cnf, honest_proof, verify  # noqa
from rareprob.cnf import forced_input_literals  # noqa
from rareprob.dfsb import dfsb_estimate  # noqa
from rareprob.envelope import Envelope, envelope_estimate  # noqa
from rareprob.families import linear_hash_trigger, spn_trigger, trigger_circuit  # noqa
from rareprob.stats import mc_samples_needed  # noqa

EPS, DELTA = 0.1, 0.05
TIME_LIMIT = 1200  # seconds per instance for the prover and the verifier
PART1_LIMIT = 900  # seconds per instance for the prover-free procedures
OUT = os.path.join(os.path.dirname(__file__), "results")
os.makedirs(OUT, exist_ok=True)


def body_prob(C, S, a, body):
    """Exact Pr[R] by enumerating the body variables with x_S = a."""
    nb = len(body)
    X = np.zeros((1 << nb, C.n), dtype=bool)
    X[:, body] = ((np.arange(1 << nb)[:, None] >> np.arange(nb)) & 1).astype(bool)
    X[:, S] = np.array(a, dtype=bool)
    return float(C.eval_bits(X).mean())


def make_instance(fam, k, r, seed):
    rng = np.random.default_rng(seed)
    if fam == "linhash":
        C, S, a, body = linear_hash_trigger(12, k, rng)
    else:
        C, S, a, body = spn_trigger(12, k, r, rng)
    return C, S, a, body, rng


def instance_facts(fam, k, r, seed):
    """Size and exact p of an instance (p = Pr[R] 2^-k, a dyadic rational, exact in floating point)."""
    C, S, a, body, _ = make_instance(fam, k, r, seed)
    return dict(size=C.size, p=body_prob(C, S, a, body) * 2.0 ** (-k))


def run_part1(fam, k, r, seed):
    """The prover-free procedures: forcing (UP, probing, Gaussian elimination) and DFSB."""
    C, S, a, body, rng = make_instance(fam, k, r, seed)
    D = Product.uniform(C.n)
    p = body_prob(C, S, a, body) * 2.0 ** (-k)
    t = time.time()
    forced = forced_input_literals(C)
    e1 = dfsb_estimate(C, D, eps=EPS, delta=DELTA, rng=rng, node_budget=300)
    return dict(forced_by_part1=len(forced or {}), part1_lo=e1.lo, part1_hi=e1.hi,
                part1_ratio=e1.ratio, part1_cost=e1.evaluations, part1_seconds=time.time() - t,
                part1_contains=bool(e1.lo <= p <= e1.hi))


def run_part2(fam, k, r, seed):
    """Part 2: envelope = the trigger point, DRUP proof from a CDCL solver."""
    C, S, a, body, rng = make_instance(fam, k, r, seed)
    D = Product.uniform(C.n)
    p = body_prob(C, S, a, body) * 2.0 ** (-k)
    E = Envelope()
    E.root = E.PROD([E.lit(i, b) for i, b in zip(S, a)])
    t = time.time()
    pf = honest_proof(C, E)
    tp = time.time() - t
    t = time.time()
    v = verify(C, D, E, pf, eps=EPS, delta=DELTA, rng=rng)
    tv = time.time() - t
    return dict(family=fam, k=k, rounds=r, size=C.size, p=p, proof_steps=len(pf), prover_seconds=tp,
                proof_ok=v.proof_ok, verify_seconds=tv, part2_lo=v.estimate.lo, part2_hi=v.estimate.hi,
                part2_samples=v.estimate.samples, mc_cost=mc_samples_needed(p, EPS, DELTA),
                part2_contains=bool(v.estimate.lo <= p <= v.estimate.hi))


def _worker(fn, args, q):
    q.put(fn(*args))


def run_limited(fn, args, limit):
    """fn(*args) in a child process; None if it exceeds `limit` seconds."""
    import multiprocessing as mp
    q = mp.Queue()
    pr = mp.Process(target=_worker, args=(fn, args, q))
    pr.start()
    pr.join(limit)
    if pr.is_alive():
        pr.terminate()
        pr.join()
        return None
    return q.get()


def main():
    rows = []
    insts = [("linhash", 12, 0), ("linhash", 16, 0), ("linhash", 20, 0), ("linhash", 24, 0),
             ("spn", 8, 2), ("spn", 12, 2), ("spn", 16, 3), ("spn", 20, 3)]
    for idx, (fam, k, r) in enumerate(insts):
        args = (fam, k, r, 99 + idx)
        row = run_limited(run_part2, args, TIME_LIMIT)
        if row is None:
            row = dict(family=fam, k=k, rounds=r, timeout_seconds=TIME_LIMIT, **instance_facts(*args))
            print(f"{fam:8s} k={k:2d}: no proof within {TIME_LIMIT} s", flush=True)
        p1 = run_limited(run_part1, args, PART1_LIMIT)
        if p1 is None:
            row["part1_timeout_seconds"] = PART1_LIMIT
            p1txt = f"part1 no verdict within {PART1_LIMIT} s"
        else:
            row.update(p1)
            p1txt = (f"part1 [{p1['part1_lo']:.2e},{p1['part1_hi']:.2e}] ok={p1['part1_contains']} "
                     f"forced={p1['forced_by_part1']}")
        if "proof_steps" in row:
            print(f"{fam:8s} k={k:2d} size={row['size']:4d} p={row['p']:.2e} | {p1txt} | "
                  f"proof {row['proof_steps']} steps ({row['prover_seconds']:.1f}s), check {row['verify_seconds']:.1f}s, "
                  f"[{row['part2_lo']:.2e},{row['part2_hi']:.2e}] ok={row['part2_contains']} | MC {row['mc_cost']:.1e}",
                  flush=True)
        else:
            print(f"{fam:8s} k={k:2d} | {p1txt}", flush=True)
        rows.append(row)
        with open(os.path.join(OUT, "arguments.json"), "w") as f:
            json.dump(rows, f, indent=1)

    rng = np.random.default_rng(199)
    # E4: surprise accounting. Trigger of k = 40 bits; the argument reveals j
    # of them (subcube envelope on those j bits, domination is by unit
    # propagation); the verifier samples the rest.
    srows = []
    k = 40
    C, trig, rest, R = trigger_circuit(k + 12, k, rng, body_gates=30)
    D = Product.uniform(C.n)
    # exact p
    X = np.zeros((1 << 12, C.n), dtype=bool)
    X[:, rest] = ((np.arange(1 << 12)[:, None] >> np.arange(12)) & 1).astype(bool)
    for i, b in trig:
        X[:, i] = bool(b)
    p = float(C.eval_bits(X).mean()) * 2.0 ** (-k)
    for j in range(k, k - 14, -2):
        E = Envelope()
        E.root = E.PROD([E.lit(i, b) for i, b in trig[:j]])
        pf = honest_proof(C, E)
        v = verify(C, D, E, pf, eps=0.2, delta=DELTA, rng=rng, max_samples=2 * 10**7)
        srows.append(dict(revealed=j, unexplained_bits=k - j, argument_bits=j * (1 + int(np.ceil(np.log2(C.n)))),
                          samples=v.estimate.samples, lo=v.estimate.lo, hi=v.estimate.hi, p=p,
                          contains=bool(v.estimate.lo <= p <= v.estimate.hi), ratio=v.estimate.ratio))
        print(f"revealed {j:2d}/{k}: samples {v.estimate.samples:9d} ratio {v.estimate.ratio:.3f} "
              f"contains {srows[-1]['contains']}", flush=True)
        with open(os.path.join(OUT, "surprise.json"), "w") as f:
            json.dump(srows, f, indent=1)


if __name__ == "__main__":
    main()
