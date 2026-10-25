import re, sys
for path in sys.argv[1:]:
    for line in open(path):
        m = re.match(r"\[(.*)\] (\d+)s\s+MAE ([\d.]+) scSp ([-\d.na]+) sclog ([\d.]+) succ ([\d.]+) ex ([-\d.na]+) \((\d+)\) tSp ([-\d.na]+)", line)
        if m:
            kw, sec, mae, scsp, sclog, succ, ex, npc, tsp = m.groups()
            score = float(mae) + 0.05 * float(sclog) - 0.05 * float(ex) - 0.05 * float(succ)
            print(f"{kw:45s} MAE {mae} scSp {scsp} sclog {sclog} succ {succ} ex {ex} tSp {tsp}  score {score:.4f}  ({sec}s)")
        elif line.startswith("  n*"):
            print("     " + line.strip())
