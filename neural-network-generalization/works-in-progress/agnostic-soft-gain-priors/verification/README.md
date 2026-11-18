# Verification record

The manuscript has conventional mathematical proofs and independent AI-agent review. It has not been formalized in Lean, and this record is not a claim of human peer review.

- [Independent mathematical review](independent-review.md) describes the checked arguments and scope.
- [Reviewed source hashes](independent-review-hashes.json) identify the exact reviewed theorem and proof sources.
- [Build record](build-record.json) records an isolated three-pass PDF build, source hashes, matching extracted text, and final reference and box checks.

The build completed without undefined references, undefined citations, LaTeX errors, or overfull boxes. The displayed PDF is built from the included source. Run `bash ../build.sh` from this directory to rebuild it.

The review includes the full-support soft gain prior and the selective comparison that retains the usual Gaussian base scales. It checks the actual internal normalizer, conditional endpoint dependence, all-width quantifiers, gain moments, function-neighborhood probabilities, and raw posterior-risk bounds. The earlier `hierarchical-log-normalization-review.*` files document a distinct intermediate model; the current main review and hash file identify the model presented in the PDF.

The ordinary-spectral-gain variant was independently checked as a further extension: scalar layer balancing, ordinary-gain transport, the Lipschitz-class entropy integral, and the dimension-dependent adaptive oracle all passed. Its final integration review identifies the exact source snapshot.
