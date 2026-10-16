import NeuralGeneralization.GaussianCoordinateIntegration
import Mathlib.Data.Fintype.Card

/-! The Gaussian Prékopa--Leindler inequality on every actual finite
independent Gaussian product, proved by coordinate induction. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
namespace NeuralGeneralization.PrekopaLeindlerProduct
open PrekopaLeindlerInterval PrekopaLeindlerGaussian GaussianCoordinateIntegration
universe u

def ProductPL (I : Type*) [Fintype I] : Prop :=
  ∀ (f g h : (I → ℝ) → ℝ) (t : ℝ),
    Continuous f → Continuous g → Continuous h →
    (∀ x, 0 < f x) → (∀ x, 0 < g x) → (∀ x, 0 < h x) →
    (∀ x, f x ≤ 1) → (∀ x, g x ≤ 1) → (∀ x, h x ≤ 1) →
    t ∈ Icc 0 1 →
    (∀ x y, f x ^ (1-t) * g y ^ t ≤ h (mixVec t x y)) →
    (∫ x, f x ∂law I) ^ (1-t) * (∫ x, g x ∂law I) ^ t ≤ ∫ x, h x ∂law I

set_option maxHeartbeats 600000 in
theorem productPL (I : Type u) [Fintype I] : ProductPL I := by
  classical
  have main : ∀ n, ∀ (J : Type u) [Fintype J], Fintype.card J = n → ProductPL J := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro J _ hcard f g h t hf hg hh hfpos hgpos hhpos hfB hgB hhB ht hpoint
      by_cases he : IsEmpty J
      · letI := he
        have hi (q : (J → ℝ) → ℝ) : (∫ x, q x ∂law J) = q 0 := by
          calc
            _ = ∫ _ : J → ℝ, q 0 ∂law J := by
              apply integral_congr_ae
              exact Eventually.of_forall fun x => congrArg q (Subsingleton.elim x 0)
            _ = _ := by simp
        rw [hi f, hi g, hi h]
        have hm : mixVec t (0 : J → ℝ) 0 = 0 := Subsingleton.elim _ _
        simpa only [hm] using hpoint 0 0
      · haveI : Nonempty J := not_isEmpty_iff.mp he
        let i : J := Classical.choice inferInstance
        let K := {j : J // j ≠ i}
        have hlt : Fintype.card K < n := by
          rw [← hcard]
          exact Fintype.card_subtype_lt (x := i) (not_not.mpr rfl)
        have houter := ih (Fintype.card K) hlt K rfl
        have hinner (y z : K → ℝ) :
            marginal i f y ^ (1-t) * marginal i g z ^ t ≤
              marginal i h (mixVec t y z) := by
          apply prekopa_leindler_gaussian
            (hf.comp ((continuous_split_symm i).comp (continuous_id.prodMk continuous_const)))
            (hg.comp ((continuous_split_symm i).comp (continuous_id.prodMk continuous_const)))
            (hh.comp ((continuous_split_symm i).comp (continuous_id.prodMk continuous_const)))
            (fun _ => hfpos _) (fun _ => hgpos _) 1 1 1
            (fun _ => by dsimp only [Function.comp_def, id_eq]; rw [abs_of_pos (hfpos _)]; exact hfB _)
            (fun _ => by dsimp only [Function.comp_def, id_eq]; rw [abs_of_pos (hgpos _)]; exact hgB _)
            (fun _ => by dsimp only [Function.comp_def, id_eq]; rw [abs_of_pos (hhpos _)]; exact hhB _) ht
          intro a b
          dsimp only [Function.comp_def, id_eq]
          rw [split_symm_mix]
          exact hpoint _ _
        have hout := houter (marginal i f) (marginal i g) (marginal i h) t
          (continuous_marginal i hf hfpos hfB) (continuous_marginal i hg hgpos hgB)
          (continuous_marginal i hh hhpos hhB)
          (marginal_pos i hf hfpos hfB) (marginal_pos i hg hgpos hgB)
          (marginal_pos i hh hhpos hhB)
          (marginal_le_one i hf hfpos hfB) (marginal_le_one i hg hgpos hgB)
          (marginal_le_one i hh hhpos hhB) ht hinner
        dsimp only [K] at hout
        rw [integral_marginal i hf hfpos hfB, integral_marginal i hg hgpos hgB,
          integral_marginal i hh hhpos hhB] at hout
        exact hout
  exact main (Fintype.card I) I rfl

theorem prekopa_leindler_product {I : Type*} [Fintype I]
    {f g h : (I → ℝ) → ℝ} {t : ℝ}
    (hf : Continuous f) (hg : Continuous g) (hh : Continuous h)
    (hfpos : ∀ x, 0 < f x) (hgpos : ∀ x, 0 < g x) (hhpos : ∀ x, 0 < h x)
    (hfB : ∀ x, f x ≤ 1) (hgB : ∀ x, g x ≤ 1) (hhB : ∀ x, h x ≤ 1)
    (ht : t ∈ Icc 0 1)
    (hpoint : ∀ x y, f x ^ (1-t) * g y ^ t ≤ h (mixVec t x y)) :
    (∫ x, f x ∂law I) ^ (1-t) * (∫ x, g x ∂law I) ^ t ≤ ∫ x, h x ∂law I :=
  productPL I f g h t hf hg hh hfpos hgpos hhpos hfB hgB hhB ht hpoint

end NeuralGeneralization.PrekopaLeindlerProduct
end
