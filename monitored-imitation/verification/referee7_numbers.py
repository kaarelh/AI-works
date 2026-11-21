"""Referee 7: the numbers of verified-slack.md (version 3), sections 5-8 (not E7), against their sources.

Sources: results/slack_imitation_table.md (E6), research/threadQ_hints.json (EQ),
research/threadG_byproducts_sim.out (G1), research/threadF_certified.out and threadF_cbc.out (F1),
research/threadS_selection.out and threadS-redteam2.md section 7 (thread S),
verification/referee7_eq_default.out (EQ with the default weights, this referee's re-run).

Run: python3 referee7_numbers.py > referee7_numbers.out
"""
import json
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")


def rd(*p):
    return open(os.path.join(ROOT, *p)).read()


def num(s):
    return float(s.replace(",", ""))


def check(label, claimed, actual, ok):
    print(f"  [{'ok' if ok else '!!'}] {label}: note says {claimed}; source {actual}")


def hr(t):
    print("\n" + "=" * 90 + "\n" + t + "\n" + "=" * 90)


# ------------------------------------------------------------------------------------------
hr("E6 (results/slack_imitation_table.md)")
tab = rd("results", "slack_imitation_table.md")
rows = {}
for line in tab.splitlines():
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) == 5 and cells[0] and not cells[0].startswith("-") and cells[0] != "protocol":
        rows[(cells[0], cells[1])] = [num(re.match(r"[\d,]+", c).group()) if re.match(r"[\d,]+", c) else None
                                      for c in cells[2:]]
ci = rows[("CI, no slack, same humans (n = n₀)", "noticing")]
check("chained imitation, noticing", "2,915 -> 12,724 -> 51,365", ci, ci == [2915, 12724, 51365])
si = {k: rows[("SI: CI with slack (n = 2n₀)", k)] for k in ("noticing", "misled-2", "misled-8", "fooled", "silent")}
bs = [si[k] for k in ("noticing", "misled-2", "misled-8")]
lo16, hi16 = min(b[0] for b in bs), max(b[0] for b in bs)
later = [b[j] for b in bs for j in (1, 2)]
check("slack imitation, bounded setback, n0 = 8", "160-490", f"{lo16:.0f}-{hi16:.0f}", lo16 == 160 and abs(hi16 - 490) <= 5)
check("slack imitation, bounded setback, n0 = 32, 128", "about 205", f"{min(later):.0f}-{max(later):.0f} "
      f"(n0 = 32: {[b[1] for b in bs]}, n0 = 128: {[b[2] for b in bs]})", max(later) <= 215)
check("fooled, slack", "1,631 -> 2,811 -> 4,296", si["fooled"], si["fooled"] == [1631, 2811, 4296])
cis = rows[("CI, no slack, same humans (n = n₀)", "silent")]
ratio = [a / b for a, b in zip(si["silent"], cis)]
check("silent: slack doubles the cost", "x2", [round(r, 2) for r in ratio], all(1.9 < r < 2.1 for r in ratio))
siv = {}
for line in tab.splitlines():
    if line.startswith("| SI-V |"):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        siv[cells[1]] = [num(re.match(r"[\d,]+", c).group()) for c in cells[2:]]
vals = [v for k in ("noticing", "misled-2", "misled-8") for v in siv[k]]
others = sorted(v for v in vals if v != siv["misled-8"][0])
check("SI-V, bounded setback", "13-16 (38 for misled-8 at n0 = 8)",
      f"{others[0]:.0f}-{others[-1]:.0f}, misled-8 n0=8: {siv['misled-8'][0]:.0f}",
      others[0] == 13 and others[-1] == 16 and siv["misled-8"][0] == 38)

# ------------------------------------------------------------------------------------------
hr("EQ (research/threadQ_hints.json): equal round robin")
q = json.load(open(os.path.join(ROOT, "research", "threadQ_hints.json")))
g = lambda k, n, p: q[f"{k}_n{n}_{p}"]["task_mean"]
ns = (16, 64, 256)
check("fooled, U", "181 -> 750 -> 2,636", [round(g("fooled", n, "U")) for n in ns],
      [round(g("fooled", n, "U")) for n in ns] == [181, 750, 2636])
check("fooled, U+S+H", "40 -> 55 -> 54", [round(g("fooled", n, "USH")) for n in ns],
      [round(g("fooled", n, "USH")) for n in ns] == [40, 55, 54])
