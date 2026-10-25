"""Fourier-race predictions of a network's learning trajectory for one target.

    python predict.py <fn> <out_dir>

writes <out_dir>/<fn>__<cond>.npz for cond in online, 16384, 2048, 512, with arrays
    steps [T]         training steps
    f     [T, 2^r]    predicted E[f | x_R] on the relevant cube (itertools.product([-1, 1], repeat=r) order)
for any fn in boolfuncs.make_suite(30).  Uses only the target (its Fourier coefficients); the constants are in
model.PARAMS.  Single-threaded, a few seconds per target.
"""
import os, sys
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model as M

CONDS = ["online", "16384", "2048", "512"]


def main(fn, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    sp = M.spectrum(fn)
    for cond in CONDS:
        steps, f = M.predict(fn, cond, sp=sp)
        np.savez_compressed(os.path.join(out_dir, f"{fn}__{cond}.npz"), steps=steps.astype(np.float64),
                            f=f.astype(np.float32))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
