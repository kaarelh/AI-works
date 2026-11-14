"""Write the two tables of the circuit computation (paper/table-circuits-query.tex and
paper/table-circuits-seq.tex) from results/circuits.json (written by run_circuits.py)."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
PAPER = os.path.join(HERE, "..", "paper")
r = json.load(open(os.path.join(HERE, "results", "circuits.json")))


def num(v, digits):
    """A share to `digits` decimals; the exact values 0 and 1 are printed as 0 and 1; None is blank."""
    if v is None:
        return ""
    if v["exact"] in ("0", "1"):
        return v["exact"]
    return "%.*f" % (digits, v["float"])


# ---- query form ----
QROWS = [("x1 AND x2", r"$x_1\wedge x_2$"), ("x1 XOR x2", r"$x_1\oplus x_2$"), ("x1", r"$x_1$"),
         ("(x1 AND x2) XOR x3", r"$(x_1\wedge x_2)\oplus x_3$"), ("(x1 AND x2) XOR v", r"$(x_1\wedge x_2)\oplus v$")]
byname = {row["world"]: row for row in r["query_form"]}
q = [r"\begin{tabular}{lrrrrrrr}", r"\toprule",
     r"target & $k$ & $s_D$ & $s=s_D$ & $s_D+1$ & $s_D+2$ & $s_D+3$ & $s_D+4$ \\", r"\midrule"]
for name, tex in QROWS:
    row = byname[name]
    sD = row["s_D"]
    cells = [num(row["by_size"].get(str(s), {}).get("deviation_mass"), 4) for s in range(sD, sD + 5)]
    q.append("%s & %d & %d & %s \\\\" % (tex, row["k"], sD, " & ".join(cells)))
q += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(PAPER, "table-circuits-query.tex"), "w").write("\n".join(q) + "\n")

# ---- sequence form ----
SROWS = [("(b0 AND b1) XOR b3", r"$(b_0\wedge b_1)\oplus b_3$"), ("(b0 AND b1) XOR b2", r"$(b_0\wedge b_1)\oplus b_2$"),
         ("b0 AND b1", r"$b_0\wedge b_1$"), ("constant 0", r"constant $0$")]
z = [r"\begin{tabular}{lrrrr}", r"\toprule", r"world & cut $n$ & $s=2$ & $s=3$ & $s=4$ \\", r"\midrule"]
for name, tex in SROWS:
    for row in r["sequence_form_k4"]:
        if row["world"] != name:
            continue
        cells = [num(row["by_size"][str(s)]["off_truth_mass"], 3) for s in (2, 3, 4)]
        z.append("%s & %d & %s \\\\" % (tex, row["n"], " & ".join(cells)))
z += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(PAPER, "table-circuits-seq.tex"), "w").write("\n".join(z) + "\n")

for f in ("table-circuits-query.tex", "table-circuits-seq.tex"):
    print(open(os.path.join(PAPER, f)).read())
