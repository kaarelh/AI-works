"""A small CNN on the UNPERMUTED QuickDraw pixels: a context reference for Part 9 (PROTOCOL.md, Amendment 4, C2), not a Q2
reference. It uses the pixel layout, which the MLPs and the discrete learners do not see (the stored columns are permuted
by data.py's fixed permutation, seed 9192, which this script inverts).
Network: 28x28x1 -> conv 3x3, 16, ReLU -> max-pool 2 -> conv 3x3, 32, ReLU -> max-pool 2 -> dense 128, ReLU, dropout 0.1
-> C. Recipe as mlp_strong.py otherwise: pixels in [0, 1], batch 128, S = min(10000, max(2000, 50 epochs)) steps, AdamW
with lr 1e-3 and cosine decay, one network. Decoupled weight decay: fixed at 0.1 by default (CNN_WDS; for compute: a
CNN step costs ~5x an MLP step on this CPU). With more than one value in CNN_WDS, the value is chosen by validation
accuracy (10% of the n points, last 4 of 40 checkpoints) and one network is retrained on all n.
FLOPs (analytic, multiply-adds x 2): forward 2.44e6 per example; one training run 3 x 2.44e6 x 128 x S (with selection,
len(WDS) + 1 runs). Results: results/cnn__<ds>.json.
usage: python cnn_ref.py <qd_dataset> ...   (env CNN_NS: comma list of n; default 1000, 10000, 60000; seed 0 only)"""
import os, sys, time, json, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import jax, jax.numpy as jnp
import data as DATA
from harness import RES

B, NCK, LR, DROP = 128, 40, 1e-3, 0.1
WDS = tuple(float(v) for v in os.environ.get("CNN_WDS", "0.1").split(","))
CH1, CH2, HID = 16, 32, 128
FWD = 2.0 * (28 * 28 * CH1 * 9 + 14 * 14 * CH2 * CH1 * 9 + 7 * 7 * CH2 * HID + HID * 10)


def n_steps(n):
    return int(min(10000, max(2000, math.ceil(50 * n / B))))


def unpermute(X):
    perm = np.random.default_rng(9192).permutation(784)            # data.py: X_stored = X_orig[:, perm]
    return np.asarray(X[:, np.argsort(perm)], np.float32).reshape(-1, 28, 28, 1)


def init(key, C):
    k = jax.random.split(key, 4)
    he = lambda kk, shape, fan: jax.random.normal(kk, shape) * jnp.sqrt(2.0 / fan)
    return [(he(k[0], (3, 3, 1, CH1), 9), jnp.zeros(CH1)), (he(k[1], (3, 3, CH1, CH2), 9 * CH1), jnp.zeros(CH2)),
            (he(k[2], (7 * 7 * CH2, HID), 7 * 7 * CH2), jnp.zeros(HID)), (he(k[3], (HID, C), HID), jnp.zeros(C))]


def forward(ps, x, key=None):
    dn = ("NHWC", "HWIO", "NHWC")
    for w, b in ps[:2]:
        x = jax.nn.relu(jax.lax.conv_general_dilated(x, w, (1, 1), "SAME", dimension_numbers=dn) + b)
        x = jax.lax.reduce_window(x, -jnp.inf, jax.lax.max, (1, 2, 2, 1), (1, 2, 2, 1), "VALID")
    x = jax.nn.relu(x.reshape(x.shape[0], -1) @ ps[2][0] + ps[2][1])
    if key is not None:
        x = jnp.where(jax.random.bernoulli(key, 1 - DROP, x.shape), x / (1 - DROP), 0.0)
    return x @ ps[3][0] + ps[3][1]


