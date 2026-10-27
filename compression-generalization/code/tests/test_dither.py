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


if __name__ == "__main__":
    for C in (1, 4):
        for t1, t2 in [(2.6, 1.6), (3.0, 1.4)]:
            for coarse in (-6, 0, 4):
                print(C, t1, t2, coarse, violation_rate(C, t1, t2, coarse))
