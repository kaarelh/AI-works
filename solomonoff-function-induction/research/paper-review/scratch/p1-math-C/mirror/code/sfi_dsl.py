"""A tiny enumerated program class for exact Bayes-mixture (SFI-proxy) computations.

Programs map a nonempty bitstring x to an integer.  Grammar:

    Prog ::= E                      (probability p_plain)
           | if C then E else E     (probability 1 - p_plain)
    E    ::= leaf                    (probability 1/2, each of 6 leaves 1/12)
           | E op E                 (probability 1/2, each of + - * 1/6), depth <= depth_max
    leaf ::= len | ones | zeros | 0 | 1 | 2
    C    ::= even(leaf) | leaf < leaf | leaf == leaf | first(x)=1 | last(x)=1
             (each of the 5 forms with probability 1/5, leaves uniform)

At the depth limit only leaves are allowed, so the prior is a sub-probability
(the truncated mass is simply lost).  Programs are grouped by their value vector on a
finite domain, which is exact for every question asked on that domain.

The Bayes mixture over this class is an "x-only" predictor (each program is a
deterministic function), i.e. a computable proxy for SFI's program mixture.
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass

import numpy as np

LEAVES = ["len", "ones", "zeros", "0", "1", "2"]
OPS = ["+", "-", "*"]


def all_strings(lengths):
    out = []
    for L in lengths:
        for bits in itertools.product("01", repeat=L):
            out.append("".join(bits))
    return out


def leaf_values(domain):
    lens = np.array([len(s) for s in domain], dtype=np.int64)
    ones = np.array([s.count("1") for s in domain], dtype=np.int64)
    zeros = lens - ones
    n = len(domain)
    return {
        "len": lens, "ones": ones, "zeros": zeros,
        "0": np.zeros(n, dtype=np.int64), "1": np.ones(n, dtype=np.int64),
        "2": np.full(n, 2, dtype=np.int64),
    }


@dataclass
class ExprClass:
    values: np.ndarray   # (num_classes, |domain|) int64
    mass: np.ndarray     # (num_classes,) prior mass (sum over expressions with these values)
    example: list        # one expression string per class (the most probable one)


def enumerate_expressions(domain, depth_max=2) -> ExprClass:
    lv = leaf_values(domain)
    # level d: list of (value_vector, mass, string); deduplicate at the end of each level
    level = []
    for name in LEAVES:
        level.append((lv[name], 1.0 / 12.0, name))
    level = _dedup(level)
    for _d in range(depth_max):
        new = []
        for name in LEAVES:
            new.append((lv[name], 1.0 / 12.0, name))
        vals = np.stack([v for v, _, _ in level])
        masses = np.array([m for _, m, _ in level])
        strs = [s for _, _, s in level]
        for op in OPS:
            for i in range(len(level)):
                a = vals[i]
                if op == "+":
                    res = a[None, :] + vals
                elif op == "-":
                    res = a[None, :] - vals
                else:
                    res = a[None, :] * vals
                ms = (1.0 / 6.0) * masses[i] * masses
                for j in range(len(level)):
                    new.append((res[j], ms[j], f"({strs[i]} {op} {strs[j]})"))
        level = _dedup(new)
    vals = np.stack([v for v, _, _ in level])
    masses = np.array([m for _, m, _ in level])
    strs = [s for _, _, s in level]
    return ExprClass(vals, masses, strs)


def _dedup(items):
    """Group expressions with identical value vectors; keep total mass and the most probable string."""
    vals = np.stack([v for v, _, _ in items])
    masses = np.array([m for _, m, _ in items])
    uniq, inv = np.unique(vals, axis=0, return_inverse=True)
    inv = inv.reshape(-1)
    tot = np.zeros(len(uniq))
    np.add.at(tot, inv, masses)
    best = {}
    for k, (v, m, s) in enumerate(items):
        c = inv[k]
        if c not in best or m > best[c][0]:
            best[c] = (m, s)
    return [(uniq[c], tot[c], best[c][1]) for c in range(len(uniq))]


def conditions(domain):
    """List of (mask over domain, prior probability, name)."""
    lv = leaf_values(domain)
    first = np.array([s[0] == "1" for s in domain])
    last = np.array([s[-1] == "1" for s in domain])
    out = []
    for a in LEAVES:
        out.append((lv[a] % 2 == 0, (1 / 5) * (1 / 6), f"even({a})"))
    for a in LEAVES:
        for b in LEAVES:
            out.append((lv[a] < lv[b], (1 / 5) * (1 / 36), f"{a}<{b}"))
            out.append((lv[a] == lv[b], (1 / 5) * (1 / 36), f"{a}=={b}"))
    out.append((first, 1 / 5, "first=1"))
    out.append((last, 1 / 5, "last=1"))
    return out


def posterior_predictive(ec: ExprClass, conds, train_idx, train_y, test_idx, p_plain=0.5,
                         extra_programs=()):
    """Exact Bayes-mixture predictive distribution on each test input.

    Returns (Z, preds): Z = total prior mass of programs consistent with the training
    data; preds[j] = dict value -> posterior probability for test_idx[j].
    extra_programs: iterable of (value_vector_over_domain, prior_mass) added to the mixture
    (used to model a different universal machine that favours a given program).
    """
    train_idx = np.asarray(train_idx)
    train_y = np.asarray(train_y)
    test_idx = np.asarray(test_idx)
    V = ec.values
    m = ec.mass
    nt = len(test_idx)
    acc = [dict() for _ in range(nt)]

    def add(j, val, w):
        acc[j][val] = acc[j].get(val, 0.0) + w

    Z = 0.0
    # plain programs
    ok = np.all(V[:, train_idx] == train_y[None, :], axis=1)
    w_plain = p_plain * m[ok]
    Z += w_plain.sum()
    Vt = V[ok][:, test_idx]
    for j in range(nt):
        vals, inv = np.unique(Vt[:, j], return_inverse=True)
        sums = np.zeros(len(vals))
        np.add.at(sums, inv.reshape(-1), w_plain)
        for v, s in zip(vals, sums):
            add(j, int(v), s)
    # if-programs
    for mask, pc, _name in conds:
        tr_in = mask[train_idx]
        idx1 = train_idx[tr_in]
        idx2 = train_idx[~tr_in]
        ok1 = np.all(V[:, idx1] == train_y[tr_in][None, :], axis=1) if idx1.size else np.ones(len(V), bool)
        ok2 = np.all(V[:, idx2] == train_y[~tr_in][None, :], axis=1) if idx2.size else np.ones(len(V), bool)
        m1 = m[ok1].sum()
        m2 = m[ok2].sum()
        wC = (1 - p_plain) * pc * m1 * m2
        if wC == 0:
            continue
        Z += wC
        for j in range(nt):
            x = test_idx[j]
            if mask[x]:
                sel, mm = ok1, m1
            else:
                sel, mm = ok2, m2
            vals, inv = np.unique(V[sel][:, x], return_inverse=True)
            sums = np.zeros(len(vals))
            np.add.at(sums, inv.reshape(-1), m[sel])
            for v, s in zip(vals, sums):
                add(j, int(v), wC * s / mm)
    for vec, w in extra_programs:
        vec = np.asarray(vec)
        if np.all(vec[train_idx] == train_y):
            Z += w
            for j in range(nt):
                add(j, int(vec[test_idx[j]]), w)
    preds = [{v: s / Z for v, s in a.items()} for a in acc]
    return Z, preds
