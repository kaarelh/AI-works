# Independent audit: arbitrary-control variance and spread occupation

26 October 2026.

Source: universal-quadratic-variance-and-diagonal-occupation.md.
SHA256: dceffe4170d62e473430b9fdf6a5435193aba1f058f70f7254ae223093ebe11d.

Verdict: PASS.

I checked the centered subexponential moment estimate, both signs of the entropy variational bound, and the small-ball Laplace argument needed for the large-entropy lower comparison. The split into small and large D correctly removes the otherwise fixed additive constant from the logarithmic comparison.

The maximum-variance recursion uses monotonicity of F before taking maxima; no common maximizing input is assumed. Young's inequality absorbs the delta and square-root-entropy terms, and bounded q absorbs qD, giving the quadratic occupation bound with delta²H.

For the diagonal-spread bound, the compact-interval logarithmic elasticity of F is strictly positive. A direct check of strict concavity is available: for r>0, the relevant derivative has sign r(1−3tanh²r)−tanh r, which is strictly negative because r sech²r<tanh r. Thus g=F/a has −g'/g>0, continuously extending to value2 at zero. The ratio telescope and its sign are correct.

Finite entropy preserves positivity of every initially positive diagonal. Constants may depend on the fixed compact variance/prefactor interval as stated. The note appropriately makes no scalar-formula, path-replacement, or posterior-learning claim from these scalar budgets alone.

This is a mathematical audit, not Lean verification.

