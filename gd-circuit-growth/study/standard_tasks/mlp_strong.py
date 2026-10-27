"""A stronger MLP reference for Part 8 (defined after the Part 8 fairness audit, from standard practice; not tuned on any
held-out result).  Same network size and step budget as mlp.py (input -> 256 -> 256 -> C, ReLU, He init, batch 128,
S = min(10000, max(2000, 50 epochs)), softmax cross-entropy), plus:
  inputs     continuous tabular columns quantile-transformed to a standard normal (sklearn QuantileTransformer fitted on
             the training rows); image pixels scaled to [0, 1] (MNIST, Fashion-MNIST; the Part 9 QuickDraw sets are not
             in IMAGES, so their pixels are quantile-transformed: Part 9 fairness audit F4, where quantile inputs were
             the better encoding in every paired probe); binary +-1; categorical one-hot over the column's domain;
  optimizer  AdamW, lr 1e-3 with cosine decay to 0 over S steps; decoupled weight decay wd in {0, 0.1, 1.0}
             (p -= lr_t wd p), chosen per (dataset, n, seed) by validation accuracy averaged over the last 4 of 40
             checkpoints (10% of the n points held out, at least 10);
  dropout    0.1 on both hidden layers;
  ensemble   3 networks (different initialisations and batch orders) retrained on all n with the chosen wd; prediction =
             argmax of the averaged softmax at the final step.
Cost per fit: 3 selection runs + 3 retrained networks = 6 training runs (the baseline mlp: 3; the discrete learners'
budget: 3).  Results: results/mlp_strong__<ds>.json (the ensemble) and results/mlp_strong1__<ds>.json (its first network
alone, i.e. the same recipe without ensembling).
usage: python mlp_strong.py <dataset> [...]   (env MLP_MAX_N: largest n; MLP_RESUME=1: continue an interrupted run;
MLP_SEED0_FROM=m: seed 0 only for n >= m, the other seeds NaN - as for the discrete learners on images)"""
import os, sys, time, json, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import jax, jax.numpy as jnp
import data as DATA
from harness import RES

W, B, NCK, LR, WDS, DROP, ENS = 256, 128, 40, 1e-3, (0.0, 0.1, 1.0), 0.1, 3
IMAGES = ("mnist", "fashion_mnist")
# Part 9 variants (PROTOCOL.md, Amendment 4), all off by default: MLP_W width, MLP_WDS weight-decay grid (comma list),
# MLP_ENS ensemble size, MLP_TAG result name (its first network alone is <tag>1), MLP_NS the n values to run (comma
# list), MLP_FEATS=pool: append the pooled sums of hyb_portfolio2's pool_sets at k = 4, 9, 16 (pooling sets computed on
# each fit's n training rows; encoded like the other columns).
W = int(os.environ.get("MLP_W", W)); ENS = int(os.environ.get("MLP_ENS", ENS))
WDS = tuple(float(v) for v in os.environ["MLP_WDS"].split(",")) if os.environ.get("MLP_WDS") else WDS
TAG = os.environ.get("MLP_TAG", "mlp_strong"); FEATS = os.environ.get("MLP_FEATS", "")


def pooled(Xtr):
    """The pooled-sum map of hyb_portfolio2 (part9/hyb_portfolio2/learner.py, pool_sets) fitted on training rows Xtr."""
    import importlib.util
    sp = importlib.util.spec_from_file_location("hp2_learner", os.path.join(os.path.dirname(HERE), "part9", "hyb_portfolio2", "learner.py"))
    m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
    As, _ = m.pool_sets(Xtr, (4, 9, 16))
    A = np.concatenate([As[k] for k in (4, 9, 16)], 1)
    return lambda X: np.concatenate([X, X @ A], 1)


def n_steps(n):
    return int(min(10000, max(2000, math.ceil(50 * n / B))))


