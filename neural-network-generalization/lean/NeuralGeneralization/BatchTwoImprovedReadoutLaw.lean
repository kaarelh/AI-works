import NeuralGeneralization.BatchTwoImprovedSourceKernel
import NeuralGeneralization.RobustCompressionReadout

/-! Exact importance sampling of the readout, including the zero-vector case.
The law is a measurable function of the actual coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoImprovedReadout
open BatchTwoImprovedWeightedSampling RobustCompressionReadout
open RobustCompressionSampling CompressionSampling Classical
variable {N m : ℕ}

def absoluteSum (v : Fin N → ℝ) : ℝ := ∑ i, |v i|
def amplitude (v : Fin N → ℝ) : ℝ := absoluteSum v / N
def coefficientSign (a : ℝ) : ℝ := if 0 ≤ a then 1 else -1
def indexProbability (v : Fin N → ℝ) (i : Fin N) : ℝ :=
  if absoluteSum v = 0 then 1 / N else |v i| / absoluteSum v

theorem absoluteSum_nonneg (v : Fin N → ℝ) : 0 ≤ absoluteSum v :=
  Finset.sum_nonneg (fun _ _ => abs_nonneg _)

theorem amplitude_nonneg (v : Fin N → ℝ) : 0 ≤ amplitude v :=
  div_nonneg (absoluteSum_nonneg v) (Nat.cast_nonneg N)

theorem zero_of_absoluteSum_zero (v : Fin N → ℝ) (hz : absoluteSum v = 0) (i : Fin N) :
    v i = 0 := by
  have h : |v i| ≤ absoluteSum v :=
    Finset.single_le_sum (f := fun j => |v j|) (fun _ _ => abs_nonneg _) (Finset.mem_univ i)
  rw [hz] at h
  exact abs_eq_zero.mp (le_antisymm h (abs_nonneg _))

theorem sign_abs (a : ℝ) : |coefficientSign a| = 1 := by
  unfold coefficientSign
  split_ifs <;> norm_num

theorem abs_mul_sign (a : ℝ) : |a| * coefficientSign a = a := by
  unfold coefficientSign
  split_ifs with ha
  · rw [abs_of_nonneg ha, mul_one]
  · rw [abs_of_neg (lt_of_not_ge ha)]
    ring

theorem indexProbability_nonneg (v : Fin N → ℝ) (i : Fin N) :
    0 ≤ indexProbability v i := by
  unfold indexProbability
  split_ifs
  · positivity
  · exact div_nonneg (abs_nonneg _) (absoluteSum_nonneg v)

