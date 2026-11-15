"""Posterior beliefs of the bounded equational inductor for a unary function.

Reads the profile table written by eq_unary.c. A profile gives, for x = 0..7, the value that an
identity set proves for f(x), or -1. Data D_n are the values of a target g at x = 0..n-1. The
sets that fit D_n are the consistent ones whose profile agrees with g there. For a query x:
    right        = weight of fitting sets that prove f(x) = g(x)
    wrong        = weight of fitting sets that prove another value
    undetermined = the rest
each divided by the weight of all fitting sets. All of this is within the enumerated sets
(total size at most CAP) and the bounded closure (see eq_unary.c).

Usage: python3 eq_unary_analyze.py TABLE.txt
"""
import sys

XS = range(8)

TARGETS = {
    "successor": lambda x: x + 1,
    "identity": lambda x: x,
    "x+2": lambda x: x + 2,
    "constant 1": lambda x: 1,
    "predecessor": lambda x: max(x - 1, 0),
    "double": lambda x: 2 * x,
    "parity": lambda x: x % 2,
    "[x > 0]": lambda x: int(x > 0),
    "min(x+1, 2)": lambda x: min(x + 1, 2),
    "successor, but 0 at 0": lambda x: 0 if x == 0 else x + 1,
    "successor, but 0 at 3": lambda x: 0 if x == 3 else x + 1,
    "square": lambda x: x * x,
}


def fits(prof, g, n):
    return all(prof[x] == g(x) for x in range(n))


def main(path):
    rows = []
    for line in open(path):
        if line.startswith("#"):
            print(line.strip())
            continue
        if line.startswith("D "):                     # listing lines of the dump mode
            continue
        prof, w, ms, ex = line.rstrip("\n").split("|")
        rows.append((tuple(int(v) for v in prof.split()), float(w), int(ms), ex.strip()))
    for name, g in TARGETS.items():
        print(f"\n== {name}: values {[g(x) for x in XS]} ==")
        print(f"{'n':>2s} {'weight of fitting sets':>23s} | {'next input x = n':^27s} | {'far input x = 7':^27s} | least size of a fitting set that")
        print(f"{'':>2s} {'':>23s} | {'right':>8s} {'wrong':>8s} {'undet.':>8s} | {'right':>8s} {'wrong':>8s} {'undet.':>8s} | proves all of 0..7 right / some value wrong")
        for n in range(0, 7):
            F = [r for r in rows if fits(r[0], g, n)]
            M = sum(r[1] for r in F)
            if M == 0:
                print(f"{n:2d} {'no fitting set of size <= CAP':>23s}")
                continue
            cells = []
            for x in (n, 7):
                right = sum(r[1] for r in F if r[0][x] == g(x)) / M
                wrong = sum(r[1] for r in F if r[0][x] not in (-1, g(x))) / M
                cells.append(f"{right:8.5f} {wrong:8.1e} {1 - right - wrong:8.5f}")
            full = [r for r in F if all(r[0][x] == g(x) for x in XS)]
            dev = [r for r in F if any(r[0][x] not in (-1, g(x)) for x in XS)]
            fs = min(full, key=lambda r: r[2]) if full else None
            ds = min(dev, key=lambda r: r[2]) if dev else None
            tail = (f"{fs[2]} [{fs[3]}]" if fs else "none") + " / " + (f"{ds[2]} [{ds[3]}]" if ds else "none")
            print(f"{n:2d} {M:23.3e} | {cells[0]} | {cells[1]} | {tail}")


if __name__ == "__main__":
    main(sys.argv[1])
