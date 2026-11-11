"""Audit probe: the mlp_strong single network (seed 0, key 777, wd 1.0, [0,1]-scaled inputs) on qd_dev n=10000, inputs
[x, x @ A9] with A9 = p9_gates' scale-9 pooling sets built from the training rows (p9_gates.learner.pool_sets, unchanged)."""
import sys, time, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/standard_tasks")
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/part9/p9_gates"); sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/hybrid")
import jax, jax.numpy as jnp
import data as DATA, mlp_strong as MS
import importlib.util
spec = importlib.util.spec_from_file_location("g", "/home/user/AI-works/gd-circuit-growth/study/part9/p9_gates/learner.py"); G = importlib.util.module_from_spec(spec); spec.loader.exec_module(G)
n = 10000; D = DATA.load("qd_dev"); s = 0
pool, te = DATA.splits(D, s); tr = pool[:n]
t0 = time.process_time()
As, fl = G.pool_sets(D["X"][tr], [9]); A = As[9]
f = lambda Q: np.concatenate([Q, Q @ A], 1)
Ftr, Fte = f(D["X"][tr]), f(D["X"][te]); m = np.abs(Ftr).max(0); m[m < 1e-12] = 1.0
Ftr, Fte = (Ftr / m).astype(np.float32), (Fte / m).astype(np.float32)
S = MS.n_steps(n); train = jax.jit(MS.make_net(Ftr.shape[1], 10, S))
acc, prob = train(jax.random.PRNGKey(777 + s), jnp.asarray(Ftr), jnp.asarray(D["y"][tr]), n, jnp.float32(1.0), jnp.asarray(Fte), jnp.asarray(D["y"][te]))
err = float(np.mean(np.asarray(prob).argmax(1) != D["y"][te]))
print(f"MLP on [x, pooled9(x)] (d={Ftr.shape[1]}) n={n} wd=1.0 unit-scaled: test err {err:.4f}; cpu {time.process_time()-t0:.0f}s", flush=True)
