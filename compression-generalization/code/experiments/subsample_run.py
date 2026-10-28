"""Can a short surrogate of a trained Boolean network be found cheaply?

Trains one network f on a Boolean task (uniform inputs on {-1,1}^n, so the
disagreement term of Theorem 2 is free), then compares search procedures for
a short network g close to f:

  sub_refit      keep k hidden units (Maurey sampling, top-k or uniform),
                 quantize them, refit the next layer by least squares
  sub_refit_init same, coding the kept units relative to their (free)
                 initialization rows (+ the index set)
  update_refit   subsample the update f - f_0 relative to the initialization
                 (g = f_0 + sum_j beta_j delta_j; f_0 is free)
  sub_distill    sub_refit followed by distillation through the quantizer
  scratch        a width-k student distilled from scratch
  codec          the influence-guided codec of the main paper (boolean.compress)

Each family's best candidate is chosen on a selection pool and certified on
2x10^5 fresh inputs drawn with OS entropy afterwards (Theorem 2 with the design
charge of accounting.py).  Also records, for Maurey sampling without refit,
the measured disagreement against the Maurey prediction.

Usage: python subsample_run.py --task teacher4 --param std --width 512 --depth 1 --out ...
"""
import argparse
import copy
import json
import math
import os
import secrets
import sys
import time

import numpy as np
import torch
import torch.nn.functional as F

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from accounting import boolean_bound, DESIGN_BITS  # noqa: E402
from cgb import coding  # noqa: E402
from cgb.bounds import occam_bound, cp_upper  # noqa: E402
from cgb.boolean import compress  # noqa: E402
from cgb.codec import QuantMLP, distill  # noqa: E402
from cgb.data import make_target, uniform_cube  # noqa: E402
from cgb.models import MLP, train, np_forward  # noqa: E402
from cgb import subsample as ss  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--task", required=True)
ap.add_argument("--n", type=int, default=50)
ap.add_argument("--m", type=int, default=16000)
ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--param", default="std", choices=["std", "mf", "lazy"])
ap.add_argument("--width", type=int, default=512)
ap.add_argument("--depth", type=int, default=1)
ap.add_argument("--mf_lr", type=float, default=0.2)
ap.add_argument("--max_steps", type=int, default=40000)
ap.add_argument("--ks", default="2,4,8,16,32,64")
ap.add_argument("--draws", type=int, default=3)
ap.add_argument("--rels", default="1,0.5,0.25")
ap.add_argument("--distill_steps", type=int, default=2000)
ap.add_argument("--qat_steps", type=int, default=400)
ap.add_argument("--skip_codec", action="store_true")
ap.add_argument("--families", default="maurey_raw,sub_refit,update_refit,sub_distill,scratch,codec",
                help="comma list; 'greedy' adds greedy (OMP) unit selection + refit / + distillation")
ap.add_argument("--load_saved", action="store_true", help="reuse the saved f (same seed and data) instead of training")
ap.add_argument("--delta", type=float, default=0.05)
ap.add_argument("--out", required=True)
args = ap.parse_args()
torch.set_num_threads(1)
T0 = time.time()
n, m, N = args.n, args.m, args.width
ks = [int(k) for k in args.ks.split(",")]
rels = [float(r) for r in args.rels.split(",")]
delta = args.delta

# ----------------------------------------------------------------------------- data and f
target = make_target(args.task, n, seed=0)
rng = np.random.default_rng(12345 + 1000 * args.seed + m)
Xtr = uniform_cube(n, m, rng)
ytr = target(Xtr)


