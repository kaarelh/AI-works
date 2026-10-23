import NeuralGeneralization.BatchTwoOnlineIIDSampledInfinite
import NeuralGeneralization.BatchTwoOnlineNeuralMain
import NeuralGeneralization.BatchTwoOnlineConfidence
import NeuralGeneralization.BatchTwoOnlinePolynomial

/-!
# Online cumulative learning: both actual uniform protocols

This endpoint combines the exact finite-permutation experiment and the actual
infinite IID experiment. Hypotheses are sampled freshly from their literal
consistency posteriors. The neural endpoints import proved structural bounds,
not capacity or posterior-risk conclusions as assumptions.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling ConcreteModel
variable {H : Type*} [Fintype H] [DecidableEq H] [MeasurableSpace H] [MeasurableSingletonClass H]
variable {m : ℕ} [NeZero m]

def InfiniteIIDBounds (w : H → ℝ) (good : H → Fin m → Prop)
    (hw : ∀ g,0 ≤ w g) (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (h β : ℝ) : Prop :=
  (∫⁻ s,totalError w good s ∂iidQueryLaw (Fin m)) ≤ ENNReal.ofReal (expectationBudget m h β) ∧
  (∫⁻ query,∫⁻ draw,sampledTotal good query draw
    ∂posteriorSampleLaw w good query hw target htarget hwt ∂iidQueryLaw (Fin m)) =
    (∫⁻ s,totalError w good s ∂iidQueryLaw (Fin m)) ∧
  ∀ δ : ℝ, 0 < δ → δ < 1 →
    iidQueryLaw (Fin m) {s | ENNReal.ofReal (highProbabilityBudget m h β δ) < totalError w good s} ≤
      ENNReal.ofReal δ ∧
    (∫⁻ query,posteriorSampleLaw w good query hw target htarget hwt
      {draw | ENNReal.ofReal (highProbabilityBudget m h β δ) < sampledTotal good query draw}
      ∂iidQueryLaw (Fin m)) ≤ ENNReal.ofReal δ

lemma highProbabilityBudget_nonneg (hm : 2 ≤ m) (h β δ : ℝ)
    (hh : 0 ≤ h) (hβ : 0 ≤ β) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 ≤ highProbabilityBudget m h β δ := by
  have he : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hl : 0 ≤ Real.log (1/δ) := Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
  exact (add_nonneg (mul_nonneg he hh) hl).trans
    (prior_tail_le_highProbabilityBudget hm h β δ hh hβ hδ hδ1)

/-- Every exact random-order bound already established above also holds for
the literal infinite IID protocol, with exactly the same constants. -/
theorem iid_bounds_of_randomOrderBounds (hm : 2 ≤ m)
    (w : H → ℝ) (hw : ∀ g,0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (h β : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β) (hb : RandomOrderBounds w good h β) :
    InfiniteIIDBounds w good hw target htarget hwt h β := by
  refine ⟨(iid_expected_totalError_le_permutation (by omega) w hw good target htarget hwt).trans
      (ENNReal.ofReal_le_ofReal hb.1), iid_expected_sampledTotal_eq w good hw target htarget hwt, ?_⟩
  intro δ hδ hδ1
  have hU := highProbabilityBudget_nonneg hm h β δ hh hβ hδ hδ1
  have htail := hb.2.2 δ hδ hδ1
  exact ⟨(iid_totalError_tail_le_permutation (by omega) w hw good target htarget hwt _ hU).trans
      (ENNReal.ofReal_le_ofReal htail.1),
    (iid_sampledTotal_tail_le_permutation (by omega) w good hw target htarget hwt _ hU).trans
      (ENNReal.ofReal_le_ofReal htail.2)⟩

/-- The manuscript's principal statistical theorem, including both uniform
protocols, actual posterior draws, exact harmonic expectation, and both
separate high-probability conclusions. -/
theorem cumulative_errors_both_protocols (hm : 2 ≤ m)
    (w : H → ℝ) (hw : ∀ g,0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (A : Finset H) (hA : target∈A) (h β : ℝ) (hlog : Real.log (A.card : ℝ) ≤ h)
    (hβ : 0 ≤ β) (_hβ1 : β < 1) (htail : (∑ g∈Finset.univ \ A,w g)/w target ≤ β) :
    RandomOrderBounds w good h β ∧ InfiniteIIDBounds w good hw target htarget hwt h β := by
  have hApos : 0 < A.card := Finset.card_pos.mpr ⟨target,hA⟩
  have hh : 0 ≤ h := (Real.log_nonneg (by exact_mod_cast hApos)).trans hlog
  have hcard : (A.card : ℝ) ≤ Real.exp h := by
    calc
      _ = Real.exp (Real.log (A.card : ℝ)) := (Real.exp_log (by exact_mod_cast hApos)).symm
      _ ≤ _ := Real.exp_le_exp.mpr hlog
  have hb := bounds_of_relevant_class (by omega) w hw good target htarget hwt A h β hh hβ hcard htail
  exact ⟨hb,iid_bounds_of_randomOrderBounds hm w hw good target htarget hwt h β hh hβ hb⟩

/-- Fixed query streams admit the infinite direct prior-mass sampled tail,
under the literal product of their actual posterior laws. -/
theorem infinite_sampled_prior_tail (w : H → ℝ) (hw : ∀ g,0 ≤ w g) (hwsum : ∑ g,w g ≤ 1)
    (good : H → Fin m → Prop) (query : ℕ → Fin m)
    (target : H) (htarget : ∀ x,good target x) (hwt : 0 < w target)
    (δ : ℝ) (hδ : 0 < δ) (hδ1 : δ < 1) :
    posteriorSampleLaw w good query hw target htarget hwt
      {draw | ENNReal.ofReal ((Real.exp 1-1)*(-Real.log (w target))+Real.log (1/δ)) <
        sampledTotal good query draw} ≤ ENNReal.ofReal δ := by
  have hwt1 : w target ≤ 1 := (Finset.single_le_sum (fun g _ => hw g) (Finset.mem_univ target)).trans hwsum
  have hJ : 0 ≤ -Real.log (w target) := neg_nonneg.mpr (Real.log_nonpos hwt.le hwt1)
  have hU : 0 ≤ (Real.exp 1-1)*(-Real.log (w target))+Real.log (1/δ) :=
    add_nonneg (mul_nonneg (by linarith [Real.add_one_le_exp (1:ℝ)]) hJ)
      (Real.log_nonneg ((one_le_div hδ).mpr hδ1.le))
  apply infinite_tail_le_of_prefix _ (sampledError good query) (sampledError_nonneg good query) _ hU
  intro n
  rw [posteriorSampleLaw_prefix_event]
  exact ENNReal.ofReal_le_ofReal (sequentialMistakes_prior_tail w hw hwsum good query target htarget hwt n δ hδ)

/-- The neural conclusion covers both protocols and includes positive target
mass, so the displayed infinite posterior product laws are well defined. -/
def NetworkOnlineBounds {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) (P : ℝ) : Prop :=
  NetworkRandomOrderBounds φ a μ f P ∧
  ∃ hf : 0 < functionMass φ a μ f,
    InfiniteIIDBounds (functionMass φ a μ)
      (fun g i => g (cubeEnumeration d i)=f (cubeEnumeration d i))
      (functionMass_nonneg φ a μ) f (fun _ => rfl) hf P (1/Fintype.card (Cube d))

lemma network_online_of_randomOrder {d N r : ℕ} (hd : 1 ≤ d)
    (φ : ℝ → ℝ) (a : ℝ) (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (P : ℝ) (hP : 0 ≤ P) (hf : 0 < functionMass φ a μ f)
    (hb : NetworkRandomOrderBounds φ a μ f P) : NetworkOnlineBounds φ a μ f P := by
  refine ⟨hb,hf,?_⟩
  exact iid_bounds_of_randomOrderBounds (cube_card_ge_two d hd) _
    (functionMass_nonneg φ a μ) _ f (fun _ => rfl) hf P _ hP (by positivity) hb

/-- Strong-prior cumulative learning, every admissible width, both protocols.
A single sufficiently small positive variance is fixed for the entire run. -/
theorem strongPrior_online_bounds {d C N r : ℕ}
    (hd : 1 ≤ d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      NetworkOnlineBounds φ (1/2) (smallPrior d N r σ) f (strongCapacity d r C) := by
  obtain ⟨σ₀,hσ₀,hbounds⟩ := strongPrior_randomOrder_bounds hd φ hφ f hf hCN
  refine ⟨σ₀,hσ₀,fun σ hσ hσlt => ?_⟩
  exact network_online_of_randomOrder hd φ (1/2) _ f _ (by positivity)
    (small_functionMass_pos (by omega) (admissibleActivation_continuous hφ) f hf hCN hσ)
    (hbounds σ hσ hσlt)

/-- Mean-field tanh cumulative learning at every width above the teacher's,
with the same polynomial budget for both entire sampling protocols. -/
theorem meanField_online_bounds {d C N r : ℕ}
    (hd : 1 ≤ d) (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hCN : C ≤ N) : NetworkOnlineBounds Real.tanh (1/2) (powerPrior d N r 1) f
      (MeanFieldLearningBudget.sampleBudget r d (C+d)) := by
  have hmass := meanField_target_mass_polynomial (by omega) Real.tanh tanh_admissible f hf hCN
  exact network_online_of_randomOrder hd Real.tanh (1/2) _ f _ (by positivity)
    ((Real.exp_pos _).trans_le hmass) (meanField_randomOrder_bounds hd f hf hCN)

/-- All fixed exponents above mean field, every admissible activation and
learner width, with one width-independent polynomial budget. -/
theorem aboveMeanField_online_bounds (r : ℕ) (γ : ℝ) (hγ : 1 < γ) :
    ∃ P : ℕ → ℕ → ℕ, PolynomialGrowth2 P ∧
      ∀ d C N : ℕ, 1 ≤ d → ∀ φ : ℝ → ℝ, admissibleActivation φ →
        ∀ f : BooleanFunction d, realizesAtComplexity (r := r) φ f C → C ≤ N →
          NetworkOnlineBounds φ (1/2) (powerPrior d N r γ) f (P d C) := by
  obtain ⟨P,hP,hbounds⟩ := aboveMeanField_randomOrder_bounds r γ hγ
  refine ⟨P,hP,?_⟩
  intro d C N hd φ hφ f hf hCN
  have hmass := powerPrior_target_mass_polynomial (by omega) φ hφ f hf hCN hγ.le
  exact network_online_of_randomOrder hd φ (1/2) _ f _ (by positivity)
    ((Real.exp_pos _).trans_le hmass) (hbounds d C N hd φ hφ f hf hCN)

end NeuralGeneralization.BatchTwoOnline
