"""Online Adam/SGD on standard nets for Boolean targets on {-1,1}^D, uniform inputs.
Adapted from round1-default-init/gd_train.py.  Changes:
  * --init gaussian : every weight iid N(0, 1/fan_in), every bias 0 (incl. readouts).
  * held-out test set: 20000 points (stratified 10000 per z-half for mix/ctrl), and every
    training point that coincides with a test point is resampled, so test points are never
    trained on (matters when 2^D is comparable to the number of training samples).
  * fine eval grid; records the first sample count at which each error <= --thr; JSON summary.
  * --opt sgd (with --momentum) as an alternative to Adam.

Targets (x = first d coordinates, z = coordinate d (last) for mix/ctrl; d odd for stair/mix):
  stair : sign(sum_{t<=d} x_1..x_t)                                 D = d
  par   : x_1 x_2 ... x_d                                           D = d
  mix   : f*(x,z) = stair(x) if z=+1, par(x) if z=-1                D = d+1
  ctrl  : x_1 if z=+1, par(x) if z=-1                               D = d+1
Archs:
  trunk : h = MLP_depth(x) (ReLU, width), out = a.h + z * b.h  (z only gates the readout)
  mlp   : plain MLP on all D coordinates (z, if present, is an ordinary input)
Labels are computed from the sampled input only; the network never sees labels as inputs.
"""
import argparse, json, math, sys, time
import torch, torch.nn as nn

p = argparse.ArgumentParser()
p.add_argument("target"); p.add_argument("d", type=int)
p.add_argument("--arch", default="trunk"); p.add_argument("--depth", type=int, default=3)
p.add_argument("--width", type=int, default=512); p.add_argument("--init", default="gaussian")
p.add_argument("--opt", default="adam"); p.add_argument("--lr", type=float, default=1e-3)
p.add_argument("--momentum", type=float, default=0.0)
p.add_argument("--batch", type=int, default=512); p.add_argument("--seed", type=int, default=1)
p.add_argument("--max_samples", type=float, default=3e7); p.add_argument("--thr", type=float, default=0.05)
p.add_argument("--stop_after", type=int, default=3,
               help="stop once every tracked error <= thr at this many consecutive evals")
p.add_argument("--ntest", type=int, default=20000); p.add_argument("--json", default=None)
a = p.parse_args()

torch.set_num_threads(1)
torch.manual_seed(a.seed)
d = a.d
two_task = a.target in ("mix", "ctrl")
D = d + 1 if two_task else d
assert D <= 62

def label(X):
    x = X[:, :d]
    Y = torch.cumprod(x, dim=1)
    if a.target == "stair":
        return torch.sign(Y.sum(1))
    if a.target == "par":
        return Y[:, -1]
    z = X[:, d]
    if a.target == "mix":
        return torch.where(z > 0, torch.sign(Y.sum(1)), Y[:, -1])
    if a.target == "ctrl":
        return torch.where(z > 0, x[:, 0], Y[:, -1])
    raise ValueError(a.target)

POW = (2 ** torch.arange(D, dtype=torch.int64))
def code(X):  # integer code of a +-1 point
    return (((1 - X) / 2).to(torch.int64) * POW).sum(1)

def sample(n):
    return torch.randint(0, 2, (n, D)).float() * 2 - 1

# ---- held-out test set (separate seeded generator) ----
gtest = torch.Generator().manual_seed(10_000 + a.seed)
def sample_g(n):
    return torch.randint(0, 2, (n, D), generator=gtest).float() * 2 - 1
