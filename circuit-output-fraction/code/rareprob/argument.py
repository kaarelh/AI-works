"""Part 2: a sound argument system for Pr_D[C = 1].

An argument is (phi, pi):
  phi  an envelope (literal leaves, SUM, decomposable PROD), and
  pi   a DRUP refutation of  Tseitin(C) & [C = 1] & Tseitin(supp phi) & [supp phi = 0],
       i.e. a propositional proof that C(x) = 1 implies phi(x) >= 1.

Verifier:
  1. checks that phi is well formed (PROD children have disjoint supports);
  2. checks pi with the trusted RUP checker;
  3. runs the envelope importance sampler and outputs an interval.
If pi is missing or invalid, the verifier still outputs a valid LOWER bound
(the upper end becomes +inf): the importance weights C/phi lie in [0, 1]
on the proposal's support whatever phi is, and their mean is
Pr[C = 1 and phi > 0] / E[phi] <= p / E[phi].

Soundness (every circuit, every argument): Pr[p not in interval] <= delta.
Completeness: if C has an envelope with K = E[phi]/p and a DRUP proof of
size s, the honest verifier's work is O(s-checking + K log(1/delta)/eps^2
samples of cost O(|C| + |phi|)).
"""

from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np

from .circuit import Circuit
from .cnf import tseitin
from .dist import Product
from .envelope import Envelope, envelope_estimate
from .rup import RUPChecker
from .stats import Estimate


def support_circuit(env: Envelope, n: int) -> Circuit:
    """Boolean circuit for [phi(x) > 0] (SUM -> OR, PROD -> AND)."""
    B = Circuit(n)
    m: dict[int, int] = {}
    for u in env.cone():
        k = env.kind[u]
        if k == "ONE":
            m[u] = B.const(1)
        elif k == "ZERO":
            m[u] = B.const(0)
        elif k == "LIT":
            i, b = env.data[u]
            m[u] = B.lit(i, b)
        elif k == "SUM":
            m[u] = B.OR(*[m[c] for c in env.data[u]])
        elif k == "PROD":
            m[u] = B.AND(*[m[c] for c in env.data[u]])
        else:
            raise ValueError("argument envelopes use literal leaves only")
    B.output = m[env.root]
    return B


def domination_cnf(C: Circuit, env: Envelope) -> list[list[int]]:
    """CNF that is unsatisfiable iff C(x) = 1 implies phi(x) > 0."""
    B = support_circuit(env, C.n)
    off = len(C.ops)  # B's gate variables live after C's
    cls = tseitin(C) + [[C.output + 1]]
    cls += tseitin(B, offset=off)
    outB = B.output + 1 if B.output < C.n else B.output + 1 + off
    cls.append([-outB])
    return cls


def honest_proof(C: Circuit, env: Envelope, solver: str = "g4"):
    """Prover side: DRUP refutation from a CDCL solver, or None if C does not
    imply supp(phi)."""
    from pysat.solvers import Solver

    cls = domination_cnf(C, env)
    with Solver(name=solver, bootstrap_with=cls, with_proof=True) as s:
        if s.solve():
            return None
        proof = s.get_proof()
    from .rup import parse_drup

    return parse_drup(proof)


@dataclass
class Verdict:
    estimate: Estimate
    proof_ok: bool
    proof_steps: int


def verify(C: Circuit, D: Product, env: Envelope, proof, eps: float = 0.1, delta: float = 0.05,
           max_samples: int = 10**6, rng=None) -> Verdict:
    rng = np.random.default_rng() if rng is None else rng
    # 1. well-formedness (PROD decomposability is enforced by Envelope.PROD,
    #    but re-check: the argument is untrusted data)
    for u in env.cone():
        if env.kind[u] == "PROD":
            acc = 0
            for c in env.data[u]:
                if acc & env.sup[c]:
                    raise ValueError("malformed envelope")
                acc |= env.sup[c]
        if env.kind[u] == "BOX":
            raise ValueError("argument envelopes use literal leaves only")
    # 2. domination certificate
    ok = False
    steps = 0
    if proof is not None:
        steps = len(proof)
        ok = RUPChecker(domination_cnf(C, env)).check_refutation(proof)
    # 3. sampling
    est = envelope_estimate(C, D, env, eps=eps, delta=delta, max_samples=max_samples, rng=rng)
    if not ok:
        est = Estimate(est.lo, est.lo, math.inf, est.samples, est.evaluations, delta,
                       est.note + "; no valid domination proof: lower bound only")
    return Verdict(est, ok, steps)
