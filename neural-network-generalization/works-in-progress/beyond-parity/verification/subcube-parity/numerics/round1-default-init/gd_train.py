"""Online SGD/Adam on standard MLPs for Boolean targets on {-1,1}^D (uniform inputs).

Targets (d = number of x bits; f_mix uses one extra bit z as the LAST coordinate):
  stair : f1(x)   = sign(sum_t x_1..x_t)                       (D = d, d odd)
  mix   : f*(x,z) = f1(x) if z=+1, chi_[d](x) if z=-1           (D = d+1)
  par   : chi_[d](x)                                            (D = d)
  ctrl  : x_1 if z=+1, chi_[d](x) if z=-1                        (D = d+1)
Usage: python gd_train.py target d steps seed [width depth lr batch init]
Prints test error (overall, and on the z=-1 half for mix/ctrl) every eval interval.
"""
import sys, time, math
import torch, torch.nn as nn

torch.set_num_threads(1)
target, d, steps, seed = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
width = int(sys.argv[5]) if len(sys.argv) > 5 else 512
depth = int(sys.argv[6]) if len(sys.argv) > 6 else 3
lr = float(sys.argv[7]) if len(sys.argv) > 7 else 1e-3
batch = int(sys.argv[8]) if len(sys.argv) > 8 else 512
init = sys.argv[9] if len(sys.argv) > 9 else "default"
torch.manual_seed(seed)
D = d + 1 if target in ("mix", "ctrl", "mixw") else d

def label(X):
    x = X[:, :d]
    Y = torch.cumprod(x, dim=1)
    if target == "stair":
        return torch.sign(Y.sum(1))
    if target == "par":
        return Y[:, -1]
    z = X[:, d]
    if target == "mix":
        return torch.where(z > 0, torch.sign(Y.sum(1)), Y[:, -1])
    if target == "mixw":   # z=+1: weighted staircase with heavy last term c*y_d, c = odd ~ sqrt(d)
        c = (int(math.sqrt(d)) // 2) * 2 + 1
        return torch.where(z > 0, torch.sign(Y[:, :-1].sum(1) + c * Y[:, -1]), Y[:, -1])
    if target == "ctrl":
        return torch.where(z > 0, x[:, 0], Y[:, -1])
    raise ValueError(target)

def sample(n):
    return torch.randint(0, 2, (n, D)).float() * 2 - 1

arch = sys.argv[10] if len(sys.argv) > 10 else "mlp"
if arch == "mlp":
    layers, w = [], D
    for _ in range(depth):
        layers += [nn.Linear(w, width), nn.ReLU()]
        w = width
    layers += [nn.Linear(w, 1)]
    net = nn.Sequential(*layers)
else:
    # shared trunk on x only; z (last coordinate) enters only through a gated linear readout:
    # out = a.h(x) + z * b.h(x)   (two tasks, z = task indicator)
    class Trunk(nn.Module):
        def __init__(self):
            super().__init__()
            layers, w = [], d
            for _ in range(depth):
                layers += [nn.Linear(w, width), nn.ReLU()]
                w = width
            self.h = nn.Sequential(*layers)
            self.a = nn.Linear(width, 1); self.b = nn.Linear(width, 1)
        def forward(self, X):
            h = self.h(X[:, :d])
            return self.a(h) + X[:, d:d + 1] * self.b(h)
    net = Trunk()
if init == "rademacher" and arch == "mlp":   # first layer +-1/sqrt(D) entries
    with torch.no_grad():
        net[0].weight.copy_((torch.randint(0, 2, net[0].weight.shape).float() * 2 - 1) / math.sqrt(D))
opt = torch.optim.Adam(net.parameters(), lr=lr)
Xt = sample(20000); yt = label(Xt)
half = (Xt[:, -1] < 0) if target in ("mix", "ctrl", "mixw") else None
t0 = time.time()
evals = sorted(set([int(steps * q) for q in [i / 40 for i in range(1, 41)]]))
for s in range(1, steps + 1):
    X = sample(batch); y = label(X)
    loss = ((net(X).squeeze(1) - y) ** 2).mean()
    opt.zero_grad(); loss.backward(); opt.step()
    if s in evals:
        with torch.no_grad():
            p = torch.sign(net(Xt).squeeze(1))
            err = (p != yt).float().mean().item()
            msg = f"step {s} samples {s*batch:.2e} test_err {err:.4f}"
            if half is not None:
                msg += f" err_zneg {(p[half] != yt[half]).float().mean().item():.4f} err_zpos {(p[~half] != yt[~half]).float().mean().item():.4f}"
            # staircase diagnostic: correlation of the network output with prefix parities y_t,
            # relative to the target's own correlation with y_t (digit 9 = fully matched)
            out = net(Xt).squeeze(1)
            Yt = torch.cumprod(Xt[:, :d], dim=1)
            cn = (out[:, None] * Yt).mean(0); cf = (yt[:, None] * Yt).mean(0)
            ratio = (cn / cf).clamp(-9, 9)
            msg += " stair[" + "".join(str(int(max(0, min(9, round(float(v) * 9))))) for v in ratio) + "]"
            print(msg + f"  ({time.time()-t0:.0f}s)", flush=True)
