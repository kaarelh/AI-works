# Independent mathematical and finite-reduction audit

26 October 2026. Independent AI-agent review. This is not human peer review or a certification of the missing analytic Lean proof.

## Reviewed snapshot

- Manuscript: `source/paper.tex`, SHA256 `95dab7faa4c3c1df99c5f7ab6957ae9856106e0bf2fd2f84938ef06778a94f00`.
- Final nine-page PDF: `paper.pdf`, SHA256 `221a8d77e21583a6aa86c6b92b2c6cb5183b3223f7ad1997a0434ec3579d7490`.
- `lean/FiniteReductionBoosting.lean`: `47c7b89b5bc6de17ed6eee567d8c03dadb532a273b0ab55e5183142a8e306814`.
- `lean/FiniteReductionPosterior.lean`: `68b55011b76f27d3bf0a69002e8fb3bfd6b522c817f55984195eafc2838300bd`.
- `lean/FiniteReductionConverse.lean`: `b2e2326fb332ac28489d0f7cea9661979830494fac089fa16ab5c7a9abe9c700`.

**Verdict: PASS for the manuscript's mathematical reduction and the reviewed finite Lean statements/proofs.** The complete neural impossibility theorem remains unproved in Lean because the analytic posterior-circuit ceiling has not been formalized. A fresh kernel build is recorded separately; this review checked source semantics and proof correspondence.

## Mathematical checks

1. **Actual model and quantifiers.** The first, internal, and readout variances are respectively `t²/d`, `t²/N`, and `t²/N²`. The original global strict absolute margin and exact noiseless-label conditioning are retained. The schedule is fixed before the input distribution and sample. Teacher resources include dimension, depth, and both width and coefficient bound. Zero padding is valid for tanh and positive conditioning follows from a global-margin teacher and finite-domain continuity.

2. **Fixed confidence constants.** Correct-label probability at most `2/3`, including equality, is a failure. Failure mass at most `1/16` gives posterior-averaged classification error at most `1/3+(2/3)(1/16)=3/8`. Posterior mass at least `5/6` in the ceiling class therefore supplies a voter of error at most `(3/8)/(5/6)=9/20`. The proof treats the whole posterior mixture and never assumes concentration on one circuit.

3. **Finite boosting.** The multiplicative update factors `9/10` for correct and `10/9` for incorrect predictions give the potential factor `(11/20)(9/10)+(9/20)(10/9)=199/200`. All weights remain positive. Bernoulli's inequality gives `(199/200)^400<1/2`; hence `400(d+1)` rounds drive the total potential below one on at most `2^d` inputs. Any input with at least half incorrect votes would retain weight at least one, a contradiction. This proves a strict majority even though the number of voters is even. No minimax, sampling concentration, or efficiency assumption is hidden in this argument.

4. **Teacher compiler.** For a NAND circuit with `s` gates, the proposed width `d+s+256` and weighted depth `d+s+3` count initialization, one layer per gate, and `d+1` copy layers correctly. NAND's signed score is `1-u-v`. At most three input/constant errors of size `1/16` preserve score margin greater than `1/2`. Gain 64 and the elementary tanh saturation estimate restore error at most `1/16`. Coincident wires can contribute three coefficients of magnitude 64, so the stated bound 192 is safe. The readout margin is at least `15/8`. Constant wires are counted and no hidden bias is assumed for free.

5. **Imported analytic theorem.** The manuscript's proposition is the circuit consequence of the earlier source's `thm:uniform-ceiling`. The earlier theorem supplies one common circuit-resource class independent of width, scale, and sample, a scale-independent finite-width threshold, and all consistent samples of at most the stated budget. The present paper correctly states this as an imported analytic input. This audit checked the interface and quantifiers; it does not independently reprove the long analytic theorem.