def encode(X, types, ref, dom, image):
    from sklearn.preprocessing import QuantileTransformer
    cols, cont = [], [j for j, t in enumerate(types) if t not in ("binary", "categorical")]
    if cont and not image:
        qt = QuantileTransformer(n_quantiles=min(1000, len(ref)), output_distribution="normal", subsample=10 ** 9,
                                 random_state=0).fit(ref[:, cont])
        Q = qt.transform(X[:, cont])
    for j, t in enumerate(types):
        x = X[:, j]
        if t == "categorical":
            cols += [np.where(x == v, 1.0, 0.0) for v in dom[j]]
        elif t == "binary":
            cols.append(np.where(x > np.min(ref[:, j]), 1.0, -1.0))
        elif image:
            m = np.max(np.abs(ref[:, j])); cols.append(x / (m if m > 1e-12 else 1.0))
        else:
            cols.append(Q[:, cont.index(j)])
    return np.stack(cols, 1).astype(np.float32)


def init(key, sizes):
    ps = []
    for i in range(len(sizes) - 1):
        key, k = jax.random.split(key)
        ps.append((jax.random.normal(k, (sizes[i], sizes[i + 1])) * jnp.sqrt(2.0 / sizes[i]), jnp.zeros(sizes[i + 1])))
    return ps


def forward(ps, x, key=None):
    for i, (w, b) in enumerate(ps):
        x = x @ w + b
        if i < len(ps) - 1:
            x = jax.nn.relu(x)
            if key is not None:                                          # inverted dropout (training only)
                key, k = jax.random.split(key)
                x = jnp.where(jax.random.bernoulli(k, 1 - DROP, x.shape), x / (1 - DROP), 0.0)
    return x


def make_net(d, C, S):
    sizes, every = [d, W, W, C], S // NCK

    def loss(ps, x, y, key):
        lg = forward(ps, x, key)
        return -jnp.mean(jnp.take_along_axis(jax.nn.log_softmax(lg), y[:, None], 1))

    def step(state, x, y, key, wd):
        ps, m, v, t = state
        g = jax.grad(loss)(ps, x, y, key)
        t = t + 1
        lr = LR * 0.5 * (1 + jnp.cos(jnp.pi * t / S))
        m = jax.tree_util.tree_map(lambda a, b: 0.9 * a + 0.1 * b, m, g)
        v = jax.tree_util.tree_map(lambda a, b: 0.999 * a + 0.001 * b * b, v, g)
        c1, c2 = 1 - 0.9 ** t, 1 - 0.999 ** t
        ps = jax.tree_util.tree_map(lambda p, a, b: p - lr * (a / c1) / (jnp.sqrt(b / c2) + 1e-8) - lr * wd * p, ps, m, v)
        return (ps, m, v, t)

    def train(key, X, y, ntr, wd, Xev, yev):
        """Returns (accuracy on (Xev, yev) at each of NCK checkpoints, final softmax on Xev)."""
        k0, key = jax.random.split(key)
        ps = init(k0, sizes); z = jax.tree_util.tree_map(jnp.zeros_like, ps)

        def chunk(carry, _):
            st, key = carry

            def body(c, _):
                st, k = c
                k, kb, kd = jax.random.split(k, 3)
                idx = jax.random.randint(kb, (B,), 0, ntr)
                return (step(st, X[idx], y[idx], kd, wd), k), None
            (st, key), _ = jax.lax.scan(body, (st, key), None, length=every)
            return (st, key), jnp.mean(jnp.argmax(forward(st[0], Xev), 1) == yev)
        (st, _), acc = jax.lax.scan(chunk, ((ps, z, z, 0), key), None, length=NCK)
        return acc, jax.nn.softmax(forward(st[0], Xev))

    return train


