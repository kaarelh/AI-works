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


def loss_fn(ps, x, y):
    lg = forward(ps, x)
    return -jnp.mean(jnp.take_along_axis(jax.nn.log_softmax(lg), y[:, None], 1))


def make_runner(d, C, S):
    sizes = [d, W, W, C]
    every = S // NCK

    def adam_step(state, batch, lr):
        ps, m, v, t = state
        x, y = batch
        g = jax.grad(loss_fn)(ps, x, y)
        t = t + 1
        m = jax.tree_util.tree_map(lambda a, b: 0.9 * a + 0.1 * b, m, g)
        v = jax.tree_util.tree_map(lambda a, b: 0.999 * a + 0.001 * b * b, v, g)
        mh = jax.tree_util.tree_map(lambda a: a / (1 - 0.9 ** t), m)
        vh = jax.tree_util.tree_map(lambda a: a / (1 - 0.999 ** t), v)
        ps = jax.tree_util.tree_map(lambda p, a, b: p - lr * a / (jnp.sqrt(b) + 1e-8), ps, mh, vh)
        return (ps, m, v, t)

    def one_net(key, Xtr, ytr, ntr, lr, Xev, yev):
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
                return (adam_step(st, (Xtr[idx], ytr[idx]), lr), k), None
            (state, key), _ = jax.lax.scan(body, (state, key), None, length=every)
            accs = jnp.stack([jnp.mean(jnp.argmax(forward(state[0], X), 1) == Y) for X, Y in zip(Xev, yev)])
            return (state, key), accs
        _, accs = jax.lax.scan(chunk, (state, key), None, length=NCK)
        return accs                                                     # (NCK, n_eval_sets)

    return one_net


def run(name, seeds=(0, 1, 2)):
    D = DATA.load(name); grid = DATA.grid(D); C = D["C"]
    res = dict(learner="mlp", dataset=name, ns=grid, seeds=list(seeds), err=[], flops=[], flops_total=[], cpu_seconds=[],
               chosen_lr=[], chosen_step=[])
    for n in grid:
        S = n_steps(n); t0 = time.time()
        enc = []
        dom = {j: np.unique(D["X"][:, j]) for j, t in enumerate(D["types"]) if t == "categorical"}   # feature domain only
        for s in seeds:
            pool, te = DATA.splits(D, s); tr = pool[:n]
            nv = max(10, int(round(0.1 * n))); fit_idx, val_idx = tr[nv:], tr[:nv]
            Xf = encode_standard(D["X"][fit_idx], D["types"], ref=D["X"][fit_idx], domain=dom)
            Xv = encode_standard(D["X"][val_idx], D["types"], ref=D["X"][fit_idx], domain=dom)
            Xa = encode_standard(D["X"][tr], D["types"], ref=D["X"][tr], domain=dom)
            Xt_f = encode_standard(D["X"][te], D["types"], ref=D["X"][fit_idx], domain=dom)
            Xt_a = encode_standard(D["X"][te], D["types"], ref=D["X"][tr], domain=dom)
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
        keys, Xs, ys, nt, lrs, Xv, yv, Xt, yt = [], [], [], [], [], [], [], [], []
        for i, s in enumerate(seeds):
            for j, lr in enumerate(LRS):
                e = enc[i]; keys.append(jax.random.PRNGKey(1000 * s + 10 * j + 1))
                Xs.append(pad(e["Xf"], nmax)); ys.append(pad(e["yf"], nmax)); nt.append(len(e["yf"])); lrs.append(lr)
        Xv_ = [e["Xv"] for e in enc]; yv_ = [e["yv"] for e in enc]
        nvmax = max(len(a) for a in yv_)
        fn1 = jax.jit(jax.vmap(lambda k, X, y, ntr, lr, xv, yvv, xt, ytt: net(k, X, y, ntr, lr, (xv, xt), (yvv, ytt)),
                               in_axes=(0, 0, 0, 0, 0, 0, 0, 0, 0)))
        rep = lambda L: [L[i] for i in range(len(seeds)) for _ in LRS]
        Xvp = [pad(a, nvmax) for a in Xv_]; yvp = [np.concatenate([b, -np.ones(nvmax - len(b), b.dtype)]) for b in yv_]
        acc1 = np.asarray(fn1(jnp.stack(keys), f32(np.stack(Xs)), jnp.asarray(np.stack(ys)), jnp.asarray(nt), f32(lrs),
                              f32(np.stack(rep(Xvp))), jnp.asarray(np.stack(rep(yvp))),
                              f32(np.stack(rep([e["Xt_f"] for e in enc]))), jnp.asarray(np.stack(rep([e["yt"] for e in enc])))))
        # padded validation labels (-1) never match: rescale accuracy to the true validation size
        nv_true = np.array(rep([len(b) for b in yv_]), float)
        val = acc1[:, :, 0] * nvmax / nv_true[:, None]                 # (nets, NCK)
        chosen = []
        for i in range(len(seeds)):
            best = None
            for j in range(len(LRS)):
                k = i * len(LRS) + j
                c = int(np.argmax(val[k]))                               # first maximum: earliest checkpoint
                if best is None or val[k, c] > best[0]:
                    best = (val[k, c], j, c)
            chosen.append(best)
        # stage 2: retrain on all n with the chosen lr; read the test error at the chosen checkpoint
        Xa = [e["Xa"] for e in enc]; na = max(len(a) for a in Xa)
        keys2 = jnp.stack([jax.random.PRNGKey(777 + s) for s in seeds])
        fn2 = jax.jit(jax.vmap(lambda k, X, y, ntr, lr, xt, ytt: net(k, X, y, ntr, lr, (xt,), (ytt,))))
        acc2 = np.asarray(fn2(keys2, f32(np.stack([pad(a, na) for a in Xa])), jnp.asarray(np.stack([pad(e["ya"], na) for e in enc])),
                              jnp.asarray([len(e["ya"]) for e in enc]), f32([LRS[c[1]] for c in chosen]),
                              f32(np.stack([e["Xt_a"] for e in enc])), jnp.asarray(np.stack([e["yt"] for e in enc]))))
        err = [float(1 - acc2[i, chosen[i][2], 0]) for i in range(len(seeds))]
        fl = 6.0 * P * B * S
        res["err"].append(err); res["flops"].append([fl] * len(seeds)); res["flops_total"].append([3 * fl] * len(seeds))
        res["cpu_seconds"].append([(time.time() - t0) / len(seeds)] * len(seeds))
        res["chosen_lr"].append([LRS[c[1]] for c in chosen]); res["chosen_step"].append([(c[2] + 1) * (S // NCK) for c in chosen])
        print(f"  {name} n={n} S={S} P={P} err={np.round(err, 4).tolist()} lr={res['chosen_lr'][-1]} "
              f"step={res['chosen_step'][-1]} ({time.time() - t0:.0f}s)", flush=True)
        os.makedirs(RES, exist_ok=True)
        json.dump(res, open(os.path.join(RES, f"mlp__{name}.json"), "w"))
    return res


if __name__ == "__main__":
    for nm in sys.argv[1:]:
        run(nm)
