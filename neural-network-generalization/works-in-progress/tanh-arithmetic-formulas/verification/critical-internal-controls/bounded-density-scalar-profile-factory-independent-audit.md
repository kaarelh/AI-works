# Independent audit: the scalar profile factory

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `d8d746c81c6f21c3de3e0339144db87255034c3a312ce3fa8ead356b43c17654`.

The normalized Wiener-chaos pairing gives the exact tensor coefficients in the stated unit-direction interface. The coefficient-squared coordinate distribution is input independent. Averaging m_k=ceil(kV) independent children reduces their total second moment to at most 1+(V-1)/m_k, whose kth power is at most e. The resulting scalar contraction second moment is bounded by e times the squared Hilbert--Schmidt coefficient norm, with no ambient-dimension factor.

The degree probabilities p_k=||B_k||/(C_* k A), A=sum k||B_k||, simultaneously give integrated second moment C A^2 and common expected work at most T. The null branch, finite almost-sure degree, coordinate repetitions with independent samples, and constant term are all accounted for. Absolute convergence of the chaos pairing follows from Cauchy--Schwarz; nonnegative second-moment sums justify the countable construction.

For psi_q=tanh^2(sqrt(q)z)/q, Gaussian H^2 estimates are uniform on bounded q intervals. Subtracting z^2 leaves H^2 norm O(q), so after the density's degree-two tensor vanishes the residual second moment is O(q^2 ||r-1||_2^2). The corrected condition is equality of uncentered second moments, not covariance equality alone. An upper density bound r<=M suffices for chi-square<=C_M KL because the ratio of (r-1)^2 to r log r-r+1 extends continuously across r=1 and remains bounded on [0,M].

The last-layer consequence uses ||lambda r||_L2(gamma)^2<=M||lambda||_L2(rho)^2 and the exact weighted normalized-tanh Hermite bound 1+6q^2. This gives a chosen scalar functional, but summing these readout norms over a full output basis can diverge. The source expressly preserves that trace/factorization gap and assumes unit query directions. It makes no recursive arbitrary-law compiler, finite-bit, or posterior-learning claim.
