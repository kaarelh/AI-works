#!/usr/bin/env python3
"""Small exact engine used by the referee's checks of research/prove-c/shift-abstain.md.

Objects (all finite):
  X = range(nx) inputs, Y = range(ny) answers; a kernel is a list C[x] of length ny + 1,
  where C[x][y] is the probability of answer y and C[x][ny] the probability of the
  abstention (the run ends there).  A hypothesis is such a kernel (a conditional
  semimeasure, its missing mass on the abstention).
  A scaffold has top-level inputs z in range(nz) with law D0, horizon L, and a map
  nxt[(z, history)] -> input or None (STOP), history = tuple of earlier answers.
Everything is computed by exact enumeration of runs (no simulation).
Written independently of the prover's scripts.
"""
import itertools
import random

ABORT = -1


def random_scaffold(rng, nx, ny, nz, L, stop_prob=0.15, adaptive=True, stop0=0.0):
    D0 = [rng.random() + 0.05 for _ in range(nz)]
    s = sum(D0)
    D0 = [d / s for d in D0]
    nxt = {}
    for z in range(nz):
        for j in range(L):
            for hist in itertools.product(range(ny), repeat=j):
                if j > 0 and nxt.get((z, hist[:-1])) is None:
                    nxt[(z, hist)] = None          # the run stopped earlier
                    continue
                if (j > 0 and rng.random() < stop_prob) or (j == 0 and rng.random() < stop0):
                    nxt[(z, hist)] = None
                elif adaptive:
                    nxt[(z, hist)] = rng.randrange(nx)
                else:
                    # input depends on z and the position only
                    nxt[(z, hist)] = (z * 7 + j * 3) % nx
    return dict(D0=D0, nxt=nxt, L=L, nz=nz, nx=nx, ny=ny)


def runs(sc, C):
    """All runs of the scaffold answered by kernel C: list of (prob, z, inputs, answers).
    An aborted run has ABORT as its last answer."""
    out = []
    ny, L = sc['ny'], sc['L']

    def rec(z, hist, xs, pr):
        x = sc['nxt'].get((z, hist)) if len(hist) < L else None
        if x is None:
            out.append((pr, z, xs, hist))
            return
        for y in range(ny):
            p = C[x][y]
            if p > 0:
                rec(z, hist + (y,), xs + (x,), pr * p)
        pa = C[x][ny]
        if pa > 0:
            out.append((pr * pa, z, xs + (x,), hist + (ABORT,)))

    for z in range(sc['nz']):
        rec(z, (), (), sc['D0'][z])
    return out


def visit(sc, C):
    d = [0.0] * sc['nx']
    for pr, z, xs, ys in runs(sc, C):
        for x in xs:
            d[x] += pr
    return d


def tv_point(p, q):
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def beta_along(sc, Crun, P, C):
    """E over runs answered by Crun of the sum over calls of TV(P, C)(x_j)."""
    tv = [tv_point(P[x], C[x]) for x in range(sc['nx'])]
    return sum(pr * sum(tv[x] for x in xs) for pr, z, xs, ys in runs(sc, Crun))


def separation_prob(sc, P, C):
    """Probability that the maximally coupled runs of C and P separate (Lemma 1.4)."""
    ny, L = sc['ny'], sc['L']
    tv = [tv_point(P[x], C[x]) for x in range(sc['nx'])]

    def rec(z, hist):
        x = sc['nxt'].get((z, hist)) if len(hist) < L else None
        if x is None:
            return 0.0
        tot = tv[x]
        for y in range(ny):
            m = min(P[x][y], C[x][y])
            if m > 0:
                tot += m * rec(z, hist + (y,))
        return tot

    return sum(sc['D0'][z] * rec(z, ()) for z in range(sc['nz']))


def run_law(sc, C):
    law = {}
    for pr, z, xs, ys in runs(sc, C):
        law[(z, ys)] = law.get((z, ys), 0.0) + pr
    return law


def tv_laws(a, b):
    keys = set(a) | set(b)
    return 0.5 * sum(abs(a.get(k, 0.0) - b.get(k, 0.0)) for k in keys)


def random_kernel(rng, nx, ny, abort=False, det=False, sparse=0.3):
    C = []
    for x in range(nx):
        if det:
            row = [0.0] * (ny + 1)
            row[rng.randrange(ny)] = 1.0
        else:
            row = [rng.random() if rng.random() > sparse else 0.0 for _ in range(ny)]
            if sum(row) == 0:
                row[rng.randrange(ny)] = 1.0
            a = rng.random() * 0.5 if abort and rng.random() < 0.5 else 0.0
            s = sum(row)
            row = [r * (1 - a) / s for r in row] + [a]
        C.append(row)
    return C


def mixture(hyps, post):
    nx = len(hyps[0])
    ny1 = len(hyps[0][0])
    M = [[sum(post[i] * hyps[i][x][y] for i in range(len(hyps))) for y in range(ny1 - 1)]
         for x in range(nx)]
    for x in range(nx):
        M[x].append(max(0.0, 1.0 - sum(M[x])))
    return M


def posterior(hyps, w, data):
    lik = []
    for i, h in enumerate(hyps):
        l = w[i]
        for x, y in data:
            l *= h[x][y]
        lik.append(l)
    s = sum(lik)
    return [l / s for l in lik], s