def make_net(C, S):
    every = S // NCK

    def loss(ps, x, y, key):
        return -jnp.mean(jnp.take_along_axis(jax.nn.log_softmax(forward(ps, x, key)), y[:, None], 1))

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

    def evaluate(ps, Xev):                                            # in chunks (memory)
        return jnp.concatenate([forward(ps, Xev[i:i + 2000]) for i in range(0, Xev.shape[0], 2000)])

    def train(key, X, y, ntr, wd, Xev, yev):
        k0, key = jax.random.split(key)
        ps = init(k0, C); z = jax.tree_util.tree_map(jnp.zeros_like, ps)

        def chunk(carry, _):
            st, key = carry

            def body(c, _):
                st, k = c
                k, kb, kd = jax.random.split(k, 3)
                idx = jax.random.randint(kb, (B,), 0, ntr)
                return (step(st, X[idx], y[idx], kd, wd), k), None
            (st, key), _ = jax.lax.scan(body, (st, key), None, length=every)
            return (st, key), jnp.mean(jnp.argmax(evaluate(st[0], Xev), 1) == yev)
        (st, _), acc = jax.lax.scan(chunk, ((ps, z, z, 0), key), None, length=NCK)
        return acc, jnp.argmax(evaluate(st[0], Xev), 1)

    return train


def run(name, ns):
    D = DATA.load(name); C = D["C"]; s = 0
    res = dict(learner="cnn", dataset=name, ns=ns, seeds=[0, 1, 2], err=[], flops=[], flops_total=[], cpu_seconds=[],
               chosen_wd=[], wds=list(WDS), note="context reference on unpermuted pixels (uses the layout); seed 0 only")
    path = os.path.join(RES, f"cnn__{name}.json"); KEYS = ("err", "flops", "flops_total", "cpu_seconds", "chosen_wd")
    done = {}
    if os.path.exists(path):                                          # resume (container restarts): reuse finished n
        old = json.load(open(path))
        done = {n: {k: old[k][i] for k in KEYS} for i, n in enumerate(old["ns"][:len(old["err"])])}
    pool, te = DATA.splits(D, s)
    Xt = jnp.asarray(unpermute(D["X"][te])); yt = D["y"][te]
    for n in ns:
        if n in done:
            for k in KEYS:
                res[k].append(done[n][k])
            continue
        S = n_steps(n); t0 = time.time(); tr = pool[:n]
        nv = max(10, int(round(0.1 * n))); fit_idx, val_idx = tr[nv:], tr[:nv]
        train = make_net(C, S)
        j = 0
        if len(WDS) > 1:
            f1 = jax.jit(jax.vmap(train, in_axes=(0, None, None, None, 0, None, None)))
            keys = jnp.stack([jax.random.PRNGKey(1000 * s + 10 * j + 1) for j in range(len(WDS))])
            acc, _ = f1(keys, jnp.asarray(unpermute(D["X"][fit_idx])), jnp.asarray(D["y"][fit_idx]), len(fit_idx),
                        jnp.asarray(WDS, jnp.float32), jnp.asarray(unpermute(D["X"][val_idx])), jnp.asarray(D["y"][val_idx]))
            sc = np.asarray(acc)[:, -4:].mean(1); j = int(np.argmax(sc))
        _, pred = jax.jit(train)(jax.random.PRNGKey(777 + s), jnp.asarray(unpermute(D["X"][tr])), jnp.asarray(D["y"][tr]), n,
                                 jnp.float32(WDS[j]), Xt, jnp.asarray(yt))
        err = float(np.mean(np.asarray(pred) != yt)); fl = 3.0 * FWD * B * S
        res["err"].append([err, float("nan"), float("nan")]); res["flops"].append([fl] * 3)
        res["flops_total"].append([(len(WDS) + 1 if len(WDS) > 1 else 1) * fl] * 3); res["chosen_wd"].append([WDS[j]])
        res["cpu_seconds"].append([time.time() - t0] * 3)
        print(f"  cnn {name} n={n} S={S} err={err:.4f} wd={WDS[j]} ({time.time() - t0:.0f}s)", flush=True)
        json.dump(res, open(path, "w"))
    return res


if __name__ == "__main__":
    ns = [int(v) for v in os.environ.get("CNN_NS", "1000,10000,60000").split(",")]
    for nm in sys.argv[1:]:
        run(nm, ns)