def run(name, seeds=(0, 1, 2), max_n=None):
    D = DATA.load(name); grid = [n for n in DATA.grid(D) if max_n is None or n <= max_n]; C = D["C"]
    if os.environ.get("MLP_NS"):
        grid = [n for n in grid if n in {int(v) for v in os.environ["MLP_NS"].split(",")}]
    image = name in IMAGES
    dom = {j: np.unique(D["X"][:, j]) for j, t in enumerate(D["types"]) if t == "categorical"}   # feature domain only
    res = dict(learner=TAG, dataset=name, ns=grid, seeds=list(seeds), err=[], err_single=[], flops=[],
               flops_total=[], cpu_seconds=[], chosen_wd=[], wds=list(WDS))
    path = os.path.join(RES, f"{TAG}__{name}.json")
    if os.environ.get("MLP_RESUME") and os.path.exists(path):
        old = json.load(open(path))
        if old["ns"] == grid[:len(old["ns"])]:
            res = old; res["ns"] = grid
    for n in grid[len(res["err"]):]:
        S = n_steps(n); t0 = time.time(); err, err1, cw = [], [], []
        f1 = f2 = None; d0 = None
        big = os.environ.get("MLP_SEED0_FROM") and n >= int(os.environ["MLP_SEED0_FROM"])
        for s in (seeds[:1] if big else seeds):                                                  # one seed at a time (memory at n = 60000)
            pool, te = DATA.splits(D, s); tr = pool[:n]
            nv = max(10, int(round(0.1 * n))); fit_idx, val_idx = tr[nv:], tr[:nv]
            aug, ty = (lambda X: X), list(D["types"])
            if FEATS == "pool":
                aug = pooled(D["X"][tr]); ty = ty + ["continuous"] * (aug(D["X"][:1]).shape[1] - len(ty))
            Xf = encode(aug(D["X"][fit_idx]), ty, aug(D["X"][fit_idx]), dom, image)
            Xv = encode(aug(D["X"][val_idx]), ty, aug(D["X"][fit_idx]), dom, image)
            d = Xf.shape[1]; P = d * W + W + W * W + W + W * C + C
            if f1 is None or d != d0:                                    # compiled once per n (shapes agree across seeds)
                d0 = d
                train = make_net(d, C, S)
                # stage 1 vmaps over (key, wd) with shared data; stage 2 over keys with a shared wd
                f1 = jax.jit(jax.vmap(train, in_axes=(0, None, None, None, 0, None, None)))
                f2 = jax.jit(jax.vmap(train, in_axes=(0, None, None, None, None, None, None)))
            keys = jnp.stack([jax.random.PRNGKey(1000 * s + 10 * j + 1) for j in range(len(WDS))])
            acc, _ = f1(keys, jnp.asarray(Xf), jnp.asarray(D["y"][fit_idx]), len(fit_idx), jnp.asarray(WDS, jnp.float32),
                        jnp.asarray(Xv), jnp.asarray(D["y"][val_idx]))
            sc = np.asarray(acc)[:, -4:].mean(1); j = int(np.argmax(sc)); cw.append(WDS[j])  # ties: smaller wd
            # stage 2: ENS networks on all n with the chosen wd; average their final softmax on the test set
            Xa = encode(aug(D["X"][tr]), ty, aug(D["X"][tr]), dom, image)
            Xt = encode(aug(D["X"][te]), ty, aug(D["X"][tr]), dom, image)
            keys2 = jnp.stack([jax.random.PRNGKey(777 + s + 100 * e) for e in range(ENS)])
            _, prob = f2(keys2, jnp.asarray(Xa), jnp.asarray(D["y"][tr]), n, jnp.float32(WDS[j]), jnp.asarray(Xt),
                         jnp.asarray(D["y"][te]))
            prob = np.asarray(prob); yt = D["y"][te]
            err.append(float(np.mean(prob.mean(0).argmax(1) != yt))); err1.append(float(np.mean(prob[0].argmax(1) != yt)))
        fl = 6.0 * P * B * S
        err += [float("nan")] * (len(seeds) - len(err)); err1 += [float("nan")] * (len(seeds) - len(err1))
        res["err"].append(err); res["err_single"].append(err1); res["flops"].append([fl] * len(seeds))
        res["flops_total"].append([(len(WDS) + ENS) * fl] * len(seeds)); res["chosen_wd"].append(cw)
        res["cpu_seconds"].append([(time.time() - t0) / len(seeds)] * len(seeds))
        print(f"  {name} n={n} S={S} err={np.round(err, 4).tolist()} single={np.round(err1, 4).tolist()} wd={cw} "
              f"({time.time() - t0:.0f}s)", flush=True)
        os.makedirs(RES, exist_ok=True)
        json.dump(res, open(path, "w"))
        single = dict(res, learner=TAG + "1", err=res["err_single"], flops_total=[[(len(WDS) + 1) * fl] * len(seeds)
                                                                                         for _ in res["err"]])
        json.dump(single, open(os.path.join(RES, f"{TAG}1__{name}.json"), "w"))
    return res


if __name__ == "__main__":
    mx = int(os.environ["MLP_MAX_N"]) if os.environ.get("MLP_MAX_N") else None
    for nm in sys.argv[1:]:
        run(nm, max_n=mx)
