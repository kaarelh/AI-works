# Audit of the circuit prefix and critical-rate steering

Date: 2026-10-18. Reviewer: depth_memorization agent.

This audit covers `source/circuit-rate-steering.tex`. I developed the local exact-feature repair lemma; that lemma has separately been independently checked by the depth_critical agent, and another independent review was requested from depth_continuous_lower. The global circuit prefix and steering assembly were written by depth_critical and checked here.

## Circuit prefix

The threshold-circuit definition counts a constant rail in every layer and normalizes every gate to margin at least one. Bounded-fan-in AND/OR/NOT gates have uniformly bounded coefficient norms under this normalization. Input covariance is exactly `d^{-1}H^(0)(H^(0))^T`, with diagonal `(d+1)/d<=2`.

For a layer of `C_j` gates, averaging exact repaired gate laws produces second-moment domination `(4C_j)^{-1}H^(j)(H^(j))^T`; this follows by applying the mean-square lower bound to each component separately before averaging. It does not rely on the mean of the averaged law having all gate components. The common constant diagonal supplied by the repair lemma is sufficient for the next layer.

Dilution at probability `theta_j=r_(j-1)/(P h L)` is valid, has KL at most `1/(hL)`, and preserves the state domination with `r_j=r_(j-1)/(4 C_j P h L)`. Every `r_j` is positive and at most one. The resulting logarithmic component estimate is `log d+h log(4WPhL)`. The bound includes the normalized coefficient norm `B`; dropping this dependence for arbitrary threshold gates would be unjustified.

## Steering from a small diagonal

I checked the holding and growth proofs directly in the published `critical-rate-foundations.tex`. Their controls require an upper bound on residual diagonal, and the initial holding step also has total diagonal at most the chosen cooling level. These hold when the prefix diagonal is already below that level, so the free-cooling stage may be omitted. If cooling is needed, its ratio product is uniformly bounded below on initial diagonals in `(0,1]`, preserving a component at least a universal constant times `delta*r_h`.

Reducing the tracked component to `v0=delta exp(-A S)` is valid for `S=1+log(1/r_h)` and a sufficiently large universal `A`. Growth from `v0` to `delta` uses `O(S/delta)` steps. Growth thereafter uses `O(1/delta)` steps; there is no hidden `log(p/delta)` factor in its length. The extra entropy term `delta log(p/delta)` is absorbed by `p/e`.

The remaining budget is `R=L-h`, giving exactly `R-1` additional hidden layers and one linear readout. Increasing the universal depth constant allows all active stages to fit, and holding fills the remaining integer number of layers. The prefix cost adds to the steering cost, yielding

`J_L(f)<=1/L+V_*+C[S²+log²(2R)]/R`.

The theorem's parameter `T=log(d+2)+h log(W+B+h+L+2)` bounds both `S` and `log(2R)`. Therefore its displayed `V_*+C T²/(L-h)` estimate follows. The sufficient depth `C h² log²(W+B+h+2)` for a bounded absolute rate also follows: above that endpoint the squared logarithm divided by depth decreases, and `log h` is absorbed by `log(W+B+h+2)`.

## Correction and scope

The first source version incorrectly described the total mass of the local repair components as exponentially small. Individual component weights are exponentially small in the number of state bits, but the total repair mass is a small universal constant. The polynomial entropy comes from convexity and the polynomial bound on each component's Gaussian shift cost. This prose correction was sent to the author. It does not change any estimate or proof.

The result is a prior-rate upper bound for the original Gaussian learner, without a robustness support restriction. It does not imply a sample-complexity bound: competing inaccurate sample-consistent functions can have the same leading rate. No claim of Lean verification is made.

## Bounded-fan-in sharpening and final source

I checked the added bounded-fan-in corollary. Each gate's input wires and the constant rail form a subcollection of the preceding tracked state, so the same covariance domination coefficient applies to this smaller state. The repair cost is consequently `P_*/r` for a constant depending only on the fixed gate library and fan-in. Different gates may have different constant diagonal values and amplitudes: their mixture still has constant diagonal, and the uniform amplitude lower bound `1/2` gives the desired covariance domination. Thus this optimization does not require padding all local states to one common size.

It yields the sharper parameter `T_B=log(d+2)+h log(C+h+L+2)`. The fixed-budget depth `[log(d+2)+h log(C+h+2)]²` follows as stated. In particular, writing `A=log(d+2)+h log(C+h+2)`, the estimate `h log A=O(A)` is uniform because `A>=h log(h+2)`. The endpoint estimate extends to all larger depths by the displayed monotonicity argument.

The total-repair-mass prose has been corrected. No substantive gap was found in the final source, whose SHA-256 is `b574e557530438f85026e88a82ef9427f85b5eaab03a31eee79bf9083ffae131`.
