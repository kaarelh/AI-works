"""Part 2: a sound argument system for Pr_D[C = 1] (the ENVELOPE rule of PCIS).

An argument is (phi, pi):
  phi  an envelope with literal leaves and 0/1 constants, SUM, and
       decomposable PROD, so phi is integer-valued and [phi >= 1] = supp phi;
  pi   a DRUP refutation of  Tseitin(C) & [C = 1] & Tseitin(supp phi) & [supp phi = 0],
       i.e. a propositional proof that C(x) = 1 implies phi(x) >= 1.

Verifier:
  1. checks that phi is well formed, treating it as untrusted data: node kinds,
     literal indices, children that precede their parents (so the DAG is
     acyclic), and decomposability of every PROD with supports RECOMPUTED from
     the leaves (the stored supports are the prover's claim and are ignored);
     the checked structure is copied into a fresh Envelope, which is used for
     everything that follows;
  2. checks pi with the trusted RUP checker;
  3. runs the envelope importance sampler and outputs an interval.
A malformed envelope is a failed deductive certificate: the output is the
trivial interval [0, 1]. If pi is missing or invalid, the verifier still
outputs a valid LOWER bound (the upper end becomes +inf): the importance
weights C/phi lie in [0, 1] on the proposal's support because phi is
integer-valued, and their mean is Pr[C = 1 and phi > 0] / E[phi] <= p / E[phi].

The verifier has no EXACT rule: it never trusts a claim of determinism (a
d-DNNF whose OR-gates are not checked to be deterministic is only a DNNF, and
reading it as a d-DNNF can overcount; x OR x would get mass 2 q).

Soundness (every circuit, every argument): Pr[p not in interval] <= delta.
Completeness: if C has an envelope with K = E[phi]/p and a DRUP proof of
size s, the honest verifier's work is O(s-checking + K log(1/delta)/eps^2
samples of cost O(|C| + |phi|)).
"""

from __future__ import annotations

import math
import operator
from dataclasses import dataclass

import numpy as np

from .circuit import Circuit
from .cnf import tseitin
from .dist import Product
from .envelope import Envelope, envelope_estimate
from .rup import RUPChecker
from .stats import Estimate

_LEAF_KINDS = ("ONE", "ZERO", "LIT")
_GATE_KINDS = ("SUM", "PROD")


def _index(v) -> int:
    """v as a Python int if it is an integer (not a bool, float or string)."""
    if isinstance(v, bool):
        raise TypeError("booleans are not indices")
    return operator.index(v)


def sanitize_envelope(env, n: int) -> Envelope | None:
    """A verified copy of an untrusted literal envelope over n variables, or
    None if it is malformed.

    The copy keeps the node indices, kinds and child order of env (so the
    support circuit, and hence the domination CNF, is the one the prover
    encoded), with supports recomputed from the leaves. Accepted: ONE, ZERO,
    LIT (i, b) with 0 <= i < n and b in {0, 1}; SUM and PROD with a nonempty
    tuple of children, each with a smaller index than its parent; every PROD
    decomposable with respect to the recomputed supports. Box leaves are not
    accepted in arguments.
    """
    try:
        kinds = list(env.kind)
        datas = list(env.data)
        root = _index(env.root)
    except Exception:
        return None
    m = len(kinds)
    if len(datas) != m or not 0 <= root < m:
        return None
    # cone of the root, rejecting forward references (children must precede parents)
    cone, stack = set(), [root]
    clean: dict[int, tuple] = {}
    while stack:
        u = stack.pop()
        if u in cone:
            continue
        cone.add(u)
        k = kinds[u]
        if not isinstance(k, str):
            return None
        d = datas[u]
        try:
            if k in ("ONE", "ZERO"):
                clean[u] = (k, None)
            elif k == "LIT":
                i, b = (_index(t) for t in d)
                if not (0 <= i < n and b in (0, 1)):
                    return None
                clean[u] = (k, (i, b))
            elif k in _GATE_KINDS:
                ch = tuple(_index(c) for c in d)
                if not ch or any(not 0 <= c < u for c in ch):
                    return None
                clean[u] = (k, ch)
                stack.extend(ch)
            else:
                return None
        except Exception:
            return None
    E = Envelope()
    sup = [0] * m
    for u in range(m):
        if u not in cone:  # placeholder that nothing refers to
            E.kind.append("ZERO")
            E.data.append(None)
            E.sup.append(0)
            continue
        k, d = clean[u]
        if k == "LIT":
            sup[u] = 1 << d[0]
        elif k in _GATE_KINDS:
            acc = 0
            for c in d:  # children precede u, so sup[c] is final
                if k == "PROD" and acc & sup[c]:
                    return None  # not decomposable
                acc |= sup[c]
            sup[u] = acc
        E.kind.append(k)
        E.data.append(d)
        E.sup.append(sup[u])
    E.root = root
    return E


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
    from .ve import binarize

    C = binarize(C)
    B = binarize(support_circuit(env, C.n))
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
    if D.n != C.n:
        raise ValueError("D and C have different numbers of variables")
    # 1. well-formedness, on a verified copy (the argument is untrusted data)
    env = sanitize_envelope(env, C.n)
    if env is None:
        return Verdict(Estimate(0.0, 0.0, 1.0, 0, 0, delta, "malformed envelope: trivial interval"),
                       False, 0)
    # 2. domination certificate
    ok = False
    steps = 0
    if proof is not None:
        try:
            steps = len(proof)
            ok = RUPChecker(domination_cnf(C, env)).check_refutation(proof)
        except Exception:
            ok = False
    # 3. sampling
    est = envelope_estimate(C, D, env, eps=eps, delta=delta, max_samples=max_samples, rng=rng)
    if not ok:
        est = Estimate(est.lo, est.lo, math.inf, est.samples, est.evaluations, delta,
                       est.note + "; no valid domination proof: lower bound only")
    return Verdict(est, ok, steps)
