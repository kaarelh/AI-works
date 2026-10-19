# Independent phase assessment (19 October 2026)

Scope: fixed depth, fixed Boolean cube, tanh, independent Gaussian coordinates; variances N^{-a_1}/d at input, N^{-a_s} internally, and N^{-beta} at linear readout. Global margin and exact-sign posterior as in the collection. This note is exploratory, not a theorem.

## Most defensible extension of the existing picture

Suppose a_1 <= 0 and every internal a_s <= 1. Hidden activations then remain order one (some layers saturate). Subject to a positive definite limiting finite-domain kernel K and exponential concentration of empirical covariances at fixed accuracy, beta < 2 should have a frozen-kernel leading description:

- beta < 1: after output normalization the fixed absolute margin disappears; the limiting object is a GP conditioned on training signs.
- beta = 1: the global margin survives in the GP law.
- 1 < beta < 2: global margin costs order N^{beta-1}, below the order-N cost of an order-one empirical-kernel change. Thus the leading rate is Gaussian minimum energy in K. This does not identify relative posterior weights of tied minimizers.

The comparison is robust: conditional on the features, output is exactly Gaussian; an empirical-kernel bad event has probability <= exp(-c N), while a nondegenerate target margin event has probability exp(-O(N^{beta-1})). Conditioning therefore cannot promote an order-one kernel change. Letting fixed covariance tolerance decrease after N -> infinity gives the kernel rate. For exact GP convergence at beta <= 1, use ordinary finite-dimensional CLT/convergence and continuity of the fixed-margin or sign event.

A parity lower bound additionally needs kernel spectrum plus the actual posterior-confidence argument. It is not a consequence of the word 'kernel'. This broad conjectural region contains the established original gamma < 1 line.

At beta = 2, changing features can pay at the same scale as forcing output, and at beta > 2 it can be cheaper. For the genuinely nondegenerate fan-in slice (a_1=0 and all internal a_s=1), beta=2 is the established critical theorem. I would conjecture a broad adaptive/circuit-learning side for beta >= 2, perhaps after sufficient effective depth, but would not assert that all these tuples have polynomially equivalent circuit prior weights without proof. At beta>2 optimal hidden saturation and subleading feature costs can matter.

Extending the positive conjecture to saturated hidden layers (a_s<1) is less automatic than the negative-side extension: N-dependent steep tanh/sign limits remove uniform Lipschitz constants used by present compression proofs. A mean-shift circuit construction looks plausible, but this does not supply the accompanying low-complexity posterior control.

## Why I would not conjecture a universal two-region phase diagram

Small-amplitude layers can generate Taylor-degree-dependent costs. Consider just one hidden layer with a_1 > beta > 1. On a fixed number of neurons, a realizable degree-k Taylor construction at input amplitude t has the schematic energy

    N^{a_1} t^2 + N^{beta} t^{-2k}.

The optimum is t of order N^{-(a_1-beta)/(2(k+1))}, with rate exponent

    rho_k = (k a_1 + beta)/(k+1).

This increases strictly in k. It suggests a prior which first favors low polynomial/Taylor degree, and only later coefficient/representation complexity. Cloning q replicas produces a schematic multiplicative factor q^{(k-1)/(k+1)} in the optimal cost, so for k>1 dense replication does not obviously erase this mechanism.

For the complementary population regime, O(N^{(beta-a_1)/2}) nonlinear neurons at order-one amplitude can balance rare-feature cost with output cost and give exponent (a_1+beta)/2. The population must be between one and N; applying this formula outside that interval is wrong. In particular the sparse-collapse case above occurs when the formal population would be below one.

These are constructive scaling comparisons, NOT proofs of posterior concentration, NOT lower bounds ruling out better deep implementations, and NOT examples proving an intermediate sample-complexity rate. They nevertheless make a universal tuple partition based only on the typical output variance implausible. Even if every tuple eventually falls into one of two coarse worst-case sample-complexity outcomes, a proof must handle different mechanisms, effective depths, and possible target-dependent degree thresholds.

## Safe editorial recommendation

Explain the original price/collapse heuristic first, explicitly state its standing noncollapsed/nonsaturated posterior assumption, then critique it. Give the order-one-hidden/beta<2 frozen-kernel region as a concrete conjectural extension with its mechanism. Describe beta=2 as feature/forcing competition, not a universal boundary for arbitrary tuples. Say that global two-regime classification is uncertain; mixed/Taylor regimes are a real reason for uncertainty rather than merely lack of bookkeeping.
