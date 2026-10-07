"""T6 check 7 (exploratory, informs an open problem): for the k-exclusive credence P_k, what is the smallest
threshold m (called "multiplicity" before verification) of a valid counting sequent it violates?  Search integer books lam in {-B..B}^F."""
import itertools
import numpy as np

def search(k, B):
    atoms = list(range(k)); pairs = list(itertools.combinations(atoms, 2))
    worlds = np.array(list(itertools.product([0, 1], repeat=k)))
    cols = [worlds[:, i] for i in atoms] + [worlds[:, i] * worlds[:, j] for (i, j) in pairs]
    T = np.stack(cols, axis=1)                    # worlds x F
    P = np.array([1.0 / (k - 1)] * k + [0.0] * len(pairs))
    F = T.shape[1]
    best = None
    rng = range(-B, B + 1)
    for lam in itertools.product(rng, repeat=F):
        lam = np.array(lam)
        c = (T @ lam).min()
        if lam @ P < c - 1e-9:
            m = c + (-lam[lam < 0]).sum()
            if best is None or m < best[0]:
                best = (int(m), lam.tolist(), int(c))
    return best

for k, B in [(3, 2), (4, 1), (4, 2)]:
    print("k=%d, |lam_i|<=%d: smallest violated threshold m, book, c =" % (k, B), search(k, B))
