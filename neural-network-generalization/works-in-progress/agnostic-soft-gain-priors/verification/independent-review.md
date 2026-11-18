# Independent mathematical review — soft reweighted prior

Reviewed the revised seven-source manuscript on 18 November 2026. No substantive gap was found. This is a conventional mathematical audit, not a Lean formalization. The earlier log-reinforced hierarchical model review is preserved separately in hierarchical-log-normalization-review.md with its own hashes; this record concerns the new soft reweighted model without that logarithmic precision factor.

The revised prior is the independent Gaussian base tilted by exp[-omega{(G-1)(u+q)+(G^2-1)}/2]. Integrating the endpoint Gaussians yields exactly the stated internal marginal, including G^(-D_end/2). Conditional endpoint energy still satisfies omega Q~chi-square(D_end).

The gain-moment lemma was independently checked: G(cX)<=max(1,cG(X)) for c<=1 implies G(cX)^2-1<=c^2(G(X)^2-1). A change of variables in the actual internal normalizer gives the exponential moment and E G^2<=2. The affine transport of the actual internal tuple toward a stable implementation decreases both log G and G^2 potentials. Its exact relative entropy includes all normalizers and the affine Jacobian. The remaining Gaussian translation and covariance costs give 2 KL/omega<=3P+1+2log(1/eta).

The uniform-input error proof correctly conditions on all internal matrices before handling the first-layer covariance. Internal telescoping uses products bounded by G(X), so no false layer independence is assumed. The readout perturbation is independent of the first layer conditional on the internals. Together these give the stated uniform RMS tube.

Path-flow balancing, arbitrary-width cloning, the energy characterization, actual function-neighborhood probability bounds, dimension-free path-capacity estimate, weighted posterior tails, free-energy root, and population constants 25 and 280 were checked against the revised model. The resulting one-event theorem covers all eligible widths and every internal exponent gamma>=1, with one fixed architecture and full parameter support. This is a deliberately soft gain-penalized prior, not the original independent Gaussian tuple. Its complexity is path variation, which can still be exponential in ordinary teacher depth.

## Usual-base-scale extension

The integrated original-scale-variant.tex module also passes independent audit. The active/cross-block transport has Jacobian eta^((H-1)(2CN-C²)), keeps the inactive block unchanged, and decreases both gain potentials. Endpoint balancing gives u=q=sqrt(d)P and chi-square dimension ratio at most d+1. The gain penalty Omega=omega+D_int ensures E G²<=2. The dependence-aware uniform tube and exact entropy bound imply the displayed H[1+sqrt(d)P+HC+d]² sample factor, hence C²H³ for controlled-gain teachers at fixed dimension. This retains the usual independent Gaussian BASE scales but adds a soft gain reweighting; it is not the unmodified independent Gaussian prior.
