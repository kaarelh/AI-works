"""Reasonably tuned MLP baseline for the standard tasks (JAX, CPU).

Network: input -> 256 -> 256 -> C, ReLU, He-normal init, softmax cross-entropy, Adam (batch 128), no weight decay.
Inputs: harness.encode_standard (continuous standardized with the training set's statistics, binary +-1, categorical
one-hot over the column's code set in the whole dataset - feature domain only, no labels; MNIST / Fashion-MNIST pixels are
'continuous' and are standardized per pixel).
Steps: S = min(10000, max(2000, 50 epochs)); 40 checkpoints.

Model selection, per (dataset, n, seed):
  1. hold out 10% of the n training points (at least 10) as validation; train with lr in {1e-3, 3e-4};
  2. pick (lr, checkpoint) with the best validation accuracy (ties: earlier checkpoint);
  3. retrain on all n points with that lr and report the test error at that checkpoint.
All seeds x lrs train in parallel (vmap).  FLOPs: one training run = 6 P x 128 x S (the selection costs 3 runs in
all; we report the per-run figure as the 'MLP compute unit' and the total separately).

usage: python mlp.py <dataset> [<dataset> ...]   -> results/mlp__<dataset>.json
"""
import os, sys, time, json, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import jax, jax.numpy as jnp
import data as DATA
from harness import encode_standard, RES

W, B, LRS, NCK = 256, 128, (1e-3, 3e-4), 40
# variants (environment MLP_VARIANT): "" = the baseline above; "plus" = lr in {3e-3, 1e-3, 3e-4} x decoupled weight decay
# in {0, 0.05} (AdamW), 6 configurations per seed; "unit" = the baseline with continuous inputs scaled to [-1, 1] by their
# training max |x| instead of standardized (for images: raw [0, 1] pixels).
VARIANT = os.environ.get("MLP_VARIANT", "")
CONFIGS = [(lr, wd) for lr in (3e-3, 1e-3, 3e-4) for wd in (0.0, 0.05)] if VARIANT == "plus" else [(lr, 0.0) for lr in LRS]
# "l2" (added after the MLP-fairness audit): lr 1e-3 and a coupled L2 penalty lam/2 * sum ||W||^2 on the weight matrices,
# lam in {1e-4, 1e-3, 1e-2, 1e-1}; lam chosen by validation accuracy averaged over the last 4 checkpoints; the network
# retrained on all n is read at its FINAL checkpoint (no early stopping).
# "l2unit": the same as "l2" with the "unit" input scaling (for images: raw [0, 1] pixels).
if VARIANT in ("l2", "l2unit"):
    CONFIGS = [(1e-3, lam) for lam in (1e-4, 1e-3, 1e-2, 1e-1)]
TAG = "mlp" + (("_" + VARIANT) if VARIANT else "")


def n_steps(n):
    return int(min(10000, max(2000, math.ceil(50 * n / B))))


def init(key, sizes):
    ps = []
    for i in range(len(sizes) - 1):
        key, k = jax.random.split(key)
        ps.append((jax.random.normal(k, (sizes[i], sizes[i + 1])) * jnp.sqrt(2.0 / sizes[i]), jnp.zeros(sizes[i + 1])))
    return ps


def forward(ps, x):
    for i, (w, b) in enumerate(ps):
        x = x @ w + b
        if i < len(ps) - 1:
            x = jax.nn.relu(x)
    return x


def loss_fn(ps, x, y, lam=0.0):
    lg = forward(ps, x)
    ce = -jnp.mean(jnp.take_along_axis(jax.nn.log_softmax(lg), y[:, None], 1))
    return ce + 0.5 * lam * sum(jnp.sum(w * w) for w, _ in ps)


