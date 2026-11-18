# Independent mathematical review

Reviewed on 18 November 2026. This is not Lean verification.

Both exact compiler lemmas pass. The bounded-coefficient compiler restores Boolean gate margins at every layer rather than accumulating approximation errors, and its exact constant tanh(1) wire implements offsets without drift. The polynomial coefficient, width and depth bounds follow from the imported Boolean compiler and logarithmic saturation gain. The narrow arbitrary-coefficient construction correctly approximates ReLU(z) by z sech^2(a[tanh(kz)-1]) and uses two tanh units to approximate the derivative by a centered finite difference. Linear reconstructions fold into the next block, giving width 2C+1 and depth 2h. Compact-domain approximation and additional identity padding require only finite coefficients, as stated. This review imports the previously audited Boolean compiler; it does not claim a new proof of its TC0 arithmetic input.

The final derivative-gating replacement was checked explicitly: z sech^2(a[tanh(kz)-1]) approximates ReLU uniformly after splitting the compact interval, and the centered two-unit finite difference converges uniformly on the resulting compact rectangle.