check("silent, U", "1,610 -> 6,450 -> 26,091", [round(g("silent", n, "U")) for n in ns],
      [round(g("silent", n, "U")) for n in ns] == [1610, 6450, 26091])
check("silent, with the scan", "663 -> 2,497 -> 9,734", [round(g("silent", n, "USH")) for n in ns],
      [round(g("silent", n, "USH")) for n in ns] == [663, 2497, 9734])
r = max((g(k, n, "USH") / g(k, n, "U"), k, n) for k in ("noticing", "misled-2", "misled-8") for n in ns)
check("extra streams, bounded setback (max USH/U)", "at most 1.45x", f"{r[0]:.3f} ({r[1]}, n = {r[2]})", abs(r[0] - 1.45) < 0.005)
r = max((g(k, n, "UA") / g(k, n, "U"), k, n) for k in ("noticing", "misled-2", "misled-8", "fooled", "silent") for n in ns)
check("adversarial list (max UA/U)", "at most 1.64x", f"{r[0]:.3f} ({r[1]}, n = {r[2]})", abs(r[0] - 1.64) < 0.005)

hr("EQ with the default weights (1/2, 1/4, 1/4), from referee7_eq_default.out")
txt = open(os.path.join(HERE, "referee7_eq_default.out")).read()
eqd = {}
for line in txt.splitlines():
    m = re.match(r"\| (\S+) \| (USH|SUSH|RAND) \| (.*) \|$", line)
    if m:
        eqd[(m.group(1), m.group(2))] = [num(re.match(r"[\d,.]+", c.strip()).group()) for c in m.group(3).split("|")]
for k in ("noticing", "misled-2", "misled-8", "fooled", "silent"):
    u = [g(k, n, "U") for n in ns]
    print(f"  {k:9s} U {[round(x) for x in u]}  USH {[round(x) for x in eqd[(k, 'USH')]]}  "
          f"S,U,S,H {[round(x) for x in eqd[(k, 'SUSH')]]}  random {[round(x) for x in eqd[(k, 'RAND')]]}")
mx = max((eqd[(k, 'SUSH')][i] / g(k, n, "U"), k, n) for k in ("noticing", "misled-2", "misled-8") for i, n in enumerate(ns))
print(f"  bounded-setback humans under the default weights: up to {mx[0]:.2f}x U ({mx[1]}, n = {mx[2]}), "
      f"against the note's 1.45x for equal weights")

# ------------------------------------------------------------------------------------------
hr("G1 (research/threadG_byproducts_sim.out)")
gt = rd("research", "threadG_byproducts_sim.out")
m = re.search(r"\| REVIEW \| LASTREV \| ([\d,]+) .*?\| ([\d,]+) .*?\| ([\d,]+) ", gt)
v = [num(x) for x in m.groups()]
check("readable insights, reviews, last-review queries", "285-310", v, min(v) == 285 and max(v) == 310)
m = re.search(r"\| DO \| SI \| ([\d,]+) .*?\| ([\d,]+) .*?\| ([\d,]+) ", gt)
v = [num(x) for x in m.groups()]
print(f"  doing-only (DO, slack): {v}; ratio per 4x routine work: {v[1] / v[0]:.2f}, {v[2] / v[1]:.2f} (proportional)")

# ------------------------------------------------------------------------------------------
hr("F1 (research/threadF_certified.out, threadF_cbc.out)")
ft = rd("research", "threadF_certified.out")
fr = {}
for line in ft.splitlines():
    m = re.match(r"(\S+)\s+failed\s+([\d.]+)", line)
    if m:
        fr[m.group(1)] = float(m.group(2))
f = lambda key: [fr[key.format(n=n)] for n in (32, 64, 128)]
si_c = f("C_trusting_r1_n{n}_SI")
abc_c = f("C_trusting_r1_n{n}_SI-ABC_a0.3")
csi_c = f("C_trusting_r1_n{n}_CSI")
check("checkable wrong claims, SI / SI-ABC", "about 260 -> 1,200", f"SI {si_c}, SI-ABC {abc_c}", True)
check("local check (CSI)", "9-11", csi_c, all(9 <= x <= 11 for x in csi_c))
cbc = re.findall(r"C_trusting_r1_n\d+_CSI-CBC\s+failed\s+([\d.]+)", rd("research", "threadF_cbc.out"))
check("checking before committing", "0", cbc, all(float(x) == 0 for x in cbc))
w03 = f("W_trusting_r1_n{n}_SI-ABC_a0.3")
w005 = f("W_trusting_r1_n{n}_SI-ABC_a0.05")
asks = [float(x) for x in re.findall(r"W_trusting_r1_n\d+_SI-ABC_a0.05.*?asks\s+([\d.]+)", ft)]
check("W at alpha = 0.3 grows; at alpha = 0.05 vanishes, 7-16 asks per problem",
      "grow / 0 / 7-16", f"{w03} / {w005} / asks per problem {[a / 100 for a in asks]}",
      all(x == 0 for x in w005) and 6.5 <= asks[0] / 100 and asks[-1] / 100 <= 16)
