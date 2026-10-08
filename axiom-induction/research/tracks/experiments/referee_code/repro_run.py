"""Referee: re-run the track's experiments without touching code/results.
Patches common.RESULTS so every results file goes to referee_code/repro/.  Usage: python3 repro_run.py e2_pa [e5_gold ...]
Run with PYTHONDONTWRITEBYTECODE=1 so no __pycache__ is written into the track's code folder."""
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
os.chdir(EXP)
import common  # noqa: E402
common.RESULTS = os.path.join(HERE, 'repro')
os.makedirs(common.RESULTS, exist_ok=True)

for name in sys.argv[1:]:
    t0 = time.time()
    mod = __import__(name)
    mod.main()
    print(name, 'done in %.0f s' % (time.time() - t0), flush=True)
