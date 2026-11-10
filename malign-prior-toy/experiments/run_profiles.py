"""Exact deviation profiles of the bounded mixture of the BF8 machine.

For a stream z and each position k this computes, as exact dyadic rationals,
  truth(k) = xi(z_1..k) / xi(z_1..k-1)      posterior mass that emits the true k-th bit on schedule
  flip(k)  = xi(z_1..k-1 ~z_k) / xi(z_1..k-1)   posterior mass that emits the other bit on schedule
  stall(k) = 1 - truth(k) - flip(k)             posterior mass that emits nothing on schedule
and checks the budget inequalities of the paper.  It also computes, for a world drawn
from the prior, the probability that a sampled next-bit prediction differs from the
world's own next bit, as a function of the position.

Run:  python3 run_profiles.py        (compiles ../code/bf8enum.c if needed; about a minute)
Writes results/profiles.json and results/profiles.pdf.
"""
import json
import math
import os
import subprocess
import sys
import tempfile
from fractions import Fraction

HERE = os.path.dirname(os.path.abspath(__file__))
CODE = os.path.join(HERE, "..", "code")
sys.path.insert(0, CODE)
import bf8  # noqa: E402

LC, N, CELLMOD = 10, 48, 16
SCHEDULES = [24, 6, 3]            # T1; T0 = 0
STREAMS = {
    "ones": "1" * 48,
    "zeros": "0" * 48,
    "alternating": "10" * 24,
    "eight ones then zeros": "1" * 8 + "0" * 40,
}


def enumerate_mixture(T1, tmp):
    exe = os.path.join(CODE, "bf8enum")
    if not os.path.exists(exe):
        subprocess.run(["gcc", "-O2", "-o", exe, os.path.join(CODE, "bf8enum.c")], check=True)
    out = os.path.join(tmp, "m_%d.txt" % T1)
    subprocess.run([exe, str(LC), str(N), "0", str(T1), str(CELLMOD), out], check=True, capture_output=True)
    return bf8.load_mixture(out)


def profile(m, z):
    rows = []
    for k in range(1, len(z) + 1):
        prev = m.get(z[:k - 1], Fraction(0)) if k > 1 else Fraction(1)
        if prev == 0:
            rows.append({"k": k, "prefix_mass": "0", "truth": None, "flip": None, "stall": None})
            continue
        t = m.get(z[:k], Fraction(0)) / prev
        other = z[:k - 1] + ("1" if z[k - 1] == "0" else "0")
        f = m.get(other, Fraction(0)) / prev
        rows.append({"k": k, "prefix_mass": str(prev), "truth": float(t), "flip": float(f),
                     "stall": float(1 - t - f), "truth_exact": str(t)})
    return rows


def budget_checks(m, z):
    """sum_k (1 - truth(k)) <= ln(1/xi(z)) and #{k : truth(k) <= 1/2} <= log2(1/xi(z)), over the
    positions where the prefix has positive mass."""
    zN = m.get(z, Fraction(0))
    if zN == 0:
        return None
    s, half = Fraction(0), 0
    for k in range(1, len(z) + 1):
        prev = m[z[:k - 1]] if k > 1 else Fraction(1)
        t = m[z[:k]] / prev
        s += 1 - t
        half += (t <= Fraction(1, 2))
    return {"sum_one_minus_truth": float(s), "ln_inverse_mass": math.log(1 / float(zN)),
            "count_truth_at_most_half": half, "log2_inverse_mass": math.log2(1 / float(zN)),
            "holds": float(s) <= math.log(1 / float(zN)) and half <= math.log2(1 / float(zN))}


def prior_average_disagreement(m):
    """For each n: probability that the sampled next bit differs from the world's own next bit,
    for a world drawn from the prior, given that it emits n+1 bits on schedule (normalised prediction)."""
    by_len = {}
    for x, v in m.items():
        by_len.setdefault(len(x), {})[x] = v
    out = []
    for n in range(0, N):
        num, den = Fraction(0), Fraction(0)
        nxt = by_len.get(n + 1, {})
        seen = set()
        for xb in nxt:
            x = xb[:-1]
            if x in seen:
                continue
            seen.add(x)
            a, b = nxt.get(x + "0", Fraction(0)), nxt.get(x + "1", Fraction(0))
            num += 2 * a * b / (a + b)
            den += a + b
        out.append({"n": n, "disagreement": float(num / den) if den else None, "mass_emitting_n_plus_1": float(den)})
    return out


