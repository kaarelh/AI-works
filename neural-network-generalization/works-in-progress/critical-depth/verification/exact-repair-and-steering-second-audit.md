# Independent audit: exact Boolean feature repair and circuit rate propagation

Auditor: `/root/depth_continuous_lower`.

Reviewed sources:

- `source/exact-feature-repair.tex`.
- `source/circuit-rate-steering.tex`.
- The previously established free-cooling, holding, prescribed-growth and target-component steering arguments in the critical-depth manuscript.

**Verdict: no substantive mathematical gap found.** This is a conventional mathematical audit, not Lean verification. The result is a bound on the width-first critical prior rate. It is not a sample-complexity theorem or a finite-width realization bound.

## Exact local repair

1. The singular-covariance shift calculation is valid. From Q≥rHH^T, every Hc lies in the range of Q, and ||Q^{+1/2}Hc||²≤||c||²/r. Thus the Gaussian shift has entropy at most ||c||²/(2r), even when Q is singular. Applying tanh preserves the needed upper bound by data processing.

2. State-dependent marginal expectations are well defined. All inputs with the same H-state have the same shift mean and the same marginal variance q. No equality of their full covariance rows is required.

3. The saturation parameter can be common to all gates. Epsilon=c_*²/(10^6 M) depends on H and the universal q≤2 bound; A=O(log M+1)=O(s+1), independently of the gate coefficients w. The gate margin assumption |w·H|≥1 suffices. The constant law, point-indicator laws and diagonal-repair laws therefore share common saturation and diagonal parameters.

4. The first repair is a genuine probability mixture. The feature-mean matrix is within M epsilon/2 of the identity in maximum-row-sum norm. Hence the correction coefficients have absolute sum at most M epsilon, below the reserved mass t_1=4M epsilon. Negative coefficients mean output-negated component laws, not negative mixture probabilities. All component diagonals stay in [1-epsilon,1]. The resulting mean is exactly (1-t_1)g.

5. Positivity in the diagonal repair is established, rather than assumed from matrix inversion. Gaussian absolute values are stochastically increasing with the magnitude of a mean shift. Since |Ad_p|≤As, the matrix D=s_c-u_p is entrywise nonnegative. Its diagonal c is at least c_*/2; each off-diagonal entry is at most epsilon. The right-hand side b lies in [3epsilon,5epsilon]. Although D^{-1} need not be nonnegative, the explicit inverse perturbation estimate gives

   ||D^{-1}b-b/c||_infinity < 0.3 epsilon/c,

   whereas every coordinate of b/c is at least 3epsilon/c. Thus every repair weight is strictly positive. The bound ||lambda||_infinity≤12epsilon/c_* also ensures that their sum is below the reserved mass t_2=32M epsilon/c_*.

6. The final diagonal algebra checks exactly:

   (1-t_2)s_1+t_2s_c-Dlambda=s_c-4epsilon.

   Its mean is exactly (1-t_1)(1-t_2)g. Both amplitude and diagonal exceed one half, and neither depends on which gate is being repaired.

7. Exponentially many mixture components do not introduce an exponential KL penalty. Every component has a polynomial shift cost, and convexity bounds the relative entropy of the mixture by the weighted average of those costs. The final bound is O((s+1)^2(||w||²+(s+1)^2)/r), as stated. This is an existence argument; it does not assert an efficient algorithm for computing the mixture weights.

## Circuit prefix

The initial covariance is exactly d^{-1}H^(0)(H^(0))^T. Averaging the gate laws supplies covariance domination by (4C_j)^{-1}H^(j)(H^(j))^T. Diluting by theta_j=r_{j-1}/(PhL) spends at most 1/(hL) entropy per layer and gives the stated recursion r_j=r_{j-1}/(4C_jPhL). The common diagonal is retained at every step. Its positivity follows from the retained constant coordinate.

Taking logarithms gives O(log(d+2)+h log(W+B+h+L+2)), with no hidden exponential factor. In the bounded-fan-in corollary, restricting to a gate's input coordinates preserves the covariance domination. Gate amplitudes and diagonal constants may differ, but a common lower amplitude bound and individually constant diagonals suffice after averaging. The resulting logarithmic dependence on d is justified.

## Steering from a small diagonal

The new extension from an arbitrary positive constant diagonal q≤1 is sound. The free-cooling ratio R(q)=q[1-F(q)]²/F(q) has log R(q)=O(q²) at zero; positivity and continuity extend the bound over (0,1]. The sum of q_j² along a free trajectory is universally bounded. If cooling is needed, the first diagonal below delta is at least a constant times delta, preserving a tracked component at least c delta v. If q≤delta already, no cooling is necessary.

The chosen exact component v_0=delta exp(-AS), S=1+log(1/v), lies below the available component for a sufficiently large universal A. The residual diagonal is at most delta. Holding and growth use this upper bound and do not require a lower bound on the starting diagonal. The remaining depth is R=L-h, leaving R-1 hidden layers; the prescribed stage accounting and adjustable holding interval fit that count.

The excess bound O((S²+log²(2R))/R), addition of the prefix cost at most 1/L, and the two displayed polynomial sufficient-depth conclusions follow as claimed. I checked the monotonicity argument needed for those conclusions to hold at every larger depth, rather than just at the threshold.

## Scope

The repair can use exponentially many components and exponentially small component masses. That is compatible with the width-first variational rate theorem. It supplies neither a polynomial minimum width nor the comparison with inaccurate sample-consistent functions required for a learning theorem. The source explicitly preserves these distinctions.
