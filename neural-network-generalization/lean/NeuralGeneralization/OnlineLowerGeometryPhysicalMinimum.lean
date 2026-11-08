import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerGeometryMinimum

/-!
# From calibrated equality to a unique actual physical score

This is the final finite equality step. The total residual and calibrated
deviation bounds force the physical score itself, not merely a choice of
parameters or an independently introduced logical surrogate.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem uniform_nonnegative_mean_zero {d : ℕ} (F : ClippingCube d → ℝ)
    (hF : ∀ x, 0 ≤ F x) (hmean : uniformCubeMean F = 0) (x : ClippingCube d) : F x = 0 := by
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hsum : (∑ y, F y) = 0 := by
    unfold uniformCubeMean at hmean
    simpa only [zero_mul] using (div_eq_iff hM).mp hmean
  have hle := Finset.single_le_sum (fun y _ => hF y) (Finset.mem_univ x)
  rw [hsum] at hle
  exact le_antisymm hle (hF x)

theorem uniform_square_mean_zero {d : ℕ} (F : ClippingCube d → ℝ)
    (hmean : uniformCubeMean (fun x => (F x) ^ 2) = 0) : F = fun _ => 0 := by
  funext x
  exact sq_eq_zero_iff.mp (uniform_nonnegative_mean_zero _ (fun y => sq_nonneg (F y)) hmean x)

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

theorem relu_physical_score_of_zero_defects
    (H : CubeSubgroup m) (v zstar : ClippingCube m) (hv : v ∉ H.carrier)
    (hzstar : cubeTranslation v zstar ∈ H.carrier)
    (F : ClippingCube d → ℝ) (w0 : ℝ) (hw0 : 0 < w0)
    (hdeviation : 2 * w0 * uniformCubeMean (fun z =>
      if cubeTranslation v z ∉ H.carrier then
        |C.logicalProjection F z - reluReference z| else 0) ≤ 0)
    (hvariance : uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤ 0)
    (hp : reluLiveMass H v (C.logicalProjection F) = pointIndicator zstar) :
    F = fun x => C.base x * reluStar zstar (C.syndrome x) := by
  have hmeanvar : uniformCubeMean (fun x => (F x - C.project F x) ^ 2) = 0 := by
    apply le_antisymm hvariance
    exact div_nonneg (Finset.sum_nonneg fun x _ => sq_nonneg _) (Nat.cast_nonneg _)
  have hres := uniform_square_mean_zero (fun x => F x - C.project F x) hmeanvar
  have hnpoint (z : ClippingCube m) : 0 ≤
      (if cubeTranslation v z ∉ H.carrier then
        |C.logicalProjection F z - reluReference z| else 0) := by
    by_cases hz : cubeTranslation v z ∉ H.carrier
    · rw [if_pos hz]
      exact abs_nonneg _
    · rw [if_neg hz]
  have hmeandev : uniformCubeMean (fun z => if cubeTranslation v z ∉ H.carrier then
      |C.logicalProjection F z - reluReference z| else 0) = 0 := by
    have hn : 0 ≤ uniformCubeMean (fun z => if cubeTranslation v z ∉ H.carrier then
        |C.logicalProjection F z - reluReference z| else 0) := by
      exact div_nonneg (Finset.sum_nonneg fun z _ => hnpoint z) (Nat.cast_nonneg _)
    nlinarith
  have hcal (z : ClippingCube m) (hz : cubeTranslation v z ∉ H.carrier) :
      C.logicalProjection F z = reluReference z := by
    have hpoint := uniform_nonnegative_mean_zero
      (fun z => if cubeTranslation v z ∉ H.carrier then
        |C.logicalProjection F z - reluReference z| else 0)
      hnpoint hmeandev z
    rw [if_pos hz] at hpoint
    exact sub_eq_zero.mp (abs_eq_zero.mp hpoint)
  have hg (z : ClippingCube m) : C.logicalProjection F z = reluStar zstar z := by
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · have hmass := congrFun hp z
      simp only [reluLiveMass, if_pos hz] at hmass
      change C.logicalProjection F z = reluReference z + pointIndicator zstar z
      rw [reluReference_on_coset H v z hv hz]
      linarith
    · have hne : z ≠ zstar := by intro h; subst z; exact hz hzstar
      rw [hcal z hz]
      change reluReference z = reluReference z + pointIndicator zstar z
      simp [pointIndicator, hne]
  funext x
  have hx := congrFun hres x
  have hF : F x = C.project F x := sub_eq_zero.mp hx
  rw [hF, project, hg]

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
