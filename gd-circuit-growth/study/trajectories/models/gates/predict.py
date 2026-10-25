"""python predict.py <fn> <out_dir>  ->  <out_dir>/<fn>__{online,16384,2048,512}.npz (steps [T'], f [T', 2^r]).
Works for any target in boolfuncs.make_suite(30); about a second per target.  Run with OPENBLAS_NUM_THREADS=1."""
import os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gates as G


def main(fn, out):
    os.makedirs(out, exist_ok=True)
    pred, ev, T = G.predict(fn)
    for cond, (st, f) in pred.items():
        np.savez(os.path.join(out, f"{fn}__{cond}.npz"), steps=st, f=f)
    names = lambda js: ",".join("x" + "".join(str(T["R"][i] + 1) for i in T["subs"][j]) for j in js)
    for tf, ta, k, js in ev:
        print(f"{fn}: step {tf:8.0f}  order {k}  {names(js)[:100]}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
