import NeuralGeneralization.FiniteProcessMax
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-!
# Actual maximum-column bound for independent finite selectors

An exponential-moment proof gives a logarithmic column maximum bound.
The selectors are literal independent draws from a finite uniform space;
their common selection probability is defined by its actual finite mean.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling

variable {α J : Type*} [Fintype α] [Nonempty α] [Fintype J] [Nonempty J]

def selector (b : α → Bool) (x : α) : ℝ := if b x then 1 else 0

theorem selector_nonneg (b : α → Bool) (x : α) : 0 ≤ selector b x := by
  unfold selector
  split_ifs <;> norm_num

def selectionProbability (b : α → Bool) : ℝ := finiteMean (selector b)

theorem selectionProbability_nonneg (b : α → Bool) : 0 ≤ selectionProbability b :=
  finiteMean_nonneg (selector_nonneg b)

theorem exp_unit_chord {x : ℝ} (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    Real.exp x ≤ 1+(Real.exp 1-1)*x := by
  have hh := convexOn_exp.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (1 : ℝ))
    (show 0 ≤ 1-x by linarith) hx (show (1-x)+x=1 by ring)
  simp only [smul_eq_mul, mul_zero, mul_one, zero_add, Real.exp_zero] at hh
  nlinarith only [hh]

theorem selector_exp_mean (b : α → Bool) (x : ℝ) :
    finiteMean (fun ω => Real.exp (selector b ω*x)) =
      1+selectionProbability b*(Real.exp x-1) := by
  have he (ω : α) : Real.exp (selector b ω*x) = 1+(Real.exp x-1)*selector b ω := by
    unfold selector
    cases hb : b ω <;> simp [hb]
  simp_rw [he]
  rw [finiteMean_add, finiteMean_const, finiteMean_mul]
  unfold selectionProbability
  ring

theorem selector_scalar_mgf (b : α → Bool) {y R : ℝ}
    (hy : 0 ≤ y) (hyR : y ≤ R) (hR : 0 < R) :
    finiteMean (fun ω => Real.exp (selector b ω*y/R)) ≤
      Real.exp ((Real.exp 1-1)*selectionProbability b*y/R) := by
  have hx : 0 ≤ y/R := div_nonneg hy hR.le
  have hx1 : y/R ≤ 1 := (div_le_one hR).mpr hyR
  have hp := selectionProbability_nonneg b
  have hchord := exp_unit_chord hx hx1
  have he : (fun ω => Real.exp (selector b ω*y/R)) =
      (fun ω => Real.exp (selector b ω*(y/R))) := by funext ω; congr 1; ring
  rw [he, selector_exp_mean]
  calc
    _ ≤ 1+selectionProbability b*((Real.exp 1-1)*(y/R)) := by nlinarith only [mul_nonneg hp (sub_nonneg.mpr hchord)]
    _ = 1+(Real.exp 1-1)*selectionProbability b*y/R := by ring
    _ ≤ _ := by simpa only [add_comm] using Real.add_one_le_exp ((Real.exp 1-1)*selectionProbability b*y/R)

theorem selector_sum_mgf (m : ℕ) (b : α → Bool) (v : Fin m → ℝ)
    {R C : ℝ} (hR : 0 < R) (hv : ∀ i, 0 ≤ v i) (hvR : ∀ i, v i ≤ R)
    (hC : (∑ i, v i) ≤ C) :
    finiteMean (fun s : Fin m → α => Real.exp ((∑ i, selector b (s i)*v i)/R)) ≤
      Real.exp ((Real.exp 1-1)*selectionProbability b*C/R) := by
  have he (s : Fin m → α) : Real.exp ((∑ i, selector b (s i)*v i)/R) =
      ∏ i, Real.exp (selector b (s i)*v i/R) := by rw [Finset.sum_div, Real.exp_sum]
  simp_rw [he]
  rw [finiteMean_pi_prod (fun i ω => Real.exp (selector b ω*v i/R))]
  calc
    _ ≤ ∏ i, Real.exp ((Real.exp 1-1)*selectionProbability b*v i/R) := by
      apply Finset.prod_le_prod
      · intro i hi
        exact finiteMean_nonneg (fun _ => (Real.exp_pos _).le)
      · intro i hi
        exact selector_scalar_mgf b (hv i) (hvR i) hR
    _ = Real.exp ((Real.exp 1-1)*selectionProbability b*(∑ i, v i)/R) := by
      rw [← Real.exp_sum, ← Finset.sum_div, ← Finset.mul_sum]
    _ ≤ _ := by
      apply Real.exp_le_exp.mpr
      apply div_le_div_of_nonneg_right _ hR.le
      apply mul_le_mul_of_nonneg_left hC
      have he : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
      exact mul_nonneg he (selectionProbability_nonneg b)

