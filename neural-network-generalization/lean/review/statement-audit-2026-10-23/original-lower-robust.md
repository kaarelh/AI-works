# Statement audit: original subcritical and robust-prior results

Audited snapshot: `7c69c4abe5f93476d59c95b4d04d13b33ff01301`.
This is a fresh comparison of manuscript statements with Lean definitions and
closed theorem types. It is separate from the existing kernel and axiom checks;
it does not recheck every informal proof or appendix.

## Subcritical exponential lower bound: matches

The manuscript's Theorem 1.1 is in
`main-results/subcritical-exponential/source/subcritical-exponential.tex:125–135`.
The formal proposition is
`NeuralGeneralization/Statements.lean:102–111`, proved without additional
premises by `MainProofs.subcriticalExponential` in `SubcriticalMain.lean:20–53`.

The following definitions were inspected, rather than inferred from the theorem
name or earlier review:

- `Network.lean:23–58` encodes the cube using Boolean values, with `true = +1`,
  one augmented constant input, `r+1` tanh hidden layers, and a linear readout.
  Thus manuscript depth `L` is formal depth `r+2`.
- `Model.lean:27–44` uses independent centered Gaussian **variances**
  `N^(1-γ)/d`, `N^(-γ)`, and `N^(-γ-1)`, exactly as the manuscript's
  equation (1.1), at lines 102–106.
- `Network.lean:64–70`, `FunctionPrior.lean:70–102`, and
  `FinitePosterior.lean:37–42` define actual Gaussian masses of globally
  strict-margin sign events, retain training-consistent functions, and divide
  by their total mass. This is the full posterior mixture, not a selected
  minimizer or posterior mean. `FieldPosteriorBridge.lean:128–146` also proves
  the event identifications with direct global-margin and training-sign
  conditioning.
- `FunctionPrior.lean:126–152` uses uniform test mass, an actual product law
  for iid training samples (repetitions allowed), and counts correct-label
  probability **at most** `2/3` as a failure. The manuscript does the same at
  lines 113–123. `parity` at lines 182–184 is the product of the input signs.
- The coefficient `c` and dimension threshold are chosen after depth and
  margin but **before** dimension, sample size, and exponent. Consequently
  they are common to all `γ<1`, including zero and negative exponents.
  `liminf` is over width alone with the sample, exponent, and dimension held
  fixed. The event is for each specified sample size, not simultaneously all
  sample prefixes. The constants `1/16` and `3/4` match literally.
- Positivity is concluded eventually in width; it is not an assumption hiding
  conditioning failures. The formal conclusion is uniform over the finitely
  many sample sequences of the fixed length, slightly stronger than the
  manuscript's pointwise positivity sentence.

The explicit `1 ≤ d` formal hypothesis is harmless for the asymptotic theorem:
increase the manuscript dimension threshold to at least one. No substantive
statement mismatch was found.

## Robust-prior polynomial-depth result: matches with a width convention qualification

The manuscript's principal theorem is in
`main-results/robust-polynomial-depth/source/robustness-theory.tex:88–105`.
The formal proposition is `RobustStatements.lean:32–52`, closed by
`RobustMainProofs.robustPolynomialDepth` in `RobustMain.lean:20–22`.

The model and learning conclusion match as follows:

- Put `H=r+1`, `L=r+2`, and `t=sqrt(N)*σ`. The formal Gaussian variances
  `N*σ²/d`, `σ²`, `σ²/N` become the manuscript's `t²/d`, `t²/N`, `t²/N²`.
  Since the formal circuit has at least one wire, eligible learner widths are
  positive. The conditions `σ>0` and `N*σ²≤1` are then exactly `0<t≤1`.
- `RobustModel.lean:20–61` uses simultaneous **postactivation** disturbances
  at every hidden layer and a scalar readout disturbance. The squared cost is
  the sum of hidden squared Euclidean norms divided by `N`, plus the squared
  output disturbance. No restriction keeps noisy activations in `[-1,1]`.
  The radius is `c/sqrt(1+H*N*‖v‖²)`, the score is clipped at `±1/2`,
  and its permitted change is `1/16`. These agree with manuscript lines
  26–63, including the non-strict boundary of the disturbance ball.
- `RobustPosterior.lean:15–25` conditions the actual Gaussian on this support
  and on signed training outputs strictly greater than `1/2`. It does **not**
  impose an extra clean margin at every input. Lines 49–55 prove equivalence
  with two-stage conditioning. Positive conditioning mass is a conclusion.
- `RobustConfidence.lean:42–58` gives literal posterior probability of signed
  output `>1/4` and the Gibbs loss for signed output `≤1/4`. The formal
  theorem bounds Gibbs loss by `ε/3` and confidence failure by `ε`; the
  manuscript states Gibbs loss `≤ε` and derives confidence failure `≤3ε`.
  These are equivalent existential-polynomial claims by replacing `ε` with
  `ε/3`. The formal conclusion is stronger at the same displayed parameter.
- The universal coefficient and exponent precede all architecture, circuit,
  calibration, input-law and accuracy parameters. The good sample event is
  chosen before `N` and `σ`, and works simultaneously for every eligible
  width and scale. Replacing an unspecified polynomial by a sufficiently
  large multiple of `(2+d+C+r+c+c⁻¹+ε⁻¹+log(1/δ))^m` and shifting depth by
  two do not weaken the existential polynomial assertion.

**The circuit convention requires an explicit qualification.**
`RobustCircuit.lean:85–107` requires a distinguished `+1` wire at **every**
stage, including the final stage. The theorem therefore has its claimed
`N≥C` guarantee for this formal, counted-constant circuit class. At `C=1`,
that class computes only the constant `+1`: its only output wire is its
distinguished constant, by `finalBits_constant` at lines 124–126.

The manuscript's prose convention allows some other width-one circuits, such
as a literal, and explicitly acknowledges this difference in
`source/robustness-paper.tex:148–155`: their Lean representation needs width
two. The principal theorem's general `N≥C` wording consequently should not
be described as a literal formalization of the paper's width-one `N=1`
cases. This is a known, documented endpoint coverage difference, not a flaw
in the Lean theorem or a change to the qualitative polynomial-depth result.
No formal translation covering every paper circuit convention was checked in
this audit; use the concrete `LayeredBooleanCircuit` width when citing the
verified width threshold.

The optional extra global-margin statement at manuscript lines 107–114 is
explicitly outside this original main theorem's coverage. The verified proof
also uses a looser sufficient polynomial than the sharper informal estimates.
Neither distinction should be silently promoted to exact certification of
every result in the paper.

## Documentation findings in the audited snapshot

- The original robust paper's README still says that the newer
  `original-support-all-scales` compression argument and exponents are
  **not Lean verified**. That statement became stale after the second batch.
  The correct status is that its headline polynomial bound and stated
  exponents are verified, with its separate numerical `16/ε` allocation
  excluded as described in `BatchTwo-coverage.md`.
- Statements that the original robust paper is an “exact” formalization should
  state the counted-constant convention above or link to a record that does.

## Resolution checked during this audit

The updated robust-paper README, FAQ Questions 15 and 40, verification record,
and second-batch coverage table explicitly state the reserved-constant-wire
convention and the missing paper width-one cases. The robust README also
corrects the stale improved-polynomial status and retains the numerical
constant exclusion. These changes accurately distinguish the verified
qualitative theorem from literal certification at every manuscript width.
For completeness, the width-one exclusion includes constant `-1` as well as
nonconstant targets: only constant `+1` has formal width one. The existing
Lean statements and proofs are unchanged.
