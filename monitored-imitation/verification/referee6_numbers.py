"""Referee 6: check the numbers quoted in verified-slack.md (Sections 3, 4, 7 and the
answers in brief) against the thread outputs and E6's result files.

Reads only; writes nothing but stdout.  Run from the repository's monitored-imitation folder:
    python3 verification/referee6_numbers.py > verification/referee6_numbers.out
"""
import json
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def load(path):
    with open(os.path.join(ROOT, path)) as f:
        return json.load(f)


def hdr(s):
    print()
    print("=" * 78)
    print(s)
    print("=" * 78)


KINDS = ["noticing", "misled-2", "misled-8", "fooled", "silent"]
BOUNDED = ["noticing", "misled-2", "misled-8"]
NS = [16, 64, 256]

# ---------------------------------------------------------------------------
hdr("1. EQ (threadQ_hints.json): the note's Section 7 'EQ' bullet")
q = load("research/threadQ_hints.json")


def tm(kind, n, prot):
    return q[f"{kind}_n{n}_{prot}"]["task_mean"]


for prot in ["U", "US", "UH", "USH", "UA"]:
    for kind in KINDS:
        vals = [tm(kind, n, prot) for n in NS]
        print(f"  {prot:4s} {kind:9s} " + " -> ".join(f"{v:8.1f}" for v in vals))

print()
print("  Note: 'fooled humans: 181 -> 750 -> 2,636 under uniform search, and 28 -> 37 -> 36")
print("  with the H stream'.  VSI's search is U+S+H.  Values:")
for prot in ["U", "UH", "USH"]:
    print(f"    fooled {prot:4s}: " + " -> ".join(f"{tm('fooled', n, prot):.1f}" for n in NS))

print()
print("  Note: 'bounded-setback humans pay at most 1.5x' for the extra streams.")
worst = (0, None)
for prot in ["US", "UH", "USH"]:
    for kind in BOUNDED:
        for n in NS:
            r = tm(kind, n, prot) / tm(kind, n, "U")
            print(f"    {prot:4s}/U {kind:9s} n={n:3d}: {r:.3f}")
            if r > worst[0]:
                worst = (r, (prot, kind, n))
print(f"  max ratio over bounded-setback cells: {worst[0]:.3f} at {worst[1]}")

print()
print("  Note: 'an adversarial list at most 1.6x' (UA/U), all kinds:")
worst = (0, None)
for kind in KINDS:
    for n in NS:
        r = tm(kind, n, "UA") / tm(kind, n, "U")
        print(f"    UA/U {kind:9s} n={n:3d}: {r:.3f}")
        if r > worst[0]:
            worst = (r, (kind, n))
print(f"  max UA/U: {worst[0]:.3f} at {worst[1]}  (Lemma 3's guarantee for 2 streams: 2)")

print()
print("  Scan stream on silent humans (US/U):")
for n in NS:
    print(f"    n={n:3d}: U {tm('silent', n, 'U'):.1f}, US {tm('silent', n, 'US'):.1f}, ratio {tm('silent', n, 'U')/tm('silent', n, 'US'):.2f}")

print()
print("  Queries per rejection versus Theorem 5(c)'s worst case 3 n0 (n0 = n/2), U+S+H:")
for kind in KINDS:
    row = []
    for n in NS:
        e = q[f"{kind}_n{n}_USH"]
        row.append(f"n0={n//2:3d}: {e['per_rejection']:.1f} (<= {3*n//2})")
    print(f"    {kind:9s} " + "; ".join(row))

# ---------------------------------------------------------------------------
hdr("2. E6 (results/*.json): the note's Section 7 'E6' bullet and the 6-23x remark")
same = load("results/slack_imitation_same.json")
summ = load("results/slack_imitation_summary.json")
ver = load("results/slack_imitation_verifier.json")
abc = load("results/slack_imitation_verifier_abc.json")


def g(dct, key):
    return dct[key]["task_mean"] if "task_mean" in dct[key] else dct[key]


print("  chained imitation without slack, same humans (n = n0):")
for kind in KINDS:
    vals = []
    for n in NS:
        e = same[f"{kind}_n{n}_same_CI_n0"]
        vals.append(e.get("task_mean", e.get("queries_mean", float("nan"))))
    print(f"    {kind:9s} " + " -> ".join(f"{v:9.1f}" for v in vals))

print("  SI with slack (n = 2 n0):")
for kind in KINDS:
    vals = []
    for n in NS:
        e = summ[f"{kind}_n{n}_sigma{n//2}_CI"]
        vals.append(e.get("task_mean", e.get("queries_mean", float("nan"))))
    print(f"    {kind:9s} " + " -> ".join(f"{v:9.1f}" for v in vals))

print("  SI-V (uniform search), total task queries for 100 problems:")
for kind in KINDS:
    vals = [ver[f"{kind}_n{n}_sigma{n//2}_SIV"]["task_mean"] for n in NS]
    print(f"    {kind:9s} " + " -> ".join(f"{v:9.1f}" for v in vals))

print()
print("  Note: 'In E6 [asking] multiplied the cost for bounded-setback humans by 6-23'.")
for alpha in [0.3, 0.1]:
    rs = []
    for kind in BOUNDED:
        for n in NS:
            a = abc[f"{kind}_n{n}_sigma{n//2}_SIV-ABC_alpha{alpha}"]["task_mean"]
            v = ver[f"{kind}_n{n}_sigma{n//2}_SIV"]["task_mean"]
            rs.append(a / v)
    print(f"    alpha = {alpha}: SI-V-ABC / SI-V ranges {min(rs):.1f} .. {max(rs):.1f}")

