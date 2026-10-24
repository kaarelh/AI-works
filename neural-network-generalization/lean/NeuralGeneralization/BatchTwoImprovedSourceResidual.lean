import NeuralGeneralization.BatchTwoImprovedWhitenedError
import NeuralGeneralization.RobustCompressionLayerParameters

/-! The residual hypotheses used by the q/m estimate are derived from the
actual zero-safe Gram--Schmidt source bank, including singular active spans. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open InnerProductSpace WithLp Submodule
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedProjection
open BatchTwoImprovedActiveGeometry RobustCompressionClipping Classical
variable {N q : ℕ}

def sourceResidual (b : Fin q → EuclideanSpace ℝ (Fin N)) (h : Fin N → ℝ) (j : Fin N) : ℝ :=
  Real.sqrt (N:ℝ)*queryResidual b (normalizedFeature h) j

theorem sourceResidual_decomposition (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (hN : 0 < N) (j : Fin N) :
    sourceResidual b h j = h j-linearEvaluation (fun k => sourceRows b j k)
      (evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h)) := by
  have hn : Real.sqrt (N:ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)).ne'
  have he : activeProjection b (normalizedFeature h) j =
      ∑ k, evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h) k*
        gramSchmidtNormed ℝ b k j := by
    change (EuclideanSpace.proj j) (activeProjection b (normalizedFeature h)) = _
    simp [activeProjection,evaluations]
  change Real.sqrt (N:ℝ)*(normalizedFeature h j-activeProjection b (normalizedFeature h) j)=_
  rw [he,mul_sub]
  have hcoord : Real.sqrt (N:ℝ)*normalizedFeature h j=h j := by
    change Real.sqrt (N:ℝ)*(h j/Real.sqrt (N:ℝ))=h j
    field_simp
  rw [hcoord]
  congr 1
  simp only [sourceRows,linearEvaluation,Finset.mul_sum,ofLp_toLp]
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem sourceResidual_orthogonal (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (k : Fin q) :
    ∑ j, sourceRows b j k*sourceResidual b h j=0 := by
  have hi : ⟪gramSchmidtNormed ℝ b k,queryResidual b (normalizedFeature h)⟫=0 := by
    apply (Submodule.mem_orthogonal _ _).mp (queryResidual_mem_orthogonal b (normalizedFeature h))
    have hs : Submodule.span ℝ (Set.range (gramSchmidtNormed ℝ b)) =
        Submodule.span ℝ (Set.range b) := by
      rw [span_gramSchmidtNormed_range,span_gramSchmidt]
    rw [← hs]
    exact Submodule.subset_span (Set.mem_range_self k)
  have he : (∑ j, sourceRows b j k*sourceResidual b h j) =
      (N:ℝ)*⟪gramSchmidtNormed ℝ b k,queryResidual b (normalizedFeature h)⟫ := by
    simp only [sourceRows,sourceResidual,EuclideanSpace.inner_eq_star_dotProduct,
      dotProduct,star_trivial,Pi.star_apply,Finset.mul_sum,ofLp_toLp]
    apply Finset.sum_congr rfl
    intro j _
    have hs := Real.sq_sqrt (Nat.cast_nonneg N)
    calc
      _ = (Real.sqrt (N:ℝ))^2*
          (queryResidual b (normalizedFeature h) j*gramSchmidtNormed ℝ b k j) := by ring
      _ = _ := by rw [hs]
  rw [he,hi,mul_zero]

theorem sourceResidual_energy (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (hN : 0 < N) :
    (∑ j, (sourceResidual b h j)^2)/(N:ℝ) = ‖queryResidual b (normalizedFeature h)‖^2 := by
  simp only [sourceResidual,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N),← Finset.mul_sum]
  rw [mul_div_cancel_left₀ _ (Nat.cast_ne_zero.mpr hN.ne'),EuclideanSpace.real_norm_sq_eq]

theorem normalizedFeature_energy (h : Fin N → ℝ) :
    ‖normalizedFeature h‖^2=(∑ j, (h j)^2)/(N:ℝ) := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [normalizedFeature,ofLp_toLp,div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
  exact (Finset.sum_div _ _ _).symm

theorem sourceResidual_energy_le_one (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (hN : 0 < N) (hh : ∀ j, (h j)^2 ≤ 1) :
    (∑ j, (sourceResidual b h j)^2)/(N:ℝ) ≤ 1 := by
  rw [sourceResidual_energy b h hN]
  have he := residual_pythagoras b (normalizedFeature h)
  have hn : ‖normalizedFeature h‖^2 ≤ 1 := by
    rw [normalizedFeature_energy]
    apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).mpr
    simpa using Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hh j)
  nlinarith [sq_nonneg ‖activeProjection b (normalizedFeature h)‖]

theorem active_coordinates_energy_le_one (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (hN : 0 < N) (hh : ∀ j, (h j)^2 ≤ 1) :
    ∑ k, (evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h) k)^2 ≤ 1 := by
  have he := active_energy_eq_projection b (normalizedFeature h)
  have hp := residual_pythagoras b (normalizedFeature h)
  have hn : ‖normalizedFeature h‖^2 ≤ 1 := by
    rw [normalizedFeature_energy]
    apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).mpr
    simpa using Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hh j)
  rw [he]
  nlinarith [sq_nonneg ‖queryResidual b (normalizedFeature h)‖]

theorem sourceRows_trace (b : Fin q → EuclideanSpace ℝ (Fin N)) (hN : 0 < N) :
    ∑ j, rowEnergy (fun j k => sourceRows b j k) j ≤ (N:ℝ)*q := by
  have ht := sourceRows_trace_le b hN
  rw [div_le_iff₀ (Nat.cast_pos.mpr hN)] at ht
  simpa only [rowEnergy,EuclideanSpace.real_norm_sq_eq,mul_comm] using ht

/-- The uniform component controls h; the leverage component controls its
active projection. The residual has uniformly bounded importance-weighted
square even when individual source rows are arbitrarily large. -/
theorem sourceResidual_weighted_bound (b : Fin q → EuclideanSpace ℝ (Fin N))
    (h : Fin N → ℝ) (hN : 0 < N) (hq : 0 < q) (hh : ∀ j, (h j)^2 ≤ 1) (j : Fin N) :
    sourceMultiplier (fun j k => sourceRows b j k) j*(sourceResidual b h j)^2 ≤
      4*((q:ℝ)+1) := by
  let u := fun j k => sourceRows b j k
  let a := sourceMultiplier u
  let ψ := evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h)
  have ha := (sourceMultiplier_pos hN hq u j).le
  have ha2 := sourceMultiplier_le_two hN hq u (sourceRows_trace b hN) j
  have hue := sourceMultiplier_energy_le hN hq u (sourceRows_trace b hN) j
  have hψ := active_coordinates_energy_le_one b h hN hh
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (u j) ψ
  have hul : (linearEvaluation (u j) ψ)^2 ≤ rowEnergy u j := by
    have hp := mul_le_mul_of_nonneg_left hψ (rowEnergy_nonneg u j)
    exact hcs.trans (by simpa only [mul_one,ψ,rowEnergy,u] using hp)
  rw [sourceResidual_decomposition b h hN j]
  change a j*(h j-linearEvaluation (u j) ψ)^2 ≤ _
  have hsq : (h j-linearEvaluation (u j) ψ)^2 ≤ 2*(h j)^2+2*(linearEvaluation (u j) ψ)^2 := by
    nlinarith [sq_nonneg (h j+linearEvaluation (u j) ψ)]
  have h1 := mul_le_mul_of_nonneg_left hsq ha
  have h2 := mul_le_mul_of_nonneg_left (hh j) ha
  have h3 := mul_le_mul_of_nonneg_left hul ha
  change a j ≤ 2 at ha2
  change a j*rowEnergy u j ≤ 2*q at hue
  nlinarith

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
