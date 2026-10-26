"""Rich-regime (muP) MLP training on Boolean targets, in JAX on CPU.

Network: f(x) = a . relu(W2 relu(W1 x + b1) + b2), widths N, N; square loss on +-1 labels.
muP initialisation (Tensor Programs V, Table 3): W1 ~ N(0, 1/d), W2 ~ N(0, 1/N),
a ~ N(0, 1/N^2) (small readout), biases zero.  Per-layer learning-rate multipliers
relative to a base width of 64:
    Adam: W1, b1: 1;   W2, b2, a: 64/N
    SGD : W1, b1: N/64; W2, b2: 1;  a: 64/N

Protocols
  fixed : a fixed training set of size n (nested across n for each seed), minibatch
          size 64 sampled with replacement, many epochs; train/test curves over time.
  online: a fresh minibatch of 64 every step (one pass), test error vs samples seen.

Many networks (all n x seeds) are trained in parallel with vmap.  Results go to
<out>/<protocol>_<opt>_<fn>.npz.
"""
import os, sys, json, time, itertools, argparse
import numpy as np
import jax, jax.numpy as jnp
from boolfuncs import make_suite, make_random_suite, make_poly_suite, make_dl_heldout_suite, make_dl_heldout2_suite, make_dl_heldout3_suite

D, N, B, N_TEST, BASE = int(os.environ.get("DIM", 30)), int(os.environ.get("WIDTH", 128)), 64, 4096, 64
SUITE = {"random": make_random_suite, "poly": make_poly_suite, "dlheld": make_dl_heldout_suite, "dlheld2": make_dl_heldout2_suite, "dlheld3": make_dl_heldout3_suite}.get(os.environ.get("SUITE"), make_suite)(D)

# ---------------------------------------------------------------- data

def _fn_seed(name):
    return int.from_bytes(name.encode(), "little") % (2 ** 31)

def make_data(name, seed, n_max):
    rng = np.random.default_rng([_fn_seed(name), seed])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(n_max, D))
    return X, SUITE[name]["fn"](X).astype(np.float32)

def make_test(name):
    rng = np.random.default_rng([_fn_seed(name), 10 ** 6])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(N_TEST, D))
    return X, SUITE[name]["fn"](X).astype(np.float32)

def char_sets(rel, kmax=4):
    sets = [()]
    for k in range(1, min(kmax, len(rel)) + 1):
        sets += list(itertools.combinations(rel, k))
    return sets

def char_matrix(X, sets):
    C = np.ones((len(X), len(sets)), dtype=np.float32)
    for j, S in enumerate(sets):
        for i in S:
            C[:, j] *= X[:, i]
    return C

# ---------------------------------------------------------------- model

def init_params(key):
    k1, k2, k3 = jax.random.split(key, 3)
    return dict(W1=jax.random.normal(k1, (N, D)) / np.sqrt(D), b1=jnp.zeros(N),
                W2=jax.random.normal(k2, (N, N)) / np.sqrt(N), b2=jnp.zeros(N),
                a=jax.random.normal(k3, (N,)) / N)

def forward(p, x):
    h1 = jax.nn.relu(x @ p["W1"].T + p["b1"])
    h2 = jax.nn.relu(h1 @ p["W2"].T + p["b2"])
    return h2 @ p["a"], h1, h2

def loss_fn(p, x, y):
    return 0.5 * jnp.mean((forward(p, x)[0] - y) ** 2)

MULT = {"adam": dict(W1=1.0, b1=1.0, W2=BASE / N, b2=BASE / N, a=BASE / N),
        "sgd": dict(W1=N / BASE, b1=N / BASE, W2=1.0, b2=1.0, a=BASE / N)}

def make_step(opt, lr):
    mult = MULT[opt]
    def step(state, x, y):
        p, m, v, t = state
        g = jax.grad(loss_fn)(p, x, y)
        if opt == "sgd":
            p = {k: p[k] - lr * mult[k] * g[k] for k in p}
            return (p, m, v, t + 1)
        t = t + 1
        m = {k: 0.9 * m[k] + 0.1 * g[k] for k in p}
        v = {k: 0.999 * v[k] + 0.001 * g[k] ** 2 for k in p}
        c1, c2 = 1 - 0.9 ** t, 1 - 0.999 ** t
        p = {k: p[k] - lr * mult[k] * (m[k] / c1) / (jnp.sqrt(v[k] / c2) + 1e-8) for k in p}
        return (p, m, v, t)
    return step

# ---------------------------------------------------------------- diagnostics

def participation_ratio(h):
    hc = h - h.mean(0)
    ev = jnp.clip(jnp.linalg.eigvalsh(hc.T @ hc / h.shape[0]), 0, None)
    return ev.sum() ** 2 / jnp.maximum((ev ** 2).sum(), 1e-30)