def train_mf(seed, eta, max_steps, batch=64):
    """Mean-field one-hidden-layer net f(x) = (1/N) sum_i a_i relu(w_i.x + b_i) + c,
    w_i ~ N(0, I/n), a_i ~ N(0, 1); SGD with learning rate eta*N on (W, b, a)."""
    g = torch.Generator().manual_seed(seed)
    W = (torch.randn(N, n, generator=g) / math.sqrt(n)).requires_grad_()
    b = torch.zeros(N, requires_grad=True)
    a = torch.randn(N, generator=g).requires_grad_()
    c = torch.zeros(1, requires_grad=True)
    init = [(W.detach().double().numpy().copy(), b.detach().double().numpy().copy()),
            ((a.detach().double().numpy() / N)[None, :].copy(), c.detach().double().numpy().copy())]
    opt = torch.optim.SGD([{"params": [W, b, a], "lr": eta * N}, {"params": [c], "lr": eta}])
    Xt, yt = torch.as_tensor(Xtr, dtype=torch.float32), torch.as_tensor(ytr).float()
    fwd = lambda x: (F.relu(x @ W.T + b) @ a) / N + c
    gperm = torch.Generator().manual_seed(seed + 7)
    steps = 0
    while steps < max_steps:
        perm = torch.randperm(m, generator=gperm)
        for s in range(0, m, batch):
            idx = perm[s:s + batch]
            loss = F.binary_cross_entropy_with_logits(fwd(Xt[idx]), yt[idx])
            opt.zero_grad()
            loss.backward()
            opt.step()
            steps += 1
        with torch.no_grad():
            out = fwd(Xt)
            err = float(((out > 0).float() != yt).float().mean())
            L = float(F.binary_cross_entropy_with_logits(out, yt))
        if err == 0.0 and L <= 0.01:
            break
    w = [(W.detach().double().numpy(), b.detach().double().numpy()),
         ((a.detach().double().numpy() / N)[None, :], c.detach().double().numpy())]
    return w, init, {"steps": steps, "train_err": err, "train_loss": L}


