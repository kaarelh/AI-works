import NeuralGeneralization.OnlineLowerCostCombined
import NeuralGeneralization.OnlineLowerCostSigns

/-! # Uniform prefix cancellation for every path syndrome

All prefix bits are present, while the path support is completely arbitrary.
The resulting bound therefore applies outside the selected ordering family.
-/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open OnlineLowerBernstein OnlineLowerRelu

theorem joinedSyndromeSupport_card_ge (P V : ℕ) (T : Finset (Fin V)) :
    P ≤ (joinedSyndromeSupport P V T).card := by
  classical
  have hinj : Function.Injective (fun i : Fin P => (finSumFinEquiv (.inl i) : Fin (P+V))) := by
    intro i j h
    exact Sum.inl.inj (finSumFinEquiv.injective h)
  have hsub : (Finset.univ.image (fun i : Fin P => (finSumFinEquiv (.inl i) : Fin (P+V)))) ⊆
      joinedSyndromeSupport P V T := by
    intro j hj
    obtain ⟨i,_,rfl⟩ := Finset.mem_image.mp hj
    simp [joinedSyndromeSupport]
  have hc := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ hinj] at hc
  simpa only [Finset.card_univ, Fintype.card_fin] using hc

theorem fixedPathDegree_shift (n₀ u : ℝ) (n : ℕ) (s : ClippingCube (n+1)) :
    fixedPathDegree (n₀+u) n s = u + fixedPathDegree n₀ n s := by
  unfold fixedPathDegree columnDegree
  ring

namespace FamilyCost

theorem scalarCost_exp_prefix (k : ℕ) (n₀ t : ℝ)
    (T : Finset (Fin (Family.pathDim k))) :
    scalarCost k n₀ (fun n => Real.exp (-n*t)) T =
      prefixLaplaceFactor (Family.prefixDim k) t *
        walshCoefficients (fun s => Real.exp (-fixedPathDegree n₀ (2*k) s*t)) T := by
  rw [scalarCost_split]
  have hcoef (s : ClippingCube (Family.prefixDim k)) :
      walshCoefficients (fun z => Real.exp
        (-fixedPathDegree (n₀+prefixDegree (Family.prefixDim k) s) (2*k) z*t)) T =
        Real.exp (-prefixDegree (Family.prefixDim k) s*t) *
          walshCoefficients (fun z => Real.exp (-fixedPathDegree n₀ (2*k) z*t)) T := by
    have hfun : (fun z => Real.exp
        (-fixedPathDegree (n₀+prefixDegree (Family.prefixDim k) s) (2*k) z*t)) =
        (fun z => Real.exp (-prefixDegree (Family.prefixDim k) s*t) *
          Real.exp (-fixedPathDegree n₀ (2*k) z*t)) := by
      funext z
      rw [fixedPathDegree_shift, show -(prefixDegree (Family.prefixDim k) s +
        fixedPathDegree n₀ (2*k) z)*t = -prefixDegree (Family.prefixDim k) s*t +
          -fixedPathDegree n₀ (2*k) z*t by ring, Real.exp_add]
    rw [hfun, coefficient_const_mul]
  simp_rw [hcoef, ← mul_assoc]
  rw [← Finset.sum_mul, ← div_mul_eq_mul_div, prefix_laplace_sum]

theorem scalarCost_relu_bernstein (k : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (T : Finset (Fin (Family.pathDim k))) :
    scalarCost k n₀ gammaCost T =
      -(∫ t in Ioi (0 : ℝ), reluCostDensity t *
        scalarCost k n₀ (fun n => Real.exp (-n*t)) T) := by
  let S := joinedSyndromeSupport (Family.prefixDim k) (Family.pathDim k) T
  have hcard : 3 ≤ S.card := by
    have h := joinedSyndromeSupport_card_ge (Family.prefixDim k) (Family.pathDim k) T
    dsimp [S, Family.prefixDim] at *
    omega
  have hS : S ≠ ∅ := by intro h; simp [h] at hcard
  have hcol (j) : S ≠ Family.column k j := by
    intro h
    have hc := Family.column_card_le k j
    rw [← h] at hc
    omega
  have hd (s) : 1 < columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ)) s :=
    lt_of_lt_of_le hn₀ (columnDegree_ge _ _ _ (fun j => Nat.cast_nonneg _) s)
  have h := columnCost_bernstein (volume.restrict (Ioi 0)) n₀ (Family.column k)
    (fun j => (Family.increment k j : ℝ)) gammaCost reluCostSlope reluCostIntercept
    (fun s t => Real.exp (-columnDegree n₀ (Family.column k)
      (fun j => (Family.increment k j : ℝ)) s*t) * reluCostDensity t)
    (fun s => reluCostDensity_laplaceIntegrable (hd s))
    (fun s => gammaCost_bernstein (hd s)) S hS hcol
  change scalarCost k n₀ gammaCost T = _ at h
  rw [h]
  congr 1
  apply integral_congr_ae
  filter_upwards [] with t
  unfold scalarCost walshCoefficients uniformCubeMean
  rw [← mul_div_assoc, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem scalarCost_relu_integrable (k : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (T : Finset (Fin (Family.pathDim k))) :
    IntegrableOn (fun t => reluCostDensity t *
      scalarCost k n₀ (fun n => Real.exp (-n*t)) T) (Ioi 0) := by
  let degree := columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ))
  have hd (s) : 1 < degree s :=
    lt_of_lt_of_le hn₀ (columnDegree_ge _ _ _ (fun j => Nat.cast_nonneg _) s)
  have hi := coefficient_integrable (volume.restrict (Ioi 0))
    (fun s t => reluCostDensity t * Real.exp (-degree s*t))
    (fun s => by simpa only [LaplaceIntegrable, IntegrableOn, mul_comm] using reluCostDensity_laplaceIntegrable (hd s))
    (joinedSyndromeSupport (Family.prefixDim k) (Family.pathDim k) T)
  simpa only [coefficient_const_mul, scalarCost, degree, IntegrableOn] using hi