def make_runner(d, C, S):
    sizes = [d, W, W, C]
    every = S // NCK

    def adam_step(state, batch, lr, wd):
        ps, m, v, t = state
        x, y = batch
        g = jax.grad(loss_fn)(ps, x, y, wd if VARIANT in ("l2", "l2unit") else 0.0)
        t = t + 1
        m = jax.tree_util.tree_map(lambda a, b: 0.9 * a + 0.1 * b, m, g)
        v = jax.tree_util.tree_map(lambda a, b: 0.999 * a + 0.001 * b * b, v, g)
        mh = jax.tree_util.tree_map(lambda a: a / (1 - 0.9 ** t), m)
        vh = jax.tree_util.tree_map(lambda a: a / (1 - 0.999 ** t), v)
        dec = 0.0 if VARIANT in ("l2", "l2unit") else wd                         # 'plus': decoupled decay; 'l2': penalty in the loss
        ps = jax.tree_util.tree_map(lambda p, a, b: p - lr * a / (jnp.sqrt(b) + 1e-8) - lr * dec * p, ps, mh, vh)
        return (ps, m, v, t)

    def one_net(key, Xtr, ytr, ntr, lr, wd, Xev, yev):
        """Xtr padded (nmax, d) with ntr valid rows; returns accuracy on each eval set at each checkpoint."""
        k0, key = jax.random.split(key)
        ps = init(k0, sizes); z = jax.tree_util.tree_map(jnp.zeros_like, ps)
        state = (ps, z, z, 0)

        def chunk(carry, _):
            state, key = carry

            def body(c, _):
                st, k = c
                k, kb = jax.random.split(k)
                idx = jax.random.randint(kb, (B,), 0, ntr)
                return (adam_step(st, (Xtr[idx], ytr[idx]), lr, wd), k), None
            (state, key), _ = jax.lax.scan(body, (state, key), None, length=every)
            accs = jnp.stack([jnp.mean(jnp.argmax(forward(state[0], X), 1) == Y) for X, Y in zip(Xev, yev)])
            return (state, key), accs
        _, accs = jax.lax.scan(chunk, (state, key), None, length=NCK)
        return accs                                                     # (NCK, n_eval_sets)

    return one_net


def _enc(X, types, ref, dom):
    Z = encode_standard(X, types, ref=ref, domain=dom)
    if VARIANT not in ("unit", "l2unit"):
        return Z
    k = 0                                                              # rescale continuous columns: x / max|x_ref|
    for j, t in enumerate(types):
        if t == "categorical":
            k += len(dom[j]); continue
        if t != "binary":
            m = np.max(np.abs(ref[:, j])); Z[:, k] = X[:, j] / (m if m > 1e-12 else 1.0)
        k += 1
    return Z


