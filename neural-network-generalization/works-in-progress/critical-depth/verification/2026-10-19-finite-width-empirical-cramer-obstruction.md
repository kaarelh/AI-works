# A distribution-free empirical Cramér bound is impossible

Fix any integer N >= 1. There is no function b(N,2,t) tending to zero as t tends to infinity that bounds P{I_P(sample mean)>t} uniformly over compactly supported probability laws P on R^2. In particular, bounds of the proposed form poly(N)^m exp(-(N-O(m))t) are false even when N is arbitrarily larger than m=2.

## Construction and proof

Let M >= 3, put t=log M and r=1/(4t), and define a_j=r^j and v_j=(a_j,a_j^2), 1<=j<=M. Define P_M by P_M({0})=1/2 and P_M({v_j})=1/(2M). All supports lie in [0,1]^2.

For j let theta_j=(2t/a_j,-t/a_j^2). Writing u=a_i/a_j gives theta_j dot v_i=t(2u-u^2). Thus:

- if i=j, the score is t;
- if i<j, then u>=1/r=4t>2, so the score is nonpositive;
- if i>j, then 0<u<=r, so the score is at most 2tr=1/2.

Consequently

    E exp(theta_j dot X)
      <= 1/2 + (exp(t)+(M-1)exp(1/2))/(2M)
      <= 1+sqrt(e)/2 < e.

The Cramér transform I_M(x)=sup_theta[theta dot x-log E exp(theta dot X)] therefore satisfies

    I_M(v_j/N) >= (log M)/N - 1.

If precisely one of N iid draws is nonzero, their mean is some v_j/N. This event has probability N 2^{-N}. Hence

    P{I_M(sample mean) >= (log M)/N - 1} >= N 2^{-N}.

Letting M grow proves the assertion. The empirical mean rate is finite here: it lies in the convex hull of the finite support, and the empirical type itself is a feasible absolutely continuous mean-matching law. The obstruction is not a boundary infinite-rate pathology.

For every positive alpha, E exp(alpha I_M(sample mean)) is unbounded uniformly in P_M, by the same event. This also rules out the proposed fractional normalized maximum-likelihood moment estimate, even with exponent N-m or N-m-1 positive.

## Scope

This does not disprove the desired NNbayes finite-width extension. Its conditional row reference laws are Gaussian preactivations followed by tanh, and their sufficient statistics are quadratic activation products. The constructed reference laws are arbitrary discrete moment-curve laws. It does prove that a generic theorem using only moment dimension and boundedness cannot be the missing ingredient; one must exploit the Gaussian/tanh structure or accept additional geometry-dependent constants.

## Related literature checked

- Chowdhury, Saux, Maillard and Gopalan, *Bregman Deviations of Generic Exponential Families*, COLT 2023, https://proceedings.mlr.press/v195/chowdhury23a.html. Their general concentration formula retains a family-dependent Bregman information-gain term; its fixed-family asymptotic logarithmic behavior does not give the uniform bound ruled out here.
- Grünwald, Hao and Balsubramani, *Growth-Optimal E-Variables and an extension to the multivariate Csiszár-Sanov-Chernoff Theorem*, https://arxiv.org/abs/2412.17554. The surrounding-alternative bound retains minimax regret; the paper provides fixed-family asymptotic analysis under regularity rather than the nonexistent uniform finite-sample bound.

Status: elementary proof checked by author; independent audit requested from depth_counter_audit.
