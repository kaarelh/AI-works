# Statement audit: activation learning and polynomial depth

Reviewed snapshot: `7c69c4abe5f93476d59c95b4d04d13b33ff01301` (23 October 2026).

This is a fresh source-level comparison of the two manuscripts with the exported Lean theorem statements and the definitions they use. It checks mathematical correspondence, separately from the already recorded kernel/build verification. It is an AI-agent review, not human peer review or an independent reimplementation of all proofs.

**Finding:** the activation paper's main statements match. The ReLU/GELU polynomial-depth endpoints match their numerical formulas, distributions, support restriction and quantifiers, but its Boolean-circuit convention needs an explicit qualification: the formal circuit reserves a counted constant-one wire at every stage, including the final stage. The manuscript's shorter phrase “constant wires count” does not by itself impose that requirement. This matters at the claimed exact width threshold, as detailed below. No other substantive statement mismatch was found.

## 1. ReLU, GELU, and general Lipschitz activations

Manuscript: [paper.tex](../../../works-in-progress/unbounded-activations/source/paper.tex), especially the model at lines 38–72, summary theorem at 74–86, capacity formula at 185–193, strong-prior theorem at 223–229, and [uniform-supercritical.tex](../../../works-in-progress/unbounded-activations/source/uniform-supercritical.tex), lines 67–106.

Compared with:

- `BatchTwoActivationStrongManuscript.lean:33`, `strong_prior_manuscript_learning`;
- `BatchTwoActivationManuscriptMain.lean:13`, `uniform_manuscript_learning`;
- `BatchTwoActivationStatements.lean:27`, `zeroLipschitzActivation`, and line 44, `activationBandPrior`;
- `BatchTwoActivationUniformMain.lean:23`, the independently assembled existential-polynomial endpoint;
- `BatchTwoActivationManuscriptBudgets.lean:12–18,77–100,145–158` and `BatchTwoActivationUniformManuscript.lean:17–43` for the displayed budgets and the enlarged endpoint polynomial;
- `BatchTwoActivationGelu.lean:61`, `exact_same_depth_gelu_compilation`.

### Model and hypotheses

`Network.lean` defines an actual first matrix, `r` internal matrices and a linear readout, so paper depth is `L=r+2` and hidden-layer count is `H=r+1`. The augmented constant coordinate appears first in Lean rather than last in some manuscript displays, which is only a fixed coordinate permutation. All hidden layers have the stated equal width. `realizesAtComplexity` (line 135) requires a genuine width-`C` implementation, every weight bounded by `C`, and strict target margin `>1/2` on every Boolean input. It does not assume minimality, which the manuscript does not require either. The input cube uses Boolean coordinates with `labelReal` mapping to minus/plus one.

`zeroLipschitzActivation` requires exactly zero at zero and the stipulated global Lipschitz inequality. It does not accidentally reuse the older bounded-activation predicate. The assumption `1≤ℓ` agrees with the model section. `Model.lean:33–47` defines independent centered Gaussian coordinates with first variance `(N/d)σ²`, internal variance `σ²`, and readout variance `σ²/N`. Substitution `σ=t/√N` gives exactly `t²/d,t²/N,t²/N²`; all eligible widths are positive.

`FunctionPrior.lean:69–101` assigns each Boolean function the raw mass of its strict global-margin event and then normalizes over functions consistent with the observed labels. These events are disjoint and their union is the global absolute-margin event (`Network.lean:83–108`), so cancellation of the first normalizer gives the intended two-stage posterior. This is not an unconditioned sign posterior. `posteriorRisk` (line 134) averages the true sign error over the full posterior, while `sampleProbability` (line 150) is the exact IID product probability for the arbitrary `InputLaw`. Posterior positivity is an explicit conclusion, so the learning theorem is not made vacuous by a zero denominator.

### Strong-prior statement

The exact printed teacher budget is `d(d+1)C²+(r+2)C⁴`, and `manuscriptLogCapacity` is the printed natural ceiling of the cubic capacity expression, times `log(2^d+1)`. The theorem uses the exact leading `2/ε` and `B(B_*+1)` formula.

