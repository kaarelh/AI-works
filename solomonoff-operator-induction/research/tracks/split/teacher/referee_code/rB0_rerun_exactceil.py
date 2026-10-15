"""rB0: re-run the prover's t2 and t3 with exact ceilings of log2 binomials, and report every output
line that changes.

The prover's tcommon.log2binom uses lgamma; math.ceil of it is one bit too large when the binomial
is an exact power of 2 (C(2^m, 1) = 2^m, C(2^m, 2^m - 1) = 2^m) for several m, e.g. m = 4, 6, 8, 10
(rB2(D)). So the single-cell rule (F5, j = 1) and the single named input (F3, j = 1, d = 10) are
charged one bit too many. This script imports the prover's modules read-only (no bytecode is
written into checks/), replaces log2binom by an exact version in each module namespace, re-runs
part_A and part_B with the same seeds, and diffs against the saved outputs.
Deterministic (the prover's seeds).
"""
import contextlib
import difflib
import importlib
import io
import math
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
CHECKS = os.path.join(HERE, "..", "checks")
sys.path.insert(0, CHECKS)


def exact_log2binom(n, k):
    c = math.comb(int(n), int(k))
    return float(math.log2(c)) if c > 0 else 0.0


def rerun(modname, patch):
    if modname in sys.modules:
        del sys.modules[modname]
    if "tcommon" in sys.modules:
        del sys.modules["tcommon"]
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        mod = importlib.import_module(modname)  # module-level rng is (re)created here with the prover's seed
        if patch:
            mod.log2binom = exact_log2binom
        mod.part_A()
        mod.part_B()
    return buf.getvalue()


for modname in ("t2_reuse_factor", "t3_second_kink"):
    saved = open(os.path.join(CHECKS, modname + ".out")).read()
    plain = rerun(modname, patch=False)
    print("=" * 100)
    print(f"{modname}: unpatched re-run identical to the saved output: {plain == saved}")
    patched = rerun(modname, patch=True)
    diff = list(difflib.unified_diff(saved.splitlines(), patched.splitlines(), lineterm="", n=0,
                                     fromfile="saved", tofile="exact ceilings"))
    print(f"{modname}: lines changed with exact ceilings: {sum(1 for l in diff if l.startswith('+') and not l.startswith('+++'))}")
    for line in diff:
        print("   " + line)