if two_task:
    Xt = sample_g(a.ntest); Xt[: a.ntest // 2, -1] = -1; Xt[a.ntest // 2:, -1] = 1
else:
    Xt = sample_g(a.ntest)
ct = torch.unique(code(Xt))          # sorted test codes
yt = label(Xt)
half = (Xt[:, -1] < 0) if two_task else None

# ---- network ----
def mlp(n_in):
    layers, w = [], n_in
    for _ in range(a.depth):
        layers += [nn.Linear(w, a.width), nn.ReLU()]; w = a.width
    return layers, w

if a.arch == "mlp":
    layers, w = mlp(D)
    net = nn.Sequential(*layers, nn.Linear(w, 1))
    first = net[0]
elif a.arch == "trunk":
    assert two_task or True
    class Trunk(nn.Module):
        def __init__(self):
            super().__init__()
            layers, w = mlp(d)
            self.h = nn.Sequential(*layers)
            self.a = nn.Linear(w, 1)
            self.b = nn.Linear(w, 1) if two_task else None
        def forward(self, X):
            h = self.h(X[:, :d])
            out = self.a(h)
            if self.b is not None:
                out = out + X[:, d:d + 1] * self.b(h)
            return out
    net = Trunk(); first = net.h[0]
else:
    raise ValueError(a.arch)

# init variants (all layers): weights  gaussian*: N(0, 1/fan_in) ; gaussian3*: N(0, 1/(3 fan_in))
# (= variance of PyTorch's default U(-1/sqrt(fan_in), 1/sqrt(fan_in))) ; default0: PyTorch default weights.
# biases: suffix U keeps PyTorch's default U(-1/sqrt(fan_in), 1/sqrt(fan_in)) biases, otherwise 0.
VARIANTS = {"gaussian": (1.0, False), "gaussianU": (1.0, True), "gaussian3": (1 / 3, False),
            "gaussian3U": (1 / 3, True), "default0": (None, False)}
if a.init in VARIANTS:
    vscale, keep_bias = VARIANTS[a.init]
    with torch.no_grad():
        for m in net.modules():
            if isinstance(m, nn.Linear):
                if vscale is not None:
                    m.weight.normal_(0.0, math.sqrt(vscale / m.weight.shape[1]))
                if not keep_bias:
                    m.bias.zero_()
elif a.init == "rademacher":   # first layer +-1/sqrt(fan_in), rest default
    with torch.no_grad():
        fi = first.weight.shape[1]
        first.weight.copy_((torch.randint(0, 2, first.weight.shape).float() * 2 - 1) / math.sqrt(fi))
elif a.init != "default":
    raise ValueError(a.init)

if a.opt == "adam":
    opt = torch.optim.Adam(net.parameters(), lr=a.lr)
elif a.opt == "sgd":
    opt = torch.optim.SGD(net.parameters(), lr=a.lr, momentum=a.momentum)
else:
    raise ValueError(a.opt)

steps = int(a.max_samples // a.batch)
def is_eval(s):
    return (s <= 2000 and s % 100 == 0) or (s % 500 == 0) or s == steps

hit = {}; consec = 0; t0 = time.time(); n_reject = 0; loss_acc = 0.0; loss_n = 0
Yt = torch.cumprod(Xt[:, :d], dim=1); cf = (yt[:, None] * Yt).mean(0)
hdr = vars(a).copy(); hdr["D"] = D; hdr["n_params"] = sum(q.numel() for q in net.parameters())
print("# " + json.dumps(hdr), flush=True)
last = None
for s in range(1, steps + 1):
    X = sample(a.batch)
    bad = torch.isin(code(X), ct)
    while bad.any():                       # never train on a test point
        n_reject += int(bad.sum())
        X[bad] = sample(int(bad.sum()))
        bad = torch.isin(code(X), ct)
    y = label(X)
    loss = ((net(X).squeeze(1) - y) ** 2).mean()
    opt.zero_grad(); loss.backward(); opt.step()
    loss_acc += loss.item(); loss_n += 1
    if is_eval(s):
        with torch.no_grad():
            out = net(Xt).squeeze(1)
        pr = torch.sign(out)
        errs = {"all": (pr != yt).float().mean().item()}
        if two_task:
            errs["zneg"] = (pr[half] != yt[half]).float().mean().item()
            errs["zpos"] = (pr[~half] != yt[~half]).float().mean().item()
        n = s * a.batch
        for k, v in errs.items():
            if v <= a.thr and k not in hit:
                hit[k] = n
        tracked = [errs["zneg"], errs["zpos"]] if two_task else [errs["all"]]
        consec = consec + 1 if max(tracked) <= a.thr else 0
        cn = (out[:, None] * Yt).mean(0)
        ratio = (cn / cf).clamp(-9, 9) if a.target in ("mix", "stair") else None
        msg = f"step {s} samples {n:.3e} " + " ".join(f"err_{k} {v:.4f}" for k, v in errs.items())
        msg += f" train_loss {loss_acc / max(loss_n, 1):.4f}"
        if ratio is not None:
            msg += " stair[" + "".join(str(int(max(0, min(9, round(float(v) * 9))))) for v in ratio) + "]"
        print(msg + f"  ({time.time() - t0:.0f}s)", flush=True)
        loss_acc = 0.0; loss_n = 0
        last = dict(step=s, samples=n, **{"err_" + k: v for k, v in errs.items()})
        if consec >= a.stop_after:
            break

summary = dict(args=hdr, hit_samples=hit, final=last, wall_s=round(time.time() - t0, 1),
               rejected_train_points=n_reject, test_points=a.ntest, distinct_test_points=int(ct.numel()),
               stopped_early=consec >= a.stop_after)
print("# SUMMARY " + json.dumps(summary), flush=True)
if a.json:
    with open(a.json, "w") as f:
        json.dump(summary, f, indent=1)