The function of thresholds `σ₀ : ℕ → ℝ` is chosen before the input distribution, confidence parameter, and sample count. It may depend on the fixed target, depth, activation, dimension, complexity witness, and accuracy, as allowed in the paper. Inside one sample-probability event, the conclusion quantifies over every `N≥C` and every `0<σ<σ₀ N`. This verifies the stronger common-event sentence as well as the width-by-width statement. Lean permits every positive `δ`; restricting to `δ<1` recovers the paper's meaningful range and is not an added hypothesis.

### Uniform finite-scale statement

The polynomial choices occur before the activation, dimension, target, teacher width, distribution and statistical parameters. The conclusion places `∀N≥C, ∀0<t≤1` *inside* one sample event, precisely matching the manuscript's simultaneous claim. The theorem also asserts positive training normalizers for every sample.

The combined-energy definitions match `K_s,t_*,K_m,N_*,D_*,J_0,J_*` after substituting `L=r+2`. The endpoint polynomials are existential, not printed fixed coefficients: the formalization chooses positive polynomial envelopes and enlarges the energy polynomial before using the displayed `B(J_*)` formula. This is a legitimate choice within the manuscript statement, not a certification of one particular minimal endpoint polynomial. The envelope bounds include real energy arguments via upward rounding. `BatchTwoActivationEndpointEnergyWitness.actual_good_network_energy_witness` supplies an actual auxiliary implementation with the stated bounded energy; the final learning endpoint has no reconstruction or target-mass oracle hypothesis.

The heterogeneous auxiliary activations are part of the paper's counting class, not the learner. `networkPosterior` throughout still evaluates the one fixed activation `φ`. The GELU compiler uses `gelu x = x * cdf (gaussianReal 0 1) x`, not a tanh approximation; its theorem constructs an actual width-`2C`, same-depth network with weights at most four and output exactly the target sign. The formal compiler's treatment of the constant wire differs internally from the displayed proof but preserves every claim of the compiler proposition.

The main endpoints give posterior-average error. The stated strict `>2/3` interpretation uses the separate average-risk-to-confidence inequality and accuracy `ε/3`. It should not be described as an unchanged-ε confidence conclusion from the average-risk theorem.

## 2. Polynomial-depth learning under population merging

Manuscript: [paper.tex](../../../works-in-progress/relu-gelu-polynomial-depth/source/paper.tex), model/support at lines 28–51, target/budgets and main theorem at 53–83, quadratic corollary at 90–97, GELU budgets/theorem at 224–263.

Compared with:

- `BatchTwoMergingModel.lean:29–38,70–103,124–139,168–203,217–229`;
- `BatchTwoMergingSharpMain.lean:30,55`, `manuscript_relu_learning` and `manuscript_gelu_learning`;
- `BatchTwoMergingSharpScales.lean:24,38,72,117`, the positive-normalizer and literal-`t` corollaries;
- `BatchTwoMergingSharpBudgets.lean:10–24`, `BatchTwoMergingSharpTarget.lean:12–20`, `BatchTwoMergingSharpRadius.lean:7–12`, `BatchTwoMergingSharpMass.lean:13–15`;
- `BatchTwoMergingPolynomialMain.lean:31`, `BatchTwoMergingGeluPolynomialMain.lean:17` and `BatchTwoMergingSharpWidthAsymptotics.lean:163–178`.

### Actual support and circuit class

A partition is a surjective neuron-label map, so all populations are nonempty, of arbitrary size. `populationProjection` has entries `1/k` within a population and zero elsewhere, exactly `FFᵀ` for the normalized indicator columns. `mergedWeights` applies `P₁W¹`, `P_sW^sP_(s−1)` and `P_Hv` to the actual finite-network weights. There is no substituted compressed learner.

The support requires the clipped-output discrepancy at most `1/16` on all cube inputs. Its energy inequality is written separately for each layer and input, with coefficient `(q_s:ℝ)-1`. The lemma `population_budget_iff_maxima` proves equivalence to the paper's `(max_s q_s−1)(max_x |z_w(x)|)² ≤ 4E_v`. Nonnegative coefficients follow from positive width and nonempty populations. The use of `max(-1/2,min(1/2,z))` instead of `min(1/2,max(-1/2,z))` is the same clipping function.

