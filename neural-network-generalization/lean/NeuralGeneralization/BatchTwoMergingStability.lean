import NeuralGeneralization.BatchTwoMergingGeometry
import NeuralGeneralization.ParameterStability

/-! # A sharp coefficient perturbation bound without bounded activations

The hidden states may be unbounded.  Only the activation's Lipschitz constant
and value at zero are used; this includes ReLU.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def LipschitzZero (φ : ℝ → ℝ) : Prop :=
  φ 0 = 0 ∧ ∀ a b, |φ a - φ b| ≤ |a - b|

theorem relu_lipschitzZero : LipschitzZero relu := by
  refine ⟨relu_zero, fun a b => ?_⟩
  simpa [relu, max_comm] using abs_max_sub_max_le_abs a b 0

theorem LipschitzZero.abs_le {φ : ℝ → ℝ} (hφ : LipschitzZero φ) (a : ℝ) :
    |φ a| ≤ |a| := by simpa [hφ.1] using hφ.2 a 0

private theorem sum_product_bound {I : Type*} [Fintype I]
    (u v : I → ℝ) {R B : ℝ} (hR : 0 ≤ R) (hB : 0 ≤ B)
    (hu : ∀ i, |u i| ≤ R) (hv : ∀ i, |v i| ≤ B) :
    |∑ i, u i * v i| ≤ (Fintype.card I : ℝ) * R * B := by
  calc
    _ ≤ ∑ i, |u i * v i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : I, R * B := Finset.sum_le_sum fun i _ => by
      rw [abs_mul]
      exact mul_le_mul (hu i) (hv i) (abs_nonneg _) hR
    _ = _ := by simp [mul_assoc]

private theorem sum_product_difference_bound {I : Type*} [Fintype I]
    (w v h k : I → ℝ) {R B η E : ℝ}
    (hR : 0 ≤ R) (hη : 0 ≤ η) (hE : 0 ≤ E)
    (hv : ∀ i, |v i| ≤ R) (hh : ∀ i, |h i| ≤ B)
    (hwv : ∀ i, |w i - v i| ≤ η) (hhk : ∀ i, |h i - k i| ≤ E) :
    |(∑ i, w i * h i) - ∑ i, v i * k i| ≤
      (Fintype.card I : ℝ) * (η * B + R * E) := by
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ i, |w i * h i - v i * k i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : I, (η * B + R * E) := by
      apply Finset.sum_le_sum
      intro i _
      calc
        _ = |(w i-v i)*h i + v i*(h i-k i)| := by congr 1; ring
        _ ≤ |w i-v i| *|h i| + |v i| *|h i-k i| := by
          simpa only [abs_mul] using abs_add_le ((w i-v i)*h i) (v i*(h i-k i))
        _ ≤ η*B + R*E := add_le_add
          (mul_le_mul (hwv i) (hh i) (abs_nonneg _) hη)
          (mul_le_mul (hv i) (hhk i) (abs_nonneg _) hR)
    _ = _ := by simp [mul_add]

/-- All intermediate activations are controlled by one geometric budget. -/
theorem hiddenFold_abs_le_power {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w : Weights d N r) {R A : ℝ}
    (hR : 0 ≤ R) (hA : 1 ≤ A) (hd : (d+1 : ℝ)*R ≤ A)
    (hNR : (N : ℝ)*R ≤ A) (hw : ∀ i, |w i| ≤ R)
    (ss : List (Fin r)) (x : Cube d) (i : Fin N) :
    |ss.foldl (hiddenStep φ w) (firstHidden φ w x) i| ≤ A^(ss.length+1) := by
  induction ss using List.reverseRecOn generalizing i with
  | nil =>
      simp only [List.foldl_nil, List.length_nil, zero_add, pow_one]
      apply (hφ.abs_le _).trans
      exact (sum_product_bound _ _ hR zero_le_one (fun j => hw _) (fun j => by
        rw [abs_inputVector])).trans (by simpa using hd)
  | append_singleton ss s ih =>
      simp only [List.foldl_append, List.foldl_cons, List.foldl_nil,
        List.length_append, List.length_singleton]
      apply (hφ.abs_le _).trans
      calc
        _ ≤ (N : ℝ)*R*A^(ss.length+1) := by
          simpa only [Fintype.card_fin] using
            sum_product_bound (fun j => w (Sum.inr (Sum.inl (s,i,j)))) _ hR
              (pow_nonneg (by linarith) _) (fun j => hw _) (fun j => ih j)
        _ ≤ A*A^(ss.length+1) := mul_le_mul_of_nonneg_right hNR (by positivity)
        _ = A^(ss.length+1+1) := by rw [pow_succ]; ring

