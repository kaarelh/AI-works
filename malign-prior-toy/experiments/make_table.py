"""Write the table of the computation section from results/profiles.json."""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
r = json.load(open(os.path.join(HERE, "results", "profiles.json")))
ROWS = [("ones", r"$1^{48}$", 16), ("ones", r"$1^{48}$", 31), ("alternating", r"$(10)^{24}$", 17),
        ("alternating", r"$(10)^{24}$", 31), ("zeros", r"$0^{48}$", 17), ("eight ones then zeros", r"$1^80^{40}$", 9)]


def cell(T, name, k):
    p = r["schedules"][str(T)]["streams"][name]["profile"][k - 1]
    return "%.3f & %.3f & %.3f" % (p["truth"], p["flip"], p["stall"])


lines = [r"\begin{tabular}{lr@{\qquad}rrr@{\qquad}rrr}", r"\toprule",
         r" & & \multicolumn{3}{c}{$T(k)=24k$\qquad\mbox{}} & \multicolumn{3}{c}{$T(k)=3k$} \\",
         r"stream & $k$ & true & other & none & true & other & none \\", r"\midrule"]
for name, tex, k in ROWS:
    lines.append("%s & %d & %s & %s \\\\" % (tex, k, cell(24, name, k), cell(3, name, k)))
lines += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(HERE, "..", "paper", "table-profiles.tex"), "w").write("\n".join(lines) + "\n")

b = [r"\begin{tabular}{lrrrr}", r"\toprule",
     r"stream & $\sum_{k\le48}(1-\mathrm{true}_k)$ & $\ln(1/\xi(z_{1:48}))$ & $\#\{k:\mathrm{true}_k\le\frac12\}$ & $\log_2(1/\xi(z_{1:48}))$ \\",
     r"\midrule"]
for name, tex in [("ones", r"$1^{48}$"), ("zeros", r"$0^{48}$"), ("alternating", r"$(10)^{24}$"), ("eight ones then zeros", r"$1^80^{40}$")]:
    v = r["schedules"]["24"]["streams"][name]["budget"]
    b.append("%s & %.2f & %.2f & %d & %.2f \\\\" % (tex, v["sum_one_minus_truth"], v["ln_inverse_mass"],
                                                     v["count_truth_at_most_half"], v["log2_inverse_mass"]))
b += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(HERE, "..", "paper", "table-budget.tex"), "w").write("\n".join(b) + "\n")
print(open(os.path.join(HERE, "..", "paper", "table-profiles.tex")).read())