# ---------------------------------------------------------------------------
hdr("3. G1 (threadG_byproducts_sim.out): 'about 300 task queries at every size'")
txt = open(os.path.join(ROOT, "research/threadG_byproducts_sim.out")).read()
for line in txt.splitlines():
    if line.startswith("| REVIEW | LASTREV") or line.startswith("| REVIEW | MIXREV") or line.startswith("| DO "):
        print("   ", line)

# ---------------------------------------------------------------------------
hdr("4. F1 (threadF_certified.out, threadF_cbc.out)")
ftxt = open(os.path.join(ROOT, "research/threadF_certified.out")).read()
pat = re.compile(r"^(\S+)\s+failed\s+([\d.]+)", re.M)
f = {m.group(1): float(m.group(2)) for m in pat.finditer(ftxt)}
for n in [32, 64, 128]:
    si = f[f"C_trusting_r1_n{n}_SI"]
    sa = f[f"C_trusting_r1_n{n}_SI-ABC_a0.3"]
    csi = f[f"C_trusting_r1_n{n}_CSI"]
    w1 = f[f"W_trusting_r1_n{n}_SI"]
    w2 = f[f"W_trusting_r2_n{n}_SI"]
    w3 = f[f"W_trusting_r3_n{n}_SI"]
    wa05 = f.get(f"W_trusting_r1_n{n}_SI-ABC_a0.05", float("nan"))
    print(f"  n={n:3d}: C/SI {si:7.1f}  C/SI-ABC {sa:7.1f}  C/CSI {csi:5.1f}  |  W r=1 {w1:7.1f}, "
          f"r=2 {w2:6.1f} (/{w1/w2:.2f}), r=3 {w3:6.1f} (/{w1/w3:.2f}); W SI-ABC a=0.05 {wa05:.1f}")
print("  Note: 'trusted false negatives grow with n under every protocol' -- but W with")
print("  SI-ABC at alpha = 0.05 has 0 failures at every n (thread F's own table).")
cbc = open(os.path.join(ROOT, "research/threadF_cbc.out")).read()
print("  threadF_cbc.out:")
for line in cbc.splitlines():
    print("   ", line)

# ---------------------------------------------------------------------------
hdr("5. Thread J's class W: is each query 'a point query on about n/(D+1) candidate windows'?")
print("  Theorem J1: s = ceil((sigma+1)/(D+1)), N = n - s(D+1) + 1, load l >= N/s.")
print("  The effective number of candidates is N/s ~ Lambda = min{n, (D+1)n/(sigma+1)},")
print("  not n/(D+1).")
print(f"  {'n':>4} {'sigma':>5} {'D':>3} {'s':>4} {'N':>5} {'N/s':>8} {'Lambda':>8} {'n/(D+1)':>8}")
for n, sigma, D in [(64, 32, 0), (64, 32, 1), (64, 32, 3), (64, 32, 15), (256, 128, 2), (40, 20, 2), (40, 0, 0)]:
    n0 = n - sigma
    if D > n0 / 2:
        continue
    s = math.ceil((sigma + 1) / (D + 1))
    N = n - s * (D + 1) + 1
    lam = min(n, (D + 1) * n / (sigma + 1))
    print(f"  {n:4d} {sigma:5d} {D:3d} {s:4d} {N:5d} {N/s:8.2f} {lam:8.2f} {n/(D+1):8.2f}")

# ---------------------------------------------------------------------------
hdr("6. Section 6 arithmetic: 'VSI works in the worst case' (3 n0 K vs 20 n0 K)")
print("  Ratio of guarantees: 3 n0 K / (n0 K / 0.05) = 0.15 < 0.2.  This compares UPPER BOUNDS;")
print("  chained imitation's actual cost can be far below n0 K / eps (see report B5).")
print("  Extra human effort not in 3 n0 K: verifications, post-mortem reads (<= K/b), audits.")
print("  With an imitated verifier at eps_V = 5%: ~20 K_V verifications of cost c_V task steps each.")
print("  VSI stays under a fifth of 20 n0 K iff 3 n0 K + 20 c_V K_V + c_PM K <= 4 n0 K:")
for n0 in [20, 40]:
    for kv in [0.5, 1.0]:
        for cpm in [0.0, 0.1]:
            cv_max = (n0 - cpm) / (20 * kv)
            print(f"    n0 = {n0}, K_V/K = {kv}, post-mortem cost {cpm} steps: needs c_V <= {cv_max:.2f} task steps")

# ---------------------------------------------------------------------------
hdr("7. Imitated verifier when the verdict needs problem-specific knowledge")
print("  Hidden-insight class (note.md Theorem 3), each of m problems seen once (T = m).")
print("  An unlocated insight problem's run fails; V_H rejects it; V' (posterior Pr[insight] = eta < 1/2)")
print("  accepts it.  So unasked false acceptances = (1 - beta) * (#insight problems) ~ (1 - beta) eta m.")
print("  Output failure <= eps needs beta >= 1 - eps/eta, i.e. almost every notebook verified.")
for eta in [0.05, 0.1, 0.2]:
    for eps in [0.01, 0.02, 0.05]:
        if eps >= eta:
            continue
        beta = 1 - eps / eta
        h = -eta * math.log2(eta) - (1 - eta) * math.log2(1 - eta)
        kv_per_problem = h  # K_V >= m h(eta): the verdicts encode which problems hide an insight
        print(f"    eta = {eta:4.2f}, eps = {eps:4.2f}: beta >= {beta:4.2f}; verifications >= {beta:4.2f} m; "
              f"K_V/eps >= {kv_per_problem/eps:5.1f} m  (vs T = m verifying everything)")
print("  Theorem 6 is not contradicted (K_V grows with m), but 'about K_V/eps verifications, for")
print("  any number of problems' saves nothing here: imitation pays only if verdicts are generic")
print("  (e.g. line-by-line proof checking) or problems recur.")