def exclusion_example(tmp):
    """With at most 9 commands: a stream that the generous schedule predicts and the tight one cannot print."""
    z = STREAMS["eight ones then zeros"]
    out = {"LC": 9, "z": z}
    for T1 in (24, 3):
        exe = os.path.join(CODE, "bf8enum")
        f = os.path.join(tmp, "x_%d.txt" % T1)
        subprocess.run([exe, "9", str(N), "0", str(T1), str(CELLMOD), f], check=True, capture_output=True)
        m = bf8.load_mixture(f)
        last = max([k for k in range(1, N + 1) if m.get(z[:k], 0) > 0] + [0])
        entry = {"longest_prefix_with_positive_mass": last, "mass_of_that_prefix": str(m.get(z[:last], Fraction(0))),
                 "mass_of_full_stream": float(m.get(z, Fraction(0)))}
        if last < N:
            other = z[:last] + ("1" if z[last] == "0" else "0")
            entry["mass_true_next"] = str(m.get(z[:last + 1], Fraction(0)))
            entry["mass_other_next"] = str(m.get(other, Fraction(0)))
        out[str(T1)] = entry
    return out


def main():
    res = {"machine": "BF8", "LC": LC, "N": N, "cellmod": CELLMOD, "T0": 0, "schedules": {}}
    with tempfile.TemporaryDirectory() as tmp:
        res["exclusion_example"] = exclusion_example(tmp)
        for T1 in SCHEDULES:
            m = enumerate_mixture(T1, tmp)
            entry = {"streams": {}}
            for name, z in STREAMS.items():
                entry["streams"][name] = {"z": z, "profile": profile(m, z), "budget": budget_checks(m, z)}
            if T1 == SCHEDULES[0]:
                entry["prior_average_disagreement"] = prior_average_disagreement(m)
            res["schedules"][str(T1)] = entry
            del m
    with open(os.path.join(HERE, "results", "profiles.json"), "w") as f:
        json.dump(res, f, indent=1)
    plot(res)


def plot(res):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    main_T = str(SCHEDULES[0])
    fig, axes = plt.subplots(1, 3, figsize=(13.5, 3.6))
    ax = axes[0]
    for name, style in [("ones", "-"), ("alternating", "--"), ("zeros", ":")]:
        p = res["schedules"][main_T]["streams"][name]["profile"]
        ax.plot([r["k"] for r in p], [1 - r["truth"] for r in p], style, color="black", label=name, lw=1.3)
    ax.set_yscale("log"); ax.set_ylim(1e-6, 1.5); ax.set_xlabel("position k")
    ax.set_ylabel("posterior mass not on the true bit"); ax.set_title("three streams, schedule $T(k)=24k$", fontsize=10)
    ax.legend(frameon=False, fontsize=8)
    ax = axes[1]
    d = res["schedules"][main_T]["prior_average_disagreement"]
    ax.plot([r["n"] + 1 for r in d], [r["disagreement"] for r in d], "-", color="black", lw=1.3)
    ax.set_yscale("log"); ax.set_xlabel("position k")
    ax.set_ylabel("P[sampled bit $\\neq$ world's bit]"); ax.set_title("world drawn from the prior", fontsize=10)
    ax = axes[2]
    for T1, style in zip(SCHEDULES, ["-", "--", ":"]):
        p = res["schedules"][str(T1)]["streams"]["eight ones then zeros"]["profile"]
        ks = [r["k"] for r in p if r["truth"] is not None]
        ax.plot(ks, [r["truth"] for r in p if r["truth"] is not None], style, color="black", lw=1.3, label="$T(k)=%dk$" % T1)
    ax.set_xlabel("position k"); ax.set_ylabel("posterior mass on the true bit")
    ax.set_title("stream $1^80^{40}$ under three schedules", fontsize=10); ax.legend(frameon=False, fontsize=8)
    fig.tight_layout()
    fig.savefig(os.path.join(HERE, "results", "profiles.pdf"))


if __name__ == "__main__":
    main()