theorem indexProbability_sum (hN : 0 < N) (v : Fin N → ℝ) :
    ∑ i, indexProbability v i = 1 := by
  by_cases hz : absoluteSum v = 0
  · simp [indexProbability, hz, (Nat.cast_pos.mpr hN : (0 : ℝ) < N).ne']
  · simp only [indexProbability, hz, if_false, ← Finset.sum_div]
    exact div_self hz

theorem probability_amplitude_sign (v : Fin N → ℝ) (i : Fin N) :
    indexProbability v i * amplitude v * coefficientSign (v i) = v i / N := by
  by_cases hz : absoluteSum v = 0
  · rw [zero_of_absoluteSum_zero v hz i]
    simp [indexProbability, amplitude, hz]
  · rw [indexProbability, if_neg hz, amplitude]
    calc
      _ = (|v i| * coefficientSign (v i)) / N := by field_simp <;> ring
      _ = _ := by rw [abs_mul_sign]

@[fun_prop] theorem measurable_amplitude : Measurable (amplitude (N := N)) := by
  unfold amplitude absoluteSum
  fun_prop

@[fun_prop] theorem measurable_coefficientSign : Measurable coefficientSign := by
  unfold coefficientSign
  exact measurable_const.ite (measurableSet_le measurable_const measurable_id) measurable_const

@[fun_prop] theorem measurable_indexProbability : Measurable (indexProbability (N := N)) := by
  apply measurable_pi_lambda
  intro i
  unfold indexProbability
  have ha : Measurable (absoluteSum (N := N)) := by unfold absoluteSum; fun_prop
  exact measurable_const.ite (measurableSet_eq_fun ha measurable_const)
    (((measurable_pi_apply i).abs).div ha)

def indexKernel (hN : 0 < N) : Kernel (Fin N → ℝ) (Fin N) where
  toFun := fun v => finiteLaw (indexProbability v) (indexProbability_nonneg v) (indexProbability_sum hN v)
  measurable' := measurable_finiteLaw indexProbability measurable_indexProbability
    indexProbability_nonneg (indexProbability_sum hN)

instance indexKernel_markov (hN : 0 < N) : IsMarkovKernel (indexKernel hN) where
  isProbabilityMeasure v := by
    change IsProbabilityMeasure (finiteLaw (indexProbability v) (indexProbability_nonneg v) (indexProbability_sum hN v))
    infer_instance

def indicesKernel (hN : 0 < N) (m : ℕ) : Kernel (Fin N → ℝ) (Fin m → Fin N) where
  toFun := fun v => finiteLaw (iidWeight (indexProbability v) m)
    (iidWeight_nonneg _ (indexProbability_nonneg v) m)
    (iidWeight_mass _ (indexProbability_sum hN v) m)
  measurable' := by
    apply measurable_finiteLaw
    unfold iidWeight
    apply measurable_pi_lambda
    intro I
    apply Finset.measurable_prod
    intro j _
    exact (measurable_pi_apply (I j)).comp measurable_indexProbability

instance indicesKernel_markov (hN : 0 < N) (m : ℕ) : IsMarkovKernel (indicesKernel hN m) where
  isProbabilityMeasure v := by
    change IsProbabilityMeasure (finiteLaw (iidWeight (indexProbability v) m)
      (iidWeight_nonneg _ (indexProbability_nonneg v) m)
      (iidWeight_mass _ (indexProbability_sum hN v) m))
    infer_instance

theorem indicesKernel_eq_iid (hN : 0 < N) (m : ℕ) (v : Fin N → ℝ) :
    indicesKernel hN m v = iidSamples (indexKernel hN v) m := by
  apply Measure.ext_of_singleton
  intro I
  change finiteLaw (iidWeight (indexProbability v) m)
    (iidWeight_nonneg _ (indexProbability_nonneg v) m)
    (iidWeight_mass _ (indexProbability_sum hN v) m) {I} = _
  rw [finiteLaw_singleton, iidSamples, Measure.pi_singleton]
  change ENNReal.ofReal (∏ j, indexProbability v (I j)) = _
  rw [ENNReal.ofReal_prod_of_nonneg (fun j _ => indexProbability_nonneg v (I j))]
  apply Finset.prod_congr rfl
  intro j _
  exact (finiteLaw_singleton (indexProbability v) (indexProbability_nonneg v)
    (indexProbability_sum hN v) (I j)).symm

theorem integral_atom (hN : 0 < N) (v h : Fin N → ℝ) :
    (∫ i, amplitude v * coefficientSign (v i) * h i ∂indexKernel hN v) =
      populationMean (fun i => v i * h i) := by
  change (∫ i, amplitude v * coefficientSign (v i) * h i ∂
    finiteLaw (indexProbability v) (indexProbability_nonneg v) (indexProbability_sum hN v)) = _
  rw [finiteLaw_integral]
  unfold mean populationMean
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  calc
    _ = (indexProbability v i * amplitude v * coefficientSign (v i)) * h i := by ring
    _ = _ := by rw [probability_amplitude_sign]; ring

theorem amplitude_sq_le_energy (hN : 0 < N) (v : Fin N → ℝ) :
    (amplitude v)^2 ≤ populationMean (fun i => (v i)^2) := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun i : Fin N => |v i|) (fun _ => (1 : ℝ))
  simp only [mul_one, one_pow, sq_abs, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul] at h
  have hN0 : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  unfold amplitude absoluteSum populationMean
  rw [div_pow]
  apply (div_le_iff₀ (sq_pos_of_pos hN0)).mpr
  have he : ((∑ i, (v i)^2) / (N : ℝ)) * (N : ℝ)^2 = (∑ i, (v i)^2) * N := by
    field_simp <;> ring
  rwa [he]

theorem amplitude_le_sqrt_energy (hN : 0 < N) (v : Fin N → ℝ) {K : ℝ}
    (hK : 0 ≤ K) (hv : populationMean (fun i => (v i)^2) ≤ K) : amplitude v ≤ Real.sqrt K := by
  apply (sq_le_sq₀ (amplitude_nonneg v) (Real.sqrt_nonneg K)).mp
  rw [Real.sq_sqrt hK]
  exact (amplitude_sq_le_energy hN v).trans hv

end NeuralGeneralization.BatchTwoImprovedReadout
