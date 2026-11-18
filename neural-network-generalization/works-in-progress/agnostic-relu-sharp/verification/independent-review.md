# Independent mathematical audit

Reviewed by the independent proof-audit research agent on 18 November 2026. The exact source snapshot is in `independent-review-hashes.json`. This is not a Lean verification.

## Conclusion

The strengthened finite-scale negative theorem, its arbitrary-mixture extension, and the revised teacher implementation pass this audit. No substantive gap was found. The positive theorem was previously checked in the original manuscript; its revised sparse homogeneous implementation gives the sharper energy constant stated here.

## Main checks

- Selective Gaussian perturbation: exact active-coordinate count, normalized relative entropy, total hidden second moments, active-coordinate error propagation, and readout perturbation. The inactive Gaussian bulk is retained and controlled; there is no normalized-full-parameter-count assumption.
- Exact sparse gated memorization: the off-grid hinge formula for every Boolean parity, Fourier/Parseval coefficient bound, gating away all signal atoms, amplified first-layer active coordinates, two signed relay coordinates, and positive-homogeneous energy balancing. The covariance penalty depends on later active widths, so the first-layer memorizer size does not create a hidden width requirement.
- The same construction and sample event work at every finite scale with N*sigma^2<=1, every likelihood temperature, and every width at least the displayed O(m+n log n) threshold.
- Gaussian-readout sector: conditional ridge contraction, preservation under hidden-posterior averaging and clipping of an individual raw mean, and the common linear separator. The exact target identity holds coordinatewise on the constructed law.
- Non-power-of-two sample counts: J=2^ceil(log2 n) lies in [n,2n). The collision variance uses the correct shared-pair covariance and implies sum of squared noisy counts at most 4n except on probability at most 1/n. The separator norm is below 11, giving the stated 1/300000 mixture constant.
- Localized-noise extension: the upper-count event is explicitly assigned to the inner signal pair; its norm bound is at most 9/p and gives the stated p^3*exp(-2p)/600000 lower bound. The individual prediction conventions and their stronger constants are distinct from the mixture statement.
- Strong-prior minimizers: the deterministic sparse comparison gives the low-temperature branch, comparison with zero bounds energy in the high-temperature branch, and every minimizing readout is a ridge contraction. They satisfy the same sector and separation event.
- The threshold statement and the no-joint-polynomial consequence preserve the law-varying-with-n and logarithmic-input-dimension qualifications. No endpoint result or fixed-distribution inconsistency claim is inferred.

The imported smooth-loss constant is now an unspecified valid universal constant. The source explicitly excludes averaging clipped posterior draws and clipping only after an arbitrary raw-mean mixture from the mixture theorem; these exclusions are correct.

Final abstract precision follow-up (18 November): the above-threshold negative claim now explicitly says a>0, matching the theorem body. Only source/paper.tex changed; all proof modules match their reviewed hashes. Both source manifests and the rebuilt PDF hash are refreshed.