def run(name, seeds=(0, 1, 2), max_n=None):
    D = DATA.load(name); grid = [n for n in DATA.grid(D) if max_n is None or n <= max_n]; C = D["C"]
    res = dict(learner=TAG, dataset=name, ns=grid, seeds=list(seeds), err=[], flops=[], flops_total=[], cpu_seconds=[],
               chosen_lr=[], chosen_wd=[], chosen_step=[], configs=CONFIGS)
    path = os.path.join(RES, f"{TAG}__{name}.json")
    if os.environ.get("MLP_RESUME") and os.path.exists(path):              # continue an interrupted run
        old = json.load(open(path))
        if old["ns"] == grid[:len(old["ns"])]:                            # same grid, or a prefix of it
            res = old; res["ns"] = grid
            res.setdefault("chosen_wd", [[0.0] * len(seeds) for _ in res["err"]]); res.setdefault("configs", CONFIGS)
            res["learner"] = TAG
    for n in grid[len(res["err"]):]:
        S = n_steps(n); t0 = time.time()
        enc = []
        dom = {j: np.unique(D["X"][:, j]) for j, t in enumerate(D["types"]) if t == "categorical"}   # feature domain only
        for s in seeds:
            pool, te = DATA.splits(D, s); tr = pool[:n]
            nv = max(10, int(round(0.1 * n))); fit_idx, val_idx = tr[nv:], tr[:nv]
            Xf = _enc(D["X"][fit_idx], D["types"], D["X"][fit_idx], dom)
            Xv = _enc(D["X"][val_idx], D["types"], D["X"][fit_idx], dom)
            Xa = _enc(D["X"][tr], D["types"], D["X"][tr], dom)
            Xt_f = _enc(D["X"][te], D["types"], D["X"][fit_idx], dom)
            Xt_a = _enc(D["X"][te], D["types"], D["X"][tr], dom)
            enc.append(dict(Xf=Xf, yf=D["y"][fit_idx], Xv=Xv, yv=D["y"][val_idx], Xa=Xa, ya=D["y"][tr], Xt_f=Xt_f, Xt_a=Xt_a,
                            yt=D["y"][te]))
        d = enc[0]["Xf"].shape[1]
        assert all(e["Xf"].shape[1] == d for e in enc), "encoding width differs across seeds"
        P = d * W + W + W * W + W + W * C + C
        net = make_runner(d, C, S)
        f32 = lambda a: jnp.asarray(a, jnp.float32)
        # stage 1: lr selection on validation (seeds x lrs nets)
        nmax = max(len(e["yf"]) for e in enc)
        pad = lambda A, m: np.concatenate([A, np.zeros((m - len(A),) + A.shape[1:], A.dtype)]) if len(A) < m else A
        keys, Xs, ys, nt, lrs, wds = [], [], [], [], [], []
        for i, s in enumerate(seeds):
            for j, (lr, wd) in enumerate(CONFIGS):
                e = enc[i]; keys.append(jax.random.PRNGKey(1000 * s + 10 * j + 1))
                Xs.append(pad(e["Xf"], nmax)); ys.append(pad(e["yf"], nmax)); nt.append(len(e["yf"])); lrs.append(lr); wds.append(wd)
        Xv_ = [e["Xv"] for e in enc]; yv_ = [e["yv"] for e in enc]
        nvmax = max(len(a) for a in yv_)
        fn1 = jax.jit(jax.vmap(lambda k, X, y, ntr, lr, wd, xv, yvv, xt, ytt: net(k, X, y, ntr, lr, wd, (xv, xt), (yvv, ytt))))
        rep = lambda L: [L[i] for i in range(len(seeds)) for _ in CONFIGS]
        Xvp = [pad(a, nvmax) for a in Xv_]; yvp = [np.concatenate([b, -np.ones(nvmax - len(b), b.dtype)]) for b in yv_]
        acc1 = np.asarray(fn1(jnp.stack(keys), f32(np.stack(Xs)), jnp.asarray(np.stack(ys)), jnp.asarray(nt), f32(lrs), f32(wds),
                              f32(np.stack(rep(Xvp))), jnp.asarray(np.stack(rep(yvp))),
                              f32(np.stack(rep([e["Xt_f"] for e in enc]))), jnp.asarray(np.stack(rep([e["yt"] for e in enc])))))
        # padded validation labels (-1) never match: rescale accuracy to the true validation size
        nv_true = np.array(rep([len(b) for b in yv_]), float)
        val = acc1[:, :, 0] * nvmax / nv_true[:, None]                 # (nets, NCK)
        chosen = []
        for i in range(len(seeds)):
            best = None
            for j in range(len(CONFIGS)):
                k = i * len(CONFIGS) + j
                if VARIANT in ("l2", "l2unit"):                          # final checkpoint; smoothed validation score
                    c, sc = NCK - 1, float(np.mean(val[k, -4:]))
                else:
                    c = int(np.argmax(val[k])); sc = val[k, c]           # first maximum: earliest checkpoint
                if best is None or sc > best[0]:
                    best = (sc, j, c)
            chosen.append(best)
        # stage 2: retrain on all n with the chosen lr; read the test error at the chosen checkpoint
        Xa = [e["Xa"] for e in enc]; na = max(len(a) for a in Xa)
        keys2 = jnp.stack([jax.random.PRNGKey(777 + s) for s in seeds])
        fn2 = jax.jit(jax.vmap(lambda k, X, y, ntr, lr, wd, xt, ytt: net(k, X, y, ntr, lr, wd, (xt,), (ytt,))))
        acc2 = np.asarray(fn2(keys2, f32(np.stack([pad(a, na) for a in Xa])), jnp.asarray(np.stack([pad(e["ya"], na) for e in enc])),
                              jnp.asarray([len(e["ya"]) for e in enc]), f32([CONFIGS[c[1]][0] for c in chosen]),
                              f32([CONFIGS[c[1]][1] for c in chosen]),
                              f32(np.stack([e["Xt_a"] for e in enc])), jnp.asarray(np.stack([e["yt"] for e in enc]))))
        err = [float(1 - acc2[i, chosen[i][2], 0]) for i in range(len(seeds))]
        fl = 6.0 * P * B * S
        res["err"].append(err); res["flops"].append([fl] * len(seeds)); res["flops_total"].append([(len(CONFIGS) + 1) * fl] * len(seeds))
        res["cpu_seconds"].append([(time.time() - t0) / len(seeds)] * len(seeds))
        res["chosen_lr"].append([CONFIGS[c[1]][0] for c in chosen]); res["chosen_wd"].append([CONFIGS[c[1]][1] for c in chosen])
        res["chosen_step"].append([(c[2] + 1) * (S // NCK) for c in chosen])
        print(f"  {name} n={n} S={S} P={P} err={np.round(err, 4).tolist()} lr={res['chosen_lr'][-1]} "
              f"step={res['chosen_step'][-1]} ({time.time() - t0:.0f}s)", flush=True)
        os.makedirs(RES, exist_ok=True)
        json.dump(res, open(os.path.join(RES, f"{TAG}__{name}.json"), "w"))
    return res


if __name__ == "__main__":
    mx = int(os.environ["MLP_MAX_N"]) if os.environ.get("MLP_MAX_N") else None
    for nm in sys.argv[1:]:
        run(nm, max_n=mx)
