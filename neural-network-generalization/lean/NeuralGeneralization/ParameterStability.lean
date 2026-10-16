import NeuralGeneralization.Network
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Ring

/-!+# Parameter stability for the concrete network

This is a coordinatewise perturbation bound for actual network evaluations,
used to turn a bounded-width/bounded-weight compression theorem into a finite
function count. It makes no assumption about a Gaussian or learning limit.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

private theorem sum_abs_difference_le {ι : Type*} [Fintype ι]
    (u v : ι → ℝ) (b : ℝ) (h : ∀ i, |u i - v i| ≤ b) :
    |(∑ i, u i) - ∑ i, v i| ≤ (Fintype.card ι : ℝ) * b := by
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ i, |u i - v i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _ : ι, b := Finset.sum_le_sum fun i _ => h i
    _ = _ := by simp

theorem abs_inputVector {d : ℕ} (x : Cube d) (j : Fin (d + 1)) :
    |inputVector x j| = 1 := by
  induction j using Fin.cases <;> simp [inputVector]

theorem firstHidden_parameter_stability {d N r : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) (η : ℝ)
    (hclose : ∀ i, |w i - v i| ≤ η) (x : Cube d) (i : Fin N) :
    |firstHidden φ w x i - firstHidden φ v x i| ≤ (d + 1 : ℝ) * η := by
  apply le_trans (hφ.2 _ _)
  have hh := sum_abs_difference_le
    (fun j => w (Sum.inl (i, j)) * inputVector x j)
    (fun j => v (Sum.inl (i, j)) * inputVector x j) η (fun j => by
      rw [← sub_mul, abs_mul, abs_inputVector, mul_one]
      exact hclose _)
  simpa using hh

private theorem product_difference_bound (w v h k B η E : ℝ)
    (hη : 0 ≤ η) (_hE : 0 ≤ E)
    (hweight : |v| ≤ B) (hbounded : |h| ≤ 1)
    (hw : |w - v| ≤ η) (hh : |h - k| ≤ η * E) :
    |w * h - v * k| ≤ η * (1 + B * E) := by
  calc
    _ = |(w - v) * h + v * (h - k)| := by congr 1; ring
    _ ≤ |(w - v) * h| + |v * (h - k)| := abs_add_le _ _
    _ = |w - v| * |h| + |v| * |h - k| := by rw [abs_mul, abs_mul]
    _ ≤ η * 1 + B * (η * E) := by
      apply add_le_add
      · exact mul_le_mul hw hbounded (abs_nonneg _) hη
      · exact mul_le_mul hweight hh (abs_nonneg _) (le_trans (abs_nonneg _) hweight)
    _ = _ := by ring

/-- Sensitivity after one additional layer (or the linear readout). -/
def nextSensitivity (N : ℕ) (B E : ℝ) : ℝ :=
  (N : ℝ) * (1 + B * E)

theorem nextSensitivity_nonneg (N : ℕ) {B E : ℝ} (hB : 0 ≤ B) (hE : 0 ≤ E) :
    0 ≤ nextSensitivity N B E := by
  unfold nextSensitivity
  positivity

theorem hiddenStep_parameter_stability {d N r : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) (B η E : ℝ) (hη : 0 ≤ η) (hE : 0 ≤ E)
    (hv : boundedWeights B v) (hclose : ∀ i, |w i - v i| ≤ η)
    (h k : Fin N → ℝ) (hb : ∀ i, |h i| ≤ 1)
    (hh : ∀ i, |h i - k i| ≤ η * E) (s : Fin r) (i : Fin N) :
    |hiddenStep φ w h s i - hiddenStep φ v k s i| ≤
      η * nextSensitivity N B E := by
  apply le_trans (hφ.2 _ _)
  have hsum := sum_abs_difference_le
    (fun j => w (Sum.inr (Sum.inl (s, i, j))) * h j)
    (fun j => v (Sum.inr (Sum.inl (s, i, j))) * k j)
    (η * (1 + B * E)) (fun j =>
      product_difference_bound _ _ _ _ B η E hη hE (hv _) (hb j) (hclose _) (hh j))
  calc
    _ ≤ (N : ℝ) * (η * (1 + B * E)) := by simpa using hsum
    _ = _ := by unfold nextSensitivity; ring

