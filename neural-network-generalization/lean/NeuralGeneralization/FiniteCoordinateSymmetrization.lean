import NeuralGeneralization.FiniteSymmetrization

/-! Actual symmetrization for independent uniform coordinates with possibly
different functions at each coordinate. In particular this covers arbitrary
rational Bernoulli selectors, encoded as subsets of a common finite domain. -/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators
variable {U α : Type*}

/-- Exact IID sample totals, before division by the sample size. -/
def coordinateTotal {n : ℕ} (F : Fin n → U → α → ℝ) (s : Fin n → α) (u : U) : ℝ :=
  ∑ i, F i u (s i)

/-- Uniform independent signs are represented by the full Boolean cube. -/
def signedCoordinateTotal {n : ℕ} (F : Fin n → U → α → ℝ) (ε : Fin n → Bool)
    (s : Fin n → α) (u : U) : ℝ :=
  ∑ i, cubeCoordinateSign (ε i) * F i u (s i)

lemma coordinateTotal_abs_le {n : ℕ} (F : Fin n → U → α → ℝ) {B : ℝ}
    (hF : ∀ i u x, |F i u x| ≤ B) (s : Fin n → α) (u : U) :
    |coordinateTotal F s u| ≤ (n : ℝ) * B := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ _i : Fin n, B := Finset.sum_le_sum (fun i _ => hF i u (s i))
    _ = _ := by simp

lemma signedCoordinateTotal_abs_le {n : ℕ} (F : Fin n → U → α → ℝ) {B : ℝ}
    (hF : ∀ i u x, |F i u x| ≤ B) (ε : Fin n → Bool) (s : Fin n → α) (u : U) :
    |signedCoordinateTotal F ε s u| ≤ (n : ℝ) * B := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ _i : Fin n, B := by
      apply Finset.sum_le_sum
      intro i _
      have hsign : |cubeCoordinateSign (ε i)| = 1 := by cases ε i <;> norm_num [cubeCoordinateSign]
      rw [abs_mul, hsign, one_mul]
      exact hF i u (s i)
    _ = _ := by simp

lemma coordinateTotal_signSwap {n : ℕ} (F : Fin n → U → α → ℝ) (ε : Fin n → Bool)
    (p : (Fin n → α) × (Fin n → α)) (u : U) :
    coordinateTotal F (signSwap ε p).1 u - coordinateTotal F (signSwap ε p).2 u =
      signedCoordinateTotal F ε p.1 u - signedCoordinateTotal F ε p.2 u := by
  unfold coordinateTotal signedCoordinateTotal
  rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases h : ε i <;> simp [signSwap, h, cubeCoordinateSign]
  ring

/-- Exact Rademacher symmetrization for any uniformly bounded, potentially
uncountable function class on a finite domain. Both IID observations and
Rademacher signs use their actual uniform product laws. -/
theorem finite_coordinate_symmetrization [Fintype α] [Nonempty α] [Nonempty U]
    (n : ℕ) (F : Fin n → U → α → ℝ) {B : ℝ} (hF : ∀ i u x, |F i u x| ≤ B) :
    finiteMean (fun s : Fin n → α =>
      envelope (fun u => coordinateTotal F s u -
        finiteMean (fun t : Fin n → α => coordinateTotal F t u))) ≤
      2 * finiteMean (fun ε : Fin n → Bool =>
        finiteMean (fun s : Fin n → α => envelope (signedCoordinateTotal F ε s))) := by
  have hghost := finite_ghost_symmetrization (coordinateTotal (n := n) F) (coordinateTotal_abs_le F hF)
  have hsigned (ε : Fin n → Bool) :
      finiteMean (fun s : Fin n → α => finiteMean (fun t : Fin n → α =>
        envelope (fun u => coordinateTotal F s u - coordinateTotal F t u))) ≤
      2 * finiteMean (fun s : Fin n → α => envelope (signedCoordinateTotal F ε s)) := by
    rw [← finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
      envelope (fun u => coordinateTotal F p.1 u - coordinateTotal F p.2 u))]
    rw [← finiteMean_equiv (signSwap ε) (fun p : (Fin n → α) × (Fin n → α) =>
      envelope (fun u => coordinateTotal F p.1 u - coordinateTotal F p.2 u))]
    simp_rw [coordinateTotal_signSwap]
    have hsub (p : (Fin n → α) × (Fin n → α)) :=
      envelope_sub_le (signedCoordinateTotal F ε p.1) (signedCoordinateTotal F ε p.2)
        (signedCoordinateTotal_abs_le F hF ε p.1) (signedCoordinateTotal_abs_le F hF ε p.2)
    apply (finiteMean_mono hsub).trans_eq
    have hleft : finiteMean (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedCoordinateTotal F ε p.1)) =
        finiteMean (fun s : Fin n → α => envelope (signedCoordinateTotal F ε s)) := by
      rw [finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedCoordinateTotal F ε p.1))]
      simp
    have hright : finiteMean (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedCoordinateTotal F ε p.2)) =
        finiteMean (fun s : Fin n → α => envelope (signedCoordinateTotal F ε s)) := by
      rw [finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedCoordinateTotal F ε p.2))]
      simp
    rw [finiteMean_add, hleft, hright]
    ring
  have havg := finiteMean_mono hsigned
  rw [finiteMean_const, finiteMean_mul] at havg
  exact hghost.trans havg


lemma finiteMean_coordinateTotal [Fintype α] [Nonempty α] (n : ℕ)
    (F : Fin n → U → α → ℝ) (u : U) :
    finiteMean (fun s : Fin n → α => coordinateTotal F s u) =
      ∑ i, finiteMean (F i u) := by
  unfold coordinateTotal
  rw [finiteMean_sum]
  simp_rw [finiteMean_pi_eval]

/-- Coordinate-dependent symmetrization centered at each actual marginal
mean. Both selector observations and auxiliary signs use literal finite
uniform product laws. -/
theorem finite_coordinate_symmetrization_centered [Fintype α] [Nonempty α] [Nonempty U]
    (n : ℕ) (F : Fin n → U → α → ℝ) {B : ℝ} (hF : ∀ i u x, |F i u x| ≤ B) :
    finiteMean (fun s : Fin n → α =>
      envelope (fun u => coordinateTotal F s u - ∑ i, finiteMean (F i u))) ≤
      2 * finiteMean (fun ε : Fin n → Bool =>
        finiteMean (fun s : Fin n → α => envelope (signedCoordinateTotal F ε s))) := by
  simpa only [finiteMean_coordinateTotal] using finite_coordinate_symmetrization n F hF

end NeuralGeneralization.SquaredSampling
