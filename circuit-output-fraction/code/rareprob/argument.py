"""Part 2: a sound argument system for Pr_D[C = 1] (the ENVELOPE rule of PCIS).

An argument is (phi, pi):
  phi  an envelope with literal leaves and 0/1 constants, SUM, and
       decomposable PROD, so phi is integer-valued and [phi >= 1] = supp phi;
  pi   a DRUP refutation of  Tseitin(C) & [C = 1] & Tseitin(supp phi) & [supp phi = 0],
       i.e. a propositional proof that C(x) = 1 implies phi(x) >= 1.

Both are untrusted data. The verifier never reads a derived field of the
prover's objects (stored supports, hash-consing tables, boxes):
  1. it copies phi into a fresh Envelope, reading only kinds, leaf and child
     data and the root, once each, and checks the copy: node kinds (exact
     strings), literal indices and values, children that precede their
     parents (so the DAG is acyclic), and decomposability of every PROD with
     supports RECOMPUTED bottom-up from the leaves. This happens whether or
     not a proof is given, since the lower bound also needs the exact mass and
     sampler of phi. The copy is used for everything that follows;
  2. it copies pi into fresh lists of Python ints (pi must be DRUP text, as
     str or bytes, or a plain list/tuple of clauses of ints) and checks it with
     the trusted RUP checker;
  3. it runs the envelope importance sampler and outputs an interval.
A malformed envelope is a failed deductive certificate: the output is the
trivial interval [0, 1]. If pi is missing, malformed or invalid, the verifier
still outputs a valid LOWER bound (the upper end becomes +inf): the importance
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
import re
from dataclasses import dataclass

import numpy as np

from .circuit import Circuit
from .cnf import tseitin
from .dist import Product
from .envelope import Envelope, envelope_estimate
from .rup import RUPChecker
from .stats import Estimate

_KINDS = {"ONE": "ONE", "ZERO": "ZERO", "LIT": "LIT", "SUM": "SUM", "PROD": "PROD"}
_GATE_KINDS = ("SUM", "PROD")
_DRUP_INT = re.compile(r"-?[0-9]{1,18}")  # longer literals are out of range anyway


def _index(v) -> int:
    """v as a Python int if it is an integer (not a bool, float or string)."""
    if isinstance(v, bool):
        raise TypeError("booleans are not indices")
    return operator.index(v)


def sanitize_envelope(env, n: int) -> Envelope | None:
    """A verified copy of an untrusted literal envelope over n variables, or
    None if it is malformed.

    Only env.kind, env.data and env.root are read, each entry once; derived
    fields (env.sup, the hash-consing table, boxes) are ignored. The copy
    keeps the node indices, kinds and child order of env (so the support
    circuit, and hence the domination CNF, is the one the prover encoded),
    with supports recomputed bottom-up from the leaves. Accepted: kinds that
    are exact strings ONE, ZERO, LIT, SUM, PROD; LIT (i, b) with integers
    0 <= i < n and b in {0, 1}; SUM and PROD with a nonempty tuple of integer
    children, each with a smaller index than its parent; every PROD
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
        # exact str only: a str subclass could compare equal to several kinds
        k = _KINDS.get(k) if type(k) is str else None
        if k is None:
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
            else:
                ch = tuple(_index(c) for c in d)
                if not ch or any(not 0 <= c < u for c in ch):
                    return None
                clean[u] = (k, ch)
                stack.extend(ch)
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


def _parse_drup_text(text: str) -> list[list[int]] | None:
    """Clauses of DRUP text (whitespace-separated integers, each clause ended
    by 0, a deletion prefixed by 'd'), deletions dropped; None if malformed."""
    out: list[list[int]] = []
    cur: list[int] = []
    dele = False
    for tok in text.split():
        if tok == "d":
            if cur or dele:
                return None
            dele = True
            continue
        if not _DRUP_INT.fullmatch(tok):
            return None
        lit = int(tok)
        if lit:
            cur.append(lit)
            continue
        if not dele:
            out.append(cur)
        cur, dele = [], False
    if cur or dele:  # unterminated clause
        return None
    return out


def canonical_proof(proof) -> list[list[int]] | None:
    """A fresh copy of an untrusted DRUP proof as a list of clauses (lists of
    nonzero Python ints), deletions dropped, or None if the proof is not in an
    accepted format:
      * DRUP text, as str or ASCII bytes (exact types);
      * a list or tuple (exact types, not subclasses) of steps, each a list or
        tuple of ints (Python or numpy integers, not bools), a deletion step
        starting with the string 'd' (the output of rup.parse_drup).
    Every step is read once, so the checker sees exactly the clauses copied
    here. Dropping deletions is sound: the checker then keeps more clauses.
    """
    if type(proof) is bytes:
        try:
            proof = proof.decode("ascii")
        except UnicodeDecodeError:
            return None
    if type(proof) is str:
        return _parse_drup_text(proof)
    if type(proof) not in (list, tuple):
        return None
    out: list[list[int]] = []
    for step in list(proof):
        if type(step) not in (list, tuple):
            return None
        s = list(step)
        dele = bool(s) and type(s[0]) is str
        if dele:
            if s[0] != "d":
                return None
            s = s[1:]
        cl = []
        for lit in s:
            if not (type(lit) is int or isinstance(lit, np.integer)):
                return None
            lit = operator.index(lit)
            if lit == 0:
                return None
            cl.append(lit)
        if not dele:
            out.append(cl)
    return out


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
    proof_steps: int  # clauses in the accepted copy of the proof (deletions dropped)


def verify(C: Circuit, D: Product, env: Envelope, proof, eps: float = 0.1, delta: float = 0.05,
           max_samples: int = 10**6, rng=None) -> Verdict:
    rng = np.random.default_rng() if rng is None else rng
    if D.n != C.n:
        raise ValueError("D and C have different numbers of variables")
    # 1. well-formedness, on a verified copy (the argument is untrusted data);
    #    done with or without a proof: the lower bound needs the exact mass and sampler
    env = sanitize_envelope(env, C.n)
    if env is None:
        return Verdict(Estimate(0.0, 0.0, 1.0, 0, 0, delta, "malformed envelope: trivial interval"),
                       False, 0)
    # 2. domination certificate, checked on a copy of the proof made of plain ints
    ok = False
    steps = 0
    clauses = canonical_proof(proof) if proof is not None else None
    if clauses is not None:
        steps = len(clauses)
        try:
            cnf = domination_cnf(C, env)
            nv = max((abs(l) for c in cnf for l in c), default=0)
            # literals outside the CNF's variables are rejected (honest DRUP proofs
            # never use them), which keeps the checker's memory polynomial
            if all(abs(l) <= nv for c in clauses for l in c):
                ok = RUPChecker(cnf).check_refutation(clauses)
        except Exception:
            ok = False
    # 3. sampling
    est = envelope_estimate(C, D, env, eps=eps, delta=delta, max_samples=max_samples, rng=rng)
    if not ok:
        est = Estimate(est.lo, est.lo, math.inf, est.samples, est.evaluations, delta,
                       est.note + "; no valid domination proof: lower bound only")
    return Verdict(est, ok, steps)
