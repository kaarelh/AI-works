# Independent final integration review

Reviewed all four included sources on 18 November 2026. The depth-normalized energy certificate, exact selective Gaussian comparison and all-width bounded-output theorem pass. Retaining the product AM--GM bound and Gaussian scale 1/L gives exp(O(H)) rather than exp(O(H log H)) samples at fixed remaining resources. The linear-dimension extension keeps d0=1+d/L and the exact balanced per-layer teacher energy, so the same exponent is uniform for d=O(H).

The raw-readout extension correctly retains the tilted chi-square Lth moment in its weighted risk tail. Its cutoff stays O(1+log(n)/L), and the exponentially bounded teacher amplitude costs only O(L) extra logarithmic precision. Raw finite posterior moments exist at every architecture. The extra condition N^{gamma-1}>=H+1 is explicitly retained; the bounded-output small-width certificate is not incorrectly reused.

The abstract, model, likelihood normalization, common sample-event quantifiers, certificate selector and external statistical inputs agree with the proofs. No substantive gap was found. This is a conventional mathematical audit, not Lean verification.
