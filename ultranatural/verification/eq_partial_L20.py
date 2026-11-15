"""Referee: what a run of `eq_unary 12 20 dump` shows, compared with the dump at L = 18.

The run at L = 20 was not finished when the report was written.  eq_unary enumerates sorted
multisets with the identities ordered by size, so once it works on first identities of size s,
every set that contains an identity of fewer than s symbols has been done, and its D line (if it
determines f at 0, 1, 2) has been written.  This script compares the part done with the L = 18
dump, which lists the sets in the same order.

Usage: python3 eq_partial_L20.py DUMP_L18 DUMP_L20_so_far
"""
import sys


def load(path):
    out = []
    for line in open(path):
        if line.startswith("D ") and line.endswith("\n") and line.count("|") == 2:
            head, prof, ids = line[2:].split("|")
            p = tuple(int(v) for v in prof.split())
            if len(p) == 8:
                out.append((ids.strip(), p, float(head.split()[0])))
    return out


a18, a20 = load(sys.argv[1]), load(sys.argv[2])
d18 = {k: p for k, p, w in a18}
d20 = {k: p for k, p, w in a20}
idx = max(i for i, (k, _, _) in enumerate(a18) if k in d20)
covered = a18[: idx + 1]
size = lambda e: len(e) - 1                         # "fSx=SS0": symbols = characters minus the "="
print(f"L = 20 run so far: {len(a20)} sets listed; the last one is {a20[-1][0]} (first identity of {size(a20[-1][0].split()[0])} symbols)")
print(f"L = 18 dump: {len(a18)} sets; position reached: {idx + 1} ({100 * (idx + 1) / len(a18):.0f}%)")
gone = [k for k, p, w in covered if k not in d20]
changed = [k for k, p, w in covered if k in d20 and d20[k] != p]
new = [k for k in d20 if k not in d18]
print(f"in the part done: inconsistent at L = 20: {len(gone)}; more values proved: {len(changed)}; "
      f"sets that determine f(0), f(1), f(2) at L = 20 and not at L = 18: {len(new)} {new[:5]}")
T = {"successor": lambda x: x + 1, "identity": lambda x: x, "x+2": lambda x: x + 2, "constant 1": lambda x: 1,
     "predecessor": lambda x: max(x - 1, 0), "double": lambda x: 2 * x, "[x > 0]": lambda x: int(x > 0),
     "min(x+1, 2)": lambda x: min(x + 1, 2), "successor, but 0 at 0": lambda x: 0 if x == 0 else x + 1}
for name, g in T.items():
    fits = lambda p: all(p[i] == g(i) for i in range(3))
    dev = lambda p: any(p[i] not in (-1, g(i)) for i in range(8))
    all18 = sum(1 for k, p, w in a18 if fits(p))
    f18 = {k for k, p, w in covered if fits(p)}
    f20 = {k for k, p in d20.items() if fits(p)}
    nd = sorted(k for k in f20 if dev(d20[k]) and not (k in d18 and dev(d18[k])))
    print(f"   {name:22s}: fitting at L = 18: {all18}, of which done at L = 20: {len(f18)}; of these still fitting: {len(f18 & f20)}, "
          f"inconsistent: {len(f18 - f20)}; newly fitting: {len(f20 - f18)}; newly proving a wrong value: {len(nd)} {nd[:3]}")
