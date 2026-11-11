"""Audit probe (fairness): mlp_strong's single network on qd_dev seed 0, quantile vs [0,1] pixel encoding.
Uses mlp_strong.make_net / encode unchanged; no writes outside this directory."""
import sys, time, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/standard_tasks")
import jax, jax.numpy as jnp
import data as DATA, mlp_strong as MS
n = int(sys.argv[1]); cfgs = [(a.split(":")[0], float(a.split(":")[1])) for a in sys.argv[2:]]
D = DATA.load("qd_dev"); s = 0
pool, te = DATA.splits(D, s); tr = pool[:n]
S = MS.n_steps(n); train = MS.make_net(784, 10, S)
f = jax.jit(train)
for enc, wd in cfgs:
    t0 = time.process_time(); w0 = time.time()
    image = enc == "unit"
    Xa = MS.encode(D["X"][tr], D["types"], D["X"][tr], {}, image); Xt = MS.encode(D["X"][te], D["types"], D["X"][tr], {}, image)
    acc, prob = f(jax.random.PRNGKey(777 + s), jnp.asarray(Xa), jnp.asarray(D["y"][tr]), n, jnp.float32(wd), jnp.asarray(Xt), jnp.asarray(D["y"][te]))
    err = float(np.mean(np.asarray(prob).argmax(1) != D["y"][te]))
    print(f"n={n} S={S} enc={enc} wd={wd}: test err {err:.4f}  (acc curve last4 {np.round(1-np.asarray(acc)[-4:],4).tolist()})  cpu {time.process_time()-t0:.0f}s wall {time.time()-w0:.0f}s", flush=True)
