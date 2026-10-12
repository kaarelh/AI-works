"""r3: independent re-implementation of check e5 (examples track, notes section 5.3).

The grammar is re-implemented from the description in code/sfi_dsl.py's docstring and the
notes, WITHOUT merging expressions by value vector: all 38994 expressions of depth <= 2
are enumerated individually.  The exact posterior predictive on even-length strings after
training on all odd-length strings of length 1..7 is recomputed for p_plain in
{0.5, 0.9, 0.99} and for the two "tilted" priors, and compared with the numbers printed in
the notes' table (section 5.3).  Also: the online part (reveal all strings of length 2, 4, 6).

Deterministic.  Output: r3_dsl_independent_output.txt
"""
import itertools
import math
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def main():
    say("r3_dsl_independent.py")
    dom = ["".join(b) for L in range(1, 9) for b in itertools.product("01", repeat=L)]
    lens = np.array([len(s) for s in dom], dtype=np.int64)
    ones = np.array([s.count("1") for s in dom], dtype=np.int64)
    leaves = {"len": lens, "ones": ones, "zeros": lens - ones, "0": np.zeros_like(lens),
              "1": np.ones_like(lens), "2": np.full_like(lens, 2)}
    # level-by-level enumeration of expression trees (no merging)
    lvl_vals = [v for v in leaves.values()]
    lvl_mass = [1 / 12] * 6
    for depth in range(2):
        V = np.stack(lvl_vals)
        m = np.array(lvl_mass)
        new_vals = [v for v in leaves.values()]
        new_mass = [1 / 12] * 6
        for op in ("+", "-", "*"):
            for i in range(len(V)):
                if op == "+":
                    R = V[i][None, :] + V
                elif op == "-":
                    R = V[i][None, :] - V
                else:
                    R = V[i][None, :] * V
                new_vals.extend(list(R))
                new_mass.extend(list((1 / 6) * m[i] * m))
        lvl_vals, lvl_mass = new_vals, new_mass
    V = np.stack(lvl_vals)
    mass = np.array(lvl_mass)
    say(f"expressions enumerated: {len(V)}; total mass {mass.sum():.6f}; distinct value vectors: "
        f"{len(np.unique(V, axis=0))}")
    # conditions
    first = np.array([s[0] == "1" for s in dom])
    last = np.array([s[-1] == "1" for s in dom])
    conds = []
    for a in leaves:
        conds.append((leaves[a] % 2 == 0, 1 / 30))
    for a in leaves:
        for b in leaves:
            conds.append((leaves[a] < leaves[b], 1 / 180))
            conds.append((leaves[a] == leaves[b], 1 / 180))
    conds.append((first, 1 / 5))
    conds.append((last, 1 / 5))
    say(f"conditions: {len(conds)}, total prior {sum(c[1] for c in conds):.6f}")

    def predictive(tr, te, p_plain, extra=None):
        tr = np.asarray(tr)
        te = np.asarray(te)
        ytr = lens[tr]
        Z = 0.0
        acc = [dict() for _ in te]
        ok = np.all(V[:, tr] == ytr[None, :], axis=1)
        w = p_plain * mass[ok]
        Z += w.sum()
        for j, x in enumerate(te):
            for val, ww in zip(V[ok, x], w):
                acc[j][int(val)] = acc[j].get(int(val), 0.0) + ww
        for mask, pc in conds:
            t1 = tr[mask[tr]]
            t2 = tr[~mask[tr]]
            ok1 = np.all(V[:, t1] == lens[t1][None, :], axis=1)
            ok2 = np.all(V[:, t2] == lens[t2][None, :], axis=1)
            m1 = mass[ok1].sum()
            m2 = mass[ok2].sum()
            wc = (1 - p_plain) * pc * m1 * m2
            if wc == 0:
                continue
            Z += wc
            for j, x in enumerate(te):
                sel = ok1 if mask[x] else ok2
                mm = m1 if mask[x] else m2
                vals = V[sel, x]
                ms = mass[sel]
                u, inv = np.unique(vals, return_inverse=True)
                sums = np.bincount(inv.reshape(-1), weights=ms)
                for val, ss in zip(u, sums):
                    acc[j][int(val)] = acc[j].get(int(val), 0.0) + wc * ss / mm
        if extra is not None:
            vec, wx = extra
            if np.all(vec[tr] == ytr):
                Z += wx
                for j, x in enumerate(te):
                    acc[j][int(vec[x])] = acc[j].get(int(vec[x]), 0.0) + wx
        return Z, [{k: v / Z for k, v in a.items()} for a in acc]

    tr = np.array([i for i, s in enumerate(dom) if len(s) % 2 == 1])
    te = np.array([i for i, s in enumerate(dom) if len(s) % 2 == 0])
    ok = np.all(V[:, tr] == lens[tr][None, :], axis=1)
    say(f"plain expressions consistent with training: {ok.sum()} (mass {mass[ok].sum():.6f}); "
        f"all agree with len on the test set: {bool(np.all(V[ok][:, te] == lens[te][None, :]))}")
    notes = {0.5: (0.9824, 0.9835, 0.9834, 0.9834, 3.3e-3, 0.9790),
             0.9: (0.9975, 0.9977, 0.9977, 0.9977, 4.6e-4, 0.9971),
             0.99: (0.99977, 0.99978, 0.99978, 0.99978, 4.3e-5, 0.99972)}
    say("prior          | P(correct) L=2..8 (referee)            | P(0) at L=8 | min P(correct) | notes' table")
    for pp in (0.5, 0.9, 0.99):
        Z, pr = predictive(tr, te, pp)
        pc = [np.mean([pr[j].get(L, 0.0) for j, x in enumerate(te) if lens[x] == L]) for L in (2, 4, 6, 8)]
        p0 = np.mean([pr[j].get(0, 0.0) for j, x in enumerate(te) if lens[x] == 8])
        mn = min(pr[j].get(int(lens[x]), 0.0) for j, x in enumerate(te))
        say(f"p_plain={pp:<5} | " + " ".join(f"{v:.5f}" for v in pc) + f" | {p0:.2e}   | {mn:.5f}        | {notes[pp]}")
    bad = np.where(lens % 2 == 0, 0, lens)
    for tilt, nt in ((1.0, (0.557, 0.435, 0.555)), (10.0, (0.114, 0.885, 0.113))):
        Z, pr = predictive(tr, te, 0.5, extra=(bad, tilt * 0.5 * mass[ok].sum()))
        pc = [np.mean([pr[j].get(L, 0.0) for j, x in enumerate(te) if lens[x] == L]) for L in (2, 4, 6, 8)]
        p0 = np.mean([pr[j].get(0, 0.0) for j, x in enumerate(te) if lens[x] == 8])
        mn = min(pr[j].get(int(lens[x]), 0.0) for j, x in enumerate(te))
        say(f"tilted x{tilt:<5}| " + " ".join(f"{v:.5f}" for v in pc) + f" | {p0:.3f}    | {mn:.5f}        | notes: {nt}")
    say("online (p_plain = 0.5): reveal all strings of even length <= L, then P(wrong) on the remaining even lengths")
    revealed = list(tr)
    for Lr in (2, 4, 6):
        revealed += [i for i, s in enumerate(dom) if len(s) == Lr]
        rest = [L for L in (2, 4, 6, 8) if L > Lr]
        te2 = np.array([i for i, s in enumerate(dom) if len(s) in rest])
        Z, pr = predictive(np.array(revealed), te2, 0.5)
        pw = [1 - np.mean([pr[j].get(L, 0.0) for j, x in enumerate(te2) if lens[x] == L]) for L in rest]
        say(f"  after length {Lr}: " + ", ".join(f"P(wrong|L={L}) = {v:.3e}" for L, v in zip(rest, pw))
            + "   (notes: 2.7e-3 / 1.5e-8 / 0)")
    with open(os.path.join(HERE, "r3_dsl_independent_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