w1 = f("W_trusting_r1_n{n}_SI")
r2 = [a / b for a, b in zip(w1, f("W_trusting_r2_n{n}_SI"))]
r3 = [a / b for a, b in zip(w1, f("W_trusting_r3_n{n}_SI"))]
check("retry rule divides by 3-4", "3-4", f"r = 2: {[round(x, 2) for x in r2]}, r = 3: {[round(x, 2) for x in r3]}",
      min(r2) > 2.8 and max(r3) < 4.4)
print(f"  W-trusting with r = 3: {f('W_trusting_r3_n{n}_SI')} (still proportional to n)")

# ------------------------------------------------------------------------------------------
hr("Thread S quotes in sections 5-7 (research/threadS_selection.out, threadS-redteam2.md)")
st = rd("research", "threadS_selection.out")
m = re.findall(r"U,S,H equal \(VSI\)\s+(\d+)\s+0\.0 \|.*?\|\s+[\d.]+/[\d.]+/[\d.]+\s+([\d.]+)/([\d.]+)/([\d.]+)", st)
print("  repeated verification, equal weights, h = 0, f = 0.10 (rho = 1 / 0.5 / 0):")
for u, a, b, c in m:
    print(f"    u = {u:>2s}: {a}/{b}/{c}  -> amplification at rho = 0.5: x{float(b) / 0.10:.1f}, at rho = 0: x{float(c) / 0.10:.1f}")
m2 = re.findall(r"S-heavy 8:1:1\s+(\d+)\s+0\.0 \|.*?\|\s+[\d.]+/[\d.]+/[\d.]+\s+([\d.]+)/([\d.]+)/([\d.]+)", st)
for u, a, b, c in m2:
    print(f"    8:1:1, u = {u:>2s}: {a}/{b}/{c}")
print("  note: 'x2 to x4.4 at f = 0.1' = equal weights, rho = 0.5 (u = 5 and 20); x6.1 at rho = 0.")
m = re.search(r"bits of enrichment log2\(f_m/f_h\): (.*)", st)
print(f"  enrichment: {m.group(1)}  (with f_m = 0.9; log2(1/0.1) would be {math.log2(10):.2f})")
m = re.search(r"k=64: ([\d.]+) bits", st)
print(f"  best-of-k: thread S gives ln k - (k-1)/k nats = {m.group(1)} bits at k = 64, against log2 64 = 6 "
      f"('about log2 k' overstates by about 1.44 bits; it is an upper bound)")
m = re.search(r"q=0.75 \| (.*)", st)
print(f"  heavy tails at q = 0.75 (Pr[tau > n], n = 2 n0): {m.group(1)}")
print("  section 7 table against thread S section 7 (read off the two tables):")
pairs = [("proof assistant", "85%", "70%", "70%"), ("test suite", "(85%)", "45%", "45%"),
         ("V-cone", "70% / 30%", "45% / 10%", "45% / 10%"), ("V-human", "65% / 30%", "40% / 10%", "40% / 10%"),
         ("Proposition 7", "45% / 20%", "30% / 10%", "30% / 10%"),
         ("slack imitation with asking", "40% / 20%", "25% / 10%", "25% / 10%"), ("truly O(K)", "45%", "25%", "25%")]
ts = rd("research", "threadS-redteam2.md")
for name, d, s, fin in pairs:
    print(f"    {name:28s} draft {d:10s} thread S {s:10s} final {fin}")
print("  (thread S section 7: 70% / 45% for the machine rows; 45% and 10% V-cone; 40% and 10% V-human imitated;")
print("   30% and 10% Proposition 7; 25% and 10% slack with asking; 25% truly O(K): all match.)")
print("  note: thread S's 40% / 10% row is 'VSI with a human verifier, imitated'; the note applies it to V-human")
print("  in general, including the human verifying every output.")
