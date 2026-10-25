# Independent audit of normalized empirical transport

25 October 2026. Independent AI-agent conventional mathematical audit; not Lean verified.

Verdict: the expanded derivative-product and matrix-derivative empirical-quality argument passes, with the common-additive Bures comparison now proved explicitly in `bures-common-additive-error.md`. The finite-N posterior theorem still additionally requires occupation, rare-margin mass, and readout comparison arguments; those are outside this record.

## Global derivative-product quality

The classes B=phi_q(u.G), A=phi_q'(u.G)(v.G), and R=q partial_q phi_q(u.G) have direct linear Gaussian envelopes uniformly for q in[0,2], t in[1,2], with the stated q=0 limits. Their products are uniformly subexponential. The apparently singular q-derivatives can be bounded uniformly using h_s(z)=z b(sz²), b(r)=tanh(sqrt r)/sqrt r: the required b derivatives are bounded on[0,infinity), including their Taylor limits at zero, and normalization T(q)/q is smooth and bounded away from zero.

The sample Gaussian-radius cutoff yields polynomial parameter-modulus bounds. The product parameter dimension is O(m), so the stated mesh has entropy O(m log(eN)) in the small-quality range. Its interpolation error and Bernstein union bound are correct. The event defined by the full supremum, rather than the particular proof net, is exactly rotation invariant.

Integrating products of directional derivatives along a sphere arc and a log-variance segment proves squared-secant empirical error O(sqrt(v)delta²) and squared-norm-difference error O(sqrt(v)delta). The sphere path length is at most(pi/2)||u-w||, and this constant affects only the empirical error. The population contraction is retained exactly. The empirical row-normalization identity subtracts the squared norm difference, avoiding an erroneous extra population cross term.

For large v, the proof correctly requires a lower empirical feature norm and does not infer it from a Bernstein upper bound. That lower estimate is uniform in q without an inverse-epsilon cost: |phi_q(z)|>=c min(|z|,1) for q in[0,2], t in[1,2]. A uniform narrow-Gaussian-strip bound therefore suffices. Such a bound can also be proved with an elementary direction net: set delta=exp(-Cv), truncate max row norm at O(sqrt(m+log N+Nv)), and use net mesh delta divided by twice that radius. If a direction puts at least half the rows inside its delta strip, a net direction puts those rows inside a constant-multiple strip. Its fixed-direction probability is at most2^N(C delta)^(N/2). The net entropy is O(m[v+log(eN)]), absorbed by Nv when N dominates m log(eN) and C is large. This verifies the form of the imported rare-strip/lower-normalization event used in the note.

## Local covariance and derivative quality

For a white-region factor B, coordinate-normalized features h are centered by oddness. Gaussian Poincare bounds the population covariance operator independently of dimension. For ||M||F=1, ||Mh|| has bounded mean square and a dimension-independent Gaussian Lipschitz constant, hence a bounded subGaussian norm. The angular derivative dual is dominated by C||Mh||||EG||. The logarithmic radial dual is dominated by2||Mh||||diag(r)R_q(BG)||. R_q is uniformly odd and Lipschitz; the latter vector norm has subGaussian scale C||r||2. These arguments justify dimension-free subexponential Bernstein bounds for every Frobenius dual test.

The matrix/tangent parameter space has dimension O(m²), polynomial parameter radius, and fixed polynomial Gaussian derivative envelopes. Thus the cutoff-net entropy is O(m² log(eN)). The conservative m⁴log(eN)/N quality floor more than covers it; no inverse-epsilon factor enters.

Empirical correlation normalization is differentiated only along row-unit factor paths, so diag(dot F)=0. This point is essential and is now stated explicitly. The dot A and diagonal-normalization terms have the claimed Frobenius bounds; population dot F is bounded by the same dual estimate. Interpolating the correlation matrices linearly and taking their canonical positive roots remains inside the white correlation ball and keeps every row unit length. The integral of root-factor speed is bounded by C d_B(C,C'). This constant again multiplies only the empirical error.

## Exact covariance metric interface

The separate proof `bures-common-additive-error.md` establishes the dimension-independent inequality

    d_B(A+E,B+F)<=(1+3eta)d_B(A,B)+||E-F||F

for ||A-I||op,||B-I||op<=1/4 and ||E||op,||F||op<=eta<=1/10. It derives the path-length metric from a factor-lift ODE and compares translated Lyapunov operators along an explicitly optimal Gaussian covariance path. The loss is O(eta), not O(the white-ball radius). Applying this to the two normalized empirical covariance errors gives precisely the local gain1-c epsilon²+C sqrt(v), after the logarithmic diagonal component is included.

The updated physical-metric conversion also checks: optimal unit-row factors give row cost sqrt(qp)||r-s||²+(sqrt q-sqrt p)², and |sqrt q-sqrt p|<=sqrt(qmax)|log(q/p)|/2. Summation yields the displayed physical Bures bound by sqrt(qmax) times the joint normalized distance.

Past-measurable switches between canonical local factors and optimally aligned global factors preserve both Gaussian transition marginals. Uniformity of the quality event over factor orientations is sufficient, and has been built into its defining supremum.

Reviewed source SHA256:

- normalized coupling: `beb22e4c02400ad6e9f20465bc6198e3a6a0d92b4b1dc95f6aa4765bb5127228`
- normalized empirical quality: `bb3c4c8de52bcb32f94569239d803a8fa221f710aaa2c5819fabbcb9d4a1e703`
- common-additive Bures comparison: `93ba17e851eee648e704a40cfb1ed68b37489d3c6922646a782ecd85f64291b3`
