# Independent review of the closed-main-theorem paper

29 October 2026. Reviewed `publication-after-closure/paper.after-closure.tex` and its analytic mechanism appendix against the final concrete Lean statement and selected proof interfaces. The complete 583-module source replay has passed; this review concerns statement/prose correspondence rather than substituting for that build.

## Conclusion

No substantive mismatch or mathematical error was found in the central theorem or new analytic outline. The theorem is conditional on nonuniform P/poly differing from TC¹. It rules out one distribution-free, learner-width-independent sample polynomial jointly in input dimension, bounded-weight teacher width and depth, for each prescribed positive scale schedule. It does not establish an exponential depth rate, uniform-input hardness, or the exact zero-temperature limiting posterior.

## Specific checks

- The Gaussian variance blocks, tanh architecture, global strict half-margin conditioning, exact noiseless sample fit, common IID input law, and strict greater-than-two-thirds prediction criterion match the concrete definitions.
- The main statement and its complement use success probability at least one half at confidence-error mass at most one sixteenth; failure therefore has probability strictly greater than one half at error mass strictly greater than one sixteenth.
- Teacher widths, coefficient bounds, and learner widths preserve the actual `realizesAtComplexity` convention. The NAND compiler uses bounded integer coefficients rather than unconstrained real precision.
- The threshold class is the usual nonuniform majority-gate TC¹ convention. Wire-count and ordinary gate-count conventions are polynomially equivalent here. The NAND simulation is actually proved.
- The small-raw-action appendix correctly says **after normalization** that the linear part is contractive. `PhysicalShortPicard.normLinear_norm_le` and `propagator_norm_le` establish exactly this; `PhysicalShortDimensionResources.critical_exp_budget_polynomial` bounds the final denormalization factor polynomially. It is not an unproved assertion that the original layers are nonexpansive.
- The long-prefix square-root entropy and variance budgets are actual prefix quantities controlled by `PhysicalLongPicardBudget`; gain normalization, opposite-label separation, and representative classification are actual constructions.
- The formalization scope correctly distinguishes the closed central theorem and fixed-beta ceiling from the stronger conventional every-beta ceiling and hard-family corollary. The hard-family corollary's conventional contrapositive argument is consistent with the stated stronger analytic proposition.

## Scratch draft improvements made

1. Added the polynomial final-readout normalization factor in the small-action outline, explaining why inverse-polynomial normalized precision preserves the original sign.
2. Replaced “separated representatives” by actual-input representatives with **opposite-label** separation. The proof does not require all pairs of representatives to be separated.
3. Added an explicit exclusion of the exact zero-temperature fixed-width posterior from the formal verification scope.
4. Pointed the reverse circuit-class inclusion to its proved lemma rather than calling it merely standard.

Only scratch publication drafts were edited. No repository file was changed by this review.
