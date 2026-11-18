# Verification record

This manuscript has mathematical checks and a reproducible LaTeX build. It has **not** been formalized in Lean.

## Scope checked

- The learner's prior is a single independent Gaussian at each fixed architecture. No architecture mixture or support restriction is introduced.
- The prior norm tails and raw second/fourth moments hold uniformly over width and Gaussian scale.
- The teacher neighborhood works for any globally Lipschitz activation, including nonzero activation at zero, at every width above the teacher width.
- The finite-class Bernstein estimate is proved explicitly. It replaces any need for an external smooth-loss or Rademacher-complexity theorem.
- The raw oracle inequalities control both posterior-average risk and the ordinary raw posterior mean. The leading comparison-risk coefficient is one.
- One sample event covers all widths and scales because the finite function covers are common to them; there is no uncountable union of failure events.
- The clipped-output refinement concerns the mean of individually clipped outputs, not an improved bound for the raw posterior mean.
- The growing comparison-class exponents account for the teacher's output bound in its Bernstein term.
- The dimensional cost and possible rapid depth dependence of constants are stated explicitly.
- The biased-teacher comparison uses one additional constant neuron per hidden layer, preserves depth, and changes only the comparison weight cap by a fixed activation-dependent factor. It does not change the learner prior.

The generic activation proof, teacher cylinder, and raw moments were independently checked by the `agnostic_gamma_one` and `agnostic_raw_finite` research agents. The tanh refinement and original norm-cover argument were checked by `agnostic_followup_audit`. The `agnostic_fixed_meanfield` agent assembled the self-contained manuscript and independently checked the teacher cylinder, raw transfer, common-event quantifiers, and finite-class Bernstein simplification. The [independent assembled-source review](independent-review.md) records the final checks and source correspondence; [its hash record](independent-review-hashes.json) identifies the reviewed source snapshots.

## Rebuilding

From `source/`, run:

```sh
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.. paper.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.. paper.tex
```

The final build was checked for undefined references, warnings, and overfull boxes. Source hashes and the build log are recorded in this directory.

Run `bash build.sh` from the package root for an isolated rebuild. The [build record](build-record.json) records the current publication PDF and source hashes, isolated rebuild, extracted-text match, and reference checks.