6. **Class-collapse reduction.** For a fixed polynomial-size Boolean family, compiled teacher width and depth, the proposed sample count, and the resource `R` are all polynomial in input dimension. The polynomial degrees may depend on that family and the proposed learning polynomial, but not on dimension. Padding to `L≥d` eventually ensures `L≥c log R`. Learner width is chosen after the sample count and before the input law; the scale is then read from the prescribed schedule. Appending one majority layer preserves polynomial size and logarithmic threshold depth. Finitely many exceptional dimensions can be hardcoded with fixed constants. The reverse inclusion uses an explicit ordinary Boolean implementation of count-threshold gates in the stated majority/Boolean basis.

7. **Negation and stronger hard-family corollary.** Negating success probability at least `1/2` produces failure probability strictly greater than `1/2`. For a fixed family outside TC¹ and any polynomial sample budget, membership in the bounded majority closure at all but finitely many dimensions would put the family in TC¹; hence infinitely many dimensions fail. Contraposing the finite weak-learning lemma supplies one input distribution under which every ceiling-class member has error greater than `9/20`. Because the ceiling class is common, this one law defeats every sufficiently large width, every canonical scale, and every target-labelled sample within the budget. Thus the corollary's probability-one failure is valid and does not require monotonicity in sample size.

## Lean correspondence checked

The three finite modules reproduce the manuscript's rational constants, weight update, potential estimate, strict-majority conclusion, and full-mixture averaging. `WeakClass` quantifies over nonnegative weightings, including zero; `weakClass_of_normalized` proves its equivalence in the needed direction from normalized laws and handles the zero-total case explicitly. `posterior_family_exact_majority` fixes the predictor class before the input law while allowing the posterior to depend on that law. `exists_distribution_defeating_posteriors` correctly reverses those quantifiers: one law defeats every normalized posterior with the required class mass.

The concrete `NNBayesStatement.lean` declarations were also inspected against the paper. Depth is `r+2`; the restriction `r≥1` is exactly `L≥3`. `realizesAtComplexity` includes positive teacher width, the strict global margin, and coefficient bound `C`. The sample envelope has one exponent outside all architecture quantifiers. The actual finite iid sample probability and the original posterior definitions are used. `ConditionalImpossibility` is explicitly a proposition definition/proof target, not a proved theorem.

`AnalyticCeiling.lean` likewise labels the genuine Gaussian posterior ceiling as a proof target and retains it as an explicit hypothesis in currently proved reduction lemmas. Its integer/logarithm envelopes are conservative versions of the imported conventional theorem. These source declarations must not be described as full formal verification of the neural impossibility result.

## Scope and presentation

The paper correctly distinguishes failure of a universal polynomial guarantee from exponential or stretched-exponential depth lower bounds. Its claim about changing the prior is conditioned on retaining the target class, architecture, inference conventions, and width/distribution quantifiers. Support restriction is identified as one possible change, not the unique remedy or an automatically sufficient one.

The final snapshot incorporates the requested wording clarification: the hard-family comparison class consists of **all** majorities of `400(d+1)` members of the ceiling class, allowing repetitions. It also uses the integer count `A0(1+d+C+L)^k` with a fixed positive integer `A0≥A`, matching the formal resource helper. This is permitted by the guarantee for every sample count above its real envelope. Redundant extra width enlargement/depth padding was removed because the explicit compiler already gives width at least 256 and depth at least d. These final edits were checked and require no weakening of a theorem.

## Final publication-status follow-up

The final source hash above supersedes mathematical snapshot `4e4a1cfa5316492995c94989d28bc555b964a1fcf2500789866f8a2a3b9fd4b3`. The only subsequent manuscript edits added one abstract sentence on formal scope and replaced the final formal-verification paragraph with the completed component list and the exact remaining analytic premise. No theorem statement or mathematical proof changed. These final passages were reread against the concrete declarations, including `conditionalImpossibility_of_posteriorCeiling`, whose `AnalyticPosteriorCeiling` hypothesis is explicit. They correctly state that the main claim has no closed Lean proof from the complexity assumption alone. The release build is recorded separately as passing all 17 modules with only standard foundational axioms; that kernel check does not discharge the analytic hypothesis.
