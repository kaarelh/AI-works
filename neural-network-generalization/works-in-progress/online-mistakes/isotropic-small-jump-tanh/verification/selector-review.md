# Independent selector and calibration review

Reviewed on 6 November 2026 by a separate research agent (`wide_tanh`). This is an independent mathematical audit, not a Lean formalization.

Reviewed source: `source/selector.tex`, SHA256 `950940054310fdd20ed708be74571280af0a363171a1ef29998d466f6b774638`.

The compressed selector construction checks. In particular:

- The first `r` nonzero binary vectors span the prescribed seed space, so the seed map is injective. Uniform seeds give unbiased, pairwise independent free bits and include the all-minus assignment. The support-size bound, including `r=0`, is correct.
- Every prescribed group has the stated label and affine score. Pairing labeled antipodes cancels the appended constant mean and all constant-coordinate covariance terms without changing the homogeneous signed mean.
- The positive KKT weights sum to `Q_t`, their signed mean is the proposed affine coefficient vector, and every support point is active. All earlier query groups remain feasible. Strict convexity proves unique affine minimality, including the appended constant coordinate.
- I recomputed each entry of the covariance block. Pairwise independence suffices for every moment used; no full independence remains implicit. The Gershgorin estimate, the two Schur-complement correction bounds, and the final numerical inequality hold for every `k >= 8`.
- The initial and per-stage support counts are valid, groups are disjoint, their antipodes occupy the other `s` slice, and the designated query belongs to its group. The constructed sequence can therefore be completed to an input permutation without repetitions.
- Before the first query of each stage, the history is exactly the preceding completed history. The final paragraph correctly invokes the separate unique-full-function theorem to control competitors before the query's antipode is revealed; it does not incorrectly assume the new complete history is already available.
- The odd target has a Boolean circuit with `Theta(k)` bounded-fan-in gates. The proposed width `ceil(1/epsilon)` teacher has all weights bounded by one and signed output strictly greater than one on every input.

This review verifies the selector section and its interface with the stated unique-function theorem. It does not independently certify the separate activation-profile or posterior-comparison proofs.

Final wording clarification checked: carry groups are distinguished by their highest differing bit, in addition to the selector-face and difference distinctions used for other groups. The source hash above includes this clarification.

## Whitespace-only publication update

A final blank line at the end of `source/posterior.tex` was removed. Its SHA256 is now `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460`. No theorem or proof text changed; the selector source is unchanged. An isolated rebuild was compared with the retained publication PDF and has identical extracted text.
