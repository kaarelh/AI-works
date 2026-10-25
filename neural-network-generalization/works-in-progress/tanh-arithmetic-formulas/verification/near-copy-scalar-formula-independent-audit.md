# Independent audit of the near-copy scalar-formula compiler

25 October 2026. Audited `near-copy-scalar-formula-compiler.md`, prioritizing Sections 1--5 and also checking the finite-bit accounting in Section 6. The main theorem's bounds are supported. Two implementation/wording clarifications are needed; both preserve the claimed exponential budget and avoid vector/DAG sharing.

## Checks that pass

* Row sampling with `p_ij=K_ij^2/b_i` gives `E Z_i^2=b_i sum_(j in support_i) V_j(x)`. Summing rows yields at most `||K||_HS^2 V`. This uses a pointwise trace bound, not an unjustified sum of coordinatewise suprema over inputs.
* The copied base child and perturbation estimator can be independent. Their cross term is exactly `2<J mu,K mu>` and is at most `2 kappa V`. The rare branch therefore has trace multiplier `1+3 kappa` and expected scalar cost `1+O(kappa)`.
* The residual Poisson identity remains valid with a common deterministic lambda chosen using the trace budget V. Each coordinate still has `v_i<=min(omega^2 s^2 V_i,1)`, yielding the sixth-order local moment bound and then `sum_i E R_i^2<=C s^4 V^3`.
* Independent base and residual calls make the activation cross term nonpositive after summing coordinates. The rare activation branch has moment/cost increments O(s^2) while V stays in a fixed interval.
* Mean-norm assumptions after both linear and activation steps justify averaging resets. Small resets are charged to accumulated kappa+s^2; large steps have polynomial cost whose logarithm is O(kappa+s^2). No fixed operation overhead is charged on absent branches or coordinate copies.
* Final readout sampling gives exactly `E Y^2=||v||^2 sum_(i:v_i!=0) E Y_i^2`, with no dimension factor. Independent averaging, group majority, the all-input union bound, and a size Markov bound give the stated deterministic existence result.
* Section 6's rounding has polynomial modulus when S+Q=O(log R), depth/dimensions are polynomial, and input arithmetic formulas have the stated bit bounds. Tiny scales can be deleted; matrix/scales/readout can be rounded on sufficiently fine inverse-polynomial meshes. The conclusion remains conditional on the cited arithmetic-formula evaluation and PNC1 composition facts, and is explicitly not a Boolean NC1 or general critical-posterior theorem.

## Required clarification 1: identical scalar occurrences in the residual

In `R=Im prod_a(1+i c X_a)-c sum_a X_a`, the product and linear subtraction must use the **same realized X_a**. Replacing occurrences in the linear subtraction by independent reruns destroys the sixth-order second-moment cancellation. Thus a blanket assertion that every recursive occurrence is independently rerun is too strong.

A genuine scalar arithmetic formula can implement the correct law without shared computation: sample each fresh child expression once, then duplicate that expression syntactically wherever needed, charging its full size at each occurrence. Distinct Poisson children and the independently added base child remain independent draws. There are no shared DAG nodes. The duplicate linear subtraction costs at most another O(K T), harmless on the rare residual branch.

## Required clarification 2: real arithmetic size of a complex product

If the expected-size claim counts real arithmetic formulas, an imaginary part of a product of K complex factors should not be charged O(K) real formula size. A balanced real/imaginary expansion gives O((K+1)^2) child occurrences, with all duplicates charged. This suffices locally, without assuming a higher moment of the entire recursively generated formula size.

For lambda=1+omega^2 a, `E[K^2|omega]=lambda^2+lambda`. Both frequency laws have all fixed moments. Hence `E(K+1)^2=O(1)` for a=s^2V<=1, and it is O((1+a)^2) in general. The small activation cost remains `T(1+C s^2V)`. The large activation cost should be stated as polynomial in 1+s^2V rather than necessarily linear; its logarithm is still O(s^2) above the fixed threshold. This leaves every main conclusion unchanged, including linear dependence on the initial formula-size bound T0.

After these explicit clarifications, the claimed scalar-formula theorem passes this independent audit. The near-copy restriction is essential to this proof: an arbitrary dense isometry is not a cheap coordinate copy, and rotating its basis generally destroys coordinatewise tanh.
