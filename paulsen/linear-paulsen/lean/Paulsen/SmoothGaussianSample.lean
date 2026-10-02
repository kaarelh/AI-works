import Paulsen.SmoothGaussianThresholds
import Paulsen.SmoothDenseCore

/-! One actual Gaussian sample simultaneously realizes the moderate seed budgets. -/
namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

def moderateNoiseFrame {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)

/-- These conditions all concern the same concrete retained Gaussian realization. -/
structure ModerateGaussianSample {n d : ℕ} (U : Frame n d) (ρ t u₁ u₂ : ℝ)
    (M : Frame n n) (g : FrameVector n d) : Prop where
  horizontal : U.transpose * moderateNoiseFrame U ρ g = 0
  operator : ‖(Matrix.toEuclideanLin (moderateNoiseFrame U ρ g)).toContinuousLinearMap‖ < 128
  noiseRows : ∀ i, rowNormSq (moderateNoiseFrame U ρ g) i < 600 * ((d : ℝ) / n)
  tangentRows : ∀ i, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i <
    2000 * ((d : ℝ) / n)
  normalDiagonal : ∀ i, |(moderateNoiseFrame U ρ g * U.transpose) i i| < u₁
  quadraticDiagonal : ∀ i, |horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i -
    ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
      ∂stdGaussian (FrameVector n d)| < u₂
  centeredGraph : ‖matrixEuclideanOperator (graphLaplacian
    (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖ < ((d : ℝ) / n) / 32
  dense : ∀ i, i ∉ moderateVarianceExceptional U ρ →
    smallCoordinateFraction (t * Real.sqrt (((d : ℝ) / n) / n) / 1000)
      (WithLp.toLp 2 (M i) + t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g) < 1 / 20

/-- Seven proved concentration events leave room for one additional event. -/
theorem exists_moderateGaussianSample_avoiding {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 1000000 ≤ d) (hdn : d ≤ n)
    (hdensity : (d : ℝ) / n ≤ 1 / 2)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i ∧
      rowNormSq U i ≤ 3 * ((d : ℝ) / n) / 2)
    {ρ t u₁ u₂ : ℝ} (hρ : 0 < ρ) (ht : 0 < t) (hu₁ : 0 ≤ u₁) (hu₂ : 0 ≤ u₂)
    (hdiag : Real.log n + 200 ≤ (n : ℝ) ^ 2 * u₁ ^ 2 / (4 * ρ * d))
    (hquad : Real.log n + 200 ≤ min ((n : ℝ) ^ 2 * u₂ ^ 2 / (96 * d)) ((n : ℝ) * u₂ / 16))
    (hgraph : 4096000000000000 * (Real.log n + 2) ≤ (d : ℝ))
    (hdense : (4000000000000 * Real.pi ^ 2) * Real.log (100 * (n : ℝ)) ≤ (d : ℝ))
    (M : Frame n n) (B : Set (FrameVector n d))
    (hB : (stdGaussian (FrameVector n d)).real B ≤ 1 / 100) :
    ∃ g, ModerateGaussianSample U ρ t u₁ u₂ M g ∧ g ∉ B := by
  classical
  have hn : 0 < n := NeZero.pos n
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hd0 : 0 < d := by omega
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have hL : 0 ≤ Real.log n := Real.log_nonneg (by exact_mod_cast hn)
  have hlog : Real.log n ≤ (d : ℝ) := by linarith
  have hp (i : Fin n) : 0 < rowNormSq U i := lt_of_lt_of_le (by positivity) (hrows i).1
  have hnear (i : Fin n) : rowNormSq U i ≤ 2 * (d : ℝ) / n := by
    have := (hrows i).2
    have ha : 0 ≤ (d : ℝ) / n := by positivity
    calc
      _ ≤ 3 * ((d : ℝ) / n) / 2 := this
      _ ≤ 2 * ((d : ℝ) / n) := by nlinarith
      _ = 2 * (d : ℝ) / n := by ring
  let b₀ : Set (FrameVector n d) := {g | 124 <
    ‖(Matrix.toEuclideanLin (moderateNoiseFrame U ρ g)).toContinuousLinearMap‖}
  let b₁ : Set (FrameVector n d) := {g | ∃ i,
    600 * ((d : ℝ) / n) ≤ rowNormSq (moderateNoiseFrame U ρ g) i}
  let b₂ : Set (FrameVector n d) := {g | ∃ i,
    2000 * ((d : ℝ) / n) ≤ rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i}
  let b₃ : Set (FrameVector n d) := {g | ∃ i,
    u₁ ≤ |(moderateNoiseFrame U ρ g * U.transpose) i i|}
  let b₄ : Set (FrameVector n d) := {g | ∃ i,
    u₂ ≤ |horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i -
      ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
        ∂stdGaussian (FrameVector n d)|}
  let b₅ : Set (FrameVector n d) := {g | ((d : ℝ) / n) / 64 <
    ‖matrixEuclideanOperator (graphLaplacian
      (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖}
  let b₆ : Set (FrameVector n d) := {g | ∃ i, i ∉ moderateVarianceExceptional U ρ ∧
    1 / 20 ≤ smallCoordinateFraction (t * Real.sqrt (((d : ℝ) / n) / n) / 1000)
      (WithLp.toLp 2 (M i) + t • Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g)}
  let bad : Fin 8 → Set (FrameVector n d) := ![b₀, b₁, b₂, b₃, b₄, b₅, b₆, B]
  have h₀ : (stdGaussian (FrameVector n d)).real b₀ ≤ 1 / 100 :=
    normalizedTangentNoise_operator_margin_failure_le hn hdn hU hρ.le
  have h₁ : (stdGaussian (FrameVector n d)).real b₁ ≤ 1 / 100 :=
    normalizedTangentNoise_row_max_failure_le hd0 hU hρ.le hlog
  have h₂ : (stdGaussian (FrameVector n d)).real b₂ ≤ 1 / 100 :=
    retainedTangent_row_max_failure_le hd0 hU hρ.le hnear hlog
  have h₃ : (stdGaussian (FrameVector n d)).real b₃ ≤ 1 / 100 :=
    normalizedTangentNoise_diagonal_max_failure_le hn hd0 hU hp hnear hρ hu₁ hdiag
  have h₄ : (stdGaussian (FrameVector n d)).real b₄ ≤ 1 / 100 :=
    normalizedTangentNoise_quadratic_max_failure_le hn hd0 hU hnear hρ.le hu₂ hquad
  have h₅ : (stdGaussian (FrameVector n d)).real b₅ ≤ 1 / 100 := by
    have hlarge : 1000000000000 * (Real.log n + 2) ≤ (1 / 64 : ℝ) ^ 2 * d := by nlinarith
    have h := retainedTangentGraph_operator_failure_le hU hd0 hρ.le
      (by norm_num : (0 : ℝ) < 1 / 64) (by norm_num : (1 / 64 : ℝ) ≤ 1) hnear hlarge
    have he : (1 / 64 : ℝ) * d / n = ((d : ℝ) / n) / 64 := by ring
    simpa only [he] using h
  have h₆ : (stdGaussian (FrameVector n d)).real b₆ ≤ 1 / 100 :=
    retainedTangent_dense_core_failure_le hU hd hdn hdensity hrows hdense hρ.le ht M
  have hb (k : Fin 8) : (stdGaussian (FrameVector n d)).real (bad k) ≤ 1 / 100 := by
    fin_cases k
    · exact h₀
    · exact h₁
    · exact h₂
    · exact h₃
    · exact h₄
    · exact h₅
    · exact h₆
    · exact hB
  have htotal : (stdGaussian (FrameVector n d)).real (⋃ k, bad k) ≤ 8 / 100 := by
    calc
      _ ≤ ∑ k, (stdGaussian (FrameVector n d)).real (bad k) := measureReal_iUnion_fintype_le _
      _ ≤ ∑ _k : Fin 8, (1 / 100 : ℝ) := Finset.sum_le_sum fun k _ => hb k
      _ = _ := by norm_num
  have hex : ∃ g, g ∉ ⋃ k, bad k := by
    by_contra hh
    push Not at hh
    have heq : (⋃ k, bad k) = Set.univ := Set.eq_univ_of_forall hh
    rw [heq, probReal_univ] at htotal
    norm_num at htotal
  obtain ⟨g, hg⟩ := hex
  have hgk (k : Fin 8) : g ∉ bad k := fun hk => hg (Set.mem_iUnion.mpr ⟨k, hk⟩)
  refine ⟨g, ?_, hgk 7⟩
  refine ⟨normalizedTangentNoiseFactor_horizontal hU ρ (fun p => g p), ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact (le_of_not_gt (hgk 0)).trans_lt (by norm_num)
  · intro i
    exact lt_of_not_ge (fun hi => hgk 1 ⟨i, hi⟩)
  · intro i
    exact lt_of_not_ge (fun hi => hgk 2 ⟨i, hi⟩)
  · intro i
    exact lt_of_not_ge (fun hi => hgk 3 ⟨i, hi⟩)
  · intro i
    exact lt_of_not_ge (fun hi => hgk 4 ⟨i, hi⟩)
  · apply (le_of_not_gt (hgk 5)).trans_lt
    have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
    change ((d : ℝ) / n) / 64 < ((d : ℝ) / n) / 32
    linarith
  · intro i hi
    exact lt_of_not_ge (fun hsmall => hgk 6 ⟨i, hi, hsmall⟩)

/-- An unconditional sample, with no additional event supplied by the caller. -/
theorem exists_moderateGaussianSample {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 1000000 ≤ d) (hdn : d ≤ n)
    (hdensity : (d : ℝ) / n ≤ 1 / 2)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i ∧
      rowNormSq U i ≤ 3 * ((d : ℝ) / n) / 2)
    {ρ t u₁ u₂ : ℝ} (hρ : 0 < ρ) (ht : 0 < t) (hu₁ : 0 ≤ u₁) (hu₂ : 0 ≤ u₂)
    (hdiag : Real.log n + 200 ≤ (n : ℝ) ^ 2 * u₁ ^ 2 / (4 * ρ * d))
    (hquad : Real.log n + 200 ≤ min ((n : ℝ) ^ 2 * u₂ ^ 2 / (96 * d)) ((n : ℝ) * u₂ / 16))
    (hgraph : 4096000000000000 * (Real.log n + 2) ≤ (d : ℝ))
    (hdense : (4000000000000 * Real.pi ^ 2) * Real.log (100 * (n : ℝ)) ≤ (d : ℝ))
    (M : Frame n n) :
    ∃ g, ModerateGaussianSample U ρ t u₁ u₂ M g := by
  obtain ⟨g, hg, _⟩ := exists_moderateGaussianSample_avoiding hU hd hdn hdensity hrows hρ ht
    hu₁ hu₂ hdiag hquad hgraph hdense M ∅ (by simp)
  exact ⟨g, hg⟩

/-- A single dimension condition pays for both diagonal fluctuations at the seed scales. -/
theorem exists_moderateGaussianSample_scaled_avoiding {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 1000000 ≤ d) (hdn : d ≤ n)
    (hdensity : (d : ℝ) / n ≤ 1 / 2)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i ∧
      rowNormSq U i ≤ 3 * ((d : ℝ) / n) / 2)
    {D t ζ : ℝ} (hD : 0 < D) (ht : 0 < t) (hζ : 0 < ζ) (hζ1 : ζ ≤ 1)
    (hfluctuation : 100 * (D ^ 2 + 1) * (Real.log n + 200) ≤ ζ ^ 2 * d)
    (hgraph : 4096000000000000 * (Real.log n + 2) ≤ (d : ℝ))
    (hdense : (4000000000000 * Real.pi ^ 2) * Real.log (100 * (n : ℝ)) ≤ (d : ℝ))
    (M : Frame n n) (B : Set (FrameVector n d))
    (hB : (stdGaussian (FrameVector n d)).real B ≤ 1 / 100) :
    ∃ g, ModerateGaussianSample U (D ^ 2 * t ^ 2) t
      (ζ * ((d : ℝ) / n) * t) (ζ * ((d : ℝ) / n)) M g ∧ g ∉ B := by
  have hd0 : 0 < d := by omega
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr (NeZero.pos n)
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd0
  have hb := moderate_scaled_exponent_budgets hd0 hD ht hζ hζ1 hfluctuation
  exact exists_moderateGaussianSample_avoiding hU hd hdn hdensity hrows
    (by positivity) ht (by positivity) (by positivity) hb.1 hb.2 hgraph hdense M B hB

/-- The first- and second-order random diagonal errors have their final common scale. -/
theorem ModerateGaussianSample.scaled_diagonal_fluctuation {n d : ℕ}
    {U : Frame n d} {ρ t ζ : ℝ} {M : Frame n n} {g : FrameVector n d}
    (hs : ModerateGaussianSample U ρ t (ζ * ((d : ℝ) / n) * t)
      (ζ * ((d : ℝ) / n)) M g) (ht : 0 ≤ t) (i : Fin n) :
    |2 * t * (moderateNoiseFrame U ρ g * U.transpose) i i +
      t ^ 2 * (horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i -
        ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
          ∂stdGaussian (FrameVector n d))| ≤ 3 * ζ * ((d : ℝ) / n) * t ^ 2 := by
  have hfirst : |2 * t * (moderateNoiseFrame U ρ g * U.transpose) i i| ≤
      (2 * t) * (ζ * ((d : ℝ) / n) * t) := by
    rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ 2 * t)]
    exact mul_le_mul_of_nonneg_left (hs.normalDiagonal i).le (by positivity)
  have hsecond : |t ^ 2 * (horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i -
        ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
          ∂stdGaussian (FrameVector n d))| ≤ t ^ 2 * (ζ * ((d : ℝ) / n)) := by
    rw [abs_mul, abs_of_nonneg (sq_nonneg t)]
    exact mul_le_mul_of_nonneg_left (hs.quadraticDiagonal i).le (sq_nonneg t)
  calc
    _ ≤ |2 * t * (moderateNoiseFrame U ρ g * U.transpose) i i| +
      |t ^ 2 * (horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ g) i -
        ∫ h, horizontalQuadraticDiagonal U (moderateNoiseFrame U ρ h) i
          ∂stdGaussian (FrameVector n d))| := abs_add_le _ _
    _ ≤ (2 * t) * (ζ * ((d : ℝ) / n) * t) + t ^ 2 * (ζ * ((d : ℝ) / n)) :=
      add_le_add hfirst hsecond
    _ = _ := by ring

end
end Paulsen.Smooth