fams = set(args.families.split(","))
want = lambda name: name in fams
save_dir = os.environ.get("CGB_NETS", os.path.expanduser("~/.cache/cgb_nets"))
os.makedirs(save_dir, exist_ok=True)
net_path = os.path.join(save_dir, f"{args.task}_{args.param}_{N}_d{args.depth}_s{args.seed}_m{m}.npz")
t_train = time.time()
widths = [n] + [N] * args.depth + [1]
if args.load_saved and os.path.exists(net_path):
    z = np.load(net_path)
    arrs = [z[f"arr_{i}"] for i in range(len(z.files))]
    L2 = len(arrs) // 2
    Fw = [(arrs[2 * i], arrs[2 * i + 1]) for i in range(L2 // 2)]
    Iw = [(arrs[L2 + 2 * i], arrs[L2 + 2 * i + 1]) for i in range(L2 // 2)]
    tr = {"loaded": os.path.basename(net_path)}
elif args.param == "mf":
    assert args.depth == 1
    Fw, Iw, tr = train_mf(args.seed, args.mf_lr, args.max_steps)
else:
    scale, opt, lr = (1.0, "adam", 1e-3) if args.param == "std" else (2.0, "sgd", 0.02)
    fnet = MLP(widths, init_scale=scale, seed=args.seed)
    Iw = fnet.weights()
    tr = train(fnet, Xtr.astype(np.float32), ytr, epochs=100000, lr=lr, batch=64, opt=opt, seed=args.seed,
               stop_train_err=0.0, stop_loss=0.01, max_steps=args.max_steps)
    Fw = fnet.weights()
t_train = time.time() - t_train
if "loaded" not in tr:
    np.savez(net_path, *[x for wb in Fw for x in wb], *[x for wb in Iw for x in wb])
f_logits = lambda X: np_forward(Fw, X)[:, 0]
f_predict = lambda X: (f_logits(X) > 0).astype(np.int64)
params = sum(W.size + b.size for W, b in Fw)
Xt = uniform_cube(n, 300_000, np.random.default_rng(999 + args.seed))
test_err_f = float(np.mean(f_predict(Xt) != target(Xt)))
k_tr_f = int(np.sum(f_predict(Xtr) != ytr))
rel_move = float(np.sqrt(sum(((W - W0) ** 2).sum() + ((b - b0) ** 2).sum() for (W, b), (W0, b0) in zip(Fw, Iw))
                         / sum((W0 ** 2).sum() + (b0 ** 2).sum() for W0, b0 in Iw)))
print(f"f: {args.task} {args.param} N={N} depth={args.depth} test err {test_err_f:.4f} train {tr} move {rel_move:.2f} "
      f"({t_train:.0f}s)", flush=True)

# ----------------------------------------------------------------------------- pools
rp = np.random.default_rng(777 + 1000 * args.seed + m)
Xfit = uniform_cube(n, 10_000, rp)            # importance scores and least-squares refits
Xdis = uniform_cube(n, 100_000, rp)           # distillation pool
Xsel = uniform_cube(n, 30_000, rp)            # selection among candidates
zfit, zdis, zsel = f_logits(Xfit), f_logits(Xdis), f_logits(Xsel)
ysel, ydis = (zsel > 0).astype(np.int64), (zdis > 0).astype(np.int64)
pdis = 1.0 / (1.0 + np.exp(-np.clip(zdis, -50, 50)))   # soft targets for distillation


class Code:
    """A candidate g: predict(X) and a description length in bits."""

    def __init__(self, logits_fn, desc):
        self.logits_fn, self.desc = logits_fn, desc

    def predict(self, X):
        return (self.logits_fn(X) > 0).astype(np.int64)

    @property
    def bits(self):
        return self.desc.bits

    def description(self):
        return self.desc


def quant_code(weights, coords, exps, ref=None, extra=None):
    """QuantMLP for a float weight list at the given step exponents (+extra items)."""
    q = []
    for li, ((W, b), (eW, eb)) in enumerate(zip(weights, exps)):
        if ref is not None:
            W, b = W - ref[li][0], b - ref[li][1]
        q.append((np.round(W / QuantMLP.step_value(eW)).astype(np.int64),
                  np.round(b / QuantMLP.step_value(eb)).astype(np.int64)))
    qm = QuantMLP(n, coords, q, exps, ref=ref, seed_bits=32.0 if ref is not None else 0.0)
    d = qm.description()
    d.add("search family", 3.0)            # which of up to 8 search families produced g
    for name, bits in (extra or {}).items():
        d.add(name, bits)
    return Code(lambda X: qm.logits(X)[:, 0], d), qm.weights()


def step_exp(x, rel):
    rms = float(np.sqrt(np.mean(np.asarray(x) ** 2))) + 1e-12
    return int(round(4 * math.log2(rel * rms)))


def exps_for(weights, rel):
    return [(step_exp(W, rel), step_exp(np.concatenate([b.ravel(), W.ravel()]) if b.size < 4 else b, rel))
            for W, b in weights]


cands = []
timing = {}


def consider(family, g, label, **extra):
    k_err = int(np.sum(g.predict(Xtr) != ytr))
    occ = occam_bound(k_err, m, g.bits + DESIGN_BITS, delta / 2)
    dis = float(np.mean(g.predict(Xsel) != ysel))
    c = {"family": family, "label": label, "bits": g.bits, "train_err_g": k_err, "occ": occ, "sel_dis": dis,
         "est": occ + dis, **extra}
    cands.append((c, g))
    return c


def quantize_refit_chain(Wlist, rel, ref_first=None, coords=None):
    """Quantize layer by layer and refit each following layer by least squares to
    f's corresponding quantities on Xfit.  Wlist: float weights of the small net,
    plus targets: for the last layer, f's logits; for a middle layer (depth 2), the
    kept units' pre-activations (passed as Wlist[i] = (W, b, Ztarget))."""
    Xf = Xfit if coords is None else Xfit[:, coords]
    out, exps = [], []
    H = Xf.astype(np.float64)
    for li, layer in enumerate(Wlist):
        W, b = layer[0], layer[1]
        last = li == len(Wlist) - 1
        if li > 0:   # refit this layer on the quantized features of the previous one
            T = zfit[:, None] if last else layer[2]
            W, b = ss.refit_linear(H, T)
        if li == 0 and ref_first is not None:   # steps from the update relative to the reference
            e = (step_exp(W - ref_first[0], rel), step_exp(b - ref_first[1], rel))
        else:
            e = (step_exp(W, rel), step_exp(b if b.size >= 4 else np.concatenate([b, W.ravel()]), rel))
        if li == 0 and ref_first is not None:
            R0, r0 = ref_first
            Wq = R0 + np.round((W - R0) / QuantMLP.step_value(e[0])) * QuantMLP.step_value(e[0])
            bq = r0 + np.round((b - r0) / QuantMLP.step_value(e[1])) * QuantMLP.step_value(e[1])
        else:
            Wq = np.round(W / QuantMLP.step_value(e[0])) * QuantMLP.step_value(e[0])
            bq = np.round(b / QuantMLP.step_value(e[1])) * QuantMLP.step_value(e[1])
        out.append((Wq, bq))
        exps.append(e)
        if not last:
            H = np.maximum(H @ Wq.T + bq, 0.0)
    return out, exps


def float_dis(weights, coords=None):
    Xs = Xsel if coords is None else Xsel[:, coords]
    return float(np.mean((np_forward(weights, Xs)[:, 0] > 0).astype(np.int64) != ysel))


def to_mlp(weights):
    net = MLP([weights[0][0].shape[1]] + [W.shape[0] for W, _ in weights], seed=0)
    with torch.no_grad():
        for lin, (W, b) in zip(net.layers, weights):
            lin.weight.copy_(torch.as_tensor(W, dtype=torch.float32))
            lin.bias.copy_(torch.as_tensor(b, dtype=torch.float32))
    return net


def distill_and_quantize(family, net, label, float_steps, lr, seed, ref=None, extra=None, **meta):
    """Distill net (in place) toward f on Xdis, then for each rel do QAT and consider."""
    if float_steps:
        distill(net, Xdis.astype(np.float32), pdis, steps=float_steps, lr=lr, seed=seed, soft=True)
    fd = float_dis(net.weights())
    for rel in rels:
        s2 = copy.deepcopy(net)
        w = s2.weights()
        exps = exps_for(w if ref is None else [(W - R, b - r) for (W, b), (R, r) in zip(w, ref)], rel)
        distill(s2, Xdis.astype(np.float32), pdis, steps=args.qat_steps, lr=1e-3, seed=seed + 1000,
                qat_steps_exp=exps, qat_ref=ref, soft=True)
        g, _ = quant_code(s2.weights(), np.arange(n), exps, ref=ref, extra=extra)
        consider(family, g, f"{label} rel={rel}", rel=rel, float_dis=fd, **meta)


def distill_and_quantize_pool(family, net, label, Xp, yp, float_steps, lr, seed, **meta):
    """As distill_and_quantize, on a given pool with soft targets yp."""
    Xp32 = Xp.astype(np.float32)
    if float_steps:
        distill(net, Xp32, yp, steps=float_steps, lr=lr, seed=seed, soft=True)
    fd = float_dis(net.weights())
    for rel in rels:
        s2 = copy.deepcopy(net)
        exps = exps_for(s2.weights(), rel)
        distill(s2, Xp32, yp, steps=args.qat_steps, lr=1e-3, seed=seed + 1000, qat_steps_exp=exps, soft=True)
        g, _ = quant_code(s2.weights(), np.arange(n), exps)
        consider(family, g, f"{label} rel={rel}", rel=rel, float_dis=fd, **meta)


# ----------------------------------------------------------------------------- path norm, margins
info = {}
if args.depth == 1:
    (W1, b1), (V, c) = Fw
    Phi = ss.relu_features(W1, b1, Xfit)
    imp = ss.unit_importance(V, Phi)
    A = float(imp.sum())
    info["path_norm_A"] = A
    info["eff_units"] = float(imp.sum() ** 2 / (imp ** 2).sum())       # participation ratio of importances
    (W10, b10), (V0, c0) = Iw
    Phi0 = ss.relu_features(W10, b10, Xfit)
    m11, m10, m00 = np.mean(Phi ** 2, 0), np.mean(Phi * Phi0, 0), np.mean(Phi0 ** 2, 0)
    dn = np.sqrt(np.maximum(np.sum(V ** 2, 0) * m11 - 2 * np.sum(V * V0, 0) * m10 + np.sum(V0 ** 2, 0) * m00, 0))
    info["path_norm_A_update"] = float(dn.sum())
    info["f0_rms"] = float(np.sqrt(np.mean((Phi0 @ V0.T + c0) ** 2)))
    info["f_rms"] = float(np.sqrt(np.mean(zfit ** 2)))
    gam = np.quantile(np.abs(zsel), [0.01, 0.05, 0.1, 0.25, 0.5])
    info["margin_quantiles"] = [float(x) for x in gam]
    # Maurey prediction for E[Pr(f != g)] after k i.i.d. draws: min_gamma Pr(|f|<gamma) + A^2/(k gamma^2)
    absz = np.sort(np.abs(zsel))
    grid = np.quantile(absz, np.linspace(0.001, 0.999, 400))
    info["maurey_pred"] = {}
    for k in ks + [256, 1024]:
        pr = np.searchsorted(absz, grid) / len(absz)
        info["maurey_pred"][k] = float(np.min(pr + A ** 2 / (k * grid ** 2)))

# ----------------------------------------------------------------------------- search families
seeds_draw = list(range(args.draws))
if args.depth == 1 and want("maurey_raw"):
    t = time.time()
    raw = []
    for k in ks:
        for r in seeds_draw:
            gw, idx, inf_ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(10_000 * k + r), "maurey", refit=False)
            raw.append({"k": k, "draw": r, "dis": float_dis(gw), "unique": inf_["unique"]})
    info["maurey_raw"] = raw
    # float-only curves (no quantization): disagreement after keeping k units and refitting the output layer
    curves = []
    for k in [kk for kk in (2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048) if kk < N]:
        for mode in ["maurey", "topk", "uniform"]:
            gw, idx, _ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(30_000 * k), mode, refit=True)
            curves.append({"k": k, "mode": mode, "dis": float_dis(gw), "unique": int(len(idx))})
        gw, idx, _ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(30_000 * k), "maurey", refit=False)
        curves.append({"k": k, "mode": "maurey_norefit", "dis": float_dis(gw), "unique": int(len(idx))})
        lg, idx, _ = ss.subsample_update(Fw, Iw, k, Xfit, np.random.default_rng(30_000 * k), "maurey", refit=True)
        curves.append({"k": k, "mode": "update", "dis": float(np.mean((lg(Xsel)[:, 0] > 0).astype(np.int64) != ysel)),
                       "unique": int(len(idx))})
    info["float_curves"] = curves
    timing["maurey_raw"] = time.time() - t

if args.depth == 1 and want("sub_refit"):
    t = time.time()
    for k in ks:
        for mode in ["maurey", "topk", "uniform"]:
            for r in (seeds_draw if mode != "topk" else [0]):
                gw, idx, _ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(10_000 * k + r), mode, refit=True)
                fd = float_dis(gw)
                for rel in rels:
                    qw, exps = quantize_refit_chain([gw[0], gw[1]], rel)
                    g, _ = quant_code(qw, np.arange(n), exps)
                    consider("sub_refit", g, f"{mode} k={k} draw={r} rel={rel}", k=k, mode=mode, rel=rel, float_dis=fd)
                    ref = (Iw[0][0][idx], Iw[0][1][idx])
                    qw, exps = quantize_refit_chain([gw[0], gw[1]], rel, ref_first=ref)
                    q_ref = [ref, (np.zeros_like(qw[1][0]), np.zeros_like(qw[1][1]))]
                    g, _ = quant_code(qw, np.arange(n), exps, ref=q_ref,
                                      extra={"unit indices": coding.elias_delta(N) + coding.subset(N, len(idx))})
                    consider("sub_refit_init", g, f"{mode} k={k} draw={r} rel={rel}", k=k, mode=mode, rel=rel,
                             float_dis=fd)
    timing["sub_refit(+init)"] = time.time() - t

