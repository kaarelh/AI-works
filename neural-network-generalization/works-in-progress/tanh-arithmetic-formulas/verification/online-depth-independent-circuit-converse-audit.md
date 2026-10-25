# Independent audit: a distribution-universal online converse

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS** for `online-depth-independent-circuit-converse.md`, SHA256 `e11ad26fcda5aa38c8c20495174aa906229872c26647dd3c5db3957ef4f61524`.

Fix `M>=0`, set `n=ceil(16(M+1))`, and choose a learner satisfying the imported posterior-ceiling width/depth/scale hypotheses at this n, before the input distribution is selected. The distribution-universal expected total confidence-mistake bound implies that, for each input law D, one of the first n prediction times and one realized history have confidence-failure D-mass at most `M/n<1/16`. The sample length may vary with D; all these histories nevertheless use the same low-product representation class furnished by the uniform ceiling at n. Thus the existing two-majority/minimax proof applies. No padding of the history and no monotonicity of risk under additional conditioning is used.

For Gibbs mistakes, conditioning the chosen posterior on its low-product event of mass at least `1-beta`, with `beta<=1/6`, increases risk by at most `1/(1-beta)`. Its risk is therefore less than `1/8`, so one low-product voter has that D-risk. Finite minimax and an `O(d)`-voter majority give exact representation; the established PNC1 composition theorem absorbs this majority. Independence of fresh posterior draws suffices for the online-risk interpretation; no higher moment of the mistake count is needed.

The cold-limit argument uses only posteriors for the finite set of histories of lengths at most n. It does not exchange a strong-prior limit with the infinite-horizon sum: the total-mistake guarantee is a hypothesis about the limiting learner, and only its first n risks enter the proof. The inherited ceiling holds for every limit posterior in this finite collection.

The note correctly excludes ordinary deterministic-majority mistakes, a guarantee only for one fixed D, and one complete reveal ordering. The minimax step requires distribution-universal weak approximation, and tiny correct posterior biases do not provide the confidence gap needed to extract accurate voters. The gamma=1 remark retains the existing weaker depth-dependent converse and does not claim the new depth-independent PNC1 conclusion there.
