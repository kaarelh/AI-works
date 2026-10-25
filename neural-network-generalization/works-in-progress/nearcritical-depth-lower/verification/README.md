# Verification record

The paper proves a quantified finite-width result for ordinary tanh with variance prefactor $t=1+\epsilon>1$. It does not resolve exact canonical $t\le1$. These are independent AI-agent conventional mathematical checks, **not Lean verification or human peer review**.

## Statement checked

For $D=d+1+\log(1/\epsilon)$, absolute constants can be chosen so that

$$
H=\left\lceil K(\epsilon^{-4}+\epsilon^{-2}D)\right\rceil,
\qquad N=\left\lceil e^{AD}\right\rceil
$$

gives a ratio at most $1+e^{-cD}$ between any two raw full-cube truth-table probabilities with output margin greater than one half. After the stated global margin and label conditioning, every unseen label probability lies near one half. The theorem is about confidence and Gibbs prediction, not deterministic majority at exactly one half.

## Independent mathematical audits

- [Complete finite-N assembly](nearcritical-finite-posterior-independent-audit.md): parameter order, quality budget, actual mass lower bounds, exact readout dilation, and posterior pairing. **Pass.**
- [Normalized empirical quality](nearcritical-normalized-empirical-independent-audit.md): one independent check of scalar derivative-product nets, matrix derivative bounds, and empirical normalization. **Pass.**
- [Empirical transport and Bures geometry](nearcritical-empirical-transport-independent-audit.md): a second independent check, including the fully explicit common-additive-error covariance comparison. **Pass.**
- [Optimized mass and square-root pair quality](nearcritical-optimized-mass-pair-audit.md): cheap rank-one control schedule and lower-tail uniformity through degenerate pairs. **Pass.**
- [Population coupling and free-prefix whitening](nearcritical-coupling-prefix-independent-audit.md): unequal variances, Hermite factors, local metric geometry, and finite-width prefix. **Pass.**
- [Separate free-prefix audit](nearcritical-bures-free-prefix-independent-audit.md): the improvement to width exponential in D. **Pass.**
- [Occupation and deterministic transport](nearcritical-smooth-occupation-audit.md), with the [full independent derivation](../research-notes/nearcritical-occupation-transport-independent-audit.md): spectral Lyapunov drift and high-variance cooling. **Pass.**

The [standalone manuscript audit](nearcritical-manuscript-independent-audit.md) checked all source sections and appendices against the reviewed proofs and **passed**. Its source SHA-256 matches the packaged source. The independent component reviews above are also complete.

## Clean build

The 18-page PDF was built in a new temporary directory containing only the source and build script. The final log has no LaTeX warnings, unresolved references, or overfull/underfull boxes. The title/abstract and main-result pages were visually inspected. See the [hash and build manifest](build-manifest.json), [compiler log](clean-build.log), and [local-link check](local-link-check.json). The packaged PDF is the isolated build output.

## External mathematical inputs

The manuscript proves its model-specific concentration and transport estimates. It uses standard Gaussian integration by parts, Gaussian concentration and Poincaré inequalities, Bernstein and Hoeffding bounds, Hermite orthogonality, the Schur product theorem, finite-dimensional positive-matrix square-root facts, and relative-entropy data processing.

The one specialized combinatorial theorem invoked is Karpinski and Macintyre's polynomial VC-dimension bound for sigmoidal networks, *Journal of Computer and System Sciences* 54 (1997), 169–176, [DOI](https://doi.org/10.1006/jcss.1997.1477). It supplies the conservative bound $O(m^4)$ for two-tanh strips. The required rare-set consequence is proved directly in the appendix; no unrestricted uniform relative-KL assertion is assumed.

The earlier fixed-prefactor paper is cited for context and a simpler treatment, not as an unspecified proof dependency.
