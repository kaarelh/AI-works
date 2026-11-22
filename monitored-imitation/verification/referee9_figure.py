"""Referee 9: regenerate the paper's Figure 2 with paper/make_paper_figures.py, unchanged, into a scratch
directory, and compare it with the committed paper/fig_e6.pdf (rendered to pixels).

Usage (from monitored-imitation/):  python3 -B verification/referee9_figure.py SCRATCH_DIR > verification/referee9_figure.out
Writes only into SCRATCH_DIR. Needs pdftoppm.
"""
import importlib.util
import os
import subprocess
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
scratch = os.path.abspath(sys.argv[1])
os.makedirs(scratch, exist_ok=True)
sys.dont_write_bytecode = True

spec = importlib.util.spec_from_file_location("mpf", os.path.join(ROOT, "paper", "make_paper_figures.py"))
mpf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mpf)
mpf.HERE = scratch          # RES and VER still point at the repository's results/ and verification/
mpf.main()                  # writes scratch/fig_e6.pdf and prints the parsed S,U,S,H column

def render(pdf, stem):
    subprocess.run(["pdftoppm", "-r", "100", "-png", "-singlefile", pdf, os.path.join(scratch, stem)], check=True)
    return np.asarray(Image.open(os.path.join(scratch, stem + ".png")).convert("L"), dtype=float)

a = render(os.path.join(ROOT, "paper", "fig_e6.pdf"), "committed")
b = render(os.path.join(scratch, "fig_e6.pdf"), "regenerated")
print("committed size", a.shape, "regenerated size", b.shape)
if a.shape == b.shape:
    d = np.abs(a - b)
    print(f"pixels differing by more than 32 grey levels: {(d > 32).sum()} of {d.size}; max difference {d.max():.0f}")
else:
    print("sizes differ")

# the data each panel plots, for the record
import json
R = lambda *p: os.path.join(ROOT, *p)
same = json.load(open(R("results", "slack_imitation_same.json")))
summ = json.load(open(R("results", "slack_imitation_summary.json")))
ver = json.load(open(R("results", "slack_imitation_verifier.json")))
ns = [16, 64, 256]
print("(a) CI noticing:", [same[f"noticing_n{n}_same_CI_n0"]["task_mean"] for n in ns])
for kind in ["noticing", "fooled", "silent"]:
    print(f"(a) SI {kind}:", [summ[f"{kind}_n{n}_sigma{n//2}_CI"]["task_mean"] for n in ns])
for kind in ["noticing", "fooled", "silent"]:
    print(f"(b) SI-V {kind}:", [ver[f"{kind}_n{n}_sigma{n//2}_SIV"]["task_mean"] for n in ns])
sush = mpf.sush_column()
for mech in ["M1", "M2", "M3"]:
    print(f"(b) VSI S,U,S,H {mech}:", [sush[(mech, n0)] for n0 in (8, 32, 128)])
print("Note: panel (b) pairs E6's humans (SI-V, results/slack_imitation_verifier.json) with E7's M1-M3 "
      "(referee 8's rerun); thread R's reproduction table confirms that M1-M3 are E6's noticing, fooled and "
      "silent humans (E6 SI-V reproduced exactly).")
