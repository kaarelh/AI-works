"""Compressing a network trained on a Boolean task, and the resulting bounds.

Setting: inputs uniform on {-1,1}^n (the input distribution is known, labels
are not).  For a trained network f and a compressed network g:

    err(f) <= err(g) + Pr_x[f(x) != g(x)]
           <= Occam(g; training errors of g, L(g) bits, delta1)
              + CP-upper(disagreements on N fresh uniform inputs, delta2)

The fresh inputs used for the disagreement term are drawn after g is fixed;
the pools used to build and select g are drawn independently of both the
training set and the final disagreement sample.  For n <= 22 the
disagreement is computed exactly by enumerating {-1,1}^n.
"""

import copy
import math

import numpy as np
import torch

from . import coding
from .bounds import occam_bound, cp_upper, LN2
from .codec import QuantMLP, QATNet, quantize_mlp, default_steps, distill
from .data import uniform_cube, all_inputs
from .models import MLP, np_predict

FAMILY_BITS = 2.0  # which codec family: truth table / quantized MLP (/ two spare codes)


class TruthTable:
    """g(x) = T[x_J] for a k-subset J and a table T in {0,1}^(2^k)."""

    def __init__(self, n, coords, table):
        self.n = n
        self.coords = np.asarray(coords, dtype=np.int64)
        self.table = np.asarray(table, dtype=np.int64)

    def predict(self, X):
        Z = X[:, self.coords] > 0
        idx = (Z.astype(np.int64) << np.arange(len(self.coords))[None, :]).sum(axis=1)
        return self.table[idx]

    def description(self):
        d = coding.Description()
        d.add("family", FAMILY_BITS)
        d.add("input subset", coding.subset(self.n, len(self.coords)))
        d.add("table", coding.kt_counts(np.bincount(self.table, minlength=2)))
        return d

    @property
    def bits(self):
        return self.description().bits


class StudentMLP:
    """Wrapper adding the family tag to a QuantMLP description."""

    def __init__(self, q):
        self.q = q
        self.n = q.n
        self.coords = q.coords

    def predict(self, X):
        return self.q.predict(X)

    def description(self):
        d = self.q.description()
        d.add("family", FAMILY_BITS)
        return d

    @property
    def bits(self):
        return self.description().bits


def influences(predict, n, rng, N=2000):
    X = uniform_cube(n, N, rng)
    base = predict(X)
    inf = np.zeros(n)
    for j in range(n):
        Xf = X.copy()
        Xf[:, j] *= -1
        inf[j] = np.mean(predict(Xf) != base)
    return inf


def truth_table_from_pool(n, coords, Xpool, ypool):
    k = len(coords)
    Z = Xpool[:, coords] > 0
    idx = (Z.astype(np.int64) << np.arange(k)[None, :]).sum(axis=1)
    ones = np.bincount(idx, weights=ypool, minlength=2 ** k)
    tot = np.bincount(idx, minlength=2 ** k)
    table = (ones * 2 > tot).astype(np.int64)
    return TruthTable(n, coords, table)


def estimated_bound(g, Xtr, ytr, Xsel, ysel, delta):
    """Occam term from training data + plug-in disagreement on the selection
    pool (used only to choose g; the final bound uses a fresh sample)."""
    k_err = int(np.sum(g.predict(Xtr) != ytr))
    occ = occam_bound(k_err, len(ytr), g.bits, delta / 2)
    dis = float(np.mean(g.predict(Xsel) != ysel))
    return occ + dis, occ, dis, k_err


