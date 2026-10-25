# Independent audit: normalized nearcritical coupling and free-prefix whitening

25 October 2026. Independent AI-agent mathematical audit; not Lean verified.

## Normalized joint coupling

Verdict: the population estimates in Sections2--4 of `nearcritical-normalized-coupling.md` pass. The deterministic empirical metric/coupling implications in Section5 also pass, conditional on its explicitly stated uniform secant/covariance/derivative quality estimates. This record does not independently supply the finite-net probability bookkeeping for those estimates.

- The normalized Hermite expansions give J(q)=1+O(q²) and a1(q)²=1-(2/3)t⁴q²+O(q³). The L2 q-derivative is uniformly bounded down to q=0. Comparing coefficients across an interval of length O(epsilon) therefore gives sum of the squared coordinatewise higher-coefficient suprema O(epsilon²).
- The row identity for two differently scaled normalized features is exact. Bounding coefficient products by their absolute values is valid even when a higher Hermite coefficient changes sign. For odd k, 0<=1-c^k<=k(1-c) for every c in[-1,1], including negative correlations. This yields the global squared gain1+O(epsilon²), with the radial log-distance contribution also O(epsilon²). No hidden angular-radial cross term was discarded.
- For a correlation matrix within operator radius rho of I, each off-diagonal row has squared norm at most rho². This proves the Hadamard-power spectrum bound1±rho^k. The Frobenius secant estimate and the Bures/Frobenius comparisons are dimension-independent in the fixed white ball. Their constant affects only higher Hermite terms; the linear term remains exact.
- Independent optimal factors for each Hermite chaos may be placed in an orthogonal direct sum. The unit-row factor identity produces the stated unequal-variance term. The leading coefficient's deficit is at least c epsilon² on [a epsilon,b epsilon], while all higher terms cost at most C epsilon² rho⁴. Choosing one sufficiently small absolute rho gives angular contraction. The scalar logarithmic map contracts by order epsilon, which absorbs the order-epsilon² radial coupling and proves the full joint contraction.
- The empirical global normalization is compatible with the listed secant estimates: for empirical row norms a,b, the squared distance of normalized rows equals [raw squared distance-(a-b)²]/(ab). This avoids an uncontrolled normalization cross term. Log-diagonal error differences have the stated Lipschitz contribution.
- The local empirical coupling correctly uses canonical correlation roots, rather than pretending that independently optimal Hermite couplings come from one Gaussian array. Its empirical-error differences can be added to the exact population estimate. A common additive covariance error changes the Bures metric by1+O(eta): on a uniformly positive definite path, compare the positive Lyapunov operators X -> PX+XP and X -> (P+E)X+X(P+E) using Loewner order, then invert the comparison. The ordinary PD Bures geodesic stays in a fixed larger white ball. It need not stay in the correlation elliptope, and the proof does not require that false property.
- Choosing factors based on the coupled past preserves each transition marginal because the fresh Gaussian array is rotationally invariant. The quality event must be uniform over those factors, exactly as the note states.

## Free-prefix whitening

Verdict: the actual finite-width free-prefix proof in `nearcritical-bures-free-prefix.md` passes, with its scalar asymptotic inputs and standard Gaussian differentiation identities as stated. It is a free-prefix theorem; no posterior-flatness conclusion is inferred from it alone.

- The cubic normalized Hermite coefficient is uniformly positive in squared magnitude relative to q². Its displayed integration-by-parts expression is a strictly negative covariance before squaring, and the nonzero small-q limit plus compactness justifies a uniform constant. This supplies the epsilon² correlation contraction from every initial distinct cube pair.
- The Gaussian regression inequality E[Delta² psi(W)]<=E Delta² E psi(W) is correct for nonnegative even psi decreasing in |W|. Conditional second moments are a nonnegative affine function of W², whose covariance with psi is nonpositive. Degenerate W is harmless.
- If Bures error is at most c epsilon^(3/2), every interpolated row variance is at least q*-C epsilon². Monotonicity of the sech-fourth expectation and its bounded derivative then give covariance-map Bures gain1+O(epsilon²), even during the nonstationary population prefix.
- Entrywise sampling error u implies Bures error at most m sqrt(u), without a lower-eigenvalue condition. The chosen u controls only h0=O(epsilon^-2 D) stages, for which the cumulative gain is exp(O(D)). All inverse powers of u are exp(O(D)), including its m and epsilon factors.
- At h0 the covariance entries enter the claimed small box. Near its diagonals, scalar attraction has gap Theta(epsilon). Near zero off-diagonal covariance, the derivative is the product of two expected sech² factors with gap Theta(epsilon²). Derivatives with respect to covariance coordinates remain bounded by Gaussian heat identities and bounded tanh derivatives; no inverse-epsilon loss is necessary here.
- Sampling error at most c epsilon² r preserves the entrywise box for arbitrarily later stages. Hence only the conditional union bound, and not an accumulated Bures gain over the entire prefix, depends on the requested duration h. Width exp(A D)log(h+2) suffices for the stated constant success probability.

Reviewed source hashes:

- normalized coupling: `34f30e7e8282de518ca6cd7e339d605f8e6ea0494e24673bfbe134eb4f0b6d5b`
- free-prefix whitening: `5fcf7bb1f29e59334e9af91555c5418e1968a36c6b7312828f53556b12bad59e`

Neither this audit nor the two notes resolves the exact t=1 or stronger canonical-prior unrestricted-depth question.


Expanded Section5 and physical conversion Section6 were subsequently checked with the complete companion empirical-quality argument. See `nearcritical-empirical-transport-independent-audit.md` for the updated source hashes and scope.