`restrictedSupport` explicitly intersects with the global-margin event only when the Boolean switch requests it. `posteriorEvent` then intersects with signed training margin `>1/2`. `posterior_eq_two_stage` identifies the single conditional measure with the two-stage conditioning in the paper. `gibbsMarginRisk` integrates the posterior probability of signed output `≤1/4`, exactly the main test loss; a finite-input integral-interchange lemma identifies it with the displayed expectation over networks followed by test inputs. Full posterior mixtures are retained.

`LayeredNorCircuit` (`BatchTwoMergingCircuit.lean:104–127`) specifies actual NOR, COPY and NOT gates, a counted constant wire copied at every layer, one selected output, and `r+1` stages. This is the explicit convention of the unbounded-activation compiler manuscript (`paper.tex:245`). However, the polynomial-depth manuscript at line 54 only says “Constant wires count toward C”; it should explicitly require a constant-one wire at every stage, including the final stage, to match the formal definition. Layers of width at most `C` can then be padded with copies, counting those resources. The ReLU threshold is `N≥C`; GELU correctly requires `N≥2C`. Exact GELU is again the standard-normal-CDF activation.

This is more than a cosmetic possibility: if “width C” instead allowed a one-wire, one-stage COPY circuit for a nonconstant literal without a final constant wire, then `C=N=1` would be allowed by a broad reading of the ReLU theorem. A width-one ReLU network with a bias-free linear readout has output `v max(0,a·x+b)`, of one weak sign everywhere. It cannot fit strict positive and negative training margins simultaneously, contradicting the stated positivity for all samples. The formal theorem excludes this interpretation. For circuits without the reserved wire, adding one to every stage yields the valid `N≥C+1` ReLU threshold (and `N≥2(C+1)` via the GELU compiler). The manuscript must either adopt the formal counted-wire convention explicitly or state this overhead.

### Constants and quantifier order

The definitions expand to the printed `b_L,S₀,D₀,ρ,q₀,B₀,D_*` with `a=4`, and to the GELU replacements with `D=2C`. In particular `256=64a` in the radius, and the energy constants are `d+10rC+160C` (ReLU) and `d+100rD+1600D` (GELU). The `B,Q,J,R,ζ` and grid-coordinate counts expand to the paper's formulas, including the extra `HQ` GELU coordinates and its factor-four amplification. Both main theorems use the printed `2/ε` sample prefactor.

The sample event is chosen before learner width, positive scale, and the optional global-margin switch. The condition `Nσ²≤1` is equivalent to `0<t≤1` under `σ=t/√N`, and the separate `*_learning_meanfield` endpoints make that parameterization literal. Both support and subsequent training normalizers are proved positive for every sample, separately from the sample-count assumption.

The literal quadratic corollaries have one fixed universal numerical constant, `C²(2+d+L+log(4/ε))⁹`, and the same width/scale simultaneity. The GELU corollary retains `N≥2C`. The arbitrary universal constant in the manuscript permits the conservative concrete constants used in Lean. The `O(C² log³(C+2))` bounds are proved for the actual displayed numerical sufficient-sample budgets with the other parameters fixed, rather than for a surrogate budget.

## Scope retained in public summaries

Subject to making the polynomial-depth manuscript's counted-wire convention explicit, these two papers' stated main learning results are covered. Neither result says the structural condition holds for typical gradient-trained networks; neither identifies arbitrary analog teacher width with Boolean-circuit width. The unrestricted activation result remains fixed-depth polynomial, and the population-merging theorem changes the prior support. These are genuine model restrictions already present in both the manuscripts and the formal statements. The counted-wire ambiguity above is the only new statement-correspondence issue found; no hidden analytic premise or other erroneous formalization label was found in this audit.

## Resolution in the publication update

The revised ReLU/GELU manuscript now explicitly requires a constant-one wire at every stage, including the final stage, counted in `C`. It states the conversion `C=C₀+1` for circuits without that wire and therefore the sufficient learner thresholds `N≥C₀+1` for ReLU and `N≥2(C₀+1)` for GELU. It also explains the width-one ReLU obstruction. I checked the actual source diff, the paper README, and FAQ Questions 25 and 40: they consistently state this corrected convention. This resolves the identified ambiguity; the corrected main paper statements match the existing formal endpoints. No Lean definition or theorem was changed to obtain this match. The review above preserves the finding against the original reviewed snapshot.