def make_eval(Xte, yte, chi, Xflip):
    """Xflip: (k, m, D) test points with one irrelevant coordinate flipped each."""
    m = Xflip.shape[1]
    def ev(p, p0):
        fte, h1, h2 = forward(p, Xte)
        coef = fte @ chi / Xte.shape[0]
        fbase = fte[:m]
        infl = jax.vmap(lambda Xf: jnp.mean((forward(p, Xf)[0] - fbase) ** 2) / 4)(Xflip)
        norms = dict(W1=jnp.linalg.norm(p["W1"]), W2=jnp.linalg.norm(p["W2"]), a=jnp.linalg.norm(p["a"]),
                     dW1=jnp.linalg.norm(p["W1"] - p0["W1"]), dW2=jnp.linalg.norm(p["W2"] - p0["W2"]),
                     da=jnp.linalg.norm(p["a"] - p0["a"]),
                     # l1 path norm of the whole network: sum over paths |a_k W2_kj W1_ji|, plus bias paths
                     path1=jnp.abs(p["a"]) @ jnp.abs(p["W2"]) @ (jnp.abs(p["W1"]).sum(1) + jnp.abs(p["b1"]))
                           + jnp.abs(p["a"]) @ jnp.abs(p["b2"]))
        return dict(test_loss=0.5 * jnp.mean((fte - yte) ** 2), test_err=jnp.mean(jnp.sign(fte) != yte),
                    coef=coef, infl_irr=infl.mean(), pr1=participation_ratio(h1[:1024]),
                    pr2=participation_ratio(h2[:1024]), pred=jnp.sign(fte).astype(jnp.int8),
                    out=fte.astype(jnp.float16), **norms)
    return ev

# ---------------------------------------------------------------- protocols

CKPTS = [0, 10, 20, 50, 100, 200, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000, 30000, 40000]

def run_fixed(name, opt, lr, ns, seeds, steps_max, out_dir, save_params=True):
    t0 = time.time()
    ns = np.array(ns); S = len(seeds); n_max = int(ns.max())
    data = [make_data(name, s, n_max) for s in seeds]
    Xall = jnp.array(np.stack([d[0] for d in data])); yall = jnp.array(np.stack([d[1] for d in data]))
    Xte, yte = make_test(name)
    rel = SUITE[name]["relevant"]; sets = char_sets(rel)
    chi = jnp.array(char_matrix(Xte, sets))
    irr = [i for i in range(D) if i not in rel][:5] or [D - 1]   # no irrelevant input: the metric is then not meaningful
    Xflip = jnp.array(np.stack([Xte[:1024] * np.where(np.arange(D) == i, -1.0, 1.0).astype(np.float32) for i in irr]))
    # one network per (n, seed)
    net_n = jnp.array(np.repeat(ns, S)); net_s = jnp.array(np.tile(np.arange(S), len(ns)))
    keys = jax.vmap(lambda i: jax.random.PRNGKey(i))(jnp.array([1000 * seeds[s] + 7 for s in np.tile(np.arange(S), len(ns))]))
    p0 = jax.vmap(init_params)(keys)  # same init for a given seed across n
    zeros = jax.tree_util.tree_map(jnp.zeros_like, p0)
    state = (p0, zeros, zeros, jnp.zeros(len(net_n)))
    step = make_step(opt, lr)

    def one_net_chunk(st, key, n, s, n_steps):
        def body(i, st):
            idx = jax.random.randint(jax.random.fold_in(key, i), (B,), 0, n)
            return step(st, Xall[s][idx], yall[s][idx])
        return jax.lax.fori_loop(0, n_steps, body, st)

    @jax.jit
    def chunk(state, keys, n_steps):
        return jax.vmap(lambda st, k, n, s: one_net_chunk(st, k, n, s, n_steps),
                        in_axes=((0, 0, 0, 0), 0, 0, 0))(state, keys, net_n, net_s)

    ev = make_eval(Xte, yte, chi, Xflip)
    eval_all = jax.jit(jax.vmap(ev))

    @jax.jit
    def train_metrics(p):
        def one(p, n, s):
            f = forward(p, Xall[s])[0]
            mask = jnp.arange(n_max) < n
            l = jnp.sum(mask * 0.5 * (f - yall[s]) ** 2) / n
            e = jnp.sum(mask * (jnp.sign(f) != yall[s])) / n
            return l, e
        return jax.vmap(one)(p, net_n, net_s)

    rec = {k: [] for k in ["step", "train_loss", "train_err", "test_loss", "test_err", "coef", "infl_irr",
                           "pr1", "pr2", "W1", "W2", "a", "dW1", "dW2", "da", "path1", "pred"]}
    ck = [c for c in CKPTS if c <= steps_max]
    done = 0
    for c in ck:
        if c > done:
            n_steps = c - done
            ks = jax.vmap(lambda i: jax.random.PRNGKey(i))(jnp.arange(len(net_n)) + 1009 * c)
            state = chunk(state, ks, jnp.int32(n_steps))
            done = c
        m = eval_all(state[0], p0)
        trl, tre = train_metrics(state[0])
        rec["step"].append(c); rec["train_loss"].append(np.array(trl)); rec["train_err"].append(np.array(tre))
        for k in rec:
            if k in m:
                rec[k].append(np.array(m[k]))
        print(f"  [{name}/{opt}] step {c:6d}  test_err(mean over nets) {float(np.mean(m['test_err'])):.3f}"
              f"  train_err {float(np.mean(tre)):.3f}  ({time.time()-t0:.0f}s)", flush=True)
    os.makedirs(out_dir, exist_ok=True)
    arrays = {k: np.array(v) for k, v in rec.items()}
    arrays["out_final"] = np.array(m["out"])
    arrays.update(ns=ns, seeds=np.array(seeds), net_n=np.array(net_n), net_s=np.array(net_s),
                  sets=np.array(json.dumps(sets)), lr=lr)
    np.savez_compressed(os.path.join(out_dir, f"fixed_{opt}_{name}.npz"), **arrays)
    if save_params:
        np.savez_compressed(os.path.join(out_dir, f"params_fixed_{opt}_{name}.npz"),
                            **{k: np.array(v, dtype=np.float16) for k, v in state[0].items()})
    return arrays

