#!/usr/bin/env python3
"""Synthesis check (2026-10-16): re-run the threads' check scripts on a scratch copy and compare outputs.

Deterministic harness (the scripts themselves are seeded or deterministic, as their records state).
Usage: python3 rerun_checks.py <scratch-copy-root> <threads...>
  <scratch-copy-root>/<thread>/checks/ must be a copy of research/tracks/<thread>/checks/.
For each X.py with a saved X.out: delete the scratch X.out, run X.py (cwd = that folder, timeout per script),
then compare the regenerated X.out (or, if the script prints instead of writing, its stdout) byte for byte with
the saved copy in the repository.  Scripts listed in SKIP are not run (with the reason).
Scripts that import pyerfa need PYTHONPATH pointing to a pyerfa 2.0.1.5 installation (the threads used one in a
scratch library folder); RERUN_TIMEOUT overrides the per-script timeout; RERUN_ONLY (comma-separated file names) restricts the run.
"""
import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent / "tracks"
TIMEOUT = int(os.environ.get("RERUN_TIMEOUT", "300"))  # seconds per script; override by env
SKIP = {
    ("philosophy", "c4b_volume_crosscheck.py"): "did not finish in 72 min in the thread's own run (philosophy §4.4)",
}


def md5(b):
    return hashlib.md5(b).hexdigest()[:10]


def main():
    root = Path(sys.argv[1])
    threads = sys.argv[2:]
    for t in threads:
        d = root / t / "checks"
        for py in sorted(d.glob("*.py")):
            out = py.with_suffix(".out")
            saved = REPO / t / "checks" / out.name
            if not saved.exists():
                continue
            only = os.environ.get("RERUN_ONLY")
            if only and py.name not in only.split(","):
                continue
            if (t, py.name) in SKIP:
                print(f"{t}/{py.name}: SKIPPED ({SKIP[(t, py.name)]})", flush=True)
                continue
            if out.exists():
                out.unlink()
            t0 = time.time()
            try:
                r = subprocess.run([sys.executable, py.name], cwd=d, capture_output=True, timeout=TIMEOUT)
                status = f"exit {r.returncode}"
                stdout = r.stdout
            except subprocess.TimeoutExpired as e:
                status = f"TIMEOUT after {TIMEOUT}s"
                stdout = e.stdout or b""
            dt = time.time() - t0
            new = out.read_bytes() if out.exists() else stdout
            src = "file" if out.exists() else "stdout"
            old = saved.read_bytes()
            same = "IDENTICAL" if new == old else f"DIFFERS (saved {md5(old)}, new {md5(new)}, {len(old)} vs {len(new)} bytes)"
            print(f"{t}/{py.name}: {status}, {dt:.1f}s, compared {src}: {same}", flush=True)


if __name__ == "__main__":
    main()
