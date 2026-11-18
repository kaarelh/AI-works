# Independent conditional-fiber tail review

18 November 2026 — agnostic_proof_audit.

The exact excess-mass MGF and tail corollary pass. In the PR1 nullspace coordinates, W(u)=V(u)-V(0) is nonnegative, convex, coercive, and zero at the origin. Convexity implies W(ru)>=rW(u) for r>=1. The change of variables in the numerator of the conditional MGF therefore bounds the partition-function ratio by r^d, giving (1-s)^(-d). The minimum-value factors cancel exactly.

Centering that MGF gives log E exp(s(X-d))<=d[-log(1-s)-s]<=d s²/[2(1-s)], for X=omega(P-Pmin). Standard Chernoff optimization gives d+sqrt(2dt)+t; the displayed d+2sqrt(dt)+2t is a valid relaxed threshold. The zero-dimensional fiber has identically zero excess. The almost-every-fiber qualification and exact conditional law are inherited from PR1. This does not assert a function-distance or population-risk bound.
