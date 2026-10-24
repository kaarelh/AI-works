import NeuralGeneralization.BatchTwoImprovedWhitenedLayer

/-! Source averaging of the sharp Gaussian comparison cost.  This version
can be used for any jointly measurable parameterized Gaussian coupling. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace NNReal
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp Matrix
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedActiveGeometry
open RobustCompressionLayerGaussian BatchTwoImprovedGaussianSquareRoot Classical
variable {N q m D : ℕ}
theorem whitened_layer_error_of_pointwise (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (H : Fin D → Fin q → ℝ)
    (h : Fin N → ℝ) (hh : ∀ j, (h j)^2 ≤ 1)
    {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1)
    (F : (Fin m → Fin N) → ℝ)
    (hF : ∀ s, F s ≤ ∑ i,
      (((whitenedParameters b H h t).idealMean s i-(whitenedParameters b H h t).finiteMean s i)^2+
        (Real.sqrt ((whitenedParameters b H h t).idealVariance s i:ℝ)-
          Real.sqrt ((whitenedParameters b H h t).finiteVariance s i:ℝ))^2)) :
    (∫ s, if sourceBad b s then 0 else F s
      ∂sourceIndicesKernel hN hq m (fun j k => sourceRows b j k)) ≤
        (2*(∑ i, ∑ k, (H i k)^2)+16*(D:ℝ)*((q:ℝ)+1))/(m:ℝ) := by
  dsimp only
  let u := fun j k => sourceRows b j k
  let a := sourceMultiplier u
  let p := sourceProbability u
  let P := whitenedParameters (m:=m) b H h t
  let gap := fun s : Fin m → Fin N =>
    (‖queryResidual (sampledColumns a s u) (sampledVector a s (sourceResidual b h))‖-
      ‖queryResidual b (normalizedFeature h)‖)^2
  let active := fun s : Fin m → Fin N => ∑ i,
    (sampleAverage s (fun j => a j*linearEvaluation (u j) (H i)*h j)-
      (∑ j, linearEvaluation (u j) (H i)*h j)/(N:ℝ))^2
  have hp := fun j => (sourceProbability_pos hN hq u j).le
  have hpm := sourceProbability_mass hN hq u
  have hw := iidWeight_nonneg p hp m
  have hcov (v : Fin q → ℝ) :
      (∑ j, (linearEvaluation (u j) v)^2)/(N:ℝ) ≤ ∑ k, (v k)^2 := by
    have hc := sourceRows_quadratic_le b hN (toLp 2 v)
    simpa only [EuclideanSpace.real_norm_sq_eq,EuclideanSpace.inner_eq_star_dotProduct,
      dotProduct,star_trivial,Pi.star_apply,linearEvaluation,mul_comm,u] using hc
  have hactive : mean (iidWeight p m) active ≤ 2*(∑ i, ∑ k, (H i k)^2)/(m:ℝ) := by
    unfold active
    rw [mean_sum]
    calc
      _ ≤ ∑ i, 2*(∑ k, (H i k)^2)/(m:ℝ) := Finset.sum_le_sum (fun i _ =>
        active_sample_mean_square hN hm p a hp hpm
          (fun j => (sourceMultiplier_pos hN hq u j).le)
          (sourceMultiplier_le_two hN hq u (sourceRows_trace b hN))
          (sourceProbability_mul_multiplier hN hq u) u hcov h hh (H i))
      _ = _ := by rw [← Finset.sum_div,← Finset.mul_sum]
  have hgap : mean (iidWeight p m) (fun s => if sourceBad b s then 0 else gap s) ≤
      16*((q:ℝ)+1)/(m:ℝ) := by
    have hc := sourceBank_variance_error hN hq hm b h hh
    dsimp only at hc
    change (∫ s, _ ∂finiteLaw (iidWeight p m) hw (iidWeight_mass p hpm m)) ≤ _ at hc
    rw [finiteLaw_integral] at hc
    exact hc
  have hpoint (s : Fin m → Fin N) :
      (if sourceBad b s then 0 else F s) ≤
      active s + (D:ℝ)*(if sourceBad b s then 0 else gap s) := by
    split_ifs with hb
    · simpa using Finset.sum_nonneg (fun i _ => sq_nonneg
        (sampleAverage s (fun j => a j*linearEvaluation (u j) (H i)*h j)-
          (∑ j, linearEvaluation (u j) (H i)*h j)/(N:ℝ)))
    · have hc := hF s
      calc
        _ ≤ ∑ i, ((P.idealMean s i-P.finiteMean s i)^2+
            (Real.sqrt (P.idealVariance s i:ℝ)-Real.sqrt (P.finiteVariance s i:ℝ))^2) := hc
        _ = active s+(D:ℝ)*(t^2*gap s) := by
          simp_rw [P,whitenedParameters_variance_difference hN hm b H h ht]
          rw [Finset.sum_add_distrib]
          congr 1
          · unfold active
            apply Finset.sum_congr rfl
            intro i _
            dsimp only [whitenedParameters,u,a]
            ring
          · simp [gap,u,a]
        _ ≤ active s+(D:ℝ)*gap s := by
          have ht2 : t^2 ≤ 1 := by nlinarith
          have hgs : 0 ≤ gap s := sq_nonneg _
          have htg : t^2*gap s ≤ gap s := by nlinarith only [mul_le_mul_of_nonneg_right ht2 hgs]
          exact add_le_add le_rfl (mul_le_mul_of_nonneg_left htg (Nat.cast_nonneg D))
  change (∫ s, _ ∂finiteLaw (iidWeight p m) hw (iidWeight_mass p hpm m)) ≤ _
  rw [finiteLaw_integral]
  calc
    _ ≤ mean (iidWeight p m) (fun s => active s+(D:ℝ)*(if sourceBad b s then 0 else gap s)) :=
      mean_mono _ hw hpoint
    _ = mean (iidWeight p m) active+(D:ℝ)*
        mean (iidWeight p m) (fun s => if sourceBad b s then 0 else gap s) := by rw [mean_add,mean_mul]
    _ ≤ 2*(∑ i, ∑ k, (H i k)^2)/(m:ℝ)+(D:ℝ)*(16*((q:ℝ)+1)/(m:ℝ)) :=
      add_le_add hactive (mul_le_mul_of_nonneg_left hgap (Nat.cast_nonneg D))
    _ = _ := by ring

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
