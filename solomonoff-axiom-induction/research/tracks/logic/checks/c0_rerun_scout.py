"""c0_rerun_scout.py -- re-run scout N1's scripts c1_lottery.py and c3_threshold.py on scratch
copies and compare their output byte for byte with the outputs saved in the scout's folder.

Deterministic: the scout scripts are seeded (20261015). No randomness here.
Output: c0_rerun_scout.out (stdout of this script).
Usage: python3 -I c0_rerun_scout.py <scratch_dir> [<scout_checks_dir>]
The scout folder defaults to ../../../scouts/novel-logic/checks relative to this file, so run the
script in place or pass the folder explicitly (revision; referee B, issue 11: a copy of the script
run elsewhere could not find the folder).
"""
import hashlib
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCOUT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "scouts", "novel-logic", "checks"))


def main():
    global SCOUT
    scratch = sys.argv[1]
    if len(sys.argv) > 2:
        SCOUT = os.path.abspath(sys.argv[2])
    os.makedirs(scratch, exist_ok=True)
    for name in ("c1_lottery", "c3_threshold"):
        src = os.path.join(SCOUT, name + ".py")
        dst_dir = os.path.join(scratch, name)
        os.makedirs(dst_dir, exist_ok=True)
        dst = os.path.join(dst_dir, name + ".py")
        shutil.copyfile(src, dst)
        res = subprocess.run([sys.executable, "-I", dst], capture_output=True, cwd=dst_dir)
        saved = open(os.path.join(SCOUT, name + ".out"), "rb").read()
        same = res.stdout == saved
        h_new = hashlib.sha256(res.stdout).hexdigest()[:16]
        h_old = hashlib.sha256(saved).hexdigest()[:16]
        print(f"{name}: exit code {res.returncode}; {len(res.stdout)} bytes (sha256 {h_new}) "
              f"vs saved {len(saved)} bytes (sha256 {h_old}); byte-identical: {same}")
        tail = res.stdout.decode().strip().splitlines()[-1]
        print(f"  last line of rerun: {tail}")
        if res.stderr:
            print("  stderr:", res.stderr.decode()[:500])
    print("done")


if __name__ == "__main__":
    main()
