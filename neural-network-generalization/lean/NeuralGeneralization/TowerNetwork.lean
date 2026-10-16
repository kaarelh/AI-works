import NeuralGeneralization.ConcreteReadoutDual
import NeuralGeneralization.ParameterCounting
import NeuralGeneralization.Activation

/-! Appending actual hidden layers and the final covariance readout. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.TowerNetwork
open ConcreteModel

/-- Append one ordinary hidden matrix to the existing finite network. -/
def appendLayer {d N r : ℕ} (w : Weights d N r) (A : Fin N → Fin N → ℝ) :
    Weights d N (r + 1)
  | .inl ij => w (.inl ij)
  | .inr (.inl (s, i, j)) => Fin.lastCases (A i j)
      (fun t => w (.inr (.inl (t, i, j)))) s
  | .inr (.inr j) => w (.inr (.inr j))

@[simp] theorem firstHidden_appendLayer {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (A : Fin N → Fin N → ℝ) (x : Cube d) :
    firstHidden φ (appendLayer w A) x = firstHidden φ w x := rfl

@[simp] theorem hiddenStep_appendLayer_castSucc {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (A : Fin N → Fin N → ℝ) (h : Fin N → ℝ) (s : Fin r) :
    hiddenStep φ (appendLayer w A) h s.castSucc = hiddenStep φ w h s := by
  ext i
  simp [hiddenStep, appendLayer]

@[simp] theorem hiddenStep_appendLayer_last {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (A : Fin N → Fin N → ℝ) (h : Fin N → ℝ) :
    hiddenStep φ (appendLayer w A) h (Fin.last r) =
      fun i => φ (∑ j, A i j * h j) := by
  ext i
  simp [hiddenStep, appendLayer]

/-- Appending the matrix has exactly the expected activation semantics. -/
theorem finalHidden_appendLayer {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (A : Fin N → Fin N → ℝ) (x : Cube d) :
    finalHidden φ (appendLayer w A) x =
      fun i => φ (∑ j, A i j * finalHidden φ w x j) := by
  simp only [finalHidden, List.finRange_succ_last, List.foldl_append, List.foldl_cons,
    List.foldl_nil, List.foldl_map, firstHidden_appendLayer]
  simp only [hiddenStep_appendLayer_castSucc, hiddenStep_appendLayer_last]

/-- Bounded parameters are preserved by appending a bounded matrix. -/
theorem appendLayer_bound {d N r : ℕ} (w : Weights d N r) (A : Fin N → Fin N → ℝ)
    {B : ℝ} (hw : ∀ i, |w i| ≤ B) (hA : ∀ i j, |A i j| ≤ B) :
    ∀ i, |appendLayer w A i| ≤ B := by
  intro i
  rcases i with ij | (⟨s, i, j⟩ | j)
  · exact hw _
  · refine Fin.lastCases ?_ (fun t => ?_) s
    · simpa [appendLayer] using hA i j
    · simpa [appendLayer] using hw (.inr (.inl (t, i, j)))
  · exact hw _

/-- Replacing only the final linear readout. -/
def withReadout {d N r : ℕ} (w : Weights d N r) (v : Fin N → ℝ) : Weights d N r
  | .inl ij => w (.inl ij)
  | .inr (.inl s) => w (.inr (.inl s))
  | .inr (.inr j) => v j

@[simp] theorem finalHidden_withReadout {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (v : Fin N → ℝ) (x : Cube d) :
    finalHidden φ (withReadout w v) x = finalHidden φ w x := by
  rfl

/-- The covariance dual is encoded in just N actual readout weights. -/
def covarianceReadout {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (β : Cube d → ℝ) : Fin N → ℝ :=
  fun i => (∑ x, β x * finalHidden φ w x i) / (N : ℝ)

theorem covarianceReadout_output {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (β : Cube d → ℝ) (x : Cube d) :
    networkOutput φ (withReadout w (covarianceReadout φ w β)) x =
      ∑ y, β y * finalCovariance φ w x y := by
  simp only [networkOutput, withReadout, finalHidden_withReadout, covarianceReadout,
    finalCovariance, Finset.sum_div, div_mul_eq_mul_div, mul_div_assoc, Finset.sum_mul,
    Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro y hy
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem finalHidden_tanh_abs_le_one {d N r : ℕ} (w : Weights d N r)
    (x : Cube d) (i : Fin N) : |finalHidden Real.tanh w x i| ≤ 1 := by
  have hinit : ∀ i, |firstHidden Real.tanh w x i| ≤ 1 :=
    fun i => (Real.abs_tanh_lt_one _).le
  have hstep (h : Fin N → ℝ) (s : Fin r) : ∀ i, |hiddenStep Real.tanh w h s i| ≤ 1 :=
    fun i => (Real.abs_tanh_lt_one _).le
  have hall (l : List (Fin r)) (h : Fin N → ℝ) (hh : ∀ j, |h j| ≤ 1) :
      ∀ j, |l.foldl (hiddenStep Real.tanh w) h j| ≤ 1 := by
    induction l generalizing h with
    | nil => exact hh
    | cons a l ih =>
      simp only [List.foldl_cons]
      exact ih _ (hstep _ a)
  exact hall _ _ hinit i

theorem covarianceReadout_bound {d N r : ℕ} (w : Weights d N r)
    (β : Cube d → ℝ) {K : ℝ} (hβ : (∑ x, |β x|) ≤ K)
    {i : Fin N} : |covarianceReadout Real.tanh w β i| ≤ K / (N : ℝ) := by
  unfold covarianceReadout
  rw [abs_div, abs_of_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ (N : ℝ))]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg N)
  calc
    _ ≤ ∑ x, |β x * finalHidden Real.tanh w x i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ x, |β x| := by
      apply Finset.sum_le_sum
      intro x hx
      rw [abs_mul]
      simpa using mul_le_mul_of_nonneg_left (finalHidden_tanh_abs_le_one w x i) (abs_nonneg _)
    _ ≤ K := hβ

end NeuralGeneralization.TowerNetwork
