import NeuralGeneralization.GaussianMarginClipping

/-! # Fixed-margin endpoint confidence from explicit posterior moments

The threshold is buffered at 13/20, strictly below 2/3, so the result can
be transferred through ordinary posterior convergence. The prediction is
the actual posterior sign probability, not the sign of its mean.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianMarginConfidence
open GaussianMarginClipping ConfidenceClipping
variable {d u : ℕ}

def drawRisk (z : ClippingCube d → ℝ) : ℝ :=
  uniformCubeMean (fun x => if 0 < fullParity x*z x then (0:ℝ) else 1)

def amplitudeFraction (b : ℝ) (z : ClippingCube d → ℝ) : ℝ :=
  uniformCubeMean (fun x => if |z x| ≤ b then (1:ℝ) else 0)

def confidence (μ : Measure (ClippingCube d → ℝ)) (x : ClippingCube d) : ℝ :=
  μ.real {z | 0 < fullParity x*z x}

lemma integrable_amplitudeFraction (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ]
    (b : ℝ) : Integrable (amplitudeFraction b) μ := by
  exact (GaussianAmplitude.integrable_smallMeanCount μ id measurable_id b).div_const _

lemma integrable_error_indicator (μ : Measure (ClippingCube d → ℝ)) [IsFiniteMeasure μ]
    (x : ClippingCube d) : Integrable (fun z => if 0 < fullParity x*z x then (0:ℝ) else 1) μ := by
  apply Integrable.of_bound
    ((measurable_const.ite (measurableSet_lt measurable_const
      ((measurable_pi_apply x).const_mul _)) measurable_const).aestronglyMeasurable) 1
  exact Filter.Eventually.of_forall fun z => by split_ifs <;> norm_num

lemma integrable_drawRisk (μ : Measure (ClippingCube d → ℝ)) [IsFiniteMeasure μ] :
    Integrable (drawRisk (d:=d)) μ := by
  unfold drawRisk uniformCubeMean
  exact (integrable_finsetSum _ (fun x _ => integrable_error_indicator μ x)).div_const _

lemma risk_eq_mean_confidence (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ] :
    (∫ z, drawRisk z ∂μ) = uniformCubeMean (fun x => 1-confidence μ x) := by
  have hi (x : ClippingCube d) :
      (∫ z, if 0 < fullParity x*z x then (0:ℝ) else 1 ∂μ) = 1-confidence μ x := by
    let E : Set (ClippingCube d → ℝ) := {z | 0 < fullParity x*z x}
    have hE : MeasurableSet E := measurableSet_lt measurable_const ((measurable_pi_apply x).const_mul _)
    have he : (fun z => if 0 < fullParity x*z x then (0:ℝ) else 1) = Eᶜ.indicator 1 := by
      funext z
      by_cases hz : 0 < fullParity x*z x <;> simp [E, hz]
    rw [he, integral_indicator_one hE.compl, probReal_compl_eq_one_sub hE]
    rfl
  unfold drawRisk uniformCubeMean
  rw [integral_div, integral_finsetSum _ (fun x _ => integrable_error_indicator μ x)]
  simp_rw [hi]

