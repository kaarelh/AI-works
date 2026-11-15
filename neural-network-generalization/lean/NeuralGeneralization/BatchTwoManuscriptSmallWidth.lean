import NeuralGeneralization.BatchTwoManuscriptResources
import NeuralGeneralization.RobustCouplingSmallWidth

/-! The displayed small-width cutoff controls the actual physical weights. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel

theorem parameterCount_eq (p : Input) (N : ℕ) :
    parameterCount p.dimension N p.depth=robustParameterCount p.dimension N (p.depth-2) := by
  simp only [parameterCount,robustParameterCount,pow_two,mul_assoc]

theorem smallBound_pos (p : Input) : 0<smallBound p := by
  unfold smallBound
  apply Real.sqrt_pos.mpr
  have hM : (0:ℝ)<widthBound p := Nat.cast_pos.mpr (widthBound_pos p)
  have hK := energy_pos p
  have hl := Real.log_pos (by norm_num : (1:ℝ)<2)
  exact div_pos (by positivity) p.failure_pos

theorem small_weight_allocation (p : Input) :
    4*(widthBound p:ℝ)*p.energy+2*(robustParameterCount p.dimension (widthBound p) (p.depth-2):ℝ)≤
      (p.failure/2)*(weightBound p)^2 := by
  have hα := p.failure_pos
  have hK := energy_pos p
  have hm := Nat.cast_nonneg (α:=ℝ) (widthBound p)
  have hP := Nat.cast_nonneg (α:=ℝ) (parameterCount p.dimension (widthBound p) p.depth)
  have hl : (1:ℝ)/2≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hS : 0≤4*(4*(widthBound p:ℝ)*p.energy+2*(parameterCount p.dimension (widthBound p) p.depth:ℝ)*Real.log 2)/p.failure := by positivity
  have he : (smallBound p)^2=4*(4*(widthBound p:ℝ)*p.energy+
      2*(parameterCount p.dimension (widthBound p) p.depth:ℝ)*Real.log 2)/p.failure := Real.sq_sqrt hS
  have hb : smallBound p≤weightBound p := (le_max_left _ _).trans (le_max_left _ _)
  have hb0 := (smallBound_pos p).le
  have hB : (smallBound p)^2≤(weightBound p)^2 := by nlinarith
  rw [he] at hB
  have hbudget := (div_le_iff₀ hα).mp hB
  rw [←parameterCount_eq]
  have hlP := mul_le_mul_of_nonneg_left hl hP
  nlinarith [mul_nonneg hm hK.le]

theorem small_width_weight_tail (p : Input) {N : ℕ} (hN : 0<N) (hNM : N≤widthBound p)
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    Q.real {w | ¬boundedWeights (weightBound p) w}≤p.failure/2 := by
  have hn : (N:ℝ)≠0 := (Nat.cast_pos.mpr hN).ne'
  have hscale : t^2=(N:ℝ)*(t/Real.sqrt (N:ℝ))^2 := by
    rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    field_simp
  obtain ⟨hi,hm⟩ := smallPrior_entropy_physical_moment p.dimension_pos hN (energy_pos p).le
    ht (by nlinarith) hscale Q hQ
  have hcount := robustParameterCount_mono_width (d:=p.dimension) (r:=p.depth-2) hNM
  have hnM : (N:ℝ)≤widthBound p := by exact_mod_cast hNM
  have hc : (robustParameterCount p.dimension N (p.depth-2):ℝ)≤
      robustParameterCount p.dimension (widthBound p) (p.depth-2) := by exact_mod_cast hcount
  have henergy : 4*(N:ℝ)*p.energy+2*(robustParameterCount p.dimension N (p.depth-2):ℝ)≤
      4*(widthBound p:ℝ)*p.energy+2*(robustParameterCount p.dimension (widthBound p) (p.depth-2):ℝ) := by
    nlinarith [mul_le_mul_of_nonneg_right hnM (energy_pos p).le]
  have hB : 0<weightBound p := (smallBound_pos p).trans_le ((le_max_left _ _).trans (le_max_left _ _))
  exact physical_moment_boundedWeights_tail Q hi hB (hm.trans (henergy.trans (small_weight_allocation p)))

end NeuralGeneralization.BatchTwoManuscriptResources
