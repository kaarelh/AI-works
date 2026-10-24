import NeuralGeneralization.BatchTwoNeuralConverseCompressionMoments
import NeuralGeneralization.BatchTwoHilbertBernstein

/-! The explicit dimension-free per-stage tail used by robust compression. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open MeasureTheory ProbabilityTheory
open CompressionSampling
variable {Ω E : Type*} [Fintype Ω] [MeasurableSpace Ω] [MeasurableSingletonClass Ω]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

def sampleAverage (M : ℕ) (Y : Ω → E) (J : Fin M → Ω) : E :=
  ((M : ℝ)⁻¹) • ∑ a,Y (J a)

theorem sampleAverage_centered (M : ℕ) (hM : 0<M) (Y : Ω → E) (c : E) (J : Fin M → Ω) :
    sampleAverage M Y J-c=((M : ℝ)⁻¹) • ∑ a,(Y (J a)-c) := by
  simp only [Finset.sum_sub_distrib,Finset.sum_const,Finset.card_univ,Fintype.card_fin,
    smul_sub,Finset.smul_sum,sampleAverage]
  rw [←Nat.cast_smul_eq_nsmul ℝ M c,smul_smul,inv_mul_cancel₀ (by exact_mod_cast Nat.ne_of_gt hM),one_smul]

theorem finite_source_stage_tail (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Y : Ω → E) {K ρ v : ℝ} (hK : 0<K) (hρ : 0<ρ) (hv : 0≤v)
    (hbound : ∀ j,‖Y j‖≤8*Real.sqrt K*Real.sqrt v/ρ)
    (hvariance : (∫ j,‖Y j‖^2 ∂μ)≤v) (M : ℕ) (hM : 0<M) :
    (iidSamples μ M).real {J | ρ*Real.sqrt v/(4*Real.sqrt K)<
        ‖sampleAverage M Y J-(∫ j,Y j ∂μ)‖}≤
      Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
  have hMR : (0:ℝ)<M := by exact_mod_cast hM
  have hsqrtK : 0<Real.sqrt K := Real.sqrt_pos.mpr hK
  by_cases hv0 : v=0
  · have hY : ∀ j,Y j=0 := by
      intro j
      have hh := hbound j
      simp only [hv0,Real.sqrt_zero,mul_zero,zero_div] at hh
      exact norm_eq_zero.mp (le_antisymm hh (norm_nonneg _))
    simp only [hY,sampleAverage,Finset.sum_const_zero,smul_zero,integral_zero,sub_self,norm_zero,
      hv0,Real.sqrt_zero,mul_zero,zero_div,lt_self_iff_false,Set.setOf_false,measureReal_empty]
    exact (Real.exp_pos _).le
  have hvp : 0<v := lt_of_le_of_ne hv (Ne.symm hv0)
  have hsqrtv : 0<Real.sqrt v := Real.sqrt_pos.mpr hvp
  let X := fun j => Y j-(∫ i,Y i ∂μ)
  let b := 16*Real.sqrt K*Real.sqrt v/ρ
  let t := (M:ℝ)*ρ*Real.sqrt v/(4*Real.sqrt K)
  have hb : 0<b := by dsimp [b]; positivity
  have hX : ∀ j,‖X j‖≤b := by
    intro j
    have hh := finite_centered_norm μ Y hbound j
    convert hh using 1 <;> dsimp [X,b] <;> ring
  have hvar : (∫ j,‖X j‖^2 ∂μ)≤v :=
    (finite_centered_second_moment μ Y).trans hvariance
  have htail := BatchTwoHilbert.iid_hilbert_bernstein μ X (finite_centered_mean μ Y)
    hb hX hvp hvar (by dsimp [t]; positivity : 0≤t) M hM
  have hsub : {J : Fin M → Ω | ρ*Real.sqrt v/(4*Real.sqrt K)<
      ‖sampleAverage M Y J-(∫ j,Y j ∂μ)‖} ⊆ {J | t≤‖∑ a,X (J a)‖} := by
    intro J hJ
    change ρ*Real.sqrt v/(4*Real.sqrt K)<‖sampleAverage M Y J-(∫ j,Y j ∂μ)‖ at hJ
    rw [sampleAverage_centered M hM,norm_smul,Real.norm_eq_abs,abs_of_pos (inv_pos.mpr hMR)] at hJ
    have hh := (lt_inv_mul_iff₀ hMR).mp hJ
    change t≤_
    dsimp [t,X]
    convert hh.le using 1 <;> first | ring | rfl
  have hsK := Real.sq_sqrt hK.le
  have hsv := Real.sq_sqrt hv
  have he1 : t^2/(6*(M:ℝ)*v)=(M:ℝ)*ρ^2/(96*K) := by
    dsimp [t]
    field_simp
    nlinarith only [hsK,hsv]
  have he2 : t/(2*b)=(M:ℝ)*ρ^2/(128*K) := by
    dsimp [t,b]
    field_simp
    nlinarith only [hsK]
  have hcomp : (M:ℝ)*ρ^2/(128*K)≤(M:ℝ)*ρ^2/(96*K) := by
    apply div_le_div_of_nonneg_left (by positivity) (by positivity)
    nlinarith
  rw [he1,he2,min_eq_right hcomp] at htail
  exact (measureReal_mono hsub).trans htail

end
end NeuralGeneralization.BatchTwoNeuralConverse
