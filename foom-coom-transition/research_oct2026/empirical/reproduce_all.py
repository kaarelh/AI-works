#!/usr/bin/env python3
"""Reproduce the three analyses offline using this interpreter's dependencies."""
from pathlib import Path
import os
import subprocess
import sys

root = Path(__file__).resolve().parent
scripts = [root / "controlled_vintage/fit.py",
           root / "rebench/digitize_and_fit.py",
           root / "pretraining/analyze.py",
           root / "consolidate.py"]
for script in scripts:
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1",
               MPLCONFIGDIR=str(script.parent / ".mplconfig"),
               XDG_CACHE_HOME=str(script.parent / ".cache"))
    print(f"Running {script.relative_to(root)}", flush=True)
    subprocess.run([sys.executable, str(script)], cwd=script.parent, env=env, check=True)
print("All three offline analyses completed.")