def compress(f_predict, n, Xtr, ytr, *, rng, delta=0.05, pool=100_000, sel=30_000,
             widths_h=(0, 1, 2, 4, 8, 16), rels=(0.5, 0.25, 0.125),
             kmax_table=14, distill_steps=2000, qat_steps=500, log=print, seed=0):
    """Search over compressed descriptions of f; returns the best candidate and
    a list of all candidates tried (with their selection-pool estimates)."""
    Xpool = uniform_cube(n, pool, rng)
    ypool = f_predict(Xpool)
    Xsel = uniform_cube(n, sel, rng)
    ysel = f_predict(Xsel)
    inf = influences(f_predict, n, rng)
    order = np.argsort(-inf)
    ks = set()
    for tau in (0.3, 0.2, 0.1, 0.05, 0.02, 0.01, 0.005):
        k = int(np.sum(inf > tau))
        if k >= 1:
            ks.add(k)
    ks.add(n)
    ks = sorted(ks)
    cands = []

    def consider(g, label):
        est, occ, dis, k_err = estimated_bound(g, Xtr, ytr, Xsel, ysel, delta)
        cands.append({"label": label, "bits": g.bits, "est": est, "occ": occ, "sel_dis": dis,
                      "train_err_g": k_err, "g": g})
        return est, dis

    for k in ks:
        J = np.sort(order[:k])
        if k <= kmax_table:
            consider(truth_table_from_pool(n, J, Xpool, ypool), f"table k={k}")
        Xs = Xpool[:, J].astype(np.float32)
        for h in widths_h:
            widths = [k, 1] if h == 0 else [k, h, 1]
            torch.manual_seed(seed)
            st = MLP(widths, seed=seed + 17 * h + k)
            distill(st, Xs, ypool, steps=distill_steps, seed=seed + h)
            fl_pred = (st(torch.as_tensor(Xsel[:, J], dtype=torch.float32))[:, 0] > 0).long().numpy()
            fl_dis = float(np.mean(fl_pred != ysel))
            best_here = None
            for rel in rels:
                s2 = copy.deepcopy(st)
                exps = default_steps(s2, rel)
                distill(s2, Xs, ypool, steps=qat_steps, lr=1e-3, seed=seed + 1000 + h, qat_steps_exp=exps)
                q = quantize_mlp(s2, n, J, exps)
                est, dis = consider(StudentMLP(q), f"mlp k={k} widths={widths} rel={rel}")
                if best_here is None or est < best_here:
                    best_here = est
            log(f"    k={k:3d} h={h:3d} float dis={fl_dis:.4f} best est={best_here:.4f}")
            if fl_dis < 1e-4:
                break
    best = min(cands, key=lambda c: c["est"])
    return best, cands, inf


def final_bound(f_predict, g, n, Xtr, ytr, *, rng, delta=0.05, n_cert=200_000, exact_max_n=22,
                f_all=None):
    """Certified bound on err(f) and on err(g).  f_all: f's predictions on
    all_inputs(n), if already computed."""
    m = len(ytr)
    k_err = int(np.sum(g.predict(Xtr) != ytr))
    out = {"bits": g.bits, "train_err_g": k_err, "code": g.description().summary()}
    if n <= exact_max_n:
        X = all_inputs(n)
        fa = f_predict(X) if f_all is None else f_all
        dis = float(np.mean(fa != g.predict(X)))
        out["dis_exact"] = dis
        out["dis_upper"] = dis
        out["occam_g"] = occam_bound(k_err, m, g.bits, delta)
        out["bound_f"] = min(1.0, out["occam_g"] + dis)
        out["n_exceptions"] = int(round(dis * 2 ** n))
    else:
        dis_k = 0
        for s in range(0, n_cert, 200_000):
            Xc = uniform_cube(n, min(200_000, n_cert - s), rng)
            dis_k += int(np.sum(f_predict(Xc) != g.predict(Xc)))
        out["dis_hat"] = dis_k / n_cert
        out["dis_upper"] = cp_upper(dis_k, n_cert, delta / 2)
        out["occam_g"] = occam_bound(k_err, m, g.bits, delta / 2)
        out["bound_f"] = min(1.0, out["occam_g"] + out["dis_upper"])
    return out


def distribution_free_bound(f_predict, g, n, Xtr, ytr, delta=0.05, f_all=None):
    """For n <= 22: patch g on the (enumerated) set E where f != g, so the
    patched g' equals f on all of {-1,1}^n; then the Occam bound for g' is a
    bound on err_D(f) for EVERY input distribution D (training data from D)."""
    X = all_inputs(n)
    fa = f_predict(X) if f_all is None else f_all
    E = np.flatnonzero(fa != g.predict(X))
    extra = 1.0 + coding.subset(2 ** n, len(E))  # flag + exception set
    bits = g.bits + extra
    k_err = int(np.sum(f_predict(Xtr) != ytr))  # g' = f everywhere
    return {"n_exceptions": int(len(E)), "bits_any_D": bits,
            "bound_f_any_D": occam_bound(k_err, len(ytr), bits, delta)}
