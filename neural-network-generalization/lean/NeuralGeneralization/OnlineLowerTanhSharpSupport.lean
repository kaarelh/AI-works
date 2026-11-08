import NeuralGeneralization.OnlineLowerTanhSharpParity
import NeuralGeneralization.OnlineLowerTanhCodeSupport

/-! # Sharp arbitrary-affine parity atoms and quantitative support stability -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- The actual affine tanh coefficient obeys the balanced sharp cost. Its
deficit controls the incoming bias and all coordinates outside the parity.
The coefficient and the energy are the literal physical finite-cube ones. -/
theorem exists_sharp_affine_support_threshold :
    ∃ n₀ : ℕ,∀ d : ℕ,∀ A : Finset (Fin d),n₀ ≤ A.card → Odd A.card →
      ∀ u : Fin d → ℝ,∀ b : ℝ,
      let w := balancedCost (A.card/2)
      let r := Real.sqrt (b^2+incomingEnergy u)
      let q := w*|walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) A|
      q ≤ r ∧ b^2+(∑ i ∈ Aᶜ,(u i)^2) ≤ 4608*(A.card:ℝ)^2*r*(r-q) := by
  obtain ⟨n₀,hn₀⟩ := exists_intrinsicParityBound_threshold
  refine ⟨n₀,?_⟩
  intro d A hlarge hodd u b
  have hs := intrinsicParityBound_physical_support A hodd (balancedCost (A.card/2))
    (balancedCost_pos _).le (hn₀ A.card hlarge hodd) u b
  dsimp only at hs ⊢
  refine ⟨hs.1,hs.2.trans ?_⟩
  have hn : 1 ≤ A.card := by obtain ⟨r,hr⟩:=hodd;omega
  have hnR : (1:ℝ) ≤ A.card := by exact_mod_cast hn
  have hdegree : 2*(A.card/2)+1=A.card := by
    obtain ⟨r,hr⟩ := hodd
    omega
  have hw : balancedCost (A.card/2) ≤ 4*(A.card:ℝ) := by
    simpa only [hdegree] using balancedCost_le_four_degree (A.card/2)
  have hc : max (2:ℝ) (288*(balancedCost (A.card/2))^2) ≤ 4608*(A.card:ℝ)^2 := by
    apply max_le
    · nlinarith [sq_nonneg ((A.card:ℝ)-1)]
    · have hp := balancedCost_pos (A.card/2)
      have hw2 := (sq_le_sq₀ hp.le (by positivity : (0:ℝ) ≤ 4*(A.card:ℝ))).mpr hw
      nlinarith
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_right hc (Real.sqrt_nonneg _)) (sub_nonneg.mpr hs.1)

end NeuralGeneralization.OnlineLowerTanh
