"""p1-math-C check 1b: share of the total prior carried by the single 'tilted' program in e5 (p_plain=0.5).
Usage: python3 -I c1b_prior_share.py <path to code/>"""
import sys
import numpy as np
sys.path.insert(0, sys.argv[1])
import sfi_dsl as dsl
domain = dsl.all_strings(range(1, 9))
lens = np.array([len(s) for s in domain])
ec = dsl.enumerate_expressions(domain, depth_max=2)
conds = dsl.conditions(domain)
train_idx = np.array([i for i, s in enumerate(domain) if len(s) % 2 == 1])
ok = np.all(ec.values[:, train_idx] == lens[train_idx][None, :], axis=1)
p = 0.5
plain = p*ec.mass.sum()
ifm = (1-p)*sum(pc for _, pc, _ in conds)*ec.mass.sum()**2
for tilt in [1, 10]:
    extra = tilt*p*ec.mass[ok].sum()
    print(f"tilt x{tilt}: extra {extra:.4f}; plain {plain:.4f}; if-programs {ifm:.4f}; share of total prior {extra/(extra+plain+ifm):.3f}")