lemma risk_le_failure (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ] :
    (∫ z, drawRisk z ∂μ) ≤ 7/20+(13/20)*failure (confidence μ) (13/20) := by
  rw [risk_eq_mean_confidence]
  have hp (x : ClippingCube d) : 1-confidence μ x ≤
      7/20+(13/20)*(if confidence μ x ≤ 13/20 then (1:ℝ) else 0) := by
    have hq : 0 ≤ confidence μ x := measureReal_nonneg
    split_ifs with hh <;> linarith
  have hh := mean_mono _ _ hp
  convert! hh using 1
  unfold ConfidenceClipping.failure fraction uniformCubeMean
  simp only [Set.mem_setOf_eq, Finset.sum_add_distrib, ← Finset.mul_sum,
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- Exact moment-budget closing argument for the actual field posterior.
All quantities are posterior moments of concrete fields. -/
theorem risk_lower_of_moment_budgets (hd : 0 < d)
    (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ]
    (c : (ClippingCube d → ℝ) → Finset (Fin d) → ℝ)
    (hdegree : ∀ z S, c z S ≠ 0 → S.card ≤ u)
    (b : ℝ) (hb : 0 < b)
    (hiH : Integrable (fun z => uniformCubeMean (fun x => walshExpansion (c z) x^2)) μ)
    (hiT : Integrable (fun z => uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2)) μ)
    (hhead : (u:ℝ)^2*(∫ z, uniformCubeMean (fun x => walshExpansion (c z) x^2) ∂μ) ≤
      (b*(d:ℝ))^2/256)
    (htail : (∫ z, uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2) ∂μ) ≤ b^2/256)
    (hamp : (∫ z, amplitudeFraction b z ∂μ) ≤ 1/32) :
    (25:ℝ)/64 ≤ ∫ z, drawRisk z ∂μ := by
  let H := fun z => uniformCubeMean (fun x => walshExpansion (c z) x^2)
  let T := fun z => uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2)
  let C : ℝ := 4*((u:ℝ)^2/((b*(d:ℝ))^2))
  let Q : ℝ := 4/b^2
  have hiA := integrable_amplitudeFraction μ b
  have hiL : Integrable (fun z => (1-(1/8+C*H z+Q*T z+2*amplitudeFraction b z))/2) μ :=
    ((integrable_const 1).sub ((((integrable_const (1/8)).add (hiH.const_mul C)).add
      (hiT.const_mul Q)).add (hiA.const_mul 2))).div_const 2
  have hh := integral_mono hiL (integrable_drawRisk μ)
    (fun z => draw_risk_lower hd (c z) (hdegree z) z b hb)
  have hlin : (∫ z, (1-(1/8+C*H z+Q*T z+2*amplitudeFraction b z))/2 ∂μ) =
      (1-(1/8+C*(∫ z, H z ∂μ)+Q*(∫ z, T z ∂μ)+2*(∫ z, amplitudeFraction b z ∂μ)))/2 := by
    have i0 : Integrable (fun z => (1/8:ℝ)+C*H z) μ := (integrable_const _).add (hiH.const_mul C)
    have i1 : Integrable (fun z => (1/8:ℝ)+C*H z+Q*T z) μ := i0.add (hiT.const_mul Q)
    have i2 : Integrable (fun z => (1/8:ℝ)+C*H z+Q*T z+2*amplitudeFraction b z) μ := i1.add (hiA.const_mul 2)
    rw [integral_div, integral_sub (f:=fun _ => (1:ℝ))
      (g:=fun z => (1/8:ℝ)+C*H z+Q*T z+2*amplitudeFraction b z) (integrable_const _) i2,
      integral_add (f:=fun z => (1/8:ℝ)+C*H z+Q*T z)
        (g:=fun z => 2*amplitudeFraction b z) i1 (hiA.const_mul 2),
      integral_add (f:=fun z => (1/8:ℝ)+C*H z) (g:=fun z => Q*T z) i0 (hiT.const_mul Q),
      integral_add (f:=fun _ => (1/8:ℝ)) (g:=fun z => C*H z) (integrable_const _) (hiH.const_mul C)]
    simp only [integral_const_mul, integral_const, measureReal_univ_eq_one, smul_eq_mul, one_mul]
  rw [hlin] at hh
  have hbd : 0 < (b*(d:ℝ))^2 := by positivity
  have hH : C*(∫ z, H z ∂μ) ≤ 1/64 := by
    calc
      C*(∫ z, H z ∂μ) = 4*((u:ℝ)^2*(∫ z, H z ∂μ))/((b*(d:ℝ))^2) := by dsimp [C]; ring
      _ ≤ 1/64 := by
        apply (div_le_iff₀ hbd).mpr
        dsimp [H]
        linarith [hhead]
  have hT : Q*(∫ z, T z ∂μ) ≤ 1/64 := by
    have hm := mul_le_mul_of_nonneg_left htail (show 0 ≤ 4/b^2 by positivity)
    dsimp [Q, T]
    have he : (4/b^2)*(b^2/256)=(1:ℝ)/64 := by field_simp [hb.ne']; norm_num
    rwa [he] at hm
  linarith

/-- The buffered threshold makes ordinary posterior limits sufficient for
the original strict two-thirds confidence criterion. -/
theorem failure_lower_of_moment_budgets (hd : 0 < d)
    (μ : Measure (ClippingCube d → ℝ)) [IsProbabilityMeasure μ]
    (c : (ClippingCube d → ℝ) → Finset (Fin d) → ℝ)
    (hdegree : ∀ z S, c z S ≠ 0 → S.card ≤ u)
    (b : ℝ) (hb : 0 < b)
    (hiH : Integrable (fun z => uniformCubeMean (fun x => walshExpansion (c z) x^2)) μ)
    (hiT : Integrable (fun z => uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2)) μ)
    (hhead : (u:ℝ)^2*(∫ z, uniformCubeMean (fun x => walshExpansion (c z) x^2) ∂μ) ≤
      (b*(d:ℝ))^2/256)
    (htail : (∫ z, uniformCubeMean (fun x => (z x-walshExpansion (c z) x)^2) ∂μ) ≤ b^2/256)
    (hamp : (∫ z, amplitudeFraction b z ∂μ) ≤ 1/32) :
    (1:ℝ)/16 ≤ failure (confidence μ) (13/20) := by
  have hr := risk_lower_of_moment_budgets hd μ c hdegree b hb hiH hiT hhead htail hamp
  have hf := risk_le_failure μ
  linarith

end NeuralGeneralization.GaussianMarginConfidence
