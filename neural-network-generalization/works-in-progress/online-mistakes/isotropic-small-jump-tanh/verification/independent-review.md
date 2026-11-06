# Independent complete-manuscript review

Reviewed on 6 November 2026 by a separate research agent (`wide_tanh`), independently of the principal proof and manuscript author. The complete integrated source and its theorem/proof correspondence were checked. This is an informal AI mathematical audit, not a Lean formalization.

## Mathematical checks

1. **Model and quantifiers.** The Gaussian prior is unchanged across the first-layer coordinates, including the constant input, and has the stated canonical readout scaling. The activation is a fixed bounded but discontinuous function `tanh + epsilon sign`. The strong-prior limit is at each fixed width; the direct regimes are every fixed exponent above one and every sufficiently large width, or a sufficiently small fixed prefactor uniformly at every width and every exponent at least one. No conclusion for the zero-jump activation is claimed.
2. **Exact profile.** I checked the active KKT/covariance identities, the decomposition into the affine direction and its orthogonal complement, the second-order tanh estimate, square completion, both epsilon ranges in the numerical bounds, and strict positivity of the orthogonal penalty. The equality conditions force every neuron to be the stated scalar atom up to simultaneous sign reversal. This proves unique output function at every finite width and also for arbitrary finite-energy neuron measures.
3. **Uniform energy gap.** The relaxed jump-coordinate space is closed. Energy sublevels of probability measures are tight, output means pass to limits by the second-moment bound and truncation, and energy is lower semicontinuous. The attained correct-query infimum is strictly larger than the previous minimum because equality fixes all queried jump values. This controls an incomplete stage without assuming a covariance certificate for the newly extended history.
4. **Selector.** The separate selector review checks the compressed pairwise-independent supports, all KKT weights, the full covariance and Schur-complement bounds, disjointness, stage counts and order, and the bounded teacher. The integrated proof uses exactly that construction and does not assume the posterior function is odd.
5. **Actual posterior.** The product-box denominator has strict global margins and stays away from all activation jumps. The Gaussian chi-square tail comparison cancels the logarithmic scale terms exactly. The resulting width-uniform constants imply all stated cold, direct-width, and small-prefactor probability conclusions, including simultaneous sampled mistakes by a union bound.
6. **IID compression.** A bounded monotone neuron has the stated level-set representation by strict affine threshold tables, including possible constant tables and jumps. The coefficient normalization, Hoeffding bound, all-input union bound, and threshold-class cardinality yield the displayed compression count. A cheap full-target affine witness gives a posterior energy cutoff uniformly over all histories; the consistency union bound and posterior-error Markov argument establish the stated greater-than-two-thirds confidence guarantee.
7. **Scope and presentation.** The final introduction describes a lower bound for an activation uniformly close to tanh, without claiming an unproved behavioral separation from tanh itself. The dimension restriction, fixed nonzero jump, unspecified large-width threshold, and different IID versus ordered-input conclusions are explicit.

No mathematical correction remains outstanding.

## Reviewed snapshot

- `source/paper.tex`: SHA256 `85eee6fbf46bb436ecb7e4fa36e93fe0224154aa6677aee55ee64b9f78c8152c`.
- `source/dual.tex`: SHA256 `0fda467e8b96367423c4f416917c92c9d49da5f69800ba26aaedda7b235a44f9`.
- `source/selector.tex`: SHA256 `950940054310fdd20ed708be74571280af0a363171a1ef29998d466f6b774638`.
- `source/posterior.tex`: SHA256 `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460`.
- `source/compression.tex`: SHA256 `ed85129384d15c5c4e85f713261cef8a4dee54ec0448a850a09330170ef7b79d`.
- `paper.pdf`: SHA256 `a4223ce606586306d044f19629368fcdab83e6e7cc1c30a11a2eaa0d22cbe15d`.

## Whitespace-only publication update

A final blank line at the end of `source/posterior.tex` was removed. Its SHA256 is now `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460`. No theorem or proof text changed; the selector source is unchanged. An isolated rebuild was compared with the retained publication PDF and has identical extracted text.