if args.depth == 1 and want("update_refit"):
    # update subsampling: g = f0 + sum_j beta_j delta_j (f0 free)
    t = time.time()
    (W1, b1), (V, c) = Fw
    (W10, b10), (V0, c0) = Iw
    for k in ks:
        for r in seeds_draw:
            lg, idx, inf_ = ss.subsample_update(Fw, Iw, k, Xfit, np.random.default_rng(20_000 * k + r), "maurey", refit=True)
            fd = float(np.mean((lg(Xsel)[:, 0] > 0).astype(np.int64) != ysel))
            for rel in rels:
                sW, sb = QuantMLP.step_value(step_exp(W1[idx] - W10[idx], rel)), QuantMLP.step_value(step_exp(b1[idx] - b10[idx], rel))
                sV = QuantMLP.step_value(step_exp(V[:, idx] - V0[:, idx], rel))
                qW = np.round((W1[idx] - W10[idx]) / sW).astype(np.int64)
                qb = np.round((b1[idx] - b10[idx]) / sb).astype(np.int64)
                qV = np.round((V[:, idx] - V0[:, idx]) / sV).astype(np.int64)
                Wk, bk, Vk = W10[idx] + qW * sW, b10[idx] + qb * sb, V0[:, idx] + qV * sV
                Pk, P0k = ss.relu_features(Wk, bk, Xfit), ss.relu_features(W10[idx], b10[idx], Xfit)
                Dk = Pk * Vk[0][None, :] - P0k * V0[0, idx][None, :]
                f0fit = np_forward(Iw, Xfit)[:, 0]
                beta, cs = ss.refit_linear(Dk, (zfit - f0fit)[:, None])
                beta = beta[0]
                sbeta = QuantMLP.step_value(step_exp(beta, rel / 4))
                qbeta = np.round(beta / sbeta).astype(np.int64)
                beta_q = qbeta * sbeta
                cq = np.round(cs / 2 ** -10) * 2 ** -10
                d = coding.Description()
                d.add("search family", 3.0)
                d.add("seed", 32.0)
                d.add("unit indices", coding.elias_delta(N) + coding.elias_delta(len(idx)) + coding.subset(N, len(idx)))
                d.add("steps", sum(coding.signed_int(step_exp(x, rel)) for x in (W1[idx] - W10[idx], b1[idx] - b10[idx], V[:, idx] - V0[:, idx]))
                      + coding.signed_int(step_exp(beta, rel / 4)))
                d.add("delta W", coding.best_tensor_code(qW))
                d.add("delta b", coding.best_tensor_code(qb))
                d.add("delta a", coding.best_tensor_code(qV))
                d.add("beta", coding.best_tensor_code(qbeta))
                d.add("output shift", coding.signed_int(int(np.round(cs[0] / 2 ** -10))))
                W10k, b10k, V0k = W10[idx], b10[idx], V0[0, idx]

                def lg_q(X, Wk=Wk, bk=bk, Vk=Vk, beta_q=beta_q, cq=cq, W10k=W10k, b10k=b10k, V0k=V0k):
                    return (np_forward(Iw, X)[:, 0] + ss.relu_features(Wk, bk, X) @ (Vk[0] * beta_q)
                            - ss.relu_features(W10k, b10k, X) @ (V0k * beta_q) + cq[0])
                consider("update_refit", Code(lg_q, d), f"k={k} draw={r} rel={rel}", k=k, rel=rel, float_dis=fd)
    timing["update_refit"] = time.time() - t

