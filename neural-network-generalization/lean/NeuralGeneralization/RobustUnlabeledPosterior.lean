import NeuralGeneralization.UnlabeledStabilityPosterior
import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.RobustTargetAllWidths
import NeuralGeneralization.BatchTwoImprovedGlobalPosterior

/-! The actual input-adapted Gaussian posterior used in the unlabeled-pool
variant, including optional all-input clean-margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel UnlabeledStability
variable {d C N r m n : ℕ}

def inputSupport (c : ℝ) (U : Fin m → Cube d) (S : Fin n → Cube d) : Set (Weights d N r) :=
  poolEvent (stableAt Real.tanh c) U ∩ poolEvent (stableAt Real.tanh c) S

def posteriorEvent (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (U : Fin m → Cube d) (S : Fin n → Cube d) : Set (Weights d N r) :=
  inputSupport c U S ∩ RobustPosterior.trainingMarginEvent Real.tanh f S ∩
    (if globalMargin then globalMarginEvent Real.tanh (1/2) else Set.univ)

def posterior (c σ : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (U : Fin m → Cube d) (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent c globalMargin f U S)

lemma measurable_posteriorEvent {c : ℝ} (hc : 0 < c) (globalMargin : Bool)
    (f : BooleanFunction d) (U : Fin m → Cube d) (S : Fin n → Cube d) :
    MeasurableSet (posteriorEvent (N := N) (r := r) c globalMargin f U S) := by
  apply MeasurableSet.inter
  · exact ((measurable_poolEvent _ (measurable_stableAt tanh_continuous hc) U).inter
      (measurable_poolEvent _ (measurable_stableAt tanh_continuous hc) S)).inter
      (RobustPosterior.measurable_trainingMarginEvent tanh_continuous f S)
  · cases globalMargin
    · exact MeasurableSet.univ
    · exact BatchTwoImprovedGlobalPosterior.measurable_globalMarginEvent tanh_continuous

lemma target_subset (c : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (U : Fin m → Cube d) (S : Fin n → Cube d) :
    robustEvent (N := N) (r := r) Real.tanh c ∩ marginEvent Real.tanh (1/2) f ⊆
      posteriorEvent c globalMargin f U S := by
  intro w hw
  refine ⟨⟨⟨fun i => hw.1 (U i), fun i => hw.1 (S i)⟩,fun i => hw.2 (S i)⟩,?_⟩
  cases globalMargin
  · trivial
  · exact marginEvent_subset_global Real.tanh (1/2) f hw.2

/-- Every pool and every labeled sample retain the actual target cylinder. -/
theorem target_mass (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (U : Fin m → Cube d) (S : Fin n → Cube d) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real (posteriorEvent c globalMargin B.computes U S) :=
  (robust_boolean_target_mass hd B hCN hc hσ hscale).trans
    (measureReal_mono (target_subset c globalMargin B.computes U S))

theorem posterior_probability (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (U : Fin m → Cube d) (S : Fin n → Cube d) :
    IsProbabilityMeasure (posterior (N := N) (r := r) c σ globalMargin B.computes U S) := by
  apply cond_isProbabilityMeasure
  have hp := (Real.exp_pos _).trans_le (target_mass hd B hCN hc hσ hscale globalMargin U S)
  intro hz
  simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
  exact (lt_irrefl 0) hp

/-- The literal Gaussian posterior entropy is bounded without an oracle. -/
theorem posterior_entropy (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (U : Fin m → Cube d) (S : Fin n → Cube d) :
    klDiv (posterior (N := N) (r := r) c σ globalMargin B.computes U S) (smallPrior d N r σ) ≤
      ENNReal.ofReal (digitalMassPolynomial d C r c/σ^2) := by
  apply RobustPosterior.klDiv_cond_le_of_mass_lower _ _ (measurable_posteriorEvent hc globalMargin B.computes U S)
  simpa only [neg_div] using target_mass hd B hCN hc hσ hscale globalMargin U S

/-- The paper's unlabeled-data allocation gives posterior mean instability
at most ε/4, uniformly over all later sample sizes and labeled input lists. -/
theorem posterior_instability_quarter (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c σ ε δ : ℝ} (hc : 0 < c) (hσ : 0 < σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (m : ℕ)
    (hbudget : (8/ε)*(digitalMassPolynomial d C r c/σ^2+Real.log (2/δ)) ≤ m) :
    ∃ E : Set (Fin m → Cube d), MeasurableSet E ∧
      1-δ/2 ≤ (Measure.pi (fun _ : Fin m => D)).real E ∧
      ∀ U ∈ E, ∀ n : ℕ, ∀ S : Fin n → Cube d, ∀ globalMargin : Bool,
        (∫ w,instability D (stableAt Real.tanh c) w
          ∂posterior (N := N) (r := r) c σ globalMargin B.computes U S) ≤ ε/4 := by
  let K := digitalMassPolynomial d C r c/σ^2
  have hK : 0 ≤ K := div_nonneg (digitalMassPolynomial_nonneg d C r c) (sq_nonneg σ)
  have hlog : 0 < Real.log (2/δ) := Real.log_pos ((lt_div_iff₀ hδ).mpr (by linarith))
  have hm : 0 < m := by
    have hp : 0 < (8/ε)*(K+Real.log (2/δ)) := by positivity
    exact_mod_cast hp.trans_le hbudget
  obtain ⟨E,hE,hprob,hbound⟩ := conditioned_pool_coverage (smallPrior d N r σ) D
    (stableAt Real.tanh c) (measurable_stableAt tanh_continuous hc) m hm
    (show 0 < δ/2 by positivity)
  refine ⟨E,hE,hprob,?_⟩
  intro U hU n S globalMargin
  have hh := (hbound U hU (posteriorEvent c globalMargin B.computes U S)
    (measurable_posteriorEvent hc globalMargin B.computes U S)
    (fun _ hw => hw.1.1.1) K hK (by
      simpa only [K,neg_div] using target_mass hd B hCN hc hσ hscale globalMargin U S)).2
  have hid : 1/(δ/2) = 2/δ := by ring
  rw [hid] at hh
  apply hh.trans
  have hmp : (0:ℝ) < m := by exact_mod_cast hm
  apply (le_div_iff₀ (by norm_num : (0:ℝ) < 4)).mpr
  have hb := (div_le_iff₀ hε).mp (show 8*(K+Real.log (2/δ))/ε ≤ m by
    simpa only [div_mul_eq_mul_div] using hbudget)
  apply (mul_le_mul_iff_left₀ hmp).mp
  have hid2 : ((2/(m:ℝ))*(K+Real.log (2/δ))*4)*(m:ℝ) = 8*(K+Real.log (2/δ)) := by field_simp; ring
  rw [hid2]
  nlinarith

end NeuralGeneralization.RobustUnlabeled
