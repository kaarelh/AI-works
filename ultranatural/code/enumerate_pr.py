"""Enumerate a small language of bounded primitive recursion and record, for every function it
expresses on a finite domain, the size of its smallest term.

Language (fixed before any result was looked at):

    t ::= x | y | a | 0 | S(t) | P(t) | It(t_n, t_body, t_init) | ifz(t_c, t_then, t_else)

* Values are the integers 0..VMAX, with saturating successor S and predecessor P (P(0) = 0).
* x, y are the two inputs; a is the accumulator.
* It(n, body, init): start from v = init, then n times replace v by the value of body with a := v.
  n and init are evaluated in the enclosing environment; an inner It shadows a.
* ifz(c, u, v) is u if c = 0 and v otherwise.
* A closed program is run with a = 0.
* The size of a term is its number of nodes. K(f) is the least size of a term computing f on the
  domain {0..XMAX-1}^2.

There is no addition primitive: x + y is It(y, S(a), x), of size 5.

The enumeration is bottom-up by size and keeps one term per behaviour on (x, y, a); a term of
least size for a given behaviour can always be built from least-size subterms, so the recorded
sizes are exact minima.

Usage: python3 enumerate_pr.py MAXSIZE OUT.npz
"""
import sys
import time

import numpy as np

XMAX = 6
VMAX = 31
NXY = XMAX * XMAX
NA = VMAX + 1

XS = np.repeat(np.arange(XMAX), XMAX).astype(np.uint8)  # x of input index i
YS = np.tile(np.arange(XMAX), XMAX).astype(np.uint8)    # y of input index i
ROW = np.arange(NXY)[:, None]


def atoms():
    x = np.repeat(XS[:, None], NA, axis=1)
    y = np.repeat(YS[:, None], NA, axis=1)
    a = np.repeat(np.arange(NA, dtype=np.uint8)[None, :], NXY, axis=0)
    z = np.zeros((NXY, NA), dtype=np.uint8)
    return [(x, "x"), (y, "y"), (a, "a"), (z, "0")]


def succ(t):
    return np.minimum(t.astype(np.int16) + 1, VMAX).astype(np.uint8)


def pred(t):
    return np.maximum(t.astype(np.int16) - 1, 0).astype(np.uint8)


def iterate(n, body, inits):
    """n, body: (NXY, NA); inits: (k, NXY, NA). Returns (k, NXY, NA)."""
    cur = inits.copy()
    top = int(n.max())
    for k in range(1, top + 1):
        nxt = body[ROW[None, :, :], cur]
        mask = (n >= k)[None, :, :]
        cur = np.where(mask, nxt, cur)
    return cur


def main(maxsize, out):
    t0 = time.time()
    seen = {}            # behaviour bytes -> index
    tables = []          # list of (NXY, NA) uint8
    sizes = []
    terms = []
    by_size = {s: [] for s in range(1, maxsize + 1)}

    def add(tab, size, term):
        key = tab.tobytes()
        if key in seen:
            return
        seen[key] = len(tables)
        by_size[size].append(len(tables))
        tables.append(tab)
        sizes.append(size)
        terms.append(term)

    for tab, name in atoms():
        add(tab, 1, name)

    for s in range(2, maxsize + 1):
        for i in list(by_size[s - 1]):
            add(succ(tables[i]), s, "S(" + terms[i] + ")")
            add(pred(tables[i]), s, "P(" + terms[i] + ")")
        for s1 in range(1, s - 2):
            for s2 in range(1, s - 1 - s1):
                s3 = s - 1 - s1 - s2
                if s3 < 1:
                    continue
                idx3 = list(by_size[s3])
                if not idx3:
                    continue
                stack3 = np.stack([tables[i] for i in idx3])
                for i1 in list(by_size[s1]):
                    t1 = tables[i1]
                    zero1 = (t1 == 0)[None, :, :]
                    for i2 in list(by_size[s2]):
                        t2 = tables[i2]
                        # ifz(t1, t2, t3)
                        res = np.where(zero1, t2[None, :, :], stack3)
                        for j, i3 in enumerate(idx3):
                            key = res[j].tobytes()
                            if key not in seen:
                                add(res[j].copy(), s,
                                    "ifz(" + terms[i1] + "," + terms[i2] + "," + terms[i3] + ")")
                        # It(t1, t2, t3)
                        res = iterate(t1, t2, stack3)
                        for j, i3 in enumerate(idx3):
                            key = res[j].tobytes()
                            if key not in seen:
                                add(res[j].copy(), s,
                                    "It(" + terms[i1] + "," + terms[i2] + "," + terms[i3] + ")")
        print(f"size {s}: {len(by_size[s])} new behaviours, total {len(tables)}, "
              f"{time.time() - t0:.0f}s", flush=True)

    # closed functions: run with a = 0
    closed = {}
    for i, tab in enumerate(tables):
        key = tab[:, 0].tobytes()
        if key not in closed or sizes[i] < sizes[closed[key]]:
            closed[key] = i
    order = sorted(closed.values(), key=lambda i: (sizes[i], i))
    F = np.stack([tables[i][:, 0] for i in order])
    K = np.array([sizes[i] for i in order], dtype=np.int16)
    T = np.array([terms[i] for i in order])
    np.savez_compressed(out, F=F, K=K, T=T, xmax=XMAX, vmax=VMAX, maxsize=maxsize)
    print("closed functions by K:", {int(k): int((K == k).sum()) for k in np.unique(K)})
    print(f"total closed functions {len(K)}; saved {out}; {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main(int(sys.argv[1]), sys.argv[2])
