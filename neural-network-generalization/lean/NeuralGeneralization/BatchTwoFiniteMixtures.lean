import NeuralGeneralization.RobustStatistics
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Probability.ProbabilityMassFunction.Integrals

/-! Averaging a measurable finite probability family over an arbitrary
probability measure. Nonnegativity is only needed almost everywhere. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoFiniteMixtures
variable {W H : Type*} [MeasurableSpace W] [Fintype H]
  [MeasurableSpace H] [MeasurableSingletonClass H]

theorem weight_le_one (p : H → ℝ) (hp : ∀ h, 0 ≤ p h) (hs : ∑ h, p h=1) (h : H) : p h ≤ 1 := by
  classical
  have hh := Finset.single_le_sum (fun i _ => hp i) (Finset.mem_univ h)
  rwa [hs] at hh

theorem integrable_weights (Q : Measure W) [IsProbabilityMeasure Q] (p : W → H → ℝ)
    (hm : ∀ h, Measurable (fun w => p w h))
    (hp : ∀ᵐ w ∂Q, ∀ h, 0 ≤ p w h) (hs : ∀ᵐ w ∂Q, ∑ h, p w h=1) (h : H) :
    Integrable (fun w => p w h) Q := by
  apply (integrable_const (1 : ℝ)).mono' (hm h).aestronglyMeasurable
  filter_upwards [hp, hs] with w hw hw'
  rw [Real.norm_eq_abs, abs_of_nonneg (hw h)]
  exact weight_le_one (p w) hw hw' h

theorem exists_averaged_law (Q : Measure W) [IsProbabilityMeasure Q] (p : W → H → ℝ)
    (hm : ∀ h, Measurable (fun w => p w h))
    (hp : ∀ᵐ w ∂Q, ∀ h, 0 ≤ p w h) (hs : ∀ᵐ w ∂Q, ∑ h, p w h=1) :
    ∃ Γ : Measure H, IsProbabilityMeasure Γ ∧
      ∀ g : H → ℝ, (∫ h, g h ∂Γ) = ∫ w, (∑ h, p w h*g h) ∂Q := by
  classical
  let q : H → ℝ := fun h => ∫ w, p w h ∂Q
  have hq (h : H) : 0 ≤ q h := integral_nonneg_of_ae (hp.mono fun _ hw => hw h)
  have hi := integrable_weights Q p hm hp hs
  have hsum : ∑ h, q h=1 := by
    dsimp only [q]
    rw [← integral_finsetSum Finset.univ (fun h _ => hi h)]
    calc _ = ∫ _w, (1 : ℝ) ∂Q := integral_congr_ae hs
         _ = 1 := by simp
  let P : PMF H := PMF.ofFintype (fun h => ENNReal.ofReal (q h)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun h _ => hq h), hsum, ENNReal.ofReal_one])
  refine ⟨P.toMeasure, by infer_instance, ?_⟩
  intro g
  rw [PMF.integral_eq_sum]
  simp only [P, PMF.ofFintype_apply, ENNReal.toReal_ofReal (hq _), smul_eq_mul]
  rw [integral_finsetSum Finset.univ (fun h _ => (hi h).mul_const (g h))]
  simp only [integral_mul_const, q]

theorem finite_law_integral (P : Measure H) [IsProbabilityMeasure P] (g : H → ℝ) :
    (∫ h, g h ∂P) = ∑ h, P.real {h}*g h := by
  rw [integral_fintype (RobustStatistics.integrable_finite_domain P g)]
  simp only [smul_eq_mul]

theorem product_singleton {m : ℕ} (P : Measure H) [IsProbabilityMeasure P] (a : Fin m → H) :
    (CompressionSampling.iidSamples P m).real {a} = ∏ i, P.real {a i} := by
  have hs : ({a} : Set (Fin m → H)) = Set.pi Set.univ (fun i => {a i}) := by
    ext b
    simp only [Set.mem_singleton_iff, Set.mem_pi, Set.mem_univ, forall_const]
    exact ⟨fun h i => congrFun h i, fun h => funext h⟩
  rw [hs, CompressionSampling.iidSamples, Measure.real, Measure.pi_pi,
    ENNReal.toReal_prod]
  rfl

end NeuralGeneralization.BatchTwoFiniteMixtures
