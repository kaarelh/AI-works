"""Standard classification tasks for comparing DFG-style learners with MLPs.

Sources (cached under DATA_DIR):
  mnist, fashion_mnist  - Keras copies on storage.googleapis.com (standard 60000/10000 split; pixels scaled to [0, 1])
  PMLB datasets         - github.com/EpistasisLab/pmlb (tsv.gz + metadata.yaml giving each feature's type)

load(name) -> dict(X (N, d) float64, y (N,) int classes 0..C-1, types [d] in {'binary','categorical','continuous'},
                   C, split: 'standard' (mnist/fashion: given test set) or 'random')
splits(name, seed) -> train pool indices (permuted by seed) and the fixed test indices.
"""
import os, gzip, io, urllib.request, numpy as np

DATA_DIR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/data"
GCS = "https://storage.googleapis.com/tensorflow/tf-keras-datasets/"
PMLB = "https://media.githubusercontent.com/media/EpistasisLab/pmlb/master/datasets/{0}/{0}.tsv.gz"   # git-lfs media
PMLB_META = "https://raw.githubusercontent.com/EpistasisLab/pmlb/master/datasets/{0}/metadata.yaml"

DEV = ["optdigits", "magic", "kr_vs_kp", "satimage", "spambase"]
HELDOUT = ["mnist", "fashion_mnist", "adult", "letter", "pendigits", "connect_4", "dna", "nursery", "ring", "twonorm",
           "phoneme", "waveform_40", "mushroom"]
# Fresh held-out datasets for Part 8 (the hybrid learner), fixed before any hybrid was designed; never used before.
HELDOUT2 = ["texture", "churn", "wine_quality_white", "page_blocks", "clean2", "led24", "ann_thyroid", "banana", "krkopt",
            "sleep"]
NS = [100, 300, 1000, 3000, 10000, 30000, 60000]
TEST_MAX = 10000


def _get(url, path):
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with urllib.request.urlopen(url, timeout=120) as r:
            open(path, "wb").write(r.read())
    return path


def _idx(path):
    b = gzip.open(path).read()
    nd = b[3]; dims = [int.from_bytes(b[4 + 4 * i: 8 + 4 * i], "big") for i in range(nd)]
    return np.frombuffer(b, dtype=np.uint8, offset=4 + 4 * nd).reshape(dims)


def _meta_types(name, cols):
    txt = open(_get(PMLB_META.format(name), os.path.join(DATA_DIR, name, "metadata.yaml"))).read()
    types, cur = {}, None
    for line in txt.splitlines():
        s = line.strip()
        if s.startswith("- name:"):
            cur = s.split(":", 1)[1].strip().strip("'\"")
        elif s.startswith("type:") and cur is not None:
            types[cur] = s.split(":", 1)[1].strip().strip("'\""); cur = None
    return [types.get(c, "continuous") for c in cols]


def load(name):
    cache = os.path.join(DATA_DIR, name, "arrays.npz")
    if os.path.exists(cache):
        z = np.load(cache, allow_pickle=True)
        return dict(X=z["X"], y=z["y"], types=list(z["types"]), C=int(z["C"]), split=str(z["split"]), n_test=int(z["n_test"]))
    if name in ("mnist", "fashion_mnist"):
        if name == "mnist":
            z = np.load(_get(GCS + "mnist.npz", os.path.join(DATA_DIR, name, "mnist.npz")))
            Xtr, ytr, Xte, yte = z["x_train"], z["y_train"], z["x_test"], z["y_test"]
        else:
            f = lambda s: _idx(_get(GCS + s, os.path.join(DATA_DIR, name, s)))
            Xtr, ytr = f("train-images-idx3-ubyte.gz"), f("train-labels-idx1-ubyte.gz")
            Xte, yte = f("t10k-images-idx3-ubyte.gz"), f("t10k-labels-idx1-ubyte.gz")
        X = np.concatenate([Xtr.reshape(len(Xtr), -1), Xte.reshape(len(Xte), -1)]).astype(np.float64) / 255.0
        y = np.concatenate([ytr, yte]).astype(np.int64)
        out = dict(X=X, y=y, types=["continuous"] * X.shape[1], C=10, split="standard", n_test=len(yte))
    else:
        raw = gzip.open(_get(PMLB.format(name), os.path.join(DATA_DIR, name, name + ".tsv.gz"))).read().decode()
        lines = [l.rstrip("\r") for l in raw.strip().split("\n")]; cols = lines[0].split("\t")
        A = np.array([[float(v) for v in l.split("\t")] for l in lines[1:]])
        ti = cols.index("target"); feats = [c for c in cols if c != "target"]
        X = np.delete(A, ti, axis=1); t = A[:, ti]
        cls, y = np.unique(t, return_inverse=True)
        types = _meta_types(name, feats)
        for j, ty in enumerate(types):                     # a 'categorical' column with 2 values is binary
            if ty == "categorical" and len(np.unique(X[:, j])) <= 2:
                types[j] = "binary"
        out = dict(X=X, y=y.astype(np.int64), types=types, C=len(cls), split="random",
                   n_test=min(TEST_MAX, int(round(0.25 * len(y)))))
    np.savez_compressed(cache, X=out["X"], y=out["y"], types=np.array(out["types"]), C=out["C"], split=out["split"],
                        n_test=out["n_test"])
    return out


def splits(D, seed):
    """Fixed test set (seed-independent); train pool permuted by seed (training sets are nested prefixes)."""
    N = len(D["y"])
    if D["split"] == "standard":
        te = np.arange(N - D["n_test"], N); pool = np.arange(N - D["n_test"])
    else:
        perm = np.random.default_rng(12345).permutation(N)
        te, pool = np.sort(perm[: D["n_test"]]), perm[D["n_test"]:]
    pool = np.random.default_rng([seed, 999]).permutation(pool)
    return pool, te


def grid(D):
    pool = len(D["y"]) - D["n_test"]
    g = [n for n in NS if n <= pool]
    if pool > 1.2 * g[-1]:
        g.append(pool)
    return g


if __name__ == "__main__":
    import sys
    for nm in (sys.argv[1:] or DEV + HELDOUT):
        D = load(nm); t = D["types"]
        print(f"{nm:14s} N={len(D['y']):6d} d={D['X'].shape[1]:4d} C={D['C']:2d} bin={t.count('binary'):3d} cat={t.count('categorical'):3d} "
              f"cont={t.count('continuous'):3d} test={D['n_test']} grid={grid(D)} class-freq-max={np.bincount(D['y']).max() / len(D['y']):.2f}", flush=True)
