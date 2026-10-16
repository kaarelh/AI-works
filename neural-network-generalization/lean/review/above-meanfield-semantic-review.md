# Independent semantic review of the above-mean-field main statement

Reviewed the published source snapshot identified by commit
`7d256b846523529482c8b65c468667ee0b5ec9b1`, specifically:

- `main-results/gamma-above-one/source/gamma-above-one.tex`, SHA-256
  `e0fc5afb63b3d8bf82144dc4a4fc6ec00454a00c2852d38e1a3042daf914c825`.
- `main-results/gamma-above-one/source/source/gamma-gt1-main.tex`, SHA-256
  `9c7be1a56c2c2595ee76ec0c3864cc5986ac0ac31353a19a70d1d6ecbf6b4f6a`.

These hashes match the recorded source manifest. The target is the published
all-width learning theorem, not every auxiliary claim in the paper.

## Statement and model correspondence

`MainStatements.AboveMeanFieldGeneralization` faithfully expresses the main
learning theorem. No semantic mismatch or vacuous replacement was found.

- `r` internal matrices means depth `L = r + 2`, including `r = 0`.
- The finite cube uses Boolean coordinates whose `labelReal` values are exactly
  -1 and +1. The constant coordinate is the first input coordinate.
- Each hidden layer has the actual learner width N. The final readout is linear;
  no hidden biases, coordinatewise normalizations, or extra trainable units
  were silently added to the architecture.
- `admissibleActivation` means range contained in [-1,1] and Lipschitz constant
  at most one. It does not assume oddness, non-polynomiality, or phi(0) = 0.
- `isComplexity` states the true minimum positive integer C for which a width-C
  network has strict global margin 1/2 and every weight bounded by C. The
  constructive argument actually needs only the witness, not minimality.
- `powerPrior` is the actual product Gaussian on all weight coordinates, with
  variances N^(1-gamma)/d, N^(-gamma), and N^(-gamma-1). The variance convention
  therefore agrees with the paper's displayed standard deviations.
- Function masses are the actual measure of the strict event at every cube
  input. The consistency posterior normalizes these actual masses after
  requiring all observed labels. The global-margin normalizer cancels, as
  established by the separate checked equivalence theorem.
- Posterior risk averages label error over the complete posterior law and the
  arbitrary finite input distribution. This is not regression of the posterior
  mean. Training probability is the exact product probability of n IID inputs.
- A and m are chosen after fixed depth and exponent but before the activation,
  dimension, target, complexity, width, input distribution, epsilon, delta,
  and n. In particular, neither polynomial coefficient nor degree can depend
  on learner width or accuracy. The term log(1/epsilon) is an explicit argument.
- Every width N >= C is covered, not just a width limit or a subsequence. The
  sample condition has the advertised factor 2/epsilon and
  log(2/(epsilon*delta)). The denominator is additionally proved positive for
  every training sample, ruling out a zero-normalizer convention as a route to
  an empty guarantee.

The statement is nonvacuous whenever the paper's representability condition
holds. A degenerate activation with no representable target makes the same
representation assumption fail in the paper and in Lean; the main theorem
has not acquired any additional such hypothesis.

## Elementary proof route

The Lean route deliberately replaces Gaussian isoperimetry and exact singular
value truncation by an explicit finite-dimensional orthogonal witness and a
finite factor grid. This change is mathematically compatible with the main
existential-polynomial statement:

1. Failure of an operator approximation with squared Frobenius energy at most
   K gives an actual finite orthonormal energy witness.
2. Its normalized capture matrix has actual Frobenius energy one and a large
   actual scalar pairing with the Gaussian matrix.
3. The factor grid and scalar Gaussian tails bound the actual exceptional
   parameter event. The entropy is lower order than K*N^gamma for gamma > 1.
4. The retained matrices need only bounded Frobenius energy and a small
   residual operator norm. The network perturbation theorem uses exactly those
   properties, with uniform error on the entire cube; it does not assume an
   unidentified singular-value truncation map.
5. Norm compression and finite parameter counting produce an actual finite
   class of globally margin-separated functions. Its complement's total raw
   mass is bounded directly, with no union bound over all Boolean functions.
6. The closed all-width cylinder theorem gives an actual target mass lower
   bound even for phi(0) != 0. Its supported subspace includes the extra padding
   direction, of dimension at most C+1.
7. The risk-only finite posterior splice covers widths below the truncation
   threshold using target mass, and all larger widths using the relevant class.
8. The arithmetic budgets and shifted-ceiling polynomial envelope have fixed
   natural degree for each fixed depth and gamma. Rounding log(1/epsilon)
   changes only the polynomial coefficient. The exponent is allowed to worsen
   as gamma decreases to one, exactly as in the paper.

The elementary route has looser constants and proves the same main learning
statement. It should not be described as a Lean verification of the paper's
specific exp(-K/(8*sigma^2)) singular-value lemma, precise cutoff constants,
or its separate equivalence between normalized negative log mass and circuit
complexity. Those auxiliary results are not needed for this alternative proof.

## Minor editorial observation

The gamma>1 paper's Scope section still describes a mean-field companion with
an unquantified threshold, whereas the current collection presents a newer
all-width mean-field paper. This is a stale cross-paper description rather
than an error in the gamma>1 learning theorem or its formal statement.

## Verification of this agent's completed contributions

Fresh direct Lean compilation passed for the cylinder probability/scaling,
containment, actual target mass, explicit polynomial cost, full power-prior
mass, risk-only statistical splice, both exponential tail-ratio lemmas, the
polynomial composition/shifted-ceiling lemmas, and the above-mean-field budget.
The axiom audits for the closed target theorem and all principal new budget
and splice theorems report only `propext`, `Classical.choice`, and `Quot.sound`.
Logs: `/workspace/scratch/cylinder-closure-audit.log` and
`/workspace/scratch/above-budget-audit.log`.

This review by itself does not certify the final main theorem. Its exact type,
full dependency-aware rebuild, and full axiom audit remain the publication gate.

## Final main-theorem verification

The independent dependency-aware command
`lake --no-cache build NeuralGeneralization.AboveMeanFieldMain` completed
successfully, all 3233 jobs. The exact target's 74 project dependency source
files and the three toolchain/manifest/config files had identical SHA-256
hashes before and after the rebuild. A fresh Lean file then checked

```lean
example : NeuralGeneralization.MainStatements.AboveMeanFieldGeneralization :=
  NeuralGeneralization.MainProofs.aboveMeanField
#print axioms NeuralGeneralization.MainProofs.aboveMeanField
```

The axiom closure was exactly `propext`, `Classical.choice`, and `Quot.sound`.
Logs and hash manifests:

- `/workspace/scratch/above-main-independent-build.log`
- `/workspace/scratch/above-main-exact-audit.log`
- `/workspace/scratch/above-main-dependency-source-before.json`
- `/workspace/scratch/above-main-dependency-source-after.json`

This verifies the precise above-mean-field main learning theorem. It does not
assert completion of the other main-paper verification obligations or expand
coverage to the sharp auxiliary statements distinguished above.
