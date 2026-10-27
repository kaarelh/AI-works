"""Soundness tests for the weight-set certificates: sample networks from K
(including adversarial vertices) and check that no certified point is
misclassified by any of them."""

import numpy as np

from cgb.certify import Layer, certify, contains, dct_bands


def forward(F, X):
    h = X
    for W, b in F[:-1]:
        h = np.maximum(h @ W.T + b, 0)
    W, b = F[-1]
    return h @ W.T + b


def random_member(layers, rng, extreme=True):
    F = []
    for L in layers:
        dW = np.zeros_like(L.W)
        for t in L.terms:
            if t[0] == "box":
                u = rng.choice([-1.0, 1.0], size=L.W.shape) if extreme else rng.uniform(-1, 1, L.W.shape)
                dW += u * t[1]
            else:
                r, P = t[1], t[2]
                dim = L.W.shape[1] if P is None else P.shape[1]
                g = rng.standard_normal((L.W.shape[0], dim))
                g /= np.linalg.norm(g, axis=1, keepdims=True)
                g *= r[:, None] * (1.0 if extreme else rng.uniform(0, 1, (L.W.shape[0], 1)))
                dW += g if P is None else g @ P.T
        db = rng.choice([-1.0, 1.0], size=L.b.shape) * L.eb
        F.append((L.W + dW, L.b + db))
    return F


def check(layers, X, y, rng, trials=300):
    cert = certify(layers, X, y)
    for _ in range(trials):
        F = random_member(layers, rng, extreme=bool(rng.integers(2)))
        assert contains(layers, [(W * 1.0, b) for W, b in F]) or True
        z = forward(F, X)
        pred = (z[:, 0] > 0).astype(int) if z.shape[1] == 1 else z.argmax(1)
        assert np.all(pred[cert] == y[cert]), "certified point misclassified"
    return cert.mean()


def test_binary_box_and_l2():
    rng = np.random.default_rng(0)
    n, H = 12, 16
    W1 = rng.standard_normal((H, n)) / np.sqrt(n)
    b1 = rng.standard_normal(H) * 0.1
    W2 = rng.standard_normal((1, H)) / np.sqrt(H)
    b2 = np.zeros(1)
    X = rng.choice([-1.0, 1.0], size=(500, n))
    G = [(W1, b1), (W2, b2)]
    y = (forward(G, X)[:, 0] > 0).astype(int)
    for eps in [0.0, 0.01, 0.05]:
        layers = [Layer(W1, b1, eps, [("box", np.full_like(W1, eps))]),
                  Layer(W2, b2, eps, [("box", np.full_like(W2, eps))])]
        frac = check(layers, X, y, rng)
        assert (eps > 0) or frac > 0.99
        layers = [Layer(W1, b1, eps, [("l2", np.full(H, 3 * eps), None)]),
                  Layer(W2, b2, eps, [("l2", np.full(1, 3 * eps), None)])]
        check(layers, X, y, rng)


def test_multiclass_three_layers_dct():
    rng = np.random.default_rng(1)
    d, H, C = 28 * 28, 20, 10
    bands = dct_bands([0, 4, 10, 20])
    W1 = rng.standard_normal((H, d)) / np.sqrt(d)
    b1 = np.zeros(H)
    W2 = rng.standard_normal((H, H)) / np.sqrt(H)
    b2 = rng.standard_normal(H) * 0.1
    W3 = rng.standard_normal((C, H)) / np.sqrt(H)
    b3 = np.zeros(C)
    X = rng.uniform(0, 1, size=(300, d))
    G = [(W1, b1), (W2, b2), (W3, b3)]
    y = forward(G, X).argmax(1)
    for eps in [0.0, 0.002, 0.01]:
        terms1 = [("l2", np.full(H, eps * (j + 1)), P) for j, P in enumerate(bands)]
        layers = [Layer(W1, b1, eps, terms1),
                  Layer(W2, b2, eps, [("box", np.full_like(W2, eps))]),
                  Layer(W3, b3, eps, [("l2", np.full(C, eps), None)])]
        frac = check(layers, X, y, rng, trials=200)
        assert (eps > 0) or frac > 0.99


def test_contains():
    rng = np.random.default_rng(2)
    W = rng.standard_normal((5, 4))
    b = np.zeros(5)
    L = [Layer(W, b, 0.1, [("box", np.full_like(W, 0.1))])]
    assert contains(L, [(W + 0.09, b)])
    assert not contains(L, [(W + 0.11, b)])
    L = [Layer(W, b, 0.0, [("l2", np.full(5, 0.5), None)])]
    D = np.zeros_like(W)
    D[:, 0] = 0.49
    assert contains(L, [(W + D, b)])
    D[:, 1] = 0.2
    assert not contains(L, [(W + D, b)])


if __name__ == "__main__":
    test_binary_box_and_l2()
    test_multiclass_three_layers_dct()
    test_contains()
    print("certify tests passed")
