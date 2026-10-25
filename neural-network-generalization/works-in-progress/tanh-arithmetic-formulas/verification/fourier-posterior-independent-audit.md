# Independent audit of the assembled posterior corollary draft

25 October 2026. Reviewed the file
[posterior.tex](../source/posterior.tex).

Verdict: PASS, conditional on the explicitly imported finite-scale posterior
ceiling and the separately audited low-product arithmetic-formula theorem.
No correction is required.

Checked the physical/energy variance conversion; all ceiling constants match
the existing `parallel-complexity.tex` imported statement. The simplification
P0<=exp(19/2)544^(3/4)(d+n+2)^9 is valid. The width and positive Gaussian scale
are selected before the input law, the ceiling is simultaneous over samples,
and fixed gamma>1 uses zeta=gamma-1 exactly.

The first majority conditions posterior mass at least5/6 and obtains signed
vote gap greater than1/5 at every point with confidence greater than2/3.
Its Hoeffding and full-cube union bounds are correct. The resulting finite
majority class is independent of the input law. Finite minimax and the second
majority then give equality with f for every epsilon<1/2, with the stated
polynomial dependence on (1-2epsilon)^-1. Constant-depth PNC1 composition is
the right closure theorem; no product-norm closure under majority is assumed.

For the cold limit, every truth-table distribution is a finite probability
vector and the low-product truth-table class is a fixed finite subset. Its
mass lower bound passes directly to every subsequential limit. A common
subsequence over the finitely many possible samples is available. The proof
runs on the limiting posterior and does not incorrectly pass a strict
confidence inequality through a limit.

The bounded-weight NAND teacher construction has correct margins: copying
uses tanh(4u), NAND uses tanh(4(1-u-v)) with signed preactivation at least3.2
when each input approximates its sign within0.1, and the constant1 is supplied
by twice a charged constant1/2 rail. Repeated gate inputs require coefficient
at most8, included in the stated bound. The final factor2 gives margin>1.
The all-width, all-distribution polynomial-learning hypothesis therefore
has the stated conditional consequence P/poly=nonuniform PNC1=L/poly.

The text correctly excludes the critical gamma=1 rate class from this PNC1
upgrade and correctly distinguishes a conditional superpolynomial obstruction
from an unconditional exponential-in-depth sample lower bound.

A separate fresh check by the geometry/Lean audit agent reached the same
verdict on these posterior arguments. This record is a mathematical AI-agent
review, not Lean verification of the new paper.
