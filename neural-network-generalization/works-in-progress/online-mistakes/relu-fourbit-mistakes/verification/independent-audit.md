# Independent audit of the exact four-bit ReLU mistake theorem

Audit by the `positive_symmetry` research lane, 7 November 2026. The audited artifacts are in the sibling `search/` directory. No substantive mathematical flaw was found. This is an AI mathematical/code review, not formal verification or human peer review.

## Scope verified

For `g(x)=x_1x_2 ANDsign(x_3,x_4)`, at each fixed learner width `N>=16`, the exactly isotropic shallow ReLU posterior has a fixed full-cube query order with fifteen later error probabilities tending to one as `sigma->0`. The first prediction is exactly balanced. Consequently the limiting expected number of posterior-sampled mistakes is `15.5` out of sixteen queries.

This is a finite dimension-four theorem. It does not establish an exponential lower bound as dimension grows, nor a prior-scale threshold uniform in width.

## Mathematical checks

1. **Activation-cone completeness.** The exact rational Farkas witnesses and strict-margin witnesses cover all 222 ordinary cube-isometry/output-sign orbits of all 65,536 Boolean tables. A feasible orbit contributes only valid strict affine patterns. The union is exactly the 1,882 supplied patterns. Boundary atom directions belong to closures of those cones by generic perturbation.

2. **Cone-polar lower certificates.** With `A_D=diag(2D-1)X`, the sign convention is correct: for `q>=0` and `A_Dw>=0`, `h.w <= (h+A_D^Tq).w`. A norm bound on the latter residual proves the desired dual inequality. The target's algebraic checker correctly represents its coefficients as `sqrt(2)(a+b sqrt(15))`; the squared residual formula is `2 sum(a_i^2+15b_i^2)+4sqrt(15)sum a_i b_i`.

3. **All-class interval certificates.** The lower and upper witnesses are valid for the unrestricted continuous atom class. No optimizer output is used as a premise. The interval checker takes minima over every consistent truth table through the independently verified orbit map, so it does not omit non-threshold or asymmetric completions. The fifteen strict rational gaps suffice; uniqueness of the wrong minimizer is unnecessary.

4. **Integer arithmetic.** With the stored integral types and the `<10^10` coefficient bounds, intermediate NumPy matrix products are below `2^63`; norm squares use Python arbitrary-precision integers. Upper-bound square-root ceilings are exact. I suggested explicit positivity and integral-type assertions; the author added them. Actual data already satisfied those conditions.

5. **Width sixteen.** The atomic unit ball is compact and full dimensional in `R^16`: normalized single-vertex ReLU indicators span all coordinate vectors. A nonzero vector divided by its atomic norm lies in a supporting face of dimension at most fifteen. Carathéodory on that face therefore gives at most sixteen signed atoms. Independent positive-homogeneous balancing gives exactly `K_N=4V` for all `N>=16`. Thus the finite-width statement does not assume that the numerical SOCP's many-atom representation is itself available at width sixteen.

6. **Strict support and posterior.** Readout amplification identifies strict and weak sign-cell energy infima. Every cell is nonempty at width sixteen. Gaussian large-deviation upper/lower bounds, together with a finite number of cells and histories, turn every strict gap into posterior error probability tending to one. Global-margin normalization cancels in conditional ratios. Readout-sign symmetry gives exactly one-half error probability at the first query.

7. **Exact target and teacher.** The target weak-margin representation has cost `(5sqrt(30)+4sqrt(2))/6`; direct calculation of the two atom-family norms agrees. The effective-coordinate unit-bounded width-sixteen teacher outputs `g`. I also ran the stronger updated canonical-coordinate teacher check: with the specified output prefactor `1/2`, every canonical parameter is at most one and the output is exactly `21g/40`, hence has strict margin above one half. The statement should keep the chosen coordinate normalization explicit.

## Executed verification

I independently ran, without invoking an optimizer:

- `search/verify_d4_foundations.py`: all 3,764 signed algebraic cone inequalities and cone completeness passed;
- `search/verify_d4_interval_certificates.py`: all 222 interval classes, all 65,536 completions, and all fifteen strict gaps passed; minimum displayed gap `0.014941974359970482`;
- `search/certify_d4_primals.target_primal`: exact target output, effective-coordinate unit teacher, and the updated canonical-coordinate unit teacher all passed.

The checked canonical order is `[0,1,2,4,5,6,8,9,12,10,13,7,3,11,14,15]`. The exact isometry maps it to `[15,14,13,11,10,9,7,6,3,5,2,8,12,4,1,0]` for the displayed target `g`.
