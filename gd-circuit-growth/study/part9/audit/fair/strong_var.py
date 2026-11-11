"""Audit probe: mlp_strong single network (seed 0, key 777) on qd_dev with width / step-count / wd variations.
usage: strong_var.py n W step_mult enc wd"""
import sys, time, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/standard_tasks")
import jax, jax.numpy as jnp
import data as DATA, mlp_strong as MS
n, W, mult, enc, wd = int(sys.argv[1]), int(sys.argv[2]), float(sys.argv[3]), sys.argv[4], float(sys.argv[5])
MS.W = W
D = DATA.load("qd_dev"); s = 0
pool, te = DATA.splits(D, s); tr = pool[:n]
S = int(MS.n_steps(n) * mult); S -= S % MS.NCK
train = jax.jit(MS.make_net(784, 10, S))
t0 = time.process_time()
image = enc == "unit"
Xa = MS.encode(D["X"][tr], D["types"], D["X"][tr], {}, image); Xt = MS.encode(D["X"][te], D["types"], D["X"][tr], {}, image)
acc, prob = train(jax.random.PRNGKey(777 + s), jnp.asarray(Xa), jnp.asarray(D["y"][tr]), n, jnp.float32(wd), jnp.asarray(Xt), jnp.asarray(D["y"][te]))
err = float(np.mean(np.asarray(prob).argmax(1) != D["y"][te]))
P = 784 * W + W + W * W + W + W * 10 + 10
print(f"n={n} W={W} S={S} ({S*128/n:.0f} epochs) enc={enc} wd={wd}: test err {err:.4f}; FLOPs {6*P*128*S:.3g} = {6*P*128*S/(3*6*(784*256+256+256*256+256+2570)*128*MS.n_steps(n)):.2f} x 3-run budget; cpu {time.process_time()-t0:.0f}s", flush=True)