def hiddenSensitivity (d N : ℕ) (B : ℝ) : ℕ → ℝ
  | 0 => d + 1
  | s + 1 => nextSensitivity N B (hiddenSensitivity d N B s)

theorem hiddenSensitivity_nonneg (d N s : ℕ) {B : ℝ} (hB : 0 ≤ B) :
    0 ≤ hiddenSensitivity d N B s := by
  induction s with
  | zero => dsimp [hiddenSensitivity]; positivity
  | succ s ih => exact nextSensitivity_nonneg N hB ih

/-- Bound after any specified list of actual internal layers. -/
theorem hiddenFold_parameter_stability {d N r : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) (B η : ℝ) (hB : 0 ≤ B) (hη : 0 ≤ η)
    (hv : boundedWeights B v) (hclose : ∀ i, |w i - v i| ≤ η)
    (ss : List (Fin r)) (x : Cube d) :
    ∀ i, |ss.foldl (hiddenStep φ w) (firstHidden φ w x) i -
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) i| ≤
        η * hiddenSensitivity d N B ss.length := by
  induction ss using List.reverseRecOn with
  | nil =>
      intro i
      simpa [hiddenSensitivity, mul_comm] using
        firstHidden_parameter_stability φ hφ w v η hclose x i
  | append_singleton ss s ih =>
      intro i
      simp only [List.foldl_append, List.foldl_cons, List.foldl_nil,
        List.length_append, List.length_singleton, hiddenSensitivity]
      apply hiddenStep_parameter_stability φ hφ w v B η _ hη
        (hiddenSensitivity_nonneg d N ss.length hB) hv hclose _ _ _ ih s i
      intro j
      cases ss using List.reverseRecOn with
      | nil => exact hφ.1 _
      | append_singleton tt t =>
          simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
          exact hφ.1 _

/-- A bound for the actual linear-readout output in terms of coordinate errors. -/
theorem networkOutput_parameter_stability {d N r : ℕ}
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) (B η : ℝ) (hB : 0 ≤ B) (hη : 0 ≤ η)
    (hv : boundedWeights B v) (hclose : ∀ i, |w i - v i| ≤ η)
    (x : Cube d) :
    |networkOutput φ w x - networkOutput φ v x| ≤
      η * nextSensitivity N B (hiddenSensitivity d N B r) := by
  have hhidden := hiddenFold_parameter_stability φ hφ w v B η hB hη hv hclose
    (List.finRange r) x
  simp only [List.length_finRange] at hhidden
  have hb (j : Fin N) : |finalHidden φ w x j| ≤ 1 := by
    unfold finalHidden
    generalize List.finRange r = ss
    cases ss using List.reverseRecOn with
    | nil => exact hφ.1 _
    | append_singleton tt t =>
        simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
        exact hφ.1 _
  have hs := sum_abs_difference_le
    (fun j => w (Sum.inr (Sum.inr j)) * finalHidden φ w x j)
    (fun j => v (Sum.inr (Sum.inr j)) * finalHidden φ v x j)
    (η * (1 + B * hiddenSensitivity d N B r)) (fun j =>
      product_difference_bound _ _ _ _ B η _ hη
        (hiddenSensitivity_nonneg d N r hB) (hv _) (hb j) (hclose _) (hhidden j))
  calc
    _ ≤ (N : ℝ) * (η * (1 + B * hiddenSensitivity d N B r)) := by simpa [networkOutput] using hs
    _ = _ := by unfold nextSensitivity; ring

end NeuralGeneralization.ConcreteModel
