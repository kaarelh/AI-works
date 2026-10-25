# Independent audit of the quantified nearcritical extension

25 October 2026. Reviewed `nearcritical-chaos-and-canonical-obstruction.md`
Sections 1--5 against the fixed-prefactor component proofs.

Verdict: the stated conservative powers and the actual finite-width corollary
are supported. No substantive gap found. This remains a conventional audit,
not proof-assistant verification, and applies only to `t=1+epsilon>1`.

The following checks matter for uniformity.

1. The expansions `q_*=epsilon+O(epsilon²)`, scalar derivative gap
   `2epsilon+O(epsilon²)`, and off-diagonal derivative gap
   `(2/3)epsilon²+O(epsilon³)` are consistent with the given expansion of
   `F` and its first standardized Hermite coefficient. The slow mode really
   is quadratic in epsilon.

2. Scaling `Q=q_*R` converts the local activation to
   `tanh(t sqrt(q_*)u)/sqrt(q_*)`. Its Lipschitz constant and the relevant
   Gaussian polynomial envelopes remain bounded as epsilon tends to zero.
   Frobenius-dual derivative tests retain dimension-independent
   subexponential constants by Poincare. A relative operator radius
   `c epsilon²` and empirical quality at most `c epsilon^4` therefore give
   local Bures gain `1-c epsilon²` without an extra inverse-epsilon
   metric loss.

3. Scalar logarithmic drift is uniformly at least
   `c epsilon min(V,1)`. With a relative variance tolerance `c epsilon²`,
   scalar-bad counts cost `epsilon^-3`. The pair count does not multiply
   this by an additional `epsilon^-2`: the pair potential never increases
   under a free transition even when variances are bad, so those steps can
   simply be omitted from the negative drift and added to the final count.
   The pair term itself costs at most `epsilon^-2` times the accumulated
   perturbation budget, dominated by `epsilon^-3`.

4. In the upper spectral potential, threshold `epsilon_X=c epsilon^4`
   makes perturbations cost at most `C epsilon^-4 zeta(v)`; division by
   the free gap `c epsilon²` gives `epsilon^-6`. Previously charged
   scalar/pair exceptions contribute at most `epsilon^-5`, so are absorbed.
   For the lower spectral potential, threshold `epsilon_Y=c epsilon²`
   gives bad-state decrement `c epsilon^4`; multiplying the upper count
   by `epsilon^-4` gives the asserted conservative `epsilon^-10`.
   Large-quality-step counting costs only `epsilon^-4 sum v`.

5. The all-label mass witness has a uniform entropy constant. Its seed
   common component is `Omega(epsilon/m)`; bounded covariance inflation
   doubles it to a fixed constant in `O(d+log(1/epsilon))=O(D)` steps.
   Every inflation entropy is bounded by an absolute constant per row.
   Residual eigenvalues are at least `exp(-CD)` and the final readout cost
   is `O(N)`. Hence total entropy is `O(ND)`.

6. The free whitening time is `O(epsilon^-2 D)`. A crude entrywise error
   amplification by `12^h0`, along with the absolute white tolerance
   `c epsilon³` and preservation tolerance `c epsilon^5/m`, is paid for
   by width `exp(C epsilon^-2 D) log(H+2)`. This width exponent does not
   grow with the final depth multiplier K.

7. With `H=ceil(K epsilon^-50 D)` and
   `N=ceil((H+1)^2 exp(A epsilon^-2 D))`, increasing absolute A gives
   `H tau<=D`. The quality-budget Chernoff factor `exp(CH)` is absorbed
   by `exp(cND)` because `N>H²`. Bad-event exponents can be chosen strictly
   larger than the uniform all-label mass exponent.

8. On the good quality event, the negative transport exponent is order
   `K epsilon^-48 D`; the leading adverse term is order
   `K^(3/4) epsilon^-47.5 D`. The latter is smaller uniformly for
   `epsilon<=epsilon0` after fixing K sufficiently large. The same choice
   dominates `log N=O(A epsilon^-2 D+log H)` and the readout polynomial
   factors. Thus the exact readout comparison has exponentially small
   relative error, as required.

The canonical-memory argument also checks: at `t_j<=1`, variances are
`O(1/j)`, the loss of first Hermite mass is `O(q_j²)`, and the sum of these
losses is finite. Normalized free correlations retain a fixed fraction of
initial correlations. The stated Bures/readout cancellation is therefore an
obstruction to that transfer route, not a general posterior impossibility
claim. The isotropic excited-phase entropy calculation uses entropy
superadditivity relative to a product reference and correctly permits
arbitrary dependent non-Gaussian controls.
