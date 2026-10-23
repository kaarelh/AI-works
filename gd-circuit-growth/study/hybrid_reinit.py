"""Networks re-trained on the SAME training sets with a DIFFERENT initialisation (for the per-example-agreement ceiling).

In the main sweep the seed s fixes both the training set and the initialisation (PRNGKey(1000 s + 7)); the NN-SGD vs
NN-Adam reference therefore shares both.  This script re-runs nn_train.run_fixed with every initial key folded with a
constant, so the training sets (and minibatch order) are unchanged but the initial weights are fresh.  Used by
hybrid_diagnose.py to separate how much of two networks' agreement on individual test points comes from the shared
training set and how much from the shared initialisation.

    XLA_FLAGS="--xla_cpu_multi_thread_eigen=false intra_op_parallelism_threads=1" \
        python hybrid_reinit.py <out_dir> [fns] [ns]
"""
import sys, os
import jax
import nn_train

_orig_init = nn_train.init_params
nn_train.init_params = lambda key: _orig_init(jax.random.fold_in(key, 271828))

if __name__ == "__main__":
    out = sys.argv[1]
    fns = sys.argv[2].split(",") if len(sys.argv) > 2 else ["and3", "maj9", "par3", "majpar", "mux", "dlist5", "sparsepoly", "rand1", "rand3"]
    ns = [int(v) for v in sys.argv[3].split(",")] if len(sys.argv) > 3 else [16, 32, 64, 128, 256, 512, 1024, 2048]
    for fn in fns:
        if os.path.exists(os.path.join(out, f"fixed_adam_{fn}.npz")):
            continue
        nn_train.run_fixed(fn, "adam", 1e-3, ns, [0, 1, 2], 20000, out, save_params=True)
