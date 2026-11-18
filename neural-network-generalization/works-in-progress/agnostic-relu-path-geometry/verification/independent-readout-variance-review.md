# Independent conditional-readout variance audit

18 November 2026 — agnostic_proof_audit. Mathematical review of a posterior diagnostic, not a new population oracle.

RV1 and RV2 pass. Conditional on hidden weights and the sample, the actual readout posterior is Gaussian with precision N²/nu times the identity plus H-transpose H divided by the physical observation variance. Consequently its covariance is at most the native readout covariance and the covariance of the training prediction vector is at most sigma² I. A convex interpolation of two observed feature rows therefore has conditional prediction variance at most sigma².

The ReLU interpolation error in each coordinate is at most |a_j|h (indeed a slightly sharper bound is available). Applying the native covariance bound to that residual gives nu Q_W h²/N. The elementary factor-two variance inequality yields RV1 without assuming independence of the interpolated prediction and its residual.

Gaussian radial integration by parts in all3N parameters gives E Q_N=3nu-(2/lambda)E P_n[z(z-Y)], because the network is homogeneous of degree two in its complete parameter vector. Completing the square yields E Q_N<=3nu+Yhat²/(2lambda). Since Q_W<=Q_N, averaging the conditional covariance inequality gives RV2, with the stated unbounded-sample-label variant.

For maximum interior sample gap O(log(n/delta)/n) and N>=n, the displayed O(lambda+log²(n/delta)/(n³lambda)) bound follows. This controls only the conditional Gaussian-readout component of posterior variance. The source correctly excludes the variation of the conditional posterior mean over hidden weights and extrapolation outside the observed sample range. No frozen Gaussian theorem is changed or strengthened by this diagnostic alone.
