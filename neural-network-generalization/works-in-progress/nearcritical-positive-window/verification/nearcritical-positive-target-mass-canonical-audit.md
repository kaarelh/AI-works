# Independent audit of positive nearcritical target mass

26 October 2026. Auditor: `/root/fresh_canonical_depth`.

**PASS** on `nearcritical-positive-target-mass.md`, initial source SHA256
`1c869f8ee07754756893b7ed2efa14b23c4304bd3c4a43d2b56321139de310ae`.
The critical scalar and finite-channel foundations are imported inputs;
I checked the relevant source statements in `critical-scalar-paths.tex`
and `critical-finite-width-channel.tex` as well as the complete new note.

The critical cooling drift loses at most C delta q, so it remains a
quadratic decrease above a sufficiently large multiple of delta. The
tracked first-Hermite component/diagonal ratio is a function of t²q and
has loss O(q²); its product remains bounded below during cooling.

Holding and growth use a one-dimensional Gaussian variance change along
the target direction, with the actual t²R covariance in its complement.
The full conditional-mean component is continuous and increasing in the
chosen variance a and crosses each prescribed target value. Thus the
conditional Gaussian Poincare bound applies to the actual residual,
without an uncharged deliberate component reduction. Its map
r -> t²r(1-c t²r) preserves [0,Delta] when Delta>=C delta. The entropy
cost O((Delta+v)²), growth length, and telescoping costs follow as stated.

Purification uses p>=C delta and hence has geometric contraction
1-c'p. In the increasing scalar suffix, E eta²/q>=1; this makes the
reference change to variance t²q cost at most C delta² per step, with
the correct favorable sign. The suffix has O(1/p) steps, so residual
inflation t^{2m} is bounded. Its conditional-mean loss is O(m r0), which
is absorbed by the stated purification accuracy and readout budget.

The scales Delta=B1 U/H and p=B2 U/H fit all phases into exact depth,
and direct square-root accounting gives O(U). The finite-width row
formula has exactly the actual Gaussian reference marginal conditional
on all preceding history; only its scalar coordinate is controlled.
Its comparison gain t exp(sqrt(D)) accumulates exp(O(U)). The bounded
score moments, stopping argument, and binary entropy conversion give
the raw all-cube target probability at every sufficiently large finite
width, rather than merely a variational upper bound.

No Gaussian change of measure in the full row space, posterior-width
limit, or monotonicity of the supercritical residual is used. The
window delta H=O(S) and Fourier-variation target scope are explicit.
This result is adjacent to the original canonical t<=1 depth question.

## Final clarification check

The final source SHA256 is
`c7b206934ae34139dcddd077d487de90b4cb8a61ba3f580b68b157bed6845e3d`.
It explicitly states full conditional-mean equality during holding/growth
and spells out the direct square-root-cost budget. Both clarifications
are correct and the PASS verdict is unchanged.