if args.depth == 1 and want("sub_distill"):
    # subsample then distill (from the best maurey and top-k refits at each k)
    t = time.time()
    for k in ks:
        for mode in ["maurey", "topk"]:
            gw, idx, _ = ss.subsample_one_layer(Fw, k, Xfit, np.random.default_rng(10_000 * k), mode, refit=True)
            distill_and_quantize("sub_distill", to_mlp(gw), f"{mode} k={k}", args.distill_steps // 2, 1e-3, args.seed + k,
                                 k=k, mode=mode)
    timing["sub_distill"] = time.time() - t

if args.depth == 1 and want("greedy"):
    # greedy (orthogonal matching pursuit) unit selection, nested in k
    t = time.time()
    (W1, b1), (V, c) = Fw
    kg = min(128, N)
    order = ss.greedy_units(ss.relu_features(W1, b1, Xfit), zfit[:, None], kg, return_order=True)
    gcurve = []
    for k in [kk for kk in (2, 4, 8, 16, 32, 64, 128) if kk <= kg]:
        idx = np.sort(order[:k])
        Wo, bo = ss.refit_linear(ss.relu_features(W1[idx], b1[idx], Xfit), zfit[:, None])
        gcurve.append({"k": k, "mode": "greedy", "dis": float_dis([(W1[idx], b1[idx]), (Wo, bo)])})
    info["float_curves_greedy"] = gcurve
    for k in ks:
        idx = np.sort(order[:k])
        Wo, bo = ss.refit_linear(ss.relu_features(W1[idx], b1[idx], Xfit), zfit[:, None])
        gw = [(W1[idx].copy(), b1[idx].copy()), (Wo, bo)]
        fd = float_dis(gw)
        for rel in rels:
            qw, exps = quantize_refit_chain([gw[0], gw[1]], rel)
            g, _ = quant_code(qw, np.arange(n), exps)
            consider("greedy_refit", g, f"greedy k={k} rel={rel}", k=k, mode="greedy", rel=rel, float_dis=fd)
            ref = (Iw[0][0][idx], Iw[0][1][idx])
            qw, exps = quantize_refit_chain([gw[0], gw[1]], rel, ref_first=ref)
            q_ref = [ref, (np.zeros_like(qw[1][0]), np.zeros_like(qw[1][1]))]
            g, _ = quant_code(qw, np.arange(n), exps, ref=q_ref,
                              extra={"unit indices": coding.elias_delta(N) + coding.subset(N, len(idx))})
            consider("greedy_refit_init", g, f"greedy k={k} rel={rel}", k=k, mode="greedy", rel=rel, float_dis=fd)
        distill_and_quantize("greedy_distill", to_mlp(gw), f"greedy k={k}", args.distill_steps // 2, 1e-3,
                             args.seed + k, k=k, mode="greedy")
    timing["greedy"] = time.time() - t

