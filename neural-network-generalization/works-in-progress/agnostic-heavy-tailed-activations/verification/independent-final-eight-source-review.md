# Final eight-source integration review
The earlier seven-source review remains applicable. The new expectation module is the already independently audited arbitrary-prior conditional-sub-Gaussian theorem, with only the unneeded logarithmic-comparison corollary removed.

The all-Lipschitz L2 comparison has KL K r^(-q), q=a/(2-a), and risk increase 2 sqrt(A_g r)+r. Its exact sharp expectation optimization gives A_g^(q/(2q+1)) u^(1/(2q+1)) + u^(1/(q+1)); at a=1/2 this is A_g^(1/5) n^(-3/5)+n^(-3/4), suppressing resource constants. The smooth comparison directly increases risk by r, giving the faster u^(1/(q+1)) expectation rate at arbitrary approximation error. Both results use one fixed physical variance and the ordinary all-data final posterior mean. The previously proved high-probability, calibration, growing-class and consistency statements retain their separate scope. All eight sources pass.

This is an independent mathematical source review, not a Lean verification.
