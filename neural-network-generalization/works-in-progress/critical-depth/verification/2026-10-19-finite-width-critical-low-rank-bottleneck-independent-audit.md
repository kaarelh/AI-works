# Independent audit of the low-rank teacher bottleneck

Auditor: `/root/depth_continuous_lower`, 19 October 2026.
Reviewed `critical-low-rank-bottleneck.md`, SHA256 `eac4960f33198d3b3f2805d02637f6773cc5e964bbc4afc9016987ef2a7c43a7`.

**Verdict: the statement and proof pass independent reconstruction.**

1. A relevant coordinate has a bichromatic edge. The output gap and tanh Lipschitz bound imply that its first-layer column, multiplied by the remaining Frobenius product, has norm at least one. Squaring and summing gives at most P squared relevant coordinates.
2. Freezing irrelevant signs preserves the Boolean function. The expected squared norm of the new bias column is its original squared norm plus the squared norms of the removed columns; therefore one freezing does not increase the first-layer Frobenius norm. Its range remains within the original range, so rank does not increase.
3. Orthogonal factorization of the reduced first layer yields a projection to at most r coordinates and a scalar continuation of Lipschitz constant at most P. Opposite labels are therefore separated by at least 2/P in projected space, regardless of original teacher depth.
4. The rounded projection error, grid radius, and box size satisfy the strict separation inequality with ample slack. A negative input cannot enter a selected positive box. The number of possible centers is at most (C P sqrt(rm))^r.
5. Projection values and centers lie on compatible dyadic lattices. Moving each box boundary by half the fine lattice spacing produces exact Boolean inequalities of normalized margin at least one and polynomial coefficients. AND of the inequalities and OR of the boxes yield a fixed-depth threshold circuit with the asserted resources.
6. Applying the existing exact threshold-feature repair and steering theorem gives the rate with logarithmic resource term O(log(d+L)+r log(P+r)). The established rate-sublevel theorem yields the displayed sample dependence and preserves its qualitative sufficiently-large-width qualification.
7. The approximate rank case has uniform output error at most1/8, and readout rescaling by8/7 restores margin without increasing the product by more than that factor. No approximation of the physical learner or prior support is asserted.

This audit does not establish a general theorem from the Frobenius product alone. The fixed-rank conclusion is a target-representation condition, and the note correctly distinguishes it from a robustness restriction on the prior.
