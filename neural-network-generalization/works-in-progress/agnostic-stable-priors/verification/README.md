# Verification record

The manuscript has conventional mathematical proofs and independent AI-agent review. It has not been formalized in Lean, and this record is not a claim of human peer review.

- [Independent mathematical review](independent-review.md) describes the checked arguments and scope.
- [Reviewed source hashes](independent-review-hashes.json) identify the exact reviewed theorem and proof sources.
- [Build record](build-record.json) records an isolated three-pass PDF build, source hashes, matching extracted text, and final reference and box checks.

The build completed without undefined references, undefined citations, LaTeX errors, or overfull boxes. The displayed PDF is built from the included source. Run `bash ../build.sh` from this directory to rebuild it.
