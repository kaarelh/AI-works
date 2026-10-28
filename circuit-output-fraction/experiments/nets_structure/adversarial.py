"""Where the heuristics are unsound: explicit nets of the same architecture
(one hidden layer, ReLU, uniform {-1,+1}^d inputs) on which they are wrong by
exponential factors, with exact p by enumeration (d = 24).

(a) Lattice small ball. f(x) = 1 + a sum_{k<m} (|x_{2k} + x_{2k+1}| - 1), m = d/2,
    with |u| = relu(u) + relu(-u) (width d). Each block is +-1 with probability
    1/2 independently, so f = 1 + a * (Rademacher sum of m terms); with
    1/(2m) < a < 1/(2(m-2)), f < 1/2 iff every block cancels: p = 2^-m. The
    failure is a small-ball event at the lattice scale (x_{2k} = -x_{2k+1} for all
    k). Mean 1, sd a sqrt(m): the output-Gaussian heuristic gives
    Phi(-(1/2)/(a sqrt m)) ~ e^{-m/2}; the Gaussian-input (CLT for the hidden
    pre-activations) and sphere heuristics replace the lattice event by a
    continuous small ball of radius O(1/m) in m dimensions, whose mass decays
    like c^m / m!.
(b) Planted subcube (Thm. blackbox inside the architecture). A trained net g
    plus one unit: f(x) = g(x) - M relu(sum_{i<k} s_i x_i - (k-1)), which fails
    exactly on g's failures and on the subcube {x_i = s_i, i < k} (mass 2^-k)
    when M > max g. Moment-based heuristics barely move when 2^-k << 1/N for
    their N samples; the Gaussian-input surrogate charges the gadget
    Phi(-(k-1)/sqrt k) ~ e^{-k/2} >> 2^-k instead.

usage: python3 adversarial.py   (writes results/adversarial.json)
"""

import math

import numpy as np

from common import MLP, all_f, save_json, suite_net
from heuristics import edgeworth, gauss, lin_gauss_cgf, lugannani_rice_lower, mcfit, sus_curve


def lattice_net(d, a):
    m = d // 2
    W = np.zeros((d, d))
    for k in range(m):
        W[2 * k, 2 * k] = W[2 * k, 2 * k + 1] = 1.0
        W[2 * k + 1, 2 * k] = W[2 * k + 1, 2 * k + 1] = -1.0
    b = np.zeros(d)
    out = np.full((1, d), a)
    c = np.array([1.0 - a * m])
    return MLP([W, out], [b, c], threshold=0.5, loss="mse")


def planted_net(base, k, M, rng):
    d = base.d
    s = rng.choice([-1.0, 1.0], size=d)
    s[k:] = 0.0
    W = np.vstack([base.Ws[0], s[None, :]])
    b = np.append(base.bs[0], -(k - 1.0))
    out = np.append(base.Ws[1][0], -M)[None, :]
    return MLP([W, out], [b, base.bs[1].copy()], threshold=base.threshold, loss=base.loss)


def heur(net, rng):
    d, t = net.d, net.threshold
    f = all_f(net)
    p = float((f < t).mean())
    mu, sd = float(f.mean()), float(f.std())
    y = (f - mu) / sd
    k3, k4 = float((y ** 3).mean()), float((y ** 4).mean() - 3)
    o = dict(p=p, z=(mu - t) / sd, gauss=gauss(t, mu, sd), edgeworth=edgeworth(t, mu, sd, k3, k4),
             mcfit=mcfit(net, rng)(t),
             lin_gauss=lugannani_rice_lower(lin_gauss_cgf(net, mu, sd * sd, rng), t, sd),
             ginput=sus_curve(lambda G: net.forward(G), d, t - 1e-9, rng)(t),
             sphere=sus_curve(lambda G: net.forward(G * (math.sqrt(d) / np.linalg.norm(G, axis=1))[:, None]), d,
                              t - 1e-9, rng)(t))
    return o


def main():
    rng = np.random.default_rng(31)
    rows = []
    d = 24
    m = d // 2
    a = 0.5 * (1 / (2 * m) + 1 / (2 * (m - 2)))
    o = heur(lattice_net(d, a), rng)
    o.update(case="lattice small ball", d=d, exact_formula=2.0 ** -m)
    rows.append(o)
    print(o, flush=True)
    # the same family for larger m, analytically: p = 2^-m, mean 1, sd a sqrt(m)
    for mm in (12, 25, 50, 100, 200):
        aa = 0.5 * (1 / (2 * mm) + 1 / (2 * (mm - 2)))
        z = 0.5 / (aa * math.sqrt(mm))
        g = gauss(0.5, 1.0, aa * math.sqrt(mm))
        rows.append(dict(case="lattice small ball (analytic)", d=2 * mm, p=2.0 ** -mm, z=z, gauss=g,
                         log10_gauss_over_p=math.log10(g) + mm * math.log10(2)))
        print(rows[-1], flush=True)
    base = suite_net("mse_d24_w32_s2000")
    for k in (12, 16, 20):
        net = planted_net(base, k, 10.0, rng)
        o = heur(net, rng)
        o.update(case=f"planted subcube k={k} on mse_d24_w32_s2000", d=d, base_p=5.96e-8, planted_mass=2.0 ** -k)
        rows.append(o)
        print(o, flush=True)
    save_json(rows, "adversarial.json")


if __name__ == "__main__":
    main()
