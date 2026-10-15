"""p1-math-C check 1: what the 'tilted' rows of tab:ood:grammar actually tilt by.

Reruns the exact grammar mixture of research/tracks/examples/checks/e5_dsl_odd_lengths.py
(read-only import of code/sfi_dsl.py) and compares
  (A) the extra program with mass = tilt * (prior mass of the training-consistent plain programs)
      [what e5 actually does: extra_programs=[(bad, tilt * 0.5 * m_plain_ok)]]
  (B) the extra program with mass = tilt * (prior mass of ALL plain programs)
      [what app-ood.tex says: "prior mass equal to (or ten times) that of all plain programs"].
Deterministic.  Usage: python3 -I c1_e5_tilt.py <path to solomonoff-function-induction/code>
"""
import sys, math
import numpy as np
sys.path.insert(0, sys.argv[1])
import sfi_dsl as dsl

domain = dsl.all_strings(range(1, 9))
lens = np.array([len(s) for s in domain])
ec = dsl.enumerate_expressions(domain, depth_max=2)
conds = dsl.conditions(domain)
train_idx = np.array([i for i, s in enumerate(domain) if len(s) % 2 == 1])
test_idx = np.array([i for i, s in enumerate(domain) if len(s) % 2 == 0])
train_y = lens[train_idx]
ok = np.all(ec.values[:, train_idx] == train_y[None, :], axis=1)
m_plain_ok = ec.mass[ok].sum()
m_plain_all = ec.mass.sum()
p_plain = 0.5
print(f"expression classes: {len(ec.mass)}; total plain-expression mass (before p_plain) {m_plain_all:.6f}")
print(f"training-consistent plain mass (before p_plain) {m_plain_ok:.6f}  (class 'len' only)")
print(f"prior mass of ALL plain programs at p_plain=0.5: {p_plain*m_plain_all:.6f}")
print(f"prior mass of consistent plain programs at p_plain=0.5: {p_plain*m_plain_ok:.6f}")
print(f"ratio all/consistent = {m_plain_all/m_plain_ok:.3f}")
bad = np.where(lens % 2 == 0, 0, lens)

def summ(preds):
    res = {}
    for L in [2, 4, 6, 8]:
        js = [j for j, x in enumerate(test_idx) if len(domain[x]) == L]
        res[L] = float(np.mean([preds[j].get(L, 0.0) for j in js]))
    mn = min(min(preds[j].get(len(domain[x]), 0.0) for j, x in enumerate(test_idx)) for _ in [0])
    return res, mn

for label, base in [("(A) e5 as coded: tilt x consistent-plain mass", p_plain*m_plain_ok),
                    ("(B) app-ood wording: tilt x ALL-plain mass", p_plain*m_plain_all)]:
    for tilt in [1.0, 10.0]:
        Z, preds = dsl.posterior_predictive(ec, conds, train_idx, train_y, test_idx, p_plain=p_plain,
                                            extra_programs=[(bad, tilt*base)])
        r, mn = summ(preds)
        print(f"{label}, tilt={tilt:>4}: extra mass {tilt*base:.4f}; P(correct) L=2..8 = "
              + " ".join(f"{r[L]:.4f}" for L in [2, 4, 6, 8]) + f"; min {mn:.4f}")
# natural weight of the bad program inside the grammar (as e5 computes it)
pc_even_len = (1/5)*(1/6)
m_len = ec.mass[[i for i in range(len(ec.mass)) if np.array_equal(ec.values[i], lens)][0]]
m_zero = ec.mass[[i for i in range(len(ec.mass)) if np.all(ec.values[i] == 0)][0]]
nat = (1-p_plain)*pc_even_len*m_zero*m_len
print(f"natural grammar mass of 'if even(len) then 0 else len': {nat:.3e}; tilt x10 (A) inflates it by {10*p_plain*m_plain_ok/nat:.0f}x")
