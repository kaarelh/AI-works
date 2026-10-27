"""Monte Carlo checks of the dithered-certificate concentration claims.

For a fixed network f and inputs x, over fresh dithers xi:
  P[ exists c: |M_g,yc - M_f,yc| > T_yc(g) ] <= eta(t1, t2)
where M is the margin z_y - z_c (binary: signed logit) and T the threshold
computed from g alone.  We use small t1, t2 so that eta is well below 1
but violations would be visible."""
import numpy as np

from cgb.dither import DitheredNet, certificate_v2, bad_event_prob
from cgb.models import np_forward


def make(rng, d, H, C):
    W = rng.standard_normal((H, d)) / np.sqrt(d)
    b = rng.standard_normal(H) * 0.3
    V = rng.standard_normal((C, H)) / np.sqrt(H)
    c = rng.standard_normal(C) * 0.1
    W0 = W + rng.standard_normal(W.shape) * 0.3
    return [(W, b), (V, c)], [(W0, b * 0), (V * 0, c * 0)]


def violation_rate(C, t1, t2, coarse, d=30, H=4, trials=400, seed=0):
    rng = np.random.default_rng(seed)
    F, I = make(rng, d, H, C)
    X = rng.standard_normal((100, d))
    zf = np_forward(F, X)
    y = (zf[:, 0] > 0).astype(int) if C == 1 else zf.argmax(1)
    if C == 1:
        Mf = ((2 * y - 1) * zf[:, 0])[:, None]
    else:
        Mf = zf[np.arange(len(y)), y][:, None] - zf
    B = np.eye(d)
    ids = np.zeros(d, dtype=int)
    viol = 0
    for t in range(trials):
        g = DitheredNet(F, I, B, ids, np.zeros(H, int), np.array([coarse]), coarse, coarse, coarse,
                        seed=10_000 * seed + t)
        _, _, (Mg, T) = certificate_v2(g, X, y, t1=t1, t2=t2, return_parts=True)
        bad = np.abs(Mg - Mf) > T
        if C > 1:
            bad[np.arange(len(y)), y] = False
        viol += bad.any(1).sum()
    return viol / (trials * len(X)), bad_event_prob(H, max(C, 2), t1, t2)


def test_dither_concentration():
    for C in (1, 4):
        for t1, t2 in [(2.6, 1.6), (3.0, 1.4)]:
            for coarse in (-6, 0, 4):
                rate, eta = violation_rate(C, t1, t2, coarse)
                assert eta < 1
                assert rate <= eta, (C, t1, t2, coarse, rate, eta)


def calibration(regime, trials=2500, seed=3):
    """Var_xi(F) / P_hat in a regime where Lemma 7's proxy should be exact:
    'V' = only the output-layer dithers matter; 'active' = only the first-layer
    dithers matter and every unit is far inside its active region."""
    rng = np.random.default_rng(seed)
    d, H, C = 20, 6, 3
    W = rng.standard_normal((H, d)) / np.sqrt(d)
    V = rng.standard_normal((C, H))
    if regime == "V":
        b = np.abs(rng.standard_normal(H)) + 1.0
        e_first, e_V = -60, 0          # first-layer steps ~ 0
    else:
        b = np.full(H, 50.0)           # all units strongly active
        e_first, e_V = -4, -60         # output-layer steps ~ 0
    F = [(W, b), (V, np.zeros(C))]
    I = [(W * 0, b * 0), (V * 0, np.zeros(C))]
    x = rng.standard_normal((1, d))
    zf = np_forward(F, x)
    y = np.array([int(zf.argmax())])
    c = (y[0] + 1) % C
    Mf = zf[0, y[0]] - zf[0, c]
    B = np.eye(d)
    ids = np.zeros(d, dtype=int)
    Fs, P = [], None
    for t in range(trials):
        g = DitheredNet(F, I, B, ids, np.zeros(H, int), np.array([e_first]), e_first, e_V, e_V, seed=77 + t)
        zg = np_forward(g.weights(), x)
        Fs.append(zg[0, y[0]] - zg[0, c] - Mf)
        if P is None:
            # sqrt(2 P) = T(t2 = 2) - T(t2 = 1) at fixed t1 (the bias does not depend on t2)
            _, _, (_, T2) = certificate_v2(g, x, y, t1=6.0, t2=2.0, return_parts=True)
            _, _, (_, T1) = certificate_v2(g, x, y, t1=6.0, t2=1.0, return_parts=True)
            P = ((T2 - T1)[0, c]) ** 2 / 2
    return float(np.var(Fs) / P)


def test_dither_proxy_calibrated():
    # a proxy that is too small (a bug in a constant) would give a ratio well above 1,
    # a needlessly loose one a ratio well below 1
    # Monte Carlo relative error of the variance estimate is about sqrt(2/2500) = 2.8%
    for regime in ("V", "active"):
        r = calibration(regime)
        assert 0.88 < r < 1.12, (regime, r)


if __name__ == "__main__":
    print("calibration V", calibration("V"), "active", calibration("active"))
    for C in (1, 4):
        for t1, t2 in [(2.6, 1.6), (3.0, 1.4)]:
            for coarse in (-6, 0, 4):
                print(C, t1, t2, coarse, violation_rate(C, t1, t2, coarse))
