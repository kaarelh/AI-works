"""The reported bounds, recomputed from stored counts with a charge for the
design choices made while developing the codecs on the same data.

Codecs, step grids and certificate parameters were developed by looking at
results on the same datasets (development runs on MNIST and on Boolean tasks
before the final grids).  Strictly, the code must be fixed before the sample
is drawn.  We cover up to 16 designs by a uniform prior over them: every
description pays DESIGN_BITS = 4 extra bits, and every disagreement term
estimated on inputs that the development runs also used is taken at
confidence delta2 / 16.  The effect on the numbers is negligible (4 bits
against descriptions of tens to tens of thousands of bits).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from cgb.bounds import occam_bound, cp_upper  # noqa: E402

DESIGN_BITS = 4.0
DESIGN_FACTOR = 16


def boolean_bound(r, delta=0.05):
    """Theorem 2 for a row of a Boolean grid."""
    m = r["m"]
    bits = r["bits"] + DESIGN_BITS
    if "dis_exact" in r:   # n <= 22: exact disagreement, all of delta to the Occam term
        return min(1.0, occam_bound(r["train_err_g"], m, bits, delta) + r["dis_exact"])
    n_cert = r.get("n_cert", 200_000)
    k = r["dis_count"] if "dis_count" in r else int(round(r["dis_hat"] * n_cert))
    return min(1.0, occam_bound(r["train_err_g"], m, bits, delta / 2)
               + cp_upper(k, n_cert, delta / 2 / DESIGN_FACTOR))


def boolean_any_D(r, delta=0.05):
    """Corollary 3 (exact equivalence on {-1,1}^n, any input distribution)."""
    k_f = int(round(r["train_err_f"] * r["m"]))
    return occam_bound(k_f, r["m"], r["bits_any_D"] + DESIGN_BITS, delta)


def t2_bound(r, K, m=60000, delta=0.05):
    occ = occam_bound(int(round(r["train_err_g"] * m)), m, r["bits"] + DESIGN_BITS, delta / 2)
    return min(1.0, occ + cp_upper(r["dis_count"], r["n_unlabeled"], delta / (2 * K * DESIGN_FACTOR)))


def t1_bound(r, m=60000, delta=0.05):
    return occam_bound(int(round(r["train_err_g"] * m)), m, r["bits"] + DESIGN_BITS, delta)


def t3_bound(r):
    """Theorem 5 + Lemma 7 for a row of mnist_t3.py (bits) or boolean_t3.py (t3_bits)."""
    m = r.get("m", 60000)
    bits = r["bits"] if "bits" in r else r["t3_bits"]
    kfail = int(round((1 - r["cert_frac"]) * m))
    return min(1.0, occam_bound(kfail, m, bits + DESIGN_BITS, r.get("delta", 0.04))
               + r["eta"] / r.get("delta_prime", 0.01))
