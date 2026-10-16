import NeuralGeneralization.CubeNoise

/-! An elementary finite second-moment lower bound, with explicit constants. -/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

theorem finite_weighted_paley_zygmund_half {ι : Type*} [Fintype ι]
    (p Y : ι → ℝ) (μ : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hpsum : ∑ x,p x = 1)
    (hY : ∀ x, 0 ≤ Y x) (hμ : 0 < μ)
    (hmean : ∑ x,p x*Y x = μ)
    (hsecond : ∑ x,p x*(Y x)^2 ≤ 2*μ^2) :
    (1 : ℝ)/8 ≤ ∑ x, if μ/2 ≤ Y x then p x else 0 := by
  classical
  let M : ℝ := ∑ x, if μ/2 ≤ Y x then p x else 0
  let H : ℝ := ∑ x, if μ/2 ≤ Y x then p x*Y x else 0
  have hM : 0 ≤ M := Finset.sum_nonneg fun x hx => by
    split_ifs
    · exact hp x
    · exact le_rfl
  have hH : 0 ≤ H := Finset.sum_nonneg fun x hx => by
    split_ifs
    · exact mul_nonneg (hp x) (hY x)
    · exact le_rfl
  have hpoint (x : ι) : p x*Y x ≤ (μ/2)*p x+
      (if μ/2 ≤ Y x then p x*Y x else 0) := by
    split_ifs with h
    · have hh := mul_nonneg (show 0 ≤ μ/2 by positivity) (hp x)
      linarith
    · have hh := mul_le_mul_of_nonneg_left (le_of_not_ge h) (hp x)
      linarith
  have htotal := Finset.sum_le_sum (fun x (_hx : x ∈ Finset.univ) => hpoint x)
  rw [hmean,Finset.sum_add_distrib,← Finset.mul_sum,hpsum,mul_one] at htotal
  change μ ≤ μ/2+H at htotal
  have hcs := Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
    (r := fun x => if μ/2 ≤ Y x then p x*Y x else 0)
    (f := fun x => if μ/2 ≤ Y x then p x else 0)
    (g := fun x => p x*(Y x)^2)
    (fun x hx => by split_ifs; exact hp x; exact le_rfl)
    (fun x hx => mul_nonneg (hp x) (sq_nonneg _))
    (fun x hx => by split_ifs <;> nlinarith)
  change H^2 ≤ M*(∑ x,p x*(Y x)^2) at hcs
  have hupper := mul_le_mul_of_nonneg_left hsecond hM
  change (1 : ℝ)/8 ≤ M
  have hμ2 := sq_pos_of_pos hμ
  have hhalf : μ/2 ≤ H := by linarith
  have hlower : μ^2/4 ≤ H^2 := by nlinarith
  nlinarith

end NeuralGeneralization
