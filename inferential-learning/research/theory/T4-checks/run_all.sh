#!/bin/sh
# Sanity checks for T4-informal-math-latent-formalization.md (total runtime: a few minutes)
set -e
cd "$(dirname "$0")"
python3 bag_vs_object_game.py      # Thm 4.3/4.4: exact minimax, objects vs bags (single culprit, k culprits, random)
python3 bag_vs_elasticity.py       # Thm 4.4(a): M_bag <= el*, and the refuted "M_bag = el*" conjecture
python3 bag_product.py             # Thm 4.5 / Prop 4.6: bag-size dependence on product classes
python3 bag_size_conjecture.py     # Conjecture M_bag^(r) <= r * M_obj
python3 comprehension_toy.py       # Sec 5: finite-model sanity checks + Frege-Russell-Zermelo dynamics
python3 robust_core_and_mdl.py     # Prop 6.4 (sorites, union bound), Sec 7 (steeper simplicity penalty)
python3 verification_checks.py     # Added after verification: Thm 3.4(d) revised (V1, ~minutes), Thm 5.2(iv) sub-supports (V2),
                                   # Thm 4.4 remark figures + antichain (V3), M_obj = Ldim (V4), Prop 4.6' (V5)
