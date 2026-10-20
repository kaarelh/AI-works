"""Sanity check: two-head net out(x,z) = a.h(x) + z b.h(x) with a,b iid (same law).
(1) prior covariance across halves: Cov[out(x,+1), out(x',-1)] = (Var a - Var b) Q(x,x') = 0; within: 2 Var a Q.
(2) empirical NTK across halves -> 0 as width grows (relative to within-half), i.e. the lazy/kernel regime decouples too.
Contrast: plain MLP with z as an input has cross-half NNGP covariance kappa(x.x'/(D+1)) != 0."""
import torch, math
torch.set_num_threads(1); torch.manual_seed(0)
d = 8
def trunk(N, L=2):
    layers, w = [], d
    for _ in range(L):
        lin = torch.nn.Linear(w, N); torch.nn.init.normal_(lin.weight, 0, 1 / math.sqrt(w)); torch.nn.init.normal_(lin.bias, 0, 1.0)
        layers += [lin, torch.nn.Tanh()]; w = N
    return torch.nn.Sequential(*layers)
X = (torch.randint(0, 2, (6, d)) * 2 - 1).float()
# (1) prior covariance over random draws at width N=512
N, R = 512, 400
outs_p, outs_m = [], []
for r in range(R):
    h = trunk(N)(X); a = torch.randn(N) / math.sqrt(N); b = torch.randn(N) / math.sqrt(N)
    outs_p.append((h @ (a + b)).detach()); outs_m.append((h @ (a - b)).detach())
P = torch.stack(outs_p); M = torch.stack(outs_m)
cross = (P[:, :, None] * M[:, None, :]).mean(0); within = (P[:, :, None] * P[:, None, :]).mean(0)
print(f"(1) prior: mean |Cov(+,-)| = {cross.abs().mean():.4f}  vs mean |Cov(+,+)| = {within.abs().mean():.4f}  (MC noise ~ {within.abs().mean()/math.sqrt(R):.4f})")
# (2) empirical NTK at init for growing width
for N in [256, 1024, 4096]:
    net = trunk(N); a = torch.nn.Parameter(torch.randn(N) / math.sqrt(N)); b = torch.nn.Parameter(torch.randn(N) / math.sqrt(N))
    params = list(net.parameters()) + [a, b]
    def grad(x, z):
        out = net(x[None])[0] @ (a + z * b)
        g = torch.autograd.grad(out, params)
        return torch.cat([t.reshape(-1) for t in g])
    Gp = torch.stack([grad(x, 1.0) for x in X]); Gm = torch.stack([grad(x, -1.0) for x in X])
    print(f"(2) width {N}: mean |NTK(+,-)| = {(Gp @ Gm.T).abs().mean():.4f}   mean |NTK(+,+)| = {(Gp @ Gp.T).abs().mean():.4f}")
