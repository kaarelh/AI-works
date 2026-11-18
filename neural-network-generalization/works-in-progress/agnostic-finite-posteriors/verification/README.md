# Verification record

The paper has conventional mathematical proofs and independent AI-agent reviews. It has not been formalized in Lean or externally peer reviewed.

- [Current mathematical and integration review](review.md): finite raw posterior bounds, covariance and scale covers, simultaneous width/exponent event, growing comparison classes, and the fixed-dimension obstruction.
- [Reviewed source hashes](review-source-hashes.json): exact assembled source snapshots checked by the reviewer.
- [Build record](build-record.json): current source and PDF hashes, isolated rebuild, reference checks, and PDF text correspondence.

The proof invokes standard Gaussian concentration, Bernstein's inequality, and the published smooth-loss generalization theorem of Srebro, Sridharan, and Tewari. The new posterior, Gaussian comparison, covering, and uniform-scale arguments are proved in the source. The review checks the use of those imported results as well as the new arguments.

An auxiliary Gaussian architecture and finite scale mixtures occur in the proof. The learner itself always retains its one specified dense Gaussian architecture and prior. The width-only appendix fixes the prior and temperature before choosing the counterexample law; its quantifiers differ from the separate all-temperature noisy obstruction paper.

Internal scratch paths in the review identify working copies. The published source is the `source/` directory in this package. A successful TeX build or numerical check is not a formal proof certificate.
