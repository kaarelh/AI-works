# Independent exact-depth posterior refinement audit

26 October 2026. Source: `strahler-exact-stage-posterior-refinement.md`.
SHA256: `b49573bf44d779b6d5a67ef2cc29f773ab0d8cfcf3718d7c1fc088a9adffb55c`.

Verdict: PASS on the full supporting note. The universal posterior conclusion follows from the explicit deterministic compiler and the cited existing analytic theorems. No final-linear-code Gaussian-seed extension is being assumed.

The gated alternating-threshold identity evaluates a complete same-rank path in one feature stage. Invalid last-reset and bottom-assignment candidates have negative scores and vanish; the unique valid candidate gives the correct signed parity. Every off-path side is a lower-rank output. Retaining each completed component as a linear combination of its physical features prevents recursive coefficient growth. The resulting exactly-r-hidden-stage tanh teacher has polynomial width and coefficient bound, with universal polynomial degrees and a fixed global margin. Constant wires and the final readout intercept are explicitly charged.

At L=r+1, padding that teacher's width to dominate its coefficient bound meets the precise hypotheses of the published fixed-depth uniform-prefactor lemma. I independently reread its proof. Its displayed B0 and M are jointly polynomial in d,C,L, and log(1/rho)=O(log(d+C+L)+L log(C+L)); thus Q_L has a universal polynomial degree. The imported normalized intrinsic theorem also has universal degrees. The estimate Rcal(D)<=4D+2 implies P_t<=[C0(1+Q_L)]^{(L-1)/2} uniformly in 0<t<=1. Consequently the boundary sample resource is (d+C+L)^{O(L)}=R^{O(r+1)}, with the stated uniform statistical factors. This is an extraction from the actual proof, not reliance on an unspecified depth-dependent polynomial.

For actual realizable widths smaller than the compiled teacher, the complete finite-width tanh VC bound is polynomial in d,L,N and hence in R. Every posterior-supported classifier is sample-consistent. Uniform convergence bounds its Gibbs error, and the inclusive correct-probability-at-most-2/3 failure set has mass at most three times that error. The constructed teacher is not required to fit those widths.

For L>=r+2, appending one threshold gate gives h=r+1 stages with polynomial coefficients and unit margins. The exact published short-padding threshold theorem applies at L>=h+1 and yields R^{O((r+1)^2)} uniformly over the actual width and canonical prefactor. Rank zero is handled by the Fourier theorem with variation one. Thus the combined theorem covers L>=max(2,r+1), all common input distributions, and the original strict global-margin/exact-label conditioning. It remains a rank-dependent polynomial and does not settle unrestricted formulas or provide a statistical lower bound at smaller depth.

The finite enumeration is a supplementary check only; the general proof is the algebra and rank induction. The main structural PDF may retain its weaker condition while this note states the independently verified strengthening.