theorem exp_nonnegative_envelope_le_sum (f : J → ℝ) (hf : ∀ j, 0 ≤ f j) (t : ℝ) :
    Real.exp (t*envelope f) ≤ ∑ j, Real.exp (t*f j) := by
  classical
  obtain ⟨j, hj⟩ := Finite.exists_max (fun j => |f j|)
  rw [envelope_eq_of_max f j hj, abs_of_nonneg (hf j)]
  exact Finset.single_le_sum (fun k _ => (Real.exp_pos (t*f k)).le) (Finset.mem_univ j)

/-- A direct logarithmic bound for the actual largest selected column
energy. It applies in particular to `v i j = b i j ^ 2`. -/
theorem selector_column_maximum (m : ℕ) (b : α → Bool) (v : Fin m → J → ℝ)
    {R C : ℝ} (hR : 0 < R) (hv : ∀ i j, 0 ≤ v i j) (hvR : ∀ i j, v i j ≤ R)
    (hC : ∀ j, (∑ i, v i j) ≤ C) :
    finiteMean (fun s : Fin m → α => envelope (fun j => ∑ i, selector b (s i)*v i j)) ≤
      R*Real.log (Fintype.card J)+(Real.exp 1-1)*selectionProbability b*C := by
  let X := fun s : Fin m → α => fun j : J => ∑ i, selector b (s i)*v i j
  have hX (s : Fin m → α) (j : J) : 0 ≤ X s j :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (selector_nonneg b _) (hv i j))
  have hmax := finiteMean_mono (fun s : Fin m → α =>
    exp_nonnegative_envelope_le_sum (X s) (hX s) (1/R))
  rw [finiteMean_sum] at hmax
  have hterms (j : J) : finiteMean (fun s : Fin m → α => Real.exp ((1/R)*X s j)) ≤
      Real.exp ((Real.exp 1-1)*selectionProbability b*C/R) := by
    simpa only [X, one_div_mul_eq_div] using selector_sum_mgf m b (fun i => v i j) hR
      (fun i => hv i j) (fun i => hvR i j) (hC j)
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterms j)
  have hJ := exp_finiteMean_le (fun s : Fin m → α => (1/R)*envelope (X s))
  rw [finiteMean_mul] at hJ
  have hh := hJ.trans (hmax.trans hsum)
  have hc : (0 : ℝ) < Fintype.card J := Nat.cast_pos.mpr Fintype.card_pos
  have hrhs : (∑ _j : J, Real.exp ((Real.exp 1-1)*selectionProbability b*C/R)) =
      Real.exp (Real.log (Fintype.card J)+(Real.exp 1-1)*selectionProbability b*C/R) := by
    rw [Real.exp_add, Real.exp_log hc]
    simp
  rw [hrhs, Real.exp_le_exp, one_div_mul_eq_div] at hh
  have hmul := (div_le_iff₀ hR).mp hh
  have he : (Real.log (Fintype.card J)+(Real.exp 1-1)*selectionProbability b*C/R)*R =
      R*Real.log (Fintype.card J)+(Real.exp 1-1)*selectionProbability b*C := by
    field_simp
  exact hmul.trans_eq he

end NeuralGeneralization.SquaredSampling