def run_online(name, opt, lr, seeds, steps_max, out_dir, chunk_steps=500):
    t0 = time.time()
    S = len(seeds); Xte, yte = make_test(name)
    rel = SUITE[name]["relevant"]; sets = char_sets(rel); chi = jnp.array(char_matrix(Xte, sets))
    irr = [i for i in range(D) if i not in rel][:5] or [D - 1]   # no irrelevant input: the metric is then not meaningful
    Xflip = jnp.array(np.stack([Xte[:1024] * np.where(np.arange(D) == i, -1.0, 1.0).astype(np.float32) for i in irr]))
    keys = jax.vmap(lambda i: jax.random.PRNGKey(i))(jnp.array([1000 * s + 7 for s in seeds]))
    p0 = jax.vmap(init_params)(keys); zeros = jax.tree_util.tree_map(jnp.zeros_like, p0)
    state = (p0, zeros, zeros, jnp.zeros(S)); step = make_step(opt, lr)

    @jax.jit
    def run_chunk(state, Xc, yc):  # Xc: (S, steps, B, D)
        # also returns the prequential mistakes: errors on each fresh batch made BEFORE the update on it
        def one(st, Xs, ys):
            def body(i, carry):
                st, mis = carry
                f = forward(st[0], Xs[i])[0]
                return step(st, Xs[i], ys[i]), mis + jnp.sum(jnp.sign(f) != ys[i])
            return jax.lax.fori_loop(0, Xs.shape[0], body, (st, jnp.float32(0)))
        return jax.vmap(one)(state, Xc, yc)

    eval_all = jax.jit(jax.vmap(make_eval(Xte, yte, chi, Xflip)))
    rng = np.random.default_rng([_fn_seed(name), 777])
    rec = {k: [] for k in ["step", "test_loss", "test_err", "coef", "infl_irr", "pr1", "pr2", "dW1", "path1"]}
    preq, preq_steps = [], []   # prequential mistakes per chunk (per seed) and the step at the end of each chunk
    grid = sorted(set([0] + [c for c in CKPTS if c <= steps_max] + list(range(chunk_steps, steps_max + 1, chunk_steps))))
    done = 0
    for c in grid:
        while done < c:
            k = min(chunk_steps, c - done)
            Xc = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(S, k, B, D))
            yc = SUITE[name]["fn"](Xc.reshape(-1, D)).reshape(S, k, B).astype(np.float32)
            state, mis = run_chunk(state, jnp.array(Xc), jnp.array(yc)); done += k
            preq.append(np.array(mis)); preq_steps.append(done)
        m = eval_all(state[0], p0)
        rec["step"].append(c)
        for kk in rec:
            if kk in m:
                rec[kk].append(np.array(m[kk]))
        if c in CKPTS or c == grid[-1]:
            print(f"  [online {name}/{opt}] step {c:6d} test_err {np.round(np.array(m['test_err']), 3)} ({time.time()-t0:.0f}s)", flush=True)
    os.makedirs(out_dir, exist_ok=True)
    arrays = {k: np.array(v) for k, v in rec.items()}
    arrays.update(seeds=np.array(seeds), sets=np.array(json.dumps(sets)), lr=lr, batch=B,
                  preq_mistakes=np.array(preq), preq_steps=np.array(preq_steps))
    np.savez_compressed(os.path.join(out_dir, f"online_{opt}_{name}.npz"), **arrays)
    return arrays

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--protocol", default="fixed"); ap.add_argument("--opt", default="adam")
    ap.add_argument("--lr", type=float, default=1e-3); ap.add_argument("--fns", default="all")
    ap.add_argument("--ns", default="16,32,64,128,256,512,1024,2048,4096,8192,16384")
    ap.add_argument("--seeds", default="0,1,2"); ap.add_argument("--steps", type=int, default=20000)
    ap.add_argument("--out", default="results")
    a = ap.parse_args()
    fns = list(SUITE) if a.fns == "all" else a.fns.split(",")
    seeds = [int(s) for s in a.seeds.split(",")]
    for fn in fns:
        if a.protocol == "fixed":
            run_fixed(fn, a.opt, a.lr, [int(n) for n in a.ns.split(",")], seeds, a.steps, a.out)
        else:
            run_online(fn, a.opt, a.lr, seeds, a.steps, a.out)
