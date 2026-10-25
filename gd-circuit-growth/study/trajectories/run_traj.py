"""Learning trajectories: what function the network computes at each moment of training.

For a target with relevant variables R (|R| = r <= 9), the probe set is all 2^r patterns of x_R, each with M random
completions of the irrelevant coordinates.  At ~70 log-spaced checkpoints we save the network output on the probe set,
which gives exactly (up to Monte-Carlo over completions) the conditional mean f_R(x_R) = E[f(x) | x_R] -- the part of
the learned function that depends on the relevant variables -- and the variance across completions (dependence on
irrelevant coordinates).  We also save the first-layer weights on R, the norms of the first-layer weights off R, and
the readout, so features can be followed unit by unit.

Same network, initialisation, optimizer and data as study/nn_train.py (muP MLP width 128, Adam lr 1e-3, batch 64, d = 30).
Protocols: 'online' (fresh minibatch every step) and 'fixed' (fixed training sets of the given sizes, nested per seed).

    python run_traj.py <fn> <out_dir> [--ns 512,2048,16384] [--seeds 0,1,2] [--steps 20000] [--online]
"""
import os, sys, json, time, itertools, argparse
import numpy as np
import jax, jax.numpy as jnp
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
import nn_train as T

M = 32


def ckpts(steps_max):
    c = np.unique(np.round(np.logspace(0, np.log10(steps_max), 72)).astype(int))
    return [0] + [int(v) for v in c]


def probe_set(fn):
    R = T.SUITE[fn]["relevant"]; r = len(R)
    pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)), dtype=np.float32)
    rng = np.random.default_rng([T._fn_seed(fn), 4321])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(len(pats), M, T.D))
    X[:, :, R] = pats[:, None, :]
    return R, pats, X.reshape(-1, T.D)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("fn"); ap.add_argument("out")
    ap.add_argument("--ns", default="512,2048,16384"); ap.add_argument("--seeds", default="0,1,2")
    ap.add_argument("--steps", type=int, default=20000); ap.add_argument("--online", action="store_true")
    a = ap.parse_args()
    fn, seeds = a.fn, [int(s) for s in a.seeds.split(",")]
    R, pats, Xp = probe_set(fn); Xp = jnp.array(Xp)
    step = T.make_step("adam", 1e-3)
    CK = ckpts(a.steps)
    t0 = time.time()
    if a.online:
        nets = [("online", s) for s in seeds]
    else:
        ns = [int(v) for v in a.ns.split(",")]
        nets = [(n, s) for n in ns for s in seeds]
        n_max = max(ns)
        data = {s: T.make_data(fn, s, n_max) for s in seeds}
    keys = jnp.array([1000 * s + 7 for _, s in nets])
    p0 = jax.vmap(lambda k: T.init_params(jax.random.PRNGKey(k)))(keys)
    zeros = jax.tree_util.tree_map(jnp.zeros_like, p0)
    state = (p0, zeros, zeros, jnp.zeros(len(nets)))

    if a.online:
        rng = np.random.default_rng([T._fn_seed(fn), 999])

        @jax.jit
        def run(state, Xc, yc):          # Xc [nets, k, B, D]
            def one(st, Xs, ys):
                return jax.lax.fori_loop(0, Xs.shape[0], lambda i, st: step(st, Xs[i], ys[i]), st)
            return jax.vmap(one)(state, Xc, yc)
    else:
        Xall = jnp.array(np.stack([data[s][0] for _, s in nets])); yall = jnp.array(np.stack([data[s][1] for _, s in nets]))
        nn_ = jnp.array([n for n, _ in nets])

        @jax.jit
        def run_fixed(state, keys, n_steps):
            def one(st, key, X, y, n):
                def body(i, st):
                    idx = jax.random.randint(jax.random.fold_in(key, i), (T.B,), 0, n)
                    return step(st, X[idx], y[idx])
                return jax.lax.fori_loop(0, n_steps, body, st)
            return jax.vmap(one, in_axes=(0, 0, 0, 0, 0))(state, keys, Xall, yall, nn_)

    @jax.jit
    def evalp(p):
        return jax.vmap(lambda q: T.forward(q, Xp)[0])(p)

    @jax.jit
    def hidden(p):                       # conditional means of every hidden unit over x_R: [nets, P, N] for both layers
        def one(q):
            _, h1, h2 = T.forward(q, Xp)
            return h1.reshape(len(pats), M, -1).mean(1), h2.reshape(len(pats), M, -1).mean(1)
        return jax.vmap(one)(p)
    HCK = set(CK[::6] + [CK[-1]])

    if not a.online:
        @jax.jit
        def train_loss(p):
            def one(q, X, y, n):
                f = T.forward(q, X)[0]; m = jnp.arange(X.shape[0]) < n
                return jnp.sum(m * 0.5 * (f - y) ** 2) / n
            return jax.vmap(one)(p, Xall, yall, nn_)

    out_f, W1R, W1off, A, B1, TL, H1, H2, HS = [], [], [], [], [], [], [], [], []
    done = 0
    for c in CK:
        if c > done:
            k = c - done
            if a.online:
                Xc = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(len(nets), k, T.B, T.D))
                yc = T.SUITE[fn]["fn"](Xc.reshape(-1, T.D)).reshape(len(nets), k, T.B).astype(np.float32)
                state = run(state, jnp.array(Xc), jnp.array(yc))
            else:
                ks = jax.vmap(lambda i: jax.random.PRNGKey(i))(jnp.arange(len(nets)) + 7919 * c)
                state = run_fixed(state, ks, jnp.int32(k))
            done = c
        p = state[0]
        out_f.append(np.array(evalp(p), dtype=np.float32))
        W1R.append(np.array(p["W1"][:, :, R], dtype=np.float32))
        off = [i for i in range(T.D) if i not in R]
        W1off.append(np.array(jnp.linalg.norm(p["W1"][:, :, off], axis=-1), dtype=np.float32))
        A.append(np.array(p["a"], dtype=np.float32)); B1.append(np.array(p["b1"], dtype=np.float32))
        if not a.online:
            TL.append(np.array(train_loss(p)))
        if c in HCK:
            h1, h2 = hidden(p); H1.append(np.array(h1, dtype=np.float16)); H2.append(np.array(h2, dtype=np.float16)); HS.append(c)
    fR = np.stack(out_f).reshape(len(CK), len(nets), len(pats), M)
    os.makedirs(a.out, exist_ok=True)
    tag = "online" if a.online else "fixed"
    np.savez_compressed(os.path.join(a.out, f"traj_{tag}_{fn}.npz"), steps=np.array(CK), nets=np.array([str(n) for n, _ in nets]),
                        seeds=np.array([s for _, s in nets]), R=np.array(R), pats=pats,
                        f_mean=fR.mean(-1), f_var=fR.var(-1), W1R=np.stack(W1R), W1off=np.stack(W1off), a=np.stack(A),
                        b1=np.stack(B1), train_loss=np.array(TL) if TL else np.zeros(0),
                        h_steps=np.array(HS), H1=np.stack(H1), H2=np.stack(H2))
    print(f"{fn} {tag} done in {time.time() - t0:.0f}s", flush=True)


if __name__ == "__main__":
    main()