def universalPrefixFactor (k : ℕ) (n₀ : ℝ)
    (T : Finset (Fin (Family.pathDim k))) (t : ℝ) : ℝ :=
  prefixLaplaceFactor (Family.prefixDim k) t * (Real.exp (n₀*t) *
    walshCoefficients (fun s => Real.exp (-fixedPathDegree n₀ (2*k) s*t)) T)

theorem universalPrefixFactor_abs_le (k : ℕ) (n₀ : ℝ)
    (T : Finset (Fin (Family.pathDim k))) (t : ℝ) (ht : 0 < t) :
    |universalPrefixFactor k n₀ T t| ≤ (2*t)^(Family.prefixDim k) := by
  have hc : |walshCoefficients (fun s => Real.exp (-fixedPathDegree n₀ (2*k) s*t)) T| ≤
      Real.exp (-n₀*t) := by
    apply walshCoefficient_abs_le_uniform
    intro s
    rw [abs_of_pos (Real.exp_pos _)]
    apply Real.exp_le_exp.mpr
    have := fixedPathDegree_ge n₀ (2*k) s
    nlinarith
  unfold universalPrefixFactor
  rw [abs_mul, abs_mul, abs_of_pos (prefixLaplaceFactor_pos _ ht),
    abs_of_pos (Real.exp_pos _)]
  have he : Real.exp (n₀*t) * Real.exp (-n₀*t) = 1 := by
    rw [← Real.exp_add, show n₀*t + -n₀*t = 0 by ring, Real.exp_zero]
  calc
    _ ≤ prefixLaplaceFactor (Family.prefixDim k) t *
        (Real.exp (n₀*t) * Real.exp (-n₀*t)) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hc (Real.exp_pos _).le)
        (prefixLaplaceFactor_pos _ ht).le
    _ ≤ _ := by rw [he, mul_one]; exact prefixLaplaceFactor_le _ ht

theorem universalPrefixFactor_integrand (k : ℕ) (n₀ : ℝ)
    (T : Finset (Fin (Family.pathDim k))) (t : ℝ) :
    Real.exp (-n₀*t) * reluCostDensity t * universalPrefixFactor k n₀ T t =
      reluCostDensity t * scalarCost k n₀ (fun n => Real.exp (-n*t)) T := by
  rw [scalarCost_exp_prefix]
  unfold universalPrefixFactor
  have he : Real.exp (-n₀*t) * Real.exp (n₀*t) = 1 := by
    rw [← Real.exp_add, show -n₀*t + n₀*t = 0 by ring, Real.exp_zero]
  calc
    _ = (Real.exp (-n₀*t) * Real.exp (n₀*t)) *
        (reluCostDensity t * prefixLaplaceFactor (Family.prefixDim k) t *
          walshCoefficients (fun s => Real.exp (-fixedPathDegree n₀ (2*k) s*t)) T) := by ring
    _ = _ := by rw [he]; ring

/-- Uniform bound for every support with all compulsory prefix coordinates.
No membership in the specially ordered candidate family is required. -/
theorem scalarCost_universal_prefix_bound (k : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (T : Finset (Fin (Family.pathDim k))) :
    |scalarCost k n₀ gammaCost T| ≤
      8*reluCostSlope*2^(Family.prefixDim k)*((Family.prefixDim k).factorial : ℝ) /
        (n₀-1)^(Family.prefixDim k+1) := by
  have hi : IntegrableOn (fun t => Real.exp (-n₀*t) * reluCostDensity t *
      universalPrefixFactor k n₀ T t) (Ioi 0) := by
    simpa only [universalPrefixFactor_integrand] using scalarCost_relu_integrable k n₀ hn₀ T
  have hb := density_integral_prefix_bound (Family.prefixDim k) hn₀
    (universalPrefixFactor k n₀ T) hi (universalPrefixFactor_abs_le k n₀ T)
  rw [scalarCost_relu_bernstein k n₀ hn₀ T, abs_neg]
  simpa only [universalPrefixFactor_integrand] using hb

end FamilyCost
end NeuralGeneralization.OnlineLower
