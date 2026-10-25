# Independent audit of Fourier-factory precision

25 October 2026. Independent check of `fourier-factory-finite-bits.md`. The argument passes for the variable-diagonal Gaussian compiler's ordinary H^3 Fourier--Poisson factories.

Conditioning on frequency and Poisson count, the extra Rademacher term has constant-in-input amplitude `sqrt(delta)|c|s_theta`. It preserves the mean and forces conditional cube RMS at least that amplitude. Averaging over the conditional type then gives the stated pointwise variance floor for the mixed oracle. Its second-moment cost is bounded by delta times the same integrated H^3 bound, so the small amplitudes of coefficient residuals are preserved.

Each normalized complex factor has two bounded coefficients. The child's pointwise floor implies `E|1+i aX|^2>=gamma(1+a^2 RMS(X)^2)` at every input. Independence of distinct Poisson children therefore gives the product lower bound on s_theta, and hence the root coefficient bound `delta^(-1/2)gamma^(-K/2)`. Conditional phase cancellation cannot defeat this because of the added noise. The same realized child expression is duplicated syntactically, with every occurrence charged, when the complex product is expanded into real formulas.

The mixture normalization ratio has squared expectation one after conditioning on the caller's oracle type. Summing conditional tail probabilities over expected primitive-call count is valid even for countably many adaptive types. Intersecting this high-probability coefficient event with the polynomial-size event and the all-cube correctness event gives a good seed. Active K is bounded by its realized tree size. No unsupported frequency cutoff or lower bound on Fourier coefficients is used.

Polynomial-bit rounding then follows from ordinary finite-formula sensitivity once the normalized base input expressions have polynomial logarithmic coefficient bounds. This base condition holds for normalized Boolean cube coordinates, and more generally for the earlier stated polynomial-bit initial formulas. It should remain explicit in any fully abstract standalone precision theorem; arbitrary initial expressions with enormous canceling constants are not covered merely by a bound on their output RMS.

This audit does not extend the argument to a singular-frequency residual subtraction automatically. The source note correctly restricts itself to ordinary integrable Fourier transforms, which are exactly what the variable-diagonal construction uses.
