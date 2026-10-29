# Independent evaluator-agent audit of the posterior and public statement

2026-10-28. Read directly against the public `NNBayesStatement.lean`,
`AnalyticCeiling.lean`, `FamilyCollapse.lean`, `Circuits.lean`, and the scratch
`UniformCapacityAssembly`, `StructuralPosteriorAssembly`, and
`FullPosteriorCeilingBridge` source modules.

No substantive theorem-statement mismatch, vacuity, or hidden circuit-capacity
assumption was found in this glue. The analytic capacity branches are explicit
premises of the assembly lemmas; the final theorem still must instantiate them
with their actual proved branches.

* The public claim is the exact negation of a joint-polynomial, distribution-free
  sample guarantee at every learner width at least the teacher width. The
  coefficient and degree precede all target/depth/width/distribution quantifiers.
  A chosen scale schedule is fixed before the input law/sample, but may depend on
  architecture and need not be computable.
* The finite Gaussian variances, strict global half-margin, exact training fit,
  confidence failure at correct-label probability at most 2/3, iid sampling,
  failure mass greater than 1/16 and probability greater than 1/2 match the paper.
  Positive conditioning probability is proved from actual realizability.
* Teacher complexity is an admissible bounded-weight width, not silently assumed
  to be a minimal width. This is sufficient for the impossibility statement;
  the compiled Boolean teachers have polynomial resources and bounded integer
  coefficients. The statement does not rely on encoding a truth table into a
  real-valued coefficient.
* The three scale cases cover every t in (0,1], including the critical boundary
  a=t^-2-1=0 and the far-strong boundary a=1/4. Q and all padding/circuit constants
  are selected before the instance. The short-scale coefficient enlargement is
  mathematically valid from aH<=Q log R and c_t<=a^2/2.
* The posterior proof uses the actual bad-class event. Failure of 5/6 class mass
  yields a genuine controlled margin path outside the class with action at most
  A+log(6)/N+2 tau. Its contradiction with the concrete capacity property uses
  log(6)/N<=tau. No majority-of-minimizers assumption appears.
* The denominator and covariance-repair widths are controlled using the
  normalized budget t^2(A+2 tau), with tau=1/(t^2 r). Thus the width threshold is
  independent of the chosen scale even as it approaches zero. The extracted
  path has r+1 hidden transitions; enlarging the denominator's r*c_t baseline
  to (r+1)*c_t is justified by nonnegativity, not an off-by-one identification.
* The eventual family argument fixes polynomial sample count before selecting
  the potentially exponential width. The common ceiling class is independent
  of sample, width, scale and input distribution; finite boosting then produces
  an actual polynomial-size logarithmic-depth threshold circuit. Threshold
  gates count wires and have ordinary integer cutoffs; the separate proved
  threshold-to-NAND simulation establishes the standard reverse inclusion.

Two scope distinctions should remain explicit in verification prose:

1. The concrete formal posterior ceiling used for the main theorem has fixed
   beta=1/6. It does not, by itself, formalize the paper's stronger ancillary
   proposition stated for every beta in (0,1). This does not weaken the formal
   main impossibility theorem.
2. `CanonicalSchedule` requires t>0. The main statement covers every fixed
   gamma>=1 finite-width prior and arbitrarily small positive scheduled scales,
   but does not itself state a theorem about a separately defined exact t->0
   posterior limit at fixed width. No such extension should be inferred merely
   by substituting t=0.

Replay C progressed from 200/425 to 226/425 checked modules during this audit;
no failure, error, or `sorryAx` was reported in its aggregate log.
