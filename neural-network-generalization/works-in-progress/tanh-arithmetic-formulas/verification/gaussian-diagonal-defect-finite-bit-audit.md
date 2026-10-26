# Finite-bit closure of the centered Gaussian diagonal-defect construction

26 October 2026. Independent audit of `gaussian-diagonal-defect-quadratic-occupation.md`, restricted to the finite-precision interface. The exact mean, trace, and real-work recurrences are separate mathematical inputs. This audit does not transfer the construction to the full posterior.

## Verdict

The new convex-mixture defect state is compatible with the existing finite-bit argument. Assuming the real-formula bounds in Sections 2–5, the conclusion may be strengthened to a majority of rational arithmetic-sign formulas, with a polynomial overhead in the number of layers and in the ordinary finite-input/readout resources. No lower bound on a nonzero defect increment, Gaussian-control singular value beyond its already charged logarithm, Fourier coefficient, or sampled coordinate probability is necessary.

In particular, let W bound the real expected formula work, the initial finite-description resource, the readout norm and inverse output margin, and the usual all-input selection resource. The total rational-formula size and coefficient bit length are polynomial in W+H. Substituting the source's bound (11) therefore preserves its logarithmic work charge, up to the ordinary polynomial prefactor in H and the initial/readout/input parameters. This is a nonuniform existence statement: the branch probabilities and the real parameter functions need not have an efficient algorithm for computing their digits.

## The new mixtures preserve the noise floor

Write a_i² for the cube-average second moment of a scalar oracle X_i. As in `fourier-factory-finite-bits.md`, maintain pointwise floors Var(X_i(x)) >= gamma a_i² by independent zero-mean Rademacher additions. If I is selected independently of x with probabilities p_i and X=X_I, then

    a² = sum_i p_i a_i²,
    Var(X(x)) >= sum_i p_i Var(X_i(x)) >= gamma a².

Thus the source's exact convex mixture `a e+(1-a)g_A` preserves the same floor without a cancellation argument. The selected normalized child introduces the coefficient a_i/a, but its squared expectation is exactly one. A conditional Markov/expected-call-count bound handles arbitrarily small p_i. The branch probability itself is not an arithmetic coefficient of the fixed-seed expression.

For rare residual creation, apply the same argument to the complete conditional branch, including the division by its sampling probability. Its conditional RMS b_theta satisfies E_theta(b_theta/b)^2=1. A zero branch is removed. Hence a very small branch probability does not force an unbounded bit length in the selected polynomial-size seed. The explicit bound c/p=O(1) in the defect-control update makes this even more direct, but is not essential to the normalized-mixture argument.

## No uncancelled small physical denominator

For the free defect update, first construct the function

    [e_next(e)-e]/(q Delta)

using the cancelled integral formula in Section 2. Its fixed H³ norm is uniformly bounded. The factory therefore sees an ordinary uniformly bounded transform, followed by the scalar factor q Delta. Zero increments are omitted. One must not implement the uncancelled difference quotient as a division of two separately approximated quantities.

For the controlled defect helper, the coefficient matrix B/(4 kappa) has uniformly bounded Hilbert–Schmidt norm. It is treated as one normalized coefficient tensor. Its constant term is 1/2+kappa/4. No division by kappa remains in the normalized formula. Entry sampling is input independent. The existing Hilbert–Schmidt quadratic-oracle normalization applies even when individual tensor entries or coordinate RMS values are arbitrarily small.

The normalized direction update uses the existing copy-plus-Hilbert–Schmidt correction. Its inverse-square-root helper is already included in the large-control charge through log_+(1/sigma_min A). The new defect representation introduces no additional inverse of Delta or Delta'.

## Floors, products, and the finite-bit seed

Use inverse-polynomial noise-floor strengths, for example gamma of order (H+1)^(-2) after fixing a sufficiently large universal constant. The final oracle outputs receive floors after any potentially cancelling addition; independent product children retain the existing conditional-product lower bounds. Injecting floors changes means by zero and multiplies second-moment envelopes by 1+O(gamma) at each maintained stage. The accumulated factor is bounded. The leaf/addition overhead is an ordinary polynomial in H, not a new exponential per layer.

The degree-thinned Fock and ordinary H³ Fourier transforms are exactly the primitives covered by the existing coefficient-floor arguments. In the Fourier factory, conditional product normalization bounds coefficient logarithms by O(K log(1/gamma)+log(1/gamma)); the random conditional-to-unconditional RMS ratio has squared expectation one. Tensor factors use independent child calls, and the same-child real/complex expansions retain their sampled children rather than rerunning them.

First select a seed giving polynomial total syntactic work and the usual all-input majority margin. Intersect this event with the coefficient-ratio Markov bounds, summed over expected primitive calls. Every active product degree and Poisson count is bounded by the selected syntactic size. Normalized coefficients consequently have logarithmic magnitude polynomial in W+H. Arithmetic-formula sensitivity gives polynomial-bit dyadic approximations preserving the good groups' sign margins. This uses the previously audited real-affine balancing and rational denominator-clearing construction; it does not assert that each group is accurate or that a real-arithmetic formula is automatically an NC¹ Boolean formula.

The final physical readout includes sqrt(1-Delta e). Its smooth-function costs are polynomial in 1/s_min when needed; their logarithms are absorbed by the source's charged log(1/s_min,0)+S+L. The readout norm and inverse desired margin must remain explicit in W. Arbitrarily tiny physical scales may be harmlessly absorbed into the readout coefficient normalization, but an arbitrarily large required readout norm is not a free resource.

## Scope

This establishes finite-bit closure for the proposed centered Gaussian path representation, conditional on its real-oracle recurrences. It does not prove a learning theorem, an unrestricted non-Gaussian path compiler, or a delta²H window for the actual posterior. The circuit-class consequence uses the existing nonuniform arithmetic-sign/PNC¹ theorem, with all of its original hypotheses.

## Explicit rational corollary follow-up

The final corollary `gaussian-diagonal-defect-rational-corollary.md`, SHA256 `ecd1d19f2ffca9e25da99790c2f1af517b47ee0c5eadb2f62248b275f65f4111`, is approved. It now explicitly permits the original normalized signed coordinates or an already-valid finite-bit initial-oracle interface, avoiding the incorrect claim that 1/sqrt(d+1) is always a rational constant. Using u_H directly is correct: ||h_H||<=1 makes the direction readout margin at least the physical margin, so no final square-root function is required. The resource and posterior-scope limitations remain explicit.

Circuit-class wording follow-up: the final rational corollary, SHA256 `d6a8203b0db2509c94dbe605196d7c0fc78876807a5ea9249e9cacb7d8a4ddd7`, now explicitly distinguishes size poly(R), depth O(log R) from membership in PNC1, which additionally requires R polynomial in the Boolean input length. This correction is approved; the quantitative representation theorem is unchanged.
