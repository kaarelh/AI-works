Reviewer p1-math-C scratch (Paper 1: ood, comp, nn, steeper, related; appendices F, G, H, I).
All scripts are deterministic or seeded; run with python3 -I from this folder.
  c1_pointwise_bound.py   combinatorial step of the pointwise bound on e(x*) (issue C-01)        -> c1_pointwise_bound.out.txt
  c2_comp_constants.py    constants of comp.tex/app-comp.tex/ood.tex (C-03, C-23; checks)          -> c2_comp_constants.out.txt
  c3_kernels_ladder.py    Walsh eigenvalues, KRR anti-correlation, ladder for formulas/circuits    -> c3_kernels_ladder.out.txt
  mirror/                 scratch copy of examples check e5 and code/sfi_dsl.py; output byte-identical to the saved one
  make_issues.py          builds ../../p1/issues-p1-math-C.json and ../../p1/review-p1-math-C.md (head: review_head.md)
  patch_merge.py          one-off merge of the verified items of the parallel list (make_issues_p1_math_C.py) into make_issues.py
  make_issues.before_merge.py  generator state before that merge
Files not written by this reviewer instance (parallel instance of p1-math-C): c1_e5_tilt.py, c1b_prior_share.py,
  c2_comp_nn_checks.py, c3_ladder_formulas.py, c4_pointwise_e_check.py, make_issues_p1_math_C.py (and their outputs).