/-- Perturbations grow geometrically in depth, but their logarithm is only
linear in depth; this is the finite-grid estimate needed for a polynomial
sample bound. -/
theorem hiddenFold_difference_le_power {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r) {R A η : ℝ}
    (hR : 0 ≤ R) (hA : 1 ≤ A) (hη : 0 ≤ η)
    (hdR : (d+1 : ℝ)*R ≤ A) (hd : (d+1 : ℝ) ≤ A)
    (hNR : (N : ℝ)*R ≤ A) (hN : (N : ℝ) ≤ A)
    (hw : ∀ i, |w i| ≤ R) (hv : ∀ i, |v i| ≤ R)
    (hclose : ∀ i, |w i-v i| ≤ η)
    (ss : List (Fin r)) (x : Cube d) (i : Fin N) :
    |ss.foldl (hiddenStep φ w) (firstHidden φ w x) i -
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) i| ≤
        η*(ss.length+1)*A^(ss.length+1) := by
  induction ss using List.reverseRecOn generalizing i with
  | nil =>
      simp only [List.foldl_nil, List.length_nil, Nat.cast_zero, zero_add, mul_one,
        pow_one]
      apply (hφ.2 _ _).trans
      rw [← Finset.sum_sub_distrib]
      calc
        _ ≤ ∑ j, |w (Sum.inl (i,j))*inputVector x j -
            v (Sum.inl (i,j))*inputVector x j| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _j : Fin (d+1), η := Finset.sum_le_sum fun j _ => by
          rw [← sub_mul, abs_mul, abs_inputVector, mul_one]; exact hclose _
        _ = (d+1 : ℝ)*η := by simp
        _ ≤ η*A := by nlinarith
  | append_singleton ss s ih =>
      simp only [List.foldl_append, List.foldl_cons, List.foldl_nil,
        List.length_append, List.length_singleton]
      apply (hφ.2 _ _).trans
      calc
        _ ≤ (N : ℝ)*(η*A^(ss.length+1) +
            R*(η*(ss.length+1)*A^(ss.length+1))) :=
          by
          simpa only [Fintype.card_fin] using
            sum_product_difference_bound (fun j => w (Sum.inr (Sum.inl (s,i,j))))
              (fun j => v (Sum.inr (Sum.inl (s,i,j)))) _ _ hR hη (by positivity)
              (fun j => hv _) (fun j => hiddenFold_abs_le_power hφ w hR hA hdR hNR hw ss x j)
              (fun j => hclose _) (fun j => ih j)
        _ = η*((N : ℝ) + ((N : ℝ)*R)*(ss.length+1))*A^(ss.length+1) := by ring
        _ ≤ η*(A+A*(ss.length+1))*A^(ss.length+1) := by
          apply mul_le_mul_of_nonneg_right _ (by positivity)
          apply mul_le_mul_of_nonneg_left _ hη
          exact add_le_add hN (mul_le_mul_of_nonneg_right hNR (by positivity))
        _ = η*(↑(ss.length+1)+1)*A^(ss.length+1+1) := by
          rw [pow_succ]; push_cast; ring

theorem networkOutput_difference_le_power {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) (w v : Weights d N r) {R A η : ℝ}
    (hR : 0 ≤ R) (hA : 1 ≤ A) (hη : 0 ≤ η)
    (hdR : (d+1 : ℝ)*R ≤ A) (hd : (d+1 : ℝ) ≤ A)
    (hNR : (N : ℝ)*R ≤ A) (hN : (N : ℝ) ≤ A)
    (hw : ∀ i, |w i| ≤ R) (hv : ∀ i, |v i| ≤ R)
    (hclose : ∀ i, |w i-v i| ≤ η) (x : Cube d) :
    |networkOutput φ w x - networkOutput φ v x| ≤ η*(r+2)*A^(r+2) := by
  have hb := hiddenFold_abs_le_power hφ w hR hA hdR hNR hw (List.finRange r) x
  have he := hiddenFold_difference_le_power hφ w v hR hA hη hdR hd hNR hN hw hv
    hclose (List.finRange r) x
  simp only [List.length_finRange] at hb he
  calc
    _ ≤ (N : ℝ)*(η*A^(r+1) + R*(η*(r+1)*A^(r+1))) :=
      by
      simpa only [networkOutput, finalHidden, Fintype.card_fin] using
        sum_product_difference_bound (fun j => w (Sum.inr (Sum.inr j)))
          (fun j => v (Sum.inr (Sum.inr j))) _ _ hR hη (by positivity)
          (fun j => hv _) hb (fun j => hclose _) he
    _ = η*((N : ℝ) + ((N : ℝ)*R)*(r+1))*A^(r+1) := by ring
    _ ≤ η*(A+A*(r+1))*A^(r+1) := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      apply mul_le_mul_of_nonneg_left _ hη
      exact add_le_add hN (mul_le_mul_of_nonneg_right hNR (by positivity))
    _ = η*(r+2)*A^(r+2) := by rw [show r+2=r+1+1 by omega, pow_succ]; push_cast; ring

end NeuralGeneralization.BatchTwoMerging