if want("mixed"):
    # Distil on fresh inputs AND on the training set.  f interpolates S, so its labels there are the
    # true labels; weighting the training points keeps g's training error (the Occam term) small.
    t = time.time()
    reps = max(1, int(round(len(Xdis) / m)))
    Xmix = np.concatenate([Xdis] + [Xtr] * reps)
    ymix = np.concatenate([pdis] + [ytr.astype(np.float64)] * reps)
    for k in ks:
        st = MLP([n] + [k] * args.depth + [1], seed=args.seed + 31 * k)
        distill_and_quantize_pool("mixed_scratch", st, f"k={k}", Xmix, ymix, args.distill_steps, 3e-3, args.seed + k, k=k)
        if args.depth == 1:
            (W1, b1), (V, c) = Fw
            order = ss.greedy_units(ss.relu_features(W1, b1, Xfit), zfit[:, None], k, return_order=True)
            idx = np.sort(order)
            Wo, bo = ss.refit_linear(ss.relu_features(W1[idx], b1[idx], Xfit), zfit[:, None])
            distill_and_quantize_pool("mixed_greedy", to_mlp([(W1[idx].copy(), b1[idx].copy()), (Wo, bo)]), f"greedy k={k}",
                                      Xmix, ymix, args.distill_steps // 2, 1e-3, args.seed + k, k=k)
    timing["mixed"] = time.time() - t

if args.depth == 2 and want("sub_refit"):
    (W1, b1), (W2, b2), (V, c) = Fw
    t = time.time()
    curves = []
    for k in [kk for kk in (2, 4, 8, 16, 32, 64, 128, 256) if kk < N]:
        for mode in ["maurey", "topk"]:
            gw, _, _ = ss.subsample_two_layer(Fw, k, k, Xfit, np.random.default_rng(30_000 * k), mode)
            curves.append({"k": k, "mode": mode, "dis": float_dis(gw)})
    info["float_curves"] = curves
    H1 = ss.relu_features(W1, b1, Xfit)
    Z2 = H1 @ W2.T + b2
    for k in ks:
        for mode in ["maurey", "topk"]:
            for r in (seeds_draw if mode != "topk" else [0]):
                gw, (idx1, idx2), _ = ss.subsample_two_layer(Fw, k, k, Xfit, np.random.default_rng(10_000 * k + r), mode)
                fd = float_dis(gw)
                for rel in rels:
                    qw, exps = quantize_refit_chain([gw[0], (gw[1][0], gw[1][1], Z2[:, idx2]), gw[2]], rel)
                    g, _ = quant_code(qw, np.arange(n), exps)
                    consider("sub_refit", g, f"{mode} k={k} draw={r} rel={rel}", k=k, mode=mode, rel=rel, float_dis=fd)
                if mode == "maurey" and r == 0 or mode == "topk":
                    distill_and_quantize("sub_distill", to_mlp(gw), f"{mode} k={k}", args.distill_steps // 2, 1e-3,
                                         args.seed + k, k=k, mode=mode)
    timing["sub_refit+sub_distill"] = time.time() - t

if want("scratch"):
    t = time.time()
    for k in ks:
        st = MLP([n] + [k] * args.depth + [1], seed=args.seed + 31 * k)
        distill_and_quantize("scratch", st, f"k={k}", args.distill_steps, 3e-3, args.seed + k, k=k)
    timing["scratch"] = time.time() - t

if want("codec") and not args.skip_codec:
    t = time.time()
    best, cc, inf = compress(lambda X: f_predict(X), n, Xtr, ytr, rng=np.random.default_rng(4242 + args.seed), delta=delta,
                             seed=args.seed, log=lambda s: None)
    for c in cc:
        g = c["g"]
        d = g.description()
        cands.append(({"family": "codec", "label": c["label"], "bits": g.bits, "train_err_g": c["train_err_g"],
                       "occ": occam_bound(c["train_err_g"], m, g.bits + DESIGN_BITS, delta / 2),
                       "sel_dis": float(np.mean(g.predict(Xsel) != ysel))}, g))
        cands[-1][0]["est"] = cands[-1][0]["occ"] + cands[-1][0]["sel_dis"]
    timing["codec"] = time.time() - t

# ----------------------------------------------------------------------------- certify each family's best
cert_seed = secrets.randbits(63)
rc = np.random.default_rng(cert_seed)
Xc = uniform_cube(n, 200_000, rc)
fc = f_predict(Xc)
final = {}
for fam in sorted({c["family"] for c, _ in cands}):
    c, g = min(((c, g) for c, g in cands if c["family"] == fam), key=lambda t: t[0]["est"])
    dis_k = int(np.sum(g.predict(Xc) != fc))
    r = {"m": m, "bits": g.bits, "train_err_g": c["train_err_g"], "dis_count": dis_k, "n_cert": 200_000}
    final[fam] = {"label": c["label"], "bits": g.bits, "train_err_g": c["train_err_g"], "dis_count": dis_k,
                  "dis_hat": dis_k / 200_000, "bound_f": boolean_bound(r, delta), "code": g.description().summary()}
    print(f"  {fam:15s} {c['label']:32s} bits {g.bits:9.1f} dis {dis_k / 2e5:.4f} bound {final[fam]['bound_f']:.4f}", flush=True)

res = {"task": args.task, "n": n, "m": m, "seed": args.seed, "param": args.param, "width": N, "depth": args.depth,
       "params": int(params), "train": tr, "train_err_f": k_tr_f / m, "test_err_f": test_err_f, "rel_param_move": rel_move,
       "info": info, "timing": {k: round(v, 1) for k, v in timing.items()}, "final": final, "cert_seed": str(cert_seed),
       "baseline_occam32": occam_bound(k_tr_f, m, 32.0 * params + 64, delta),
       "candidates": [c for c, _ in cands], "secs": round(time.time() - T0, 1), "secs_train": round(t_train, 1),
       "args": vars(args)}
os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
with open(args.out, "a") as fh:
    fh.write(json.dumps(res) + "\n")
print(f"done in {time.time() - T0:.0f}s", flush=True)
